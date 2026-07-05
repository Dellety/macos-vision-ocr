# ocr - macOS Vision OCR CLI

## 项目概述

基于 Apple Vision 框架的 macOS 命令行 OCR 工具，从图片中提取文字。
通过 `install.sh`（curl 一键脚本）分发，不依赖 Homebrew。

## 技术栈

- **语言**：Swift 5.9+
- **构建**：Swift Package Manager（`Package.swift`，target 名 `ocr`）
- **依赖**：swift-argument-parser 1.2.3
- **框架**：Vision / Cocoa / Foundation
- **CI**：GitHub Actions（`.github/workflows/release.yml`，构建 arm64 / x86_64 / universal + checksums）

## 项目结构

```
Sources/ocr.swift        # 全部源码（单文件）
Package.swift            # SPM 配置
install.sh               # curl 一键安装脚本
uninstall.sh             # curl 一键卸载脚本
skills/ocr/SKILL.md      # 跨 agent 复用的 skill 描述
.zcode-plugin/plugin.json# ZCode 插件清单
.github/workflows/release.yml # 发布 CI
```

## 关键设计

- **单文件源码**：所有逻辑在 `Sources/ocr.swift`，无必要时不要拆分
- **默认输出纯文本**，`--json` 输出带位置的 JSON；JSON 键按字母序固定为 `info / observations / texts`
- **自动语言检测**：macOS 13+ 启用 `automaticallyDetectsLanguage`，未指定 `--rec-langs` 时生效
- **位置参数优先**：`ocr image.png` 即可，无需 `--img`
- **可执行文件名是 `ocr`**，不是 `macos-vision-ocr`
- **`filepath` 字段输出用户传入的原始路径**：绝对路径原样、相对路径解析为绝对路径

## 构建与测试

```bash
swift build -c release --arch arm64    # Apple Silicon
swift build -c release --arch x86_64   # Intel
.build/release/ocr image.png           # 运行
.build/release/ocr --json image.png    # JSON 输出
.build/release/ocr --lang              # 列出支持的语言
```

无单元测试；改动后用真实图片手测一次。

## 发布流程

1. 提交并推送 `main`
2. 触发 release workflow：
   ```bash
   gh workflow run release.yml --field platform=all --field version=v<VERSION>
   ```
3. CI 自动构建 arm64/x86_64/universal 三份 zip + checksums 并创建 Release
4. 用户通过 `install.sh` 自动拉取最新 Release，无需维护 SHA

## CLI 选项参考

```
ocr [<input-files> ...] [options]

位置参数:    <input-files>       图片路径（一个或多个）
选项:        --json              JSON 输出（带位置）
             --img <path>        单张图片（legacy，推荐用位置参数）
             --output <path>     单图模式输出目录
             --img-dir <path>    批量输入目录
             --output-dir <path> 批量输出目录
             --merge             批量结果合并为一个文件
             --debug             绘制检测框
             --rec-langs <langs> 手动指定语言（逗号分隔）
             --lang              列出支持的语言
```

## 重要修改记录

- 2026-07-05：fork 自 `maoxiaoke/macos-vision-ocr` 后做以下重构
  - 移除 Homebrew 支持（删除 `HomebrewFormula/`、`scripts/update-formula.sh`）
  - 修复 `extractText` 中绝对路径被错误拼接的 bug（`filepath` 现输出原始路径）
  - 删除死代码 `isEmptyBox`，调整 JSON 键顺序与文档一致，补全 fallback 语言列表
  - 将 `CLAUDE.md` 改写为本 `AGENTS.md`（zcode 风格）
  - 改造为可跨 agent（zcode / reasonix / pi）安装的 skill 插件
  - 重写 README，安装说明仅给出 agent 安装提示词
  - 新增 `uninstall.sh`（与 install.sh 对称的卸载脚本）
