local settings = require("settings")
local colors = require("colors")

local cal = sbar.add("item", {
    icon = {
        color = colors.white,
        padding_left = 8,
        padding_right = 8,
        font = {
            style = settings.font.style_map["Black"],
            size = 12.0,
        },
    },
    label = {
        color = colors.white,
        padding_right = 8,
        width = 45,
        align = "right",
        font = { family = settings.font.numbers },
    },
    position = "right",
    update_freq = 30,
    padding_left = 15,
    padding_right = 2,
    click_script = "open -a 'Calendar'"
})

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
    cal:set({ icon = os.date("%a %d %b"), label = os.date("%H:%M") })
end)
