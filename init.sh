#!/bin/bash

echo "Enter subreddit: " #Enter the wanted subreddit
read subreddit
# create directory to store images
mkdir -p "$subreddit"

# download JSON data of subreddit
curl "https://www.reddit.com/r/$subreddit.json" > subreddit.json

# parse JSON data to get URLs of images in posts
jq -r '.data.children[].data.url' subreddit.json | while read -r url; do
    # check if URL is an image file
    if [[ $url =~ \.jpg$ ]]; then
        ext=jpg
    elif [[ $url =~ \.png$ ]]; then
        ext=png
    elif [[ $url =~ \.gif$ ]]; then
        ext=gif
    fi
    if [ -n "$ext" ]; then
        #create directory if it doesn't exist
        mkdir -p "$subreddit/$ext"
        # download image
        wget "$url"
        # move image to directory
        mv $(basename $url) "$subreddit/$ext"
    fi
done

# Create a Telegram bot
echo "Enter bot token: "
read Bot > bot_token.txt

bot_token=$(ls -1 "~/red-pam/bot_token.txt")

# Channel ID
echo "Enter Telegram ID: "
read channel_id
echo "Enter path: "
read path
# Directory to post
directory_path="$subreddit/$path"

# Get all files in the directory
files=$(ls -1 $directory_path)

# Send each file as a message
for file in $files; do
	curl -F document=@"$directory_path/$file" -X POST https://api.telegram.org/bot$bot_token/sendDocument?chat_id=$channel_id
done


