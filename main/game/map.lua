local Landscape = require "main/game/landscape"
local Building = require "main/game/building"
local Unit = require "main/game/unit"
local Data = require "main/game/data"

local TILE_WIDTH = 32
local TILE_HEIGHT = 48
local PLAY_ZONE_PADDING = 10
local SCREEN_WIDTH = 1920
local GUI_PLAY_ZONE_WIDTH = 1080
local GUI_PLAY_ZONE_HEIGHT = 1300
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
	return Data.get_hex(x, y)
end

function Map.set_radius(r)
	scale = math.min(PLAY_ZONE_WIDTH / TILE_WIDTH / (2 * r + 1), PLAY_ZONE_HEIGHT / TILE_WIDTH / (1.5 * r + 1))
	scale = 3
	for hex in Data.iterate() do
		go.animate(hex.id, "scale", go.PLAYBACK_ONCE_FORWARD, scale, go.EASING_OUTBOUNCE, 1)
		go.animate(hex.id, "position", go.PLAYBACK_ONCE_FORWARD, hex_to_world(hex.x, hex.y), go.EASING_OUTBOUNCE, 1)
		if hex.unit ~= nil then
			go.animate(hex.unit.id, "scale", go.PLAYBACK_ONCE_FORWARD, scale, go.EASING_OUTBOUNCE, 1)
			go.animate(hex.unit.id, "position", go.PLAYBACK_ONCE_FORWARD, unit_to_world(hex.x, hex.y), go.EASING_OUTBOUNCE, 1)
		end
	end
end

function Map.generate()
	Data.generate()
	for hex in Data.iterate() do
		hex.id = factory.create("#hex_factory", hex_to_world(hex.x, hex.y), nil, nil, scale)
	end
end

function Map.distance(hex1, hex2)
	local dx = math.abs(hex1.x - hex2.x)
	local dy = math.abs(hex1.y - hex2.y)
	return math.max(dy, (dx + dy) / 2)
end

function Map.get_radius(hex)
	local ax = math.abs(hex.x)
	local ay = math.abs(hex.y)
	return math.max(ay, (ax + ay) / 2)
end

function Map.content_set(hex, type)
	hex.content = {
		id = factory.create("#content_factory", unit_to_world(hex.x, hex.y), nil, nil, scale),
		type = type,
		action = false,
		health = type.health,
		power = 0,
		temp = 0,
	}
end

function Map.content_destroy(hex)
	go.delete(hex.content.id)
	if hex.content.type.name == "rocket" then
		msg.post("gui", hash("game_over"))
	end
	hex.content = nil
end

function Map.content_damage(hex, damage)
	hex.content.health = math.max(0, hex.content.health - damage)
end

function Map.content_move(current, target)
	go.animate(current.content.id, "position", go.PLAYBACK_ONCE_FORWARD, unit_to_world(target.x, target.y), go.EASING_INOUTSINE, 0.2)
	if target.content then
		Map.content_destroy(target)
	end
	if current.content.type.name ~= "solar" then
		Data.update_resources("energy", current.content.power)
		current.content.power = 0
	end
	target.content = current.content
	current.content = nil
end

function Map.content_attack(current, target, damage)
	Map.content_damage(target, damage)
	if target.content.health == 0 then
		Map.content_destroy(target)
		Map.content_move(current, target)
	else
		go.animate(current.content.id, "position", go.PLAYBACK_ONCE_PINGPONG, unit_to_world(target.x, target.y), go.EASING_INOUTSINE, 0.4)
	end
end

function Map.content_punch(current, target, damage)
	Map.content_damage(target, damage)
	go.animate(current.content.id, "position", go.PLAYBACK_ONCE_PINGPONG, unit_to_world(target.x, target.y), go.EASING_INOUTSINE, 0.4)
	if target.content.health == 0 then
		Map.content_destroy(target)
	end
end

function Map.content_splash(current, targets, damage)
	for _, target in pairs(targets) do
		Map.content_damage(target, damage)
		if target.content.health == 0 then
			Map.content_destroy(target)
		end
	end
end

function Map.content_shoot(current, target, damage)
	Map.content_damage(target, damage)
	if target.content.health == 0 then
		Map.content_destroy(target)
	end
end

function Map.content_norm_temp(hex)
	if hex.content then
		hex.content.temp = math.max(0, hex.content.temp)
		hex.content.temp = math.min(4, hex.content.temp)
	end
end

function Map.content_apply_temp(hex)
	if hex.content.temp >= 4 then
		Map.content_damage(hex, 1)
	end
	if hex.content.health == 0 then
		Map.content_destroy(hex)
	end
end


function Map.is_move_target(target)
	return Map.distance(Data.get_focus(), target) == 1 and target.content == nil
end

function Map.is_shoot_target(target)
	return Map.distance(Data.get_focus(), target) <= 2 and target.content ~= nil and target.content.type.team == "enemy"
end

function Map.is_splash_target(target)
	return Map.distance(Data.get_focus(), target) == 1 and target.content ~= nil and target.content.type.team == "enemy"
end

function Map.is_build_target(target)
	return Map.distance(Data.get_focus(), target) == 1 and target.content == nil
end

local function is_highlighted(hex)
	if not Data.get_awaiting_target() and hex == Data.get_focus() and Data.get_selected_action() == -1 and Data.get_to_build() == nil then
		return true
	end
	if not Data.get_awaiting_target() or not Data.get_focus() then
		return false
	end
	local name = ""
	if Data.get_selected_action() == -1 then
		name = "build"
	else
		name = Data.get_focus().content.type.actions[Data.get_selected_action()].type
	end
	if Map.is_build_target(hex) and Data.get_to_build() then
		return true
	end
	if Map.is_shoot_target(hex) and (name == "shoot1" or name == "shoot2") then
		return true
	end
	if Map.is_splash_target(hex) and name == "splash" then
		return true
	end
	if Map.is_move_target(hex) and name == "move" then
		return true
	end
	return false
end

function Map.update()
	for hex in Data.iterate() do
		if hex.visible then
			msg.post(hex.id, "enable")
			local pic = hex.landscape.name .. tostring(Data.get_heat())
			local highlight_front_url = msg.url(nil, hex.id, "highlight_front")
			if is_highlighted(hex) then
				msg.post(highlight_front_url, "enable")
			else
				msg.post(highlight_front_url, "disable")
			end
			local hex_sprite_url = msg.url(nil, hex.id, "sprite")
			msg.post(hex_sprite_url, "play_animation", {id = hash(pic)})
			if hex.content ~= nil then
				local pic = hex.content.type.name
				local health_pic = "healthbar_".. hex.content.health .."_0"
				local content_sprite_url = msg.url(nil, hex.content.id, "sprite")
				msg.post(content_sprite_url, "play_animation", {id = hash(pic)})
				local content_healthbar_url = msg.url(nil, hex.content.id, "healthbar")
				msg.post(content_healthbar_url, "play_animation", {id = hash(health_pic)})
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