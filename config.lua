Config = {}

Config.Mode = 'ox_target' -- 'ox_target' or 'standalone'
Config.Debug = false

Config.OxTarget = {
    Icon = 'fa-solid fa-elevator',
    Label = 'Use elevator',
    Distance = 2.0,
}

Config.Standalone = {
    Key = 38, -- INPUT_PICKUP (E)
    HelpText = '[E] Use elevator',
    DrawMarker = true,
    MarkerType = 2,
    MarkerSize = { x = 0.4, y = 0.4, z = 0.4 },
    MarkerColor = { r = 120, g = 120, b = 255, a = 180 },
    MarkerDistance = 15.0,
    InteractDistance = 1.5,
}

Config.Elevators = {
    -- main_tower = {
    --     label = 'Main Tower Elevator',
    --     point = {
    --         coords = { x = 0.0, y = 0.0, z = 0.0 },
    --         size = { x = 1.2, y = 1.2, z = 2.0 },
    --         rotation = 0.0,
    --         debug = false,
    --     },
    --     floors = {
    --         { id = '12', label = '12F', order = 12, coords = vector4(0.0, 0.0, 0.0, 0.0) },
    --         { id = '11', label = '11F', order = 11, coords = vector4(0.0, 0.0, 0.0, 0.0) },
    --         { id = '10', label = '10F', order = 10, coords = vector4(0.0, 0.0, 0.0, 0.0) },
    --         { id = '9',  label = '9F',  order = 9,  coords = vector4(0.0, 0.0, 0.0, 0.0) },
    --         { id = '8',  label = '8F',  order = 8,  coords = vector4(0.0, 0.0, 0.0, 0.0) },
    --         { id = '7',  label = '7F',  order = 7,  coords = vector4(0.0, 0.0, 0.0, 0.0) },
    --         { id = '6',  label = '6F',  order = 6,  coords = vector4(0.0, 0.0, 0.0, 0.0) },
    --         { id = '5',  label = '5F',  order = 5,  coords = vector4(0.0, 0.0, 0.0, 0.0) },
    --         { id = '4',  label = '4F',  order = 4,  coords = vector4(0.0, 0.0, 0.0, 0.0) },
    --         { id = '3',  label = '3F',  order = 3,  coords = vector4(0.0, 0.0, 0.0, 0.0) },
    --         { id = '2',  label = '2F',  order = 2,  coords = vector4(0.0, 0.0, 0.0, 0.0) },
    --         { id = '1',  label = '1F',  order = 1,  coords = vector4(0.0, 0.0, 0.0, 0.0) },
    --         { id = 'B1', label = 'B1',  order = 0,  coords = vector4(0.0, 0.0, 0.0, 0.0) },
    --         { id = 'B2', label = 'B2',  order = -1, coords = vector4(0.0, 0.0, 0.0, 0.0) },
    --         { id = 'BELL', label = 'BELL', order = -2 },
    --     },
    -- },

    main_tower = {
        label = 'Main Tower Elevator',
        floors = {
            {
                id = '3',
                label = '3F',
                order = 3,
                coords = vector4(136.20, -761.77, 242.15, 157.82),
                point = {
                    coords = vector3(136.68, -763.05, 242.15),
                    size = { x = 1.2, y = 1.2, z = 2.0 },
                    rotation = 0.0,
                    debug = false,
                },
            },
            {
                id = '2',
                label = '2F',
                order = 2,
                coords = vector4(136.20, -761.77, 234.15, 157.82),
                point = {
                    coords = vector3(136.61, -763.01, 234.15),
                    size = { x = 1.2, y = 1.2, z = 2.0 },
                    rotation = 0.0,
                    debug = false,
                },
            },
            {
                id = '1',
                label = '1F',
                order = 1,
                coords = vector4(136.25, -761.87, 45.75, 162.00),
                point = {
                    coords = vector3(136.61, -763.03, 45.75),
                    size = { x = 1.2, y = 1.2, z = 2.0 },
                    rotation = 0.0,
                    debug = false,
                },
            },
            { id = 'BELL', label = 'BELL', order = -2 },
        },
    },
}
