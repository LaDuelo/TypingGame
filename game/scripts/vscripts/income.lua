income = {}
INCOME_DEFAULT = 10 -- 100 for testing purposes
function initIncome(playerID)
	--initializes the income table for all connected players
	if income[playerID] == nil then
		income[playerID] = INCOME_DEFAULT
	end
end

local function modifyIncome(playerID, add)
	income[playerID] = income[playerID] + add

	CustomGameEventManager:Send_ServerToAllClients( "income_updated", income )
end

function creepSpawn(unitPrice, playerID)
	--10% of creep cost added to income for spawning it
	local add = unitPrice / 10
	modifyIncome(playerID, add)
end

function wrongWord(playerID, creatureID)
	--every wrong word is -12% of player's income(12 because fuck you)
	local income = income[playerID]
	local newIncome = income * (1- 0.88)
	modifyIncome(playerID, -newIncome)
	Notifications:Top(playerID, "WRONG", 9, nil, {color="red"})
end

function giveIncome()
	--Creates a timer which gives income every x seconds
	--possible bug: timer does not have a unique name but i'm too lazy right now to add playerID on the end to fix that
	Timers:CreateTimer("GiveIncome",{
	callback = function()
		for i = 0,9 do
			local ply = PlayerResource:GetPlayer(i)
			if ply then
				local hero = ply:GetAssignedHero()
				if hero then
					hero:ModifyGold(income[i], true, 0)
				end
			end
		end

		return 10 -- every second for testing purposes
	end
	})
end