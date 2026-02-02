#!/bin/bash

# --- Settings ---
TARGET_USER="ctf"
SUDOERS_FILE="/etc/sudoers.d/ctf-find"
FIND_PATH="/usr/bin/find"

# --- Check Function ---
verify_setup() {
    echo -e "\n[*] Running Verification..."
    # ---Step 1 : user check---
    if ! id "$TARGET_USER" &>/dev/null; then
        echo "[-] Failure: User $TARGET_USER does not exist."
        return 1
    fi

	# Step 2 : Sudos config check
    if [ ! -f "$SUDOERS_FILE" ]; then
        echo "[-] Failure: Sudoers file $SUDOERS_FILE is missing."
        return 1
    fi

    if ! sudo -l -U "$TARGET_USER" | grep -q "$FIND_PATH"; then
        echo "[-] Failure: Sudo rule for $FIND_PATH not found for user $TARGET_USER."
        return 1
    fi
	# Step 3 : run witout password
    if sudo -u "$TARGET_USER" sudo -n "$FIND_PATH" /etc/shadow -maxdepth 0 &>/dev/null; then
        echo "[+] Success: Vulnerability is properly configured!"
        return 0
    else
        echo "[-] Failure: Execution test failed (Password required or rule not active)."
        return 1
    fi
}

# ---Step 1: run as root  ---
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run this script as root (use sudo)."
    exit 1
fi

echo "[*] Starting CTF Environment Setup..."

# --- Step 2: create user (if not exist)---

if id "$TARGET_USER" &>/dev/null; then
    echo "[!] User $TARGET_USER already exists. Skipping creation."
else
    useradd -m -s /bin/bash "$TARGET_USER"
    echo "[+] Created user: $TARGET_USER"
fi

# --- Step 3 : config  sudoers ---
# ---and create file with specific premission ---
echo "$TARGET_USER ALL=(root) NOPASSWD: $FIND_PATH" > "$SUDOERS_FILE"

#--- Settigs for sudoers (0440)---
chown root:root "$SUDOERS_FILE"
chmod 0440 "$SUDOERS_FILE"
echo "[+] Configured sudoers rule in $SUDOERS_FILE (Permissions: 0440)"

# --- Step 4 :Verification---
verify_setup
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "\n[DONE] Setup complete. Target is now vulnerable. Exit code: 0"
else
    echo -e "\n[ERROR] Setup failed verification. Exit code: $EXIT_CODE"
fi

apt-get update
apt-get install -y docker.io
systemctl start docker
systemctl enable docker
docker run -d -p 8000:8000 --name ctfd ctfd/ctfd

exit $EXIT_CODE
