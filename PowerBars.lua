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
    [1455] = 1, --Initial DK (no spec)
    --DH
    [577] = 0, --Havoc
    [581] = 0, --Vengeance
    [1456] = 0, --Initial DH (no spec)
    --Druid
    [102] = 3, --Balance
    [103] = 3, --Feral
    [104] = 3, --Guardian
    [105] = 3, --Restoration
    [1447] = 3, --Initial Druid (no spec)
    --Evoker
    [1465] = 1, --Initial Evoker (no spec)
    [1467] = 1, --Devastation
    [1468] = 1, --Preservation
    --Hunter
    [253] = 0, --BM
    [254] = 0, --Marksmanship
    [255] = 0, --Survival
    [1448] = 0, --Initial Hunter (no spec)
    --Mage
    [62] = 1, --Arcane
    [63] = 0, --Fire
    [64] = 0, --Frost
    [1449] = 0, --Initial Mage (no spec)
    --Monk
    [268] = 2, --Brewmaster
    [269] = 1, --Windwalker
    [270] = 0, --Mistweaver
    [1450] = 0, --Initial Monk (no spec)
    --Paladin
    [65] = 1, --Holy
    [66] = 1, --Protection
    [70] = 1, --Retribution
    [1451] = 1, --Initial
    --Priest
    [256] = 0, --Discipline
    [257] = 0, --Holy
    [258] = 2, --Shadow
    [1452] = 0, --Initial Priest
    --Rogue
    [259] = 1, --Assassination
    [260] = 1, --Outlaw
    [261] = 1, --Subtlety
    [1453] = 1, --Initial
    --Shaman
    [262] = 2, --Elemental
    [263] = 0, --Enhancement
    [264] = 0, --Restoration
    [1444] = 0, --Initial
    --Warlock
    [265] = 1, --Affliction
    [266] = 1, --Demonology
    [267] = 1, --Destruction
    [1454] = 1, --Initial Warlock (no spec)
    --Warrior
    [71] = 0, --Arms
    [72] = 0, --Fury
    [73] = 0, --Protection
    [1446] = 0, --Initial Warrior (no spec)
}

srslylawlUI.PowerBar.SpecToPowerType = {
    --DK
    [250] = "Runes", --Blood
    [251] = "Runes", --Frost
    [252] = "Runes", --Unholy
    [1455] = "Runes", --Initial
    --Evoker
    [1465] = "Essence", --Initial
    [1467] = "Essence", --Devastation
    [1468] = "Essence", --Preservation
    --Mage
    [62] = "ArcaneCharges", --Arcane
    --Monk
    [268] = "Stagger", --Brewmaster
    [269] = "Chi", --Windwalker
    --Paladin
    [65] = "HolyPower", --Holy
    [66] = "HolyPower", --Protection
    [70] = "HolyPower", --Retribution
    [1451] = "HolyPower", --Initial
    --Priest
    [258] = "Mana", --Shadow
    --Rogue
    [259] = "ComboPoints", --Assassination
    [260] = "ComboPoints", --Outlaw
    [261] = "ComboPoints", --Subtlety
    [1453] = "ComboPoints", --Initial
    --Shaman
    [262] = "Mana", --Elemental
    [263] = 0, --Enhancement
    --Warlock
    [265] = "SoulShards", --Affliction
    [266] = "SoulShards", --Demonology
    [267] = "SoulShards", --Destruction
    [1454] = "SoulShards", --Initial
}

srslylawlUI.PowerBar.EventToTokenTable = {
    MANA = "Mana",
    RAGE = "Rage",
    FOCUS = "Focus",
    ENERGY = "Energy",
    ESSENCE = "Essence",
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
    Mana          = { hideWhenInactive = true, inactiveState = "FULL" },
    Rage          = { hideWhenInactive = true, inactiveState = "EMPTY" },
    Focus         = { hideWhenInactive = true, inactiveState = "FULL" },
    Energy        = { hideWhenInactive = true, inactiveState = "FULL" },
    ComboPoints   = { hideWhenInactive = true, inactiveState = "EMPTY" },
    Runes         = { hideWhenInactive = true, inactiveState = "FULL" },
    RunicPower    = { hideWhenInactive = true, inactiveState = "EMPTY" },
    SoulShards    = { hideWhenInactive = true, inactiveState = "SOULSHARDS" },
    Essence       = { hideWhenInactive = true, inactiveState = "FULL" },
    LunarPower    = { hideWhenInactive = true, inactiveState = "EMPTY" },
    HolyPower     = { hideWhenInactive = true, inactiveState = "EMPTY" },
    Maelstrom     = { hideWhenInactive = true, inactiveState = "EMPTY" },
    Insanity      = { hideWhenInactive = true, inactiveState = "EMPTY" },
    Chi           = { hideWhenInactive = true, inactiveState = "EMPTY" },
    ArcaneCharges = { hideWhenInactive = true, inactiveState = "EMPTY" },
    Fury          = { hideWhenInactive = true, inactiveState = "EMPTY" },
    Pain          = { hideWhenInactive = true, inactiveState = "EMPTY" },
    Stagger       = { hideWhenInactive = true, inactiveState = "EMPTY" },
}

local function PowerBarSetVisible(self, visible)
    if self.disabled or self.isUnparented then
        visible = false
    end
    if self:IsShown() ~= visible then
        self:SetShown(visible)
    end
end

function srslylawlUI.CreatePointBar(parent, amount, padding, name)
    local frame = CreateFrame("Frame", name, parent)
    frame.padding = padding
    frame.desiredButtonCount = amount
    srslylawlUI.CreateBackground(frame, 1, .8)
    frame.pointFrames = {}

    function frame:CreatePointFrame(parent, i)
        local pointFrame = CreateFrame("StatusBar", "$parent_PointBar" .. i, parent)
        pointFrame:SetStatusBarTexture(srslylawlUI.textures.PowerBarSprite)
        pointFrame:SetMinMaxValues(0, 1)
        pointFrame:SetValue(1)
        pointFrame.text = srslylawlUI.CreateCustomFontString(pointFrame, "$parent_point" .. i, 6, "GameTooltipTextSmall")
        pointFrame.text:SetPoint("CENTER", pointFrame, "CENTER", 0, 0)
        return pointFrame
    end

    function frame:StockPointFrames()
        if self.desiredButtonCount > #self.pointFrames then
            local index = #self.pointFrames
            while self.desiredButtonCount > index do
                index = index + 1
                self.pointFrames[index] = self:CreatePointFrame(self, index)
            end
        end
    end

    function frame:SetColor(color)
        if color then
            self.color = color
        else
            color = self.color
        end
        for i = 1, #self.pointFrames do
            if not self.pointFrames[i].isCharged then
                self.pointFrames[i]:SetStatusBarColor(color.r, color.g, color.b)
            end
        end
    end

    function frame:ResetPoints()
        for i = 1, #self.pointFrames do
            self.pointFrames[i]:SetValue(1)
            self.pointFrames[i].text:SetText("")
            self.pointFrames[i]:SetAlpha(1)
        end
    end

    function frame:SetButtonCount(newCount)
        self.desiredButtonCount = newCount
        self:SetPoints()
        self:SetColor()
        if self.OnButtonCountChanged ~= nil then self:OnButtonCountChanged() end
    end

    function frame:SetPoints(x, y)
        frame:StockPointFrames()

        if not x or not y then
            x, y = srslylawlUI.Utils_PixelFromScreenToCode(self:GetWidth(), self:GetHeight())
        end

        local desiredSize = x
        local totalSize = x
        local height = y
        local buttons = self.desiredButtonCount
        local totalpadding = (buttons - 1) * self.padding
        totalSize = totalSize - totalpadding
        local barSize = buttons == 0 and 0 or srslylawlUI.Utils_ScuffedRound(totalSize / buttons)
        totalSize = barSize * buttons + totalpadding
        local diff = desiredSize - totalSize
        local middleFrame = ceil(self.desiredButtonCount / 2)
        local pixelPerfectCompensation
        for i = 1, #self.pointFrames do
            local current = self.pointFrames[i]
            if i > self.desiredButtonCount then
                current:Hide()
            else
                current:Show()
            end
            if i == 1 then
                srslylawlUI.Utils_SetPointPixelPerfect(current, "BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
            else
                srslylawlUI.Utils_SetPointPixelPerfect(current, "BOTTOMLEFT", self.pointFrames[i - 1], "BOTTOMRIGHT",
                    self.padding, 0)
            end
            pixelPerfectCompensation = i == middleFrame and diff or 0
            srslylawlUI.Utils_SetSizePixelPerfect(current, barSize + pixelPerfectCompensation, height)

            current.text:ScaleToFit(barSize, height, 20)
        end
        srslylawlUI.Utils_SetSizePixelPerfect(self, totalSize + diff, height)
        if self.OnButtonCountChanged ~= nil then self:OnButtonCountChanged() end
    end

    return frame
end

local function SpecIDIsRogue(specID)
    return (specID >= 259 and specID <= 261) or specID == 1453
end

local function SpecIDIsWarlock(specID)
    return (specID >= 265 and specID <= 267) or specID == 1454
end

local function SpecIDIsDK(specID)
    return (specID >= 250 and specID <= 252) or specID == 1455
end

function srslylawlUI.PowerBar.CreatePowerPointBar(amount, parent, padding, powerToken, specID)
    if amount < 1 then error("Param1 'Amount' must be 1 or higher") return end
    -- local frame = CreateFrame("Frame", "$parent_PointResourceBar_" .. powerToken, parent)
    local frame = srslylawlUI.CreatePointBar(parent, amount, padding, "$parent_PointResourceBar_" .. powerToken)
    frame:SetAttribute("type", "pointBar")
    frame.powerToken = Enum.PowerType[powerToken]
    frame.unit = parent:GetAttribute("unit")
    frame.name = powerToken
    frame.hideWhenInactive = srslylawlUI.PowerBar.BarDefaults[powerToken].hideWhenInactive
    frame.inactiveState = srslylawlUI.PowerBar.BarDefaults[powerToken].inactiveState
    frame.specID = specID
    frame.reversed = false
    frame.OnButtonCountChanged = function(self)
        if self.powerToken == 5 then --is a runebar
            self:RuneUpdate()
        else
            self:Update()
        end
    end

    function frame:Update()
        if SpecIDIsWarlock(self.specID) then --warlock
            self:SoulshardUpdate()
            return
        elseif SpecIDIsRogue(self.specID) then --rogue
            self:RogueUpdate()
            return
        end
        local displayCount = UnitPower(self.unit, self.powerToken)
        if self.reversed then
            local reverseIndex = self.desiredButtonCount
            for i = 1, self.desiredButtonCount do
                self.pointFrames[reverseIndex]:SetShown(i <= displayCount)
                reverseIndex = reverseIndex - 1
            end
        else
            for i = 1, self.desiredButtonCount do
                self.pointFrames[i]:SetShown(i <= displayCount)
            end
        end

        self:UpdateVisible()
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

            local progress = current / duration
            rune.cd = cd
            rune:SetValue(progress)
            rune:SetAlpha(.5)

            rune:SetScript("OnUpdate", function(self, elapsed)
                current = GetTime() - start
                progress = current / duration
                progress = progress > 1 and 1 or progress
                self:SetValue(progress)
                self.text:SetFormattedText("%.1f", duration - current, 1)

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
            cd = runeReady and 0 or duration - current
            runeObject = { cd, start, current, duration, runeReady }
            table.insert(runeTable, #runeTable + 1, runeObject)

            if runeReady then
                runesReady = runesReady + 1
            end

            index = index + 1
            start, duration, runeReady = GetRuneCooldown(index)
        end

        if self.reversed then
            table.sort(runeTable, function(a, b)
                if a[1] > b[1] then
                    return true
                else
                    return false
                end
            end)
        else
            table.sort(runeTable, function(a, b)
                if a[1] < b[1] then
                    return true
                else
                    return false
                end
            end)
        end

        local rune
        for i = 1, #runeTable do
            rune = self.pointFrames[i]
            UpdateRuneTimer(rune, unpack(runeTable[i]))
        end

        local visible = true
        self.runesFull = runesReady == #runeTable
        if self.hideWhenInactive then
            if self.runesFull then
                visible = false
            end
        end
        PowerBarSetVisible(self, visible)
    end

    function frame:SoulshardUpdate()
        local pointsToDisplay
        if self.specID == 267 then --destro uses shardfragments
            local displayCount = UnitPower(self.unit, self.powerToken, true)
            pointsToDisplay = ceil(displayCount / 10)
            local progressLast = math.fmod(displayCount, 10)
            if self.reversed then
                local reverseIndex = #self.desiredButtonCount
                for i = 1, self.desiredButtonCount do
                    local pFrame = self.pointFrames[reverseIndex]
                    if i < pointsToDisplay then
                        pFrame:Show()
                        pFrame:SetAlpha(1)
                        pFrame.text:SetText("")
                        pFrame:SetValue(1)
                    elseif i == pointsToDisplay then
                        if progressLast > 0 then
                            pFrame:Show()
                            pFrame:SetAlpha(.5)
                            pFrame.text:SetText(progressLast)
                            pFrame:SetValue(progressLast / 10)
                        else
                            pFrame:Show()
                            pFrame:SetAlpha(1)
                            pFrame.text:SetText("")
                            pFrame:SetValue(1)
                        end
                    else
                        pFrame:Hide()
                    end
                    reverseIndex = reverseIndex - 1
                end
            else
                for i = 1, self.desiredButtonCount do
                    local pFrame = self.pointFrames[i]
                    if i < pointsToDisplay then
                        pFrame:Show()
                        pFrame:SetAlpha(1)
                        pFrame.text:SetText("")
                        pFrame:SetValue(1)
                    elseif i == pointsToDisplay then
                        if progressLast > 0 then
                            pFrame:Show()
                            pFrame:SetAlpha(.5)
                            pFrame.text:SetText(progressLast)
                            pFrame:SetValue(progressLast / 10)
                        else
                            pFrame:Show()
                            pFrame:SetAlpha(1)
                            pFrame.text:SetText("")
                            pFrame:SetValue(1)
                        end
                    else
                        pFrame:Hide()
                    end
                end
            end
        else
            pointsToDisplay = UnitPower(self.unit, self.powerToken)
            for i = 1, self.desiredButtonCount do
                self.pointFrames[i]:SetShown(i <= pointsToDisplay)
            end

        end

        local visible = true
        if self.hideWhenInactive then
            if pointsToDisplay == 3 and not InCombatLockdown() then
                visible = false
            end
        end
        PowerBarSetVisible(self, visible)
    end

    function frame:RogueUpdate()
        local displayCount = UnitPower(self.unit, self.powerToken)
        for i = 1, self.desiredButtonCount do
            local reverseIndex = #self.pointFrames
            local pFrame = self.reversed and self.pointFrames[reverseIndex] or self.pointFrames[i]
            local show = i <= displayCount
            if not pFrame.isCharged then
                pFrame:SetShown(show)
            else
                -- if not active, then set to .4 alpha instead of hiding it.
                if show then
                    pFrame:Show()
                    pFrame:SetAlpha(1)
                else
                    pFrame:Show()
                    pFrame:SetAlpha(.4)
                end
            end
            reverseIndex = reverseIndex - 1
        end

        local visible = true
        if self.hideWhenInactive then
            if self.inactiveState == "EMPTY" and displayCount == 0 then
                visible = false
            elseif self.inactiveState == "FULL" and displayCount == self.desiredButtonCount then
                visible = false
            end
        end
        visible = self.hasChargedPoint or visible
        PowerBarSetVisible(self, visible)
    end

    function frame:OnComboPointCharged()
        --rogue animacharge
        local chargedPointsTable = GetUnitChargedPowerPoints(self.unit)

        if chargedPointsTable then
            local chargedPoints = {}
            for i = 1, self.desiredButtonCount do
                chargedPoints[i] = false
            end
            for _, v in pairs(chargedPointsTable) do
                chargedPoints[v] = true
            end
            self.hasChargedPoint = true
            for i = 1, self.desiredButtonCount do
                local pf = self.pointFrames[i]
                local pointIsCharged = chargedPoints[i]
                if pointIsCharged then
                    pf.isCharged = true
                    pf:SetStatusBarColor(0.713, 0.101, 1)
                else
                    pf.isCharged = nil
                    pf:SetStatusBarColor(self.color.r, self.color.g, self.color.b)
                    pf:SetAlpha(1)
                end
            end
        elseif self.hasChargedPoint then
            self.hasChargedPoint = nil
            for i = 1, #self.pointFrames do
                self.pointFrames[i]:SetAlpha(1)
                self.pointFrames[i].isCharged = nil
            end
            self:SetColor(self.color)
        end
        self:RogueUpdate()
    end

    function frame:UpdateVisible()
        local visible = true
        if SpecIDIsDK(self.specID) then --dk
            self:RuneUpdate()
            return
        elseif SpecIDIsWarlock(self.specID) then --warlock
            self:SoulshardUpdate()
            return
        elseif SpecIDIsRogue(self.specID) then --rogue
            self:RogueUpdate()
            return
        end

        local displayCount = UnitPower(self.unit, self.powerToken)
        if self.hideWhenInactive then
            if self.inactiveState == "EMPTY" and displayCount == 0 then
                visible = false
            elseif self.inactiveState == "FULL" and displayCount == self.desiredButtonCount then
                visible = false
            end
        end
        PowerBarSetVisible(self, visible)
    end

    function frame:SetReverseFill(bool)
        if self.reversed ~= bool then
            self.reversed = bool
            if SpecIDIsDK(self.specID) then
                self:RuneUpdate()
            else
                self:Update()
            end
        end
    end

    frame:SetPoints()
    frame:OnButtonCountChanged()

    return frame
end

function srslylawlUI.PowerBar.CreateResourceBar(parent, powerToken, specID)
    local frame = CreateFrame("Frame", "$parent_ResourceBar_" .. powerToken, parent)
    srslylawlUI.CreateBackground(frame, 1, .8)
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
    frame.name = powerToken
    frame:SetAttribute("type", "resourceBar")
    frame.statusBar.rightText = srslylawlUI.CreateCustomFontString(frame.statusBar, "leftText",
        srslylawlUI.GetSetting("player.playerFrame.power.fontSize"))
    frame.statusBar.rightText:SetPoint("CENTER", frame.statusBar, "CENTER", 0, 0)
    frame.specID = specID

    frame.reversed = false

    frame.hideWhenInactive = srslylawlUI.PowerBar.BarDefaults[powerToken].hideWhenInactive
    frame.inactiveState = srslylawlUI.PowerBar.BarDefaults[powerToken].inactiveState
    frame.hideInCombat = srslylawlUI.PowerBar.BarDefaults[powerToken].hideInCombat

    function frame:SetColor(color)
        self.color = color
        self.statusBar:SetStatusBarColor(color.r, color.g, color.b)
    end

    function frame:UpdateVisible()
        local amount = UnitPower(self.unit, self.powerToken)
        local visible = true
        if self.hideWhenInactive then
            if self.inactiveState == "EMPTY" and amount < 1 then
                visible = false
            elseif self.inactiveState == "FULL" and abs(self.max - amount) < 1 then
                visible = false
            elseif self.inactiveState == "SOULSHARDS" and abs(amount - 300) <= 1 then
                visible = false
            end
        end

        PowerBarSetVisible(self, visible)
    end

    function frame:Update()
        local amount = UnitPower(self.unit, self.powerToken)
        self.statusBar.rightText:SetText(amount > 0 and amount or "")
        self.statusBar:SetValue(amount)

        self:UpdateVisible()
    end

    function frame:UpdateMax()
        self.max = UnitPowerMax(self.unit, self.powerToken)
        self.statusBar:SetMinMaxValues(0, frame.max)
        self:Update()
    end

    function frame:SetReverseFill(bool)
        if self.reversed ~= bool then
            self.reversed = bool
            self.statusBar:SetReverseFill(bool)
        end
    end

    function frame:SetPoints()
        local w, h = srslylawlUI.Utils_PixelFromScreenToCode(self:GetWidth(), self:GetHeight())
        self.statusBar.rightText:ScaleToFit(w, h, 20)
    end

    if frame.powerToken then
        frame:UpdateMax()
    end



    return frame
end

local height = 25
local height2 = 20
local height3 = 15


function srslylawlUI.PowerBar.Set(parent, unit)
    parent:UnregisterAll()
    parent.specID = srslylawlUI.GetSpecID()
    local function DisplayMainBar(parent)
        local _, powerToken = UnitPowerType("player")
        powerToken = srslylawlUI.PowerBar.EventToTokenTable[powerToken]
        local bar = srslylawlUI.PowerBar.GetBar(parent, "resource", powerToken)
        parent:RegisterBar(bar, 3, height)
    end

    if not parent.powerBars then
        parent.powerBars = {}
    end
    local barType = srslylawlUI.PowerBar.GetType()
    if barType == srslylawlUI.PowerBar.Type.None then
        --No Additional Bar
        DisplayMainBar(parent)
        return
    elseif barType == srslylawlUI.PowerBar.Type.ResourceBar then
        DisplayMainBar(parent)
        --Resource Bar
        local powerToken = srslylawlUI.PowerBar.GetPowerToken()
        local bar = srslylawlUI.PowerBar.GetBar(parent, "resource", powerToken)
        if powerToken == "Stagger" then
            srslylawlUI.PowerBar.SetupStaggerBar(bar, parent)
        end
        parent:RegisterBar(bar, 5, floor(height2))
    elseif barType == srslylawlUI.PowerBar.Type.PointBar then
        --Point Bar
        DisplayMainBar(parent)
        local powerToken = srslylawlUI.PowerBar.GetPowerToken()
        local bar = srslylawlUI.PowerBar.GetBar(parent, "point", powerToken)
        bar:ResetPoints()
        parent:RegisterBar(bar, 5, floor(height2))
        if parent.specID >= 250 and parent.specID <= 252 and not bar.isRegistered then --dk spec, use rune update
            bar:RegisterEvent("RUNE_POWER_UPDATE")
            bar:RegisterEvent("PLAYER_REGEN_ENABLED")
            bar:SetScript("OnEvent", function(self, event, ...)
                self:RuneUpdate()
            end)
            bar.isRegistered = true
        elseif parent.specID >= 259 and parent.specID <= 261 and not bar.isRegistered then --is rogue, check for kyrian ability cp chargedPointsTable
            bar:RegisterEvent("UNIT_POWER_POINT_CHARGE")
            bar:RegisterEvent("PLAYER_REGEN_ENABLED")
            bar:SetScript("OnEvent", function(self, event, ...)
                self:OnComboPointCharged()
            end)
            bar.isRegistered = true
        elseif parent.specID >= 265 and parent.specID <= 267 then -- warlock
            bar:RegisterEvent("PLAYER_REGEN_ENABLED")
            bar:SetScript("OnEvent", function(self, event, ...)
                self:SoulshardUpdate()
            end)
        end

    elseif barType == srslylawlUI.PowerBar.Type.Special then
        --player is druid
        srslylawlUI.PowerBar.SetupDruidBars(parent, unit)
    end
    parent:SortBars()
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
    if powerToken == 4 then -- for some reason cp get converted to chi
        colortoken = "COMBO_POINTS"
    end
    local color = srslylawlUI.Frame_GetCustomPowerBarColor(colortoken)
    if color then
        bar:SetColor(color)
    end
end

function srslylawlUI.PowerBar.GetPowerToken()
    return srslylawlUI.PowerBar.SpecToPowerType[srslylawlUI.GetSpecID()]
end

function srslylawlUI.PowerBar.GetBar(parent, type, token)
    local specID = parent.specID
    if not parent.powerBars[token] then
        if token == "Stagger" then
            parent.powerBars[token] = srslylawlUI.PowerBar.CreateResourceBar(parent, token, specID)
        end
        if type == "resource" or type == nil then
            parent.powerBars[token] = srslylawlUI.PowerBar.CreateResourceBar(parent, token, specID)
        elseif type == "point" then
            local maxPoints = UnitPowerMax("player", Enum.PowerType[token])
            parent.powerBars[token] = srslylawlUI.PowerBar.CreatePowerPointBar(maxPoints, parent, 1, token, specID)
        end
        srslylawlUI.PowerBar.SetColorByToken(parent.powerBars[token], Enum.PowerType[token])
        parent.powerBars[token]:SetAttribute("powerToken", token)
    end
    parent.powerBars[token].specID = specID
    return parent.powerBars[token]
end

function srslylawlUI.PowerBar.SetupDruidBars(parent, unit)
    local specID = srslylawlUI.GetSpecID()
    local manaBar = srslylawlUI.PowerBar.GetBar(parent, "resource", "Mana")
    local cpBar = srslylawlUI.PowerBar.GetBar(parent, "point", "ComboPoints")
    local energyBar = srslylawlUI.PowerBar.GetBar(parent, "resource", "Energy")
    local rageBar = srslylawlUI.PowerBar.GetBar(parent, "resource", "Rage")
    local astralPowerBar = srslylawlUI.PowerBar.GetBar(parent, "resource", "LunarPower")
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

    -- rageBar:Hide() -- since it resets to 25 on bear enter anyway
    if specID ~= 103 then --if not feral we dont care about energy
        energyBar:Hide()
    end
    if specID ~= 102 then
        astralPowerBar:Hide() --if not moonkin we dont care about astral
    end
    if currentStance == nil or currentStance == 31 then
        --human/owl
        if specID == 102 then -- balance
            -- main bar is now astral power, show mana and cp if needed
            parent:RegisterBar(astralPowerBar, 1, height)
            parent:RegisterBar(manaBar, 2, height2)
            parent:RegisterBar(cpBar, 3, height3)
        elseif specID == 103 then -- feral
            parent:RegisterBar(energyBar, 1, height)
            parent:RegisterBar(cpBar, 2, height2)
            parent:RegisterBar(manaBar, 3, height3)
        else
            parent:RegisterBar(manaBar, 1, height)
            parent:RegisterBar(cpBar, 2, height2)
        end
    elseif currentStance == 3 or currentStance == 4 or currentStance == 27 or currentStance == 29 then
        --travelforms, default main bar is now mana
        if specID == 102 then -- balance
            parent:RegisterBar(astralPowerBar, 1, height)
            parent:RegisterBar(manaBar, 2, height2)
            parent:RegisterBar(cpBar, 3, height3)
        elseif specID == 103 then -- feral
            parent:RegisterBar(energyBar, 1, height)
            parent:RegisterBar(cpBar, 2, height2)
            parent:RegisterBar(manaBar, 3, height3)
        else
            parent:RegisterBar(manaBar, 1, height)
            parent:RegisterBar(cpBar, 2, height2)
        end
    elseif currentStance == 1 then
        --cat form, default is energy
        parent:RegisterBar(energyBar, 1, height)
        parent:RegisterBar(cpBar, 2, height2)
        local index = 3
        if specID == 102 then -- balance
            parent:RegisterBar(astralPowerBar, index, height3)
            index = index + 1
        end
        parent:RegisterBar(manaBar, index, height3)
    elseif currentStance == 5 then
        --bear, default is rage
        parent:RegisterBar(rageBar, 1, height2)
        local index = 2
        if specID == 102 then -- balance
            parent:RegisterBar(astralPowerBar, index, height2)
            index = index + 1
        elseif specID == 103 then -- feral
            parent:RegisterBar(energyBar, index, height2)
            index = index + 1
        end
        parent:RegisterBar(manaBar, index, height3)
        index = index + 1
        parent:RegisterBar(cpBar, index, height3)
    end
end

function srslylawlUI.PowerBar.SetupStaggerBar(bar, parent)
    function bar:UpdateMax()
        self.max = UnitHealthMax(self.unit)
        self.statusBar:SetMinMaxValues(0, self.max)
        self:Update()
    end

    function bar:Update()
        self:UpdateVisible()
        local amount = UnitStagger(self.unit)

        if not self:IsShown() then
            return
        end
        self.statusBar:SetValue(amount)
        self.statusBar.rightText:SetText(amount)
        local percent = self.max == 0 and 0 or amount / self.max
        local color = percent < STAGGER_YELLOW_TRANSITION and { 0.662, 1, 0.541 }
            or percent < STAGGER_RED_TRANSITION and { 0.945, 0.933, 0.074 }
            or { 1, 0.039, 0.141 }
        self.statusBar:SetStatusBarColor(unpack(color))
    end

    function bar:UpdateVisible()
        local amount = UnitStagger(self.unit)

        local visible = true
        if self.hideWhenInactive then
            if amount < 1 then
                visible = false
            end
        end
        PowerBarSetVisible(self, visible)
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
    if powerToken then
        local bar = srslylawlUI.PowerBar.GetBar(parent, nil, powerToken)
        if not bar.disabled and not bar.isUnparented then
            --since bars we dont want to see can still get events(druid's rage in other forms, since it gets reset to 25 anyway), check for that here
            bar:Update()
        end
    else
        for _, bar in pairs(parent.powerBars) do
            if not bar.disabled and not bar.isUnparented then
                --since bars we dont want to see can still get events(druid's rage in other forms, since it gets reset to 25 anyway), check for that here
                bar:Update()
            end
        end
    end
end

function srslylawlUI.PowerBar.UpdateMax(parent, powerToken)
    local eventToToken = srslylawlUI.PowerBar.EventToTokenTable[powerToken]
    powerToken = eventToToken and eventToToken or powerToken
    srslylawlUI.PowerBar.GetBar(parent, nil, powerToken):UpdateMax()
end

function srslylawlUI.GetSpecID()
    local specIndex = GetSpecialization()
    return GetSpecializationInfo(specIndex)
end
