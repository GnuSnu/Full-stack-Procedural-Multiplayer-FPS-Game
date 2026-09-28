local attackEvent = game.ReplicatedStorage.Weapons.Remotes.Bat.Attack
local batTool     = game.ReplicatedStorage.Weapons.CLOSE.CLOSE_Bat
local hitbox      = game.ReplicatedStorage.Weapons.CLOSE.CLOSE_Bat.HITBOX

local PlayerMatchStats = require(game.ServerScriptService.Weapons.Modules.getPlayerMatchStats)

local EliminateEvent = game.ServerScriptService.Weapons.Events.Eliminated

attackEvent.OnServerEvent:Connect(function(Player, Bat, amountOfHitPlayers)

	local BatSettings   = require(Bat.Scripts.Modules.BatSettings)
	local BatController = require(Bat.Scripts.Modules.BatController)
	
	local damageMultiplier = 1 + (PlayerMatchStats.UpgradePower * PlayerMatchStats.getPlayerUpgrades(Player))
	local damage = BatSettings.damage * damageMultiplier

	--print(Bat:FindFirstAncestorWhichIsA("Model").Name )

	if not (os.clock() - BatController.lastAttackTimestamp >= BatSettings.delayAfterAttack) then
		--warn("Wait ".. BatSettings.delayAfterAttack - (os.clock() - BatController.lastAttackTimestamp) .."s. before next attack")
		return
	end

	BatController.lastAttackTimestamp = os.clock()

	--play hit anim on serv
	task.spawn(function()
		pcall(function()
			Bat:FindFirstChild("Bat"):FindFirstChild("model").Transparency = 1
			Bat:FindFirstChild("Bat"):FindFirstChild("model2").Transparency = 0
			task.wait(0.3)
			Bat:FindFirstChild("Bat"):FindFirstChild("model").Transparency = 0
			Bat:FindFirstChild("Bat"):FindFirstChild("model2").Transparency = 1			
		end)
		--Bat.Bat.PrimaryPart.CFrame = Bat.Bat.PrimaryPart.CFrame * CFrame.Angles(math.rad(90),0,0)
	end)


	attackEvent:FireClient(Player) --player gets info that attack ran on server, thus updates lastAttackTimestamp

	local character = Player.Character

	local lookvector = character.PrimaryPart.CFrame.LookVector
	local hbox = hitbox:Clone()
	hbox.Position = Bat.Handle.Position
	hbox:PivotTo(hbox:GetPivot() * CFrame.new(lookvector * 3))
	hbox.CFrame = CFrame.lookAlong(hbox.Position, lookvector)
	hbox.Parent = Bat
	hbox.Name = "ATTACK HITBOX BY "..Player.Name

	local PartsInHitbox = game.Workspace:GetPartsInPart(hbox)

	local attackedPlayers = {}

	for _,i in PartsInHitbox do
		if i.Parent and i.Parent.Name~="GnuSnuX" then print(i.Parent, i) end
		if i.Parent and game:GetService("Players"):GetPlayerFromCharacter(i.Parent) then
			local plr = game:GetService("Players"):GetPlayerFromCharacter(i.Parent)
			if plr and not table.find(attackedPlayers, plr) and not (plr==Player) then
				table.insert(attackedPlayers, plr)
			end
		else
			if i.Parent and i.Parent:isA("Model") and i.Parent.PrimaryPart and i==i.Parent.PrimaryPart and i.Parent:FindFirstChild("Humanoid") then  --non player objects (like in the playground area)
				i.Parent.Humanoid:TakeDamage(damage)
			end
		end
	end

	--warn("Confirmed Players attacked("..#attackedPlayers.."):")
	local plrA = Player.Character.Head.Position

	for _,i in attackedPlayers do

		if i.Character.Humanoid.Health <= 0 then
			continue
		end
		--cast raycast
		local plrB1 = i.Character.PrimaryPart.Position
		local plrB2 = i.Character.Head.Position

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {Player.Character, i.Character}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		local ray = workspace:Raycast(plrA, plrB1-plrA, raycastParams)

		if ray then
			ray = workspace:Raycast(plrA, plrB2-plrA, raycastParams)
			if ray then
				warn("Something (",ray.Instance.Name,") was in a way of a hit between ",Player.Name, i.Name)
				continue
			end
		end


		i.Character.Humanoid:TakeDamage(damage)
		if i.Character.Humanoid.Health <= 0 then
			warn(i.Name, "died, killed by",Player.Name)
			EliminateEvent:Fire(Player, i.Character, damage)
		end
	end

	hbox:Destroy()



end)