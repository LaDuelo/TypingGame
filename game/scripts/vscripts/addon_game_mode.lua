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

function TypingGame:OnPlayerUseAbility(args)
	print("OnPlayerUseAbility")
	DeepPrintTable(args)
	local plyID = args["PlayerID"]
	local plyTeam = PlayerResource:GetTeam(plyID)
	local hero = PlayerResource:GetSelectedHeroEntity(plyID)
	if plyTeam == DOTA_TEAM_GOODGUYS then
		local spawner = Entities:FindByClassname(nil, "npc_dota_spawner_good_mid")
		CreateUnitByName('npc_dota_hero_nevermore', spawner:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
	else
		local spawner = Entities:FindByClassname(nil, "npc_dota_spawner_bad_mid")
		CreateUnitByName('npc_dota_hero_nevermore', spawner:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
	end
end

function TypingGame:OnPlayerPickHero(args)
	print("OnPlayerPickHero")
	DeepPrintTable(args)
end

function TypingGame:InitGameMode()
	print( "Typing Game addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	
	GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled(false)
	
	ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(TypingGame, 'OnPlayerUseAbility'), self)
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

function onInputSubmit(eventSourceIndex, args)
	local text
	for key,value in pairs(args['text']) do
		text = key
	end

	-- we have the entered text here
	Say(PlayerResource:GetPlayer(args['playerId']), text, false)
end

CustomGameEventManager:RegisterListener("input_submit", onInputSubmit);

function onMakeUnitClick(eventSourceIndex, args)
	local plyID = args["playerId"]
	local plyTeam = PlayerResource:GetTeam(plyID)
	if plyTeam == DOTA_TEAM_GOODGUYS then
		local spawner = Entities:FindByClassname(nil, "npc_dota_spawner_good_mid")
		CreateUnitByName('npc_dota_hero_nevermore', spawner:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
	else
		local spawner = Entities:FindByClassname(nil, "npc_dota_spawner_bad_mid")
		CreateUnitByName('npc_dota_hero_nevermore', spawner:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
	end
end

CustomGameEventManager:RegisterListener("make_unit_click", onMakeUnitClick)