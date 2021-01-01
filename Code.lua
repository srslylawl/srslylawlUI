srslylawlUI = {}

srslylawlUI.settings = {
    header = {anchor = "CENTER", xOffset = 10, yOffset = 10},
    hp = {width = 100, height = 50, minWidthPercent = 0.45},
    pet = {width = 15},
    buffs = { anchor = "TOPLEFT", xOffset = -29, yOffset = 0, size = 16, growthDir = "LEFT",
            showCastByPlayer = true, maxBuffs = 15, maxDuration = 60, showDefensives = true},
    debuffs = { anchor = "BOTTOMLEFT", xOffset = -29, yOffset = 0, size = 16, growthDir = "LEFT", showCastByPlayer = true,
            maxDebuffs = 15, maxDuration = 180},
    absorbOverlapPercent = 0.1,
    maxAbsorbFrames = 20,
    minAbsorbAmount = 100,
    autoApproveKeywords = true,
    showArena = false,
    showParty = true,
    showSolo = true,
    showRaid = false,
    showPlayer = true,
    frameOnUpdateInterval = 0.1
}
srslylawlUI.spells = {
    known = {},
    absorbs = {},
    defensives = {},
    whiteList = {},
    blackList = {}
}
srslylawlUI.sortedSpellLists = {
    buffs = { 
        known = {},
        absorbs = {},
        defensives = {},
        whiteList = {},
        blackList = {}
    },
    debuffs = {
        known = {},
        absorbs = {},
        defensives = {},
        whiteList = {},
        blackList = {}
    }
}
local powerUpdateType = "UNIT_POWER_UPDATE" -- "UNIT_POWER_UPDATE" or "UNIT_POWER_FRQUENT"
local unsaved = {flag = false, buttons = {}}

-- "units" tracks auras and frames
local units = {
    player = {},
    party1 = {},
    party2 = {},
    party3 = {},
    party4 = {},
}
local unitHealthBars = {}
srslylawlUI.units = units
srslylawlUI.AuraHolderFrame = CreateFrame("Frame", "srslylawlUI_AuraHolderFrame", nil, nil)
srslylawlUI.sortTimerActive = false


local tooltipTextGrabber = CreateFrame("GameTooltip", "srslylawl_TooltipTextGrabber", UIParent, "GameTooltipTemplate")
local customTooltip = CreateFrame("GameTooltip", "srslylawl_CustomTooltip", UIParent, "GameTooltipTemplate")

local unitTable = { "player", "party1", "party2", "party3", "party4"}
local anchorTable = {
    "TOP", "RIGHT", "BOTTOM", "LEFT", "CENTER", "TOPRIGHT", "TOPLEFT",
    "BOTTOMLEFT", "BOTTOMRIGHT"
}
local debugString = ""



-- TODO:
--      rare bug: absorb frame sometimes does not show up (observed with warlock and power word shield, use /srsdbg to debug)
--      right click buffs to blacklist them
--      readycheck
--      necrotic/healabsorb
--      debuff white/blacklist/spellremember etc
--      CC
--      phase/shard
--      UnitHasIncomingResurrection(unit)
--      config window


--Utils
function srslylawlUI.Log(text, ...)
    str = ""
    for i = 1, select('#', ...) do
        str = str .. (select(i, ...) .. " ")
    end
    print("|cff4D00FFsrslylawlUI:|r " .. text, str)
end
function srslylawlUI.Utils_ShortenString(str, start, numChars)
    -- This function can return a substring of a UTF-8 string, properly handling UTF-8 codepoints. Rather than taking a start index and optionally an end index, it takes the string, the start index, and
    -- the number of characters to select from the string.
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
function srslylawlUI.Utils_TableDeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[srslylawlUI.Utils_TableDeepCopy(orig_key)] = srslylawlUI.Utils_TableDeepCopy(orig_value)
        end
        setmetatable(copy, srslylawlUI.Utils_TableDeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
function srslylawlUI.Utils_TableEquals(table1, table2)
    if table1 == table2 then return true end
    local table1Type = type(table1)
    local table2Type = type(table2)
    if table1Type ~= table2Type then return false end
    if table1Type ~= "table" then return false end

    local keySet = {}

    for key1, value1 in pairs(table1) do
        local value2 = table2[key1]
        if value2 == nil or srslylawlUI.Utils_TableEquals(value1, value2) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(table2) do if not keySet[key2] then return false end end
    return true
end
function srslylawlUI.Utils_GetTableLength(T)
    local count = 0
    if t == nil then return 0
    end
    for _ in pairs(T) do count = count + 1 end
    return count
end
function srslylawlUI.Utils_ScuffedRound(num)
    num = floor(num+0.5)
    return num
end
function srslylawlUI.Utils_DecimalRound(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
function srslylawlUI.Utils_GetUnitNameWithServer(unit)
    local name, server
    if (UnitExists(unit)) then
        name, server = UnitName(unit)
        if (server and server ~= "") then name = name .. "-" .. server end
    end
    return name
end
function srslylawlUI.Debug()
    if srslylawlUI.DebugWindow == nil then
        srslylawlUI.DebugWindow = CreateFrame("Frame", "srslylawlUI_DebugWindow", UIParent)
        srslylawlUI.DebugWindow:SetSize(500, 500)
        srslylawlUI.DebugWindow:SetPoint("CENTER")
        local scrollFrame = CreateFrame("ScrollFrame", "$parent_ScrollFrame", srslylawlUI.DebugWindow, "UIPanelScrollFrameTemplate,BackdropTemplate")
        --scrollFrame:SetSize(500, 500)
        scrollFrame:SetAllPoints()
        scrollFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 12,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
            })
        scrollFrame:SetBackdropColor(0.05, 0.05, .05, .5)
        srslylawlUI.DebugWindow.ScrollFrame = scrollFrame

        local editBox = CreateFrame("EditBox", "$parent_EditBox", srslylawlUI.DebugWindow.ScrollFrame)
        scrollFrame:SetScrollChild(editBox)
        editBox:SetTextInsets(5, 5, 15, 15)
        editBox:SetSize(450, 200)
        editBox:SetPoint("TOPLEFT")
        editBox:SetAutoFocus(false)
        editBox:SetFont("Fonts\\FRIZQT__.TTF", 10)
        editBox:SetNumeric(false)
        editBox:SetMultiLine(true)
        editBox:SetFontObject(ChatFontNormal)
        srslylawlUI.DebugWindow.EditBox = editBox
        srslylawlUI.DebugWindow.CloseButton = CreateFrame("Button", "srslylawlUI_DebugWindow_CloseButton",
                                     srslylawlUI.DebugWindow,
                                     "UIPanelCloseButton")
        srslylawlUI.DebugWindow.CloseButton:SetPoint("BOTTOMLEFT", srslylawlUI.DebugWindow, "TOPRIGHT", 0, 0)
    end

    local text = "Debug \n"

    local function AnchorToString(...)
        local s = ""
        for i=1,select('#', ...) do
            local val = select(i, ...)
            if type(val) == "table" then
                val = val:GetName()
            end
            s = s .. val .. " "
        end

        return s
    end

    for k, v in pairs(srslylawlUI.units) do
        local absorbFrameVisible = v.absorbFrames[1]:IsVisible()
        local absorbOverlapFrameVisible = v.absorbFramesOverlap[1]:IsVisible()
        local s = "________________\n" .. k .. "\n" .. (absorbFrameVisible and "Absorb Frame is visible! :)" or "Absorb Frame not visible") .. "\n" ..
        "Anchor: " .. AnchorToString(v.absorbFrames[1]:GetPoint()) .. "\n\n" ..
        (absorbOverlapFrameVisible and "Absorb Overlap Frame is visible! :)" or "Absorb Overlap Frame not visible") .. "\n" ..
        "Anchor: " .. AnchorToString(v.absorbFramesOverlap[1]:GetPoint()) .. "\n"

        text = text .. s .. "\n\n"
    end



    debugString = text
    srslylawlUI.DebugWindow.EditBox:SetText(debugString)
    srslylawlUI.DebugWindow:Show()
end

--Frame
function srslylawlUI.SetBuffFrames()
    for k, v in pairs(units) do
        if units[k] ~= nil and units[k].buffFrames ~= nil then
            for i = 1, srslylawlUI.settings.buffs.maxBuffs do
                local size = srslylawlUI.settings.buffs.size
                local xOffset, yOffset = srslylawlUI.GetBuffOffsets()
                local anchor = "CENTER"
                if (i == 1) then
                    anchor = srslylawlUI.settings.buffs.anchor
                    xOffset = srslylawlUI.settings.buffs.xOffset
                    yOffset = srslylawlUI.settings.buffs.yOffset
                    units[k].buffFrames[i]:SetParent(srslylawlUI.Frame_GetByUnitType(k).unit.auraAnchor)
                end

                if units[k].buffFrames[i] == nil then
                    error('Max visible buffs setting has been changed, please reload UI by typing "/reload" ')
                end
                units[k].buffFrames[i]:ClearAllPoints()
                units[k].buffFrames[i]:SetPoint(anchor, xOffset, yOffset)
                units[k].buffFrames[i]:SetSize(size, size)
            end
        end
    end
end
function srslylawlUI.SetDebuffFrames()
    for k, v in pairs(units) do
        if units[k] ~= nil and units[k].debuffFrames ~= nil then
            for i = 1, srslylawlUI.settings.debuffs.maxDebuffs do
                local size = srslylawlUI.settings.debuffs.size
                local xOffset, yOffset = srslylawlUI.GetDebuffOffsets()
                local anchor = "CENTER"
                if (i == 1) then
                    anchor = srslylawlUI.settings.debuffs.anchor
                    xOffset = srslylawlUI.settings.debuffs.xOffset
                    yOffset = srslylawlUI.settings.debuffs.yOffset
                    units[k].debuffFrames[i]:SetParent(srslylawlUI.Frame_GetByUnitType(k).unit.auraAnchor)
                end

                if units[k].debuffFrames[i] == nil then
                    error('Max visible debuffs setting has been changed, please reload UI by typing "/reload" ')
                end

                units[k].debuffFrames[i]:ClearAllPoints()
                units[k].debuffFrames[i]:SetPoint(anchor, xOffset, yOffset)
                units[k].debuffFrames[i]:SetSize(size, size)
            end
        end
    end
end
function srslylawlUI.GetBuffOffsets()
    local xOffset, yOffset
    local size = srslylawlUI.settings.buffs.size
    local growthDir = srslylawlUI.settings.buffs.growthDir
    if growthDir == "LEFT" then
        xOffset = -size
        yOffset = 0
    elseif growthDir == "RIGHT" then
        xOffset = size
        yOffset = 0
    end
    return xOffset, yOffset
end
function srslylawlUI.GetDebuffOffsets()
    local xOffset, yOffset
    local size = srslylawlUI.settings.debuffs.size
    local growthDir = srslylawlUI.settings.debuffs.growthDir
    if growthDir == "LEFT" then
        xOffset = -size
        yOffset = 0
    elseif growthDir == "RIGHT" then
        xOffset = size
        yOffset = 0
    end
    return xOffset, yOffset
end
function srslylawlUI.Frame_InitialUnitConfig(buttonFrame)
    --buttonFrame = _G[buttonFrame]
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
    buttonFrame.TimeSinceLastUpdate = 0
    buttonFrame.wasInRange = true
    if buttonFrame:GetAttribute("unit") ~= "player" then
        buttonFrame:SetScript("OnUpdate", function(self, deltaTime)
            self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + deltaTime;
            if (self.TimeSinceLastUpdate > srslylawlUI.settings.frameOnUpdateInterval) then
                --check for unit range
                local unit = self:GetAttribute("unit")
                local inRange = UnitInRange(unit)
                if self.wasInRange ~= inRange then
                    srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
                end
                self.wasInRange = inRange
                self.TimeSinceLastUpdate = 0;
            end
        end)
    end

    RegisterUnitWatch(buttonFrame.pet)
    buttonFrame.pet:SetFrameRef("unit", buttonFrame.unit)

    srslylawlUI.CreateBackground(buttonFrame.pet)
    if (buttonFrame.unit.healthBar["bg"] == nil) then
        srslylawlUI.CreateBackground(buttonFrame.unit.healthBar)
    end
    buttonFrame.unit.healthBar.name:SetPoint("BOTTOMLEFT", buttonFrame.unit,
                                             "BOTTOMLEFT", 2, 2)
    buttonFrame.unit.healthBar.text:SetPoint("BOTTOMRIGHT", 2, 2)
    buttonFrame.unit.healthBar.text:SetDrawLayer("OVERLAY", 7)
    buttonFrame.unit.auras = {}
    srslylawlUI.Frame_ResetDimensions(buttonFrame)
end
function srslylawlUI.Frame_GetByUnitType(unit)
    -- returns buttonframe that matches unit attribute
    local frame = _G["srslylawlUI_PartyHeader_"..unit]

    if frame and type(frame) == "table" then return frame end

    return nil
end
function srslylawlUI.Frame_ResetAllFrames()
    for k, v in pairs(unitTable) do
        local button = srslylawlUI.Frame_GetByUnitType(v)
        if v then
            srslylawlUI.Frame_ResetDimensions(button)
        end
    end
end
function srslylawlUI.Frame_ResetDimensions(button)
    local unitType = button:GetAttribute("unit")
    local h = srslylawlUI.settings.hp.height
    local w = srslylawlUI.settings.hp.width
    if unitHealthBars ~= nil then
        if unitHealthBars[unitType] ~= nil then
            if unitHealthBars[unitType]["width"] ~= nil then
                w = unitHealthBars[unitType]["width"]
            end
        end
    end

    local needsResize = abs(button.unit.healthBar:GetWidth() - w) > 1 or
                            abs(button.unit.healthBar:GetHeight() - h) > 1
    if needsResize then
        -- print("sizing req, cur:", button.unit.healthBar:GetWidth(), "tar", w)
        button.unit.auraAnchor:SetSize(srslylawlUI.settings.hp.width, srslylawlUI.settings.hp.height)
        button.unit.healthBar:SetSize(w, h)
        if button.unit.healthBar["bg"] == nil then
            srslylawlUI.CreateBackground(button.unit.healthBar)
        end
        button.unit.healthBar.bg:SetSize(w + 2, h + 2)
        button.unit.powerBar:SetHeight(h)
        button.unit.powerBar.background:SetSize(button.unit.powerBar:GetWidth() + 2, h + 2)

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

    srslylawlUI.Frame_ResetUnitButton(button.unit, button:GetAttribute("unit"))
end
function srslylawlUI.Frame_IsHeaderVisible()
    return srslylawlUI_PartyHeader:IsVisible()
end
function srslylawlUI.Frame_UpdateVisibility()
    local function UpdateHeaderVisible(show)
        local frame = srslylawlUI_PartyHeader
        if show then
            if not frame:IsShown() then
                frame:Show()
            end
        else
            if frame:IsShown() then
                frame:Hide()
            end
        end
    end

    --if true then return end

    local isInArena = C_PvP.IsArena()
    local isInBG = C_PvP.IsBattleground()
    local isInGroup = IsInGroup() and not IsInRaid()
    local isInRaid = IsInRaid() and not C_PvP.IsArena()

    if isInGroup then
        UpdateHeaderVisible(srslylawlUI.settings.showParty)
    elseif isInRaid then
        UpdateHeaderVisible(srslylawlUI.settings.showRaid)
    elseif isInArena then
        UpdateHeaderVisible(srslylawlUI.settings.showArena)
    else
        local frame = srslylawlUI_PartyHeader.player
        if srslylawlUI.settings.showSolo then
            if not frame:IsShown() then
                RegisterUnitWatch(frame)
            end
        else
            if frame:IsShown() then
                UnregisterUnitWatch(frame)
            end
        end
        UpdateHeaderVisible(srslylawlUI.settings.showSolo)
    end
end
function srslylawlUI.Frame_MakeFrameMoveable(frame)
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
function srslylawlUI_Frame_OnEvent(self, event, arg1, ...)
    local unit = self:GetAttribute("unit")
    local unitExists = UnitExists(unit)
    if not unitExists then return end
    if not unit then error(self:GetName() .. "has no assigned unit") end
    -- Handle any events that don’t accept a unit argument
    if event == "PLAYER_ENTERING_WORLD" then
        srslylawlUI.Frame_HandleAuras(self.unit, unit, true)
    elseif event == "GROUP_ROSTER_UPDATE" then
        srslylawlUI.Frame_ResetUnitButton(self.unit, unit)
    elseif event == "PLAYER_TARGET_CHANGED" then
        if UnitIsUnit(unit, "target") then
            self.unit.selected:Show()
        else
            self.unit.selected:Hide()
        end
    elseif arg1 and UnitIsUnit(unit, arg1) and arg1 ~= "nameplate1" then
        if event == "UNIT_MAXHEALTH" then
            if self.unit.dead ~= UnitIsDeadOrGhost(unit) then
                srslylawlUI.Frame_ResetUnitButton(self.unit, unit)
                srslylawlUI.Frame_HandleAuras(self.unit, unit, true)
            end
            self.unit.healthBar:SetMinMaxValues(0, UnitHealthMax(unit))
            self.unit.healthBar:SetValue(UnitHealth(unit))
        elseif event == "UNIT_HEALTH" then
            srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
            srslylawlUI.Frame_HandleAuras(self.unit, unit)
        elseif event == "UNIT_DISPLAYPOWER" then
            srslylawlUI.Frame_ResetPowerBar(self.unit, unit)
        elseif event == powerUpdateType then
            self.unit.powerBar:SetValue(UnitPower(unit))
        elseif event == "UNIT_NAME_UPDATE" then
            srslylawlUI.Frame_ResetName(self.unit, unit)
        elseif event == "UNIT_THREAT_SITUATION_UPDATE" then
            local status = UnitThreatSituation(unit)
            if status and status > 0 then
                local r, g, b = GetThreatStatusColor(status)
                self.unit.healthBar.name:SetTextColor(r, g, b)
            else
                self.unit.healthBar.name:SetTextColor(1, 1, 1)
            end
        elseif event == "UNIT_CONNECTION" then
            srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
            srslylawlUI.Frame_ResetPowerBar(self.unit, unit)
            srslylawlUI.Log(UnitName(unit) .. (UnitIsConnected(unit) and " came online." or " disconnected."))
        elseif event == "UNIT_AURA" then
            srslylawlUI.Frame_HandleAuras(self.unit, unit)
        elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            srslylawlUI.Frame_HandleAuras(self.unit, unit, true)
        elseif event == "UNIT_HEAL_PREDICTION" then
            srslylawlUI.Frame_HandleAuras(self.unit, unit, true)
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
function srslylawlUI.Frame_ResetUnitButton(button, unit)
    if unit == nil then error("trying to reset nonexisting button"..unit) return end
    srslylawlUI.Frame_ResetHealthBar(button, unit)
    srslylawlUI.Frame_ResetPowerBar(button, unit)
    srslylawlUI.Frame_ResetName(button, unit)
    if UnitIsUnit(unit, "target") then
        button.selected:Show()
    else
        button.selected:Hide()
    end
end
function srslylawlUI.Frame_ResetName(button, unit)
    local name = UnitName(unit) or UNKNOWN
    local substring
    local maxLength = srslylawlUI.settings.hp.width
    for length = #name, 1, -1 do
        substring = srslylawlUI.Utils_ShortenString(name, 1, length)
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
function srslylawlUI.Frame_ResetPetButton(button, unit)
    if UnitExists(unit) then
        local health = UnitHealth(unit)
        local maxHealth = UnitHealth(unit)
        button.healthBar:SetMinMaxValues(0, maxHealth)
        button.healthBar:SetValue(health)
    end
end
function srslylawlUI.Frame_ResetHealthBar(button, unit)
    local class = select(2, UnitClass(unit)) or "WARRIOR"
    local classColor = RAID_CLASS_COLORS[class]
    local alive = not UnitIsDeadOrGhost(unit)
    local health = UnitHealth(unit)
    local healthMax = UnitHealthMax(unit)
    local healthPercent = ceil(health / healthMax * 100)
    local online = UnitIsConnected(unit)
    local SBColor = { r = classColor.r, g = classColor.g, b =classColor.b, a = classColor.a}
    -- button.healthBar.text:SetText(health .. "/" .. healthMax .. " " ..
    --                                 healthPercent .. "%")

    button.healthBar.text:SetText(health .. " " .. healthPercent .. "%")
    if not alive or not online then
        -- If dead, set bar color to grey and fill bar
        SBColor.r, SBColor.g, SBColor.b = 0.3, 0.3, 0.3
        button.healthBar:SetMinMaxValues(0, 1)
        button.healthBar:SetValue(1)
        button.dead = true
        if not alive then button.healthBar.text:SetText("DEAD") end
        if not online then button.healthBar.text:SetText("offline") end
    else
        button.healthBar:SetMinMaxValues(0, healthMax)
        button.healthBar:SetValue(health)
        button.dead = false
    end

    if unit == "player" or UnitInRange(unit) then SBColor.a = 1
    else SBColor.a = 0.4
    end

    button.healthBar:SetStatusBarColor(SBColor.r, SBColor.g, SBColor.b, SBColor.a)
end
function srslylawlUI.Frame_ResetPowerBar(button, unit)
    local powerType, powerToken = UnitPowerType(unit)
    local powerColor = srslylawlUI.Frame_GetCustomPowerBarColor(powerToken)
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
function srslylawlUI.Frame_GetCustomPowerBarColor(powerToken)
    local color = PowerBarColor[powerToken]
    if powerToken == "MANA" then
        color.r, color.g, color.b = 0.349, 0.522, 0.953
    end
    return color
end
function srslylawlUI.Frame_ResizeHealthBarScale()
    local list, highestHP, averageHP = srslylawlUI.GetPartyHealth()

    if not highestHP then
        return
    end

    --only one sortmethod for now
    local scaleByHighest = true
    local lowerCap = srslylawlUI.settings.hp.minWidthPercent -- bars can not get smaller than this percent of highest
    local pixelPerHp = srslylawlUI.settings.hp.width / highestHP
    local minWidth = floor(highestHP * pixelPerHp * lowerCap)

    if scaleByHighest then
        for unit, _ in pairs(unitHealthBars) do
            local scaledWidth = (unitHealthBars[unit]["maxHealth"] *
                                    pixelPerHp)
            local scaledWidth = scaledWidth < minWidth and minWidth or
                                    scaledWidth
            unitHealthBars[unit]["width"] = scaledWidth
        end
    else -- sort by average
    end
    srslylawlUI.Frame_ResetAllFrames()
end
function srslylawlUI_Button_OnDragStart(self, button)
    if not srslylawlUI_PartyHeader:IsMovable() then return end
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
        srslylawlUI.SetDirtyFlag()
    end
end
function srslylawlUI_Frame_OnShow(button)
    local unit = button:GetAttribute("unit")
    if unit then
        local guid = UnitGUID(unit)
        if guid ~= button.guid then
            srslylawlUI.Frame_ResetUnitButton(button.unit, unit)
            button.guid = guid
        end
    end
end
function srslylawlUI_Frame_OnHide(button)
    local unit = button:GetAttribute("unit")

    if unit == nil then
        srslylawlUI.Log("error unit nil on frame hide")
        return
    end
    if units[unit]["absorbFrames"] ~= nil then
        units[unit]["absorbFrames"][1]:Hide()
    end
    if units[unit]["absorbFramesOverlap"] ~= nil then
        units[unit]["absorbFramesOverlap"][1]:Hide()
    end
    if units[unit]["effectiveHealthFrames"] ~= nil then
        units[unit]["effectiveHealthFrames"][1]:Hide()
    end
end

--Sorting
function srslylawlUI.SortAfterCombat()
    srslylawlUI_EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
end
function srslylawlUI.SortAfterLogin()
    local _, _, _, hasUnknownMember = srslylawlUI.GetPartyHealth()
    if srslylawlUI.Frame_IsHeaderVisible and not hasUnknownMember then
        srslylawlUI_EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        srslylawlUI_EventFrame:RegisterEvent("UNIT_MAXHEALTH")
        srslylawlUI.UpdateEverything()
    else
        C_Timer.After(.5, function() srslylawlUI.SortAfterLogin() end)
    end
end
function srslylawlUI.SortPartyFrames()
    --print("sort called")
    local list, _, _, hasUnknownMember = srslylawlUI.GetPartyHealth()

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
                srslylawlUI.SortPartyFrames()
            end)
        end
        return
    end

    for i = 1, #list do
        local buttonFrame = srslylawlUI.Frame_GetByUnitType(list[i].unit)
        --print(i, ".", list[i].unit, list[i].name, list[i].maxHealth)

        if (buttonFrame) then
            buttonFrame:ClearAllPoints()
            if i == 1 then
                buttonFrame:SetPoint("TOPLEFT", srslylawlUI_PartyHeader,
                                     "TOPLEFT")
            else
                local parent = srslylawlUI.Frame_GetByUnitType(list[i - 1].unit)
                buttonFrame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT")
            end
            srslylawlUI.Frame_ResetUnitButton(buttonFrame.unit, list[i].unit)
        end
    end

    --print("sort done")
end
function srslylawlUI.UpdateEverything()
    if InCombatLockdown() == false then
        srslylawlUI.SortPartyFrames()
        srslylawlUI.Frame_ResizeHealthBarScale()
    else
        C_Timer.After(1, function() srslylawlUI.UpdateEverything() end)
    end
end
function srslylawlUI.GetPartyHealth()
    local nameStringSortedByHealthDesc = {}
    local hasUnknownMember = false

    local highestHP, averageHP, memberCount = 0, 0, 0

    local currentUnit = "player"
    local partyIndex = 0
    if not UnitExists("player") then
        --error("player doesnt exist?")
        return nil
    else
        -- loop through all units
        repeat
            if unitHealthBars[currentUnit] == nil then
                unitHealthBars[currentUnit] = {}
            end
            local maxHealth = UnitHealthMax(currentUnit)
            if maxHealth > highestHP then highestHP = maxHealth end
            local name = srslylawlUI.Utils_GetUnitNameWithServer(currentUnit)

            if name == "Unknown" or maxHealth == 1 then
                hasUnknownMember = true
            end

            unitHealthBars[currentUnit]["maxHealth"] = maxHealth
            unitHealthBars[currentUnit]["unit"] = currentUnit
            unitHealthBars[currentUnit]["name"] = name

            averageHP = averageHP + maxHealth
            table.insert(nameStringSortedByHealthDesc,
                         unitHealthBars[currentUnit])
            memberCount = memberCount + 1
            currentUnit = "party" .. memberCount
        until not UnitExists(currentUnit)
    end

    table.sort(nameStringSortedByHealthDesc,
               function(a, b) return b.maxHealth < a.maxHealth end)
    averageHP = floor(averageHP / memberCount)

    return nameStringSortedByHealthDesc, highestHP, averageHP, hasUnknownMember
end

--Auras
function srslylawlUI.Auras_GetBuffText(buffIndex, unit)
    tooltipTextGrabber:SetOwner(srslylawlUI_PartyHeader, "ANCHOR_NONE")
    tooltipTextGrabber:SetUnitBuff(unit, buffIndex)
    local n2 = srslylawl_TooltipTextGrabberTextLeft2:GetText()
    tooltipTextGrabber:Hide()
    return n2
end
function srslylawlUI.Frame_HandleAuras(unitbutton, unit, absorbChanged)
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

        if units[unit][byIndex][index].source == nil then
            error("error while untracking an aura", units[unit][byIndex][index].name)
        end

        local src = units[unit][byIndex][index].source

        local s = units[unit][byIndex][index].spellId

        if units[unit][byAura][src] == nil or units[unit][byAura][src][s] == nil then
            --error("error while untracking an aura", units[unit][byIndex][index].name)
        end

        units[unit][byIndex][index] = nil

        if units[unit][byAura][src] == nil then
            return;
        end
        units[unit][byAura][src][s] = nil
        local t = srslylawlUI.Utils_GetTableLength(units[unit][byAura][src])

        --No more auras being tracked for that unit, untrack source
        if t == 0 then units[unit][byAura][src] = nil end
    end
    local function ChangeTrackingIndex(name, source, count, spellId,
                                       currentIndex, absorb, icon, duration,
                                       expirationTime, auraType)
        -- srslylawlUI.Log("index changed " .. name)
        local byAura = auraType .. "Auras"
        local byIndex = "trackedAurasByIndex"
        local oldIndex = units[unit][byAura][source][spellId].index
        assert(oldIndex ~= nil)
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

    if not UnitExists(unit) then
        error(unit.. "does not exist")
    end

    if unitbutton["buffFrames"] == nil and srslylawlUI.settings.buffs.maxBuffs > 0 then -- this unit doesnt own the frames yet
        unitbutton.buffFrames = {}
        unitbutton.buffFrames = units[unit].buffFrames
        if unitbutton.buffFrames[1] == nil then
            error('Max visible buffs setting has been changed, please reload UI by typing "/reload" ')
        end
        srslylawlUI.SetBuffFrames()
    end
    if unitbutton["debuffFrames"] == nil and srslylawlUI.settings.debuffs.maxDebuffs > 0 then -- this unit doesnt own the frames yet
        unitbutton.debuffFrames = {}
        unitbutton.debuffFrames = units[unit].debuffFrames
        if unitbutton.debuffFrames[1] == nil then
            error('Max visible debuffs setting has been changed, please reload UI by typing "/reload" ')
        end
        srslylawlUI.SetDebuffFrames()
    end
    -- frames exist and unit owns them
    -- reset frame check verifier
    for k, v in pairs(units[unit].trackedAurasByIndex) do
        v["checkedThisEvent"] = false
    end
    -- process buffs on unit
    local currentBuffFrame = 1
    for i = 1, 40 do
        -- loop through all frames on standby and assign them based on their index
        local f = unitbutton.buffFrames[currentBuffFrame]
        local name, icon, count, debuffType, duration, expirationTime, source,
              isStealable, nameplateShowPersonal, spellId, canApplyAura,
              isBossDebuff, castByPlayer, nameplateShowAll, timeMod, absorb =
            UnitAura(unit, i, "HELPFUL")
        if name then -- if aura on this index exists, assign it
            srslylawlUI.Auras_RememberSpellID(spellId, i, unit, absorb)
            if srslylawlUI.Auras_ShouldDisplayBuff(UnitAura(unit, i)) and i <= srslylawlUI.settings.buffs.maxBuffs then
                CompactUnitFrame_UtilSetBuff(f, i, UnitAura(unit, i))
                f:SetID(i)
                f:Show()
                currentBuffFrame = currentBuffFrame + 1
            else
                f:Hide()
            end
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
    -- process debuffs on unit
    currentDebuffFrame = 1
    for i = 1, 40 do
        local f = unitbutton.debuffFrames[currentDebuffFrame]
        local name, icon, count, debuffType, duration, expirationTime, source,
              isStealable, nameplateShowPersonal, spellId, canApplyAura,
              isBossDebuff, castByPlayer, nameplateShowAll, timeMod, absorb =
            UnitAura(unit, i, "HARMFUL")
        if name then -- if aura on this index exists, assign it
            --srslylawlUI.RememberSpellID(spellId, i, unit, absorb)

            --TODO: remember debuff auras
            if true and i <= srslylawlUI.settings.debuffs.maxDebuffs then
                f.icon:SetTexture(icon)
                if ( count > 1 ) then
		            local countText = count;
		            if ( count >= 100 ) then
			            countText = BUFF_STACKS_OVERFLOW;
		            end
		            f.count:Show();
		            f.count:SetText(countText);
	            else
		            f.count:Hide();
	            end
                f:SetID(i)
                local enabled = expirationTime and expirationTime ~= 0;
	            if enabled then
		            local startTime = expirationTime - duration;
		            CooldownFrame_Set(f.cooldown, startTime, duration, true);
	            else
		            CooldownFrame_Clear(f.cooldown);
                end
                local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
	            f.border:SetVertexColor(color.r, color.g, color.b);

                f:Show()
                currentDebuffFrame = currentDebuffFrame + 1
            else
                if f then
                    f:Hide()
                end
            end
        else -- no more debuffs, hide frames
            if f then
                f:Hide()
            end
        end
        
    end
    

    -- we checked all frames, untrack any that are gone
    -- print("untrack all that are gone")
    for k, v in pairs(units[unit].trackedAurasByIndex) do
        if (v["checkedThisEvent"] == false) then
            UntrackAura(k)
        end
    end
    -- we tracked all absorbs, now we have to visualize them. if absorbchange fired, we need to rearrange them
    -- check if segments already exist for unit

    local buttonFrame = unitbutton:GetParent()
    local height = buttonFrame.unit:GetHeight()*0.7
    local width = buttonFrame.unit.healthBar:GetWidth()
    local playerHealthMax = UnitHealthMax(unit)
    local pixelPerHp = width / playerHealthMax
    local playerCurrentHP = UnitHealth(unit)
    local playerMissingHP = playerHealthMax - playerCurrentHP
    local statusBarTex = "Interface/RAIDFRAME/Shield-Fill"
    local currentBarLength = (playerCurrentHP * pixelPerHp) + 1
    --index 1 means we havent filled the bar up with absorbs, 2 means we are now overlaying absorbs over the healthbar
    local overlapBarIndex = 1
    ---create frames if needed
    local function CreateAbsorbFrame(parent, i, height, parentTable)
        local isOverlapFrame = parentTable == units[unit]["absorbFramesOverlap"]
        local n = unit .. (isOverlapFrame and "AbsorbFrameOverlap" or "AbsorbFrame") .. i
        local f = CreateFrame("Frame", "srslylawlUI_"..n, parent)
        f.texture = f:CreateTexture("n".."texture", "ARTWORK")
        f.texture:SetAllPoints()
        f.texture:SetTexture(statusBarTex)
        if isOverlapFrame then
            f:SetPoint("TOPRIGHT", parent, "TOPLEFT", -1, 0)
        else
            f:SetPoint("TOPLEFT", parent, "TOPRIGHT", 1, 0)
        end
        f:SetHeight(height)
        f:SetWidth(40)
        local t = f:CreateTexture("$parent_background", "BACKGROUND")
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

    --Display effective health
    units[unit].effectiveHealthSegments = SortDefensives(units[unit].trackedAurasByIndex)
    local effectiveHealthMod = 1
    local stackMultiplier = 1
    local reducAmount
    if #units[unit].effectiveHealthSegments > 0 then
        for k, v in ipairs(units[unit].effectiveHealthSegments) do
            --tooltip gets updated with stacks anyway so we might want to ignore it until we config a per stack amount
            stackMultiplier = 1 --v.stacks > 1 and v.stacks or 1 TODO:check if this works out fine
            reducAmount = srslylawlUI.spells.known[v.spellId].reductionAmount /
                              100

            effectiveHealthMod = effectiveHealthMod *
                                     (1 - (reducAmount * stackMultiplier))
        end
    end
    if effectiveHealthMod ~= 1 then
        assert(#units[unit].effectiveHealthSegments > 0)
        local eHealth = playerCurrentHP / effectiveHealthMod
        local additionalHealth = eHealth - playerCurrentHP
        local maxWidth = playerMissingHP*pixelPerHp - 1
        local barWidth = additionalHealth * pixelPerHp
        local barWidth = barWidth < maxWidth and barWidth or maxWidth
        srslylawlUI.Frame_ChangeAbsorbSegment(units[unit]["effectiveHealthFrames"][1], barWidth, eHealth, buttonFrame.unit:GetHeight())
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
    local SortAbsorbBySpellIDDesc = function(absorbAuraTable)
        local t = {}
        for k, _ in pairs(absorbAuraTable) do
            if absorbAuraTable[k].auraType == "absorb" then
                t[#t + 1] = absorbAuraTable[k]
            end
        end
        table.sort(t, function(a, b) return b.spellId < a.spellId end)
        return t
    end
    local sortedAbsorbAuras = SortAbsorbBySpellIDDesc(units[unit].trackedAurasByIndex)
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
            --caching the index so we display the segment correctly
            local oIndex = overlapBarIndex

            local pixelOverlap = (currentBarLength + barWidth) - allowedWidth
            --if we are already at overlapindex 2 and we have overlap, we are now at the left end of the bar
            --for now, ignore it and just let it stick out
            if pixelOverlap > 0 and overlapBarIndex < 2 then
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
        srslylawlUI.Frame_ChangeAbsorbSegment(currentBar, barWidth, absorbAmount, height)
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
    local incomingHealWidth
    if incomingHeal ~= nil then
        incomingHealWidth = floor(incomingHeal * pixelPerHp)
        if incomingHealWidth > 2 then
            CalcSegment(incomingHeal, "incomingHeal", nil)
        end
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
                srslylawlUI.Frame_ChangeAbsorbSegment(bar, segment.width, segment.amount, height, true)
                bar:Show()
            elseif segment.sType == "various" then
                if bar.wasHealthPrediction then
                    bar.texture:SetTexture(statusBarTex)
                    bar.texture:SetVertexColor(1, 1, 1, 0.9)
                    bar.wasHealthPrediction = false
                end
                srslylawlUI.Frame_ChangeAbsorbSegment(bar, segment.width, segment.amount, height)
                bar:Show()
            else
                if segment.tAura == nil then
                    srslylawlUI.Log("ERROR: segment nil", segment.oIndex, segment.amount, segment.sType);
                    return
                end
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

    if #absorbSegments > 0 then
        DisplayFrames(absorbSegments)
    end

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
    srslylawlUI.Frame_MoveAbsorbAnchorWithHealth(unit)
end
function srslylawlUI.Frame_ChangeAbsorbSegment(frame, barWidth, absorbAmount, height, isHealPrediction)
    frame:SetAttribute("absorbAmount", absorbAmount)
    frame:SetHeight(height)
    frame:SetWidth(srslylawlUI.Utils_ScuffedRound(barWidth))
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
function srslylawlUI.Frame_MoveAbsorbAnchorWithHealth(unit)
    if units[unit] == nil or units[unit]["absorbFrames"] == nil or
        units[unit]["absorbFramesOverlap"] == nil then return end
    local buttonFrame = srslylawlUI.Frame_GetByUnitType(unit)
    local width = buttonFrame.unit.healthBar:GetWidth()
    local maxHP = UnitHealthMax(unit)
    local pixelPerHp = width / (maxHP ~= 0 and maxHP or 1)
    local playerCurrentHP = UnitHealth(unit)
    local baseAnchorOffset = srslylawlUI.Utils_ScuffedRound(playerCurrentHP * pixelPerHp)
    local mergeOffset = 0
    if units[unit]["absorbFramesOverlap"][1].isMerged then
        --offset by mergeamount
        mergeOffset = units[unit]["absorbFramesOverlap"][1].mergeAmount
    end
    units[unit]["absorbFrames"][1]:SetPoint("TOPLEFT", buttonFrame.unit.healthBar,"TOPLEFT", baseAnchorOffset+1, 0)
    units[unit]["absorbFramesOverlap"][1]:SetPoint("TOPRIGHT", buttonFrame.unit.healthBar, "TOPLEFT", baseAnchorOffset+mergeOffset,0)
    units[unit]["effectiveHealthFrames"][1]:SetPoint("TOPLEFT", buttonFrame.unit.healthBar,"TOPLEFT", baseAnchorOffset+1, 0)
end
function srslylawlUI.Auras_HasToolTipChanged(spellId, index, unit)
    local s = srslylawlUI.Auras_GetBuffText(index, unit)
    return srslylawlUI.spells.known[spellId].text ~= s
end
function srslylawlUI.Auras_ShouldDisplayBuff(...)
    local name, icon, count, debuffType, duration, expirationTime, source,
              isStealable, nameplateShowPersonal, spellId, canApplyAura,
              isBossDebuff, castByPlayer, nameplateShowAll, timeMod, absorb = ...

    if srslylawlUI.spells.whiteList[spellId] ~= nil then
        --always show whitelisted spells
        return true
    end

    if srslylawlUI.spells.blackList[spellId] ~= nil then
        --never show blacklisted spells
        return false
    end

    if srslylawlUI.settings.buffs.showDefensives and srslylawlUI.spells.defensives[spellId] ~= nil then
        --if we want to show defensives, do so
        return true
    end

    if duration == 0 or duration > srslylawlUI.settings.buffs.maxDuration then
        --dont show infinite duration spells or long duration spells
        return false
    end

    if srslylawlUI.spells.absorbs[spellId] ~= nil then
        --dont show absorb spells unless whitelisted
        return false
    end

    if source == "player" and srslylawlUI.settings.buffs.showCastByPlayer then
        --show cast by player if wanted
        return true
    end

    return false
end
function srslylawlUI.Auras_RememberSpellID(spellId, buffIndex, unit, arg1)
    local function SpellIsKnown(spellId)
        return srslylawlUI.spells.known[spellId] ~= nil
    end
    local function GetPercentValue(tooltipText)
            -- %d+ = multiple numbers in a row
            -- %% = the % sign
            -- so we are looking for something like 15%
            local valueWithSign = tooltipText:match("%d*%.?%d+%%")

            if not valueWithSign then return 0 end
            -- remove the percent sign now

            local number = valueWithSign:match("%d+")

            return tonumber(number) or 0
    end
    local function HasDefensiveKeyword(tooltipText)
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
    local function HasAbsorbKeyword(tooltipText)
        local s = string.lower(tooltipText)
        local keyPhrases = {"absorb"}

        for _, phrase in pairs(keyPhrases) do
            if s:match(phrase) and true then return true end
        end

        return false
    end
    local function ProcessID(spellId, buffIndex, unit, arg1)
        local spellName = GetSpellInfo(spellId)
        local buffText = srslylawlUI.Auras_GetBuffText(buffIndex, unit)
        local buffLower = buffText
        if buffText ~= nil then
            buffLower = string.lower(buffText)
        else
            buffLower = ""
        end
        local autoApprove = srslylawlUI.settings.autoApproveKeywords
        local keyWordAbsorb = HasAbsorbKeyword(buffLower) and
                                  autoApprove and ((arg1 ~= nil) and (arg1 > 1))
        local keyWordDefensive = HasDefensiveKeyword(buffLower) and
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

            if abs(amount) ~= 0 then spell.reductionAmount = amount
            else
                error("reduction amount is 0 " .. spellName .. " " .. buffText)
            end

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
            -- srslylawlUI.spells.blackList[spellId] = spell
            -- srslylawl_saved.spells.blackList[spellId] = spell
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
        srslylawlUI.Auras_HasToolTipChanged(spellId, buffIndex, unit) then
        ProcessID(spellId, buffIndex, unit, arg1)
    else
        ProcessID(spellId, buffIndex, unit, arg1)
    end
end
function srslylawlUI.Auras_ManuallyAddSpell(spellId, list)
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
        srslylawlUI.spells.blackList[spellId] = nil
        srslylawl_saved.spells.blackList[spellId] = nil
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
function srslylawlUI.Auras_ManuallyRemoveSpell(spellId, list)
    local spell = srslylawlUI.spells[list][spellId]
    if list == "known" then
        srslylawlUI.Log(
            "I never forget spells! Unless.. you delete my savefile.")
        return
    end
    srslylawlUI.spells[list][spellId] = nil
    srslylawl_saved.spells[list][spellId] = nil
    srslylawlUI.Log(spell.name .. " removed from " .. list .. "!")

    -- see if the spell is somewhere else, if not then put it to unapproved spells
    -- no longer needed since unapproved is now just a blacklist
    -- local isInAbsorbs = srslylawlUI.spells.absorbs[spellId] ~= nil
    -- local isInDefensives = srslylawlUI.spells.defensives[spellId] ~= nil
    -- local isInWhiteList = srslylawlUI.spells.whiteList[spellId] ~= nil
    -- local isInUnapproved = srslylawlUI.spells.blackList[spellId] ~= nil
    -- local isSomeWhere = isInAbsorbs or isInDefensives or isInWhiteList or
    --                         isInUnapproved or false

    -- if srslylawlUI.spells.blackList[spellId] == nil and not isSomeWhere then
    --     srslylawlUI.spells.blackList[spellId] = spell
    -- end
end

--Config
function srslylawlUI.ToggleConfigVisible(visible)
    if visible then
        srslylawlUI_ConfigFrame:Show()
    else
        srslylawlUI_ConfigFrame:Hide()
    end
end
function srslylawlUI.LoadSettings(reset, announce)
    if announce then srslylawlUI.Log("Settings Loaded") end
    if srslylawl_saved.settings ~= nil then
        srslylawlUI.settings = srslylawlUI.Utils_TableDeepCopy(srslylawl_saved.settings)
    end
    if srslylawl_saved.spells == nil then
        srslylawl_saved.spells = srslylawlUI.spells
    else
        srslylawlUI.spells = srslylawlUI.Utils_TableDeepCopy(srslylawl_saved.spells)
    end

    local c = srslylawlUI_ConfigFrame
    if c then
        local s = srslylawlUI.settings
        for k, v in pairs(c.sliders) do
            local default = v:GetAttribute("defaultValue")
            if default then
                v:SetValue(default)
            end
        end
        for k, v in pairs(c.editBoxes) do
            local default = v:GetAttribute("defaultValue")
            if default then
                v:SetText(default)
            end
        end
        for k, v in pairs(c.checkButtons) do
            local default = v:GetAttribute("defaultValue")
            if default ~= nil then
                v:SetChecked(default)
            end
        end
    end
    if not srslylawlUI_PartyHeader then return end
    srslylawlUI_PartyHeader:ClearAllPoints()
    srslylawlUI_PartyHeader:SetPoint(srslylawlUI.settings.header.anchor,
                                     srslylawlUI.settings.header.xOffset,
                                     srslylawlUI.settings.header.yOffset)
    srslylawlUI.SetBuffFrames()
    srslylawlUI.Frame_UpdateVisibility()
    srslylawlUI.RemoveDirtyFlag()
    if (reset) then srslylawlUI.UpdateEverything() end
end
function srslylawlUI.SaveSettings()
    srslylawlUI.Log("Settings Saved")
    srslylawl_saved.settings = srslylawlUI.Utils_TableDeepCopy(srslylawlUI.settings)
    srslylawl_saved.spells = srslylawlUI.Utils_TableDeepCopy(srslylawlUI.spells)

    for k, v in pairs(srslylawlUI_ConfigFrame.editBoxes) do
        v:SetAttribute("defaultValue", v:GetText())
    end
    for k, v in pairs(srslylawlUI_ConfigFrame.sliders) do
        v:SetAttribute("defaultValue", v:GetValue())
    end
    for k, v in pairs(srslylawlUI_ConfigFrame.checkButtons) do
        v:SetAttribute("defaultValue", v:GetChecked())
    end
    
    srslylawlUI.RemoveDirtyFlag()
end
function srslylawlUI.CreateBackground(frame)
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
function srslylawlUI.SetDirtyFlag()
    if unsaved.flag == true then return end
    unsaved.flag = true
    for _, v in ipairs(unsaved.buttons) do v:Enable() end
end
function srslylawlUI.RemoveDirtyFlag()
    unsaved.flag = false
    for _, v in ipairs(unsaved.buttons) do v:Disable() end
end
local function CreateConfigWindow()
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
        editBox:SetScript("OnTextChanged", funcOnTextChanged)
        editBox:SetAttribute("defaultValue", defaultValue)
        return editBox
    end
    local function CreateCustomSlider(name, min, max, defaultValue, parent, offset, valueStep, isNumeric, decimals)
        local title = name
        name = "$parent_Slider"..name
        local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
        name = slider:GetName()
        _G[name .. "Low"]:SetText(min)
        _G[name .. "High"]:SetText(max)
        _G[name .. "Text"]:SetText(title)
        _G[name .. "Text"]:SetTextColor(1, 0.82, 0, 1)
        _G[name .. "Text"]:SetPoint("TOP", 0, 15)
        slider:SetPoint("TOP", 0, offset)
        slider:SetWidth(150)
        slider:SetHeight(16)
        slider:SetMinMaxValues(min, max)
        slider:SetValue(defaultValue)
        slider:SetValueStep(valueStep)
        slider:SetObeyStepOnDrag(true)
        local editBox = CreateFrame("EditBox", name .. "_EditBox", slider,
                                    "BackdropTemplate")
        editBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 12,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        })
        editBox:SetBackdropColor(0.2, 0.2, .2, 1)
        editBox:SetTextInsets(5, 5, 0, 0)
        editBox:SetHeight(25)
        editBox:SetWidth(50)
        editBox:SetPoint("RIGHT", 55, 0)
        editBox:SetAutoFocus(false)
        editBox:SetFont("Fonts\\FRIZQT__.TTF", 10)
        editBox:SetNumeric(isNumeric or false)
        if isNumeric then
            editBox:SetNumber(defaultValue)
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
        else
            editBox:SetText(defaultValue)
            editBox:SetScript("OnTextChanged", function(self) slider:SetValue(srslylawlUI.Utils_DecimalRound(self:GetText(), decimals)) end)
            slider:SetScript("OnValueChanged", function(self, value)
                if editBox:GetText() == srslylawlUI.Utils_DecimalRound(value, decimals) then
                    return
                else
                    editBox:SetText(srslylawlUI.Utils_DecimalRound(value, decimals))
                end
            end)
        end
        editBox:SetMaxLetters(4)
        slider:SetAttribute("defaultValue", defaultValue)
        slider.editbox = editBox
        return slider
    end
    local function CreateCustomDropDown(title, width, parent, anchor, relativePoint,
                                    xOffset, yOffset, valueRef, values,
                                    onChangeFunc, checkFunc)
        -- Create the dropdown, and configure its appearance
        local dropDown = CreateFrame("FRAME", "$parent_"..title, parent,
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
            srslylawlUI.SetDirtyFlag()
            onChangeFunc(newValue)
            -- Update the text; if we merely wanted it to display newValue, we would not need to do this

            -- Because this is called from a sub-menu, only that menu level is closed by default.
            -- Close the entire menu with this next call
            -- CloseDropDownMenus()
        end

        return dropDown
    end
    local function CreateConfigBody(name, parent)
        local f = CreateFrame("Frame", name, parent, "BackdropTemplate")
        f:SetSize(500, 500)
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
    local function RemoveTooltip(frame)
        frame:EnableMouse(false)
        frame:SetScript("OnEnter", nil)
        frame:SetScript("OnLeave", nil)
    end
    local function AddSpellTooltip(frame, id)
        local function OnEnter(self)
            customTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
            customTooltip:ClearLines()
            customTooltip:AddSpellByID(id)
        end
        local function OnLeave(self) customTooltip:Hide() end

        frame:EnableMouse(true)
        frame:SetScript("OnEnter", OnEnter)
        frame:SetScript("OnLeave", OnLeave)
    end
    local function CreateFrameWBG(name, parent)
        local f = CreateFrame("Frame", "$parent_" ..name, parent, "BackdropTemplate")
        f:SetSize(500, 500)
        f:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 10,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        })
        f:SetBackdropColor(0, 0, 0, .4)
        f.title = f:CreateFontString(
                    "$parent_Title", "OVERLAY", "GameFontNormal")
        f.title:SetText(name)
        f.title:SetPoint("BOTTOMLEFT", f, "TOPLEFT")
        return f
    end
    local function CreateCheckButton(name, parent)
        local checkButton = CreateFrame("CheckButton",name,parent,"UICheckButtonTemplate")
        if srslylawlUI_ConfigFrame.checkButtons == nil then srslylawlUI_ConfigFrame.checkButtons = {} end
        srslylawlUI_ConfigFrame.checkButtons[name] = checkButton
        checkButton.text:SetText(name)
        return checkButton
    end
    local function CreateSaveLoadButtons(frame)
        -- Save Button
        frame.SaveButton = CreateFrame("Button", "srslylawlUI_Config_SaveButton",
                                    srslylawlUI_ConfigFrame,
                                    "UIPanelButtonTemplate")
        local s = frame.SaveButton
        s:SetPoint("TOPRIGHT", -5, -30)
        s:SetText("Save")
        s:SetScript("OnClick", function(self) srslylawlUI.SaveSettings() end)
        s:SetWidth(60)
        table.insert(unsaved.buttons, s)

        -- Load Button
        frame.LoadButton = CreateFrame("Button", "srslylawlUI_Config_LoadButton",
                                    srslylawlUI_ConfigFrame,
                                    "UIPanelButtonTemplate")
        local l = frame.LoadButton
        l:SetPoint("TOPRIGHT", s, "TOPLEFT")
        l:SetText("Load")
        l:SetScript("OnClick", function(self) srslylawlUI.LoadSettings(true, true) end)
        l:SetWidth(60)
        table.insert(unsaved.buttons, l)
        l:Disable()
        s:Disable()
        frame.CloseButton = CreateFrame("Button", "srslylawlUI_Config_CloseButton",
                                     srslylawlUI_ConfigFrame,
                                     "UIPanelCloseButton")
        local c = frame.CloseButton
        c:SetPoint("TOPRIGHT", 0, 0)
    end
    local function FillGeneralTab(tab)
        local lockFrames = CreateCheckButton("Make frames moveable", tab)
        lockFrames:SetPoint("TOPLEFT", tab, "TOPLEFT", 5, -5)
        lockFrames:SetScript("OnClick", function(self)
            srslylawlUI_PartyHeader:SetMovable(self:GetChecked()) end
        )

        local visibility = CreateFrameWBG("Visibility", lockFrames)
        visibility:SetPoint("TOPLEFT", lockFrames, "BOTTOMLEFT", 0, -15)
        visibility:SetPoint("BOTTOMRIGHT", tab, "TOPRIGHT", -80, -115)

        local showParty = CreateCheckButton("Show In Party", visibility)
        
        showParty:SetScript("OnClick", function(self)
            srslylawlUI.settings.showParty = self:GetChecked()
            srslylawlUI.Frame_UpdateVisibility()
            srslylawlUI.SetDirtyFlag()
        end)
        AddTooltip(showParty, "Show Frames while in a Party")
        showParty:SetPoint("TOPLEFT", visibility, "TOPLEFT")
        showParty:SetChecked(srslylawlUI.settings.showParty)
        showParty:SetAttribute("defaultValue", srslylawlUI.settings.showParty)

        local showRaid = CreateCheckButton("Show in Raid", visibility)
        showRaid:SetScript("OnClick", function(self)
            srslylawlUI.settings.showRaid = self:GetChecked()
            srslylawlUI.Frame_UpdateVisibility()
            srslylawlUI.SetDirtyFlag()
        end)
        showRaid:SetPoint("LEFT", showParty.text, "RIGHT")
        AddTooltip(showRaid, "Show Frames while in a Raid (not recommended)")
        showRaid:SetChecked(srslylawlUI.settings.showRaid)
        showRaid:SetAttribute("defaultValue", srslylawlUI.settings.showRaid)

        local showPlayer = CreateCheckButton("Show Player", visibility)
        showPlayer:SetScript("OnClick", function(self)
            srslylawlUI.settings.showPlayer = self:GetChecked()
            srslylawlUI.Frame_UpdateVisibility()
            srslylawlUI.SetDirtyFlag()
        end)
        showPlayer:SetPoint("LEFT", showRaid.text, "RIGHT")
        AddTooltip(showPlayer, "Show Player in PartyFrames (recommended)")
        showPlayer:SetChecked(srslylawlUI.settings.showPlayer)
        showPlayer:SetAttribute("defaultValue", srslylawlUI.settings.showPlayer)

        local showSolo = CreateCheckButton("Show Solo", visibility)
        showSolo:SetScript("OnClick", function(self)
            srslylawlUI.settings.showSolo = self:GetChecked()
            srslylawlUI.Frame_UpdateVisibility()
            srslylawlUI.SetDirtyFlag()
        end)
        showSolo:SetPoint("LEFT", showPlayer.text, "RIGHT")
        AddTooltip(showSolo, "Show Frames while not in a group (overrides Show Player)")
        showSolo:SetChecked(srslylawlUI.settings.showSolo)
        showSolo:SetAttribute("defaultValue", srslylawlUI.settings.showSolo)

        local showArena = CreateCheckButton("Show Arena", visibility)
        showArena:SetScript("OnClicK", function(self)
        srslylawlUI.settings.showArena = self:GetChecked()
            srslylawlUI.Frame_UpdateVisibility()
            srslylawlUI.SetDirtyFlag()
        end)
        showArena:SetPoint("TOPLEFT", showParty, "BOTTOMLEFT", 0, 0)
        showArena:SetAttribute("defaultValue", srslylawlUI.settings.showArena)
    end
    local function FillFramesTab(tab)
        -- HP Bar Sliders
        local cFrame = srslylawlUI_ConfigFrame
        cFrame.editBoxes = {}
        cFrame.sliders = {}

        local healthBarFrame = CreateFrameWBG("Health Bar", tab)
        healthBarFrame:SetPoint("TOPLEFT", tab, "TOPLEFT", 5, -25)
        healthBarFrame:SetPoint("BOTTOMRIGHT", tab, "TOPRIGHT", -5, -135)
        
        local width = floor(srslylawlUI.settings.hp.width)
        local height = floor(srslylawlUI.settings.hp.height)
        cFrame.sliders.height = CreateCustomSlider("Height", 5, 500,
            height, healthBarFrame, -50, 1, true)
        cFrame.sliders.height:SetPoint("TOPLEFT", 10, -20)
        cFrame.sliders.height:HookScript("OnValueChanged", function(self, value)
            srslylawlUI.settings.hp.height = value
            srslylawlUI.UpdateEverything()
            srslylawlUI.SetDirtyFlag() end)
        cFrame.sliders.hpwidth = CreateCustomSlider("Max Width", 25,
            2000, width, cFrame.sliders.height, -40, 1, true)
        cFrame.sliders.hpwidth:ClearAllPoints()
        cFrame.sliders.hpwidth:SetPoint("LEFT", cFrame.sliders.height.editbox,
            "RIGHT", 10, 0)
        cFrame.sliders.hpwidth:HookScript("OnValueChanged", function(self, value)
            srslylawlUI.settings.hp.width = value
            srslylawlUI.UpdateEverything()
            srslylawlUI.SetDirtyFlag()
        end)
        cFrame.sliders.minWidth = CreateCustomSlider("Min Width Percent", 0.1, 1, srslylawlUI.Utils_DecimalRound(srslylawlUI.settings.hp.minWidthPercent, 2), cFrame.sliders.height, -50, 0.01, false, 2)
        cFrame.sliders.minWidth:HookScript("OnValueChanged", function(self, value)
            srslylawlUI.settings.hp.minWidthPercent = value
            srslylawlUI.UpdateEverything()
            srslylawlUI.SetDirtyFlag()
        end)
        AddTooltip(cFrame.sliders.minWidth, "Minimum percent of Max Width a bar can be scaled to. Default: 0.45")

        -- Buff Frames
        local buffFrame = CreateFrameWBG("Buffs", healthBarFrame)
        buffFrame:SetPoint("TOPLEFT", healthBarFrame, "BOTTOMLEFT", 0, -15)
        buffFrame:SetPoint("BOTTOMRIGHT", healthBarFrame, "BOTTOMRIGHT", 0, -120)
        local buffAnchor = CreateCustomDropDown("Anchor", 75, buffFrame, "TOPLEFT",
            "TOPLEFT", -10, -20, srslylawlUI.settings.buffs.anchor, anchorTable, function(newValue)
                srslylawlUI.settings.buffs.anchor = newValue
                srslylawlUI.SetBuffFrames()
        end, function(self) return self.value == srslylawlUI.settings.buffs.anchor end)
        local buffGrowthDir = CreateCustomDropDown("Growth Direction", 125, buffAnchor, "TOPLEFT",
            "TOPRIGHT", -25, 0, srslylawlUI.settings.buffs.growthDir, {"LEFT", "RIGHT"}, function(newValue)
                srslylawlUI.settings.buffs.growthDir = newValue
                srslylawlUI.SetBuffFrames()
        end, function(self) return self.value == srslylawlUI.settings.buffs.growthDir end)
        local buffAnchorXOffset = CreateEditBox("$parent_BuffAnchorXOffset", buffGrowthDir, srslylawlUI.settings.buffs.xOffset,
        function(self)
            local n = self:GetNumber()
            if srslylawlUI.settings.buffs.xOffset == n then return end
            srslylawlUI.settings.buffs.xOffset = n
            srslylawlUI.SetBuffFrames()
            srslylawlUI.SetDirtyFlag()
        end)
        buffAnchorXOffset.title = buffAnchorXOffset:CreateFontString("$parent_Title", "OVERLAY", "GameFontNormal")
        buffAnchorXOffset.title:SetPoint("TOP", 0, 12)
        buffAnchorXOffset.title:SetText("X Offset")
        buffAnchorXOffset:ClearAllPoints()
        buffAnchorXOffset:SetPoint("TOPLEFT", buffGrowthDir, "TOPRIGHT", -10, 0)
        local buffAnchorYOffset = CreateEditBox("$parent_BuffAnchorXOffset", buffAnchorXOffset, srslylawlUI.settings.buffs.xOffset,
        function(self)
            local n = self:GetNumber()
            if srslylawlUI.settings.buffs.yOffset == n then return end
            srslylawlUI.settings.buffs.yOffset = n
            srslylawlUI.SetBuffFrames()
            srslylawlUI.SetDirtyFlag()
        end)
        buffAnchorYOffset.title = buffAnchorYOffset:CreateFontString("$parent_Title", "OVERLAY", "GameFontNormal")
        buffAnchorYOffset.title:SetPoint("TOP", 0, 12)
        buffAnchorYOffset.title:SetText("Y Offset")

        cFrame.editBoxes.buffAnchorXOffset = buffAnchorXOffset
        cFrame.editBoxes.buffAnchorYOffset = buffAnchorYOffset
        local buffIconSize = CreateEditBox("$parent_Icon Size", buffAnchorYOffset, srslylawlUI.settings.buffs.size,
        function(self)
            local n = self:GetNumber()
            if srslylawlUI.settings.buffs.size == n then return end
            srslylawlUI.settings.buffs.size = n
            srslylawlUI.SetBuffFrames()
            srslylawlUI.SetDirtyFlag()
        end)
        cFrame.editBoxes.buffIconSize = buffIconSize
        buffIconSize.title = buffIconSize:CreateFontString("$parent_Title", "OVERLAY", "GameFontNormal")
        buffIconSize.title:SetPoint("TOP", 0, 12)
        buffIconSize.title:SetText("Size")

        cFrame.sliders.maxBuffs = CreateCustomSlider("Max Visible Buffs", 0, 40, srslylawlUI.settings.buffs.maxBuffs, buffAnchor, -50, 1, true, 0)
        cFrame.sliders.maxBuffs:SetPoint("TOPLEFT", buffAnchor, "BOTTOMLEFT", 20, -15)
        cFrame.sliders.maxBuffs:HookScript("OnValueChanged", function(self, value)
            srslylawlUI.settings.buffs.maxBuffs = value
            srslylawlUI.SetDirtyFlag() end)
        AddTooltip(cFrame.sliders.maxBuffs, "Requires UI Reload")

        --Debuff Frames
        local debuffFrame = CreateFrameWBG("Debuffs", buffFrame)
        debuffFrame:SetPoint("TOPLEFT", buffFrame, "BOTTOMLEFT", 0, -15)
        debuffFrame:SetPoint("BOTTOMRIGHT", buffFrame, "BOTTOMRIGHT", 0, -120)
        local debuffAnchor = CreateCustomDropDown("Anchor", 75, debuffFrame, "TOPLEFT",
            "TOPLEFT", -10, -20, srslylawlUI.settings.debuffs.anchor, anchorTable, function(newValue)
                srslylawlUI.settings.debuffs.anchor = newValue
                srslylawlUI.SetDebuffFrames()
        end, function(self) return self.value == srslylawlUI.settings.debuffs.anchor end)
        local debuffGrowthDir = CreateCustomDropDown("Growth Direction", 125, debuffAnchor, "TOPLEFT",
            "TOPRIGHT", -25, 0, srslylawlUI.settings.debuffs.growthDir, {"LEFT", "RIGHT"}, function(newValue)
                srslylawlUI.settings.debuffs.growthDir = newValue
                srslylawlUI.SetDebuffFrames()
        end, function(self) return self.value == srslylawlUI.settings.debuffs.growthDir end)
        local debuffAnchorXOffset = CreateEditBox("$parent_DebuffAnchorXOffset", debuffGrowthDir, srslylawlUI.settings.debuffs.xOffset,
        function(self)
            local n = self:GetNumber()
            if srslylawlUI.settings.debuffs.xOffset == n then return end
            srslylawlUI.settings.debuffs.xOffset = n
            srslylawlUI.SetDebuffFrames()
            srslylawlUI.SetDirtyFlag()
        end)
        debuffAnchorXOffset.title = debuffAnchorXOffset:CreateFontString("$parent_Title", "OVERLAY", "GameFontNormal")
        debuffAnchorXOffset.title:SetPoint("TOP", 0, 12)
        debuffAnchorXOffset.title:SetText("X Offset")
        debuffAnchorXOffset:ClearAllPoints()
        debuffAnchorXOffset:SetPoint("TOPLEFT", debuffGrowthDir, "TOPRIGHT", -10, 0)
        local debuffAnchorYOffset = CreateEditBox("$parent_DebuffAnchorXOffset", debuffAnchorXOffset, srslylawlUI.settings.debuffs.yOffset,
        function(self)
            local n = self:GetNumber()
            if srslylawlUI.settings.debuffs.yOffset == n then return end
            srslylawlUI.settings.debuffs.yOffset = n
            srslylawlUI.SetDebuffFrames()
            srslylawlUI.SetDirtyFlag()
        end)
        debuffAnchorYOffset.title = debuffAnchorYOffset:CreateFontString("$parent_Title", "OVERLAY", "GameFontNormal")
        debuffAnchorYOffset.title:SetPoint("TOP", 0, 12)
        debuffAnchorYOffset.title:SetText("Y Offset")

        cFrame.editBoxes.debuffAnchorXOffset = debuffAnchorXOffset
        cFrame.editBoxes.debuffAnchorYOffset = debuffAnchorYOffset
        local debuffIconSize = CreateEditBox("$parent_Icon Size", debuffAnchorYOffset, srslylawlUI.settings.debuffs.size,
        function(self)
            local n = self:GetNumber()
            if srslylawlUI.settings.debuffs.size == n then return end
            srslylawlUI.settings.debuffs.size = n
            srslylawlUI.SetDebuffFrames()
            srslylawlUI.SetDirtyFlag()
        end)
        cFrame.editBoxes.debuffIconSize = debuffIconSize
        debuffIconSize.title = debuffIconSize:CreateFontString("$parent_Title", "OVERLAY", "GameFontNormal")
        debuffIconSize.title:SetPoint("TOP", 0, 12)
        debuffIconSize.title:SetText("Size")

        cFrame.sliders.maxDebuffs = CreateCustomSlider("Max Visible Debuffs", 0, 40, srslylawlUI.settings.debuffs.maxDebuffs, debuffAnchor, -50, 1, true, 0)
        cFrame.sliders.maxDebuffs:SetPoint("TOPLEFT", debuffAnchor, "BOTTOMLEFT", 20, -15)
        cFrame.sliders.maxDebuffs:HookScript("OnValueChanged", function(self, value)
            srslylawlUI.settings.debuffs.maxDebuffs = value
            srslylawlUI.SetDirtyFlag() end)
        AddTooltip(cFrame.sliders.maxDebuffs, "Requires UI Reload")
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
    local function GenerateSpellList(spellListKey, filter)
        local function startsWith(str, start)
            return str:sub(1, #start) == start
        end
        local filter = (filter ~= nil and filter) or ""
        spellList = srslylawlUI.spells[spellListKey]
        if spellList == nil then error("spelllist nil") end
        -- sort list
        local sortedSpellList = {}
        for spellId, _ in pairs(spellList) do
            local name, _, icon = GetSpellInfo(spellId)
            local spell = {name = name, spellId = spellId, icon = icon}
            if startsWith(name, filter) then
                table.insert(sortedSpellList, spell)
            end
        end

        table.sort(sortedSpellList, function(a, b) return b.name > a.name end)

        --print("SpellList", spellListKey, "Generated with filter ", filter, "and len", #sortedSpellList)

        srslylawlUI.sortedSpellLists.buffs[spellListKey] = sortedSpellList
    end
    local function CreateScrollFrame(parent)
        local ScrollFrame = CreateFrame("ScrollFrame", "$parent_ScrollFrame", parent, "UIPanelScrollFrameTemplate")
        ScrollFrame:SetClipsChildren(true)
        ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel)
        ScrollFrame.ScrollBar:ClearAllPoints()
        ScrollFrame.ScrollBar:SetPoint("TOPLEFT", ScrollFrame, "TOPRIGHT", -40,
                                       -18)
        ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", ScrollFrame,
                                       "BOTTOMRIGHT", -7, 17)

        return ScrollFrame
    end
    local function CreateFauxScrollFrame(parent, spellList)
        local function ScrollFrame_Update(frame)
                local list = spellList
                local lineplusoffset
                local sortedSpellList = srslylawlUI.sortedSpellLists.buffs[list]
                local maxButtons = frame.ButtonCount or 0
                local totalItems = #sortedSpellList or 0
                frame.TotalItems = totalItems
                local buttonHeight = frame.ButtonHeight or 0
                FauxScrollFrame_Update(frame,totalItems,maxButtons,buttonHeight)
                for line=1,maxButtons do
                    lineplusoffset = line + FauxScrollFrame_GetOffset(frame)
                    local curr = frame.Buttons[line]
                    if curr == nil then error("button nil") end
                    if lineplusoffset <= totalItems then
                        local spell = sortedSpellList[lineplusoffset]
                        local name, spellId, icon = spell.name, spell.spellId, spell.icon
                        local nameWidth = curr:GetWidth()
                        local length = #name
                        local addNameTooltip = false
                        curr:SetText(name)
                        while curr:GetTextWidth() > nameWidth do
                            substring = srslylawlUI.Utils_ShortenString(name, 1, length)
                            curr:SetText(substring)
                            length = length - 1
                        end
                        AddTooltip(curr, name.."\nID: ".. spellId)
                        curr:SetAttribute("spellId", spellId)
                        curr.icon.texture:SetTexture(icon)
                        if srslylawlUI.spells.known[spellId] ~= nil then
                            local tooltipText = srslylawlUI.spells.known[spellId].text
                            if tooltipText and tooltipText ~= "" then
                                tooltipText = tooltipText .. "\n\nID:" .. spellId
                                AddSpellTooltip(curr.icon, spellId)
                            end
                        end
                        curr:Show()
                    else
                        curr:Hide()
                    end
                end
        end
        local function CreateButtons(parent,count, tab)
            function Button_OnClick(self)
                local id = self:GetID()
                local parent = self:GetParent()
                local tabcontent = parent:GetParent():GetParent():GetParent()
                for _, button in pairs(parent.buttons) do
                    button:SetChecked(button:GetID() == id)
                end
                tabcontent.activeButton = self
            end
            local anchorParent = parent
            local iconSize = 25
            local offset = 3
            local firstButton
            for i=1, count do
                button = CreateFrame("CheckButton", parent:GetName() .. "ListButton"..i, anchorParent, "UIMenuButtonStretchTemplate")
                button:SetCheckedTexture(button:GetHighlightTexture())
                button:SetScript("OnClick", Button_OnClick)
                button:SetID(i)

                button.icon = CreateFrame("Frame", "$parent_icon", button)
                button.icon.texture = button.icon:CreateTexture("$parent_texture", "ARTWORK")
                button.icon:SetSize(iconSize, iconSize)
                button.icon.texture:SetAllPoints()
                button.icon:SetPoint("RIGHT", button, "LEFT")
                parent.Buttons[i] = button

                if i == 1 then
                    firstButton = button
                    button:SetPoint("TOPLEFT", anchorParent, "TOPLEFT", iconSize + offset, -10)
                else
                    button:SetPoint("TOPLEFT", anchorParent, "BOTTOMLEFT", 0, 0)
                end
                anchorParent = button
                button:SetPoint("RIGHT", parent, "RIGHT", -35, 0)

                button:Show()
            end

            parent.ButtonCount = count
            parent.ButtonHeight = iconSize

            return firstButton
        end
        local function Faux_OnMouseWheel(self, delta)
            local old = self.ScrollBar:GetValue()
            local valueStep = self.ScrollBar:GetValueStep()
            local newValue = old - delta*valueStep
            local max = (self.TotalItems - self.ButtonCount) * self.ButtonHeight
            if newValue < 0 then
                newValue = 0
            elseif newValue > max then
                newValue = max
            end
            self.ScrollBar:SetValue(newValue)

            FauxScrollFrame_OnVerticalScroll(self, newValue, self.ButtonHeight, ScrollFrame_Update)
        end
        local ScrollFrame = CreateFrame("ScrollFrame", "$parent_ScrollFrame", parent, "FauxScrollFrameTemplate")
        ScrollFrame:SetClipsChildren(true)
        ScrollFrame:SetScript("OnMouseWheel", Faux_OnMouseWheel)
        ScrollFrame.ScrollBar:ClearAllPoints()
        ScrollFrame.ScrollBar:SetPoint("TOPLEFT", ScrollFrame, "TOPRIGHT", -40, -18)
        ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", ScrollFrame, "BOTTOMRIGHT", -7, 17)
        ScrollFrame.Buttons = {}
        CreateButtons(ScrollFrame, 11, parent)
        ScrollFrame:SetScript("OnVerticalScroll", function(self, offset) FauxScrollFrame_OnVerticalScroll(self, offset, self.ButtonHeight, ScrollFrame_Update) end)
        ScrollFrame:SetScript("OnShow", function(self)
            GenerateSpellList(spellList)
            ScrollFrame_Update(self) end)
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
        parent.borderFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, -45)
        parent.borderFrame:SetPoint("TOPRIGHT", parent, "TOPLEFT", 230, -5)
        parent.borderFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 5)

        parent.ScrollFrame = CreateFauxScrollFrame(parent.borderFrame, parent:GetAttribute("spellList"))
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
        parent.FilterFrame = CreateFrameWBG("FilterFrame", parent)
        parent.FilterFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, -5)
        parent.FilterFrame:SetPoint("BOTTOMRIGHT", parent.borderFrame, "TOPRIGHT", 0, 5)
        parent.FilterFrame.title:SetText("Filter By Name..")

        return parent.ScrollFrame, parent.ScrollFrame.child
    end
    local function OpenSpellAttributePanel(parentTab)
        local function AddSpell_OnEnterPressed(self)
            local text = self:GetText()
            local spellId = tonumber(text)
            local tabcontent = self:GetParent():GetParent()

            local listString = tabcontent:GetAttribute("spellList")

            if listString and spellId then
                srslylawlUI.Auras_ManuallyAddSpell(spellId, listString)
                tabcontent:Hide()
                tabcontent:Show()
            end

            self:SetText("")
        end
        local function RemoveSpell_OnClick(self)
            local tabcontent = self:GetParent():GetParent()
            local spellId = tabcontent.activeButton:GetAttribute("spellId")
            local spellList = tabcontent:GetAttribute("spellList")
            srslylawlUI.Auras_ManuallyRemoveSpell(spellId, spellList)
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
            srslylawlUI.Auras_ManuallyAddSpell(spellId, listKey)
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
    local function CreateSpellMenus(knownSpells, absorbSpells, defensives, whiteList, blackList)
        local function Menu_OnShow(parentTab, list)
            return function()
                OpenSpellAttributePanel(parentTab)
                local mainButton = nil
                if mainButton then mainButton:Click() end
            end
        end
        knownSpells:SetAttribute("spellList", "known")
        knownSpells:SetScript("OnShow", Menu_OnShow(knownSpells, "known"))
        local scrollFrame, child = CreateScrollFrameWithBGAndChild(knownSpells)

        absorbSpells:SetScript("OnShow", Menu_OnShow(absorbSpells, "absorbs"))
        absorbSpells:SetAttribute("spellList", "absorbs")
        CreateScrollFrameWithBGAndChild(absorbSpells)


        defensives:SetScript("OnShow", Menu_OnShow(defensives, "defensives"))
        defensives:SetAttribute("spellList", "defensives")
        CreateScrollFrameWithBGAndChild(defensives)


        whiteList:SetScript("OnShow", Menu_OnShow(whiteList, "whiteList"))
        whiteList:SetAttribute("spellList", "whiteList")
        CreateScrollFrameWithBGAndChild(whiteList)

        blackList:SetScript("OnShow", Menu_OnShow(blackList, "blackList"))
        blackList:SetAttribute("spellList", "blackList")
        CreateScrollFrameWithBGAndChild(blackList)

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
    srslylawlUI.Frame_MakeFrameMoveable(cFrame)

    cFrame.body = CreateConfigBody("$parent_Body", cFrame)

    CreateSaveLoadButtons(cFrame)

    local generalTab, framesTab, buffsTab = SetTabs(cFrame.body, "General", "Frames", "Buffs")

    -- Create General Tab
    Mixin(generalTab, BackdropTemplateMixin)
    generalTab:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 4, right = 4, top = 4, bottom = 4}})
    generalTab:SetBackdropColor(0, 0, 0, .4)
    FillGeneralTab(generalTab)

    -- Create Bars Tab
    Mixin(framesTab, BackdropTemplateMixin)
    framesTab:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 4, right = 4, top = 4, bottom = 4}})
    framesTab:SetBackdropColor(0, 0, 0, .4)
    FillFramesTab(framesTab)

    -- Create Spells Tab
    buffsTab:ClearAllPoints()
    buffsTab:SetPoint("TOP", cFrame.body, "TOP", 0, -35)
    buffsTab:SetPoint("BOTTOMLEFT", cFrame.body, "BOTTOMLEFT", 4, 4)
    buffsTab:SetPoint("BOTTOMRIGHT", cFrame.body, "BOTTOMRIGHT", -4, 2)
    Mixin(buffsTab, BackdropTemplateMixin)
    buffsTab:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 4, right = 4, top = 4, bottom = 4}})
    buffsTab:SetBackdropColor(0, 0, 0, .4)

    -- Buffs Tab buttons
    local knownSpells, absorbSpells, defensives, whiteList, blackList =
        SetTabs(buffsTab, "Encountered", "Absorbs", "Defensives", "Whitelist",
                "Blacklist")

    AddTooltip(knownSpells.tabButton, "List of all encountered buffs.")
    AddTooltip(absorbSpells.tabButton,
               "Buffs with absorb effects, will be shown as segments.")
    AddTooltip(defensives.tabButton,
               "Buffs with damage reduction effects, will increase your effective health.")
    AddTooltip(whiteList.tabButton,
               "Whitelisted buffs will always appear as buff frames.")
    AddTooltip(blackList.tabButton,
               "Buffs that will not be displayed on the interface")

    Mixin(knownSpells, BackdropTemplateMixin)
    CreateSpellMenus(knownSpells, absorbSpells, defensives, whiteList,
                     blackList)

    srslylawlUI.ToggleConfigVisible(true)
    InterfaceOptions_AddCategory(srslylawlUI_ConfigFrame)
end



local function Initialize()
    local function CreateSlashCommands()
        -- Setting Slash Commands
        SLASH_SRSLYLAWLUI1 = "/srslylawlUI"
        SLASH_SRSLYLAWLUI2 = "/srslylawlUI"
        SLASH_SRSLYLAWLUI3 = "/srsUI"
        SLASH_SRSLYLAWLUI4 = "/srslylawl"
        SLASH_SRSLYLAWLUI5 = "/srslylawl save"
        SLASH_SRSLYLAWLUIDEBUG1 = "/srsdbg"

        SLASH_SRLYLAWLAPPROVESPELL1 = "/approvespell id"

        SlashCmdList["SRSLYLAWLUI"] = function(msg, txt)
            if InCombatLockdown() then
                srslylawlUI.Log("Can't access menu while in combat.")
                return
            end
            if msg and msg == "save" then
                srslylawlUI.SaveSettings()
            else
                srslylawlUI.ToggleConfigVisible(true)
            end
        end

        SlashCmdList["SRSLYLAWLUIDEBUG"] = function()
            srslylawlUI.Debug()
        end
    end
    local function CreateBuffFrames()
        for _, v in pairs(unitTable) do
            local unitName = v
            local frameName = "srslylawlUI_"..unitName.."Aura"

            if units[unitName].buffFrames == nil then
                units[unitName] = {
                    absorbAuras = {},
                    trackedAurasByIndex = {},
                    buffFrames = {},
                    defensiveAuras = {},
                    debuffFrames = {},
                    effectiveHealthSegments = {},
                    parentName = "srslylawlUI_AuraHolderFrame"
                }
            end
            for i = 1, srslylawlUI.settings.buffs.maxBuffs do
                local xOffset, yOffset = srslylawlUI.GetBuffOffsets()
                local parent = _G[frameName .. (i - 1)]
                local anchor = srslylawlUI.settings.buffs.growthDir
                if (i == 1) then
                    parent = srslylawlUI.AuraHolderFrame
                    anchor = srslylawlUI.settings.buffs.anchor
                    xOffset = srslylawlUI.settings.buffs.xOffset
                    yOffset = srslylawlUI.settings.buffs.yOffset
                end
                local f = CreateFrame("Button", frameName .. i, parent, "CompactBuffTemplate")
                f:SetPoint(anchor, xOffset, yOffset)
                f:SetAttribute("unit", unitName)
                f:SetScript("OnLoad", nil)
                f:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(f, "ANCHOR_RIGHT", 0, 0)
                    GameTooltip:SetUnitBuff(self:GetAttribute("unit"), self:GetID())
                end)
                f:SetScript("OnUpdate", function(self)
                    if GameTooltip:IsOwned(f) then
                        GameTooltip:SetUnitBuff(self:GetAttribute("unit"),self:GetID())
                    end
                end)
                units[unitName].buffFrames[i] = f
                end
        end
    end
    local function CreateDebuffFrames()
        for _, v in pairs(unitTable) do
            local unitName = v
            local frameName = "srslylawlUI_"..unitName.."Debuff"

            for i = 1, srslylawlUI.settings.debuffs.maxDebuffs do
                local xOffset, yOffset = srslylawlUI.GetDebuffOffsets()
                local parent = _G[frameName .. (i - 1)]
                local anchor = srslylawlUI.settings.debuffs.growthDir
                if (i == 1) then
                    parent = srslylawlUI.AuraHolderFrame
                    anchor = srslylawlUI.settings.debuffs.anchor
                    xOffset = srslylawlUI.settings.debuffs.xOffset
                    yOffset = srslylawlUI.settings.debuffs.yOffset
                end
                local f = CreateFrame("Button", frameName .. i, parent, "CompactDebuffTemplate")
                f:SetPoint(anchor, xOffset, yOffset)
                f:SetAttribute("unit", unitName)
                f:SetScript("OnLoad", nil)
                f:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(f, "ANCHOR_RIGHT", 0, 0)
                    GameTooltip:SetUnitDebuff(self:GetAttribute("unit"), self:GetID())
                end)
                f:SetScript("OnUpdate", function(self)
                    if GameTooltip:IsOwned(f) then
                        GameTooltip:SetUnitDebuff(self:GetAttribute("unit"),self:GetID())
                    end
                end)
                units[unitName].debuffFrames[i] = f
            end
        end
    end
    local function HeaderSetup()
        local header = CreateFrame("Frame", "srslylawlUI_PartyHeader", UIParent)
        header:SetSize(srslylawlUI.settings.hp.width, srslylawlUI.settings.hp.height)
        header:SetPoint(srslylawlUI.settings.header.anchor,
        srslylawlUI.settings.header.xOffset,
        srslylawlUI.settings.header.yOffset)
        header:Show()
        --Create Unit Frames
        for _, unit in pairs(unitTable) do
            local unitFrame = CreateFrame("Frame", "$parent_"..unit, header, "srslylawlUI_UnitTemplate")
            header[unit] = unitFrame
            unitFrame:SetAttribute("unit", unit)

            srslylawlUI.Frame_InitialUnitConfig(unitFrame)
            RegisterUnitWatch(unitFrame)
        end
        srslylawlUI.Frame_UpdateVisibility()
    end
    srslylawlUI.LoadSettings()
    HeaderSetup()
    CreateSlashCommands()
    CreateConfigWindow()
    CreateBuffFrames()
    CreateDebuffFrames()
end

srslylawlUI_EventFrame = CreateFrame("Frame")
srslylawlUI_EventFrame:RegisterEvent("PLAYER_LOGIN")
srslylawlUI_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
srslylawlUI_EventFrame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if (event == "PLAYER_LOGIN") then
        Initialize()
        self:UnregisterEvent("PLAYER_LOGIN")
    elseif event == "UNIT_MAXHEALTH" or event == "GROUP_ROSTER_UPDATE" then
        -- delay since it bugs if it happens at the same frame for some reason
        -- print("roster update")
        if event == "UNIT_MAXHEALTH" and not (arg1 == "player" or arg1 == "party1" or arg1 == "party2" or arg1 == "party3" or arg1 == "party4") then
            --this event fires for all nameplates etc, but we only care about our party members
            return
        end
        C_Timer.After(.1, function()
            --print(event, " sort after maxhealth/grp change", arg1)
            srslylawlUI.SortPartyFrames()
            srslylawlUI.Frame_ResizeHealthBarScale()
        end)

        if event == "GROUP_ROSTER_UPDATE" then
            srslylawlUI.Frame_UpdateVisibility()
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if not (arg1 or arg2) then
            -- print("just zoning between maps")
        elseif arg1 then
            -- srslylawlUI.SortAfterLogin()
            -- since it takes a while for everything to load, we just wait until all our frames are visible before we do anything else
            srslylawlUI.SortPartyFrames()
        elseif arg2 then
            -- print("reload ui")
            srslylawlUI.Frame_ResizeHealthBarScale()
            srslylawlUI.SortPartyFrames()
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
