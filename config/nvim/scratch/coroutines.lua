local co = coroutine

local thread = co.create(function(x, y, z)
  print(x, y, z)
  x, y, z = co.yield(x, y, z)
  print(x, y, z)
  return 12
end)

local ret = { co.resume(thread, 1, 2, 3) }
P(ret)

ret = { co.resume(thread, 4, 5, 6) }
P(ret)

ret = { co.resume(thread, 8) }
P(ret)

-- P(coroutine.resume(co))
-- P(coroutine.resume(co, 4, 5))
-- P(coroutine.resume(co))
