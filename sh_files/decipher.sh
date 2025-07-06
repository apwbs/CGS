#!/bin/sh

# Initialize variables
requester_name=""
message_id=""
slice_id=""
output_folder=""
function=""

# Parse command-line arguments
while [ $# -gt 0 ]; do
    key="$1"
    case $key in
        --requester_name|-r)
            requester_name="$2"
            shift
            shift
            ;;
        -m|--message_id)
            message_id="$2"
            shift
            shift
            ;;
        -s|--slice_id)
            slice_id="$2"
            shift
            shift
            ;;
        -o|--output_folder)
            output_folder="$2"
            shift
            shift
            ;;
        -f|--function)
            function="$2"
            shift
            shift
            ;;
        *)
            echo "Unknown option $1"
            exit 1
    esac
done

# Check required arguments
if [ -z "$requester_name" ]; then
    echo "You need to specify --requester_name!"
    exit 1
fi

if [ -z "$message_id" ]; then
    echo "You need to specify --message_id!"
    exit 1
fi

if [ -z "$output_folder" ] || [ ! -d "$output_folder" ]; then
    echo "You need to specify a directory for the --output_folder option!"
    exit 1
fi

if [ -z "$function" ]; then
    echo "You need to specify the --function option!"
    exit 1
fi

filename="../src/.env"
count=$(grep -c '^[^#]*''NAME="AUTH' "$filename")

# Run handshake and key generation for each authority
for i in $(seq 1 $count); do
    python3 ../src/client.py --handshake -a "$i" -r "$requester_name"
    python3 ../src/client.py --generate_key -a "$i" -r "$requester_name"
done

# Validate message_id format and correct it from cache if needed
if ! echo "$message_id" | grep -qE '^[0-9]{20}$'; then
    matching_lines=$(grep "$message_id" "../src/.cache")
    if [ $(echo "$matching_lines" | wc -l) -eq 1 ]; then
        message_id=$(echo "$matching_lines" | grep -oP '\b\d+\b')
    fi
fi
# Count number of slices from IPFS
# Derive the actual function name to import based on --function
retrieval_function=$(echo "$function" | sed 's/^get/retrieve/')

# Retrieve IPFS link using the derived function
ipfs_link=$(python3 -c "import sys; sys.path.append('../src'); from block_int import $retrieval_function as retrieve_fn; print(retrieve_fn(int(sys.argv[1]))[1])" "$message_id")
echo "ℹ️ Retrieved IPFS link: '$ipfs_link'"

status=$(python3 -c "import sys; sys.path.append('../src'); from block_int import $retrieval_function as retrieve_fn; print(retrieve_fn(int(sys.argv[1]))[0])" "$message_id")
echo "ℹ️ Retrieved status: '$status'"

# Check if it looks valid (must start with Qm or bafy etc.)
if ! echo "$ipfs_link" | grep -Eq '^(Qm|bafy)[1-9A-HJ-NP-Za-km-z]{44,}$'; then
    echo "❌ Retrieved IPFS link seems invalid: $ipfs_link"
    exit 1
fi

# Count the number of slices in the retrieved IPFS object
count_of_slices=$(ipfs cat "$ipfs_link" | python3 -c "import sys, json; data = sys.stdin.read(); print(len(json.loads(data).get('header', [])))")

# Ensure count_of_slices is numeric
if ! echo "$count_of_slices" | grep -qE '^[0-9]+$'; then
    echo "❌ Invalid slice count received from IPFS"
    exit 1
fi

# Run reader with or without slice_id
if [ -z "$slice_id" ]; then
    if [ "$count_of_slices" -gt 1 ]; then
        echo "You need to specify the slice id (--slice_id) since the message_id has $count_of_slices slices!"
        exit 1
    fi
    python3 ../src/reader.py --message_id "$message_id" \
        --reader_name "$requester_name" --output_folder "$output_folder" \
        --function "$function"
else
    if ! echo "$slice_id" | grep -qE '^[0-9]{20}$'; then
        matching_lines=$(grep "$slice_id" "../src/.cache")
        if [ $(echo "$matching_lines" | wc -l) -eq 1 ]; then
            slice_id=$(echo "$matching_lines" | grep -oP '\b\d+\b')
        fi
    fi
    if [ "$count_of_slices" -eq 1 ]; then
        echo "You do not need to specify the slice id (--slice_id) since the message_id has $count_of_slices slice!"
        exit 1
    fi
    python3 ../src/reader.py --message_id "$message_id" --slice_id "$slice_id" \
        --reader_name "$requester_name" --output_folder "$output_folder" \
        --function "$function"
fi

# Final check
if [ $? -ne 0 ]; then
    echo "Error: python3 command failed!"
else
    echo "✅ Data owner access done"
fi
