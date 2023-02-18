#!/bin/bash
# Author: Calvindd2f : Last change on 8Dec2022

# Set the IP address of the preferred DNS server
PREFERRED_DNS_SERVER="8.8.8.8"

# Create a file to store the iptables rules
IPTABLES_FILE="/etc/iptables/rules.v4"

# Flush any existing iptables rules
iptables -F

# Redirect all DNS requests to the preferred DNS server
iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to-destination $PREFERRED_DNS_SERVER

# Save the iptables rules
iptables-save > $IPTABLES_FILE
