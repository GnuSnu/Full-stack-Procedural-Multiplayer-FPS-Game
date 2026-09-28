local MatchStats = {}

MatchStats.Stats = {}

local UpgradePickupEvent = game.ReplicatedStorage.Remotes.UpgradePickup
local PlayerMatchStats = require(game.ServerScriptService.Weapons.Modules.getPlayerMatchStats) -- for upgrade power

-- MatchStats.Stats[player obj] = {kills, upgrades}

function MatchStats.AddPlayer(player)
	MatchStats.Stats[player] = {["Kills"]=0, ["Upgrades"]=0}
end

function MatchStats.AddKill(player)
	if MatchStats.Stats[player] == nil then return end
	MatchStats.Stats[player].Kills += 1
end

function MatchStats.AddUpgrade(player)
	if MatchStats.Stats[player] == nil then return end
	MatchStats.Stats[player].Upgrades += 1
	UpgradePickupEvent:FireClient(player, MatchStats.Stats[player].Upgrades, PlayerMatchStats.UpgradePower)
end

function MatchStats.GetStats(player)
	if MatchStats.Stats[player] == nil then return nil end
	return MatchStats.Stats[player]
end

function MatchStats.ClearStats()
	table.clear(MatchStats.Stats)
end

return MatchStats
