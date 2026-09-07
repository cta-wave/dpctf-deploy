#!/usr/bin/env bash
set -Eeuo pipefail

USER_NAME="${1:-}"

if [[ -z "$USER_NAME" ]]; then
  echo "Usage: ./build_wave_wsl.sh <WindowsUsername>"
  exit 1
fi

BASE_DIR="/mnt/c/Users/$USER_NAME"
REPO_DIR="$BASE_DIR/dpctf-deploy"

DEFAULT_BRANCH="master"

detect_compose() {
  if docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD=(docker compose)
  elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD=(docker-compose)
  else
    echo "ERROR: Docker Compose not found. Install 'docker compose' or 'docker-compose'."
    exit 1
  fi
}

run_compose() {
  "${COMPOSE_CMD[@]}" "$@"
}

prompt_yes_no() {
  local prompt="$1"
  local default="${2:-N}"
  local reply=""

  if [[ "$default" == "Y" ]]; then
    read -r -p "$prompt [Y/n]: " reply
    reply="${reply:-Y}"
  else
    read -r -p "$prompt [y/N]: " reply
    reply="${reply:-N}"
  fi

  [[ "$reply" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]
}

echo ""
echo "=== WAVE Test Suite Build Script ==="
echo ""

if [[ ! -d "$BASE_DIR" ]]; then
  echo "ERROR: Windows user folder not found: $BASE_DIR"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git is not installed."
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker is not installed."
  exit 1
fi

detect_compose

echo "Default repository settings:"
echo "  BRANCH=\"$DEFAULT_BRANCH\""
echo "  TAG=\"<none>\"   (use latest on the selected branch)"
echo ""
echo "Use 'master' for released builds or 'staging' for pre-release validation builds."
echo "Press Enter to accept defaults, or enter a branch and optional release tag."
echo ""

read -r -p "Enter branch [$DEFAULT_BRANCH]: " BRANCH
BRANCH="${BRANCH:-$DEFAULT_BRANCH}"

read -r -p "Enter tag [leave blank for latest on $BRANCH]: " TAG

echo ""
echo "Using:"
echo "  BRANCH=\"$BRANCH\""
if [[ -n "$TAG" ]]; then
  echo "  TAG=\"$TAG\""
else
  echo "  TAG=\"<none>\""
fi

# Build type prompt
echo ""
echo "Build type:"
echo "  1 = Full rebuild — fresh clone, clean start"
echo "      Use for: major version changes, corrupted state, or first-time build"
echo "  2 = Incremental update — update existing repo, skips unchanged content"
echo "      Use for: minor updates, new tests or content added"
echo ""

if [[ -d "$REPO_DIR" ]]; then
  read -r -p "Select build type [1]: " BUILD_TYPE
  BUILD_TYPE="${BUILD_TYPE:-1}"
else
  echo "No existing dpctf-deploy found — full rebuild required."
  BUILD_TYPE="1"
fi

echo ""

cd "$BASE_DIR"

if [[ "$BUILD_TYPE" == "1" ]]; then

  # --- Full rebuild ---
  if [[ -d "$REPO_DIR" ]]; then
    echo "Stopping any running Docker containers..."
    (cd "$REPO_DIR" && run_compose down 2>/dev/null || true)

    DATE="$(date +%Y%m%d_%H%M%S)"
    BACKUP_DIR="${REPO_DIR}_$DATE"
    echo "Backing up recordings and results to dpctf-deploy_$DATE..."
    mkdir -p "$BACKUP_DIR"
    cp -r "$REPO_DIR/test_recordings" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$REPO_DIR/results" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$REPO_DIR/observation_results" "$BACKUP_DIR/" 2>/dev/null || true
    echo "Note: Prior recordings, results, and observation results are in dpctf-deploy_$DATE"
    echo "Removing existing dpctf-deploy..."
    rm -rf "$REPO_DIR"
  fi

  echo ""
  echo "Cloning repository..."
  git clone https://github.com/cta-wave/dpctf-deploy.git

  cd "$REPO_DIR"

  if [[ "$BRANCH" != "master" ]]; then
    echo ""
    echo "Checking out branch $BRANCH"
    git checkout "$BRANCH"
  fi

  if [[ -n "$TAG" ]]; then
    echo ""
    echo "Checking out tag $TAG"
    git checkout "$TAG"
  fi

else

  # --- Incremental update ---
  if [[ ! -d "$REPO_DIR" ]]; then
    echo "No existing dpctf-deploy found — falling back to full rebuild..."
    BUILD_TYPE="1"

    echo ""
    echo "Cloning repository..."
    git clone https://github.com/cta-wave/dpctf-deploy.git

    cd "$REPO_DIR"

    if [[ "$BRANCH" != "master" ]]; then
      git checkout "$BRANCH"
    fi
    if [[ -n "$TAG" ]]; then
      git checkout "$TAG"
    fi

  else
    echo "Stopping any running Docker containers..."
    (cd "$REPO_DIR" && run_compose down 2>/dev/null || true)

    cd "$REPO_DIR"

    echo ""
    echo "Updating repository..."
    git fetch --tags --force origin

    if [[ "$BRANCH" != "master" ]]; then
      echo ""
      echo "Checking out branch $BRANCH"
      git checkout "$BRANCH"
      git pull origin "$BRANCH" 2>/dev/null || true
    else
      git pull origin master 2>/dev/null || true
    fi

    if [[ -n "$TAG" ]]; then
      echo ""
      echo "Checking out tag $TAG"
      git checkout "$TAG"
    fi
  fi

fi

# --- Both paths converge here ---

# Detect build system: Makefile (4.0+) or build.sh (3.x)
if [[ -f "$REPO_DIR/Makefile" ]]; then
  BUILD_SYSTEM="make"
  echo ""
  echo "Detected Makefile — using make build system (4.0+)"

  if ! command -v make >/dev/null 2>&1; then
    echo "make not found. Installing..."
    sudo apt install make -y
  fi
else
  BUILD_SYSTEM="shell"
  echo ""
  echo "No Makefile found — using build.sh (3.x)"
fi

echo ""
echo "Building image..."
if [[ "$BUILD_SYSTEM" == "make" ]]; then
  make import-runner
  make import-tests
  make build
else
  chmod +x build.sh
  ./build.sh
fi

echo ""
if [[ "$BUILD_SYSTEM" == "make" ]]; then
  echo "Importing test content — this may take a long time..."
  make import-content
else
  echo "Importing test content — this may take a long time..."
  chmod +x import.sh
  ./import.sh
fi

echo ""
echo "CTA WAVE Test Suite usage requires agreement to the EULA."
echo "Review the EULA here:"
echo "https://github.com/cta-wave/dpctf-deploy/?tab=readme-ov-file#agree-to-the-eula"
echo ""

if grep -q 'AGREE_EULA:.*"yes"' docker-compose.yml 2>/dev/null; then
  echo "AGREE_EULA is already set to yes in docker-compose.yml — EULA previously accepted."
else
  if ! prompt_yes_no "Have you reviewed and agreed to the EULA?" "N"; then
    echo ""
    echo "ERROR: You must agree to the EULA before running the WAVE Test Suite."
    echo "Re-run this script and accept the EULA to continue."
    exit 1
  fi
  if grep -q 'AGREE_EULA:' docker-compose.yml; then
    sed -i 's/AGREE_EULA:.*/AGREE_EULA: "yes"/' docker-compose.yml
    echo "Updated docker-compose.yml: AGREE_EULA=\"yes\""
  else
    echo "WARNING: AGREE_EULA entry not found in docker-compose.yml. Set it manually if needed."
  fi
fi

echo ""
if [[ "$BUILD_TYPE" == "1" ]]; then
  echo "Cleaning previous DPCTF Docker state..."
  echo "WARNING: This will remove existing DPCTF Docker containers and named volumes,"
  echo "including any persisted test session data. Test recordings in test_recordings/"
  echo "are not affected."
  run_compose down -v 2>/dev/null || true
  docker rm -f dpctf 2>/dev/null || true

  echo ""
  echo "Optional cleanup:"
  echo "Running 'docker volume prune' removes ALL unused Docker volumes on this system,"
  echo "including volumes from other projects."
  if prompt_yes_no "Run docker volume prune now?" "N"; then
    docker volume prune -f
  else
    echo "Skipping docker volume prune."
  fi
else
  echo "Stopping containers for restart (session data preserved)..."
  run_compose down 2>/dev/null || true
  docker rm -f dpctf 2>/dev/null || true
fi

echo ""
echo "Starting docker containers"
run_compose up -d --force-recreate

echo ""
echo "Checking container status"
docker ps --format '{{.Names}}' | grep -q '^dpctf$' || echo "WARNING: dpctf container not found running"

echo ""
echo "Building Device Observation Framework (DOF) image..."

# Detect expected DOF version from analyse-recording.sh
DOF_VERSION=""
if [[ -f "$REPO_DIR/analyse-recording.sh" ]]; then
  DOF_VERSION="$(grep -o 'dpctf-dof:[^ "]*' "$REPO_DIR/analyse-recording.sh" | head -1 | cut -d: -f2 || true)"
fi

if [[ -n "$DOF_VERSION" ]]; then
  echo "Detected expected DOF version: $DOF_VERSION"
fi

if [[ -z "$DOF_VERSION" ]]; then
  echo "WARNING: Could not detect the required DOF version from analyse-recording.sh."
  echo "DOF image was not built during this step."
  echo "It will be built automatically (with a prompt) the first time you run analyse_wave_recordings.sh,"
  echo "or you can rebuild it yourself:"
  echo "  cd $REPO_DIR && ./build-dof.sh --reload-dof"
elif [[ -f "$REPO_DIR/Dockerfile.dof" ]]; then
  docker build --file Dockerfile.dof -t "dpctf-dof:$DOF_VERSION" .
  echo "DOF image built: dpctf-dof:$DOF_VERSION"
else
  echo "WARNING: Dockerfile.dof not found. DOF image not built."
  echo "Run: cd $REPO_DIR && ./build-dof.sh --reload-dof"
fi

echo ""
echo "Creating test recording folders..."
mkdir -p "$REPO_DIR/test_recordings"
mkdir -p "$REPO_DIR/test_recordings_backups"

echo ""
echo "Fetching test_suite_scripts..."
SCRIPTS_SRC="$REPO_DIR/test_suite_scripts"
SCRIPTS_DST="$BASE_DIR/test_suite_scripts"

if [[ ! -d "$SCRIPTS_SRC" ]]; then
  echo "ERROR: Source folder not found:"
  echo "  $SCRIPTS_SRC"
  exit 1
fi

echo "NOTE: Any local changes to files in test_suite_scripts/ will be overwritten."
WIN_SCRIPTS_DST="C:\\Users\\$USER_NAME\\test_suite_scripts"
cmd.exe /c "if exist \"$WIN_SCRIPTS_DST\" rmdir /s /q \"$WIN_SCRIPTS_DST\"" 2>/dev/null || true
cp -r "$SCRIPTS_SRC" "$SCRIPTS_DST"

echo "Created: $REPO_DIR/test_recordings"
echo "Created: $REPO_DIR/test_recordings_backups"
echo "Created: $SCRIPTS_DST"

echo ""
echo "===================================="
echo "BUILD COMPLETE"
echo "===================================="
echo ""
echo "You can now verify that the Test Runner is running."
echo ""
echo "Next step:"
echo "Run the PowerShell script as Administrator to:"
echo "  - Select 1-device or 2-device testing"
echo "  - Configure HTTP or HTTPS access"
echo "  - Configure host IP or domain usage"
echo "  - Create observation-config.ini only if required for 2-device testing"
echo ""
