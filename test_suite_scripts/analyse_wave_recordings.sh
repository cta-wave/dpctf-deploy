#!/usr/bin/env bash

set -e

USER_NAME=$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')
BASE_DIR="/mnt/c/Users/$USER_NAME/dpctf-deploy"
RECORDINGS_DIR="$BASE_DIR/test_recordings"
BACKUP_DIR="$BASE_DIR/test_recordings_backups"
ANALYSE_SCRIPT="$BASE_DIR/analyse-recording.sh"

TOOLS_DIR="/mnt/c/Users/$USER_NAME/test_suite_scripts"
STATE_FILE="$TOOLS_DIR/.analyse_wave_last"
INSTRUCTIONS_FILE="$TOOLS_DIR/Analyse_Recording_Instructions.md"

mkdir -p "$BACKUP_DIR"
mkdir -p "$TOOLS_DIR"

LAST_FILE=""
LAST_OPTIONS=""
LAST_RECORDINGS_DIR=""

if [ -f "$STATE_FILE" ]; then
    # shellcheck disable=SC1090
    source "$STATE_FILE"
fi

echo ""
echo "=== WAVE Recording Analysis ==="
echo ""

# Open analysis instructions in Notepad
if [ -f "$INSTRUCTIONS_FILE" ]; then
    WIN_PATH="$(wslpath -w "$INSTRUCTIONS_FILE" 2>/dev/null || true)"
    if [ -n "$WIN_PATH" ]; then
        cmd.exe /c start notepad.exe "$WIN_PATH" 2>/dev/null &
    fi
fi

if [ ! -d "$RECORDINGS_DIR" ]; then
    echo "Recording folder not found:"
    echo "$RECORDINGS_DIR"
    exit 1
fi

if [ ! -x "$ANALYSE_SCRIPT" ]; then
    echo "Analysis script not found or not executable:"
    echo "$ANALYSE_SCRIPT"
    exit 1
fi

DOF_IMAGE="$(docker images dpctf-dof --format '{{.Repository}}:{{.Tag}}' | head -n 1 2>/dev/null || true)"

if [ -z "$DOF_IMAGE" ]; then
    echo ""
    echo "Device Observation Framework (DOF) Docker image not found."
    echo "The DOF image must be built before analysis can run."
    echo ""
    read -r -p "Build DOF now? [Y/n]: " BUILD_DOF_REPLY
    BUILD_DOF_REPLY="${BUILD_DOF_REPLY:-Y}"

    if [[ "$BUILD_DOF_REPLY" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]; then
        DOF_BUILD_SCRIPT="$BASE_DIR/build-dof.sh"
        if [ ! -f "$DOF_BUILD_SCRIPT" ]; then
            echo "ERROR: build-dof.sh not found in $BASE_DIR"
            exit 1
        fi
        chmod +x "$DOF_BUILD_SCRIPT"
        cd "$BASE_DIR"
        ./build-dof.sh
        DOF_IMAGE="$(docker images dpctf-dof --format '{{.Repository}}:{{.Tag}}' | head -n 1 2>/dev/null || true)"
        if [ -z "$DOF_IMAGE" ]; then
            echo "ERROR: DOF image still not found after build. Check build-dof.sh output."
            exit 1
        fi
        echo "DOF image built: $DOF_IMAGE"
        cd "$RECORDINGS_DIR"
    else
        echo "Cannot run analysis without the DOF image. Exiting."
        exit 1
    fi
else
    echo "DOF image found: $DOF_IMAGE"
fi

cd "$RECORDINGS_DIR"

echo "Available recordings:"
echo ""

shopt -s nullglob
FILES=( *.mp4 *.MP4 *.mov *.MOV )
shopt -u nullglob

if [ ${#FILES[@]} -eq 0 ]; then
    echo "No .mp4 or .mov recordings found in:"
    echo "$RECORDINGS_DIR"
    exit 1
fi

for i in "${!FILES[@]}"; do
    printf "%2d) %s\n" $((i+1)) "${FILES[$i]}"
done

echo ""
if [ -n "$LAST_FILE" ]; then
    echo "Last selected file: $LAST_FILE"
fi
read -r -p "Select recording number, or press Enter to reuse last file: " FILE_INDEX_INPUT

VIDEO_FILE=""

if [ -z "$FILE_INDEX_INPUT" ]; then
    if [ -n "$LAST_FILE" ] && [ -f "$LAST_FILE" ]; then
        VIDEO_FILE="$LAST_FILE"
        echo "Reusing last file: $VIDEO_FILE"
    else
        echo "No valid previous file found."
        exit 1
    fi
else
    FILE_INDEX=$((FILE_INDEX_INPUT-1))
    if [ "$FILE_INDEX" -lt 0 ] || [ "$FILE_INDEX" -ge "${#FILES[@]}" ]; then
        echo "Invalid selection."
        exit 1
    fi
    VIDEO_FILE="${FILES[$FILE_INDEX]}"
fi

if [ ! -f "$VIDEO_FILE" ]; then
    echo "Selected file not found:"
    echo "$VIDEO_FILE"
    exit 1
fi

EXT="${VIDEO_FILE##*.}"
WORK_FILE="$VIDEO_FILE"

if [ "$EXT" = "mov" ] || [ "$EXT" = "MOV" ]; then
    MP4_NAME="${VIDEO_FILE%.*}.mp4"
    echo ""
    echo "Recording is .mov — creating working .mp4 copy..."
    cp -f "$VIDEO_FILE" "$MP4_NAME"
    WORK_FILE="$MP4_NAME"
fi

echo ""
echo "Common analysis options:"
echo "1) none"
echo "2) --log debug"
echo "3) --scan intensive"
echo "4) custom"

if [ -n "$LAST_OPTIONS" ]; then
    echo "Last options: $LAST_OPTIONS"
fi

read -r -p "Select option number, or press Enter to reuse last options: " OPT_CHOICE

OPTIONS=""

if [ -z "$OPT_CHOICE" ]; then
    OPTIONS="$LAST_OPTIONS"
    echo "Reusing last options: ${OPTIONS:-none}"
else
    case "$OPT_CHOICE" in
    1)
        OPTIONS=""
        ;;
    2)
        OPTIONS="--log debug"
        ;;
    3)
        OPTIONS="--scan intensive"
        ;;
    4)
        read -r -p "Enter custom options: " OPTIONS
        ;;
    *)
        echo "Invalid option."
        exit 1
        ;;
    esac
fi

echo ""
echo "Creating backup of original recording..."
cp -f "$VIDEO_FILE" "$BACKUP_DIR/"

COMMAND="./analyse-recording.sh \"$RECORDINGS_DIR/$WORK_FILE\""
if [ -n "$OPTIONS" ]; then
    COMMAND="$COMMAND $OPTIONS"
fi

echo ""
echo "Command to run:"
echo "$COMMAND"
echo ""

read -r -p "Run analysis now? (y/N): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Analysis cancelled."
    exit 0
fi

cat > "$STATE_FILE" <<EOF
LAST_FILE=$(printf '%q' "$VIDEO_FILE")
LAST_OPTIONS=$(printf '%q' "$OPTIONS")
LAST_RECORDINGS_DIR=$(printf '%q' "$RECORDINGS_DIR")
EOF

cd "$BASE_DIR"

echo ""
echo "Running analysis..."
echo ""

if [ -n "$OPTIONS" ]; then
    ./analyse-recording.sh "$RECORDINGS_DIR/$WORK_FILE" $OPTIONS
else
    ./analyse-recording.sh "$RECORDINGS_DIR/$WORK_FILE"
fi

echo ""
echo "Analysis complete."
echo "Saved last-used state to:"
echo "  $STATE_FILE"
echo ""
