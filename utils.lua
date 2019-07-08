local constants = require 'constants'

return {
  computeRebound = function(obj, rectangle)
    if obj.x >= rectangle.right then
      obj.x = rectangle.right
      obj.speedX = obj.speedX * -1
    elseif obj.x <= rectangle.left then
      obj.x = rectangle.left
      obj.speedX = obj.speedX * -1
    end

    if obj.y >= rectangle.bottom then
      obj.y = rectangle.bottom
      obj.speedY = obj.speedY * -1
    elseif obj.y <= rectangle.top then
      obj.y = rectangle.top
      obj.speedY = obj.speedY * -1
    end
  end,
  keepOnScreen = function(obj, margin)
    local m = margin or 0

    if (obj.x + m) > constants.CANVAS_WIDTH then
      obj.x = constants.CANVAS_WIDTH - m
    end

    if (obj.x - m) < 0 then obj.x = m end

    if (obj.y + m) > constants.CANVAS_HEIGHT then
      obj.y = constants.CANVAS_HEIGHT - m
    end

    if (obj.y - m) < 0 then obj.y = m end
  end,
  areColliding = function(a, b)
    -- Pythagoras
    local distance = math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2))

    return distance < a.radius + b.radius
  end,
  drawCenteredImage = function(obj)
    love.graphics.draw(
      obj.img,
      math.floor(obj.x),
      math.floor(obj.y),
      0,
      1,
      1,
      obj.img:getWidth() / 2,
      obj.img:getHeight() / 2
    )
  end,
  mouseBtns = {
    LEFT = 1,
    RIGHT = 2,
    MIDDLE = 3
  }
}