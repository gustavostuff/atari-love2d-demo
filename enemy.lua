local utils = require 'utils'
local constants = require 'constants'

enemy = {
  initSpeed = 10,
  speedIncrease = 8
}
enemy.__index = enemy -- google OOP Lua

function enemy.new(data)
  local e = {}

  e.radius = 5
  e.x = love.math.random(0, constants.CANVAS_WIDTH)
  e.y = love.math.random(-constants.CANVAS_HEIGHT / 2, 0)
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

function enemy.updateAll(enemies, dt)
  for i = #enemies, 1, -1 do
    local e = enemies[i]

    e:update(dt)
    utils.computeRebound(e, {
      left = 0,
      right = constants.CANVAS_WIDTH,
      top = -constants.CANVAS_HEIGHT / 2,
      bottom = constants.CANVAS_HEIGHT
    })

    if not e.alive then
      return e, i
    end
  end
end

function enemy:update(dt)
  self.x = self.x + self.speedX * dt
  self.y = self.y + self.speedY * dt
end

function enemy:draw()
  love.graphics.setColor(constants.colors.PINK)

  utils.drawCenteredImage(self)

  if love.debug then
    love.graphics.circle('line', self.x, self.y, self.radius)
  end
end

return enemy