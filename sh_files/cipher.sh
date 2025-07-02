#!/bin/sh

# Initialize variables
input=""
policies=""
sender_name=""
function=""
case_id=""

# Parse command-line arguments
while [ $# -gt 0 ]; do
  key="$1"
  case $key in
    -i|--input)
      input="$2"
      shift
      shift
      ;;
    -p|--policies)
      policies="$2"
      shift
      shift
      ;;
    -s|--sender_name)
      sender_name="$2"
      shift
      shift
      ;;
    -f|--function)
      function="$2"
      shift
      shift
      ;;
    -c|--case_id)
      case_id="$2"
      shift
      shift
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

# Verify required arguments
if [ -z "$input" ] || [ ! -d "$input" ]; then
  echo "You need to provide a directory for the input option: --input"
  exit 1
fi

if [ -z "$policies" ] || [ ! -f "$policies" ]; then
  echo "You need to provide a file for the policies option: --policies"
  exit 1
fi

if [ -z "$sender_name" ]; then
  echo "You need to provide a value for the sender_name parameter: --sender_name"
  exit 1
fi

if [ -z "$function" ]; then
  echo "You need to provide a value for the function parameter: --function"
  exit 1
fi

# Execute the data owner script with optional caseKD
if [ -n "$case_id" ]; then
  python3 ../src/data_owner.py -i "$input" -p "$policies" -s "$sender_name" -f "$function" --case_id "$case_id"
else
  python3 ../src/data_owner.py -i "$input" -p "$policies" -s "$sender_name" -f "$function"
fi

echo "✅ Data owner cipher done"
