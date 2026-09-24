#!/usr/bin/env python3
"""
Audio Pack Generator for Mocco (Indonesian id-ID Voice Over)
Uses edge-tts (GadisNeural) to synthesize warmth-calibrated preschool voiceovers.

Requirements:
    pip install edge-tts
    (Optional for audio normalization: ffmpeg)

Usage:
    python scripts/generate_audio_pack.py [--overwrite] [--voice VOICE_NAME]
"""

import argparse
import asyncio
import os
import shutil
import subprocess
import sys

VOICE_DEFAULT = "id-ID-GadisNeural"

# Target audio lines according to audio-fix-pack.md
AUDIO_SCRIPTS = [
    # Praises
    ("praise_hebat.mp3", "Hebat!"),
    ("praise_pintar.mp3", "Pintar sekali!"),
    ("praise_bagus.mp3", "Bagus!"),
    ("praise_keren.mp3", "Keren sekali!"),
    ("praise_luar_biasa.mp3", "Luar biasa!"),
    ("praise_kamu_bisa.mp3", "Kamu pasti bisa!"),
    # Encouragement
    ("coba_lagi.mp3", "Yuk, coba lagi!"),
    ("tidak_apa_apa.mp3", "Tidak apa-apa, coba lagi yuk!"),
    # Prompts
    ("hitung.mp3", "Ayo hitung buahnya!"),
    ("tebalkan_dulu_ya.mp3", "Tebalkan dulu ya!"),
    ("pilih_pulau.mp3", "Pilih pulau main!"),
    # Zone Announcements
    ("zone_huruf.mp3", "Pulau Huruf!"),
    ("zone_angka.mp3", "Pulau Angka!"),
    ("zone_kata.mp3", "Pulau Kata!"),
]


async def render_tts_edge(voice: str, text: str, output_path: str):
    """Renders text-to-speech using edge_tts Python library or CLI."""
    try:
        import edge_tts

        communicate = edge_tts.Communicate(text, voice)
        await communicate.save(output_path)
        return True
    except ImportError:
        # Fallback to edge-tts CLI if installed in environment
        cmd = [
            "edge-tts",
            "--voice",
            voice,
            "--text",
            text,
            "--write-media",
            output_path,
        ]
        res = subprocess.run(cmd, capture_output=True)
        return res.returncode == 0


def normalize_audio_if_ffmpeg_available(file_path: str):
    """Normalizes MP3 audio loudness to preschool broadcast standard using ffmpeg loudnorm."""
    if not shutil.which("ffmpeg"):
        return

    tmp_path = file_path + ".tmp.mp3"
    cmd = [
        "ffmpeg",
        "-y",
        "-i",
        file_path,
        "-filter:a",
        "loudnorm=I=-16:TP=-1.5:LRA=11",
        tmp_path,
    ]
    res = subprocess.run(cmd, capture_output=True)
    if res.returncode == 0 and os.path.exists(tmp_path):
        os.replace(tmp_path, file_path)


async def main():
    parser = argparse.ArgumentParser(description="Generate voice pack for Mocco")
    parser.add_argument(
        "--overwrite", action="store_true", help="Overwrite existing files"
    )
    parser.add_argument(
        "--voice", default=VOICE_DEFAULT, help=f"TTS voice name (default: {VOICE_DEFAULT})"
    )
    args = parser.parse_args()

    # Determine target directory
    project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    voice_dir = os.path.join(project_root, "assets", "audio", "voice")
    os.makedirs(voice_dir, exist_ok=True)

    print(f"[*] Target voice directory: {voice_dir}")
    print(f"[*] Voice talent: {args.voice}")

    # Check edge-tts availability
    has_edge_tts = False
    try:
        import edge_tts  # noqa: F401
        has_edge_tts = True
    except ImportError:
        if shutil.which("edge-tts"):
            has_edge_tts = True

    if not has_edge_tts:
        print("\n[!] edge-tts is not installed.")
        print("    To render voice files, please run: pip install edge-tts\n")
        sys.exit(1)

    has_ffmpeg = shutil.which("ffmpeg") is not None
    if not has_ffmpeg:
        print("[i] ffmpeg not found in PATH; skipping loudnorm normalization.")

    success_count = 0
    skip_count = 0

    for filename, text in AUDIO_SCRIPTS:
        target_path = os.path.join(voice_dir, filename)
        if os.path.exists(target_path) and not args.overwrite:
            print(f"[SKIP] Already exists: {filename}")
            skip_count += 1
            continue

        print(f"[RENDER] {filename} <- '{text}'")
        try:
            ok = await render_tts_edge(args.voice, text, target_path)
            if ok and os.path.exists(target_path):
                if has_ffmpeg:
                    normalize_audio_if_ffmpeg_available(target_path)
                success_count += 1
            else:
                print(f"[ERROR] Failed to render {filename}")
        except Exception as e:
            print(f"[ERROR] Exception rendering {filename}: {e}")

    print(f"\n[DONE] Rendered: {success_count}, Skipped (existing): {skip_count}")


if __name__ == "__main__":
    asyncio.run(main())
