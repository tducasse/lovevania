local peachy = require("lib.peachy")
local Item = Class:extend()

function Item:draw()
  self.sprite:draw(self.x, self.y)
end

function Item:destroy()
  Signal.emit(SIGNALS.DESTROY_ITEM, self, self.collection)
end

function Item:update(dt)
  self.sprite:update(dt)
end

function Item:new(i, collection)
  self.type = "item"
  self.item = string.lower(i.type)
  self.collection = collection

  -- POSITION
  self.x = i.x
  self.y = i.y
  self.w = i.w
  self.h = i.h

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/" .. self.item .. ".json",
                    love.graphics.newImage("assets/" .. self.item .. ".png"),
                    "default")
  self.sprite:play()
end

return Item
