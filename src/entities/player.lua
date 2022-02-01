local peachy = require("lib.peachy")
local Player = Class:extend()

function Player:draw()
  local left = self.left or 0
  local top = self.top or 0
  local x = self.x - left
  local y = self.y - top
  if self.last_dir == -1 then
    x = x + self.w + left * 2
  end
  self.sprite:draw(x, y, 0, self.last_dir)
end

function Player:moveOutOfBounds()
  local dir = nil
  local x, y = self.x, self.y
  if self.x > self.east - self.w / 3 then
    dir = "e"
    x = self.west + self.w / 3
  elseif self.x < self.west - self.w / 3 then
    dir = "w"
    x = self.east - self.w - self.w / 3
  elseif self.y > self.south - self.h / 3 then
    dir = "s"
    y = self.north + self.h / 3
    self.jumping = false
    self.rolling = false
  elseif self.y < self.north - self.h / 3 then
    dir = "n"
    y = self.south - self.h - self.h / 3
    self.jumping = false
    self.rolling = false
  end
  if dir then
    self:stop_rolling()
    Signal.emit(SIGNALS.NEXT_LEVEL, dir)
    self.world:remove(self)
    self.x = x
    self.y = y
  end
end

function Player:start_morphing()
  if self.rolling or self.morphing then
    return
  end
  self.morphing = true
  self.next_tag = "Morph"
end

function Player:start_morphing_out()
  if not self.rolling or self.standing then
    return
  end
  self.standing = true
  self.next_tag = "Stand"
end

function Player:start_rolling()
  self.rolling = true
  self.morphing = false
  self.next_tag = "Ball"
  self.x = self.x - self.rolling_x
  self.world:update(
      self, self.x + self.rolling_x, self.y + self.rolling_y, self.rolling_w,
      self.rolling_h)
end

function Player:stop_rolling()
  if not self.rolling then
    return
  end
  self.standing = false
  self.rolling = false
  self.x = self.x + self.rolling_x
  self.world:update(self, self.x, self.y, self.w, self.h)
  self.next_tag = "Idle"
end

function Player:update(dt, world)
  self.sprite:update(dt)

  if self.dead then
    return false
  end

  if self.hp < 0 then
    self:die()
  end

  if self.next_tag == "Death" then
    self.dead = true
    self.sprite:setTag(self.next_tag)
    return false
  end

  if not self.world and world then
    self.world = world
  end

  local x, y = self.x, self.y
  local x_axis = Input:get("move")

  local still_shooting = self.shooting and
                             (love.timer.getTime() - self.shooting < 0.4)
  if not still_shooting and self.shooting then
    self.shooting = false
  end

  if math.abs(self.x_velocity) > 10 then
    if not self.bouncing then
      self.x_velocity = self.x_velocity - self.last_dir * self.friction
    else
      self.x_velocity = self.x_velocity / 2
    end
  else
    if self.bouncing then
      self.bouncing = false
      self.jumping = false
    end
    self.x_velocity = 0
  end

  if self.ground then
    if Input:pressed("down") and self.ball then
      self:start_morphing()
    end
  end
  if Input:pressed("up") and self.rolling and not self.ceiling then
    self:start_morphing_out()
  end

  if not self.bouncing then
    if x_axis > 0 then
      self.x_velocity = self.speed
      if self.ground then
        if self.rolling and not self.standing then
          self.next_tag = "Roll"
        elseif self.morphing then
          self.next_tag = "Morph"
        elseif self.standing then
          self.next_tag = "Stand"
        else
          self.next_tag = "Run"
        end
      end
      self.last_dir = 1
    elseif x_axis < 0 then
      self.x_velocity = -self.speed
      if self.ground then
        if self.rolling and not self.standing then
          self.next_tag = "Roll"
        elseif self.morphing then
          self.next_tag = "Morph"
        elseif self.standing then
          self.next_tag = "Stand"
        else
          self.next_tag = "Run"
        end
      end
      self.last_dir = -1
    else
      if self.ground then
        if self.rolling and not self.standing then
          self.next_tag = "Ball"
        elseif self.morphing then
          self.next_tag = "Morph"
        elseif self.standing then
          self.next_tag = "Stand"
        else
          self.next_tag = "Idle"
        end
      end
    end

    if Input:down("jump") and not self.rolling then
      if self.ground and not self.jumping then
        self.morphing = false
        love.audio.play("assets/jump.ogg", "static", nil, 0.7)
        self.jumping = true
        self.y_velocity = self.jump_height
      end
    end

    if Input:released("jump") then
      self.jumping = false
    end

    if Input:down("shoot") and not self.rolling then
      if not self.shooting then
        self.morphing = false
        love.audio.play("assets/shoot.ogg", "static", nil, 0.3)
        still_shooting = true
        self.shooting = love.timer.getTime()
        Signal.emit(
            SIGNALS.SHOOT, self.x + (self.last_dir > 0 and self.w or 0),
            self.y + self.gun_height, self.last_dir, 0)
      end
    end
  end

  x = self.x + self.x_velocity * dt + 0.000001
  y = self.y + self.y_velocity * dt + 0.000001
  self.y_velocity = self.y_velocity + self.gravity * dt

  local cols
  if self.rolling then
    local newX, newY = 0, 0
    newX, newY, cols = self.world:move(
                           self, x + self.rolling_x, y + self.rolling_y,
                           self.filter)
    self.x, self.y = newX - self.rolling_x, newY - self.rolling_y
  else
    self.x, self.y, cols = self.world:move(self, x, y, self.filter)
  end

  local ground = false
  for _, col in pairs(cols) do
    if col.type == "cross" then
      self:cross(col.other)
    elseif col.type == "bounce" then
      self:bounce(col.other)
    elseif col.normal.y == 1 then
      self.y_velocity = 0
    elseif col.normal.y == -1 then
      ground = true
      self.y_velocity = 0
    end
  end

  self.ground = ground

  if not self.ground and not self.rolling then
    self.next_tag = "Jump"
  end

  if still_shooting then
    if not self.ground then
      self.next_tag = "Jump aim"
    elseif self.x_velocity ~= 0 then
      self.next_tag = "Run aim"
    else
      self.next_tag = "Idle aim"
    end

  end

  local _, _, cols = world:check(self, self.x, self.y - self.rolling_y)
  self.ceiling = false
  for _, col in pairs(cols) do
    if col.normal.y == 1 then
      self.ceiling = true
    end
  end

  self.sprite:setTag(self.next_tag)

  self:moveOutOfBounds()
end

function Player:onLoop()
  if self.sprite.tagName == "Morph" then
    self:start_rolling()
  elseif self.sprite.tagName == "Stand" then
    self:stop_rolling()
  elseif self.sprite.tagName == "Death" then
    self.sprite:setTag("Dead")
    Signal.emit(SIGNALS.LOSE)
  end
end

function Player:bounce(other)
  if self.bouncing then
    return
  end
  if other.type == "crawler" then
    self:hit(1)
  end
  self.bouncing = true
  local diff = (self.x + self.w / 2) - (other.x + other.w / 2)
  local dir = diff / math.abs(diff)
  self.x_velocity = self.bounciness * dir
end

function Player:cross(other)
  if other.type == "item" then
    love.audio.play("assets/pickup.ogg", "static", nil, 0.7)
    if other.item == "ball" then
      other:destroy()
      self.ball = true
    end
  elseif other.type == "acid" then
    self:die()
  end
end

function Player:hit(hit)
  local damage = hit or 1
  love.audio.play("assets/hurt.ogg", "static", nil, 0.7)
  self.hp = self.hp - damage
  Signal.emit(SIGNALS.HIT)
end

function Player:die()
  self.next_tag = "Death"
end

function Player:filter(other)
  if other.type then
    if other.type == "crawler" then
      if not self.bouncing then
        return "bounce"
      else
        return nil
      end
    elseif other.type == "bullet" then
      return nil
    elseif other.type == "item" or other.type == "acid" then
      return "cross"
    else
      return "slide"
    end
  else
    return "slide"
  end
end

function Player:onLevelLoaded()
  self.jumping = false
  self.world:add(self, self.x, self.y, self.w, self.h)
end

function Player:display_hp()
  for i = 1, self.hp do
    love.graphics.draw(self.heart, (i - 1) * self.heart:getWidth() + i, 58)
  end
end

function Player:new(p, map_width, map_height)
  self.type = "player"
  self.hp = 5
  self.heart = love.graphics.newImage("assets/heart.png")

  -- POSITION
  self.x = p.x
  self.y = p.y
  self.top = p.top
  self.left = p.left
  self.w = p.w
  self.h = p.h
  self.rolling_h = p.rolling_h
  self.rolling_w = p.rolling_w
  self.rolling_x = p.rolling_x
  self.rolling_y = p.rolling_y

  -- SHOOTING
  self.shooting = false
  self.gun_height = self.h - 6

  -- ITEMS
  self.ball = false

  -- PHYSICS
  self.speed = 50
  self.friction = 5
  self.ground = false
  self.ceiling = false
  self.jump_height = -93
  self.gravity = 180
  self.jumping = false
  self.y_velocity = 0
  self.x_velocity = 0
  self.bounciness = 600
  self.bouncing = false
  self.morphing = false
  self.standing = false

  -- LEVEL BOUNDARIES
  self.east = map_width
  self.south = map_height
  self.north = 0
  self.west = 0

  -- DRAWING
  self.sprite = peachy.new(
                    "assets/player.json",
                    love.graphics.newImage("assets/player.png"), "Idle")

  self.sprite:onLoop(self.onLoop, self)
  self.last_dir = 1
  self.sprite:play()
end

return Player

