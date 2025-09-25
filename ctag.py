#!/usr/bin/env python3
import subprocess
import time
import sys
from pathlib import Path

def measure_ctags_time(project_path):
    """Universal ctags 생성 시간 측정"""
    project_path = Path(project_path)
    # Create tags file in current directory to avoid permission issues
    tags_file = Path("tags")

    print(f"📁 Project: {project_path}")
    print(f"🏷️  Tags file: {tags_file.absolute()}")

    # 기존 tags 파일 제거
    if tags_file.exists():
        tags_file.unlink()

    cmd = [
        "ctags", "-R",
        "--fields=+iaS", "--extras=+q",
        "--exclude=node_modules", "--exclude=.git", "--exclude=__pycache__",
        f"-f{tags_file}",
        str(project_path)
    ]

    print(f"⏱️  Starting ctags generation...")
    start_time = time.time()

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        end_time = time.time()

        elapsed = end_time - start_time

        # 결과 확인
        if tags_file.exists():
            file_size = tags_file.stat().st_size
            with open(tags_file, 'r') as f:
                line_count = sum(1 for _ in f)
        else:
            file_size = 0
            line_count = 0

        print(f"✅ Success!")
        print(f"⏱️  Time: {elapsed:.2f} seconds")
        print(f"📊 Tags file size: {file_size:,} bytes")
        print(f"📊 Number of tags: {line_count:,}")

        return elapsed, True

    except subprocess.CalledProcessError as e:
        end_time = time.time()
        elapsed = end_time - start_time

        print(f"❌ Failed after {elapsed:.2f} seconds")
        print(f"Error: {e.stderr}")

        return elapsed, False

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python measure_ctags.py <project_path>")
        sys.exit(1)

    project_path = sys.argv[1]
    elapsed, success = measure_ctags_time(project_path)