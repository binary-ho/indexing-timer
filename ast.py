#!/usr/bin/env python3
import subprocess
import time
import sys
import json
from pathlib import Path

def measure_ast_time(file_path):
    """단일 파일의 tree-sitter AST 생성 시간 측정"""
    file_path = Path(file_path)

    if not file_path.exists():
        print(f"❌ File not found: {file_path}")
        return None, False

    print(f"📄 File: {file_path}")
    print(f"📏 File size: {file_path.stat().st_size:,} bytes")

    cmd = ["tree-sitter", "parse", str(file_path), "--output-format", "json"]

    print(f"⏱️  Starting AST generation...")
    start_time = time.time()

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        end_time = time.time()

        elapsed = end_time - start_time

        # AST 크기 확인
        ast_data = json.loads(result.stdout)
        ast_json = json.dumps(ast_data, indent=2)
        ast_size = len(ast_json.encode('utf-8'))

        print(f"✅ Success!")
        print(f"⏱️  Time: {elapsed:.3f} seconds")
        print(f"📊 AST JSON size: {ast_size:,} bytes")

        return elapsed, True

    except subprocess.CalledProcessError as e:
        end_time = time.time()
        elapsed = end_time - start_time

        print(f"❌ Failed after {elapsed:.3f} seconds")
        print(f"Error: {e.stderr}")

        return elapsed, False
    except json.JSONDecodeError as e:
        end_time = time.time()
        elapsed = end_time - start_time

        print(f"❌ JSON parsing failed after {elapsed:.3f} seconds")
        print(f"Error: {e}")

        return elapsed, False

def measure_multiple_files(file_list):
    """여러 파일의 AST 생성 시간 측정"""
    results = []
    total_time = 0
    success_count = 0

    print(f"📋 Measuring {len(file_list)} files...")
    print("=" * 50)

    for i, file_path in enumerate(file_list, 1):
        print(f"\n[{i}/{len(file_list)}]")
        elapsed, success = measure_ast_time(file_path)

        if elapsed is not None:
            results.append({
                'file': str(file_path),
                'time': elapsed,
                'success': success
            })
            total_time += elapsed
            if success:
                success_count += 1

    print(f"\n" + "=" * 50)
    print(f"📊 Summary:")
    print(f"   Total files: {len(file_list)}")
    print(f"   Successful: {success_count}")
    print(f"   Failed: {len(file_list) - success_count}")
    print(f"   Total time: {total_time:.3f} seconds")
    print(f"   Average time: {total_time / len(file_list):.3f} seconds per file")

    return results

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage:")
        print("  Single file: python measure_ast.py <file_path>")
        print("  Multiple files: python measure_ast.py <file1> <file2> ...")
        sys.exit(1)

    file_paths = [Path(path) for path in sys.argv[1:]]

    if len(file_paths) == 1:
        measure_ast_time(file_paths[0])
    else:
        measure_multiple_files(file_paths)