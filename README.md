# FiveM Webadmin Chatlog Plugin
### A simple chatlog implementation for the Webadmin plugin system

## Features

Adds a chat history page to Webadmin

Adds the following convars:

 - `chatlog_limit`, controls how many messages are stored
 - `chatlog_per_page`, controls how many messages are shown on each page
 - `chatlog_show_unread_messages`, set to `true` or `false` to enable / disable the unread message badge

## Note

Message history is not stored between server restarts

You need to have the `webadmin.chatlog.view` ACE permission (which means `webadmin` works!) to see the page.

This resource provides an example for the plugin system.

## Dependency
Requires the Lua Webadmin Plugin Factory resource
[https://github.com/glitchdetector/webadmin-lua/](https://github.com/glitchdetector/webadmin-lua/)
