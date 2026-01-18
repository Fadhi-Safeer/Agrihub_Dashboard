import subprocess
import sys
import os
import time
from pathlib import Path

# =====================================
# PROJECT PATHS (AUTO-DETECTED)
# =====================================
PROJECT_ROOT = Path(__file__).resolve().parent
BACKEND_DIR = PROJECT_ROOT / "backend"
FLUTTER_DIR = PROJECT_ROOT

PYTHON = sys.executable
FASTAPI_MODULE = "fast_api"
FASTAPI_PORT = "8001"
FLUTTER_DEVICE = "chrome"  # change to "windows" if needed


def run_new_cmd(command, cwd=None):
    """
    Run command in a NEW CMD window (Windows-safe)
    """
    subprocess.Popen(
        ["cmd", "/k"] + command,
        cwd=cwd,
        shell=False,
    )


def main():
    print("🚀 Starting AGRIVISION system...")

    # 1️⃣ WebSocket / Streaming Service
    print("▶ Starting automated_streaming.py")
    run_new_cmd(
        [PYTHON, "automated_streaming.py"],
        cwd=BACKEND_DIR,
    )
    time.sleep(2)

    # 2️⃣ AGRIVISION Core App
    print("▶ Starting AGRIVISION-app.py")
    run_new_cmd(
        [PYTHON, "AGRIVISION-app.py"],
        cwd=BACKEND_DIR,
    )
    time.sleep(2)

    # 3️⃣ FastAPI (Excel + Analytics APIs)
    print("▶ Starting FastAPI server")
    run_new_cmd(
        [
            "uvicorn",
            f"{FASTAPI_MODULE}:app",
            "--port",
            FASTAPI_PORT,
            "--reload",
        ],
        cwd=BACKEND_DIR,
    )
    time.sleep(3)

    # 4️⃣ Flutter (Chrome – NO DEVICE PROMPT)
    print("▶ Starting Flutter app")
    run_new_cmd(
        ["flutter", "run", "-d", FLUTTER_DEVICE],
        cwd=FLUTTER_DIR,
    )

    print("✅ All services launched successfully.")


if __name__ == "__main__":
    main()
