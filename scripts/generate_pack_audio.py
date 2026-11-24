#!/usr/bin/env python3
"""
Scans all JSON files inside content_packs/ (except catalog.json) and
generates EN + MY MP3 pronunciation files into content_packs/audio/.
"""

import asyncio
import json
import re
import subprocess
from pathlib import Path

PACKS_DIR = Path("content_packs")
AUDIO_DIR = PACKS_DIR / "audio"
VOICE_EN = "en-US-AnaNeural"
VOICE_MY = "my-MM-NilarNeural"


def clean_myanmar(text: str) -> str:
    t = text.strip()
    m = re.match(r"^[၀-၉]+\s*\((.+)\)$", t)
    if m:
        t = m.group(1).strip()
    return t.replace("→", " မှ ").replace("/", " သို့မဟုတ် ").replace(" - ", " ၊ ")


def collect_pack_tasks() -> list[tuple[str, str, str]]:
    tasks: dict[str, tuple[str, str]] = {}
    if not PACKS_DIR.exists():
        return []

    for path in sorted(PACKS_DIR.glob("*.json")):
        if path.name == "catalog.json":
            continue
        data = json.loads(path.read_text(encoding="utf-8"))

        for lesson in data.get("lessons", []):
            for item in lesson.get("items", []):
                ak = (item.get("audioKey") or item.get("id") or "").strip()
                en = (item.get("english") or "").strip()
                my = clean_myanmar(item.get("myanmar") or "")
                if ak and en:
                    tasks[ak] = (en, "en")
                if ak and my:
                    tasks[f"{ak}_my"] = (my, "my")

                ex_k = (item.get("exampleAudioKey") or f"{ak}_ex").strip()
                ex_en = (item.get("exampleEn") or "").strip()
                ex_my = clean_myanmar(item.get("exampleMy") or "")
                if ex_k and ex_en:
                    tasks[ex_k] = (ex_en, "en")
                if ex_k and ex_my:
                    tasks[f"{ex_k}_my"] = (ex_my, "my")

        for phrase in data.get("phrases", []):
            ak = (phrase.get("audioKey") or "").strip()
            if not ak:
                continue
            en = (phrase.get("english") or "").strip()
            my = clean_myanmar(phrase.get("myanmar") or "")
            res_en = (phrase.get("responseEn") or "").strip()
            res_my = clean_myanmar(phrase.get("responseMy") or "")
            if en:
                tasks[ak] = (en, "en")
            if my:
                tasks[f"{ak}_my"] = (my, "my")
            if res_en:
                tasks[f"{ak}_res"] = (res_en, "en")
            if res_my:
                tasks[f"{ak}_res_my"] = (res_my, "my")

    return [(k, v[0], v[1]) for k, v in tasks.items()]


def fallback_espeak(text: str, lang: str, out_mp3: Path) -> None:
    wav = out_mp3.with_suffix(".wav")
    code = "my" if lang == "my" else "en-us"
    subprocess.run(
        ["espeak-ng", "-s", "135", "-v", code, "-w", str(wav), text],
        check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    subprocess.run(
        ["ffmpeg", "-y", "-i", str(wav), "-codec:a", "libmp3lame", "-b:a", "40k", str(out_mp3)],
        check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    if wav.exists():
        wav.unlink()


async def synth(sem: asyncio.Semaphore, key: str, text: str, lang: str) -> None:
    out_mp3 = AUDIO_DIR / f"{key}.mp3"
    if out_mp3.exists() and out_mp3.stat().st_size > 200:
        return
    voice = VOICE_MY if lang == "my" else VOICE_EN
    rate = "-5%" if lang == "my" else "-10%"
    async with sem:
        for attempt in range(3):
            try:
                import edge_tts
                await edge_tts.Communicate(text=text, voice=voice, rate=rate).save(str(out_mp3))
                if out_mp3.exists() and out_mp3.stat().st_size > 200:
                    return
            except Exception:
                await asyncio.sleep(0.5 * (attempt + 1))
        try:
            fallback_espeak(text, lang, out_mp3)
        except Exception as err:
            print(f"[WARN] Failed {key}: {err}")


async def main() -> None:
    AUDIO_DIR.mkdir(parents=True, exist_ok=True)
    tasks = collect_pack_tasks()
    print(f"Found {len(tasks)} pack audio entries (EN + MY).")
    sem = asyncio.Semaphore(10)
    await asyncio.gather(*(synth(sem, k, t, l) for k, t, l in tasks))
    print(f"Pack audio ready: {len(list(AUDIO_DIR.glob('*.mp3')))} MP3 files in {AUDIO_DIR}")


if __name__ == "__main__":
    asyncio.run(main())
