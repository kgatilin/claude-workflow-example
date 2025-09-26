#!/bin/bash

# Initialize task setup script
# Usage: init_task_setup.sh <backlog-file>

set -e  # Exit on error

BACKLOG_INPUT="$1"

# Parse input path
if [[ "$BACKLOG_INPUT" == @* ]]; then
    FILEPATH="${BACKLOG_INPUT:1}"
else
    FILEPATH=".agent/backlog/$BACKLOG_INPUT"
    [[ "$FILEPATH" != *.md ]] && FILEPATH="$FILEPATH.md"
fi

# Extract task name
TASK_NAME=$(basename "$FILEPATH" .md)

# Verify backlog file exists
if [ ! -f "$FILEPATH" ]; then
    echo "❌ Error: Backlog file not found: $FILEPATH"
    echo "Available backlog items:"
    ls -1 .agent/backlog/*.md 2>/dev/null | xargs -I {} basename {} .md || echo "No backlog items found"
    exit 1
fi

# Create feature branch
echo "Creating branch: feature/$TASK_NAME"
git checkout -b "feature/$TASK_NAME"

# Create task directory
echo "Creating task directory: .agent/tasks/$TASK_NAME/"
mkdir -p ".agent/tasks/$TASK_NAME"

# Copy stage template
echo "Setting up stage tracking..."
cp .agent/templates/stage.yaml ".agent/tasks/$TASK_NAME/stage.yaml"

# Update template with current values
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
sed -i '' "s/{timestamp}/$TIMESTAMP/g" ".agent/tasks/$TASK_NAME/stage.yaml"
sed -i '' "s/{branch_name}/feature\\/$TASK_NAME/g" ".agent/tasks/$TASK_NAME/stage.yaml"

# Output success
echo "✅ Branch: feature/$TASK_NAME"
echo "✅ Folder: .agent/tasks/$TASK_NAME/"
echo "✅ Stage tracking initialized"
echo "Task name: $TASK_NAME"