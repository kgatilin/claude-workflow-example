#!/bin/bash

# Get current task context script
# Extracts task information from current branch and folder structure

set -e

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Check if we're on a feature branch
if [[ ! "$CURRENT_BRANCH" =~ ^feature/ ]]; then
    echo "❌ Error: Not on a feature branch. Current branch: $CURRENT_BRANCH"
    echo "Use /workflow:init_task to start a new task or switch to an existing feature branch"
    exit 1
fi

# Extract task name from branch
TASK_NAME=${CURRENT_BRANCH#feature/}

# Check if task directory exists
TASK_DIR=".agent/tasks/$TASK_NAME"
if [ ! -d "$TASK_DIR" ]; then
    echo "❌ Error: Task directory not found: $TASK_DIR"
    echo "Available tasks:"
    ls -1 .agent/tasks/ 2>/dev/null || echo "No active tasks found"
    exit 1
fi

echo "<context>"
echo "Current branch: $CURRENT_BRANCH"
echo "Task name: $TASK_NAME"
echo "Task directory: $TASK_DIR"
echo ""

# List existing task files with @ prefix for auto-reading
echo "Task files to read:"
for file in "$TASK_DIR"/*.md; do
    if [ -f "$file" ]; then
        echo "@$file"
    fi
done

# Check if stage.yaml exists
if [ -f "$TASK_DIR/stage.yaml" ]; then
    echo "@$TASK_DIR/stage.yaml"
fi

echo ""

echo "</context>"