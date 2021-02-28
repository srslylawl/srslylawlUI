function srslylawlUI.CreateConfigWindow()
    local function ToggleFakeFrames(bool)
        if srslylawlUI_ConfigFrame.fakeFramesToggled == bool then
            return
        end
        srslylawlUI_ConfigFrame.lockFramesButton:SetChecked(bool)

        srslylawlUI_ConfigFrame.fakeFramesToggled = bool
        srslylawlUI_PartyHeader:SetMovable(bool)
        srslylawlUI.mainUnits.player.unitFrame:SetMovable(bool)
        srslylawlUI.mainUnits.target.unitFrame:SetMovable(bool)
        srslylawlUI.mainUnits.targettarget.unitFrame:SetMovable(bool)
        srslylawlUI.Log((bool and "Frames can now be moved." or "Frames can no longer be moved."))

        srslylawlUI_Frame_ToggleFauxFrames(bool)
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
        editBox:SetSize(50, 25)
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
        slider:SetSize(150, 16)
        slider:SetMinMaxValues(min, max)
        slider:SetValue(defaultValue)
        slider:SetValueStep(valueStep)
        slider:SetObeyStepOnDrag(true)
        local editBox = CreateFrame("EditBox", name .. "_EditBox", slider, "BackdropTemplate")
        editBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 12,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        })
        editBox:SetBackdropColor(0.2, 0.2, .2, 1)
        editBox:SetTextInsets(5, 5, 0, 0)
        editBox:SetSize(50, 25)
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
    local function CreateCustomDropDown(title, width, parent, anchor, relativePoint, xOffset, yOffset, valueRef, values, onChangeFunc, checkFunc)
        -- Create the dropdown, and configure its appearance
        local dropDown = CreateFrame("FRAME", "$parent_"..title, parent, "UIDropDownMenuTemplate")
        dropDown:SetPoint(anchor, parent, relativePoint, xOffset, yOffset)
        UIDropDownMenu_SetWidth(dropDown, width)
        UIDropDownMenu_SetText(dropDown, title)

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

        function dropDown:SetValue(newValue)
            UIDropDownMenu_SetText(dropDown, title)
            onChangeFunc(newValue)
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
            srslylawlUI.customTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
            srslylawlUI.customTooltip:SetText(text)
        end
        local function OnLeave(self) srslylawlUI.customTooltip:Hide() end

        frame:EnableMouse(true)
        frame:SetScript("OnEnter", OnEnter)
        frame:SetScript("OnLeave", OnLeave)
    end
    local function AddSpellTooltip(frame, id)
        --since the tooltip seems to glitch the first time we mouseover, we add an onupdate
        local function OnEnter(self)
            srslylawlUI.customTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
            srslylawlUI.customTooltip:ClearLines()
            srslylawlUI.customTooltip:AddSpellByID(id)
        end
        local function OnUpdate(self)
            if srslylawlUI.customTooltip:IsOwned(self) then
                srslylawlUI.customTooltip:ClearLines()
                srslylawlUI.customTooltip:AddSpellByID(id)
            end
        end
        local function OnLeave(self) srslylawlUI.customTooltip:Hide() end

        frame:EnableMouse(true)
        frame:SetScript("OnEnter", OnEnter)
        frame:SetScript("OnUpdate", OnUpdate)
        frame:SetScript("OnLeave", OnLeave)
    end
    local function ScrollFrame_Update(frame)
        local tabcontent = frame:GetParent():GetParent()
        local list = tabcontent:GetAttribute("spellList")
        local auraType = tabcontent:GetAttribute("auraType")
        local lineplusoffset
        local sortedSpellList = srslylawlUI.sortedSpellLists[auraType][list]
        local maxButtons = frame.ButtonCount or 0
        local totalItems = (sortedSpellList ~= nil and #sortedSpellList) or 0
        frame.TotalItems = totalItems
        local buttonHeight = frame.ButtonHeight or 0
        FauxScrollFrame_Update(frame,totalItems,maxButtons,buttonHeight, nil, nil, nil, nil, nil, nil, true)
        for line=1,maxButtons do
            lineplusoffset = line + (FauxScrollFrame_GetOffset(frame) >= 0 and FauxScrollFrame_GetOffset(frame) or 0)
            local curr = frame.Buttons[line]
            if curr == nil then error("button nil") end
            if lineplusoffset <= totalItems then
                local spell = sortedSpellList[lineplusoffset]
                local name, spellId, icon = spell.name, spell.spellId, spell.icon
                local nameWidth = curr:GetWidth()
                local length = #name
                curr:SetText(name)
                while curr:GetTextWidth() > nameWidth do
                    substring = srslylawlUI.Utils_ShortenString(name, 1, length)
                    curr:SetText(substring)
                    length = length - 1
                end
                AddTooltip(curr, name.."\nID: ".. spellId)
                curr:SetAttribute("spellId", spellId)
                if tabcontent.lastSelectedSpellId == spellId then 
                    curr:Click()
                    curr:SetChecked(true)
                else
                    curr:SetChecked(false)
                end
                curr.icon.texture:SetTexture(icon)
                AddSpellTooltip(curr.icon, spellId)
                curr:Show()
            else
                curr:Hide()
            end
        end
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
        f.title:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 10, 0)
        return f
    end
    local function CreateCheckButton(name, parent)
        local nameWithoutSpace = name:gsub(" ", "_")
        local checkButton = CreateFrame("CheckButton","$parent_"..nameWithoutSpace,parent,"UICheckButtonTemplate")
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
        table.insert(srslylawlUI.unsaved.buttons, s)

        -- Load Button
        frame.LoadButton = CreateFrame("Button", "srslylawlUI_Config_LoadButton",
                                    srslylawlUI_ConfigFrame,
                                    "UIPanelButtonTemplate")
        local l = frame.LoadButton
        l:SetPoint("TOPRIGHT", s, "TOPLEFT")
        l:SetText("Load")
        l:SetScript("OnClick", function(self) srslylawlUI.LoadSettings(true, true) end)
        l:SetWidth(60)
        table.insert(srslylawlUI.unsaved.buttons, l)
        l:Disable()
        s:Disable()
        frame.CloseButton = CreateFrame("Button", "srslylawlUI_Config_CloseButton",
                                     srslylawlUI_ConfigFrame,
                                     "UIPanelCloseButton")
        local c = frame.CloseButton
        c:SetPoint("TOPRIGHT", 0, 0)
    end
    local function FillGeneralTab(tab)
        local function CreateVisibilityFrame(tab)
            local visibility = CreateFrameWBG("Party Frame Visibility", tab)
            visibility:SetPoint("TOPLEFT", tab, "TOPLEFT", 5, -25)
            visibility:SetPoint("BOTTOMRIGHT", tab, "TOPRIGHT", -70, -55)
            tab.visibility = visibility

            local showParty = CreateCheckButton("Party", visibility)
            showParty:SetScript("OnClick", function(self)
                srslylawlUI.ChangeSetting("party.showParty", self:GetChecked())
                srslylawlUI.Frame_UpdateVisibility()
            end)
            local showPartyBool = srslylawlUI.GetSetting("party.showParty")
            AddTooltip(showParty, "Show Frames while in a Party")
            showParty:SetPoint("TOPLEFT", visibility, "TOPLEFT")
            showParty:SetChecked(showPartyBool)
            showParty:SetAttribute("defaultValue", showPartyBool)

            local showRaidBool = srslylawlUI.GetSetting("party.showRaid")
            local showRaid = CreateCheckButton("Raid", visibility)
            showRaid:SetScript("OnClick", function(self)
                srslylawlUI.ChangeSetting("party.showRaid", self:GetChecked())
                srslylawlUI.Frame_UpdateVisibility()
            end)
            showRaid:SetPoint("LEFT", showParty.text, "RIGHT")
            AddTooltip(showRaid, "Show Frames while in a Raid (not recommended)")
            showRaid:SetChecked(showRaidBool)
            showRaid:SetAttribute("defaultValue", showRaidBool)

            local showPlayerBool = srslylawlUI.GetSetting("party.showPlayer")
            local showPlayer = CreateCheckButton("Show Player", visibility)
            showPlayer:SetScript("OnClick", function(self)
                srslylawlUI.ChangeSetting("party.showPlayer", self:GetChecked())
                srslylawlUI.Frame_UpdateVisibility()
            end)
            showPlayer:SetPoint("LEFT", showRaid.text, "RIGHT")
            AddTooltip(showPlayer, "Show Player in Party Frames (recommended)")
            showPlayer:SetChecked(showPlayerBool)
            showPlayer:SetAttribute("defaultValue", showPlayerBool)

            local showSoloBool = srslylawlUI.GetSetting("party.showSolo")
            local showSolo = CreateCheckButton("Solo", visibility)
            showSolo:SetScript("OnClick", function(self)
                srslylawlUI.ChangeSetting("party.showSolo", self:GetChecked())
                srslylawlUI.Frame_UpdateVisibility()
            end)
            showSolo:SetPoint("LEFT", showPlayer.text, "RIGHT")
            AddTooltip(showSolo, "Show Frames while not in a group (will assume Show Player)")
            showSolo:SetChecked(showSoloBool)
            showSolo:SetAttribute("defaultValue", showSoloBool)

            local showArenaBool = srslylawlUI.GetSetting("party.showArena")
            local showArena = CreateCheckButton("Arena", visibility)
            showArena:SetScript("OnClicK", function(self)
                srslylawlUI.ChangeSetting("party.showArena",self:GetChecked())
                srslylawlUI.Frame_UpdateVisibility()
            end)
            showArena:SetPoint("LEFT", showSolo.text, "RIGHT")
            showArena:SetChecked(showArenaBool)
            showArena:SetAttribute("defaultValue", showArenaBool)
            AddTooltip(showArena, "Show Frames in Arena")

        end

        local function CreateBuffConfigFrame(tab)
            local buffSettings = CreateFrameWBG("Party Buffs", tab)
            buffSettings:SetPoint("TOPLEFT", tab.visibility, "BOTTOMLEFT", 0, -15)
            buffSettings:SetPoint("BOTTOMRIGHT", tab.visibility, "BOTTOMRIGHT", 0, -45)
            tab.buffSettings = buffSettings

            local showDefault = CreateCheckButton("Show per Default", buffSettings)
            showDefault:SetScript("OnClick", function(self)
                srslylawlUI.ChangeSetting("party.buffs.showDefault", self:GetChecked())
                srslylawlUI.Party_HandleAuras_ALL()
            end)
            AddTooltip(showDefault, "Show/hide all buffs per default, except if they are in/excluded by another setting.\n\nRecommended: Hiding all per default, while showing defensives and whitelisted Auras.")
            showDefault:SetPoint("TOPLEFT", buffSettings, "TOPLEFT")
            showDefault:SetChecked(srslylawlUI.GetSetting("party.buffs.showDefault"))
            showDefault:SetAttribute("defaultValue", srslylawlUI.GetSetting("party.buffs.showDefault"))

            local showDefensives = CreateCheckButton("Show Defensives", buffSettings)
            showDefensives:SetScript("OnClick", function(self)
                srslylawlUI.ChangeSetting("party.buffs.showDefensives", self:GetChecked())
                srslylawlUI.Party_HandleAuras_ALL()
            end)
            AddTooltip(showDefensives, "Show/hide buffs categorized as Defensives.")
            showDefensives:SetPoint("LEFT", showDefault.text, "RIGHT")
            showDefensives:SetChecked(srslylawlUI.GetSetting("party.buffs.showDefensives"))
            showDefensives:SetAttribute("defaultValue", srslylawlUI.GetSetting("party.buffs.showDefensives"))

            local showCastByPlayer = CreateCheckButton("Show cast by Player", buffSettings)
            showCastByPlayer:SetScript("OnClick", function(self)
                srslylawlUI.ChangeSetting("party.buffs.showCastByPlayer", self:GetChecked())
                srslylawlUI.Party_HandleAuras_ALL()
            end)
            AddTooltip(showCastByPlayer, "Show/hide buffs that have been applied by the Player.")
            showCastByPlayer:SetPoint("LEFT", showDefensives.text, "RIGHT")
            showCastByPlayer:SetChecked(srslylawlUI.GetSetting("party.buffs.showCastByPlayer"))
            showCastByPlayer:SetAttribute("defaultValue", srslylawlUI.GetSetting("party.buffs.showCastByPlayer"))

            local showInfiniteDuration = CreateCheckButton("Show infinite duration", buffSettings)
            showInfiniteDuration:SetScript("OnClick", function(self)
                srslylawlUI.ChangeSetting("party.buffs.showInfiniteDuration", self:GetChecked())
                srslylawlUI.Party_HandleAuras_ALL()
            end)
            AddTooltip(showInfiniteDuration, "Show/hide buffs with no expiration time.")
            showInfiniteDuration:SetPoint("LEFT", showCastByPlayer.text, "RIGHT")
            showInfiniteDuration:SetChecked(srslylawlUI.GetSetting("party.buffs.showInfiniteDuration"))
            showInfiniteDuration:SetAttribute("defaultValue", srslylawlUI.GetSetting("party.buffs.showInfiniteDuration"))

            local showLongDuration = CreateCheckButton("Show long duration", buffSettings)
            showLongDuration:SetScript("OnClick", function(self)
                print("changing setting")
                srslylawlUI.ChangeSetting("party.buffs.showLongDuration", self:GetChecked())
                srslylawlUI.Party_HandleAuras_ALL()
            end)
            AddTooltip(showLongDuration, "Show/hide buffs with a base duration longer than 60 seconds.")
            showLongDuration:SetPoint("LEFT", showInfiniteDuration.text, "RIGHT")
            showLongDuration:SetChecked(srslylawlUI.GetSetting("party.buffs.showLongDuration"))
            showLongDuration:SetAttribute("defaultValue", srslylawlUI.GetSetting("party.buffs.showLongDuration"))
        end

        local function CreateDebuffConfigFrame(tab)
            local debuffSettings = CreateFrameWBG("Party Debuffs", tab)
            debuffSettings:SetPoint("TOPLEFT", tab.buffSettings, "BOTTOMLEFT", 0, -15)
            debuffSettings:SetPoint("BOTTOMRIGHT", tab.buffSettings, "BOTTOMRIGHT", 0, -45)
            tab.debuffSettings = debuffSettings

            local showDefault = CreateCheckButton("Show per Default", debuffSettings)
            showDefault:SetScript("OnClick", function(self)
                srslylawlUI.ChangeSetting("party.debuffs.showDefault", self:GetChecked())
                srslylawlUI.Party_HandleAuras_ALL()
            end)
            AddTooltip(showDefault, "Show/hide all debuffs per default, except if they are in/excluded by another setting.\n\nRecommended: Showing all per default, while hiding infinite duration auras.")
            showDefault:SetPoint("TOPLEFT", debuffSettings, "TOPLEFT")
            showDefault:SetChecked(srslylawlUI.GetSetting("party.debuffs.showDefault"))
            showDefault:SetAttribute("defaultValue", srslylawlUI.GetSetting("party.debuffs.showDefault"))

            local showCastByPlayer = CreateCheckButton("Show cast by Player", debuffSettings)
            showCastByPlayer:SetScript("OnClick", function(self)
                srslylawlUI.ChangeSetting("party.debuffs.showCastByPlayer", self:GetChecked())
                srslylawlUI.Party_HandleAuras_ALL()
            end)
            AddTooltip(showCastByPlayer, "Show/hide debuffs that have been applied by the Player.")
            showCastByPlayer:SetPoint("LEFT", showDefault.text, "RIGHT")
            showCastByPlayer:SetChecked(srslylawlUI.GetSetting("party.debuffs.showCastByPlayer"))
            showCastByPlayer:SetAttribute("defaultValue", srslylawlUI.GetSetting("party.debuffs.showCastByPlayer"))

            local showInfiniteDuration = CreateCheckButton("Show infinite duration", debuffSettings)
            showInfiniteDuration:SetScript("OnClick", function(self)
                srslylawlUI.ChangeSetting("party.debuffs.showInfiniteDuration", self:GetChecked())
                srslylawlUI.Party_HandleAuras_ALL()
            end)
            AddTooltip(showInfiniteDuration, "Show/hide debuffs with no expiration time.")
            showInfiniteDuration:SetPoint("LEFT", showCastByPlayer.text, "RIGHT")
            showInfiniteDuration:SetChecked(srslylawlUI.GetSetting("party.debuffs.showInfiniteDuration"))
            showInfiniteDuration:SetAttribute("defaultValue", srslylawlUI.GetSetting("party.debuffs.showInfiniteDuration"))


            local showLongDuration = CreateCheckButton("Show long duration", debuffSettings)
            showLongDuration:SetScript("OnClick", function(self)
                srslylawlUI.ChangeSetting("party.debuffs.showLongDuration", self:GetChecked())
                srslylawlUI.Party_HandleAuras_ALL()
            end)
            AddTooltip(showLongDuration, "Show/hide debuffs with a base duration longer than 180 seconds.")
            showLongDuration:SetPoint("LEFT", showInfiniteDuration.text, "RIGHT")
            showLongDuration:SetChecked(srslylawlUI.GetSetting("party.debuffs.showLongDuration"))
            showLongDuration:SetAttribute("defaultValue", srslylawlUI.GetSetting("party.debuffs.showLongDuration"))
        end

        CreateVisibilityFrame(tab)
        CreateBuffConfigFrame(tab)
        CreateDebuffConfigFrame(tab)
        


    end
    local function FillFramesTab(tab)
        -- HP Bar Sliders
        local cFrame = srslylawlUI_ConfigFrame
        cFrame.fakeFramesToggled = false
        cFrame.editBoxes = {}
        cFrame.sliders = {}

        local lockFrames = CreateCheckButton("Preview settings and make frames moveable", tab)
        cFrame.lockFramesButton = lockFrames
        lockFrames:SetPoint("TOPLEFT", tab, "TOPLEFT", 5, -5)
        lockFrames:SetScript("OnClick", function(self)
            ToggleFakeFrames(self:GetChecked())
            cFrame.fakeFramesToggled = self:GetChecked()
        end)

        local healthBarFrame = CreateFrameWBG("Party Health Bar", tab)
        healthBarFrame:SetPoint("TOPLEFT", tab, "TOPLEFT", 5, -55)
        healthBarFrame:SetPoint("BOTTOMRIGHT", tab, "TOPRIGHT", -5, -115)
        
        local width = floor(srslylawlUI.GetSetting("party.hp.width"))
        local height = floor(srslylawlUI.GetSetting("party.hp.height"))
        cFrame.sliders.height = CreateCustomSlider("Height", 5, 500,
            height, healthBarFrame, -50, 1, true)
        cFrame.sliders.height:SetPoint("TOPLEFT", 10, -20)
        cFrame.sliders.height:HookScript("OnValueChanged", function(self, value)
            srslylawlUI.ChangeSetting("party.hp.height", value)
            srslylawlUI.UpdateEverything()
        end)
        cFrame.sliders.hpwidth = CreateCustomSlider("Max Width", 25,
            2000, width, cFrame.sliders.height, -40, 1, true)
        cFrame.sliders.hpwidth:ClearAllPoints()
        cFrame.sliders.hpwidth:SetPoint("LEFT", cFrame.sliders.height.editbox,
            "RIGHT", 10, 0)
        cFrame.sliders.hpwidth:HookScript("OnValueChanged", function(self, value)
            srslylawlUI.ChangeSetting("party.hp.width", value)
            srslylawlUI.UpdateEverything()
        end)
        cFrame.sliders.minWidth = CreateCustomSlider("Min Width Percent", 0.1, 1, srslylawlUI.Utils_DecimalRound(srslylawlUI.GetSetting("party.hp.minWidthPercent"), 2),
        cFrame.sliders.height, -50, 0.01, false, 2)
        cFrame.sliders.minWidth:HookScript("OnValueChanged", function(self, value)
            srslylawlUI.ChangeSetting("party.hp.minWidthPercent", value)
            srslylawlUI.UpdateEverything()
        end)
        cFrame.sliders.minWidth:ClearAllPoints(true);
        cFrame.sliders.minWidth:SetPoint("LEFT", cFrame.sliders.hpwidth.editbox,
            "RIGHT", 10, 0)
        AddTooltip(cFrame.sliders.minWidth, "Minimum percent of Max Width a bar can be scaled to. Default: 0.55")

        --powerbar
        local powerFrame = CreateFrameWBG("Party Power Bar", healthBarFrame)
        powerFrame:SetPoint("TOPLEFT", healthBarFrame, "BOTTOMLEFT", 0, -15)
        powerFrame:SetSize(225, 60)
        -- powerFrame:SetPoint("BOTTOMRIGHT", healthBarFrame, "BOTTOMRIGHT", -475, -75)
        cFrame.sliders.powerWidth = CreateCustomSlider("Power Bar Width", 3, 50, srslylawlUI.GetSetting("party.power.width"), powerFrame, -50, 1, true, 0)
        cFrame.sliders.powerWidth:HookScript("OnValueChanged", function(self, value)
            srslylawlUI.ChangeSetting("party.power.width", value)
            srslylawlUI.Frame_Party_ResetDimensions_ALL()
        end)
        cFrame.sliders.powerWidth:ClearAllPoints()
        cFrame.sliders.powerWidth:SetPoint("LEFT", powerFrame, "LEFT", 10, 0)

        --petbar
        local petFrame = CreateFrameWBG("Party Pet Bar", powerFrame)
        petFrame:SetPoint("TOPLEFT", powerFrame, "TOPRIGHT", 5, 0)
        petFrame:SetSize(225, 60)
        -- petFrame:SetPoint("BOTTOMRIGHT", powerFrame, "BOTTOMRIGHT", 265, 0)
        cFrame.sliders.petWidth = CreateCustomSlider("Pet Bar Width", 3, 50, srslylawlUI.GetSetting("party.pet.width"), petFrame, -50, 1, true, 0)
        cFrame.sliders.petWidth:HookScript("OnValueChanged", function(self, value)
            srslylawlUI.ChangeSetting("party.pet.width", value)
            srslylawlUI.Frame_Party_ResetDimensions_ALL()
        end)
        cFrame.sliders.petWidth:ClearAllPoints()
        cFrame.sliders.petWidth:SetPoint("LEFT", petFrame, "LEFT", 10, 0)
        
        -- Buff Frames
        local buffFrame = CreateFrameWBG("Party Buffs", powerFrame)
        buffFrame:SetPoint("TOPLEFT", powerFrame, "BOTTOMLEFT", 0, -15)
        buffFrame:SetPoint("BOTTOMRIGHT", powerFrame, "BOTTOMRIGHT", 200, -120)
        local buffAnchor = CreateCustomDropDown("Anchor", 75, buffFrame, "TOPLEFT",
            "TOPLEFT", -10, -20, srslylawlUI.GetSetting("party.buffs.anchor"), srslylawlUI.anchorTable, function(newValue)
                srslylawlUI.ChangeSetting("party.buffs.anchor", newValue)
                srslylawlUI.Party_SetBuffFrames()
        end, function(self) return self.value == srslylawlUI.GetSetting("party.buffs.anchor") end)
        local buffGrowthDir = CreateCustomDropDown("Growth Direction", 125, buffAnchor, "TOPLEFT",
            "TOPRIGHT", -25, 0, srslylawlUI.GetSetting("party.buffs.growthDir"), {"LEFT", "RIGHT"}, function(newValue)
                srslylawlUI.ChangeSetting("party.buffs.growthDir", newValue)
                srslylawlUI.Party_SetBuffFrames()
        end, function(self) return self.value == srslylawlUI.GetSetting("party.buffs.growthDir") end)
        local buffAnchorXOffset = CreateEditBox("$parent_BuffAnchorXOffset", buffGrowthDir, srslylawlUI.GetSetting("party.buffs.xOffset"),
        function(self)
            local n = self:GetNumber()
            if srslylawlUI.GetSetting("party.buffs.xOffset") == n then return end
            srslylawlUI.ChangeSetting("party.buffs.xOffset", n)
            srslylawlUI.Party_SetBuffFrames()
        end)
        buffAnchorXOffset.title = buffAnchorXOffset:CreateFontString("$parent_Title", "OVERLAY", "GameFontNormal")
        buffAnchorXOffset.title:SetPoint("TOP", 0, 12)
        buffAnchorXOffset.title:SetText("X-Offset")
        buffAnchorXOffset:ClearAllPoints()
        buffAnchorXOffset:SetPoint("TOPLEFT", buffGrowthDir, "TOPRIGHT", -10, 0)
        local buffAnchorYOffset = CreateEditBox("$parent_BuffAnchorXOffset", buffAnchorXOffset, srslylawlUI.GetSetting("party.buffs.xOffset"),
        function(self)
            local n = self:GetNumber()
            if srslylawlUI.GetSetting("party.buffs.yOffset") == n then return end
            srslylawlUI.ChangeSetting("party.buffs.yOffset", n)
            srslylawlUI.Party_SetBuffFrames()
        end)
        buffAnchorYOffset.title = buffAnchorYOffset:CreateFontString("$parent_Title", "OVERLAY", "GameFontNormal")
        buffAnchorYOffset.title:SetPoint("TOP", 0, 12)
        buffAnchorYOffset.title:SetText("Y-Offset")

        cFrame.editBoxes.buffAnchorXOffset = buffAnchorXOffset
        cFrame.editBoxes.buffAnchorYOffset = buffAnchorYOffset
        local buffIconSize = CreateEditBox("$parent_Icon Size", buffAnchorYOffset, srslylawlUI.GetSetting("party.buffs.size"),
        function(self)
            local n = self:GetNumber()
            if srslylawlUI.GetSetting("party.buffs.size") == n then return end
            srslylawlUI.ChangeSetting("party.buffs.size", n)
            srslylawlUI.Party_SetBuffFrames()
        end)
        cFrame.editBoxes.buffIconSize = buffIconSize
        buffIconSize.title = buffIconSize:CreateFontString("$parent_Title", "OVERLAY", "GameFontNormal")
        buffIconSize.title:SetPoint("TOP", 0, 12)
        buffIconSize.title:SetText("Size")

        cFrame.sliders.maxBuffs = CreateCustomSlider("Max Visible Buffs", 0, 40, srslylawlUI.GetSetting("party.buffs.maxBuffs"), buffAnchor, -50, 1, true, 0)
        cFrame.sliders.maxBuffs:SetPoint("TOPLEFT", buffAnchor, "BOTTOMLEFT", 20, -15)
        cFrame.sliders.maxBuffs:HookScript("OnValueChanged", function(self, value)
            srslylawlUI.ChangeSetting("party.buffs.maxBuffs", value)
        end)
        AddTooltip(cFrame.sliders.maxBuffs, "Requires UI Reload")

        --ccbar frame
        local ccBarFrame = CreateFrameWBG("Crowd Control Bar", petFrame)
        ccBarFrame:SetPoint("TOPLEFT", petFrame, "TOPRIGHT", 5, 0)
        ccBarFrame:SetSize(233, 125)
        -- ccBarFrame:SetPoint("BOTTOMRIGHT", petFrame, "BOTTOMRIGHT", 220, -65)
        
        --enable/disable ccbar
        local enableCCBar = CreateCheckButton("Enable CC Duration Bar", ccBarFrame)
        enableCCBar:SetScript("OnClick", function(self)
            srslylawlUI.ChangeSetting("party.ccbar.enabled", self:GetChecked())
            srslylawlUI.Frame_Party_ResetDimensions_ALL()
        end)
        local ccEnabled = srslylawlUI.GetSetting("party.ccbar.enabled")
        AddTooltip(enableCCBar, "Show Crowd Control duration of party members.")
        enableCCBar:SetPoint("TOPLEFT", ccBarFrame, "TOPLEFT", 5, -5)
        enableCCBar:SetChecked(ccEnabled)
        enableCCBar:SetAttribute("defaultValue", ccEnabled)

        --ccbar width
        cFrame.sliders.ccbarWidth = CreateCustomSlider("CC Bar Width", 3, 300, srslylawlUI.GetSetting("party.ccbar.width"), ccBarFrame, -50, 1, true, 0)
        cFrame.sliders.ccbarWidth:HookScript("OnValueChanged", function(self, value)
            srslylawlUI.ChangeSetting("party.ccbar.width", value)
            srslylawlUI.Frame_Party_ResetDimensions_ALL()
        end)
        cFrame.sliders.ccbarWidth:ClearAllPoints()
        cFrame.sliders.ccbarWidth:SetPoint("TOPLEFT", enableCCBar, "BOTTOMLEFT", 5, -10)

        --ccbar height
        cFrame.sliders.ccbarHeight = CreateCustomSlider("CC Bar Height %", 0.1, 1, srslylawlUI.GetSetting("party.ccbar.heightPercent"), ccBarFrame, -50, 0.05, false, 2)
        cFrame.sliders.ccbarHeight:HookScript("OnValueChanged", function(self, value)
            srslylawlUI.ChangeSetting("party.ccbar.heightPercent", value)
            srslylawlUI.Frame_Party_ResetDimensions_ALL()
        end)
        cFrame.sliders.ccbarHeight:ClearAllPoints()
        cFrame.sliders.ccbarHeight:SetPoint("TOPLEFT", cFrame.sliders.ccbarWidth, "BOTTOMLEFT", 0, -20)
        AddTooltip(cFrame.sliders.ccbarHeight, "Percentage of HP Bar height.")
        




        --Debuff Frames
        local debuffFrame = CreateFrameWBG("Party Debuffs", buffFrame)
        debuffFrame:SetPoint("TOPLEFT", buffFrame, "BOTTOMLEFT", 0, -15)
        debuffFrame:SetPoint("BOTTOMRIGHT", buffFrame, "BOTTOMRIGHT", 0, -120)
        local debuffAnchor = CreateCustomDropDown("Anchor", 75, debuffFrame, "TOPLEFT",
            "TOPLEFT", -10, -20, srslylawlUI.GetSetting("party.debuffs.anchor"), srslylawlUI.anchorTable, function(newValue)
                srslylawlUI.ChangeSetting("party.debuffs.anchor", newValue)
                srslylawlUI.Party_SetDebuffFrames()
        end, function(self) return self.value == srslylawlUI.GetSetting("party.debuffs.anchor") end)
        local debuffGrowthDir = CreateCustomDropDown("Growth Direction", 125, debuffAnchor, "TOPLEFT",
            "TOPRIGHT", -25, 0, srslylawlUI.GetSetting("party.debuffs.growthDir"), {"LEFT", "RIGHT"}, function(newValue)
                srslylawlUI.ChangeSetting("party.debuffs.growthDir", newValue)
                srslylawlUI.Party_SetDebuffFrames()
        end, function(self) return self.value == srslylawlUI.GetSetting("party.debuffs.growthDir") end)
        local debuffAnchorXOffset = CreateEditBox("$parent_DebuffAnchorXOffset", debuffGrowthDir, srslylawlUI.GetSetting("party.debuffs.xOffset"),
        function(self)
            local n = self:GetNumber()
            if srslylawlUI.GetSetting("party.debuffs.xOffset") == n then return end
            srslylawlUI.ChangeSetting("party.debuffs.xOffset", n)
            srslylawlUI.Party_SetDebuffFrames()
        end)
        debuffAnchorXOffset.title = debuffAnchorXOffset:CreateFontString("$parent_Title", "OVERLAY", "GameFontNormal")
        debuffAnchorXOffset.title:SetPoint("TOP", 0, 12)
        debuffAnchorXOffset.title:SetText("X-Offset")
        debuffAnchorXOffset:ClearAllPoints()
        debuffAnchorXOffset:SetPoint("TOPLEFT", debuffGrowthDir, "TOPRIGHT", -10, 0)
        local debuffAnchorYOffset = CreateEditBox("$parent_DebuffAnchorXOffset", debuffAnchorXOffset, srslylawlUI.GetSetting("party.debuffs.yOffset"),
        function(self)
            local n = self:GetNumber()
            if srslylawlUI.GetSetting("party.debuffs.yOffset") == n then return end
            srslylawlUI.ChangeSetting("party.debuffs.yOffset", n)
            srslylawlUI.Party_SetDebuffFrames()
        end)
        debuffAnchorYOffset.title = debuffAnchorYOffset:CreateFontString("$parent_Title", "OVERLAY", "GameFontNormal")
        debuffAnchorYOffset.title:SetPoint("TOP", 0, 12)
        debuffAnchorYOffset.title:SetText("Y-Offset")

        cFrame.editBoxes.debuffAnchorXOffset = debuffAnchorXOffset
        cFrame.editBoxes.debuffAnchorYOffset = debuffAnchorYOffset
        local debuffIconSize = CreateEditBox("$parent_Icon Size", debuffAnchorYOffset, srslylawlUI.GetSetting("party.debuffs.size"),
        function(self)
            local n = self:GetNumber()
            if srslylawlUI.GetSetting("party.debuffs.size") == n then return end
            srslylawlUI.ChangeSetting("party.debuffs.size", n)
            srslylawlUI.Party_SetDebuffFrames()
        end)
        cFrame.editBoxes.debuffIconSize = debuffIconSize
        debuffIconSize.title = debuffIconSize:CreateFontString("$parent_Title", "OVERLAY", "GameFontNormal")
        debuffIconSize.title:SetPoint("TOP", 0, 12)
        debuffIconSize.title:SetText("Size")

        cFrame.sliders.maxDebuffs = CreateCustomSlider("Max Visible Debuffs", 0, 40, srslylawlUI.GetSetting("party.debuffs.maxDebuffs"), debuffAnchor, -50, 1, true, 0)
        cFrame.sliders.maxDebuffs:SetPoint("TOPLEFT", debuffAnchor, "BOTTOMLEFT", 20, -15)
        cFrame.sliders.maxDebuffs:HookScript("OnValueChanged", function(self, value)
            srslylawlUI.ChangeSetting("party.debuffs.maxDebuffs", value)
        end)
        AddTooltip(cFrame.sliders.maxDebuffs, "Requires UI Reload")
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
            tab = CreateFrame("Button", "$parent_" .. n, frame, "OptionsFrameTabButtonTemplate")
            tab:SetID(i)
            tab:SetText(n)
            tab:SetScript("OnClick", Tab_OnClick)

            local width = tab:GetWidth()
            PanelTemplates_TabResize(tab, -10, nil, width)
            tab.content = CreateFrame("Frame", "$parent_" .. n .. "Content", frame)
            tab.content:SetAllPoints()
            tab.content:Hide()
            tab.content.tabButton = tab

            frame.Tabs[i] = tab
            table.insert(contents, tab.content)

            if i == 1 then
                tab:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -5, 0)
            else
                tab:SetPoint("BOTTOMLEFT", frame.Tabs[i - 1], "BOTTOMRIGHT", -10, 0)
            end
        end

        Tab_OnClick(frame.Tabs[1])

        return unpack(contents)
    end
    local function GenerateSpellList(spellListKey, filter, auratype)
        local function startsWith(str, start)
            str = string.lower(str)
            start = string.lower(start)
            return str:sub(1, #start) == start
        end
        local function contains(str, pattern)
            str = string.lower(str)
            pattern = string.lower(pattern)
            return string.match(str, pattern)
        end
        local filter = (filter ~= nil and filter) or ""
        spellList = srslylawlUI[auratype][spellListKey]
        if spellList == nil then error("spelllist nil "..spellListKey.. " "..auratype) end
        -- sort list
        local sortedSpellList = {}
        local exactMatch = nil
        for spellId, _ in pairs(spellList) do
            local name, _, icon = GetSpellInfo(spellId)
            local spell = {name = name, spellId = spellId, icon = icon}
            if tostring(spellId) == tostring(filter) then
                exactMatch = spell
            elseif startsWith(name, filter) or startsWith(spellId, filter) or contains(name, filter) then
                table.insert(sortedSpellList, spell)
            end
        end

        table.sort(sortedSpellList, function(a, b) return b.name > a.name end)

        if exactMatch ~= nil then
            table.insert(sortedSpellList, 1, exactMatch)
        end

        srslylawlUI.sortedSpellLists[auratype][spellListKey] = sortedSpellList
    end
    local function OpenSpellAttributePanel(parentTab, spellId)
        --auraType "buffs" or "debuffs"
        local function SetEnableButtons(attributePanel, auraType, checked)
            if auraType == "buffs" then
                    attributePanel.isDefensive:SetEnabled(not checked)
                    attributePanel.isAbsorb:SetEnabled(not checked)
                    attributePanel.DefensiveAmount:SetShown(attributePanel.isDefensive:GetChecked() and not checked)
            elseif auraType == "debuffs" then
                if (checked) then
                    UIDropDownMenu_DisableDropDown(attributePanel.CCType)
                else
                    UIDropDownMenu_EnableDropDown(attributePanel.CCType)
                end
            end
        end
        local function CreatePanel(parentTab, auraType)
            local attributePanel = CreateFrame("Frame","$parent_AttributePanel",parentTab, "BackdropTemplate")
            parentTab:GetParent().AttributePanel = attributePanel --make the attribute panel unique to the auratype buff
            attributePanel:SetBackdrop(
                {
                    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                    edgeSize = 10,
                    insets = {left = 4, right = 4, top = 4, bottom = 4}
            })
            attributePanel:SetBackdropColor(1, 1, 1, .4)

            local function ButtonCheckFunction(auraType, category, attribute)
                return function(self)
                    local id = self:GetParent():GetAttribute("spellId")
                    local checked = self:GetChecked()

                    srslylawlUI[auraType].known[id][attribute] = checked
                    srslylawl_saved[auraType].known[id][attribute] = checked

                    if checked then
                        srslylawlUI[auraType][category][id] = srslylawlUI[auraType].known[id]
                        srslylawl_saved[auraType][category][id] = srslylawlUI[auraType].known[id]

                        --remove from opposite list
                        if category == "whiteList" then
                            srslylawlUI[auraType].blackList[id] = nil
                            srslylawl_saved[auraType].blackList[id] = nil
                            self:GetParent().isBlacklisted:SetChecked(not checked)
                        elseif category == "blackList" then
                            srslylawlUI[auraType].whiteList[id] = nil
                            srslylawl_saved[auraType].whiteList[id] = nil
                            self:GetParent().isWhitelisted:SetChecked(not checked)
                        end
                    else
                        srslylawlUI[auraType][category][id] = nil
                        srslylawl_saved[auraType][category][id] = nil
                    end



                    --refresh buttons to reflect new list
                    parentTab:GetParent():Hide()
                    parentTab:GetParent():Show()
                end
            end

            -- local disableOnAutodetect = {}

            attributePanel.SpellIconFrame = CreateFrame("Frame", "$parent_SpellIconFrame", attributePanel)
            attributePanel.SpellIconFrame:SetSize(75, 75)
            attributePanel.SpellIconFrame:SetPoint("TOPLEFT", attributePanel, "TOPLEFT", 5, -5)
            attributePanel.SpellIcon = attributePanel.SpellIconFrame:CreateTexture("$parent_SpellIcon")
            attributePanel.SpellIcon:SetAllPoints(true)

            
            attributePanel.SpellName = attributePanel:CreateFontString("$parent_SpellName", "OVERLAY", "GameFontGreenLarge")
            attributePanel.SpellName:SetPoint("LEFT", attributePanel.SpellIcon, "RIGHT", 15, 0)
            
            
            attributePanel.isWhitelisted = CreateCheckButton("Whitelisted", attributePanel)
            attributePanel.isWhitelisted:SetScript("OnClick", ButtonCheckFunction(auraType, "whiteList", "isWhitelisted"))
            attributePanel.isWhitelisted:SetPoint("TOPLEFT", attributePanel.SpellIcon, "BOTTOMLEFT", 5, -5)
            
            attributePanel.isBlacklisted = CreateCheckButton("Blacklisted", attributePanel)
            attributePanel.isBlacklisted:SetScript("OnClick", ButtonCheckFunction(auraType, "blackList", "isBlacklisted"))
            attributePanel.isBlacklisted:SetPoint("TOPLEFT", attributePanel.isWhitelisted, "BOTTOMLEFT")

            attributePanel.AutoDetect = CreateCheckButton("Auto-Detect settings", attributePanel)
            attributePanel.AutoDetect:SetPoint("TOPLEFT", attributePanel.isBlacklisted, "BOTTOMLEFT")

            AddTooltip(attributePanel.AutoDetect, "Automatically detect settings based on spell tooltip. Disable this to stop updating the settings when spell is encountered.\nUse this if auto settings aren't accurate for this spell, recommended for non-english language clients.")
            attributePanel.AutoDetect:SetScript("OnClick", function(self)
                local id = self:GetParent():GetAttribute("spellId")
                local checked = self:GetChecked()

                srslylawlUI[auraType].known[id].autoDetect = checked
                srslylawl_saved[auraType].known[id].autoDetect = checked

                SetEnableButtons(attributePanel, auraType, checked)
            end)

            attributePanel.LastParsedText = CreateFrame("Frame", "$parent_LastParsedText", attributePanel)
            attributePanel.LastParsedText.title = attributePanel.LastParsedText:CreateFontString("$parent_Title", "OVERLAY", "GameFontNormal")
            attributePanel.LastParsedText.title:SetText("<last seen tooltip>")
            
            attributePanel.LastParsedText:SetPoint("TOPRIGHT", attributePanel, "TOPRIGHT")
            attributePanel.LastParsedText:SetPoint("BOTTOMLEFT", attributePanel, "TOPRIGHT", -attributePanel.LastParsedText.title:GetStringWidth()-5, -attributePanel.LastParsedText.title:GetStringHeight()-5)
            attributePanel.LastParsedText.title:ClearAllPoints(true)
            attributePanel.LastParsedText.title:SetPoint("CENTER")

            if auraType == "buffs" then
                attributePanel.isDefensive = CreateCheckButton("is Defensive effect", attributePanel)
                attributePanel.isDefensive:SetPoint("TOPLEFT", attributePanel.AutoDetect, "BOTTOMRIGHT", -5, 0)
                attributePanel.isDefensive:SetScript("OnClick", ButtonCheckFunction(auraType, "defensives", "isDefensive"))
                AddTooltip(attributePanel.isDefensive, "Does this buff provide % damage reduction?\nDisabling this will stop the effect from being used in effective health calculations.")

                attributePanel.DefensiveAmount = CreateEditBox("Reduction Amount", attributePanel, 0,
                    nil, "LEFT", 0, 0, true)
                attributePanel.DefensiveAmount:ClearAllPoints(true)
                attributePanel.DefensiveAmount:SetPoint("LEFT", attributePanel.isDefensive.text, "RIGHT")
                attributePanel.DefensiveAmount:SetScript("OnEnterPressed", function (self)
                        local amount = self:GetNumber();
                        local id = self:GetParent():GetAttribute("spellId")
                        local old = srslylawlUI.buffs.known[id].reductionAmount
                        srslylawlUI.buffs.known[id].reductionAmount = amount
                        srslylawlUI.buffs.defensives[id] = srslylawlUI.buffs.known[id]

                        srslylawl_saved.buffs.known[id].reductionAmount = amount
                        srslylawl_saved.buffs.defensives[id] = srslylawlUI.buffs.known[id]

                        srslylawlUI.Log("Damage reduction amount for spell " .. GetSpellInfo(id) .. " set from " .. old .. "% to " .. amount .. "%!")
                    end)
                AddTooltip(attributePanel.DefensiveAmount, "Set custom damage reduction effect (per stack) in % and confirm with [ENTER]-Key.\n(For example: Enter 15 for 15% damage reduction)\n\nSetting this to 100 will cause this spell to be treated as an immunity.")

                attributePanel.isAbsorb = CreateCheckButton("is Absorb effect", attributePanel)
                attributePanel.isAbsorb:SetPoint("TOPLEFT", attributePanel.isDefensive, "BOTTOMLEFT")
                attributePanel.isAbsorb:SetScript("OnClick", ButtonCheckFunction(auraType, "absorbs", "isAbsorb"))
                AddTooltip(attributePanel.isAbsorb, "Does this buff provide damage absorption?\nDisabling this will stop the effect from being displayed as an absorb segment.\n\nNote: will cause errors if spell is not actually an absorb effect.")
                AddTooltip(attributePanel.isWhitelisted, "Whitelisted buffs will always be displayed as buff frames.")
                AddTooltip(attributePanel.isBlacklisted, "Blacklisted buffs won't be displayed as buffs.\n\nNote: [SHIFT]-[RIGHTCLICK]ing an active buff (or debuff) will automatically blacklist it.")
            elseif auraType == "debuffs" then
                AddTooltip(attributePanel.isWhitelisted, "Whitelisted debuffs will always be displayed.")
                AddTooltip(attributePanel.isBlacklisted, "Blacklisted debuffs won't be displayed.\n\nNote: [SHIFT]-[RIGHTCLICK]ing an active debuff (or buff) will automatically blacklist it.")

                attributePanel.CCType = CreateFrame("FRAME", "$parent_CCType", attributePanel, "UIDropDownMenuTemplate")
                attributePanel.CCType:SetPoint("TOPLEFT", attributePanel.AutoDetect, "BOTTOMLEFT", -15, 0)
                UIDropDownMenu_SetWidth(attributePanel.CCType, 200)
                UIDropDownMenu_SetText(attributePanel.CCType, "Crowd Control Type")
            end

            attributePanel.RemoveSpell = CreateFrame("Button", "$parent_RemoveSpell", attributePanel, "UIPanelButtonTemplate")
            attributePanel.RemoveSpell:SetSize(200, 25)
            attributePanel.RemoveSpell:SetPoint("BOTTOMRIGHT", attributePanel, "BOTTOMRIGHT", -5, 5)
            attributePanel.RemoveSpell:SetScript("OnClick", function(self)
                local spellId = attributePanel:GetAttribute("spellId")
                local auraType = parentTab:GetAttribute("auraType")
                srslylawlUI.Auras_ManuallyRemoveSpell(spellId, auraType)

                parentTab:GetParent():Hide()
                parentTab:GetParent():Show()
                attributePanel:Hide()
            end)
        end

        local auraType = parentTab:GetAttribute("auraType")
        local spellList = parentTab:GetAttribute("spellList")
        local attributePanel = parentTab:GetParent().AttributePanel

        if attributePanel == nil then
            if spellId == nil then return end
            CreatePanel(parentTab, auraType)
            attributePanel = parentTab:GetParent().AttributePanel
        end

        attributePanel:Show()
        attributePanel:SetParent(parentTab)
        attributePanel:SetPoint("TOPLEFT", parentTab.borderFrame,"TOPRIGHT")
        attributePanel:SetPoint("BOTTOMRIGHT", parentTab,"BOTTOMRIGHT", -5, 5)
        
        if spellId == nil then
            --only adjusting parenting (switched/opened tabs)
            if not srslylawlUI[auraType].known[attributePanel:GetAttribute("spellId")] then
                attributePanel:Hide()
            end
            return 
        end

        attributePanel:SetAttribute("spellId", spellId)
        

        attributePanel.SpellIcon:SetTexture(select(3, GetSpellInfo(spellId)))
        AddSpellTooltip(attributePanel.SpellIconFrame, spellId)
        attributePanel.SpellName:SetText(select(1, GetSpellInfo(spellId)))
        attributePanel.RemoveSpell:SetText("Remove Spell from "..auraType)
        AddTooltip(attributePanel.RemoveSpell, "WARNING: this will remove the spell from every >\""..auraType.."\"< category, including \"Encountered\".\nIf you just want to change its sub-category, use the appropriate checkbox/dropdown.")



        local isBlacklisted = srslylawlUI[auraType].blackList[spellId] ~= nil or false
        local isWhitelisted = srslylawlUI[auraType].whiteList[spellId] ~= nil or false
        local autoDetect = srslylawlUI[auraType].known[spellId].autoDetect == nil or srslylawlUI[auraType].known[spellId].autoDetect
        AddTooltip(attributePanel.LastParsedText, srslylawlUI[auraType].known[spellId].text or "<Aura either has no tooltip or was never encountered>")
        attributePanel.AutoDetect:SetChecked(autoDetect)
        attributePanel.isBlacklisted:SetChecked(isBlacklisted)
        attributePanel.isWhitelisted:SetChecked(isWhitelisted)
        if auraType == "buffs" then
            attributePanel.isDefensive:SetChecked(srslylawlUI.buffs.known[spellId].isDefensive)
            attributePanel.isAbsorb:SetChecked(srslylawlUI.buffs.known[spellId].isAbsorb)
            attributePanel.DefensiveAmount:SetNumber(srslylawlUI[auraType].known[spellId].reductionAmount or 0)
            -- attributePanel.DefensiveAmount:SetShown(srslylawlUI.buffs.known[spellId].isDefensive and not autoDetect)
        elseif auraType == "debuffs" then
            --dropdown cctype
            local dropDown = attributePanel.CCType
            UIDropDownMenu_SetText(attributePanel.CCType, "Crowd Control Type: " .. srslylawlUI.Utils_CCTableTranslation(srslylawlUI[auraType].known[spellId].crowdControlType))
            UIDropDownMenu_Initialize(dropDown, 
                function(self)
                    local info = UIDropDownMenu_CreateInfo()
                    local checkFunc = function(self) 
                        return self.value == srslylawlUI.Utils_CCTableTranslation(srslylawlUI[auraType].known[spellId].crowdControlType)
                    end
                    info.func = self.SetValue
                    for k, v in pairs(srslylawlUI.crowdControlTable) do
                        local value = srslylawlUI.Utils_CCTableTranslation(v)
                        info.text = value
                        info.arg1 = value
                        info.checked = checkFunc
                        UIDropDownMenu_AddButton(info)
                    end
                    info.text = "none"
                    info.arg1 = "none"
                    info.checked = checkFunc
                    UIDropDownMenu_AddButton(info)
                end)
            function attributePanel.CCType:SetValue(newValue)
                local spell = srslylawlUI[auraType].known[spellId]
                local old = spell.crowdControlType
                UIDropDownMenu_SetText(attributePanel.CCType, "Crowd Control Type: " .. newValue)
                newValue = srslylawlUI.Utils_CCTableTranslation(newValue)

                if old ~= "none" then 
                    srslylawlUI[auraType][old][spellId] = nil
                    srslylawl_saved[auraType][old][spellId] = nil
                end

                if newValue ~= "none" then
                    srslylawlUI[auraType][newValue][spellId] = spell
                    srslylawl_saved[auraType][newValue][spellId] = spell
                end

                srslylawlUI[auraType].known[spellId].crowdControlType = newValue
                srslylawl_saved[auraType].known[spellId].crowdControlType = newValue

                parentTab:Hide()
                parentTab:Show()
            end
            
        end
        SetEnableButtons(attributePanel, auraType, autoDetect)
    end
    local function CreateFauxScrollFrame(parent, spellList)
        --fauxscrollframe doesnt actually create a button for every item, it just creates max amount of buttons once and then updates them during scrolling
        local function CreateButtons(parent,count, tab)
            function Button_OnClick(self)
                local id = self:GetID()
                --local parent = self:GetParent()
                local tabcontent = parent:GetParent():GetParent()
                local spellId = self:GetAttribute("spellId")
                for _, button in pairs(parent.Buttons) do
                    button:SetChecked(button:GetID() == id)
                end
                tabcontent.activeButton = self
                tabcontent.lastSelectedSpellId = spellId
                local auraType = tabcontent:GetAttribute("auraType")
                OpenSpellAttributePanel(tabcontent, spellId)
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
            local tab = self:GetParent():GetParent()
            local filterText = tab.FilterFrame.EditBox:GetText()
            GenerateSpellList(spellList, filterText or "", tab:GetAttribute("auraType"))
            ScrollFrame_Update(self)
            OpenSpellAttributePanel(tab)
         end)
        return ScrollFrame
    end
    local function CreateScrollFrameWithBGAndChild(parent)
        parent.borderFrame = CreateFrame("Frame", "$parent_BorderFrame", parent, "BackdropTemplate")
        parent.borderFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 10,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        })
        parent.borderFrame:SetBackdropColor(0, 1, 1, .4)
        parent.borderFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, -45)
        parent.borderFrame:SetPoint("TOPRIGHT", parent, "TOPLEFT", 300, -5)
        parent.borderFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 5)

        parent.ScrollFrame = CreateFauxScrollFrame(parent.borderFrame, parent:GetAttribute("spellList"))
        parent.ScrollFrame:SetPoint("TOPLEFT", parent.borderFrame, "TOPLEFT", 2, -5)
        parent.ScrollFrame:SetPoint("TOPRIGHT", parent.borderFrame, "TOPRIGHT", 5, -5)
        parent.ScrollFrame:SetPoint("BOTTOM", parent.borderFrame, "BOTTOM", 0, 5)
        parent.ScrollFrame:SetPoint("BOTTOMLEFT", parent.borderFrame, "BOTTOMRIGHT", 0, 5)

        parent.ScrollFrame.child = CreateFrame("Frame", "$parent_ScrollFrameChild", parent.ScrollFrame)
        parent.ScrollFrame.child:SetPoint("CENTER", parent.ScrollFrame)
        parent.ScrollFrame.child:SetPoint("LEFT", parent.ScrollFrame, "LEFT")
        parent.ScrollFrame.child:SetPoint("RIGHT", parent.ScrollFrame, "RIGHT")
        parent.ScrollFrame.child:SetSize(parent.borderFrame:GetWidth() - 30, 100)
        parent.ScrollFrame:SetScrollChild(parent.ScrollFrame.child)
        --Filtering the list by name or ID
        parent.FilterFrame = CreateFrameWBG("FilterFrame", parent)
        parent.FilterFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, -20)
        parent.FilterFrame:SetPoint("BOTTOMRIGHT", parent.borderFrame, "TOPRIGHT", 0, 2)
        parent.FilterFrame.title:SetText("Filter by Name or ID:")
        parent.FilterFrame.EditBox = CreateEditBox("filterBox", parent.FilterFrame, "",
            function(self)
                local listKey = parent:GetAttribute("spellList")
                local filterText = self:GetText()
                GenerateSpellList(listKey, filterText, parent:GetAttribute("auraType"))
                ScrollFrame_Update(parent.ScrollFrame)
            end, "CENTER", 0, 0, false)
        parent.FilterFrame.EditBox:SetMaxLetters(20)
        parent.FilterFrame.EditBox:SetAllPoints(true)
        --Allowing to add a new spell
        parent.AddNewSpellFrame = CreateFrame("Button", "$parent_AddNewSpell", parent.FilterFrame, "UIPanelButtonTemplate")
        parent.AddNewSpellFrame:SetSize(115, 25)
        parent.AddNewSpellFrame:SetText("Add New Spell")
        parent.AddNewSpellFrame:SetPoint("LEFT", parent.FilterFrame.EditBox, "RIGHT")
        parent.AddNewSpellFrame:SetScript("OnClick", function(self)
            local input = parent.FilterFrame.EditBox:GetText()
            local auraType = parent:GetAttribute("auraType")
            srslylawlUI.Auras_ManuallyAddSpell(input, auraType)
            parent:GetParent():GetParent():Hide()
            parent:GetParent():GetParent():Show()
        end)



        return parent.ScrollFrame, parent.ScrollFrame.child
    end
    local function CreateBuffTabs(knownSpells, absorbSpells, defensives, whiteList, blackList)
        local function Menu_OnShow(parentTab, list)
            return function()
                --OpenSpellAttributePanel(parentTab, "buffs")
                --local mainButton = parentTab.Buttons[1]
                --if mainButton then mainButton:Click() end
            end
        end
        local function CreateFrames(tab, key)
            tab:SetScript("OnShow", Menu_OnShow(tab, key))
            tab:SetAttribute("spellList", key)
            tab:SetAttribute("auraType", "buffs")
            CreateScrollFrameWithBGAndChild(tab)
        end
        CreateFrames(knownSpells, "known")
        CreateFrames(absorbSpells, "absorbs")
        CreateFrames(defensives, "defensives")
        CreateFrames(whiteList, "whiteList")
        CreateFrames(blackList, "blackList")
    end
    local function CreateDebuffTabs(knownDebuffs, whiteList, blackList, stuns, incaps, disorients, silences, roots)
        local function Menu_OnShow(parentTab, list)
            return function()
                --OpenSpellAttributePanel(parentTab, "debuffs")
                --local mainButton = parentTab.Buttons[1]
                --if mainButton then mainButton:Click() end
            end
        end
        local function CreateFrames(tab, key)
            tab:SetScript("OnShow", Menu_OnShow(tab, key))
            tab:SetAttribute("spellList", key)
            tab:SetAttribute("auraType", "debuffs")
            CreateScrollFrameWithBGAndChild(tab)
        end
        CreateFrames(knownDebuffs, "known")
        CreateFrames(whiteList, "whiteList")
        CreateFrames(blackList, "blackList")
        CreateFrames(stuns, "stuns")
        CreateFrames(incaps, "incaps")
        CreateFrames(disorients, "disorients")
        CreateFrames(silences, "silences")
        CreateFrames(roots, "roots")
    end

    srslylawlUI_ConfigFrame = CreateFrame("Frame", "srslylawlUI_Config", UIParent, "UIPanelDialogTemplate")
    local cFrame = srslylawlUI_ConfigFrame
    local cFrameSizeX = 750
    local cFrameSizeY = 500

    -- Main Config Frame
    cFrame.name = "srslylawlUI"
    cFrame:SetSize(cFrameSizeX, cFrameSizeY)
    cFrame:SetPoint("CENTER")
    cFrame.Title:SetText("srslylawlUI Configuration")
    srslylawlUI.Frame_MakeFrameMoveable(cFrame)
    cFrame:SetScript("OnHide", function() ToggleFakeFrames(false) end)

    cFrame.body = CreateConfigBody("$parent_Body", cFrame)

    CreateSaveLoadButtons(cFrame)

    local generalTab, playerFrames, partyFramesTab, buffsTab, debuffsTab = SetTabs(cFrame.body, "General", "Player Frames", "Party Frames", "Buffs", "Debuffs")

    -- Create General Tab
    Mixin(generalTab, BackdropTemplateMixin)
    generalTab:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 4, right = 4, top = 4, bottom = 4}})
    generalTab:SetBackdropColor(0, 0, 0, .4)
    FillGeneralTab(generalTab)

    -- Create Frames Tab
    Mixin(partyFramesTab, BackdropTemplateMixin)
    partyFramesTab:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 4, right = 4, top = 4, bottom = 4}})
    partyFramesTab:SetBackdropColor(0, 0, 0, .4)
    local ScrollFrame = CreateFrame("ScrollFrame", "$parent_ScrollFrame", partyFramesTab, "UIPanelScrollFrameTemplate")
    ScrollFrame:SetClipsChildren(true)
    ScrollFrame:SetAllPoints(true)
    ScrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local newValue = self:GetVerticalScroll() - (delta * 20)
        if newValue < 0 then
            newValue = 0
        elseif newValue > self:GetVerticalScrollRange() then
            newValue = self:GetVerticalScrollRange()
        end
        self:SetVerticalScroll(newValue)
    end)
    ScrollFrame.ScrollBar:ClearAllPoints()
    ScrollFrame.ScrollBar:SetPoint("TOPLEFT", ScrollFrame, "TOPRIGHT", -22, -20)
    ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", ScrollFrame, "BOTTOMRIGHT", -7, 20)
    ScrollFrame.child = CreateFrame("Frame", "$parent_ScrollFrameChild", ScrollFrame)
    ScrollFrame.child:SetAllPoints(true)
    ScrollFrame.child:SetSize(partyFramesTab:GetWidth()-30, 10000)
    ScrollFrame:SetScrollChild(ScrollFrame.child)
    FillFramesTab(ScrollFrame.child)

    -- Create Buffs Tab
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
    local knownBuffs, absorbs, defensives, whiteList, blackList =
        SetTabs(buffsTab, "Encountered", "Absorbs", "Defensives", "Whitelist", "Blacklist")
    AddTooltip(knownBuffs.tabButton, "List of all encountered buffs.")
    AddTooltip(absorbs.tabButton, "Buffs with absorb effects, will be shown as segments.")
    AddTooltip(defensives.tabButton, "Buffs with damage reduction effects, will increase your effective health.")
    AddTooltip(whiteList.tabButton, "Whitelisted buffs will always appear as buff frames.")
    AddTooltip(blackList.tabButton, "Buffs that will not be displayed on the interface")

    Mixin(knownBuffs, BackdropTemplateMixin)
    CreateBuffTabs(knownBuffs, absorbs, defensives, whiteList, blackList)

    -- Create Debuffs Tab
    debuffsTab:ClearAllPoints()
    debuffsTab:SetPoint("TOP", cFrame.body, "TOP", 0, -35)
    debuffsTab:SetPoint("BOTTOMLEFT", cFrame.body, "BOTTOMLEFT", 4, 4)
    debuffsTab:SetPoint("BOTTOMRIGHT", cFrame.body, "BOTTOMRIGHT", -4, 2)
    Mixin(debuffsTab, BackdropTemplateMixin)
    debuffsTab:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = {left = 4, right = 4, top = 4, bottom = 4}})
    debuffsTab:SetBackdropColor(0, 0, 0, .4)
    
    local knownDebuffs, whiteList, blackList, stuns, incaps, disorients, silences, roots = 
        SetTabs(debuffsTab, "Encountered", "Whitelist", "Blacklist", "Stuns", "Incapacitates", "Disorients", "Silences", "Roots")
    CreateDebuffTabs(knownDebuffs, whiteList, blackList, stuns, incaps, disorients, silences, roots)
    AddTooltip(knownDebuffs.tabButton, "List of all encountered debuffs.")
    AddTooltip(whiteList.tabButton, "Whitelisted debuffs will always be displayed.")
    AddTooltip(blackList.tabButton, "Blacklisted debuffs will never be displayed.")


    srslylawlUI.ToggleConfigVisible(true)
    InterfaceOptions_AddCategory(srslylawlUI_ConfigFrame)
end