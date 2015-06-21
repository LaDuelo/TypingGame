-- Generated from template

require("util")

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
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	PrecacheResource( "particle", "particles/econ/items/legion/legion_weapon_voth_domosh/legion_commander_duel_text.vpcf", context)
	PrecacheResource( "particle", "particles/msg_fx/msg_evade.vpcf", context)
	PrecacheResource ("model_folder", 	"models/heroes/lina", context)
	PrecacheResource ("model_folder", "models/heroes/nevermore", context)
	PrecacheResource ("particle_folder", "particles/econ/items/legion", context)
	PrecacheResource ("particle_folder", "particles/units/heroes/hero_alchemist/", context)
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
        unit1 = 'npc_dota_neutral_rock_golem',
        unit2 = 'npc_dota_neutral_fel_beast'
    }
	-- todo: id => creature logic

	return CreateUnitByName(createList[creatureId], spawnLocation, true, nil, nil, TypingGame:GetTeam(playerId))
end


function TypingGame:SpawnUnit(playerId, creatureId)
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
	
	ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(TypingGame, 'OnPlayerPickHero'), self)
	
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
		if v == text then
			--find entity HScript and kill it
			local entToKill = EntIndexToHScript(k:GetEntityIndex())
			entToKill:Kill(nil, PlayerResource:GetPlayer(args['playerId']))
			entityOnMap[k] = nil
			break --we want to kill only one unit with matching words
		end
	end
	Say(PlayerResource:GetPlayer(args['playerId']), text, false)
end


local function onMakeUnitClick(eventSourceIndex, args)
	local playerId = args["playerId"]
	local unitId = "unit" .. args["unit"]

    -- todo: money shit

	TypingGame:SpawnUnit(playerId,unitId);
end

CustomGameEventManager:RegisterListener("input_submit", onInputSubmit)
CustomGameEventManager:RegisterListener("make_unit_click", onMakeUnitClick)

