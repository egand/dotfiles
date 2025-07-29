local colors = require("colors")
local icons = require("icons")
local settings = require("settings")


local apple = sbar.add("item", {
    icon = {
        font = { size = 18.0 },
        string = icons.apple,
    },
    label = { drawing = false },
    padding_left = 6,
    padding_right = 12,
    click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0"
})
