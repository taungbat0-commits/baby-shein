#!/usr/bin/env python3
import json
import re
import subprocess
import sys
from pathlib import Path

CAT_PATH = Path("content_packs/catalog.json")


def get_repo_slug() -> str:
    out = subprocess.check_output(["git", "remote", "get-url", "origin"], text=True).strip()
    m = re.search(r"github\.com[:/]([^/]+/[^/.]+?)(?:\.git)?$", out)
    if not m:
        print("❌ GitHub repo URL မတွေ့ပါ")
        sys.exit(1)
    return m.group(1)


def main() -> None:
    slug = get_repo_slug()
    cat = json.loads(CAT_PATH.read_text(encoding="utf-8")) if CAT_PATH.exists() else {"packs": []}
    cur = cat.get("appUpdate") or {}

    print("=== 🚀 Baby Shein App Update ထုတ်ပြန်ရန် ===")
    if cur.get("latestVersionCode"):
        print(f"လက်ရှိကြေညာထားသော Version: v{cur.get('latestVersionName')} (Build {cur.get('latestVersionCode')})")
    else:
        print("လက်ရှိ Update ကြေညာထားခြင်း မရှိသေးပါ")
    print("(Update Popup ပိတ်ချင်ရင် 0 ရိုက်ထည့်ပါ)\n")

    raw_code = input("ဖြန့်ချင်တဲ့ Build Number (ဥပမာ v1.0.15 ဆို 15): ").strip()
    if not raw_code.isdigit():
        print("❌ ဂဏန်းပဲ ရိုက်ထည့်ပေးပါ")
        return

    code = int(raw_code)
    if code == 0:
        cat["appUpdate"] = {
            "latestVersionCode": 0,
            "latestVersionName": "",
            "apkUrl": "",
            "releaseNotesEn": "",
            "releaseNotesMy": "",
            "forceUpdate": False,
        }
        msg = "Disable app update popup [skip ci]"
    else:
        ver_name = f"1.0.{code}"
        tag = f"v{ver_name}"
        apk_url = f"https://github.com/{slug}/releases/download/{tag}/baby-shein-{tag}.apk"

        notes_my = input("အသစ်ပါဝင်ချက် (Myanmar) [Enter = ပုံမှန်စာသား]: ").strip()
        if not notes_my:
            notes_my = "ဂိမ်းအသစ်များနှင့် တိုးတက်ပြင်ဆင်ချက်အသစ်များ ပါဝင်ပါသည်။"

        force_in = input("မဖြစ်မနေ Update တင်ခိုင်းမလား (Force Update)? (y/n) [n]: ").strip().lower()
        force = force_in in ("y", "yes")

        cat["appUpdate"] = {
            "latestVersionCode": code,
            "latestVersionName": ver_name,
            "apkUrl": apk_url,
            "releaseNotesEn": f"Baby Shein {tag} update is now available.",
            "releaseNotesMy": notes_my,
            "forceUpdate": force,
        }
        msg = f"Publish app update {tag} [skip ci]"
        print(f"\n📦 Release Link: {apk_url}")

    CAT_PATH.write_text(json.dumps(cat, ensure_ascii=False, indent=2), encoding="utf-8")
    print("✅ content_packs/catalog.json ပြင်ပြီးပါပြီ")

    if input("GitHub ပေါ် အခု Push တင်ပြီး User တွေဆီ ကြေညာမလား? (y/n) [y]: ").strip().lower() in ("", "y", "yes"):
        subprocess.run(["git", "add", str(CAT_PATH)], check=True)
        subprocess.run(["git", "commit", "-m", msg], check=True)
        subprocess.run(["git", "pull", "--rebase", "--autostash"], check=True)
        subprocess.run(["git", "push", "-u", "origin", "main"], check=True)
        print("🚀 User တွေဆီ Update သတိပေးစာ လွှတ်ပြီးပါပြီ!")


if __name__ == "__main__":
    main()
