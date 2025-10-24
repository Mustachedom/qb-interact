# QB-Interact

## Description
A quick and seamless alternative to the classic "Press E" interaction system.  
It uses a data structure similar to **qb-target** and allows easier implementation of **multiple interaction options per zone**.

---

## Installation

### Step 1:
- Drag and Drop into your `resources` folder.

### Step 2:
- Party 🎉

---

## Exports

## Options Table

Each zone can contain one or more **interaction options**, allowing multiple contextual choices for the player.

| Key | Required | Type | Description |
|:----|:----------|:------|:-------------|
| `label` | ✅ | string | Text displayed in the UI for the option. |
| `event` | ❌ | string | Event name to trigger when selected. |
| `type` | ❌ | string | `"client"` or `"server"` — determines where the event is fired. |
| `action` | ❌ | function | Direct function to execute instead of an event. |
| `args` | ❌ | table | Arguments passed to the event or action. |
| `item` | ❌ | string | Requires the player to have a specific item. |
| `job` | ❌ | string / table | Restricts access to one or more job names. |
| `gang` | ❌ | string / table | Restricts access to one or more gang names. |
| `citizenid` | ❌ | string / table | Restricts access to specific player citizen IDs. |
| `canInteract` | ❌ | function | Optional conditional function. Must return `true` for option to appear. |

---

### `addInteractZone(interactData)`
Adds an interactable zone at specified coordinates with given options.

| Value | Required | Type | Default | Description |
|:------|:----------|:------|:----------|:-------------|
| `name` | ✅ | string | n/a | Unique identifier for the zone. |
| `coords` | ✅ | vector3 / vector4 | n/a | Center coordinates of the zone. |
| `length` | ❌ | number | `2.0` | Length of the interaction zone. |
| `width` | ❌ | number | `2.0` | Width of the interaction zone. |
| `height` | ❌ | number | `2.0` | Height of the interaction zone (used for Z bounds). |
| `options` | ✅ | table | n/a | Table of interaction options (see below). |



#### Example
```lua
exports['qb-interact']:addInteractZone({
    name = "atm_zone",
    coords = vector4(147.24, -1035.73, 29.34, 340.0),
    length = 1.5,
    width = 1.5,
    options = {
        {
            label = "Use ATM",
            event = "bank:open",
            type = "client"
        },
        {
            label = "Hack ATM",
            event = "atm:hack",
            type = "server",
            job = {"hacker"}
        },
        {
          label = "This Is An Example",
          item = 'lockpick',
          job = {'police', 'ambulance', 'mechanic'},
          gang = 'ballas',
          citizenid = {'ABC1234'},
          -- this option will only show IF you have a lockpick, are in the ballas, if your citizenid is ABC1234 and if you are a police, ambulance or mechanic job. if one fails 
          -- you will not be shown this option
        }
    }
})
```

---

### `addEntityZone(entity, zoneOptions)`
Adds an interactable zone attached to a specific **entity** with given options.

| Value | Required | Type | Default | Description |
|:------|:----------|:------|:----------|:-------------|
| `entity` | ✅ | number | n/a | The entity handle to attach the zone to. |
| `zoneOptions` | ✅ | table | n/a | Same structure as `addInteractZone` (see above). |

---

### `removeInteractZones(name)`
Removes an interactable zone by name for the current resource.

| Value | Required | Type | Description |
|:------|:----------|:------|:-------------|
| `name` | ✅ | string | The name of the interact zone to remove. |

---

### `addObjectModel(model, zoneOptions)`
Adds interactable zones to all **objects** that match the specified model.

| Value | Required | Type | Description |
|:------|:----------|:------|:-------------|
| `model` | ✅ | string | The model name to apply zones to. |
| `zoneOptions` | ✅ | table | Same structure as `addInteractZone`. |

---

### `addPedModel(model, zoneOptions)`
Adds interactable zones to all **peds** matching the specified model.

| Value | Required | Type | Description |
|:------|:----------|:------|:-------------|
| `model` | ✅ | string | The ped model name to apply zones to. |
| `zoneOptions` | ✅ | table | Same structure as `addInteractZone`. |

---


## Notes

- Press **Arrow Up / Down** to scroll options.  
- Press **E** or **Enter** to select.  
- Press **Backspace / Esc** to close the UI.  
- Zones automatically clean up when a resource stops.

---


**Created with ❤️ for the QB-Core Framework**
