local localplayer = game.Players.LocalPlayer
local character = localplayer.Character
local UIS = game:GetService("UserInputService")

local ToolsGui = script.Parent
local SlotCLOSE = ToolsGui.ToolSlot_CLOSE
local SlotFAR = ToolsGui.ToolSlot_FAR

local SlotCLOSE_img = SlotCLOSE.InnerFrame.Tool_image
local SlotFAR_img = SlotFAR.InnerFrame.Tool_image

local UnequippedColor = Color3.fromRGB(58, 58, 86)
local EquippedColor = Color3.fromRGB(210,210,210)

local SlotCLOSE_img_empty = "rbxassetid://112635354047283"
local SlotFAR_img_empty = "rbxassetid://107134473812223"


local currentTools : {Tool}   = {CLOSE=nil, FAR=nil}
local currentToolsConnections = {CLOSE=nil, FAR=nil} 

character.ChildAdded:Connect(function(child)
	--check if MazeID got removed (player removed from match)
	if child.Name ~= "MazeID" or not child:IsA("StringValue") then return end
	print("mazeId added")

	SlotFAR_img.Image = SlotFAR_img_empty
	SlotCLOSE_img.Image = SlotCLOSE_img_empty

	if currentTools.CLOSE then currentTools.CLOSE = nil end
	if currentTools.FAR   then currentTools.FAR = nil end
	if currentToolsConnections.CLOSE then currentToolsConnections.CLOSE = nil end
	if currentToolsConnections.FAR   then currentToolsConnections.FAR = nil end
	
	ToolsGui.Enabled = true

end)

character.ChildRemoved:Connect(function(child)
	--check if MazeID got removed (player removed from match)
	if child.Name ~= "MazeID" or not child:IsA("StringValue") then return end
	print("mazeId removeed")
	
	SlotFAR_img.Image = SlotFAR_img_empty    --just why not
	SlotCLOSE_img.Image = SlotCLOSE_img_empty
	
	ToolsGui.Enabled = false
	
end)

localplayer.Backpack.ChildAdded:Connect(function(child)
	if not child:IsA("Tool") then return end
	
	
	
	if string.find(child.Name,"CLOSE") then
		--toolType = "CLOSE"
		
		if currentTools.CLOSE == child then
			return
		end
		
		if currentTools.CLOSE then
			local timestamp = os.clock()
			while os.clock() - timestamp <= 1 do
				task.wait()
				if not currentTools.CLOSE then
					break
				end
			end

		end

		if currentTools.CLOSE then
			warn("Equipped tool CLOSE while another one in hand!")
			return
		end

		currentTools.CLOSE = child
		
		SlotCLOSE_img.Image = child.TextureId
		
		currentToolsConnections.CLOSE = currentTools.CLOSE.AncestryChanged:Connect(function(child, parent)
			--print("CLOSE tool moved to "..parent.Name)
			
			if parent ~= character and parent~= localplayer.Backpack then
				--print("player deleted the CLOSE tool!")
				SlotCLOSE.BackgroundColor3 = UnequippedColor
				if currentToolsConnections.CLOSE then    --if some edge case occurs and it's nil, then the code wont crash
					currentToolsConnections.CLOSE:Disconnect()				
				end
				currentTools.CLOSE = nil
			end
			
			if parent == character then
				SlotCLOSE.BackgroundColor3 = EquippedColor
			else
				SlotCLOSE.BackgroundColor3 = UnequippedColor
			end
			
		end)
		
		currentTools.CLOSE.Destroying:Once(function()
			--print("CLOSE TOOL DESTROYED!")
			SlotCLOSE.BackgroundColor3 = UnequippedColor
			if currentToolsConnections.CLOSE then    --if some edge case occurs and it's nil, then the code wont crash
				currentToolsConnections.CLOSE:Disconnect()				
			end
			currentTools.CLOSE = nil
		end)
		
		if currentTools.CLOSE.Name == "CLOSE_Fists" then
			EquipTool("CLOSE")
		end
		

	else
		--toolType = "FAR"
		
		if currentTools.FAR == child then
			return
		end
		
		if currentTools.FAR then
			local timestamp = os.clock()
			while os.clock() - timestamp <= 1 do
				task.wait()
				if not currentTools.FAR then
					break
				end
			end
			
		end
		
		if currentTools.FAR then
			warn("Equipped tool FAR while another one in hand!")
			return
		end
		
		currentTools.FAR = child
		
		SlotFAR_img.Image = child.TextureId
		
		currentToolsConnections.FAR = currentTools.FAR.AncestryChanged:Connect(function(child, parent)
			--print("FAR tool moved to "..parent.Name)

			if parent ~= character and parent~= localplayer.Backpack then
				--print("player deleted the FAR tool!")
				SlotFAR.BackgroundColor3 = UnequippedColor
				if currentToolsConnections.FAR then     --if some edge case occurs and it's nil, then the code wont crash
					currentToolsConnections.FAR:Disconnect()
				end
				currentTools.FAR = nil

			end

			if parent == character then
				SlotFAR.BackgroundColor3 = EquippedColor
			else
				SlotFAR.BackgroundColor3 = UnequippedColor
			end
		end)
		
		currentTools.FAR.Destroying:Once(function()
			--print("FAR TOOL DESTROYED!")
			SlotFAR.BackgroundColor3 = UnequippedColor
			if currentToolsConnections.FAR then     --if some edge case occurs and it's nil, then the code wont crash
				currentToolsConnections.FAR:Disconnect()
			end
			currentTools.FAR = nil
		end)
		
	end
	
end)

function UnequipTool(tool)
	if not tool then return end
	tool.Parent = localplayer.Backpack
end

function EquipTool(tool:string)
	-- tool = "CLOSE" / "FAR"
	
	if tool == "CLOSE" then
		if not currentTools.CLOSE then return end
		if currentTools.FAR then
			UnequipTool(currentTools.FAR)
		end

		if currentTools.CLOSE.Parent == localplayer.Backpack then
			currentTools.CLOSE.Parent = character
		else
			currentTools.CLOSE.Parent = localplayer.Backpack
		end
	else
		if not currentTools.FAR then return end
		if currentTools.CLOSE then
			UnequipTool(currentTools.CLOSE)
		end

		if currentTools.FAR.Parent == localplayer.Backpack then
			currentTools.FAR.Parent = character
		else
			currentTools.FAR.Parent = localplayer.Backpack
		end
	end
	
end


UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.One then
		EquipTool("CLOSE")
	elseif input.KeyCode == Enum.KeyCode.Two then
		EquipTool("FAR")
	end
	
end)
SlotCLOSE_img.MouseButton1Click:Connect(function()
	EquipTool("CLOSE")
end)
SlotFAR_img.MouseButton1Click:Connect(function()
	EquipTool("FAR")
end)