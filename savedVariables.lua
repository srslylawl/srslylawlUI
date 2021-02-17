srslylawl_saved = {
    settings = {
        party = {
            header = {
                anchor = "CENTER",
                xOffset = 10,
                yOffset = 10
            },
            hp = {
                width = 100,
                height = 50,
                minWidthPercent = 0.55
            },
            pet = {
                width = 15
            },
            buffs = { anchor = "TOPLEFT", xOffset = -29, yOffset = 0, size = 16, growthDir = "LEFT", showCastByPlayer = true, maxBuffs = 40, maxDuration = 60, showDefensives = true, showInfiniteDuration = false, showDefault = true},
            debuffs = { anchor = "BOTTOMLEFT", xOffset = -29, yOffset = 0, size = 16, growthDir = "LEFT", showCastByPlayer = true,
                maxDebuffs = 15, maxDuration = 180, showInfiniteDuration = false, showDefault = true},
            maxBuffs = 15,
            maxAbsorbFrames = 20,
            showArena = false,
            showParty = true,
            showSolo = true,
            showRaid = false,
            showPlayer = true,
        },
        frameOnUpdateInterval = 0.1
    },
    buffs = {
        known = {
            	[118038] = {
				["autoDetect"] = false,
				["isAbsorb"] = false,
				["name"] = "Die by the Sword",
				["text"] = "Parry chance increased by 100%.\r\nDamage taken reduced by 30%.",
				["isDefensive"] = true,
				["reductionAmount"] = 30,
			}
        },
        absorbs = {},
        defensives = {
            	[118038] = {
				["autoDetect"] = false,
				["isAbsorb"] = false,
				["name"] = "Die by the Sword",
				["text"] = "Parry chance increased by 100%.\r\nDamage taken reduced by 30%.",
				["isDefensive"] = true,
				["reductionAmount"] = 30,
			},
        },
        whiteList = {},
        blackList = {}
    },
    debuffs = {
        known = {
            	[116095] = {
				["autoDetect"] = false,
				["name"] = "Disable",
				["crowdControlType"] = "none",
				["text"] = "Movement slowed by 50%. When struck again by Disable, you will be rooted for 8 sec.",
				["isBlacklisted"] = false,
			}
        },
        whiteList = {},
        blackList = {},
        roots = {},
        stuns = {},
        incaps = {},
        silences = {},
        disorients = {},
    }
}
