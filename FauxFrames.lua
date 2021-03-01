function srslylawlUI.ToggleFauxFrames(visible)
    srslylawlUI_FAUX_PartyHeader:SetShown(visible)
    srslylawlUI_PartyHeader_player:SetShown(not visible)

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
        for i,unit in pairs(srslylawlUI.partyUnitsTable) do
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
            frame.unit.CCDurBar:SetShown(srslylawlUI.GetSetting("party.ccbar.enabled"))
            frame.unit.CCDurBar.icon:SetTexture(fauxUnit.CCIcon)
            local color = DebuffTypeColor[fauxUnit.CCColor]
            frame.unit.CCDurBar:SetStatusBarColor(color.r, color.g, color.b)

            color = RAID_CLASS_COLORS[fauxUnit.class]

            local hp = (srslylawlUI.ShortenNumber(fauxUnit.hp) .. " " .. ceil(fauxUnit.hp / fauxUnit.hpmax * 100) .. "%")

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
            local parent = frame.unit
            for i = 1, 40 do
                local xOffset, yOffset = srslylawlUI.Party_GetBuffOffsets()
                local anchor = srslylawlUI.GetSetting("party.buffs.growthDir")
                local f = CreateFrame("Button", frameName .. i, frame.unit, "CompactBuffTemplate")
                if (i == 1) then
                    xOffset = srslylawlUI.GetSetting("party.buffs.xOffset")
                    yOffset = srslylawlUI.GetSetting("party.buffs.yOffset")
                    f:SetPoint(srslylawlUI.GetSetting("party.buffs.anchor"), srslylawlUI.Utils_PixelFromCodeToScreen(xOffset), srslylawlUI.Utils_PixelFromCodeToScreen(yOffset))
                else
                    srslylawlUI.Utils_SetPointPixelPerfect(f, "CENTER", parent, "CENTER", xOffset, yOffset)
                end
                f:EnableMouse(false)
                f.icon:SetTexture(135932)
                frame.buffs[i] = f
                parent = f
            end
            --debuffs
            frame.debuffs = {}
            frameName = "srslylawlUI_FAUX"..unit.."Debuff"
            parent = frame.unit
            for i = 1, 40 do
                local xOffset, yOffset = srslylawlUI.Party_GetDebuffOffsets()
                local anchor = srslylawlUI.GetSetting("party.debuffs.growthDir")
                local f = CreateFrame("Button", frameName .. i, frame.unit, "CompactDebuffTemplate")
                if (i == 1) then
                    anchor = srslylawlUI.GetSetting("party.debuffs.anchor")
                    xOffset = srslylawlUI.GetSetting("party.debuffs.xOffset")
                    yOffset = srslylawlUI.GetSetting("party.debuffs.yOffset")
                    f:SetPoint(srslylawlUI.GetSetting("party.debuffs.anchor"), srslylawlUI.Utils_PixelFromCodeToScreen(xOffset), srslylawlUI.Utils_PixelFromCodeToScreen(yOffset))
                else
                    srslylawlUI.Utils_SetPointPixelPerfect(f, "CENTER", parent, "CENTER", xOffset, yOffset)
                end
                f:EnableMouse(false)
                f.icon:SetTexture(136207)
                frame.debuffs[i] = f
                parent = f
            end

            local timerFrame = 1

            --update frames to reflect current settings
            frame:SetScript("OnUpdate",
                function(self, elapsed)
                timerFrame = timerFrame + elapsed
                if timerFrame > 0.1 then
                    local countChanged = self.shownBuffs ~= srslylawlUI.GetSetting("party.buffs.maxBuffs")
                    local anchorChanged = self.buffs.anchor ~= srslylawlUI.GetSetting("party.buffs.anchor") or self.buffs.xOffset ~= srslylawlUI.GetSetting("party.buffs.xOffset") or self.buffs.yOffset ~= srslylawlUI.GetSetting("party.buffs.yOffset")
                    local sizeChanged = self.buffs.size ~= srslylawlUI.GetSetting("party.buffs.size")
                    local growthDirChanged = self.buffs.growthDir ~= srslylawlUI.GetSetting("party.buffs.growthDir")
                    if countChanged or anchorChanged or sizeChanged or growthDirChanged then
                        self.shownBuffs = srslylawlUI.GetSetting("party.buffs.maxBuffs")
                        for i=1,40 do
                            self.buffs[i]:SetShown(i <= self.shownBuffs)
                            local size = srslylawlUI.GetSetting("party.buffs.size")
                            local xOffset, yOffset = srslylawlUI.Party_GetBuffOffsets()
                            local anchor = "CENTER"
                            self.buffs[i]:ClearAllPoints()
                            if (i == 1) then
                                anchor = srslylawlUI.GetSetting("party.buffs.anchor")
                                xOffset = srslylawlUI.GetSetting("party.buffs.xOffset")
                                yOffset = srslylawlUI.GetSetting("party.buffs.yOffset")
                                self.buffs[i]:SetParent(self.unit.auraAnchor)
                                self.buffs[i]:SetPoint(anchor, srslylawlUI.Utils_PixelFromCodeToScreen(xOffset), srslylawlUI.Utils_PixelFromCodeToScreen(yOffset))
                                self.buffs.anchor = anchor
                                self.buffs.xOffset = xOffset
                                self.buffs.yOffset = yOffset
                                self.buffs.size = size
                                self.buffs.growthDir = srslylawlUI.GetSetting("party.buffs.growthDir")
                            else
                                srslylawlUI.Utils_SetPointPixelPerfect(self.buffs[i], anchor, self.buffs[i-1], anchor, xOffset, yOffset)
                            end
                            srslylawlUI.Utils_SetSizePixelPerfect(self.buffs[i], size, size)
                        end
                    end
                    countChanged = self.shownDebuffs ~= srslylawlUI.GetSetting("party.debuffs.maxDebuffs")
                    sizeChanged = self.debuffs.size ~= srslylawlUI.GetSetting("party.debuffs.size")
                    anchorChanged = self.debuffs.anchor ~= srslylawlUI.GetSetting("party.debuffs.anchor") or self.debuffs.xOffset ~= srslylawlUI.GetSetting("party.debuffs.xOffset") or self.debuffs.yOffset ~= srslylawlUI.GetSetting("party.debuffs.yOffset")
                    growthDirChanged = self.debuffs.growthDir ~= srslylawlUI.GetSetting("party.debuffs.growthDir")
                    if countChanged or anchorChanged or sizeChanged or growthDirChanged then
                        self.shownDebuffs = srslylawlUI.GetSetting("party.debuffs.maxDebuffs")
                        for i=1,40 do
                            self.debuffs[i]:SetShown(i <= self.shownDebuffs)
                            local size = srslylawlUI.GetSetting("party.debuffs.size")
                            local xOffset, yOffset = srslylawlUI.Party_GetDebuffOffsets()
                            local anchor = "CENTER"
                            self.debuffs[i]:ClearAllPoints()
                            if (i == 1) then
                                anchor = srslylawlUI.GetSetting("party.debuffs.anchor")
                                xOffset = srslylawlUI.GetSetting("party.debuffs.xOffset")
                                yOffset = srslylawlUI.GetSetting("party.debuffs.yOffset")
                                self.debuffs[i]:SetParent(self.unit.auraAnchor)
                                self.debuffs[i]:SetPoint(anchor, srslylawlUI.Utils_PixelFromCodeToScreen(xOffset), srslylawlUI.Utils_PixelFromCodeToScreen(yOffset))
                                self.debuffs.anchor = anchor
                                self.debuffs.xOffset = xOffset
                                self.debuffs.yOffset = yOffset
                                self.debuffs.size = size
                                self.debuffs.growthDir = srslylawlUI.GetSetting("party.debuffs.growthDir")
                            else
                                srslylawlUI.Utils_SetPointPixelPerfect(self.debuffs[i], anchor, self.debuffs[i-1], anchor, xOffset, yOffset)
                            end
                            srslylawlUI.Utils_SetSizePixelPerfect(self.debuffs[i], size, size)
                        end
                    end
                    local h = srslylawlUI.GetSetting("party.hp.height")
                    local lowerCap = srslylawlUI.GetSetting("party.hp.minWidthPercent")
                    local health = UnitHealthMax("player")
                    local pixelPerHp = srslylawlUI.GetSetting("party.hp.width") / health
                    local minWidth = floor(health * pixelPerHp * lowerCap)
                    local scaledWidth = (self:GetAttribute("hpMax") * pixelPerHp)
                    scaledWidth = scaledWidth < minWidth and minWidth or scaledWidth
                    srslylawlUI.Utils_SetSizePixelPerfect(self, srslylawlUI.GetSetting("party.hp.width")+2, h+2)
                    srslylawlUI.Utils_SetSizePixelPerfect(self.unit, srslylawlUI.GetSetting("party.hp.width"), h)
                    srslylawlUI.Utils_SetSizePixelPerfect(self.unit.auraAnchor, scaledWidth, h)
                    srslylawlUI.Utils_SetSizePixelPerfect(self.unit.healthBar, scaledWidth, h)
                    srslylawlUI.Utils_SetHeightPixelPerfect(self.unit.powerBar, h)
                    srslylawlUI.Utils_SetHeightPixelPerfect(self.pet.healthBar, h)
                    srslylawlUI.Utils_SetHeightPixelPerfect(self.pet, h)
                    local h2 = h*srslylawlUI.GetSetting("party.ccbar.heightPercent")
                    local w = srslylawlUI.GetSetting("party.ccbar.width")
                    local iconSize = (w > h2 and h2) or w
                    srslylawlUI.Utils_SetSizePixelPerfect(self.unit.CCDurBar, w, h2)
                    srslylawlUI.Utils_SetSizePixelPerfect(self.unit.CCDurBar.icon, iconSize, iconSize)
                    srslylawlUI.Frame_ResetDimensions_Pet(self)
                    srslylawlUI.Frame_ResetDimensions_PowerBar(self)

                    self.unit.CCDurBar:SetShown(srslylawlUI.GetSetting("party.ccbar.enabled"))

                    timerFrame = 0
                end
            end)
            frame:Show()
            lastFrame = frame
        end
        srslylawlUI_FAUX_PartyHeader.initiated = true
    end

end