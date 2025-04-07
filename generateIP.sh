#!/bin/bash

# Function to convert IP to integer
ip_to_int() {
    local IFS=.
    read -r i1 i2 i3 i4 <<< "$1"
    echo $(( (i1 << 24) + (i2 << 16) + (i3 << 8) + i4 ))
}

# Function to convert integer to IP
int_to_ip() {
    local ip=$1
    echo "$(( (ip >> 24) & 255 )).$(( (ip >> 16) & 255 )).$(( (ip >> 8) & 255 )).$(( ip & 255 ))"
}

# Function to convert mask to CIDR bits
mask_to_cidr() {
    local mask=$1
    local bits=0
    local IFS=.
    read -r m1 m2 m3 m4 <<< "$mask"
    for oct in $m1 $m2 $m3 $m4; do
        while [ $oct -gt 0 ]; do
            bits=$(( bits + (oct & 1) ))
            oct=$(( oct >> 1 ))
        done
    done
    echo $bits
}

# Get input
echo "Simple IP Generator"
read -p "Enter subnet and mask (e.g., 192.168.1.0,255.255.255.0): " input

# Split input into subnet and mask
IFS=',' read -r subnet mask <<< "$input"

# Calculate range
network_int=$(ip_to_int "$subnet")
mask_bits=$(mask_to_cidr "$mask")
num_hosts=$(( 2 ** (32 - mask_bits) ))
first_ip=$(( network_int + 1 ))
last_ip=$(( network_int + num_hosts - 2 ))

# Print usable IPs
echo -e "\nUsable IP addresses:"
for ((i = first_ip; i <= last_ip; i++)); do
    echo "$(int_to_ip "$i")"
done
