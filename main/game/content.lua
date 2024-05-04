local Content = {
    solar = {
        name = "solar",
        team = "ally",
        health = 2,
        actions = {
            [0] = {
                type = "move",
                cost = {
                    energy = 1,
                },
                distance = 1,
            },
        },
        production = {
            head = {
                [0] = "heat",
                [1] = "max_energy",
            },
            [0] = {
                [1] = 1,
            },
            [1] = {
                [1] = 1,
            },
            [2] = {
                [1] = 2,
            },
            [3] = {
                [1] = 2,
            },
            [4] = {
                [1] = 3,
            },
        },
        cost = {
            metal = 6,
        }
    },
    cooler = {
        name = "cooler",
        team = "ally",
        health = 2,
        actions = {
            [0] = {
                type = "move",
                cost = {
                    energy = 1,
                },
                distance = 1,
            },
        },
        production = {
            head = {
                [0] = "energy",
                [1] = "cool",
            },
            [1] = {
                [1] = 1,
            },
            [2] = {
                [1] = 2,
            },
            [3] = {
                [1] = 3,
            },
        },
        cost = {
            metal = 4,
        }
    },
    drill = {
        name = "drill",
        team = "ally",
        health = 3,
        actions = {
            [0] = {
                type = "move",
                cost = {
                    energy = 1,
                },
                distance = 1,
            },
        },
        production = {
            head = {
                [0] = "energy",
                [1] = "resource",
                [2] = "temp",
            },
            [1] = {
                [1] = 2,
                [2] = 2,
            },
            [2] = {
                [1] = 3,
                [2] = 3,
            },
            [3] = {
                [1] = 4,
                [2] = 4,
            },
        },
        cost = {
            metal = 6,
        }
    },
    laser = {
        name = "laser",
        team = "ally",
        health = 3,
        actions = {
            [0] = {
                type = "move",
                cost = {
                    energy = 1,
                },
                distance = 1,
            },
            [1] = {
                type = "shoot1",
                cost = {
                    energy = 1,
                    temp = 1,
                },
                distance = 2,
                power = 2,
            },
            [2] = {
                type = "shoot2",
                cost = {
                    energy = 2,
                    temp = 2,
                },
                distance = 2,
                power = 5,
            },
        },
        cost = {
            metal = 6,
        }
    },
    static = {
        name = "static",
        team = "ally",
        health = 4,
        actions = {
            [0] = {
                type = "move",
                cost = {
                    energy = 1,
                },
                distance = 1,
            },
            [1] = {
                type = "splash",
                cost = {
                    energy = 2,
                    temp = 1,
                },
                distance = 1,
                power = 1,
            },
            -- [2] = {
            --     type = "punch",
            --     cost = {
            --         energy = 1,
            --         temp = 1,
            --     },
            --     distance = 1,
            --     power = 3,
            -- },
        },
        cost = {
            metal = 4,
        }
    },
    rocket = {
        name = "rocket",
        team = "ally",
        health = 4,
        actions = {},
    },
    enemy_small = {
        name = "enemy_small",
        team = "enemy",
        health = 1,
        actions = {},
    },
    enemy_middle = {
        name = "enemy_middle",
        team = "enemy",
        health = 3,
        actions = {},
    },
    enemy_large = {
        name = "enemy_large",
        team = "enemy",
        health = 5,
        actions = {},
    },
}

return Content