local settings = {
    header = {
        anchor = "CENTER",
        xOffset = 10,
        yOffset = 10
    },
    hp = {
        width = 100,
        height = 50
    },
    pet = {
        width = 15
    },
    maxBuffs = 40,
    minAbsorbAmount = 100,
    spellList = {},
    approvedSpells = {},
    pendingSpells = {},
    autoApproveAbsorbKeyWord = true
}
local unsaved = {
    flag = false,
    buttons = {}
}
local anchored
local units = {} -- tracks auras and frames
local tooltip = CreateFrame("GameTooltip", "srslylawl_ScanTooltip", UIParent, "GameTooltipTemplate")

srslylawlUI = {}

srslylawlUI.sortTimerActive = false
srslylawlUI.clearTimerActive = false

--TODO: char tooltip
--      cleanup functions (sort by abc)
--      replace buffframes table stuff
--      debuffs
--      magic absorb
--      necrotic
--      defensive cooldowns
--      config window
srslylawlUI.AbsorbAuraBySpellIDDescending = function(absorbAuraTable)
    local t = {}

    for k, v in pairs(absorbAuraTable) do
        t[#t + 1] = absorbAuraTable[k]
    end
    table.sort(
        t,
        function(a, b)
            return b.spellID < a.spellID
        end
    )
    return t
end
function tableEquals(table1, table2)
    if table1 == table2 then
        return true
    end
    local table1Type = type(table1)
    local table2Type = type(table2)
    if table1Type ~= table2Type then
        return false
    end
    if table1Type ~= "table" then
        return false
    end

    local keySet = {}

    for key1, value1 in pairs(table1) do
        local value2 = table2[key1]
        if value2 == nil or tableEquals(value1, value2) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(table2) do
        if not keySet[key2] then
            return false
        end
    end
    return true
end
local function GetBuffText(buffIndex, unit, spellId)
    tooltip:SetOwner(srslylawlUI_PartyHeader, "ANCHOR_NONE")
    tooltip:SetUnitBuff(unit, buffIndex)
    local n2 = srslylawl_ScanTooltipTextLeft2:GetText()
    tooltip:Hide()
    return n2
end
function srslylawlUI.Log(text)
    print("|cff4D00FFsrslylawlUI:|r " .. text)
end
function srslylawlUI_GetSettings()
    return settings
end
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
local powerUpdateType = "UNIT_POWER_UPDATE" --"UNIT_POWER_UPDATE" or "UNIT_POWER_FRQUENT"
local function LoadSettings(reset, announce)
    if announce then
        srslylawlUI.Log("Settings Loaded")
    end
    settings = deepcopy(srslylawl_saved.settings)
    if srslylawlUI_ConfigFrame then
        srslylawlUI_ConfigFrame.sliders.height:SetValue(settings.hp.height)
        srslylawlUI_ConfigFrame.sliders.hpwidth:SetValue(settings.hp.width)
    end
    srslylawlUI_PartyHeader:ClearAllPoints()
    srslylawlUI_PartyHeader:SetPoint(settings.header.anchor, settings.header.xOffset, settings.header.yOffset)
    srslylawlUI_RemoveDirtyFlag()
    if (reset) then
        srslylawlUI.UpdateEverything()
    end
end
function srslylawlUI_ToggleConfigVisible(visible)
    if visible then
        srslylawlUI_ConfigFrame:Show()
        srslylawlUI_PartyHeader:SetMovable(true)
    else
        srslylawlUI_ConfigFrame:Hide()
        srslylawlUI_PartyHeader:SetMovable(false)
    end
end
local function SaveSettings()
    srslylawlUI.Log("Settings Saved")
    srslylawl_saved.settings = deepcopy(settings)
    srslylawlUI_RemoveDirtyFlag()
end
function srslylawlUI_InitialConfig(header, buttonFrame)
    -- header = PartyHeader
    buttonFrame = _G[buttonFrame]
    --local frameLevel = buttonFrame.unit:GetFrameLevel()
    --buttonFrame.unit:SetFrameLevel(2)
    buttonFrame.unit.healthBar:SetFrameLevel(2)
    buttonFrame.unit.powerBar:SetFrameLevel(2)
    buttonFrame.pet:SetFrameLevel(2)
    buttonFrame.pet.healthBar:SetFrameLevel(1)
    buttonFrame.unit:RegisterForDrag("LeftButton")
    buttonFrame:RegisterEvent("UNIT_HEALTH")
    buttonFrame:RegisterEvent("UNIT_MAXHEALTH")
    buttonFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    buttonFrame:RegisterEvent(powerUpdateType)
    buttonFrame:RegisterEvent("UNIT_DISPLAYPOWER")
    buttonFrame:RegisterEvent("UNIT_NAME_UPDATE")
    buttonFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    buttonFrame:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    buttonFrame:RegisterEvent("UNIT_CONNECTION")
    buttonFrame:RegisterEvent("UNIT_AURA")
    buttonFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    buttonFrame:RegisterEvent("UNIT_HEAL_PREDICTION")
    buttonFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    buttonFrame.unit:SetScript(
        "OnEnter",
        function(self)
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:SetUnit("player")
        end
    )

    RegisterUnitWatch(buttonFrame.pet)
    buttonFrame.pet:SetFrameRef("unit", buttonFrame.unit)

    srslylawlUI_CreateBackground(buttonFrame.pet)
    if (buttonFrame.unit.healthBar["bg"] == nil) then
        srslylawlUI_CreateBackground(buttonFrame.unit.healthBar)
    end
    buttonFrame.unit.healthBar.name:SetPoint("BOTTOMLEFT", buttonFrame.unit, "BOTTOMLEFT", 2, 2)
    buttonFrame.unit.healthBar.text:SetPoint("BOTTOMRIGHT", 2, 2)
    --buttonFrame.unit.healthBar.text:SetDrawLayer("OVERLAY")
    buttonFrame.unit.auras = {}
    srslylawlUI_Frame_ResetDimensions(buttonFrame)
end
function srslylawlUI_CreateBackground(frame)
    local background = CreateFrame("Frame", "$parent_background", frame)
    local t = background:CreateTexture(nil, "BACKGROUND")
    t:SetColorTexture(0, 0, 0, .5)
    t:SetAllPoints(background)
    background:SetPoint("CENTER", 0, 0)
    background:SetWidth(frame:GetWidth() + 2)
    background:SetHeight(settings.hp.height + 2)
    background.texture = t
    background:Show()
    background:SetFrameStrata("BACKGROUND")
    background:SetFrameLevel(1)
    frame.bg = background
end
local configString =
    [[
        -- me is UnitButtonFrameX
        local me = self:GetName()
        local partyHeader = self:GetParent()
        partyHeader:CallMethod("initialConfigFunction", me)
]]
function srslylawlUI_Frame_OnShow(button)
    -- button = UnitButtonX
    if button:GetName() == "srsylawlUI_PartyHeaderUnitButton2" then
        print("worked")
    --srslylawlUI.SortAfterLogin()
    end

    local unit = button:GetAttribute("unit")
    --i think the code below never executes since the button will never have the unit attribute on show (gets assigned later)
    if unit then
        local guid = UnitGUID(unit)
        if guid ~= button.guid then
            srslylawlUI_ResetUnitButton(button.unit, unit)
            srslylawlUI_ResetPetButton(button.pet, unit .. "pet")
            button.guid = guid
        end
    end
end
function srslylawlUI_ResetUnitButton(button, unit)
    if unit == nil then
        return
    end
    srslylawlUI_ResetHealthBar(button, unit)
    srslylawlUI_ResetPowerBar(button, unit)
    srslylawlUI_ResetName(button, unit)
    if UnitIsUnit(unit, "target") then
        button.selected:Show()
    else
        button.selected:Hide()
    end
end
function srslylawlUI_ResetName(button, unit)
    -- This function can return a substring of a UTF-8 string, properly handling UTF-8 codepoints. Rather than taking a start index and optionally an end index, it takes the string, the start index, and
    -- the number of characters to select from the string.
    local function utf8sub(str, start, numChars)
        local currentIndex = start
        while numChars > 0 and currentIndex <= #str do
            local char = string.byte(str, currentIndex)
            if char >= 240 then
                currentIndex = currentIndex + 4
            elseif char >= 225 then
                currentIndex = currentIndex + 3
            elseif char >= 192 then
                currentIndex = currentIndex + 2
            else
                currentIndex = currentIndex + 1
            end
            numChars = numChars - 1
        end
        return str:sub(start, currentIndex - 1)
    end

    local name = UnitName(unit) or UNKNOWN
    local substring
    local maxLength = settings.hp.width
    for length = #name, 1, -1 do
        substring = utf8sub(name, 1, length)
        button.healthBar.name:SetText(substring)
        if button.healthBar.name:GetStringWidth() <= maxLength then
            return
        end
    end
    local status = UnitThreatSituation(unit)
    if status and status > 0 then
        local r, g, b = GetThreatStatusColor(status)
        button.name:SetTextColor(r, g, b)
    else
        button.name:SetTextColor(1, 1, 1)
    end
end
function srslylawlUI_ResetPetButton(button, unit)
    if UnitExists(unit) then
        local health = UnitHealth(unit)
        local maxHealth = UnitHealth(unit)
        button.healthBar:SetMinMaxValues(0, maxHealth)
        button.healthBar:SetValue(health)
    end
end
function srslylawlUI_ResetHealthBar(button, unit)
    local class = select(2, UnitClass(unit)) or "WARRIOR"
    local classColor = RAID_CLASS_COLORS[class]
    local alive = not UnitIsDeadOrGhost(unit)
    local health = UnitHealth(unit)
    local healthMax = UnitHealthMax(unit)
    local healthPercent = ceil(health / healthMax * 100)
    local online = UnitIsConnected(unit)
    button.healthBar.text:SetText(health .. "/" .. healthMax .. " " .. healthPercent .. "%")
    if not alive or not online then
        -- If dead, set bar color to grey and fill bar
        button.healthBar:SetStatusBarColor(0.3, 0.3, 0.3)
        button.healthBar:SetMinMaxValues(0, 1)
        button.healthBar:SetValue(1)
        button.dead = true
        if not online then
            button.healthBar.text:SetText("offline")
        end
    else
        button.healthBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
        button.healthBar:SetMinMaxValues(0, healthMax)
        button.healthBar:SetValue(health)
        srslylawlUI_MoveAbsorbAnchorWithHealth(unit)
        button.dead = false
    end
end
function srslylawlUI_ResetPowerBar(button, unit)
    local powerType, powerToken = UnitPowerType(unit)
    local powerColor = srlylawlUI_GetCustomPowerColor(powerToken)
    local alive = not UnitIsDeadOrGhost(unit)
    local online = UnitIsConnected(unit)
    if alive and online then
        button.powerBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
    else
        button.powerBar:SetStatusBarColor(0.3, 0.3, 0.3)
    end
    button.powerBar:SetMinMaxValues(0, UnitPowerMax(unit))
    button.powerBar:SetValue(UnitPower(unit))
end
function srlylawlUI_GetCustomPowerColor(powerToken)
    local color = PowerBarColor[powerToken]
    if powerToken == "MANA" then
        color.r, color.g, color.b = 0.349, 0.522, 0.953
    end
    return color
end
function srslylawlUI_Button_OnDragStart(self, button)
    if not srslylawlUI_PartyHeader:IsMovable() then
        return
    end

    local grpMembers = GetNumGroupMembers()
    if grpMembers == 0 then
        srslylawlUI_PartyHeaderUnitButton1:SetPoint("TOPLEFT", srslylawlUI_PartyHeader, "TOPLEFT")
    else
        for i = 1, grpMembers do
            local buttonFrame
            if i == 1 then
                buttonFrame = srslylawlUI_PartyHeaderUnitButton1
                print(buttonFrame:GetName())
            else
                buttonFrame = srslylawlUI_GetFrameByUnitType(u)
            end
            if (buttonFrame) then
                buttonFrame:ClearAllPoints()
                if i == 1 then
                    buttonFrame:SetPoint("TOPLEFT", srslylawlUI_PartyHeader, "TOPLEFT")
                else
                    local parent = srslylawlUI_GetFrameByUnitType("party" .. i - 1)
                    if i == 2 then
                        parent = srslylawlUI_PartyHeaderUnitButton1
                    end
                    buttonFrame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT")
                end
                srslylawlUI_ResetUnitButton(buttonFrame.unit, "party" .. i)
            end
        end
    end
    srslylawlUI_PartyHeader:StartMoving()
    srslylawlUI_PartyHeader.isMoving = true
end
function srslylawlUI_Button_OnDragStop(self, button)
    if srslylawlUI_PartyHeader.isMoving then
        srslylawlUI_PartyHeader:StopMovingOrSizing()
        local point, relativeTo, relativePoint, xOfs, yOfs = srslylawlUI_PartyHeader:GetPoint()
        settings.header.anchor = point
        settings.header.xOffset = xOfs
        settings.header.yOffset = yOfs
        srslylawlUI_SetDirtyFlag()
        SortPartyFrames()
    end
end
local function ShowHideAllUnits()
    for k, v in ipairs(srslylawlUI_PartyHeader) do
        v:Hide()
        v:Show()
    end
end
srslylawlUI_Frame_OnEvent = function(self, event, arg1, ...)
    local unit = self:GetAttribute("unit")
    if not unit then
        return
    end
    -- Handle any events that don’t accept a unit argument
    if event == "PLAYER_ENTERING_WORLD" then
        srslylawlUI_Frame_HandleAuras(self.unit, unit, true)
    elseif event == "GROUP_ROSTER_UPDATE" then
        srslylawlUI_ResetUnitButton(self.unit, unit)
    elseif event == "PLAYER_TARGET_CHANGED" then
        if UnitIsUnit(unit, "target") then
            self.unit.selected:Show()
        else
            self.unit.selected:Hide()
        end
    elseif arg1 and UnitIsUnit(unit, arg1) then
        if event == "UNIT_MAXHEALTH" then
            srslylawlUI_ResizeHealthBarScale()
            if self.unit.dead ~= UnitIsDeadOrGhost(unit) then
                srslylawlUI_ResetUnitButton(self.unit, unit)
            end
            self.unit.healthBar:SetMinMaxValues(0, UnitHealthMax(unit))
            self.unit.healthBar:SetValue(UnitHealth(unit))
        elseif event == "UNIT_HEALTH" then
            srslylawlUI_ResetHealthBar(self.unit, unit)
        elseif event == "UNIT_DISPLAYPOWER" then
            srslylawlUI_ResetPowerBar(self.unit, unit)
        elseif event == powerUpdateType then
            self.unit.powerBar:SetValue(UnitPower(unit))
        elseif event == "UNIT_NAME_UPDATE" then
            srslylawlUI_ResetName(self.unit, unit)
        elseif event == "UNIT_THREAT_SITUATION_UPDATE" then
            local status = UnitThreatSituation(unit)
            if status and status > 0 then
                local r, g, b = GetThreatStatusColor(status)
                self.unit.healthBar.name:SetTextColor(r, g, b)
            else
                self.unit.healthBar.name:SetTextColor(1, 1, 1)
            end
        elseif event == "UNIT_CONNECTION" then
            srslylawlUI_ResetHealthBar(self.unit, unit)
            srslylawlUI_ResetPowerBar(self.unit, unit)
            srslylawlUI.Log(UnitName(unit) .. " went on/offline")
        elseif event == "UNIT_AURA" then
            srslylawlUI_Frame_HandleAuras(self.unit, unit)
        elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            srslylawlUI_Frame_HandleAuras(self.unit, unit, true)
        elseif event == "UNIT_HEAL_PREDICTION" then
            --srslylawlUI_MoveAbsorbAnchorWithHealth(unit)
            srslylawlUI_Frame_HandleAuras(self.unit, unit, true)
        end
    elseif arg1 and UnitIsUnit(unit .. "pet", arg1) then
        if event == "UNIT_MAXHEALTH" then
            self.pet.healthBar:SetMinMaxValues(0, UnitHealthMax(arg1))
            self.pet.healthBar:SetValue(UnitHealth(arg1))
        elseif event == "UNIT_HEALTH" then
            self.pet.healthBar:SetValue(UnitHealth(arg1))
        end
    end
end
function srslylawlUI_ResizeHealthBarScale()
    --print("resize scale")
    local list, highestHP, averageHP = srslylawlUI_GetPartyHealth()

    local scaleByHighest = true
    local lowerCap = 0.45 --bars can not get smaller than this percent of highest
    local pixelPerHp = settings.hp.width / highestHP
    local minWidth = floor(highestHP * pixelPerHp * lowerCap)

    if scaleByHighest then
        for unit, _ in pairs(units["healthBars"]) do
            local scaledWidth = (units["healthBars"][unit]["maxHealth"] * pixelPerHp)
            local scaledWidth = scaledWidth < minWidth and minWidth or scaledWidth
            units["healthBars"][unit]["width"] = scaledWidth
        end
    else -- sort by average
    end
    srslylawlUI_Frame_Reset_All()
end
function srslylawlUI_CreateNameListString()
    local list = srslylawlUI_GetPartyHealth()

    local nameString = ""

    for i = 1, #list do
        local u = list[i].name
        if i == 1 then
            nameString = nameString .. u
        else
            nameString = nameString .. "," .. u
        end
    end
    return nameString
end
local function GetUnitNameWithServer(unit)
    local name, server
    if (UnitExists(unit)) then
        name, server = UnitName(unit)
        if (server and server ~= "") then
            name = name .. "-" .. server
        end
    end
    return name
end
function srslylawlUI_GetPartyHealth()
    --print("gethealth called")
    if units["healthBars"] == nil then
        units["healthBars"] = {}
    end

    local nameStringSortedByHealthDesc = {}
    local hasUnknownMember = false

    local highestHP, averageHP, memberCount = 0, 0, 0

    local currentUnit = "player"
    local partyIndex = 0
    if not UnitExists("player") then
        print("XXXXXX player doesnt exist? XXXXX")
    else
        --loop through all units
        repeat
            if units["healthBars"][currentUnit] == nil then
                units["healthBars"][currentUnit] = {}
            end
            local maxHealth = UnitHealthMax(currentUnit)
            if maxHealth > highestHP then
                highestHP = maxHealth
            end
            local name = GetUnitNameWithServer(currentUnit)

            if name == "Unknown" or maxHealth == 1 then
                hasUnknownMember = true
            end

            units["healthBars"][currentUnit]["maxHealth"] = maxHealth
            units["healthBars"][currentUnit]["unit"] = currentUnit
            units["healthBars"][currentUnit]["name"] = name

            averageHP = averageHP + maxHealth
            table.insert(nameStringSortedByHealthDesc, units["healthBars"][currentUnit])
            memberCount = memberCount + 1
            currentUnit = "party" .. memberCount
        until not UnitExists(currentUnit)
    end

    table.sort(
        nameStringSortedByHealthDesc,
        function(a, b)
            return b.maxHealth < a.maxHealth
        end
    )
    averageHP = floor(averageHP / memberCount)

    return nameStringSortedByHealthDesc, highestHP, averageHP, hasUnknownMember
end
local function srslylawlUI_RememberSpellID(id, buffIndex, unit)
    local function ProcessID(spellId, buffIndex, unit)
        local spellName = GetSpellInfo(id)
        local buffText = GetBuffText(buffIndex, unit)
        local buffLower
        local buffLower = buffText
        if buffText ~= nil then
            buffLower = string.lower(buffText)
        else
            buffLower = ""
        end
        local keyWordAbsorb = buffLower:match("absorb") and true or false --returns true if has absorb in text, false if otherwise

        settings.spellList[id] = {
            name = spellName,
            text = buffText,
            hasAbsorbKeyWord = keyWordAbsorb
        }

        if keyWordAbsorb and settings.autoApproveAbsorbKeyWord then
            if (settings.approvedSpells[id] == nil) then
                --first time entry
                srslylawlUI.Log("spell auto-approved " .. spellName .. "!")
            else
                --srslylawlUI.Log("spell updated " .. spellName .. "!")
            end

            settings.approvedSpells[id] = {
                name = spellName,
                text = buffText,
                hasAbsorbKeyWord = keyWordAbsorb
            }
            srslylawl_saved.settings.approvedSpells = deepcopy(settings.approvedSpells)
        else
            if settings.pendingSpells[id] == nil then
                --first time entry
                srslylawlUI.Log("new spell encountered: " .. spellName .. "!")
            else
                --srslylawlUI.Log("spell updated " .. spellName .. "!")
            end

            settings.pendingSpells[id] = {
                name = spellName,
                text = buffText,
                hasAbsorbKeyWord = keyWordAbsorb
            }
        end

        srslylawl_saved.settings.spellList = deepcopy(settings.spellList)
        srslylawl_saved.settings.pendingSpells = deepcopy(settings.pendingSpells)
    end
    if settings.spellList[id] then
        --already seen
        --does it have a new tooltip though?
        local s = GetBuffText(buffIndex, unit)
        if
            settings.spellList[id].text == nil or settings.spellList[id].text ~= s or settings.approvedSpells[id] == nil or
                settings.pendingSpells[id]
         then
            --update text
            ProcessID(id, buffIndex, unit)
        end
    else
        ProcessID(id, buffIndex, unit)
    end
end
function srslylawlUI_ApproveSpellID(id)
    --we dont have the same tooltip that we get from unit buffindex and slot, so we dont save it
    --it should get added updated though once we ever see it on any party members
    srslylawlUI.Log("spell approved: " .. id .. "!")
    settings.approvedSpells[id] = {
        name = GetSpellInfo(id)
    }
    if settings.pendingSpells[id] ~= nil then
        table.remove(settings.pendingSpells, id)
    end
    srslylawl_saved.settings.spellList = deepcopy(settings.spellList)
    srslylawl_saved.settings.pendingSpells = deepcopy(settings.pendingSpells)
end
function tablelength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end
function srslylawlUI_Frame_HandleAuras(unitbutton, unit, absorbChanged)
    -- Buffs --
    ---create frames for this unittype
    if units[unit] == nil then
        unitbutton.buffFrames = {}
        units[unit] = {
            absorbAuras = {},
            absorbAurasByIndex = {},
            buffFrames = {},
            activeAbsorbFrames = 0
        }
        for i = 1, 40 do
            local xOffset = -17
            local parent = _G[unit .. "_" .. (i - 1)]
            if (i == 1) then
                parent = unitbutton
                xOffset = -29
            end
            local f = CreateFrame("Button", unit .. "_" .. i, parent, "CompactBuffTemplate")
            f:SetPoint("TOPLEFT", xOffset, 0)
            f:SetAttribute("unit", unit)
            f:SetScript("OnLoad", nil)
            f:SetScript(
                "OnEnter",
                function(self)
                    GameTooltip:SetOwner(f, "ANCHOR_RIGHT", 0, 0)
                    GameTooltip:SetUnitBuff(self:GetAttribute("unit"), self:GetID())
                end
            )
            f:SetScript(
                "OnUpdate",
                function(self)
                    if GameTooltip:IsOwned(f) then
                        GameTooltip:SetUnitBuff(self:GetAttribute("unit"), self:GetID())
                    end
                end
            )
            units[unit].buffFrames[i] = f
            unitbutton.buffFrames[i] = f
        end
    elseif unitbutton["buffFrames"] == nil then --frames exist but this unit doesnt own them yet
        --print("exist, reassigning")
        unitbutton.buffFrames = {}
        unitbutton.buffFrames = units[unit].buffFrames
        unitbutton.buffFrames[1]:SetParent(unitbutton)
    end
    local function trackSpell(castBy, id, name, index, absorb, icon, duration, expirationTime, verify)
        --if verify ~= true then
        --srslylawlUI.Log(name .. " added")
        --else
        --srslylawlUI.Log(name .. " verified ")
        --end

        if castBy == nil then
            castBy = "unknown"
        end
        if units[unit].absorbAuras[castBy] == nil then
            units[unit].absorbAuras[castBy] = {
                [id] = {
                    ["name"] = name,
                    ["index"] = index
                }
            }
        else
            units[unit].absorbAuras[castBy][id] = {
                ["name"] = name,
                ["index"] = index
            }
        end

        local diff = 0
        if verify then
            if units[unit].absorbAurasByIndex[index] ~= nil and units[unit].absorbAurasByIndex[index].expiration ~= nil then
                diff = expirationTime - units[unit].absorbAurasByIndex[index].expiration
            end
        end

        local flagRefreshed = (diff > 0.1)

        if units[unit].absorbAurasByIndex[index] == nil then
            units[unit].absorbAurasByIndex[index] = {}
        end
        --doing it this way since we dont want our tracked fragment to reset
        units[unit].absorbAurasByIndex[index]["castBy"] = castBy
        units[unit].absorbAurasByIndex[index]["name"] = name
        units[unit].absorbAurasByIndex[index]["spellID"] = id
        units[unit].absorbAurasByIndex[index]["checkedThisEvent"] = true
        units[unit].absorbAurasByIndex[index]["absorb"] = absorb
        units[unit].absorbAurasByIndex[index]["icon"] = icon
        units[unit].absorbAurasByIndex[index]["duration"] = duration
        units[unit].absorbAurasByIndex[index]["expiration"] = expirationTime
        units[unit].absorbAurasByIndex[index]["wasRefreshed"] = flagRefreshed
        units[unit].absorbAurasByIndex[index]["index"] = index --double index here to make it easier to get it again for tooltip
    end
    local function unTrackSpell(index)
        --print("untrack spell" .. units[unit].absorbAurasByIndex[index].name)
        local c = units[unit].absorbAurasByIndex[index].castBy
        local s = units[unit].absorbAurasByIndex[index].spellID
        local t = tablelength(units[unit].absorbAuras[c])

        --should be redundant check
        if t > 0 then
            units[unit].absorbAuras[c][s] = nil
        end

        units[unit].absorbAuras[c][s] = nil
        units[unit].absorbAurasByIndex[index] = nil
        t = tablelength(units[unit].absorbAuras[c])

        if t == 0 then
            units[unit].absorbAuras[c] = nil
        end
    end
    local function changeTrackingIndex(name, source, spellId, i, absorb, icon, duration, expirationTime)
        --srslylawlUI.Log("index changed " .. name)
        local oldIndex = units[unit].absorbAuras[source][spellId].index
        units[unit].absorbAuras[source][spellId].index = i

        --flag for timer refresh
        local diff = 0
        if
            units[unit].absorbAurasByIndex[oldIndex] ~= nil and
                units[unit].absorbAurasByIndex[oldIndex].expiration ~= nil
         then
            diff = expirationTime - units[unit].absorbAurasByIndex[oldIndex].expiration
        end

        local flagRefreshed = (diff > 0.1)

        if units[unit].absorbAurasByIndex[i] == nil then
            units[unit].absorbAurasByIndex[i] = {}
        end
        units[unit].absorbAurasByIndex[i]["castBy"] = source
        units[unit].absorbAurasByIndex[i]["name"] = name
        units[unit].absorbAurasByIndex[i]["spellID"] = spellId
        units[unit].absorbAurasByIndex[i]["checkedThisEvent"] = true
        units[unit].absorbAurasByIndex[i]["absorb"] = absorb
        units[unit].absorbAurasByIndex[i]["icon"] = icon
        units[unit].absorbAurasByIndex[i]["duration"] = duration
        units[unit].absorbAurasByIndex[i]["expiration"] = expirationTime
        units[unit].absorbAurasByIndex[i]["wasRefreshed"] = flagRefreshed
        units[unit].absorbAurasByIndex[i]["index"] = i

        if units[unit].absorbAurasByIndex[oldIndex]["trackedSegments"] ~= nil then
            if units[unit].absorbAurasByIndex[i]["trackedSegments"] == nil then
                units[unit].absorbAurasByIndex[i]["trackedSegments"] = {}
            end

            for index, segment in pairs(units[unit].absorbAurasByIndex[oldIndex]["trackedSegments"]) do
                units[unit].absorbAurasByIndex[i]["trackedSegments"][index] = segment
            end
        end

        local trackedApplyTime = units[unit].absorbAurasByIndex[oldIndex]["trackedApplyTime"]
        if trackedApplyTime ~= nil then
            units[unit].absorbAurasByIndex[i]["trackedApplyTime"] = trackedApplyTime
        end

        units[unit].absorbAurasByIndex[oldIndex] = nil
    end

    --frames exist and unit owns them
    --reset frame check verifier
    for k, v in pairs(units[unit].absorbAurasByIndex) do
        v["checkedThisEvent"] = false
    end
    for i = 1, 40 do
        --loop through all frames on standby and assign them based on their index
        local f = unitbutton.buffFrames[i]
        local nextFrame = unitbutton.buffFrames[i + 1]
        local name,
            icon,
            count,
            debuffType,
            duration,
            expirationTime,
            source,
            isStealable,
            nameplateShowPersonal,
            spellId,
            canApplyAura,
            isBossDebuff,
            castByPlayer,
            nameplateShowAll,
            timeMod,
            absorb = UnitAura(unit, i, "HELPFUL")
        if name then --if aura on this index exists, assign it
            if absorb ~= nil and absorb > 1 then
                srslylawlUI_RememberSpellID(spellId, i, unit)
            end
            CompactUnitFrame_UtilSetBuff(f, i, UnitAura(unit, i))
            f:SetID(i)
            f:Show()

            if units[unit].absorbAurasByIndex[i] == nil then
                --no aura is currently tracked for that index
                if settings.approvedSpells[spellId] then --spell is approved absorb
                    -- print(i)
                    -- if units[unit].absorbAuras[source] == nil then
                    --     print("no spells by this unit")
                    -- elseif units[unit].absorbAuras[source][spellId] == nil then
                    --     print("unit does not track " .. name .. " yet")
                    -- end
                    if units[unit].absorbAuras[source] == nil or units[unit].absorbAuras[source][spellId] == nil then
                        --aura is not tracked at all, track it!
                        -- print("added here 1")
                        trackSpell(source, spellId, name, i, absorb, icon, duration, expirationTime)
                    else
                        --aura is being tracked but at another index, change that
                        changeTrackingIndex(name, source, spellId, i, absorb, icon, duration, expirationTime)
                    end
                end
            else
                -- print(i .. "_else")
                --an aura at this index is currently being tracked, see if its this one
                if units[unit].absorbAurasByIndex[i]["spellID"] ~= spellId then
                    --the aura we are currently tracking at this index is not the displayed one
                    --stop tracking it
                    unTrackSpell(i)
                    --do we want to track our aura?
                    if settings.approvedSpells[spellId] then --spell is approved absorb
                        if units[unit].absorbAuras[source] == nil or units[unit].absorbAuras[source][spellId] == nil then
                            --aura is not tracked at all, track it!
                            trackSpell(source, spellId, name, i, absorb, icon, duration, expirationTime)
                        else
                            --aura is being tracked but at another index, change that
                            changeTrackingIndex(name, source, spellId, i, absorb, icon, duration, expirationTime)
                        end
                    end
                else
                    --aura is tracked and at same index, update that we verified that this frame
                    trackSpell(source, spellId, name, i, absorb, icon, duration, expirationTime, true)
                end
            end
        else -- no more buffs, hide this frame and stop iterating if its the last visible frame
            f:Hide()
            if type(nextFrame) ~= "nil" and not nextFrame:IsVisible() then
                break
            end
        end
    end
    --we checked all frames, untrack any that are gone
    -- print("untrack all that are gone")
    for k, v in pairs(units[unit].absorbAurasByIndex) do
        if (v["checkedThisEvent"] == false) then
            unTrackSpell(k)
        end
    end
    local remainingTrackedAuraCount = tablelength(units[unit].absorbAurasByIndex)
    if not absorbChanged then
        return
    end
    --we tracked all absorbs, now we have to visualize them. if absorbchange fired, we need to rearrange them
    --check if segments already exist for unit
    local buttonFrame = srslylawlUI_GetFrameByUnitType(unit)
    local height = buttonFrame.unit:GetHeight()
    local width = buttonFrame.unit.healthBar:GetWidth()
    local playerHealthMax = UnitHealthMax(unit)
    local pixelPerHp = width / playerHealthMax
    local playerCurrentHP = UnitHealth(unit)
    local playerMissingHP = playerHealthMax - playerCurrentHP
    local statusBarTex = "Interface/RAIDFRAME/Shield-Fill"
    ---create frames if needed
    local maxFrames = 15
    if units[unit]["absorbFrames"] == nil then
        --create frames
        units[unit]["absorbFrames"] = {}
        for i = 1, maxFrames do
            local parentFrame = units[unit]["absorbFrames"][i - 1]
            if i == 1 then
                parentFrame = buttonFrame.unit.healthBar or UIParent
            end
            local n = unit .. "AbsorbFrame" .. i
            local f = CreateFrame("StatusBar", n, parentFrame)
            f:SetStatusBarTexture(statusBarTex, "ARTWORK")
            f:SetStatusBarColor(1, 1, 1, .8)
            f:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", 1, 0)
            f:SetHeight(height)
            f:SetWidth(40)
            --f:CreateTexture()
            local t = f:CreateTexture("background", "BACKGROUND")
            t:SetColorTexture(0, 0, 0, .5)
            t:SetPoint("CENTER", f, "CENTER")
            t:SetHeight(height + 2)
            t:SetWidth(42)
            f.background = t
            f:Hide()
            f["icon"] = f:CreateTexture("icon", "OVERLAY", nil, 2)
            f["icon"]:SetPoint("CENTER")
            f["icon"]:SetHeight(15)
            f["icon"]:SetWidth(15)
            f["icon"]:SetTexCoord(.08, .92, .08, .92)
            f["icon"]:Hide()
            f["cooldown"] = CreateFrame("Cooldown", n .. "CD", f, "CooldownFrameTemplate")
            f["cooldown"]:SetReverse(true)
            f:SetFrameLevel(1)
            f["cooldown"]:Show()
            f:SetAttribute("unit", unit)
            f:SetScript(
                "OnEnter",
                function(self)
                    local index = self:GetAttribute("buffIndex")
                    if index then
                        GameTooltip:SetOwner(f, "ANCHOR_RIGHT", 0, 0)
                        GameTooltip:SetUnitBuff(self:GetAttribute("unit"), index)
                    end
                end
            )
            f:SetScript(
                "OnLeave",
                function(self)
                    if GameTooltip:IsOwned(f) then
                        GameTooltip:Hide()
                    end
                end
            )

            units[unit]["absorbFrames"][i] = f
            units[unit]["absorbFrames"][i].wasHealthPrediction = false
        end
    end
    --make sure that our first absorb anchor moves with the bar fill amount
    srslylawlUI_MoveAbsorbAnchorWithHealth(unit)

    local incomingHeal = UnitGetIncomingHeals(unit)
    if remainingTrackedAuraCount == 0 and units[unit].activeAbsorbFrames > 0 and incomingHeal < 1 then
        --no more absorbs, done here
        for k, v in pairs(units[unit]["absorbFrames"]) do
            if v:IsVisible() then
                v:Hide()
                units[unit].activeAbsorbFrames = units[unit].activeAbsorbFrames - 1
            end
        end
        return
    end
    --- made sure that frames exist, now use those frames for each absorb effect
    local absorbFrameCount = tablelength(units[unit]["absorbFrames"])

    local curBarIndex = 1

    --some absorbs are too small to display, so we group them together and display them if they reach a certain amount
    local variousAbsorbAmount = 0

    local absorbAurasBySpellId = {}
    local function CheckSegments(tAura, curBarIndex)
        local function SetupSegments(tAura, curBarIndex, useOldTimer)
            local segmentPool = units[unit]["absorbFrames"]
            local absorbAmount = tAura.absorb
            local iconID = tAura.icon
            local duration = tAura.duration
            local expirationTime = tAura.expiration
            local startTime = expirationTime - duration
            local wasRefreshed = tAura.wasRefreshed
            local doesTrackSegments = trackedSegments ~= nil

            if not doesTrackSegments then
                tAura["trackedSegments"] = {}
            end

            local trackedSegments = tAura["trackedSegments"]
            local currentBar = segmentPool[curBarIndex]
            local barWidth = floor(pixelPerHp * absorbAmount)
            srslylawlUI_ChangeAbsorbSegment(currentBar, barWidth, absorbAmount, height)
            units[unit].activeAbsorbFrames = units[unit].activeAbsorbFrames + 1

            local t
            if useOldTimer then
                --print("resegment ", tAura.name, "absorb amount: ", absorbAmount, "to index ", curBarIndex)
                currentBar:GetAttribute("")
                t = tAura["trackedApplyTime"]
                duration = expirationTime - t
            else
                --print("initial setup ", tAura.name, "absorb amount: ", absorbAmount, "to index ", curBarIndex)
                --may display wrong time on certain auras that are still active if ui has just been reloaded, very niche though
                t = GetTime()
                duration = expirationTime - t
                tAura["trackedApplyTime"] = t
            end

            CooldownFrame_Set(currentBar.cooldown, t, duration, true)

            if currentBar.wasHealthPrediction then
                currentBar:SetStatusBarTexture(statusBarTex, "ARTWORK")
                currentBar:SetStatusBarColor(1, 1, 1, .8)
                currentBar.wasHealthPrediction = false
            end

            currentBar:SetAttribute("buffIndex", tAura.index)
            currentBar.icon:SetTexture(iconID)
            currentBar:Show()
            --track the segment
            trackedSegments[curBarIndex] = currentBar
            return curBarIndex + 1
        end
        --tAura = units[unit].absorbAurasByIndex[key]
        local segmentPool = units[unit]["absorbFrames"]
        local absorbAmount = tAura.absorb
        local iconID = tAura.icon
        local duration = tAura.duration
        local expirationTime = tAura.expiration
        local startTime = expirationTime - duration
        local wasRefreshed = tAura.wasRefreshed
        local doesTrackSegments = tAura["trackedSegments"] ~= nil
        local barWidth = floor(pixelPerHp * absorbAmount)

        if (barWidth < 2) then
            --bar is too small to display, dont bother creating it,
            --add it to our various frame
            variousAbsorbAmount = variousAbsorbAmount + absorbAmount
            return curBarIndex
        end

        if not doesTrackSegments then
            tAura["trackedSegments"] = {}
        end

        local trackedSegments = tAura["trackedSegments"]

        --print(tAura.name, "does track segments? ", doesTrackSegments, "curIndex ", curBarIndex)
        if doesTrackSegments then
            --this aura has active segments, check if they still make sense

            --go through all tracked segments
            for bIndex, cBar in pairs(trackedSegments) do
                --print("tracking at ", bIndex)

                local segmentNumberIsfine = (segmentPool[curBarIndex] == cBar)
                local oldAbsorb = cBar:GetAttribute("absorbAmount")
                local absorbIsSame = (absorbAmount == oldAbsorb)

                if bIndex < curBarIndex then
                    --print("already updated, just changing this one")
                    --we already refreshed the segment we were tracking with something else, so we just have to update this one now
                    curBarIndex = SetupSegments(tAura, curBarIndex, true)
                elseif not segmentNumberIsfine then
                    --print("segment number changed")
                    local tempIndex = 1
                    -- for key, value in pairs(units[unit].absorbAurasByIndex) do
                    for key, value in ipairs(srslylawlUI.AbsorbAuraBySpellIDDescending(units[unit].absorbAurasByIndex)) do
                        tempIndex = SetupSegments(value, tempIndex, true)
                    end
                elseif not absorbIsSame then
                    --since resegmenting fixes all absorb values, we only have to check for that if segment number is fine
                    --print("absorb not same, changing from", oldAbsorb, "to", absorbAmount)
                    srslylawlUI_ChangeAbsorbSegment(cBar, barWidth, absorbAmount, height)
                end
                if wasRefreshed then
                    --print(tAura.name, "was refreshed this frame")
                    local t = GetTime()
                    duration = expirationTime - t
                    CooldownFrame_Set(cBar.cooldown, t, duration, true)
                    tAura["trackedApplyTime"] = t
                end
            end
            curBarIndex = curBarIndex + 1
        else
            curBarIndex = SetupSegments(tAura, curBarIndex, false)
        end
        return curBarIndex
    end

    --if our incoming heal is bigger than max hp, we only display the actual healing done
    incomingHeal = incomingHeal > playerMissingHP and playerMissingHP or incomingHeal
    local incomingHealWidth = floor(incomingHeal * pixelPerHp)
    if incomingHealWidth > 5 then
        local incomingHealBar = units[unit]["absorbFrames"][curBarIndex]
        srslylawlUI_ChangeAbsorbSegment(incomingHealBar, incomingHealWidth, incomingHeal, height, true)
        incomingHealBar:SetStatusBarTexture("Interface/AddOns/srslylawlUI/media/healthBar", ARTWORK)
        incomingHealBar:SetStatusBarColor(.2, .9, .1, 0.9)
        incomingHealBar.wasHealthPrediction = true
        incomingHealBar:Show()
        curBarIndex = curBarIndex + 1
    end
    -- absorb auras seem to get consumed in order by their spellid, ascending, (not confirmed)
    -- so we sort by descending to visualize which one gets removed first
    for key, value in ipairs(srslylawlUI.AbsorbAuraBySpellIDDescending(units[unit].absorbAurasByIndex)) do
        curBarIndex = CheckSegments(value, curBarIndex)
    end

    --see if we should display our various frame
    local variousFrameLength = floor(variousAbsorbAmount * pixelPerHp)
    if variousFrameLength >= 2 then
        local variousBar = units[unit]["absorbFrames"][curBarIndex]
        srslylawlUI_ChangeAbsorbSegment(segmentPool[curBarIndex], variousFrameLength, variousAbsorbAmount, height)
        variousBar:Show()
        curBarIndex = curBarIndex + 1
    end

    for i = curBarIndex, maxFrames do
        if units[unit]["absorbFrames"][i]:IsVisible() then
            units[unit]["absorbFrames"][i]:Hide()
            units[unit].activeAbsorbFrames = units[unit].activeAbsorbFrames - 1
        end
    end
end

function srslylawlUI_ChangeAbsorbSegment(frame, barWidth, absorbAmount, height, isHealPrediction)
    frame:SetAttribute("absorbAmount", absorbAmount)
    frame:SetHeight(height)
    frame:SetWidth(barWidth)
    frame.background:SetHeight(height + 2)
    frame.background:SetWidth(barWidth + 2)
    --resize icon
    if isHealPrediction ~= nil and true then
        frame.icon:Hide()
        frame.cooldown:Clear()
    else
        local minSize = 15
        local maxIconSize = floor(height * 0.8)
        if (barWidth < minSize) then
            frame.icon:SetWidth(minSize)
            frame.icon:SetHeight(minSize)
            frame.icon:Hide()
        elseif (barWidth >= maxIconSize) then
            frame.icon:SetHeight(maxIconSize)
            frame.icon:SetWidth(maxIconSize)
            frame.icon:Show()
        else
            frame.icon:SetHeight(barWidth - 5)
            frame.icon:SetWidth(barWidth - 5)
            frame.icon:Show()
        end
    end
end
function srslylawlUI_MoveAbsorbAnchorWithHealth(unit)
    if units[unit] == nil or units[unit]["absorbFrames"] == nil then
        return
    end
    local buttonFrame = srslylawlUI_GetFrameByUnitType(unit)
    local height = buttonFrame.unit:GetHeight()
    local width = buttonFrame.unit.healthBar:GetWidth()
    local pixelPerHp = width / UnitHealthMax(unit)
    local playerCurrentHP = UnitHealth(unit)
    local incomingHeal = UnitGetIncomingHeals(unit)
    local baseAnchorOffset = (playerCurrentHP * pixelPerHp) + 1 --((playerCurrentHP + incomingHeal) * pixelPerHp) + 1
    units[unit]["absorbFrames"][1]:SetPoint("TOPLEFT", buttonFrame.unit.healthBar, "TOPLEFT", baseAnchorOffset, 0)
end
local function UpdateHeaderNameList()
    srslylawlUI_PartyHeader:SetAttribute("nameList", srslylawlUI_CreateNameListString())
end
local function HeaderSetup()
    local header = srslylawlUI_PartyHeader
    UpdateHeaderNameList()
    header:SetAttribute("initialConfigFunction", configString)
    header.initialConfigFunction = srslylawlUI_InitialConfig
    --header:SetScript(
    --    "OnEvent",
    --    nil
    -- function(self, event, ...)
    --     if ((event == "GROUP_ROSTER_UPDATE" or event == "UNIT_NAME_UPDATE") and self:IsVisible()) then
    --         print("event")
    --         if not InCombatLockdown() then
    --             ClearPointsAllPartyFrames()
    --             SecureGroupHeader_Update(self)
    --         end
    --     --SecureGroupHeader_Update(self)
    --     end
    -- end
    --)

    -- header:HookScript(
    --     "OnEvent",
    --     function(self, event, ...)
    --         if event == "GROUP_ROSTER_UPDATE" or event == "UNIT_NAME_UPDATE" then
    --             print("sort in hookscript")
    --         --UpdateAfterLockDown()
    --         end
    --     end,
    -- )
    header:Show()
    header:SetPoint(settings.header.anchor, settings.header.xOffset, settings.header.yOffset)
end
local function CreateCustomSlider(name, min, max, defaultValue, parent, offset)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    _G[name .. "Low"]:SetText(min)
    _G[name .. "High"]:SetText(max)
    _G[name .. "Text"]:SetText(name)
    _G[name .. "Text"]:SetPoint("TOPLEFT", 0, 15)
    slider:SetPoint("TOP", 0, offset)
    slider:SetWidth(150)
    slider:SetHeight(16)
    slider:SetMinMaxValues(min, max)
    slider:SetValue(defaultValue)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    local editBox = CreateFrame("EditBox", name .. "_EditBox", slider, "BackdropTemplate")
    editBox:SetBackdrop(
        {
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 12,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        }
    )
    editBox:SetBackdropColor(0.05, 0.05, .05, .5)
    editBox:SetTextInsets(5, 5, 0, 0)
    editBox:SetHeight(25)
    editBox:SetWidth(50)
    editBox:SetPoint("RIGHT", 55, 0)
    editBox:SetAutoFocus(false)
    editBox:SetFont("Fonts\\FRIZQT__.TTF", 10)
    editBox:SetNumeric(true)
    editBox:SetNumber(defaultValue)
    editBox:SetMaxLetters(4)
    editBox:SetScript(
        "OnTextChanged",
        function(self)
            slider:SetValue(self:GetNumber())
        end
    )
    slider:SetScript(
        "OnValueChanged",
        function(self, value)
            if editBox:GetNumber() == tonumber(value) then
                return
            else
                local index = string.find(tostring(value), "%p")
                if type(index) ~= "nil" then
                    value = string.sub(tostring(value), 0, index - 1)
                end
                value = tonumber(value)
                editBox:SetNumber(value)
            end
        end
    )
    slider.editbox = editBox
    return slider
end
local function MakeFrameMoveable(frame)
    frame:SetScript(
        "OnMouseDown",
        function(self, button)
            if button == "LeftButton" and not self.isMoving then
                self:StartMoving()
                self.isMoving = true
            end
        end
    )
    frame:SetScript(
        "OnMouseUp",
        function(self, button)
            if button == "LeftButton" and self.isMoving then
                self:StopMovingOrSizing()
                self.isMoving = false
            end
        end
    )
    frame:SetScript(
        "OnHide",
        function(self)
            if (self.isMoving) then
                self:StopMovingOrSizing()
                self.isMoving = false
            end
        end
    )
    frame:RegisterForDrag("LeftButton")
    frame:SetMovable(true)
    frame:EnableMouse(true)
end
function srslylawlUI_GetFrameByUnitType(unit)
    --returns buttonframe that matches unit attribute
    for k, v in pairs(srslylawlUI_PartyHeader) do
        local b = type(v) == "table" and v or nil
        local c = type(b) == "table" and b:GetAttribute("unit") == unit or false
        if c then
            return b
        end
    end

    return nil
end
function srslylawlUI_Frame_Reset_All()
    for k, v in ipairs(srslylawlUI_PartyHeader) do
        local button = v:GetName()
        if type(button) == "string" then
            button = _G[button]
            srslylawlUI_Frame_ResetDimensions(button)
        end
    end
end
function srslylawlUI_Frame_ResetDimensions(button)
    local unitType = button:GetAttribute("unit")
    local h = settings.hp.height
    local w = settings.hp.width
    if units["healthBars"] ~= nil then
        if units["healthBars"][unitType] ~= nil then
            if units["healthBars"][unitType]["width"] ~= nil then
                w = units["healthBars"][unitType]["width"]
            end
        end
    end

    local needsResize = abs(button.unit.healthBar:GetWidth() - w) > 1 or abs(button.unit.healthBar:GetHeight() - h) > 1
    if needsResize then
        --print("sizing req, cur:", button.unit.healthBar:GetWidth(), "tar", w)
        button.unit.healthBar:SetWidth(w)
        button.unit.healthBar:SetHeight(h)
        if button.unit.healthBar["bg"] == nil then
            srslylawlUI_CreateBackground(button.unit.healthBar)
        end
        button.unit.healthBar.bg:SetWidth(w + 2) --TODO: showed nil once, why?
        button.unit.healthBar.bg:SetHeight(h + 2)
        button.unit.powerBar:SetHeight(h)
        button.unit.powerBar.background:SetHeight(h + 2)
        button.unit.powerBar.background:SetWidth(button.unit.powerBar:GetWidth() + 2)
        if not InCombatLockdown() then
            --stuff that taints in combat
            button.unit:SetWidth(w)
            button.unit:SetHeight(h)
            button:SetWidth(w + 2)
            button:SetHeight(h + 2)
            button.pet:Execute([[
        local h = self:GetFrameRef("unit"):GetHeight()
        self:SetHeight(h)]])
            button.pet.bg:SetHeight(settings.hp.height + 2)
        end
    end

    srslylawlUI_ResetUnitButton(button.unit, button:GetAttribute("unit"))
end
function srslylawlUI_SetDirtyFlag()
    if unsaved.flag == true then
        return
    end
    unsaved.flag = true
    for k, v in ipairs(unsaved.buttons) do
        v:Enable()
    end
end
function srslylawlUI_RemoveDirtyFlag()
    unsaved.flag = false
    for k, v in ipairs(unsaved.buttons) do
        v:Disable()
    end
end
local function CreateConfig()
    srslylawlUI_ConfigFrame = CreateFrame("Frame", "srslylawlUI_Config", UIParent, "BackdropTemplate")
    local cFrame = srslylawlUI_ConfigFrame

    cFrame.name = "srslylawlUI"
    cFrame:SetWidth(320)
    cFrame:SetHeight(300)
    cFrame:SetPoint("CENTER", 0, 0)
    cFrame:SetBackdrop(
        {
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        }
    )
    cFrame:SetBackdropColor(0.1, 0.1, .1, .5)
    MakeFrameMoveable(cFrame)
    cFrame.Title = cFrame:CreateFontString("$parent_Title", "OVERLAY", "GameFontHighlight")
    cFrame.Title:SetParent(cFrame)
    cFrame.Title:SetPoint("TOP", 0, -5)
    cFrame.Title:SetText("srslylawlUI Configuration")
    cFrame.Title:SetFont("Fonts\\FRIZQT__.TTF", 20)
    cFrame.sliders = {}
    local width = floor(settings.hp.width)
    local height = floor(settings.hp.height)
    cFrame.sliders.height = CreateCustomSlider("Health Bar Height", 5, 500, height, srslylawlUI_ConfigFrame, -50)
    cFrame.sliders.height:HookScript(
        "OnValueChanged",
        function(self, value)
            local v = value
            settings.hp.height = v
            srslylawlUI.UpdateEverything()
            srslylawlUI_SetDirtyFlag()
        end
    )
    cFrame.sliders.hpwidth = CreateCustomSlider("Health Bar Max Width", 25, 2000, width, cFrame.sliders.height, -40)
    cFrame.sliders.hpwidth:HookScript(
        "OnValueChanged",
        function(self, value)
            local v = value
            settings.hp.width = v
            srslylawlUI.UpdateEverything()
            srslylawlUI_SetDirtyFlag()
        end
    )
    cFrame.SaveButton =
        CreateFrame("Button", "srslylawlUI_Config_SaveButton", srslylawlUI_ConfigFrame, "UIPanelButtonTemplate")
    local s = cFrame.SaveButton
    s:SetPoint("BOTTOM", 20, 20)
    s:SetText("Save")
    s:SetScript(
        "OnClick",
        function(self)
            SaveSettings()
        end
    )
    table.insert(unsaved.buttons, s)
    cFrame.LoadButton =
        CreateFrame("Button", "srslylawlUI_Config_LoadButton", srslylawlUI_ConfigFrame, "UIPanelButtonTemplate")
    local l = cFrame.LoadButton
    l:SetPoint("BOTTOM", -20, 20)
    l:SetText("Load")
    l:SetScript(
        "OnClick",
        function(self)
            LoadSettings(true, true)
        end
    )
    table.insert(unsaved.buttons, l)
    l:Disable()
    s:Disable()
    cFrame.CloseButton =
        CreateFrame("Button", "srslylawlUI_Config_CloseButton", srslylawlUI_ConfigFrame, "UIPanelCloseButton")
    local c = cFrame.CloseButton
    c:SetPoint("TOPRIGHT", 0, 0)
    srslylawlUI_ToggleConfigVisible(false)
    InterfaceOptions_AddCategory(srslylawlUI_ConfigFrame)
end
local function CreateSlashCommands()
    -- Setting Slash Commands
    SLASH_SRSLYLAWLUI1 = "/srslylawlUI"
    SLASH_SRSLYLAWLUI2 = "/srslylawlUI"
    SLASH_SRSLYLAWLUI3 = "/srsUI"
    SLASH_SRSLYLAWLUI4 = "/srslylawl"
    SLASH_SRSLYLAWLUI5 = "/srslylawl save"

    SLASH_SRLYLAWLAPPROVESPELL1 = "/approvespell id"

    SlashCmdList["SRSLYLAWLUI"] = function(msg, txt)
        if InCombatLockdown() then
            srslylawlUI.Log("Can't access menu while in combat.")
            return
        end
        if msg and msg == "save" then
            SaveSettings()
        else
            srslylawlUI_ToggleConfigVisible(true)
        end
    end
    SlashCmdList["SLASH_SRLYLAWLAPPROVESPELL1"] = function(msg, txt)
        if msg and msg == "save" then
            SaveSettings()
        else
            srslylawlUI_ToggleConfigVisible(true)
        end
    end
end
function SortPartyFrames()
    --print("sort called")
    local list, _, _, hasUnknownMember = srslylawlUI_GetPartyHealth()

    if not list then
        return
    end

    --print(#list, GetNumGroupMembers())
    if InCombatLockdown() then
        srslylawlUI.SortAfterCombat()
        return
    end

    if hasUnknownMember then
        --all units arent properly loaded yet, lets check again in a few secs
        --print("has unknown, checking again soon")
        if not srslylawlUI.sortTimerActive then
            srslylawlUI.sortTimerActive = true
            C_Timer.After(
                1,
                function()
                    srslylawlUI.sortTimerActive = false
                    SortPartyFrames()
                end
            )
        end
        return
    end

    for i = 1, #list do
        local buttonFrame = srslylawlUI_GetFrameByUnitType(list[i].unit)
        --print(i, ".", list[i].unit, list[i].name, list[i].maxHealth)

        if (buttonFrame) then
            buttonFrame:ClearAllPoints()
            if i == 1 then
                buttonFrame:SetPoint("TOPLEFT", srslylawlUI_PartyHeader, "TOPLEFT")
            else
                local parent = srslylawlUI_GetFrameByUnitType(list[i - 1].unit)
                buttonFrame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT")
            end
            srslylawlUI_ResetUnitButton(buttonFrame.unit, list[i].unit)
        end
    end
    ClearAfterSort()
    --print("done sorting")
end
function ClearAfterSort()
    if not srslylawlUI.clearTimerActive then
        srslylawlUI.clearTimerActive = true
        C_Timer.After(
            0.5,
            function()
                if not InCombatLockdown() then
                    srslylawlUI.clearTimerActive = false
                    ClearPointsAllPartyFrames()
                    if not srslylawlUI.AreFramesVisible() then
                        srslylawlUI.UpdateEverything()
                    end
                else
                    ClearAfterSort()
                end
            end
        )
    end
end
function ClearPointsAllPartyFrames()
    for k, v in ipairs(srslylawlUI_PartyHeader) do
        local button = v:GetName()
        if type(button) == "string" then
            button = _G[button]
            button:ClearAllPoints()
        end
    end
    --print("points cleared")
end
local function srslylawlUI_Initialize()
    LoadSettings()
    HeaderSetup()
    CreateSlashCommands()
    CreateConfig()
end
srslylawlUI.AreFramesVisible = function()
    local base = "srslylawlUI_PartyHeaderUnitButton"
    local index = 1
    local b = _G[base .. index]

    if not b then
        --print("not ", base .. index)
        return false
    end
    repeat
        --print(base .. index, b)
        if b:IsVisible() == false then
            --print(b:GetName(), "not visible")
            --means we dont have as many group members as buttons (someone left)
            if GetNumGroupMembers() < index then
                return true
            end
        end
        local dist = b:GetLeft()

        if dist == nil or dist < 1 then
            --print("left", dist)
            return false
        end
        dist = b:GetRight()
        if dist == nil or dist < 1 then
            --print("right", dist)
            return false
        end
        --print(dist)

        index = index + 1
        b = _G[base .. index]
    until not b
    --print("frames are visible")
    return true
end
srslylawlUI.SortAfterCombat = function()
    srslylawlUI_EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
end
srslylawlUI.SortAfterLogin = function()
    local list, _, _, hasUnknownMember = srslylawlUI_GetPartyHealth()
    --print(#list, GetNumGroupMembers(), IsInGroup(), hasUnknownMember)
    if srslylawlUI.AreFramesVisible and not hasUnknownMember then
        srslylawlUI_EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        srslylawlUI_EventFrame:RegisterEvent("UNIT_MAXHEALTH")
        srslylawlUI.UpdateEverything()
    else
        C_Timer.After(
            .5,
            function()
                srslylawlUI.SortAfterLogin()
            end
        )
    end
end
srslylawlUI.UpdateEverything = function()
    --print("update everything")
    if not InCombatLockdown() then
        UpdateHeaderNameList()
        SortPartyFrames()
        srslylawlUI_ResizeHealthBarScale()
    else
        C_Timer.After(
            1,
            function()
                srslylawlUI.UpdateEverything()
            end
        )
    end
end

srslylawlUI_EventFrame = CreateFrame("Frame")
srslylawlUI_EventFrame:RegisterEvent("PLAYER_LOGIN")
srslylawlUI_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
srslylawlUI_EventFrame:SetScript(
    "OnEvent",
    function(self, event, arg1, arg2)
        if (event == "PLAYER_LOGIN") then
            srslylawlUI_Initialize()
            self:UnregisterEvent("PLAYER_LOGIN")
        elseif event == "UNIT_MAXHEALTH" or event == "GROUP_ROSTER_UPDATE" then
            --delay since it bugs if it happens at the same frame for some reason
            --print("roster update")
            C_Timer.After(
                .1,
                function()
                    --print("sort after maxhealth/grp change")
                    SortPartyFrames()
                end
            )
        elseif event == "PLAYER_ENTERING_WORLD" then
            if not (arg1 or arg2) then
                --print("just zoning between maps")
            elseif arg1 then
                --srslylawlUI.SortAfterLogin()
                --since it takes a while for everything to load, we just wait until all our frames are visible before we do anything else
                SortPartyFrames()
            elseif arg2 then
                --print("reload ui")
                srslylawlUI_ResizeHealthBarScale()
                SortPartyFrames()
            end
        elseif event == "PLAYER_REGEN_ENABLED" then
            --print("regen enabled sort")
            srslylawlUI.UpdateEverything()
            self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        end
    end
)
--since events seem to fire in arbitrary order after login, we use this frame for the first time the maxhealth event fires
srslylawlUI_FirstMaxHealthEventFrame = CreateFrame("Frame")
srslylawlUI_FirstMaxHealthEventFrame:RegisterEvent("UNIT_MAXHEALTH")
srslylawlUI_FirstMaxHealthEventFrame:SetScript(
    "OnEvent",
    function(self, event, ...)
        if event == "UNIT_MAXHEALTH" then
            srslylawlUI.SortAfterLogin()
            self:UnregisterEvent("UNIT_MAXHEALTH")
        end
    end
)
