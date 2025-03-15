#!/bin/bash

# Output file name
output_file="mss-cloud.md"

# Check if the output file already exists and delete it
if [ -e "$output_file" ]; then
  rm "$output_file"
fi

# Loop through all .md files in the folder and append their content to the output file
for file in *.md; do
  if [ "$file" != "$output_file" ]; then
    cat "$file" >> "$output_file"
    echo "" >> "$output_file"  # Add an empty line between concatenated files
  fi
done

echo "Concatenation complete. Output saved to $output_file"
