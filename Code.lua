srslylawlUI = {}

srslylawlUI.settings = {
    header = {anchor = "CENTER", xOffset = 10, yOffset = 10},
    hp = {width = 100, height = 50},
    pet = {width = 15},
    absorbOverlapPercent = 0.1,
    buffAnchor = "TOPLEFT",
    buffAnchorXOffset = -29,
    buffAnchorYOffset = 0,
    maxBuffs = 40,
    maxAbsorbFrames = 20,
    minAbsorbAmount = 100,
    autoApproveKeywords = true
}
srslylawlUI.spells = {
    known = {},
    absorbs = {},
    defensives = {},
    whiteList = {},
    unapproved = {}
}
local unsaved = {flag = false, buttons = {}}
local units = {} -- tracks auras and frames
local tooltipTextGrabber = CreateFrame("GameTooltip",
                                       "srslylawl_TooltipTextGrabber", UIParent,
                                       "GameTooltipTemplate")
local customTooltip = CreateFrame("GameTooltip", "srslylawl_CustomTooltip",
                                  UIParent, "GameTooltipTemplate")

local anchorTable = {
    "TOP", "RIGHT", "BOTTOM", "LEFT", "CENTER", "TOPRIGHT", "TOPLEFT",
    "BOTTOMLEFT", "BOTTOMRIGHT"
}

srslylawlUI.sortTimerActive = false
srslylawlUI.clearTimerActive = false

-- TODO: char tooltip
--      defensive cooldowns(display effective health)
--      merge buffssegments that get split by overlap
--      update overlapping frames position with health change
--      debuffs
--      necrotic
--      CC
--      UnitHasIncomingResurrection(unit)
--      recently lost health
--      config window
--      test (performance)
local function scuffedRound(num)
    num = floor(num+0.5)
    return num
end
local function GetBuffText(buffIndex, unit)
    tooltipTextGrabber:SetOwner(srslylawlUI_PartyHeader, "ANCHOR_NONE")
    tooltipTextGrabber:SetUnitBuff(unit, buffIndex)
    local n2 = srslylawl_TooltipTextGrabberTextLeft2:GetText()
    tooltipTextGrabber:Hide()
    return n2
end
local function SpellIsKnown(spellId)
    return srslylawlUI.spells.known[spellId] ~= nil
end
local function SpellHasDifferentTooltip(spellId, index, unit)
    local s = GetBuffText(index, unit)
    return srslylawlUI.spells.known[spellId].text ~= s
end
srslylawlUI.SortAbsorbAurasBySpellIDDescending =
    function(absorbAuraTable)
        local t = {}

        for k, _ in pairs(absorbAuraTable) do
            if absorbAuraTable[k].auraType == "absorb" then
                t[#t + 1] = absorbAuraTable[k]
            end
        end
        table.sort(t, function(a, b) return b.spellId < a.spellId end)
        return t
    end
function tableEquals(table1, table2)
    if table1 == table2 then return true end
    local table1Type = type(table1)
    local table2Type = type(table2)
    if table1Type ~= table2Type then return false end
    if table1Type ~= "table" then return false end

    local keySet = {}

    for key1, value1 in pairs(table1) do
        local value2 = table2[key1]
        if value2 == nil or tableEquals(value1, value2) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(table2) do if not keySet[key2] then return false end end
    return true
end

function srslylawlUI.Log(text) print("|cff4D00FFsrslylawlUI:|r " .. text) end
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
local powerUpdateType = "UNIT_POWER_UPDATE" -- "UNIT_POWER_UPDATE" or "UNIT_POWER_FRQUENT"
local function LoadSettings(reset, announce)
    if announce then srslylawlUI.Log("Settings Loaded") end
    if srslylawl_saved.settings ~= nil then
        srslylawlUI.settings = deepcopy(srslylawl_saved.settings)
    end
    if srslylawl_saved.spells == nil then
        srslylawl_saved.spells = srslylawlUI.spells
    else
        srslylawlUI.spells = deepcopy(srslylawl_saved.spells)
    end

    local c = srslylawlUI_ConfigFrame
    if c then
        local s = srslylawlUI.settings
        c.sliders.height:SetValue(s.hp.height)
        c.sliders.hpwidth:SetValue(s.hp.width)
        -- c.editBoxes.buffAnchorXOffset:SetText(s.buffAnchorXOffset)
    end
    srslylawlUI_PartyHeader:ClearAllPoints()
    srslylawlUI_PartyHeader:SetPoint(srslylawlUI.settings.header.anchor,
                                     srslylawlUI.settings.header.xOffset,
                                     srslylawlUI.settings.header.yOffset)
    srslylawlUI_RemoveDirtyFlag()
    if (reset) then srslylawlUI.UpdateEverything() end
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
    srslylawl_saved.settings = deepcopy(srslylawlUI.settings)
    srslylawl_saved.spells = deepcopy(srslylawlUI.spells)
    srslylawlUI_RemoveDirtyFlag()
end
function srslylawlUI_InitialConfig(header, buttonFrame)
    -- header = PartyHeader
    buttonFrame = _G[buttonFrame]
    -- local frameLevel = buttonFrame.unit:GetFrameLevel()
    -- buttonFrame.unit:SetFrameLevel(2)
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
    buttonFrame.unit:SetScript("OnEnter", function(self)
        local unit = self:GetParent():GetAttribute("unit")
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(unit)
    end)
    buttonFrame.pet:SetScript("OnEnter", function(self)
        local unit = self:GetParent():GetAttribute("unit")
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetUnit(unit.."pet")
    end)

    RegisterUnitWatch(buttonFrame.pet)
    buttonFrame.pet:SetFrameRef("unit", buttonFrame.unit)

    srslylawlUI_CreateBackground(buttonFrame.pet)
    if (buttonFrame.unit.healthBar["bg"] == nil) then
        srslylawlUI_CreateBackground(buttonFrame.unit.healthBar)
    end
    buttonFrame.unit.healthBar.name:SetPoint("BOTTOMLEFT", buttonFrame.unit,
                                             "BOTTOMLEFT", 2, 2)
    buttonFrame.unit.healthBar.text:SetPoint("BOTTOMRIGHT", 2, 2)
    buttonFrame.unit.healthBar.text:SetDrawLayer("OVERLAY", 7)
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
    background:SetHeight(srslylawlUI.settings.hp.height + 2)
    background.texture = t
    background:Show()
    background:SetFrameStrata("BACKGROUND")
    background:SetFrameLevel(1)
    frame.bg = background
end
local configString = [[
        -- me is UnitButtonFrameX
        local me = self:GetName()
        local partyHeader = self:GetParent()
        partyHeader:CallMethod("initialConfigFunction", me)
]]
function srslylawlUI_Frame_OnShow(button)
    -- button = UnitButtonX

    local unit = button:GetAttribute("unit")
    -- i think the code below never executes since the button will never have the unit attribute on show (gets assigned later)
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
    if unit == nil then return end
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
    local maxLength = srslylawlUI.settings.hp.width
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
    button.healthBar.text:SetText(health .. "/" .. healthMax .. " " ..
                                      healthPercent .. "%")
    if not alive or not online then
        -- If dead, set bar color to grey and fill bar
        button.healthBar:SetStatusBarColor(0.3, 0.3, 0.3)
        button.healthBar:SetMinMaxValues(0, 1)
        button.healthBar:SetValue(1)
        button.dead = true
        if not online then button.healthBar.text:SetText("offline") end
    else
        button.healthBar:SetStatusBarColor(classColor.r, classColor.g,
                                           classColor.b)
        button.healthBar:SetMinMaxValues(0, healthMax)
        button.healthBar:SetValue(health)
        button.dead = false
    end
end
function srslylawlUI_ResetPowerBar(button, unit)
    local powerType, powerToken = UnitPowerType(unit)
    local powerColor = srlylawlUI_GetCustomPowerColor(powerToken)
    local alive = not UnitIsDeadOrGhost(unit)
    local online = UnitIsConnected(unit)
    if alive and online then
        button.powerBar:SetStatusBarColor(powerColor.r, powerColor.g,
                                          powerColor.b)
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
    if not srslylawlUI_PartyHeader:IsMovable() then return end

    local grpMembers = GetNumGroupMembers()
    if grpMembers == 0 then
        srslylawlUI_PartyHeaderUnitButton1:SetPoint("TOPLEFT",
                                                    srslylawlUI_PartyHeader,
                                                    "TOPLEFT")
    else
        for i = 1, grpMembers do
            local buttonFrame
            local u = "party" .. i - 1
            if i == 1 then
                buttonFrame = srslylawlUI_PartyHeaderUnitButton1
                print(buttonFrame:GetName())
            else
                buttonFrame = srslylawlUI_GetFrameByUnitType(u)
            end
            if (buttonFrame) then
                buttonFrame:ClearAllPoints()
                if i == 1 then
                    buttonFrame:SetPoint("TOPLEFT", srslylawlUI_PartyHeader,
                                         "TOPLEFT")
                else
                    local parent = srslylawlUI_GetFrameByUnitType(
                                       "party" .. i - 1)
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
        local point, relativeTo, relativePoint, xOfs, yOfs =
            srslylawlUI_PartyHeader:GetPoint()
        srslylawlUI.settings.header.anchor = point
        srslylawlUI.settings.header.xOffset = xOfs
        srslylawlUI.settings.header.yOffset = yOfs
        srslylawlUI_SetDirtyFlag()
        SortPartyFrames()
    end
end
function srslylawlUI_Frame_OnEvent(self, event, arg1, ...)
    local unit = self:GetAttribute("unit")
    if not unit then return end
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
    elseif arg1 and UnitIsUnit(unit, arg1) and arg1 ~= "nameplate1" then
        if event == "UNIT_MAXHEALTH" then
            srslylawlUI_ResizeHealthBarScale()
            if self.unit.dead ~= UnitIsDeadOrGhost(unit) then
                srslylawlUI_ResetUnitButton(self.unit, unit)
            end
            self.unit.healthBar:SetMinMaxValues(0, UnitHealthMax(unit))
            self.unit.healthBar:SetValue(UnitHealth(unit))
        elseif event == "UNIT_HEALTH" then
            srslylawlUI_ResetHealthBar(self.unit, unit)
            srslylawlUI_Frame_HandleAuras(self.unit, unit)
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
    -- print("resize scale")
    local list, highestHP, averageHP = srslylawlUI_GetPartyHealth()

    local scaleByHighest = true
    local lowerCap = 0.45 -- bars can not get smaller than this percent of highest
    local pixelPerHp = srslylawlUI.settings.hp.width / highestHP
    local minWidth = floor(highestHP * pixelPerHp * lowerCap)

    if scaleByHighest then
        for unit, _ in pairs(units["healthBars"]) do
            local scaledWidth = (units["healthBars"][unit]["maxHealth"] *
                                    pixelPerHp)
            local scaledWidth = scaledWidth < minWidth and minWidth or
                                    scaledWidth
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
        if (server and server ~= "") then name = name .. "-" .. server end
    end
    return name
end
function srslylawlUI_GetPartyHealth()
    -- print("gethealth called")
    if units["healthBars"] == nil then units["healthBars"] = {} end

    local nameStringSortedByHealthDesc = {}
    local hasUnknownMember = false

    local highestHP, averageHP, memberCount = 0, 0, 0

    local currentUnit = "player"
    local partyIndex = 0
    if not UnitExists("player") then
        print("XXXXXX player doesnt exist? XXXXX")
    else
        -- loop through all units
        repeat
            if units["healthBars"][currentUnit] == nil then
                units["healthBars"][currentUnit] = {}
            end
            local maxHealth = UnitHealthMax(currentUnit)
            if maxHealth > highestHP then highestHP = maxHealth end
            local name = GetUnitNameWithServer(currentUnit)

            if name == "Unknown" or maxHealth == 1 then
                hasUnknownMember = true
            end

            units["healthBars"][currentUnit]["maxHealth"] = maxHealth
            units["healthBars"][currentUnit]["unit"] = currentUnit
            units["healthBars"][currentUnit]["name"] = name

            averageHP = averageHP + maxHealth
            table.insert(nameStringSortedByHealthDesc,
                         units["healthBars"][currentUnit])
            memberCount = memberCount + 1
            currentUnit = "party" .. memberCount
        until not UnitExists(currentUnit)
    end

    table.sort(nameStringSortedByHealthDesc,
               function(a, b) return b.maxHealth < a.maxHealth end)
    averageHP = floor(averageHP / memberCount)

    return nameStringSortedByHealthDesc, highestHP, averageHP, hasUnknownMember
end
function srslylawlUI.HasDefensiveKeyword(tooltipText)
    local s = string.lower(tooltipText)
    local keyPhrases = {
        "reduces damage taken", "damage taken reduced", "reducing damage taken",
        "reducing all damage taken", "reduces all damage taken"
    }

    for _, phrase in pairs(keyPhrases) do
        if s:match(phrase) and true then return true end
    end

    return false
end
function srslylawlUI.HasAbsorbKeyword(tooltipText)
    local s = string.lower(tooltipText)
    local keyPhrases = {"absorb"}

    for _, phrase in pairs(keyPhrases) do
        if s:match(phrase) and true then return true end
    end

    return false
end
function srslylawlUI.RememberSpellID(spellId, buffIndex, unit, arg1)
    local function GetPercentValue(tooltipText)
        -- %d+ = multiple numbers in a row
        -- %% = the % sign
        -- so we are looking for something like 15%
        local valueWithSign = tooltipText:match("%d+%%")

        if not valueWithSign then return 0 end
        -- remove the percent sign now

        local number = valueWithSign:match("%d+")

        return tonumber(number) or 0
    end
    local function ProcessID(spellId, buffIndex, unit, arg1)
        local spellName = GetSpellInfo(spellId)
        local buffText = GetBuffText(buffIndex, unit)
        local buffLower = buffText
        if buffText ~= nil then
            buffLower = string.lower(buffText)
        else
            buffLower = ""
        end
        local autoApprove = srslylawlUI.settings.autoApproveKeywords
        local keyWordAbsorb = srslylawlUI.HasAbsorbKeyword(buffLower) and
                                  autoApprove and ((arg1 ~= nil) and (arg1 > 1))
        local keyWordDefensive = srslylawlUI.HasDefensiveKeyword(buffLower) and
                                     autoApprove
        local isKnown = srslylawlUI.spells.known[spellId] ~= nil

        local spell = {
            name = spellName,
            text = buffText,
            isAbsorb = keyWordAbsorb,
            isDefensive = keyWordDefensive
        }

        if keyWordAbsorb then
            if (srslylawlUI.spells.absorbs[spellId] == nil) then
                -- first time entry
                srslylawlUI.Log("absorb spell " .. spellName ..
                                    " auto-approved !")
            else
                -- srslylawlUI.Log("spell updated " .. spellName .. "!")
            end

            srslylawlUI.spells.absorbs[spellId] = spell
            srslylawl_saved.spells.absorbs[spellId] = spell
        elseif keyWordDefensive then
            local amount = GetPercentValue(buffLower)

            if abs(amount) ~= 0 then spell.reductionAmount = amount end

            if (srslylawlUI.spells.defensives[spellId] == nil) then
                -- first time entry
                srslylawlUI.Log("defensive spell " .. spellName ..
                                    " auto-approved with a reduction of " ..
                                    amount .. "%!")
            else
                -- srslylawlUI.Log("spell updated " .. spellName .. "!")
            end
            srslylawlUI.spells.defensives[spellId] = spell
            srslylawl_saved.spells.defensives[spellId] = spell
        else
            -- couldnt identify spell, add to unapproved
            srslylawlUI.spells.unapproved[spellId] = spell
            srslylawl_saved.spells.unapproved[spellId] = spell
        end

        if isKnown then
            -- make sure not to replace any other keys
            for key, _ in pairs(spell) do
                srslylawlUI.spells.known[spellId][key] = spell[key]
                srslylawl_saved.spells.known[spellId][key] = spell[key]
            end
        else
            srslylawlUI.Log("new spell encountered: " .. spellName .. "!")
            -- Add spell to known spell list
            srslylawlUI.spells.known[spellId] = spell
            srslylawl_saved.spells.known[spellId] = spell
        end
    end

    if SpellIsKnown(spellId) and
        SpellHasDifferentTooltip(spellId, buffIndex, unit) then
        ProcessID(spellId, buffIndex, unit, arg1)
    else
        ProcessID(spellId, buffIndex, unit, arg1)
    end
end
function srslylawlUI_ManuallyAddSpell(spellId, list)
    -- we dont have the same tooltip that we get from unit buffindex and slot, so we dont save it
    -- it should get added/updated though once we ever see it on any party members

    local isKnown = srslylawlUI.spells.known[spellId] ~= nil

    if isKnown then
        local spell = srslylawlUI.spells.known[spellId]

        if srslylawlUI.spells[list][spellId] ~= nil then
            srslylawlUI.Log(spell.name .. " is already part of list " .. list ..
                                ", I refuse to work under these conditions.")
            return
        end

        -- we already know the spell, just move it to list and remove from other lists
        srslylawlUI.spells[list][spellId] = spell
        srslylawl_saved.spells[list][spellId] = spell
        srslylawlUI.spells.unapproved[spellId] = nil
        srslylawl_saved.spells.unapproved[spellId] = nil
        srslylawlUI.Log(spell.name .. " added to " .. list .. "!")
    else
        local n = GetSpellInfo(spellId)
        if n == nil then
            srslylawlUI.Log("Spell with ID: " .. spellId ..
                                " not found. Make sure you typed it correctly.")
            return
        end
        local spell = {name = n}

        srslylawlUI.spells.known[spellId] = spell
        srslylawl_saved.spells.known[spellId] = spell
        srslylawlUI.Log("New spell approved: " .. n .. "!")
    end
end
function srslylawlUI_ManuallyRemoveSpell(spellId, list)
    local spell = srslylawlUI.spells[list][spellId]
    if list == "known" then
        srslylawlUI.Log(
            "I never forget spells! Unless.. you delete my savefile.")
        return
    end
    srslylawlUI.spells[list][spellId] = nil
    srslylawl_saved.spells[list][spellId] = nil
    srslylawlUI.Log(spell.name .. " removed from " .. list .. "!")

    -- see if the spell is somewhere else, if no then put it to unapproved spells
    local isInAbsorbs = srslylawlUI.spells.absorbs[spellId] ~= nil
    local isInDefensives = srslylawlUI.spells.defensives[spellId] ~= nil
    local isInWhiteList = srslylawlUI.spells.whiteList[spellId] ~= nil
    local isInUnapproved = srslylawlUI.spells.unapproved[spellId] ~= nil
    local isSomeWhere = isInAbsorbs or isInDefensives or isInWhiteList or
                            isInUnapproved or false

    if srslylawlUI.spells.unapproved[spellId] == nil and not isSomeWhere then
        srslylawlUI.spells.unapproved[spellId] = spell
    end
end
function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
function srslylawlUI_Frame_HandleAuras(unitbutton, unit, absorbChanged)
    -- Buffs --
    ---create frames for this unittype
        local function GetTypeOfAuraID(spellId)
        local auraType = nil
        if srslylawlUI.spells.absorbs[spellId] ~= nil then
            auraType = "absorb"
        elseif srslylawlUI.spells.defensives[spellId] ~= nil then
            auraType = "defensive"
        end

        return auraType
    end
    local function TrackAura(source, spellId, count, name, index, absorb, icon,
                             duration, expirationTime, auraType, verify)
        if auraType == nil then error("auraType is nil") end

        local byAura = auraType .. "Auras"
        local byIndex = "trackedAurasByIndex"

        if verify == nil or verify == false then end
        if source == nil then source = "unknown" end

        local aura = {["name"] = name, ["index"] = index}
        if units[unit][byAura][source] == nil then
            units[unit][byAura][source] = {[spellId] = aura}
        else
            units[unit][byAura][source][spellId] = aura
        end

        local diff = 0
        if verify then
            if units[unit][byIndex][index] ~= nil and
                units[unit][byIndex][index].expiration ~= nil then
                diff = expirationTime - units[unit][byIndex][index].expiration
            end
        end

        local flagRefreshed = (diff > 0.01)

        if units[unit][byIndex][index] == nil then
            units[unit][byIndex][index] = {}
        end
        local t = units[unit][byIndex][index]
        -- doing it this way since we dont want our tracked fragment to reset
        t["source"] = source
        t["name"] = name
        t["spellId"] = spellId
        t["checkedThisEvent"] = true
        t["absorb"] = absorb
        t["icon"] = icon
        t["duration"] = duration
        t["expiration"] = expirationTime
        t["wasRefreshed"] = flagRefreshed
        t["index"] = index -- double index here to make it easier to get it again for tooltip
        t["auraType"] = auraType
        t["stacks"] = count
    end
    local function UntrackAura(index)
        -- print("untrack spell" .. units[unit].trackedAurasByIndex[index].name)
        local byIndex = "trackedAurasByIndex"
        local auraType = units[unit][byIndex][index].auraType
        if auraType == nil then error("auraType is nil") end
        local byAura = auraType .. "Auras"

        local src = units[unit][byIndex][index].source
        local s = units[unit][byIndex][index].spellId
        local t = tablelength(units[unit][byAura][src])

        -- should be redundant check
        if t > 0 then units[unit][byAura][src][s] = nil end

        units[unit][byAura][src][s] = nil
        units[unit][byIndex][index] = nil
        t = tablelength(units[unit][byAura][src])

        if t == 0 then units[unit][byAura][src] = nil end
    end
    local function ChangeTrackingIndex(name, source, count, spellId,
                                       currentIndex, absorb, icon, duration,
                                       expirationTime, auraType)
        -- srslylawlUI.Log("index changed " .. name)
        local byAura = auraType .. "Auras"
        local byIndex = "trackedAurasByIndex"

        local oldIndex = units[unit][byAura][source][spellId].index

        -- assign to current
        units[unit][byAura][source][spellId].index = currentIndex

        -- flag for timer refresh
        local diff = 0
        if units[unit][byIndex][oldIndex] ~= nil and
            units[unit][byIndex][oldIndex].expiration ~= nil then
            diff = expirationTime - units[unit][byIndex][oldIndex].expiration
        end

        local flagRefreshed = (diff > 0.1)

        if units[unit][byIndex][currentIndex] == nil then
            units[unit][byIndex][currentIndex] = {}
        end
        local t = units[unit][byIndex][currentIndex]
        t["source"] = source
        t["name"] = name
        t["spellId"] = spellId
        t["checkedThisEvent"] = true
        t["absorb"] = absorb
        t["icon"] = icon
        t["duration"] = duration
        t["expiration"] = expirationTime
        t["wasRefreshed"] = flagRefreshed
        t["index"] = currentIndex
        t["stacks"] = count
        t["auraType"] = auraType

        -- carry over tracked segments
        if units[unit][byIndex][oldIndex]["trackedSegments"] ~= nil then
            if units[unit][byIndex][currentIndex]["trackedSegments"] == nil then
                units[unit][byIndex][currentIndex]["trackedSegments"] = {}
            end

            for index, segment in pairs(
                                      units[unit][byIndex][oldIndex]["trackedSegments"]) do
                units[unit][byIndex][currentIndex]["trackedSegments"][index] =
                    segment
            end
        end

        local trackedApplyTime =
            units[unit][byIndex][oldIndex]["trackedApplyTime"]
        if trackedApplyTime ~= nil then
            units[unit][byIndex][currentIndex]["trackedApplyTime"] =
                trackedApplyTime
        end

        units[unit][byIndex][oldIndex] = nil
    end
    local function IsAuraBeingTrackedAtOtherIndex(source, spellId, auraType)
        if units[unit][auraType .. "Auras"][source] == nil then
            return false
        elseif units[unit][auraType .. "Auras"][source][spellId] == nil then
            return false
        else
            return true
        end
    end
    local function AuraIsBeingTrackedAtIndex(index)
        return units[unit].trackedAurasByIndex[index] ~= nil
    end
    local function ProcessAuraTracking(name, source, count, spellId, i, absorb,
                                       icon, duration, expirationTime, auraType)
        if IsAuraBeingTrackedAtOtherIndex(source, spellId, auraType) then
            -- aura is being tracked but at another index, change that

            ChangeTrackingIndex(name, source, count, spellId, i, absorb, icon,
                                duration, expirationTime, auraType)
        else
            -- aura is not tracked at all, track it!
            TrackAura(source, spellId, count, name, i, absorb, icon, duration,
                      expirationTime, auraType)
        end
    end

    if units[unit] == nil then
        unitbutton.buffFrames = {}
        units[unit] = {
            absorbAuras = {},
            trackedAurasByIndex = {},
            buffFrames = {},
            defensiveAuras = {},
            effectiveHealthSegments = {}
        }
        for i = 1, 40 do
            local xOffset = -17
            local yOffset = 0
            local parent = _G[unit .. "_" .. (i - 1)]
            local anchor = "TOPLEFT"
            if (i == 1) then
                parent = unitbutton
                anchor = srslylawlUI.settings.buffAnchor
                xOffset = srslylawlUI.settings.buffAnchorXOffset
                yOffset = srslylawlUI.settings.buffAnchorYOffset
            end

            local f = CreateFrame("Button", unit .. "_" .. i, parent,
                                  "CompactBuffTemplate")
            f:SetPoint(anchor, xOffset, 0)

            f:SetAttribute("unit", unit)
            f:SetScript("OnLoad", nil)
            f:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(f, "ANCHOR_RIGHT", 0, 0)
                GameTooltip:SetUnitBuff(self:GetAttribute("unit"), self:GetID())
            end)
            f:SetScript("OnUpdate", function(self)
                if GameTooltip:IsOwned(f) then
                    GameTooltip:SetUnitBuff(self:GetAttribute("unit"),
                                            self:GetID())
                end
            end)
            units[unit].buffFrames[i] = f
            unitbutton.buffFrames[i] = f
        end
    elseif unitbutton["buffFrames"] == nil then -- frames exist but this unit doesnt own them yet
        -- print("exist, reassigning")
        unitbutton.buffFrames = {}
        unitbutton.buffFrames = units[unit].buffFrames
        unitbutton.buffFrames[1]:SetParent(unitbutton)
    end
    -- frames exist and unit owns them
    -- reset frame check verifier
    for k, v in pairs(units[unit].trackedAurasByIndex) do
        v["checkedThisEvent"] = false
    end
    -- process auras on unit
    for i = 1, 40 do
        -- loop through all frames on standby and assign them based on their index
        local f = unitbutton.buffFrames[i]
        local name, icon, count, debuffType, duration, expirationTime, source,
              isStealable, nameplateShowPersonal, spellId, canApplyAura,
              isBossDebuff, castByPlayer, nameplateShowAll, timeMod, absorb =
            UnitAura(unit, i, "HELPFUL")
        if name then -- if aura on this index exists, assign it
            srslylawlUI.RememberSpellID(spellId, i, unit, absorb)
            CompactUnitFrame_UtilSetBuff(f, i, UnitAura(unit, i))
            f:SetID(i)
            f:Show()

            -- track auras, check if we care to track it
            local auraType = GetTypeOfAuraID(spellId)

            if auraType ~= nil then
                if AuraIsBeingTrackedAtIndex(i) then
                    if units[unit].trackedAurasByIndex[i]["spellId"] ~= spellId then
                        -- different spell is being tracked
                        UntrackAura(i)
                        ProcessAuraTracking(name, source, count, spellId, i,
                                            absorb, icon, duration,
                                            expirationTime, auraType)
                    else
                        -- aura is tracked and at same index, update that we verified that this frame
                        TrackAura(source, spellId, count, name, i, absorb, icon,
                                  duration, expirationTime, auraType, true)
                    end
                else
                    -- no aura is currently tracked for that index
                    ProcessAuraTracking(name, source, count, spellId, i, absorb,
                                        icon, duration, expirationTime, auraType)
                end
            else
                if AuraIsBeingTrackedAtIndex(i) then
                    UntrackAura(i)
                end
            end
        else -- no more buffs, hide frames
            f:Hide()
        end
    end
    -- we checked all frames, untrack any that are gone
    -- print("untrack all that are gone")
    for k, v in pairs(units[unit].trackedAurasByIndex) do
        if (v["checkedThisEvent"] == false) then UntrackAura(k) end
    end
    -- we tracked all absorbs, now we have to visualize them. if absorbchange fired, we need to rearrange them
    -- check if segments already exist for unit
    local buttonFrame = srslylawlUI_GetFrameByUnitType(unit)
    local height = buttonFrame.unit:GetHeight()*0.7
    local width = buttonFrame.unit.healthBar:GetWidth()
    local playerHealthMax = UnitHealthMax(unit)
    local pixelPerHp = width / playerHealthMax
    local playerCurrentHP = UnitHealth(unit)
    local playerMissingHP = playerHealthMax - playerCurrentHP
    local statusBarTex = "Interface/RAIDFRAME/Shield-Fill"
    local currentBarLength = (playerCurrentHP * pixelPerHp) + 1
    local overlapBarIndex = 1
    ---create frames if needed
    local function CreateAbsorbFrame(parent, i, height, parentTable)
        local n = unit .. "AbsorbFrame" .. i
        local f = CreateFrame("Frame", n, parent)
        f.texture = f:CreateTexture("n".."texture", "ARTWORK")
        f.texture:SetAllPoints()
        f.texture:SetTexture(statusBarTex)
        if parentTable == units[unit]["absorbFramesOverlap"] then
            f:SetPoint("TOPRIGHT", parent, "TOPLEFT", -1, 0)
        else
            f:SetPoint("TOPLEFT", parent, "TOPRIGHT", 1, 0)
        end
        f:SetHeight(height)
        f:SetWidth(40)
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
        f["cooldown"] = CreateFrame("Cooldown", n .. "CD", f,
                                    "CooldownFrameTemplate")
        f["cooldown"]:SetReverse(true)
        --f:SetFrameLevel(1)
        f["cooldown"]:Show()
        f:SetAttribute("unit", unit)
        f:SetScript("OnEnter", function(self)
            local index = self:GetAttribute("buffIndex")
            if index then
                GameTooltip:SetOwner(f, "ANCHOR_RIGHT", 0, 0)
                GameTooltip:SetUnitBuff(self:GetAttribute("unit"), index)
            end
        end)
        f:SetScript("OnLeave", function(self)
            if GameTooltip:IsOwned(f) then GameTooltip:Hide() end
        end)

        parentTable[i] = f
        parentTable[i].wasHealthPrediction = false
    end
    if units[unit]["absorbFrames"] == nil then
        -- create frames
        units[unit]["absorbFrames"] = {}
        for i = 1, srslylawlUI.settings.maxAbsorbFrames do
            local parentFrame = units[unit]["absorbFrames"][i - 1]
            if i == 1 then
                parentFrame = buttonFrame.unit.healthBar or UIParent
            end
            CreateAbsorbFrame(parentFrame, i, height,
                              units[unit]["absorbFrames"])
        end
    end
    if units[unit]["absorbFramesOverlap"] == nil then
        units[unit]["absorbFramesOverlap"] = {}
        for i = 1, srslylawlUI.settings.maxAbsorbFrames do
            local parentFrame = units[unit]["absorbFramesOverlap"][i - 1]
            if i == 1 then
                parentFrame = buttonFrame.unit.healthBar or UIParent
            end
            CreateAbsorbFrame(parentFrame, i, height, units[unit]["absorbFramesOverlap"])
        end
    end
    if units[unit]["effectiveHealthFrames"] == nil then
        units[unit]["effectiveHealthFrames"] = {}
        for i = 1, 1 do
            local parentFrame = units[unit]["effectiveHealthFrames"][i - 1]
            if i == 1 then
                parentFrame = buttonFrame.unit.healthBar
            end
            local n = "srslylawlUI" .. unit .. "EffectiveHealthFrame" .. i
            local f = CreateFrame("Frame", n, parentFrame)
            f:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", 1, 0)
            f:SetHeight(buttonFrame.unit:GetHeight())
            f:SetWidth(40)
            local t = f:CreateTexture("background", "BACKGROUND")
            t:SetPoint("CENTER", f, "CENTER")
            t:SetHeight(height + 2)
            t:SetWidth(42)
            f.background = t
            f["icon"] = f:CreateTexture("icon", "OVERLAY", nil, 2)
            f["icon"]:SetPoint("CENTER")
            f["icon"]:SetHeight(15)
            f["icon"]:SetWidth(15)
            f["icon"]:SetTexCoord(.08, .92, .08, .92)
            f["icon"]:Hide()
            f["cooldown"] = CreateFrame("Cooldown", n .. "CD", f, "CooldownFrameTemplate")
            f["cooldown"]:SetReverse(true)
            f["cooldown"]:Show()
            f:SetAttribute("unit", unit)
            f:SetScript("OnEnter", function(self)
                local index = self:GetAttribute("buffIndex")
                if index then
                    GameTooltip:SetOwner(f, "ANCHOR_RIGHT", 0, 0)
                    GameTooltip:SetUnitBuff(self:GetAttribute("unit"), index)
                end
            end)
            f:SetScript("OnLeave", function(self)
                if GameTooltip:IsOwned(f) then GameTooltip:Hide() end
            end)
            f.texture = f:CreateTexture(nil, "BACKGROUND")
            f.texture:SetAllPoints()
            f.texture:SetTexture("Interface/AddOns/srslylawlUI/media/healthBar", true, "MIRROR")

            f.texture.bg = f:CreateTexture(nil, "BACKGROUND")
            f.texture.bg:SetTexture("Interface/AddOns/srslylawlUI/media/eHealthBar2", true, "MIRROR")
            f.texture.bg:SetVertTile(true)
            f.texture.bg:SetHorizTile(true)
            f.texture.bg:SetAllPoints()
            
            local class = UnitClassBase(unit)
            local color = {GetClassColor(class)}
            color[4] = 0.7
            f.texture:SetVertexColor(unpack(color))
            f.texture.bg:SetVertexColor(1, 1, 1, 1)
            f.texture.bg:SetBlendMode("MOD")


            units[unit]["effectiveHealthFrames"][i] = f
            end
    end


    -- some absorbs are too small to display, so we group them together and display them if they reach a certain amount
    local variousAbsorbAmount = 0

    local function SortDefensives(trackedAuras)
        local sortedTable = {}

        for index, aura in pairs(trackedAuras) do
            if aura.auraType == "defensive" then
                table.insert(sortedTable, aura)
            end
        end

        -- if #sortedTable == 0 then
        --     return nil
        -- end

        table.sort(sortedTable, function(a, b)
            -- spells that expire first are last in the list
            if a.expiration > b.expiration then return true end
        end)

        return sortedTable
    end

    units[unit].effectiveHealthSegments = SortDefensives(units[unit].trackedAurasByIndex)
    local effectiveHealthMod = 1
    local stackMultiplier = 1
    local reducAmount
    if #units[unit].effectiveHealthSegments > 0 then
        for k, v in ipairs(units[unit].effectiveHealthSegments) do
            stackMultiplier = v.stacks > 1 and v.stacks or 1
            reducAmount = srslylawlUI.spells.known[v.spellId].reductionAmount /
                              100

            effectiveHealthMod = effectiveHealthMod *
                                     (1 - (reducAmount * stackMultiplier))
        end
    end
    if effectiveHealthMod ~= 1 then
        local eHealth = playerCurrentHP / effectiveHealthMod
        local additionalHealth = eHealth - playerCurrentHP
        local maxWidth = playerMissingHP*pixelPerHp - 1
        local barWidth = additionalHealth * pixelPerHp
        local barWidth = barWidth < maxWidth and barWidth or maxWidth
        srslylawlUI_ChangeAbsorbSegment(units[unit]["effectiveHealthFrames"][1], barWidth, eHealth, buttonFrame.unit:GetHeight())
        units[unit]["effectiveHealthFrames"][1]:Show()
    else
        units[unit]["effectiveHealthFrames"][1]:Hide()
    end

    local function NewAbsorbSegment(amount, width, sType, oIndex, tAura)
        return {
            ["amount"] = amount,
            ["width"] = width,
            ["tAura"] = tAura,
            ["sType"] = sType,
            ["oIndex"] = oIndex
        }
    end
    local absorbSegments = {}
    local sortedAbsorbAuras = srslylawlUI.SortAbsorbAurasBySpellIDDescending(units[unit].trackedAurasByIndex)
    local function CalcSegment(amount, sType, tAura)
        local absorbAmount = amount
        local allowedWidth
        local overlapAmount
        local barWidth
        if absorbAmount == nil then
            local errorMsg = "Aura " .. tAura.name .. " with ID " .. tAura.index .. " does not have an absorb amount. Make sure that it is the spellID of the actual buff, not of the spell that casts the buff."
            srslylawlUI.Log(errorMsg)
            return
        end
        while absorbAmount > 0 do
            overlapAmount = 0
            barWidth = pixelPerHp * absorbAmount
            allowedWidth = srslylawlUI.settings.hp.width * overlapBarIndex
            oIndex = overlapBarIndex

            local pixelOverlap = (currentBarLength + barWidth) - allowedWidth
            if pixelOverlap > 0 then
                -- bar overlaps, display only the value that wouldnt overlap
                overlapAmount = pixelOverlap / pixelPerHp
                --since pixels arent that accurate in converting from/to health, make sure we never overlap more than our full absorb amount
                overlapAmount = overlapAmount > absorbAmount and absorbAmount or overlapAmount
                absorbAmount = absorbAmount - overlapAmount
                barWidth = pixelPerHp * absorbAmount
                overlapBarIndex = overlapBarIndex + 1
            end

            if barWidth > 2 then
            absorbSegments[#absorbSegments + 1] = NewAbsorbSegment(absorbAmount, barWidth, sType, oIndex, tAura)
            else
                variousAbsorbAmount = variousAbsorbAmount + absorbAmount
            end
            currentBarLength = currentBarLength + barWidth
            absorbAmount = overlapAmount
        end
    end
    local function SetupSegment(tAura, bar, absorbAmount, barWidth, height)
        local iconID = tAura.icon
        local duration = tAura.duration
        local expirationTime = tAura.expiration
        local currentBar = bar
        srslylawlUI_ChangeAbsorbSegment(currentBar, barWidth, absorbAmount, height)
        local t
        if tAura.wasRefreshed or tAura["trackedApplyTime"] == nil then
            -- we only want to refresh the expiration timer if the aura has actually just been reapplied
            t = GetTime()
            duration = expirationTime - t
            tAura["trackedApplyTime"] = t
        else
            -- may display wrong time on certain auras that are still active if ui has just been reloaded, very niche case though
            t = tAura["trackedApplyTime"]
            duration = expirationTime - t
        end
        CooldownFrame_Set(currentBar.cooldown, t, duration, true)
        if currentBar.wasHealthPrediction then
            currentBar.texture:SetTexture(statusBarTex)
            currentBar.texture:SetVertexColor(1, 1, 1, 0.9)
            currentBar.wasHealthPrediction = false
        end
        currentBar:SetAttribute("buffIndex", tAura.index)
        currentBar.icon:SetTexture(iconID)
        currentBar:Show()
    end

    local incomingHeal = UnitGetIncomingHeals(unit)
    local incomingHealWidth = floor(incomingHeal * pixelPerHp)
    if incomingHealWidth > 2 then
        CalcSegment(incomingHeal, "incomingHeal", nil)
    end
    -- absorb auras seem to get consumed in order by their spellid, ascending, (not confirmed)
    -- so we sort by descending to visualize which one gets removed first
    for _, value in ipairs(sortedAbsorbAuras) do
        CalcSegment(value.absorb, "aura", value)
    end
    local variousFrameWidth = floor(variousAbsorbAmount * pixelPerHp)
    if variousFrameWidth >= 2 then
        CalcSegment(variousAbsorbAmount, "various", nil)
    end
    local curBarIndex = 1
    local curBarOverlapIndex = 1
    local function DisplayFrames(absorbSegments)
        local segment
        local bar
        local pool
        local i
        local shouldMerge
        for k, _ in ipairs(absorbSegments) do
            segment = absorbSegments[k]
            i = segment.oIndex > 1 and curBarOverlapIndex or curBarIndex
            pool = segment.oIndex > 1 and units[unit]["absorbFramesOverlap"] or units[unit]["absorbFrames"]
            bar = pool[i]
            shouldMerge = segment.oIndex > 1 and segment.tAura ~= nil and segment.tAura == absorbSegments[1].tAura and absorbSegments[1].oIndex == 1
            shouldMerge = shouldMerge or (segment.sType == "incomingHeal" and absorbSegments[1].sType == "incomingHeal" and segment.oIndex > 1 and absorbSegments[1].oIndex == 1)
            if shouldMerge then
                --hiding the non overlap frame and instead making the overlap frame bigger
                units[unit]["absorbFrames"][1].hide = true
                bar.isMerged = true
                bar.mergeAmount = absorbSegments[1].width
                segment.width = segment.width + bar.mergeAmount
            end

            if segment.sType == "incomingHeal" then
                bar.texture:SetTexture("Interface/AddOns/srslylawlUI/media/healthBar", ARTWORK)
                bar.texture:SetVertexColor(.2, .9, .1, 0.9)
                bar.wasHealthPrediction = true
                srslylawlUI_ChangeAbsorbSegment(bar, segment.width, segment.amount, height, true)
                bar:Show()
            else
                SetupSegment(segment.tAura, bar, segment.amount, segment.width, height)
            end
            bar.hide = false

            if segment.oIndex > 1 then
                curBarOverlapIndex = curBarOverlapIndex + 1
            else
                curBarIndex = curBarIndex + 1
            end

        end
    end
    --flag all bars as hide
    for _, bar in pairs(units[unit]["absorbFramesOverlap"]) do
        bar.hide = true
    end
    units[unit]["absorbFramesOverlap"][1].isMerged = false
    for _, bar in pairs(units[unit]["absorbFrames"]) do
        bar.hide = true
    end

    DisplayFrames(absorbSegments)

    --hide the ones we didnt use
    for _, bar in pairs(units[unit]["absorbFramesOverlap"]) do
        if bar.hide then
            bar:Hide()
        end
    end
    for _, bar in pairs(units[unit]["absorbFrames"]) do
        if bar.hide then
            bar:Hide()
        end
    end

        -- make sure that our first absorb anchor moves with the bar fill amount
    srslylawlUI_MoveAbsorbAnchorWithHealth(unit)
end
function srslylawlUI_ChangeAbsorbSegment(frame, barWidth, absorbAmount, height, isHealPrediction)
    frame:SetAttribute("absorbAmount", absorbAmount)
    frame:SetHeight(height)
    frame:SetWidth(scuffedRound(barWidth))
    frame.background:SetHeight(height + 2)
    frame.background:SetWidth(ceil(barWidth + 2))
    -- resize icon
    if isHealPrediction then
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
    if units[unit] == nil or units[unit]["absorbFrames"] == nil or
        units[unit]["absorbFramesOverlap"] == nil then return end
    local buttonFrame = srslylawlUI_GetFrameByUnitType(unit)
    local width = buttonFrame.unit.healthBar:GetWidth()
    local pixelPerHp = width / UnitHealthMax(unit)
    local playerCurrentHP = UnitHealth(unit)
    local baseAnchorOffset = scuffedRound(playerCurrentHP * pixelPerHp)
    local mergeOffset = 0
    if units[unit]["absorbFramesOverlap"][1].isMerged then
        --offset by mergeamount
        mergeOffset = units[unit]["absorbFramesOverlap"][1].mergeAmount
    end
    units[unit]["absorbFrames"][1]:SetPoint("TOPLEFT", buttonFrame.unit.healthBar,"TOPLEFT", baseAnchorOffset+1, 0)
    units[unit]["absorbFramesOverlap"][1]:SetPoint("TOPRIGHT", buttonFrame.unit.healthBar, "TOPLEFT", baseAnchorOffset+mergeOffset,0)
    units[unit]["effectiveHealthFrames"][1]:SetPoint("TOPLEFT", buttonFrame.unit.healthBar,"TOPLEFT", baseAnchorOffset+1, 0)
end
local function UpdateHeaderNameList()
    srslylawlUI_PartyHeader:SetAttribute("nameList",
                                         srslylawlUI_CreateNameListString())
end
local function HeaderSetup()
    local header = srslylawlUI_PartyHeader
    UpdateHeaderNameList()
    header:SetAttribute("initialConfigFunction", configString)
    header.initialConfigFunction = srslylawlUI_InitialConfig
    header:Show()
    header:SetPoint(srslylawlUI.settings.header.anchor,
                    srslylawlUI.settings.header.xOffset,
                    srslylawlUI.settings.header.yOffset)
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
    local editBox = CreateFrame("EditBox", name .. "_EditBox", slider,
                                "BackdropTemplate")
    editBox:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
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
    editBox:SetScript("OnTextChanged",
                      function(self) slider:SetValue(self:GetNumber()) end)
    slider:SetScript("OnValueChanged", function(self, value)
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
    end)
    slider.editbox = editBox
    return slider
end
local function CreateCustomDropDown(title, width, parent, anchor, relativePoint,
                                    xOffset, yOffset, valueRef, values,
                                    onChangeFunc, checkFunc)
    -- Create the dropdown, and configure its appearance
    local dropDown = CreateFrame("FRAME", title, parent,
                                 "UIDropDownMenuTemplate")
    dropDown:SetPoint(anchor, parent, relativePoint, xOffset, yOffset)
    UIDropDownMenu_SetWidth(dropDown, width)
    UIDropDownMenu_SetText(dropDown, title)

    -- Create and bind the initialization function to the dropdown menu
    UIDropDownMenu_Initialize(dropDown, function(self)
        local info = UIDropDownMenu_CreateInfo()
        info.func = self.SetValue
        for k, v in pairs(values) do
            local value = v or k
            info.text = value
            info.arg1 = value
            info.checked = checkFunc
            UIDropDownMenu_AddButton(info)
        end
    end)

    -- Implement the function to change the favoriteNumber
    function dropDown:SetValue(newValue)
        UIDropDownMenu_SetText(dropDown, title)
        srslylawlUI_SetDirtyFlag()
        onChangeFunc(newValue)
        -- Update the text; if we merely wanted it to display newValue, we would not need to do this

        -- Because this is called from a sub-menu, only that menu level is closed by default.
        -- Close the entire menu with this next call
        -- CloseDropDownMenus()
    end

    return dropDown
end
local function CreateEditBox(name, parent, defaultValue, funcOnTextChanged,
                             point, xOffset, yOffset, isNumeric)
    local editBox = CreateFrame("EditBox", name, parent, "BackdropTemplate")
    editBox:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    editBox:SetBackdropColor(0.05, 0.05, .05, .5)
    editBox:SetTextInsets(5, 5, 0, 0)
    editBox:SetHeight(25)
    editBox:SetWidth(50)
    editBox:SetPoint(point or "RIGHT", xOffset or 55, yOffset or 0)
    editBox:SetAutoFocus(false)
    editBox:SetFont("Fonts\\FRIZQT__.TTF", 10)
    editBox:SetNumeric(isNumeric or false)

    if isNumeric then
        editBox:SetNumber(defaultValue)
    else
        editBox:SetText(defaultValue)
    end
    editBox:SetMaxLetters(4)
    editBox:SetScript("OnEnterPressed", funcOnTextChanged)
    return editBox
end
local function MakeFrameMoveable(frame)
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and not self.isMoving then
            self:StartMoving()
            self.isMoving = true
        end
    end)
    frame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.isMoving then
            self:StopMovingOrSizing()
            self.isMoving = false
        end
    end)
    frame:SetScript("OnHide", function(self)
        if (self.isMoving) then
            self:StopMovingOrSizing()
            self.isMoving = false
        end
    end)
    frame:RegisterForDrag("LeftButton")
    frame:SetMovable(true)
    frame:EnableMouse(true)
end
function srslylawlUI_GetFrameByUnitType(unit)
    -- returns buttonframe that matches unit attribute
    for k, v in pairs(srslylawlUI_PartyHeader) do
        local b = type(v) == "table" and v or nil
        local c = type(b) == "table" and b:GetAttribute("unit") == unit or false
        if c then return b end
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
    local h = srslylawlUI.settings.hp.height
    local w = srslylawlUI.settings.hp.width
    if units["healthBars"] ~= nil then
        if units["healthBars"][unitType] ~= nil then
            if units["healthBars"][unitType]["width"] ~= nil then
                w = units["healthBars"][unitType]["width"]
            end
        end
    end

    local needsResize = abs(button.unit.healthBar:GetWidth() - w) > 1 or
                            abs(button.unit.healthBar:GetHeight() - h) > 1
    if needsResize then
        -- print("sizing req, cur:", button.unit.healthBar:GetWidth(), "tar", w)
        button.unit.healthBar:SetWidth(w)
        button.unit.healthBar:SetHeight(h)
        if button.unit.healthBar["bg"] == nil then
            srslylawlUI_CreateBackground(button.unit.healthBar)
        end
        button.unit.healthBar.bg:SetWidth(w + 2) -- TODO: showed nil once, why?
        button.unit.healthBar.bg:SetHeight(h + 2)
        button.unit.powerBar:SetHeight(h)
        button.unit.powerBar.background:SetHeight(h + 2)
        button.unit.powerBar.background:SetWidth(
            button.unit.powerBar:GetWidth() + 2)
        if not InCombatLockdown() then
            -- stuff that taints in combat
            button.unit:SetWidth(w)
            button.unit:SetHeight(h)
            button:SetWidth(w + 2)
            button:SetHeight(h + 2)
            button.pet:Execute([[
        local h = self:GetFrameRef("unit"):GetHeight()
        self:SetHeight(h)]])
            button.pet.bg:SetHeight(srslylawlUI.settings.hp.height + 2)
        end
    end

    srslylawlUI_ResetUnitButton(button.unit, button:GetAttribute("unit"))
end
function srslylawlUI_SetDirtyFlag()
    if unsaved.flag == true then return end
    unsaved.flag = true
    for k, v in ipairs(unsaved.buttons) do v:Enable() end
end
function srslylawlUI_RemoveDirtyFlag()
    unsaved.flag = false
    for k, v in ipairs(unsaved.buttons) do v:Disable() end
end
local function CreateConfig()
    local function CreateConfigBody(name, parent)
        local f = CreateFrame("Frame", name, parent, "BackdropTemplate")
        f:SetSize(500, 500)
        -- f.Title = f:CreateFontString("$parent_Title", "OVERLAY", "DialogButtonHighlightText")
        -- f.Title:SetParent(f)
        -- f.Title:SetPoint("TOP", 0, -5)
        -- f.Title:SetText(name)
        -- f.Title:SetFont("Fonts\\FRIZQT__.TTF", 18)
        f:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 10,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        })
        f:SetBackdropColor(0, 0, 0, .4)
        f:SetPoint("TOP", 0, -80)
        f:SetPoint("BOTTOM", parent, "BOTTOM", 0, 0)
        f:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 10, 10)
        f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -7, 10)

        return f
    end
    local function ScrollFrame_OnMouseWheel(self, delta)
        local newValue = self:GetVerticalScroll() - (delta * 20)

        if newValue < 0 then
            newValue = 0
        elseif newValue > self:GetVerticalScrollRange() then
            newValue = self:GetVerticalScrollRange()
        end
        self:SetVerticalScroll(newValue)
    end
    local function CreateFrameWBG(name, parent)
        local f = CreateFrame("Frame", name, parent, "BackdropTemplate")
        f:SetSize(500, 500)
        f:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 10,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        })
        f:SetBackdropColor(0, 0, 0, .4)
        return f
    end
    local function Tab_OnClick(self)
        local parent = self:GetParent()
        PanelTemplates_SetTab(parent, self:GetID())
        self.content:Show()

        for k, tab in ipairs(parent.Tabs) do
            if tab:GetID() ~= parent.selectedTab then
                tab.content:Hide()
            end
        end
    end
    local function SetTabs(frame, ...)
        local numTabs = select("#", ...)
        frame.numTabs = numTabs
        frame.Tabs = {}

        local contents = {}
        -- local name = frame:GetName()
        local tab

        for i = 1, numTabs do
            local n = select(i, ...)
            tab = CreateFrame("Button", "$parent_" .. n, frame,
                              "OptionsFrameTabButtonTemplate") -- name .. "Tab" .. i, frame
            tab:SetID(i)

            tab:SetText(n)
            tab:SetScript("OnClick", Tab_OnClick)

            local width = tab:GetWidth()
            PanelTemplates_TabResize(tab, -10, nil, width)
            tab.content = CreateFrame("Frame", "$parent_" .. n .. "Content",
                                      frame)
            tab.content:SetAllPoints()
            tab.content:Hide()
            tab.content.tabButton = tab

            frame.Tabs[i] = tab
            table.insert(contents, tab.content)

            if i == 1 then
                tab:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -5, 0)
            else
                tab:SetPoint("BOTTOMLEFT", frame.Tabs[i - 1], "BOTTOMRIGHT",
                             -10, 0)
            end
        end

        Tab_OnClick(frame.Tabs[1])

        return unpack(contents)
    end
    local function GenerateSpellList(parent, spellList)
        function Button_OnClick(self)
            local id = self:GetID()
            local parent = self:GetParent()
            local tabcontent = parent:GetParent():GetParent():GetParent()
            for _, button in pairs(parent.buttons) do
                button:SetChecked(button:GetID() == id)
            end
            tabcontent.activeButton = self
        end
        if parent.buttons == nil then parent.buttons = {} end
        local first = true
        local previousButton
        local firstButton
        local buttonParent = parent
        local iconSize = 25
        local offset = 3
        local count = 0
        if spellList == nil then
            error("no spell list, saved variables corrupt?")
            return
        end
        -- sort list
        local sortedSpellList = {}
        for spellId, _ in pairs(spellList) do
            local name, _, icon = GetSpellInfo(spellId)
            local spell = {name = name, spellId = spellId, icon = icon}
            table.insert(sortedSpellList, spell)
        end

        table.sort(sortedSpellList, function(a, b) return b.name > a.name end)

        for index, spell in ipairs(sortedSpellList) do
            local name, spellId, icon = spell.name, spell.spellId, spell.icon

            if not first then buttonParent = previousButton end

            local button = parent.buttons[count + 1]
            if button == nil then
                button = CreateFrame("CheckButton", parent:GetName() .. name,
                                     parent, "UIMenuButtonStretchTemplate")
                button:SetCheckedTexture(button:GetHighlightTexture())
                button:SetScript("OnClick", Button_OnClick)
                button:SetID(count + 1)

                button.icon = CreateFrame("Frame", "icon", button)
                button.icon.texture = button.icon:CreateTexture("icon",
                                                                "ARTWORK")
                button.icon:SetSize(iconSize, iconSize)
                button.icon.texture:SetAllPoints()
                button.icon:SetPoint("RIGHT", button, "LEFT")

                parent.buttons[count + 1] = button
            end

            if first then
                first = false
                firstButton = button
                firstButton:SetPoint("TOPLEFT", parent, "TOPLEFT",
                                     iconSize + offset, -10)
            else
                button:SetPoint("TOPLEFT", buttonParent, "BOTTOMLEFT", 0, 0)
            end
            button:SetText(name)
            button:SetPoint("RIGHT", parent, "RIGHT")

            button:SetAttribute("spellId", spellId)

            button.icon.texture:SetTexture(icon)
            button:Show()

            count = count + 1

            previousButton = button
        end
        for i = count + 1, #parent.buttons do
            -- hide all inactive buttons
            local button = parent.buttons[i]
            if button then button:Hide() end
        end
        parent:SetHeight(count * (iconSize + 2))

        return firstButton
    end
    local function CreateScrollFrame(parent)
        local ScrollFrame
        ScrollFrame = CreateFrame("ScrollFrame", "$parent_ScrollFrame", parent,
                                  "UIPanelScrollFrameTemplate")
        ScrollFrame:SetClipsChildren(true)
        ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
        ScrollFrame.ScrollBar:ClearAllPoints()
        ScrollFrame.ScrollBar:SetPoint("TOPLEFT", ScrollFrame, "TOPRIGHT", -40,
                                       -18)
        ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", ScrollFrame,
                                       "BOTTOMRIGHT", -7, 17)

        return ScrollFrame
    end
    local function CreateScrollFrameWithBGAndChild(parent)
        parent.borderFrame = CreateFrame("Frame", "$parent_BorderFrame", parent,
                                         "BackdropTemplate")
        parent.borderFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 10,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        })
        parent.borderFrame:SetBackdropColor(0, 1, 1, .4)
        parent.borderFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, -5)
        parent.borderFrame:SetPoint("TOPRIGHT", parent, "TOPLEFT", 230, -5)
        parent.borderFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 5)

        parent.ScrollFrame = CreateScrollFrame(parent.borderFrame)
        parent.ScrollFrame:SetPoint("TOPLEFT", parent.borderFrame, "TOPLEFT", 2,
                                    -5)
        parent.ScrollFrame:SetPoint("TOPRIGHT", parent.borderFrame, "TOPRIGHT",
                                    5, -5)
        parent.ScrollFrame:SetPoint("BOTTOM", parent.borderFrame, "BOTTOM", 0, 5)
        parent.ScrollFrame:SetPoint("BOTTOMLEFT", parent.borderFrame,
                                    "BOTTOMRIGHT", 0, 5)

        parent.ScrollFrame.child = CreateFrame("Frame",
                                               "$parent_ScrollFrameChild",
                                               parent.ScrollFrame)
        parent.ScrollFrame.child:SetPoint("CENTER", parent.ScrollFrame)
        parent.ScrollFrame.child:SetPoint("LEFT", parent.ScrollFrame, "LEFT")
        parent.ScrollFrame.child:SetPoint("RIGHT", parent.ScrollFrame, "RIGHT")
        parent.ScrollFrame.child:SetSize(parent.borderFrame:GetWidth() - 30, 100)
        parent.ScrollFrame:SetScrollChild(parent.ScrollFrame.child)

        return parent.ScrollFrame, parent.ScrollFrame.child
    end
    local function OpenSpellAttributePanel(parentTab)
        local function AddSpell_OnEnterPressed(self)
            local text = self:GetText()
            local spellId = tonumber(text)
            local tabcontent = self:GetParent():GetParent()

            local listString = tabcontent:GetAttribute("spellList")

            if listString and spellId then
                srslylawlUI_ManuallyAddSpell(spellId, listString)
                tabcontent:Hide()
                tabcontent:Show()
            end

            self:SetText("")
        end
        local function RemoveSpell_OnClick(self)
            local tabcontent = self:GetParent():GetParent()
            local spellId = tabcontent.activeButton:GetAttribute("spellId")
            local spellList = tabcontent:GetAttribute("spellList")
            srslylawlUI_ManuallyRemoveSpell(spellId, spellList)
            tabcontent:Hide()
            tabcontent:Show()
        end
        local function MoveSpellToList(self)
            local listKey = self:GetAttribute("spellList")
            if listKey == nil then
                error("no spellList found for this button")
            end
            local tabcontent = self:GetParent():GetParent()
            local spellId = tabcontent.activeButton:GetAttribute("spellId")
            srslylawlUI_ManuallyAddSpell(spellId, listKey)
            tabcontent:Hide()
            tabcontent:Show()
        end
        local function CreatePanel(parentTab)
            parentTab.AttributePanel = CreateFrame("Frame",
                                                   "$parent_AttributePanel",
                                                   parentTab, "BackdropTemplate")
            parentTab.AttributePanel:SetBackdrop(
                {
                    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                    edgeSize = 10,
                    insets = {left = 4, right = 4, top = 4, bottom = 4}
                })
            parentTab.AttributePanel:SetBackdropColor(1, 1, 1, .4)
            parentTab.AttributePanel.NewSpellEditBox =
                CreateFrame("EditBox", "$parent_AddSpellBox",
                            parentTab.AttributePanel, "InputBoxTemplate")
            parentTab.AttributePanel.NewSpellEditBox:SetAutoFocus(false)
            parentTab.AttributePanel.NewSpellEditBox:SetPoint("TOPLEFT",
                                                              parentTab.AttributePanel,
                                                              "TOPLEFT", 15, -10)
            parentTab.AttributePanel.NewSpellEditBox:SetPoint("BOTTOMRIGHT",
                                                              parentTab.AttributePanel,
                                                              "TOPRIGHT", -15,
                                                              -60)
            parentTab.AttributePanel.NewSpellEditBox.Title =
                parentTab.AttributePanel.NewSpellEditBox:CreateFontString(
                    "$parent_Title", "OVERLAY", "GameFontNormal")
            parentTab.AttributePanel.NewSpellEditBox.Title:SetText(
                "Add new spell")
            parentTab.AttributePanel.NewSpellEditBox.Title:SetPoint("BOTTOM",
                                                                    parentTab.AttributePanel
                                                                        .NewSpellEditBox,
                                                                    "TOP", 0,
                                                                    -10)
            parentTab.AttributePanel.NewSpellEditBox:SetText("enter spellID...")
            parentTab.AttributePanel.NewSpellEditBox:SetScript("OnEnterPressed",
                                                               AddSpell_OnEnterPressed)

            parentTab.AttributePanel.RemoveSpellButton =
                CreateFrame("Button", "$parent_RemoveSpellButton",
                            parentTab.AttributePanel, "UIPanelButtonTemplate")
            parentTab.AttributePanel.RemoveSpellButton:SetText(
                "Remove spell from this list")
            parentTab.AttributePanel.RemoveSpellButton:SetPoint("BOTTOMRIGHT",
                                                                parentTab.AttributePanel,
                                                                "BOTTOMRIGHT",
                                                                -5, 5)
            parentTab.AttributePanel.RemoveSpellButton:SetPoint("TOPLEFT",
                                                                parentTab.AttributePanel,
                                                                "BOTTOMLEFT", 5,
                                                                30)
            parentTab.AttributePanel.RemoveSpellButton:SetScript("OnClick",
                                                                 RemoveSpell_OnClick)

            parentTab.AttributePanel.AddSpellToWhiteListButton =
                CreateFrame("Button", "$AddSpellToWhiteListButton",
                            parentTab.AttributePanel, "UIPanelButtonTemplate")
            parentTab.AttributePanel.AddSpellToWhiteListButton:SetText(
                "Add spell to whitelist")
            parentTab.AttributePanel.AddSpellToWhiteListButton:SetPoint(
                "BOTTOMRIGHT", parentTab.AttributePanel.RemoveSpellButton,
                "TOPRIGHT", 0, 0)
            parentTab.AttributePanel.AddSpellToWhiteListButton:SetPoint(
                "TOPLEFT", parentTab.AttributePanel.RemoveSpellButton,
                "TOPLEFT", 0, 25)
            parentTab.AttributePanel.AddSpellToWhiteListButton:SetScript(
                "OnClick", MoveSpellToList)
            parentTab.AttributePanel.AddSpellToWhiteListButton:SetAttribute(
                "spellList", "whiteList")

            parentTab.AttributePanel.AddSpellToDefensivesButton =
                CreateFrame("Button", "$AddSpellToDefensivesButton",
                            parentTab.AttributePanel, "UIPanelButtonTemplate")
            parentTab.AttributePanel.AddSpellToDefensivesButton:SetText(
                "Add spell to defensives")
            parentTab.AttributePanel.AddSpellToDefensivesButton:SetPoint(
                "BOTTOMRIGHT",
                parentTab.AttributePanel.AddSpellToWhiteListButton, "TOPRIGHT",
                0, 0)
            parentTab.AttributePanel.AddSpellToDefensivesButton:SetPoint(
                "TOPLEFT", parentTab.AttributePanel.AddSpellToWhiteListButton,
                "TOPLEFT", 0, 25)
            parentTab.AttributePanel.AddSpellToDefensivesButton:SetScript(
                "OnClick", MoveSpellToList)
            parentTab.AttributePanel.AddSpellToDefensivesButton:SetAttribute(
                "spellList", "defensives")

            parentTab.AttributePanel.AddSpellToAbsorbsButton =
                CreateFrame("Button", "$AddSpellToAbsorbsButton",
                            parentTab.AttributePanel, "UIPanelButtonTemplate")
            parentTab.AttributePanel.AddSpellToAbsorbsButton:SetText(
                "Add spell to absorbs")
            parentTab.AttributePanel.AddSpellToAbsorbsButton:SetPoint(
                "BOTTOMRIGHT",
                parentTab.AttributePanel.AddSpellToDefensivesButton, "TOPRIGHT",
                0, 0)
            parentTab.AttributePanel.AddSpellToAbsorbsButton:SetPoint("TOPLEFT",
                                                                      parentTab.AttributePanel
                                                                          .AddSpellToDefensivesButton,
                                                                      "TOPLEFT",
                                                                      0, 25)
            parentTab.AttributePanel.AddSpellToAbsorbsButton:SetScript(
                "OnClick", MoveSpellToList)
            parentTab.AttributePanel.AddSpellToAbsorbsButton:SetAttribute(
                "spellList", "absorbs")
        end

        if parentTab.AttributePanel == nil then CreatePanel(parentTab) end

        local buttons = {}

        parentTab.AttributePanel:SetParent(parentTab)
        parentTab.AttributePanel:SetPoint("TOPLEFT", parentTab.borderFrame,
                                          "TOPRIGHT")
        parentTab.AttributePanel:SetPoint("BOTTOMRIGHT", parentTab,
                                          "BOTTOMRIGHT", -5, 5)
    end
    local function CreateSpellMenus(knownSpells, absorbSpells, defensives,
                                    whiteList, unapprovedSpells)
        local function Menu_OnShow(parentTab, list)
            local f = function()
                OpenSpellAttributePanel(parentTab)
                local mainButton = GenerateSpellList(
                                       parentTab.ScrollFrame.child,
                                       srslylawlUI.spells[list])
                if mainButton then mainButton:Click() end
            end

            return f
        end
        Mixin(knownSpells, BackdropTemplateMixin)
        knownSpells:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 10,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        })
        knownSpells:SetBackdropColor(0, 0, 1, .4)
        CreateScrollFrameWithBGAndChild(knownSpells)
        knownSpells:SetScript("OnShow", Menu_OnShow(knownSpells, "known"))
        knownSpells:SetAttribute("spellList", "known")

        CreateScrollFrameWithBGAndChild(absorbSpells)
        absorbSpells:SetScript("OnShow", Menu_OnShow(absorbSpells, "absorbs"))
        absorbSpells:SetAttribute("spellList", "absorbs")

        CreateScrollFrameWithBGAndChild(defensives)
        defensives:SetScript("OnShow", Menu_OnShow(defensives, "defensives"))
        defensives:SetAttribute("spellList", "defensives")

        CreateScrollFrameWithBGAndChild(whiteList)
        whiteList:SetScript("OnShow", Menu_OnShow(whiteList, "whiteList"))
        whiteList:SetAttribute("spellList", "whiteList")

        CreateScrollFrameWithBGAndChild(unapprovedSpells)
        unapprovedSpells:SetScript("OnShow",
                                   Menu_OnShow(unapprovedSpells, "unapproved"))
        unapprovedSpells:SetAttribute("spellList", "unapproved")
    end
    local function AddTooltip(frame, text)
        local function OnEnter(self)
            customTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
            customTooltip:SetText(text)
        end
        local function OnLeave(self) customTooltip:Hide() end

        frame:EnableMouse(true)
        frame:SetScript("OnEnter", OnEnter)
        frame:SetScript("OnLeave", OnLeave)
    end

    srslylawlUI_ConfigFrame = CreateFrame("Frame", "srslylawlUI_Config",
                                          UIParent, "UIPanelDialogTemplate")
    local cFrame = srslylawlUI_ConfigFrame
    local cFrameSizeX = 500
    local cFrameSizeY = 500
    local topOffset = 30

    -- Main Config Frame
    cFrame.name = "srslylawlUI"
    cFrame:SetSize(cFrameSizeX, cFrameSizeY)
    cFrame:SetPoint("CENTER")
    cFrame.Title:SetText("srslylawlUI Configuration")
    MakeFrameMoveable(cFrame)

    cFrame.body = CreateConfigBody("$parent_Body", cFrame)

    local barsTab, spellsTab = SetTabs(cFrame.body, "Bars", "Spells")

    -- Create Spells Tab
    spellsTab:ClearAllPoints()
    spellsTab:SetPoint("TOP", cFrame.body, "TOP", 0, -35)
    spellsTab:SetPoint("BOTTOMLEFT", cFrame.body, "BOTTOMLEFT", 4, 4)
    spellsTab:SetPoint("BOTTOMRIGHT", cFrame.body, "BOTTOMRIGHT", -4, 2)
    Mixin(spellsTab, BackdropTemplateMixin)
    spellsTab:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    spellsTab:SetBackdropColor(0, 0, 0, .4)

    -- Debug Texture
    spellsTab.bg = spellsTab:CreateTexture(nil, "BACKGROUND")
    spellsTab.bg:SetAllPoints()
    spellsTab.bg:SetColorTexture(.3, 1, .4, .2)

    -- Spell Tab buttons
    local knownSpells, absorbSpells, defensives, whiteList, unapprovedSpells =
        SetTabs(spellsTab, "Known Spells", "Absorbs", "Defensives", "Whitelist",
                "Unapproved Spells")

    AddTooltip(knownSpells.tabButton, "List of all encountered buffs.")
    AddTooltip(absorbSpells.tabButton,
               "Buffs with absorb effects, will be shown as segments.")
    AddTooltip(defensives.tabButton,
               "Buffs with damage reduction effects, will increase your effective health.")
    AddTooltip(whiteList.tabButton,
               "Whitelisted buffs will always be displayed as buffs (not segments).")
    AddTooltip(unapprovedSpells.tabButton,
               "Buffs that will not be displayed on the interface")

    Mixin(knownSpells, BackdropTemplateMixin)
    CreateSpellMenus(knownSpells, absorbSpells, defensives, whiteList,
                     unapprovedSpells)

    srslylawlUI_ToggleConfigVisible(false)
    if true then return end

    -- HP Bar Sliders
    cFrame.sliders = {}
    local width = floor(srslylawlUI.settings.hp.width)
    local height = floor(srslylawlUI.settings.hp.height)
    cFrame.sliders.height = CreateCustomSlider("Health Bar Height", 5, 500,
                                               height, cFrame.barFrame, -50)
    cFrame.sliders.height:SetPoint("TOPLEFT", 20, -40)
    cFrame.sliders.height:HookScript("OnValueChanged", function(self, value)
        local v = value
        srslylawlUI.settings.hp.height = v
        srslylawlUI.UpdateEverything()
        srslylawlUI_SetDirtyFlag()
    end)
    cFrame.sliders.hpwidth = CreateCustomSlider("Health Bar Max Width", 25,
                                                2000, width,
                                                cFrame.sliders.height, -40)
    cFrame.sliders.hpwidth:ClearAllPoints()
    cFrame.sliders.hpwidth:SetPoint("LEFT", cFrame.sliders.height.editbox,
                                    "RIGHT", 10, 0)
    cFrame.sliders.hpwidth:HookScript("OnValueChanged", function(self, value)
        local v = value
        srslylawlUI.settings.hp.width = v
        srslylawlUI.UpdateEverything()
        srslylawlUI_SetDirtyFlag()
    end)

    -- Save Button
    cFrame.SaveButton = CreateFrame("Button", "srslylawlUI_Config_SaveButton",
                                    srslylawlUI_ConfigFrame,
                                    "UIPanelButtonTemplate")
    local s = cFrame.SaveButton
    s:SetPoint("BOTTOM", 30, 15)
    s:SetText("Save")
    s:SetScript("OnClick", function(self) SaveSettings() end)
    s:SetWidth(60)
    table.insert(unsaved.buttons, s)

    -- Load Button
    cFrame.LoadButton = CreateFrame("Button", "srslylawlUI_Config_LoadButton",
                                    srslylawlUI_ConfigFrame,
                                    "UIPanelButtonTemplate")
    local l = cFrame.LoadButton
    l:SetPoint("BOTTOM", -30, 15)
    l:SetText("Load")
    l:SetScript("OnClick", function(self) LoadSettings(true, true) end)
    l:SetWidth(60)
    table.insert(unsaved.buttons, l)
    l:Disable()
    s:Disable()
    cFrame.CloseButton = CreateFrame("Button", "srslylawlUI_Config_CloseButton",
                                     srslylawlUI_ConfigFrame,
                                     "UIPanelCloseButton")
    local c = cFrame.CloseButton
    c:SetPoint("TOPRIGHT", 0, 0)

    cFrame.editBoxes = {}

    -- Buff Frame Anchor
    local buffAnchor = CreateCustomDropDown("Buff Anchor", 100,
                                            cFrame.sliders.height, "TOPLEFT",
                                            "BOTTOMLEFT", 0, -10,
                                            srslylawlUI.settings.buffAnchor,
                                            anchorTable, function(newValue)
        for k, v in pairs(units) do
            if units[k] ~= nil and units[k].buffFrames ~= nil then
                units[k].buffFrames[1]:ClearAllPoints()
                srslylawlUI.settings.buffAnchor = newValue
                units[k].buffFrames[1]:SetPoint(srslylawlUI.settings.buffAnchor,
                                                srslylawlUI.settings
                                                    .buffAnchorXOffset,
                                                srslylawlUI.settings
                                                    .buffAnchorYOffset)
            end
        end
    end, function(self) return self.value == srslylawlUI.settings.buffAnchor end)
    local buffAnchorXOffset = CreateEditBox("BuffAnchorXOffset", buffAnchor,
                                            srslylawlUI.settings
                                                .buffAnchorXOffset,
                                            function(self)
        local n = self:GetNumber()
        srslylawlUI.settings.buffAnchorXOffset = n
        for k, v in pairs(units) do
            if units[k] ~= nil and units[k].buffFrames ~= nil then
                units[k].buffFrames[1]:ClearAllPoints()
                srslylawlUI.settings.buffAnchorXOffset = n
                units[k].buffFrames[1]:SetPoint(srslylawlUI.settings.buffAnchor,
                                                srslylawlUI.settings
                                                    .buffAnchorXOffset,
                                                srslylawlUI.settings
                                                    .buffAnchorYOffset)
            end
        end
        print("editboxchanged")
        srslylawlUI_SetDirtyFlag()
    end)
    cFrame.editBoxes.buffAnchorXOffset = buffAnchorXOffset
    -- srslylawlUI_ToggleConfigVisible(false)
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
end
function SortPartyFrames()
    -- print("sort called")
    local list, _, _, hasUnknownMember = srslylawlUI_GetPartyHealth()

    if not list then return end

    -- print(#list, GetNumGroupMembers())
    if InCombatLockdown() then
        srslylawlUI.SortAfterCombat()
        return
    end

    if hasUnknownMember then
        -- all units arent properly loaded yet, lets check again in a few secs
        -- print("has unknown, checking again soon")
        if not srslylawlUI.sortTimerActive then
            srslylawlUI.sortTimerActive = true
            C_Timer.After(1, function()
                srslylawlUI.sortTimerActive = false
                SortPartyFrames()
            end)
        end
        return
    end

    for i = 1, #list do
        local buttonFrame = srslylawlUI_GetFrameByUnitType(list[i].unit)
        -- print(i, ".", list[i].unit, list[i].name, list[i].maxHealth)

        if (buttonFrame) then
            buttonFrame:ClearAllPoints()
            if i == 1 then
                buttonFrame:SetPoint("TOPLEFT", srslylawlUI_PartyHeader,
                                     "TOPLEFT")
            else
                local parent = srslylawlUI_GetFrameByUnitType(list[i - 1].unit)
                buttonFrame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT")
            end
            srslylawlUI_ResetUnitButton(buttonFrame.unit, list[i].unit)
        end
    end
    ClearAfterSort()
    -- print("done sorting")
end
function ClearAfterSort()
    if not srslylawlUI.clearTimerActive then
        srslylawlUI.clearTimerActive = true
        C_Timer.After(0.5, function()
            if not InCombatLockdown() then
                srslylawlUI.clearTimerActive = false
                ClearPointsAllPartyFrames()
                if not srslylawlUI.AreFramesVisible() then
                    srslylawlUI.UpdateEverything()
                end
            else
                ClearAfterSort()
            end
        end)
    end
end
function ClearPointsAllPartyFrames()
    for _, v in ipairs(srslylawlUI_PartyHeader) do
        local button = v:GetName()
        if type(button) == "string" then
            button = _G[button]
            button:ClearAllPoints()
        end
    end
    -- print("points cleared")
end
local function CreateTestTextureBar()
    srslylawlTestFrame = CreateFrame("Frame", "srslylawlUI_TextureTest",
                                     UIParent)
    local frame = srslylawlTestFrame
    local w = srslylawlUI.settings.hp.width
    local h = srslylawlUI.settings.hp.height
    frame:EnableMouse(true)
    frame:SetSize(w * 2, h)
    frame:SetPoint("CENTER")
    frame.texture = frame:CreateTexture(nil, "OVERLAY")
    frame.texture:SetAllPoints()
    frame.texture:SetTexture(
        "Interface/AddOns/srslylawlUI/media/eHealthBarTransparent1", true,
        "MIRROR")
    frame.texture:SetVertTile(true)
    frame.texture:SetHorizTile(true)
    frame.texture.bg = frame:CreateTexture("bg", "BACKGROUND")
    frame.texture.bg:SetAllPoints()
    frame.texture.bg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
    frame.texture:SetVertexColor(GetClassColor("PRIEST"))
end
function srslylawlUI.TranslateTexY(texture, amount, onlyIfChanged)
    local coords = {texture:GetTexCoord()}
    if onlyIfChanged then
        local original = {0, 0, 0, 1, 1, 0, 1, 1}
        local cont = false
        for i, v in ipairs(coords) do
            if coords[i] ~= original[i] then
                cont = true
                break
            end
        end
        if not cont then return end
    end
    coords[2] = coords[2] + amount
    coords[4] = coords[4] + amount
    coords[6] = coords[6] + amount
    coords[8] = coords[8] + amount

    texture:SetTexCoord(unpack(coords))
end
function srslylawlUI.TranslateTexX(texture, amount, onlyIfChanged)
    local coords = {texture:GetTexCoord()}

    if onlyIfChanged then
        local original = {0, 0, 0, 1, 1, 0, 1, 1}
        local cont = false
        for i, v in ipairs(coords) do
            if coords[i] ~= original[i] then
                cont = true
                break
            end
        end
        if not cont then return end
    end
    coords[1] = coords[1] + amount
    coords[3] = coords[3] + amount
    coords[5] = coords[5] + amount
    coords[7] = coords[7] + amount

    texture:SetTexCoord(unpack(coords))
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
        -- print("not ", base .. index)
        return false
    end
    repeat
        -- print(base .. index, b)
        if b:IsVisible() == false then
            -- print(b:GetName(), "not visible")
            -- means we dont have as many group members as buttons (someone left)
            if GetNumGroupMembers() < index then return true end
        end
        local dist = b:GetLeft()

        if dist == nil or dist < 1 then
            -- print("left", dist)
            return false
        end
        dist = b:GetRight()
        if dist == nil or dist < 1 then
            -- print("right", dist)
            return false
        end
        -- print(dist)

        index = index + 1
        b = _G[base .. index]
    until not b
    -- print("frames are visible")
    return true
end
srslylawlUI.SortAfterCombat = function()
    srslylawlUI_EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
end
srslylawlUI.SortAfterLogin = function()
    local _, _, _, hasUnknownMember = srslylawlUI_GetPartyHealth()
    -- print(#list, GetNumGroupMembers(), IsInGroup(), hasUnknownMember)
    if srslylawlUI.AreFramesVisible and not hasUnknownMember then
        srslylawlUI_EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        srslylawlUI_EventFrame:RegisterEvent("UNIT_MAXHEALTH")
        srslylawlUI.UpdateEverything()
    else
        C_Timer.After(.5, function() srslylawlUI.SortAfterLogin() end)
    end
end
srslylawlUI.UpdateEverything = function()
    -- print("update everything")
    if not InCombatLockdown() then
        UpdateHeaderNameList()
        SortPartyFrames()
        srslylawlUI_ResizeHealthBarScale()
    else
        C_Timer.After(1, function() srslylawlUI.UpdateEverything() end)
    end
end

srslylawlUI_EventFrame = CreateFrame("Frame")
srslylawlUI_EventFrame:RegisterEvent("PLAYER_LOGIN")
srslylawlUI_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
srslylawlUI_EventFrame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if (event == "PLAYER_LOGIN") then
        srslylawlUI_Initialize()
        self:UnregisterEvent("PLAYER_LOGIN")
    elseif event == "UNIT_MAXHEALTH" or event == "GROUP_ROSTER_UPDATE" then
        -- delay since it bugs if it happens at the same frame for some reason
        -- print("roster update")
        C_Timer.After(.1, function()
            -- print("sort after maxhealth/grp change")
            SortPartyFrames()
        end)
    elseif event == "PLAYER_ENTERING_WORLD" then
        if not (arg1 or arg2) then
            -- print("just zoning between maps")
        elseif arg1 then
            -- srslylawlUI.SortAfterLogin()
            -- since it takes a while for everything to load, we just wait until all our frames are visible before we do anything else
            SortPartyFrames()
        elseif arg2 then
            -- print("reload ui")
            srslylawlUI_ResizeHealthBarScale()
            SortPartyFrames()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- print("regen enabled sort")
        srslylawlUI.UpdateEverything()
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end)
-- since events seem to fire in arbitrary order after login, we use this frame for the first time the maxhealth event fires
srslylawlUI_FirstMaxHealthEventFrame = CreateFrame("Frame")
srslylawlUI_FirstMaxHealthEventFrame:RegisterEvent("UNIT_MAXHEALTH")
srslylawlUI_FirstMaxHealthEventFrame:SetScript("OnEvent",
                                               function(self, event, ...)
    if event == "UNIT_MAXHEALTH" then
        srslylawlUI.SortAfterLogin()
        self:UnregisterEvent("UNIT_MAXHEALTH")
    end
end)
