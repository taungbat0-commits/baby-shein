#!/usr/bin/env python3
"""
Baby Shein - Interactive Content Pack & Notification Builder for Termux.
Run: python3 scripts/add_pack.py
"""

import json
import re
import subprocess
from datetime import datetime
from pathlib import Path

PACKS_DIR = Path("content_packs")
CATALOG_PATH = PACKS_DIR / "catalog.json"

COLORS = [0xFF4FB3FF, 0xFFFF7AA2, 0xFF38C98F, 0xFFFF9B6A, 0xFF9B7BFF, 0xFFFFCA3A]


def get_repo_slug() -> str:
    out = subprocess.check_output(["git", "remote", "get-url", "origin"], text=True).strip()
    m = re.search(r"github\.com[:/]([^/]+/[^/.]+?)(?:\.git)?$", out)
    if not m:
        raise RuntimeError("Could not detect GitHub repo from git remote origin")
    return m.group(1)


def load_catalog() -> dict:
    if CATALOG_PATH.exists():
        return json.loads(CATALOG_PATH.read_text(encoding="utf-8"))
    return {"announcement": {}, "packs": []}


def save_catalog(cat: dict) -> None:
    PACKS_DIR.mkdir(parents=True, exist_ok=True)
    CATALOG_PATH.write_text(json.dumps(cat, ensure_ascii=False, indent=2), encoding="utf-8")


def ask(prompt: str, default: str = "") -> str:
    suffix = f" [{default}]" if default else ""
    val = input(f"{prompt}{suffix}: ").strip()
    return val if val else default


def slugify(text: str) -> str:
    s = re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_")
    return s or f"pack_{int(datetime.now().timestamp())}"


def add_lesson_pack(cat: dict, base_url: str) -> str:
    print("\n--- သင်ခန်းစာ Pack အသစ်ထည့်ခြင်း ---")
    title_en = ask("Title (English, e.g. Vehicles)")
    title_my = ask("Title (Myanmar, e.g. ယာဉ်များ)")
    desc_my = ask("Short Description (Myanmar)", f"{title_my} သင်ခန်းစာအသစ်")
    grade = int(ask("Grade (1 or 2)", "1"))
    icon = ask("Emoji Icon", "🚗")
    pack_slug = slugify(title_en)
    pack_id = f"pack_g{grade}_{pack_slug}"
    lesson_id = f"lesson_{pack_id}"

    items = []
    print("\nစကားလုံးများ ထည့်ပါ (ပြီးသွားရင် English နေရာမှာ ဘာမှမရိုက်ဘဲ Enter ခေါက်ပါ)")
    idx = 1
    while True:
        print(f"\n[Word #{idx}]")
        en = input("  English word (Enter to finish): ").strip()
        if not en:
            break
        my = ask("  Myanmar meaning")
        em = ask("  Emoji", icon)
        ex_en = ask("  Example sentence (EN)", f"This is a {en.lower()}.")
        ex_my = ask("  Example sentence (MY)", f"ဒါ {my} ပါ။")
        item_id = f"{pack_slug}_{idx}"
        items.append({
            "id": item_id,
            "english": en,
            "myanmar": my,
            "phonetic": "",
            "emoji": em,
            "audioKey": item_id,
            "exampleEn": ex_en,
            "exampleMy": ex_my,
            "exampleAudioKey": f"{item_id}_ex",
        })
        idx += 1

    if not items:
        print("❌ စကားလုံး မထည့်ထားလို့ ရပ်လိုက်ပါတယ်။")
        return ""

    order = 20 + len(cat.get("packs", []))
    color_hex = COLORS[len(cat.get("packs", [])) % len(COLORS)]
    pack_data = {
        "lessons": [{
            "id": lesson_id,
            "grade": grade,
            "order": order,
            "titleEn": title_en,
            "titleMy": f"{title_my} (အသစ်)",
            "descriptionEn": f"New {title_en} lesson.",
            "descriptionMy": desc_my,
            "icon": icon,
            "colorHex": color_hex,
            "category": "vocabulary",
            "items": items,
        }]
    }

    pack_file = PACKS_DIR / f"{pack_id}.json"
    pack_file.write_text(json.dumps(pack_data, ensure_ascii=False, indent=2), encoding="utf-8")

    # Update or append pack entry
    packs = [p for p in cat.get("packs", []) if p["id"] != pack_id]
    packs.insert(0, {
        "id": pack_id,
        "version": 1,
        "titleEn": title_en,
        "titleMy": title_my,
        "descriptionEn": f"{len(items)} new words with EN + MY audio.",
        "descriptionMy": f"{desc_my} ({len(items)} လုံး + EN/MY အသံပါ)",
        "grade": grade,
        "type": "lesson",
        "icon": icon,
        "colorHex": color_hex,
        "sizeLabel": f"~{len(items) * 28} KB",
        "downloadUrl": f"{base_url}/{pack_id}.json",
    })
    cat["packs"] = packs

    notice_id = f"notice_{datetime.now().strftime('%Y%m%d_%H%M')}"
    cat["announcement"] = {
        "id": notice_id,
        "titleEn": f"New Lesson: {title_en}!",
        "titleMy": f"သင်ခန်းစာအသစ် - {title_my} ရောက်နေပြီ!",
        "messageEn": f"Tap to download {title_en} with English & Myanmar audio.",
        "messageMy": f"{title_my} (အင်္ဂလိပ်+မြန်မာအသံပါ) ကို နှိပ်ပြီး Download ဆွဲထည့်နိုင်ပါပြီ။",
    }
    save_catalog(cat)
    return f"Add new pack: {title_en}"


def add_daily_pack(cat: dict, base_url: str) -> str:
    print("\n--- Daily English စကားပြော Pack အသစ်ထည့်ခြင်း ---")
    title_en = ask("Pack Title (English, e.g. Polite Talk)")
    title_my = ask("Pack Title (Myanmar, e.g. ယဉ်ကျေးစွာပြောဆိုခြင်း)")
    icon = ask("Emoji Icon", "💬")
    pack_slug = slugify(title_en)
    pack_id = f"pack_daily_{pack_slug}"

    phrases = []
    idx = 1
    while True:
        print(f"\n[Phrase #{idx}]")
        en = input("  English phrase (Enter to finish): ").strip()
        if not en:
            break
        my = ask("  Myanmar translation")
        sit_en = ask("  Situation (EN)", "Daily")
        sit_my = ask("  Situation (MY)", "နေ့စဉ်")
        res_en = ask("  Reply (EN, optional)", "")
        res_my = ask("  Reply (MY, optional)", "")
        ak = f"daily_{pack_slug}_{idx}"
        phrases.append({
            "id": ak,
            "english": en,
            "myanmar": my,
            "situationEn": sit_en,
            "situationMy": sit_my,
            "emoji": icon,
            "audioKey": ak,
            "responseEn": res_en,
            "responseMy": res_my,
        })
        idx += 1

    if not phrases:
        print("❌ စကားပြော မထည့်ထားလို့ ရပ်လိုက်ပါတယ်။")
        return ""

    color_hex = COLORS[len(cat.get("packs", [])) % len(COLORS)]
    pack_file = PACKS_DIR / f"{pack_id}.json"
    pack_file.write_text(json.dumps({"phrases": phrases}, ensure_ascii=False, indent=2), encoding="utf-8")

    packs = [p for p in cat.get("packs", []) if p["id"] != pack_id]
    packs.insert(0, {
        "id": pack_id,
        "version": 1,
        "titleEn": title_en,
        "titleMy": title_my,
        "descriptionEn": f"{len(phrases)} daily phrases with EN + MY audio.",
        "descriptionMy": f"နေ့စဉ်သုံးစကားပြော {len(phrases)} ခု (EN/MY အသံပါ)",
        "grade": 1,
        "type": "daily",
        "icon": icon,
        "colorHex": color_hex,
        "sizeLabel": f"~{len(phrases) * 25} KB",
        "downloadUrl": f"{base_url}/{pack_id}.json",
    })
    cat["packs"] = packs

    notice_id = f"notice_{datetime.now().strftime('%Y%m%d_%H%M')}"
    cat["announcement"] = {
        "id": notice_id,
        "titleEn": f"New Daily English: {title_en}",
        "titleMy": f"စကားပြောအသစ် - {title_my}!",
        "messageEn": "Tap to download new daily phrases.",
        "messageMy": f"{title_my} ကို နှိပ်ပြီး Download ဆွဲထည့်နိုင်ပါပြီ။",
    }
    save_catalog(cat)
    return f"Add daily pack: {title_en}"


def update_announcement_only(cat: dict) -> str:
    print("\n--- သတိပေးစာ (Notification) ပို့ရန် ---")
    title_my = ask("ခေါင်းစဉ် (Myanmar)")
    msg_my = ask("အကြောင်းအရာ (Myanmar)")
    title_en = ask("Title (English)", "Baby Shein Notice")
    notice_id = f"notice_{datetime.now().strftime('%Y%m%d_%H%M')}"
    cat["announcement"] = {
        "id": notice_id,
        "titleEn": title_en,
        "titleMy": title_my,
        "messageEn": msg_my,
        "messageMy": msg_my,
    }
    save_catalog(cat)
    return f"Update announcement: {title_en}"


def main() -> None:
    slug = get_repo_slug()
    base_url = f"https://raw.githubusercontent.com/{slug}/main/content_packs"
    cat = load_catalog()

    print("\n=== Baby Shein Pack & Notification Manager ===")
    print("1) Add Lesson Pack (Grade 1 / Grade 2)")
    print("2) Add Daily English Pack")
    print("3) Send Notification / Announcement Only")
    choice = input("Choose (1/2/3): ").strip()

    if choice == "1":
        msg = add_lesson_pack(cat, base_url)
    elif choice == "2":
        msg = add_daily_pack(cat, base_url)
    elif choice == "3":
        msg = update_announcement_only(cat)
    else:
        print("Cancelled.")
        return

    if not msg:
        return

    print(f"\n✅ Saved locally! ({msg})")
    push_now = input("GitHub ပေါ် အခုတန်း Push တင်မလား? (y/n) [y]: ").strip().lower()
    if push_now in ("", "y", "yes"):
        subprocess.run(["git", "pull", "--rebase"], check=False)
        subprocess.run(["git", "add", "content_packs/"], check=True)
        subprocess.run(["git", "commit", "-m", msg], check=True)
        subprocess.run(["git", "push", "-u", "origin", "main"], check=True)
        print("🚀 GitHub ပေါ် တင်ပြီးပါပြီ! Pack Audio MP3 တွေကို Actions က စက္ကန့် ၃၀ အတွင်း အလိုအလျောက် ထုတ်ပေးပါလိမ့်မယ် (APK ထပ်မ Build ပါ)။")


if __name__ == "__main__":
    main()
