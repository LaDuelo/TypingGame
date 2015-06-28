local MyClass = {} -- the table representing the class, which will double as the metatable for the instances
MyClass.__index = MyClass -- failed table lookups on the instances should fallback to the class table, to get methods


-- syntax equivalent to "MyClass.new = function..."
function MyClass.new()
  local self = setmetatable({}, MyClass)
  return self
end
self = MyClass.new()

function MyClass:topkek()
self.unitData = {unit1 = 10}
MyClass:topcake()
end

function MyClass:topcake()
print(self.unitData.unit1)
end

MyClass:topkek()
