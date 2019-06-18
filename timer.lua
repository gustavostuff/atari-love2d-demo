timer = {
  elements = {}
}

function timer.new(key, duration)
  timer.elements[key] = {
    deltaSum = 0,
    duration = duration or 1,
    times = 0
  }
end

function timer.isTimeFor(key, dt)
  if not timer.exists(key) then return end

  local t = timer.elements[key]
  t.deltaSum = t.deltaSum + dt

  if t.deltaSum >= t.duration then
    t.times = t.times + 1
    t.deltaSum = 0
    return true
  end
end

function timer.reset(key)
  if not timer.exists(key) then return end
  local t = timer.elements[key]
  
  timer.new(key, t.duration)
end

function timer.exists(key)
  if not timer.elements[key] then return false end
  return true
end

return timer