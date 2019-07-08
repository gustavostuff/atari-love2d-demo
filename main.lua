local player = require 'player'
local bullet = require 'bullet'
local enemy = require 'enemy'
local timer = require 'timer'
local utils = require 'utils'
local constants = require 'constants'

function love.load()
  initDirectories()
  initGraphics()
  initAudio()
  initCanvas()
  initOtherStuff()
  setInitialState()
end

function initDirectories()
  imgsDir = '/assets/imgs/'
  fontsDir = '/assets/fonts/'
  soundsDir = '/assets/sounds/'
end

function initGraphics()
  mainFont = love.graphics.newFont(fontsDir .. 'ATARCC__.TTF', 8)
  love.graphics.setFont(mainFont)

  imgPlayer = love.graphics.newImage(imgsDir .. 'player.png')
  imgBullet = love.graphics.newImage(imgsDir .. 'bullet.png')
  imgEnemy = love.graphics.newImage(imgsDir .. 'enemy.png')
  imgTarget = love.graphics.newImage(imgsDir .. 'target.png')
end

function initAudio()
  soundGameOver = love.audio.newSource(soundsDir .. 'gameOver.ogg', 'static')
  soundEnemyDies = love.audio.newSource(soundsDir .. 'enemyDies.ogg', 'static')
end

function initCanvas()
  canvas = love.graphics.newCanvas(160, 192) -- Atari 2600 max resolution
  --canvas:setFilter('nearest', 'nearest')
  sx = love.graphics.getWidth() / constants.CANVAS_WIDTH
  sy = love.graphics.getHeight() / constants.CANVAS_HEIGHT
end

function initOtherStuff()
  gameOverText = 'GAME OVER'
  gameStarted = false
  timer.new('shoot', .2)
  player.init({
    img = imgPlayer
  })
  love.mouse.setCursor(love.mouse.newCursor(love.image.newImageData(1, 1), 0, 0))
end

function setInitialState()
  enemies = {}
  bullets = {}
  player.x = constants.CANVAS_WIDTH / 2
  player.y = constants.CANVAS_HEIGHT - 30
  score = 0
  gameOver = false

  for i = 1, constants.MAX_ENEMIES do
    table.insert(enemies, enemy.new({
      img = imgEnemy
    }))
  end
end



--*************************************************************************
--*************************************************************************
--*************************************************************************



function love.update(dt)
  if not gameOver and gameStarted then
    updatePlayer(dt)
    checkCollisions()
    updateEnemies(dt)
    bullet.updateAll(bullets, dt)
  end
end

function updatePlayer(dt)
  player.move(dt)

  if love.mouse.isDown(utils.mouseBtns.LEFT) and timer.isTimeFor('shoot', dt) then
    shootBullet()
  end
end

function checkCollisions()
  for i = #enemies, 1, -1 do
    local enemy = enemies[i]

    checkCollisionEnemyPlayer(enemy, player)

    for j = #bullets, 1, -1 do
      local bullet = bullets[j]
      checkCollisionEnemyBullet(enemy, bullet)
    end
  end
end

function updateEnemies(dt)
  local deadEnemy, index = enemy.updateAll(enemies, dt)

  if deadEnemy then
    table.insert(enemies, enemy.new({
      canvas = canvas,
      img = imgEnemy,
      speed = math.abs(deadEnemy.speedX) + enemy.speedIncrease
    }))
    table.remove(enemies, index)
  end
end

function checkCollisionEnemyPlayer(enemy, player)
  if utils.areColliding(enemy, player) then
    soundGameOver:play()
    gameOver = true
  end
end

function checkCollisionEnemyBullet(enemy, bullet)
  if utils.areColliding(enemy, bullet) then
    soundEnemyDies:play()
    enemy.alive = false
    bullet.alive = false
    increaseScore()
  end
end



--*************************************************************************
--*************************************************************************
--*************************************************************************



function love.draw()
  love.graphics.setColor(constants.colors.WHITE)
  love.graphics.setCanvas(canvas)

  drawBackground()

  if not gameStarted then
    drawInitialScreen()
  else
    drawMainStuff()
  end

  love.graphics.setCanvas()
  love.graphics.setColor(constants.colors.WHITE)
  love.graphics.draw(canvas, 0, 0, 0, sx, sy)

  if love.debug then
    printDebug()
  end
end

function drawInitialScreen()
  love.graphics.setColor(constants.colors.WHITE)
  love.graphics.print('PRESS ANY KEY')
end

function drawMainStuff()
  player.draw()

  for i = 1, #bullets do
    bullets[i]:draw()
  end

  for i = 1, #enemies do
    enemies[i]:draw()
  end

  drawTarget()

  if gameOver then
    love.graphics.setColor(constants.colors.WHITE)
    love.graphics.print(
      gameOverText,
      math.floor(constants.CANVAS_WIDTH / 2 - love.graphics.getFont():getWidth(gameOverText) / 2),
      math.floor(constants.CANVAS_HEIGHT / 2 - love.graphics.getFont():getHeight() / 2)
    )
  end

  love.graphics.setColor(constants.colors.WHITE)
  love.graphics.print(score)
end

function drawTarget()
  love.graphics.setColor(constants.colors.ORANGE)
  love.graphics.draw(imgTarget,
    math.floor(love.mouse.getX() / sx),
    math.floor(love.mouse.getY() / sy),
    0,
    1,
    1,
    imgTarget:getWidth() / 2,
    imgTarget:getHeight() / 2
  )
end

function drawBackground()
  love.graphics.clear()
  love.graphics.setColor(constants.colors.BLACK)
  love.graphics.rectangle('fill', 0, 0, constants.CANVAS_WIDTH, constants.CANVAS_HEIGHT)
end



--*******************************************************
--****************** general functions ******************
--*******************************************************



function increaseScore(amount)
  score = score + (amount or 10)
end

-- debug only function:
function highestEnemySpeed(enemies)
  if not love.debug then
    do return end
  end
  
  local highest = 0

  for i = 1, #enemies do
    if math.abs(enemies[i].speedX) > highest then
      highest = math.abs(enemies[i].speedX)
    end
  end

  return highest
end

function shootBullet()
  table.insert(bullets, 
    bullet.new({
      playerX = player.x,
      playerY = player.y,
      mouseX = love.mouse.getX() / sx,
      mouseY = love.mouse.getY() / sy,
      img = imgBullet,
      radius = radius
    })
  )
end

function printDebug()
  love.graphics.setColor(constants.colors.WHITE)
  love.graphics.print(
    'FPS ' .. love.timer.getFPS() ..
    '\nbullets: ' .. #bullets ..
    '\nscore:' .. score ..
    '\nenemies:' .. #enemies ..
    '\nplayer x, y:' ..
      string.format('%.2f', player.x) .. ', ' ..
      string.format('%.2f', player.y) ..
    '\nhighest enemy speed: ' .. highestEnemySpeed(enemies) ..
    '', 0, 30
  )
end



--*******************************************************
--******************** callbacks ************************
--*******************************************************



function love.keypressed(k)
  if k == 'escape' then
    love.event.quit()
  else
    if not gameStarted then
      gameStarted = true
    elseif gameOver and k == 'return' then
      setInitialState()
    end

    if love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl') then
      if k == 'd' then
        love.debug = not love.debug
      end
    end
  end
end

function love.mousepressed(x, y, btn)
  if btn == utils.mouseBtns.LEFT then
    if gameStarted and not gameOver then
      shootBullet()
    elseif gameOver then
      setInitialState()
    end
  end
end

function love.mousereleased(x, y, btn)
  if btn == utils.mouseBtns.LEFT then
    timer.reset('shoot')
  end
end

function love.resize(w, h)
  sx = w / constants.CANVAS_WIDTH
  sy = h / constants.CANVAS_HEIGHT
end
