# ocr

A macOS command-line OCR tool powered by Apple's Vision framework. Extracts text from images with automatic language detection.

## Installation

This project ships as a **skill plugin** for coding agents (ZCode / Reasonix / Pi) plus a standalone `ocr` CLI. The simplest way to install both is to paste the prompt below into your agent.

### Install via your coding agent

Copy the block below and send it to ZCode, Reasonix, Pi, or any agent that supports the `~/.agents/skills/` convention:

```
帮我安装 ocr skill 和命令行工具：

1. 从 https://github.com/Dellety/macos-vision-ocr/raw/main/skills/ocr/SKILL.md 下载 SKILL.md
2. 保存到 ~/.agents/skills/ocr/SKILL.md（目录不存在就先创建）
3. 用 curl 安装 ocr 命令行工具：
   curl -fsSL https://raw.githubusercontent.com/Dellety/macos-vision-ocr/main/install.sh | bash
4. 跑一下 `ocr --help` 验证可用，然后简述用法
```

### Manual install (CLI only)

```bash
curl -fsSL https://raw.githubusercontent.com/Dellety/macos-vision-ocr/main/install.sh | bash
```

Or build from source:

```bash
git clone https://github.com/Dellety/macos-vision-ocr.git
cd macos-vision-ocr
swift build -c release --arch arm64   # Apple Silicon; use --arch x86_64 on Intel
cp .build/release/ocr /usr/local/bin/ocr
```

## Usage

### Basic

```bash
# Extract text (plain text by default)
ocr image.png

# Multiple images
ocr a.png b.png c.png

# JSON output with position data
ocr --json image.png
```

### Output to file

```bash
ocr image.png --output ./results
ocr --json image.png --output ./results
```

### Batch processing

```bash
ocr --img-dir ./images --output-dir ./output
ocr --img-dir ./images --output-dir ./output --merge   # one merged text file
```

### Language options

Auto-detected on macOS 13+. Manual override:

```bash
ocr image.png --rec-langs "zh-Hans, en-US"
ocr --lang              # list supported languages
```

### Debug mode

Draws red bounding boxes around detected text:

```bash
ocr image.png --debug
```

![handwriting_boxes.png](./images/handwriting_boxes.png)

### All options

```
USAGE: ocr [<input-files> ...] [options]

ARGUMENTS:
  <input-files>           Image file path(s) to process

OPTIONS:
  --json                  Output as JSON with position data
  --img <path>            Path to a single image file (legacy; prefer positional)
  --output <path>         Output directory for single image mode
  --img-dir <path>        Directory containing images for batch mode
  --output-dir <path>     Output directory for batch mode
  --merge                 Merge all text outputs into a single file
  --debug                 Draw bounding boxes on the image
  --rec-langs <langs>     Recognition languages (auto-detected if not specified)
  --lang                  Show supported recognition languages
  -h, --help              Show help information
```

## JSON output format

When using `--json`, the output includes text positions and confidence scores. Keys are sorted alphabetically (`info`, `observations`, `texts`):

```json
{
  "info": {
    "filepath": "./images/handwriting.webp",
    "filename": "handwriting.webp",
    "height": 720,
    "width": 1600
  },
  "observations": [
    {
      "confidence": 0.95,
      "quad": {
        "bottomLeft":  { "x": 0.09, "y": 0.35 },
        "bottomRight": { "x": 0.88, "y": 0.35 },
        "topLeft":     { "x": 0.09, "y": 0.28 },
        "topRight":    { "x": 0.88, "y": 0.28 }
      },
      "text": "Detected line of text"
    }
  ],
  "texts": "Detected text content..."
}
```

`quad` coordinates are normalized 0–1, origin at the **top-left** (y flipped from Vision's bottom-left convention).

## Supported languages

English, French, Italian, German, Spanish, Portuguese (Brazil), Simplified Chinese, Traditional Chinese, Simplified Cantonese, Traditional Cantonese, Korean, Japanese, Russian, Ukrainian, Thai, Vietnamese.

## Node.js integration

```javascript
const { execSync } = require("child_process");

const text = execSync('ocr image.png').toString();
const json = JSON.parse(execSync('ocr --json image.png').toString());
console.log(json.texts);
console.log(json.observations);
```

## System requirements

- macOS 10.15+ (macOS 13+ recommended for auto language detection)
- arm64 (Apple Silicon) or x86_64 (Intel)

## Uninstall

```bash
rm /usr/local/bin/ocr
rm -rf ~/.agents/skills/ocr   # remove the skill too, if installed
```

## License

MIT License — see [LICENSE](LICENSE) for details.
