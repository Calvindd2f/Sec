#!/usr/bin/env python3
# Author: Calvindd2f
import base64
import argparse

parser = argparse.ArgumentParser(description='Convert binary file containing shellcode to various formats')
parser.add_argument('input_file', type=str, help='Path to input binary file containing shellcode')
args = parser.parse_args()

with open(args.input_file, 'rb') as sc_handle:
    sc_data = sc_handle.read()

encoded_raw = base64.b64encode(sc_data)

binary_code = ''
fs_code = ''
for byte in sc_data:
    binary_code += "\\x" + hex(byte)[2:].zfill(2)
    fs_code += "0x" + hex(byte)[2:].zfill(2) + "uy;"

cs_shellcode = "0" + ",0".join(binary_code.split("\\")[1:])
encoded_cs = base64.b64encode(cs_shellcode.encode())

with open('formatted_shellcode.txt', 'w') as format_out:
    format_out.write("Binary Blob base64 encoded:\n\n")
    format_out.write(encoded_raw.decode('ascii'))
    format_out.write("\n\nStandard shellcode format:\n\n")
    format_out.write(binary_code)
    format_out.write("\n\nC# formatted shellcode:\n\n")
    format_out.write(cs_shellcode)
    format_out.write("\n\nBase64 Encoded C# shellcode:\n\n")
    format_out.write(encoded_cs.decode('ascii'))
    format_out.write("\n\nF# Shellcode:\n\n")
    format_out.write(fs_code)
    format_out.write("\n")

