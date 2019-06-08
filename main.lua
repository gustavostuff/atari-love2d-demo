--[[

Workshop keypoints:

* Pythagoras for mouse bullet shooting
* Direction inversion for bullet rebound on screen
* More Pythagoras for enemy<>bullet collisions
* Enemy spawn
* Game state

Contest notes:

* Send this .love file to the class (slack preferably)
* Try the .love file to see if it works
* At 3, we start
* Send me the score for email
* Give the price to the winner and close the workshop

]]

local colors = require 'colors'
local player = require 'player'
local bullet = require 'bullet'
local enemy = require 'enemy'
local timer = require 'timer'
local utils = require 'utils'

local gr = love.graphics
local kb = love.keyboard
local au = love.audio
local mo = love.mouse

--love.debug = true

function love.load()
  imgsDir = '/imgs/'
  fontsDir = '/fonts/'
  soundsDir = '/sounds/'

  mainFont = gr.newFont(fontsDir .. 'ATARCC__.TTF', 8)
  gr.setFont(mainFont)

  imgPlayer = gr.newImage(imgsDir .. 'player.png')
  imgBullet = gr.newImage(imgsDir .. 'bullet.png')
  imgEnemy = gr.newImage(imgsDir .. 'enemy.png')

  soundGameOver = love.audio.newSource(soundsDir .. 'gameOver.ogg', 'static')
  soundEnemyDies = love.audio.newSource(soundsDir .. 'enemyDies.ogg', 'static')

  canvas = gr.newCanvas(160, 192) -- Atari 2600 max resolution
  canvasW = canvas:getWidth()
  canvasH = canvas:getHeight()
  --canvas:setFilter('nearest', 'nearest')

  sx, sy = gr.getWidth() / canvasW, gr.getHeight() / canvasH
  MAX_ENEMIES = 10
  gameOverText = 'GAME OVER'
  gameStarted = false

  -- timers:

  timer.new('shoot', 0.2)

  -- player:

  player.init({
    img = imgPlayer
  })

  setInitialState()
end

function love.update(dt)
  if not gameOver and gameStarted then
    -- player:

    player.move(dt, kb, canvas)

    if mo.isDown(utils.mouseBtns.LEFT) and timer.isTimeFor('shoot', dt) then
      shootBullet()
    end

    -- collisions enemy <> bullet, enemy <> player:

    for i = #enemies, 1, -1 do
      local e = enemies[i]

      if utils.areColliding(e, player) then
        soundGameOver:play()
        gameOver = true
      end

      for j = #bullets, 1, -1 do
        local b = bullets[j]

        if utils.areColliding(b, e) then
          soundEnemyDies:play()
          e.alive = false
          b.alive = false
          increaseScore()
        end
      end
    end

    -- update stuff:

    enemy.updateAll(enemies, canvas, dt)
    bullet.updateAll(bullets, canvas, dt)
  end
end

function love.draw()
  gr.setColor(colors.white)
  gr.setCanvas(canvas)


  if not gameStarted then
    gr.setColor(colors.black)
    drawBackground(gr)
    gr.setColor(colors.white)
    gr.print('PRESS ANY KEY')
  else
    -- background:

    drawBackground(gr)

    -- player:

    player.draw(gr)

    -- bullets:

    for i = 1, #bullets do
      bullets[i]:draw(gr)

    end

    -- enemies:

    for i = 1, #enemies do
      enemies[i]:draw(gr)
    end

    -- game over:

    if gameOver then
      gr.setColor(colors.white)
      gr.print(
        gameOverText,
        math.floor(canvasW / 2 - gr.getFont():getWidth(gameOverText) / 2),
        math.floor(canvasH / 2 - gr.getFont():getHeight() / 2)
      )
    end

    -- score:

    gr.setColor(colors.white)
    gr.print(score)
  end


  gr.setCanvas()
  gr.setColor(colors.white)
  gr.draw(canvas, 0, 0, 0, sx, sy)

  if love.debug then
    gr.setColor(colors.white)
    gr.print('FPS ' .. love.timer.getFPS() ..
      '\nbullets: ' .. #bullets ..
      '\nscore:' .. score, 0, 30)
  end
end

function drawBackground(gr)
  gr.setColor(colors.black)
  gr.rectangle('fill', 0, 0, canvasW, canvasH)
end

function increaseScore()
  score = score + 10
end

function shootBullet()
  table.insert(bullets, 
    bullet.new({
      playerX = player.x,
      playerY = player.y,
      mouseX = mo.getX() / sx,
      mouseY= mo.getY() / sy,
      img = imgBullet
    })
  )
end

function setInitialState()
  enemies = {}
  bullets = {}
  player.x = canvasW / 2
  player.y = canvasH
  score = 0
  gameOver = false

  for i = 1, MAX_ENEMIES do
    table.insert(enemies, enemy.new({
      canvas = canvas,
      img = imgEnemy
    }))
  end
end

function love.keypressed(k)
  if k == 'escape' then
    love.event.quit()
  else
    if not gameStarted then
      gameStarted = true
    elseif gameOver and k == 'return' then
      setInitialState()
    end
  end
end

function love.mousepressed(x, y, btn)
  if btn == utils.mouseBtns.LEFT and gameStarted and not gameOver then
    shootBullet()
  end
end

function love.mousereleased(x, y, btn)
  if btn == utils.mouseBtns.LEFT then
    timer.reset('shoot')
  end
end

function love.resize(w, h)
  sx = w / canvasW
  sy = h / canvasH
end
