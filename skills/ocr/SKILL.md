---
name: ocr
description: Drive the `ocr` CLI (macOS Vision framework) to extract text from images. NOT a default OCR tool — the agent already has its own multimodal vision or MCP for reading images, so use those first. Only invoke this skill when the user explicitly mentions `ocr` by name (e.g. "用 ocr 识别", "run ocr on this", "ocr this image", "ocr --json", "ocr 批量处理"). Do NOT trigger on generic "识别图片文字 / extract text / what does this say" requests unless `ocr` is named.
---

# OCR — Extract Text from Images

`ocr` extracts text from images via Apple's Vision framework. Auto-detects languages (including CJK) on macOS 13+; outputs plain text by default. Supports JPG / JPEG / PNG / WEBP.

Assumed installed on `PATH` (macOS 10.15+). If a run reports "command not found", point the user at: `curl -fsSL https://raw.githubusercontent.com/Dellety/macos-vision-ocr/main/install.sh | bash`.

## Core usage

```bash
ocr image.png                       # plain text (default)
ocr a.png b.jpg c.webp              # multiple images
ocr --json image.png                # JSON with positions/confidence
ocr screenshot.png | pbcopy         # pipe-friendly
```

## Flags

| Scenario | Command |
|---|---|
| Plain text | `ocr image.png` |
| Coordinates / positions | `ocr --json image.png` |
| Save to a directory | `ocr image.png --output ./results` |
| Batch a folder | `ocr --img-dir ./images --output-dir ./output` |
| Merge batch into one file | `ocr --img-dir ./images --output-dir ./output --merge` |
| Draw bounding boxes | `ocr --debug image.png` |
| Override auto-detection (rare) | `ocr --rec-langs "zh-Hans, ja-JP" image.png` |
| List supported languages | `ocr --lang` |

`--rec-langs` is rarely needed — auto-detection covers English, French, Italian, German, Spanish, Portuguese, Chinese (Simplified/Traditional), Cantonese, Korean, Japanese, Russian, Ukrainian, Thai, Vietnamese. Run `ocr --lang` for the live list.

## JSON output

Keys are sorted alphabetically (`info`, `observations`, `texts`):

```json
{
  "info": { "filename": "x.png", "filepath": "/abs/path/x.png", "height": 720, "width": 1600 },
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

`quad` coordinates are normalized 0–1, origin at the **top-left** (y already flipped from Vision's bottom-left convention).
