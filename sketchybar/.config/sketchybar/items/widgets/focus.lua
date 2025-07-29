local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Mappa dei colori di sistema Apple a valori esadecimali
local apple_system_colors = {
    systemRedColor = colors.red,
    systemGreenColor = colors.green,
    systemBlueColor = colors.blue,
    systemOrangeColor = colors.orange,
    systemYellowColor = colors.yellow,
    systemPinkColor = colors.magenta,
    systemPurpleColor = 0xffa277ff,
    systemTealColor = 0xff64c7c7,
    systemIndigoColor = 0xff5e5ce6,
    systemMintColor = 0xff70e1c8,
    systemBrownColor = 0xffac8e68,
    systemGrayColor = colors.grey,
    systemGray2Color = 0xffaeaeb2,
    systemGray3Color = 0xffc7c7cc,
    systemGray4Color = 0xffd1d1d6,
    systemGray5Color = 0xffe5e5ea,
    systemGray6Color = 0xfff2f2f7,
}

local function json_decode(str)
    local f, err = load("return " .. str:gsub('"%s*:%s*', '" = '))
    if not f then return nil, err end
    local ok, res = pcall(f)
    if not ok then return nil, res end
    return res
end


local focus = sbar.add("item", "widgets.focus", {
    position = "right",
    icon = {
        font = {
            style = settings.font.style_map["Regular"],
            size = 16.0,
        },
        color = colors.yellow,
    },
    label = { drawing = false },
    update_freq = 20, -- aggiorna ogni 20 secondi
    popup = { align = "center" }
})

local function get_focus_mode(callback)
    local script = [[
    osascript -l JavaScript -e '
      const app = Application.currentApplication()
      app.includeStandardAdditions = true
      function getJSON(path) {
        const fullPath = path.replace(/^~/, app.pathTo("home folder"))
        const contents = app.read(fullPath)
        return JSON.parse(contents)
      }
      function run() {
        let result = { name: "", tintColorName: "", symbolImageName: "" }
        try {
          const assertions = getJSON("~/Library/DoNotDisturb/DB/Assertions.json")
          const configs = getJSON("~/Library/DoNotDisturb/DB/ModeConfigurations.json")
          if (!assertions || !configs) return JSON.stringify(result)
          const records = assertions.data?.[0]?.storeAssertionRecords
          if (!records || records.length === 0) return JSON.stringify(result)
          const modeid = records[0]?.assertionDetails?.assertionDetailsModeIdentifier
          if (!modeid) return JSON.stringify(result)
          const config = configs.data?.[0]?.modeConfigurations
          if (!config || !config[modeid]) return JSON.stringify(result)
          const mode = config[modeid]?.mode
          result.name = mode?.name || ""
          result.tintColorName = mode?.tintColorName || ""
          result.symbolImageName = mode?.symbolImageName || ""
        } catch (e) {}
        return JSON.stringify(result)
      }
      run()
    '
    ]]
    sbar.exec(script, function(result)
        if result then
            callback(result)
        else
            callback({ name = "", tintColorName = "", symbolImageName = "" })
        end
    end)
end


focus:subscribe({ "routine", "system_woke" }, function()
    get_focus_mode(function(mode)
        if mode.name == "" then
            focus:set({ icon = "" })
        else
            -- Usa il nome SF Symbol se disponibile, altrimenti fallback
            local icon = mode.symbolImageName ~= "" and icons.focus[mode.symbolImageName] or "􀆺"
            -- Mappa il colore Apple a esadecimale, fallback su yellow
            local color = apple_system_colors[mode.tintColorName] or colors.yellow
            focus:set({
                icon = { string = icon, color = color }
            })
        end
    end)
end)
