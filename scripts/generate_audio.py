#!/usr/bin/env python3
import asyncio
import json
import re
import subprocess
from pathlib import Path

DATA_DIR = Path("assets/data")
AUDIO_DIR = Path("assets/audio")
VOICE_EN = "en-US-AnaNeural"
VOICE_MY = "my-MM-NilarNeural"


def clean_myanmar_text(text: str) -> str:
    t = text.strip()
    m = re.match(r"^[၀-၉]+\s*\((.+)\)$", t)
    if m:
        t = m.group(1).strip()
    t = t.replace("→", " မှ ").replace("/", " သို့မဟုတ် ").replace(" - ", " ၊ ")
    return t


def collect_audio_tasks() -> list[tuple[str, str, str]]:
    tasks: dict[str, tuple[str, str]] = {}

    for json_name in ("grade1_lessons.json", "grade2_lessons.json"):
        path = DATA_DIR / json_name
        if not path.exists():
            continue
        data = json.loads(path.read_text(encoding="utf-8"))
        for lesson in data.get("lessons", []):
            for item in lesson.get("items", []):
                ak = item.get("audioKey", "").strip()
                en = item.get("english", "").strip()
                my = clean_myanmar_text(item.get("myanmar", ""))
                if ak and en:
                    tasks[ak] = (en, "en")
                if ak and my:
                    tasks[f"{ak}_my"] = (my, "my")

                ex_k = item.get("exampleAudioKey", "").strip()
                ex_en = item.get("exampleEn", "").strip()
                ex_my = clean_myanmar_text(item.get("exampleMy", ""))
                if ex_k and ex_en:
                    tasks[ex_k] = (ex_en, "en")
                if ex_k and ex_my:
                    tasks[f"{ex_k}_my"] = (ex_my, "my")

    daily_path = DATA_DIR / "daily_english.json"
    if daily_path.exists():
        daily_data = json.loads(daily_path.read_text(encoding="utf-8"))
        for phrase in daily_data.get("phrases", []):
            ak = phrase.get("audioKey", "").strip()
            en = phrase.get("english", "").strip()
            my = clean_myanmar_text(phrase.get("myanmar", ""))
            if ak and en:
                tasks[ak] = (en, "en")
            if ak and my:
                tasks[f"{ak}_my"] = (my, "my")
            res_en = phrase.get("responseEn", "").strip()
            res_my = clean_myanmar_text(phrase.get("responseMy", ""))
            if ak and res_en:
                tasks[f"{ak}_res"] = (res_en, "en")
            if ak and res_my:
                tasks[f"{ak}_res_my"] = (res_my, "my")

    return [(k, v[0], v[1]) for k, v in tasks.items()]


def generate_with_espeak(text: str, lang: str, out_mp3: Path) -> None:
    wav_tmp = out_mp3.with_suffix(".wav")
    voice_code = "my" if lang == "my" else "en-us"
    subprocess.run(
        ["espeak-ng", "-s", "135", "-v", voice_code, "-w", str(wav_tmp), text],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    subprocess.run(
        [
            "ffmpeg", "-y", "-i", str(wav_tmp),
            "-codec:a", "libmp3lame", "-b:a", "40k", str(out_mp3),
        ],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    if wav_tmp.exists():
        wav_tmp.unlink()


async def generate_one(sem: asyncio.Semaphore, key: str, text: str, lang: str) -> None:
    out_mp3 = AUDIO_DIR / f"{key}.mp3"
    if out_mp3.exists() and out_mp3.stat().st_size > 200:
        return
    voice = VOICE_MY if lang == "my" else VOICE_EN
    rate = "-5%" if lang == "my" else "-10%"

    async with sem:
        for attempt in range(3):
            try:
                import edge_tts
                communicate = edge_tts.Communicate(text=text, voice=voice, rate=rate)
                await communicate.save(str(out_mp3))
                if out_mp3.exists() and out_mp3.stat().st_size > 200:
                    return
            except Exception:
                await asyncio.sleep(0.5 * (attempt + 1))
        try:
            generate_with_espeak(text, lang, out_mp3)
        except Exception as err:
            print(f"[WARN] Could not synthesize {key} ({lang}): {err}")


async def main() -> None:
    AUDIO_DIR.mkdir(parents=True, exist_ok=True)
    tasks = collect_audio_tasks()
    print(f"Found {len(tasks)} bilingual (EN + MY) audio entries to bundle.")
    sem = asyncio.Semaphore(12)
    await asyncio.gather(*(generate_one(sem, k, t, l) for k, t, l in tasks))
    generated = len(list(AUDIO_DIR.glob("*.mp3")))
    print(f"Offline bilingual audio bundle ready: {generated} MP3 files in {AUDIO_DIR}")


if __name__ == "__main__":
    asyncio.run(main())
