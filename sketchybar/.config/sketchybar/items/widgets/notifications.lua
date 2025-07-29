local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- Lista delle app da monitorare
local apps = {
    { name = "Messages",          icon = app_icons["Messages"] },
    { name = "WhatsApp",          icon = app_icons["WhatsApp"] },
    { name = "Telegram",          icon = app_icons["Telegram"] },
    { name = "Microsoft Teams",   icon = app_icons["Microsoft Teams"] },
    { name = "Microsoft Outlook", icon = app_icons["Microsoft Outlook"] }
}

local notification_items = {}
local notification_item_names = {}

local function update_notification_for_app(app)
    local script = [[osascript -e '
    tell application "System Events"
      tell process "Dock"
        set unreadCount to 0
        try
          set unreadCount to value of attribute "AXStatusLabel" of UI element "]] .. app.name .. [[" of list 1
        end try
        return unreadCount
      end tell
    end tell
    ']]
    sbar.exec(script, function(result)
        local unread = tonumber(result) or 0
        if unread > 0 then
            notification_items[app.name]:set({
                icon = { color = colors.red },
                label = { string = tostring(unread) }
            })
        else
            notification_items[app.name]:set({
                icon = { color = colors.grey },
                label = { string = "" }
            })
        end
    end)
end

sbar.add("item", { position = "right", width = settings.group_paddings })

for i, app in ipairs(apps) do
    local item = sbar.add("item", "widgets.notifications." .. app.name, {
        position = "right",
        icon = {
            string = app.icon,
            color = colors.grey,
            font = "sketchybar-app-font:Regular:16.0",
        },
        label = {
            string = "",
            color = colors.white,
            font = { family = settings.font.numbers },
            padding_left = 2,
            padding_right = 2,
        },
        update_freq = 9,
        click_script = "open -a '" .. app.name .. "'"
    })
    notification_items[app.name] = item
    table.insert(notification_item_names, item.name)

    item:subscribe({ "routine", "system_woke" }, function()
        update_notification_for_app(app)
    end)
end

-- Bracket unica per tutte le notifiche
sbar.add("bracket", notification_item_names, {
    background = {
        color = colors.bg1
    }
})
