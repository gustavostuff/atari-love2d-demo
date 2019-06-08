local bullet = {}
bullet.__index = bullet -- google OOP Lua

local colors = require 'colors'
local utils = require 'utils'

function bullet.new(data)
  local b = {}

  b.x = data.playerX
  b.y = data.playerY
  b.lifespan = 3
  b.alive = true
  b.speed = 150

  -- shoot towards mouse with a fixed speed:

  local distance = math.sqrt(
    math.pow(data.mouseX - data.playerX, 2) +
    math.pow(data.mouseY - data.playerY, 2)
  )

  b.speedX = (data.mouseX - b.x) / distance * b.speed
  b.speedY = (data.mouseY - b.y) / distance * b.speed

  b.img = data.img
  b.radius = 1

  return setmetatable(b, bullet) -- google OOP Lua
end

function bullet.updateAll(bullets, canvas, dt)
  for i = #bullets, 1, -1 do
    local b = bullets[i]

    b:update(dt)
    utils.computeRebound(b, {
      left = 0,
      right = canvas:getWidth(),
      top = 0,
      bottom = canvas:getHeight()
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

function bullet:draw(gr)
  gr.setColor(colors.orange)

  gr.draw(
    self.img,
    math.floor(self.x),
    math.floor(self.y),
    0,
    1,
    1,
    self.img:getWidth() / 2,
    self.img:getHeight() / 2
  )

  if love.debug then
    gr.circle('line', self.x, self.y, self.radius)
  end
end

return bullet
