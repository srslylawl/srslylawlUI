function srslylawlUI.CreateBuffFrames(buttonFrame, unit)
    local frameName = "srslylawlUI_"..unit.."Aura"
    local unitsType = buttonFrame:GetAttribute("unitsType")
    local maxBuffs = srslylawlUI.GetSettingByUnit("buffs.maxBuffs", unitsType, unit)
    if unitsType == "fauxUnits" or unitsType == "mainFauxUnits" then maxBuffs = 40 end
    local size = srslylawlUI.GetSettingByUnit("buffs.size", unitsType, unit)
    local texture = size >= 64 and srslylawlUI.textures.AuraBorder64 or srslylawlUI.textures.AuraBorder32
    local swipeTexture = size >= 64 and srslylawlUI.textures.AuraSwipe64 or srslylawlUI.textures.AuraSwipe32
    for i = 1, maxBuffs do
        if not srslylawlUI[unitsType][unit].buffFrames[i] then --so we can call this function multiple times
            local f = CreateFrame("Button", frameName .. i, buttonFrame.unit, "CompactBuffTemplate")
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
            local id = self:GetID()
            local unit = self:GetAttribute("unit")
            if button == "RightButton" and IsShiftKeyDown() then
                GameTooltip:SetOwner(f, "ANCHOR_RIGHT", 0, 0)
                local spellID = select(10, UnitAura(unit, id, "HELPFUL"))
                srslylawlUI.Auras_BlacklistSpell(spellID, "buffs")
                srslylawlUI.Party_HandleAuras_ALL()
            elseif button == "RightButton" and unit == "player" and not InCombatLockdown() then
                CancelUnitBuff(unit, id, "HELPFUL")
            end
            end)
            --template creates a border thats not pixel perfect (yikes)
            f.border = f:CreateTexture("$parent_Border", "OVERLAY")
            f.border:SetTexture(texture)
            f.border:SetTexCoord(0, 1, 0, 1);
            srslylawlUI.Utils_SetPointPixelPerfect(f.border, "TOPLEFT", f, "TOPLEFT", -1, 1)
            srslylawlUI.Utils_SetPointPixelPerfect(f.border, "BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, -1)
            f.cooldown:ClearAllPoints()
            srslylawlUI.Utils_SetPointPixelPerfect(f.cooldown, "TOPLEFT", f, "TOPLEFT", -1, 1)
            srslylawlUI.Utils_SetPointPixelPerfect(f.cooldown, "BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, -1)
            f.cooldown:SetSwipeTexture(swipeTexture)
            f.count:SetFont("Fonts\\FRIZQT__.TTF", srslylawlUI.Utils_PixelFromCodeToScreen(size/2), "OUTLINE")
            f.count:SetPoint("BOTTOMRIGHT")
            srslylawlUI[unitsType][unit].buffFrames[i] = f
            f:Hide()
        end
    end
    for i=maxBuffs, 40 do
        if srslylawlUI[unitsType][unit].buffFrames[i] then
                srslylawlUI[unitsType][unit].buffFrames[i]:Hide()
        end
    end
end
function srslylawlUI.CreateDebuffFrames(buttonFrame, unit)
    local frameName = "srslylawlUI_"..unit.."Debuff"
    local unitsType = buttonFrame:GetAttribute("unitsType")
    local maxBuffs = srslylawlUI.GetSettingByUnit("debuffs.maxDebuffs", unitsType, unit)
    if unitsType == "fauxUnits" or unitsType == "mainFauxUnits" then maxBuffs = 40 end
    local size = srslylawlUI.GetSettingByUnit("debuffs.maxDebuffs", unitsType, unit)
    local texture = size >= 64 and srslylawlUI.textures.AuraBorder64 or srslylawlUI.textures.AuraBorder32
    local swipeTexture = size >= 64 and srslylawlUI.textures.AuraSwipe64 or srslylawlUI.textures.AuraSwipe32
    for i = 1, maxBuffs do
        if not srslylawlUI[unitsType][unit].debuffFrames[i] then
            local f = CreateFrame("Button", frameName .. i, buttonFrame.unit, "CompactDebuffTemplate")
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
                srslylawlUI.Party_HandleAuras_ALL()
            end
            end)
            f:SetScript("OnUpdate", function(self)
            if GameTooltip:IsOwned(f) then
                GameTooltip:SetUnitDebuff(self:GetAttribute("unit"),self:GetID())
            end
            end)

            --template creates a border thats not pixel perfect (yikes)
            f.border:ClearAllPoints()
            f.border:SetTexture(texture)
            f.border:SetTexCoord(0, 1, 0, 1);
            srslylawlUI.Utils_SetPointPixelPerfect(f.border, "TOPLEFT", f, "TOPLEFT", -1, 1)
            srslylawlUI.Utils_SetPointPixelPerfect(f.border, "BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, -1)
            f.cooldown:ClearAllPoints()
            srslylawlUI.Utils_SetPointPixelPerfect(f.cooldown, "TOPLEFT", f, "TOPLEFT", -1, 1)
            srslylawlUI.Utils_SetPointPixelPerfect(f.cooldown, "BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, -1)
            f.cooldown:SetSwipeTexture(swipeTexture)
            f.count:SetFont("Fonts\\FRIZQT__.TTF", srslylawlUI.Utils_PixelFromCodeToScreen(size/2), "OUTLINE")
            f.count:SetPoint("BOTTOMRIGHT")

            srslylawlUI[unitsType][unit].debuffFrames[i] = f
            f:Hide()
        end
    end
    for i=maxBuffs, 40 do
        if srslylawlUI[unitsType][unit].debuffFrames[i] then
            srslylawlUI[unitsType][unit].debuffFrames[i]:Hide()
        end
    end
end
local function CreateCustomFrames(buttonFrame, unit)
    local unitsType = buttonFrame:GetAttribute("unitsType")
    local function CreateAbsorbFrame(parent, i, parentTable, unit)
        local isOverlapFrame = parentTable == srslylawlUI[unitsType][unit].absorbFramesOverlap
        local n = "srslylawlUI_"..unit .. (isOverlapFrame and "AbsorbFrameOverlap" or "AbsorbFrame") .. i
        local f = CreateFrame("Frame", n, parent)
        f.texture = f:CreateTexture("$parent_texture", "ARTWORK")
        f.texture:SetAllPoints()
        f.texture:SetTexture(srslylawlUI.textures.AbsorbFrame)
        if isOverlapFrame then
            srslylawlUI.Utils_SetPointPixelPerfect(f, "TOPRIGHT", parent, "TOPLEFT", -1, 0)
        else
            srslylawlUI.Utils_SetPointPixelPerfect(f, "TOPLEFT", parent, "TOPRIGHT", 1, 0)
        end
        f:SetFrameLevel(5)
        -- srslylawlUI.CreateBackground(f)
        f.background = CreateFrame("Frame", "$parent_background", f)
        f.background.texture = f.background:CreateTexture("$parent_texture", "BACKGROUND")
        f.background.texture:SetColorTexture(0, 0, 0, .5)
        f.background.texture:SetAllPoints(true)
        f.background.texture:Show()
        srslylawlUI.Utils_SetPointPixelPerfect(f.background, "TOPLEFT", f, "TOPLEFT", -1, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(f.background, "BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, -1)
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
        srslylawlUI.Utils_SetPointPixelPerfect(f, "TOPLEFT", parentFrame, "TOPRIGHT", 1, 0)
        f:SetHeight(buttonFrame.unit:GetHeight())
        f:SetWidth(40)
        f.background = CreateFrame("Frame", "$parent_background", f)
        f.background.texture = f.background:CreateTexture("$parent_texture", "BACKGROUND")
        f.background.texture:SetColorTexture(0, 0, 0, .1)
        f.background.texture:SetAllPoints(true)
        f.background.texture:Show()
        srslylawlUI.Utils_SetPointPixelPerfect(f.background, "TOPLEFT", f, "TOPLEFT", -1, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(f.background, "BOTTOMRIGHT", f, "BOTTOMRIGHT", 1, -1)
        f.background:SetFrameLevel(3)
        f.icon = f:CreateTexture("$parent_icon", "OVERLAY", nil, 2)
        f.icon:SetPoint("CENTER")
        f.icon:SetTexCoord(.08, .92, .08, .92)
        f.icon:Hide()
        f.cooldown = CreateFrame("Cooldown", n .. "CD", f, "CooldownFrameTemplate")
        f.cooldown:SetReverse(true)
        f.cooldown:Show()
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
        -- srslylawlUI.CreateBackground(f)
        f.texture.bg = f:CreateTexture(nil, "ARTWORK")
        f.texture.bg:SetTexture(srslylawlUI.textures.EffectiveHealth, true, "MIRROR")
        f.texture.bg:SetVertTile(true)
        f.texture.bg:SetHorizTile(true)
        f.texture.bg:SetAllPoints()
        f.texture.bg:SetVertexColor(1, 1, 1, .5)
        f.texture.bg:SetBlendMode("MOD")
        
        
        local class = UnitClassBase(unit)
        local color = {GetClassColor(class)}
        color[4] = 0.7
        f.texture:SetVertexColor(unpack(color))
        f:Hide()
        f:SetFrameLevel(5)
        buttonFrame.unit.healthBar.effectiveHealthFrame = f
        srslylawlUI[unitsType][unit]["effectiveHealthFrames"][i] = f
        f.offset = 0
    end
    --create absorb frames
    for i = 1, srslylawlUI.GetSetting("party.maxAbsorbFrames") do
        local parentFrame = (i == 1 and buttonFrame.unit.healthBar) or srslylawlUI[unitsType][unit].absorbFrames[i - 1]
        CreateAbsorbFrame(parentFrame, i, srslylawlUI[unitsType][unit].absorbFrames, unit)
    end
    --overlap frames (absorb/incoming heal that exceeds maximum health)
    for i = 1, srslylawlUI.GetSetting("party.maxAbsorbFrames") do
        local parentFrame = (i == 1 and buttonFrame.unit.healthBar) or srslylawlUI[unitsType][unit].absorbFramesOverlap[i - 1]
        CreateAbsorbFrame(parentFrame, i, srslylawlUI[unitsType][unit].absorbFramesOverlap, unit)
    end
    --effective health frame (sums up active defensive spells)
    CreateEffectiveHealthFrame(buttonFrame, unit, 1)
end
function srslylawlUI.CreateCustomFontString(frame, name, fontSize)
    local fString = frame:CreateFontString("$parent"..name, "ARTWORK", "GameFontHighlight")

    function fString:ChangeFontSize(size)
        if self.fontSize == size then return end
        self:SetFont("Fonts\\FRIZQT__.TTF", srslylawlUI.Utils_PixelFromCodeToScreen(size))
        self.fontSize = size
    end

    fString:ChangeFontSize(fontSize)

    return fString
end

function srslylawlUI.FrameSetup()
    local function CreateCCBar(unitFrame)
        local CCDurationBar = CreateFrame("Frame", "$parent_CCDurationBar", unitFrame.unit)
        CCDurationBar.name = "CCDurationBar"
        unitFrame.unit.CCDurBar = CCDurationBar
        CCDurationBar.statusBar = CreateFrame("StatusBar", "$parent_StatusBar", CCDurationBar)
        CCDurationBar.statusBar:SetStatusBarTexture(srslylawlUI.textures.HealthBar)
        CCDurationBar.statusBar:SetMinMaxValues(0, 1)
        CCDurationBar.icon = CCDurationBar:CreateTexture("icon", "OVERLAY", nil, 2)
        srslylawlUI.Utils_SetPointPixelPerfect(CCDurationBar.icon, "BOTTOMLEFT", CCDurationBar, "BOTTOMLEFT", 0, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(CCDurationBar.statusBar, "BOTTOMLEFT", CCDurationBar.icon, "BOTTOMRIGHT", 1, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(CCDurationBar.statusBar, "TOPRIGHT", CCDurationBar, "TOPRIGHT", 0, 0)
        CCDurationBar.icon:SetTexCoord(.08, .92, .08, .92)
        CCDurationBar.icon:SetTexture(408)
        CCDurationBar.timer = srslylawlUI.CreateCustomFontString(CCDurationBar.statusBar, "Timer", 15)
        CCDurationBar.timer:SetText("0")
        srslylawlUI.Utils_SetPointPixelPerfect(CCDurationBar.timer, "LEFT", CCDurationBar.statusBar, "LEFT", 1, 0)
        srslylawlUI.CreateBackground(CCDurationBar, 0)
        CCDurationBar:Hide()

        function CCDurationBar:SetPoints(w, h)
            if h then
                srslylawlUI.Utils_SetSizePixelPerfect(self, w, h)
                srslylawlUI.Utils_SetSizePixelPerfect(self.icon, h, h)
            else
                srslylawlUI.Utils_SetSizePixelPerfect(self.icon, w, w)
            end
        end

        function CCDurationBar:UpdateVisible()
            local timer = self.timer:GetText()
            local n = tonumber(string.match(timer, "%d"))
            if self.disabled or type(n) ~= "number" or n < 0 then
                self:Hide()
            end
        end
    end
    local function CreateUnitFrame(header, unit, faux, party)
        local name = party and "$parent_"..unit or "srslylawlUI_Main_"..unit
        local unitFrame = CreateFrame("Frame",name, header, "srslylawlUI_UnitTemplate")
        local unitsType = faux and "fauxUnits" or party and "partyUnits" or "mainUnits"
        unitFrame:SetAttribute("unit", unit)
        unitFrame:SetAttribute("unitsType", unitsType)
        unitFrame.unit:SetAttribute("unitsType", unitsType)
        if unit ~= "targettarget" then
            srslylawlUI.CreateBackground(unitFrame.pet, 1, .8)
            unitFrame.ReadyCheck = CreateFrame("Frame", "$parent_ReadyCheck", unitFrame)
            unitFrame.ReadyCheck:SetPoint("CENTER")
            srslylawlUI.Utils_SetSizePixelPerfect(unitFrame.ReadyCheck, 64, 64) --icon is 64x64
            unitFrame.ReadyCheck.texture = unitFrame.ReadyCheck:CreateTexture("$parent_ReadyCheck", "OVERLAY")
            unitFrame.ReadyCheck.texture:SetAllPoints(true)
            unitFrame.ReadyCheck.texture:SetTexture("Interface/RAIDFRAME/ReadyCheck-Waiting")
            unitFrame.ReadyCheck:SetFrameLevel(5)
            unitFrame.ReadyCheck:Hide()
            unitFrame.unit.CombatIcon = CreateFrame("Frame", "$parent_CombatIcon", unitFrame)
            unitFrame.unit.CombatIcon.texture = unitFrame.unit.CombatIcon:CreateTexture("$parent_Icon", "OVERLAY")
            unitFrame.unit.CombatIcon.texture:SetTexture("Interface/CHARACTERFRAME/UI-StateIcon")
            unitFrame.unit.CombatIcon.texture:SetAllPoints(true)
            --set texture to combat icon
            unitFrame.unit.CombatIcon.texture:SetTexCoord(0.5, 1, 0, .5)
            -- unitFrame.unit.CombatIcon.texture:SetTexCoord(0, .5, 0, .5)
            -- unitFrame.CombatIcon.texture:SetTexCoord(0.5, 1, 0, .5)
            srslylawlUI.Utils_SetSizePixelPerfect(unitFrame.unit.CombatIcon, 16, 16)
            srslylawlUI.Utils_SetPointPixelPerfect(unitFrame.unit.CombatIcon, "BOTTOMLEFT", unitFrame.unit, "BOTTOMLEFT", -1, -1)
            unitFrame.unit.CombatIcon:SetFrameLevel(4)
            unitFrame.unit.CombatIcon.texture:Hide()
        end
        srslylawlUI.CreateBackground(unitFrame.unit.healthBar, 1, .8)
        srslylawlUI.CreateBackground(unitFrame.unit.powerBar, 1, .8)

        local height, width = srslylawlUI.GetSettingByUnit("hp.height", unitsType, unit), srslylawlUI.GetSettingByUnit("hp.width", unitsType, unit)

        srslylawlUI.Utils_SetSizePixelPerfect(unitFrame.unit, width, height)
        srslylawlUI.Utils_SetPointPixelPerfect(unitFrame, "TOPLEFT", unitFrame.unit, "TOPLEFT", -1, 1)
        srslylawlUI.Utils_SetPointPixelPerfect(unitFrame, "BOTTOMRIGHT", unitFrame.unit, "BOTTOMRIGHT", 1, -1)

        unitFrame.unit.healthBar:SetPoint("TOPLEFT", unitFrame.unit, "TOPLEFT", 0, 0)

        local fontSize = (party or faux) and srslylawlUI.GetSetting("party.hp.fontSize") or srslylawlUI.GetSetting("player."..unit.."Frame.hp.fontSize")
        unitFrame.unit.healthBar.leftTextFrame = CreateFrame("Frame", "$parent_leftTextFrame", unitFrame.unit.healthBar)
        unitFrame.unit.healthBar.leftText = unitFrame.unit.healthBar.leftTextFrame:CreateFontString("$parent_leftText", "OVERLAY", "GameFontHIGHLIGHT")
        unitFrame.unit.healthBar.leftText:SetFont("Fonts\\FRIZQT__.TTF", srslylawlUI.Utils_PixelFromCodeToScreen(fontSize))

        unitFrame.unit.healthBar.rightTextFrame = CreateFrame("Frame", "$parent_rightTextFrame", unitFrame.unit.healthBar)
        unitFrame.unit.healthBar.rightText = unitFrame.unit.healthBar.rightTextFrame:CreateFontString("$parent_rightText", "OVERLAY", "GameFontHIGHLIGHT")
        unitFrame.unit.healthBar.rightText:SetFont("Fonts\\FRIZQT__.TTF", srslylawlUI.Utils_PixelFromCodeToScreen(fontSize))

        unitFrame.unit.healthBar.leftTextFrame:SetFrameLevel(9)
        unitFrame.unit.healthBar.rightTextFrame:SetFrameLevel(9)
        
        unitFrame.PartyLeader = CreateFrame("Frame", "$parent_PartyLeader", unitFrame)
        unitFrame.PartyLeader:SetPoint("TOPLEFT", unitFrame.unit, "TOPLEFT")
        unitFrame.PartyLeader:SetFrameLevel(5)
        srslylawlUI.Utils_SetSizePixelPerfect(unitFrame.PartyLeader, 16, 16) --icon is 16x16
        unitFrame.PartyLeader.texture = unitFrame.PartyLeader:CreateTexture("$parent_PartyLeader", "OVERLAY")
        unitFrame.PartyLeader.texture:SetTexture("Interface/GROUPFRAME/UI-Group-LeaderIcon")
        unitFrame.PartyLeader.texture:SetAllPoints(true)
        unitFrame.PartyLeader:Hide()
        if party then
            header[unit] = unitFrame
        end
        if unitsType ~= "mainUnits" or unit == "target" then
            CreateCCBar(unitFrame)
        end
        
        return unitFrame
    end
    local header = CreateFrame("Frame", "srslylawlUI_PartyHeader", nil)
    header:SetSize(srslylawlUI.GetSetting("party.hp.width"), srslylawlUI.GetSetting("party.hp.height"))
    header:SetPoint(unpack(srslylawlUI.GetSetting("party.header.position")))
    header:Show()
    --Create Unit Frames
    local fauxHeader = CreateFrame("Frame", "srslylawlUI_FAUX_PartyHeader", header)
    fauxHeader:SetAllPoints(true)
    fauxHeader:Hide()
    local parent = header
    --Initiate party frames
    for _, unit in pairs(srslylawlUI.partyUnitsTable) do
        local frame = CreateUnitFrame(header, unit, false, true)
        srslylawlUI.partyUnits[unit] = {
            absorbAuras = {},
            absorbFrames = {},
            absorbFramesOverlap = {},
            buffFrames = {},
            debuffFrames = {},
            defensiveAuras = {},
            effectiveHealthFrames = {},
            effectiveHealthSegments = {},
            trackedAurasByIndex = {},
            unitFrame = frame
        }
        srslylawlUI.CreateBuffFrames(frame, unit)
        srslylawlUI.CreateDebuffFrames(frame, unit)
        CreateCustomFrames(frame, unit)

        local faux = CreateUnitFrame(fauxHeader, unit, true, true)
        srslylawlUI.fauxUnits[unit] = {
            absorbAuras = {},
            absorbFrames = {},
            absorbFramesOverlap = {},
            buffFrames = {},
            debuffFrames = {},
            defensiveAuras = {},
            effectiveHealthFrames = {},
            effectiveHealthSegments = {},
            trackedAurasByIndex = {},
            unitFrame = faux
        }
        srslylawlUI.CreateBuffFrames(faux, unit)
        srslylawlUI.CreateDebuffFrames(faux, unit)


        --initial sorting
        if unit == "player" then
            frame.unit:SetPoint("TOPLEFT", header, "TOPLEFT")
        else
            frame.unit:SetPoint("TOPLEFT", parent, "BOTTOMLEFT")
        end
        srslylawlUI.Frame_InitialPartyUnitConfig(frame, false)
        srslylawlUI.Frame_InitialPartyUnitConfig(faux, true)
        parent = frame.unit
    end
    --Initiate player, target and targettarget frame
    for _, unit in pairs(srslylawlUI.mainUnitsTable) do
        local frame = CreateUnitFrame(nil, unit, false, false)
        srslylawlUI.mainUnits[unit] = {
            absorbAuras = {},
            absorbFrames = {},
            absorbFramesOverlap = {},
            buffFrames = {},
            debuffFrames = {},
            defensiveAuras = {},
            effectiveHealthFrames = {},
            effectiveHealthSegments = {},
            trackedAurasByIndex = {},
            unitFrame = frame
        }
        if unit ~= "targettarget" then
            srslylawlUI.CreateBuffFrames(frame, unit)
            srslylawlUI.CreateDebuffFrames(frame, unit)
            CreateCustomFrames(frame, unit)
        end
        local a = srslylawlUI.GetSetting("player."..unit.."Frame.position")
        srslylawlUI.Utils_SetPointPixelPerfect(frame.unit, a[1], srslylawlUI.TranslateFrameAnchor(a[2]), a[3], a[4], a[5])

        srslylawlUI.Frame_InitialMainUnitConfig(frame)
    end
    srslylawlUI.Frame_UpdateVisibility()
end

--setup
function srslylawlUI.SetupUnitFrame(buttonFrame, unit)
    buttonFrame.unit:SetFrameLevel(8)
    buttonFrame.pet:SetFrameLevel(4)
    buttonFrame.pet.healthBar:SetFrameLevel(4)
    buttonFrame.unit.healthBar:SetFrameLevel(4)
    buttonFrame.unit.powerBar:SetFrameLevel(4)
    buttonFrame.unit:RegisterForDrag("LeftButton")
    buttonFrame.unit:SetAttribute("unit", buttonFrame:GetAttribute("unit"))
    buttonFrame.pet:SetFrameRef("unit", buttonFrame.unit)
    buttonFrame.unit.powerBar:ClearAllPoints()
    -- if unit == "target" then
    --     srslylawlUI.Utils_SetPointPixelPerfect(buttonFrame.unit.healthBar.leftText,"BOTTOMLEFT", buttonFrame.unit.healthBar, "BOTTOMLEFT", 12, 2)
    -- else
        srslylawlUI.Utils_SetPointPixelPerfect(buttonFrame.unit.healthBar.leftText,"BOTTOMLEFT", buttonFrame.unit.healthBar, "BOTTOMLEFT", 12, 2)
    -- end
    srslylawlUI.Utils_SetPointPixelPerfect(buttonFrame.unit.healthBar.rightText, "BOTTOMRIGHT", buttonFrame.unit.healthBar, "BOTTOMRIGHT", -2, 2)
end
function srslylawlUI.Frame_InitialPartyUnitConfig(buttonFrame, faux)
    srslylawlUI.SetupUnitFrame(buttonFrame)
    local unit = buttonFrame:GetAttribute("unit")

    if not faux then
        srslylawlUI.RegisterEvents(buttonFrame)   
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
                if (self.TimeSinceLastUpdate > 0.1) then
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

    buttonFrame.unit.CombatIcon:SetScript("OnUpdate", srslylawlUI.Frame_UpdateCombatIcon)
    buttonFrame.PartyLeader:SetShown(UnitIsGroupLeader(unit))

    srslylawlUI.Frame_ResetDimensions_Pet(buttonFrame)
    srslylawlUI.Frame_ResetDimensions_PowerBar(buttonFrame)
    srslylawlUI.Frame_ResetDimensions(buttonFrame)
end
function srslylawlUI.Frame_InitialMainUnitConfig(buttonFrame)
    local unit = buttonFrame:GetAttribute("unit")
    srslylawlUI.SetupUnitFrame(buttonFrame, unit)

    srslylawlUI.RegisterEvents(buttonFrame)
    RegisterUnitWatch(buttonFrame)
    buttonFrame:SetMovable(true)
    buttonFrame.unit:RegisterForDrag("LeftButton")
    buttonFrame.unit:EnableMouse(true)
    buttonFrame.unit:SetScript("OnDragStart", srslylawlUI.PlayerFrame_OnDragStart)
    buttonFrame.unit:SetScript("OnDragStop", srslylawlUI.PlayerFrame_OnDragStop)
    buttonFrame.unit:SetScript("OnHide", srslylawlUI.PlayerFrame_OnDragStop)


    if unit == "player" then
        RegisterUnitWatch(buttonFrame.pet)
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
        srslylawlUI.Frame_ResetDimensions_Pet(buttonFrame)
        buttonFrame.unit.powerBar:Hide()
        srslylawlUI.BarHandler_Create(buttonFrame, buttonFrame.unit)

        buttonFrame.CastBar = srslylawlUI.CreateCastBar(buttonFrame, unit)
        buttonFrame:RegisterBar(buttonFrame.CastBar, 0)
        srslylawlUI.PowerBar.Set(buttonFrame, unit)
        local oldSetSize = buttonFrame.SetSize
        buttonFrame.SetSize = function(self, arg1, arg2, arg3, arg4, arg5)
            oldSetSize(self, arg1, arg2)
            -- self:SetSize(arg1, arg2)
            self:SetPoints()
        end
    else
        buttonFrame.pet:Hide()
    end

    if unit == "target" then
        srslylawlUI.Frame_SetupTargetFrame(buttonFrame)
    end

    if unit == "targettarget" then
        buttonFrame.unit.healthBar.rightText:Hide()
    else
        buttonFrame.unit.CombatIcon:SetScript("OnUpdate", srslylawlUI.Frame_UpdateCombatIcon)
    end

    buttonFrame.PartyLeader:SetShown(UnitIsGroupLeader(unit))
    srslylawlUI.Frame_ResetDimensions(buttonFrame)
    if unit ~= "player" then
        srslylawlUI.Frame_ResetDimensions_PowerBar(buttonFrame)
    end
end


function srslylawlUI.Frame_SetupTargetFrame(frame)
    srslylawlUI.BarHandler_Create(frame, frame.unit)
    frame.CastBar = srslylawlUI.CreateCastBar(frame, frame:GetAttribute("unit"))
    frame:RegisterBar(frame.CastBar, 0)
    frame:RegisterBar(frame.unit.CCDurBar)

    frame:RegisterEvent("UNIT_PORTRAIT_UPDATE", "target")
	frame:RegisterEvent("UNIT_MODEL_CHANGED", "target")
    frame:RegisterEvent("UNIT_FACTION", "target")
    local portrait = CreateFrame("PlayerModel", "$parent_Portrait", frame.unit)
    srslylawlUI.Utils_SetPointPixelPerfect(portrait, "TOPLEFT", frame.unit, "TOPRIGHT", 1, 0)
    local height = srslylawlUI.GetSetting("player.targetFrame.hp.height")
    srslylawlUI.Utils_SetPointPixelPerfect(portrait, "BOTTOMRIGHT", frame.unit, "BOTTOMRIGHT", height+1, 0)
    portrait:SetAlpha(1)
    portrait:SetUnit("target")
    portrait:SetPortraitZoom(1)
    frame.unitLevel = srslylawlUI.CreateCustomFontString(portrait, "Level", 12)
    frame.unitLevel:SetFont("Fonts\\FRIZQT__.TTF", srslylawlUI.Utils_PixelFromCodeToScreen(12), "OUTLINE")
    srslylawlUI.Utils_SetPointPixelPerfect(frame.unitLevel, "CENTER", portrait, "BOTTOMRIGHT", 2, 5)
    frame.unitLevel:SetText("??")

    frame.factionIcon = portrait:CreateTexture("$parent_FactionIcon", "OVERLAY")
    srslylawlUI.Utils_SetSizePixelPerfect(frame.factionIcon, 20, 20)
    frame.factionIcon:SetPoint("CENTER", portrait, "TOPRIGHT", 0, 0)
    frame.factionIcon:SetTexCoord(0, 0.625, 0, 0.625)

    local oldSetSize = frame.SetSize
    function frame:SetSize(x, y)
        srslylawlUI.Utils_SetPointPixelPerfect(portrait, "TOPLEFT", frame.unit, "TOPRIGHT", 1, 0)
        local height = srslylawlUI.GetSetting("player.targetFrame.hp.height")
        srslylawlUI.Utils_SetPointPixelPerfect(portrait, "BOTTOMRIGHT", frame.unit, "BOTTOMRIGHT", height+1, 0)

        oldSetSize(frame, x, y)
    end

    function frame:UpdateUnitLevel()
        local unitLevel = UnitLevel("target")

        if unitLevel < 0 then
            self.unitLevel:SetText("??")
        else
            self.unitLevel:SetText(unitLevel)
        end
    end
    function frame:UpdateUnitFaction()
        local ffa = UnitIsPVPFreeForAll("target")

        if ffa then
            if self.faction ~= faction then
                    self.factionIcon:SetTexture("Interface/TARGETINGFRAME/UI-PVP-FFA")
                    self.factionIcon:Show()
                self.faction = "FFA"
            end
        else
            local faction = UnitFactionGroup("target")
            if not faction or faction == "Neutral" then
                if self.faction then
                    self.factionIcon:Hide()
                    self.faction = nil
                end
            elseif faction == "Horde" then
                if self.faction ~= faction then
                    self.factionIcon:SetTexture("Interface/TARGETINGFRAME/UI-PVP-Horde")
                    self.factionIcon:Show()
                    self.faction = faction
                end
            elseif faction == "Alliance" then
                if self.faction ~= faction then
                    self.factionIcon:SetTexture("Interface/TARGETINGFRAME/UI-PVP-Alliance")
                    self.factionIcon:Show()
                    self.faction = faction
                end
            end
        end
    end
    srslylawlUI.CreateBackground(portrait)
    portrait.ModelUpdate = function(self)
        if not UnitIsVisible("target") or not UnitIsConnected("target") then
	        self:SetModelScale(5.5)
	        self:SetPosition(2, 0, .9)
            self:SetPortraitZoom(5)
            self:ClearModel()
	        self:SetModel("Interface\\Buttons\\talktomequestionmark.m2")
        else
		    self:SetPortraitZoom(1)
		    self:SetPosition(0, 0, 0)
            self:ClearModel()
		    self:SetUnit("target")
        end
    end
    portrait.PortraitUpdate = function(self)
        local guid = UnitGUID("target")
		if self.guid ~= guid then
            self.guid = guid
			self:ModelUpdate()
		end
    end
    frame.portrait = portrait

    frame.portrait:SetScript("OnShow", function(self) self:ModelUpdate() end)
    --portrait seems to be very sensitive to order of execution, needs it as onshow or else it wont update properly
    frame:UpdateUnitLevel()
end
function srslylawlUI.CreateCastBar(parent, unit)
    local cBar = CreateFrame("Frame", "$parent_CastBar", parent)
    local unitsType = parent:GetAttribute("unitsType")
    srslylawlUI.CreateBackground(cBar, 1)
    local function CastOnUpdate(self, elapsed)
	    local time = GetTime()
        
	    self.elapsed = self.isChannelled and self.elapsed - (time - self.lastUpdate) or self.elapsed + (time - self.lastUpdate)
	    self.lastUpdate = time
        
        if self.elapsed <= 0 then
            self.elapsed = 0
        end
	    self.StatusBar:SetValue(self.elapsed)

        if self.isChannelled then
	    	if self.elapsed <= 0 then
	    		self.StatusBar.Timer:SetText("0.0")
                self.StatusBar:SetValue(0)
                self.spellName = nil
                self.castID = nil
                self:FadeOut()
            elseif self.pushback == 0 then
                -- no pushback
	    		self.StatusBar.Timer:SetFormattedText("%.1f", self.elapsed)
	    	else
                -- has pushback, display it
                self.StatusBar.Timer:SetText("|cffff0000".."+"..srslylawlUI.Utils_DecimalRound(self.pushback, 1).."|r".." "..srslylawlUI.Utils_DecimalRound(self.elapsed, 1))
	    	end
        else
	    	local timeLeft = self.endSeconds - self.elapsed
	    	if timeLeft <= 0 then
	    		self.StatusBar.Timer:SetText("0.0")
                self.StatusBar:SetValue(self.endSeconds)
            elseif self.pushback == 0 then
                -- no pushback
	    		self.StatusBar.Timer:SetFormattedText("%.1f", timeLeft, 1)
	    	else
                -- has pushback, display pushback
	    		self.StatusBar.Timer:SetText("|cffff0000".."+"..srslylawlUI.Utils_DecimalRound(self.pushback, 1).."|r".." "..srslylawlUI.Utils_DecimalRound(timeLeft, 1))
	    	end
            
            if self.elapsed >= self.endSeconds then
                self.spellName = nil
                self.castID = nil
                self:FadeOut()
            end
	    end
    end
    function cBar:UpdateCast()
        if self.disabled then return end
	    local spell, displayName, icon, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(self.unit)
	    local isChannelled
	    if not spell then
	    	spell, displayName, icon, startTime, endTime, isTradeSkill, notInterruptible, spellID = UnitChannelInfo(self.unit)
	    	isChannelled = true
	    end
	    if not spell then
            return
        end

	    -- self.StatusBar.SpellName:SetText(spell)
        
	    self.Icon:SetTexture(icon)
	    self.Icon:Show()

	    self.isChannelled = isChannelled
	    self.startTime = startTime / 1000
	    self.endTime = endTime / 1000
	    self.endSeconds = self.endTime - self.startTime
	    self.elapsed = self.isChannelled and self.endSeconds or 0
	    self.spellName = spell
	    self.spellID = spellID
	    self.castID = isChannelled and spellID or castID
	    self.pushback = 0
	    self.lastUpdate = self.startTime

	    self.StatusBar:SetMinMaxValues(0, self.endSeconds)
	    self.StatusBar:SetValue(self.elapsed)
	    self.StatusBar:Show()
        self:SetAlpha(1)
        --trigger hook functions, such as bar ordering
        self:GetScript("OnShow")(self)
        srslylawlUI.Utils_SetLimitedText(self.StatusBar.SpellName, self.StatusBar:GetWidth()*0.8, spell, true)

        
        self:SetScript("OnUpdate", CastOnUpdate)
    
	    if notInterruptible then
	    	self:ChangeBarColor("uninterruptible")
        elseif self.isChannelled then
            self:ChangeBarColor("channel")
	    else
            self:ChangeBarColor("cast")
	    end
    end
    function cBar:StopCast(event, unit, castID, spellID)
	    if event == "UNIT_SPELLCAST_CHANNEL_STOP" and not castID then
            castID = spellID
        end
	    if self.castID ~= castID or (event == "UNIT_SPELLCAST_FAILED" and self.isChannelled) or not self.castID then
            return
        end

        self.StatusBar:SetMinMaxValues(0, 1)
        self.StatusBar:SetValue(self.isChannelled and 0 or 1)
	    self.spellName = nil
	    self.spellID = nil
	    self.castID = nil
	    self:FadeOut()
    end
    function cBar:UpdateDelay()
	    local spell, displayName, icon, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(self.unit)
	    if not spell then
	    	spell, displayName, icon, startTime, endTime, isTradeSkill, notInterruptible, spellID = UnitChannelInfo(self.unit)
	    end
        if not spell then return end
	    startTime = startTime / 1000
	    endTime = endTime / 1000


	    local delay = startTime - self.startTime
	    if not self.isChannelled then
	    	self.endSeconds = self.endSeconds + delay
	    	self.StatusBar:SetMinMaxValues(0, self.endSeconds)
	    else
	    	self.elapsed = self.elapsed + delay
	    end

        if abs(delay) > 0.01 then
	        self.pushback = self.pushback + delay
        end
	    self.lastUpdate = GetTime()
	    self.startTime = startTime
	    self.endTime = endTime
    end
    function cBar:CastSucceeded(event, unit, castID, spellID)
	    if not self.isChannelled and self.castID == castID then
	    	self:ChangeBarColor("success")
	    end
    end
    function cBar:FadeOut()
        if self:GetAlpha() <= 0.01 then return end
        local fadeTime = .5
        local tick = 0.01
        self.fadeTimer = (self.fadeTimer and self.fadeTimer) or fadeTime
        self.fadeInterval = self.fadeInterval or 0

        self:SetScript("OnUpdate", function(self, elapsed)
            self.fadeTimer = self.fadeTimer - elapsed
            self.fadeInterval = self.fadeInterval + elapsed
            if self.fadeInterval <= tick then return end

            self.fadeTimer = self.fadeTimer > 0 and self.fadeTimer or 0

            self:SetAlpha(self.fadeTimer/fadeTime)

            if self.fadeTimer == 0 then
                self:SetScript("OnUpdate", nil)
                self.fadeTimer = nil
                self:GetScript("OnHide")(self)
                return
            end

            self.fadeInterval = self.fadeInterval - tick
            self.fadeTimer = self.fadeTimer - tick
        end)
    end
    function cBar:ChangeBarColor(type)
        local color = {1, 1, 1, 1}
        -- local bgColor = {0, 0, 0, .4}
        if type == "channel" then
            color = {0.160, 0.411, 1, 1}
        elseif type == "cast" then
            -- color = {0.862, 0.549, 0.196, 1}
            color = {0.862, 0.713, 0.196, 1}
        elseif type == "uninterruptible" then
            color = {0.8, 0, 0.741, 1}
        elseif type == "success" then
            color = {0.364, 1, 0.160, 1}
        elseif type == "failed" then
            color = {0.980, 0.152, 0, 1}
            -- bgColor = color
        end
        self.StatusBar:SetStatusBarColor(unpack(color))
        -- bgColor[4] = .4
        -- self:SetBackdropColor(unpack(bgColor))
    end
    function cBar:CastInterrupted(event, unit, castID, spellID)
        if not self.castID then
            return
        end
        self:ChangeBarColor("failed")
        self.StatusBar.SpellName:SetText("Interrupted")

        self.castID = nil
	    self.spellID = nil
        self:FadeOut()
    end
    function cBar:Interruptible()
        if self.isChannelled then
            self:ChangeBarColor("channel")
        else
            self:ChangeBarColor("cast")
        end
    end
    function cBar:UpdateVisible()
        -- if self.isChannelled then
	    -- 	if self.elapsed and self.elapsed <= 0 then
	    -- 		self.StatusBar.Timer:SetText("0.0")
        --         self.StatusBar:SetValue(0)
        --         self.spellName = nil
        --         self.castID = nil
        --         self:FadeOut()
        --     end
        -- elseif self.endSeconds and self.elapsed then
	    -- 	if self.elapsed >= self.endSeconds then
        --         self.spellName = nil
        --         self.castID = nil
        --         self:FadeOut()
        --     else
        --         self:Show()
    end

    function cBar:SetPoints(h)
        if h then
            h = math.max(1, h)
            srslylawlUI.Utils_SetSizePixelPerfect(cBar.Icon, h, h)
            local fSize = srslylawlUI.GetSettingByUnit("cast.fontSize", unitsType, unit)

            if h > 0 then
                local fontSizeScale = h/fSize
                local newSize = srslylawlUI.Utils_ScuffedRound(fSize*fontSizeScale)
                newSize = newSize > 25 and 25 or newSize
                self.StatusBar.Timer:SetFont("Fonts\\FRIZQT__.TTF", srslylawlUI.Utils_PixelFromCodeToScreen(newSize))
                self.StatusBar.SpellName:SetFont("Fonts\\FRIZQT__.TTF", srslylawlUI.Utils_PixelFromCodeToScreen(newSize))
            end
        end
    end

    cBar.unit = unit
    cBar:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
	cBar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
	cBar:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
	cBar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
	cBar:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", unit)
	cBar:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unit)
	cBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
	cBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
	cBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
	cBar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unit)
	cBar:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unit)

    cBar.name = "CastBar"
    cBar.StatusBar = CreateFrame("StatusBar", "$parent_StatusBar", cBar)
    cBar.StatusBar:SetStatusBarTexture(srslylawlUI.textures.HealthBar)
    cBar.StatusBar:Hide()
    cBar.Icon = cBar:CreateTexture("$parent_icon", "OVERLAY")
    cBar.Icon:SetTexCoord(.08, .92, .08, .92)
    cBar.StatusBar.Timer = cBar.StatusBar:CreateFontString("$parent_Timer", "OVERLAY", "GameFontHIGHLIGHT")
    local fontSize = srslylawlUI.GetSettingByUnit("cast.fontSize", unitsType, unit)
    local height = srslylawlUI.GetSettingByUnit("cast.height", unitsType, unit)
    cBar.StatusBar.Timer:SetFont("Fonts\\FRIZQT__.TTF", srslylawlUI.Utils_PixelFromCodeToScreen(fontSize))
    cBar.StatusBar.SpellName = cBar.StatusBar:CreateFontString("$parent_SpellName", "OVERLAY", "GameFontHIGHLIGHT")
    cBar.StatusBar.SpellName:SetFont("Fonts\\FRIZQT__.TTF", srslylawlUI.Utils_PixelFromCodeToScreen(fontSize))
    srslylawlUI.Utils_SetSizePixelPerfect(cBar.Icon, height, height)
    cBar.Icon:SetPoint("TOPLEFT", cBar, "TOPLEFT", 0, 0)
    srslylawlUI.Utils_SetPointPixelPerfect(cBar.StatusBar, "TOPLEFT", cBar.Icon, "TOPRIGHT", 1, 0)
    srslylawlUI.Utils_SetPointPixelPerfect(cBar.StatusBar, "BOTTOMRIGHT", cBar, "BOTTOMRIGHT", 0, 0)
    srslylawlUI.Utils_SetPointPixelPerfect(cBar.StatusBar.SpellName, "LEFT", cBar.StatusBar, "LEFT", 1, 0)
    srslylawlUI.Utils_SetPointPixelPerfect(cBar.StatusBar.Timer, "RIGHT", cBar.StatusBar, "RIGHT", -1, 0)
    cBar:SetAlpha(0)

    cBar:SetScript("OnShow", function(self)
        if UnitCastingInfo(self.unit) or UnitChannelInfo(self.unit) then
            if self:GetAlpha() < 0.9 then
		        self:UpdateCast()
            end
	    else
            self.castID = nil
	        self.spellID = nil
            self.StatusBar:Hide()
            self.Icon:Hide()
            self:SetAlpha(0)
	    end
    end)

    cBar:SetScript("OnHide", function(self)
        self.castID = nil
	    self.spellID = nil
        self.StatusBar:Hide()
        self.Icon:Hide()
        self:SetAlpha(0)
    end)

    cBar:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
        if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
        -- starting cast
            self:UpdateCast()
        elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_FAILED" then
        -- stopping cast
            self:StopCast(event, arg1, arg2, arg3)
        elseif event == "UNIT_SPELLCAST_DELAYED" or event == "UNIT_SPELLCAST_CHANNEL_UPDATE" then
        -- cast delayed
            self:UpdateDelay()
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        -- cast successful
            self:CastSucceeded(event, arg1, arg2, arg3)
        elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        -- cast interrupted
            self:CastInterrupted(event, unit, castID, spellID)
        elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
        -- cast can now be interrupted, change color
            self:Interruptible()
        elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
        -- cast can now now longer be interrupted, change color
            self:ChangeBarColor("uninterruptible")
        end
    end)

    return cBar
end
function srslylawlUI.BarHandler_Create(frame, barParent)
    frame.BarHandler = CreateFrame("Frame", "$parent_BarHandler", frame)

    local bh = frame.BarHandler
    local unit = barParent:GetAttribute("unit")
    local unitsType = barParent:GetAttribute("unitsType")
    bh.barParent = barParent

    bh.bars = {}


    function frame:RegisterBar(bar, priority, height)
        local disabled = false
        if bar.name == "CastBar" then
            priority = srslylawlUI.GetSettingByUnit("cast.priority", unitsType, unit)
            height = srslylawlUI.GetSettingByUnit("cast.height", unitsType, unit)
            disabled = srslylawlUI.GetSettingByUnit("cast.disabled", unitsType, unit)
        elseif bar.name == "CCDurationBar" then
            priority = srslylawlUI.GetSettingByUnit("ccbar.priority", unitsType, unit)
            height = srslylawlUI.GetSettingByUnit("ccbar.height", unitsType, unit)
            disabled = srslylawlUI.GetSettingByUnit("ccbar.disabled", unitsType, unit)
        elseif unit == "player" then
            local specIndex = GetSpecialization()
            local specID = GetSpecializationInfo(specIndex)

            if specID < 102 or specID > 105 then -- not druid
                local path = "player.playerFrame.power.overrides."..specID.."."..bar.name.."."
                priority = srslylawlUI.GetSetting(path.."priority", true) or priority
                height = srslylawlUI.GetSetting(path.."height", true) or height
                disabled = srslylawlUI.GetSetting(path.."disabled", true) or disabled
            else
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
                if currentStance == nil then currentStance = 0 end
                local path = "player.playerFrame.power.overrides."..specID.."."..currentStance.."."..bar.name.."."
                priority = srslylawlUI.GetSetting(path.."priority", true) or priority
                height = srslylawlUI.GetSetting(path.."height", true) or height
                disabled = srslylawlUI.GetSetting(path.."disabled", true) or disabled
            end
        end
        bar.disabled = disabled

        for _, v in pairs(bh.bars) do
            if v.bar == bar then
                v.priority = priority
                v.height = height
                self:SortBars()
                return
            end
        end

        table.insert(bh.bars, {bar = bar, priority = priority, height = height})

        if not bar:GetScript("OnShow") then
            bar:SetScript("OnShow", function() self:SetPoints() end)
        else
            bar:HookScript("OnShow", function() self:SetPoints() end)
        end

        if not bar:GetScript("OnHide") then
            bar:SetScript("OnHide", function() self:SetPoints() end)
        else
            bar:HookScript("OnHide", function() self:SetPoints() end)
        end

        bar.isUnparented = false

        bar:SetScript("OnHide", function() self:SetPoints() end)

        -- self:SortBars()
    end
    function frame:UnregisterBar(bar)
        local found
        for k, v in pairs(bh.bars) do
            if v.bar == bar then
                found = k
            end
        end
        if not found then
            return
        end

        table.remove(bh.bars, found)
        bar.isUnparented = true
        self:SortBars()
    end
    function frame:UnregisterAll()
        local actualIndex = 1
        for i=1,#bh.bars do
            if bh.bars[i].bar.name == "CastBar" then
                -- Move i's kept value to actualIndex's position, if it's not already there.
                if i ~= actualIndex then
                    bh.bars[actualIndex] = bh.bars[i];
                    bh.bars[i] = nil;
                end
                actualIndex = actualIndex + 1; -- Increment position of where we'll place the next kept value.
            else
                bh.bars[i].bar.isUnparented = true
                bh.bars[i] = nil;
            end
        end
    end
    function frame:SortBars()
        table.sort(bh.bars, function(a, b)
            return a.priority < b.priority
        end)

        self:SetPoints()
    end
    function frame:SetPoints()
        local currentBar
        local lastBar
        local height
        for i=1, #bh.bars do
            currentBar = bh.bars[i].bar
            height = bh.bars[i].height or 40
            if currentBar:IsShown() and currentBar:GetAlpha() > .9 and not currentBar.disabled then --ignore if the bar isnt visible
                if not lastBar then
                    srslylawlUI.Utils_SetPointPixelPerfect(currentBar, "TOPLEFT", bh.barParent, "BOTTOMLEFT", 0, -1)
                    srslylawlUI.Utils_SetPointPixelPerfect(currentBar, "BOTTOMRIGHT", bh.barParent, "BOTTOMRIGHT", 0, -1-height)
                else
                    srslylawlUI.Utils_SetPointPixelPerfect(currentBar, "TOPLEFT", lastBar, "BOTTOMLEFT", 0, -1)
                    srslylawlUI.Utils_SetPointPixelPerfect(currentBar, "BOTTOMRIGHT", lastBar, "BOTTOMRIGHT", 0, -1-height)
                end
                if currentBar.SetPoints then
                    currentBar:SetPoints(height)
                    currentBar.pointsSet = true
                end
                lastBar = currentBar
            elseif currentBar.SetPoints and not currentBar.pointsSet then
                currentBar:SetPoints(height)
                currentBar.pointsSet = true
            end
            currentBar:UpdateVisible()
        end
    end
    function frame:SetDemoMode(active)
        if not bh.demoBars then
            bh.demoBars = {}
        end
        if active then
            local timer = 0
            bh:SetScript("OnUpdate", function(self, elapsed)
                timer = timer + elapsed
                if timer <= .1 then return end
                local currentBar, currentDemoBar, lastBar, height, token, resourceName
                for i=1, #bh.bars do
                    if not bh.demoBars[i] then
                        bh.demoBars[i] = CreateFrame("StatusBar", "$parent_DemoBar"..i, bh.barParent)
                        bh.demoBars[i]:SetStatusBarTexture(srslylawlUI.textures.PowerBarSprite)
                        bh.demoBars[i].text = srslylawlUI.CreateCustomFontString(bh.demoBars[i], "Text", 15)
                        bh.demoBars[i].text:SetPoint("CENTER")
                    end
                    currentDemoBar = bh.demoBars[i]
                    currentBar = bh.bars[i]
                    height = currentBar.height or 40

                    if currentBar.bar.color then
                        currentDemoBar:SetStatusBarColor(currentBar.bar.color.r, currentBar.bar.color.g, currentBar.bar.color.b)
                    else
                        currentDemoBar:SetStatusBarColor(1, 1, 1)
                    end

                    if not lastBar then
                        srslylawlUI.Utils_SetPointPixelPerfect(currentDemoBar, "TOPLEFT", bh.barParent, "BOTTOMLEFT", 0, -1)
                        srslylawlUI.Utils_SetPointPixelPerfect(currentDemoBar, "BOTTOMRIGHT", bh.barParent, "BOTTOMRIGHT", 0, -1-height)
                    else
                        srslylawlUI.Utils_SetPointPixelPerfect(currentDemoBar, "TOPLEFT", lastBar, "BOTTOMLEFT", 0, -1)
                        srslylawlUI.Utils_SetPointPixelPerfect(currentDemoBar, "BOTTOMRIGHT", lastBar, "BOTTOMRIGHT", 0, -1-height)
                    end

                    currentDemoBar.text:SetText(currentBar.bar.name)

                    currentDemoBar:Show()
                    lastBar = currentDemoBar
                end
                for i=#bh.bars+1, #bh.demoBars do
                    bh.demoBars[i]:Hide()
                end
                timer = 0
            end)
        else
            for i=1, #bh.demoBars do
                bh.demoBars[i]:Hide()
            end
            bh:SetScript("OnUpdate", nil)
        end
    end
    function frame:ReRegisterAll()
        for i=1, #bh.bars do
            local b = bh.bars[i]
            frame:RegisterBar(b.bar, b.priority, b.height)
        end
    end
end
function srslylawlUI.Frame_SetCombatIcon(button)
    local unit = button:GetParent():GetAttribute("unit")
    local inCombat = UnitAffectingCombat(unit)
    if button.inCombat == inCombat then return end

    if inCombat then
        if not button.wasCombat then
            button.texture:SetTexCoord(0.5, 1, 0, .5)
            button.wasCombat = true
        end
        button.texture:Show()
    elseif unit == "player" then
        if button.wasCombat ~= false then
            button.texture:SetTexCoord(0, .5, 0, .5)
            button.wasCombat = false
        end
        button.texture:Show()
    else
        button.texture:Hide()
    end

    button.inCombat = inCombat
end
function srslylawlUI.CreateBackground(frame, customSize, opacity)
    customSize = customSize or 1
    local background = CreateFrame("Frame", "$parent_background", frame)
    local t = background:CreateTexture(nil, "BACKGROUND")
    opacity = opacity or .5
    t:SetColorTexture(0, 0, 0, opacity)
    t:SetAllPoints()
    srslylawlUI.Utils_SetPointPixelPerfect(background, "TOPLEFT", frame, "TOPLEFT", -customSize, customSize)
    srslylawlUI.Utils_SetPointPixelPerfect(background, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", customSize, -customSize)
    background.texture = t
    background:Show()
    background:SetFrameStrata("BACKGROUND")
    local frameLevel = frame:GetFrameLevel()
    frameLevel = frameLevel > 0 and frameLevel or 1
    background:SetFrameLevel(frameLevel-1)
    frame.background = background
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
    local unitsType = button:GetAttribute("unitsType")
    if unitsType == "fauxUnits" or unit == "targettarget" then return end
    srslylawlUI[unitsType][unit].absorbFrames[1]:Hide()
    srslylawlUI[unitsType][unit].absorbFramesOverlap[1]:Hide()
    srslylawlUI[unitsType][unit].effectiveHealthFrames[1]:Hide()
end

--party
function srslylawlUI.Frame_Party_ResetDimensions_ALL()
    for _, unit in pairs(srslylawlUI.partyUnitsTable) do
        local button = srslylawlUI.partyUnits[unit].unitFrame
        if button then
            srslylawlUI.Frame_ResetDimensions(button)
            srslylawlUI.Frame_ResetDimensions_Pet(button)
            srslylawlUI.Frame_ResetDimensions_PowerBar(button)
            srslylawlUI.Frame_ResetCCDurBar(button)
        end
    end
end
function srslylawlUI_PartyFrame_OnDragStart()
    if not srslylawlUI_PartyHeader:IsMovable() then return end
    srslylawlUI_PartyHeader:StartMoving()
    srslylawlUI_PartyHeader.isMoving = true
end
function srslylawlUI_PartyFrame_OnDragStop()
    if srslylawlUI_PartyHeader.isMoving then
        srslylawlUI_PartyHeader:StopMovingOrSizing()
        srslylawlUI.ChangeSetting("party.header.point", srslylawlUI_PartyHeader:GetPoint())
    end
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
        UpdateHeaderVisible(srslylawlUI.GetSetting("party.visibility.showParty"))
    elseif isInRaid then
        UpdateHeaderVisible(srslylawlUI.GetSetting("party.visibility.showRaid"))
    elseif isInArena then
        UpdateHeaderVisible(srslylawlUI.GetSetting("party.visibility.showArena"))
    else
        local frame = srslylawlUI_PartyHeader.player
        if srslylawlUI.GetSetting("party.visibility.showSolo") then
            if not frame:IsShown() then
                RegisterUnitWatch(frame)
            end
        else
            if frame:IsShown() then
                UnregisterUnitWatch(frame)
            end
        end
        UpdateHeaderVisible(srslylawlUI.GetSetting("party.visibility.showSolo"))
    end
end

--main
function srslylawlUI.Frame_Main_ResetDimensions_ALL()
    for _, unit in pairs(srslylawlUI.mainUnitsTable) do
        local button = srslylawlUI.mainUnits[unit].unitFrame
        if button then
            srslylawlUI.Frame_ResetDimensions(button)
            if unit == "player" then
                srslylawlUI.Frame_ResetDimensions_Pet(button)
            else
                srslylawlUI.Frame_ResetDimensions_PowerBar(button)
            end
            --srslylawlUI.Frame_ResetCCDurBar(button)
        end
    end
end
function srslylawlUI.Frame_ResetCCDurBar(button)
    local unit, unitsType = button:GetAttribute("unit"), button:GetAttribute("unitsType")
    local h = srslylawlUI.GetSettingByUnit("hp.height", unitsType, unit)
    if button:GetAttribute("unit") == "target" then


    else


    end
    local h = srslylawlUI.GetSetting("party.hp.height")
    local h2 = h*srslylawlUI.GetSetting("party.ccbar.heightPercent")
    local w = srslylawlUI.GetSetting("party.ccbar.width")
    -- local iconSize = (w > h2 and h2) or w
    button.unit.CCDurBar:SetPoints(w, h2)
    -- srslylawlUI.Utils_SetSizePixelPerfect(button.unit.CCDurBar, w, h2)
    -- srslylawlUI.Utils_SetSizePixelPerfect(button.unit.CCDurBar.icon, iconSize, iconSize)
end
function srslylawlUI.PlayerFrame_OnDragStart(self)
    if self:IsMovable() then
        self.isMoving = true
        self:StartMoving()
    end
end
function srslylawlUI.PlayerFrame_OnDragStop(self)
    if self.isMoving then
        self:StopMovingOrSizing()
        self.isMoving = false
        local points = {self:GetPoint()}
        local offsets = {srslylawlUI.Utils_PixelFromScreenToCode(points[4], points[5])}
        srslylawlUI.ChangeSetting("player."..self:GetAttribute("unit").."Frame.position", {points[1], srslylawlUI.TranslateFrameAnchor(points[2]), points[3], unpack(offsets)})
        if self.ResetAnchoringPanel then
            self:ResetAnchoringPanel(unpack({points[1], srslylawlUI.TranslateFrameAnchor(points[2]), points[3], unpack(offsets)}))
        end
    end
end

--events
function srslylawlUI.RegisterEvents(buttonFrame)
    local unit = buttonFrame:GetAttribute("unit")
    buttonFrame:RegisterUnitEvent("UNIT_HEALTH", unit, "pet")
    buttonFrame:RegisterUnitEvent("UNIT_MAXHEALTH", unit, "pet")
    buttonFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)
    buttonFrame:RegisterUnitEvent("UNIT_DISPLAYPOWER", unit)
    buttonFrame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    buttonFrame:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)
    buttonFrame:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", unit)
    buttonFrame:RegisterUnitEvent("UNIT_EXITED_VEHICLE", unit)

    if unit ~= "targettarget" then
        buttonFrame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", unit)
        buttonFrame:RegisterUnitEvent("UNIT_CONNECTION", unit)
        buttonFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit)
        buttonFrame:RegisterUnitEvent("UNIT_AURA", unit)
        buttonFrame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit)
        buttonFrame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unit)
        buttonFrame:RegisterUnitEvent("UNIT_PHASE", unit)
        buttonFrame:RegisterUnitEvent("READY_CHECK_CONFIRM", unit)
        buttonFrame:RegisterEvent("READY_CHECK")
        buttonFrame:RegisterEvent("READY_CHECK_FINISHED")
        buttonFrame:RegisterEvent("PARTY_LEADER_CHANGED")
        buttonFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
        buttonFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    end
end
function srslylawlUI_Frame_OnEvent(self, event, arg1, arg2)
    local function UpdatePowerBar(unit, unitsType, token)
        if unit == "player" and unitsType == "mainUnits" then
            srslylawlUI.PowerBar.Update(self, token)
        else
            self.unit.powerBar:SetValue(UnitPower(unit))
        end
    end
    local unit = self:GetAttribute("unit")
    local unitExists = UnitExists(unit)
    local unitsType = self:GetAttribute("unitsType")
    if not unitExists then return end
    -- Handle any events that don’t accept a unit argument
    if event == "PLAYER_ENTERING_WORLD" then
        srslylawlUI.HandleAuras(self.unit, unit)
        UpdatePowerBar(unit, nil)
    elseif event == "GROUP_ROSTER_UPDATE" then
        self.PartyLeader:SetShown(UnitIsGroupLeader(unit))
    elseif event == "PLAYER_TARGET_CHANGED" then
        if unitsType == "partyUnits" then
            if UnitIsUnit(unit, "target") then
                self.unit.selected:Show()
            else
                self.unit.selected:Hide()
            end
        elseif unitsType == "mainUnits" then
            if unit == "target" then
                if self.CastBar then
                    self.CastBar:Hide()
                    self.CastBar:Show()
                end
                self.portrait:PortraitUpdate()
                self:UpdateUnitLevel()
                self:UpdateUnitFaction()
                srslylawlUI.HandleAuras(self.unit, unit)
                srslylawlUI.SetAuraPointsAll(unit, unitsType)
            end
            srslylawlUI.Frame_SetCombatIcon(self.unit.CombatIcon)
            srslylawlUI.Frame_ResetUnitButton(self.unit, unit)
        end
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" and unit == "player" then
        srslylawlUI.PowerBar.Set(self, unit)
    elseif event == "PARTY_LEADER_CHANGED" then
        self.PartyLeader:SetShown(UnitIsGroupLeader(unit))
    elseif event == "READY_CHECK" then
            srslylawlUI.Frame_ReadyCheck(self, arg1 == UnitName(unit) and "ready" or "start")
    elseif event == "READY_CHECK_CONFIRM" then
            srslylawlUI.Frame_ReadyCheck(self, arg2 and "ready" or "notready")
    elseif event == "READY_CHECK_FINISHED" then
            srslylawlUI.Frame_ReadyCheck(self, "end")
    elseif arg1 and UnitIsUnit(unit, arg1) and arg1 ~= "nameplate1" then
        if event == "UNIT_MAXHEALTH" then
            if self.unit.dead ~= UnitIsDeadOrGhost(unit) then
                if unit ~= "targettarget" then
                    srslylawlUI.HandleAuras(self.unit, unit)
                end
                srslylawlUI.Frame_ResetUnitButton(self.unit, unit)
            end
            self.unit.healthBar:SetMinMaxValues(0, UnitHealthMax(unit))
            self.unit.healthBar:SetValue(UnitHealth(unit))
        elseif event == "UNIT_HEALTH" then
            srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
            if unit ~= "targettarget" then
                srslylawlUI.HandleAuras(self.unit, unit)
            end
        elseif event == "UNIT_DISPLAYPOWER" then
            srslylawlUI.Frame_ResetPowerBar(self.unit, unit)
            if unit == "player" and unitsType == "mainUnits" then
                srslylawlUI.PowerBar.Set(self, unit)
            end
        elseif event == "UNIT_POWER_FREQUENT" then
            UpdatePowerBar(unit, unitsType, arg2)
        elseif event == "UNIT_MAXPOWER" then
            if unit == "player" and unitsType == "mainUnits" then
                srslylawlUI.PowerBar.UpdateMax(self, arg2)
            else
                self.unit.powerBar:SetMinMaxValues(0, UnitPowerMax(unit))
            end
        elseif event == "UNIT_NAME_UPDATE" then
            if unit == "target" then
                srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
            else
                srslylawlUI.Frame_ResetName(self.unit, unit)
            end
        elseif event == "UNIT_THREAT_SITUATION_UPDATE" then
            local status = UnitThreatSituation(unit)
            if status and status > 0 then
                local r, g, b = GetThreatStatusColor(status)
                self.unit.healthBar.leftText:SetTextColor(r, g, b)
            else
                self.unit.healthBar.leftText:SetTextColor(1, 1, 1)
            end
        elseif event == "UNIT_CONNECTION" then
            srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
            srslylawlUI.Frame_ResetPowerBar(self.unit, unit)
            if unitsType == "partyUnits" then
                if UnitName(unit) ~= "Unknown" then
                    srslylawlUI.Log(UnitName(unit) .. (UnitIsConnected(unit) and " is now online." or " is now offline."))
                end
            end
        elseif event == "UNIT_AURA" or event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_PREDICTION" then
            srslylawlUI.HandleAuras(self.unit, unit)
        elseif event == "UNIT_PHASE" then
            srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
        elseif event == "UNIT_PORTRAIT_UPDATE" and unit == "target" then
            self.portrait:PortraitUpdate()
        elseif event == "UNIT_MODEL_CHANGED" and unit == "target" then
            self.portrait:ModelUpdate()
        elseif event == "UNIT_FACTION" and unit == "target" then
            self:UpdateUnitFaction()
        elseif event == "UNIT_ENTERED_VEHICLE" then
            srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
        elseif event == "UNIT_EXITED_VEHICLE" then
            srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
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
    srslylawlUI.Frame_ResetHealthBar(button, unit)
    srslylawlUI.Frame_ResetPowerBar(button, unit)
    srslylawlUI.Frame_ResetName(button, unit)
    if UnitIsUnit(unit, "target") and button:GetAttribute("unitsType") == "partyUnits" then
        button.selected:Show()
    else
        button.selected:Hide()
    end
end
function srslylawlUI.Frame_ResetName(button, unit)
    if unit == "target" then
        srslylawlUI.Frame_ResetHealthBar(button, unit)
        return
    end
    local name = UnitName(unit) or UNKNOWN
    srslylawlUI.Utils_SetLimitedText(button.healthBar.leftText, button.healthBar:GetWidth()*0.5, name, true)
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
    local class = select(2, UnitClass(unit))
    local SBColor
    local isPlayer = UnitIsPlayer(unit)
    if isPlayer and class then
        SBColor = { RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b, RAID_CLASS_COLORS[class].a }
        local alive = not UnitIsDeadOrGhost(unit)
        local online = UnitIsConnected(unit)
        local inRange = UnitInRange(unit)
        local differentPhase = UnitPhaseReason(unit)
        if not alive or not online then
            -- set bar color to grey and fill bar
            SBColor[1], SBColor[2], SBColor[3] = 0.3, 0.3, 0.3
            if not alive then
                button.healthBar.rightText:SetText("DEAD")
            elseif not online then
                button.healthBar.rightText:SetText("offline")
            end
        elseif differentPhase then
            local phaseReason
            if differentPhase == Enum.PhaseReason.WarMode then
                phaseReason = "diff War Mode"
            elseif differentPhase == Enum.PhaseReason.ChromieTime then
                phaseReason = "Timewalking Campaign"
            elseif differentPhase == Enum.PhaseReason.Phasing then
                phaseReason = "different Phase"
            elseif differentPhase == Enum.PhaseReason.Sharding then
                phaseReason = "different Shard"
            end
            button.healthBar.rightText:SetText(phaseReason)
        end
        if unit == "player" or inRange or button:GetAttribute("unitsType") == "mainUnits" then
            SBColor[4] = 1
        else
            SBColor[4] = 0.4
        end
        button.dead = (not alive)
        button.online = online
        button.wasInRange = inRange
    else
        SBColor = {UnitSelectionColor(unit, true)}
        if not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) and UnitCanAttack("player", unit) then
            SBColor = {0.5, 0.5, 0.5, 1}
        end
    end
    local health = UnitHealth(unit)
    local healthMax = UnitHealthMax(unit)
    local healthPercent = ceil(health / healthMax * 100)
    if unit == "target" then
        local name = UnitName(unit) or UNKNOWN
        srslylawlUI.Utils_SetLimitedText(button.healthBar.leftText, button.healthBar:GetWidth()*0.5, healthPercent .. "%".." ".. name, true)
        button.healthBar.rightText:SetText(srslylawlUI.ShortenNumber(health).."/"..srslylawlUI.ShortenNumber(healthMax))
    else
        srslylawlUI.Utils_SetLimitedText(button.healthBar.rightText, button.healthBar:GetWidth()*0.5, srslylawlUI.ShortenNumber(health).." "..healthPercent .. "%")
    end
    button.healthBar:SetMinMaxValues(0, healthMax)
    button.healthBar:SetValue(health)
    button.healthBar:SetStatusBarColor(unpack(SBColor))
    if button:GetAttribute("unitsType") ~= "fauxUnits" and unit ~= "targettarget" then
        button.healthBar.effectiveHealthFrame.texture:SetVertexColor(SBColor[1], SBColor[2], SBColor[3], .5)
    end
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
function srslylawlUI.Frame_ResetDimensions(button)
    local unit = button:GetAttribute("unit")
    local unitsType = button:GetAttribute("unitsType")
    local h, w = srslylawlUI.GetSettingByUnit("hp.height", unitsType, unit), srslylawlUI.GetSettingByUnit("hp.width", unitsType, unit)
    local fontSize = srslylawlUI.GetSettingByUnit("hp.fontSize", unitsType, unit)
    local checkFrame = button.unit.healthBar
    if unitsType == "partyUnits" or unitsType == "fauxUnits" then
        if srslylawlUI.unitHealthBars[unit] and srslylawlUI.unitHealthBars[unit]["width"] then
            w = srslylawlUI.unitHealthBars[unit]["width"]
        end
    elseif unitsType == "mainUnits" then
        checkFrame = button
    end

    local widthDiff = abs(srslylawlUI.Utils_PixelFromScreenToCode(checkFrame:GetWidth()) - w)
    local heightDiff = abs(srslylawlUI.Utils_PixelFromScreenToCode(checkFrame:GetHeight()) - h)
    local tolerance = 0.1
    local needsResize = widthDiff > tolerance or heightDiff > tolerance
    if needsResize or unitsType == "mainUnits" then
        -- srslylawlUI.Utils_SetSizePixelPerfect(button.unit.auraAnchor, w, h)
        srslylawlUI.Utils_SetSizePixelPerfect(button.unit.healthBar, w, h)
        srslylawlUI.Utils_SetHeightPixelPerfect(button.unit.powerBar, h)

        if unitsType ~= "fauxUnits" and unit ~= "targettarget" then
            srslylawlUI.MoveAbsorbAnchorWithHealth(unit, unitsType)
        end

        if not InCombatLockdown() then
            -- stuff that taints in combat
            local frameH = srslylawlUI.GetSettingByUnit("hp.height", unitsType, unit)
            local frameW = srslylawlUI.GetSettingByUnit("hp.width", unitsType, unit)
            srslylawlUI.Utils_SetSizePixelPerfect(button.unit, frameW, frameH)
        end

        if unit == "player" and unitsType == "mainUnits"then
            button:SetPoints() --reparent powerbars
        end
    end

    button.unit.healthBar.leftText:SetFont("Fonts\\FRIZQT__.TTF", srslylawlUI.Utils_PixelFromCodeToScreen(fontSize))
    button.unit.healthBar.rightText:SetFont("Fonts\\FRIZQT__.TTF", srslylawlUI.Utils_PixelFromCodeToScreen(fontSize))

    srslylawlUI.Frame_ResetUnitButton(button.unit, button:GetAttribute("unit"))
end
function srslylawlUI.Frame_ResetDimensions_Pet(button)
    --manipulating the petframe will cause taint in combat
    if InCombatLockdown() then
        srslylawlUI.SortAfterCombat()
        return
    end
    local unitsType = button:GetAttribute("unitsType")
    if unitsType ~= "mainUnits" then
        srslylawlUI.Utils_SetPointPixelPerfect(button.pet, "TOPLEFT", button.unit, "TOPRIGHT", 1, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(button.pet, "BOTTOMRIGHT", button.unit, "BOTTOMRIGHT", srslylawlUI.GetSetting("party.pet.width"), 0)
        srslylawlUI.Utils_SetPointPixelPerfect(button.unit.CCDurBar, "BOTTOMLEFT", button.unit, "BOTTOMRIGHT", srslylawlUI.GetSetting("party.pet.width")+4, 0)
    else
        local unit = button:GetAttribute("unit")
        if unit == "player" then
            button.pet:ClearAllPoints()
            srslylawlUI.Utils_SetPointPixelPerfect(button.pet, "TOPRIGHT", button.unit, "TOPLEFT", -1, 0)
            srslylawlUI.Utils_SetPointPixelPerfect(button.pet, "BOTTOMLEFT", button.unit, "BOTTOMLEFT", -srslylawlUI.GetSetting("player."..unit.."Frame.pet.width"), 0)
        end
    end

end
function srslylawlUI.Frame_ResetDimensions_PowerBar(button)
    local unitsType = button:GetAttribute("unitsType")
    if unitsType ~= "mainUnits" then
        srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "BOTTOMRIGHT", button.unit, "BOTTOMLEFT", -1, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "TOPLEFT", button.unit, "TOPLEFT", -(2+srslylawlUI.GetSetting("party.power.width")), 0)
    else
        local unit = button:GetAttribute("unit")
        if unit == "targettarget" then
            srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "BOTTOMLEFT", button.unit, "BOTTOMRIGHT", 1, 0)
            srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "TOPRIGHT", button.unit, "TOPRIGHT", 2+srslylawlUI.GetSetting("player."..unit.."Frame.power.width"), 0)
        else
            srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "BOTTOMRIGHT", button.unit, "BOTTOMLEFT", -1, 0)
            srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "TOPLEFT", button.unit, "TOPLEFT", -(2+srslylawlUI.GetSetting("player."..unit.."Frame.power.width")), 0)
        end
    end
end

function srslylawlUI.ToggleAllFrames(bool)
    local function ActivateFrame(frame, bool)
        if bool then
            RegisterUnitWatch(frame)
        else
            UnregisterUnitWatch(frame)
        end

        if UnitExists(frame:GetAttribute("unit")) then
            frame:SetShown(bool)
        end
    end
local playerEnabled = srslylawlUI.GetSetting("player.playerFrame.enabled") and bool
local targetEnabled = srslylawlUI.GetSetting("player.targetFrame.enabled") and bool
local ttargetEnabled = srslylawlUI.GetSetting("player.targettargetFrame.enabled") and bool

ActivateFrame(srslylawlUI_Main_player, playerEnabled)
ActivateFrame(srslylawlUI_Main_target, targetEnabled)
ActivateFrame(srslylawlUI_Main_targettarget, ttargetEnabled)
srslylawlUI_PartyHeader:SetShown(bool)
end

function srslylawlUI.SetAuraPoints(unit, unitsType, auraType)
    local function ReversePos(str)
        if str == "TOP" then return "BOTTOM"
        elseif str == "BOTTOM" then return "TOP"
        elseif str == "RIGHT" then return "LEFT"
        elseif str == "LEFT" then return "RIGHT"
        else return false
        end
    end
    local function ReverseAnchorPointPos(str, pos)
        if pos == 1 then
            local firstPoint
            local i = 3
            while not firstPoint and i < 10 do
                firstPoint = ReversePos(str:sub(1, i))
                i = i + 1
            end
            return firstPoint..str:sub(i)
        elseif pos == 2 then
            local secondPoint
            local i = string.len(str)
            local max = i
            while not secondPoint and i > 0 do
                secondPoint = ReversePos(str:sub(i, max))
                i = i - 1
            end
            return str:sub(1, i)..secondPoint
        else -- reverse both
            return ReverseAnchorPointPos(ReverseAnchorPointPos(str, 1), 2)
        end
    end
    local function ReparentOnHideShow(frame)
        frame:SetScript("OnHide", function()
        srslylawlUI.SetAuraPointsAll(unit, unitsType)
        end)
        frame:SetScript("OnShow", function()
        srslylawlUI.SetAuraPointsAll(unit, unitsType)
        end)
    end
    local unitsTable = srslylawlUI[unitsType]
    local unitFrame = unitsTable[unit].unitFrame
    local frames = auraType == "buffs" and unitsTable[unit].buffFrames or unitsTable[unit].debuffFrames
    local rowAnchor
    local path = (unitsType == "mainUnits" or unitsType == "mainFauxUnits") and "player." or "party."
    if unitsType == "mainUnits" or unitsType == "mainFauxUnits" then
        path = path .. unit.."Frame."
    end

    local anchorMethod = srslylawlUI.GetSetting(path..auraType..".anchor")
    local maxRowLength, initialAnchorPoint, initialAnchorPointRelative, anchorPoint, anchorPointRelative
    local offset = 3
    local initialXOffset, initialYOffset, xOffset, yOffset
    local defaultSize = srslylawlUI.GetSetting(path..auraType..".size")
    local frameXOffset = srslylawlUI.GetSetting(path..auraType..".xOffset")
    local frameYOffset = srslylawlUI.GetSetting(path..auraType..".yOffset")

    local anchorTo = srslylawlUI.GetSetting(path..auraType..".anchoredTo")
    if anchorTo == "Buffs" and unitsTable[unit]["buffsAnchor"] and unitsTable[unit]["buffsAnchor"]:IsShown() then
        rowAnchor = unitsTable[unit]["buffsAnchor"]
        anchorMethod = srslylawlUI.GetSetting(path.."buffs.anchor")
    elseif anchorTo == "Debuffs" and unitsTable[unit]["debuffsAnchor"] and unitsTable[unit]["debuffsAnchor"]:IsShown() then
        rowAnchor = unitsTable[unit]["debuffsAnchor"]
        anchorMethod = srslylawlUI.GetSetting(path.."debuffs.anchor")
    else
        rowAnchor = unitFrame.unit
    end

    if anchorMethod == "TOPLEFT" or anchorMethod == "TOPRIGHT" or anchorMethod == "BOTTOMLEFT" or anchorMethod == "BOTTOMRIGHT" then
        maxRowLength = srslylawlUI.GetSetting(path.."hp.width")
        initialAnchorPoint = ReverseAnchorPointPos(anchorMethod, 1)
        initialAnchorPointRelative = anchorMethod
        anchorPoint = (anchorMethod == "TOPLEFT" or anchorMethod == "BOTTOMLEFT") and "LEFT" or "RIGHT"
        anchorPointRelative = (anchorMethod == "TOPLEFT" or anchorMethod == "BOTTOMLEFT") and "RIGHT" or "LEFT"
        initialXOffset = 0
        initialYOffset = (anchorMethod == "TOPLEFT" or anchorMethod == "TOPRIGHT") and 1 or -1
        xOffset = (anchorMethod == "TOPLEFT" or anchorMethod == "BOTTOMLEFT") and 1 or -1
        yOffset = 0
    else
        maxRowLength = srslylawlUI.GetSetting(path.."hp.height")
        if anchorMethod == "LEFTBOTTOM" then
            initialAnchorPoint = "BOTTOMRIGHT"
            initialAnchorPointRelative = "BOTTOMLEFT"
            anchorPoint = "BOTTOM"
            anchorPointRelative = "TOP"
            initialXOffset, initialYOffset = -1, 0
            xOffset, yOffset = 0, 1
        elseif anchorMethod == "LEFTTOP" then
            initialAnchorPoint = "TOPRIGHT"
            initialAnchorPointRelative = "TOPLEFT"
            anchorPoint = "TOP"
            anchorPointRelative = "BOTTOM"
            initialXOffset, initialYOffset = -1, 0
            xOffset, yOffset = 0, -1
        elseif anchorMethod == "RIGHTTOP" then
            initialAnchorPoint = "TOPLEFT"
            initialAnchorPointRelative = "TOPRIGHT"
            anchorPoint = "TOP"
            anchorPointRelative = "BOTTOM"
            initialXOffset, initialYOffset = 1, 0
            xOffset, yOffset = 0, -1
        elseif anchorMethod == "RIGHTBOTTOM" then
            initialAnchorPoint = "BOTTOMLEFT"
            initialAnchorPointRelative = "BOTTOMRIGHT"
            anchorPoint = "BOTTOM"
            anchorPointRelative = "TOP"
            initialXOffset, initialYOffset = 1, 0
            xOffset, yOffset = 0, 1
        end
    end


    local currentRowLength = 0
    if unitsTable[unit][auraType.."Anchor"] then
        unitsTable[unit][auraType.."Anchor"]:SetScript("OnHide", nil)
    end
    local rowHasScaledFrame = false
    local lastRowHasScaledFrame = rowAnchor.rowHasScaledFrame or false
    local rowAnchorIsScaled = rowAnchor.isScaled or false
    local lastAnchorWasOffset = false
    local anchorFrame
    for i=1, #frames do
        local frame = frames[i]
        local frameSize = frame.size or defaultSize
        if frameSize > defaultSize then
            rowHasScaledFrame = true
        end
        frame:ClearAllPoints()
        if i == 1 then
            frame.anchor = rowAnchor
            if not rowAnchorIsScaled and lastRowHasScaledFrame and rowAnchor.size then --if rowanchor is not scaled and their row had a scaled frame
                local scaledOffset = (frameSize-rowAnchor.size) / 2
                srslylawlUI.Utils_SetPointPixelPerfect(frame, initialAnchorPoint, rowAnchor, initialAnchorPointRelative, (initialXOffset*offset)+frameXOffset+(initialXOffset*scaledOffset), (initialYOffset*offset)+frameYOffset+(initialYOffset*scaledOffset))
            else
                srslylawlUI.Utils_SetPointPixelPerfect(frame, initialAnchorPoint, rowAnchor, initialAnchorPointRelative, (initialXOffset*offset)+frameXOffset, (initialYOffset*offset)+frameYOffset)
            end
            rowAnchor = frame
            if frame:IsShown() then
                unitsTable[unit][auraType.."Anchor"] = frame
                anchorFrame = frame
                anchorFrame.size = frameSize
                rowHasScaledFrame = frameSize > defaultSize
                rowAnchorIsScaled = rowHasScaledFrame
                lastAnchorWasOffset = false
            else
                unitsTable[unit][auraType.."Anchor"] = unitFrame.unit
            end
            ReparentOnHideShow(frame)
            currentRowLength = frameSize
        else
            if currentRowLength + frameSize + offset > maxRowLength then
                --doesnt fit into row
                frame.anchor = rowAnchor
                if rowHasScaledFrame and not rowAnchorIsScaled and rowAnchor.size then
                    local scaledOffset = (frameSize-rowAnchor.size) / 2
                    srslylawlUI.Utils_SetPointPixelPerfect(frame, initialAnchorPoint, rowAnchor, initialAnchorPointRelative, (initialXOffset*offset)+(initialXOffset*scaledOffset), (initialYOffset*offset)+(initialYOffset*scaledOffset))
                else
                    srslylawlUI.Utils_SetPointPixelPerfect(frame, initialAnchorPoint, rowAnchor, initialAnchorPointRelative, (initialXOffset*offset), (initialYOffset*offset))
                end

                rowAnchor = frame
                if frame:IsShown() then
                    unitsTable[unit][auraType.."Anchor"] = frame
                    anchorFrame = frame
                    anchorFrame.size = frameSize
                    frame.rowHasScaledFrame = rowHasScaledFrame
                    rowHasScaledFrame = frameSize > defaultSize
                    rowAnchorIsScaled = rowHasScaledFrame
                    lastAnchorWasOffset = false
                end
                ReparentOnHideShow(frame)
                currentRowLength = frameSize
            else
                srslylawlUI.Utils_SetPointPixelPerfect(frame, anchorPoint, frames[i-1], anchorPointRelative, xOffset*offset, yOffset*offset)
                currentRowLength = currentRowLength + frameSize + offset
                frame:SetScript("OnHide", nil)
                frame:SetScript("OnShow", nil)
            end
        end
        if rowHasScaledFrame and anchorFrame and not rowAnchorIsScaled and not lastAnchorWasOffset then
            lastAnchorWasOffset = true
            scaledSize = frameSize
            local scaledOffset = (frameSize-anchorFrame.size) / 2
            if anchorFrame.anchor.size and anchorFrame.anchor.size == anchorFrame.size then
                scaledOffset = scaledOffset * 2
            end
            if anchorFrame == frames[1] then
                srslylawlUI.Utils_SetPointPixelPerfect(anchorFrame, initialAnchorPoint, anchorFrame.anchor, initialAnchorPointRelative, (initialXOffset*offset)+frameXOffset+(initialXOffset*scaledOffset), (initialYOffset*offset)+frameYOffset+(initialYOffset*scaledOffset))
            else
                srslylawlUI.Utils_SetPointPixelPerfect(anchorFrame, initialAnchorPoint, anchorFrame.anchor, initialAnchorPointRelative, (initialXOffset*offset)+(initialXOffset*scaledOffset), (initialYOffset*offset)+(initialYOffset*scaledOffset))
            end

            anchorFrame.rowHasScaledFrame = true
            anchorFrame.isScaled = anchorFrame.size > defaultSize
        end
        srslylawlUI.Utils_SetSizePixelPerfect(frame, frameSize, frameSize)
    end
end
function srslylawlUI.SetAuraPointsAll(unit, unitsType)
    --order matters depending on what is anchored to what
    if srslylawlUI.GetSettingByUnit("buffs.anchoredTo", unitsType, unit) == "Debuffs" then
        srslylawlUI.SetAuraPoints(unit, unitsType, "debuffs")
        srslylawlUI.SetAuraPoints(unit, unitsType, "buffs")
    else
        srslylawlUI.SetAuraPoints(unit, unitsType, "buffs")
        srslylawlUI.SetAuraPoints(unit, unitsType, "debuffs")
    end
end

function srslylawlUI.Frame_GetFrameByUnit(unit, unitsType)
    -- returns buttonframe that matches unit attribute
    return srslylawlUI[unitsType][unit].unitFrame
end
function srslylawlUI.Frame_MakeFrameMoveable(frame)
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and not self.isMoving and self:IsMovable() then
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


function srslylawlUI.Frame_GetCustomPowerBarColor(powerToken)
    if type(powerToken) == "string" then
        powerToken = string.upper(powerToken)
    end
    local color = PowerBarColor[powerToken]
    if powerToken == "MANA" or powerToken == 0 then
        color = {r=0.349, g=0.522, b=0.953}
    elseif powerToken == "LUNAR_POWER" or powerToken == "MAELSTROM" then
        color = {r=0, g=0, b=1}
    end
    color = color or {r=1, g=1, b=1}
    return color
end
function srslylawlUI.Frame_ResizeHealthBarScale()
    local list, highestHP, averageHP = srslylawlUI.GetPartyHealth()

    if not highestHP then
        return
    end

    --only one sortmethod for now
    local scaleByHighest = true
    local lowerCap = srslylawlUI.GetSetting("party.hp.minWidthPercent") -- bars can not get smaller than this percent of highest
    local pixelPerHp = srslylawlUI.GetSetting("party.hp.width") / highestHP
    local minWidth = floor(highestHP * pixelPerHp * lowerCap)

    if scaleByHighest then
        for unit, _ in pairs(srslylawlUI.unitHealthBars) do
            local scaledWidth = (srslylawlUI.unitHealthBars[unit]["maxHealth"] * pixelPerHp)
            scaledWidth = scaledWidth < minWidth and minWidth or scaledWidth
            srslylawlUI.unitHealthBars[unit]["width"] = scaledWidth
        end
    else -- sort by something else, NYI
    end
    srslylawlUI.Frame_Party_ResetDimensions_ALL()
end



function srslylawlUI.Frame_ReadyCheck(button, state)
    local rc = button.ReadyCheck

    if state == "end" then
        --hide
        button.ReadyCheck:SetScript("OnUpdate", function(self, elapsed)
            local alpha = self:GetAlpha()
            alpha = alpha - elapsed*0.1
            if alpha <= 0 then
               self:Hide()
               self:SetScript("OnUpdate", nil)
               return
            else
                self:SetAlpha(alpha)
            end
        end)
    elseif state == "start" then
        button.ReadyCheck.texture:SetTexture("Interface/RAIDFRAME/ReadyCheck-Waiting")
        button.ReadyCheck:SetAlpha(1)
        button.ReadyCheck:Show()
    elseif state == "ready" then
        button.ReadyCheck.texture:SetTexture("Interface/RAIDFRAME/ReadyCheck-Ready")
        button.ReadyCheck:SetAlpha(1)
        button.ReadyCheck:Show()
    elseif state == "notready" then
        button.ReadyCheck.texture:SetTexture("Interface/RAIDFRAME/ReadyCheck-NotReady")
        button.ReadyCheck:SetAlpha(1)
        button.ReadyCheck:Show()
    end
end
function srslylawlUI.Frame_UpdateCombatIcon(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
	if self.timer <= .5 then return end
	self.timer = self.timer - .5
    srslylawlUI.Frame_SetCombatIcon(self)
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
        -- not all units are properly loaded yet, lets check again in a few secs
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
        local buttonFrame = srslylawlUI.Frame_GetFrameByUnit(list[i].unit, "partyUnits").unit

        if (buttonFrame) then
            buttonFrame:ClearAllPoints()
            if i == 1 then
                buttonFrame:SetPoint("TOPLEFT", srslylawlUI_PartyHeader, "TOPLEFT")
            else
                local parent = srslylawlUI.Frame_GetFrameByUnit(list[i - 1].unit, "partyUnits").unit
                srslylawlUI.Utils_SetPointPixelPerfect(buttonFrame, "TOPLEFT", parent, "BOTTOMLEFT", 0, -1)
            end
            srslylawlUI.Frame_ResetUnitButton(buttonFrame, list[i].unit)
        end
    end

end
function srslylawlUI.UpdateEverything()
    if not InCombatLockdown() then
        srslylawlUI.SortPartyFrames()
        srslylawlUI.Frame_ResizeHealthBarScale()
        srslylawlUI.Frame_Main_ResetDimensions_ALL()
    else
        C_Timer.After(1, function() srslylawlUI.UpdateEverything() end)
    end
end
