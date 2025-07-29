local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

sbar.add("item", { position = "right", width = settings.group_paddings })

local betterdisplay = sbar.add("item", "betterdisplay", {
    icon = {
        string = "􀟛",
        font = { size = 12.0 },
        color = colors.white,
    },
    label = { drawing = false },
    position = "right",
    click_script = "open -a 'BetterDisplay'"
})

local maccy = sbar.add("item", "maccy", {
    icon = {
        string = "􀉄",
        font = { size = 12.0 },
        color = colors.white,
        padding_left = 2,
        padding_right = 2,
    },
    label = { drawing = false },
    position = "right",
    click_script = "open -a 'Maccy'"
})

-- Bracket attorno alle icone di BetterDisplay e Maccy
sbar.add("bracket", { betterdisplay.name, maccy.name }, {
    background = {
        color = colors.bg1
    }
})
