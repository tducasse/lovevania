local ScreenManager = require("lib.screen_manager")
local Screen = require("lib.screen")

local MenuScreen = {}

function MenuScreen.new()
  local self = Screen.new()

  local push = require("lib.push")

  local menu = {}

  function self:init()
    menu = love.graphics.newImage("assets/menu.png")
  end

  function self:update()
    Input:update()
    if Input:pressed("jump") then
      love.audio.stop(Music)
      ScreenManager.switch("game")
    end
  end

  function self:draw()
    push:start()
    love.graphics.draw(menu)
    push:finish()
  end

  return self
end
return MenuScreen
