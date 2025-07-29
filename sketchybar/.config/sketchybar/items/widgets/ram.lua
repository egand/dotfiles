local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Avvia il provider di eventi per la RAM
sbar.exec("killall ram_load >/dev/null; $CONFIG_DIR/helpers/event_providers/ram_load/bin/ram_load ram_update 2.0")

local ram = sbar.add("item", "widgets.ram", {
    position = "right",
    background = {
        height = 22,
        color = { alpha = 0 },
        border_color = { alpha = 0 },
        drawing = true,
    },
    icon = { string = icons.ram },
    label = {
        string = "??%",
        font = {
            family = settings.font.numbers,
            style = settings.font.style_map["Bold"],
            size = 12.0,
        },
        align = "right",
        padding_right = 0,
        padding_left = 6,
        color = colors.green, -- colore iniziale
    },
    padding_right = settings.paddings + 6
})

ram:subscribe("ram_update", function(env)
    local used = tonumber(env.used_percent)
    local color = colors.green
    if used > 70 then
        if used < 85 then
            color = colors.yellow
        elseif used < 95 then
            color = colors.orange
        else
            color = colors.red
        end
    end

    ram:set({
        label = {
            string = env.used_percent .. "%",
            color = color,
        }
    })
end)

ram:subscribe("mouse.clicked", function(env)
    sbar.exec("open -a 'Activity Monitor'")
end)
