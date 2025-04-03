#!/usr/bin/env python3
import os
import glob
import re
import argparse

'''
Images Linter
The script checks for dead references and unused images in the markdown files.

Example:

./images_linter.py .

'''

class color:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

# Parse command-line arguments
parser = argparse.ArgumentParser(
    description="Images Linter: Check for dead references and unused images in markdown files."
)
parser.add_argument("directory", nargs="?", default=".", help="Directory to check (default: current directory).")
parser.add_argument("--delete", action="store_true", help="Delete unused images.")
args = parser.parse_args()

image_dir = "./images"
image_extensions = ("*.png", "*.svg", "*.jpeg", "*.jpg", "*.gif")

# List all images in the images directory
existing_images = set()
for ext in image_extensions:
    existing_images.update(os.path.basename(img) for img in glob.glob(os.path.join(image_dir, ext)))

# List all markdown files
md_files = glob.glob("*.md")

# Find all image references in markdown files
referenced_images = set()
image_regex = re.compile(r'!\[.*\]\(((.*)/(.*\.(.+)))\)')  # Match ![alt](path/to/image)
extensions = ["png", "svg", "jpeg", "jpg","gif"]

dead_references = set()
for md_file in md_files:
    with open(md_file, 'r', encoding='utf-8') as f:
        content = f.read()
        matches = image_regex.findall(content)
        for match in matches:
            referenced_images.add(match[2])
            if match[3] not in extensions:
                print(f"{color.WARNING}[WARNING]{color.ENDC} Unknown image extension in {md_file}: {match[0]}")
            if match[1] != "./images" and match[1] != "images":
                print(f"{color.FAIL}[ERROR]{color.ENDC} Invalid image path in {md_file}: {match[0]}")
            if match[2] not in existing_images:
                dead_references.add((md_file, match[2]))

# Images that exist but are not referenced
unused_images = existing_images - referenced_images

# Output results
if dead_references:
    print(f"\n{color.FAIL}[ERROR]{color.ENDC} Dead references (referenced in .md but missing in ./images/):")
    for md, img in dead_references:
        print(f" - {img} (in {md})")
else:
    print(f"\n{color.OKGREEN}[INFO]{color.ENDC} No dead references found.")

# Output and optionally delete unused images
if unused_images:
    print(f"\n{color.WARNING}[WARNING]{color.ENDC} Unused images (exist in ./images/ but not referenced in .md):")
    for img in unused_images:
        print(f" - {img}")
    if args.delete:
        for img in unused_images:
            img_path = os.path.join(image_dir, img)
            try:
                os.remove(img_path)
                print(f"{color.OKBLUE}[INFO]{color.ENDC} Deleted unused image: {img}")
            except Exception as e:
                print(f"{color.FAIL}[ERROR]{color.ENDC} Could not delete {img}: {e}")
else:
    print(f"\n{color.OKGREEN}[INFO]{color.ENDC} No unused images found.")
