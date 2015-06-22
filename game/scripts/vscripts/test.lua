function table.set(t) -- set of list
  local u = { }
  for _, v in ipairs(t) do u[v] = true end
  return u
end

function table.find(f, l) -- find element v of l satisfying f(v)
  for _, v in ipairs(l) do
    if f(v) then
      return v
    end
  end
  return nil
end


unitPrices = {unit1 = 2}
local ret = table.find("unit1", unitPrices)
print(unitPrices.unit1)
