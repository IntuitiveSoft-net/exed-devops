#!/usr/bin/python3

import re
import os
import sys
import glob

'''
Usage: ./task_linter.py <markdown_file_or_directory>

Lab Task ( user interaction ) and Insight ( description/information on a topic ) are identified by a header in the markdown file. 

The header format is as follows:

## Task X. Task Title
or
## Insight X. Insight Title

All `##` headers in the markdown file must at least define a type ( Task or Insight ).

The script automate the numeration of the `##` headers in the markdown file.

Example:

./task_linter.py my_lab.md
Verifying ./my_lab.md
CHANGED: l:1	## Task Foo -> ## Task 1. Foo
CHANGED: l:5	## Insight 1. Bar -> ## Insight 2. Bar
WARNING: l:9	## Lorem -> has no type ( Task or Insight ) skipping
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

def fix_task_ids(markdown_file):
    print(f"Verifying {markdown_file}")

    # Read the markdown content
    with open(markdown_file, 'r') as file:
        lines = file.readlines()

    header_regex = re.compile(r'^## (.+)')
    type_regex = re.compile(r'^(Task|Insight) (.+)')
    number_regex = re.compile(r'^(\d+)\. (.+)')

    task_counter = 1
    new_lines = []
    lc = 0
    for line in lines:
        lc += 1
        header_match = header_regex.match(line)
        if header_match:
            #Line is a header
            type_match = type_regex.match(header_match.group(1))
            if type_match:
                task_type = type_match.group(1)
                #line has a type
                number_match = number_regex.match(type_match.group(2))
                if number_match:
                    #task has a number
                    task_name = number_match.group(2)
                else:
                    #task has no number
                    task_name = type_match.group(2)
            else:
                #line has no type
                print(f"{color.WARNING}WARNING{color.ENDC}: l:{lc}\t{line.strip()} -> has no type ( Task or Insight ) skipping")
                new_lines.append(line)
                continue
            new_line = f'## {task_type} {task_counter}. {task_name}\n'
            if new_line.strip() != line.strip():
                print(f"{color.OKBLUE}CHANGED{color.ENDC}: l:{lc}\t{line.strip()} -> {new_line.strip()}")
            # Replace it with the correct task number
            new_lines.append(new_line)
            task_counter += 1
        else:
            # Keep the line as is if it's not a task or insight header
            new_lines.append(line)

    # Write the modified content back to the file
    with open(markdown_file, 'w') as file:
        file.writelines(new_lines)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: ./task_linter.py <markdown_file_or_directory>")
        sys.exit(1)

    input_path = sys.argv[1]

    if os.path.isdir(input_path):
        # If input_path is a directory, iterate over all .md files within it
        for md_file in glob.glob(os.path.join(input_path, "*.md")):
            fix_task_ids(md_file)
    else:
        # Otherwise, process the single file
        fix_task_ids(input_path)