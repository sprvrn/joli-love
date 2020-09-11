function love.conf(t)
    t.window.width = 800
    t.window.height = 600
    t.window.minwidth = 200
    t.window.minheight = 200 

    t.window.title = "test"
    t.window.icon = nil

    t.identity = "test"
    t.version = "11.3"

    t.window.borderless = false
    t.window.resizable = false
    t.window.fullscreen = false
    t.window.vsync = false

    t.gammacorrect = false
end