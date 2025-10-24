#!/bin/bash

BUCKET="petdirect-cdn-logs"
PREFIX="logs"
LOCAL_DIR="./cdn_logs"
TMP_FILE="ai_requests.tsv"
OUTPUT_FILE="ai_crawler_counts.csv"

# LLM label and their associated regex patterns
LLM_NAMES=("OpenAI" "Anthropic" "Google" "Bard" "OtherAI")
LLM_REGEX=(
    "GPTBot|openai\\.com"
    "Claude|anthropic"
    "Google-Extended"
    "Bard"
    "AI|LLM"
)

mkdir -p "$LOCAL_DIR"

echo "Syncing logs from S3..."
aws --profile ecomhq s3 sync "s3://$BUCKET/$PREFIX" "$LOCAL_DIR"

echo "Decompressing .gz files..."
find "$LOCAL_DIR" -name "*.gz" -exec gunzip -f {} \;

echo "Filtering for AI crawler lines..."
grep -Ei 'GPTBot|openai\.com|Claude|anthropic|Google-Extended|Bard|AI|LLM' "$LOCAL_DIR"/* > "$TMP_FILE"

echo "Processing and counting by Date and LLM..."
echo "Date,LLM,Count" > "$OUTPUT_FILE"

# Loop through each LLM regex
for i in "${!LLM_NAMES[@]}"; do
    LLM="${LLM_NAMES[$i]}"
    PATTERN="${LLM_REGEX[$i]}"
    
    awk -v llm="$LLM" -v pat="$PATTERN" '
    BEGIN { FS="\t" }
    {
        # extract the filename part before the tab, get the date after the colon
        split($1, parts, ":")
        date = parts[2]
        if ($12 ~ pat) {
            count[date]++
        }
    }
    END {
        for (d in count) {
            print d "," llm "," count[d]
        }
    }' "$TMP_FILE" >> "$OUTPUT_FILE"
done

echo "Done! Output written to $OUTPUT_FILE"

