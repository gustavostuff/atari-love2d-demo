return {
  computeRebound = function(obj, rectangle)
    if obj.x >= rectangle.right then
      obj.x = canvas:getWidth()
      obj.speedX = obj.speedX * -1
    elseif obj.x <= rectangle.left then
      obj.x = 0
      obj.speedX = obj.speedX * -1
    end

    if obj.y >= rectangle.bottom then
      obj.y = canvas:getHeight()
      obj.speedY = obj.speedY * -1
    elseif obj.y <= rectangle.top then
      obj.y = 0
      obj.speedY = obj.speedY * -1
    end
  end,
  keepOnScreen = function(obj, canvas)
    if obj.x > canvas:getWidth() then
      obj.x = canvas:getWidth()
    end

    if obj.x < 0 then obj.x = 0 end

    if obj.y > canvas:getHeight() then
      obj.y = canvas:getHeight()
    end

    if obj.y < 0 then obj.y = 0 end
  end,
  areColliding = function(a, b)
    -- Pythagoras
    local distance = math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2))

    return distance < a.radius + b.radius
  end,
  mouseBtns = {
    LEFT = 1,
    RIGHT = 2,
    MIDDLE = 3
  }
}