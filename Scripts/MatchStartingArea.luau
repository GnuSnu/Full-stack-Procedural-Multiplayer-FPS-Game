local MazeGeneration = game.Workspace.MazeGeneration
local MazeStarterSettings = require(script.Parent.MazeSettings1)
local MazeStrucutre = game.ReplicatedStorage.MazeGeneration:WaitForChild("MazeStucture")

local UI_value = script.UI_value
local ToggleUIEvent = script.ToggleUI

local SpawnEvent = MazeGeneration:WaitForChild("MazeSpawner").SPAWN
local MatchEndedEvent = script.Parent:WaitForChild("MatchEnded")

local Visual = script.Parent.Visual
local Visual_WAITING = BrickColor.new("New Yeller")      --im using the color of the visual to get the state of the game
local Visual_STARTING = BrickColor.new("Lime green")
local Visual_DURING_MATCH = BrickColor.new("Earth green")


local PLAYERS_NEEDED_TO_START = 2
local TIME_NEEDED_TO_START_MATCH = 3

local playersInTouch = {}



function UpdateUI(text)
	UI_value.Value = text
end

UpdateUI("Need "..PLAYERS_NEEDED_TO_START.." more players to start!")

function TogglePlayerUI(character, status)
	local plr = game.Players:GetPlayerFromCharacter(character)
	ToggleUIEvent:FireClient(plr, status)
end


function removeAllPlayersInTouch()
	for ind,plr in pairs(playersInTouch) do
		TogglePlayerUI(plr, false)
	end
	table.clear(playersInTouch)
end

function removePlayerInTouch(plr, characterRemoved)
	--print("[removePlayerInTouch] characterRemoved=",characterRemoved)
	--print("[removePlayerInTouch] plr=",plr)
	
	characterRemoved = characterRemoved or false --if character doesnt exists, Toggling UI causes error
	
	
	--print("Removing ",plr,"from match queue")
	for ind,val in pairs(playersInTouch) do
		if val == plr or game.Players:GetPlayerFromCharacter(val)==nil then
			if not characterRemoved then
				TogglePlayerUI(plr, false)
			end
			table.remove(playersInTouch, ind)
		end
	end
	
end

function addPlayerInTouch(plr)
	--print("added",plr,"to a match queue!")
	TogglePlayerUI(plr, true)
	table.insert(playersInTouch,plr)
end

function SpawnMaze()
	local M = MazeStrucutre:Clone()
	local Ms = require(M.Scripts.Generator.MazeStarterSettings)
	
	-- SET THE SETTINGS OF A MAZE:
	if #playersInTouch <=2 then
		
		Ms.Row_lenght = MazeStarterSettings.SMALL_Row_lenght
		Ms.Column_lenght = MazeStarterSettings.SMALL_Column_lenght
		Ms.SpawnPositions = MazeStarterSettings.SMALL_SpawnPositions
		Ms.LootBoxAmount = MazeStarterSettings.SMALL_LootBoxAmount
		Ms.StructureAmount = MazeStarterSettings.SMALL_StructureAmount
		
	elseif #playersInTouch <=4 then
		Ms.Row_lenght = MazeStarterSettings.NORMAL_Row_lenght
		Ms.Column_lenght = MazeStarterSettings.NORMAL_Column_lenght
		Ms.SpawnPositions = MazeStarterSettings.NORMAL_SpawnPositions
		Ms.LootBoxAmount = MazeStarterSettings.NORMAL_LootBoxAmount
		Ms.StructureAmount = MazeStarterSettings.NORMAL_StructureAmount
	else
		Ms.Row_lenght = MazeStarterSettings.BIG_Row_lenght
		Ms.Column_lenght = MazeStarterSettings.BIG_Column_lenght
		Ms.SpawnPositions = MazeStarterSettings.BIG_SpawnPositions
		Ms.LootBoxAmount = MazeStarterSettings.BIG_LootBoxAmount
		Ms.StructureAmount = MazeStarterSettings.BIG_StructureAmount
	end
	
	
	------
	--Ms.Vertex_distance = MazeStarterSettings.Vertex_distance
	Ms.Vertex_distance = 12 + math.random(0,3)*4 
	------
	
	Ms.Storm_height = MazeStarterSettings.Storm_height	
	Ms.Storm_color = MazeStarterSettings.Storm_color
	Ms.Storm_damage = MazeStarterSettings.Storm_damage
	Ms.Storm_spawn_delay = MazeStarterSettings.Storm_spawn_delay
	Ms.Storm_start_time = MazeStarterSettings.Storm_start_time
	Ms.Starting_vertex_position = MazeStarterSettings.Starting_vertex_position
	Ms.Max_row_length = MazeStarterSettings.Max_row_length
	Ms.Max_column_length = MazeStarterSettings.Max_column_length
	Ms.Looks = MazeStarterSettings["Looks"..math.random(1,4)]
	
	-- GENERATE MAZE
	M.Parent = MazeGeneration
	local ID = string.format("MazeStructure%d",math.random( bit32.lshift(1,31) - 1))
	M.Name = ID
	
	
	SpawnEvent:Fire(ID, playersInTouch) -- Maze Spawner uses it to properly add players to the match
	removeAllPlayersInTouch()
	
	UpdateUI("Wait for the end of the match!")
	--print("Players in touch:",playersInTouch)

end



local spawnMazeTask
local spawningTaskRunning_bool = false



function HandleTouch(touch)
	
	local plr = game:GetService("Players"):GetPlayerFromCharacter(touch.Parent)
	
	if  not(plr) or not(plr.Character) or not(touch == plr.Character:FindFirstChild("HumanoidRootPart")) then
		return
	end
	
	if plr.Character:FindFirstChild("MazeID") then  --if someone is in a match, they cant join another one/enter spectate mode
		return
	end
	
	
	if Visual.BrickColor == Visual_DURING_MATCH then
		script.Parent.EnterSpectateMode:FireClient(game.Players:GetPlayerFromCharacter(plr.Character))
		return
	end
	
	if Visual.BrickColor == Visual_STARTING then
		touch = plr.Character
		addPlayerInTouch(touch)
		return
	end


	touch = plr.Character

	addPlayerInTouch(touch)
	
	if #playersInTouch >=PLAYERS_NEEDED_TO_START then
		--print("STATGIN MATCH!")
		--print(playersInTouch)
		
		spawnMazeTask = task.spawn(function()
			spawningTaskRunning_bool = true
			Visual.BrickColor = Visual_STARTING
			for i=1,TIME_NEEDED_TO_START_MATCH do
				
				UpdateUI(1 + TIME_NEEDED_TO_START_MATCH - i)
				
				--print("Countdown:",1 + TIME_NEEDED_TO_START_MATCH - i)
				task.wait(1)
			end
			SpawnMaze()
			spawningTaskRunning_bool = false
			Visual.BrickColor = Visual_DURING_MATCH
		end)
	else
		
		
		local needmore = PLAYERS_NEEDED_TO_START- #playersInTouch
		if needmore > 1 then
			UpdateUI("Need "..needmore.." more players to start!")
		else
			UpdateUI("Need "..needmore.." more player to start!")
		end
		
		--print(PLAYERS_NEEDED_TO_START- #playersInTouch,"more players needed to start a match")
	end
	

end

function HandleTouchEnd(touch, characterRemoved:boolean)
	characterRemoved = characterRemoved or false  -- if true, make sure touch is the Player instance (not character)
	local plr;
	if not characterRemoved then
		plr = game:GetService("Players"):GetPlayerFromCharacter(touch.Parent)

		if (not plr) or (not plr.Character) or not(touch == plr.Character:FindFirstChild("HumanoidRootPart")) then
			return
		end

		if Visual.BrickColor == Visual_DURING_MATCH then
			script.Parent.LeaveSpectateMode:FireClient(game.Players:GetPlayerFromCharacter(plr.Character))
			return
		end
	else
		plr = touch
	end
	
	--print("[HandleTouchEnd]",plr,"left the queue")
	--print("[HandleTouchEnd] characterRemoved=",characterRemoved)
	touch = plr.Character

	removePlayerInTouch(touch,characterRemoved)
	
	if not spawningTaskRunning_bool then
		local needmore = PLAYERS_NEEDED_TO_START- #playersInTouch
		if needmore > 1 then
			UpdateUI("Need "..needmore.." more players to start!")
		else 
			UpdateUI("Need "..needmore.." more player to start!")
		end
	end
	
	if #playersInTouch < PLAYERS_NEEDED_TO_START and spawningTaskRunning_bool then
		task.cancel(spawnMazeTask)
		spawningTaskRunning_bool = false
		Visual.BrickColor = Visual_WAITING
		
		local needmore = PLAYERS_NEEDED_TO_START- #playersInTouch
		if needmore > 1 then
			UpdateUI("Need "..needmore.." more players to start!")
		else 
			UpdateUI("Need "..needmore.." more player to start!")
		end
		--print("MATCH CANCELLED")
	end

end

script.Parent.Touched:Connect(HandleTouch)
script.Parent.TouchEnded:Connect(HandleTouchEnd)

--[[
task.spawn(function()
	
	while task.wait(3) do
		print(playersInTouch)
	end
end)
]]

MatchEndedEvent.Event:Connect(function()
	Visual.BrickColor = Visual_WAITING
	
	if PLAYERS_NEEDED_TO_START > 1 then
		UpdateUI("Need "..PLAYERS_NEEDED_TO_START.." more players to start!")
	else
		UpdateUI("Need "..PLAYERS_NEEDED_TO_START.." more player to start!")
	end
	
end)

game.Players.PlayerAdded:Connect(function(plr)
	plr.CharacterRemoving:Connect(function(char)
		--print("player: ",plr," character removing!")
		HandleTouchEnd(plr, true)
	end)
end)