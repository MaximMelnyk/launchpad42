#!/bin/bash
# _helpers.sh — shared test helpers (sourced by test scripts)
# Provides compilation attempt tracking.

# Track compilation attempts for an exercise.
# Usage: track_compile "$EXERCISE_ID"
# Stores count in .compile_count file in student's working directory.
track_compile() {
    local exercise_id="$1"
    local src_dir="${SRC_DIR:-.}"
    local count_file="${src_dir}/.compile_count"
    local count=0

    if [ -f "$count_file" ]; then
        # Read current count for this exercise (exact match via awk)
        local existing
        existing=$(awk -F: -v id="$exercise_id" '$1 == id {print $2}' "$count_file" 2>/dev/null)
        if [ -n "$existing" ]; then
            count="$existing"
        fi
    fi

    count=$((count + 1))

    # Update or append entry (awk for exact field match, no regex issues)
    if [ -f "$count_file" ] && awk -F: -v id="$exercise_id" '$1 == id {found=1} END {exit !found}' "$count_file" 2>/dev/null; then
        awk -F: -v id="$exercise_id" -v cnt="$count" 'BEGIN{OFS=":"} $1 == id {$2 = cnt} {print}' "$count_file" > "${count_file}.tmp" && mv "${count_file}.tmp" "$count_file"
    else
        echo "${exercise_id}:${count}" >> "$count_file"
    fi

    export _COMPILE_COUNT="$count"
}

# Show compilation count after hash output.
# Usage: show_compile_count
show_compile_count() {
    if [ -n "$_COMPILE_COUNT" ]; then
        echo "(Compilations: ${_COMPILE_COUNT})"
    fi
}
