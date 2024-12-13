#!/bin/bash

token="a5c43e936699f98c"
url="https://hackattic.com/challenges/brute_force_zip/problem?access_token=$token"
post_url="https://hackattic.com/challenges/brute_force_zip/solve?access_token=$token"

json_response=$(curl -s "$url")

if [ $? -ne 0 ]; then
    echo "Failed to fetch JSON file"
    exit 1
fi

zip_url=$(echo "$json_response" | jq -r ".zip_url")

if [ -z "$zip_url" ]; then
    echo "zip_url not found in the JSON response."
    exit 1
fi

curl -o "./file.zip" "$zip_url"

echo "Downloaded file.zip"

password=$(fcrackzip -v -u -l 4-6 -c a1 file.zip | tail -n 1 | sed 's/.*== //')

echo "Password:$password"

mkdir -p content

rm content/*

unzip -P $password -d "./content/" file.zip

content=$(<"./content/secret.txt")

json_payload=$(jq -n --arg content "$content" '{secret: $content}')

response=$(curl -s -X POST -H "Content-Type: application/json" -d "$json_payload" "$post_url")

echo $response