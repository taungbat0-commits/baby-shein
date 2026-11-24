#!/usr/bin/env python3
import json, re, subprocess, sys
from datetime import datetime
from pathlib import Path

PACKS_DIR = Path("content_packs")
CATALOG_PATH = PACKS_DIR / "catalog.json"
COLORS = [0xFF4FB3FF, 0xFFFF7AA2, 0xFF38C98F, 0xFFFF9B6A, 0xFF9B7BFF, 0xFFFFCA3A]


def get_repo_slug() -> str:
    out = subprocess.check_output(["git", "remote", "get-url", "origin"], text=True).strip()
    m = re.search(r"github\.com[:/]([^/]+/[^/.]+?)(?:\.git)?$", out)
    if not m:
        raise RuntimeError("GitHub remote origin မတွေ့ပါ")
    return m.group(1)


def slugify(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_") or f"pack_{int(datetime.now().timestamp())}"


def main() -> None:
    if len(sys.argv) < 2:
        print("သုံးနည်း: python3 scripts/import_pack.py <json_file_path>")
        sys.exit(1)

    src = Path(sys.argv[1]).expanduser()
    if not src.exists():
        print(f"❌ ဖိုင်မတွေ့ပါ: {src}")
        sys.exit(1)

    raw = json.loads(src.read_text(encoding="utf-8"))
    cat = json.loads(CATALOG_PATH.read_text(encoding="utf-8")) if CATALOG_PATH.exists() else {"announcement": {}, "packs": []}
    base_url = f"https://raw.githubusercontent.com/{get_repo_slug()}/main/content_packs"
    packs = cat.get("packs", [])
    color_hex = raw.get("colorHex") or COLORS[len(packs) % len(COLORS)]

    if "lessons" in raw or "phrases" in raw:
        out_data = raw
        if "lessons" in raw and raw["lessons"]:
            l0 = raw["lessons"][0]
            title_en = raw.get("titleEn") or l0["titleEn"]
            title_my = raw.get("titleMy") or l0["titleMy"]
            grade = int(raw.get("grade") or l0.get("grade", 1))
            icon = raw.get("icon") or l0.get("icon", "📚")
            desc_my = raw.get("descriptionMy") or l0.get("descriptionMy", title_my)
            pack_type = "lesson"
            count = sum(len(l.get("items", [])) for l in raw["lessons"])
        else:
            title_en = raw.get("titleEn") or src.stem.replace("_", " ").title()
            title_my = raw.get("titleMy") or title_en
            grade = int(raw.get("grade", 1))
            icon = raw.get("icon", "💬")
            desc_my = raw.get("descriptionMy") or title_my
            pack_type = "daily"
            count = len(raw.get("phrases", []))
        pack_id = raw.get("id") or f"pack_{slugify(title_en)}"
    else:
        title_en = raw["titleEn"]
        title_my = raw.get("titleMy", title_en)
        grade = int(raw.get("grade", 1))
        icon = raw.get("icon", "📚")
        desc_my = raw.get("descriptionMy", f"{title_my} သင်ခန်းစာအသစ်")
        slug = slugify(title_en)
        pack_id = raw.get("id") or f"pack_g{grade}_{slug}"
        items = []
        for idx, it in enumerate(raw.get("items", []), 1):
            iid = it.get("id") or f"{slug}_{idx}"
            en = it["english"].strip()
            my = it["myanmar"].strip()
            items.append({
                "id": iid,
                "english": en,
                "myanmar": my,
                "phonetic": it.get("phonetic", ""),
                "emoji": it.get("emoji", icon),
                "audioKey": it.get("audioKey", iid),
                "exampleEn": it.get("exampleEn", f"This is {en.lower()}."),
                "exampleMy": it.get("exampleMy", f"ဒါ {my} ပါ။"),
                "exampleAudioKey": it.get("exampleAudioKey", f"{iid}_ex"),
            })
        out_data = {
            "lessons": [{
                "id": f"lesson_{pack_id}",
                "grade": grade,
                "order": 20 + len(packs),
                "titleEn": title_en,
                "titleMy": f"{title_my} (အသစ်)",
                "descriptionEn": raw.get("descriptionEn", f"New {title_en} lesson."),
                "descriptionMy": desc_my,
                "icon": icon,
                "colorHex": color_hex,
                "category": raw.get("category", "vocabulary"),
                "items": items,
            }]
        }
        pack_type = "lesson"
        count = len(items)

    PACKS_DIR.mkdir(parents=True, exist_ok=True)
    dest = PACKS_DIR / f"{pack_id}.json"
    dest.write_text(json.dumps(out_data, ensure_ascii=False, indent=2), encoding="utf-8")

    old = next((p for p in packs if p["id"] == pack_id), None)
    ver = (old["version"] + 1) if old else 1
    packs = [p for p in packs if p["id"] != pack_id]
    packs.insert(0, {
        "id": pack_id,
        "version": ver,
        "titleEn": title_en,
        "titleMy": title_my,
        "descriptionEn": f"{count} items with EN + MY audio.",
        "descriptionMy": f"{desc_my} ({count} ခု • EN+MY အသံပါ)",
        "grade": grade,
        "type": pack_type,
        "icon": icon,
        "colorHex": color_hex,
        "sizeLabel": f"~{max(12, count * 28)} KB",
        "downloadUrl": f"{base_url}/{pack_id}.json",
    })
    cat["packs"] = packs
    cat["announcement"] = {
        "id": f"notice_{datetime.now().strftime('%Y%m%d_%H%M')}",
        "titleEn": f"New Lesson: {title_en}!",
        "titleMy": f"သင်ခန်းစာအသစ် - {title_my} ရောက်နေပြီ!",
        "messageEn": f"Tap to download {title_en} with EN & MY audio.",
        "messageMy": f"{title_my} (EN+MY အသံပါ) ကို နှိပ်ပြီး Download ဆွဲထည့်နိုင်ပါပြီ။",
    }
    CATALOG_PATH.write_text(json.dumps(cat, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"✅ Imported: {dest} (v{ver}, {count} items)")

    if input("GitHub ပေါ် အခု Push တင်မလား? (y/n) [y]: ").strip().lower() in ("", "y", "yes"):
        subprocess.run(["git", "add", "content_packs/"], check=True)
        subprocess.run(["git", "commit", "-m", f"Import pack: {title_en} v{ver}"], check=True)
        subprocess.run(["git", "pull", "--rebase"], check=False)
        subprocess.run(["git", "push", "-u", "origin", "main"], check=True)
        print("🚀 GitHub ပေါ် တင်ပြီးပါပြီ! စက္ကန့် ၃၀ အတွင်း EN+MY MP3 အသံဖိုင်တွေ အလိုအလျောက် ထွက်လာပါမယ်။")


if __name__ == "__main__":
    main()
