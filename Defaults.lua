srslylawlUI = srslylawlUI or {}

srslylawlUI.defaultSettings = {
    party = {
        header = {
            enabled = true,
            position = {"LEFT", 250, 200}
        },
        hp = {
            width = 300, height = 60, minWidthPercent = 0.55
        },
        power = {
            width = 15
        },
        pet = {
            width = 15
        },
        buffs = { anchor = "TOPLEFT", xOffset = -29, yOffset = 0, size = 16, growthDir = "LEFT",
                showCastByPlayer = true, maxBuffs = 5, maxDuration = 60, showDefensives = true, showInfiniteDuration = false, showDefault = true, showLongDuration = false},
        debuffs = { anchor = "BOTTOMLEFT", xOffset = -29, yOffset = 0, size = 16, growthDir = "LEFT", showCastByPlayer = true,
                maxDebuffs = 5, maxDuration = 180, showInfiniteDuration = false, showDefault = true, showLongDuration = false},
        maxAbsorbFrames = 20,
        ccbar = {
            enabled = true,
            width = 100,
            heightPercent = 0.5
        },
        visibility = {
            showArena = true,
            showParty = true,
            showSolo = true,
            showRaid = false,
            showPlayer = true,
        }
    },
    player = {
        playerFrame = {
            enabled = true,
            position = { "TOPRIGHT", nil, "CENTER", -200, -100},
            hp = {
                width = 300, height = 80},
            buffs = { anchor = "TOPLEFT", xOffset = -29, yOffset = 0, size = 32, growthDir = "LEFT", perRow = 5,
                showCastByPlayer = true, maxBuffs = 15, maxDuration = 60, showDefensives = true, showInfiniteDuration = false, showDefault = true, showLongDuration = false},
            debuffs = { anchor = "BOTTOMLEFT", xOffset = -29, yOffset = 0, size = 32, growthDir = "LEFT", perRow = 5, showCastByPlayer = true,
                maxDebuffs = 15, maxDuration = 180, showInfiniteDuration = false, showDefault = true, showLongDuration = false},
            pet = {
                width = 20
            },
            power = {
                width = 15
            },
        },
        targetFrame = {
            enabled = true,
            position = { "TOPLEFT", nil, "CENTER", 200, -100},
            hp = {
                width = 300, height = 80
            },
            buffs = {
                anchor = "TOPLEFT", xOffset = -29, yOffset = 0, size = 32, growthDir = "LEFT", perRow = 5,
                showCastByPlayer = true, maxBuffs = 15, maxDuration = 60, showDefensives = true, showInfiniteDuration = false, showDefault = true, showLongDuration = false},
            debuffs = {
                anchor = "BOTTOMLEFT", xOffset = -29, yOffset = 0, size = 32, growthDir = "LEFT", perRow = 5, showCastByPlayer = true,
                maxDebuffs = 15, maxDuration = 180, showInfiniteDuration = false, showDefault = true, showLongDuration = false},
            power = {
                width = 15
            },
        },
        targettargetFrame = {
            enabled = true,
            position = {"TOPLEFT", nil, "TOPRIGHT", offsetX = 0, offsetY = 0},
            hp = {
                width = 100, height = 50
            },
            power = {
                width = 15
            },
        }
    }
}