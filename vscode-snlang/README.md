# SNlang VS Code Extension

## Installation

1. Copy this folder to `.vscode/extensions/` in your home directory
   - macOS: `~/.vscode/extensions/snlang`
   - Windows: `%USERPROFILE%\.vscode\extensions\snlang`

2. Or package as .vsix:
   ```bash
   cd vscode-snlang
   vsce package
   ```

3. Install the .vsix: `code --install-extension snlang-1.0.0.vsix`

## Features

- Syntax highlighting for `.sn` files
- Basic language support
- Comment support (`//` and `/* */`)

## Icon

Add an icon by placing a 256x256 PNG named `icon.png` in this folder.

## Files

- `package.json` - Extension manifest
- `language-configuration.json` - Language settings
- `syntaxes/snlang.json` - Syntax highlighting rules