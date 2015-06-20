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
	if plyTeam == DOTA_TEAM_GOODGUYS then
		local spawner = Entities:FindByClassname(nil, "npc_dota_spawner_good_mid")
		local creature = CreateUnitByName("npc_dota_hero_nevermore", spawner:GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_GOODGUYS)
		local direAncient = Entities:FindByName(nil, "dota_badguys_fort")
		local vecDireAncient = direAncient:GetAbsOrigin()
		creature:SetInitialGoalEntity(direAncient)
		creature:SetMustReachEachGoalEntity(true)
	else
		local spawner = Entities:FindByClassname(nil, "npc_dota_spawner_bad_mid")
		local creature = CreateUnitByName("npc_dota_hero_nevermore", spawner:GetAbsOrigin() + RandomVector( RandomFloat( 0, 200 ) ), true, nil, nil, DOTA_TEAM_BADGUYS)
		local radiantAncient = Entities:FindByName(nil, "dota_goodguys_fort")
		local vecRadiantAncient = radiantAncient:GetAbsOrigin()
		creature:SetInitialGoalEntity(radiantAncient)
		creature:SetMustReachEachGoalEntity(true)
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