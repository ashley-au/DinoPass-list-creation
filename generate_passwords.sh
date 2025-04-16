#!/bin/bash

# generate_passwords.sh - Generates a list of strong passwords from dinopass.com
# Usage: ./generate_passwords.sh [number_of_passwords]

# Default number of passwords to generate
NUM_PASSWORDS=${1:-10}

# Validate input
if ! [[ "$NUM_PASSWORDS" =~ ^[0-9]+$ ]]; then
    echo "Error: Please provide a valid positive number."
    exit 1
fi

if [ "$NUM_PASSWORDS" -lt 1 ]; then
    echo "Error: Number of passwords must be at least 1."
    exit 1
fi

echo "Generating $NUM_PASSWORDS unique strong passwords..."
echo "Saving to password_list.txt"

# Keep track of unique passwords
declare -A seen_passwords

# Counter for successful fetches
count=0

# Check if the output file already exists
if [ -f "password_list.txt" ]; then
    echo "Warning: password_list.txt already exists."
    echo "Do you want to (a)ppend to it, (o)verwrite it, or (c)ancel?"
    read -p "Enter choice [a/o/c]: " choice
    
    # Convert to lowercase for easier comparison
    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
    
    case "$choice" in
        a|append)
            echo "Appending to existing file..."
            # Read existing passwords into the seen_passwords array
            while IFS= read -r line; do
                if [ -n "$line" ]; then
                    seen_passwords["$line"]=1
                    ((count++))
                fi
            done < password_list.txt
            
            echo "Found $count existing passwords in the file."
            echo "Will add $NUM_PASSWORDS more unique passwords."
            ;;
        o|overwrite)
            echo "Overwriting existing file..."
            # Create/clear the output file
            > password_list.txt
            ;;
        *)
            echo "Operation canceled. Exiting."
            exit 0
            ;;
    esac
else
    # Create a new output file
    > password_list.txt
fi

# Track initial count to calculate new passwords added
initial_count=$count

# Set target count based on whether we're appending or starting fresh
target_count=$((initial_count + NUM_PASSWORDS))

echo "[$initial_count/$target_count] passwords collected"

# Continue until we have the requested number of unique passwords
while [ $count -lt $target_count ]; do
    # Fetch a password from dinopass
    password=$(curl -s https://www.dinopass.com/password/strong)
    
    # Check if curl was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to connect to dinopass.com. Retrying..."
        sleep 1
        continue
    fi
    
    # Check if the password is not empty and not seen before
    if [ -n "$password" ] && [ -z "${seen_passwords[$password]}" ]; then
        echo "$password" >> password_list.txt
        seen_passwords["$password"]=1
        ((count++))
        
        # Update progress
        echo -ne "\r[$count/$target_count] passwords collected"
    fi
    
    # Add a small delay to avoid hammering the website
    sleep 0.2
done

new_passwords=$((count - initial_count))
echo -e "\nDone! $new_passwords new passwords added (total: $count)."
echo "All passwords saved to password_list.txt"

