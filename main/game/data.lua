local Landscape = require "main/game/landscape"

local state = {
	hexes = {},
	resources = {},
	focus = nil,
	awaiting_target = false,
	selected_action = -1,
	to_build = nil,
	heat = 0,
	up_action = "none",
	down_action = "none",
	coordinates_to_hex = {},
	turn = 0,
}

local Data = {}
local MAP_RADIUS = 4

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
	for hex, _ in pairs(state.hexes) do
		coroutine.yield(hex)
	end
end

function Data.iterate()
	return coroutine.wrap(function() iterate_map_generator() end)
end

function Data.get_resources()
    return state.resources
end

function Data.update_resources(key, value)
	state.resources[key] = state.resources[key] + value
end

function Data.set_resources(key, value)
	state.resources[key] = value
end

function Data.get_focus()
    return state.focus
end

function Data.set_focus(value)
    state.focus = value
end

function Data.get_hex(x, y)
	if state.coordinates_to_hex[x] then
		return state.coordinates_to_hex[x][y]
	end
	return nil
end

function Data.get_awaiting_target()
	return state.awaiting_target
end

function Data.set_awaiting_target(value)
	state.awaiting_target = value
end

function Data.get_to_build()
	return state.to_build
end

function Data.set_to_build(value)
	state.to_build = value
end

function Data.get_selected_action()
	return state.selected_action
end

function Data.set_selected_action(value)
	state.selected_action = value
end

function Data.get_heat()
	return state.heat
end

function Data.set_heat(value)
	state.heat = value
end

function Data.get_up_action()
	return state.up_action
end

function Data.set_up_action(value)
	state.up_action = value
end

function Data.get_down_action()
	return state.down_action
end

function Data.set_down_action(value)
	state.down_action = value
end

function Data.get_turn()
	return state.turn
end

function Data.set_turn(value)
	state.turn = value
end

function Data.generate()
	for i = -MAP_RADIUS * 2, MAP_RADIUS * 2 do
		state.coordinates_to_hex[i] = {}
	end
	for x, y in map_coordinates() do
		if x > -5 and x < 5 then
			state.coordinates_to_hex[x][y] = {
				x = x,
				y = y,
				visible = false,
				highlighted = false,
				landscape = Landscape.empty,
				building = nil,
				building_active = false,
				unit = nil,
				connected = false,
				content = nil,
			}
			state.hexes[state.coordinates_to_hex[x][y]] = true
		end
	end
	for x, y in circle_coordinates(0) do
		state.coordinates_to_hex[x][y].visible = true
		state.coordinates_to_hex[x][y].landscape = Landscape.empty
	end
	for x, y in circle_coordinates(1) do
		state.coordinates_to_hex[x][y].visible = true
		state.coordinates_to_hex[x][y].landscape = Landscape.empty
	end
	for x, y in circle_coordinates(2) do
		state.coordinates_to_hex[x][y].visible = true
		state.coordinates_to_hex[x][y].landscape = Landscape.empty
	end
	for x, y in circle_coordinates(3) do
		if x > -5 and x < 5 then
			state.coordinates_to_hex[x][y].visible = true
			state.coordinates_to_hex[x][y].landscape = Landscape.empty
		end
	end
	for x, y in circle_coordinates(4) do
		if x > -5 and x < 5 then
			state.coordinates_to_hex[x][y].visible = true
			state.coordinates_to_hex[x][y].landscape = Landscape.empty
		end
	end
	Data.get_hex(2, 0).landscape = Landscape.metal
	Data.get_hex(1, 1).landscape = Landscape.metal

	Data.get_hex(2, -2).landscape = Landscape.crystal
	Data.get_hex(-4, 2).landscape = Landscape.crystal
end

return Data