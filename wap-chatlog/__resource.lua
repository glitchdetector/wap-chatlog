name "Webadmin Chatlog Plugin"
author "glitchdetector"
contact "glitchdetector@gmail.com"
version "1.0"

description "A chatlog plugin for Webadmin"

dependency 'webadmin-lua'
webadmin_plugin 'yes'

webadmin_settings 'yes'
convar_category 'Chat History' {
    'Configure the Chat History interface',
    {
        {'Limit', 'chatlog_limit', 'CV_MULTI', {
            {"100", 100},
            {"200", 200},
            {"500", 500},
            {"Unlimited", -1},
        }},
        {'Per Page', 'chatlog_per_page', 'CV_SLIDER', 25, 10, 50},
        {'Unread Indicator', 'chatlog_show_unread_messages', 'CV_BOOL', true, 'Show the amount of unread messages'},
    }
}

server_script 'chatlog.lua'
