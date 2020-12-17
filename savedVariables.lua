srslylawl_saved = {
    settings = {
        header = {
            anchor = "CENTER",
            xOffset = 10,
            yOffset = 10
        },
        hp = {
            width = 100,
            height = 50,
            minWidthPercent = 0.45
        },
        pet = {
            width = 15
        },
        buffs = { anchor = "TOPLEFT", xOffset = -29, yOffset = 0, size = 16, growthDir = "LEFT", showCastByPlayer = true, maxBuffs = 40, maxDuration = 60, showDefensives = true},
        debuffs = { anchor = "BOTTOMLEFT", xOffset = -29, yOffset = 0, size = 16, growthDir = "LEFT", showCastByPlayer = true,
            maxDebuffs = 15, maxDuration = 180},
        absorbOverlapPercent = 0.1,
        maxBuffs = 15,
        maxAbsorbFrames = 20,
        minAbsorbAmount = 100,
        autoApproveKeywords = true,
        showArena = false,
        showParty = true,
        showSolo = true,
        showRaid = false,
        showPlayer = true,
        frameOnUpdateInterval = 0.1
    },
    spells = {
        known = {},
        absorbs = {},
        defensives = {},
        whiteList = {},
        blackList = {}
    }
}
