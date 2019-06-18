local utils = require 'utils'
local constants = require 'constants'

local bullet = {
  normalDelay = 0.2,
  extraBulletsDelay = 0.1,
  speed = 180
}
bullet.__index = bullet -- google OOP Lua

function bullet.new(data)
  local b = {}

  b.x = data.playerX
  b.y = data.playerY
  b.lifespan = 3
  b.alive = true

  -- shoot towards mouse with a fixed speed:

  local distance = math.sqrt(
    math.pow(data.mouseX - data.playerX, 2) +
    math.pow(data.mouseY - data.playerY, 2)
  )

  b.speedX = (data.mouseX - b.x) / distance * bullet.speed
  b.speedY = (data.mouseY - b.y) / distance * bullet.speed

  b.img = data.img
  b.radius = data.radius or 1

  return setmetatable(b, bullet) -- google OOP Lua
end

function bullet.updateAll(bullets, dt)
  for i = #bullets, 1, -1 do
    local b = bullets[i]

    b:update(dt)
    utils.computeRebound(b, {
      left = 0,
      right = constants.CANVAS_WIDTH,
      top = 0,
      bottom = constants.CANVAS_HEIGHT
    })

    if not b.alive then
      table.remove(bullets, i)
    end
  end
end

function bullet:update(dt)
  self.x = self.x + self.speedX * dt
  self.y = self.y + self.speedY * dt
  self.lifespan = self.lifespan - dt

  if self.lifespan <= 0 then
    self.alive = false
  end
end

function bullet:draw()
  love.graphics.setColor(constants.colors.ORANGE)

  utils.drawCenteredImage(self)

  if love.debug then
    love.graphics.setColor(constants.colors.WHITE)
    love.graphics.circle('line', self.x, self.y, self.radius)
  end
end

return bullet
