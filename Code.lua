local settings = {
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
local units = {}
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
    print("Settings Loaded")
    settings = deepcopy(srslylawl_saved.settings)
    if srslylawlUI_ConfigFrame then
        srslylawlUI_ConfigFrame.sliders.height:SetValue(settings.hp.height)
        srslylawlUI_ConfigFrame.sliders.hpwidth:SetValue(settings.hp.width)
    end
    srslylawlUI_RemoveDirtyFlag()
    if (reset) then
        srslylawlUI_Frame_Reset_All()
    end
end
local function SaveSettings()
    print("Settings Saved")
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
    buttonFrame.unit.name:SetPoint("BOTTOM", buttonFrame.unit, "TOP", 0, 0)
    buttonFrame.unit.healthBar.text:SetPoint("BOTTOMRIGHT", 0, 2)
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
    srslylawlUI_PartyHeader:StartMoving()
    srslylawlUI_PartyHeader.isMoving = true
end
function srslylawlUI_Button_OnDragStop(self, button)
    if srslylawlUI_PartyHeader.isMoving then
        srslylawlUI_PartyHeader:StopMovingOrSizing()
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
            print(UnitName(unit) .. " went on/offline")
        elseif event == "UNIT_AURA" then
            srslylawlUI_Frame_HandleAuras(self.unit, unit)
        elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            srslylawlUI_Frame_HandleAuras(self.unit, unit)
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
local function srslylawlUI_RememberSpellID(id)
    if settings.spellList[id] then
        return
    end

    local n = GetSpellInfo(id)
    local t = GetSpellDescription(id)
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
        print("srslylawlUI: spell auto-approved " .. n .. "!")
    else
        settings.pendingSpells[id] = {
            name = n,
            text = t,
            hasAbsorbKeyWord = keyWordAbsorb
        }
        print("srslylawlUI: new spell: " .. n .. "!")
    end

    srslylawl_saved.settings.spellList = deepcopy(settings.spellList)
    srslylawl_saved.settings.pendingSpells = deepcopy(settings.pendingSpells)
end
local function srslylawlUI_ApproveSpellID(id)
    if settings.spellList[id] then
        return
    end
    print("srslylawlUI: spell approved: " .. id .. "!")
    settings.approvedSpells[id] = {
        name = GetSpellInfo(id)
    }
    table.remove(settings.pendingSpells, id)
    srslylawl_saved.settings.spellList = deepcopy(settings.spellList)
    srslylawl_saved.settings.pendingSpells = deepcopy(settings.pendingSpells)
end
function srslylawlUI_Frame_HandleAuras(unitbutton, unit)
    -- Buffs --
    ---create frames for this unittype
    if units[unit] == nil then
        unitbutton.buffFrames = {}
        units[unit] = {}
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
            units[unit][unit .. "_" .. i] = f
            unitbutton.buffFrames[i] = f
        end
    elseif unitbutton["buffFrames"] == nil then --frames exist but this unit doesnt own them yet
        print("exist, reassigning")
        unitbutton.buffFrames = {}
        unitbutton.buffFrames = units[unit]
        unitbutton.buffFrames[1]:SetParent(unitbutton)
    end
    --frames exist and unit owns them
    for i = 1, 40 do
        local f = unitbutton.buffFrames[i]
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
            args = UnitAura(unit, i, "HELPFUL")
        if name then
            f:Show()
            local f = unitbutton.buffFrames[i]
            CompactUnitFrame_UtilSetBuff(f, i, UnitAura(unit, i, "HELPFUL"))
            f:SetID(i)
            srslylawlUI_RememberSpellID(spellId)
        else
            f:Hide()
        end
    end
end
local function HeaderSetup()
    local header = srslylawlUI_PartyHeader
    header:SetAttribute("initialConfigFunction", configString)
    header.initialConfigFunction = srslylawlUI_InitialConfig
    header:Show()
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
    cFrame:Hide()
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
            srslylawlUI_ConfigFrame:Show()
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
            print(addon)
        end
    end
)
