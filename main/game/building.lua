local Building = {
	house = {
		name = "house",
		cost = {
			wood = 4
		},
	},
	farm = {
		name = "farm",
		cells = 3,
		production = {
			type = "food",
			[2] = {
				food = 3,
			},
			[3] = {
				food = 4,
			},
		},
		cost = {
			wood = 4
		}
	},
	sawmill = {
		name = "sawmill",
		cells = 3,
		production = {
			type = "wood",
			[2] = {
				wood = 1,
			},
			[3] = {
				wood = 2,
			},
		},
		cost = {
			wood = 4
		},
	},
	center = {
		name = "center",
		production = {
			[0] = {
				food = 1,
				wood = 1,
			},
		},
		is_center = true,
	},
	road = {
		name = "road",
		cost = {
			wood = 1
		},
	},
	armory = {
		name = "armory",
		cost = {
			wood = 6
		},
		actions = {
			hire_unit_militia = {
				cost = {
					wood = 1,
					human_free = 1,
				},
				unit = "militia",
				title = "Hire militia (w1 h1)"
			}
		}
	},
	tower = {
		name = "tower",
		cost = {
			wood = 6
		},
		actions = {
			hire_unit_crossbowman = {
				cost = {
					wood = 1,
					human_free = 1,
				},
				unit = "crossbowman",
				title = "Hire crossbowman (w1 h1)"
			}
		}
	},
	church = {
		name = "church",
		cost = {
			wood = 6
		},
		actions = {
			hire_unit_cleric = {
				cost = {
					wood = 1,
					human_free = 1,
				},
				unit = "cleric",
				title = "Hire cleric (h1)"
			}
		}
	},

	aztec_temple = {
		name = "aztec_temple",
		enemy_defence = {
			size = 3,
			[1] = {
				name = "elite_warrior",
				time = 4,
			},
			[2] = {
				name = "archer",
				time = 2,
			},
			[3] = {
				name = "shaman",
				time = 3,
			},
		},
		enemy_offence = {
			size = 1,
			[1] = {
				name = "warrior",
				time = 7,
			},
		}
	},

	aztec_village = {
		name = "aztec_village",
		enemy_defence = {
			size = 1,
			[1] = {
				name = "warrior",
				time = 5,
			},
		},
		enemy_offence = {
			size = 1,
			[1] = {
				name = "warrior",
				time = 9,
			},
		}
	}
}

return Building
