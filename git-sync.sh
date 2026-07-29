#!/bin/bash

# Wait to ensure entrypoint.sh has finished cloning the repo
sleep 10 

if [ ! -d "/workspace/.git" ]; then
    echo "No git repository found in /workspace. Sync disabled."
    exit 0
fi

cd /workspace
git config --global push.default current

while true; do
    sleep 300 # Run every 5 minutes
    
    # Check if there are uncommitted changes
    if [[ $(git status --porcelain) ]]; then
        echo "Changes detected. Syncing to remote..."
        git add .
        git commit -m "Auto-sync: $(date +'%Y-%m-%d %H:%M:%S')"
        git push
        echo "Sync complete."
    fi
done