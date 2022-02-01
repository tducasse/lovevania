local peachy = require("lib.peachy")
local Bullet = Class:extend()

function Bullet:draw()
  self.sprite:draw(self.x, self.y)
end

function Bullet:update(dt, world)
  self.sprite:update(dt)
  if not self.world and world then
    self.world = world
  end

  local x, y = 0, 0
  x = self.dx and (self.x + self.dx * self.speed * dt + 0.00001) or self.x
  y = self.dy and (self.y + self.dy * self.speed * dt + 0.00001) or self.y

  local cols = {}
  self.x, self.y, cols = self.world:move(self, x, y, self.filter)

  for _, col in pairs(cols) do
    if col.type == "touch" then
      self:destroy()
      if col.other.hit then
        col.other:hit()
      end
    end
  end

  if self.x < 0 or self.x > self.map_width or self.y < 0 or self.y >
      self.map_height then
    self:destroy()
  end

end

function Bullet:destroy()
  Signal.emit(SIGNALS.DESTROY_ITEM, self, self.collection)
end

function Bullet:filter(other)
  if other.type then
    if other.type == "player" then
      return nil
    else
      return "touch"
    end
  else
    return "touch"
  end
end

function Bullet:new(x, y, dx, dy, world, map_width, map_height, collection)
  self.type = "bullet"
  self.collection = collection

  -- POSITION
  self.x = x
  self.y = y
  self.dx = dx
  self.dy = dy
  self.speed = 200

  -- BOUNDARIES
  self.map_width = map_width
  self.map_height = map_height

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/bullet.json",
                    love.graphics.newImage("assets/bullet.png"), "default")
  self.sprite:play()

  world:add(
      self, self.x, self.y, self.sprite:getWidth(), self.sprite:getHeight())
end

return Bullet
