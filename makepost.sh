#!/bin/sh

read -r FIRSTLINE < ${1}
if [ "$FIRSTLINE" == "---" ]; then
  tail -n +7 ${1} > /tmp/body
else
  cat ${1} > /tmp/body
fi
# prepend new YAML front matter
HEADER="---\ntitle: "${2}"\ndate: "$(date +'%Y-%m-%d %X')"\nlayout: post\ncomments: true\n---"
(echo $HEADER|cat - /tmp/body > /tmp/out && mv /tmp/out ${1})
 
# rename file with proper title
TITLE=$(echo ${2} | awk '{gsub(/\ /, "-");print tolower}')
NEWNAME="_posts/"$(date +'%Y-%m-%d')"-"$TITLE".markdown"
mv ${1} $NEWNAME

# execute and push
jekyll
git add _site/*
git commit -am 'New post: ${2}'
git push origin master
exec ./tweet.sh 'I wrote some words: "'${2}'" http://words.davidhu.me/'$TITLE
