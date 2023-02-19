#!/usr/bin/env python3
# Remover.py
# Remove comments from PowerShell scripts
# Author: Calvindd2f

import argparse

parser = argparse.ArgumentParser(description='Remove comments from PowerShell scripts.')
parser.add_argument('input_file', type=str, help='Path to input PowerShell script')
parser.add_argument('output_file', type=str, help='Path to output stripped PowerShell script')
args = parser.parse_args()

currently_code = True

with open(args.input_file, 'r') as readtest:
    psup_contents = readtest.readlines()

with open(args.output_file, 'w') as removed:
    for line in psup_contents:
        line = line.lstrip()

        if line.startswith("#") and not line.startswith("#>"):
            pass

        elif line.startswith("<#"):
            currently_code = False

        elif line.startswith('\n'):
            pass

        elif line.startswith("#>"):
            currently_code = True

        else:
            if currently_code:
                removed.write(line)
