# 인덱싱 타이머 (Indexing Timer)

코드 인덱싱 도구들의 성능을 측정하는 유틸리티입니다. ctags와 tree-sitter AST 생성 시간을 쉽게 측정할 수 있습니다.

## 📋 프로젝트 구성

### Python 스크립트

#### 🏷️ `ctag.py`
- **목적**: Universal ctags 생성 시간 측정
- **기능**: 프로젝트 디렉토리에서 ctags 파일을 생성하고 소요 시간, 파일 크기, 태그 개수를 측정

#### 🌳 `ast.py`
- **목적**: tree-sitter AST 생성 시간 측정
- **기능**: 단일 또는 다중 파일의 AST 생성 시간과 크기를 측정

### 🛠️ Justfile
편리한 명령어들을 제공하는 task runner 설정 파일입니다.

## 🚀 설치 및 요구사항

### 1단계: Just 설치
```bash
# Just 설치 (macOS)
brew install just

# 또는 다른 방법으로 설치
# https://github.com/casey/just#installation
```

### 2단계: 의존성 설치
```bash
# 모든 필수 도구를 자동으로 설치
just setup
```

이 명령어는 다음을 자동으로 설치합니다:
- Universal ctags (brew를 통해)
- tree-sitter (npm 또는 brew를 통해)

### Python 요구사항
- Python 3.6+
- 추가 패키지 설치 불필요 (표준 라이브러리만 사용)

## 📖 사용법

### 기본 명령어 확인
```bash
just
```
사용 가능한 모든 명령어와 예시를 보여줍니다.

### 🏷️ Ctags 명령어

#### 기본 사용법
```bash
# 특정 프로젝트 경로 지정
just ctag /path/to/project

# 현재 디렉토리 측정
just ctag-here

# 대화형 모드 (경로 입력 받음)
just ctag-interactive

# 🆕 인터랙티브 디렉토리 브라우저 (추천!)
just ctag-browse
```

#### 편의 명령어
```bash
# src 디렉토리 측정
just ctag-src

# lib 디렉토리 측정
just ctag-lib
```

### 🌳 AST 명령어

#### 기본 사용법
```bash
# 단일 파일 측정
just ast src/main.py

# 다중 파일 측정
just ast-multi src/*.py

# 대화형 모드
just ast-interactive

# 🆕 인터랙티브 파일 브라우저 (추천!)
just ast-browse
```

#### 패턴 기반 측정
```bash
# Python 파일들 측정 (기본: *.py)
just ast-py

# 특정 패턴으로 Python 파일 측정
just ast-py "src/*.py"

# JavaScript 파일들 측정 (기본: *.js)
just ast-js

# 특정 패턴으로 JavaScript 파일 측정
just ast-js "src/*.js"
```

### 📊 종합 측정

```bash
# 프로젝트 전체 측정 (ctags + 주요 소스파일 AST)
just measure-all

# 특정 프로젝트 경로로 종합 측정
just measure-all /path/to/project
```

## 🆕 인터랙티브 브라우저 기능

### 🏷️ `just ctag-browse` - 디렉토리 브라우저
현재 폴더부터 시작해서 인터랙티브하게 디렉토리를 탐색할 수 있습니다:

- **0**: 상위 디렉토리로 이동 (../)
- **1**: 현재 디렉토리 선택 (ctag 측정 실행)
- **2+**: 하위 디렉토리로 이동
- **q**: 종료

### 🌳 `just ast-browse` - 파일/디렉토리 브라우저
현재 폴더부터 시작해서 파일과 디렉토리를 인터랙티브하게 탐색할 수 있습니다:

- **0**: 상위 디렉토리로 이동 (../)
- **숫자**: 디렉토리 선택 시 해당 디렉토리로 이동
- **숫자**: 파일 선택 시 AST 측정 실행
- **m**: 다중 파일 선택 모드 (여러 파일 번호를 공백으로 구분하여 입력)
- **q**: 종료

**지원하는 파일 확장자**: `.py`, `.js`, `.ts`, `.java`, `.cpp`, `.c`, `.go`, `.rs`, `.kt`, `.swift`, `.php`, `.rb`, `.cs`, `.scala`, `.clj`, `.hs`, `.ml`, `.fs`, `.elm`, `.dart`, `.lua`, `.r`, `.m`, `.mm`, `.h`, `.hpp`, `.cc`, `.cxx`

## 💡 사용 예시

### 1. 현재 프로젝트의 ctags 성능 측정
```bash
just ctag-here
```

**출력 예시:**
```
🏷️  Measuring ctags generation time for current directory...
📁 Project: .
🏷️  Tags file: tags
⏱️  Starting ctags generation...
✅ Success!
⏱️  Time: 0.56 seconds
📊 Tags file size: 4,606 bytes
📊 Number of tags: 64
```

### 2. Python 파일들의 AST 생성 시간 측정
```bash
just ast-py "*.py"
```

### 3. 대화형 모드로 여러 파일 측정
```bash
just ast-interactive
```
```
🌳 Interactive AST Measurement
Choose measurement type:
1) Single file
2) Multiple files
2
Enter file paths (space-separated):
src/main.py src/utils.py
```

### 4. 프로젝트 전체 성능 측정
```bash
just measure-all
```

이 명령어는 다음을 수행합니다:
- ctags 생성 시간 측정
- 프로젝트 내 주요 소스 파일들 (*.py, *.js, *.ts, *.java, *.cpp, *.c, *.go, *.rs)의 AST 생성 시간 측정

## 🔧 고급 사용법

### 결과 해석
- **ctags 측정**: 프로젝트 크기에 따라 수초에서 수분 소요
- **AST 측정**: 파일 크기와 복잡도에 따라 밀리초에서 초 단위 소요
- **파일 크기**: 생성된 tags 파일이나 AST JSON의 크기 정보 제공

## 🎯 활용 사례

1. **IDE 성능 최적화**: 프로젝트의 인덱싱 시간을 측정하여 IDE 설정 최적화
2. **코드베이스 분석**: 프로젝트 규모와 복잡도 파악
3. **성능 벤치마킹**: 다양한 프로젝트 간 인덱싱 성능 비교
4. **도구 선택**: ctags vs tree-sitter 성능 비교를 통한 도구 선택

## 🚨 주의사항

- `tree-sitter` CLI가 설치되어 있어야 AST 측정이 가능합니다
- 대용량 프로젝트의 경우 측정 시간이 오래 걸릴 수 있습니다
- AST 측정은 tree-sitter가 지원하는 언어에서만 동작합니다

## 📝 도움말

더 자세한 명령어 정보는 다음 명령어로 확인할 수 있습니다:
```bash
just help
```

---

**만든 이**: binary-ho  
**날짜**: 2025-09-25