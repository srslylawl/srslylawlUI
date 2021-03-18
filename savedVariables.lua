srslylawlUI = srslylawlUI or {}

srslylawlUI_Saved = {
    buffs = {
        ["known"] = {
            [118038] = {
				["autoDetect"] = false,
				["isAbsorb"] = false,
				["name"] = "Die by the Sword",
				["text"] = "Parry chance increased by 100%.\r\nDamage taken reduced by 30%.",
				["isDefensive"] = true,
				["reductionAmount"] = 30,
			},
            [1966] = {
			    ["autoDetect"] = true,
			    ["isAbsorb"] = false,
			    ["autoDetectAmount"] = false,
			    ["name"] = "Feint",
			    ["text"] = "Damage taken from area-of-effect attacks reduced by 40% and all other damage taken reduced by 30%.\r\n",
			    ["isDefensive"] = true,
			    ["reductionAmount"] = 30,
            },
			[190456] = {
				["autoDetect"] = false,
				["isAbsorb"] = true,
				["text"] = "Ignoring 50% of damage taken, preventing 1686 total damage.",
				["isDefensive"] = false,
				["name"] = "Ignore Pain",
			},
        },
        absorbs = {
			[190456] = {
				["autoDetect"] = false,
				["isAbsorb"] = true,
				["text"] = "Ignoring 50% of damage taken, preventing 1686 total damage.",
				["isDefensive"] = false,
				["name"] = "Ignore Pain",
			},
		},
        defensives = {
            [118038] = {
				["autoDetect"] = false,
				["isAbsorb"] = false,
				["name"] = "Die by the Sword",
				["text"] = "Parry chance increased by 100%.\r\nDamage taken reduced by 30%.",
				["isDefensive"] = true,
				["reductionAmount"] = 30,
			},
            [1966] = {
			    ["autoDetect"] = true,
			    ["isAbsorb"] = false,
			    ["autoDetectAmount"] = false,
			    ["name"] = "Feint",
			    ["text"] = "Damage taken from area-of-effect attacks reduced by 40% and all other damage taken reduced by 30%.\r\n",
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