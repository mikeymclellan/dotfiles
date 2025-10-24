import os
import re
import gzip
import shutil
import subprocess
import urllib.parse
from collections import defaultdict
import pandas as pd

# --- Configuration ---
S3_BUCKET = "petdirect-cdn-logs"
S3_PREFIX = "logs"
LOCAL_DIR = "./cdn_logs"
OUTPUT_CSV = "ai_crawler_counts.csv"
AWS_PROFILE = "ecomhq"

# --- Known AI Patterns ---
llm_patterns = {
    "OpenAI": re.compile(r"GPTBot|openai\.com|ChatGPT-User|OAI-SearchBot", re.IGNORECASE),
    "Anthropic": re.compile(r"ClaudeBot|anthropic", re.IGNORECASE),
    "Google": re.compile(r"Googlebot|Google-Extended|AdsBot|Read-Aloud", re.IGNORECASE),
    "Bard": re.compile(r"\bBard\b", re.IGNORECASE),
}

# --- Step 1: Sync logs from S3 ---
print("🔄 Syncing logs from S3...")
os.makedirs(LOCAL_DIR, exist_ok=True)
subprocess.run([
    "aws", "s3", "sync",
    f"s3://{S3_BUCKET}/{S3_PREFIX}", LOCAL_DIR,
    "--profile", AWS_PROFILE
], check=True)

# --- Step 2: Decompress .gz files ---
print("📦 Decompressing log files...")
for root, _, files in os.walk(LOCAL_DIR):
    for file in files:
        if file.endswith(".gz"):
            gz_path = os.path.join(root, file)
            out_path = gz_path[:-3]
            with gzip.open(gz_path, 'rb') as f_in, open(out_path, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
            os.remove(gz_path)

# --- Step 3: Scan Logs ---
print("🔍 Scanning for AI User-Agent patterns...")
llm_counts = defaultdict(int)

for root, _, files in os.walk(LOCAL_DIR):
    for file in files:
        filepath = os.path.join(root, file)
        user_agent_col = None  # reset per file

        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue

                if line.startswith("#Fields:"):
                    fields = line.split()[1:]
                    if "cs(User-Agent)" in fields:
                        user_agent_col = fields.index("cs(User-Agent)")
                    continue

                if line.startswith("#"):
                    continue

                parts = line.split("\t")

                # fallback to index 10 if no header detected
                col_index = user_agent_col if user_agent_col is not None else 10
                if col_index >= len(parts):
                    continue

                # URL-decode user-agent
                user_agent = urllib.parse.unquote(parts[col_index])

                # extract date
                date_match = re.search(r":(\d{4}-\d{2}-\d{2})", parts[0]) or re.match(r"(\d{4}-\d{2}-\d{2})", parts[0])
                if not date_match:
                    continue
                date = date_match.group(1)

                for llm, pattern in llm_patterns.items():
                    if pattern.search(user_agent):
                        llm_counts[(date, llm)] += 1
                        break

# --- Step 4: Write CSV ---
print(f"💾 Writing results to {OUTPUT_CSV}...")
df = pd.DataFrame(
    [(date, llm, count) for (date, llm), count in llm_counts.items()],
    columns=["Date", "LLM", "Count"]
).sort_values(by=["Date", "LLM"])
df.to_csv(OUTPUT_CSV, index=False)

print("✅ Done.")

