require("util")
require("timers")
require("notifications")
require("bigArrays")
require("income")
--require("creeps")
--Because OOP in Lua is T.R.A.S.H.
entityOnMap = {}


if TypingGame == nil then
	TypingGame = {}
	TypingGame.__index = TypingGame
else
	print("Unregistering listeners")
	--making sure we don't spawn more than one per click after script_reload
	CustomGameEventManager:UnregisterListener(list1)
	CustomGameEventManager:UnregisterListener(list2)
	CustomGameEventManager:UnregisterListener(list3)
end

function TypingGame.new()
	self = setmetatable({}, TypingGame)
	return self
end

function Precache( context )
	PrecacheResource ("model", "models/creeps/neutral_creeps/n_creep_ogre_med/n_creep_ogre_med.mdl", context)
	PrecacheResource ("model", "models/creeps/neutral_creeps/n_creep_gnoll/n_creep_gnoll_frost.vmdl", context)
	PrecacheResource ("model", "models/heroes/alchemist/alchemist_ogre_head.vmdl", context)
	PrecacheResource ("model_folder", "models/heroes/tuskarr", context)
	PrecacheResource ("particle", "particles/generic_gameplay/lasthit_coins.vpcf", context)
	PrecacheResource ("particle", "particles/msg_fx/msg_gold.vpcf", context)
	PrecacheResource ("particle", "particles/neutral_fx/gnoll_base_attack.vpcf", context)
end

-- Create the game mode when we activate
function Activate()
	--GameRules.TypingGame = TypingGame()
	TypingGame:InitGameMode()
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
	-- todo: id => creature logic
	--Bugged?
	local unitData = TypingGame:getUnitData()
	return CreateUnitByName(unitData[creatureId].creatureName, spawnLocation, true, nil, nil, TypingGame:GetTeam(playerId))
end

function TypingGame:SpawnUnit(playerId, creatureId, gold, useMath, answer)
	local targetLocation = TypingGame:GetTargetLocation(playerId)
	local creature = TypingGame:GetCreatureById(creatureId, playerId)
	--work out how do we include different types of math, addition and multiplication
	-- if useMath then
		-- local creep
		-- Creep:init(creatureId, answer, useMath)
	-- else
		-- local word
		-- if self.unitData[creatureId].difficulty == 'easy' then
			-- word = PickRandomValue(dict_easy, "word")
		-- elseif self.unitData[creatureId].difficulty == 'medium' then
			-- word = PickRandomValue(dict_medium, "word")
		-- elseif self.unitData[creatureId].difficulty == 'hard' then
			-- word = PickRandomValue(dict_hard, "word")
		-- end
		-- --local creep = Creep:init(creatureId, word)
	-- end
	--Creep:test(creep)
	local word
	if self.unitData[creatureId].difficulty == 'easy' then
		word = PickRandomValue(dict_easy, "word")
	elseif self.unitData[creatureId].difficulty == 'medium' then
		word = PickRandomValue(dict_medium, "word")
	elseif self.unitData[creatureId].difficulty == 'hard' then
		word = PickRandomValue(dict_hard, "word")
	end
	creature:SetInitialGoalEntity(targetLocation)
	creature:SetMustReachEachGoalEntity(true)
	
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

function TypingGame:OnPlayerConnect(args)
	--[[ args:
		[   VScript ]: {
		[   VScript ]:    index                           	= 0 (number)
		[   VScript ]:    userid                          	= 1 (number)
		[   VScript ]:    splitscreenplayer               	= -1 (number)
		[   VScript ]: }
	]]
	initIncome(args["index"])
end


 
function TypingGame:OnGameRulesStateChange(args)
--create income timer
	print("GAME STATE: "..GameRules:State_Get())
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		giveIncome()
	end

end

function TypingGame:InitGameMode()
	print( "Typing Game addon is loaded." )
	GameRules:GetGameModeEntity().TypingGame = self
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled(false)
	GameRules:GetGameModeEntity():SetCameraDistanceOverride(1600)
	GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
	
	GameRules:SetGoldPerTick(0)
	GameRules:SetGoldTickTime(0)
	GameRules:SetPreGameTime(0)
	GameRules:SetSameHeroSelectionEnabled(true)
	GameRules:SetHeroSelectionTime(0)
	GameRules:SetCustomGameSetupAutoLaunchDelay(0)
	GameRules:SetCustomGameSetupRemainingTime(0)
	
	
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( TypingGame, 'OnEntityKilled' ), self )
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(TypingGame, 'OnPlayerConnect'), self)
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( TypingGame, 'OnGameRulesStateChange' ), self )
	
	Convars:RegisterCommand("spawnfake",function(...) return spawnFakeUnits() end, "Spawns 10 enemy units", FCVAR_CHEAT) --you have to type it twice to make it work, this will do for now
	
	self.unitData = unitData
end

function TypingGame:OnEntityKilled(keys)
	--DeepPrintTable(keys)
end

-- Evaluate the state of the game
function TypingGame:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

function TypingGame:getUnitData()
--Registering a listener with Dynamic_Wrap and accessing self throws attempt to index local 'self' (a number value), but this works, so top kek
	return self.unitData
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
	local unitData = TypingGame:getUnitData()
	if PlayerResource:GetGold(playerId) >= unitData[unitId]["price"] then
		TypingGame:SpawnUnit(playerId,unitId, unitData[unitId]["price"])
		TypingGame:SpawnUnit(8,unitId, unitData[unitId]["price"])
	else
		Say(ply, "LOL", false)
	end
end

function onUnitDataRequest( eventSourceIndex, args)
	Msg("foo");
	local unitData = TypingGame:getUnitData()
	CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(args["player"]), "transmit_unit_data", unitData)
end

list1 = CustomGameEventManager:RegisterListener("input_submit", onInputSubmit)
list2 = CustomGameEventManager:RegisterListener("make_unit_click", onMakeUnitClick)
list3 = CustomGameEventManager:RegisterListener("request_unit_data", onUnitDataRequest)
