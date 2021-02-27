srslylawlUI.PowerBar = {}

srslylawlUI.PowerBar.Type = {
    None = 0,
    PointBar = 1,
    ResourceBar = 2,
    Special = 3
}

srslylawlUI.PowerBar.SpecBarTypeTable = {
    --DK
    [250] = 1, --Blood
    [251] = 1, --Frost
    [252] = 1, --Unholy
    --DH
    [577] = 0, --Havoc
    [581] = 0, --Vengeance
    --Druid
    [102] = 3, --Balance
    [103] = 3, --Feral
    [104] = 3, --Guardian
    [105] = 3, --Restoration
    --Hunter
    [253] = 0, --BM
    [254] = 0, --Marksmanship
    [255] = 0, --Survival
    --Mage
    [62] = 1, --Arcane
    [63] = 0, --Fire
    [64] = 0, --Frost
    --Monk
    [268] = 2, --Brewmaster
    [269] = 1, --Windwalker
    [270] = 0, --Mistweaver
    --Paladin
    [65] = 1, --Holy
    [66] = 1, --Protection
    [70] = 1, --Retribution
    --Priest
    [256] = 0, --Discipline
    [257] = 0, --Holy
    [258] = 2, --Shadow
    --Rogue
    [259] = 1, --Assassination
    [260] = 1, --Outlaw
    [261] = 1, --Subtlety
    --Shaman
    [262] = 2, --Elemental
    [263] = 0, --Enhancement
    [264] = 0, --Restoration
    --Warlock
    [265] = 1, --Affliction
    [266] = 1, --Demonology
    [267] = 1, --Destruction
    --Warrior
    [71] = 0, --Arms
    [72] = 0, --Fury
    [73] = 0, --Protection
}

srslylawlUI.PowerBar.SpecToPowerType = {
    --DK
    [250] = "Runes", --Blood
    [251] = "Runes", --Frost
    [252] = "Runes", --Unholy
    --Mage
    [62] = "ArcaneCharges", --Arcane

    --Monk
    [268] = "Stagger", --Brewmaster
    [269] = "Chi", --Windwalker
    --Paladin
    [65] = "HolyPower", --Holy
    [66] = "HolyPower", --Protection
    [70] = "HolyPower", --Retribution
    --Priest
    [258] = "Mana", --Shadow
    --Rogue
    [259] = "ComboPoints", --Assassination
    [260] = "ComboPoints", --Outlaw
    [261] = "ComboPoints", --Subtlety
    --Shaman
    [262] = "Mana", --Elemental
    [263] = 0, --Enhancement
    --Warlock
    [265] = "SoulShards", --Affliction
    [266] = "SoulShards", --Demonology
    [267] = "SoulShards", --Destruction
}

srslylawlUI.PowerBar.EventToTokenTable = {
    MANA = "Mana",
    RAGE = "Rage",
    FOCUS = "Focus",
    ENERGY = "Energy",
    COMBO_POINTS = "ComboPoints",
    RUNES = "Runes",
    RUNIC_POWER = "RunicPower",
    SOUL_SHARDS = "SoulShards",
    LUNAR_POWER = "LunarPower",
    HOLY_POWER = "HolyPower",
    MAELSTROM = "Maelstrom",
    INSANITY = "Insanity",
    CHI = "Chi",
    ARCANE_CHARGES = "ArcaneCharges",
    FURY = "Fury",
    PAIN = "Pain",
}
srslylawlUI.PowerBar.TokenToPowerBarColor = {
    --used for powerbarcolor
    [0] = "MANA",
    [1] = "RAGE",
    [2] = "FOCUS",
    [3] = "ENERGY",
    [4] = "CHI",
    [5] = "RUNES",
    [6] = "RUNIC_POWER",
    [7] = "SOUL_SHARDS",
    [8] = "LUNAR_POWER",
    [9] = "HOLY_POWER",
    [11] = "MAELSTROM",
    [12] = "CHI",
    [13] = "INSANITY",
    [16] = "ARCANE_CHARGES",
    [17] = "FURY",
    [18] = "PAIN",
}

srslylawlUI.PowerBar.BarDefaults = {
    Mana = {hideWhenInactive = true, inactiveState = "FULL"},
    Rage = {hideWhenInactive = true, inactiveState = "EMPTY"},
    Focus = {hideWhenInactive = true, inactiveState = "FULL"},
    Energy = {hideWhenInactive = true, inactiveState = "FULL"},
    ComboPoints  = {hideWhenInactive = true, inactiveState = "EMPTY", alwaysShowInCombat = false},
    Runes = {hideWhenInactive = true, inactiveState = "FULL"},
    RunicPower = {hideWhenInactive = true, inactiveState = "EMPTY"},
    SoulShards = {hideWhenInactive = false},
    LunarPower = {hideWhenInactive = true, inactiveState = "EMPTY"},
    HolyPower  = {hideWhenInactive = true, inactiveState = "EMPTY"},
    Maelstrom  = {hideWhenInactive = true, inactiveState = "EMPTY"},
    Insanity  = {hideWhenInactive = true, inactiveState = "EMPTY"},
    Chi  = {hideWhenInactive = true, inactiveState = "EMPTY"},
    ArcaneCharges = {hideWhenInactive = true, inactiveState = "EMPTY"},
    Fury  = {hideWhenInactive = true, inactiveState = "EMPTY"},
    Pain  = {hideWhenInactive = true, inactiveState = "EMPTY"},
    Stagger = {hideWhenInactive = true, inactiveState = "EMPTY"},
}

function srslylawlUI.PowerBar.CreatePointBar(amount, parent, padding, powerToken)
    if amount < 1 then error("Param1 'Amount' must be 1 or higher") return end
    local frame = CreateFrame("Frame", "$parent_PointResourceBar_"..powerToken, parent)
    frame.padding = padding
    frame.desiredButtonCount = amount
    srslylawlUI.CreateBackground(frame, 1)
    frame:SetAttribute("type", "pointBar")
    frame.powerToken = Enum.PowerType[powerToken]
    frame.unit = parent:GetAttribute("unit")
    frame.pointFrames = {}
    frame.hideWhenInactive = srslylawlUI.PowerBar.BarDefaults[powerToken].hideWhenInactive
    frame.inactiveState = srslylawlUI.PowerBar.BarDefaults[powerToken].inactiveState
    frame.alwaysShowInCombat = srslylawlUI.PowerBar.BarDefaults[powerToken].alwaysShowInCombat

    local function CreatePointFrame(parent, i)
        local pointFrame = CreateFrame("StatusBar", "$parent_PointBar"..i, parent)
        pointFrame:SetStatusBarTexture(srslylawlUI.textures.PowerBarSprite)
        pointFrame:SetMinMaxValues(0, 1)
        pointFrame:SetValue(1)
        pointFrame.text = pointFrame:CreateFontString("$parent_point"..i, "ARTWORK", "GameTooltipTextSmall")
        pointFrame.text:SetPoint("CENTER", pointFrame, "CENTER", 0, 0)
        return pointFrame
    end
    function frame:SetColor(color)
        self.color = color
        for i=1, #self.pointFrames do
            if not self.pointFrames[i].isCharged then
                self.pointFrames[i]:SetStatusBarColor(color.r, color.g, color.b)
            end
        end
    end
    function frame:SetButtonCount(newCount)
        self.desiredButtonCount = newCount
        self:SetPoints()
    end
    function frame:SetPoints(x, y)
        if self.desiredButtonCount > #self.pointFrames then
            local index = #self.pointFrames
            while self.desiredButtonCount > index do
                self.pointFrames[index+1] = CreatePointFrame(frame, index)
                index = index + 1
            end
        end

        if not x or not y then
            x, y = srslylawlUI.Utils_PixelFromScreenToCode(self:GetWidth(), self:GetHeight())
        end

        local desiredSize = x
        local totalSize = x
        local height = y
        local buttons = self.desiredButtonCount
        local totalpadding = (buttons-1)*self.padding
        totalSize = totalSize - totalpadding
        local barSize = srslylawlUI.Utils_ScuffedRound(totalSize/buttons)
        totalSize = barSize*buttons+totalpadding
        local diff = desiredSize - totalSize
        -- print(diff > 0 and "pointbar too small by " .. diff or diff < 0 and "pointbar too big by " .. diff or "pointbar perfect size")
        local middleFrame = ceil(self.desiredButtonCount/2)
        -- print("frame", middleFrame, "size adjusted by ", diff)
        local pixelPerfectCompensation
        for i=1, #self.pointFrames do
            local current = self.pointFrames[i]
            if i > self.desiredButtonCount then
                current:Hide()
            else
                current:Show()
            end
            if i == 1 then
                srslylawlUI.Utils_SetPointPixelPerfect(current, "BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
            else
                srslylawlUI.Utils_SetPointPixelPerfect(current, "BOTTOMLEFT", self.pointFrames[i-1], "BOTTOMRIGHT", self.padding, 0)
            end
            pixelPerfectCompensation = i == middleFrame and diff or 0
            srslylawlUI.Utils_SetSizePixelPerfect(current, barSize+pixelPerfectCompensation, height)

            -- current.text:SetTextHeight(current:GetHeight())
        end
        srslylawlUI.Utils_SetSizePixelPerfect(self, totalSize+diff, height)

        if self.powerToken == 5 then --is a runebar
            self:RuneUpdate()
        else
            self:Update()
        end
    end
    function frame:Update()
        local displayCount = UnitPower(self.unit, self.powerToken)
        for i=1, self.desiredButtonCount do
            if not self.pointFrames[i].isCharged then
                self.pointFrames[i]:SetShown(i <= displayCount)
            else
                local show = i <= displayCount
                if show then
                    self.pointFrames[i]:Show()
                    self.pointFrames[i]:SetAlpha(1)
                else
                    self.pointFrames[i]:Show()
                    self.pointFrames[i]:SetAlpha(.4)
                end
            end
        end

        local visible = true
        if self.hideWhenInactive then
            if self.alwaysShowInCombat and InCombatLockdown() then
                visible = true
            elseif self.inactiveState == "EMPTY" and displayCount == 0 then
                visible = false
            elseif self.inactiveState == "FULL" and displayCount == self.desiredButtonCount then
                visible = false
            end
        end
        visible = self.hasChargedPoint or visible
        if self:IsShown() ~= visible then
            self:SetShown(visible)
        end

    end
    function frame:UpdateMax()
        local maxPoints = UnitPowerMax(self.unit, self.powerToken)
        self:SetButtonCount(maxPoints)
        self:Update()
    end
    function frame:RuneUpdate()
        function UpdateRuneTimer(rune, cd, start, current, duration, runeReady)
            if runeReady then
                rune.cd = cd
                rune:SetValue(1)
                rune:SetAlpha(1)
                rune:SetScript("OnUpdate", nil)
                rune.text:SetText("")
                return
            end

            local progress = current/duration
            rune.cd = cd
            rune:SetValue(progress)
            rune:SetAlpha(.5)

            rune:SetScript("OnUpdate", function(self, elapsed)
                current = GetTime() - start
                progress = current/duration
                progress = progress > 1 and 1 or progress
                self:SetValue(progress)
                self.text:SetFormattedText("%.1f", duration-current, 1)

                if progress == 1 then
                    self:SetScript("OnUpdate", nil)
                    self:SetAlpha(1)
                    self.text:SetText("")
                end
            end)
        end

        local runeTable = {}
        local index = 1
        local current, cd, runeObject
        local start, duration, runeReady = GetRuneCooldown(index)
        local runesReady = 0
        while start do
            --get data
            current = GetTime() - start
            cd = runeReady and 0 or duration-current
            runeObject = {cd, start, current, duration, runeReady}
            table.insert(runeTable, #runeTable + 1, runeObject)

            if runeReady then
                runesReady = runesReady + 1
            end

            index = index + 1
            start, duration, runeReady = GetRuneCooldown(index)
        end

        table.sort(runeTable, function(a, b)
            if a[1] < b[1] then
                return true
            else
                return false
            end
        end)

        local rune
        for i = 1, #runeTable do
            rune = self.pointFrames[i]
            UpdateRuneTimer(rune, unpack(runeTable[i]))
        end


        local visible = true
        if self.hideWhenInactive then
            if self.alwaysShowInCombat and InCombatLockdown() then
                visible = true
            elseif self.inactiveState == "FULL" and runesReady == #runeTable then
                visible = false
            end
        end

        if self:IsShown() ~= visible then
            self:SetShown(visible)
        end
    end
    function frame:OnComboPointCharged()
        --rogue animacharge
        local chargedPointsTable = GetUnitChargedPowerPoints(self.unit)
        if chargedPointsTable then
            self.hasChargedPoint = true
            for _, pointIndex in pairs(chargedPointsTable) do
                self.pointFrames[pointIndex]:SetStatusBarColor(0.713, 0.101, 1)
                self.pointFrames[pointIndex].isCharged = true
                if not self.pointFrames[pointIndex]:IsShown() then
                    self.pointFrames[pointIndex]:Show()
                    self.pointFrames[pointIndex]:SetAlpha(.4)
                else
                    self.pointFrames[pointIndex]:SetAlpha(1)
                end
            end
        elseif self.hasChargedPoint then
            self.hasChargedPoint = nil
            for i=1, #self.pointFrames do
                self.pointFrames[i]:SetAlpha(1)
                self.pointFrames[i].isCharged = nil
            end
            self:SetColor(self.color)
        end
    end

    frame:SetPoints()

    return frame
end

function srslylawlUI.PowerBar.CreateResourceBar(parent, powerToken)
    local frame = CreateFrame("Frame", "$parent_ResourceBar_"..powerToken, parent)
    srslylawlUI.CreateBackground(frame, 1)
    frame.statusBar = CreateFrame("StatusBar", "$parent_StatusBar", frame)
    frame.statusBar:SetStatusBarTexture(srslylawlUI.textures.PowerBarSprite)
    srslylawlUI.Utils_SetPointPixelPerfect(frame.statusBar, "TOPLEFT", frame, "TOPLEFT", 0, 0)
    srslylawlUI.Utils_SetPointPixelPerfect(frame.statusBar, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    frame.unit = parent:GetAttribute("unit")
    if powerToken == "Stagger" then
        -- frame.powerToken = "Stagger"
    else
        frame.powerToken = Enum.PowerType[powerToken]
        frame.max = UnitPowerMax(frame.unit, frame.powerToken)
    end
    frame:SetAttribute("type", "statusBar")
    frame.statusBar.leftText = frame.statusBar:CreateFontString("$parent_LeftText", "ARTWORK", "GameTooltipTextSmall")
    frame.statusBar.rightText = frame.statusBar:CreateFontString("$parent_RightText", "ARTWORK", "GameTooltipTextSmall")
    frame.statusBar.rightText:SetPoint("CENTER", frame.statusBar, "CENTER", 0, 0)

    frame.hideWhenInactive = srslylawlUI.PowerBar.BarDefaults[powerToken].hideWhenInactive
    frame.inactiveState = srslylawlUI.PowerBar.BarDefaults[powerToken].inactiveState
    frame.hideInCombat = srslylawlUI.PowerBar.BarDefaults[powerToken].hideInCombat

    function frame:SetColor(color)
        self.statusBar:SetStatusBarColor(color.r, color.g, color.b)
    end
    function frame:Update()
        local amount = UnitPower(self.unit, self.powerToken)
        -- self.statusBar.rightText:SetText(ceil(amount/self.max*100).."%")
        self.statusBar.rightText:SetText(amount > 0 and amount or "")
        self.statusBar:SetValue(amount)

        local visible = true
        if self.hideWhenInactive then
            if self.alwaysShowInCombat and InCombatLockdown() then
                return
            elseif self.inactiveState == "EMPTY" and amount < 1 then
                visible = false
            elseif self.inactiveState == "FULL" and abs(self.max - amount) < 1 then
                visible = false
            end
        end

        if self:IsShown() ~= visible then
            self:SetShown(visible)
        end
    end
    function frame:UpdateMax()
        self.max = UnitPowerMax(self.unit, self.powerToken)
        self.statusBar:SetMinMaxValues(0, frame.max)
        self:Update()
    end
    function frame:SetPoints()
        -- local h = self.statusBar:GetHeight()
        -- if h > 0 then
        --     self.statusBar.rightText:SetTextHeight(h)
        --     self.statusBar.leftText:SetTextHeight(h)
        -- end
    end
    if frame.powerToken then
        frame:UpdateMax()
    end

    return frame
end
function srslylawlUI.PowerBar.Set(parent, unit)
    local height = 40
    local function DisplayMainBar(parent)
        local _, powerToken = UnitPowerType("player")
        powerToken = srslylawlUI.PowerBar.EventToTokenTable[powerToken]
        local bar = srslylawlUI.PowerBar.GetBar(parent, "resource", powerToken)
        parent:RegisterBar(bar, 3, height)
        -- srslylawlUI.PowerBar.PlaceBar(bar, parent, 1)
    end
    if not parent.powerBars then
        parent.powerBars = {}
    end
    -- HideActiveBars()
    local barType = srslylawlUI.PowerBar.GetType()
    if barType == srslylawlUI.PowerBar.Type.None then
        --No Additional Bar
        DisplayMainBar(parent)
        return
    elseif barType == srslylawlUI.PowerBar.Type.ResourceBar then
        DisplayMainBar(parent)
        --Resource Bar
        local token = srslylawlUI.PowerBar.GetPowerToken()
        local bar = srslylawlUI.PowerBar.GetBar(parent, "resource", token)
        if token == "Stagger" then
            srslylawlUI.PowerBar.SetupStaggerBar(bar, parent)
        end
        parent:RegisterBar(bar, 5, height*.7)
        -- srslylawlUI.PowerBar.PlaceBar(bar, parent, 2)
    elseif barType == srslylawlUI.PowerBar.Type.PointBar then
        --Point Bar
        DisplayMainBar(parent)
        local specID = srslylawlUI.GetSpecID()
        local bar = srslylawlUI.PowerBar.GetBar(parent, "point", srslylawlUI.PowerBar.GetPowerToken())
        parent:RegisterBar(bar, 5, height*.7)
        -- srslylawlUI.PowerBar.PlaceBar(bar, parent, 2)
        if specID >= 250 and specID <= 252 and not bar.isRegistered then --dk spec, use rune update
            bar:RegisterEvent("RUNE_POWER_UPDATE")
            bar:SetScript("OnEvent", function(self, event, ...)
                self:RuneUpdate()
            end)
            bar.isRegistered = true
        elseif specID >= 259 and specID <= 261 and not bar.isRegistered then --is rogue, check for kyrian ability cp chargedPointsTable
            bar:RegisterEvent("UNIT_POWER_POINT_CHARGE")
            bar:SetScript("OnEvent", function(self, event, ...)
                self:OnComboPointCharged()
            end)
            bar.isRegistered = true
        end

    elseif barType == srslylawlUI.PowerBar.Type.Special then
        --player is druid
        srslylawlUI.PowerBar.SetupDruidBars(parent, unit)
    end
end
function srslylawlUI.PowerBar.RefreshVisibility(parent)
--hide bars that are empty/full
end
function srslylawlUI.PowerBar.GetType()
    local specIndex = GetSpecialization()
    local specID = GetSpecializationInfo(specIndex)
    if not specID then
        srslylawlUI.Log("Error getting Unit spec")
        return
    end
    return srslylawlUI.PowerBar.SpecBarTypeTable[specID]
end
function srslylawlUI.PowerBar.SetColorByToken(bar, powerToken)
    local colortoken = srslylawlUI.PowerBar.TokenToPowerBarColor[powerToken]
    local color = srslylawlUI.Frame_GetCustomPowerBarColor(colortoken)
    if color then
        bar:SetColor(color)
    end
end
function srslylawlUI.PowerBar.GetPowerToken()
    return srslylawlUI.PowerBar.SpecToPowerType[srslylawlUI.GetSpecID()]
end

function srslylawlUI.PowerBar.GetBar(parent, type, token)
    if not parent.powerBars[token] then
        if token == "Stagger" then
            parent.powerBars[token] = srslylawlUI.PowerBar.CreateResourceBar(parent, token)
        end
        if type == "resource" or type == nil then
            parent.powerBars[token] = srslylawlUI.PowerBar.CreateResourceBar(parent, token)
        elseif type == "point" then
            local maxPoints = UnitPowerMax("player", Enum.PowerType[token])
            parent.powerBars[token] = srslylawlUI.PowerBar.CreatePointBar(maxPoints, parent, 1, token)
        end
        srslylawlUI.PowerBar.SetColorByToken(parent.powerBars[token], Enum.PowerType[token])
        parent.powerBars[token]:SetAttribute("powerToken", token)
    end
    return parent.powerBars[token]
end
function srslylawlUI.PowerBar.SetupDruidBars(parent, unit)
    local manaBar = srslylawlUI.PowerBar.GetBar(parent, "resource", "Mana")
    local cpBar = srslylawlUI.PowerBar.GetBar(parent, "point", "ComboPoints")
    local energyBar = srslylawlUI.PowerBar.GetBar(parent, "resource", "Energy")
    local rageBar = srslylawlUI.PowerBar.GetBar(parent, "resource", "Rage")
    local astralPowerBar = srslylawlUI.PowerBar.GetBar(parent, "resource", "LunarPower")
    local specID = srslylawlUI.GetSpecID()
    --[[
    102 -> Balance
    103 -> Feral
    104 -> Guardian
    105 -> Restoration
    ]]
    local currentStance = GetShapeshiftFormID()
    --[[
        humanoid form - nil
        Aquatic Form - 4
        Bear Form - 5
        Cat Form - 1
        Flight Form - 29
        Moonkin Form - 31
        Swift Flight Form - 27
        Travel Form - 3
        Tree of Life - 2
    ]]

    if specID ~= 102 then
        parent:UnregisterBar(astralPowerBar)
    end

    if currentStance == nil or currentStance == 31 then
        --human/owl
        if specID == 102 then -- balance
            -- main bar is now astral power, show mana and cp if needed
            parent:RegisterBar(astralPowerBar, 1)
            parent:RegisterBar(manaBar, 2)
            parent:RegisterBar(cpBar, 3)
        elseif specID == 103 then -- feral
            parent:RegisterBar(energyBar, 1)
            parent:RegisterBar(cpBar, 2)
            parent:RegisterBar(manaBar, 3)
        else
            parent:RegisterBar(manaBar, 1)
            parent:RegisterBar(cpBar, 2)
        end
    elseif currentStance == 3 or currentStance == 4 or currentStance == 27 or currentStance == 29 then
        --travelforms, default main bar is now mana
        if specID == 102 then -- balance
            parent:RegisterBar(astralPowerBar, 1)
            parent:RegisterBar(manaBar, 2)
            parent:RegisterBar(cpBar, 3)
        elseif specID == 103 then -- feral
            parent:RegisterBar(energyBar, 1)
            parent:RegisterBar(cpBar, 2)
            parent:RegisterBar(manaBar, 3)
        else
            parent:RegisterBar(manaBar, 1)
            parent:RegisterBar(cpBar, 2)
        end
    elseif currentStance == 1 then
        --cat form, default is energy
        parent:RegisterBar(energyBar, 1)
        parent:RegisterBar(cpBar, 2)
        local index = 3
        if specID == 102 then -- balance
            parent:RegisterBar(astralPowerBar, index)
            index = index + 1
        end
        parent:RegisterBar(manaBar, index)
    elseif currentStance == 5 then
        --bear, default is rage
        parent:RegisterBar(rageBar, 1)
        local index = 2
        if specID == 102 then -- balance
            parent:RegisterBar(astralPowerBar, index)
            index = index + 1
        end
        parent:RegisterBar(manaBar, index)
        index = index + 1
        parent:RegisterBar(cpBar, index)
    end
end
function srslylawlUI.PowerBar.SetupStaggerBar(bar)
    function bar:UpdateMax()
        self.max = UnitHealthMax(self.unit)
        self.statusBar:SetMinMaxValues(0, self.max)
        self:Update()
    end

    function bar:Update()
        local amount = UnitStagger(self.unit)

        local visible = true
        if self.hideWhenInactive then
            if self.alwaysShowInCombat and InCombatLockdown() then
                return
            elseif self.inactiveState == "EMPTY" and amount < 1 then
                visible = false
            elseif self.inactiveState == "FULL" and abs(self.max - amount) < 1 then
                visible = false
            end
        end

        if self:IsShown() ~= visible then
            self:SetShown(visible)
        end

        if not self:IsShown() then
            return
        end
        self.statusBar:SetValue(amount)
        self.statusBar.rightText:SetText(amount)
	    local percent = amount/self.max
	    local color = percent < STAGGER_YELLOW_TRANSITION and {0.662, 1, 0.541}
        or percent < STAGGER_RED_TRANSITION and {0.945, 0.933, 0.074}
        or {1, 0.039, 0.141}
        self.statusBar:SetStatusBarColor(unpack(color))
    end

    bar:SetScript("OnEvent", function(self, event, unit)
        if unit == self.unit then
            if event == "UNIT_MAXHEALTH" then
                self:UpdateMax()
            elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_AURA" then
                self:Update()
            end
        end
    end)

    bar:RegisterUnitEvent("UNIT_MAXHEALTH", bar.unit)
    bar:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", bar.unit)
    bar:RegisterUnitEvent("UNIT_AURA")
    bar:UpdateMax()
end

function srslylawlUI.PowerBar.Update(parent, powerToken)
    local eventToToken = srslylawlUI.PowerBar.EventToTokenTable[powerToken]
    powerToken = eventToToken and eventToToken or powerToken
    srslylawlUI.PowerBar.GetBar(parent, nil, powerToken):Update()
end
function srslylawlUI.PowerBar.UpdateMax(parent, powerToken)
    local eventToToken = srslylawlUI.PowerBar.EventToTokenTable[powerToken]
    powerToken = eventToToken and eventToToken or powerToken
    srslylawlUI.PowerBar.GetBar(parent, nil, powerToken):UpdateMax()
end
function srslylawlUI.PowerBar.RuneUpdate(parent)
    local eventToToken = srslylawlUI.PowerBar.EventToTokenTable[powerToken]
    powerToken = eventToToken and eventToToken or powerToken
    srslylawlUI.PowerBar.GetBar(parent, nil, powerToken):RuneUpdate()
end

function srslylawlUI.GetSpecID()
    local specIndex = GetSpecialization()
    return GetSpecializationInfo(specIndex)
end