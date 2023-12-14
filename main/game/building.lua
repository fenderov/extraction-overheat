local Building = {
	house = {
		name = "house",
		cost = {
			wood = 4
		},
		importance = 1
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
		importance = 1
	},
	sawmill = {
		name = "sawmill",
		production = {
			wood = 1
		},
		cost = {
			wood = 4
		},
		importance = 1
	},
	quarry = {
		name = "quarry",
		production = {
			stone = 1
		},
		cost = {
			wood = 4
		},
		importance = 1
	},
	center = {
		name = "center",
		production = {
			food = 1,
			wood = 1
		},
		build_options = {
			"center2"
		},
		importance = 2
	},
	center2 = {
		name = "center2",
		production = {
			food = 1,
			wood = 1
		},
		build_options = {
			"center3"
		},
		cost = {
			wood = 8
		},
		importance = 2
	},
	center3 = {
		name = "center3",
		production = {
			food = 1,
			wood = 1
		},
		cost = {
			wood = 16
		},
		importance = 2
	}
}

return Building
