local utils = require 'utils'
local constants = require 'constants'

local player = {}

function player.init(data)
  player.x = data.x or 100
  player.y = data.y or 100
  player.img = data.img
  player.radius = 2
  player.speed = 120
end

function player.move(dt)
  if love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl') then
    do return end
  end

  if love.keyboard.isDown('a') or love.keyboard.isDown('left') then
    player.x = player.x - player.speed * dt
  elseif love.keyboard.isDown('d') or love.keyboard.isDown('right') then
    player.x = player.x + player.speed * dt
  end

  if love.keyboard.isDown('w') or love.keyboard.isDown('up') then
    player.y = player.y - player.speed * dt
  elseif love.keyboard.isDown('s') or love.keyboard.isDown('down') then
    player.y = player.y + player.speed * dt
  end

  utils.keepOnScreen(player, player.radius * 2.2)
end

function player.screenCoords()
  return
    math.floor(player.x),
    math.floor(player.y),
    0,
    1,
    1,
    player.img:getWidth() / 2,
    player.img:getHeight() / 2
end

function player.draw()
  love.graphics.setColor(constants.colors.ORANGE)
  love.graphics.draw(
    player.img,
    player.screenCoords()
  )

  if love.debug then
    love.graphics.setColor(constants.colors.WHITE)
    love.graphics.circle('line', player.x, player.y, player.radius)
  end
end

return player