#!/bin/bash
set -e

# This script finds the group master for the "Customer Service" Sonos zone,
# skips to the next track, and removes the previous track from the queue.

# Get the output from the sonos zones command, ignoring the deprecation warning
ZONES_OUTPUT=$(/usr/local/bin/node /usr/local/bin/sonos zones 2>/dev/null)

# If ZONES_OUTPUT is empty, we can't proceed.
if [ -z "$ZONES_OUTPUT" ]; then
    echo "Error: Could not get zone information from sonos command." >&2
    exit 1
fi

TARGET_ZONE="Customer Service"

# Get the group name for the target zone.
GROUP_NAME=$(echo "$ZONES_OUTPUT" | grep "$TARGET_ZONE" | sed 's/.*RINCON_[^ ]* //' | xargs)

if [ -z "$GROUP_NAME" ]; then
    echo "Error: Could not find group for zone '$TARGET_ZONE'." >&2
    exit 1
fi

# Find the master speaker for that group.
MASTER_NAME=$(echo "$ZONES_OUTPUT" | grep -F "$GROUP_NAME" | head -n 1 | sed 's/  *RINCON_.*//' | xargs)

if [ -z "$MASTER_NAME" ]; then
    echo "Error: Could not find master for group '$GROUP_NAME'." >&2
    exit 1
fi

echo "Found group master: \"$MASTER_NAME\" for zone \"$TARGET_ZONE\" (group: \"$GROUP_NAME\")"

# Get the current track information.
# The output is JSON, so we use 'jq' to parse it.
POSITION_INFO_JSON=$(/usr/local/bin/node /usr/local/bin/sonos execute "$MASTER_NAME" "AVTransportService.GetPositionInfo" '{"InstanceID": 0, "Channel": "Master"}' 2>/dev/null | tail -n +2)

# Extract the current track number from the JSON output.
CURRENT_TRACK_NUMBER=$(echo "$POSITION_INFO_JSON" | jq -r '.Track')


if [ -z "$CURRENT_TRACK_NUMBER" ] || [ "$CURRENT_TRACK_NUMBER" = "0" ]; then
    echo "Could not determine current track number or track is not from queue. Skipping track removal."
    # Just go to the next track without trying to remove the current one.
    /usr/local/bin/node /usr/local/bin/sonos control "$MASTER_NAME" next
    exit 0
fi

echo "Current track number is $CURRENT_TRACK_NUMBER."

# Go to the next track
echo "Skipping to the next track..."
/usr/local/bin/node /usr/local/bin/sonos control "$MASTER_NAME" next

# Remove the (now previous) track from the queue
echo "Removing track $CURRENT_TRACK_NUMBER from the queue..."
/usr/local/bin/node /usr/local/bin/sonos execute "$MASTER_NAME" AVTransportService.RemoveTrackFromQueue "{\"InstanceID\": 0, \"ObjectID\": \"Q:0/$CURRENT_TRACK_NUMBER\"}"

echo "Done."
