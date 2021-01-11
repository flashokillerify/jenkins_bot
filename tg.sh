#!/bin/bash

bot_token=1336436573:AAFpaGsPLEc90A9LBObk6kSXDvjrySmQH14        #Get token from Telegra        >
send_message_to=571213272               #Give telegram id/group id where message will b

myip=$(curl -s http://ipecho.net/plain; echo)
curl -X "POST" "https://api.telegram.org/bot$bot_token/sendMessage" \
     -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" \
     --data-urlencode "text=\`ssh k@$myip\`" \
     --data-urlencode "chat_id=$send_message_to" \
     --data-urlencode "disable_web_page_preview=true" \
     --data-urlencode "parse_mode=markdown"
