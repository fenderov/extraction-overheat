local Building = {
	house = {
		name = "house",
		cost = {
			wood = 4
		},
		importance = 1,
		light_on = 2,
		light_off = 2,
	},
	farm = {
		name = "farm",
		production = {
			food = 1
		},
		cost = {
			wood = 4
		},
		build_options = {
			"sawmill"
		},
		importance = 1,
		light_on = 3,
		light_off = 2,
	},
	sawmill = {
		name = "sawmill",
		production = {
			wood = 1
		},
		cost = {
			wood = 4
		},
		importance = 1,
		light_on = 3,
		light_off = 2,
	},
	center = {
		name = "center",
		production = {
			food = 1,
			wood = 1,
			stone = 10
		},
		importance = 2,
		armor = 3,
		light_on = 3,
		light_off = 2,
	},
	fortress = {
		name = "fortress",
		cost = {
			stone = 4
		},
		importance = 0,
		light_on = 3,
		light_off = 2,
	}
}

return Building
