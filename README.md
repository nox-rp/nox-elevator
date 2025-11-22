# nox-elevator

A simple elevator system resource for FiveM. It lets you create multi-floor elevators with a small amount of configuration and move between floors using a NUI menu.

## Features

- **NUI elevator menu**  
  Shows a list of available floors in the UI and teleports the player to the selected floor.

- **Two interaction modes**  
  - `ox_target` mode: use `ox_target` box zones for interaction.  
  - `standalone` mode: uses a 3D marker and 3D help text (E key prompt) with no external dependency.

- **Flexible floor and coordinate configuration**  
  Configure floor IDs, labels, target coordinates (`vector3` / `vector4` / tables / comma-separated strings) per elevator only through `config.lua`.

- **BELL button support**  
  If you add a floor with `id = 'BELL'`, a bell button appears in the UI. When pressed, the client triggers the server event `nox-elevator:bell`, which you can handle for notifications, logs, sounds, etc.

---

## Installation

1. Copy the resource into your server resources folder.
   - Example: `resources/[nox]/nox-elevator`
2. Add the resource to your server config (such as `server.cfg`).
   ```cfg
   ensure [nox]
   ensure nox-elevator
   ```
3. Restart the server or start the resource manually.

---

## Usage

### 1) Common configuration

1. Define elevators inside the `Config.Elevators` table in `config.lua`.  
2. Each elevator is identified by a unique key (for example `main_tower`) and contains a `floors` array.  
3. Each floor can have the following fields:
   - `id`: floor ID string (for example `'1'`, `'2'`, `'3'`, `'B1'`, `'BELL'`).
   - `label`: label shown in the UI (for example `"1F"`, `"B1"`).
   - `order`: numeric value used to sort floors (higher floors usually have larger values).
   - `coords`: teleport destination (`vector4` recommended, `x, y, z, heading`).
   - `point` (optional): interaction point information
     - `coords`: interaction coordinates (`vector3`).
     - `size`, `rotation`, `debug`, etc.

### 2) ox_target mode

1. Set the mode to `ox_target` in `config.lua`.
   ```lua
   Config.Mode = 'ox_target'
   ```
2. Make sure the `ox_target` resource is properly installed and running on the server.  
3. When a player approaches a configured interaction point, an `ox_target` option appears and selecting it opens the elevator NUI menu.
4. Selecting a floor in the menu teleports the player to the configured coordinates.

### 3) standalone mode

1. Set the mode to `standalone` in `config.lua`.
   ```lua
   Config.Mode = 'standalone'
   ```
2. If a `point` is configured for a floor, a marker is drawn at that location and nearby players see 3D help text like `[E] Use elevator` (or your custom text).
3. When the player presses the configured key (default `E`, control code 38), the elevator menu opens.

---

## Example config.lua

Below is an example based on the default `config.lua` included with this resource.

```lua
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
```

---

## BELL floor server event example

If you add a floor with `id = 'BELL'` under `Config.Elevators`, pressing the bell button in the UI sends the following event from the client to the server:

- Event name: `nox-elevator:bell`
- Argument: `elevatorId` (for example `"main_tower"`)

You can handle this event in any server script like this:

```lua
RegisterNetEvent('nox-elevator:bell', function(elevatorId)
    print(('[nox-elevator] Bell pressed in elevator: %s'):format(elevatorId))
    -- TODO: Implement your own notification, sound, logging, etc. here.
end)
```
