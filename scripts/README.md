# Build Scripts for Vidyut

## Available Scripts

### Development Scripts

#### `analyze.sh`
Runs Flutter analyzer to check for code issues.
```bash
./scripts/analyze.sh
```

#### `test.sh`
Runs all unit tests with coverage.
```bash
./scripts/test.sh
```

#### `build_web.sh`
Builds the web version of the app for production.
```bash
./scripts/build_web.sh
```

### Manual Deployment Script

#### `manual_deploy.sh` (Existing)
Manually deploys to Firebase Hosting.
```bash
./scripts/manual_deploy.sh
```

## CI/CD Integration

These scripts are used in the GitHub Actions workflow (`.github/workflows/ci.yml`):

- **On PR/Push:** Runs `analyze` + `test` + `build_web`
- **On Main Push:** Additionally builds Android APK

## Creating New Scripts

When adding new scripts:
1. Make them executable: `chmod +x scripts/your_script.sh`
2. Add proper error handling: `set -e`
3. Document here
4. Update CI workflow if needed

## Environment Setup

These scripts expect:
- Flutter SDK installed and in PATH
- Firebase CLI installed (for deploy scripts)
- Proper Firebase project configuration

See `setup_firebase.md` for Firebase setup instructions.




