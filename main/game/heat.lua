local Heat = {
    [0] = {
        heat = 0,
        enemy = {
            small = 0,
            middle = 0,
            large = 0
        }
    },
    [5] = {
        heat = 1,
        enemy = {
            small = 3,
            middle = 0,
            large = 0
        }
    },
    [10] = {
        heat = 2,
        enemy = {
            small = 4,
            middle = 1,
            large = 0
        }
    },
    [15] = {
        heat = 3,
        enemy = {
            small = 3,
            middle = 2,
            large = 1
        }
    },
    [20] = {
        heat = 4,
        enemy = {
            small = 0,
            middle = 3,
            large = 5
        }
    },
    ENEMY_SPAWN_ZONE = {
        [0] = {
            x = -4,
            y = 4
        },
        [1] = {
            x = -2,
            y = 4
        },
        [2] = {
            x = 0,
            y = 4
        },
        [3] = {
            x = 2,
            y = 4
        },
        [4] = {
            x = 4,
            y = 4
        },
        [5] = {
            x = -4,
            y = -4
        },
        [6] = {
            x = -2,
            y = -4
        },
        [7] = {
            x = 0,
            y = -4
        },
        [8] = {
            x = 2,
            y = -4
        },
        [9] = {
            x = 4,
            y = -4
        },
        size = 10,
    }
}

return Heat