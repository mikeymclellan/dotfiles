#!/bin/bash

REPOS=("ideahq/subscription" "ideahq/petdirect")

# Compute ISO8601 dates for the last 14 days (works on macOS and Linux)
if date -v-14d >/dev/null 2>&1; then
  SINCE=$(date -u -v-14d "+%Y-%m-%dT%H:%M:%SZ")
  UNTIL=$(date -u "+%Y-%m-%dT%H:%M:%SZ")
else
  SINCE=$(date -u -d "14 days ago" "+%Y-%m-%dT%H:%M:%SZ")
  UNTIL=$(date -u "+%Y-%m-%dT%H:%M:%SZ")
fi

if date -v-14d >/dev/null 2>&1; then
  SINCE_DATE=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$SINCE" "+%Y-%m-%d")
else
  SINCE_DATE=$(date -d "$SINCE" '+%Y-%m-%d')
fi

echo "# Bi-Weekly Git Activity Summary ($SINCE_DATE to $(date '+%Y-%m-%d'))"
echo

# Array to store summary data for later processing
declare -a SUMMARY_DATA

# First pass: collect data and output detailed activity for each repo
for R in "${REPOS[@]}"; do
  echo "## Repository: $R"
  echo
  
  # Collect raw data
  prs_data=$(gh pr list -R "$R" --state all --search "updated:>=$SINCE" \
    --json number,title,author,state,mergedAt,createdAt,updatedAt,url --limit 200)
  
  # Get commits with stats to filter by lines added
  all_commits=$(gh api --paginate -H "Accept: application/vnd.github+json" \
    "/repos/$R/commits?since=$SINCE&until=$UNTIL&per_page=100")
  
  # Filter out merge commits only
  commits_data=$(echo "$all_commits" | jq '[.[] | select((.commit.message // "") | ascii_downcase | contains("merge") | not)]')
  
  # Store data for summary generation later
  SUMMARY_DATA+=("$R|$prs_data|$commits_data")
  
  echo "### Detailed Activity"
  echo
  echo "**Pull Requests updated in last 14 days:**"
  echo "$prs_data" | jq -r '.[] | "- PR #" + (.number|tostring) + " [" + .state + "] " + .title
             + " by @" + (.author.login // "unknown")
             + " — created " + (.createdAt // "n/a")
             + (if .mergedAt then " — merged " + .mergedAt else "" end)
             + " — " + .url'
  
  echo
  echo "**Commits in last 14 days (no merge commits):**"
  echo "$commits_data" | jq -r '.[] | "- " + .sha[0:7] + " " + (.commit.author.date // "n/a")
                 + " — " + (.commit.author.name // "n/a")
                 + ": " + ((.commit.message // "") | split("\n")[0])'
  
  echo
  echo "---"
  echo
done

# Second pass: generate AI summaries for all repositories
echo "# AI-Generated Activity Summaries"
echo

for data in "${SUMMARY_DATA[@]}"; do
  IFS='|' read -r repo prs_data commits_data <<< "$data"
  
  echo "## Summary for $repo"
  echo
  
  # Truncate data if it's too large (keep first 50 PRs and 100 commits)
  truncated_prs=$(echo "$prs_data" | jq '.[0:50]' 2>/dev/null || echo "$prs_data")
  truncated_commits=$(echo "$commits_data" | jq '.[0:100]' 2>/dev/null || echo "$commits_data")
  
  # Get counts for transparency
  pr_count=$(echo "$prs_data" | jq '. | length' 2>/dev/null || echo "unknown")
  commit_count=$(echo "$commits_data" | jq '. | length' 2>/dev/null || echo "unknown")
  
  # Create a summary prompt with truncated data
  summary_prompt="Analyze this git activity data for repository $repo (time period: $SINCE to $UNTIL) and provide a concise summary organized by user. For each user, summarize their contributions including PRs created/merged and commits made. Focus on what was accomplished rather than listing individual items. Keep it brief but informative.

PRs:
$prs_data

Commits:
$commits_data"
  
  # Check if the prompt is still too long (rough character limit check)
  if [ ${#summary_prompt} -gt 100000 ]; then
    echo "Dataset too large for AI analysis. Showing basic statistics instead:"
    echo
    echo "**Statistics for $repo:**"
    echo "- Total PRs: $pr_count"
    echo "- Total Commits: $commit_count"
    echo
    echo "**Recent Contributors:**"
    # Extract unique authors from truncated data
    echo "$truncated_prs" | jq -r '.[].author.login // "unknown"' 2>/dev/null | sort | uniq -c | sort -nr | head -10 | sed 's/^/- /'
    echo "$truncated_commits" | jq -r '.[] | .commit.author.name // "unknown"' 2>/dev/null | sort | uniq -c | sort -nr | head -10 | sed 's/^/- /'
  else
    # Use claude with --print flag for non-interactive output
    claude --print "$summary_prompt"
  fi
  
  echo
  echo "---"
  echo
done

# Third pass: generate personalized "high5" messages for team members
echo "# High5 Messages for Team Members"
echo

# Generate high5 messages for each contributor across all repos
declare -A ALL_AUTHORS
for data in "${SUMMARY_DATA[@]}"; do
  IFS='|' read -r repo prs_data commits_data <<< "$data"
  
  # Get unique contributors for this repo
  pr_authors=$(echo "$prs_data" | jq -r '.[] | .author.login // empty' 2>/dev/null | sort | uniq)
  commit_authors=$(echo "$commits_data" | jq -r '.[] | .commit.author.name // empty' 2>/dev/null | sort | uniq)
  
  # Combine and deduplicate all authors
  all_authors=$(echo -e "$pr_authors\n$commit_authors" | grep -v '^$' | sort | uniq)
  
  for author in $all_authors; do
    if [[ -n "$author" ]]; then
      ALL_AUTHORS["$author"]=1
    fi
  done
done

# Generate a high5 message for each unique author across all repos
for author in "${!ALL_AUTHORS[@]}"; do
  echo "## High5 for $author"
  echo
  
  # Collect all contributions for this author across all repos
  author_summary=""
  for data in "${SUMMARY_DATA[@]}"; do
    IFS='|' read -r repo prs_data commits_data <<< "$data"
    
    # Get their contributions for this repo
    author_prs=$(echo "$prs_data" | jq --arg author "$author" '[.[] | select(.author.login == $author)]' 2>/dev/null)
    author_commits=$(echo "$commits_data" | jq --arg author "$author" '[.[] | select(.commit.author.name == $author)]' 2>/dev/null)
    
    pr_count=$(echo "$author_prs" | jq '. | length' 2>/dev/null || echo "0")
    commit_count=$(echo "$author_commits" | jq '. | length' 2>/dev/null || echo "0")
    
    if [[ "$pr_count" -gt 0 || "$commit_count" -gt 0 ]]; then
      author_summary="$author_summary

Repository: $repo
PRs: $author_prs
Commits: $author_commits"
    fi
  done
  
  if [[ -n "$author_summary" ]]; then
    # Create a personalized high5 prompt
    high5_prompt="Generate a personalized, encouraging 'high5' message for team member $author based on their recent contributions across repositories (time period: $SINCE to $UNTIL). The message should:

1. Be positive, specific, and motivational
2. Highlight their key accomplishments
3. Be 2-3 sentences maximum
4. Feel genuine and personal
5. Use a friendly, collegial tone
6. Mention specific work if notable

Their contributions across all repositories:
$author_summary

Generate a high5 message that acknowledges their specific work and impact."

    # Use claude to generate the personalized message
    claude --print "$high5_prompt"
  else
    echo "Thanks for being part of the team, $author! 🙌"
  fi
  
  echo
  echo "---"
  echo
done

