-- Generated from template

if TypingGame == nil then
	TypingGame = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
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
        unit1 = 'npc_dota_hero_nevermore',
        unit2 = 'npc_dota_hero_lina'
    }
	-- todo: id => creature logic

	return CreateUnitByName(createList[creatureId], spawnLocation, true, nil, nil, TypingGame:GetTeam(playerId))
end


function TypingGame:SpawnUnit(playerId, creatureId)
	local targetLocation = TypingGame:GetTargetLocation(playerId)
	local creature = TypingGame:GetCreatureById(creatureId, playerId);

	creature:SetInitialGoalEntity(targetLocation)
	creature:SetMustReachEachGoalEntity(true)
end


function TypingGame:OnPlayerPickHero(args)
	print("OnPlayerPickHero")
	DeepPrintTable(args)
end

function TypingGame:InitGameMode()
	print( "Typing Game addon is loaded." )
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

