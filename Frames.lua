local function CalcAuraCountFontSize(size)
    local fontSize = size / 2
    return fontSize > 0 and fontSize or 1
end

function srslylawlUI.CreateBuffFrames(buttonFrame, unit)
    local frameName = "srslylawlUI_" .. unit .. "Aura"
    local unitsType = buttonFrame:GetAttribute("unitsType")
    if not srslylawlUI[unitsType][unit].buffData then srslylawlUI[unitsType][unit].buffData = {} end
    local maxBuffs = srslylawlUI.GetSettingByUnit("buffs.maxBuffs", unitsType, unit)
    if unitsType == "fauxUnits" or unitsType == "mainFauxUnits" then maxBuffs = 40 end
    local size = srslylawlUI.GetSettingByUnit("buffs.size", unitsType, unit)
    local texture = size >= 64 and srslylawlUI.textures.AuraBorder64 or srslylawlUI.textures.AuraBorder32
    local swipeTexture = size >= 64 and srslylawlUI.textures.AuraSwipe64 or srslylawlUI.textures.AuraSwipe32
    local fontSize = CalcAuraCountFontSize(size)

    for i = 1, maxBuffs do
        if not srslylawlUI[unitsType][unit].buffFrames[i] then --so we can call this function multiple times
            local f = CreateFrame("Button", frameName .. i, buttonFrame.unit, "CompactBuffTemplate")
            f:SetAttribute("unit", unit)
            f:SetScript("OnLoad", nil)
            f:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(f, "ANCHOR_RIGHT", 0, 0)
                GameTooltip:SetUnitBuff(self:GetAttribute("unit"), self:GetID())
            end)
            f:SetScript("OnUpdate", nil)
            --shift-Right click blacklists spell
            f:SetScript("OnClick", function(self, button, down)
                local id = self:GetID()
                local unit = self:GetAttribute("unit")
                if button == "RightButton" and IsShiftKeyDown() then
                    GameTooltip:SetOwner(f, "ANCHOR_RIGHT", 0, 0)
                    local spellID = select(10, UnitAura(unit, id, "HELPFUL"))
                    srslylawlUI.Auras_BlacklistSpell(spellID, "buffs")
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
            f.count:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
            f.count:SetPoint("BOTTOMRIGHT")
            local oldSetPoint = f.SetPoint
            f.SetPoint = function(self, ...)
                oldSetPoint(self, ...)
                local x, y = self:GetSize()
                local avg = (x + y) * .5
                f.count:SetFont("Fonts\\FRIZQT__.TTF", CalcAuraCountFontSize(avg), "OUTLINE")
            end
            srslylawlUI[unitsType][unit].buffFrames[i] = f
            f:Hide()
        end
    end

    for i = maxBuffs, 40 do
        if srslylawlUI[unitsType][unit].buffFrames[i] then
            srslylawlUI[unitsType][unit].buffFrames[i]:Hide()
        end
    end
end

function srslylawlUI.CreateDebuffFrames(buttonFrame, unit)
    local frameName = "srslylawlUI_" .. unit .. "Debuff"
    local unitsType = buttonFrame:GetAttribute("unitsType")
    if not srslylawlUI[unitsType][unit].debuffData then srslylawlUI[unitsType][unit].debuffData = {} end
    local maxBuffs = srslylawlUI.GetSettingByUnit("debuffs.maxDebuffs", unitsType, unit)
    if unitsType == "fauxUnits" or unitsType == "mainFauxUnits" then maxBuffs = 40 end
    local size = srslylawlUI.GetSettingByUnit("debuffs.maxDebuffs", unitsType, unit)
    local texture = size >= 64 and srslylawlUI.textures.AuraBorder64 or srslylawlUI.textures.AuraBorder32
    local swipeTexture = size >= 64 and srslylawlUI.textures.AuraSwipe64 or srslylawlUI.textures.AuraSwipe32
    local fontSize = size / 2
    fontSize = fontSize > 0 and fontSize or 1
    fontSize = srslylawlUI.Utils_PixelFromCodeToScreen(fontSize)
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
                end
            end)
            f:SetScript("OnUpdate", nil)
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

            f.count:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
            f.count:SetPoint("BOTTOMRIGHT")
            local oldSetPoint = f.SetPoint
            f.SetPoint = function(self, ...)
                oldSetPoint(self, ...)
                local x, y = self:GetSize()
                local avg = (x + y) * .5
                f.count:SetFont("Fonts\\FRIZQT__.TTF", CalcAuraCountFontSize(avg), "OUTLINE")
            end

            srslylawlUI[unitsType][unit].debuffFrames[i] = f
            f:Hide()
        end
    end
    for i = maxBuffs, 40 do
        if srslylawlUI[unitsType][unit].debuffFrames[i] then
            srslylawlUI[unitsType][unit].debuffFrames[i]:Hide()
        end
    end
end

local function CreateCustomFrames(buttonFrame, unit)
    local unitsType = buttonFrame:GetAttribute("unitsType")
    local function CreateAbsorbFrame(parent, i, parentTable, unit)
        local isOverlapFrame = parentTable == srslylawlUI[unitsType][unit].absorbFramesOverlap
        local n = "srslylawlUI_" .. unit .. (isOverlapFrame and "AbsorbFrameOverlap" or "AbsorbFrame") .. i
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
        local color = { GetClassColor(class) }
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
        local parentFrame = (i == 1 and buttonFrame.unit.healthBar) or
            srslylawlUI[unitsType][unit].absorbFramesOverlap[i - 1]
        CreateAbsorbFrame(parentFrame, i, srslylawlUI[unitsType][unit].absorbFramesOverlap, unit)
    end
    --effective health frame (sums up active defensive spells)
    CreateEffectiveHealthFrame(buttonFrame, unit, 1)
end

function srslylawlUI.CreateCustomFontString(frame, name, fontSize, template, mod)
    local fString = frame:CreateFontString(frame:GetName() .. name, "ARTWORK", template or "GameFontHighlight")

    function fString:ChangeFontSize(size)
        if self.fontSize == size then return end
        self:SetFont("Fonts\\FRIZQT__.TTF", size, mod or nil)
        self.fontSize = size
        if self.w and self.h and self.baseSize then
            self.ScaleToFit(self.w, self.h, self.baseSize)
        elseif self.isLimited then
            self:Limit()
        end
    end

    function fString:ScaleToFit(w, h, baseSize)
        local factor = math.min(w, h) / baseSize
        self:SetFont("Fonts\\FRIZQT__.TTF", (math.max(srslylawlUI.Utils_ScuffedRound(self.fontSize * factor), 1)))
        self.w, self.h, self.baseSize = w, h, baseSize

        if self.isLimited then
            self:Limit()
        end
    end

    function fString:Limit()
        local substring
        local wasShortened = false
        for length = #self.text, 1, -1 do
            substring = srslylawlUI.Utils_ShortenString(self.text, 1, length)
            self:SetText(wasShortened and self.dots and substring .. ".." or substring)
            if self:GetStringWidth() <= self.maxPixels then
                return
            end
            wasShortened = true
        end
    end

    function fString:SetLimitedText(maxPixels, text, dots)
        self.isLimited = true
        self.maxPixels = maxPixels
        self.dots = dots
        self.text = text

        self:Limit()
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
        CCDurationBar.timer = srslylawlUI.CreateCustomFontString(CCDurationBar.statusBar, "Timer", 15)
        CCDurationBar.statusBar:SetStatusBarTexture(srslylawlUI.textures.HealthBar)
        CCDurationBar.statusBar:SetMinMaxValues(0, 1)
        CCDurationBar.icon = CCDurationBar:CreateTexture("icon", "OVERLAY", nil, 2)
        CCDurationBar.icon:SetTexCoord(.08, .92, .08, .92)
        CCDurationBar.icon:SetTexture(408)
        CCDurationBar.timer:SetText("0")
        srslylawlUI.Utils_SetPointPixelPerfect(CCDurationBar.icon, "BOTTOMLEFT", CCDurationBar, "BOTTOMLEFT", 0, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(CCDurationBar.statusBar, "BOTTOMLEFT", CCDurationBar.icon, "BOTTOMRIGHT",
            1, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(CCDurationBar.statusBar, "TOPRIGHT", CCDurationBar, "TOPRIGHT", 0, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(CCDurationBar.timer, "LEFT", CCDurationBar.statusBar, "LEFT", 1, 0)
        srslylawlUI.CreateBackground(CCDurationBar, 0)

        CCDurationBar:Hide()

        function CCDurationBar:SetPoints(w, h)
            if h then
                srslylawlUI.Utils_SetSizePixelPerfect(self, w, h)
                h = math.min(w / 2, h)
                srslylawlUI.Utils_SetSizePixelPerfect(self.icon, h, h)
                self.timer:ScaleToFit(w, h, 40)
            else
                srslylawlUI.Utils_SetSizePixelPerfect(self.icon, w, w)
                self.timer:ScaleToFit(w, w, 40)
            end
        end

        function CCDurationBar:UpdateVisible()
            local timer = self.timer:GetText()
            if not timer then return end
            local n = tonumber(string.match(timer, "%d"))
            if self.disabled or type(n) ~= "number" or n < 0 then
                self:Hide()
            end
        end

        function CCDurationBar:SetReverseFill(bool)
            if self.reversed ~= bool then
                self.reversed = bool
                self.icon:ClearAllPoints()
                self.statusBar:ClearAllPoints()
                self.timer:ClearAllPoints()
                if bool then
                    srslylawlUI.Utils_SetPointPixelPerfect(self.icon, "BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
                    srslylawlUI.Utils_SetPointPixelPerfect(self.statusBar, "BOTTOMRIGHT", self.icon, "BOTTOMLEFT", 1, 0)
                    srslylawlUI.Utils_SetPointPixelPerfect(self.statusBar, "TOPLEFT", self, "TOPLEFT", 0, 0)
                    srslylawlUI.Utils_SetPointPixelPerfect(self.timer, "RIGHT", self.statusBar, "RIGHT", 1, 0)
                else
                    srslylawlUI.Utils_SetPointPixelPerfect(self.icon, "BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
                    srslylawlUI.Utils_SetPointPixelPerfect(self.statusBar, "BOTTOMLEFT", self.icon, "BOTTOMRIGHT", 1, 0)
                    srslylawlUI.Utils_SetPointPixelPerfect(self.statusBar, "TOPRIGHT", self, "TOPRIGHT", 0, 0)
                    srslylawlUI.Utils_SetPointPixelPerfect(self.timer, "LEFT", self.statusBar, "LEFT", 1, 0)
                end
                self.statusBar:SetReverseFill(bool)
            end
        end

        return CCDurationBar
    end

    local function CreateUnitFrame(header, unit, faux, party)
        local name = party and "$parent_" .. unit or "srslylawlUI_Main_" .. unit
        local unitFrame = CreateFrame("Frame", name, header, "srslylawlUI_UnitTemplate")
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
            -- local size = srslylawlUI.GetSettingByUnit("combatRestIcon.size", unitsType, unit)
            -- local position = srslylawlUI.GetSettingByUnit("combatRestIcon.position", unitsType, unit)
            -- srslylawlUI.Utils_SetSizePixelPerfect(unitFrame.unit.CombatIcon, size, size)
            -- srslylawlUI.Utils_SetPointPixelPerfect(unitFrame.unit.CombatIcon, unpack(position))
            srslylawlUI.Frame_ResetCombatIcon(unitFrame)
            unitFrame.unit.CombatIcon:SetFrameLevel(4)
            unitFrame.unit.CombatIcon.texture:Hide()
        end
        srslylawlUI.CreateBackground(unitFrame.unit.healthBar, 1, .8)
        srslylawlUI.CreateBackground(unitFrame.unit.powerBar, 1, .8)

        unitFrame.unit.powerBar.text = srslylawlUI.CreateCustomFontString(unitFrame.unit.powerBar, "Text", 5)
        unitFrame.unit.powerBar.text.enabled = srslylawlUI.GetSettingByUnit("power.text", unitsType, unit)
        unitFrame.unit.powerBar.text:SetPoint("BOTTOM")

        --for omnicd
        unitFrame.unitID = unit
        if unit == "player" and unitsType == "partyUnits" then
            srslylawlUI_PartyHeader_party5 = unitFrame
        end


        local height, width = srslylawlUI.GetSettingByUnit("hp.height", unitsType, unit),
            srslylawlUI.GetSettingByUnit("hp.width", unitsType, unit)

        srslylawlUI.Utils_SetSizePixelPerfect(unitFrame.unit, width, height)
        srslylawlUI.Utils_SetPointPixelPerfect(unitFrame, "TOPLEFT", unitFrame.unit, "TOPLEFT", -1, 1)
        srslylawlUI.Utils_SetPointPixelPerfect(unitFrame, "BOTTOMRIGHT", unitFrame.unit, "BOTTOMRIGHT", 1, -1)

        local alignment = "TOPLEFT"
        if unitsType == "partyUnits" then
            alignment = srslylawlUI.GetSetting("party.hp.reversed") and "TOPRIGHT" or alignment
        end
        unitFrame.unit.healthBar:SetPoint(alignment, unitFrame.unit, alignment, 0, 0)

        local fontSize = (party or faux) and srslylawlUI.GetSetting("party.hp.fontSize") or
            srslylawlUI.GetSetting("player." .. unit .. "Frame.hp.fontSize")
        unitFrame.unit.healthBar.leftTextFrame = CreateFrame("Frame", "$parent_leftTextFrame", unitFrame.unit.healthBar)
        unitFrame.unit.healthBar.leftText = srslylawlUI.CreateCustomFontString(unitFrame.unit.healthBar.leftTextFrame,
            "LeftText", fontSize, "GameFontHIGHLIGHT")

        unitFrame.unit.healthBar.rightTextFrame = CreateFrame("Frame", "$parent_rightTextFrame", unitFrame.unit.healthBar)
        unitFrame.unit.healthBar.rightText = srslylawlUI.CreateCustomFontString(unitFrame.unit.healthBar.rightTextFrame,
            "rightText", fontSize, "GameFontHIGHLIGHT")

        unitFrame.unit.healthBar.leftTextFrame:SetFrameLevel(9)
        unitFrame.unit.healthBar.rightTextFrame:SetFrameLevel(9)

        unitFrame.unit.healthBar:SetReverseFill(srslylawlUI.GetSettingByUnit("hp.reversed", unitsType, unit))

        --raid icon
        unitFrame.unit.RaidIcon = CreateFrame("Frame", "$parent_RaidIcon", unitFrame)
        function unitFrame.unit.RaidIcon:SetRaidIcon(id)
            if not self.enabled or (not id and not UnitExists(unit)) then return end

            id = id or GetRaidTargetIndex(unit)
            if id and id >= 0 and id <= 8 then
                if self.id == id then return end
                self.id = id
                self.icon:SetTexture("Interface/TARGETINGFRAME/UI-RaidTargetingIcon_" .. id)
                self.icon:Show()
            else
                self.icon:Hide()
            end
        end

        function unitFrame.unit.RaidIcon:SetEnabled(enable)
            if self.enabled == enable then return end
            self.enabled = enable
            self:SetShown(enable)
        end

        function unitFrame.unit.RaidIcon:Resize()
            local raidIconSize = srslylawlUI.GetSettingByUnit("raidIcon.size", unitsType, unit)
            srslylawlUI.Utils_SetSizePixelPerfect(self, raidIconSize, raidIconSize)
        end

        function unitFrame.unit.RaidIcon:SetPoints()
            self:ClearAllPoints()
            local anchors = srslylawlUI.GetSettingByUnit("raidIcon.position", unitsType, unit)
            srslylawlUI.Utils_SetPointPixelPerfect(self, unpack(anchors))
        end

        unitFrame.unit.RaidIcon:Resize()
        unitFrame.unit.RaidIcon:SetPoints()
        unitFrame.unit.RaidIcon.icon = unitFrame.unit.RaidIcon:CreateTexture("$parent_Icon", "OVERLAY")
        unitFrame.unit.RaidIcon.icon:SetAllPoints()

        if not unitsType:match("faux") then
            unitFrame.unit.RaidIcon:RegisterEvent("RAID_TARGET_UPDATE")
            unitFrame.unit.RaidIcon:SetScript("OnShow", function(self) self:SetRaidIcon() end)
            unitFrame.unit.RaidIcon:SetScript("OnEvent", function(self) self:SetRaidIcon() end)
        end
        unitFrame.unit.RaidIcon:SetFrameLevel(8)
        unitFrame.unit.RaidIcon:SetEnabled(srslylawlUI.GetSettingByUnit("raidIcon.enabled", unitsType, unit))
        --
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
        if (unitsType == "mainUnits" and unit == "target" or unit == "focus") or unitsType == "partyUnits" or
            unitsType == "fauxUnits" then
            local ccBar = CreateCCBar(unitFrame)
            ccBar:SetReverseFill(srslylawlUI.GetSettingByUnit("ccbar.reversed", unitsType, unit))
        end

        return unitFrame
    end

    local header = CreateFrame("Frame", "srslylawlUI_PartyHeader", nil)
    header:SetSize(srslylawlUI.GetSetting("party.hp.width"), srslylawlUI.GetSetting("party.hp.height") * 5)
    header:Show()
    --Create Unit Frames
    local fauxHeader = CreateFrame("Frame", "srslylawlUI_FAUX_PartyHeader", nil)
    fauxHeader:SetPoint("TOPLEFT", header, "TOPLEFT", 0, 0)
    fauxHeader:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
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
        if unit == "targettarget" then
            local oldSetPoint = frame.unit.SetPoint
            function frame.unit:SetPoint(...)
                local points = { ... }
                local fAnchor = points[2]
                if fAnchor == srslylawlUI.TranslateFrameAnchor("TargetFramePortrait") and
                    not srslylawlUI.GetSetting("player.targetFrame.portrait.enabled")
                then
                    points[2] = srslylawlUI.TranslateFrameAnchor("TargetFrame")
                    srslylawlUI.ChangeSetting("player.targettargetFrame.position.2", "TargetFrame")
                end
                oldSetPoint(self, unpack(points))
            end
        end
        srslylawlUI.Frame_InitialMainUnitConfig(frame)
    end
    --Apply anchoring now that every frame exists
    srslylawlUI.Frame_AnchorFromSettings(header, "party.header.position")
    for _, unit in pairs(srslylawlUI.mainUnitsTable) do
        local frame = srslylawlUI.Frame_GetFrameByUnit(unit, "mainUnits")
        srslylawlUI.Frame_AnchorFromSettings(frame.unit, "player." .. unit .. "Frame.position")
    end

    srslylawlUI.Frame_UpdatePartyHealthBarAlignment()
    srslylawlUI.Frame_UpdateMainHealthBarAlignment()
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
    local leftXoffset = unit == "targettarget" and 2 or 12

    srslylawlUI.Utils_SetPointPixelPerfect(buttonFrame.unit.healthBar.leftText, "BOTTOMLEFT", buttonFrame.unit.healthBar
        , "BOTTOMLEFT", leftXoffset, 2)
    srslylawlUI.Utils_SetPointPixelPerfect(buttonFrame.unit.healthBar.rightText, "BOTTOMRIGHT",
        buttonFrame.unit.healthBar, "BOTTOMRIGHT", -2, 2)
end

function srslylawlUI.Frame_InitialPartyUnitConfig(buttonFrame, faux)
    srslylawlUI.SetupUnitFrame(buttonFrame)
    local unit = buttonFrame:GetAttribute("unit")

    if not faux then
        srslylawlUI.RegisterEvents(buttonFrame)
        buttonFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

        buttonFrame.pet:SetScript("OnShow", function(self)
            local unit = self:GetParent():GetAttribute("unit")
            srslylawlUI.Frame_ResetPetButton(buttonFrame, unit .. "pet")
        end)
        buttonFrame.unit:SetScript("OnEnter", function(self)
            local unit = self:GetParent():GetAttribute("unit")
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:SetUnit(unit)
        end)
        buttonFrame.pet:SetScript("OnEnter", function(self)
            local unit = self:GetParent():GetAttribute("unit")
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:SetUnit(unit .. "pet")
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
                    local range = UnitInRange(unit) ~= self.unit.wasInRange
                    local online = UnitIsConnected(unit) ~= self.unit.online
                    local alive = UnitIsDeadOrGhost(unit) ~= self.unit.dead
                    if range or online or alive then

                        if online then
                            srslylawlUI.DebugTrackCall("ResetHealthBarOnUpdate OnlineDifferent: " ..
                                tostring(UnitIsConnected(unit)) .. " and " .. tostring(self.online))
                        else
                            srslylawlUI.DebugTrackCall("ResetHealthBarOnUpdate " ..
                                unit .. (range and "Range" or online and "Online" or alive and "alive"))
                        end

                        srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
                    end
                    self.TimeSinceLastUpdate = 0;
                end
            end)
        end
        --TODO: check for setting here if pet should be shown
        RegisterUnitWatch(buttonFrame)
        RegisterUnitWatch(buttonFrame.pet)
        buttonFrame.unit.registered = true
        buttonFrame.unit.CombatIcon:SetScript("OnUpdate", srslylawlUI.Frame_UpdateCombatIcon)
    end

    buttonFrame.PartyLeader:SetShown(UnitIsGroupLeader(unit))

    srslylawlUI.Frame_ResetDimensions_Pet(buttonFrame)
    srslylawlUI.Frame_ResetDimensions_PowerBar(buttonFrame)
    srslylawlUI.Frame_ResetDimensions(buttonFrame)
    srslylawlUI.Frame_ResetCCDurBar(buttonFrame)
    srslylawlUI.Frame_SetupPortrait(buttonFrame)
end

function srslylawlUI.Frame_InitialMainUnitConfig(buttonFrame)
    local unit = buttonFrame:GetAttribute("unit")
    srslylawlUI.SetupUnitFrame(buttonFrame, unit)

    srslylawlUI.RegisterEvents(buttonFrame)
    local enabled = srslylawlUI.GetSettingByUnit("enabled", "mainUnits", unit)
    buttonFrame.enabled = enabled
    if enabled then
        RegisterUnitWatch(buttonFrame)
    else
        UnregisterUnitWatch(buttonFrame)
        buttonFrame:Hide()
    end
    buttonFrame.unit.registered = true
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
            srslylawlUI.Frame_ResetPetButton(buttonFrame, unit .. "pet")
        end)
        buttonFrame.unit:SetScript("OnEnter", function(self)
            local unit = self:GetParent():GetAttribute("unit")
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:SetUnit(unit)
        end)
        buttonFrame.pet:SetScript("OnEnter", function(self)
            local unit = self:GetParent():GetAttribute("unit")
            GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
            GameTooltip:SetUnit(unit .. "pet")
        end)
        buttonFrame:RegisterEvent("PLAYER_DEAD")
        buttonFrame:RegisterEvent("PLAYER_UNGHOST")
        buttonFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
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

    if unit == "targettarget" then
        buttonFrame.unit.healthBar.rightText:Hide()
    else
        srslylawlUI.Frame_SetupPortrait(buttonFrame)
        buttonFrame:TogglePortrait()
        buttonFrame.unit.CombatIcon:SetScript("OnUpdate", srslylawlUI.Frame_UpdateCombatIcon)
    end

    if unit == "target" or unit == "focus" then
        srslylawlUI.Frame_SetupTargetFocusFrame(buttonFrame)
    end

    buttonFrame.PartyLeader:SetShown(UnitIsGroupLeader(unit))
    srslylawlUI.Frame_ResetDimensions(buttonFrame)
    if unit ~= "player" then
        srslylawlUI.Frame_ResetDimensions_PowerBar(buttonFrame)
    end
end

function srslylawlUI.Frame_SetupPortrait(frame)
    local unit = frame:GetAttribute("unit")
    local unitsType = frame:GetAttribute("unitsType")

    function frame:TogglePortrait()
        local enabled = srslylawlUI.GetSettingByUnit("portrait.enabled", unitsType, unit)

        if enabled and not frame.portrait then
            frame.portrait = CreateFrame("PlayerModel", "$parent_Portrait", frame.unit)
            frame.portrait:SetAlpha(1)
            frame.portrait:SetUnit(unit)
            frame.portrait:SetPortraitZoom(1)
            frame.portrait:SetFrameLevel(frame.unit:GetFrameLevel())

            function frame.portrait:ResetPosition()
                local height = srslylawlUI.GetSettingByUnit("hp.height", unitsType, unit)
                local anchorSetting = srslylawlUI.GetSettingByUnit("portrait.anchor", unitsType, unit)
                local anchor
                if not anchorSetting then
                    anchor = frame.unit
                else
                    if anchorSetting == "Frame" then anchor = frame.unit
                    elseif anchorSetting == "Powerbar" then anchor = frame.unit.powerBar
                    end
                end
                local position = srslylawlUI.GetSettingByUnit("portrait.position", unitsType, unit)
                frame.portrait:ClearAllPoints()
                if position == "LEFT" then
                    srslylawlUI.Utils_SetPointPixelPerfect(frame.portrait, "TOPRIGHT", anchor, "TOPLEFT", -1, 0)
                    srslylawlUI.Utils_SetPointPixelPerfect(frame.portrait, "BOTTOMLEFT", anchor, "BOTTOMLEFT",
                        -(height + 1), 0)
                elseif position == "RIGHT" then
                    srslylawlUI.Utils_SetPointPixelPerfect(frame.portrait, "TOPLEFT", anchor, "TOPRIGHT", 1, 0)
                    srslylawlUI.Utils_SetPointPixelPerfect(frame.portrait, "BOTTOMRIGHT", anchor, "BOTTOMRIGHT",
                        height +
                        1, 0)
                end
            end

            srslylawlUI.CreateBackground(frame.portrait)
            function frame.portrait:ModelUpdate()
                --order seems very important here
                if not UnitIsVisible(unit) or not UnitIsConnected(unit) then
                    self:SetModelScale(5.5)
                    self:SetPosition(2, 0, .9)
                    self:SetPortraitZoom(5)
                    self:ClearModel()
                    self:SetModel("Interface\\Buttons\\talktomequestionmark.m2")
                else
                    self:SetPortraitZoom(1)
                    self:SetPosition(0, 0, 0)
                    self:ClearModel()
                    self:SetUnit(unit)
                end
            end

            function frame.portrait:PortraitUpdate()
                local guid = UnitGUID(unit)
                if self.guid ~= guid then
                    self.guid = guid
                    self:ModelUpdate()
                end
            end

            --portrait seems to be very sensitive to order of execution, needs it as onshow or else it wont update properly
            frame.portrait:SetScript("OnShow", function(self) self:ModelUpdate() end)
        end

        if enabled then
            frame:RegisterEvent("UNIT_PORTRAIT_UPDATE", unit)
            frame:RegisterEvent("UNIT_MODEL_CHANGED", unit)
            frame.portrait:ResetPosition()
            frame.portrait:Show()
            if frame.factionIcon then
                frame.factionIcon:SetPoint("CENTER", frame.portrait, "TOPRIGHT", 0, 0)
            end
        elseif not enabled then
            frame:UnregisterEvent("UNIT_PORTRAIT_UPDATE")
            frame:UnregisterEvent("UNIT_MODEL_CHANGED")
            if frame.portrait then
                frame.portrait:Hide()
            end
            if frame.factionIcon then
                frame.factionIcon:SetPoint("CENTER", frame.unit, "TOPRIGHT", 0, 0)
            end
        end
    end
end

function srslylawlUI.Frame_SetupTargetFocusFrame(frame)
    local unit = frame:GetAttribute("unit")
    srslylawlUI.BarHandler_Create(frame, frame.unit)
    frame.CastBar = srslylawlUI.CreateCastBar(frame, unit)
    frame:RegisterBar(frame.CastBar, 0)
    frame:RegisterBar(frame.unit.CCDurBar)

    frame.unitLevel = CreateFrame("Frame", "$parent_UnitLevel", frame.unit)
    frame.unitLevel:SetFrameLevel(frame.unit:GetFrameLevel() + 1)
    frame.unitLevel.text = srslylawlUI.CreateCustomFontString(frame.unit, "Level", 6, nil, "OUTLINE")
    frame.unitLevel.text:SetPoint("CENTER", frame.unitLevel)
    srslylawlUI.Utils_SetSizePixelPerfect(frame.unitLevel, 20, 20)
    frame.unitLevel.text:SetText("??")
    frame.unitLevel.showClassification = srslylawlUI.GetSettingByUnit("unitLevel.showClassification",
        frame:GetAttribute("unitsType"), unit)

    local oldSetPoint = frame.unitLevel.SetPoint
    function frame.unitLevel:SetPoint(...)
        local points = { ... }
        local fAnchor = points[2]
        local unitCaps = unit:sub(1, 1):upper() .. unit:sub(2)
        if fAnchor == srslylawlUI.TranslateFrameAnchor(unitCaps .. "FramePortrait") and
            not srslylawlUI.GetSetting("player." .. unit .. "Frame.portrait.enabled") then
            points[2] = srslylawlUI.TranslateFrameAnchor(unitCaps .. "Frame")
            srslylawlUI.ChangeSetting("player." .. unit .. "Frame.unitLevel.position.2", unitCaps .. "Frame")
        end
        oldSetPoint(self, unpack(points))
    end

    frame.factionIcon = CreateFrame("Frame", "$parent_FactionIcon", frame.unit)
    frame.factionIcon:SetFrameLevel(frame.unit:GetFrameLevel() + 1)
    frame.factionIcon.icon = frame.factionIcon:CreateTexture("$parent_FactionIcon", "OVERLAY")
    srslylawlUI.Utils_SetSizePixelPerfect(frame.factionIcon, 20, 20)
    srslylawlUI.Utils_SetSizePixelPerfect(frame.factionIcon.icon, 20, 20)
    frame.factionIcon.icon:SetPoint("CENTER")
    frame.factionIcon.icon:SetTexCoord(0, 0.625, 0, 0.625)
    frame:RegisterEvent("UNIT_FACTION", unit)

    if unit == "focus" then
        frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    end

    function frame:ResetUnitLevelIcon()
        unit = self:GetAttribute("unit")
        srslylawlUI.Frame_AnchorFromSettings(self.unitLevel, "player." .. unit .. "Frame.unitLevel.position")
    end

    local oldSetSize = frame.SetSize
    function frame:SetSize(x, y)
        oldSetSize(frame, x, y)
        self:TogglePortrait()
    end

    function frame:UpdateUnitLevel()
        local unitLevel = UnitLevel(unit)
        local classificationText = ""
        if self.unitLevel.showClassification then
            local class = UnitClassification(unit)
            if class == "elite" then classificationText = "E" end
            if class == "rareelite" then classificationText = "RE" end
            if class == "rare" then classificationText = "R" end
        end

        if unitLevel < 0 then
            self.unitLevel.text:SetText("??" .. classificationText)
        else
            self.unitLevel.text:SetText(unitLevel .. classificationText)
        end
    end

    function frame:UpdateUnitFaction()
        local ffa = UnitIsPVPFreeForAll(unit)

        if ffa then
            if self.faction ~= "FFA" then
                self.factionIcon.icon:SetTexture("Interface/TARGETINGFRAME/UI-PVP-FFA")
                self.factionIcon.icon:Show()
                self.faction = "FFA"
            end
        else
            local faction = UnitFactionGroup(unit)
            if not faction or faction == "Neutral" then
                if self.faction then
                    self.factionIcon.icon:Hide()
                    self.faction = nil
                end
            elseif faction == "Horde" then
                if self.faction ~= faction then
                    self.factionIcon.icon:SetTexture("Interface/TARGETINGFRAME/UI-PVP-Horde")
                    self.factionIcon.icon:Show()
                    self.faction = faction
                end
            elseif faction == "Alliance" then
                if self.faction ~= faction then
                    self.factionIcon.icon:SetTexture("Interface/TARGETINGFRAME/UI-PVP-Alliance")
                    self.factionIcon.icon:Show()
                    self.faction = faction
                end
            end
        end
    end

    frame:TogglePortrait()
    frame:ResetUnitLevelIcon()
    frame:UpdateUnitLevel()
end

function srslylawlUI.CreateCastBar(parent, unit)
    local cBar = CreateFrame("Frame", "$parent_CastBar", parent)
    local unitsType = parent:GetAttribute("unitsType")
    srslylawlUI.CreateBackground(cBar, 1)
    local function CastOnUpdate(self, elapsed)
        local time = GetTime()

        self.elapsed = self.isChannelled and self.elapsed - (time - self.lastUpdate) or
            self.elapsed + (time - self.lastUpdate)
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
                self.StatusBar.Timer:SetText("|cffff0000" ..
                    "+" ..
                    srslylawlUI.Utils_DecimalRound(self.pushback, 1) ..
                    "|r" .. " " .. srslylawlUI.Utils_DecimalRound(self.elapsed, 1))
            end
        elseif self.isEmpower then
            self.EmpowerBar:UpdateEmpowerBar()
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
                self.StatusBar.Timer:SetText("|cffff0000" ..
                    "+" ..
                    srslylawlUI.Utils_DecimalRound(self.pushback, 1) ..
                    "|r" .. " " .. srslylawlUI.Utils_DecimalRound(timeLeft, 1))
            end

            if self.elapsed >= self.endSeconds then
                self.spellName = nil
                self.castID = nil
                self:FadeOut()
            end
        end
    end

    local function CreateEmpowerBar(parent)
        local frame = srslylawlUI.CreatePointBar(parent, 4, 1, "$parent_EmpowerBar")
        local foreground = CreateFrame("Frame", "$parent_FontLayer", frame)
        parent.EmpowerBar = frame
        parent.EmpowerBar.foreground = foreground
        frame.CastBar = parent


        srslylawlUI.Utils_SetPointPixelPerfect(parent.EmpowerBar, "TOPLEFT", parent.StatusBar, "TOPLEFT", 0, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(parent.EmpowerBar, "BOTTOMRIGHT", parent.StatusBar, "BOTTOMRIGHT", 0, 0)

        srslylawlUI.Utils_SetPointPixelPerfect(foreground, "TOPLEFT", frame, "TOPLEFT", 0, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(foreground, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

        frame.backgroundBar = srslylawlUI.CreatePointBar(frame, 4, 1, "$parent_backgroundBar")
        srslylawlUI.Utils_SetPointPixelPerfect(frame.backgroundBar, "TOPLEFT", parent.EmpowerBar, "TOPLEFT", 0, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(frame.backgroundBar, "BOTTOMRIGHT", parent.EmpowerBar, "BOTTOMRIGHT", 0, 0)

        local fontSize = srslylawlUI.GetSettingByUnit("cast.fontSize", unitsType, unit)
        frame.Timer = srslylawlUI.CreateCustomFontString(foreground, "Timer", fontSize)
        frame.SpellName = srslylawlUI.CreateCustomFontString(foreground, "SpellName", fontSize)
        srslylawlUI.Utils_SetPointPixelPerfect(frame.SpellName, "LEFT", foreground, "LEFT", 1, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(frame.Timer, "RIGHT", foreground, "RIGHT", -1, 0)

        frame.HoldPoint = frame:CreatePointFrame(frame, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(frame.HoldPoint, "TOPLEFT", parent.EmpowerBar, "TOPLEFT", 0, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(frame.HoldPoint, "BOTTOMRIGHT", parent.EmpowerBar, "BOTTOMRIGHT", 0, 0)
        frame.HoldPoint:SetAlpha(.5)
        frame.HoldPoint:SetValue(0)

        frame.foreground:SetFrameLevel(frame:GetFrameLevel() + 3)

        frame.Timer.defaultColor = { frame.Timer:GetTextColor() }
        frame.Timer.colorIsDefault = true

        function frame:GetEmpowerStageColor(stage, done, nonInterruptible)
            local colors = {
                [1] = { r = 0.67, g = 0.67, b = 0.67 },
                [2] = { r = 0.87, g = 0.16, b = 0.0 },
                [3] = { r = 0.91, g = 0.53, b = 0.0 },
                [4] = { r = 0.98, g = 0.73, b = 0.02 },
            }
            local colorsDone = {
                [1] = { r = 0.75, g = 0.75, b = 0.75 },
                [2] = { r = 0.95, g = 0.25, b = 0.0 },
                [3] = { r = 1, g = 0.65, b = 0.0 },
                [4] = { r = 1, g = 0.85, b = 0.00 },
            }
            local colorsNotInterruptible = {
                [1] = { r = 0.81, g = 0.33, b = 0.7 },
                [2] = { r = 0.85, g = 0.26, b = 0.7 },
                [3] = { r = 0.91, g = 0.21, b = 0.7 },
                [4] = { r = 0.98, g = 0.15, b = 0.7 },
            }
            local colorsDoneNotInterruptible = {
                [1] = { r = 0.88, g = 0.26, b = 0.74 },
                [2] = { r = 0.9, g = 0.21, b = 0.74 },
                [3] = { r = 0.94, g = 0.15, b = 0.74 },
                [4] = { r = 1, g = 0.1, b = 0.74 },
            }
            if stage <= 4 then
                if not nonInterruptible then return done and colorsDone[stage] or colors[stage]
                else
                    return done and colorsDoneNotInterruptible[stage] or colorsNotInterruptible[stage]
                end
            else
                return { r = 1, g = 1, b = 1 }
            end
        end

        function frame:SetEmpowerPoints(numStages)
            self.desiredButtonCount = numStages
            self.backgroundBar.desiredButtonCount = numStages
            self:StockPointFrames()
            self.backgroundBar:StockPointFrames()

            local castBar = self.CastBar
            local totalDuration = castBar.endSeconds * 1000

            local x, y = srslylawlUI.Utils_PixelFromScreenToCode(self:GetWidth(), self:GetHeight())
            local desiredSize = x
            local totalSize = x
            local height = y
            local bCount = self.desiredButtonCount
            local totalpadding = (bCount - 1) * self.padding
            totalSize = totalSize - totalpadding
            local actualSize = 0
            if not self.barSizes then self.barSizes = {} end
            if not self.stagePortions then self.stagePortions = {} end
            for stage = 1, bCount do
                local stageDuration = stage == self.totalEmpowerStages and GetUnitEmpowerHoldAtMaxTime(castBar.unit) or
                    GetUnitEmpowerStageDuration(castBar.unit, stage - 1)
                if stageDuration >= 0 then
                    local stagePortion = stageDuration / totalDuration
                    local barSize = srslylawlUI.Utils_ScuffedRound(totalSize * stagePortion)
                    actualSize = actualSize + barSize
                    self.barSizes[stage] = barSize
                    self.stagePortions[stage] = stagePortion
                end
            end

            actualSize = actualSize + totalpadding
            local diff = desiredSize - actualSize
            local middleFrame = ceil(self.desiredButtonCount / 2)
            local pixelPerfectCompensation
            for i = 1, #self.pointFrames do
                local pf = self.pointFrames[i]
                local pfBG = self.backgroundBar.pointFrames[i]
                if i > self.desiredButtonCount then
                    pf:Hide()
                    pfBG:Hide()
                else
                    pf:Show()
                    pfBG:Show()
                end
                if i == 1 then
                    srslylawlUI.Utils_SetPointPixelPerfect(pf, "BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
                    srslylawlUI.Utils_SetPointPixelPerfect(pfBG, "BOTTOMLEFT", self.backgroundBar, "BOTTOMLEFT", 0, 0)
                else
                    srslylawlUI.Utils_SetPointPixelPerfect(pf, "BOTTOMLEFT", self.pointFrames[i - 1], "BOTTOMRIGHT"

                        , self.padding, 0)
                    srslylawlUI.Utils_SetPointPixelPerfect(pfBG, "BOTTOMLEFT", self.backgroundBar.pointFrames[i - 1],
                        "BOTTOMRIGHT"

                        , self.padding, 0)

                end
                if i <= bCount then
                    pixelPerfectCompensation = i == middleFrame and diff or 0
                    local barSize = self.barSizes[i] + pixelPerfectCompensation
                    srslylawlUI.Utils_SetSizePixelPerfect(pf, barSize, height)
                    pf.text:ScaleToFit(barSize, height, 20)
                    srslylawlUI.Utils_SetSizePixelPerfect(pfBG, barSize, height)
                    pfBG.text:ScaleToFit(barSize, height, 20)
                    pf:SetValue(0) -- clear value
                    local col = self:GetEmpowerStageColor(i)
                    pf:SetStatusBarColor(col.r, col.g, col.b)
                    pfBG:SetAlpha(.35)
                    pfBG:SetStatusBarColor(col.r, col.g, col.b)
                end
            end
            -- srslylawlUI.Utils_SetSizePixelPerfect(self, totalSize + diff, height)
        end

        function frame:UpdateEmpowerBar()
            local castBar = self.CastBar
            local timeLeft = castBar.endSeconds - castBar.elapsed
            local currentCastTime = castBar.elapsed
            local bCount = self.desiredButtonCount
            local currentStage = 0
            local maxHold = GetUnitEmpowerHoldAtMaxTime(castBar.unit) / 1000
            local totalPlusHold = castBar.endSeconds + maxHold
            local useDefaultTimerColor = true
            local isInHoldTime = false
            if timeLeft <= 0 and castBar.elapsed >= totalPlusHold then
                self.Timer:SetText("0.0")
            elseif castBar.elapsed > castBar.endSeconds and castBar.elapsed < totalPlusHold then
                --is in spell hold time
                isInHoldTime = true
                useDefaultTimerColor = false
                local holdTime = totalPlusHold - castBar.elapsed
                self.HoldPoint:SetValue(1 - holdTime)
                self.Timer:SetFormattedText("%.1f", holdTime, 1)
            elseif castBar.pushback == 0 then
                -- no pushback
                self.Timer:SetFormattedText("%.1f", timeLeft, 1)
            else
                -- NOTE: empower does not seem to have pushback at all currently
                -- has pushback, display pushback
                self.Timer:SetText("|cffff0000" ..
                    "+" ..
                    srslylawlUI.Utils_DecimalRound(castBar.pushback, 1) ..

                    "|r" .. " " .. srslylawlUI.Utils_DecimalRound(timeLeft, 1))
            end

            if not isInHoldTime then
                self.HoldPoint:SetValue(0)
            end

            if useDefaultTimerColor then
                if not self.Timer.colorIsDefault then
                    self.Timer:SetTextColor(unpack(self.Timer.defaultColor))
                    self.Timer.colorIsDefault = true
                end
            elseif self.Timer.colorIsDefault then
                self.Timer:SetTextColor(1, 0, 0)
                self.Timer.colorIsDefault = false
            end


            if castBar.elapsed >= totalPlusHold then
                castBar.spellName = nil
                castBar.castID = nil
                castBar:FadeOut()
            end


            --handle empower stages
            for stage = 1, bCount do
                local pf = self.pointFrames[stage]
                local stageDur = self.stagePortions[stage] * castBar.endSeconds
                local nextStage = currentStage + stageDur
                local inProgressAlpha = .75
                local done = false

                if currentCastTime < currentStage then -- if cast is before this stage starts
                    pf:SetValue(0)
                    pf:SetAlpha(inProgressAlpha)
                elseif currentCastTime >= nextStage then -- if cast is already at further stage
                    pf:SetValue(1)
                    pf:SetAlpha(1)
                    done = true
                else -- cast is at this stage
                    -- 0 fill would be currentCastTime == currentStage
                    -- 1 fill would be currentCastTime >= currentStage + stageDur
                    local fill = (currentCastTime - currentStage) / stageDur
                    pf:SetValue(fill)
                    pf:SetAlpha(inProgressAlpha)
                end
                local col = self:GetEmpowerStageColor(stage, done, self.notInterruptible)
                pf:SetStatusBarColor(col.r, col.g, col.b)

                currentStage = nextStage
            end
        end
    end

    function cBar:UpdateCast()
        if self.disabled then return end
        local spell, displayName, icon, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(self
            .unit)
        local isChannelled = false
        local isEmpower = false
        local channelOrEmpower = false
        if not spell then
            spell, displayName, icon, startTime, endTime, isTradeSkill, notInterruptible, spellID, _, numChargeStages = UnitChannelInfo(self
                .unit)
            if not spell then
                return
            end

            isEmpower = numChargeStages > 0;
            if not isEmpower then
                isChannelled = true
            end
            channelOrEmpower = true
        end
        if not spell then
            return
        end

        self.Icon:SetTexture(icon)
        self.Icon:Show()

        self.isChannelled = isChannelled
        self.isEmpower = isEmpower
        self.startTime = startTime / 1000
        self.endTime = endTime / 1000
        self.endSeconds = self.endTime - self.startTime
        self.elapsed = self.isChannelled and self.endSeconds or 0
        self.spellName = spell
        self.spellID = spellID
        self.castID = channelOrEmpower and spellID or castID
        self.pushback = 0
        self.lastUpdate = self.startTime

        self.StatusBar:SetMinMaxValues(0, self.endSeconds)
        self.StatusBar:SetValue(self.elapsed)
        self.StatusBar:Show()
        self:SetAlpha(1)
        --trigger hook functions, such as bar ordering
        self:GetScript("OnShow")(self)
        local spellText = isEmpower and self.EmpowerBar.SpellName or self.StatusBar.SpellName
        spellText:SetLimitedText(self.StatusBar:GetWidth() * 0.8, spell, true)


        self:SetScript("OnUpdate", CastOnUpdate)

        if self.isEmpower then
            self.EmpowerBar.notInterruptible = notInterruptible
            self.EmpowerBar:SetEmpowerPoints(numChargeStages)
            self.StatusBar:Hide()
            self.EmpowerBar:Show()
        else
            if notInterruptible then
                self:ChangeBarColor("uninterruptible")
            elseif self.isChannelled then
                self:ChangeBarColor("channel")
            else
                self:ChangeBarColor("cast")
            end
        end


    end

    function cBar:StopCast(event, unit, castID, spellID)
        if (event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP") and not castID then
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
        local spell, displayName, icon, startTime, endTime, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(self
            .unit)
        if not spell then
            spell, displayName, icon, startTime, endTime, isTradeSkill, notInterruptible, spellID = UnitChannelInfo(self
                .unit)
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

            self:SetAlpha(self.fadeTimer / fadeTime)

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
        local color = { 1, 1, 1, 1 }
        -- local bgColor = {0, 0, 0, .4}
        if type == "channel" then
            color = { 0.160, 0.411, 1, 1 }
        elseif type == "cast" then
            -- color = {0.862, 0.549, 0.196, 1}
            color = { 0.862, 0.713, 0.196, 1 }
        elseif type == "uninterruptible" then
            color = { 0.8, 0, 0.741, 1 }
        elseif type == "success" then
            color = { 0.364, 1, 0.160, 1 }
        elseif type == "failed" then
            color = { 0.980, 0.152, 0, 1 }
            -- bgColor = color
        end
        self.StatusBar:SetStatusBarColor(unpack(color))
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
        -- do nothing - called by barhandler so has to exist
    end

    function cBar:SetReverseFill(reverse)
        if self.reversed ~= reverse then
            self.reversed = reverse

            self.StatusBar:ClearAllPoints()
            self.StatusBar.SpellName:ClearAllPoints()
            self.StatusBar.Timer:ClearAllPoints()
            self.Icon:ClearAllPoints()
            if reverse then
                self.Icon:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
                srslylawlUI.Utils_SetPointPixelPerfect(self.StatusBar, "TOPRIGHT", self.Icon, "TOPLEFT", 1, 0)
                srslylawlUI.Utils_SetPointPixelPerfect(self.StatusBar, "BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
                srslylawlUI.Utils_SetPointPixelPerfect(self.StatusBar.SpellName, "RIGHT", self.StatusBar, "RIGHT", 1, 0)
                srslylawlUI.Utils_SetPointPixelPerfect(self.StatusBar.Timer, "LEFT", self.StatusBar, "LEFT", -1, 0)
            else
                self.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
                srslylawlUI.Utils_SetPointPixelPerfect(self.StatusBar, "TOPLEFT", self.Icon, "TOPRIGHT", 1, 0)
                srslylawlUI.Utils_SetPointPixelPerfect(self.StatusBar, "BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
                srslylawlUI.Utils_SetPointPixelPerfect(self.StatusBar.SpellName, "LEFT", self.StatusBar, "LEFT", 1, 0)
                srslylawlUI.Utils_SetPointPixelPerfect(self.StatusBar.Timer, "RIGHT", self.StatusBar, "RIGHT", -1, 0)
            end
            self.StatusBar:SetReverseFill(reverse)
        end
    end

    function cBar:SetPoints(h)
        h = h or srslylawlUI.Utils_PixelFromScreenToCode(self:GetHeight())
        h = math.max(1, h)
        srslylawlUI.Utils_SetSizePixelPerfect(cBar.Icon, h, h)
        local default = srslylawlUI.GetDefaultByUnit("cast.height", unitsType, unit)
        self.StatusBar.Timer:ScaleToFit(h, h, default)
        self.StatusBar.SpellName:ScaleToFit(h, h, default)
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
    cBar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", unit)
    cBar:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", unit)


    cBar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unit)
    cBar:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unit)

    cBar.name = "CastBar"
    cBar.StatusBar = CreateFrame("StatusBar", "$parent_StatusBar", cBar)
    cBar.StatusBar:SetStatusBarTexture(srslylawlUI.textures.HealthBar)
    cBar.StatusBar:Hide()
    cBar.Icon = cBar:CreateTexture("$parent_icon", "OVERLAY")
    cBar.Icon:SetTexCoord(.08, .92, .08, .92)
    local fontSize = srslylawlUI.GetSettingByUnit("cast.fontSize", unitsType, unit)
    local height = srslylawlUI.GetSettingByUnit("cast.height", unitsType, unit)
    cBar.StatusBar.Timer = srslylawlUI.CreateCustomFontString(cBar.StatusBar, "Timer", fontSize)
    cBar.StatusBar.SpellName = srslylawlUI.CreateCustomFontString(cBar.StatusBar, "SpellName", fontSize)
    srslylawlUI.Utils_SetSizePixelPerfect(cBar.Icon, height, height)
    cBar.Icon:SetPoint("TOPLEFT", cBar, "TOPLEFT", 0, 0)
    srslylawlUI.Utils_SetPointPixelPerfect(cBar.StatusBar, "TOPLEFT", cBar.Icon, "TOPRIGHT", 1, 0)
    srslylawlUI.Utils_SetPointPixelPerfect(cBar.StatusBar, "BOTTOMRIGHT", cBar, "BOTTOMRIGHT", 0, 0)
    srslylawlUI.Utils_SetPointPixelPerfect(cBar.StatusBar.SpellName, "LEFT", cBar.StatusBar, "LEFT", 1, 0)
    srslylawlUI.Utils_SetPointPixelPerfect(cBar.StatusBar.Timer, "RIGHT", cBar.StatusBar, "RIGHT", -1, 0)
    CreateEmpowerBar(cBar)


    cBar:SetAlpha(0)
    cBar:SetScript("OnShow", function(self)
        -- does not return anything while empower spell is in "hold" stage
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
        self.EmpowerBar:Hide()
        self.Icon:Hide()
        self:SetAlpha(0)
    end)

    cBar:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
        if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" or
            event == "UNIT_SPELLCAST_EMPOWER_START" then

            -- starting cast
            self:UpdateCast()
        elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or
            event == "UNIT_SPELLCAST_EMPOWER_STOP" or event == "UNIT_SPELLCAST_FAILED" then
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
    bh.unit = unit

    function frame:RegisterBar(bar, priority, height)
        local disabled = false
        local showWhenInactive
        local reversed
        if bar.name == "CastBar" then
            priority = srslylawlUI.GetSettingByUnit("cast.priority", unitsType, unit)
            height = srslylawlUI.GetSettingByUnit("cast.height", unitsType, unit)
            disabled = srslylawlUI.GetSettingByUnit("cast.disabled", unitsType, unit)
            reversed = srslylawlUI.GetSettingByUnit("cast.reversed", unitsType, unit)
        elseif bar.name == "CCDurationBar" then
            priority = srslylawlUI.GetSettingByUnit("ccbar.priority", unitsType, unit)
            height = srslylawlUI.GetSettingByUnit("ccbar.height", unitsType, unit)
            disabled = srslylawlUI.GetSettingByUnit("ccbar.disabled", unitsType, unit)
            reversed = srslylawlUI.GetSettingByUnit("ccbar.reversed", unitsType, unit)
        elseif unit == "player" then
            local specIndex = GetSpecialization()
            local specID = GetSpecializationInfo(specIndex)

            local path
            if specID < 102 or specID > 105 then -- not druid
                path = "player.playerFrame.power.overrides." .. specID .. "." .. bar.name .. "."
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
                path = "player.playerFrame.power.overrides." .. specID .. "." .. currentStance .. "." .. bar.name .. "."
            end
            priority = srslylawlUI.GetSetting(path .. "priority", true) or priority
            height = srslylawlUI.GetSetting(path .. "height", true) or height
            disabled = srslylawlUI.GetSetting(path .. "disabled", true) or disabled
            showWhenInactive = srslylawlUI.GetSetting(path .. "showWhenInactive", true) or false
            reversed = srslylawlUI.GetSetting(path .. "reversed", true) or false
        end
        bar.disabled = disabled
        bar.isUnparented = false
        bar.hideWhenInactive = not showWhenInactive
        bar:SetReverseFill(reversed)

        for _, v in pairs(bh.bars) do
            if v.bar == bar then
                v.priority = priority
                v.height = height
                self:SortBars()
                return
            end
        end

        table.insert(bh.bars, { bar = bar, priority = priority, height = height })

        local hasOnShowScript = bar:GetScript("OnShow") ~= nil
        if not bar.onShowIsSetPoints and not hasOnShowScript then
            bar:SetScript("OnShow", function() self:SetPoints() end)
            bar.onShowIsSetPoints = true
        end
        if not bar.onShowIsSetPoints and hasOnShowScript and not bar.onShowIsHookedSetPoints then
            bar:HookScript("OnShow", function() self:SetPoints() end)
            bar.onShowIsHookedSetPoints = true
        end

        local hasOnHideScript = bar:GetScript("OnHide") ~= nil
        if not bar.onHideIsSetPoints and not hasOnHideScript then
            bar:SetScript("OnHide", function() self:SetPoints() end)
            bar.onHideIsSetPoints = true
        end
        if not bar.onHideIsSetPoints and hasOnHideScript and not bar.onHideIsHookedSetPoints then
            bar:HookScript("OnHide", function() self:SetPoints() end)
            bar.onHideIsHookedSetPoints = true
        end
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
        local removed = {}
        for i = 1, #bh.bars do
            if bh.bars[i].bar.name == "CastBar" then
                -- Move i's kept value to actualIndex's position, if it's not already there.
                if i ~= actualIndex then
                    bh.bars[actualIndex] = bh.bars[i];
                    bh.bars[i] = nil;
                end
                actualIndex = actualIndex + 1; -- Increment position of where we'll place the next kept value.
            else
                bh.bars[i].bar.isUnparented = true
                table.insert(removed, bh.bars[i].bar)
                bh.bars[i] = nil;
            end
        end
        for _, bar in pairs(removed) do
            bar:UpdateVisible()
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
        for i = 1, #bh.bars do
            currentBar = bh.bars[i].bar
            height = bh.bars[i].height or 40
            if currentBar:IsShown() and currentBar:GetAlpha() > .9 and not currentBar.disabled and
                not currentBar.isUnparented then --ignore if the bar isnt visible
                if not lastBar then
                    srslylawlUI.Utils_SetPointPixelPerfect(currentBar, "TOPLEFT", bh.barParent, "BOTTOMLEFT", 0, -1)
                    srslylawlUI.Utils_SetPointPixelPerfect(currentBar, "BOTTOMRIGHT", bh.barParent, "BOTTOMRIGHT", 0,
                        -1 - height)
                else
                    srslylawlUI.Utils_SetPointPixelPerfect(currentBar, "TOPLEFT", lastBar, "BOTTOMLEFT", 0, -1)
                    srslylawlUI.Utils_SetPointPixelPerfect(currentBar, "BOTTOMRIGHT", lastBar, "BOTTOMRIGHT", 0,
                        -1 - height)
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
        end
        for i = 1, #bh.bars do
            bh.bars[i].bar:UpdateVisible()
        end
    end

    function frame:SetDemoMode(active)
        if not bh.demoBars then
            bh.demoBars = {}
        end
        local scriptHolder = bh
        local parent = bh.barParent

        if bh.barParent:GetAttribute("unit") == "target" then
            scriptHolder = srslylawlUI.mainFauxUnits.target.unitFrame.barHandlerScriptHolder
            parent = srslylawlUI.mainFauxUnits.target.unitFrame
        end
        if active then
            local timer = 0
            scriptHolder:SetScript("OnUpdate", function(self, elapsed)
                timer = timer + elapsed
                if timer <= .1 then return end
                local currentBar, currentDemoBar, lastBar, height, token, resourceName
                for i = 1, #bh.bars do
                    if not bh.demoBars[i] then
                        bh.demoBars[i] = CreateFrame("StatusBar", "$parent_DemoBar" .. i, parent)
                        bh.demoBars[i]:SetStatusBarTexture(srslylawlUI.textures.PowerBarSprite)
                        bh.demoBars[i].text = srslylawlUI.CreateCustomFontString(bh.demoBars[i], "Text",
                            srslylawlUI.GetSetting("player.playerFrame.power.fontSize"))
                        bh.demoBars[i].text:SetPoint("CENTER")
                    end
                    currentDemoBar = bh.demoBars[i]
                    currentBar = bh.bars[i]
                    height = currentBar.height or 40

                    currentDemoBar:SetShown(not currentBar.bar.disabled)

                    if not currentBar.bar.disabled then
                        if currentBar.bar.color then
                            currentDemoBar:SetStatusBarColor(currentBar.bar.color.r, currentBar.bar.color.g,
                                currentBar.bar.color.b)
                        else
                            currentDemoBar:SetStatusBarColor(1, 1, 1)
                        end

                        if not lastBar then
                            srslylawlUI.Utils_SetPointPixelPerfect(currentDemoBar, "TOPLEFT", parent, "BOTTOMLEFT", 0,
                                -
                                1)
                            srslylawlUI.Utils_SetPointPixelPerfect(currentDemoBar, "BOTTOMRIGHT", parent, "BOTTOMRIGHT",
                                0, -1 - height)
                        else
                            srslylawlUI.Utils_SetPointPixelPerfect(currentDemoBar, "TOPLEFT", lastBar, "BOTTOMLEFT", 0,
                                -1)
                            srslylawlUI.Utils_SetPointPixelPerfect(currentDemoBar, "BOTTOMRIGHT", lastBar, "BOTTOMRIGHT"
                                , 0, -1 - height)
                        end

                        currentDemoBar.text:SetText(currentBar.bar.name)
                        currentDemoBar.text:ScaleToFit(height, height, 20)

                        lastBar = currentDemoBar
                    end
                end
                for i = #bh.bars + 1, #bh.demoBars do
                    bh.demoBars[i]:Hide()
                end
                timer = 0
            end)
        else
            for i = 1, #bh.demoBars do
                bh.demoBars[i]:Hide()
            end
            scriptHolder:SetScript("OnUpdate", nil)
        end
    end

    function frame:ReRegisterAll()
        for i = 1, #bh.bars do
            local b = bh.bars[i]
            frame:RegisterBar(b.bar, b.priority, b.height)
        end
    end
end

function srslylawlUI.Frame_SetCombatIcon(button)
    if srslylawlUI_ConfigFrame and srslylawlUI_ConfigFrame.fakeFramesToggled then
        button.texture:SetTexCoord(0.5, 1, 0, .5)
        button.wasCombat = true
        button.texture:Show()
        button.wasDemoMode = true
    elseif srslylawlUI_ConfigFrame and button.wasDemoMode and not srslylawlUI_ConfigFrame.fakeFramesToggled then
        button.texture:Hide()
        button.wasDemoMode = nil
        button.inCombat = nil
    end
    local unit = button:GetParent():GetAttribute("unit")
    local inCombat = UnitAffectingCombat(unit)
    local isResting = unit == "player" and IsResting() and button:GetParent():GetAttribute("unitsType") == "mainUnits" or
        nil
    if button.inCombat == inCombat and button.isResting == isResting then return end

    if inCombat then
        if not button.wasCombat then
            button.texture:SetTexCoord(0.5, 1, 0, .5)
            button.wasCombat = true
        end
        button.texture:Show()
    elseif isResting then
        if button.wasCombat ~= false then
            button.texture:SetTexCoord(0, .5, 0, .5)
            button.wasCombat = false
        end
        button.isResting = true
        button.texture:Show()
    else
        button.texture:Hide()
    end

    button.inCombat = inCombat
    button.isResting = isResting
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
    background:SetFrameLevel(frameLevel - 1)
    frame.background = background
end

function srslylawlUI_Frame_OnShow(button)
    local unit = button:GetAttribute("unit")
    if unit then
        local guid = UnitGUID(unit)
        if guid ~= button.guid then
            srslylawlUI.DebugTrackCall("ResetUnitButton ___ ON SHOW " .. unit)
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

function srslylawlUI.Frame_AnchorFromSettings(frame, path)
    local a = srslylawlUI.GetSetting(path)
    srslylawlUI.Utils_SetPointPixelPerfect(frame, a[1], srslylawlUI.TranslateFrameAnchor(a[2]), a[3], a[4], a[5])
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
            srslylawlUI.Frame_ResetCombatIcon(button)
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
        srslylawlUI_PartyHeader.isMoving = false
        local points = { srslylawlUI_PartyHeader:GetPoint() }
        local offsets = { srslylawlUI.Utils_PixelFromScreenToCode(points[4], points[5]) }
        srslylawlUI.ChangeSetting("party.header.position",
            { points[1], srslylawlUI.TranslateFrameAnchor(points[2]), points[3], unpack(offsets) })
        if srslylawlUI_PartyHeader.ResetAnchoringPanel then
            srslylawlUI_PartyHeader:ResetAnchoringPanel(unpack({ points[1], srslylawlUI.TranslateFrameAnchor(points[2]),
                points[3], unpack(offsets) }))
        end
    end
end

function srslylawlUI.Frame_IsHeaderVisible()
    return srslylawlUI_PartyHeader:IsVisible()
end

function srslylawlUI.Frame_UpdateVisibility()
    local function DoIfNotInfight(func)
        if not InCombatLockdown() then
            func()
        else
            C_Timer.After(1, function() DoIfNotInfight(func) end)
        end
    end

    local function UpdateHeaderVisible(show)
        DoIfNotInfight(function()
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
        end)
    end

    if srslylawlUI_FAUX_PartyHeader:IsShown() then return end

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
        DoIfNotInfight(function()
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
        end)
        UpdateHeaderVisible(srslylawlUI.GetSetting("party.visibility.showSolo"))
    end
end

function srslylawlUI.Frame_UpdatePartyHealthBarAlignment()
    local reversed = srslylawlUI.GetSetting("party.hp.reversed")
    local alignment = reversed and "TOPRIGHT" or "TOPLEFT"
    local oAnchor1, oAnchor2 = "TOPRIGHT", "TOPLEFT"
    local anchor1, anchor2 = "TOPLEFT", "TOPRIGHT"
    local oXOffset, xOffset = -1, 1

    for _, unit in pairs(srslylawlUI.partyUnitsTable) do
        local frame = srslylawlUI.partyUnits[unit].unitFrame
        frame.unit.healthBar:ClearAllPoints()
        frame.unit.healthBar:SetPoint(alignment, frame.unit, alignment, 0, 0)
        frame.unit.healthBar.alignment = alignment
        frame.unit.healthBar:SetReverseFill(reversed)
        frame.unit.healthBar.reversed = reversed

        if reversed then
            anchor1, anchor2 = "TOPRIGHT", "TOPLEFT"
            oAnchor1, oAnchor2 = "TOPLEFT", "TOPRIGHT"
            oXOffset, xOffset = 1, -1
        end

        local parent = frame.unit.healthBar
        for i = 1, #srslylawlUI.partyUnits[unit].absorbFramesOverlap do
            local f = srslylawlUI.partyUnits[unit].absorbFramesOverlap[i]
            f:ClearAllPoints()
            srslylawlUI.Utils_SetPointPixelPerfect(f, oAnchor1, parent, oAnchor2, oXOffset, 0)
            parent = f
        end
        parent = frame.unit.healthBar
        for i = 1, #srslylawlUI.partyUnits[unit].absorbFrames do
            local f = srslylawlUI.partyUnits[unit].absorbFrames[i]
            f:ClearAllPoints()
            srslylawlUI.Utils_SetPointPixelPerfect(f, anchor1, parent, anchor2, xOffset, 0)
            parent = f
        end
        srslylawlUI.partyUnits[unit]["effectiveHealthFrames"][1]:ClearAllPoints()
        srslylawlUI.Utils_SetPointPixelPerfect(srslylawlUI.partyUnits[unit]["effectiveHealthFrames"][1], anchor1,
            frame.unit.healthBar, anchor2, xOffset, 0)
    end
    srslylawlUI.Party_HandleAuras_ALL()
end

function srslylawlUI.Frame_UpdateMainHealthBarAlignment()
    for _, unit in pairs({ "player", "target" }) do
        local reversed = srslylawlUI.GetSettingByUnit("hp.reversed", "mainUnits", unit)
        local oAnchor1, oAnchor2 = "TOPRIGHT", "TOPLEFT"
        local anchor1, anchor2 = "TOPLEFT", "TOPRIGHT"
        local oXOffset, xOffset = -1, 1

        local frame = srslylawlUI.mainUnits[unit].unitFrame
        frame.unit.healthBar:SetReverseFill(reversed)
        frame.unit.healthBar.reversed = reversed

        if reversed then
            anchor1, anchor2 = "TOPRIGHT", "TOPLEFT"
            oAnchor1, oAnchor2 = "TOPLEFT", "TOPRIGHT"
            oXOffset, xOffset = 1, -1
        end

        local parent = frame.unit.healthBar
        for i = 1, #srslylawlUI.mainUnits[unit].absorbFramesOverlap do
            local f = srslylawlUI.mainUnits[unit].absorbFramesOverlap[i]
            f:ClearAllPoints()
            srslylawlUI.Utils_SetPointPixelPerfect(f, oAnchor1, parent, oAnchor2, oXOffset, 0)
            parent = f
        end
        parent = frame.unit.healthBar
        for i = 1, #srslylawlUI.mainUnits[unit].absorbFrames do
            local f = srslylawlUI.mainUnits[unit].absorbFrames[i]
            f:ClearAllPoints()
            srslylawlUI.Utils_SetPointPixelPerfect(f, anchor1, parent, anchor2, xOffset, 0)
            parent = f
        end
        srslylawlUI.mainUnits[unit]["effectiveHealthFrames"][1]:ClearAllPoints()
        srslylawlUI.Utils_SetPointPixelPerfect(srslylawlUI.mainUnits[unit]["effectiveHealthFrames"][1], anchor1,
            frame.unit.healthBar, anchor2, xOffset, 0)
    end
    srslylawlUI.Main_HandleAuras_ALL()
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
    --is only called for party as the mainunits one gets managed by barhandler
    -- local unit, unitsType = button:GetAttribute("unit"), button:GetAttribute("unitsType")
    -- local h = srslylawlUI.GetSettingByUnit("hp.height", unitsType, unit)
    local h = srslylawlUI.GetSetting("party.hp.height")
    local h2 = h * srslylawlUI.GetSetting("party.ccbar.heightPercent")
    local w = srslylawlUI.GetSetting("party.ccbar.width")
    button.unit.CCDurBar:SetPoints(w, h2)
    button.unit.CCDurBar:SetReverseFill(srslylawlUI.GetSetting("party.ccbar.reversed"))
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
        local points = { self:GetPoint() }
        local offsets = { srslylawlUI.Utils_PixelFromScreenToCode(points[4], points[5]) }
        srslylawlUI.ChangeSetting("player." .. self:GetAttribute("unit") .. "Frame.position",
            { points[1], srslylawlUI.TranslateFrameAnchor(points[2]), points[3], unpack(offsets) })
        if self.ResetAnchoringPanel then
            self:ResetAnchoringPanel(unpack({ points[1], srslylawlUI.TranslateFrameAnchor(points[2]), points[3],
                unpack(offsets) }))
        end
    end
end

--events
function srslylawlUI.RegisterEvents(buttonFrame)
    local unit = buttonFrame:GetAttribute("unit")
    buttonFrame:RegisterEvent("PLAYER_TARGET_CHANGED") --to show "selected" overlay

    if unit == "target" or unit == "targettarget" then
        buttonFrame:RegisterUnitEvent("UNIT_TARGET", unit)
    end



    if unit ~= "targettarget" then
        if buttonFrame.pet ~= nil and unit ~= "target" and unit ~= "focus" then
            buttonFrame:RegisterUnitEvent("UNIT_PET", unit)
        end

        buttonFrame:RegisterUnitEvent("UNIT_HEALTH", unit, "pet")
        buttonFrame:RegisterUnitEvent("UNIT_MAXHEALTH", unit, "pet")
        buttonFrame:RegisterUnitEvent("UNIT_DISPLAYPOWER", unit)
        buttonFrame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
        buttonFrame:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)
        buttonFrame:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", unit)
        buttonFrame:RegisterUnitEvent("UNIT_EXITED_VEHICLE", unit)
        buttonFrame:RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", unit)
        buttonFrame:RegisterUnitEvent("UNIT_CONNECTION", unit)
        buttonFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit)
        buttonFrame:RegisterUnitEvent("UNIT_AURA", unit)
        buttonFrame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit)
        buttonFrame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unit)
        buttonFrame:RegisterUnitEvent("UNIT_PHASE", unit)
        buttonFrame:RegisterUnitEvent("READY_CHECK_CONFIRM", unit)
        buttonFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)
        buttonFrame:RegisterEvent("READY_CHECK")
        buttonFrame:RegisterEvent("READY_CHECK_FINISHED")
        buttonFrame:RegisterEvent("PARTY_LEADER_CHANGED")
        buttonFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        buttonFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    else
        buttonFrame.TimeSinceLastUpdate = 0
        buttonFrame:HookScript("OnUpdate", function(self, elapsed)
            self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
            if (self.TimeSinceLastUpdate > 0.1) then
                srslylawlUI.Frame_ResetUnitButton(buttonFrame.unit, "targettarget")
                self.TimeSinceLastUpdate = 0
            end
        end)
    end
end

function srslylawlUI_Frame_OnEvent(self, event, arg1, arg2)
    local function UpdatePowerBar(unit, unitsType, token)
        if unit == "player" and unitsType == "mainUnits" then
            srslylawlUI.PowerBar.Update(self, token)
        else
            srslylawlUI.SetPowerBarValues(self.unit, unit)
        end
    end

    local unit = self:GetAttribute("unit")
    srslylawlUI.DebugTrackCall("OnEvent (General) " .. unit)
    srslylawlUI.DebugTrackCall("OnEvent " ..
        unit ..
        " Event: " ..
        event ..
        " " ..
        (arg1 ~= nil and tostring(arg1) or "") ..
        " " .. (arg2 ~= nil and type(arg2) ~= "table" and tostring(arg2) or ""
        ))
    local unitExists = UnitExists(unit)
    local unitsType = self:GetAttribute("unitsType")

    if not unitExists or unitsType == "partyUnits" and not srslylawlUI_PartyHeader:IsShown() then return end
    -- Handle any events that don’t accept a unit argument
    if event == "PLAYER_ENTERING_WORLD" then
        srslylawlUI.HandleAuras(self.unit, unit, nil, "PLAYER_ENTERING_WORLD")
        UpdatePowerBar(unit, unitsType, nil)
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
                if self.portrait then
                    self.portrait:PortraitUpdate()
                end
                self:UpdateUnitLevel()
                self:UpdateUnitFaction()
                srslylawlUI.HandleAuras(self.unit, unit, nil, "PLAYER_TARGET_CHANGED")
            end
            if unit ~= "targettarget" then
                srslylawlUI.Frame_SetCombatIcon(self.unit.CombatIcon)
            end
            srslylawlUI.DebugTrackCall("ResetUnitButton ___ PLAYER TARGET CHANGED " .. unit)
            srslylawlUI.Frame_ResetUnitButton(self.unit, unit)
        end
    elseif event == "PLAYER_FOCUS_CHANGED" then
        if self.CastBar then
            self.CastBar:Hide()
            self.CastBar:Show()
        end
        if self.portrait then
            self.portrait:PortraitUpdate()
        end
        self:UpdateUnitLevel()
        self:UpdateUnitFaction()
        srslylawlUI.HandleAuras(self.unit, unit, nil, "PLAYER_FOCUS_CHANGED")
        srslylawlUI.Frame_SetCombatIcon(self.unit.CombatIcon)
        srslylawlUI.DebugTrackCall("ResetUnitButton ___ PLAYER FOCUS CHANGED " .. unit)
        srslylawlUI.Frame_ResetUnitButton(self.unit, unit)
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" and unit == "player" then
        srslylawlUI.PowerBar.Set(self, unit)
    elseif event == "PLAYER_DEAD" or event == "PLAYER_UNGHOST" then
        UpdatePowerBar(unit, nil)
    elseif event == "PARTY_LEADER_CHANGED" then
        self.PartyLeader:SetShown(UnitIsGroupLeader(unit))
    elseif event == "READY_CHECK" then
        srslylawlUI.Frame_ReadyCheck(self, arg1 == UnitName(unit) and "ready" or "start")
    elseif event == "READY_CHECK_CONFIRM" then
        srslylawlUI.Frame_ReadyCheck(self, arg2 and "ready" or "notready")
    elseif event == "READY_CHECK_FINISHED" then
        srslylawlUI.Frame_ReadyCheck(self, "end")
    elseif event == "UNIT_PET" then
        srslylawlUI.Frame_ResetPetButton(self, unit .. "pet")
    elseif arg1 and UnitIsUnit(unit, arg1) and arg1 ~= "nameplate1" then
        -- Unit events
        if unit == "targettarget" and arg1 ~= unit then
            --Targettarget will receive EVERY unit event so filter them out
            return
        end
        if event == "UNIT_MAXHEALTH" then
            if self.unit.dead ~= UnitIsDeadOrGhost(unit) then
                if unit ~= "targettarget" then
                    srslylawlUI.HandleAbsorbFrames(unit, unitsType)
                    srslylawlUI.HandleEffectiveHealth(unit, unitsType)
                    srslylawlUI.MoveAbsorbAndEffectiveHealthAnchorWithHealth(unit, unitsType)
                end
                srslylawlUI.Frame_ResetUnitButton(self.unit, unit)
            end
            self.unit.healthBar:SetMinMaxValues(0, UnitHealthMax(unit))
            self.unit.healthBar:SetValue(UnitHealth(unit))
        elseif event == "UNIT_TARGET" then
            srslylawlUI.DebugTrackCall("ResetUnitButton ___ UNIT TARGET " .. unit .. " " .. (tostring(arg1)))
            srslylawlUI.Frame_ResetUnitButton(self.unit, unit)
        elseif event == "UNIT_HEALTH" then
            -- might just adjust health value here instead of resetting completely?
            srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
            if unit ~= "targettarget" then
                srslylawlUI.HandleAbsorbFrames(unit, unitsType)
                srslylawlUI.HandleEffectiveHealth(unit, unitsType)
                srslylawlUI.MoveAbsorbAndEffectiveHealthAnchorWithHealth(unit, unitsType)
            end
        elseif event == "UNIT_DISPLAYPOWER" then
            srslylawlUI.Frame_ResetPowerBar(self.unit, unit)
            if unit == "player" and unitsType == "mainUnits" then
                srslylawlUI.PowerBar.Set(self, unit)
            end
        elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_POWER_UPDATE" then
            UpdatePowerBar(unit, unitsType, arg2)
        elseif event == "UNIT_MAXPOWER" then
            if unit == "player" and unitsType == "mainUnits" then
                srslylawlUI.PowerBar.UpdateMax(self, arg2)
            else
                srslylawlUI.SetPowerBarValues(self.unit, unit)
            end
        elseif event == "UNIT_NAME_UPDATE" then
            if unit == "target" then
                srslylawlUI.DebugTrackCall("ResetHealth_2")
                srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
            else
                srslylawlUI.Frame_ResetName(self.unit, unit)
            end
        elseif event == "UNIT_THREAT_SITUATION_UPDATE" then
            srslylawlUI.Frame_ResetUnitThreat(self.unit, unit)
        elseif event == "UNIT_CONNECTION" then
            srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
            srslylawlUI.Frame_ResetPowerBar(self.unit, unit)
            if unitsType == "partyUnits" then
                if UnitName(unit) ~= "Unknown" then
                    srslylawlUI.Log(UnitName(unit) ..
                        (UnitIsConnected(unit) and " is now online." or " disconnected."
                        ))
                end
            end
        elseif event == "UNIT_AURA" or event == "UNIT_ABSORB_AMOUNT_CHANGED" or
            event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" or event == "UNIT_HEAL_PREDICTION" then
            local updatedAuras = (event == "UNIT_AURA") and arg2 or nil
            srslylawlUI.HandleAuras(self.unit, unit, updatedAuras, event)
        elseif event == "UNIT_PHASE" then
            srslylawlUI.DebugTrackCall("ResetHealth_4")
            srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
        elseif event == "UNIT_PORTRAIT_UPDATE" and (unit == "target" or unit == "player") then
            self.portrait:PortraitUpdate()
        elseif event == "UNIT_MODEL_CHANGED" and (unit == "target" or unit == "player") then
            self.portrait:ModelUpdate()
        elseif event == "UNIT_FACTION" then
            self:UpdateUnitFaction()
        elseif event == "UNIT_ENTERED_VEHICLE" then
            srslylawlUI.DebugTrackCall("ResetHealth_5")
            srslylawlUI.Frame_ResetHealthBar(self.unit, unit)
        elseif event == "UNIT_EXITED_VEHICLE" then
            srslylawlUI.DebugTrackCall("ResetHealth_6")
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

function srslylawlUI.Frame_ResetUnitThreat(button, unit)
    if not UnitExists(unit) then return end
    local status = UnitThreatSituation(unit)
    if status and status > 0 then
        local r, g, b = GetThreatStatusColor(status)
        button.healthBar.leftText:SetTextColor(r, g, b)
    else
        button.healthBar.leftText:SetTextColor(1, 1, 1)
    end
end

function srslylawlUI.Frame_ResetUnitButton(button, unit)
    srslylawlUI.DebugTrackCall("ResetUnitButton " .. unit)
    srslylawlUI.Frame_ResetHealthBar(button, unit)
    srslylawlUI.Frame_ResetPowerBar(button, unit)
    if unit ~= "target" and unit ~= "targettarget" then
        srslylawlUI.Frame_ResetName(button, unit)
    end
    if button.pet then srslylawlUI.Frame_ResetPetButton(button, unit .. "pet") end
    button.RaidIcon:SetRaidIcon()
    if UnitIsUnit(unit, "target") and button:GetAttribute("unitsType") == "partyUnits" then
        button.selected:Show()
    else
        button.selected:Hide()
    end
end

function srslylawlUI.Frame_ResetName(button, unit)
    srslylawlUI.DebugTrackCall("ResetName " .. unit)
    if unit == "target" or unit == "targettarget" then
        srslylawlUI.Frame_ResetHealthBar(button, unit)
        return
    end
    local name = UnitName(unit) or UNKNOWN
    button.healthBar.leftText:SetLimitedText(button.healthBar:GetWidth() * 0.45, name, true)
end

function srslylawlUI.Frame_ResetPetButton(button, unit)
    local show = button.pet and
        srslylawlUI.GetSettingByUnit("pet.enabled", button:GetAttribute("unitsType"), button:GetAttribute("unit"))

    if not InCombatLockdown() then
        if show then
            RegisterUnitWatch(button)
        else
            UnregisterUnitWatch(button)
        end
    end

    if show then
        local health = UnitHealth(unit)
        local maxHealth = UnitHealth(unit)
        button.pet.healthBar:SetMinMaxValues(0, maxHealth)
        button.pet.healthBar:SetValue(health)
    end
end

function srslylawlUI.Frame_ResetHealthBar(button, unit)
    srslylawlUI.DebugTrackCall("ResetHealthBar " .. unit)
    local class = select(2, UnitClass(unit))
    local SBColor
    local isPlayer = UnitIsPlayer(unit)
    local health = UnitHealth(unit)
    local healthMax = UnitHealthMax(unit)
    healthMax = healthMax == 0 and 1 or healthMax
    local healthPercent = healthMax == 0 and 100 or srslylawlUI.Utils_ScuffedRound(health / healthMax * 100)

    local rightText = ""
    if unit == "target" then
        rightText = srslylawlUI.ShortenNumber(health) .. "/" .. srslylawlUI.ShortenNumber(healthMax)
    else
        rightText = srslylawlUI.ShortenNumber(health) .. " " .. healthPercent .. "%"
    end
    if isPlayer and class then
        SBColor = { RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b,
            RAID_CLASS_COLORS[class].a }
        local dead = UnitIsDeadOrGhost(unit)
        local online = UnitIsConnected(unit)
        local inRange = UnitInRange(unit)
        local differentPhase = UnitPhaseReason(unit)
        if dead or not online then
            -- set bar color to grey and fill bar
            SBColor[1], SBColor[2], SBColor[3] = 0.3, 0.3, 0.3
            if dead then
                rightText = "DEAD"
            elseif not online then
                rightText = "offline"
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
            rightText = phaseReason
        end
        if unit == "player" or inRange or button:GetAttribute("unitsType") == "mainUnits" then
            SBColor[4] = 1
        else
            SBColor[4] = 0.4
        end
        button.dead = dead
        button.online = online
        button.wasInRange = inRange
    else --npc
        SBColor = { UnitSelectionColor(unit, true) }
        if not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) and UnitCanAttack("player", unit) then
            SBColor = { 0.5, 0.5, 0.5, 1 }
        end
    end

    if unit == "target" then
        local name = UnitName(unit) or UNKNOWN
        button.healthBar.leftText:SetLimitedText(button.healthBar:GetWidth() * 0.52, healthPercent .. "%" .. " " .. name
            , true)
        button.healthBar.rightText:SetLimitedText(button.healthBar:GetWidth() * 0.45, rightText)
    elseif unit == "targettarget" then
        local name = UnitName(unit) or UNKNOWN
        button.healthBar.leftText:SetLimitedText(button.healthBar:GetWidth(), healthPercent .. "%" .. " " .. name, true)
    else
        button.healthBar.rightText:SetLimitedText(button.healthBar:GetWidth() * 0.45, rightText)
    end
    button.healthBar:SetMinMaxValues(0, healthMax)
    button.healthBar:SetValue(health)
    button.healthBar:SetStatusBarColor(unpack(SBColor))
    if button:GetAttribute("unitsType") ~= "fauxUnits" and unit ~= "targettarget" then
        button.healthBar.effectiveHealthFrame.texture:SetVertexColor(SBColor[1], SBColor[2], SBColor[3], .5)
    end
    srslylawlUI.Frame_ResetUnitThreat(button, unit)
end

function srslylawlUI.Frame_ResetPowerBar(button, unit)
    local unitsType = button:GetAttribute("unitsType")
    local powerType, powerToken = UnitPowerType(unit)
    local powerColor = srslylawlUI.Frame_GetCustomPowerBarColor(powerToken)
    local alive = not UnitIsDeadOrGhost(unit)
    local online = UnitIsConnected(unit)
    if alive and online then
        button.powerBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
    else
        button.powerBar:SetStatusBarColor(0.3, 0.3, 0.3)
    end
    button.powerBar.text.enabled = srslylawlUI.GetSettingByUnit("power.text", unitsType, unit)
    srslylawlUI.SetPowerBarValues(button, unit)
    if unitsType ~= "mainUnits" or unit ~= "player" then
        local enabled = srslylawlUI.GetSettingByUnit("power.enabled", unitsType, unit)
        button.powerBar:SetShown(enabled)
    end
end

function srslylawlUI.SetPowerBarValues(button, unit)
    local max = UnitPowerMax(unit)
    max = max == 0 and 1 or max
    local curr = UnitPower(unit)
    button.powerBar:SetMinMaxValues(0, max)
    button.powerBar:SetValue(curr)
    if button.powerBar.text.enabled then
        local percent = max > 0 and srslylawlUI.Utils_ScuffedRound(curr / max * 100) or -1
        button.powerBar.text:SetText(percent >= 0 and percent or "")
    else
        button.powerBar.text:SetText("")
    end
    if button.powerBar:IsShown() ~= (max > 0) then
        button.powerBar:SetShown(max > 0)
    end
end

function srslylawlUI.Frame_ResetDimensions(button)
    local unit = button:GetAttribute("unit")
    srslylawlUI.DebugTrackCall("ResetDimensions " .. unit)
    local unitsType = button:GetAttribute("unitsType")
    local h, w = srslylawlUI.GetSettingByUnit("hp.height", unitsType, unit),
        srslylawlUI.GetSettingByUnit("hp.width", unitsType, unit)
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
            srslylawlUI.MoveAbsorbAndEffectiveHealthAnchorWithHealth(unit, unitsType)
        end

        if not InCombatLockdown() then
            -- stuff that taints in combat
            local frameH = srslylawlUI.GetSettingByUnit("hp.height", unitsType, unit)
            local frameW = srslylawlUI.GetSettingByUnit("hp.width", unitsType, unit)
            srslylawlUI.Utils_SetSizePixelPerfect(button.unit, frameW, frameH)
        end

        if unit == "player" and unitsType == "mainUnits" then
            button:SetPoints() --reparent powerbars
        end
    end

    button.unit.healthBar.leftText:SetFont("Fonts\\FRIZQT__.TTF", fontSize)
    button.unit.healthBar.rightText:SetFont("Fonts\\FRIZQT__.TTF", fontSize)

    button.unit.RaidIcon:SetPoints()
    button.unit.RaidIcon:Resize()

    srslylawlUI.Frame_ResetUnitButton(button.unit, button:GetAttribute("unit"))
end

function srslylawlUI.Frame_ResetDimensions_Pet(button)
    --manipulating the petframe will cause taint in combat
    if InCombatLockdown() then
        srslylawlUI.SortAfterCombat()
        return
    end
    local unit = button:GetAttribute("unit")
    local unitsType = button:GetAttribute("unitsType")
    if unitsType ~= "mainUnits" and unitsType ~= "mainFauxUnits" then
        srslylawlUI.Utils_SetPointPixelPerfect(button.pet, "TOPLEFT", button.unit, "TOPRIGHT", 1, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(button.pet, "BOTTOMRIGHT", button.unit, "BOTTOMRIGHT",
            srslylawlUI.GetSetting("party.pet.width"), 0)
        srslylawlUI.Utils_SetPointPixelPerfect(button.unit.CCDurBar, "BOTTOMLEFT", button.unit, "BOTTOMRIGHT",
            srslylawlUI.GetSetting("party.pet.width") + 4, 0)
    else
        if unit == "player" then
            button.pet:ClearAllPoints()
            local parent = button.unit
            --if player frame has portrait active and set to left, anchor to that instead
            if srslylawlUI.GetSetting("player.playerFrame.portrait.enabled", true) and
                srslylawlUI.GetSetting("player.playerFrame.portrait.position", true) == "LEFT" then
                if unitsType == "mainFauxUnits" then
                    parent = srslylawlUI.Frame_GetFrameByUnit("player", "mainUnits").portrait
                else
                    parent = button.portrait
                end
            end
            srslylawlUI.Utils_SetPointPixelPerfect(button.pet, "TOPRIGHT", parent, "TOPLEFT", -1, 0)
            srslylawlUI.Utils_SetPointPixelPerfect(button.pet, "BOTTOMLEFT", parent, "BOTTOMLEFT",
                -srslylawlUI.GetSetting("player." .. unit .. "Frame.pet.width") - 1, 0)
        end
    end

end

function srslylawlUI.Frame_ResetDimensions_PowerBar(button)
    local unitsType = button:GetAttribute("unitsType")
    button.unit.powerBar:ClearAllPoints()
    local width
    local baseWidth
    if unitsType == "partyUnits" or unitsType == "fauxUnits" then
        baseWidth = srslylawlUI.GetDefault("party.power.width")
        width = srslylawlUI.GetSetting("party.power.width")
        srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "BOTTOMRIGHT", button.unit, "BOTTOMLEFT", -1, 0)
        srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "TOPLEFT", button.unit, "TOPLEFT", -(2 + width), 0)
    else
        local unit = button:GetAttribute("unit")
        baseWidth = srslylawlUI.GetDefaultByUnit("power.width", unitsType, unit)
        width = srslylawlUI.GetSettingByUnit("power.width", unitsType, unit)
        if unit ~= "player" then
            local pos = srslylawlUI.GetSettingByUnit("power.position", unitsType, unit)
            if pos == "LEFT" then
                srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "BOTTOMRIGHT", button.unit, "BOTTOMLEFT",
                    -
                    1, 0)
                srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "TOPLEFT", button.unit, "TOPLEFT",
                    -(2 + width), 0)
            else
                srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "BOTTOMLEFT", button.unit, "BOTTOMRIGHT", 1
                    , 0)
                srslylawlUI.Utils_SetPointPixelPerfect(button.unit.powerBar, "TOPRIGHT", button.unit, "TOPRIGHT",
                    (2 + width), 0)
            end
        end
    end

    if button.unit.powerBar.text.enabled then
        button.unit.powerBar.text:ScaleToFit(width, width, baseWidth)
    end
end

function srslylawlUI.Frame_ResetCombatIcon(unitFrame)
    local unitsType = unitFrame:GetAttribute("unitsType")
    local unit = unitFrame:GetAttribute("unit")
    local size = srslylawlUI.GetSettingByUnit("combatRestIcon.size", unitsType, unit)
    local position = srslylawlUI.GetSettingByUnit("combatRestIcon.position", unitsType, unit)
    unitFrame.unit.CombatIcon:ClearAllPoints()
    srslylawlUI.Utils_SetSizePixelPerfect(unitFrame.unit.CombatIcon, size, size)
    srslylawlUI.Utils_SetPointPixelPerfect(unitFrame.unit.CombatIcon, unpack(position))
    unitFrame.unit.CombatIcon:SetShown(srslylawlUI.GetSettingByUnit("combatRestIcon.enabled", unitsType, unit))
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

    if bool then
        srslylawlUI.Frame_UpdateVisibility()
    else
        srslylawlUI_PartyHeader:SetShown(bool)
    end
end

function srslylawlUI.SetAuraPoints(unit, unitsType, auraType)
    srslylawlUI.DebugTrackCall("SetAuraPoints " .. unit)
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
            return firstPoint .. str:sub(i)
        elseif pos == 2 then
            local secondPoint
            local i = string.len(str)
            local max = i
            while not secondPoint and i > 0 do
                secondPoint = ReversePos(str:sub(i, max))
                i = i - 1
            end
            return str:sub(1, i) .. secondPoint
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
        path = path .. unit .. "Frame."
    end

    local anchorMethod = srslylawlUI.GetSetting(path .. auraType .. ".anchor")
    local maxRowLength, initialAnchorPoint, initialAnchorPointRelative, anchorPoint, anchorPointRelative
    local offset = 3
    local initialXOffset, initialYOffset, xOffset, yOffset
    local defaultSize = srslylawlUI.GetSetting(path .. auraType .. ".size")
    local scaledSize = defaultSize + srslylawlUI.GetSetting(path .. auraType .. ".scaledSize")
    local frameXOffset = srslylawlUI.GetSetting(path .. auraType .. ".xOffset")
    local frameYOffset = srslylawlUI.GetSetting(path .. auraType .. ".yOffset")

    local anchorTo = srslylawlUI.GetSetting(path .. auraType .. ".anchoredTo")
    if anchorTo == "Buffs" and unitsTable[unit]["buffsAnchor"] and unitsTable[unit]["buffsAnchor"]:IsShown() then
        rowAnchor = unitsTable[unit]["buffsAnchor"]
        anchorMethod = srslylawlUI.GetSetting(path .. "buffs.anchor")
    elseif anchorTo == "Debuffs" and unitsTable[unit]["debuffsAnchor"] and unitsTable[unit]["debuffsAnchor"]:IsShown() then
        rowAnchor = unitsTable[unit]["debuffsAnchor"]
        anchorMethod = srslylawlUI.GetSetting(path .. "debuffs.anchor")
    else
        rowAnchor = unitFrame.unit
    end

    if anchorMethod == "TOPLEFT" or anchorMethod == "TOPRIGHT" or anchorMethod == "BOTTOMLEFT" or
        anchorMethod == "BOTTOMRIGHT" then
        maxRowLength = srslylawlUI.GetSetting(path .. "hp.width")
        initialAnchorPoint = ReverseAnchorPointPos(anchorMethod, 1)
        initialAnchorPointRelative = anchorMethod
        anchorPoint = (anchorMethod == "TOPLEFT" or anchorMethod == "BOTTOMLEFT") and "LEFT" or "RIGHT"
        anchorPointRelative = (anchorMethod == "TOPLEFT" or anchorMethod == "BOTTOMLEFT") and "RIGHT" or "LEFT"
        initialXOffset = 0
        initialYOffset = (anchorMethod == "TOPLEFT" or anchorMethod == "TOPRIGHT") and 1 or -1
        xOffset = (anchorMethod == "TOPLEFT" or anchorMethod == "BOTTOMLEFT") and 1 or -1
        yOffset = 0
    else
        maxRowLength = srslylawlUI.GetSetting(path .. "hp.height")
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
    if unitsTable[unit][auraType .. "Anchor"] then
        unitsTable[unit][auraType .. "Anchor"]:SetScript("OnHide", nil)
    end
    local rowHasScaledFrame = false
    local lastRowHasScaledFrame = rowAnchor.rowHasScaledFrame or not rowAnchor == unitFrame.unit or false
    local rowAnchorIsScaled = rowAnchor.isScaled or not rowAnchor == unitFrame.unit or false
    local lastAnchorWasOffset = false
    local anchorFrame
    for i = 1, #frames do
        local frame = frames[i]
        local frameSize = frame.size or defaultSize
        if frame:IsShown() and frameSize > defaultSize then
            rowHasScaledFrame = true
        end
        frame:ClearAllPoints()
        if i == 1 then
            frame.anchor = rowAnchor
            if not rowAnchorIsScaled and lastRowHasScaledFrame and rowAnchor.size then --if rowanchor is not scaled and their row had a scaled frame
                local scaledOffset = (frameSize - rowAnchor.size) / 2
                srslylawlUI.Utils_SetPointPixelPerfect(frame, initialAnchorPoint, rowAnchor, initialAnchorPointRelative,
                    (initialXOffset * offset) + frameXOffset + (initialXOffset * scaledOffset),
                    (initialYOffset * offset) + frameYOffset + (initialYOffset * scaledOffset))
            else
                srslylawlUI.Utils_SetPointPixelPerfect(frame, initialAnchorPoint, rowAnchor, initialAnchorPointRelative,
                    (initialXOffset * offset) + frameXOffset, (initialYOffset * offset) + frameYOffset)
            end
            rowAnchor = frame
            if frame:IsShown() then
                unitsTable[unit][auraType .. "Anchor"] = frame
                anchorFrame = frame
                anchorFrame.size = frameSize
                rowAnchorIsScaled = rowHasScaledFrame
                lastAnchorWasOffset = false
            else
                unitsTable[unit][auraType .. "Anchor"] = unitFrame.unit
            end
            ReparentOnHideShow(frame)
            currentRowLength = frameSize
        else
            if currentRowLength + frameSize + offset > maxRowLength then
                --doesnt fit into row
                frame.anchor = rowAnchor
                if rowHasScaledFrame and not rowAnchorIsScaled and rowAnchor.size then
                    local scaledOffset
                    scaledOffset = (scaledSize - rowAnchor.size) / 2
                    srslylawlUI.Utils_SetPointPixelPerfect(frame, initialAnchorPoint, rowAnchor,
                        initialAnchorPointRelative, (initialXOffset * offset) + (initialXOffset * scaledOffset),
                        (initialYOffset * offset) + (initialYOffset * scaledOffset))
                else
                    srslylawlUI.Utils_SetPointPixelPerfect(frame, initialAnchorPoint, rowAnchor,
                        initialAnchorPointRelative, (initialXOffset * offset), (initialYOffset * offset))
                end

                rowAnchor = frame
                if frame:IsShown() then
                    unitsTable[unit][auraType .. "Anchor"] = frame
                    anchorFrame = frame
                    anchorFrame.size = frameSize
                    frame.rowHasScaledFrame = rowHasScaledFrame
                    rowAnchorIsScaled = rowHasScaledFrame
                    lastAnchorWasOffset = false
                end
                ReparentOnHideShow(frame)
                currentRowLength = frameSize
            else
                srslylawlUI.Utils_SetPointPixelPerfect(frame, anchorPoint, frames[i - 1], anchorPointRelative,
                    xOffset * offset, yOffset * offset)
                currentRowLength = currentRowLength + frameSize + offset
                frame:SetScript("OnHide", nil)
                frame:SetScript("OnShow", nil)
            end
        end
        if rowHasScaledFrame and anchorFrame and not rowAnchorIsScaled and not lastAnchorWasOffset then
            lastAnchorWasOffset = true
            scaledSize = frameSize
            local scaledOffset = (frameSize - anchorFrame.size) / 2
            if anchorFrame.anchor.size and anchorFrame.anchor.size == anchorFrame.size then
                scaledOffset = scaledOffset * 2
            end
            if anchorFrame == frames[1] then
                srslylawlUI.Utils_SetPointPixelPerfect(anchorFrame, initialAnchorPoint, anchorFrame.anchor,
                    initialAnchorPointRelative,
                    (initialXOffset * offset) + frameXOffset + (initialXOffset * scaledOffset
                    ), (initialYOffset * offset) + frameYOffset + (initialYOffset * scaledOffset))
            else
                srslylawlUI.Utils_SetPointPixelPerfect(anchorFrame, initialAnchorPoint, anchorFrame.anchor,
                    initialAnchorPointRelative, (initialXOffset * offset) + (initialXOffset * scaledOffset),
                    (initialYOffset * offset) + (initialYOffset * scaledOffset))
            end

            anchorFrame.rowHasScaledFrame = true
            anchorFrame.isScaled = anchorFrame.size > defaultSize
        end
        rowHasScaledFrame = false
        srslylawlUI.Utils_SetSizePixelPerfect(frame, frameSize, frameSize)
    end
end

function srslylawlUI.SetAuraPointsAll(unit, unitsType)
    --order matters depending on what is anchored to what
    if srslylawlUI[unitsType][unit].buffsAnchor then
        srslylawlUI[unitsType][unit].buffsAnchor.rowHasScaledFrame = nil
        srslylawlUI[unitsType][unit].buffsAnchor.isScaled = nil
    end
    if srslylawlUI[unitsType][unit].debuffsAnchor then
        srslylawlUI[unitsType][unit].debuffsAnchor.rowHasScaledFrame = nil
        srslylawlUI[unitsType][unit].debuffsAnchor.isScaled = nil
    end
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
        color = { r = 0.349, g = 0.522, b = 0.953 }
    elseif powerToken == "LUNAR_POWER" or powerToken == "MAELSTROM" then
        color = { r = 0, g = 0, b = 1 }
    end
    color = color or { r = 1, g = 1, b = 1 }
    return color
end

function srslylawlUI.Frame_ResizeHealthBarScale()
    local list, highestHP, averageHP = srslylawlUI.GetPartyHealth()

    if not highestHP or highestHp == 0 then
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
            alpha = alpha - elapsed * 0.1
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
    srslylawlUI.DebugTrackCall("SortPartyFrames")
    if not srslylawlUI.GetSetting("party.sorting.enabled") then
        local showPlayer = srslylawlUI.GetSetting("party.visibility.showPlayer")
        if not srslylawlUI.partyFramesDefaultSortActive or
            (showPlayer ~= srslylawlUI.partyUnits["player"].unitFrame.unit.registered) then
            local parent = srslylawlUI_PartyHeader
            for i, unit in ipairs(srslylawlUI.partyUnitsTable) do
                local buttonFrame = srslylawlUI.partyUnits[unit].unitFrame.unit
                if buttonFrame and not (unit == "player" and not showPlayer) then
                    buttonFrame:ClearAllPoints()
                    if parent == srslylawlUI_PartyHeader then
                        buttonFrame:SetPoint("TOPLEFT", parent, "TOPLEFT")
                    else
                        srslylawlUI.Utils_SetPointPixelPerfect(buttonFrame, "TOPLEFT", parent, "BOTTOMLEFT", 0, -1)
                    end
                    parent = buttonFrame
                end
                if unit == "player" then
                    if not showPlayer then
                        if buttonFrame.registered then
                            UnregisterUnitWatch(buttonFrame)
                            buttonFrame.registered = false
                            buttonFrame:Hide()
                        end
                    else
                        if not buttonFrame.registered then
                            RegisterUnitWatch(buttonFrame)
                            buttonFrame.registered = true
                        end
                    end
                end
            end
            srslylawlUI.partyFramesDefaultSortActive = true
        end
        return
    end
    local list, _, _, hasUnknownMember = srslylawlUI.GetPartyHealth()

    if not list then return end

    if InCombatLockdown() then
        srslylawlUI.SortAfterCombat()
        return
    end
    srslylawlUI.partyFramesDefaultSortActive = false
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

    --TODO: parent units that arent visible anyway, so they arent fucked up when someone joins mid fight, just unsorted instead.
    --Done: partyhealth returns list of all units now even if they are not active, so should properly sort in all cases

    local parent = srslylawlUI_PartyHeader
    for i, v in ipairs(list) do
        local unit = v.unit
        local buttonFrame = srslylawlUI.Frame_GetFrameByUnit(unit, "partyUnits").unit
        local showPlayer = srslylawlUI.GetSetting("party.visibility.showPlayer")
        local unitIsPlayer = unit == "player"

        if buttonFrame and not (unitIsPlayer and not showPlayer) then
            buttonFrame:ClearAllPoints()
            if parent == srslylawlUI_PartyHeader then
                buttonFrame:SetPoint("TOPLEFT", parent, "TOPLEFT")
            else
                srslylawlUI.Utils_SetPointPixelPerfect(buttonFrame, "TOPLEFT", parent, "BOTTOMLEFT", 0, -1)
            end
            parent = buttonFrame
            srslylawlUI.Frame_ResetUnitButton(buttonFrame, list[i].unit)
        end

        if unitIsPlayer then
            if not showPlayer then
                if buttonFrame.registered then
                    UnregisterUnitWatch(buttonFrame)
                    buttonFrame.registered = false
                    buttonFrame:Hide()
                end
            else
                if not buttonFrame.registered then
                    RegisterUnitWatch(buttonFrame)
                    buttonFrame.registered = true
                end
            end
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
