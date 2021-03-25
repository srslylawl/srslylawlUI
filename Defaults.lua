srslylawlUI = srslylawlUI or {}

srslylawlUI.defaultSettings = {
    party = {
        header = {
            enabled = true,
            position = { "LEFT", "Screen", "LEFT", 100, 100},
        },
        hp = {
            width = 225, height = 70, minWidthPercent = 0.55, fontSize = 7, reversed = false, absorbHeightPercent = .7
        },
        combatRestIcon = {
            enabled = true,
            size = 16,
            position = {"BOTTOMLEFT", -1, -1}
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
        debuffs = { anchor = "RIGHTTOP", anchoredTo = "Frame", xOffset = 20, yOffset = 0, size = 40, scaledSize = 0,
            showCastByPlayer = true, maxDebuffs = 5, maxDuration = 180, showInfiniteDuration = false, showDefault = true, showLongDuration = false },
        maxAbsorbFrames = 20,
        ccbar = {
            enabled = true,
            width = 100,
            heightPercent = 0.4,
            reversed = false
        },
        visibility = {
            showArena = true,
            showParty = true,
            showSolo = false,
            showRaid = false,
            showPlayer = true,
        },
        raidIcon = {
            enabled = true,
            position = {"TOPLEFT", 10, 0},
            size = 32
        },
        sorting = {
            enabled = true,
        },
        portrait = {
            enabled = false,
            position = "LEFT",
            anchor = "Frame"
        },
    },
    player = {
        playerFrame = {
            enabled = true,
            position = { "TOPRIGHT", "Screen", "CENTER", -200, -100},
            hp = {
                width = 225, height = 70, fontSize = 9, reversed = false, absorbHeightPercent = .7
            },
            buffs = { anchor = "TOPRIGHT", anchoredTo = "Frame", xOffset = 0, yOffset = 0, size = 16, scaledSize = 10, maxBuffs = 16,
                showCastByPlayer = true, maxDuration = 60, showDefensives = true, showInfiniteDuration = true, showDefault = true, showLongDuration = true
            },
            debuffs = { anchor = "BOTTOMLEFT", anchoredTo = "Buffs", xOffset = 0, yOffset = 0, size = 20, scaledSize = 10, maxDebuffs = 15,
                showCastByPlayer = true, maxDuration = 180, showInfiniteDuration = true, showDefault = true, showLongDuration = true
            },
            pet = {
                width = 20
            },
            combatRestIcon = {
                enabled = true,
                size = 16,
                position = {"BOTTOMLEFT", -1, -1}
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
                priority = 0,
                reversed = false
            },
            raidIcon = {
                enabled = true,
                position = {"TOPLEFT", 10, 0},
                size = 32
            },
        },
        targetFrame = {
            enabled = true,
            position = { "TOPLEFT", "Screen", "CENTER", 200, -100},
            hp = {
                width = 225, height = 70, fontSize = 9, reversed = false, absorbHeightPercent = .7
            },
            buffs = {
                anchor = "TOPLEFT", anchoredTo = "Frame", xOffset = 0, yOffset = 0, size = 16, scaledSize = 10, maxBuffs = 24,
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
            combatRestIcon = {
                enabled = true,
                size = 16,
                position = {"BOTTOMLEFT", -1, -1}
            },
            cast = {
                disabled = false,
                fontSize = 10,
                height = 40,
                priority = 0,
                reversed = false
            },
            ccbar = {
                disabled = false,
                height = 20,
                priority = 1,
                reversed = false,
            },
            portrait = {
                enabled = true,
                position = "RIGHT",
                anchor = "Frame"
            },
            unitLevel = {
                position = { "CENTER", "TargetFramePortrait", "BOTTOMRIGHT", 0, 2}
            },
            raidIcon = {
                enabled = true,
                position = {"TOPLEFT", 10, 0},
                size = 32
            },
        },
        targettargetFrame = {
            enabled = true,
            position = {"TOPLEFT", "TargetFramePortrait", "TOPRIGHT", 10, 0},
            hp = {
                width = 150, height = 70, fontSize = 12, reversed = false
            },
            power = {
                width = 15,
                text = true,
                position = "RIGHT"
            },
            raidIcon = {
                enabled = true,
                position = {"TOPLEFT", 10, 0},
                size = 32
            },
        },
        focusFrame = {
            enabled = true,
            position = { "RIGHT", "Screen", "RIGHT", -250, 50},
            hp = {
                width = 200, height = 50, fontSize = 9, reversed = false, absorbHeightPercent = .7
            },
            buffs = {
                anchor = "TOPLEFT", anchoredTo = "Frame", xOffset = 0, yOffset = 0, size = 20, scaledSize = 10, maxBuffs = 21,
                showCastByPlayer = true, maxDuration = 60, showDefensives = true, showInfiniteDuration = true, showDefault = true, showLongDuration = true
            },
            debuffs = {
                anchor = "BOTTOMLEFT", anchoredTo = "Buffs", xOffset = 0, yOffset = 0, size = 20, scaledSize = 10, maxDebuffs = 14,
                showCastByPlayer = true, maxDuration = 180, showInfiniteDuration = true, showDefault = true, showLongDuration = true
            },
            power = {
                width = 15,
                position = "LEFT",
                text = true
            },
            combatRestIcon = {
                enabled = true,
                size = 16,
                position = {"BOTTOMLEFT", -1, -1}
            },
            cast = {
                disabled = false,
                fontSize = 10,
                height = 40,
                priority = 0,
                reversed = false
            },
            ccbar = {
                disabled = false,
                height = 20,
                priority = 1,
                reversed = false,
            },
            portrait = {
                enabled = false,
                position = "RIGHT",
                anchor = "Frame"
            },
            unitLevel = {
                position = { "CENTER", "FocusFrame", "RIGHT", 0, 2}
            },
            raidIcon = {
                enabled = true,
                position = {"TOPLEFT", 10, 0},
                size = 32
            },
        },
    },
    blizzard = {
        player = {enabled = false},
        target = {enabled = false},
        party = {enabled = false},
        auras = { enabled = false},
        castbar = {enabled = false},
        focus = {enabled = false},
        boss = {enabled = false}
    },
    colors = {
        buffBaseColor = {0.960, 0.952, 0.760},
        buffIsStealableColor = {0.988, 0.984, 0.392},
        buffIsEnemyColor = {0.603, 0.137, 0.1521}
    },
    announcements = true
}