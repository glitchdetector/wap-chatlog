-- Chat History Webadmin plugin
-- by glitchdetector, Nov. 2019
-- Made as an example for the Webadmin plugin system
-- Heavily commented for the sake of introduction

-- Maximum amount of stored chat messages (-1 for unlimited!)
local CHATLOG_LIMIT = GetConvarInt("chatlog_limit", 200)
-- Maximum amount of entries on one page
local CHATLOG_PER_PAGE = GetConvarInt("chatlog_per_page", 25)
-- Show the unread messages notification
local CHATLOG_SHOW_UNREAD_MESSAGES = GetConvar("chatlog_show_unread_messages", "true") == "true"

-- Information used to produce the plugin page
local PAGE_NAME = "chatlog"
local PAGE_TITLE = "Chat History"
local PAGE_ICON = "comments"

-- Table to contain all stored chat messages
local CHATLOG_HISTORY = {}
-- Tally to count amount of sent messages
local CHATLOG_TALLY = 0
local CHATLOG_LAST_TALLY = 0

-- Fetch incoming chat messages
AddEventHandler("chatMessage", function(source, author, message)
    -- Add to tally
    CHATLOG_TALLY = CHATLOG_TALLY + 1
    -- Store the message details
    table.insert(CHATLOG_HISTORY, 1, {source, author, message, os.time()})
    -- Update convar value before we use it
    CHATLOG_LIMIT = GetConvarInt("chatlog_limit", 200)
    -- Delete excess messages (if we have more than the limit)
    while ((CHATLOG_LIMIT > 0) and (#CHATLOG_HISTORY > CHATLOG_LIMIT)) do
        table.remove(CHATLOG_HISTORY, #CHATLOG_HISTORY)
    end
end)

function CreatePage(FAQ, data, add)
    -- Update convar value before we use it
    CHATLOG_PER_PAGE = GetConvarInt("chatlog_per_page", 25)
    -- Calculate the amount of pages
    local paginatorPages = math.ceil(#CHATLOG_HISTORY / CHATLOG_PER_PAGE)
    -- Since we want to use pagination, make sure there's a page value
    if not data.page then data.page = 1 end
    local page = math.max(0, math.min(paginatorPages, tonumber(data.page)))
    -- Generate the paginator
    local paginator = FAQ.GeneratePaginator(PAGE_NAME, page, paginatorPages)
    -- Calculate the shown message range
    local firstMessage = CHATLOG_PER_PAGE * (page - 1) + 1
    local lastMessage = firstMessage + CHATLOG_PER_PAGE - 1
    -- Generate the shown message history list
    local chatlogData = {}
    for n = firstMessage, lastMessage do
        if n <= #CHATLOG_HISTORY and n > 0 then
            -- Table Factory takes raw row data directly by default, so we pre-format the data here
            table.insert(chatlogData, {os.date("%X", CHATLOG_HISTORY[n][4]), CHATLOG_HISTORY[n][2], CHATLOG_HISTORY[n][3]})
        end
    end
    -- Update that the chatlog has been viewed
    CHATLOG_LAST_TALLY = CHATLOG_TALLY
    if paginatorPages > 0 then
        -- Show the message history table (if there are any)
        add(FAQ.Table({
            FAQ.Node("div", {class = "text-center"}, FAQ.Icon("clock")),
            "Name",
            "Message"
        }, chatlogData, false, "table-sm"))
    else
        -- Show an alert (if there are no messages to display)
        add(FAQ.Alert("info", "No chat messages have been sent yet!"))
    end
    -- Add the paginator to the bottom
    add(paginator)
    return true, "OK"
end

-- Automatically sets up a page and sidebar option based on the above configuration
Citizen.CreateThread(function()
    local FAQ = exports['webadmin-lua']:getFactory()
    exports['webadmin']:registerPluginOutlet("nav/sideList", function(data)
        if not exports['webadmin']:isInRole("webadmin."..PAGE_NAME..".view") then return "" end
        -- modified to update convar
        CHATLOG_SHOW_UNREAD_MESSAGES = GetConvar("chatlog_show_unread_messages", "true") == "true"
        -- modified to show tally of unread messages
        return FAQ.SidebarOption(PAGE_NAME, PAGE_ICON, PAGE_TITLE, (CHATLOG_SHOW_UNREAD_MESSAGES and CHATLOG_TALLY > CHATLOG_LAST_TALLY) and (CHATLOG_TALLY - CHATLOG_LAST_TALLY) or false)
    end)
    exports['webadmin']:registerPluginPage(PAGE_NAME, function(data)
        if not exports['webadmin']:isInRole("webadmin."..PAGE_NAME..".view") then return "" end
        return FAQ.Nodes({
            -- modified to show tally of total messages in title
            FAQ.PageTitle({PAGE_TITLE, " ", FAQ.Badge("info", CHATLOG_TALLY)}),
            FAQ.BuildPage(CreatePage, data),
        })
    end)
end)
