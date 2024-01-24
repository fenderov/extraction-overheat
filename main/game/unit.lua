local Unit = {
	arquebusier = {
        name = "arquebusier",
        health = 1,
        power = 3,
        feats = {
            "shoot",
            "reload",
        },
    },
	swordsman = {
        name = "swordsman",
        health = 3,
        power = 2,
        feats = {
        },
    },
	crossbowman = {
        name = "crossbowman",
        health = 1,
        power = 2,
        feats = {
            shoot = true,
        },
    },
    horse_arquebusier = {
        name = "horse_arquebusier",
        health = 2,
        power = 3,
        feats = {
            shoot = true,
            reload = true,
            fast = true,
        },
    },
    horseman = {
        name = "horseman",
        health = 2,
        power = 2,
        feats = {
            fast = true,
        },
    },
    heavy_horseman = {
        name = "heavy_horseman",
        health = 4,
        power = 2,
        feats = {
            fast = true,
        },
    },
    militia = {
        name = "militia",
        health = 2,
        power = 1,
        feats = {
        },
    },
    cleric = {
        name = "cleric",
        health = 2,
        power = 0,
        feats = {
            healer = true,
        },
    },

    mercenary = {
        name = "mercenary",
        health = 1,
        power = 2,
        feats = {
        },
    },

    warrior = {
        name = "warrior",
        health = 2,
        power = 1,
        feats = {
        },
    },
    elite_warrior = {
        name = "elite_warrior",
        health = 4,
        power = 2,
        feats = {
        },
    },
    archer = {
        name = "archer",
        health = 1,
        power = 1,
        feats = {
            shoot = true,
        },
    },
    horse_archer = {
        name = "horse_archer",
        health = 2,
        power = 1,
        feats = {
            shoot = true,
            fast = true,
        },
    },
    eagle = {
        name = "eagle",
        health = 5,
        power = 2,
        feats = {
        },
    },
    eagle_spirit = {
        name = "eagle_spirit",
        health = 7,
        power = 3,
        feats = {
        },
    },
    shaman = {
        name = "shaman",
        health = 1,
        power = 1,
        feats = {
            healer = true,
        },
    },
}

return Unit
