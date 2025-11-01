#!/bin/bash
# ---------------------------------------------------
# ✅ Jenkins Gmail Notification Script
# ✅ Designed & Developed by: sak_shetty
# ---------------------------------------------------

LOG_DIR="/opt/scripts/logs"
LOG_FILE="$LOG_DIR/jenkins_notify_$(date +%F).log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Auto grant execute permission if missing
if [ ! -x "$0" ]; then
  echo "🔐 Fixing script execute permission..." | tee -a "$LOG_FILE"
  chmod +x "$0"
fi

STATUS="$1"
JOB_NAME="$2"
BUILD_ID="$3"
TO_EMAIL="$4"

GMAIL_USER="${GMAIL_USER}"
GMAIL_APP_PASS="${GMAIL_APP_PASS}"

if [ -z "$STATUS" ] || [ -z "$JOB_NAME" ] || [ -z "$BUILD_ID" ] || [ -z "$TO_EMAIL" ]; then
  echo "❌ Missing arguments" | tee -a "$LOG_FILE"
  echo "Usage: ./jenkins_notify.sh <STATUS> <JOB_NAME> <BUILD_ID> <RECEIVER_EMAIL>" | tee -a "$LOG_FILE"
  exit 1
fi

# Install required packages if missing
if ! command -v ssmtp >/dev/null 2>&1; then
  echo "📦 Installing ssmtp & mailutils..." | tee -a "$LOG_FILE"
  sudo apt-get update -y >> "$LOG_FILE" 2>&1
  sudo apt-get install ssmtp mailutils -y >> "$LOG_FILE" 2>&1
fi

echo "⚙️ Configuring ssmtp..." | tee -a "$LOG_FILE"
sudo bash -c "cat > /etc/ssmtp/ssmtp.conf <<EOF
root=$GMAIL_USER
mailhub=smtp.gmail.com:587
AuthUser=$GMAIL_USER
AuthPass=$GMAIL_APP_PASS
UseSTARTTLS=YES
UseTLS=YES
hostname=localhost
FromLineOverride=YES
EOF"

SUBJECT="Jenkins Build Notification - $JOB_NAME (#$BUILD_ID)"
BODY="
Hello,

Jenkins job finished.

✅ Job: $JOB_NAME
🔢 Build: $BUILD_ID
📌 Status: $STATUS
👨‍💻 Designed & Developed by: sak_shetty

Regards,
Jenkins Notification Service
"

echo "📤 Sending email to $TO_EMAIL..." | tee -a "$LOG_FILE"
echo "$BODY" | mail -s "$SUBJECT" "$TO_EMAIL" 2>&1 | tee -a "$LOG_FILE"

echo "✅ Email sent at $(date)" | tee -a "$LOG_FILE"
exit 0
