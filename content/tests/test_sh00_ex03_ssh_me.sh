#!/bin/bash
# test_sh00_ex03_ssh_me.sh — hash verification
# Usage: bash test_sh00_ex03_ssh_me.sh [source_dir]
set -e

EXERCISE_ID="sh00_ex03_ssh_me"
SRC_DIR="${1:-.}"

echo "=== Testing: ${EXERCISE_ID} ==="

# Check that id_rsa.pub exists
if [ ! -f "${SRC_DIR}/id_rsa.pub" ]; then
    echo "FAILED: File 'id_rsa.pub' not found in ${SRC_DIR}/"
    exit 1
fi

# Check that the file is not empty
FILE_SIZE=$(wc -c < "${SRC_DIR}/id_rsa.pub")
if [ "$FILE_SIZE" -lt 50 ]; then
    echo "FAILED: id_rsa.pub seems too small (${FILE_SIZE} bytes). Is it a valid public key?"
    exit 1
fi
echo "  File size: OK (${FILE_SIZE} bytes)"

# Check that it starts with a valid key type
FIRST_WORD=$(head -1 "${SRC_DIR}/id_rsa.pub" | cut -d' ' -f1)
case "$FIRST_WORD" in
    ssh-rsa|ssh-ed25519|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521|ssh-dss)
        echo "  Key type: OK (${FIRST_WORD})"
        ;;
    *)
        echo "FAILED: id_rsa.pub must start with a valid key type (ssh-rsa, ssh-ed25519, etc.), got '${FIRST_WORD}'"
        exit 1
        ;;
esac

# Validate key format with ssh-keygen (if available)
if command -v ssh-keygen &> /dev/null; then
    if ssh-keygen -l -f "${SRC_DIR}/id_rsa.pub" > /dev/null 2>&1; then
        KEY_INFO=$(ssh-keygen -l -f "${SRC_DIR}/id_rsa.pub")
        echo "  Key validation: OK (${KEY_INFO})"
    else
        echo "FAILED: ssh-keygen could not validate the key. Is id_rsa.pub a valid SSH public key?"
        exit 1
    fi
fi

# Check that private key is NOT submitted
if [ -f "${SRC_DIR}/id_rsa" ]; then
    echo "WARNING: Private key 'id_rsa' found! NEVER submit your private key!"
    echo "FAILED: Remove id_rsa from submission"
    exit 1
fi

# All tests passed
HASH=$(echo -n "${USER}-${EXERCISE_ID}-$(date +%Y%m%d)" | sha256sum | cut -c1-8)
echo "ALL TESTS PASSED"
echo "Code: $HASH"
exit 0
