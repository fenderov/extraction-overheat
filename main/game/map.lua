local Landscape = require "main/game/landscape"
local Building = require "main/game/building"

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

local function armor_to_world(x, y)
	return vmath.vector3(
	(x * TILE_WIDTH / 2 + ARMOR_X_SCALED_OFFSET) * scale + X_OFFSET,
	(y * TILE_HEIGHT / 2 + ARMOR_Y_SCALED_OFFSET) * scale + Y_OFFSET,
	0)
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
		if hex.armor ~= 0 then
			go.animate(hex.armor_id, "scale", go.PLAYBACK_ONCE_FORWARD, scale, go.EASING_OUTBOUNCE, 1)
			go.animate(hex.armor_id, "position", go.PLAYBACK_ONCE_FORWARD, armor_to_world(hex.x, hex.y), go.EASING_OUTBOUNCE, 1)
		end
	end
end

local function recalculate_light()
	for hex in Map.iterate() do
		hex.light = 0
		if hex.building ~= nil then
			if hex.building_active then
				hex.light = hex.building.light_on
			else
				hex.light = hex.building.light_off
			end
		end
		if hex.unit ~= nil and hex.unit.type == "workers" then
			hex.light = 3
		end
	end
	for i = 1, 3 do
		for hex in Map.iterate() do
			for other_hex in Map.iterate() do
				if Map.distance(hex, other_hex) == 1 then
					hex.light = math.max(hex.light, other_hex.light - 1)
				end
			end
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
			armor = 0,
			armor_id = factory.create("#armor_factory", armor_to_world(x, y), nil, nil, scale),
			light = 0
		}
		hexes[Map.coordinates_to_hex[x][y]] = true
	end
	for x, y in circle_coordinates(0) do
		Map.coordinates_to_hex[x][y].visible = true
	end
	for x, y in circle_coordinates(1) do
		Map.coordinates_to_hex[x][y].visible = true
		Map.coordinates_to_hex[x][y].landscape = Landscape.wheat
	end
	for x, y in circle_coordinates(2) do
		Map.coordinates_to_hex[x][y].visible = true
		Map.coordinates_to_hex[x][y].landscape = Landscape.forest
	end
	Map.unit_spawn(Map.coordinates_to_hex[0][0], "workers")
	Map.unit_spawn(Map.coordinates_to_hex[2][2], "barbarians")
	-- Map.building_set(Map.coordinates_to_hex[0][0], Building.center)
end

function Map.distance(hex1, hex2)
	return math.max(math.abs(hex1.x - hex2.x) / 2, math.abs(hex1.y - hex2.y))
end

function Map.get_radius(hex)
	return (math.abs(hex.x) + math.abs(hex.y)) / 2
end

function Map.unit_spawn(hex, type)
	hex.unit = {
		id = factory.create("#unit_factory", unit_to_world(hex.x, hex.y), nil, nil, scale),
		type = type,
		action = true,
	}
end

function Map.unit_move(current, target)
	go.animate(current.unit.id, "position", go.PLAYBACK_ONCE_FORWARD, unit_to_world(target.x, target.y), go.EASING_INOUTSINE, 0.2)
	target.unit = current.unit
	current.unit = nil
end

function Map.unit_destroy(hex)
	go.delete(hex.unit.id)
	hex.unit = nil
end

function Map.building_set(hex, building)
	hex.building = building
	-- DEBUG !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	hex.building_active = true
	-- DEBUG !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	if building.armor ~= nil then
		hex.armor = building.armor
	end
end

function Map.building_destroy(hex)
	hex.building = nil
end

function Map.update()
	recalculate_light()
	for hex in Map.iterate() do
		if hex.visible then
			msg.post(hex.id, "enable")
			local pic
			if hex.building ~= nil then
				pic = hex.building.name
			else
				pic = hex.landscape.name
			end
			if hex.highlighted then
				pic = pic .. "_grey"
			elseif hex.building ~= nil and (not hex.building_active) then
				pic = pic .. "_off"
			end
			msg.post(hex.id, "play_animation", {id = hash(pic)})
			if hex.unit ~= nil then
				msg.post(hex.unit.id, "enable")
				local pic = hex.unit.type
				if not hex.unit.action then
					pic = pic .. "_grey"
				end
				msg.post(hex.unit.id, "play_animation", {id = hash(pic)})
			end

			if hex.armor ~= 0 then
				msg.post(hex.armor_id, "enable")
				msg.post(hex.armor_id, "play_animation", {id = hash("armor" .. tostring(hex.armor))})
			else
				msg.post(hex.armor_id, "disable")
			end
		else
			msg.post(hex.id, "disable")
			if hex.unit ~= nil then
				msg.post(hex.unit.id, "disable")
			end
			msg.post(hex.armor_id, "disable")
		end
	end
end

return Map