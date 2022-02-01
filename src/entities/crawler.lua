local peachy = require("lib.peachy")
local Crawler = Class:extend()

function Crawler:draw()
  local left = self.left or 0
  local top = self.top or 0
  local x = self.x - left
  local y = self.y - top

  local straight = self.sprite.tagName == "Straight"

  local scale_y = 1
  local scale_x = 1

  if straight then
    if self.center.y > self.y then
      scale_y = 1
    else
      scale_y = -1
    end
  else
    if self.center.x > self.x then
      scale_x = -1
    else
      scale_x = 1
    end
  end

  if scale_x == -1 then
    x = x + self.w + left * 2
  end
  if scale_y == -1 then
    y = y + self.h + top * 2
  end

  self.sprite:draw(x, y, 0, scale_x, scale_y)
end

function Crawler:update_target()
  if self:distance_to(self.target) <= 0.1 then
    local next_path_index = self.path_index + 1 * self.last_dir
    if next_path_index > #self.path or next_path_index < 1 then
      next_path_index = self.path_index - 1 * self.last_dir
      self.last_dir = -self.last_dir
    end
    self.path_index = next_path_index
    self.target = self.path[self.path_index]
  end
end

function Crawler:distance_to(target)
  if not target then
    return 1
  end
  return math.sqrt(
             math.pow(self.x - target.x, 2) + math.pow(self.y - target.y, 2))
end

function Crawler:update(dt, world)
  if not self.world and world then
    self.world = world
  end
  self.sprite:update(dt)
  self:update_target()
  self.x_velocity = ((self.target.x - self.x) / self:distance_to(self.target)) *
                        dt * self.speed
  self.y_velocity = ((self.target.y - self.y) / self:distance_to(self.target)) *
                        dt * self.speed
  local x = self.x + self.x_velocity
  local y = self.y + self.y_velocity

  self.x, self.y = self.world:move(self, x, y, self.filter)

  if math.abs(self.y_velocity) > math.abs(self.x_velocity) then
    self.sprite:setTag("Side")
  else
    self.sprite:setTag("Straight")
  end

end

function Crawler:filter()
  return "cross"
end

function Crawler:new(c, grid_size, collection)
  self.type = "crawler"
  self.collection = collection

  -- POSITION
  self.x = c.x
  self.y = c.y
  self.top = c.top
  self.left = c.left
  self.w = c.w
  self.h = c.h
  self.center = { x = c.center.cx * grid_size, y = c.center.cy * grid_size }

  -- MOVEMENT
  self.path = {}
  for _, v in ipairs(c.path) do
    self.path[#self.path + 1] = { x = v.cx * grid_size, y = v.cy * grid_size }
  end
  self.target = self.path[1]
  self.path_index = 1
  self.last_dir = 1
  self.speed = 10
  self.x_velocity = 0
  self.y_velocity = 0

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/crawler.json",
                    love.graphics.newImage("assets/crawler.png"), "Straight")
  self.sprite:play()
end

function Crawler:hit()
  love.audio.play("assets/destroy.ogg", "static", false, "0.7")
  self:destroy()
end

function Crawler:destroy()
  Signal.emit(SIGNALS.DESTROY_ITEM, self, self.collection)
end

return Crawler
