local Landscape = require "main/game/landscape"
local Building = require "main/game/building"
local Unit = require "main/game/unit"

local TILE_WIDTH = 32
local TILE_HEIGHT = 48
local PLAY_ZONE_PADDING = 10
local SCREEN_WIDTH = 1920
local GUI_PLAY_ZONE_WIDTH = 1300
local GUI_PLAY_ZONE_HEIGHT = 1080
local PLAY_ZONE_WIDTH = GUI_PLAY_ZONE_WIDTH - PLAY_ZONE_PADDING * 2
local PLAY_ZONE_HEIGHT = GUI_PLAY_ZONE_HEIGHT - PLAY_ZONE_PADDING * 2
local X_SCALED_OFFSET = 0
local Y_SCALED_OFFSET = TILE_HEIGHT / 6
local X_OFFSET = 0
local Y_OFFSET = 0
local Z_SCALE = -0.001
local UNIT_X_SCALED_OFFSET = 0
local UNIT_Y_SCALED_OFFSET = TILE_HEIGHT / 6
local ARMOR_X_SCALED_OFFSET = 0
local ARMOR_Y_SCALED_OFFSET = -TILE_HEIGHT / 6

local camera = require "orthographic.camera"

local Map = {}
local scale = 1
Map.coordinates_to_hex = {}
local MAP_RADIUS = 4
local hexes = {}

local function circle_coordinates_generator(r)
	if r == 0 then
		coroutine.yield(0, 0)
	else
		for i = 0, r - 1 do
			coroutine.yield(-2 * r + i, i)
			coroutine.yield(-r + 2 * i, r)
			coroutine.yield(r + i, r - i)
			coroutine.yield(2 * r - i, -i)
			coroutine.yield(r - 2 * i, -r)
			coroutine.yield(-r - i, -r + i)
		end
	end
end

local function circle_coordinates(r)
	return coroutine.wrap(function() circle_coordinates_generator(r) end)
end

local function map_coordinates_generator()
	coroutine.yield(0, 0)
	for r = 1, MAP_RADIUS do
		for i = 0, r - 1 do
			coroutine.yield(-2 * r + i, i)
			coroutine.yield(-r + 2 * i, r)
			coroutine.yield(r + i, r - i)
			coroutine.yield(2 * r - i, -i)
			coroutine.yield(r - 2 * i, -r)
			coroutine.yield(-r - i, -r + i)
		end
	end
end

local function map_coordinates()
	return coroutine.wrap(function() map_coordinates_generator() end)
end

local function iterate_map_generator()
	for hex, _ in pairs(hexes) do
		coroutine.yield(hex)
	end
end

function Map.iterate()
	return coroutine.wrap(function() iterate_map_generator() end)
end

local function world_to_map(v)
	ox = ((v.x - X_OFFSET) / scale - X_SCALED_OFFSET) / TILE_WIDTH * 2
	oy = ((v.y - Y_OFFSET) / scale - Y_SCALED_OFFSET) / TILE_HEIGHT * 2
	tx = math.floor(ox)
	ty = math.floor(oy)
	x = ox - tx
	y = oy - ty
	if (tx + ty) % 2 == 0 then
		if x + 3 * y > 1 then
			tx = tx + 1
			ty = ty + 1
		end
	else
		if -x + 3 * y > 0 then
			ty = ty + 1
		else
			tx = tx + 1
		end
	end
	return tx, ty
end

local function hex_to_world(x, y)
	return vmath.vector3(
	(x * TILE_WIDTH / 2 + X_SCALED_OFFSET) * scale + X_OFFSET,
	(y * TILE_HEIGHT / 2 + Y_SCALED_OFFSET) * scale + Y_OFFSET,
	y * Z_SCALE
)
end

local function unit_to_world(x, y)
	return vmath.vector3(
	(x * TILE_WIDTH / 2 + UNIT_X_SCALED_OFFSET) * scale + X_OFFSET,
	(y * TILE_HEIGHT / 2 + UNIT_Y_SCALED_OFFSET) * scale + Y_OFFSET,
	0)
end


function Map.screen_to_hex(x, y)
	local v = camera.screen_to_world(nil, vmath.vector3(x, y, 0))
	local x, y = world_to_map(v)
	if Map.coordinates_to_hex[x] ~= nil then
		return Map.coordinates_to_hex[x][y]
	else
		return nil
	end
end

function Map.set_radius(r)
	scale = math.min(PLAY_ZONE_WIDTH / TILE_WIDTH / (2 * r + 1), PLAY_ZONE_HEIGHT / TILE_WIDTH / (1.5 * r + 1))
	for hex in Map.iterate() do
		go.animate(hex.id, "scale", go.PLAYBACK_ONCE_FORWARD, scale, go.EASING_OUTBOUNCE, 1)
		go.animate(hex.id, "position", go.PLAYBACK_ONCE_FORWARD, hex_to_world(hex.x, hex.y), go.EASING_OUTBOUNCE, 1)
		if hex.unit ~= nil then
			go.animate(hex.unit.id, "scale", go.PLAYBACK_ONCE_FORWARD, scale, go.EASING_OUTBOUNCE, 1)
			go.animate(hex.unit.id, "position", go.PLAYBACK_ONCE_FORWARD, unit_to_world(hex.x, hex.y), go.EASING_OUTBOUNCE, 1)
		end
	end
end

function Map.generate()
	for i = -MAP_RADIUS * 2, MAP_RADIUS * 2 do
		Map.coordinates_to_hex[i] = {}
	end
	for x, y in map_coordinates() do
		Map.coordinates_to_hex[x][y] = {
			x = x,
			y = y,
			id = factory.create("#hex_factory", hex_to_world(x, y), nil, nil, scale),
			visible = false,
			highlighted = false,
			landscape = Landscape.wheat,
			building = nil,
			building_active = false,
			unit = nil,
			connected = false,
		}
		hexes[Map.coordinates_to_hex[x][y]] = true
	end
	for x, y in circle_coordinates(0) do
		Map.coordinates_to_hex[x][y].visible = true
		Map.coordinates_to_hex[x][y].landscape = Landscape.barren
	end
	for x, y in circle_coordinates(1) do
		Map.coordinates_to_hex[x][y].visible = true
		Map.coordinates_to_hex[x][y].landscape = Landscape.barren
	end
	for x, y in circle_coordinates(2) do
		Map.coordinates_to_hex[x][y].visible = true
		Map.coordinates_to_hex[x][y].landscape = Landscape.barren
	end
	for x, y in circle_coordinates(3) do
		Map.coordinates_to_hex[x][y].visible = true
		Map.coordinates_to_hex[x][y].landscape = Landscape.wheat
	end
	for x, y in circle_coordinates(4) do
		Map.coordinates_to_hex[x][y].visible = true
		Map.coordinates_to_hex[x][y].landscape = Landscape.forest
	end
	Map.building_set(Map.coordinates_to_hex[0][-4], Building.center, "ally")
	Map.building_set(Map.coordinates_to_hex[0][4], Building.aztec_temple, "enemy")
	Map.building_set(Map.coordinates_to_hex[3][1], Building.aztec_village, "enemy")
end

function Map.distance(hex1, hex2)
	return math.max(math.abs(hex1.x - hex2.x) / 2, math.abs(hex1.y - hex2.y))
end

function Map.get_radius(hex)
	return (math.abs(hex.x) + math.abs(hex.y)) / 2
end

function Map.unit_spawn(hex, type, team)
	hex.unit = {
		id = factory.create("#unit_factory", unit_to_world(hex.x, hex.y), nil, nil, scale),
		type = type,
		action = true,
		health = type.health,
		power = type.power,
		team = team,
		need_reload = false,
		fast_action = true,
		enemy_behaviour = "scout",
		enemy_defender_anchor = nil,
	}
end

function Map.unit_move(current, target)
	if current.unit.type.feats.fast ~= nil and current.unit.fast_action then
		current.unit.fast_action = false
	else
		current.unit.action = false
	end
	go.animate(current.unit.id, "position", go.PLAYBACK_ONCE_FORWARD, unit_to_world(target.x, target.y), go.EASING_INOUTSINE, 0.2)
	target.unit = current.unit
	current.unit = nil
end

function Map.unit_fight(current, target, resources)
	current.unit.action = false	
	target.unit.health = math.max(0, target.unit.health - current.unit.power)
	if target.unit.health == 0 then
		Map.unit_destroy(target, resources)
		Map.unit_move(current, target)
	else
		go.animate(current.unit.id, "position", go.PLAYBACK_ONCE_PINGPONG, unit_to_world(target.x, target.y), go.EASING_INOUTSINE, 0.4)
		go.animate(target.unit.id, "position", go.PLAYBACK_ONCE_PINGPONG, unit_to_world(current.x, current.y), go.EASING_INOUTSINE, 0.4)
		current.unit.health = math.max(0, current.unit.health - target.unit.power)
		if current.unit.health == 0 then
			Map.unit_destroy(target, resources)
		end
	end
end

function Map.unit_shoot(current, target, resources)
	current.unit.action = false
	current.unit.need_reload = true
	target.unit.health = math.max(0, target.unit.health - current.unit.power)
	if target.unit.health == 0 then
		Map.unit_destroy(target, resources)
	end
end

function Map.unit_reload(current)
	current.unit.action = false
	current.unit.need_reload = false
end

function Map.unit_heal(current, target)
	current.unit.action = false
	target.unit.health = math.min(target.unit.type.health, target.unit.health + 1)
end

function Map.unit_destroy(hex, resources)
	go.delete(hex.unit.id)
	if hex.unit.team == "enemy" and hex.unit.enemy_behaviour == "defender" then
		local i = hex.unit.enemy_defender_index
		local x = hex.unit.enemy_defender_anchor_x
		local y = hex.unit.enemy_defender_anchor_y
		if Map.coordinates_to_hex[x][y].building ~= nil then
			Map.coordinates_to_hex[x][y].building.defenders[i] = nil
		end
	end
	if hex.unit.team == "ally" then
		resources.human = resources.human - 1
	end
	hex.unit = nil
end

function Map.unit_building_destroy(hex, resources)
	if hex.building.human ~= nil and hex.building.team == "ally" then
		resources.human_free = resources.human_free + hex.building.human
	end
	hex.unit.action = false
	Map.building_destroy(hex)
end

local function set_connected(hex)
	hex.connected = true
	for other in Map.iterate() do
		if Map.distance(hex, other) == 1 and not other.connected and other.building ~= nil and other.building.team == "ally" then
			set_connected(other)
		end
	end
end

local function recalculate_connected()
	for hex in Map.iterate() do
		hex.connected = false
	end
	for hex in Map.iterate() do
		if hex.building ~= nil and hex.building.type.is_center and not hex.connected then
			set_connected(hex)
		end
	end
end

local function building_update_production(hex)
	if hex.building.human ~= nil and hex.building.type.production ~= nil and hex.building.type.production[hex.building.human] ~= nil then
		hex.building.production = hex.building.type.production[hex.building.human]
	else
		hex.building.production = {}
	end
end

function Map.building_set(hex, building, team)
	hex.building = {
		type = building,
		team = team,
		human = 0,
		production = {},
		-- DEBUG !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		active = true,
		-- DEBUG !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	}
	building_update_production(hex)
	recalculate_connected()
end

function Map.building_destroy(hex)
	hex.building = nil
	recalculate_connected()
end

function Map.building_set_human(hex, value, resources)
	if hex.building == nil or hex.building.type.cells == nil or hex.building.type.cells < value then
		return
	end
	local old = hex.building.human
	if hex.building.human == value then
		hex.building.human = 0
	else
		hex.building.human = value
	end
	if hex.building.human - old > resources.human_free then
		hex.building.human = old
		return
	end
	building_update_production(hex)
end

function Map.update()
	for hex in Map.iterate() do
		if hex.visible then
			msg.post(hex.id, "enable")
			local pic
			if hex.building ~= nil then
				pic = hex.building.type.name
			else
				pic = hex.landscape.name
			end
			local highlight_front_url = msg.url(nil, hex.id, "highlight_front")
			if hex.highlighted then
				msg.post(highlight_front_url, "enable")
			else
				msg.post(highlight_front_url, "disable")
			end
			local hex_sprite_url = msg.url(nil, hex.id, "sprite")
			msg.post(hex_sprite_url, "play_animation", {id = hash(pic)})
			if hex.unit ~= nil then
				msg.post(hex.unit.id, "enable")
				local pic = hex.unit.type.name
				if not hex.unit.action then
					--pic = pic .. "_grey"
				end
				msg.post(hex.unit.id, "play_animation", {id = hash(pic)})
			end
		else
			msg.post(hex.id, "disable")
			if hex.unit ~= nil then
				msg.post(hex.unit.id, "disable")
			end
		end
	end
end

return Map