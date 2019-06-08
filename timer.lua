timer = {
  timerCollection = {}
}

function timer.new(key, duration)
  timer.timerCollection[key] = {
    deltaSum = 0,
    duration = duration,
    times = 0
  }
end

function timer.isTimeFor(key, dt)
  local timer = timer.timerCollection[key]

  timer.deltaSum = timer.deltaSum + dt

  if timer.deltaSum >= timer.duration then
    timer.times = timer.times + 1
    timer.deltaSum = 0
    return true
  end
end

function timer.getDelta(key)
  return timer.timerCollection[key].deltaSum
end

function timer.getTimes(key)
  return timer.timerCollection[key].times
end

function timer.isDone(key)
  return timer.timerCollection[key].times >= 1
end

function timer.reset(key)
  timer.timerCollection[key].deltaSum = 0
  timer.timerCollection[key].times = 0
end

return timer