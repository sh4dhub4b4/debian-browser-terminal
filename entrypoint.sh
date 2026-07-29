#!/bin/bash
set -e

if [ -z "$AUTH_USER" ] || [ -z "$AUTH_PASSWORD" ]; then
    echo "Missing authentication variables"
    exit 1
fi

# --- GIT SYNC LOGIC ---
if [ -n "$GIT_REPO" ] && [ -n "$GIT_TOKEN" ]; then
    echo "Configuring Git Workspace..."
    git config --global user.name "${GIT_USER_NAME:-'Render Terminal'}"
    git config --global user.email "${GIT_USER_EMAIL:-'terminal@render.local'}"

    AUTH_REPO="https://${GIT_TOKEN}@${GIT_REPO}"

    if [ ! -d "/workspace/.git" ]; then
        echo "Cloning repository..."
        git clone "$AUTH_REPO" /workspace
    else
        echo "Pulling latest changes..."
        cd /workspace && git pull
    fi
else
    echo "No Git config provided. Starting empty workspace."
    mkdir -p /workspace
fi

# --- AUTO-RESTORE INSTALLED PACKAGES ON BOOT ---
if [ -f "/workspace/apt-history.log" ]; then
    echo "Restoring packages from apt-history.log..."
    apt update && cat /workspace/apt-history.log | xargs -r apt install -y
fi
# -----------------------------------------------

htpasswd -bc /etc/nginx/.htpasswd "$AUTH_USER" "$AUTH_PASSWORD"
cp /etc/nginx/nginx.conf.template /etc/nginx/nginx.conf

# --- ADD CUSTOM TERMINAL FUNCTIONS ---
cat << 'EOF' > /etc/profile.d/save-alias.sh
save() {
    echo "Saving workspace..."
    (
        cd /workspace
        git add .
        
        if [ -z "$1" ]; then
            git commit -m "Manual save: $(date +'%Y-%m-%d %H:%M:%S')"
        else
            git commit -m "$*"
        fi
        
        git push
    )
    echo "✅ Saved and pushed to remote!"
}

apt() {
    command apt "$@"
    local exit_code=$?
    
    if [[ "$1" == "install" ]] && [ $exit_code -eq 0 ]; then
        echo "apt $@" >> /workspace/apt-history.log
        echo "📝 Logged installation to /workspace/apt-history.log"
    fi
    
    return $exit_code
}
EOF
# -------------------------------------

echo "Testing nginx config..."
nginx -t

echo "Starting supervisor..."
exec supervisord -n
