local MazeSettings = require(script.MazeStarterSettings)
local MazeStructure = script.Parent.Parent
local LootBoxes = game:GetService("ReplicatedStorage").LootBoxes
local EndGameEvent = MazeStructure.Events.END_GAME

local W:IntValue = MazeSettings.Row_lenght
local H:IntValue = MazeSettings.Column_lenght



local Edges = {}
local Vertexes = {} -- Vertexes[i] = {Vector3_position_of_vertex, Int_Edge_Intersection_state}
-- DSU
local Parent = table.create(MazeSettings.Max_row_length*MazeSettings.Max_column_length, 0)
local Size = table.create(MazeSettings.Max_row_length*MazeSettings.Max_column_length, 1)
--Graph
local G = table.create(MazeSettings.Max_row_length*MazeSettings.Max_column_length,0)
local Vis = table.create(MazeSettings.Max_row_length*MazeSettings.Max_column_length, false)

for i=1, #G do
	G[i] = {}
end

function find_set(v)
	if(Parent[v]==v) then
		return v
	end
	
	Parent[v] = find_set(Parent[v])
	return Parent[v]
end

function union_sets(v1,v2)
	v1 = find_set(v1)
	v2 = find_set(v2)
	
	if(Size[v1]<Size[v2]) then
		Parent[v1] = v2
		Size[v2] += Size[v1]
	else
		Parent[v2] = v1
		Size[v1] += Size[v2]	
	end
	
end

function CreateWall(v1 : Vector3, v2 : Vector3, isEdge : boolean)
	isEdge = isEdge or false
	
	local Looks = MazeSettings.Looks
	
	local Wall = Instance.new("Part")
	
	Wall.Size = Looks.size + Vector3.new(0, 0, (v1-v2).Magnitude)
	Wall.Position = (v1+v2)/2 + Vector3.new(0,Wall.Size.Y/2 -0.1,0) --the -0.1 is to avoid clipping with floor
	
	local degree = math.atan2(v1.X-v2.X , v1.Z - v2.Z)
	Wall.Orientation = Vector3.new(0,math.deg(degree),0)
	
	if isEdge then
		Wall.Parent = MazeStructure.Edges
		Wall.Name = "Edge"
		
		Wall.Orientation += Vector3.new(0,90,0)
		
		--later for animation:
		Wall.Transparency = 1
		
	else
		Wall.Parent = MazeStructure.Walls
		Wall.Name = "Wall"
	end

	
	
	Wall.Anchored = Looks.anchored
	Wall.BrickColor = Looks.brickColor
	Wall.Material = Looks.material
	if not isEdge then
		local invisWall = Wall:Clone()
		invisWall.Parent = MazeStructure.Walls
		invisWall.Name = "InvisWall"
		invisWall.Transparency = 0.5
		invisWall.Size = Wall.Size + Vector3.new(0,100,0)
		invisWall.Position = invisWall.Position + Vector3.new(0,50+Wall.Size.Y,0)
		invisWall.CastShadow = false
		invisWall.BrickColor = BrickColor.new("Fossil")
		invisWall.Material = Enum.Material.Metal
	end
	
end

function GetVertexID(v1, v2)
	return (v1-1)*W + v2
end

function shuffleTable(t)
	local j:number, temp:number
	for i = #t, 1, -1 do
		j = math.random(i)
		temp = t[i]
		t[i] = t[j]
		t[j] = temp
	end
end

function GenerateMaze()
	for i=1, #Edges do
		local v1 = Edges[i][1]
		local v2 = Edges[i][2]
		local v1Pos = Vertexes[v1][1] + Vector3.new(0,MazeSettings.Starting_vertex_position.Y,0)
		local v2Pos = Vertexes[v2][1] + Vector3.new(0,MazeSettings.Starting_vertex_position.Y,0)
		if(find_set(v1) == find_set(v2)) then
			CreateWall(v1Pos, v2Pos, true)
			
			-- Manage Fillers
			
			assert(v1 < v2)
			
			if (v2==v1+1) then
				--vertical edge
				
				Vertexes[v1][2] = bit32.bxor(Vertexes[v1][2], 1)
				
				if(v1-W > 0) then
					Vertexes[v1-W][2] = bit32.bxor(Vertexes[v1-W][2], 1)					
				end
				
			else
				--horizontal edge
				
				Vertexes[v1][2] = bit32.bxor(Vertexes[v1][2], 2)
				
				if (v1 % W ~= 1) then
					Vertexes[v1-1][2] = bit32.bxor(Vertexes[v1-1][2], 2)					
				end
			end
			
			continue
		end
		
		union_sets(find_set(v1), find_set(v2))
		table.insert(G[v1], v2)
		table.insert(G[v2], v1)
	end
end

function GenerateWalls()
	local VertDist = MazeSettings.Vertex_distance
	local V : Vector3 = Vector3.new(VertDist/2, 0, VertDist/2)
	local S : Vector3 = MazeSettings.Starting_vertex_position
	
	--[[
		corner indexes:
		1###2
		#####
		#####
		3###4
	]]
	
	--[[
		coordinates in maze:
		
		x : Down(+), Up(-)
		z : Left(+), Right(-)
	]]
	
	local WideDistance = (W-1)*VertDist
	local HeightDistance = (H-1)*VertDist
	
	local CornerPositions ={
		S + (V * Vector3.new(-1, 0, 1)),
		S + Vector3.new(0,0,-WideDistance) + (V * Vector3.new(-1, 0, -1)),
		S + Vector3.new(HeightDistance,0,0) + (V * Vector3.new(1, 0, 1)),
		S + Vector3.new(HeightDistance,0,-WideDistance) + (V * Vector3.new(1, 0, -1))
	}
	
	CreateWall(CornerPositions[1], CornerPositions[2])
	CreateWall(CornerPositions[2], CornerPositions[4]--[[ + Vector3.new(-VertDist,0,0)]])
	CreateWall(CornerPositions[3], CornerPositions[4])
	CreateWall(CornerPositions[1]--[[ + Vector3.new(VertDist,0,0)]], CornerPositions[3])
end

function GenerateFillers()
	
	local ShiftPos = Vector3.new(MazeSettings.Vertex_distance/2, 0, - MazeSettings.Vertex_distance/2)
	local Looks =  MazeSettings.Looks
	for ind, vertex in pairs(Vertexes) do
		--print("vertex ", ind, ". FillValue = ",vertex[2])
		if vertex[2] == 3 then
			local fill : BasePart = Instance.new("Part")
			fill.Parent = MazeStructure.Edges
			fill.Shape = Enum.PartType.Cylinder
			fill.Name = "filler"
			fill.Size = Vector3.new( Looks.size.Y,Looks.size.X, Looks.size.X)
			fill.Orientation = Vector3.new(0,0,90)
			fill.Position = vertex[1] + ShiftPos + Vector3.new(0,Looks.size.Y/2 -0.1,0) -- -0.1 is to avoid clipping with floor
			fill.Anchored = Looks.anchored
			fill.Material = Looks.material
			fill.BrickColor = Looks.brickColor
			
			--later for animation
			fill.Transparency = 1
		end
	end
end


local Leafs = {}     -- {vertex_id, depth_of_leaf, parentVertex}    | parent vertex is used to orient the look vector
local dfsDepth = 0
local lastIntersectionDepth = 1

function dfs(n,p)
	local prevIntersectionDepth  = lastIntersectionDepth
	
	dfsDepth+=1
	Vis[n] = true
	--print("Enter",n,"Depth",dfsDepth)
	
	if( #G[n] == 1 ) then
		table.insert(Leafs,{n,dfsDepth - lastIntersectionDepth,p})
	end
	
	if( #G[n] > 2) then
		--print(n,"is an intersection!")
		lastIntersectionDepth = dfsDepth
	end
	
	
	for _,i in G[n] do
		if not Vis[i] then
			dfs(i,n)
		end
	end
	
	dfsDepth-=1
	
	lastIntersectionDepth = prevIntersectionDepth
	--print("Leave",n)
	
end

function GenerateLootAndStructures()
	
	
	
	--[[ PRINT GRAPH
		for ind, i in pairs(G) do
			if ind > W*H then return end
			print("G["..ind.."] = {"..table.concat(i, ", ").."}")
		end
	]]
	
	table.clear(Leafs)
	dfsDepth=0
	lastIntersectionDepth=1
	local startVertex=1
	for i=1, W*H do
		if #G[i] > 2 then
			startVertex=i
			break
		end
		if i==W*H then warn("No Intersections in maze") end
	end
	
	Vis[startVertex] = true
	
	dfs(startVertex,startVertex)
	
	table.sort(Leafs, function(a,b)
		
		return a[2] > b[2]
	end)
	
	for i=1, math.min(#Leafs, MazeSettings.LootBoxAmount) do
		local v = Leafs[i][1]
		if math.random() <= 0.2 then
			local p = LootBoxes.LOOTBOX_RARE:Clone()
			p.Parent = MazeStructure.LootBoxes
			p:PivotTo(CFrame.new(Vertexes[v][1] + Vector3.new(0,p.PrimaryPart.Size.Y/2,0)))
			p:PivotTo(CFrame.lookAt(p.PrimaryPart.Position,(MazeSettings:GetPositionFromVertexID(Leafs[i][3])*Vector3.new(1,0,1)) + Vector3.new(0,p.PrimaryPart.Position.Y,0)))
		else
			local p = LootBoxes.LOOTBOX_COMMON:Clone()
			p.Parent = MazeStructure.LootBoxes
			p:PivotTo(CFrame.new(Vertexes[v][1] + Vector3.new(0,p.PrimaryPart.Size.Y/2,0)))
			p:PivotTo(CFrame.lookAt(p.PrimaryPart.Position,(MazeSettings:GetPositionFromVertexID(Leafs[i][3])*Vector3.new(1,0,1)) + Vector3.new(0,p.PrimaryPart.Position.Y,0)))
		end
		
	end
	
	for i=MazeSettings.LootBoxAmount+1, math.min(#Leafs , MazeSettings.LootBoxAmount + MazeSettings.StructureAmount) do
		print("Generating structure "..i-MazeSettings.LootBoxAmount)
		local v = Leafs[i][1]
		local p = game.ReplicatedStorage.Structures.STRUCTURE_TOWER:Clone()
		p.Parent = MazeStructure.Structures
		p:ScaleTo((MazeSettings.Vertex_distance-1) / 11)   --12 is the size of "small" corridor, and scale = 1 --> tower_width = 11 (corridor width - 1) 
		p:PivotTo(CFrame.new(Vertexes[v][1] + Vector3.new(0,p.PrimaryPart.Size.Y/2,0)))
		p:PivotTo(CFrame.lookAt(p.PrimaryPart.Position,(MazeSettings:GetPositionFromVertexID(Leafs[i][3])*Vector3.new(1,0,1)) + Vector3.new(0,p.PrimaryPart.Position.Y,0)))
	end
	
end

function GenerateStorm()
	local StormModel = game.ReplicatedStorage.MazeGeneration.Assets.StormPart
	local Storm = MazeStructure.Storm
	local SHeight = MazeSettings.Storm_height
	
	local function getDistFromCorner(pos:{IntValue}, corner:{IntValue})
		return 1 + math.abs(pos[1]-corner[1]) + math.abs(pos[2]-corner[2])
	end
	
	local function getStormValue(id)
		local i = (id-1) // W
		local j = (id-1) %  W
		i+=1
		j+=1
		return math.min(
			getDistFromCorner({i,j},{1,1}),
			getDistFromCorner({i,j},{1,W}),
			getDistFromCorner({i,j},{H,1}),
			getDistFromCorner({i,j},{H,W})
		)
		
	end
	
	for vID,i in pairs(Vertexes) do
		local Spos = i[1] + Vector3.new(0,0.05 + SHeight/2,0)
		local StormPart = StormModel:Clone()
		StormPart.Parent = Storm
		StormPart.Size = Vector3.new(MazeSettings.Vertex_distance, SHeight, MazeSettings.Vertex_distance)
		StormPart.Position = Spos
		StormPart.BrickColor = MazeSettings.Storm_color
		
		
		
		local StormCountdown = Instance.new("IntValue")
		StormCountdown.Name = "StormValue"  --DONT CHANGE NAME!
		StormCountdown.Parent = StormPart
		StormCountdown.Value = getStormValue(vID)
		
		
	end

end

function GenerateSpawners()
	local spawner = game.ReplicatedStorage.MazeGeneration.Assets.SpawnTube
	for ind,i in MazeSettings.SpawnPositions do
		local p = spawner:Clone()
		p.Parent = MazeStructure.Spawners
		p.Name = "Spawn"..ind
		p:PivotTo(CFrame.new(MazeSettings:GetPositionFromVertexID(i) + Vector3.new(0,200,0)))
	end
end

function GenerateGrid()
	
	local Vertex_dist = MazeSettings.Vertex_distance
	local StartPos = MazeSettings.Starting_vertex_position
	
	-- Delete Previous Maze
	for i, v in pairs(MazeStructure.Edges:GetChildren()) do                      --
		v:Destroy()
	end
	for i, v in pairs(MazeStructure.Walls:GetChildren()) do                      --
		v:Destroy()
	end
	for i, v in pairs(MazeStructure.Structures:GetChildren()) do                      --
		v:Destroy()
	end
	for i, v in pairs(MazeStructure.LootBoxes:GetChildren()) do                      --
		v:Destroy()
	end
	for i, v in pairs(MazeStructure.Storm:GetChildren()) do                      --
		v:Destroy()
	end
	for i, v in pairs(MazeStructure.Spawners:GetChildren()) do                      --
		v:Destroy()
	end
	for i, v in pairs(MazeStructure.PlayerLoot:GetChildren()) do                      --
		v:Destroy()
	end
	--row = table.create(W, 0)
	--G = table.create(H, row)

	for i=1, W*H do
		Size[i]=1
		Parent[i]=i
		table.clear(G[i])
		Vis[i]=false
	end

	table.clear(Vertexes)
	for i=1, H, 1 do
		for j=1, W, 1 do
			Vertexes[GetVertexID(i,j)] = {Vector3.new(StartPos.X + (i-1)*Vertex_dist, 0, StartPos.Z - (j-1)*Vertex_dist), 0}
		end
	end
	
	-- VertexIDs and (i,j) vertex coords are kinda confusing.
	-- ID's:
	--      3 6 9
	-- ^    2 5 8
	-- Z-   1 4 7
	--    X+ ->
	
	
	--(i,j) coords:
	
 	--     (1,3) (2,3) (3,3)
	-- ^   (1,2) (2,2) (3,2)
	-- Z-  (1,1) (2,1) (3,1)
	--    X+ ->
	
	
	
	
	-- add edges
	table.clear(Edges)
	-- horizontal
	for i=1, H, 1 do
		for j=1, W-1, 1 do
			table.insert(Edges,{GetVertexID(i,j), GetVertexID(i,j+1)})
		end
	end
	-- vertical
	for i=1, W, 1 do
		for j=1, H-1, 1 do
			table.insert(Edges,{GetVertexID(j,i), GetVertexID(j+1,i)})
		end
	end
	
	shuffleTable(Edges)
	
	--should be generated first, cuz players use these
	
	local LooksStyle = "<placeholder>"
	if MazeSettings.Vertex_distance < 16 then      --12
		LooksStyle = "Tiny"
	elseif MazeSettings.Vertex_distance <20  then  --16
		LooksStyle = "Normal"
	elseif MazeSettings.Vertex_distance < 24 then  --20
		LooksStyle = "Wide"
	else                                           --24
		LooksStyle = "Very Wide"
	end
	
	MazeStructure.MapStyleInfo.Value = 'Map Name: "'..MazeSettings.Looks.LooksName..'"  |  Style: '..LooksStyle
	GenerateSpawners()
	
	
	
	GenerateStorm()
	
	GenerateWalls()
	GenerateMaze()
	GenerateFillers()
	
	-- GENERATION ANIMATION
	task.spawn(function()
		local total_time, tick_time = 2, 0.05
		local Edges = MazeStructure.Edges:GetChildren()
		local total = #Edges
		
		local edges_per_tick = math.ceil((total*tick_time)/total_time)
		
		
		for i = 1, total, edges_per_tick do
			for j = 0, math.min(edges_per_tick-1, total-i) do
				Edges[i+j].Transparency = 0
			end
			task.wait(tick_time)
		end
		GenerateLootAndStructures()
	end)
	
	
	
	
end

game:GetService("RunService").Heartbeat:Wait()
GenerateGrid()

EndGameEvent.Event:Once(function()
	print("ENDING GAME")
	MazeStructure:Destroy()
end)
