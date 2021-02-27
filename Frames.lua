local function CreateBuffFrames(buttonFrame, unit)
    local frameName = "srslylawlUI_"..unit.."Aura"
    local unitsType = buttonFrame:GetAttribute("unitsType")
    local parent
    for i = 1, srslylawlUI.settings.party.buffs.maxBuffs do
        local xOffset, yOffset = srslylawlUI.Party_GetBuffOffsets()
        local anchor = srslylawlUI.settings.party.buffs.growthDir
        local f = CreateFrame("Button", frameName .. i, buttonFrame.unit.auraAnchor, "CompactBuffTemplate")
        f:ClearAllPoints()
        if (i == 1) then
            anchor = srslylawlUI.settings.party.buffs.anchor
            xOffset = srslylawlUI.settings.party.buffs.xOffset
            yOffset = srslylawlUI.settings.party.buffs.yOffset
            f:SetPoint(anchor, srslylawlUI.Utils_PixelFromCodeToScreen(xOffset), srslylawlUI.Utils_PixelFromCodeToScreen(yOffset))
        else
            srslylawlUI.Utils_SetPointPixelPerfect(f, "CENTER", parent, "CENTER", xOffset, yOffset)
        end
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
        srslylawlUI[unitsType][unit].buffFrames[i] = f
        parent = f
        f:Hide()
    end
end
local function CreateDebuffFrames(buttonFrame, unit)
    local frameName = "srslylawlUI_"..unit.."Debuff"
    local unitsType = buttonFrame:GetAttribute("unitsType")
    local parent
    for i = 1, srslylawlUI.settings.party.debuffs.maxDebuffs do
            local xOffset, yOffset = srslylawlUI.Party_GetDebuffOffsets()
            local anchor = srslylawlUI.settings.party.debuffs.growthDir
            local f = CreateFrame("Button", frameName .. i, buttonFrame.unit.auraAnchor, "CompactDebuffTemplate")
            f:ClearAllPoints()
            if (i == 1) then
                anchor = srslylawlUI.settings.party.debuffs.anchor
                xOffset = srslylawlUI.settings.party.debuffs.xOffset
                yOffset = srslylawlUI.settings.party.debuffs.yOffset
                f:SetPoint(anchor, srslylawlUI.Utils_PixelFromCodeToScreen(xOffset), srslylawlUI.Utils_PixelFromCodeToScreen(yOffset))
            else
                srslylawlUI.Utils_SetPointPixelPerfect(f, "CENTER", parent, "CENTER", xOffset, yOffset)
            end
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
            srslylawlUI[unitsType][unit].debuffFrames[i] = f
            parent = f
            f:Hide()
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
        f.background.texture:SetColorTexture(0, 0, 0, .5)
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
        f.texture.bg = f:CreateTexture(nil, "BACKGROUND")
        f.texture.bg:SetTexture(srslylawlUI.textures.EffectiveHealth, true, "MIRROR")
        f.texture.bg:SetVertTile(true)
        f.texture.bg:SetHorizTile(true)
        f.texture.bg:SetAllPoints()
        f.texture.bg:SetVertexColor(1, 1, 1, 1)
        f.texture.bg:SetBlendMode("MOD")
        
        
        local class = UnitClassBase(unit)
        local color = {GetClassColor(class)}
        color[4] = 0.7
        f.texture:SetVertexColor(unpack(color))
        f:Hide()
        f:SetFrameLevel(5)
        buttonFrame.unit.healthBar.effectiveHealthFrame = f
        srslylawlUI[unitsType][unit]["effectiveHealthFrames"][i] = f
    end
    --create absorb frames
    for i = 1, srslylawlUI.settings.party.maxAbsorbFrames do
        local parentFrame = (i == 1 and buttonFrame.unit.healthBar) or srslylawlUI[unitsType][unit].absorbFrames[i - 1]
        CreateAbsorbFrame(parentFrame, i, srslylawlUI[unitsType][unit].absorbFrames, unit)
    end
    --overlap frames (absorb/incoming heal that exceeds maximum health)
    for i = 1, srslylawlUI.settings.party.maxAbsorbFrames do
        local parentFrame = (i == 1 and buttonFrame.unit.healthBar) or srslylawlUI[unitsType][unit].absorbFramesOverlap[i - 1]
        CreateAbsorbFrame(parentFrame, i, srslylawlUI[unitsType][unit].absorbFramesOverlap, unit)
    end
    --effective health frame (sums up active defensive spells)
    CreateEffectiveHealthFrame(buttonFrame, unit, 1)
end

function srslylawlUI.FrameSetup()
        local function CreateCCBar(unitFrame, unit)
            local CCDurationBar = CreateFrame("StatusBar", "$parent_CCDurBar"..unit, unitFrame.unit.auraAnchor)
            unitFrame.unit.CCDurBar = CCDurationBar
            CCDurationBar:SetStatusBarTexture(srslylawlUI.textures.HealthBar)
            local h = srslylawlUI.settings.party.hp.height*srslylawlUI.settings.party.ccbar.heightPercent
            local w = srslylawlUI.settings.party.ccbar.width
            local petW = srslylawlUI.settings.party.pet.width
            local iconSize = (w > h and h) or w
            srslylawlUI.Utils_SetSizePixelPerfect(CCDurationBar, w, h)
            CCDurationBar:SetMinMaxValues(0, 1)
            unitFrame.unit.CCDurBar.icon = unitFrame.unit.CCDurBar:CreateTexture("icon", "OVERLAY", nil, 2)
            srslylawlUI.Utils_SetPointPixelPerfect(unitFrame.unit.CCDurBar.icon, "BOTTOMLEFT", unitFrame.unit, "BOTTOMRIGHT", petW+6, 0)
            srslylawlUI.Utils_SetPointPixelPerfect(CCDurationBar, "LEFT", unitFrame.unit.CCDurBar.icon, "RIGHT", 1, 0)
            srslylawlUI.Utils_SetSizePixelPerfect(unitFrame.unit.CCDurBar.icon, iconSize, iconSize)
            unitFrame.unit.CCDurBar.icon:SetTexCoord(.08, .92, .08, .92)
            unitFrame.unit.CCDurBar.icon:SetTexture(408)
            unitFrame.unit.CCDurBar.timer = unitFrame.unit.CCDurBar:CreateFontString("$parent_Timer", "OVERLAY", "GameFontHIGHLIGHT")
            unitFrame.unit.CCDurBar.timer:SetText("5")
            unitFrame.unit.CCDurBar.timer:SetPoint("LEFT")
            srslylawlUI.CreateBackground(CCDurationBar, 0)
            unitFrame.unit.CCDurBar:Hide()
        end
        local function CreateUnitFrame(header, unit, faux, party)
            local name = party and "$parent_"..unit or "srslylawlUI_Main_"..unit
            local unitFrame = CreateFrame("Frame",name, header, "srslylawlUI_UnitTemplate")
            unitFrame:SetAttribute("unit", unit)
            unitFrame:SetAttribute("unitsType", faux and "fauxUnits" or party and "partyUnits" or "mainUnits")
            unitFrame.unit:SetAttribute("unitsType", faux and "fauxUnits" or party and "partyUnits" or "mainUnits")

            local h = srslylawlUI.settings.party.hp.height

            srslylawlUI.CreateBackground(unitFrame.unit.healthBar, 1, .8)
            srslylawlUI.CreateBackground(unitFrame.pet, 1, .8)
            srslylawlUI.CreateBackground(unitFrame.unit.powerBar, 1, .8)

            unitFrame.ReadyCheck = CreateFrame("Frame", "$parent_ReadyCheck", unitFrame)
            unitFrame.ReadyCheck:SetPoint("CENTER")
            srslylawlUI.Utils_SetSizePixelPerfect(unitFrame.ReadyCheck, h, h)
            unitFrame.ReadyCheck.texture = unitFrame.ReadyCheck:CreateTexture("$parent_ReadyCheck", "OVERLAY")
            unitFrame.ReadyCheck.texture:SetAllPoints(true)
            unitFrame.ReadyCheck.texture:SetTexture("Interface/RAIDFRAME/ReadyCheck-Waiting")
            unitFrame.ReadyCheck:SetFrameLevel(5)
            unitFrame.ReadyCheck:Hide()

            unitFrame.PartyLeader = CreateFrame("Frame", "$parent_PartyLeader", unitFrame)
            unitFrame.PartyLeader:SetPoint("TOPLEFT", unitFrame.unit, "TOPLEFT")
            unitFrame.PartyLeader:SetFrameLevel(5)
            h = h * 0.35
            -- srslylawlUI.Utils_SetSizePixelPerfect(unitFrame.PartyLeader, h, h)
            unitFrame.PartyLeader:SetSize(10, 10)
            unitFrame.PartyLeader.texture = unitFrame.PartyLeader:CreateTexture("$parent_PartyLeader", "OVERLAY")
            unitFrame.PartyLeader.texture:SetTexture("Interface/GROUPFRAME/UI-Group-LeaderIcon")
            unitFrame.PartyLeader.texture:SetAllPoints(true)
            unitFrame.PartyLeader:Hide()

            unitFrame.unit.CombatIcon = CreateFrame("Frame", "$parent_CombatIcon", unitFrame)
            unitFrame.unit.CombatIcon.texture = unitFrame.unit.CombatIcon:CreateTexture("$parent_Icon", "OVERLAY")
            unitFrame.unit.CombatIcon.texture:SetTexture("Interface/CHARACTERFRAME/UI-StateIcon")
            unitFrame.unit.CombatIcon.texture:SetAllPoints(true)
            --set texture to combat icon
            unitFrame.unit.CombatIcon.texture:SetTexCoord(0.5, 1, 0, .5)
            -- unitFrame.unit.CombatIcon.texture:SetTexCoord(0, .5, 0, .5)
            -- unitFrame.CombatIcon.texture:SetTexCoord(0.5, 1, 0, .5)
            srslylawlUI.Utils_SetSizePixelPerfect(unitFrame.unit.CombatIcon, h, h)
            srslylawlUI.Utils_SetPointPixelPerfect(unitFrame.unit.CombatIcon, "BOTTOMLEFT", unitFrame.unit, "BOTTOMLEFT", -4, -2)
            unitFrame.unit.CombatIcon:SetFrameLevel(4)
            unitFrame.unit.CombatIcon.texture:Hide()

            if not faux then
                unitFrame.unit.healthBar.immuneTex = unitFrame.unit.healthBar:CreateTexture("srslylawlUI_Textures_ImmuneTextureObject"..unit, "BACKGROUND")
                unitFrame.unit.healthBar.immuneTex:SetHorizTile(true)
                unitFrame.unit.healthBar.immuneTex:SetBlendMode("BLEND")
                unitFrame.unit.healthBar.isImmune = false
            end
            if party then
                header[unit] = unitFrame
            end
            CreateCCBar(unitFrame, unit)
            
            return unitFrame
        end
        local header = CreateFrame("Frame", "srslylawlUI_PartyHeader", nil)
        header:SetSize(srslylawlUI.settings.party.hp.width, srslylawlUI.settings.party.hp.height)
        header:SetPoint(srslylawlUI.settings.party.header.anchor, srslylawlUI.settings.party.header.xOffset, srslylawlUI.settings.party.header.yOffset)
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
            local faux = CreateUnitFrame(fauxHeader, unit, true, true)

            CreateBuffFrames(frame, unit)
            CreateDebuffFrames(frame, unit)
            CreateCustomFrames(frame, unit)
            
            --initial sorting
            if unit == "player" then
                frame:SetPoint("TOPLEFT", header, "TOPLEFT")
            else
                frame:SetPoint("TOPLEFT", parent, "BOTTOMLEFT")
            end

            srslylawlUI.Frame_InitialPartyUnitConfig(frame, false)
            srslylawlUI.Frame_InitialPartyUnitConfig(faux, true)

            parent = frame
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

            CreateBuffFrames(frame, unit)
            CreateDebuffFrames(frame, unit)
            CreateCustomFrames(frame, unit)

            local a = srslylawlUI.settings.player[unit.."Frame"].position

            if a and #a > 1 then
                srslylawlUI.Utils_SetPointPixelPerfect(frame, a[1], a[2], a[3], a[4], a[5])
            elseif unit == "targettarget" then
                frame:SetPoint("TOPLEFT", srslylawlUI.mainUnits.target.unitFrame, "TOPRIGHT", 0, 0)
            elseif unit == "target" then
                frame:SetPoint("TOPLEFT", nil, "CENTER", 0, 0)
            elseif unit == "player" then
                frame:SetPoint("TOPRIGHT", nil, "CENTER", 0, 0)
            end

            
            
            srslylawlUI.Frame_InitialMainUnitConfig(frame)
        end
        srslylawlUI.Frame_UpdateVisibility()
end

--party
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

    buttonFrame.PartyLeader:SetShown(UnitIsGroupLeader(unit))

    srslylawlUI.Frame_ResetDimensions_Pet(buttonFrame)
    srslylawlUI.Frame_ResetDimensions_PowerBar(buttonFrame)
    srslylawlUI.Frame_ResetDimensions(buttonFrame)
end
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
        local point, relativeTo, relativePoint, xOfs, yOfs =
        srslylawlUI_PartyHeader:GetPoint()
        srslylawlUI.settings.party.header.anchor = point
        srslylawlUI.settings.party.header.xOffset = xOfs
        srslylawlUI.settings.party.header.yOffset = yOfs
        srslylawlUI.SetDirtyFlag()
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

--main
function srslylawlUI.Frame_InitialMainUnitConfig(buttonFrame)
    srslylawlUI.SetupUnitFrame(buttonFrame)
    local unit = buttonFrame:GetAttribute("unit")
    
    srslylawlUI.RegisterEvents(buttonFrame)
    RegisterUnitWatch(buttonFrame)
    buttonFrame:SetMovable(false)
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
        buttonFrame.CastBar = srslylawlUI.CreateCastBar(frame, unit)
        srslylawlUI.Utils_SetPointPixelPerfect(buttonFrame.CastBar, "TOPLEFT", buttonFrame.unit, "BOTTOMLEFT", 0, -1)
        srslylawlUI.Utils_SetPointPixelPerfect(buttonFrame.CastBar, "BOTTOMRIGHT", buttonFrame.unit, "BOTTOMRIGHT", 0, -41)
    elseif unit == "targettarget" then
        buttonFrame.unit.healthBar.text:Hide()
    end

    buttonFrame.PartyLeader:SetShown(UnitIsGroupLeader(unit))
    srslylawlUI.Frame_ResetDimensions_PowerBar(buttonFrame)
    srslylawlUI.Frame_ResetDimensions(buttonFrame)
end
function srslylawlUI.Frame_Main_ResetDimensions_ALL()
    for _, unit in pairs(srslylawlUI.mainUnitsTable) do
        local button = srslylawlUI.mainUnits[unit].unitFrame
        if button then
            srslylawlUI.Frame_ResetDimensions(button)
            srslylawlUI.Frame_ResetDimensions_PowerBar(button)
            if unit == "player" then
                srslylawlUI.Frame_ResetDimensions_Pet(button)
            end
            --srslylawlUI.Frame_ResetCCDurBar(button)
        end
    end
end
function srslylawlUI.Frame_ResetCCDurBar(button)
    local h = srslylawlUI.settings.party.hp.height
    local h2 = h*srslylawlUI.settings.party.ccbar.heightPercent
    local w = srslylawlUI.settings.party.ccbar.width
    local iconSize = (w > h2 and h2) or w
    srslylawlUI.Utils_SetSizePixelPerfect(button.unit.CCDurBar, w, h2)
    srslylawlUI.Utils_SetSizePixelPerfect(button.unit.CCDurBar.icon, iconSize, iconSize)
end
function srslylawlUI.PlayerFrame_OnDragStart(self)
    self = self:GetParent()
    if self:IsMovable() then
        self.isMoving = true
        self:StartMoving()
    end
end
function srslylawlUI.PlayerFrame_OnDragStop(self)
    self = self:GetParent()
    if self.isMoving then
        self:StopMovingOrSizing()
        self.isMoving = false
        local points = {self:GetPoint()}
        local offsets = {srslylawlUI.Utils_PixelFromScreenToCode(points[4], points[5])}
        srslylawlUI.settings.player[self:GetAttribute("unit").."Frame"].position = {points[1], points[2], points[3], unpack(offsets)}
        srslylawlUI.SetDirtyFlag()
    end
end


function srslylawlUI.Frame_ResetDimensions(button)
    local unit = button:GetAttribute("unit")
    local unitsType = button:GetAttribute("unitsType")
    local h, w
    local checkFrame = button.unit.healthBar
    if unitsType == "partyUnits" or unitsType == "fauxUnits" then
        h = srslylawlUI.settings.party.hp.height
        w = srslylawlUI.settings.party.hp.width
        if srslylawlUI.unitHealthBars ~= nil then
        if srslylawlUI.unitHealthBars[unit] ~= nil then
            if srslylawlUI.unitHealthBars[unit]["width"] ~= nil then
                w = srslylawlUI.unitHealthBars[unit]["width"]
            end
        end
        end
    elseif unitsType == "mainUnits" then
        h = srslylawlUI.settings.player[unit.."Frame"].hp.height
        w = srslylawlUI.settings.player[unit.."Frame"].hp.width
        checkFrame = button
    end

    local widthDiff = abs(srslylawlUI.Utils_PixelFromScreenToCode(checkFrame:GetWidth()) - w)
    local heightDiff = abs(srslylawlUI.Utils_PixelFromScreenToCode(checkFrame:GetHeight()) - h)
    local tolerance = 1
    local needsResize = widthDiff > tolerance or heightDiff > tolerance
    if needsResize or unitsType == "mainUnits" then
        srslylawlUI.Utils_SetSizePixelPerfect(button.unit.auraAnchor, w, h)
        srslylawlUI.Utils_SetSizePixelPerfect(button.unit.healthBar, w, h)
        srslylawlUI.Utils_SetHeightPixelPerfect(button.unit.powerBar, h)

        if unitsType ~= "fauxUnits" then
            srslylawlUI.MoveAbsorbAnchorWithHealth(unit, unitsType)
        end

        if not InCombatLockdown() then
            -- stuff that taints in combat
            local frameH = unitsType ~= "mainUnits" and srslylawlUI.settings.party.hp.height or srslylawlUI.settings.player[unit.."Frame"].hp.height
            local frameW = unitsType ~= "mainUnits" and srslylawlUI.settings.party.hp.width or srslylawlUI.settings.player[unit.."Frame"].hp.width
            srslylawlUI.Utils_SetSizePixelPerfect(button, frameW+1, frameH+1)
            srslylawlUI.Utils_SetSizePixelPerfect(button.unit, frameW, frameH)
        end
    end

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
        srslylawlUI.Utils_SetPointPixelPerfect(button.pet, "BOTTOMRIGHT", button.unit, "BOTTOMRIGHT", srslylawlUI.settings.party.pet.width, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(button.unit.CCDurBar.icon, "BOTTOMLEFT", button.unit, "BOTTOMRIGHT", srslylawlUI.settings.party.pet.width+4, 0)
    else
        local unit = button:GetAttribute("unit")
        if unit == "player" then
            button.pet:ClearAllPoints()
            srslylawlUI.Utils_SetPointPixelPerfect(button.pet, "TOPRIGHT", button.unit, "TOPLEFT", -1, 0)
            srslylawlUI.Utils_SetPointPixelPerfect(button.pet, "BOTTOMLEFT", button.unit, "BOTTOMLEFT", -srslylawlUI.settings.player[unit.."Frame"].pet.width, 0)
        end
    end

end
function srslylawlUI.Frame_ResetDimensions_PowerBar(button)
    local unitsType = button:GetAttribute("unitsType")
    if unitsType ~= "mainUnits" then
        srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "BOTTOMRIGHT", button.unit, "BOTTOMLEFT", -1, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "TOPLEFT", button.unit, "TOPLEFT", -(2+srslylawlUI.settings.party.power.width), 0)
    else
        local unit = button:GetAttribute("unit")
        if unit == "targettarget" then
            srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "BOTTOMLEFT", button.unit, "BOTTOMRIGHT", 1, 0)
            srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "TOPRIGHT", button.unit, "TOPRIGHT", 2+srslylawlUI.settings.player[unit.."Frame"].power.width, 0)
        else

            srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "BOTTOMRIGHT", button.unit, "BOTTOMLEFT", -1, 0)
            srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "TOPLEFT", button.unit, "TOPLEFT", -(2+srslylawlUI.settings.player[unit.."Frame"].power.width), 0)
        end
    end
end
function srslylawlUI.Party_SetBuffFrames()
    for k, v in pairs(srslylawlUI.partyUnits) do
        local frame = srslylawlUI.partyUnits[k]
        if frame ~= nil and frame.buffFrames ~= nil then
            for i = 1, srslylawlUI.settings.party.buffs.maxBuffs do
                local size = srslylawlUI.settings.party.buffs.size
                local xOffset, yOffset = srslylawlUI.Party_GetBuffOffsets()
                local anchor = "CENTER"
                frame.buffFrames[i]:ClearAllPoints()
                if frame.buffFrames[i] == nil then
                    srslylawlUI.Log('Max visible buffs setting has been changed, please reload UI by typing "/reload" ')
                    error('Max visible buffs setting has been changed, please reload UI by typing "/reload" ')
                end
                if (i == 1) then
                    anchor = srslylawlUI.settings.party.buffs.anchor
                    xOffset = srslylawlUI.settings.party.buffs.xOffset
                    yOffset = srslylawlUI.settings.party.buffs.yOffset
                    frame.buffFrames[i]:SetParent(srslylawlUI.Frame_GetFrameByUnit(k, "partyUnits").unit.auraAnchor)
                    frame.buffFrames[i]:SetPoint(anchor, srslylawlUI.Utils_PixelFromCodeToScreen(xOffset), srslylawlUI.Utils_PixelFromCodeToScreen(yOffset))
                else
                    srslylawlUI.Utils_SetPointPixelPerfect(frame.buffFrames[i], anchor, frame.buffFrames[i-1], anchor, xOffset, yOffset)
                end
                srslylawlUI.Utils_SetSizePixelPerfect(frame.buffFrames[i], size, size)
            end
        end
    end
end
function srslylawlUI.Party_SetDebuffFrames()
    for k, v in pairs(srslylawlUI.partyUnits) do
        local frame = srslylawlUI.partyUnits[k]
        if frame ~= nil and frame.debuffFrames ~= nil then
            for i = 1, srslylawlUI.settings.party.debuffs.maxDebuffs do
                local size = srslylawlUI.settings.party.debuffs.size
                local xOffset, yOffset = srslylawlUI.Party_GetDebuffOffsets()
                local anchor = "CENTER"
                if frame.debuffFrames[i] == nil then
                    srslylawlUI.Log('Max visible debuffs setting has been changed, please reload UI by typing "/reload" ')
                    error('Max visible debuffs setting has been changed, please reload UI by typing "/reload" ')
                end
                frame.debuffFrames[i]:ClearAllPoints()
                if (i == 1) then
                    anchor = srslylawlUI.settings.party.debuffs.anchor
                    xOffset = srslylawlUI.settings.party.debuffs.xOffset
                    yOffset = srslylawlUI.settings.party.debuffs.yOffset
                    frame.debuffFrames[i]:SetParent(srslylawlUI.Frame_GetFrameByUnit(k, "partyUnits").unit.auraAnchor)
                    frame.debuffFrames[i]:SetPoint(anchor, srslylawlUI.Utils_PixelFromCodeToScreen(xOffset), srslylawlUI.Utils_PixelFromCodeToScreen(yOffset))
                else
                    srslylawlUI.Utils_SetPointPixelPerfect(frame.debuffFrames[i], anchor, frame.debuffFrames[i-1], anchor, xOffset, yOffset)
                end
                srslylawlUI.Utils_SetSizePixelPerfect(frame.debuffFrames[i], size, size)
            end
        end
    end
end
function srslylawlUI.Party_GetBuffOffsets()
    local xOffset, yOffset
    local size = srslylawlUI.settings.party.buffs.size
    local growthDir = srslylawlUI.settings.party.buffs.growthDir
    if growthDir == "LEFT" then
        xOffset = -size
        yOffset = 0
    elseif growthDir == "RIGHT" then
        xOffset = size
        yOffset = 0
    elseif growthDir == "TOP" then
        xOffset = 0
        yOffset = size
    elseif growthDir == "BOTTOM" then
        xOffset = 0
        yOffset = -size
    end
    return xOffset, yOffset
end
function srslylawlUI.Party_GetDebuffOffsets()
    local xOffset, yOffset
    local size = srslylawlUI.settings.party.debuffs.size
    local growthDir = srslylawlUI.settings.party.debuffs.growthDir
    if growthDir == "LEFT" then
        xOffset = -size
        yOffset = 0
    elseif growthDir == "RIGHT" then
        xOffset = size
        yOffset = 0
    elseif growthDir == "TOP" then
        xOffset = 0
        yOffset = size
    elseif growthDir == "BOTTOM" then
        xOffset = 0
        yOffset = -size
    end
    return xOffset, yOffset
end
function srslylawlUI.SetupUnitFrame(buttonFrame)
    buttonFrame.unit:SetFrameLevel(8)
    buttonFrame.pet:SetFrameLevel(4)
    buttonFrame.pet.healthBar:SetFrameLevel(4)
    buttonFrame.unit.healthBar:SetFrameLevel(4)
    buttonFrame.unit.powerBar:SetFrameLevel(4)
    buttonFrame.unit:RegisterForDrag("LeftButton")
    buttonFrame.unit:SetAttribute("unit", buttonFrame:GetAttribute("unit"))
    buttonFrame.pet:SetFrameRef("unit", buttonFrame.unit)
    buttonFrame.unit.powerBar:ClearAllPoints()
    srslylawlUI.Utils_SetPointPixelPerfect(buttonFrame.unit.healthBar.name,"BOTTOMLEFT", buttonFrame.unit, "BOTTOMLEFT", 12, 2)
    buttonFrame.unit.healthBar.text:SetPoint("BOTTOMRIGHT", 0, srslylawlUI.Utils_PixelFromCodeToScreen(2))
    buttonFrame.unit.healthBar.text:SetDrawLayer("OVERLAY", 7)
    buttonFrame.unit.CombatIcon:SetScript("OnUpdate", srslylawlUI.Frame_UpdateCombatIcon)
end
function srslylawlUI.RegisterEvents(buttonFrame)
    local unit = buttonFrame:GetAttribute("unit")
    buttonFrame:RegisterUnitEvent("UNIT_HEALTH", unit)
    buttonFrame:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    buttonFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)
    buttonFrame:RegisterUnitEvent("UNIT_DISPLAYPOWER", unit)
    buttonFrame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
    buttonFrame:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)
    buttonFrame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", unit)
    buttonFrame:RegisterUnitEvent("UNIT_CONNECTION", unit)
    buttonFrame:RegisterUnitEvent("UNIT_AURA", unit)
    buttonFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit)
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
function srslylawlUI_Frame_OnEvent(self, event, arg1, arg2)
    local unit = self:GetAttribute("unit")
    local unitExists = UnitExists(unit)
    local unitsType = self:GetAttribute("unitsType")
    if not unitExists then return end
    -- Handle any events that don’t accept a unit argument
    if event == "PLAYER_ENTERING_WORLD" then
        srslylawlUI.HandleAuras(self.unit, unit)
    elseif event == "GROUP_ROSTER_UPDATE" then
        self.PartyLeader:SetShown(UnitIsGroupLeader(unit))
    --     srslylawlUI.Frame_ResetUnitButton(self.unit, unit)
    --     --for new units joining that already have an absorb (usually warlocks)
    --     srslylawlUI.Frame_HandleAuras(self.unit, unit)
    --     srslylawlUI.Frame_UpdateVisibility()
    elseif event == "PLAYER_TARGET_CHANGED" then
        if unitsType == "partyUnits" then
            if UnitIsUnit(unit, "target") then
                self.unit.selected:Show()
            else
                self.unit.selected:Hide()
            end
        elseif unitsType == "mainUnits" and unit == "target" or unit == "targettarget" then
            if unit == "target" then
                if self.CastBar then
                    self.CastBar:Hide()
                    self.CastBar:Show()
                end
                self.portrait:PortraitUpdate()
            end
            srslylawlUI.Frame_SetCombatIcon(self.unit.CombatIcon)
            srslylawlUI.Frame_ResetUnitButton(self.unit, unit)
            srslylawlUI.HandleAuras(self.unit, unit)
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
                srslylawlUI.Frame_ResetUnitButton(self.unit, unit)
                srslylawlUI.HandleAuras(self.unit, unit)
            end
            self.unit.healthBar:SetMinMaxValues(0, UnitHealthMax(unit))
            self.unit.healthBar:SetValue(UnitHealth(unit))
        elseif event == "UNIT_HEALTH" then
            srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
            srslylawlUI.HandleAuras(self.unit, unit)
        elseif event == "UNIT_DISPLAYPOWER" then
            srslylawlUI.Frame_ResetPowerBar(self.unit, unit)
            if unit == "player" and unitsType == "mainUnits" then
                srslylawlUI.PowerBar.Set(self, unit)
            end
        elseif event == "UNIT_POWER_FREQUENT" then
            if unit == "player" and unitsType == "mainUnits" then
                srslylawlUI.PowerBar.Update(self, arg2)
            else
                self.unit.powerBar:SetValue(UnitPower(unit))
            end
        elseif event == "UNIT_MAXPOWER" then
            if unit == "player" and unitsType == "mainUnits" then
                srslylawlUI.PowerBar.UpdateMax(self, arg2)
            else
                self.unit.powerBar:SetMinMaxValues(0, UnitPowerMax(unit))
            end
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
            srslylawlUI.Log(UnitName(unit) .. (UnitIsConnected(unit) and " is now online." or " is now offline."))
        elseif event == "UNIT_AURA" or event == "UNIT_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_PREDICTION" then
            srslylawlUI.HandleAuras(self.unit, unit)
        elseif event == "UNIT_PHASE" then
            srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
        elseif event == "UNIT_PORTRAIT_UPDATE" and unit == "target" then
            self.portrait:PortraitUpdate()
        elseif event == "UNIT_MODEL_CHANGED" and unit == "target" then
            self.portrait:ModelUpdate()
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
    local name = UnitName(unit) or UNKNOWN
    -- local substring
    -- local maxLength = button.healthBar:GetWidth()*0.3
    -- for length = #name, 1, -1 do
    --     substring = srslylawlUI.Utils_ShortenString(name, 1, length)
    --     button.healthBar.name:SetText(substring)
    --     if button.healthBar.name:GetStringWidth() <= maxLength then
    --         return
    --     end
    -- end
    srslylawlUI.Utils_SetLimitedText(button.healthBar.name, button.healthBar:GetWidth()*0.3, name, true)
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
                button.healthBar.text:SetText("DEAD")
            elseif not online then
                button.healthBar.text:SetText("offline")
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
            button.healthBar.text:SetText(phaseReason)
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
    end
    local health = UnitHealth(unit)
    local healthMax = UnitHealthMax(unit)
    local healthPercent = ceil(health / healthMax * 100)
    srslylawlUI.Utils_SetLimitedText(button.healthBar.text, button.healthBar:GetWidth()*0.5, srslylawlUI.ShortenNumber(health) .. " " .. healthPercent .. "%")
    -- button.healthBar.text:SetText(srslylawlUI.ShortenNumber(health) .. " " .. healthPercent .. "%")
    button.healthBar:SetMinMaxValues(0, healthMax)
    button.healthBar:SetValue(health)
    button.healthBar:SetStatusBarColor(unpack(SBColor))
    if button:GetAttribute("unitsType") ~= "fauxUnits" then
        button.healthBar.effectiveHealthFrame.texture:SetVertexColor(unpack(SBColor))
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
function srslylawlUI.Frame_GetCustomPowerBarColor(powerToken)
    if type(powerToken) == "string" then
        powerToken = string.upper(powerToken)
    end
    local color = PowerBarColor[powerToken]
    if powerToken == "MANA" or powerToken == 0 then
        color = {r=0.349, g=0.522, b=0.953}
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
        for unit, _ in pairs(srslylawlUI.unitHealthBars) do
            local scaledWidth = (srslylawlUI.unitHealthBars[unit]["maxHealth"] * pixelPerHp)
            scaledWidth = scaledWidth < minWidth and minWidth or scaledWidth
            srslylawlUI.unitHealthBars[unit]["width"] = scaledWidth
        end
    else -- sort by something else, NYI
    end
    srslylawlUI.Frame_Party_ResetDimensions_ALL()
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
    if unitsType == "fauxUnits" then return end
    srslylawlUI[unitsType][unit].absorbFrames[1]:Hide()
    srslylawlUI[unitsType][unit].absorbFramesOverlap[1]:Hide()
    srslylawlUI[unitsType][unit].effectiveHealthFrames[1]:Hide()
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
function srslylawlUI.Frame_ShowImmunity(healthBar, isImmune)
    if isImmune then
        local unit = healthBar:GetParent():GetAttribute("unit")
        local class = select(2, UnitClass(unit)) or "WARRIOR"
        local classColor = RAID_CLASS_COLORS[class]
        --textureobject seems to reset after being switched from the object to the texturefile below
        --needs texture assigned again
        healthBar.immuneTex:SetTexture(srslylawlUI.textures.Immunity, true, "REPEAT")
        healthBar.immuneTex:SetVertexColor(classColor.r, classColor.g, classColor.b, classColor.a)
        healthBar:SetStatusBarTexture(healthBar.immuneTex)
    else
        healthBar:SetStatusBarTexture(srslylawlUI.textures.HealthBar)
    end
    healthBar.isImmune = isImmune
end
function srslylawlUI.Frame_UpdateCombatIcon(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
	if self.timer <= .5 then return end
	self.timer = self.timer - .5
    srslylawlUI.Frame_SetCombatIcon(self)
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
function srslylawlUI.CreateCastBar(parent, unit)
    local cBar = CreateFrame("Frame", "$parent_CastBar", parent)
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
	    		self.StatusBar.Timer:SetText(srslylawlUI.Utils_DecimalRound(self.elapsed, 1))
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
	    		self.StatusBar.Timer:SetText(srslylawlUI.Utils_DecimalRound(timeLeft, 1))
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

    cBar.StatusBar = CreateFrame("StatusBar", "$parent_StatusBar", cBar)
    cBar.StatusBar:SetStatusBarTexture(srslylawlUI.textures.HealthBar)
    cBar.StatusBar:Hide()
    cBar.Icon = cBar:CreateTexture("$parent_icon", "OVERLAY")
    cBar.Icon:SetTexCoord(.08, .92, .08, .92)
    cBar.StatusBar.Timer = cBar.StatusBar:CreateFontString("$parent_Timer", "OVERLAY", "GameFontHIGHLIGHT")
    cBar.StatusBar.SpellName = cBar.StatusBar:CreateFontString("$parent_SpellName", "OVERLAY", "GameFontHIGHLIGHT")
    srslylawlUI.Utils_SetSizePixelPerfect(cBar.Icon, 40, 40)
    cBar.Icon:SetPoint("TOPLEFT", cBar, "TOPLEFT", 0, 0)
    srslylawlUI.Utils_SetPointPixelPerfect(cBar.StatusBar, "TOPLEFT", cBar.Icon, "TOPRIGHT", 2, 0)
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
function srslylawlUI.Frame_SetupTargetFrame(frame)
    frame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	frame:RegisterEvent("UNIT_MODEL_CHANGED")
    local portrait = CreateFrame("PlayerModel", "$parent_Portrait", frame)
    srslylawlUI.Utils_SetPointPixelPerfect(portrait, "TOPLEFT", frame.unit, "TOPRIGHT", 2, 0)
    local height = srslylawlUI.Utils_PixelFromScreenToCode(frame.unit:GetHeight())
    srslylawlUI.Utils_SetPointPixelPerfect(portrait, "BOTTOMRIGHT", frame.unit, "BOTTOMRIGHT", height+2, 0)
    portrait:SetAlpha(1)
    portrait:SetUnit("target")
    portrait:SetPortraitZoom(1)
    portrait:Show()
    srslylawlUI.CreateBackground(portrait)
    portrait.ModelUpdate = function(self)
        if not UnitIsVisible("target") or not UnitIsConnected("target") then
            self:ClearModel()
	        self:SetModelScale(5.5)
	        self:SetPosition(0, 0, -0.8)
	        self:SetModel("Interface\\Buttons\\talktomequestionmark.m2")
        else
            self:ClearModel()
		    self:SetUnit("target")
		    self:SetPortraitZoom(1)
		    self:SetPosition(0, 0, 0)
		    self:Show()
        end
    end
    portrait.PortraitUpdate = function(self)
        local guid = UnitGUID("target")
		if( self.guid ~= guid ) then
			self:ModelUpdate()
		end
        
        self.guid = guid
    end
    frame.portrait = portrait
    

end

--Sorting
function srslylawlUI.BarHandler_Create(frame, barParent)
    frame.BarHandler = CreateFrame("Frame", "$parent_BarHandler", frame)

    local bh = frame.BarHandler
    bh.barParent = barParent

    bh.bars = {}


    function frame:RegisterBar(bar, priority, height)
        for _, v in pairs(bh.bars) do
            if v.bar == bar then
                v.priority = priority
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
            bar:HookScript("OnHide", function() print("hide") self:SetPoints() end)
        end
        
        bar:SetScript("OnHide", function() self:SetPoints() end)

        self:SortBars()
    end
    function frame:UnregisterBar(bar)
        local found
        for k, v in pairs(bh.bars) do
            if v.bar == bar then
                found = k
                return
            end
        end
        if not found then
            return 
        end

        table.remove(bh.bars, found)
        bar:Hide()
        self:SortBars()
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
            if currentBar:IsShown() and currentBar:GetAlpha() > .9 then --ignore if the bar isnt visible
                if not lastBar then
                    srslylawlUI.Utils_SetPointPixelPerfect(currentBar, "TOPLEFT", bh.barParent, "BOTTOMLEFT", 0, -1)
                    srslylawlUI.Utils_SetPointPixelPerfect(currentBar, "BOTTOMRIGHT", bh.barParent, "BOTTOMRIGHT", 0, -1-height)
                else
                    srslylawlUI.Utils_SetPointPixelPerfect(currentBar, "TOPLEFT", lastBar, "BOTTOMLEFT", 0, -1)
                    srslylawlUI.Utils_SetPointPixelPerfect(currentBar, "BOTTOMRIGHT", lastBar, "BOTTOMRIGHT", 0, -1-height)
                end
                if currentBar.SetPoints then
                    currentBar:SetPoints()
                    currentBar.pointsSet = true
                end
                lastBar = currentBar
            elseif currentBar.SetPoints and not currentBar.pointsSet then
                currentBar:SetPoints()
                currentBar.pointsSet = true
            end
        end
    end
end
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
        local buttonFrame = srslylawlUI.Frame_GetFrameByUnit(list[i].unit, "partyUnits")

        if (buttonFrame) then
            buttonFrame:ClearAllPoints()
            if i == 1 then
                buttonFrame:SetPoint("TOPLEFT", srslylawlUI_PartyHeader, "TOPLEFT")
            else
                local parent = srslylawlUI.Frame_GetFrameByUnit(list[i - 1].unit, "partyUnits")
                srslylawlUI.Utils_SetPointPixelPerfect(buttonFrame, "TOPLEFT", parent, "BOTTOMLEFT", 0, -1)
            end
            srslylawlUI.Frame_ResetUnitButton(buttonFrame.unit, list[i].unit)
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
