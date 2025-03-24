#!/bin/bash

# Check if at least one argument is provided
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <url1> <url2> ..."
    exit 1
fi

# Loop through each URL provided as an argument
for url in "$@"; do
    echo "Processing URL: $url"

    # Resolve all redirects to get the final URL
    final_url=$(curl -s -L --max-redirs 0 -o /dev/null -w "%{redirect_url}" "$url")

    if [[ -z "$final_url" ]]; then
        echo "No redirect URL for: $url"
        final_url = $url
        continue
    fi

    echo "Resolved URL: $final_url"

    # Extract the filename from the URL
    filename=$(basename "$final_url")

    # Check if a partially downloaded file exists
    if [[ -f "$filename" ]]; then
        echo "Partially downloaded file found: $filename. Resuming download..."
        aria2c -x 16 -s 16 --continue=true --max-connection-per-server=16 --min-split-size=1M --file-allocation=falloc "$final_url"
    else
        echo "Starting new download for: $filename"
        aria2c -x 16 -s 16 --max-connection-per-server=16 --min-split-size=1M --file-allocation=falloc "$final_url"
    fi
done
