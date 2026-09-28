--IMPORTANT! DON'T SET THE VALUES HERE. THEY WILL GET CHANGED IN Workspace/Lobby/STARTING_AREA/MatchStartingArea.spawnMaze()
--IF YOU WANT TO CHANGE THE SETTINGS OF A MAZE, GO TO Workspace/Lobby/STARTING_AREA/MazeSettings1


local MazeSettings = {
	Row_lenght = 15,      --treat it as AMOUNT of Rows (not row length)          (row axis is Z axis, Z-- -> Row++)
	Column_lenght = 15,   --treat it as AMOUNT of Columns (not Column length)    (col axis is X axis, X++ -> Col++)
	Vertex_distance = bit32.lshift(1,4), -- distance between two neighbooring vertexes (recommended power of 2)
	Storm_height = 100,
	Storm_color = BrickColor.new("Magenta"),
	Storm_damage = 9,
	Storm_spawn_delay = 4,  --delay in seconds between next storm cycle
	Storm_start_time = 0,   --time in seconds after which a storm will begin to spawn
	Starting_vertex_position = Vector3.new(0,0,0),
	Max_row_length = 100,
	Max_column_length = 100,
	LootBoxAmount = 30,
	StructureAmount = 2,
	SpawnPositions = {1,10,20,30},  -- vertex id's of spawn positions
	Looks = {
		-- online settings are:
		-- size.Z , Position, Orientation, Parent, Name	
		LooksName = "Default",
		size = Vector3.new(0.5, 12, 0), -- Z axis is (v1-v2).Magnitude
		brickColor = BrickColor.new("Fossil"),
		material = Enum.Material.Metal,
		anchored=true,
	}
}
MazeSettings.__index = MazeSettings

function MazeSettings:GetPositionFromVertexID(vID)
	local row = (vID-1) // self.Row_lenght
	local col = (vID-1) %  self.Row_lenght

	return Vector3.new(
		self.Starting_vertex_position.X + row * self.Vertex_distance,
		25,
		self.Starting_vertex_position.Z - col * self.Vertex_distance
	)
end

return MazeSettings
