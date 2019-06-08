enemy = {
  initSpeed = 10
}
enemy.__index = enemy -- google OOP Lua

local utils = require 'utils'
local colors = require 'colors'

function enemy.new(data)
  local e = {}

  -- math similar to bullet.new:

  e.radius = 5
  e.x = love.math.random(0, data.canvas:getWidth())
  e.y = love.math.random(-data.canvas:getHeight() / 3, 0)
  e.alive = true

  e.speedX, e.speedY = data.speed or enemy.initSpeed, data.speed or enemy.initSpeed

  if love.math.random(1, 2) == 1 then
    e.speedX = e.speedX * -1
  end

  if love.math.random(1, 2) == 1 then
    e.speedY = e.speedY * -1
  end

  e.img = data.img

  return setmetatable(e, enemy) -- google OOP Lua
end

function enemy.updateAll(enemies, canvas, dt)
  for i = #enemies, 1, -1 do
    local e = enemies[i]

    e:update(dt)
    utils.computeRebound(e, {
      left = 0,
      right = canvas:getWidth(),
      top = -canvas:getHeight() / 2,
      bottom = canvas:getHeight()
    })

    if not e.alive then
      table.insert(enemies, enemy.new({
        canvas = canvas,
        img = imgEnemy,
        speed = math.abs(e.speedX) + 5
      }))
      table.remove(enemies, i)
    end
  end
end

function enemy:update(dt)
  self.x = self.x + self.speedX * dt
  self.y = self.y + self.speedY * dt
end

function enemy:draw(gr)
  gr.setColor(colors.pink)

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

return enemy