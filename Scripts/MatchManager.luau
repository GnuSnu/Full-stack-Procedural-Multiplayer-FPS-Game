local Lobby = game.Workspace.Lobby
local MazeStructure = script.Parent.Parent

local MazeSettings = require(script.Parent.Generator.MazeStarterSettings)
local DataManager = require(game.ServerScriptService.Data.DataManager)
local ManagerModule = require(script.MatchManagerModule)
local MatchStats = require(script.Parent.MatchStatsModule)

local SpawnStormEvent = MazeStructure.Events.SpawnStorm
local EndGameEvent = MazeStructure.Events.END_GAME
local SpawnFinishedEvent = game.Workspace.MazeGeneration:WaitForChild("MazeSpawner").SpawnFinished
local EndGameEvent_lobby = game.Workspace.Lobby:WaitForChild("STARTING_AREA").MatchEnded


local UI_StartCounter = script.UI_StartCounter


function END_GAME(ForcedEnd)
	ForcedEnd = ForcedEnd or false
	if not ForcedEnd then
		for _,i in ManagerModule.PLAYERS_ALIVE do
			game:GetService("TestService"):Message("Player "..i.Name.." has won!")
			DataManager.AddWin(game.Players:GetPlayerFromCharacter(i))
			
			i.Humanoid.Health = 100
			i.Humanoid:UnequipTools()
			
			if i:FindFirstChild("MazeID") then
				i.MazeID:Destroy()
			else
				warn("Winner of the match doesn't have child called 'MazeID'")
			end
			
			for __,it in game.Players:GetPlayerFromCharacter(i).Backpack:GetChildren() do
				it:Destroy()
			end
			i.PrimaryPart.CFrame = Lobby.SpawnLocation.CFrame * CFrame.new(0,20,0)
		end
	else
		for _,i in ManagerModule.PLAYERS_ALIVE do
			i.Humanoid.Health = 0
		end
	end
	
	
	MatchStats.ClearStats()
	EndGameEvent_lobby:Fire()
	EndGameEvent:Fire()
end


function OnPlayerDeath(plr)
	print(plr, " died")
	

	for ind,plrr in pairs(ManagerModule.PLAYERS_ALIVE) do
		if plrr == plr then
			table.remove(ManagerModule.PLAYERS_ALIVE, ind)
			print("Succesfully removed",plr,"from PLAYERS_ALIVE")
			break
		end
	end
	--print("PLAYERS_ALIVE:",ManagerModule.PLAYERS_ALIVE)
	if(#ManagerModule.PLAYERS_ALIVE <= 1) then
		END_GAME()
	end
end

function InitializeConnectionsWithPlayers()
	--print("players alive:",ManagerModule.PLAYERS_ALIVE)
	for _,plr in pairs(ManagerModule.PLAYERS_ALIVE) do
		--print("Successfully started listening to",plr.Name.."'s potential death")
		
		-- Using this will also catch player disconnecting during match
		local player = game.Players:GetPlayerFromCharacter(plr)
		local success, errormsg = pcall(function()
			player.CharacterRemoving:Once(OnPlayerDeath)
			MatchStats.AddPlayer(player)
		end)
		if not success then --It's vital that we catch players leaving during match | TODO:UI_FOR_THIS_SITUATION
			warn("Error while setting up CharacterRemoving event for",plr.Name)
			task.wait(3)
			END_GAME(true)
			return
		end
	end	
end		


SpawnFinishedEvent.Event:Connect(InitializeConnectionsWithPlayers)

task.spawn(function()
	task.wait(MazeSettings.Storm_start_time)
	while task.wait(MazeSettings.Storm_spawn_delay) do
		SpawnStormEvent:Fire()
	end
	
end)

task.spawn(function()
	while #MazeStructure.Spawners:GetChildren() ~= #MazeSettings.SpawnPositions do
		task.wait()
	end
	
	for i=10,1,-1 do
		print("Match starting in:",i)
		UI_StartCounter.Value = i
		task.wait(1)
	end
	UI_StartCounter.Value = 0
	
	for _,i in MazeStructure.Spawners:GetChildren() do
		i.PrimaryPart.CanCollide = false
		for __,ii in i.PrimaryPart:GetChildren() do
			ii.CanCollide = false
		end
		i.PrimaryPart.Transparency = 1
	end
	
	task.wait(5)
	
	for _,i in MazeStructure.Spawners:GetChildren() do
		i:Destroy()
	end
	
	
end)