# Git Hooks for Vidyut

## Setup

To enable these hooks, run:

```bash
git config core.hooksPath .githooks
```

## Available Hooks

### pre-commit
Runs before each commit to:
- ✅ Run `flutter analyze` (blocks commit on errors)
- ⚠️ Check for TODO comments (warning only)
- ⚠️ Check for debug print statements (warning only)

### Manual Testing
To test the hook manually:
```bash
./.githooks/pre-commit
```

## Bypassing Hooks

In rare cases where you need to bypass the hook:
```bash
git commit --no-verify -m "Your message"
```

**Note:** Only bypass in emergencies. Fix issues instead.




