function srslylawlUI.ToggleFauxFrames(visible)
    srslylawlUI_FAUX_PartyHeader:SetShown(visible)
    if not visible then
        srslylawlUI.Frame_UpdateVisibility()
    else
        srslylawlUI_PartyHeader:Hide()
    end

    if not srslylawlUI_FAUX_PartyHeader.initiated then
        local class = select(2, UnitClass("player")) or "WARRIOR"
        local health = UnitHealthMax("player")
        local _, powerToken = UnitPowerType("player")
        local fauxUnit = {
            ["class"] = class,
            ["hpmax"] = health,
            ["hp"] = ceil(health / 1.5),
            ["mana"] = 1,
            ["powerToken"] = powerToken,
            ["CCIcon"] = 132298,
            ["CCColor"] = "none",
            ["CCMaxDur"] = 6,
            ["pethp"] = 1
        }
        for i, unit in pairs(srslylawlUI.partyUnitsTable) do
            local frame = _G["srslylawlUI_FAUX_PartyHeader_" .. unit]

            if unit == "party1" then
                fauxUnit.class = "WARLOCK"
                fauxUnit.hpmax = ceil(fauxUnit.hpmax * 0.95)
                fauxUnit.hp = ceil(fauxUnit.hpmax)
                fauxUnit.mana = 1
                fauxUnit.powerToken = "MANA"
                fauxUnit.CCIcon = 136071 --poly
                fauxUnit.CCColor = "Magic"
                fauxUnit.CCMaxDur = 8
                fauxUnit.pethp = .8
            elseif unit == "party2" then
                fauxUnit.class = "ROGUE"
                fauxUnit.hpmax = ceil(fauxUnit.hpmax * 0.90)
                fauxUnit.hp = ceil(fauxUnit.hpmax * 0.6)
                fauxUnit.mana = 0.4
                fauxUnit.powerToken = "ENERGY"
                fauxUnit.CCIcon = 132310 -- sap
                fauxUnit.CCColor = "none"
                fauxUnit.CCMaxDur = 8
                fauxUnit.pethp = .5
            elseif unit == "party3" then
                fauxUnit.class = "MAGE"
                fauxUnit.hpmax = ceil(fauxUnit.hpmax)
                fauxUnit.hp = ceil(fauxUnit.hpmax * 0.3)
                fauxUnit.mana = 0.8
                fauxUnit.powerToken = "MANA"
                fauxUnit.CCIcon = 136183 -- fear
                fauxUnit.CCColor = "Magic"
                fauxUnit.CCMaxDur = 6
                fauxUnit.pethp = .2
            elseif unit == "party4" then
                fauxUnit.class = "SHAMAN"
                fauxUnit.hpmax = ceil(fauxUnit.hpmax * 0.2)
                fauxUnit.hp = ceil(fauxUnit.hpmax)
                fauxUnit.mana = 0.3
                fauxUnit.powerToken = "MANA"
                fauxUnit.CCIcon = 458230 -- silence
                fauxUnit.CCColor = "Magic"
                fauxUnit.CCMaxDur = 4
                fauxUnit.pethp = .6
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

            AddTooltip(frame.unit, unit .. " frame")
            AddTooltip(frame.pet, unit .. " petframe")
            AddTooltip(frame.unit.powerBar, unit .. " power bar")

            --CC bar
            local timerCC, duration, expirationTime, remaining = 0, fauxUnit.CCMaxDur, 0, 0
            frame.unit.CCDurBar:SetScript("OnUpdate",
                function(self, elapsed)
                    timerCC = timerCC + elapsed
                    if timerCC >= 0.025 then
                        remaining = expirationTime - GetTime()
                        self.statusBar:SetValue(remaining / duration)
                        local timerstring = tostring(remaining)
                        timerstring = timerstring:match("%d+%p?%d")
                        self.timer:SetText(timerstring)
                        timerCC = 0
                    end
                    if remaining <= 0 then
                        expirationTime = GetTime() + duration
                    end
                end)
            frame.unit.CCDurBar:SetShown(srslylawlUI.GetSetting("party.ccbar.enabled"))
            frame.unit.CCDurBar.icon:SetTexture(fauxUnit.CCIcon)
            local color = DebuffTypeColor[fauxUnit.CCColor]
            frame.unit.CCDurBar.statusBar:SetStatusBarColor(color.r, color.g, color.b)

            color = RAID_CLASS_COLORS[fauxUnit.class]

            local hp = (srslylawlUI.ShortenNumber(fauxUnit.hp) .. " " .. ceil(fauxUnit.hp / fauxUnit.hpmax * 100) .. "%"
                )

            local powerToken = fauxUnit.powerToken
            local powerColor = srslylawlUI.Frame_GetCustomPowerBarColor(powerToken)
            frame.unit.powerBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
            frame.unit.powerBar:SetMinMaxValues(0, 1)
            frame.unit.powerBar:SetValue(fauxUnit.mana)
            frame.unit.powerBar:Show()
            frame.unit.powerBar.text:SetText(ceil(fauxUnit.mana / 1 * 100))

            frame.unit.RaidIcon:SetRaidIcon(i + 1)

            frame.pet.healthBar:SetMinMaxValues(0, 1)
            frame.pet.healthBar:SetValue(fauxUnit.pethp)
            frame.unit.healthBar.leftText:SetText(unit)
            frame.unit.healthBar.rightText:SetText(hp)
            frame.unit.healthBar:SetMinMaxValues(0, fauxUnit.hpmax)
            frame.unit.healthBar:SetValue(fauxUnit.hp)
            frame.unit.CombatIcon.texture:SetTexCoord(0.5, 1, 0, .5)
            frame.unit.CombatIcon.texture:Show()

            if unit ~= "player" then
                frame.unit.healthBar:SetStatusBarColor(color.r, color.g, color.b)
            end

            --buffs
            frame.buffs = {}
            local frames = srslylawlUI.fauxUnits[unit].buffFrames
            for i = 1, 40 do
                local f = frames[i]
                if f then
                    f.icon:SetTexture(135932)
                    frame.buffs[i] = f
                end
            end
            --debuffs
            frame.debuffs = {}
            local frames = srslylawlUI.fauxUnits[unit].debuffFrames
            for i = 1, 40 do
                local f = frames[i]
                if f then
                    f.icon:SetTexture(136207)
                    frame.debuffs[i] = f
                end
            end

            local timerFrame = 1

            --update frames to reflect current settings
            frame:SetScript("OnUpdate",
                function(self, elapsed)
                    timerFrame = timerFrame + elapsed
                    if InCombatLockdown() then return end
                    if timerFrame > 0.1 then
                        local countChanged = self.shownBuffs ~= srslylawlUI.GetSetting("party.buffs.maxBuffs")
                        local anchorChanged = self.buffs.anchor ~= srslylawlUI.GetSetting("party.buffs.anchor") or
                            self.buffs.xOffset ~= srslylawlUI.GetSetting("party.buffs.xOffset") or
                            self.buffs.yOffset ~= srslylawlUI.GetSetting("party.buffs.yOffset")
                        local sizeChanged = self.buffs.size ~= srslylawlUI.GetSetting("party.buffs.size")
                        local anchorToChanged = self.buffs.anchoredTo ~= srslylawlUI.GetSetting("party.buffs.anchoredTo")
                        if countChanged or anchorChanged or sizeChanged or anchorToChanged then
                            self.shownBuffs = srslylawlUI.GetSetting("party.buffs.maxBuffs")
                            for i = 1, 40 do
                                self.buffs[i]:SetShown(i <= self.shownBuffs)
                                local size = srslylawlUI.GetSetting("party.buffs.size")
                                self.buffs.size = size
                                if (i == 1) then
                                    anchor = srslylawlUI.GetSetting("party.buffs.anchor")
                                    xOffset = srslylawlUI.GetSetting("party.buffs.xOffset")
                                    yOffset = srslylawlUI.GetSetting("party.buffs.yOffset")
                                    self.buffs.anchor = anchor
                                    self.buffs.xOffset = xOffset
                                    self.buffs.yOffset = yOffset
                                    self.buffs.size = size
                                    self.buffs.anchoredTo = srslylawlUI.GetSetting("party.buffs.anchoredTo")
                                end
                                srslylawlUI.Utils_SetSizePixelPerfect(self.buffs[i], size, size)
                            end
                        end
                        countChanged = self.shownDebuffs ~= srslylawlUI.GetSetting("party.debuffs.maxDebuffs")
                        sizeChanged = self.debuffs.size ~= srslylawlUI.GetSetting("party.debuffs.size")
                        anchorChanged = self.debuffs.anchor ~= srslylawlUI.GetSetting("party.debuffs.anchor") or
                            self.debuffs.xOffset ~= srslylawlUI.GetSetting("party.debuffs.xOffset") or
                            self.debuffs.yOffset ~= srslylawlUI.GetSetting("party.debuffs.yOffset")
                        anchorToChanged = self.debuffs.anchoredTo ~= srslylawlUI.GetSetting("party.debuffs.anchoredTo")
                        if countChanged or anchorChanged or sizeChanged or anchorToChanged then
                            self.shownDebuffs = srslylawlUI.GetSetting("party.debuffs.maxDebuffs")
                            for i = 1, 40 do
                                self.debuffs[i]:SetShown(i <= self.shownDebuffs)
                                local size = srslylawlUI.GetSetting("party.debuffs.size")
                                self.debuffs[i].size = size
                                if (i == 1) then
                                    anchor = srslylawlUI.GetSetting("party.debuffs.anchor")
                                    xOffset = srslylawlUI.GetSetting("party.debuffs.xOffset")
                                    yOffset = srslylawlUI.GetSetting("party.debuffs.yOffset")
                                    self.debuffs.anchor = anchor
                                    self.debuffs.xOffset = xOffset
                                    self.debuffs.yOffset = yOffset
                                    self.debuffs.size = size
                                    self.debuffs.anchoredTo = srslylawlUI.GetSetting("party.debuffs.anchoredTo")
                                end
                            end
                        end
                        srslylawlUI.SetAuraPointsAll(unit, "fauxUnits")
                        fontSizeChanged = self.fontSize ~= srslylawlUI.GetSetting("party.hp.fontSize")
                        if fontSizeChanged then
                            self.fontSize = srslylawlUI.GetSetting("party.hp.fontSize")
                            self.unit.healthBar.leftText:SetFont("Fonts\\FRIZQT__.TTF", self.fontSize)
                            self.unit.healthBar.rightText:SetFont("Fonts\\FRIZQT__.TTF", self.fontSize)
                            srslylawlUI.Utils_SetLimitedText(self.unit.healthBar.leftText,
                                self.unit.healthBar:GetWidth() * 0.45, unit, true)
                            srslylawlUI.Utils_SetLimitedText(self.unit.healthBar.rightText,
                                self.unit.healthBar:GetWidth() * 0.45, hp, true)
                        end
                        local h = srslylawlUI.GetSetting("party.hp.height")
                        local lowerCap = srslylawlUI.GetSetting("party.hp.minWidthPercent")
                        local health = UnitHealthMax("player")
                        local pixelPerHp = srslylawlUI.GetSetting("party.hp.width") / health
                        local minWidth = floor(health * pixelPerHp * lowerCap)
                        local scaledWidth = (self:GetAttribute("hpMax") * pixelPerHp)
                        scaledWidth = scaledWidth < minWidth and minWidth or scaledWidth
                        -- srslylawlUI.Utils_SetSizePixelPerfect(self, srslylawlUI.GetSetting("party.hp.width")+2, h+2)
                        srslylawlUI.Utils_SetSizePixelPerfect(self.unit, srslylawlUI.GetSetting("party.hp.width"), h)
                        -- srslylawlUI.Utils_SetSizePixelPerfect(self.unit.auraAnchor, scaledWidth, h)
                        srslylawlUI.Utils_SetSizePixelPerfect(self.unit.healthBar, scaledWidth, h)
                        srslylawlUI.Utils_SetHeightPixelPerfect(self.unit.powerBar, h)
                        srslylawlUI.Utils_SetHeightPixelPerfect(self.pet.healthBar, h)
                        srslylawlUI.Utils_SetHeightPixelPerfect(self.pet, h)
                        local h2 = h * srslylawlUI.GetSetting("party.ccbar.heightPercent")
                        local w = srslylawlUI.GetSetting("party.ccbar.width")
                        self.unit.CCDurBar:SetPoints(w, h2)
                        self.unit.CCDurBar:SetReverseFill(srslylawlUI.GetSetting("party.ccbar.reversed"))

                        local petEnabled = srslylawlUI.GetSetting("party.pet.enabled")
                        local petEnabledChanged = self.petEnabled ~= petEnabled
                        if petEnabledChanged then
                            self.petEnabled = petEnabled
                            self.pet:SetShown(petEnabled)
                        end
                        srslylawlUI.Frame_ResetDimensions_Pet(self)
                        srslylawlUI.Frame_ResetDimensions_PowerBar(self)
                        self.unit.healthBar:SetReverseFill(srslylawlUI.GetSetting("party.hp.reversed"))

                        self.unit.CCDurBar:SetShown(srslylawlUI.GetSetting("party.ccbar.enabled"))
                        self.unit.powerBar.text:SetShown(srslylawlUI.GetSetting("party.power.text"))

                        if srslylawlUI_FAUX_PartyHeader.showPlayer ~=
                            srslylawlUI.GetSetting("party.visibility.showPlayer")
                            or srslylawlUI_FAUX_PartyHeader.reversed ~= srslylawlUI.GetSetting("party.hp.reversed") then
                            srslylawlUI.SortFauxFrames()
                        end

                        self.unit.RaidIcon:SetEnabled(srslylawlUI.GetSetting("party.raidIcon.enabled"))
                        self.unit.RaidIcon:Resize()
                        self.unit.RaidIcon:SetPoints()

                        local portraitEnabled = srslylawlUI.GetSetting("party.portrait.enabled")
                        local portraitPos = srslylawlUI.GetSetting("party.portrait.position")
                        local portraitAnchor = srslylawlUI.GetSetting("party.portrait.anchor")

                        local portraitSettingsChanged = self.portraitEnabled ~= portraitEnabled or
                            self.portraitPos ~= portraitPos or self.portraitAnchor ~= portraitAnchor

                        if portraitSettingsChanged then
                            self:TogglePortrait()
                            self.portraitAnchor = portraitAnchor
                            self.portraitPos = portraitPos
                            self.portraitEnabled = portraitEnabled
                        end

                        local combatIconEnabled = srslylawlUI.GetSetting("party.combatRestIcon.enabled")
                        local combatIconPos = srslylawlUI.GetSetting("party.combatRestIcon.position")
                        local combatIconSize = srslylawlUI.GetSetting("party.combatRestIcon.size")

                        local combatIconSettingsChanged = self.combatIconEnabled ~= combatIconEnabled or
                            self.combatIconPos ~= combatIconPos or self.combatIconSize ~= combatIconSize

                        if combatIconSettingsChanged then
                            srslylawlUI.Frame_ResetCombatIcon(self)
                            self.combatIconSize = combatIconSize
                            self.combatIconPos = combatIconPos
                            self.combatIconEnabled = combatIconEnabled
                        end

                        timerFrame = 0
                    end
                end)
            frame:Show()
            lastFrame = frame
        end

        --create fake aura frames for player and target frames

        srslylawlUI.mainFauxUnits = {}
        for _, unit in pairs({ "player", "target", "focus" }) do
            local fauxFrame = CreateFrame("Frame", "srslylawlUI_FAUX_" .. unit, nil)
            fauxFrame:SetPoint("TOPLEFT", srslylawlUI.mainUnits[unit].unitFrame.unit, "TOPLEFT", 0, 0)
            fauxFrame:SetPoint("BOTTOMRIGHT", srslylawlUI.mainUnits[unit].unitFrame.unit, "BOTTOMRIGHT", 0, 0)
            fauxFrame.tex = fauxFrame:CreateTexture(nil, "ARTWORK")
            fauxFrame.tex:SetAllPoints()
            fauxFrame.tex:SetColorTexture(0, 0.5, 0.1, 0.2)
            fauxFrame.nameString = srslylawlUI.CreateCustomFontString(fauxFrame, "title", 12)
            fauxFrame.nameString:SetPoint("CENTER")
            fauxFrame.nameString:SetText(unit:sub(1, 1):upper() .. unit:sub(2))
            fauxFrame.unit = fauxFrame
            fauxFrame:SetAttribute("unit", unit)
            fauxFrame:SetAttribute("unitsType", "mainFauxUnits")
            fauxFrame.barHandlerScriptHolder = CreateFrame("Frame", "$parent_ScriptHolder", fauxFrame)
            srslylawlUI.mainFauxUnits[unit] = {
                absorbAuras = {},
                absorbFrames = {},
                absorbFramesOverlap = {},
                buffFrames = {},
                debuffFrames = {},
                defensiveAuras = {},
                effectiveHealthFrames = {},
                effectiveHealthSegments = {},
                trackedAurasByIndex = {},
                unitFrame = fauxFrame
            }

            if unit == "focus" or unit == "target" then
                local function OnEnter(self)
                    srslylawlUI.customTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
                    srslylawlUI.customTooltip:SetText("Make sure a " ..
                        (unit == "focus" and "focus " or "") .. "target exists before trying to move the frame.")
                end

                local function OnLeave(self) srslylawlUI.customTooltip:Hide() end

                fauxFrame:EnableMouse(true)
                fauxFrame:SetScript("OnEnter", OnEnter)
                fauxFrame:SetScript("OnLeave", OnLeave)
            end

            if unit == "player" then
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

                fauxFrame.pet = CreateFrame("StatusBar", "$parent_HealthBar", fauxFrame)
                fauxFrame.pet.healthBar = fauxFrame.pet
                srslylawlUI.CreateBackground(fauxFrame.pet, 1, .8)
                srslylawlUI.Utils_SetPointPixelPerfect(fauxFrame.pet, "TOPRIGHT", fauxFrame, "TOPLEFT", -1, 0)
                srslylawlUI.Utils_SetPointPixelPerfect(fauxFrame.pet, "BOTTOMRIGHT", fauxFrame, "BOTTOMLEFT", -1, 0)
                fauxFrame.pet:SetStatusBarTexture("Interface/Addons/srslylawlUI/media/healthBar")
                fauxFrame.pet:SetStatusBarColor(0.4, 1, 0.2, 1)
                fauxFrame.pet:SetValue(1)
                fauxFrame.pet:SetMinMaxValues(0, 1)
                local width = srslylawlUI.GetSettingByUnit("pet.width", "mainUnits", "player")
                srslylawlUI.Utils_SetWidthPixelPerfect(fauxFrame.pet, width)

                AddTooltip(fauxFrame.pet, "Player Pet")
            end

            srslylawlUI.CreateBuffFrames(fauxFrame, unit)
            srslylawlUI.CreateDebuffFrames(fauxFrame, unit)

            local timer = 0
            fauxFrame:SetScript("OnUpdate", function(self, elapsed)
                timer = timer + elapsed
                if timer < .1 then return end
                timer = 0

                local buffFrames = srslylawlUI.mainFauxUnits[unit].buffFrames
                local maxBuffs = srslylawlUI.GetSetting("player." .. unit .. "Frame.buffs.maxBuffs")
                defaultSize = srslylawlUI.GetSetting("player." .. unit .. "Frame.buffs.size")
                scaledSize = defaultSize + srslylawlUI.GetSetting("player." .. unit .. "Frame.buffs.scaledSize")
                for i = 1, maxBuffs do
                    local f = buffFrames[i]
                    f.icon:SetTexture(135932)
                    f.size = math.fmod(i + 1, 3) == 0 and scaledSize or defaultSize
                    f:Show()
                end

                if unit == "player" then
                    local petEnabled = srslylawlUI.GetSetting("player." .. unit .. "Frame.pet.enabled")
                    local petWidth = srslylawlUI.GetSetting("player." .. unit .. "Frame.pet.width")
                    fauxFrame.pet:SetShown(petEnabled)
                    srslylawlUI.Utils_SetWidthPixelPerfect(fauxFrame.pet, petWidth)
                end

                for i = maxBuffs + 1, #buffFrames do
                    buffFrames[i]:Hide()
                end

                local debuffFrames = srslylawlUI.mainFauxUnits[unit].debuffFrames
                local maxDebuffs = srslylawlUI.GetSetting("player." .. unit .. "Frame.debuffs.maxDebuffs")
                defaultSize = srslylawlUI.GetSetting("player." .. unit .. "Frame.debuffs.size")
                scaledSize = defaultSize + srslylawlUI.GetSetting("player." .. unit .. "Frame.debuffs.scaledSize")
                for i = 1, maxDebuffs do
                    local f = debuffFrames[i]
                    f.icon:SetTexture(136207)
                    f.size = math.fmod(i + 1, 3) == 0 and scaledSize or defaultSize
                    f:Show()
                end

                for i = maxDebuffs + 1, #debuffFrames do
                    debuffFrames[i]:Hide()
                end

                srslylawlUI.SetAuraPointsAll(unit, "mainFauxUnits")
            end)
        end

        srslylawlUI_FAUX_PartyHeader.initiated = true
    end

    srslylawlUI.mainFauxUnits.player.unitFrame:SetShown(visible)
    srslylawlUI.mainFauxUnits.target.unitFrame:SetShown(visible)
    srslylawlUI.mainFauxUnits.focus.unitFrame:SetShown(visible)
end

function srslylawlUI.SortFauxFrames()
    local lastFrame = srslylawlUI_FAUX_PartyHeader
    local showPlayer = srslylawlUI.GetSetting("party.visibility.showPlayer")
    local anchor1, anchor2 = "TOPLEFT", "BOTTOMLEFT"

    for _, unit in pairs(srslylawlUI.partyUnitsTable) do
        local frame = _G["srslylawlUI_FAUX_PartyHeader_" .. unit]
        if not frame then return end
        if unit ~= "player" or unit == "player" and showPlayer then
            frame.unit:ClearAllPoints()
            if lastFrame == srslylawlUI_FAUX_PartyHeader then
                frame.unit:SetPoint(anchor1, lastFrame, anchor1)
            else
                srslylawlUI.Utils_SetPointPixelPerfect(frame.unit, anchor1, lastFrame, anchor2, 0, -1)
            end
            lastFrame = frame.unit
            frame:Show()
        else
            frame:Hide()
        end
    end

    local reversed = srslylawlUI.GetSetting("party.hp.reversed")
    local alignment = reversed and "TOPRIGHT" or "TOPLEFT"

    for _, unit in pairs(srslylawlUI.partyUnitsTable) do
        local frame = _G["srslylawlUI_FAUX_PartyHeader_" .. unit]
        frame.unit.healthBar:ClearAllPoints()
        frame.unit.healthBar:SetPoint(alignment, frame.unit, alignment, 0, 0)
        frame.unit.healthBar.alignment = alignment
        frame.unit.healthBar:SetReverseFill(reversed)
        frame.unit.healthBar.reversed = reversed
    end

    srslylawlUI_FAUX_PartyHeader.showPlayer = showPlayer
    srslylawlUI_FAUX_PartyHeader.reversed = reversed
    srslylawlUI_FAUX_PartyHeader.alignment = alignment
end
