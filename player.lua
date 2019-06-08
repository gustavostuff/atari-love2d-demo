local colors = require 'colors'
local utils = require 'utils'

local player = {}

function player.init(data)
  player.x = data.x or 100
  player.y = data.y or 100
  player.img = data.img
  player.radius = 2
  player.speed = 120
end

function player.move(dt, kb, canvas)
  if kb.isDown('a') or kb.isDown('left') then
    player.x = player.x - player.speed * dt
  elseif kb.isDown('d') or kb.isDown('right') then
    player.x = player.x + player.speed * dt
  end

  if kb.isDown('w') or kb.isDown('up') then
    player.y = player.y - player.speed * dt
  elseif kb.isDown('s') or kb.isDown('down') then
    player.y = player.y + player.speed * dt
  end

  utils.keepOnScreen(player, canvas)
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

function player.draw(gr)
  gr.setColor(colors.orange)
  gr.draw(
    player.img,
    player.screenCoords()
  )

  if love.debug then
    gr.circle('line', player.x, player.y, player.radius)
  end
end

return player