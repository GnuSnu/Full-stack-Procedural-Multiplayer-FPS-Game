local Bat = script.Parent.Parent



local hitbox = game.ReplicatedStorage.Weapons.CLOSE.CLOSE_Bat.HITBOX
local localplayer = game.Players.LocalPlayer
local character = localplayer.Character
local attackEvent = game.ReplicatedStorage.Weapons.Remotes.Bat.Attack

local BatSettings   = require(script.Parent.Modules.BatSettings)
local BatController = require(script.Parent.Modules.BatController)

attackEvent.OnClientEvent:Connect(function()
	BatController.lastAttackTimestamp = os.clock()
end)

Bat.Equipped:Connect(function()
	Bat.Bat:FindFirstChildWhichIsA("MeshPart").Transparency = 1
end)


Bat.Unequipped:Connect(function()
	Bat.Bat:FindFirstChildWhichIsA("MeshPart").Transparency = 0
end)


Bat.Activated:Connect(function()
	if not (os.clock() - BatController.lastAttackTimestamp >= BatSettings.delayAfterAttack) then
		--print("os.clock():",os.clock()," lastTimestamp:",BatController.lastAttackTimestamp)
		--warn("you have to wait", BatSettings.delayAfterAttack - (os.clock() - BatController.lastAttackTimestamp) )
		return
	end
	
	
	
	local lookvector = character.PrimaryPart.CFrame.LookVector
	local hbox = hitbox:Clone()
	hbox.Position = Bat.Handle.Position
	hbox:PivotTo(hbox:GetPivot() * CFrame.new(lookvector * 3))
	hbox.CFrame = CFrame.lookAlong(hbox.Position, lookvector)
	hbox.Parent = Bat
	
	local PartsInHitbox = game.Workspace:GetPartsInPart(hbox)
	
	local attackedPlayers = {}
	
	for _,i in PartsInHitbox do
		if i.Parent and game:GetService("Players"):GetPlayerFromCharacter(i.Parent) then
			local player = game:GetService("Players"):GetPlayerFromCharacter(i.Parent)
			if player and not table.find(attackedPlayers, player) and not (player==localplayer) then
				table.insert(attackedPlayers, player)
			end
		end	
	end
	
	--print("Players attacked("..#attackedPlayers.."):")
	for _,i in attackedPlayers do
		print(i)
	end
	
	attackEvent:FireServer(Bat, #attackedPlayers)

	
	hbox:Destroy()
	
end)

Bat.Bat.model:GetPropertyChangedSignal("Transparency"):Connect(function()
	if Bat.Bat.model.Transparency ~= 1 then
		Bat.Bat.model.Transparency=1
	end
end)

Bat.Bat.model2:GetPropertyChangedSignal("Transparency"):Connect(function()
	if Bat.Bat.model2.Transparency ~= 1 then
		Bat.Bat.model2.Transparency=1
	end
end)