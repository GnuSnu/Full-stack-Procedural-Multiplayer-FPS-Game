local IS_INDEPENDENT : boolean = script.Parent.IsIndependent.Value   --means that it'll show the model independently(without waiting for some signal from f.ex. a lootbox)
local IS_DISPENSER : BoolValue = script.Parent.IsDispenser.Value -- After a player takes the loot, does the Item's value change?

local LootObj = script.Parent
local LootObjVisual = LootObj.Visual
local Item =  LootObj.Item.Value      -- If you want to set a specific loot item to spawn, drag it in here
local isLooted = false
local WeaponType = string.find(LootObj.Name, "CLOSE") 
if Item then
	Item = Item:Clone()
	WeaponType = string.find(Item.Name, "CLOSE") 
end
if WeaponType==nil then
	WeaponType= "FAR"
else
	WeaponType= "CLOSE"
end


if not Item then
	if WeaponType=="CLOSE" then
		local Weapons = game:GetService("ReplicatedStorage").Weapons.CLOSE:GetChildren()
		for ind,i in Weapons do --remove Fists
			if i:IsA("Folder") then  --remove Fists
				table.remove(Weapons,ind)
				break
			end
		end
		Item = Weapons[math.random(#Weapons)]:Clone()
	else
		local Weapons = game:GetService("ReplicatedStorage").Weapons.FAR:GetChildren()
		Item = Weapons[math.random(#Weapons)]:Clone()
	end
	
end

if Item:FindFirstChild("Blaster")then
	if Item.Blaster:FindFirstChild("SKINS")then
		--item has skins
		local Skin : string = Item.Blaster.SKINS:GetChildren()[math.random(#Item.Blaster.SKINS:GetChildren())].Value
		local WeaponTexture,ToolTexture = string.split(Skin,"|")[1],string.split(Skin,"|")[2]
		--print(WeaponTexture, ToolTexture)
		Item.Blaster.Body.TextureID = "rbxassetid://"..WeaponTexture
		Item.TextureId = "rbxassetid://"..ToolTexture	
	end
end



local ROTATION_SPEED = 0.02

function SetModel()
	LootObjVisual.Transparency = 0
	for _,i in LootObj:GetChildren() do
		if i:IsA("Model") then               --can't have any loose models inside!
			i:Destroy()
		end
	end

	for _,i in Item:GetChildren() do
		if not i:IsA("Model") then
			continue
		end
		local m = i:Clone()
		if not m.PrimaryPart then
			warn("Weapon's model has no primary part!")
			return
		end

		m.Parent = LootObj
		m:PivotTo(LootObj:GetPivot())
		m:PivotTo(m:GetPivot() * CFrame.new(0,2,0))
		m:PivotTo(m:GetPivot() * CFrame.Angles(math.rad(90),0,0))
		for _,i in m:GetChildren() do
			if i:IsA("BasePart") then
				i.CanCollide = false
				i.CanTouch = true
				i.Anchored = true 
			end
		end

		task.spawn(function()
			while game:GetService("RunService").Heartbeat:Wait() do
				m:PivotTo(m:GetPivot() * CFrame.Angles(0,0,ROTATION_SPEED))
			end
		end
		)



		return
	end
	warn("Weapon has no model to display!")
end



function PlayerHasThisWeaponType(player : Player)
	--check Backpack
	for i,v in pairs(player.Backpack:GetChildren()) do
		if v:IsA("Tool") and string.find(v.Name, WeaponType) then
			return v
		end
	end
	--check Player
	for i,v in pairs(player.Character:GetChildren()) do
		if v:IsA("Tool") and string.find(v.Name, WeaponType) then
			return v
		end
	end

	return nil
end

local LootingTask

function GetLoot(player:Player)

	local I = Item:Clone()

	local PlayerHasThisWeapon = PlayerHasThisWeaponType(player)

	if PlayerHasThisWeapon and string.find(PlayerHasThisWeapon.Name, "Fists") then
		--Handle fists
		if PlayerHasThisWeapon.Parent ~= player.Backpack then
			player.Character.Humanoid:UnequipTools()
			for i,v in pairs(player.Backpack:GetChildren()) do
				if v:IsA("Tool") and string.find(v.Name, "Fists") then
					PlayerHasThisWeapon = v
					break
				end
			end
		end

		game.Debris:AddItem(PlayerHasThisWeapon,0)

		I.Parent = player.Backpack
		
		if not IS_DISPENSER then
			LootObj:Destroy()
		end
		return

	end


	if not PlayerHasThisWeapon then
		I.Parent = player.Backpack
		if not IS_DISPENSER then 
			LootObj:Destroy() 
		end
		return
	end

	LootingTask = task.spawn(function()

		local timestamp = os.clock()
		while (os.clock() - timestamp < 2.2) do
			ROTATION_SPEED = 0.02 + (os.clock() - timestamp)*0.5
			game:GetService("RunService").Heartbeat:Wait()
		end
		ROTATION_SPEED = 0.02


		--swap Player's weapon with this weapon
		if PlayerHasThisWeapon.Parent ~= player.Backpack then
			while PlayerHasThisWeapon:GetAttribute("_reloading") do
				task.wait()
			end
			player.Character:FindFirstChild("Humanoid"):UnequipTools()
			for i,v in pairs(player.Backpack:GetChildren()) do
				if v:IsA("Tool") and string.find(v.Name, WeaponType) then
					PlayerHasThisWeapon = v
					break
				end
			end
		end

		if not IS_DISPENSER then
			Item = PlayerHasThisWeapon:Clone()
		end
		game.Debris:AddItem(PlayerHasThisWeapon,0)
		I.Parent = player.Backpack


		SetModel()

		isLooted = true

		LootObjVisual.Color = Color3.new(
			LootObjVisual.Color.R * 0.25,
			LootObjVisual.Color.G * 0.25,
			LootObjVisual.Color.B * 0.25)
		task.wait(3)
		isLooted = false

		LootObjVisual.Color = Color3.new(
			LootObjVisual.Color.R * 4,
			LootObjVisual.Color.G * 4,
			LootObjVisual.Color.B * 4)


	end)
end

local isTouching = false

function HandleTouch(touch)
	if not(touch) or not(touch.Parent) or not(game.Players:GetPlayerFromCharacter(touch.Parent)) or not(touch.Parent.PrimaryPart == touch) then
		return
	end
	if isLooted or isTouching then
		return
	end
	isTouching = true
	GetLoot(game.Players:GetPlayerFromCharacter(touch.Parent))



end

function HandleTouchEnd(touch)
	if not(touch) or not(touch.Parent) or not(game.Players:GetPlayerFromCharacter(touch.Parent)) or not(touch.Parent.PrimaryPart == touch) then
		return
	end
	isTouching = false
	if not isLooted then
		pcall(function()
			task.cancel(LootingTask)
		end)
	end
	ROTATION_SPEED = 0.02

end


LootObj.Touched:Connect(HandleTouch)
LootObj.TouchEnded:Connect(HandleTouchEnd)
if not IS_INDEPENDENT then
	LootObjVisual:GetPropertyChangedSignal("Transparency"):Once(SetModel)
else
	SetModel()
	LootObj.CanTouch = true
end