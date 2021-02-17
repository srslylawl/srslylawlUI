srslylawlUI = srslylawlUI or {}

srslylawlUI.settings = {
    party = {
        header = {anchor = "CENTER", xOffset = 10, yOffset = 10},
        hp = {width = 100, height = 50, minWidthPercent = 0.55},
        power = {width = 15},
        pet = {width = 15},
        buffs = { anchor = "TOPLEFT", xOffset = -29, yOffset = 0, size = 16, growthDir = "LEFT",
                showCastByPlayer = true, maxBuffs = 15, maxDuration = 60, showDefensives = true, showInfiniteDuration = false, showDefault = true, showLongDuration = false},
        debuffs = { anchor = "BOTTOMLEFT", xOffset = -29, yOffset = 0, size = 16, growthDir = "LEFT", showCastByPlayer = true,
                maxDebuffs = 15, maxDuration = 180, showInfiniteDuration = false, showDefault = true, showLongDuration = false},
        maxAbsorbFrames = 20,
        showArena = false,
        showParty = true,
        showSolo = true,
        showRaid = false,
        showPlayer = true,
    },
    frameOnUpdateInterval = 0.1
}
srslylawlUI.buffs = {
    known = {},
    absorbs = {},
    whiteList = {},
    blackList = {},
    defensives = {},
}
srslylawlUI.debuffs = {
    known = {},
    whiteList = {},
    blackList = {},
    roots = {},
    stuns = {},
    incaps = {},
    silences = {},
    disorients = {},
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
        whiteList = {},
        blackList = {}
    }
}
local powerUpdateType = "UNIT_POWER_UPDATE" -- "UNIT_POWER_UPDATE" or "UNIT_POWER_FRQUENT"
srslylawlUI.textures = {
    AbsorbFrame = "Interface/RAIDFRAME/Shield-Fill",
    HealthBar = "Interface/Addons/srslylawlUI/media/healthBar",
    EffectiveHealth = "Interface/AddOns/srslylawlUI/media/eHealthBar",
    CCHighlight = "Interface/AddOns/srslylawlUI/media/ccHighlight"
}
srslylawlUI.unsaved = {flag = false, buttons = {}}

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
srslylawlUI.customTooltip = CreateFrame("GameTooltip", "srslylawl_CustomTooltip", UIParent, "GameTooltipTemplate")

local unitTable = { "player", "party1", "party2", "party3", "party4"}
srslylawlUI.crowdControlTable = { "stuns", "incaps", "disorients", "silences", "roots"}
srslylawlUI.anchorTable = {
    "TOP", "RIGHT", "BOTTOM", "LEFT", "CENTER", "TOPRIGHT", "TOPLEFT",
    "BOTTOMLEFT", "BOTTOMRIGHT"
}
local debugString = ""

-- TODO:
--      config window: 
--          show buffs/debuffs visibility settings
--          faux frames absorb auras
--          power/petbar width
--      readycheck
--      phase/shard
--      UnitHasIncomingResurrection(unit)
--      immunities
--      more sort methods?


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
function srslylawlUI.Utils_CCTableTranslation(string)
    if string == "stuns" then return "stun"
    elseif string == "incaps" then return "incapacitate"
    elseif string == "disorients" then return "disorient"
    elseif string == "silences" then return "silence"
    elseif string == "roots" then return "root"
    elseif string == "root" then return "roots"
    elseif string == "silence" then return "silences"
    elseif string == "disorient" then return "disorients"
    elseif string == "incapacitate" then return "incaps"
    elseif string == "stun" then return "stuns"
    else return "none"
    end
end
function srslylawlUI.Utils_GetVirtualPixelSize(size, ...)
   local perPixelScale = 768.0 / GetScreenHeight()
   local curUiScale = GetCVar("uiscale") or 1
   local virtPixelScale = perPixelScale / curUiScale
   if select('#', ...) > 0 then
        local t = {}
        for i=1, select('#', ...) do
            local value = select(i, ...)
            table.insert(t, value/virtPixelScale)
        end
        return size/virtPixelScale, unpack(t)
    end
    return size/virtPixelScale
end
function srslylawlUI.Utils_GetPhysicalPixelSize(size, ...)
   local perPixelScale = 768.0 / GetScreenHeight()
   local curUiScale = GetCVar("uiscale") or 1
   local virtPixelScale = perPixelScale / curUiScale
   if select('#', ...) > 0 then
      local t = {}
      for i=1, select('#', ...) do
         local value = select(i, ...)
         table.insert(t, value*virtPixelScale)
      end
      return size*virtPixelScale, unpack(t)
   end
   return size*virtPixelScale
end
function srslylawlUI.Utils_SetWidthPixelPerfect(frame, width)
    frame:SetWidth(srslylawlUI.Utils_GetVirtualPixelSize(width))
end
function srslylawlUI.Utils_SetHeightPixelPerfect(frame, height)
    frame:SetHeight(srslylawlUI.Utils_GetVirtualPixelSize(height))
end
function srslylawlUI.Utils_SetSizePixelPerfect(frame, width, height)
    frame:SetSize(srslylawlUI.Utils_GetVirtualPixelSize(width, height))
end
function srslylawlUI.Debug()
    if srslylawlUI.DebugWindow == nil then
        srslylawlUI.DebugWindow = CreateFrame("Frame", "srslylawlUI_DebugWindow", UIParent)
        srslylawlUI.DebugWindow:SetSize(500, 500)
        srslylawlUI.DebugWindow:SetPoint("CENTER")
        local scrollFrame = CreateFrame("ScrollFrame", "$parent_ScrollFrame", srslylawlUI.DebugWindow, "UIPanelScrollFrameTemplate,BackdropTemplate")
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
            for i = 1, srslylawlUI.settings.party.buffs.maxBuffs do
                local size = srslylawlUI.settings.party.buffs.size
                local xOffset, yOffset = srslylawlUI.GetBuffOffsets()
                local anchor = "CENTER"
                if (i == 1) then
                    anchor = srslylawlUI.settings.party.buffs.anchor
                    xOffset = srslylawlUI.settings.party.buffs.xOffset
                    yOffset = srslylawlUI.settings.party.buffs.yOffset
                    units[k].buffFrames[i]:SetParent(srslylawlUI.Frame_GetByUnitType(k).unit.auraAnchor)
                end

                if units[k].buffFrames[i] == nil then
                    error('Max visible buffs setting has been changed, please reload UI by typing "/reload" ')
                end
                units[k].buffFrames[i]:ClearAllPoints()
                units[k].buffFrames[i]:SetPoint(anchor, xOffset, yOffset)
                srslylawlUI.Utils_SetSizePixelPerfect(units[k].buffFrames[i], size, size)
            end
        end
    end
end
function srslylawlUI.SetDebuffFrames()
    for k, v in pairs(units) do
        if units[k] ~= nil and units[k].debuffFrames ~= nil then
            for i = 1, srslylawlUI.settings.party.debuffs.maxDebuffs do
                local size = srslylawlUI.settings.party.debuffs.size
                local xOffset, yOffset = srslylawlUI.GetDebuffOffsets()
                local anchor = "CENTER"
                if (i == 1) then
                    anchor = srslylawlUI.settings.party.debuffs.anchor
                    xOffset = srslylawlUI.settings.party.debuffs.xOffset
                    yOffset = srslylawlUI.settings.party.debuffs.yOffset
                    units[k].debuffFrames[i]:SetParent(srslylawlUI.Frame_GetByUnitType(k).unit.auraAnchor)
                end

                if units[k].debuffFrames[i] == nil then
                    error('Max visible debuffs setting has been changed, please reload UI by typing "/reload" ')
                end

                units[k].debuffFrames[i]:ClearAllPoints()
                units[k].debuffFrames[i]:SetPoint(anchor, xOffset, yOffset)
                srslylawlUI.Utils_SetSizePixelPerfect(units[k].debuffFrames[i], size, size)
            end
        end
    end
end
function srslylawlUI.GetBuffOffsets()
    local xOffset, yOffset
    local size = srslylawlUI.Utils_GetVirtualPixelSize(srslylawlUI.settings.party.buffs.size)
     
    local growthDir = srslylawlUI.settings.party.buffs.growthDir
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
    local size = srslylawlUI.Utils_GetVirtualPixelSize(srslylawlUI.settings.party.debuffs.size)
    local growthDir = srslylawlUI.settings.party.debuffs.growthDir
    if growthDir == "LEFT" then
        xOffset = -size
        yOffset = 0
    elseif growthDir == "RIGHT" then
        xOffset = size
        yOffset = 0
    end
    return xOffset, yOffset
end
function srslylawlUI.Frame_InitialUnitConfig(buttonFrame, faux)
    buttonFrame.unit:SetFrameLevel(8)
    buttonFrame.pet:SetFrameLevel(4)
    buttonFrame.pet.healthBar:SetFrameLevel(4)
    buttonFrame.unit.healthBar:SetFrameLevel(4)
    buttonFrame.unit.powerBar:SetFrameLevel(4)
    --buttonFrame.pet.healthBar:SetFrameLevel(1)
    buttonFrame.unit:RegisterForDrag("LeftButton")

    if not faux then
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
        buttonFrame.pet:SetScript("OnShow", function(self)
            local unit = self:GetParent():GetAttribute("unit")
            srslylawlUI.Frame_ResetPetButton(self, unit.."pet")
        end)

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

        --update range/online/alive
        if buttonFrame:GetAttribute("unit") ~= "player" then
            buttonFrame:SetScript("OnUpdate", function(self, deltaTime)
                self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + deltaTime;
                if (self.TimeSinceLastUpdate > srslylawlUI.settings.frameOnUpdateInterval) then
                    --check for unit range
                    local unit = self:GetAttribute("unit")
                    local range = UnitInRange(unit) ~= self.wasInRange
                    local online = UnitIsConnected(unit) ~= self.online
                    local alive = not UnitIsDeadOrGhost(unit) ~= self.alive
                    if range or online or alive then
                        srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
                    end
                    self.TimeSinceLastUpdate = 0;
                end
            end)
        end
        RegisterUnitWatch(buttonFrame)
        RegisterUnitWatch(buttonFrame.pet)
    end

    buttonFrame.pet:SetPoint("TOPLEFT", buttonFrame.unit, "TOPRIGHT", 2, 0)
    buttonFrame.pet:SetPoint("BOTTOMRIGHT", buttonFrame.unit, "BOTTOMRIGHT", srslylawlUI.settings.party.pet.width+2, 0)
    buttonFrame.pet:SetFrameRef("unit", buttonFrame.unit)

    buttonFrame.unit.healthBar.name:SetPoint("BOTTOMLEFT", buttonFrame.unit, "BOTTOMLEFT", 2, 2)
    buttonFrame.unit.healthBar.text:SetPoint("BOTTOMRIGHT", 0, 2)
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
function srslylawlUI.Frame_ResetDimensions_ALL()
    for k, v in pairs(unitTable) do
        local button = srslylawlUI.Frame_GetByUnitType(v)
        if v then
            srslylawlUI.Frame_ResetDimensions(button)
        end
    end
end
function srslylawlUI.Frame_ResetDimensions(button)
    local unitType = button:GetAttribute("unit")
    local h = srslylawlUI.settings.party.hp.height
    local w = srslylawlUI.settings.party.hp.width
    if unitHealthBars ~= nil then
        if unitHealthBars[unitType] ~= nil then
            if unitHealthBars[unitType]["width"] ~= nil then
                w = unitHealthBars[unitType]["width"]
            end
        end
    end

    local widthIsWrong = abs(button.unit.healthBar:GetWidth() - srslylawlUI.Utils_GetVirtualPixelSize(w)) > 1
    local heightIsWrong = abs(button.unit.healthBar:GetHeight() - srslylawlUI.Utils_GetVirtualPixelSize(h)) > 1
    local needsResize = widthIsWrong or heightIsWrong
    if needsResize then
        srslylawlUI.Utils_SetSizePixelPerfect(button.unit.auraAnchor, w, h)
        srslylawlUI.Utils_SetSizePixelPerfect(button.unit.healthBar, w, h)
        srslylawlUI.Utils_SetHeightPixelPerfect(button.unit.powerBar, h)
        srslylawlUI.Frame_MoveAbsorbAnchorWithHealth(unitType)

        if not InCombatLockdown() then
            -- stuff that taints in combat
            srslylawlUI.Utils_SetSizePixelPerfect(button, srslylawlUI.settings.party.hp.width+1, srslylawlUI.settings.party.hp.height+1)
            srslylawlUI.Utils_SetSizePixelPerfect(button.unit, srslylawlUI.settings.party.hp.width, srslylawlUI.settings.party.hp.height)
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
        UpdateHeaderVisible(srslylawlUI.settings.party.showParty)
    elseif isInRaid then
        UpdateHeaderVisible(srslylawlUI.settings.party.showRaid)
    elseif isInArena then
        UpdateHeaderVisible(srslylawlUI.settings.party.showArena)
    else
        local frame = srslylawlUI_PartyHeader.player
        if srslylawlUI.settings.party.showSolo then
            if not frame:IsShown() then
                RegisterUnitWatch(frame)
            end
        else
            if frame:IsShown() then
                UnregisterUnitWatch(frame)
            end
        end
        UpdateHeaderVisible(srslylawlUI.settings.party.showSolo)
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
        srslylawlUI.Frame_HandleAuras(self.unit, unit)
    elseif event == "GROUP_ROSTER_UPDATE" then
        srslylawlUI.Frame_ResetUnitButton(self.unit, unit)
        --for new units joining that already have an absorb (usually warlocks)
        srslylawlUI.Frame_HandleAuras(self.unit, unit)
        srslylawlUI.Frame_UpdateVisibility()
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
                srslylawlUI.Frame_HandleAuras(self.unit, unit)
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
            srslylawlUI.Frame_HandleAuras(self.unit, unit)
        elseif event == "UNIT_HEAL_PREDICTION" then
            srslylawlUI.Frame_HandleAuras(self.unit, unit)
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
    if button == nil then error("trying to reset nonexisting button"..unit) return end
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
    local maxLength = srslylawlUI.settings.party.hp.width
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
    local inRange = UnitInRange(unit)
    local SBColor = { r = classColor.r, g = classColor.g, b =classColor.b, a = classColor.a}
    -- button.healthBar.text:SetText(health .. "/" .. healthMax .. " " ..
    --                                 healthPercent .. "%")

    button.healthBar.text:SetText(health .. " " .. healthPercent .. "%")
    if not alive or not online then
        -- If dead, set bar color to grey and fill bar
        SBColor.r, SBColor.g, SBColor.b = 0.3, 0.3, 0.3

        if not alive then button.healthBar.text:SetText("DEAD") end
        if not online then button.healthBar.text:SetText("offline") end
    end
    button.dead = (not alive)
    button.online = online
    button.wasInRange = inRange
    button.healthBar:SetMinMaxValues(0, healthMax)
    button.healthBar:SetValue(health)

    if unit == "player" or inRange then SBColor.a = 1
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
        button.powerBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
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
    local lowerCap = srslylawlUI.settings.party.hp.minWidthPercent -- bars can not get smaller than this percent of highest
    local pixelPerHp = srslylawlUI.settings.party.hp.width / highestHP
    local minWidth = floor(highestHP * pixelPerHp * lowerCap)

    if scaleByHighest then
        for unit, _ in pairs(unitHealthBars) do
            local scaledWidth = (unitHealthBars[unit]["maxHealth"] * pixelPerHp)
            scaledWidth = scaledWidth < minWidth and minWidth or scaledWidth
            unitHealthBars[unit]["width"] = scaledWidth
        end
    else -- sort by average
    end
    srslylawlUI.Frame_ResetDimensions_ALL()
end
function srslylawlUI_PartyFrame_OnDragStart()
    if not srslylawlUI_PartyHeader:IsMovable() then return end
    srslylawlUI_PartyHeader:StartMoving()
    srslylawlUI_PartyHeader.isMoving = true
end
function srslylawlUI_PartyFrame_OnDragStop()
    if srslylawlUI_PartyHeader.isMoving then
        srslylawlUI_PartyHeader:StopMovingOrSizing()
        local point, relativeTo, relativePoint, xOfs, yOfs =
            srslylawlUI_PartyHeader:GetPoint()
        srslylawlUI.settings.party.header.anchor = point
        srslylawlUI.settings.party.header.xOffset = xOfs
        srslylawlUI.settings.party.header.yOffset = yOfs
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
    units[unit].absorbFrames[1]:Hide()
    units[unit].absorbFramesOverlap[1]:Hide()
    units[unit].effectiveHealthFrames[1]:Hide()
end
function srslylawlUI_Frame_ToggleFauxFrames(visible)
    srslylawlUI_FAUX_PartyHeader:SetShown(visible)
    srslylawlUI_PartyHeader_player:SetShown(not visible)

    srslylawlUI.Log((visible and "Fake frames now visible." or "Fake frames now hidden."))

    if not srslylawlUI_FAUX_PartyHeader.initiated then
        local lastFrame
        local class = select(2, UnitClass("player")) or "WARRIOR"
        local health = UnitHealthMax("player")
        local _, powerToken = UnitPowerType("player")
        local fauxUnit = {
            ["class"] = class,
            ["hpmax"] = health,
            ["hp"] = ceil(health/1.5),
            ["mana"] = 1,
            ["powerToken"] = powerToken,
            ["CCIcon"] = 132298,
            ["CCColor"] = "none",
            ["CCMaxDur"] = 6
        }
        for i,unit in pairs(unitTable) do
            local frame = _G["srslylawlUI_FAUX_PartyHeader_"..unit]

            if unit == "party1" then
                fauxUnit.class = "WARLOCK"
                fauxUnit.hpmax = ceil(fauxUnit.hpmax * 0.95)
                fauxUnit.hp = ceil(fauxUnit.hpmax)
                fauxUnit.mana = 1
                fauxUnit.powerToken = "MANA"
                fauxUnit.CCIcon = 136071 --poly
                fauxUnit.CCColor = "Magic"
                fauxUnit.CCMaxDur = 8
            elseif unit == "party2" then
                fauxUnit.class = "ROGUE"
                fauxUnit.hpmax = ceil(fauxUnit.hpmax * 0.90)
                fauxUnit.hp = ceil(fauxUnit.hpmax * 0.6)
                fauxUnit.mana = 0.4
                fauxUnit.powerToken = "ENERGY"
                fauxUnit.CCIcon = 132310 -- sap
                fauxUnit.CCColor = "none"
                fauxUnit.CCMaxDur = 8
            elseif unit == "party3" then
                fauxUnit.class = "MAGE"
                fauxUnit.hpmax = ceil(fauxUnit.hpmax)
                fauxUnit.hp = ceil(fauxUnit.hpmax * 0.3)
                fauxUnit.mana = 0.8
                fauxUnit.powerToken = "MANA"
                fauxUnit.CCIcon = 136183 -- fear
                fauxUnit.CCColor = "Magic"
                fauxUnit.CCMaxDur = 6
            elseif unit == "party4" then
                fauxUnit.class = "SHAMAN"
                fauxUnit.hpmax = ceil(fauxUnit.hpmax * 0.2)
                fauxUnit.hp = ceil(fauxUnit.hpmax)
                fauxUnit.mana = 0.3
                fauxUnit.powerToken = "MANA"
                fauxUnit.CCIcon = 458230 -- silence
                fauxUnit.CCColor = "Magic"
                fauxUnit.CCMaxDur = 4
            end
            frame:SetAttribute("hpMax", fauxUnit.hpmax)

            local function AddTooltip(frame, text)
                local function OnEnter(self)
                    srslylawlUI.customTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
                    srslylawlUI.customTooltip:SetText(text)
                end
                local function OnLeave(self) srslylawlUI.customTooltip:Hide() end

                frame:EnableMouse(true)
                frame:SetScript("OnEnter", OnEnter)
                frame:SetScript("OnLeave", OnLeave)
            end

            AddTooltip(frame.unit, unit.." frame")
            AddTooltip(frame.pet, unit.." petframe")
            AddTooltip(frame.unit.powerBar, unit.." power bar")

            --CC bar
            local timerCC, duration, expirationTime, remaining = 0, fauxUnit.CCMaxDur, 0, 0
            frame.unit.CCDurBar:SetScript("OnUpdate", 
                function(self, elapsed)
                    timerCC = timerCC + elapsed
                    if timerCC >= 0.025 then
                        remaining = expirationTime-GetTime()
                        self:SetValue(remaining/duration)
                        local timerstring = tostring(remaining)
                        timerstring = timerstring:match("%d+%p?%d")
                        self.timer:SetText(timerstring)
                        timerCC = 0
                    end
                    if remaining <= 0 then
                        expirationTime = GetTime()+duration
                    end
                end)
            frame.unit.CCDurBar:Show()
            frame.unit.CCDurBar.icon:SetTexture(fauxUnit.CCIcon)
            local color = DebuffTypeColor[fauxUnit.CCColor]
            frame.unit.CCDurBar:SetStatusBarColor(color.r, color.g, color.b)

            color = RAID_CLASS_COLORS[fauxUnit.class]

            local hp = (fauxUnit.hp .. " " .. ceil(fauxUnit.hp / fauxUnit.hpmax * 100) .. "%")

            frame.unit.CCTexture:Hide()

            local powerToken = fauxUnit.powerToken
            local powerColor = srslylawlUI.Frame_GetCustomPowerBarColor(powerToken)
            frame.unit.powerBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
            frame.unit.powerBar:SetMinMaxValues(0, 1)
            frame.unit.powerBar:SetValue(fauxUnit.mana)

            if unit == "player" then
                frame:SetPoint("TOPLEFT", srslylawlUI_FAUX_PartyHeader, "TOPLEFT")
                frame.unit.healthBar.text:SetText("")
            else
                frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT")
                frame.unit.healthBar.name:SetText(unit)
                frame.unit.healthBar.text:SetText(hp)
                frame.unit.healthBar:SetMinMaxValues(0, fauxUnit.hpmax)
                frame.unit.healthBar:SetValue(fauxUnit.hp)
                frame.unit.healthBar:SetStatusBarColor(color.r, color.g, color.b)
            end

            --buffs
            frame.buffs = {}
            local frameName = "srslylawlUI_FAUX"..unit.."Aura"
            for i = 1, 40 do
                local xOffset, yOffset = srslylawlUI.GetBuffOffsets()
                local parent = _G[frameName .. (i - 1)]
                local anchor = srslylawlUI.settings.party.buffs.growthDir
                if (i == 1) then
                    parent = frame.unit
                    anchor = srslylawlUI.settings.party.buffs.anchor
                    xOffset = srslylawlUI.settings.party.buffs.xOffset
                    yOffset = srslylawlUI.settings.party.buffs.yOffset
                end
                local f = CreateFrame("Button", frameName .. i, parent, "CompactBuffTemplate")
                f:SetPoint(anchor, xOffset, yOffset)
                f:EnableMouse(false)
                f.icon:SetTexture(135932)
                frame.buffs[i] = f
            end
            --debuffs
            frame.debuffs = {}
            local frameName = "srslylawlUI_FAUX"..unit.."Debuff"
            for i = 1, 40 do
                local xOffset, yOffset = srslylawlUI.GetDebuffOffsets()
                local parent = _G[frameName .. (i - 1)]
                local anchor = srslylawlUI.settings.party.debuffs.growthDir
                if (i == 1) then
                    parent = frame.unit
                    anchor = srslylawlUI.settings.party.debuffs.anchor
                    xOffset = srslylawlUI.settings.party.debuffs.xOffset
                    yOffset = srslylawlUI.settings.party.debuffs.yOffset
                end
                local f = CreateFrame("Button", frameName .. i, parent, "CompactDebuffTemplate")
                f:SetPoint(anchor, xOffset, yOffset)
                f:EnableMouse(false)
                f.icon:SetTexture(136207)
                frame.debuffs[i] = f
            end

            -- local trackedAurasByIndex = {
            --     ["spellId"] = spellId,
            --     ["checkedThisEvent"] = true,
            --     ["absorb"] = fauxUnit.hpmax/5,
            --     ["icon"] = icon,
            --     ["duration"] = duration,
            --     ["expiration"] = expirationTime,
            --     ["wasRefreshed"] = flagRefreshed,
            --     ["source"] = source
            -- }

            local timerFrame = 1

            --update frames to reflect current settings
            frame:SetScript("OnUpdate",
                function(self, elapsed)
                timerFrame = timerFrame + elapsed
                if timerFrame > 0.1 then
                    local countChanged = self.shownBuffs ~= srslylawlUI.settings.party.buffs.maxBuffs
                    local anchorChanged = self.buffs.anchor ~= srslylawlUI.settings.party.buffs.anchor or self.buffs.xOffset ~= srslylawlUI.settings.party.buffs.xOffset or self.buffs.yOffset ~= srslylawlUI.settings.party.buffs.yOffset
                    local sizeChanged = self.buffs.size ~= srslylawlUI.settings.party.buffs.size
                    if countChanged or anchorChanged or sizeChanged then
                        self.shownBuffs = srslylawlUI.settings.party.buffs.maxBuffs
                        for i=1,40 do
                            self.buffs[i]:SetShown(i <= self.shownBuffs)
                            local size = srslylawlUI.settings.party.buffs.size
                            local xOffset, yOffset = srslylawlUI.GetBuffOffsets()
                            local anchor = "CENTER"
                            if (i == 1) then
                                anchor = srslylawlUI.settings.party.buffs.anchor
                                xOffset = srslylawlUI.settings.party.buffs.xOffset
                                yOffset = srslylawlUI.settings.party.buffs.yOffset
                                self.buffs[i]:SetParent(self.unit.auraAnchor)

                                self.buffs.anchor = anchor
                                self.buffs.xOffset = xOffset
                                self.buffs.yOffset = yOffset
                                self.buffs.size = size
                            end
                            self.buffs[i]:ClearAllPoints()
                            self.buffs[i]:SetPoint(anchor, xOffset, yOffset)
                            srslylawlUI.Utils_SetSizePixelPerfect(self.buffs[i], size, size)

                        end
                    end
                    countChanged = self.shownDebuffs ~= srslylawlUI.settings.party.debuffs.maxDebuffs
                    sizeChanged = self.debuffs.size ~= srslylawlUI.settings.party.debuffs.size
                    anchorChanged = self.debuffs.anchor ~= srslylawlUI.settings.party.debuffs.anchor or self.debuffs.xOffset ~= srslylawlUI.settings.party.debuffs.xOffset or self.debuffs.yOffset ~= srslylawlUI.settings.party.debuffs.yOffset
                    if countChanged or anchorChanged or sizeChanged then
                        self.shownDebuffs = srslylawlUI.settings.party.debuffs.maxDebuffs
                        for i=1,40 do
                            self.debuffs[i]:SetShown(i <= self.shownDebuffs)
                            local size = srslylawlUI.settings.party.debuffs.size
                            local xOffset, yOffset = srslylawlUI.GetDebuffOffsets()
                            local anchor = "CENTER"
                            if (i == 1) then
                                anchor = srslylawlUI.settings.party.debuffs.anchor
                                xOffset = srslylawlUI.settings.party.debuffs.xOffset
                                yOffset = srslylawlUI.settings.party.debuffs.yOffset
                                self.debuffs[i]:SetParent(self.unit.auraAnchor)

                                self.debuffs.anchor = anchor
                                self.debuffs.xOffset = xOffset
                                self.debuffs.yOffset = yOffset
                                self.debuffs.size = size
                            end
                            self.debuffs[i]:ClearAllPoints()
                            self.debuffs[i]:SetPoint(anchor, xOffset, yOffset)
                            self.debuffs[i]:SetSize(size, size)
                            self.debuffs.size = size
                        end
                    end
                    local h = srslylawlUI.settings.party.hp.height
                    local lowerCap = srslylawlUI.settings.party.hp.minWidthPercent
                    local health = UnitHealthMax("player")
                    local pixelPerHp = srslylawlUI.settings.party.hp.width / health
                    local minWidth = floor(health * pixelPerHp * lowerCap)
                    local scaledWidth = (self:GetAttribute("hpMax") * pixelPerHp)
                    scaledWidth = scaledWidth < minWidth and minWidth or scaledWidth
                    srslylawlUI.Utils_SetSizePixelPerfect(self, srslylawlUI.settings.party.hp.width+2, h+2)
                    srslylawlUI.Utils_SetSizePixelPerfect(self.unit, srslylawlUI.settings.party.hp.width, h)
                    srslylawlUI.Utils_SetSizePixelPerfect(self.unit.auraAnchor, scaledWidth, h)
                    srslylawlUI.Utils_SetSizePixelPerfect(self.unit.healthBar, scaledWidth, h)
                    srslylawlUI.Utils_SetHeightPixelPerfect(self.unit.powerBar, h)
                    srslylawlUI.Utils_SetHeightPixelPerfect(self.pet.healthBar, h)
                    srslylawlUI.Utils_SetHeightPixelPerfect(self.pet, h)
                    local h2 = h/2
                    local w = 100
                    local petW = srslylawlUI.settings.party.pet.width + 2
                    local iconSize = (w > h2 and h2) or w
                    srslylawlUI.Utils_SetSizePixelPerfect(self.unit.CCDurBar, w, h2)
                    srslylawlUI.Utils_SetSizePixelPerfect(self.unit.CCDurBar.icon, iconSize, iconSize)


                    timerFrame = 0
                end
            end)
            frame:Show()
            lastFrame = frame
        end
        srslylawlUI_FAUX_PartyHeader.initiated = true
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
    local list, _, _, hasUnknownMember = srslylawlUI.GetPartyHealth()

    if not list then return end

    if InCombatLockdown() then
        srslylawlUI.SortAfterCombat()
        return
    end

    if hasUnknownMember then
        -- all units arent properly loaded yet, lets check again in a few secs
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

        if (buttonFrame) then
            buttonFrame:ClearAllPoints()
            if i == 1 then
                buttonFrame:SetPoint("TOPLEFT", srslylawlUI_PartyHeader, "TOPLEFT")
            else
                local parent = srslylawlUI.Frame_GetByUnitType(list[i - 1].unit)
                buttonFrame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT")
            end
            srslylawlUI.Frame_ResetUnitButton(buttonFrame.unit, list[i].unit)
        end
    end

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
function srslylawlUI.Auras_GetDebuffText(debuffIndex, unit)
    tooltipTextGrabber:SetOwner(srslylawlUI_PartyHeader, "ANCHOR_NONE")
    tooltipTextGrabber:SetUnitDebuff(unit, debuffIndex)
    local n2 = srslylawl_TooltipTextGrabberTextLeft2:GetText()
    tooltipTextGrabber:Hide()
    return n2
end
function srslylawlUI.Frame_HandleAuras(unitbutton, unit)
    local function GetTypeOfAuraID(spellId)
        local auraType = nil
        if srslylawlUI.buffs.absorbs[spellId] ~= nil then
            auraType = "absorb"
        elseif srslylawlUI.buffs.defensives[spellId] ~= nil then
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
    local function ChangeTrackingIndex(name, source, count, spellId, currentIndex, absorb, icon, duration, expirationTime, auraType)
        -- srslylawlUI.Log("index changed " .. name)
        local byAura = auraType .. "Auras"
        local byIndex = "trackedAurasByIndex"
        local oldIndex = units[unit][byAura][source][spellId].index
        assert(oldIndex ~= nil)
        -- assign to current
        units[unit][byAura][source][spellId].index = currentIndex

        -- flag for timer refresh
        local diff = 0
        if units[unit][byIndex][oldIndex] ~= nil and units[unit][byIndex][oldIndex].expiration ~= nil then
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
        
        local tat = units[unit][byIndex][oldIndex].trackedApplyTime
        if tat then 
            t["trackedApplyTime"] = tat
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
    local function ProcessAuraTracking(name, source, count, spellId, i, absorb, icon, duration, expirationTime, auraType)
        if IsAuraBeingTrackedAtOtherIndex(source, spellId, auraType) then
            -- aura is being tracked but at another index, change that
            ChangeTrackingIndex(name, source, count, spellId, i, absorb, icon, duration, expirationTime, auraType)
        else
            -- aura is not tracked at all, track it!
            TrackAura(source, spellId, count, name, i, absorb, icon, duration,
                      expirationTime, auraType)
        end
    end

    if unitbutton.buffFrame == nil and srslylawlUI.settings.party.buffs.maxBuffs > 0 then -- this unit doesnt own the frames yet
        unitbutton.buffFrames = units[unit].buffFrames
        if unitbutton.buffFrames[1] == nil then
            error('Max visible buffs setting has been changed, please reload UI by typing "/reload" ')
        end
        srslylawlUI.SetBuffFrames()
    end
    if unitbutton.debuffFrames == nil and srslylawlUI.settings.party.debuffs.maxDebuffs > 0 then -- this unit doesnt own the frames yet
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
            srslylawlUI.Auras_RememberBuff(spellId, i, unit)
            if srslylawlUI.Auras_ShouldDisplayBuff(UnitAura(unit, i, "HELPFUL")) and currentBuffFrame <= srslylawlUI.settings.party.buffs.maxBuffs then
                CompactUnitFrame_UtilSetBuff(f, i, UnitAura(unit, i))
                f:SetID(i)
                f:Show()
                currentBuffFrame = currentBuffFrame + 1
            elseif f then
                f:Hide()
            end
            -- track auras, check if we care to track it
            local auraType = GetTypeOfAuraID(spellId)

            if auraType ~= nil then
                if AuraIsBeingTrackedAtIndex(i) then
                    if units[unit].trackedAurasByIndex[i]["spellId"] ~= spellId then
                        -- different spell is being tracked
                        UntrackAura(i)
                        ProcessAuraTracking(name, source, count, spellId, i, absorb, icon, duration, expirationTime, auraType)
                    else
                        -- aura is tracked and at same index, update that we verified that this frame
                        TrackAura(source, spellId, count, name, i, absorb, icon, duration, expirationTime, auraType, true)
                    end
                else
                    -- no aura is currently tracked for that index
                    ProcessAuraTracking(name, source, count, spellId, i, absorb, icon, duration, expirationTime, auraType)
                end
            else
                if AuraIsBeingTrackedAtIndex(i) then
                    UntrackAura(i)
                end
            end
        elseif f then -- no more buffs, hide frames
            f:Hide()
        end
    end
    -- process debuffs on unit

    local appliedCC = {}
    currentDebuffFrame = 1
    for i = 1, 40 do
        local f = unitbutton.debuffFrames[currentDebuffFrame]
        local name, icon, count, debuffType, duration, expirationTime, source,
              isStealable, nameplateShowPersonal, spellId, canApplyAura,
              isBossDebuff, castByPlayer, nameplateShowAll, timeMod, absorb =
            UnitAura(unit, i, "HARMFUL")
        if name then -- if aura on this index exists, assign it
            srslylawlUI.Auras_RememberDebuff(spellId, i, unit)

            --check if its CC
            if srslylawlUI.debuffs.known[spellId] ~= nil and srslylawlUI.debuffs.known[spellId].crowdControlType ~= "none" and srslylawlUI.debuffs.blackList[spellId] == nil then
                local cc = {
                    ["ID"] = spellId,
                    ["index"] = i,
                    ["expirationTime"] = expirationTime,
                    ["icon"] = icon,
                    ["debuffType"] = debuffType,
                    ["ccType"] = srslylawlUI.debuffs.known[spellId].crowdControlType,
                    ["remaining"] = expirationTime-GetTime()
                }
                table.insert(appliedCC, cc)
            end

            if srslylawlUI.Auras_ShouldDisplayDebuff(UnitAura(unit, i, "HARMFUL")) and currentDebuffFrame <= srslylawlUI.settings.party.debuffs.maxDebuffs then
                f.icon:SetTexture(icon)
                if ( count > 1 ) then
		            local countText = count;
		            if ( count >= 100 ) then
			            countText = BUFF_STACKS_OVERFLOW;
		            end
		            f.count:Show();
		            f.count:SetText(countText);
	            elseif f then
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

    --see if we want to display our cced frame
    if #appliedCC > 0 then
        --Decide which cc to display
        table.sort(appliedCC, function(a, b) return b.remaining < a.remaining end)
        local CCToDisplay = appliedCC[1]

        if CCToDisplay.ccType == "roots" then
            --if we picked a root, see if theres a hardcc applied as well, and if yes, display it instead
            for i=2, #appliedCC do
                if appliedCC[i].ccType ~= "roots" then
                    CCToDisplay = appliedCC[i]
                    break
                end
            end
        end

        local color = DebuffTypeColor[CCToDisplay.debuffType] or DebuffTypeColor["none"];
        unitbutton.CCTexture:SetVertexColor(color.r, color.g, color.b)
        unitbutton.CCTexture:Show()

        local exists = unitbutton.CCDurBar.spellData ~= nil
        local differentSpell = exists and unitbutton.CCDurBar.spellData.ID ~= CCToDisplay.ID
        local differentExpTime = exists and unitbutton.CCDurBar.spellData.expirationTime ~= CCToDisplay.expirationTime
        local differentIndex = exists and unitbutton.CCDurBar.spellData.index ~= CCToDisplay.index

        --See if its already being displayed
        if not exists or differentSpell or differentExpTime or differentIndex then
            --not being displayed
            unitbutton.CCDurBar.spellData = CCToDisplay
            unitbutton.CCDurBar.icon:SetTexture(CCToDisplay.icon)
            unitbutton.CCDurBar:SetStatusBarColor(color.r, color.g, color.b)
            local timer, duration, expirationTime, remaining = 0, 0, 0, 0
            local updateInterval = 0.02
            unitbutton.CCDurBar:SetScript("OnUpdate", 
                function(self, elapsed)
                    timer = timer + elapsed
                    _, _, _, _, duration, expirationTime = UnitAura(unit, self.spellData.index, "HARMFUL")
                    if expirationTime == nil then return end
                    if timer >= updateInterval then
                        if duration == 0 then
                            self:SetValue(1)
                            self.timer:SetText("")
                        else
                            remaining = expirationTime-GetTime()
                            self:SetValue(remaining/duration)
                            local timerstring = tostring(remaining)
                            timerstring = timerstring:match("%d+%p?%d")
                            self.timer:SetText(timerstring)
                        end
                        timer = timer - updateInterval
                    end
                end)
        else
            --just update data
            unitbutton.CCDurBar.spellData = CCToDisplay
        end
        unitbutton.CCDurBar:Show()
    else
        unitbutton.CCDurBar:Hide()
        unitbutton.CCTexture:Hide()
    end
    -- we checked all frames, untrack any that are gone
    for k, v in pairs(units[unit].trackedAurasByIndex) do
        if (v["checkedThisEvent"] == false) then
            UntrackAura(k)
        end
    end

    -- -- we tracked all absorbs, now we have to visualize them
    srslylawlUI.Auras_HandleEffectiveHealth(units[unit].trackedAurasByIndex, unit)
    srslylawlUI.Auras_HandleAbsorbFrames(units[unit].trackedAurasByIndex, unit)
end
function srslylawlUI_Frame_HandleAuras_ALL()
    for k, v in pairs(unitTable) do
        local f = srslylawlUI.Frame_GetByUnitType(v)

        if f.unit then
            srslylawlUI.Frame_HandleAuras(f.unit, v)
        end
    end
end
function srslylawlUI.Frame_ChangeAbsorbSegment(frame, barWidth, absorbAmount, height, isHealPrediction)
    frame:SetAttribute("absorbAmount", absorbAmount)
    srslylawlUI.Utils_SetSizePixelPerfect(frame, barWidth, height)
    -- resize icon
    if isHealPrediction then
        frame.icon:Hide()
        frame.cooldown:Clear()
    else
        local minSize = 7
        local maxIconSize = floor(height * 0.8)
        if (barWidth < minSize) then
            --srslylawlUI.Utils_SetSizePixelPerfect(frame.icon, minSize, minSize)
            frame.icon:Hide()
        elseif (barWidth >= maxIconSize) then
            srslylawlUI.Utils_SetSizePixelPerfect(frame.icon, maxIconSize, maxIconSize)
            frame.icon:Show()
        else
            srslylawlUI.Utils_SetSizePixelPerfect(frame.icon, barWidth - 2, barWidth - 2)
            frame.icon:Show()
        end
    end
end
function srslylawlUI.Frame_MoveAbsorbAnchorWithHealth(unit)
    local buttonFrame = srslylawlUI.Frame_GetByUnitType(unit)
    local width = buttonFrame.unit.healthBar:GetWidth()
    local maxHP = UnitHealthMax(unit)
    local pixelPerHp = width / (maxHP ~= 0 and maxHP or 1)
    local playerCurrentHP = UnitHealth(unit)
    local baseAnchorOffset = playerCurrentHP * pixelPerHp
    local mergeOffset = 0
    if units[unit]["absorbFramesOverlap"][1].isMerged then
        --offset by mergeamount
        mergeOffset = srslylawlUI.Utils_GetVirtualPixelSize(units[unit]["absorbFramesOverlap"][1].mergeAmount+1)
    end
    units[unit]["absorbFrames"][1]:SetPoint("TOPLEFT", buttonFrame.unit.healthBar,"TOPLEFT", baseAnchorOffset+1, 0)
    units[unit]["absorbFramesOverlap"][1]:SetPoint("TOPRIGHT", buttonFrame.unit.healthBar, "TOPLEFT", baseAnchorOffset+mergeOffset,0)
    units[unit]["effectiveHealthFrames"][1]:SetPoint("TOPLEFT", buttonFrame.unit.healthBar,"TOPLEFT", baseAnchorOffset+1, 0)
end
function srslylawlUI.Auras_ShouldDisplayBuff(...)
    local name, icon, count, debuffType, duration, expirationTime, source,
              isStealable, nameplateShowPersonal, spellId, canApplyAura,
              isBossDebuff, castByPlayer, nameplateShowAll, timeMod, absorb = ...

    local function NotDefault(bool)
        return bool ~= srslylawlUI.settings.party.buffs.showDefault
    end
    if srslylawlUI.buffs.whiteList[spellId] ~= nil then
        --always show whitelisted spells
        return true
    end

    if srslylawlUI.buffs.blackList[spellId] ~= nil then
        --never show blacklisted spells
        return false
    end

    if srslylawlUI.buffs.absorbs[spellId] ~= nil then
        --dont show absorb spells unless whitelisted
        return false
    end

    if srslylawlUI.buffs.defensives[spellId] ~= nil then
        --its a defensive spell 
        return srslylawlUI.settings.party.buffs.showDefensives
    end

    if duration == 0 then
        return srslylawlUI.settings.party.buffs.showInfiniteDuration
    end
    
    if duration > srslylawlUI.settings.party.buffs.maxDuration then
        if NotDefault(srslylawlUI.buffs.showLongDuration) then
            return srslylawlUI.buffs.showLongDuration
        end
    end
    
    if source == "player" and castByPlayer then
        if NotDefault(srslylawlUI.settings.party.buffs.showCastByPlayer) then
            return srslylawlUI.settings.party.buffs.showCastByPlayer
        end
    end
    

    return srslylawlUI.settings.party.buffs.showDefault
end
function srslylawlUI.Auras_ShouldDisplayDebuff(...)
    local name, icon, count, debuffType, duration, expirationTime, source,
              isStealable, nameplateShowPersonal, spellId, canApplyAura,
              isBossDebuff, castByPlayer, nameplateShowAll, timeMod, absorb = ...

    local function NotDefault(bool)
        return bool ~= srslylawlUI.settings.party.debuffs.showDefault
    end
    if srslylawlUI.debuffs.whiteList[spellId] ~= nil then
        --always show whitelisted spells
        return true
    end

    if srslylawlUI.debuffs.blackList[spellId] ~= nil then
        --never show blacklisted spells
        return false
    end
    
    if source == "player" and castByPlayer then
        if NotDefault(srslylawlUI.settings.party.debuffs.showCastByPlayer) then
            return srslylawlUI.settings.party.debuffs.showCastByPlayer
        end
    end
    
    if duration == 0 then
        if NotDefault(srslylawlUI.settings.party.debuffs.showInfiniteDuration) then
            return srslylawlUI.settings.party.debuffs.showInfiniteDuration
        end
    end
    
    if duration > srslylawlUI.settings.party.debuffs.maxDuration then
        if NotDefault(srslylawlUI.settings.party.debuffs.showLongDuration) then
            return srslylawlUI.settings.party.debuffs.showLongDuration 
        end
    end


    return srslylawlUI.settings.party.debuffs.showDefault
end
function srslylawlUI.Auras_RememberBuff(spellId, buffIndex, unit)
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
        "reducing all damage taken", "reduces all damage taken", "damage taken is redirected", "damage taken is transferred"
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
    local function ProcessID(buffIndex, unit)
        local spellName, icon, stacks, debuffType, duration, expirationTime, source,
              isStealable, nameplateShowPersonal, spellId, canApplyAura,
              isBossDebuff, castByPlayer, nameplateShowAll, timeMod, arg1 =
            UnitAura(unit, buffIndex, "HELPFUL")
        local buffText = srslylawlUI.Auras_GetBuffText(buffIndex, unit)
        local buffLower = buffText ~= nil and string.lower(buffText) or ""
        local keyWordAbsorb = HasAbsorbKeyword(buffLower) and ((arg1 ~= nil) and (arg1 > 1))
        local keyWordDefensive = HasDefensiveKeyword(buffLower)
        local isKnown = srslylawlUI.buffs.known[spellId] ~= nil
        local autoDetectDisabled = isKnown and srslylawlUI.buffs.known[spellId].autoDetect ~= nil and srslylawlUI.buffs.known[spellId].autoDetect == false

        if autoDetectDisabled then
            srslylawlUI.buffs.known[spellId].text = buffText
            srslylawl_saved.buffs.known[spellId].text = buffText
            return
        end

        local spell = {
            name = spellName,
            text = buffText,
            isAbsorb = keyWordAbsorb,
            isDefensive = keyWordDefensive
        }
        local link = GetSpellLink(spellId)

        if keyWordAbsorb then
            if (srslylawlUI.buffs.absorbs[spellId] == nil) then
                -- first time entry
                srslylawlUI.Log("new absorb spell " .. link .. " encountered!")
            else
                -- srslylawlUI.Log("spell updated " .. spellName .. "!")
            end

            srslylawlUI.buffs.absorbs[spellId] = spell
            srslylawl_saved.buffs.absorbs[spellId] = spell
        elseif keyWordDefensive then
            local amount = GetPercentValue(buffLower)
            local log = "new defensive spell " .. link .. " encountered with a reduction of " .. amount .. "%!"



            if stacks ~= 0 then
                amount = amount / stacks
                log = "new defensive spell " .. link .. " encountered with a reduction of " .. amount .. "% per stack!"
            end

            if abs(amount) ~= 0 then spell.reductionAmount = amount
            else
                error("reduction amount is 0 " .. spellName .. " " .. buffText)
            end
            if (srslylawlUI.buffs.defensives[spellId] == nil) then
                -- first time entry
                srslylawlUI.Log(log)
            else
                -- srslylawlUI.Log("spell updated " .. spellName .. "!")
            end
            srslylawlUI.buffs.defensives[spellId] = spell
            srslylawl_saved.buffs.defensives[spellId] = spell
        end

        if isKnown then
            -- make sure not to replace any other keys
            for key, _ in pairs(spell) do
                srslylawlUI.buffs.known[spellId][key] = spell[key]
                srslylawl_saved.buffs.known[spellId][key] = spell[key]
            end
        else
            --srslylawlUI.Log("new spell encountered: " .. spellName .. "!")
            -- Add spell to known spell list
            srslylawlUI.buffs.known[spellId] = spell
            srslylawl_saved.buffs.known[spellId] = spell
        end
    end

    ProcessID(buffIndex, unit)
end
function srslylawlUI.Auras_RememberDebuff(spellId, debuffIndex, unit)
    local function GetCrowdControlType(tooltipText)
        local s = string.lower(tooltipText)

        if s:match("stunned") then
            return "stuns"
        elseif s:match("silenced") then
            return "silences"
        elseif s:match("disoriented") or s:match("feared") then
            return "disorients"
        elseif s:match("incapacitated") or s:match("sleep") then
            return "incaps"    
        end

        if s:match("rooted") or s:match("immobilized") or s:match("frozen") or s:match("pinned in place") or s:match("immobile") then
            return "roots"
        end

        return "none"
    end
    local function ProcessID(spellId, debuffIndex, unit, arg1)
        local spellName = GetSpellInfo(spellId)
        local debuffText = srslylawlUI.Auras_GetDebuffText(debuffIndex, unit)
        local debuffLower = debuffText ~= nil and string.lower(debuffText) or ""

        local CCType = GetCrowdControlType(debuffLower)
        local isKnown = srslylawlUI.debuffs.known[spellId] ~= nil
        local autoDetectDisabled = isKnown and srslylawlUI.debuffs.known[spellId].autoDetect ~= nil and srslylawlUI.debuffs.known[spellId].autoDetect == false

        if autoDetectDisabled then
            --only update last parsed text
            srslylawlUI.debuffs.known[spellId].text = debuffText
            srslylawl_saved.debuffs.known[spellId].text = debuffText
            return
        end

        local spell = {
            name = spellName,
            text = debuffText,
            crowdControlType = CCType
        }
        local link = GetSpellLink(spellId)

        if CCType ~= "none" then
            if srslylawlUI.debuffs.known[spellId] == nil then
                -- first time entry
                srslylawlUI.Log("new crowd control spell " .. link .. " encountered!")
            else
                -- srslylawlUI.Log("spell updated " .. spellName .. "!")
            end

            srslylawlUI.debuffs[CCType][spellId] = spell
            srslylawl_saved.debuffs[CCType][spellId] = spell
        end

        if isKnown then
            -- make sure not to replace any other keys
            for key, _ in pairs(spell) do
                srslylawlUI.debuffs.known[spellId][key] = spell[key]
                srslylawl_saved.debuffs.known[spellId][key] = spell[key]
            end
        else
            --srslylawlUI.Log("new spell encountered: " .. spellName .. "!")
            -- Add spell to known spell list
            srslylawlUI.debuffs.known[spellId] = spell
            srslylawl_saved.debuffs.known[spellId] = spell
        end
    end

    ProcessID(spellId, debuffIndex, unit, arg1)
end
function srslylawlUI.Auras_ManuallyAddSpell(IDorName, auraType)
    -- we dont have the same tooltip that we get from unit buffindex and slot, so we dont save it
    -- it should get added/updated though once we ever see it on any party members

    local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(IDorName)

    if name == nil then
        srslylawlUI.Log("Spell " .. IDorName .. " not found. Make sure you typed the name/spell ID correctly.")
        return
    end

    local link = GetSpellLink(spellId)

    local isKnown = srslylawlUI[auraType].known[spellId] ~= nil

    if isKnown then
        srslylawlUI.Log(link .. " is already known.")
    else
        local spell = {}
        spell.name = name
        spell.text = ""


        if auraType == "buffs" then
            spell.isAbsorb = false
            spell.isDefensive = false
        elseif auraType == "debuffs" then
            spell.crowdControlType = "none"
        end


        srslylawlUI[auraType].known[spellId] = spell
        srslylawl_saved[auraType].known[spellId] = spell
        srslylawlUI.Log("New spell added: " .. link .. "!")
    end
end
function srslylawlUI.Auras_ManuallyRemoveSpell(spellId, auraType)

    srslylawlUI[auraType].known[spellId] = nil
    srslylawl_saved[auraType].known[spellId] = nil
    local link = GetSpellLink(spellId)

    for k, category in pairs(srslylawlUI[auraType]) do
        if category[spellId] ~= nil then
            category[spellId] = nil
            srslylawl_saved[auraType][k][spellId] = nil
            srslylawlUI.Log(link .. " removed from "..k.."!")
        end
    end

    srslylawlUI.Log(link .. " removed from " .. auraType .. "!")


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
function srslylawlUI.Auras_BlacklistSpell(spellId, auraType)
    local spell = srslylawlUI[auraType].known[spellId]
    local str = spell.name

    srslylawlUI[auraType].blackList[spellId] = spell
    srslylawl_saved[auraType].blackList[spellId] = spell

    if srslylawlUI[auraType].whiteList[spellId] ~= nil then
        srslylawlUI[auraType].whiteList[spellId] = nil
        srslylawl_saved[auraType].whiteList[spellID] = nil
        str = str .. " removed from whitelist and "
    end
    
    srslylawlUI.Log(str .. " blacklisted, will no longer be shown.")
end
function srslylawlUI.Auras_HandleAbsorbFrames(trackedAurasByIndex, unit)
    local height = srslylawlUI.settings.party.hp.height*0.7
    local width = srslylawlUI.settings.party.hp.width
    local playerHealthMax = UnitHealthMax(unit)
    local pixelPerHp = width / playerHealthMax
    local playerCurrentHP = UnitHealth(unit)
    local currentBarLength = (playerCurrentHP * pixelPerHp) + 1
    local overlapBarIndex, curBarIndex, curBarOverlapIndex = 1, 1, 1 --overlapBarIndex 1 means we havent filled the bar up with absorbs, 2 means we are now overlaying absorbs over the healthbar
    local variousAbsorbAmount = 0  -- some absorbs are too small to display, so we group them together and display them if they reach a certain amount
    local absorbSegments = {}
    local incomingHeal = UnitGetIncomingHeals(unit)
    local healAbsorb = UnitGetTotalHealAbsorbs(unit)
    local sortedAbsorbAuras, incomingHealWidth, variousFrameWidth, healAbsorbWidth

    local function NewAbsorbSegment(amount, width, sType, oIndex, tAura)
        return {
            ["amount"] = amount,
            ["width"] = width,
            ["tAura"] = tAura,
            ["sType"] = sType,
            ["oIndex"] = oIndex
        }
    end
    local function SortAbsorbBySpellIDDesc(absorbAuraTable)
        local t = {}
        for k, _ in pairs(absorbAuraTable) do
            if absorbAuraTable[k].auraType == "absorb" then
                t[#t + 1] = absorbAuraTable[k]
            end
        end
        table.sort(t, function(a, b) return b.spellId < a.spellId end)
        return t
    end
    local function CalcSegment(amount, sType, tAura)
        local absorbAmount = amount
        local allowedWidth, overlapAmount, barWidth
        if absorbAmount == nil then
            local errorMsg = "Aura " .. tAura.name .. " with ID " .. tAura.index .. " does not have an absorb amount. Make sure that it is the spellID of the actual buff, not of the spell that casts the buff."
            srslylawlUI.Log(errorMsg)
            return
        end
        while absorbAmount > 0 do
            overlapAmount = 0
            barWidth = pixelPerHp * absorbAmount
            allowedWidth = srslylawlUI.settings.party.hp.width * overlapBarIndex
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
            currentBar.texture:SetTexture(srslylawlUI.textures.AbsorbFrame)
            currentBar.texture:SetVertexColor(1, 1, 1, 0.9)
            currentBar.wasHealthPrediction = false
        end
        currentBar:SetAttribute("buffIndex", tAura.index)
        currentBar.icon:SetTexture(iconID)
        currentBar:Show()
    end
    local function DisplayFrames(absorbSegments)
        local segment, bar, pool, i, shouldMerge
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
                bar.texture:SetTexture(srslylawlUI.textures.HealthBar, ARTWORK)
                bar.texture:SetVertexColor(.2, .9, .1, .9)
                bar.wasHealthPrediction = true
                srslylawlUI.Frame_ChangeAbsorbSegment(bar, segment.width, segment.amount, height, true)
                bar:Show()
            elseif segment.sType == "healAbsorb" then
                bar.texture:SetTexture(srslylawlUI.textures.HealthBar, ARTWORK)
                bar.texture:SetVertexColor(.43, .01, .98, .9)
                bar.wasHealthPrediction = true
                srslylawlUI.Frame_ChangeAbsorbSegment(bar, segment.width, segment.amount, srslylawlUI.settings.party.hp.height, true)
                bar:Show()
            elseif segment.sType == "various" then
                if bar.wasHealthPrediction then
                    bar.texture:SetTexture(srslylawlUI.textures.AbsorbFrame)
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
    sortedAbsorbAuras = SortAbsorbBySpellIDDesc(trackedAurasByIndex)
    if healAbsorb > 0 then
        healAbsorbWidth = floor(healAbsorb * pixelPerHp)
        if healAbsorbWidth > 2 then
            CalcSegment(healAbsorb, "healAbsorb", nil)
        end
    end
    if incomingHeal ~= nil then
        incomingHealWidth = floor(incomingHeal * pixelPerHp)
        if incomingHealWidth > 2 then
            CalcSegment(incomingHeal, "incomingHeal", nil)
        end
    end
    -- absorb auras seem to get consumed in order by their spellid, ascending (confirmed false)
    -- so we sort by descending to visualize which one gets removed first
    for _, value in ipairs(sortedAbsorbAuras) do
        CalcSegment(value.absorb, "aura", value)
    end
    variousFrameWidth = floor(variousAbsorbAmount * pixelPerHp)
    if variousFrameWidth >= 2 then
        CalcSegment(variousAbsorbAmount, "various", nil)
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
function srslylawlUI.Auras_HandleEffectiveHealth(trackedAurasByIndex, unit)
    local function FilterDefensives(trackedAuras)
        local sortedTable = {}
        for index, aura in pairs(trackedAuras) do
            if aura.auraType == "defensive" then
                table.insert(sortedTable, aura)
            end
        end

        table.sort(sortedTable, function(a, b)
            -- spells that expire first are last in the list
            if a.expiration > b.expiration then return true end
        end)

        return sortedTable
    end
    --Display effective health

    units[unit].effectiveHealthSegments = FilterDefensives(trackedAurasByIndex)
    local effectiveHealthMod = 1
    if #units[unit].effectiveHealthSegments > 0 then
        local stackMultiplier = 1
        local reducAmount
        for _, v in ipairs(units[unit].effectiveHealthSegments) do
            stackMultiplier = v.stacks > 1 and v.stacks or 1
            reducAmount = srslylawlUI.buffs.known[v.spellId].reductionAmount / 100
    
            effectiveHealthMod = effectiveHealthMod * (1 - (reducAmount * stackMultiplier))
        end
    end
    if effectiveHealthMod ~= 1 then
        assert(#units[unit].effectiveHealthSegments > 0)
        local width = srslylawlUI.Utils_GetPhysicalPixelSize(srslylawlUI.Frame_GetByUnitType(unit).unit.healthBar:GetWidth()) --need to convert here since we will later reapply the pixel scaling
        local playerHealthMax = UnitHealthMax(unit)
        local playerCurrentHP = UnitHealth(unit)
        local pixelPerHp = width / playerHealthMax
        local playerMissingHP = playerHealthMax - playerCurrentHP
        local eHealth, barWidth
        local maxWidth = playerMissingHP*pixelPerHp - 1

        if effectiveHealthMod > 0 then
            eHealth = playerCurrentHP / effectiveHealthMod
            local additionalHealth = eHealth - playerCurrentHP
            barWidth = additionalHealth * pixelPerHp
            barWidth = barWidth < maxWidth and barWidth or maxWidth
        else
            eHealth = 0
            barWidth = maxWidth > 0 and maxWidth or 1
            --this means a 100% absorb has been used, target is immune
        end
        srslylawlUI.Frame_ChangeAbsorbSegment(units[unit]["effectiveHealthFrames"][1], barWidth, eHealth, srslylawlUI.settings.party.hp.height)
        units[unit]["effectiveHealthFrames"][1]:Show()
    else
        units[unit]["effectiveHealthFrames"][1]:Hide()
    end
end
--Config
function srslylawlUI.ToggleConfigVisible(visible)
    if visible then
        if not srslylawlUI_ConfigFrame then
            srslylawlUI.CreateConfigWindow()
        end
        srslylawlUI_ConfigFrame:Show()
    else
        srslylawlUI_ConfigFrame:Hide()
    end
end
function srslylawlUI.LoadSettings(reset, announce)
    if announce then srslylawlUI.Log("Settings Loaded") end
    if srslylawl_saved.settings.party ~= nil then
        srslylawlUI.settings.party = srslylawlUI.Utils_TableDeepCopy(srslylawl_saved.settings.party)
    end
    --buffs
    if srslylawl_saved.buffs == nil then
        srslylawl_saved.buffs = srslylawlUI.buffs
    else
        srslylawlUI.buffs = srslylawlUI.Utils_TableDeepCopy(srslylawl_saved.buffs)
    end
    --debuffs
    if srslylawl_saved.debuffs == nil then
        srslylawl_saved.debuffs = srslylawlUI.debuffs
    else
        srslylawlUI.debuffs = srslylawlUI.Utils_TableDeepCopy(srslylawl_saved.debuffs)
    end

    local c = srslylawlUI_ConfigFrame
    if c then
        local s = srslylawlUI.settings.party
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
    srslylawlUI_PartyHeader:SetPoint(srslylawlUI.settings.party.header.anchor,
                                     srslylawlUI.settings.party.header.xOffset,
                                     srslylawlUI.settings.party.header.yOffset)
    srslylawlUI.SetBuffFrames()
    srslylawlUI.Frame_UpdateVisibility()
    srslylawlUI.RemoveDirtyFlag()
    if (reset) then srslylawlUI.UpdateEverything() end
end
function srslylawlUI.SaveSettings()
    srslylawlUI.Log("Settings Saved")
    srslylawl_saved.settings.party = srslylawlUI.Utils_TableDeepCopy(srslylawlUI.settings.party)
    srslylawl_saved.buffs = srslylawlUI.Utils_TableDeepCopy(srslylawlUI.buffs)
    srslylawl_saved.debuffs = srslylawlUI.Utils_TableDeepCopy(srslylawlUI.debuffs)

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
    background:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
    background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
    background.texture = t
    background:Show()
    background:SetFrameStrata("BACKGROUND")
    background:SetFrameLevel(1)
    frame.bg = background
end
function srslylawlUI.SetDirtyFlag()
    if srslylawlUI.unsaved.flag == true then return end
    srslylawlUI.unsaved.flag = true
    for _, v in ipairs(srslylawlUI.unsaved.buttons) do v:Enable() end
end
function srslylawlUI.RemoveDirtyFlag()
    srslylawlUI.unsaved.flag = false
    for _, v in ipairs(srslylawlUI.unsaved.buttons) do v:Disable() end
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
        for _, unit in pairs(unitTable) do
            local frameName = "srslylawlUI_"..unit.."Aura"
            for i = 1, srslylawlUI.settings.party.buffs.maxBuffs do
                local xOffset, yOffset = srslylawlUI.GetBuffOffsets()
                local parent = _G[frameName .. (i - 1)]
                local anchor = srslylawlUI.settings.party.buffs.growthDir
                if (i == 1) then
                    parent = srslylawlUI.AuraHolderFrame
                    anchor = srslylawlUI.settings.party.buffs.anchor
                    xOffset = srslylawlUI.settings.party.buffs.xOffset
                    yOffset = srslylawlUI.settings.party.buffs.yOffset
                end
                local f = CreateFrame("Button", frameName .. i, parent, "CompactBuffTemplate")
                f:SetPoint(anchor, xOffset, yOffset)
                f:SetAttribute("unit", unit)
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
                --shift-Right click blacklists spell
                f:SetScript("OnClick", function(self, button, down)
                    if button == "RightButton" and IsShiftKeyDown() then
                        GameTooltip:SetOwner(f, "ANCHOR_RIGHT", 0, 0)
                        local id = self:GetID()
                        local spellID = select(10, UnitAura(self:GetAttribute("unit"), id, "HELPFUL"))
                        srslylawlUI.Auras_BlacklistSpell(spellID, "buffs")
                        srslylawlUI_Frame_HandleAuras_ALL()
                    end
                end)
                units[unit].buffFrames[i] = f
            end
        end
    end
    local function CreateDebuffFrames()
        for _, unit in pairs(unitTable) do
            local frameName = "srslylawlUI_"..unit.."Debuff"

            for i = 1, srslylawlUI.settings.party.debuffs.maxDebuffs do
                local xOffset, yOffset = srslylawlUI.GetDebuffOffsets()
                local parent = _G[frameName .. (i - 1)]
                local anchor = srslylawlUI.settings.party.debuffs.growthDir
                if (i == 1) then
                    parent = srslylawlUI.AuraHolderFrame
                    anchor = srslylawlUI.settings.party.debuffs.anchor
                    xOffset = srslylawlUI.settings.party.debuffs.xOffset
                    yOffset = srslylawlUI.settings.party.debuffs.yOffset
                end
                local f = CreateFrame("Button", frameName .. i, parent, "CompactDebuffTemplate")
                f:SetPoint(anchor, xOffset, yOffset)
                f:SetAttribute("unit", unit)
                f:SetScript("OnLoad", nil)
                f:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(f, "ANCHOR_RIGHT", 0, 0)
                    GameTooltip:SetUnitDebuff(self:GetAttribute("unit"), self:GetID())
                end)
                f:SetScript("OnClick", function(self, button, down)
                    if button == "RightButton" and IsShiftKeyDown() then
                        GameTooltip:SetOwner(f, "ANCHOR_RIGHT", 0, 0)
                        local id = self:GetID()
                        local spellID = select(10, UnitAura(self:GetAttribute("unit"), id, "HARMFUL"))
                        srslylawlUI.Auras_BlacklistSpell(spellID, "debuffs")
                        srslylawlUI_Frame_HandleAuras_ALL()
                    end
                end)
                f:SetScript("OnUpdate", function(self)
                    if GameTooltip:IsOwned(f) then
                        GameTooltip:SetUnitDebuff(self:GetAttribute("unit"),self:GetID())
                    end
                end)
                units[unit].debuffFrames[i] = f
            end
        end
    end
    local function CreateCustomFrames(buttonFrame, unit)
        local function CreateAbsorbFrame(parent, i, parentTable, unit)
            local isOverlapFrame = parentTable == units[unit].absorbFramesOverlap
            local n = "srslylawlUI_"..unit .. (isOverlapFrame and "AbsorbFrameOverlap" or "AbsorbFrame") .. i
            local f = CreateFrame("Frame", n, parent)
            f.texture = f:CreateTexture("$parent_texture", "ARTWORK")
            f.texture:SetAllPoints()
            f.texture:SetTexture(srslylawlUI.textures.AbsorbFrame)
            if isOverlapFrame then
                f:SetPoint("TOPRIGHT", parent, "TOPLEFT", -1, 0)
            else
                f:SetPoint("TOPLEFT", parent, "TOPRIGHT", 1, 0)
            end
            f:SetFrameLevel(5)
            f.background = CreateFrame("Frame", "$parent_background", f)
            f.background.texture = f.background:CreateTexture("$parent_texture", "BACKGROUND")
            f.background.texture:SetColorTexture(0, 0, 0, .5)
            f.background.texture:SetAllPoints(true)
            f.background.texture:Show()
            f.background:SetPoint("TOPLEFT", f, "TOPLEFT", -1, 0)
            f.background:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, -1)
            f.background:SetFrameLevel(5)
            f:Hide()
            f["icon"] = f:CreateTexture("$parent_icon", "OVERLAY", nil, 2)
            f["icon"]:SetPoint("CENTER")
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

            
            parentTable[i] = f
            parentTable[i].wasHealthPrediction = false
        end
        local function CreateEffectiveHealthFrame(buttonFrame, unit, i)
            local parentFrame = buttonFrame.unit.healthBar
            local n = "srslylawlUI" .. unit .. "EffectiveHealthFrame" .. i
            local f = CreateFrame("Frame", n, parentFrame)
            f:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", 1, 0)
            f:SetHeight(buttonFrame.unit:GetHeight())
            f:SetWidth(40)
            f.background = CreateFrame("Frame", "$parent_background", f)
            f.background.texture = f.background:CreateTexture("$parent_texture", "BACKGROUND")
            f.background.texture:SetColorTexture(0, 0, 0, .5)
            f.background.texture:SetAllPoints(true)
            f.background.texture:Show()
            f.background:SetPoint("TOPLEFT", f, "TOPLEFT", -1, 0)
            f.background:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, -1)
            f.background:SetFrameLevel(3)
            f["icon"] = f:CreateTexture("$parent_icon", "OVERLAY", nil, 2)
            f["icon"]:SetPoint("CENTER")
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
            f.texture:SetTexture(srslylawlUI.textures.HealthBar, true, "MIRROR")
            f.texture.bg = f:CreateTexture(nil, "BACKGROUND")
            f.texture.bg:SetTexture(srslylawlUI.textures.EffectiveHealth, true, "MIRROR")
            f.texture.bg:SetVertTile(true)
            f.texture.bg:SetHorizTile(true)
            f.texture.bg:SetAllPoints()
            
            local class = UnitClassBase(unit)
            local color = {GetClassColor(class)}
            color[4] = 0.7
            f.texture:SetVertexColor(unpack(color))
            f.texture.bg:SetVertexColor(1, 1, 1, 1)
            f.texture.bg:SetBlendMode("MOD")
            f:Hide()

            f:SetFrameLevel(5)

            units[unit]["effectiveHealthFrames"][i] = f
        end
        -- buttonFrame = srslylawlUI.Frame_GetByUnitType(unit)
        --create absorb frames
        for i = 1, srslylawlUI.settings.party.maxAbsorbFrames do
            local parentFrame = (i == 1 and buttonFrame.unit.healthBar) or units[unit].absorbFrames[i - 1]
            CreateAbsorbFrame(parentFrame, i, units[unit].absorbFrames, unit)
        end
        --overlap frames (absorb/incoming heal that exceeds maximum health)
        for i = 1, srslylawlUI.settings.party.maxAbsorbFrames do
            local parentFrame = (i == 1 and buttonFrame.unit.healthBar) or units[unit].absorbFramesOverlap[i - 1]
            CreateAbsorbFrame(parentFrame, i, units[unit].absorbFramesOverlap, unit)
        end
        --effective health frame (sums up active defensive spells)
        CreateEffectiveHealthFrame(buttonFrame, unit, 1)
    end
    local function FrameSetup()
        local function CreateCCBar(unitFrame, unit)
            local CCDurationBar = CreateFrame("StatusBar", "$parent_CCDurBar"..unit, unitFrame.unit.auraAnchor)
            unitFrame.unit.CCDurBar = CCDurationBar
            CCDurationBar:SetStatusBarTexture(srslylawlUI.textures.HealthBar)
            local h = srslylawlUI.settings.party.hp.height/2
            local w = 100
            local petW = srslylawlUI.settings.party.pet.width + 2
            local iconSize = (w > h and h) or w
            srslylawlUI.Utils_SetSizePixelPerfect(CCDurationBar, w, h)
            CCDurationBar:SetMinMaxValues(0, 1)
            --CCDurationBar:SetPoint("BOTTOMLEFT", unitFrame.unit.auraAnchor, "BOTTOMRIGHT", 17, 0)
            unitFrame.unit.CCDurBar.icon = unitFrame.unit.CCDurBar:CreateTexture("icon", "OVERLAY", nil, 2)
            --unitFrame.unit.CCDurBar.icon:SetPoint("LEFT", CCDurationBar, "RIGHT")
            unitFrame.unit.CCDurBar.icon:SetPoint("BOTTOMLEFT", unitFrame.unit, "BOTTOMRIGHT", petW+4, 0)
            CCDurationBar:SetPoint("LEFT", unitFrame.unit.CCDurBar.icon, "RIGHT", 1, 0)
            srslylawlUI.Utils_SetSizePixelPerfect(unitFrame.unit.CCDurBar.icon, iconSize, iconSize)
            unitFrame.unit.CCDurBar.icon:SetTexCoord(.08, .92, .08, .92)
            unitFrame.unit.CCDurBar.icon:SetTexture(408)
            unitFrame.unit.CCDurBar.timer = unitFrame.unit.CCDurBar:CreateFontString("$parent_Timer", "OVERLAY", "GameFontHIGHLIGHT")
            unitFrame.unit.CCDurBar.timer:SetText("5")
            unitFrame.unit.CCDurBar.timer:SetPoint("LEFT")
            Mixin(CCDurationBar, BackdropTemplateMixin)
            CCDurationBar:SetBackdrop({
                bgFile = "Interface/Tooltips/UI-Tooltip-Background"
                -- edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                -- edgeSize = 10,
                -- insets = {left = 4, right = 4, top = 4, bottom = 4}
            })
            CCDurationBar:SetBackdropColor(0, 0, 0, .4)
        end
        local function CreateUnitFrame(header, unit, faux)
            local unitFrame = CreateFrame("Frame", "$parent_"..unit, header, "srslylawlUI_UnitTemplate")
            header[unit] = unitFrame
            unitFrame:SetAttribute("unit", unit)
            unitFrame.unit.CCTexture = unitFrame:CreateTexture("$parent_CCTexture", "OVERLAY")
            unitFrame.unit.CCTexture:SetTexture(srslylawlUI.textures.CCHighlight, true, true)
            unitFrame.unit.CCTexture:SetBlendMode("ADD")
            unitFrame.unit.CCTexture:SetAllPoints(true)
            unitFrame.unit.CCTexture:Show()

            CreateCCBar(unitFrame, unit)

            return unitFrame
        end
        local header = CreateFrame("Frame", "srslylawlUI_PartyHeader", UIParent)
        header:SetSize(srslylawlUI.settings.party.hp.width, srslylawlUI.settings.party.hp.height)
        header:SetPoint(srslylawlUI.settings.party.header.anchor, srslylawlUI.settings.party.header.xOffset, srslylawlUI.settings.party.header.yOffset)
        header:Show()
        --Create Unit Frames
        local fauxHeader = CreateFrame("Frame", "srslylawlUI_FAUX_PartyHeader", header)
        fauxHeader:SetAllPoints(true)
        fauxHeader:Hide()
        local parent = header
        for _, unit in pairs(unitTable) do
            units[unit] = {
                absorbAuras = {},
                absorbFrames = {},
                absorbFramesOverlap = {},
                buffFrames = {},
                debuffFrames = {},
                defensiveAuras = {},
                effectiveHealthFrames = {},
                effectiveHealthSegments = {},
                trackedAurasByIndex = {},
                parentName = "srslylawlUI_AuraHolderFrame"
            }

            local frame = CreateUnitFrame(header, unit)
            local faux = CreateUnitFrame(fauxHeader, unit, true)
            CreateCustomFrames(frame, unit)
            -- CreateCustomFrames(faux, unit)

            --initial sorting
            if unit == "player" then
                frame:SetPoint("TOPLEFT", header, "TOPLEFT")
            else
                frame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT")
            end

            srslylawlUI.Frame_InitialUnitConfig(frame, false)
            srslylawlUI.Frame_InitialUnitConfig(faux, true)

            parent = frame
        end

        srslylawlUI.Frame_UpdateVisibility()
    end

    srslylawlUI.LoadSettings()
    FrameSetup()
    CreateSlashCommands()
    CreateBuffFrames()
    CreateDebuffFrames()
end

srslylawlUI_EventFrame = CreateFrame("Frame")
srslylawlUI_EventFrame:RegisterEvent("PLAYER_LOGIN")
srslylawlUI_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
srslylawlUI_EventFrame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if (event == "PLAYER_LOGIN") then
        Initialize()
        srslylawlUI.SortAfterLogin()
        self:UnregisterEvent("PLAYER_LOGIN")
    elseif event == "UNIT_MAXHEALTH" or event == "GROUP_ROSTER_UPDATE" then
        -- delay since it bugs if it happens at the same frame for some reason
        if event == "UNIT_MAXHEALTH" and not (arg1 == "player" or arg1 == "party1" or arg1 == "party2" or arg1 == "party3" or arg1 == "party4") then
            --this event fires for all nameplates etc, but we only care about our party members
            return
        end
        C_Timer.After(.1, function()
            srslylawlUI.SortPartyFrames()
            srslylawlUI.Frame_ResizeHealthBarScale()
        end)

        if event == "GROUP_ROSTER_UPDATE" then
            srslylawlUI.Frame_UpdateVisibility()
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if not (arg1 or arg2) then
            -- just zoning between maps
        elseif arg1 then
            -- srslylawlUI.SortAfterLogin()
            -- since it takes a while for everything to load, we just wait until all our frames are visible before we do anything else
            srslylawlUI.SortPartyFrames()
        elseif arg2 then
            -- reload ui
            srslylawlUI.Frame_ResizeHealthBarScale()
            srslylawlUI.SortPartyFrames()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- regen enabled sort
        srslylawlUI.UpdateEverything()
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end)
-- since events seem to fire in arbitrary order after login, we use this frame for the first time the maxhealth event fires
srslylawlUI_FirstMaxHealthEventFrame = CreateFrame("Frame")
srslylawlUI_FirstMaxHealthEventFrame:RegisterEvent("UNIT_MAXHEALTH")
srslylawlUI_FirstMaxHealthEventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_MAXHEALTH" then
        srslylawlUI.SortAfterLogin()
        self:UnregisterEvent("UNIT_MAXHEALTH")
    end
end)
