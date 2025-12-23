#!/bin/bash

# =========================================
# Ultimate Hands-Free Multi-Disc Ripper
# =========================================

DVD_DEVICE="/dev/cdrom"
DESKTOP="$HOME/Desktop"
LAST_MOUNT=""

# Notification function
notify() {
    if command -v notify-send &>/dev/null; then
        notify-send "Disc Ripper" "$1"
    fi
}

# Ensure ddrescue is installed
if ! command -v ddrescue &>/dev/null; then
    echo "🛠 Installing ddrescue..."
    sudo apt update && sudo apt install -y gddrescue
fi

echo "🎬 Ultimate hands-free multi-disc ripper started."
echo "⚠️ Press Ctrl+C to stop at any time."

while true; do
    # Wait for disc insertion
    echo "📀 Waiting for disc..."
    while [ ! -b "$DVD_DEVICE" ]; do
        sleep 2
    done
    echo "📀 Disc detected."

    # Detect disc type
    DISC_TYPE=$(blkid "$DVD_DEVICE" 2>/dev/null | grep -o "iso9660")
    if [ "$DISC_TYPE" == "iso9660" ]; then
        BS=2048
        echo "📀 DVD detected"
    else
        BS=1M
        echo "📀 Blu-ray or unknown disc detected"
    fi

    # Generate timestamped filename
    DATE_STR=$(date +%Y%m%d_%H%M%S)
    BASE_NAME="disc_rip_$DATE_STR"
    FILENAME="$BASE_NAME.iso"
    COUNTER=1
    while [ -e "$DESKTOP/$FILENAME" ]; do
        FILENAME="${BASE_NAME}_$COUNTER.iso"
        ((COUNTER++))
    done
    OUTPUT_FILE="$DESKTOP/$FILENAME"
    LOG_FILE="$DESKTOP/${FILENAME}.log"

    # Check free space
    DISC_SIZE=$(blockdev --getsize64 "$DVD_DEVICE" 2>/dev/null || echo 4700000000)
    FREE_SPACE=$(df --output=avail "$DESKTOP" | tail -1)
    FREE_SPACE=$((FREE_SPACE * 1024))
    if [ "$FREE_SPACE" -lt "$DISC_SIZE" ]; then
        echo "❌ Not enough free space. Ejecting disc and waiting for next."
        sudo eject "$DVD_DEVICE"
        sleep 5
        continue
    fi

    # Start ripping
    echo "⏳ Ripping to $OUTPUT_FILE..."
    sudo ddrescue -b "$BS" -n "$DVD_DEVICE" "$OUTPUT_FILE" "$LOG_FILE"
    sudo ddrescue -b "$BS" -r 3 "$DVD_DEVICE" "$OUTPUT_FILE" "$LOG_FILE"

    # Check for large Blu-ray (>25GB) and split if necessary
    if [ "$DISC_TYPE" != "iso9660" ] && [ "$DISC_SIZE" -gt $((25*1024*1024*1024)) ]; then
        echo "⚠️ Large Blu-ray detected (>25GB). Splitting ISO..."
        SPLIT_PREFIX="${OUTPUT_FILE%.iso}_part"
        split -b 4G "$OUTPUT_FILE" "$SPLIT_PREFIX"
        rm -f "$OUTPUT_FILE"
        echo "📦 Blu-ray split into multiple files with prefix $SPLIT_PREFIX"
        notify "Blu-ray ripped and split successfully"
    else
        # SHA256 verification
        ISO_SUM=$(sha256sum "$OUTPUT_FILE" | awk '{print $1}')
        echo "✅ Ripping complete. SHA256: $ISO_SUM"
        notify "Disc ripped successfully: $FILENAME"
    fi

    # Unmount previous ISO if mounted
    if [ -n "$LAST_MOUNT" ] && mountpoint -q "$LAST_MOUNT"; then
        echo "🗂 Unmounting previous ISO at $LAST_MOUNT..."
        sudo umount "$LAST_MOUNT"
        rm -rf "$LAST_MOUNT"
    fi

    # Mount new ISO if not split
    if [ "$DISC_TYPE" == "iso9660" ] || [ "$DISC_SIZE" -le $((25*1024*1024*1024)) ]; then
        MOUNT_DIR="$DESKTOP/${FILENAME%.iso}_mount"
        mkdir -p "$MOUNT_DIR"
        sudo mount -o loop "$OUTPUT_FILE" "$MOUNT_DIR"
        echo "📂 ISO mounted at $MOUNT_DIR"
        LAST_MOUNT="$MOUNT_DIR"
    fi

    # Eject disc automatically
    sudo eject "$DVD_DEVICE"
    echo "📀 Disc ejected. Waiting for next disc..."
    sleep 3
done

