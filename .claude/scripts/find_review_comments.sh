#!/bin/bash

# Find all //Review: comments in source code and test files
# Output format: filename:line:comment

# Define directories to search (default to src and tests if they exist)
SEARCH_DIRS=""

if [ -d "src" ]; then
    SEARCH_DIRS="$SEARCH_DIRS src"
fi

if [ -d "tests" ]; then
    SEARCH_DIRS="$SEARCH_DIRS tests"
fi

if [ -d "test" ]; then
    SEARCH_DIRS="$SEARCH_DIRS test"
fi

# If no standard directories found, search current directory
if [ -z "$SEARCH_DIRS" ]; then
    SEARCH_DIRS="."
fi

# Search for //Review: comments in various file types
# Using grep with line numbers and filenames
grep -n "//\s*Review:" $SEARCH_DIRS \
    -r \
    --include="*.ts" \
    --include="*.tsx" \
    --include="*.js" \
    --include="*.jsx" \
    --include="*.py" \
    --include="*.go" \
    --include="*.rs" \
    --include="*.java" \
    --include="*.cpp" \
    --include="*.c" \
    --include="*.h" \
    --include="*.hpp" \
    2>/dev/null | \
    while IFS=: read -r filename line content; do
        # Extract just the comment part after //Review:
        comment=$(echo "$content" | sed 's/.*\/\/\s*Review:\s*//')
        echo "$filename:$line:$comment"
    done

# Exit successfully even if no comments found
exit 0