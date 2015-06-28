require("util")

-- TODO: dan pls poutt thsi osmehere proetty thanks al to m8
local unitData = {
	unit1 = {
		id = 1,
		image = "file://{images}/custom_game/le.png",
		title = "Rad dude #1",
		description = "the radest of them all. this dude couldn't contain his radness if his life depended on it",
		price = 10
	},
	unit2 = {
		id = 2,
		image = "file://{images}/custom_game/lina.png",
		title = "Cool guy #2",
		description = "really cool guy. totally. I mean, just look at him - not even a glacier is this fucking cool",
		price = 25
	}
}

dictionary = {
	word1 = "gabe",
	word2 = "top cake",
	word3 = "top kek",
	word4 = "ur mume",
	word5 = "cyborgfat"
}


--Because OOP in Lua is T.R.A.S.H.
entityOnMap = {}


if TypingGame == nil then
	_G.TypingGame = class({})
else
	--making sure we don't spawn more than one per click after script_reload
	CustomGameEventManager:UnregisterListener(list1)
	CustomGameEventManager:UnregisterListener(list2)
end

function Precache( context )
	PrecacheResource ("model", "models/creeps/neutral_creeps/n_creep_ogre_med/n_creep_ogre_med.mdl", context)
	PrecacheResource ("model", "models/creeps/neutral_creeps/n_creep_gnoll/n_creep_gnoll_frost.vmdl", context)
	PrecacheResource ("particle", "particles/generic_gameplay/lasthit_coins.vpcf", context)
	PrecacheResource ("particle", "particles/msg_fx/msg_gold.vpcf", context)
	PrecacheResource ("particle", "particles/neutral_fx/gnoll_base_attack.vpcf", context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = TypingGame()
	GameRules.AddonTemplate:InitGameMode()
end

function TypingGame:IsPlayerRadiant(playerId)
	return PlayerResource:GetTeam(playerId) == DOTA_TEAM_GOODGUYS
end

-- returns the position of the enemy ancient
function TypingGame:GetTargetLocation(playerId)
	if TypingGame:IsPlayerRadiant(playerId) then
		return Entities:FindByName(nil, "dota_badguys_fort")
	else
		return Entities:FindByName(nil, "dota_goodguys_fort")
	end
end

-- returns the spawner of the players team
function TypingGame:GetSpawnLocation(playerId)
	local spawner
	if TypingGame:IsPlayerRadiant(playerId) then
		spawner = Entities:FindByClassname(nil, "npc_dota_spawner_good_mid")
	else
		spawner = Entities:FindByClassname(nil, "npc_dota_spawner_bad_mid")
	end

	return spawner:GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) )
end

function TypingGame:GetTeam(playerId)
	if TypingGame:IsPlayerRadiant(playerId) then
		return DOTA_TEAM_GOODGUYS
	else
		return DOTA_TEAM_BADGUYS
    end
end

function TypingGame:GetCreatureById(creatureId, playerId)
	local spawnLocation = TypingGame:GetSpawnLocation(playerId)

    Msg(creatureId)
    local createList = {
        unit1 = 'npc_dota_creature_test_unit',
        unit2 = 'npc_dota_creature_gnoll_assassin'
    }
	-- todo: id => creature logic

	return CreateUnitByName(createList[creatureId], spawnLocation, true, nil, nil, TypingGame:GetTeam(playerId))
end

function TypingGame:SpawnUnit(playerId, creatureId, gold)
	local targetLocation = TypingGame:GetTargetLocation(playerId)
	local creature = TypingGame:GetCreatureById(creatureId, playerId);
	
	creature:SetInitialGoalEntity(targetLocation)
	creature:SetMustReachEachGoalEntity(true)
	
	local word = PickRandomValue (dictionary,"word")
	if PlayerResource:GetTeam(playerId) == DOTA_TEAM_BADGUYS then
		creature:SetCustomHealthLabel(word, 232, 28, 28)
	else
		creature:SetCustomHealthLabel(word, 100, 255, 255)
	end
	entityOnMap[creature] = word
	PlayerResource:SpendGold(playerId, gold, 0)
end

function spawnFakeUnits()
	SendToServerConsole('dota_create_fake_clients')
	print("enter")
	for i=0, 9 do
		-- Check if this player is a fake one
		if PlayerResource:IsFakeClient(i) then
		print("yes")
			local ply = PlayerResource:GetPlayer(i)
			local playerID = ply:GetPlayerID()
			ply:SetTeam(DOTA_TEAM_BADGUYS)
			if ply then
				for i = 0,9 do
				print("test")
					TypingGame:SpawnUnit(playerID, 'unit1')
				end
				break
			end
		end
	end
end

function TypingGame:OnPlayerPickHero(args)
	print("OnPlayerPickHero")
	DeepPrintTable(args)
end

function TypingGame:InitGameMode()
	print( "Typing Game addon is loaded." )
	
	GameRules:GetGameModeEntity().TypingGame = self
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled(false)
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1600)
	
	
	GameRules:SetGoldPerTick(15)
	GameRules:SetGoldTickTime(10)
	GameRules:SetPreGameTime(30)
	GameRules:SetSameHeroSelectionEnabled(true)
	GameRules:SetHeroSelectionTime(10)
	GameRules:SetCustomGameSetupAutoLaunchDelay(1)
	GameRules:SetCustomGameSetupRemainingTime(0)
	
	
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( TypingGame, 'OnEntityKilled' ), self )
	
	Convars:RegisterCommand("spawnfake",function(...) return spawnFakeUnits() end, "Spawns 10 enemy units", FCVAR_CHEAT) --you have to type it twice to make it work, this will do for now
	
	local unitPricesSet = table.set(unitPrices)
end

function TypingGame:OnEntityKilled(keys)
	--DeepPrintTable(keys)
end

-- Evaluate the state of the game
function TypingGame:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

local function onInputSubmit(eventSourceIndex, args)
	local text
	for key,value in pairs(args['text']) do
		text = key
	end
	-- we have the entered text here
	for k,v in pairs(entityOnMap) do
		if k ~= nil and v == text then
			lastHitCreep(k, args)
			break --we want to kill only one unit with the matching word
		end
	end
	Say(PlayerResource:GetPlayer(args['playerId']), text, false)
end

function lastHitCreep(creature, args)
	local entToKill = EntIndexToHScript(creature:GetEntityIndex())
	local playerEnt = PlayerResource:GetPlayer(args['playerId'])
	local hero = playerEnt:GetAssignedHero()
	entToKill:Kill(nil, hero) -- THIS NOW PROPERLY WORKS NO NEED FOR PARTICLES
	entityOnMap[creature] = nil --might throw C++ nil object bullshit, report if it does. Possibly happens after script_reload in which case ignore
end

local function onMakeUnitClick(eventSourceIndex, args)
	local playerId = args["playerId"]
	local unitId = "unit" .. args["unit"]
	local ply = PlayerResource:GetPlayer(playerId)
	local hero = ply:GetAssignedHero()

	if PlayerResource:GetGold(playerId) >= unitData[unitId]["price"] then
		TypingGame:SpawnUnit(playerId,unitId, unitData[unitId]["price"])
	else
		Say(ply, "LOL", false)
	end
end

list1 = CustomGameEventManager:RegisterListener("input_submit", onInputSubmit)
list2 = CustomGameEventManager:RegisterListener("make_unit_click", onMakeUnitClick)

function onUnitDataRequest( eventSourceIndex, args)
	Msg("foo");
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(args["player"]), "transmit_unit_data", unitData)
end

CustomGameEventManager:RegisterListener("request_unit_data", onUnitDataRequest);