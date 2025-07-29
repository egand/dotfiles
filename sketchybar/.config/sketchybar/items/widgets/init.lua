local colors = require("colors")

require("items.widgets.battery")
require("items.widgets.volume")
require("items.widgets.wifi")
require("items.widgets.ram")
require("items.widgets.cpu")
sbar.add("bracket", "widgets.cpu_ram.bracket", { "widgets.cpu", "widgets.ram" }, {
    background = { color = colors.bg1 }
})

require("items.widgets.focus")
require("items.widgets.notifications")
