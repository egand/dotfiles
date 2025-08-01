local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local function parse_string_to_table(s)
    local result = {}
    for line in s:gmatch("([^\n]+)") do
        table.insert(result, line)
    end
    return result
end

-- Ottieni la lista dei workspace da Aerospace
local file = io.popen("aerospace list-workspaces --all")
local result = file:read("*a")
file:close()

local workspaces = parse_string_to_table(result)
local spaces = {}

for i, workspace in ipairs(workspaces) do
    local space = sbar.add("item", "space." .. i, {
        icon = {
            string = tostring(workspace),
            color = colors.white,
            highlight_color = colors.red,
            font = { family = settings.font.numbers },
            padding_left = 10,
            padding_right = 15,
        },
        label = { drawing = false },
        padding_left = 1,
        padding_right = 1,
        background = {
            color = colors.bg1,
            border_width = 1,
            height = 26,
            border_color = colors.black,
        },
    })

    spaces[i] = space

    space:subscribe("aerospace_workspace_change", function(env)
        local selected = env.FOCUSED_WORKSPACE == workspace
        space:set({
            icon = { highlight = selected, },
            label = { highlight = selected },
            background = { border_color = selected and colors.white or colors.bg2 }
        })
    end)
end

local spaces_indicator = sbar.add("item", {
    padding_left = -3,
    padding_right = 0,
    icon = {
        padding_left = 8,
        padding_right = 9,
        color = colors.grey,
        string = icons.switch.on,
    },
    label = {
        width = 0,
        padding_left = 0,
        padding_right = 8,
        string = "Spaces",
        color = colors.bg1,
    },
    background = {
        color = colors.with_alpha(colors.grey, 0.0),
        border_color = colors.with_alpha(colors.bg1, 0.0),
    }
})

spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
    local currently_on = spaces_indicator:query().icon.value == icons.switch.on
    spaces_indicator:set({
        icon = currently_on and icons.switch.off or icons.switch.on
    })
    -- Qui puoi aggiungere la logica per mostrare/nascondere i workspace o altre opzioni
end)

spaces_indicator:subscribe("mouse.entered", function(env)
    sbar.animate("tanh", 30, function()
        spaces_indicator:set({
            background = {
                color = { alpha = 1.0 },
                border_color = { alpha = 1.0 },
            },
            icon = { color = colors.bg1 },
            label = { width = "dynamic" }
        })
    end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
    sbar.animate("tanh", 30, function()
        spaces_indicator:set({
            background = {
                color = { alpha = 0.0 },
                border_color = { alpha = 0.0 },
            },
            icon = { color = colors.grey },
            label = { width = 0, }
        })
    end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
    sbar.trigger("swap_menus_and_spaces")
end)
