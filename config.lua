local Config = {
    asset_path = "assets/",

    tiles = { ---@type Tile[]
        "empty",
        "road",
        "factory",
        "forest",
        "anitkabir",
        "atakule",
        "cso",
        "tech_bridge",
        "house",
        "grand_national_assembly",
    },
    indices = {}, ---@type table<Tile, integer>

    sizes = { ---@type table<Tile, integer>
        road = 1,
        factory = 3,
        forest = 3,
        anitkabir = 7,
        atakule = 5,
        cso = 5,
        tech_bridge = 5,

        house = 2,
        grand_national_assembly = 5,
    },

    pixels = 16,

    starting_money = 22000, ---@type number

    costs = { ---@type table<Tile, number>
        road = 100,
        factory = 10000,
        forest = 450,
        anitkabir = 50000,
        atakule = 30000,
        cso = 30000,
        tech_bridge = 35000,
    },

    chunk_size = 64, ---@type integer
}

for i = 1, #Config.tiles do
    Config.indices[Config.tiles[i]] = i
end

return Config
