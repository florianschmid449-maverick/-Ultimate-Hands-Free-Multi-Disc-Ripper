# Ultimate Hands-Free Multi-Disc Ripper

This Bash script provides a fully automated solution for archiving optical media. It is designed to run in a continuous loop, allowing you to process a stack of discs by simply inserting them one after another.

---

## 🚀 Key Features

* **Automated Workflow:** Detects disc insertion, rips the content, and ejects the tray automatically without user intervention.
* **Intelligent Media Detection:** Differentiates between DVDs and Blu-rays to optimize block sizes () for the ripping process.
* **Resilient Ripping:** Utilizes `ddrescue` to perform multiple passes, ensuring data is recovered even from discs with minor surface damage.
* **Large File Handling:** Automatically detects Blu-rays larger than 25GB and splits them into manageable 4GB chunks to maintain compatibility with various file systems.
* **Integrity Verification:** Generates a SHA256 checksum for standard ISO images to ensure a perfect copy.
* **Auto-Mounting:** Mounts the newly created ISO to your desktop immediately after the rip for quick verification.
* **Smart Storage Management:** Checks available disk space before starting and automatically cleans up mount points from previous sessions.

---

## 🛠 Prerequisites

The script is intended for Linux environments (specifically Debian/Ubuntu-based distributions).

* **Sudo Privileges:** Required for mounting images and installing dependencies.
* **Required Utilities:** The script will attempt to install `gddrescue` if it is not found on your system.
* **Hardware:** An internal or external optical drive mapped to `/dev/cdrom`.

---

## 📖 How to Use

1. **Prepare the Script:** Save the code to a file named `ultimate_handsfree_ripper.sh` and make it executable:
```bash
chmod +x ultimate_handsfree_ripper.sh

```


2. **Launch:** Run the script in your terminal:
```bash
./ultimate_handsfree_ripper.sh

```


3. **Insert Media:** Place a disc in the drive. The script will detect it, rip it to your desktop with a timestamped filename, and eject the disc when finished.
4. **Repeat:** Insert the next disc once the tray opens.

---

## 📂 Output and Organization

* **ISO Files:** Standard rips are saved as `.iso` files on your desktop.
* **Split Files:** Large Blu-rays are saved as multiple parts (e.g., `_partaa`, `_partab`).
* **Logs:** A `.log` file is generated for every rip, detailing the `ddrescue` operation.
* **Mount Points:** For non-split discs, a folder named `[filename]_mount` will appear on your desktop.

---
