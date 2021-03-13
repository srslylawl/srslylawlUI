srslylawlUI = srslylawlUI or {}

srslylawlUI.defaultSettings = {
    party = {
        header = {
            enabled = true,
            position = { "LEFT", "Screen", "LEFT", 100, 100},
        },
        hp = {
            width = 300, height = 60, minWidthPercent = 0.55, fontSize = 12
        },
        power = {
            width = 15,
            text = true
        },
        pet = {
            width = 15
        },
        buffs = { anchor = "TOPLEFT", anchoredTo = "Frame", xOffset = 7, yOffset = -50, size = 27, scaledSize = 0,
            showCastByPlayer = true, maxBuffs = 5, maxDuration = 60, showDefensives = true, showInfiniteDuration = false, showDefault = false, showLongDuration = false },
        debuffs = { anchor = "LEFTTOP", anchoredTo = "Frame", xOffset = -20, yOffset = 0, size = 27, scaledSize = 0, 
            showCastByPlayer = true, maxDebuffs = 10, maxDuration = 180, showInfiniteDuration = false, showDefault = true, showLongDuration = false },
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
        },
        sorting = {
            enabled = true,
        }
    },
    player = {
        playerFrame = {
            enabled = true,
            position = { "TOPRIGHT", "Screen", "CENTER", -200, -100},
            hp = {
                width = 300, height = 70, fontSize = 6
            },
            buffs = { anchor = "TOPRIGHT", anchoredTo = "Frame", xOffset = 0, yOffset = 0, size = 20, scaledSize = 10, maxBuffs = 25,
                showCastByPlayer = true, maxDuration = 60, showDefensives = true, showInfiniteDuration = true, showDefault = true, showLongDuration = true
            },
            debuffs = { anchor = "BOTTOMLEFT", anchoredTo = "Buffs", xOffset = 0, yOffset = 0, size = 20, scaledSize = 10, maxDebuffs = 15,
                showCastByPlayer = true, maxDuration = 180, showInfiniteDuration = true, showDefault = true, showLongDuration = true
            },
            pet = {
                width = 20
            },
            power = {
                text = false,
                fontSize = 6,
                overrides = {
                }
            },
            cast = {
                disabled = false,
                fontSize = 10,
                height = 40,
                priority = 0
            },
        },
        targetFrame = {
            enabled = true,
            position = { "TOPLEFT", "Screen", "CENTER", 200, -100},
            hp = {
                width = 300, height = 70, fontSize = 6
            },
            buffs = {
                anchor = "TOPLEFT", anchoredTo = "Frame", xOffset = 0, yOffset = 0, size = 20, scaledSize = 10, maxBuffs = 25,
                showCastByPlayer = true, maxDuration = 60, showDefensives = true, showInfiniteDuration = true, showDefault = true, showLongDuration = true
            },
            debuffs = {
                anchor = "BOTTOMLEFT", anchoredTo = "Buffs", xOffset = 0, yOffset = 0, size = 20, scaledSize = 10, maxDebuffs = 40,
                showCastByPlayer = true, maxDuration = 180, showInfiniteDuration = true, showDefault = true, showLongDuration = true
            },
            power = {
                width = 15,
                position = "LEFT",
                text = true
            },
            cast = {
                disabled = false,
                fontSize = 10,
                height = 40,
                priority = 0
            },
            ccbar = {
                disabled = false,
                height = 20,
                priority = 1,
            },
            portrait = {
                enabled = true,
                position = "RIGHT",
                anchor = "Frame"
            },
            unitLevel = {
                position = { "CENTER", "TargetFramePortrait", "BOTTOMRIGHT", 0, 2}
            }
        },
        targettargetFrame = {
            enabled = true,
            position = {"TOPLEFT", "TargetFramePortrait", "TOPRIGHT", 0, 0},
            hp = {
                width = 150, height = 70, fontSize = 12
            },
            power = {
                width = 15,
                text = true
            },
        }
    },
    blizzard = {
        player = {enabled = false},
        target = {enabled = false},
        party = {enabled = false},
        auras = { enabled = false},
        castbar = {enabled = false}
    },
    colors = {
        buffBaseColor = {0.960, 0.952, 0.760},
        buffIsStealableColor = {0.760, 1, 0.984},
        buffIsEnemyColor = {0.603, 0.137, 0.1521}
    },
    announcements = true
}