srslylawlUI = srslylawlUI or {}

srslylawlUI.defaultSettings = {
    party = {
        header = {
            enabled = true,
            position = {"LEFT", 250, 200}
        },
        hp = {
            width = 300, height = 60, minWidthPercent = 0.55, fontSize = 12
        },
        power = {
            width = 15
        },
        pet = {
            width = 15
        },
        buffs = { anchor = "TOPLEFT", anchoredTo = "Frame", xOffset = -29, yOffset = 0, size = 16, scaledSize = 32, growthDir = "LEFT",
                showCastByPlayer = true, maxBuffs = 5, maxDuration = 60, showDefensives = true, showInfiniteDuration = false, showDefault = true, showLongDuration = false},
        debuffs = { anchor = "BOTTOMLEFT", anchoredTo = "Frame", xOffset = -29, yOffset = 0, size = 16, scaledSize = 32, growthDir = "LEFT", showCastByPlayer = true,
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
            position = { "TOPRIGHT", "Screen", "CENTER", -200, -100},
            hp = {
                width = 300, height = 70, fontSize = 12
            },
            buffs = { anchor = "TOPLEFT", anchoredTo = "Frame", xOffset = 0, yOffset = 0, size = 32, maxBuffs = 40
            },
            debuffs = { anchor = "BOTTOMLEFT", anchoredTo = "Buffs", xOffset = 0, yOffset = 0, size = 32, maxDebuffs = 40
            },
            pet = {
                width = 20
            },
            power = {
                width = 15
            },
        },
        targetFrame = {
            enabled = true,
            position = { "TOPLEFT", "Screen", "CENTER", 200, -100},
            hp = {
                width = 300, height = 70, fontSize = 12
            },
            buffs = {
                anchor = "TOPLEFT", anchoredTo = "Frame", xOffset = 0, yOffset = 0, size = 32, maxBuffs = 40
            },
            debuffs = {
                anchor = "BOTTOMLEFT", anchoredTo = "Buffs", xOffset = 0, yOffset = 0, size = 32, maxDebuffs = 40
            },
            power = {
                width = 15
            },
        },
        targettargetFrame = {
            enabled = true,
            position = {"TOPLEFT", "TargetFramePortrait", "TOPRIGHT", 0, 0},
            hp = {
                width = 150, height = 70, fontSize = 12
            },
            power = {
                width = 15
            },
        }
    }
}