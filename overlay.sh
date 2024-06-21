#!/bin/bash

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 v1.mp4 v2.mp4"
    exit 1
fi

# Assign arguments to variables
v1_file="$1"
v2_file="$2"

# Get the durations
duration_v1=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$v1_file")
duration_v2=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$v2_file")

# Loop or trim v1 to match v2 duration
if (( $(echo "$duration_v1 < $duration_v2" | bc -l) )); then
  loop_count=$(echo "($duration_v2 / $duration_v1)+1" | bc)
  ffmpeg -stream_loop $loop_count -i "$v1_file" -t $duration_v2 -c copy v1_temp.mp4
else
  ffmpeg -i "$v1_file" -t $duration_v2 -c copy v1_temp.mp4
fi

# Trim 15% of the height from the bottom of v2 and overlay it on v1_temp
ffmpeg -y -i v1_temp.mp4 -i "$v2_file" -filter_complex "
[0:v]scale=550:720[v1];
[1:v]scale=300:300,crop=in_w:in_h*0.69:0:0[v2];
[v1][v2]overlay=x=(main_w-overlay_w-15)/2:y=45
" -map 0:v -map 1:a -c:v libx264 -c:a aac -shortest output.mp4

# Clean up temporary file
rm v1_temp.mp4