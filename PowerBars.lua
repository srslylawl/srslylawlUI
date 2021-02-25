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

function srslylawlUI.PowerBar.CreatePointBar(amount, parent, padding, powerToken)
    if amount < 1 then error("Param1 'Amount' must be 1 or higher") return end
    local frame = CreateFrame("Frame", "$parent_PointResourceBar_"..powerToken, parent)
    frame.padding = padding
    frame.desiredButtonCount = amount
    frame.sizeX = sizeX
    frame.sizeY = sizeY
    frame.bg = frame:CreateTexture("$parent_BG", "BACKGROUND")
    frame.bg:SetColorTexture(0, 0, 0, .5)
    frame:SetAttribute("type", "pointBar")
    frame.powerToken = Enum.PowerType[powerToken]
    frame.unit = parent:GetAttribute("unit")

    frame.pointFrames = {}

    local function CreatePointFrame(parent, i)
        local pointFrame = CreateFrame("StatusBar", "$parent_PointBar"..i, parent)
        pointFrame:SetStatusBarTexture(srslylawlUI.textures.PowerBarSprite)
        pointFrame:SetMinMaxValues(0, 1)
        pointFrame:SetValue(1)
        return pointFrame
    end
    function frame:SetColor(color)
        self.color = color
        for i=1, #self.pointFrames do
            self.pointFrames[i]:SetStatusBarColor(color.r, color.g, color.b)
        end
    end

    function frame:SetButtonCount(newCount)
        self.desiredButtonCount = newCount
        self:SetPoints()
    end

    function frame:SetPoints(x, y)
        self.sizeX = x and x or self.sizeX
        self.sizeY = y and y or self.sizeY
        if self.desiredButtonCount > #self.pointFrames then
            local index = #self.pointFrames
            while self.desiredButtonCount > index do
                self.pointFrames[index+1] = CreatePointFrame(frame, index)
                index = index + 1
            end
        end

        if not self.sizeX or not self.sizeY then
            self.sizeX, self.sizeY = srslylawlUI.Utils_PixelFromScreenToCode(self:GetWidth(), self:GetHeight())
            print(self.sizeX, self.sizeY)
        end

        local totalSize = self.sizeX
        local height = self.sizeY - 2*self.padding
        local buttons = self.desiredButtonCount
        local totalpadding = (buttons+1)*self.padding
        totalSize = totalSize - totalpadding
        local barSize = srslylawlUI.Utils_ScuffedRound(totalSize/buttons)
        totalSize = barSize*buttons+totalpadding
        -- print("totalSize: ", totalSize, "barheight", height, "barsize", barSize)
        for i=1, #self.pointFrames do
            local current = self.pointFrames[i]
            if i > self.desiredButtonCount then
                current:Hide()
            else
                current:Show()
            end
            if i == 1 then
                srslylawlUI.Utils_SetPointPixelPerfect(current, "BOTTOMLEFT", self, "BOTTOMLEFT", self.padding, self.padding)
            else
                srslylawlUI.Utils_SetPointPixelPerfect(current, "BOTTOMLEFT", self.pointFrames[i-1], "BOTTOMRIGHT", self.padding, 0)
            end
            srslylawlUI.Utils_SetSizePixelPerfect(current, barSize, height)

            if self.color then
                current:SetStatusBarColor(self.color.r, self.color.g, self.color.b)
            end
        end
        -- print("final:", totalSize, (height+2))
        srslylawlUI.Utils_SetSizePixelPerfect(self, totalSize, height+2)
        self.bg:SetAllPoints()
        -- self:SetPoint("BOTTOMLEFT", self:GetParent(), "BOTTOMLEFT", 0, 0)
        -- srslylawlUI.Frame_MakeFrameMoveable(self)
        self:Update()
    end

    function frame:Update()
        local displayCount = UnitPower(self.unit, self.powerToken)
        for i=1, self.desiredButtonCount do
            self.pointFrames[i]:SetShown(i <= displayCount)
        end
    end
    function frame:UpdateMax()
        print("updatemax")
        local maxPoints = UnitPowerMax(self.unit, self.powerToken)
        self:SetButtonCount(maxPoints)
    end

    -- frame:SetPoints()
    return frame
end

function srslylawlUI.PowerBar.CreateResourceBar(parent, powerToken)
    local frame = CreateFrame("Frame", "$parent_ResourceBar_"..powerToken, parent)
    srslylawlUI.CreateBackground(frame, 0)
    frame.statusBar = CreateFrame("StatusBar", "$parent_StatusBar", frame)
    frame.statusBar:SetStatusBarTexture(srslylawlUI.textures.PowerBarSprite)
    srslylawlUI.Utils_SetPointPixelPerfect(frame.statusBar, "TOPLEFT", frame, "TOPLEFT", 1, -1)
    srslylawlUI.Utils_SetPointPixelPerfect(frame.statusBar, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
    frame.powerToken = Enum.PowerType[powerToken]
    frame:SetAttribute("type", "statusBar")
    frame.unit = parent:GetAttribute("unit")

    function frame:SetColor(color)
        self.statusBar:SetStatusBarColor(color.r, color.g, color.b)
    end

    function frame:Update()
        self.statusBar:SetValue(UnitPower(self.unit, self.powerToken))
    end
    function frame:UpdateMax()
        local max = UnitPowerMax(self.unit, self.powerToken)
        self.statusBar:SetMinMaxValues(0, max)
        self:Update()
    end
    frame:UpdateMax()

    return frame
end
function srslylawlUI.PowerBar.Set(parent, unit)
    local function HideActiveBars()
        if not parent.powerBars then
            parent.powerBars = {}
        end
        for _, bar in pairs(parent.powerBars) do
            bar:Hide()
        end
    end
    local function DisplayMainBar(parent)
        local _, powerToken = UnitPowerType("player")
        powerToken = srslylawlUI.PowerBar.EventToTokenTable[powerToken]
        local bar = srslylawlUI.PowerBar.GetBar(parent, "resource", powerToken)
        srslylawlUI.PowerBar.PlaceBar(bar, parent, 1)
    end
    HideActiveBars()
    local barType = srslylawlUI.PowerBar.GetType()
    if barType == srslylawlUI.PowerBar.Type.None then
        --No Additional Bar
        DisplayMainBar(parent)
        return
    elseif barType == srslylawlUI.PowerBar.Type.ResourceBar then
        DisplayMainBar(parent)
        --Resource Bar
        local bar = srslylawlUI.PowerBar.GetBar(parent, "resource", srslylawlUI.PowerBar.GetPowerToken())
        srslylawlUI.PowerBar.PlaceBar(bar, parent, 2)
    elseif barType == srslylawlUI.PowerBar.Type.PointBar then
        --Point Bar
        DisplayMainBar(parent)
        local bar = srslylawlUI.PowerBar.GetBar(parent, "point", srslylawlUI.PowerBar.GetPowerToken())
        srslylawlUI.PowerBar.PlaceBar(bar, parent, 2)
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
    local color = srslylawlUI.Frame_GetCustomPowerBarColor(powerToken)
    bar:SetColor(color)
end
function srslylawlUI.PowerBar.GetPowerToken()
    local specIndex = GetSpecialization()
    local specID = GetSpecializationInfo(specIndex)
    return srslylawlUI.PowerBar.SpecToPowerType[specID]
end
function srslylawlUI.PowerBar.PlaceBar(bar, parent, index, height)
    if not parent.activePowerBars then
        parent.activePowerBars = {}
    end
    index = index == nil and 1 or index
    height = height or 40
    local localParent = index == 1 and parent or parent.activePowerBars[index-1]
    srslylawlUI.Utils_SetPointPixelPerfect(bar, "TOPLEFT", localParent, "BOTTOMLEFT", 0, -1)
    srslylawlUI.Utils_SetPointPixelPerfect(bar, "BOTTOMRIGHT", localParent, "BOTTOMRIGHT", 0, -1-height)
    parent.activePowerBars[index] = bar
    if bar:GetAttribute("type") == "pointBar" then
        bar:SetPoints(srslylawlUI.Utils_PixelFromScreenToCode(localParent:GetWidth()), height)
    end
    bar:Show()
end
function srslylawlUI.PowerBar.GetBar(parent, type, token)
    if not parent.powerBars[token] then
        if token == "Stagger" then
            error("stagger not yet implemented")
            return
        end
        if type == "resource" or type == nil then
            parent.powerBars[token] = srslylawlUI.PowerBar.CreateResourceBar(parent, token)
        elseif type == "point" then
            local maxPoints = UnitPowerMax("player", Enum.PowerType[token])
            parent.powerBars[token] = srslylawlUI.PowerBar.CreatePointBar(maxPoints, parent, 1, token)
        end
        srslylawlUI.PowerBar.SetColorByToken(parent.powerBars[token], Enum.PowerType[token])
    end
    return parent.powerBars[token]
end
function srslylawlUI.PowerBar.SetupDruidBars(parent, unit)
    local manaBar = srslylawlUI.PowerBar.GetBar(parent, "resource", "Mana")
    local cpBar = srslylawlUI.PowerBar.GetBar(parent, "point", "ComboPoints")
    local energyBar = srslylawlUI.PowerBar.GetBar(parent, "resource", "Energy")
    local rageBar = srslylawlUI.PowerBar.GetBar(parent, "resource", "Rage")
    local astralPowerBar = srslylawlUI.PowerBar.GetBar(parent, "resource", "LunarPower")
    local specID = GetInspectSpecialization(unit)
    local unitHasCP = UnitPower(unit, 4) > 0
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

    if currentStance == nil or currentStance == 31 then
        --human/owl
        if specID == 102 then -- balance
            -- main bar is now astral power, show mana and cp if needed
            srslylawlUI.PowerBar.PlaceBar(astralPowerBar, parent, 1)
            srslylawlUI.PowerBar.PlaceBar(manaBar, parent, 2)
            srslylawlUI.PowerBar.PlaceBar(cpBar, parent, 3)
        elseif specID == 103 then -- feral
            srslylawlUI.PowerBar.PlaceBar(astralPowerBar, parent, 1)
            srslylawlUI.PowerBar.PlaceBar(manaBar, parent, 2)
            srslylawlUI.PowerBar.PlaceBar(cpBar, parent, 3)
        else
            srslylawlUI.PowerBar.PlaceBar(manaBar, parent, 1)
            srslylawlUI.PowerBar.PlaceBar(cpBar, parent, 2)
        end
    elseif currentStance == 3 or currentStance == 4 or currentStance == 27 or currentStance == 29 then
        --travelforms, default main bar is now mana
        if specID == 102 then -- balance
            srslylawlUI.PowerBar.PlaceBar(astralPowerBar, parent, 1)
            srslylawlUI.PowerBar.PlaceBar(manaBar, parent, 2)
            srslylawlUI.PowerBar.PlaceBar(cpBar, parent, 3)
        elseif specID == 103 then -- feral
            srslylawlUI.PowerBar.PlaceBar(energyBar, parent, 1)
            local index = 2
            if unitHasCP then
                srslylawlUI.PowerBar.PlaceBar(cpBar, parent, index)
                index = index +1
            end
            srslylawlUI.PowerBar.PlaceBar(manaBar, parent, index)
        else
            srslylawlUI.PowerBar.PlaceBar(manaBar, parent, 1)
            srslylawlUI.PowerBar.PlaceBar(cpBar, parent, 2)
        end
    elseif currentStance == 1 then
        --cat form, default is energy
        srslylawlUI.PowerBar.PlaceBar(energyBar, parent, 1)
        srslylawlUI.PowerBar.PlaceBar(cpBar, parent, 2)
        local index = 3
        if specID == 102 then -- balance
            srslylawlUI.PowerBar.PlaceBar(astralPowerBar, parent, index)
            index = index + 1
        end
        srslylawlUI.PowerBar.PlaceBar(manaBar, parent, index)
    elseif currentStance == 5 then
        --bear, default is rage
        parent.
        srslylawlUI.PowerBar.PlaceBar(rageBar, parent, 1)
        local index = 2
        if specID == 102 then -- balance
            srslylawlUI.PowerBar.PlaceBar(astralPowerBar, parent, index)
            index = index + 1
        end
        srslylawlUI.PowerBar.PlaceBar(manaBar, parent, index)
        index = index + 1
        srslylawlUI.PowerBar.PlaceBar(cpBar, parent, index)
    end
    cpBar:SetShown(unitHasCP)
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

