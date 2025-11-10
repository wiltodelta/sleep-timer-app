# SwiftLint Setup

## Installation

SwiftLint is already installed via Homebrew. If you need to reinstall:

```bash
brew install swiftlint
```

## Configuration

The project includes:
- `.swiftlint.yml` - SwiftLint configuration
- `.git/hooks/pre-commit` - Pre-commit hook that runs SwiftLint

## Setup Xcode

For SwiftLint to work, you need to switch from Command Line Tools to full Xcode:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

## Usage

### Run manually

```bash
# Check for issues
swiftlint lint

# Auto-fix some issues
swiftlint lint --fix
```

### Automatic checking

The pre-commit hook will automatically run SwiftLint before each commit. If issues are found, the commit will be blocked until you fix them.

To bypass the check (not recommended):

```bash
git commit --no-verify -m "Your message"
```

## Troubleshooting

If you get an error about `sourcekitdInProc.framework`, run:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

This switches from Command Line Tools to full Xcode.

