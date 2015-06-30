if Creep == nil then
	Creep = class({})
end

function Creep:init(creatureID, answer, useMath)
	self.creatureID = creatureID
	self.answer = answer
	self.useMath = useMath or false
end

function Creep:test(creep)
	print(self.creatureID)
	print(self.answer)
	print(self.useMath)
end
