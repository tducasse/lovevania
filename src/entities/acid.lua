local peachy = require("lib.peachy")
local Acid = Class:extend()

function Acid:draw()
  self.sprite:draw(self.x, self.y)
end

function Acid:update(dt)
  self.sprite:update(dt)
end

function Acid:new(a, collection)
  self.type = "acid"
  self.collection = collection

  -- POSITION
  self.x = a.x
  self.y = a.y
  self.w = a.w
  self.h = a.h

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/acid.json",
                    love.graphics.newImage("assets/acid.png"), "default")
  self.sprite:play()
end

return Acid
