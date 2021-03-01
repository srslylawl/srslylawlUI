srslylawlUI = srslylawlUI or {}

srslylawlUI.defaultSettings = {
    ["party"] = {
			["debuffs"] = {
				["growthDir"] = {
					["useParentOnChange"] = true,
					["type"] = "string",
					["onChangeFunc"] = 0,
					["value"] = "LEFT",
					["attributes"] = {
						"TOP", -- [1]
						"RIGHT", -- [2]
						"BOTTOM", -- [3]
						"LEFT", -- [4]
						"CENTER", -- [5]
						"TOPRIGHT", -- [6]
						"TOPLEFT", -- [7]
						"BOTTOMLEFT", -- [8]
						"BOTTOMRIGHT", -- [9]
					},
				},
				["xOffset"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = -29,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = -29,
					},
				},
				["maxDebuffs"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = 5,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = 5,
					},
				},
				["yOffset"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = 0,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = 0,
					},
				},
				["maxDuration"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = 180,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = 180,
					},
				},
				["showCastByPlayer"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = true,
				},
				["showDefault"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = true,
				},
				["anchor"] = {
					["useParentOnChange"] = true,
					["type"] = "string",
					["onChangeFunc"] = 0,
					["value"] = "BOTTOMLEFT",
					["attributes"] = {
						"TOP", -- [1]
						"RIGHT", -- [2]
						"BOTTOM", -- [3]
						"LEFT", -- [4]
						"CENTER", -- [5]
						"TOPRIGHT", -- [6]
						"TOPLEFT", -- [7]
						"BOTTOMLEFT", -- [8]
						"BOTTOMRIGHT", -- [9]
					},
				},
				["showInfiniteDuration"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = false,
				},
				["showLongDuration"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = false,
				},
				["size"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = 16,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = 16,
					},
				},
			},
			["power"] = {
				["width"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = 15,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = 15,
					},
				},
			},
			["maxAbsorbFrames"] = {
				["useParentOnChange"] = true,
				["type"] = "number",
				["onChangeFunc"] = 0,
				["value"] = 20,
				["attributes"] = {
					["min"] = 0,
					["step"] = 1,
					["max"] = 20,
				},
			},
			["hp"] = {
				["height"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = 60,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = 60,
					},
				},
				["width"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = 300,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = 300,
					},
				},
				["minWidthPercent"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = 0.55,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = 0.55,
					},
				},
			},
			["header"] = {
				["enabled"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = true,
				},
				["position"] = {
					{
						["useParentOnChange"] = true,
						["type"] = "string",
						["onChangeFunc"] = 0,
						["value"] = "LEFT",
						["attributes"] = {
							"TOP", -- [1]
							"RIGHT", -- [2]
							"BOTTOM", -- [3]
							"LEFT", -- [4]
							"CENTER", -- [5]
							"TOPRIGHT", -- [6]
							"TOPLEFT", -- [7]
							"BOTTOMLEFT", -- [8]
							"BOTTOMRIGHT", -- [9]
						},
					}, -- [1]
					{
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 250,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 250,
						},
					}, -- [2]
					{
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 200,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 200,
						},
					}, -- [3]
				},
			},
			["pet"] = {
				["width"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = 15,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = 15,
					},
				},
			},
			["buffs"] = {
				["growthDir"] = {
					["useParentOnChange"] = true,
					["type"] = "string",
					["onChangeFunc"] = 0,
					["value"] = "LEFT",
					["attributes"] = {
						"TOP", -- [1]
						"RIGHT", -- [2]
						"BOTTOM", -- [3]
						"LEFT", -- [4]
						"CENTER", -- [5]
						"TOPRIGHT", -- [6]
						"TOPLEFT", -- [7]
						"BOTTOMLEFT", -- [8]
						"BOTTOMRIGHT", -- [9]
					},
				},
				["xOffset"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = -29,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = -29,
					},
				},
				["maxBuffs"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = 5,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = 5,
					},
				},
				["yOffset"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = 0,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = 0,
					},
				},
				["maxDuration"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = 60,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = 60,
					},
				},
				["showCastByPlayer"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = true,
				},
				["showDefault"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = true,
				},
				["showDefensives"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = true,
				},
				["anchor"] = {
					["useParentOnChange"] = true,
					["type"] = "string",
					["onChangeFunc"] = 0,
					["value"] = "TOPLEFT",
					["attributes"] = {
						"TOP", -- [1]
						"RIGHT", -- [2]
						"BOTTOM", -- [3]
						"LEFT", -- [4]
						"CENTER", -- [5]
						"TOPRIGHT", -- [6]
						"TOPLEFT", -- [7]
						"BOTTOMLEFT", -- [8]
						"BOTTOMRIGHT", -- [9]
					},
				},
				["showInfiniteDuration"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = false,
				},
				["showLongDuration"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = false,
				},
				["size"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = 16,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = 16,
					},
				},
			},
			["visibility"] = {
				["showSolo"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = true,
				},
				["showArena"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = true,
				},
				["showRaid"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = false,
				},
				["showPlayer"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = true,
				},
				["showParty"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = true,
				},
			},
			["ccbar"] = {
				["enabled"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = true,
				},
				["heightPercent"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = 0.5,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = 0.5,
					},
				},
				["width"] = {
					["useParentOnChange"] = true,
					["type"] = "number",
					["onChangeFunc"] = 0,
					["value"] = 100,
					["attributes"] = {
						["min"] = 0,
						["step"] = 1,
						["max"] = 100,
					},
				},
			},
	},
	["player"] = {
			["targettargetFrame"] = {
				["enabled"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = true,
				},
				["position"] = {
					["anchor"] = {
						["useParentOnChange"] = true,
						["type"] = "string",
						["onChangeFunc"] = 0,
						["value"] = "TOPRIGHT",
						["attributes"] = {
							"TOP", -- [1]
							"RIGHT", -- [2]
							"BOTTOM", -- [3]
							"LEFT", -- [4]
							"CENTER", -- [5]
							"TOPRIGHT", -- [6]
							"TOPLEFT", -- [7]
							"BOTTOMLEFT", -- [8]
							"BOTTOMRIGHT", -- [9]
						},
					},
					["relative"] = {
						["useParentOnChange"] = true,
						["type"] = "string",
						["onChangeFunc"] = 0,
						["value"] = "TOPLEFT",
						["attributes"] = {
							"TOP", -- [1]
							"RIGHT", -- [2]
							"BOTTOM", -- [3]
							"LEFT", -- [4]
							"CENTER", -- [5]
							"TOPRIGHT", -- [6]
							"TOPLEFT", -- [7]
							"BOTTOMLEFT", -- [8]
							"BOTTOMRIGHT", -- [9]
						},
					},
					["offsetX"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 0,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 0,
						},
					},
					["offsetY"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 0,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 0,
						},
					},
				},
				["hp"] = {
					["height"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 50,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 50,
						},
					},
					["width"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 100,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 100,
						},
					},
				},
				["power"] = {
					["width"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 15,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 15,
						},
					},
				},
			},
			["playerFrame"] = {
				["enabled"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = true,
				},
				["debuffs"] = {
					["perRow"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 5,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 5,
						},
					},
					["growthDir"] = {
						["useParentOnChange"] = true,
						["type"] = "string",
						["onChangeFunc"] = 0,
						["value"] = "LEFT",
						["attributes"] = {
							"TOP", -- [1]
							"RIGHT", -- [2]
							"BOTTOM", -- [3]
							"LEFT", -- [4]
							"CENTER", -- [5]
							"TOPRIGHT", -- [6]
							"TOPLEFT", -- [7]
							"BOTTOMLEFT", -- [8]
							"BOTTOMRIGHT", -- [9]
						},
					},
					["xOffset"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = -29,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = -29,
						},
					},
					["maxDebuffs"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 15,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 15,
						},
					},
					["yOffset"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 0,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 0,
						},
					},
					["maxDuration"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 180,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 180,
						},
					},
					["showCastByPlayer"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = true,
					},
					["showDefault"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = true,
					},
					["anchor"] = {
						["useParentOnChange"] = true,
						["type"] = "string",
						["onChangeFunc"] = 0,
						["value"] = "BOTTOMLEFT",
						["attributes"] = {
							"TOP", -- [1]
							"RIGHT", -- [2]
							"BOTTOM", -- [3]
							"LEFT", -- [4]
							"CENTER", -- [5]
							"TOPRIGHT", -- [6]
							"TOPLEFT", -- [7]
							"BOTTOMLEFT", -- [8]
							"BOTTOMRIGHT", -- [9]
						},
					},
					["showInfiniteDuration"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = false,
					},
					["showLongDuration"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = false,
					},
					["size"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 32,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 32,
						},
					},
				},
				["position"] = {
					{
						["useParentOnChange"] = true,
						["type"] = "string",
						["onChangeFunc"] = 0,
						["value"] = "TOPRIGHT",
						["attributes"] = {
							"TOP", -- [1]
							"RIGHT", -- [2]
							"BOTTOM", -- [3]
							"LEFT", -- [4]
							"CENTER", -- [5]
							"TOPRIGHT", -- [6]
							"TOPLEFT", -- [7]
							"BOTTOMLEFT", -- [8]
							"BOTTOMRIGHT", -- [9]
						},
					}, -- [1]
					nil, -- [2]
					{
						["useParentOnChange"] = true,
						["type"] = "string",
						["onChangeFunc"] = 0,
						["value"] = "CENTER",
						["attributes"] = {
							"TOP", -- [1]
							"RIGHT", -- [2]
							"BOTTOM", -- [3]
							"LEFT", -- [4]
							"CENTER", -- [5]
							"TOPRIGHT", -- [6]
							"TOPLEFT", -- [7]
							"BOTTOMLEFT", -- [8]
							"BOTTOMRIGHT", -- [9]
						},
					}, -- [3]
					{
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 0,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 0,
						},
					}, -- [4]
					{
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 0,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 0,
						},
					}, -- [5]
				},
				["pet"] = {
					["width"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 20,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 20,
						},
					},
				},
				["buffs"] = {
					["perRow"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 5,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 5,
						},
					},
					["growthDir"] = {
						["useParentOnChange"] = true,
						["type"] = "string",
						["onChangeFunc"] = 0,
						["value"] = "LEFT",
						["attributes"] = {
							"TOP", -- [1]
							"RIGHT", -- [2]
							"BOTTOM", -- [3]
							"LEFT", -- [4]
							"CENTER", -- [5]
							"TOPRIGHT", -- [6]
							"TOPLEFT", -- [7]
							"BOTTOMLEFT", -- [8]
							"BOTTOMRIGHT", -- [9]
						},
					},
					["xOffset"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = -29,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = -29,
						},
					},
					["showDefensives"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = true,
					},
					["yOffset"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 0,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 0,
						},
					},
					["maxDuration"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 60,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 60,
						},
					},
					["showCastByPlayer"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = true,
					},
					["maxBuffs"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 15,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 15,
						},
					},
					["showDefault"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = true,
					},
					["anchor"] = {
						["useParentOnChange"] = true,
						["type"] = "string",
						["onChangeFunc"] = 0,
						["value"] = "TOPLEFT",
						["attributes"] = {
							"TOP", -- [1]
							"RIGHT", -- [2]
							"BOTTOM", -- [3]
							"LEFT", -- [4]
							"CENTER", -- [5]
							"TOPRIGHT", -- [6]
							"TOPLEFT", -- [7]
							"BOTTOMLEFT", -- [8]
							"BOTTOMRIGHT", -- [9]
						},
					},
					["showInfiniteDuration"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = false,
					},
					["showLongDuration"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = false,
					},
					["size"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 32,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 32,
						},
					},
				},
				["hp"] = {
					["height"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 80,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 80,
						},
					},
					["width"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 300,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 300,
						},
					},
				},
				["power"] = {
					["width"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 15,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 15,
						},
					},
				},
			},
			["targetFrame"] = {
				["enabled"] = {
					["useParentOnChange"] = true,
					["type"] = "boolean",
					["onChangeFunc"] = 0,
					["value"] = true,
				},
				["debuffs"] = {
					["perRow"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 5,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 5,
						},
					},
					["growthDir"] = {
						["useParentOnChange"] = true,
						["type"] = "string",
						["onChangeFunc"] = 0,
						["value"] = "LEFT",
						["attributes"] = {
							"TOP", -- [1]
							"RIGHT", -- [2]
							"BOTTOM", -- [3]
							"LEFT", -- [4]
							"CENTER", -- [5]
							"TOPRIGHT", -- [6]
							"TOPLEFT", -- [7]
							"BOTTOMLEFT", -- [8]
							"BOTTOMRIGHT", -- [9]
						},
					},
					["xOffset"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = -29,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = -29,
						},
					},
					["maxDebuffs"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 15,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 15,
						},
					},
					["yOffset"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 0,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 0,
						},
					},
					["maxDuration"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 180,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 180,
						},
					},
					["showCastByPlayer"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = true,
					},
					["showDefault"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = true,
					},
					["anchor"] = {
						["useParentOnChange"] = true,
						["type"] = "string",
						["onChangeFunc"] = 0,
						["value"] = "BOTTOMLEFT",
						["attributes"] = {
							"TOP", -- [1]
							"RIGHT", -- [2]
							"BOTTOM", -- [3]
							"LEFT", -- [4]
							"CENTER", -- [5]
							"TOPRIGHT", -- [6]
							"TOPLEFT", -- [7]
							"BOTTOMLEFT", -- [8]
							"BOTTOMRIGHT", -- [9]
						},
					},
					["showInfiniteDuration"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = false,
					},
					["showLongDuration"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = false,
					},
					["size"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 32,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 32,
						},
					},
				},
				["position"] = {
					["anchor"] = {
						["useParentOnChange"] = true,
						["type"] = "string",
						["onChangeFunc"] = 0,
						["value"] = "CENTER",
						["attributes"] = {
							"TOP", -- [1]
							"RIGHT", -- [2]
							"BOTTOM", -- [3]
							"LEFT", -- [4]
							"CENTER", -- [5]
							"TOPRIGHT", -- [6]
							"TOPLEFT", -- [7]
							"BOTTOMLEFT", -- [8]
							"BOTTOMRIGHT", -- [9]
						},
					},
					["relative"] = {
						["useParentOnChange"] = true,
						["type"] = "string",
						["onChangeFunc"] = 0,
						["value"] = "TOPLEFT",
						["attributes"] = {
							"TOP", -- [1]
							"RIGHT", -- [2]
							"BOTTOM", -- [3]
							"LEFT", -- [4]
							"CENTER", -- [5]
							"TOPRIGHT", -- [6]
							"TOPLEFT", -- [7]
							"BOTTOMLEFT", -- [8]
							"BOTTOMRIGHT", -- [9]
						},
					},
					["offsetX"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 0,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 0,
						},
					},
					["offsetY"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 0,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 0,
						},
					},
				},
				["buffs"] = {
					["perRow"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 5,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 5,
						},
					},
					["growthDir"] = {
						["useParentOnChange"] = true,
						["type"] = "string",
						["onChangeFunc"] = 0,
						["value"] = "LEFT",
						["attributes"] = {
							"TOP", -- [1]
							"RIGHT", -- [2]
							"BOTTOM", -- [3]
							"LEFT", -- [4]
							"CENTER", -- [5]
							"TOPRIGHT", -- [6]
							"TOPLEFT", -- [7]
							"BOTTOMLEFT", -- [8]
							"BOTTOMRIGHT", -- [9]
						},
					},
					["xOffset"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = -29,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = -29,
						},
					},
					["showDefensives"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = true,
					},
					["yOffset"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 0,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 0,
						},
					},
					["maxDuration"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 60,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 60,
						},
					},
					["showCastByPlayer"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = true,
					},
					["maxBuffs"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 15,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 15,
						},
					},
					["showDefault"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = true,
					},
					["anchor"] = {
						["useParentOnChange"] = true,
						["type"] = "string",
						["onChangeFunc"] = 0,
						["value"] = "TOPLEFT",
						["attributes"] = {
							"TOP", -- [1]
							"RIGHT", -- [2]
							"BOTTOM", -- [3]
							"LEFT", -- [4]
							"CENTER", -- [5]
							"TOPRIGHT", -- [6]
							"TOPLEFT", -- [7]
							"BOTTOMLEFT", -- [8]
							"BOTTOMRIGHT", -- [9]
						},
					},
					["showInfiniteDuration"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = false,
					},
					["showLongDuration"] = {
						["useParentOnChange"] = true,
						["type"] = "boolean",
						["onChangeFunc"] = 0,
						["value"] = false,
					},
					["size"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 32,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 32,
						},
					},
				},
				["hp"] = {
					["height"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 50,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 50,
						},
					},
					["width"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 100,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 100,
						},
					},
				},
				["power"] = {
					["width"] = {
						["useParentOnChange"] = true,
						["type"] = "number",
						["onChangeFunc"] = 0,
						["value"] = 15,
						["attributes"] = {
							["min"] = 0,
							["step"] = 1,
							["max"] = 15,
						},
					},
				},
			},
	},
}