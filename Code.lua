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
local units = {} -- tracks auras and frames
local tooltip = CreateFrame("GameTooltip", "BuffTextDebuffScanTooltip", UIParent, "GameTooltipTemplate")
local tooltipTextLeft = BuffTextDebuffScanTooltipTextLeft2

local function GetBuffText(buffIndex, unit)
    tooltip:SetOwner(srslylawlUI_PartyHeader, "ANCHOR_NONE")
    tooltip:SetUnitBuff(unit, buffIndex)
    local n = tooltipTextLeft:GetText()
    tooltip:Hide()
    return n
end
function srslylawlUI_Log(text)
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
local function LoadSettings(reset)
    srslylawlUI_Log("Settings Loaded")
    settings = deepcopy(srslylawl_saved.settings)
    if srslylawlUI_ConfigFrame then
        srslylawlUI_ConfigFrame.sliders.height:SetValue(settings.hp.height)
        srslylawlUI_ConfigFrame.sliders.hpwidth:SetValue(settings.hp.width)
    end
    srslylawlUI_PartyHeader:ClearAllPoints()
    srslylawlUI_PartyHeader:SetPoint(settings.header.anchor, settings.header.xOffset, settings.header.yOffset)
    srslylawlUI_RemoveDirtyFlag()
    if (reset) then
        srslylawlUI_Frame_Reset_All()
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
    srslylawlUI_Log("Settings Saved")
    srslylawl_saved.settings = deepcopy(settings)
    srslylawlUI_RemoveDirtyFlag()
end
function srslylawlUI_InitialConfig(header, buttonFrame)
    -- Nudge the status bar frame levels down
    -- header = PartyHeader
    -- buttonFrame = actual buttonFrame
    buttonFrame = _G[buttonFrame]
    local frameLevel = buttonFrame.unit:GetFrameLevel()
    buttonFrame.unit.healthBar:SetFrameLevel(frameLevel)
    buttonFrame.unit.powerBar:SetFrameLevel(frameLevel)
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

    RegisterUnitWatch(buttonFrame.pet)
    buttonFrame.pet:SetFrameRef("unit", buttonFrame.unit)
    --bg frame
    local background = CreateFrame("Frame", "$parent_background", buttonFrame.pet)
    local t = background:CreateTexture(nil, "BACKGROUND")
    t:SetColorTexture(0, 0, 0, .5)
    t:SetAllPoints(background)
    background:SetPoint("CENTER", 0, 0)
    background:SetWidth(15 + 2)
    background:SetHeight(settings.hp.height + 2)
    background.texture = t
    background:Show()
    buttonFrame.pet.bg = background
    --buttonFrame.pet.unit = buttonFrame.unit
    buttonFrame.pet:HookScript(
        "OnShow",
        function(self)
            print("show pet")
        end
    )
    buttonFrame.unit.name:SetPoint("BOTTOMLEFT", buttonFrame.unit, "BOTTOMLEFT", 2, 2)
    buttonFrame.unit.healthBar.text:SetPoint("BOTTOMRIGHT", 2, 2)
    buttonFrame.unit.auras = {}
    srslylawlUI_Frame_ResetDimensions(buttonFrame)
end
local configString =
    [[
        -- me is UnitButtonFrameX
        local me = self:GetName()
        local partyHeader = self:GetParent()
        --local unit = self:GetChildren()
        --local healthBar, powerBar = unit:GetChildren()
        partyHeader:CallMethod("initialConfigFunction", me)
]]
function srslylawlUI_Frame_OnShow(button)
    -- button = UnitButtonX
    local unit = button:GetAttribute("unit")
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
    -- UTF-8 Reference:
    -- 0xxxxxx - ASCII character
    -- 110yyyxx - 2 byte UTF codepoint
    -- 1110yyyy - 3 byte UTF codepoint
    -- 11110zzz - 4 byte UTF codepoint
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
        button.name:SetText(substring)
        if button.name:GetStringWidth() <= maxLength then
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
        button.dead = false
    end
end
function srslylawlUI_ResetPowerBar(button, unit)
    local powerType, powerToken = UnitPowerType(unit)
    local powerColor = PowerBarColor[powerToken]
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
function srslylawlUI_Button_OnDragStart(self, button)
    if not srslylawlUI_PartyHeader:IsMovable() then
        return
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
    end
end
local function ShowHideAllUnits()
    for k, v in ipairs(srslylawlUI_PartyHeader) do
        v:Hide()
        v:Show()
    end
end
function srslylawlUI_Frame_OnEvent(self, event, arg1, ...)
    local unit = self:GetAttribute("unit")
    if not unit then
        return
    end
    -- Handle any events that don’t accept a unit argument
    if event == "PLAYER_ENTERING_WORLD" then
        srslylawlUI_Frame_ResetDimensions(self)
        srslylawlUI_Frame_HandleAuras(self.unit, unit)
    elseif event == "PLAYER_TARGET_CHANGED" then
        if UnitIsUnit(unit, "target") then
            self.unit.selected:Show()
        else
            self.unit.selected:Hide()
        end
    elseif arg1 and UnitIsUnit(unit, arg1) then
        if event == "UNIT_MAXHEALTH" then
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
                self.unit.name:SetTextColor(r, g, b)
            else
                self.unit.name:SetTextColor(1, 1, 1)
            end
        elseif event == "UNIT_CONNECTION" then
            srslylawlUI_ResetHealthBar(self.unit, unit)
            srslylawlUI_ResetPowerBar(self.unit, unit)
            srslylawlUI_Log(UnitName(unit) .. " went on/offline")
        elseif event == "UNIT_AURA" then
            srslylawlUI_Frame_HandleAuras(self.unit, unit)
        elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            srslylawlUI_Frame_HandleAuras(self.unit, unit, true)
        elseif event == "UNIT_HEAL_PREDICTION" then
        --UnitGetIncomingHeals(unit)
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
local function srslylawlUI_RememberSpellID(id, buffIndex, unit)
    if settings.spellList[id] then
        return
    end

    local n = GetSpellInfo(id)
    local s = GetBuffText(buffIndex, unit)
    local t
    if s ~= nil then
        t = string.lower(s)
    else
        t = ""
    end

    local keyWordAbsorb = t:match("absorb") and true or false --returns true if has absorb in text, false if otherwise
    settings.spellList[id] = {
        name = n,
        text = t,
        hasAbsorbKeyWord = keyWordAbsorb
    }
    if keyWordAbsorb and settings.autoApproveAbsorbKeyWord then
        settings.approvedSpells[id] = {
            name = n,
            text = t,
            hasAbsorbKeyWord = keyWordAbsorb
        }
        srslylawl_saved.settings.approvedSpells = deepcopy(settings.approvedSpells)
        srslylawlUI_Log("spell auto-approved " .. n .. "!")
    else
        settings.pendingSpells[id] = {
            name = n,
            text = t,
            hasAbsorbKeyWord = keyWordAbsorb
        }
        srslylawlUI_Log("new spell: " .. n .. "!")
    end

    srslylawl_saved.settings.spellList = deepcopy(settings.spellList)
    srslylawl_saved.settings.pendingSpells = deepcopy(settings.pendingSpells)
end
local function srslylawlUI_ApproveSpellID(id)
    if settings.spellList[id] then
        return
    end
    srslylawlUI_Log("spell approved: " .. id .. "!")
    settings.approvedSpells[id] = {
        name = GetSpellInfo(id)
    }
    table.remove(settings.pendingSpells, id)
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
            f:SetScript(
                "OnLoad",
                function(self)
                end
            )
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
        print("exist, reassigning")
        unitbutton.buffFrames = {}
        unitbutton.buffFrames = units[unit].buffFrames
        unitbutton.buffFrames[1]:SetParent(unitbutton)
    end
    local function trackSpell(castBy, id, name, index, absorb, icon, duration, expirationTime, verify)
        if verify ~= true then
            srslylawlUI_Log(name .. " added")
        else
            --srslylawlUI_Log(name .. " verified ")
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

        units[unit].absorbAurasByIndex[index] = {
            ["castBy"] = castBy,
            ["name"] = name,
            ["spellID"] = id,
            ["checkedThisEvent"] = true,
            ["absorb"] = absorb,
            ["icon"] = icon,
            ["duration"] = duration,
            ["expiration"] = expirationTime,
            ["wasRefreshed"] = flagRefreshed
        }
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
        --srslylawlUI_Log("index changed " .. name)
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

        units[unit].absorbAurasByIndex[i] = {
            ["castBy"] = source,
            ["name"] = name,
            ["spellID"] = spellId,
            ["checkedThisEvent"] = true,
            ["absorb"] = absorb,
            ["icon"] = icon,
            ["duration"] = duration,
            ["expiration"] = expirationTime,
            ["wasRefreshed"] = flagRefreshed
        }
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
    local pixelPerHp = width / UnitHealthMax(unit)
    local playerCurrentHP = UnitHealth(unit)

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
            f:SetStatusBarTexture("Interface/RAIDFRAME/Shield-Fill")
            f:SetStatusBarColor(1, 1, 1, .8)
            f:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", 1, 0)
            f:SetHeight(height)
            f:SetWidth(40)
            f:CreateTexture()
            local t = f:CreateTexture(nil, "BACKGROUND")
            t:SetColorTexture(0, 0, 0, .5)
            t:SetPoint("CENTER", f, "CENTER")
            --t:SetParent(f)
            t:SetHeight(height + 2)
            t:SetWidth(42)
            f.background = t
            f:Hide()
            f["icon"] = f:CreateTexture(nil, "OVERLAY")
            f["icon"]:SetPoint("CENTER")
            f["icon"]:SetHeight(15)
            f["icon"]:SetWidth(15)
            f["icon"]:Hide()
            f["cooldown"] = CreateFrame("Cooldown", n .. "CD", f, "CooldownFrameTemplate")

            f["cooldown"]:SetPoint("CENTER")
            f["cooldown"]:SetHeight(100)
            f["cooldown"]:SetWidth(100)
            f["cooldown"]:SetReverse(true)
            f["cooldown"]:Show()

            units[unit]["absorbFrames"][i] = f
        end
    end

    if remainingTrackedAuraCount == 0 and units[unit].activeAbsorbFrames > 0 then
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
    for key, value in pairs(units[unit].absorbAurasByIndex) do
        local absorbAmount = units[unit].absorbAurasByIndex[key].absorb
        local current = units[unit]["absorbFrames"][curBarIndex]
        local iconID = units[unit].absorbAurasByIndex[key].icon
        local duration = units[unit].absorbAurasByIndex[key].duration
        local expirationTime = units[unit].absorbAurasByIndex[key].expiration
        local startTime = expirationTime - duration
        local wasRefreshed = units[unit].absorbAurasByIndex[key].wasRefreshed
        --check if our current frame is already set up correctly
        if current:GetAttribute("absorbAmount") ~= absorbAmount then
            srslylawlUI_ChangeAbsorbSegment(current, pixelPerHp, absorbAmount, height)
        end
        if not current:IsVisible() then
            units[unit].activeAbsorbFrames = units[unit].activeAbsorbFrames + 1
        end
        if wasRefreshed then
            CooldownFrame_Set(current.cooldown, GetTime(), duration, true)
        else
            CooldownFrame_Set(current.cooldown, startTime, duration, true)
        end

        current.icon:SetTexture(iconID)
        current.icon:Show()
        current:Show()
        curBarIndex = curBarIndex + 1
        if (curBarIndex >= maxFrames) then
            print("frame limit reached")
        end
    end
    for i = curBarIndex, maxFrames do
        if units[unit]["absorbFrames"][i]:IsVisible() then
            units[unit]["absorbFrames"][i]:Hide()
            units[unit].activeAbsorbFrames = units[unit].activeAbsorbFrames - 1
        end
    end
end
function srslylawlUI_ChangeAbsorbSegment(frame, pixelPerHp, absorbAmount, height)
    local barWidth = floor(pixelPerHp * absorbAmount)
    frame:SetAttribute("absorbAmount", absorbAmount)
    frame:SetHeight(height)
    frame:SetWidth(barWidth)
    frame.background:SetHeight(height + 2)
    frame.background:SetWidth(barWidth + 2)
end
local function HeaderSetup()
    local header = srslylawlUI_PartyHeader
    header:SetAttribute("initialConfigFunction", configString)
    header.initialConfigFunction = srslylawlUI_InitialConfig
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
        else
            return nil
        end
    end
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
    local h = settings.hp.height
    local w = settings.hp.width
    button:SetWidth(w + 2)
    button:SetHeight(h + 2)
    button.unit:SetWidth(w) --this leads to taint in combat
    button.unit:SetHeight(h) --this leads to taint in combat
    button.unit.healthBar:SetWidth(w)
    button.unit.healthBar:SetHeight(h)
    button.unit.powerBar:SetHeight(h)
    button.unit.powerBar.background:SetHeight(h + 2)
    button.unit.powerBar.background:SetWidth(button.unit.powerBar:GetWidth() + 2)
    button.pet:Execute([[
        local h = self:GetFrameRef("unit"):GetHeight()
        self:SetHeight(h)]])
    button.pet.bg:SetHeight(settings.hp.height + 2)
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
            srslylawlUI_Frame_Reset_All()
            srslylawlUI_SetDirtyFlag()
        end
    )
    cFrame.sliders.hpwidth = CreateCustomSlider("Health Bar Max Width", 25, 2000, width, cFrame.sliders.height, -40)
    cFrame.sliders.hpwidth:HookScript(
        "OnValueChanged",
        function(self, value)
            local v = value
            settings.hp.width = v
            srslylawlUI_Frame_Reset_All()
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
            LoadSettings(true)
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
end
local function CreateSlashCommands()
    -- Setting Slash Commands
    SLASH_SRSLYLAWLUI1 = "/srslylawlUI"
    SLASH_SRSLYLAWLUI2 = "/srslylawlUI"
    SLASH_SRSLYLAWLUI3 = "/srsUI"
    SLASH_SRSLYLAWLUI4 = "/srslylawl"
    SLASH_SRSLYLAWLUI5 = "/srslylawl save"

    SlashCmdList["SRSLYLAWLUI"] = function(msg, txt)
        if msg and msg == "save" then
            SaveSettings()
        else
            srslylawlUI_ToggleConfigVisible(true)
        end
    end
end
local function srslylawlUI_Initialize()
    LoadSettings()
    HeaderSetup()
    CreateSlashCommands()
    CreateConfig()
    --srslylawlUI_Frame_Reset_All()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript(
    "OnEvent",
    function(self, event, addon)
        if (event == "PLAYER_LOGIN") then
            srslylawlUI_Initialize()
            self:UnregisterEvent("PLAYER_LOGIN")
        elseif (event == "ADDON_LOADED" and (addon == "Blizzard_ArenaUI" or addon == "Blizzard_CompactRaidFrames")) then
            --ShadowUF:HideBlizzardFrames()
            print(addon .. " loaded")
        end
    end
)
