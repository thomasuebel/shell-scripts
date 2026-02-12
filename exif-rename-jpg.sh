#!/bin/sh
#
# Renames .jpg files by prepending the EXIF creation date (YYYYMMDD_).
# Usage: exif-rename-jpg.sh [directory]
#   directory  — folder to process (defaults to current directory)

set -eu

target_dir="${1:-.}"

if [ ! -d "$target_dir" ]; then
    printf "Error: '%s' is not a directory\n" "$target_dir" >&2
    exit 1
fi

if ! command -v exiftool >/dev/null 2>&1; then
    printf "Error: exiftool is required but not installed\n" >&2
    exit 1
fi

orig_dir="$(pwd)"
cd "$target_dir"

found=0
for f in *.jpg *.JPG; do
    [ -f "$f" ] || continue
    found=1

    date_str=$(exiftool -DateTimeOriginal -s3 -d "%Y%m%d" "$f" 2>/dev/null)

    if [ -z "$date_str" ]; then
        printf "No EXIF creation date: %s — skipping\n" "$f"
        continue
    fi

    new_name="${date_str}_${f}"

    if [ -e "$new_name" ]; then
        printf "Target already exists: %s — skipping %s\n" "$new_name" "$f" >&2
        continue
    fi

    mv "$f" "$new_name"
    printf "Renamed: %s -> %s\n" "$f" "$new_name"
done

if [ "$found" -eq 0 ]; then
    printf "No .jpg files found in %s\n" "$target_dir"
fi

cd "$orig_dir"
