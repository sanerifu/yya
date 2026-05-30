local Tile = {
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
}

for i = 1, #Tile.tiles do
    Tile.indices[Tile.tiles[i]] = i
end

return Tile
