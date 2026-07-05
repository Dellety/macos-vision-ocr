---
name: ocr
description: Extract text from images using the `ocr` CLI (macOS Vision framework). Use whenever the user wants to read text from an image, screenshot, photo, scan, or document image — e.g. "what does this say", "extract the text", "OCR this", "read this screenshot", "识别图片文字", "截图里写了什么", "把图片转成文字", "读一下这张图". Triggers on any mention of OCR, text recognition, or reading/extracting text from image files (png, jpg, jpeg, webp).
---

# OCR — Extract Text from Images

`ocr` is a macOS command-line tool that extracts text from images using Apple's Vision framework. It auto-detects languages (including CJK) and outputs plain text by default.

## Prerequisites

`ocr` must be installed and on `PATH`. Verify first:

```bash
command -v ocr && ocr --version 2>/dev/null || echo "NOT_INSTALLED"
```

If `NOT_INSTALLED`, install via the curl one-liner (no Homebrew needed):

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

Requires macOS 10.15+ (13+ recommended for auto language detection).

## Core usage

### Plain text (default)

```bash
ocr <image-path>
```

Most common case — pass a path, get text back.

### Multiple images

```bash
ocr image1.png image2.jpg image3.webp
```

### JSON with position data

Use `--json` when the user needs bounding boxes, confidence scores, or structured data:

```bash
ocr --json <image-path>
```

### Pipe-friendly

```bash
ocr screenshot.png | pbcopy          # copy to clipboard
ocr receipt.jpg | grep "Total"       # search results
ocr document.png >> notes.txt        # append
```

## When to use each flag

| Scenario | Command |
|---|---|
| Just the text | `ocr image.png` |
| Coordinates / positions | `ocr --json image.png` |
| Save results to a directory | `ocr image.png --output ./results` |
| A folder of images | `ocr --img-dir ./images --output-dir ./output` |
| Merge many images into one text file | `ocr --img-dir ./images --output-dir ./output --merge` |
| Visualize where text was detected | `ocr --debug image.png` |
| Auto-detection gives poor results (rare) | `ocr --rec-langs "zh-Hans, ja-JP" image.png` |
| List supported languages | `ocr --lang` |

## Language detection

Auto-detected on macOS 13+. Specify `--rec-langs` only if auto-detection underperforms (uncommon). Supported: English, French, Italian, German, Spanish, Portuguese (Brazil), Chinese (Simplified/Traditional), Cantonese (Simplified/Traditional), Korean, Japanese, Russian, Ukrainian, Thai, Vietnamese.

## Supported formats

JPG, JPEG, PNG, WEBP.

## JSON output format

Keys are sorted alphabetically (`info`, `observations`, `texts`):

```json
{
  "info": {
    "filename": "handwriting.webp",
    "filepath": "/abs/path/to/handwriting.webp",
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

`quad` coordinates are normalized 0–1, with origin at the **top-left** of the image (y already flipped from Vision's bottom-left convention).

## Example workflows

**Screenshot → text:**
```bash
ocr /path/to/screenshot.png
```

**Digitize a folder of scans into one file:**
```bash
ocr --img-dir ./scans --output-dir ./text-output --merge
```

**Programmatic use (JSON):**
```bash
ocr --json photo.jpg
```
