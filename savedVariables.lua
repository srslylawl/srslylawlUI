srslylawlUI = srslylawlUI or {}

srslylawlUI_Saved = {
    ["buffs"] = {
        ["known"] = {
            [118038] = {
				["autoDetect"] = false,
				["isAbsorb"] = false,
				["name"] = "Die by the Sword",
				["text"] = "Parry chance increased by 100%.\r\nDamage taken reduced by 30%.",
				["isDefensive"] = true,
				["reductionAmount"] = 30,
			},
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
    },
}