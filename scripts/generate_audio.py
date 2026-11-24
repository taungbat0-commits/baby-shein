#!/usr/bin/env python3
import asyncio
import json
import subprocess
from pathlib import Path

DATA_DIR = Path("assets/data")
AUDIO_DIR = Path("assets/audio")
VOICE = "en-US-AnaNeural"


def collect_audio_tasks() -> dict[str, str]:
    tasks: dict[str, str] = {}
    for json_name in ("grade1_lessons.json", "grade2_lessons.json"):
        path = DATA_DIR / json_name
        if not path.exists():
            continue
        data = json.loads(path.read_text(encoding="utf-8"))
        for lesson in data.get("lessons", []):
            for item in lesson.get("items", []):
                audio_key = item.get("audioKey")
                english = item.get("english", "").strip()
                if audio_key and english:
                    tasks[audio_key] = english
                ex_key = item.get("exampleAudioKey")
                ex_text = item.get("exampleEn", "").strip()
                if ex_key and ex_text:
                    tasks[ex_key] = ex_text

    daily_path = DATA_DIR / "daily_english.json"
    if daily_path.exists():
        daily_data = json.loads(daily_path.read_text(encoding="utf-8"))
        for phrase in daily_data.get("phrases", []):
            audio_key = phrase.get("audioKey")
            english = phrase.get("english", "").strip()
            if audio_key and english:
                tasks[audio_key] = english

    return tasks


def generate_with_espeak(text: str, out_mp3: Path) -> None:
    wav_tmp = out_mp3.with_suffix(".wav")
    subprocess.run(
        ["espeak-ng", "-s", "135", "-v", "en-us", "-w", str(wav_tmp), text],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    subprocess.run(
        [
            "ffmpeg", "-y", "-i", str(wav_tmp),
            "-codec:a", "libmp3lame", "-b:a", "48k", str(out_mp3),
        ],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    if wav_tmp.exists():
        wav_tmp.unlink()


async def generate_one(sem: asyncio.Semaphore, key: str, text: str) -> None:
    out_mp3 = AUDIO_DIR / f"{key}.mp3"
    if out_mp3.exists() and out_mp3.stat().st_size > 200:
        return
    async with sem:
        try:
            import edge_tts
            communicate = edge_tts.Communicate(text=text, voice=VOICE, rate="-10%")
            await communicate.save(str(out_mp3))
            if out_mp3.exists() and out_mp3.stat().st_size > 200:
                return
        except Exception:
            pass
        try:
            generate_with_espeak(text, out_mp3)
        except Exception as err:
            print(f"[WARN] Could not synthesize {key}: {err}")


async def main() -> None:
    AUDIO_DIR.mkdir(parents=True, exist_ok=True)
    tasks = collect_audio_tasks()
    print(f"Found {len(tasks)} audio entries to bundle.")
    sem = asyncio.Semaphore(6)
    await asyncio.gather(*(generate_one(sem, k, v) for k, v in tasks.items()))
    generated = len(list(AUDIO_DIR.glob("*.mp3")))
    print(f"Offline audio bundle ready: {generated} MP3 files in {AUDIO_DIR}")


if __name__ == "__main__":
    asyncio.run(main())
