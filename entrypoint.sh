#!/bin/bash
set -e

if [ -z "$AUTH_USER" ] || [ -z "$AUTH_PASSWORD" ]; then
    echo "Missing authentication variables"
    exit 1
fi

# --- NEW GIT SYNC LOGIC ---
if [ -n "$GIT_REPO" ] && [ -n "$GIT_TOKEN" ]; then
    echo "Configuring Git Workspace..."
    git config --global user.name "${GIT_USER_NAME:-'Render Terminal'}"
    git config --global user.email "${GIT_USER_EMAIL:-'terminal@render.local'}"

    # Use token for passwordless HTTPS authentication
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
# --------------------------

htpasswd -bc /etc/nginx/.htpasswd "$AUTH_USER" "$AUTH_PASSWORD"
cp /etc/nginx/nginx.conf.template /etc/nginx/nginx.conf

# --- ADD CUSTOM TERMINAL FUNCTIONS ---
cat << 'EOF' > /etc/profile.d/save-alias.sh
save() {
    echo "Saving workspace..."
    # Run in a subshell (...) so it doesn't change your current terminal directory
    (
        cd /workspace
        git add .
        
        # If no argument is provided, use a timestamp
        if [ -z "$1" ]; then
            git commit -m "Manual save: $(date +'%Y-%m-%d %H:%M:%S')"
        else
            # If arguments are provided, use them as the commit message
            git commit -m "$*"
        fi
        
        git push
    )
    echo "✅ Saved and pushed to remote!"
}

apt() {
    # Execute the actual apt command with all passed arguments
    command apt "$@"
    local exit_code=$?
    
    # If the action was 'install' and it completed without errors, log it
    if [[ "$1" == "install" ]] && [ $exit_code -eq 0 ]; then
        # Append the successful install command to a history file in the synced workspace
        echo "apt $@" >> /workspace/apt-history.log
        echo "📝 Logged installation to /workspace/apt-history.log"
    fi
    
    # Return the original exit code so scripts using apt don't break
    return $exit_code
}
EOF
# -------------------------------------

echo "Testing nginx config..."
nginx -t

echo "Starting supervisor..."
exec supervisord -n