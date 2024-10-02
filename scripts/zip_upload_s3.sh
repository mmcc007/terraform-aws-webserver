#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to display usage information
usage() {
    echo "Usage: $0 -d <directory> -b <s3_bucket> [-n <zip_filename>]"
    echo ""
    echo "Options:"
    echo "  -d    Directory to zip and upload (required)"
    echo "  -b    S3 bucket name (required)"
    echo "  -n    Optional name for the zip file (default: <directory_name>.zip)"
    echo "  -h    Show this help message"
    exit 1
}

# Initialize variables
DIRECTORY=""
S3_BUCKET=""
ZIP_NAME=""

# Parse command-line options
while getopts ":d:b:n:h" opt; do
    case ${opt} in
        d )
            DIRECTORY="$OPTARG"
            ;;
        b )
            S3_BUCKET="$OPTARG"
            ;;
        n )
            ZIP_NAME="$OPTARG"
            ;;
        h )
            usage
            ;;
        \? )
            echo "Invalid Option: -$OPTARG" >&2
            usage
            ;;
        : )
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done

# Check for required arguments
if [ -z "$DIRECTORY" ] || [ -z "$S3_BUCKET" ]; then
    echo "Error: Both directory (-d) and S3 bucket (-b) are required."
    usage
fi

# Check if the specified directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "Error: Directory '$DIRECTORY' does not exist."
    exit 1
fi

# Set default zip name if not provided
if [ -z "$ZIP_NAME" ]; then
    DIR_NAME=$(basename "$DIRECTORY")
    ZIP_NAME="${DIR_NAME}.zip"
fi

# Create the zip file while excluding specified paths
echo "Zipping directory '$DIRECTORY' into '$ZIP_NAME'..."
zip -r "$ZIP_NAME" "$DIRECTORY" \
    -x "*/install_dir/*" \
        "*/ktem_app_data/*" \
        "*/__pycache__/*" \
        "*/libs/ktem/ktem/assets/prebuilt/*" \
    > /dev/null

# Upload the zip file to S3
echo "Uploading '$ZIP_NAME' to S3 bucket '$S3_BUCKET'..."
aws s3 cp "$ZIP_NAME" "s3://$S3_BUCKET/$ZIP_NAME"

# Generate a pre-signed URL with maximum expiration (7 days)
EXPIRATION_SECONDS=604800  # 7 days in seconds

echo "Generating pre-signed URL with expiration of 7 days..."
PRESIGNED_URL=$(aws s3 presign "s3://$S3_BUCKET/$ZIP_NAME" --expires-in $EXPIRATION_SECONDS)

# Output the pre-signed URL
echo "Download URL (expires in 7 days):"
echo "$PRESIGNED_URL"

# Optional: Clean up the local zip file after upload
# Uncomment the following line to remove the zip file after uploading
rm "$ZIP_NAME"

exit 0
