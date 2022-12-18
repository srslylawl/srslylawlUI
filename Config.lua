srslylawlUI = srslylawlUI or {}


srslylawlUI.ConfigElements = {
    EditBoxes = {},
    Sliders = {},
    Dropdowns = {},
    CheckButtons = {}
}

srslylawlUI.UnitToColor = {
    ["party"] = { 0.019, 0.407, 1, .4 },
    ["player"] = { 0.109, 0.807, 0.301, .4 },
    ["target"] = { 0.937, 0.121, 0.101, .4 },
    ["targettarget"] = { 0.901, 0.156, 0.490, .4 },
    ["focus"] = { 0.929, 0.796, 0.172, .4 }
}

function srslylawlUI.CreateConfigWindow()
    local function ToggleFakeFrames(bool)
        if srslylawlUI_ConfigFrame.fakeFramesToggled == bool then
            return
        end
        srslylawlUI_ConfigFrame.lockFramesButton:SetChecked(bool)

        srslylawlUI_ConfigFrame.fakeFramesToggled = bool
        srslylawlUI.ToggleFauxFrames(bool)

        srslylawlUI_PartyHeader:SetMovable(bool)
        srslylawlUI.mainUnits.player.unitFrame.unit:SetMovable(bool)
        srslylawlUI.mainUnits.target.unitFrame.unit:SetMovable(bool)
        srslylawlUI.mainUnits.focus.unitFrame.unit:SetMovable(bool)
        srslylawlUI.mainUnits.targettarget.unitFrame:SetMovable(bool)
        srslylawlUI.mainUnits.player.unitFrame:SetDemoMode(bool)
        srslylawlUI.mainUnits.target.unitFrame:SetDemoMode(bool)
        srslylawlUI.mainUnits.focus.unitFrame:SetDemoMode(bool)

        srslylawlUI.Log((bool and "Frames can now be dragged!" or "Frames locked in place."))
    end

    local function CreateInfoBox(parent, content, width)
        local bounds = CreateFrame("Frame", "$parent_Bounds", parent)
        local infoBox = bounds:CreateFontString("$parent_InfoBox", "ARTWORK")
        infoBox.bounds = bounds
        infoBox.background = CreateFrame("Frame", "$parent_BG", bounds, "BackdropTemplate")
        infoBox:SetParent(infoBox.background)
        infoBox.background:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            -- edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            -- edgeSize = 0,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        infoBox.background:SetBackdropColor(0.05, 0.05, .05, .5)
        infoBox:SetPoint("CENTER")
        infoBox:SetWidth(width)
        infoBox:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
        infoBox:SetTextColor(0.980, 0.862, 0.180)

        infoBox:SetText(content)

        bounds:SetSize(width + 20, infoBox:GetStringHeight() + 20)
        infoBox.background:SetPoint("TOPLEFT", bounds, "TOPLEFT", 8, -8)
        infoBox.background:SetPoint("BOTTOMRIGHT", bounds, "BOTTOMRIGHT", -8, 8)


        local oldSetText = infoBox.SetText
        function infoBox:SetText(str)
            oldSetText(self, str)
            bounds:SetSize(width + 20, infoBox:GetStringHeight() + 20)
        end

        return infoBox
    end

    local function CreateCustomEditBox(parent, title)
        local bounds = CreateFrame("Frame", "$parent_Bounds", parent)
        local editBox = CreateFrame("EditBox", "$parent_" .. title, bounds, "BackdropTemplate")
        editBox.bounds = bounds
        editBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        editBox:SetAllPoints(true)
        editBox:SetBackdropColor(0.05, 0.05, .05, .5)
        editBox:SetTextInsets(5, 5, 0, 0)
        bounds:SetSize(40, 25)
        editBox:SetAutoFocus(false)
        editBox:SetFont("Fonts\\FRIZQT__.TTF", 10, "")

        function editBox:SetTitle(title)
            if not self.title then
                self.title = self:CreateFontString("$parent_Title", "OVERLAY", "GameFontNormal")
                self.title:SetPoint("TOP", 0, 12)
                self.bounds:SetHeight(62)
            end
            self.title:SetText(title)
        end

        return editBox
    end

    local function CreateCustomSlider(name, parent, min, max, valuePath, valueStep, decimals, onChangeFunc, canBeNil)
        local title = name
        name = "$parent_Slider" .. valuePath .. name
        local bounds = CreateFrame("Frame", "$parent_Bounds", parent)
        local slider = CreateFrame("Slider", name, bounds, "OptionsSliderTemplate")
        slider.bounds = bounds

        slider:SetPoint("LEFT", bounds, "LEFT", 5, 0)
        name = slider:GetName()
        slider.Low:SetText(min)
        slider.High:SetText(max)
        slider.Text:SetText(title)
        slider.Text:SetTextColor(0.380, 0.705, 1, 1)
        slider.Text:SetPoint("TOP", 0, 15)
        local width, height = slider:GetWidth() + 20, slider:GetHeight() + slider.Text:GetStringHeight() + 15 + 10

        slider:SetMinMaxValues(min, max)
        local var = srslylawlUI.GetSetting(valuePath, canBeNil)
        var = srslylawlUI.Utils_DecimalRound(var, decimals) or 0
        slider:SetValue(var)
        slider:SetValueStep(valueStep)
        slider:SetObeyStepOnDrag(true)
        local editBox = CreateFrame("EditBox", name .. "_EditBox", slider, "BackdropTemplate")
        editBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        editBox:SetBackdropColor(0, 0.254, 0.478, 1)
        editBox:SetTextInsets(5, 5, 0, 0)
        editBox:SetSize(60, 20)
        editBox:SetPoint("TOP", slider, "BOTTOM", 0, 0)
        editBox:SetAutoFocus(false)
        editBox:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
        editBox:SetNumeric(false)
        if (min >= 0 and max >= 0) and (not decimals or decimals == 0) then
            editBox:SetNumber(var)
            editBox:SetScript("OnTextChanged", function(self) slider:SetValue(self:GetNumber()) end)
            slider:SetScript("OnValueChanged", function(self, value)
                if editBox:GetNumber() == tonumber(value) then
                    srslylawlUI.ChangeSetting(valuePath, value)
                    if onChangeFunc then
                        onChangeFunc()
                    end
                    return
                else
                    local index = string.find(tostring(value), "%p")
                    if type(index) ~= "nil" then
                        value = string.sub(tostring(value), 0, index - 1)
                    end
                    value = tonumber(value)
                    editBox:SetNumber(value)
                    srslylawlUI.ChangeSetting(valuePath, value)
                    if onChangeFunc then
                        onChangeFunc()
                    end
                end
            end)
        else
            editBox:SetText(var)
            editBox:SetScript("OnTextChanged", function(self)
                local text = self:GetText()

                if type(text) == "string" then
                    text = tonumber(text)
                end
                text = text or 0
                text = srslylawlUI.Utils_DecimalRound(text, decimals)

                slider:SetValue(text)
            end)
            slider:SetScript("OnValueChanged", function(self, value)
                if editBox:GetText() == srslylawlUI.Utils_DecimalRound(value, decimals) then
                    srslylawlUI.ChangeSetting(valuePath, value)
                    return
                else
                    editBox:SetText(srslylawlUI.Utils_DecimalRound(value, decimals))
                    srslylawlUI.ChangeSetting(valuePath, value)
                    if onChangeFunc then
                        onChangeFunc()
                    end
                end
            end)
        end

        function slider:Reset()
            local setting = srslylawlUI.GetSetting(valuePath, canBeNil)
            setting = srslylawlUI.Utils_DecimalRound(setting, decimals) or 0
            if self:GetValue() == setting then return end

            self:SetValue(setting)
            self.editbox:SetText(setting)
        end

        function slider:SetValueClean(val)
            local isDirty = srslylawlUI.unsaved.flag
            slider:SetValue(val)

            if not isDirty then
                srslylawlUI.RemoveDirtyFlag()
            end
        end

        slider.editbox = editBox
        table.insert(srslylawlUI.ConfigElements.Sliders, slider)
        bounds:SetSize(width, height)
        return slider
    end

    local function CreatePowerBarSlider(title, parent, name, specID, value, default, onChangeFunc)
        local bounds = CreateFrame("Frame", "$parent_Bounds", parent)
        local slider = CreateFrame("Slider", "$parent_Slider" .. title .. name, bounds, "OptionsSliderTemplate")
        slider.bounds = bounds

        local px = srslylawlUI.Utils_PixelFromCodeToScreen(1)
        local valuePath = "player.playerFrame.power.overrides." .. specID .. "." .. name .. "."
        if name == "CastBar" then
            valuePath = "player.playerFrame.cast."
        end
        valuePath = valuePath .. value
        local canBeNil = true
        local max = value == "priority" and 10 or 200

        slider:SetPoint("LEFT", bounds, "LEFT", 5, 0)
        slider.Low:SetText(0)
        slider.High:SetText(max)
        slider.Text:SetText(title)
        slider.Text:SetTextColor(0.380, 0.705, 1, 1)
        slider.Text:SetPoint("TOP", 0, 15)
        local width, height = slider:GetWidth() + 20, slider:GetHeight() + slider.Text:GetStringHeight() + 15 + 10
        slider:SetMinMaxValues(0, max)
        local var = srslylawlUI.GetSetting(valuePath, canBeNil)
        var = var or default
        slider:SetValue(var)
        slider:SetValueStep(1)
        slider:SetObeyStepOnDrag(true)
        local editBox = CreateFrame("EditBox", name .. "_EditBox", slider, "BackdropTemplate")
        editBox:SetSize(60, 20)
        editBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        editBox:SetBackdropColor(0, 0.254, 0.478, 1)
        editBox:SetTextInsets(5, 5, 0, 0)
        editBox:SetPoint("TOP", slider, "BOTTOM", 0, 0)
        editBox:SetAutoFocus(false)
        editBox:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
        editBox:SetNumeric(false)
        editBox:SetNumber(var)
        editBox:SetScript("OnTextChanged", function(self) slider:SetValue(self:GetNumber()) end)
        slider:SetScript("OnValueChanged", function(self, value)
            if editBox:GetNumber() == tonumber(value) then
                srslylawlUI.ChangeSetting(valuePath, value)
                if onChangeFunc then
                    onChangeFunc()
                end
                return
            else
                local index = string.find(tostring(value), "%p")
                if type(index) ~= "nil" then
                    value = string.sub(tostring(value), 0, index - 1)
                end
                value = tonumber(value)
                editBox:SetNumber(value)
                srslylawlUI.ChangeSetting(valuePath, value)
                if onChangeFunc then
                    onChangeFunc()
                end
            end
        end)
        function slider:Reset()
            local setting = srslylawlUI.GetSetting(valuePath, canBeNil)
            setting = setting or default
            if self:GetValue() == setting and self.editbox:GetText() == setting then return end
            self:SetValue(setting)
            self.editbox:SetText(setting)
            if onChangeFunc then
                onChangeFunc()
            end
        end

        function slider:SetValueClean(val)
            local isDirty = srslylawlUI.unsaved.flag
            slider:SetValue(val)

            if not isDirty then
                srslylawlUI.RemoveDirtyFlag()
            end
        end

        slider.editbox = editBox
        table.insert(srslylawlUI.ConfigElements.Sliders, slider)
        bounds:SetSize(width, height)
        return slider
    end

    local function CreateCustomDropDown(title, width, parent, valuePath, values, onChangeFunc, onInitValueFunc)
        -- Create the dropdown, and configure its appearance
        local bounds = CreateFrame("Frame", "$parent_" .. valuePath .. "Bounds", parent)
        local dropDown = CreateFrame("FRAME", "$parent_" .. title, bounds, "UIDropDownMenuTemplate")
        dropDown.title = dropDown:CreateFontString("$parent_Title", "OVERLAY", "GameFontHighlight")
        dropDown.title:SetText(title)
        dropDown.title:SetTextColor(0.380, 0.705, 1, 1)
        dropDown.title:SetPoint("TOP", 0, 15)

        dropDown.bounds = bounds
        dropDown.onChangeFunc = onChangeFunc

        dropDown:SetPoint("BOTTOMLEFT", bounds, "BOTTOMLEFT", -10, 0)

        width = width or math.max(dropDown.title:GetWidth(), 40) + 10

        UIDropDownMenu_SetWidth(dropDown, width)
        UIDropDownMenu_SetText(dropDown, srslylawlUI.GetSetting(valuePath, true))

        bounds:SetSize(width + 30, dropDown:GetHeight() + 20)

        function dropDown:SetValue(newValue)
            UIDropDownMenu_SetText(dropDown, newValue)
            srslylawlUI.ChangeSetting(valuePath, newValue)
            if dropDown.onChangeFunc then
                dropDown:onChangeFunc(newValue)
            end
        end

        function dropDown:SetValueClean(newValue)
            UIDropDownMenu_SetText(dropDown, newValue)
        end

        UIDropDownMenu_Initialize(dropDown, function(self)
            local info = UIDropDownMenu_CreateInfo()
            info.func = self.SetValue
            for k, v in pairs(values) do
                local value = v or k
                info.text = value
                info.arg1 = value
                info.checked = function(self) return self.value == srslylawlUI.GetSetting(valuePath, true) end
                if onInitValueFunc then
                    onInitValueFunc(info, value)
                end
                -- info.disabled =
                UIDropDownMenu_AddButton(info)
            end
        end)

        table.insert(srslylawlUI.ConfigElements.Dropdowns, dropDown)

        function dropDown:Reset()
            local setting = srslylawlUI.GetSetting(valuePath, true)
            if UIDropDownMenu_GetText(self) == setting then return end
            self:SetValue(setting)
        end

        return dropDown
    end

    local function CreateFrameAnchorDropDown(title, parent, affectedFrame, valuePath, values, onChangeFunc)
        local bounds = CreateFrame("Frame", "$parent_" .. title .. "Bounds", parent)
        local dropDown = CreateFrame("FRAME", "$parent_" .. title, bounds, "UIDropDownMenuTemplate")
        dropDown.title = dropDown:CreateFontString("$parent_Title", "OVERLAY", "GameFontHighlight")
        dropDown.title:SetText(title)
        dropDown.title:SetTextColor(0.380, 0.705, 1, 1)
        dropDown.title:SetPoint("TOP", 0, 15)

        dropDown.bounds = bounds

        local validatedValues = {}
        --make sure we cant anchor to self
        for _, f in pairs(values) do
            if srslylawlUI.TranslateFrameAnchor(f) ~= affectedFrame then
                table.insert(validatedValues, f)
            end
        end

        local width = math.max(dropDown.title:GetWidth(), 40) + 10

        UIDropDownMenu_SetWidth(dropDown, width)
        UIDropDownMenu_SetText(dropDown, srslylawlUI.GetSetting(valuePath, true))

        bounds:SetSize(width + 30, dropDown:GetHeight() + 20)

        dropDown:SetPoint("BOTTOMLEFT", bounds, "BOTTOMLEFT", -10, 0)

        UIDropDownMenu_Initialize(dropDown, function(self)
            local info = UIDropDownMenu_CreateInfo()
            info.func = self.SetValue
            for k, v in pairs(validatedValues) do
                local value = v or srslylawlUI.TranslateFrameAnchor(k)
                info.text = value
                info.arg1 = value
                info.checked = function(self) return self.value == srslylawlUI.GetSetting(valuePath, true) end
                UIDropDownMenu_AddButton(info)
            end
        end)

        function dropDown:SetValue(newValue)
            UIDropDownMenu_SetText(dropDown, title)
            srslylawlUI.ChangeSetting(valuePath, newValue)
            if onChangeFunc then
                onChangeFunc()
            end
        end

        function dropDown:SetValueClean(newValue)
            UIDropDownMenu_SetText(dropDown, newValue)
        end

        table.insert(srslylawlUI.ConfigElements.Dropdowns, dropDown)

        function dropDown:Reset()
            local setting = srslylawlUI.GetSetting(valuePath, true)
            if UIDropDownMenu_GetText(self) == setting then return end
            self:SetValue(setting)
        end

        return dropDown
    end

    local function CreateConfigControl(parent, title, useFullWidth, unitToken)
        local bounds = CreateFrame("Frame", "$parent_Bounds", parent)
        local frame = CreateFrame("Frame", "$parent_" .. title, bounds, "BackdropTemplate")
        frame.bounds = bounds
        frame.useFullWidth = useFullWidth

        local inset = 10
        frame:SetPoint("TOPLEFT", bounds, "TOPLEFT", inset, -inset)
        frame:SetPoint("BOTTOMRIGHT", bounds, "BOTTOMRIGHT", -inset, inset)
        frame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        local color = unitToken and srslylawlUI.UnitToColor[unitToken] or { 0.796, 0.788, 0.564, .4 }
        frame:SetBackdropColor(unpack(color))
        frame.title = frame:CreateFontString("$parent_Title", "OVERLAY", "GameFontNormal")
        frame.title:SetText(title)
        frame.title:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 20, 0)

        frame.elements = {}
        frame.rowBounds = {}

        function frame:ResizeElements()
            local offset = 3
            local availableWidth = ceil(parent:GetWidth() - inset * 2)
            local totalWidth = 0
            local totalheight = 0

            local function GetRowBounds(index)
                if not self.rowBounds[index] then
                    self.rowBounds[index] = CreateFrame("Frame", "$parent_Row" .. index, self)

                    if index == 1 then
                        self.rowBounds[index]:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
                    else
                        self.rowBounds[index]:SetPoint("TOPLEFT", self.rowBounds[index - 1], "BOTTOMLEFT", 0, -offset)
                    end
                    self.rowBounds[index]:SetSize(availableWidth, 5)
                    self.rowBounds[index].height = 1
                    self.rowBounds[index].currentOffset = 10
                end

                return self.rowBounds[index]
            end

            local function AdjustRowBounds(index, height)
                local rB = GetRowBounds(index)

                if height > rB.height then
                    rB.height = height
                    rB:SetHeight(height)
                end
            end

            local currentWidth = inset
            local rowIndex = 1
            local r = GetRowBounds(rowIndex)
            r.height = 0
            r.currentOffset = inset
            for _, element in pairs(self.elements) do
                local elementWidth = element.bounds:GetWidth()
                local elementHeight = element.bounds:GetHeight()

                if not element.newRow and currentWidth + elementWidth + offset <= availableWidth then
                    --append to row
                    element.bounds:SetPoint("TOPLEFT", GetRowBounds(rowIndex), "TOPLEFT",
                        GetRowBounds(rowIndex).currentOffset + offset, 0)
                    currentWidth = currentWidth + elementWidth + offset
                    self.rowBounds[rowIndex].currentOffset = currentWidth
                    AdjustRowBounds(rowIndex, elementHeight)
                else
                    --new row
                    currentWidth = elementWidth + offset + inset
                    rowIndex = rowIndex + 1
                    local rB = GetRowBounds(rowIndex)
                    rB.currentOffset = inset
                    element.bounds:SetPoint("TOPLEFT", rB, "TOPLEFT", GetRowBounds(rowIndex).currentOffset + offset, 0)
                    rB.currentOffset = inset + elementWidth + offset
                    AdjustRowBounds(rowIndex, elementHeight)
                end
                totalWidth = currentWidth > totalWidth and currentWidth or totalWidth
            end

            for i = 1, rowIndex do
                totalheight = totalheight + self.rowBounds[i].height
            end
            local height = totalheight + (rowIndex + 2) * offset + inset * 2
            local w = self.useFullWidth and availableWidth or totalWidth + offset + inset * 2
            self.bounds:SetSize(w, height)
            self.totalHeight = height
            self:AddHeightToParent()
        end

        function frame:Add(...)
            for i = 1, select("#", ...) do
                local e = select(i, ...)
                if i == 1 and #self.elements > 0 then
                    e.newRow = true
                end
                table.insert(self.elements, #self.elements + 1, e)
            end
            self:ResizeElements()
        end

        function frame:SetSize(x, y)
            self.bounds:SetSize(x, y)
        end

        function frame:SetPoint(point1, parent, point2, x, y)
            self.bounds:SetPoint(point1, parent, point2, x, y)
        end

        function frame:AppendToControl(control, anchor)
            if not anchor or anchor == "BOTTOM" then
                self:SetPoint("TOPLEFT", control.bounds, "BOTTOMLEFT", 0, -10)
                self.totalHeight = self:GetHeight() + 10
                self:AddHeightToParent()
            elseif anchor == "RIGHT" then
                self:SetPoint("TOPLEFT", control.bounds, "TOPRIGHT", -10, 0)
                self.totalHeight = self:GetHeight()
            end
        end

        function frame:ChainToControl(control, anchor)
            if not anchor or anchor == "BOTTOM" then
                self:SetPoint("TOPLEFT", control.bounds, "BOTTOMLEFT", 0, 0)
            elseif anchor == "RIGHT" then
                self:SetPoint("TOPLEFT", control.bounds, "TOPRIGHT", 0, 0)
            end

            self.totalHeight = self:GetHeight()
        end

        function frame:AddHeightToParent()
            if not parent.controls then parent.controls = {} end
            parent.controls[self:GetName()] = self.totalHeight
        end

        frame:SetScript("OnHide", function(self)
            for _, v in pairs(frame.elements) do
                v:Hide()
            end
        end)
        frame:SetScript("OnShow", function(self)
            for _, v in pairs(frame.elements) do
                v:Show()
            end
        end)

        return frame
    end

    local function CreateConfigBody(name, parent)
        local f = CreateFrame("Frame", name, parent, "BackdropTemplate")
        f:SetSize(500, 500)
        f:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
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

        local function AddSpellByIDToToolTip(tooltipFrame, spellId)
            local data = C_TooltipInfo.GetSpellByID(spellId)
            if data then
                local tooltipInfo = { tooltipData = data, append = true };
                tooltipFrame:ProcessInfo(tooltipInfo);
                tooltipFrame:Show()
            end
        end

        local function OnEnter(self)
            srslylawlUI.customTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
            srslylawlUI.customTooltip:ClearLines()
            -- srslylawlUI.customTooltip:AddSpellByID(id)
            AddSpellByIDToToolTip(srslylawlUI.customTooltip, id)
        end

        local function OnUpdate(self)
            if srslylawlUI.customTooltip:IsOwned(self) then
                srslylawlUI.customTooltip:ClearLines()
                -- srslylawlUI.customTooltip:AddSpellByID(id)
                AddSpellByIDToToolTip(srslylawlUI.customTooltip, id)
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
        FauxScrollFrame_Update(frame, totalItems, maxButtons, buttonHeight, nil, nil, nil, nil, nil, nil, true)
        for line = 1, maxButtons do
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
                AddTooltip(curr, name .. "\nID: " .. spellId)
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
        local f = CreateFrame("Frame", "$parent_" .. name, parent, "BackdropTemplate")
        f:SetSize(500, 500)
        f:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
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
        local bounds = CreateFrame("Frame", "$parent_" .. nameWithoutSpace .. "_Bounds", parent)
        local checkButton = CreateFrame("CheckButton", "$parent_Button", bounds, "UICheckButtonTemplate")
        checkButton.bounds = bounds
        checkButton:SetPoint("LEFT", bounds, "LEFT", 0, 0)
        checkButton.text:SetTextColor(1, 1, 1, 1)
        checkButton.text:SetText(name)
        local w = checkButton:GetWidth() + checkButton.text:GetStringWidth()
        local h = checkButton:GetHeight()
        bounds:SetSize(w, h + 10)

        function checkButton:SetPoint(...)
            self.bounds:SetPoint(...)
        end

        return checkButton
    end

    local function CreateSettingsCheckButton(name, parent, valuePath, funcOnChanged, canBeNil)
        local nameWithoutSpace = name:gsub(" ", "_")
        local bounds = CreateFrame("Frame", "$parent_" .. nameWithoutSpace .. "_Bounds", parent)
        local checkButton = CreateFrame("CheckButton", "$parent_Button", bounds, "UICheckButtonTemplate")
        checkButton.bounds = bounds
        checkButton:SetPoint("LEFT", bounds, "LEFT", 0, 0)
        checkButton.text:SetTextColor(1, 1, 1, 1)
        table.insert(srslylawlUI.ConfigElements.CheckButtons, checkButton)
        checkButton.text:SetText(name)
        local w = checkButton:GetWidth() + checkButton.text:GetStringWidth()
        local h = checkButton:GetHeight()
        bounds:SetSize(w, h + 10)
        checkButton:SetChecked(srslylawlUI.GetSetting(valuePath, canBeNil))
        checkButton:SetScript("OnClick", function(self)
            srslylawlUI.ChangeSetting(valuePath, self:GetChecked())
            if funcOnChanged then
                funcOnChanged(self)
            end
        end)
        function checkButton:Reset()
            local setting = srslylawlUI.GetSetting(valuePath, canBeNil) or false
            if self:GetChecked() == setting then return end
            self:SetChecked(setting)
            if funcOnChanged then
                funcOnChanged(self)
            end
        end

        return checkButton
    end

    local function CreateSaveLoadButtons(frame)
        -- Save Button
        frame.SaveButton = CreateFrame("Button", "srslylawlUI_Config_SaveButton", srslylawlUI_ConfigFrame,
            "UIPanelButtonTemplate")
        local s = frame.SaveButton
        s:SetPoint("TOPRIGHT", -5, -30)
        s:SetText("Save")
        s:SetScript("OnClick", function(self) srslylawlUI.SaveSettings() end)
        s:SetWidth(60)
        table.insert(srslylawlUI.unsaved.buttons, s)

        -- Load Button
        frame.LoadButton = CreateFrame("Button", "srslylawlUI_Config_LoadButton", srslylawlUI_ConfigFrame,
            "UIPanelButtonTemplate")
        local l = frame.LoadButton
        l:SetPoint("TOPRIGHT", s, "TOPLEFT")
        l:SetText("Load")
        l:SetScript("OnClick", function(self) srslylawlUI.LoadSettings(true, true) end)
        l:SetWidth(60)
        table.insert(srslylawlUI.unsaved.buttons, l)
        l:Disable()
        s:Disable()
        frame.CloseButton = CreateFrame("Button", "srslylawlUI_Config_CloseButton", srslylawlUI_ConfigFrame,
            "UIPanelCloseButton")
        local c = frame.CloseButton
        c:SetPoint("TOPRIGHT", 0, 0)
    end

    local function CreateAnchoringPanel(parent, path, frame, frameAnchorTable, simple)
        local elements = {}
        if not simple then
            function Reanchor()
                frame:ClearAllPoints()
                local anchors = srslylawlUI.GetSetting(path)
                anchors[2] = srslylawlUI.TranslateFrameAnchor(anchors[2])
                srslylawlUI.Utils_SetPointPixelPerfect(frame, unpack(anchors))
            end

            elements[1] = CreateCustomDropDown("Point", 100, parent, path .. ".1", srslylawlUI.anchorTable, Reanchor)
            elements[2] = CreateFrameAnchorDropDown("To Frame", parent, frame, path .. ".2",
                frameAnchorTable or srslylawlUI.FramesToAnchorTo, Reanchor)
            elements[3] = CreateCustomDropDown("Relative To", 100, parent, path .. ".3", srslylawlUI.anchorTable,
                Reanchor)
            elements[4] = CreateCustomSlider("X Offset", parent, -2000, 2000, path .. ".4", 1, 0, Reanchor)
            elements[5] = CreateCustomSlider("Y Offset", parent, -2000, 2000, path .. ".5", 1, 0, Reanchor)

            function frame:ResetAnchoringPanel(...)
                local e1, e2, e3, e4, e5 = ...
                elements[1]:SetValueClean(e1)
                elements[2]:SetValueClean(e2)
                elements[3]:SetValueClean(e3)
                elements[4]:SetValueClean(e4)
                elements[5]:SetValueClean(e5)
            end
        else
            function Reanchor()
                frame:ClearAllPoints()
                local anchors = srslylawlUI.GetSetting(path)
                srslylawlUI.Utils_SetPointPixelPerfect(frame, unpack(anchors))
            end

            elements[1] = CreateCustomDropDown("Point", 100, parent, path .. ".1", srslylawlUI.anchorTable, Reanchor)
            elements[2] = CreateCustomSlider("X Offset", parent, -2000, 2000, path .. ".2", 1, 0, Reanchor)
            elements[3] = CreateCustomSlider("Y Offset", parent, -2000, 2000, path .. ".3", 1, 0, Reanchor)

            function frame:ResetAnchoringPanel(...)
                local e1, _, _, e4, e5 = ...
                elements[1]:SetValueClean(e1)
                elements[2]:SetValueClean(e4)
                elements[3]:SetValueClean(e5)
            end
        end
        return elements
    end

    local function FillGeneralTab(tab)
        local partyVisibility = CreateConfigControl(tab, "Party Frames Visibility", nil, "party")
        partyVisibility:SetPoint("TOPLEFT", tab, "TOPLEFT", 0, -15)

        local showParty = CreateSettingsCheckButton("Party", tab, "party.visibility.showParty",
            function() srslylawlUI.Frame_UpdateVisibility() end)
        AddTooltip(showParty, "Show Frames while in a Party")

        local showPlayer = CreateSettingsCheckButton("Show Player", tab, "party.visibility.showPlayer",
            function() srslylawlUI.Frame_UpdateVisibility() srslylawlUI.SortPartyFrames() srslylawlUI.Frame_ResizeHealthBarScale() end)
        AddTooltip(showPlayer, "Show Player as Party Member (recommended)")

        local showSolo = CreateSettingsCheckButton("Solo", tab, "party.visibility.showSolo",
            function() srslylawlUI.Frame_UpdateVisibility() srslylawlUI.SortPartyFrames() srslylawlUI.Frame_ResizeHealthBarScale() end)
        AddTooltip(showSolo, "Show Party with Player as sole member while not in a group (implies Show Player)")

        local showArena = CreateSettingsCheckButton("Arena", tab, "party.visibility.showArena",
            function() srslylawlUI.Frame_UpdateVisibility() end)
        AddTooltip(showArena, "Show Frames in Arena")

        local showRaid = CreateSettingsCheckButton("Raid", tab, "party.visibility.showRaid",
            function() srslylawlUI.Frame_UpdateVisibility() end)
        AddTooltip(showRaid, "Show Party-Frames while in a Raid (not recommended)")

        partyVisibility:Add(showParty, showPlayer, showSolo, showArena, showRaid)

        local partySorting = CreateConfigControl(tab, "Party Frames Sorting", nil, "party")
        local sortingEnabled = CreateSettingsCheckButton("Enabled", tab, "party.sorting.enabled",
            function() srslylawlUI.SortPartyFrames() end)
        local sortInfoBox = CreateInfoBox(partySorting,
            "If enabled, party members will be sorted by their maximum hp, descending. This means that the highest hp party member will always be the first frame."
            , 600)
        partySorting:Add(sortInfoBox, sortingEnabled)
        partySorting:ChainToControl(partyVisibility)

        local anchor = partySorting

        for _, unit in pairs({ "Party", "Player", "Target", "Focus" }) do
            local cap = unit
            unit = string.lower(unit)
            local path = unit == "party" and "party." or "player." .. unit .. "Frame."

            local buffVisibility = CreateConfigControl(tab, cap .. " Buff Visibility", nil, unit)
            buffVisibility:AppendToControl(anchor)

            local buffsDefault = CreateSettingsCheckButton("Default", tab, path .. "buffs.showDefault",
                function() srslylawlUI.Party_HandleAuras_ALL() srslylawlUI.Main_HandleAuras_ALL() end)
            if unit == "party" then
                AddTooltip(buffsDefault,
                    "Show/hide all buffs per default, except if they are in/excluded by another setting.\n\nRecommended: Hiding all per default, while showing defensives and whitelisted auras.")
            else
                AddTooltip(buffsDefault,
                    "Show/hide all buffs per default, except if they are in/excluded by another setting.")
            end
            local buffsDefensive = CreateSettingsCheckButton("Defensives", tab, path .. "buffs.showDefensives",
                function() srslylawlUI.Party_HandleAuras_ALL() srslylawlUI.Main_HandleAuras_ALL() end)
            AddTooltip(buffsDefensive, "Show/hide buffs categorized as Defensives")

            local buffsPlayer = CreateSettingsCheckButton("Cast by Player", tab, path .. "buffs.showCastByPlayer",
                function() srslylawlUI.Party_HandleAuras_ALL() srslylawlUI.Main_HandleAuras_ALL() end)
            AddTooltip(buffsPlayer, "Show/hide buffs that have been applied by the Player")

            local buffsInfinite = CreateSettingsCheckButton("Infinite Duration", tab, path ..
                "buffs.showInfiniteDuration",
                function() srslylawlUI.Party_HandleAuras_ALL() srslylawlUI.Main_HandleAuras_ALL() end)
            AddTooltip(buffsInfinite, "Show/hide buffs with no expiration time")

            local buffsLong = CreateSettingsCheckButton("Long Duration", tab, path .. "buffs.showLongDuration",
                function() srslylawlUI.Party_HandleAuras_ALL() srslylawlUI.Main_HandleAuras_ALL() end)
            AddTooltip(buffsLong, "Show/hide buffs with a base duration longer than 60 seconds")

            buffVisibility:Add(buffsDefault, buffsDefensive, buffsPlayer, buffsInfinite, buffsLong)

            local debuffVisibility = CreateConfigControl(tab, cap .. " Debuff Visibility", nil, unit)
            debuffVisibility:ChainToControl(buffVisibility)

            local debuffsDefault = CreateSettingsCheckButton("Default", tab, path .. "debuffs.showDefault",
                function() srslylawlUI.Party_HandleAuras_ALL() srslylawlUI.Main_HandleAuras_ALL() end)
            AddTooltip(debuffsDefault,
                "Show/hide all debuffs per default, except if they are in/excluded by another setting.\n\nRecommended: Showing all per default, while hiding infinite duration auras")

            local debuffsPlayer = CreateSettingsCheckButton("Cast by Player", tab, path .. "debuffs.showCastByPlayer",
                function() srslylawlUI.Party_HandleAuras_ALL() srslylawlUI.Main_HandleAuras_ALL() end)
            AddTooltip(debuffsPlayer, "Show/hide debuffs that have been applied by the Player")

            local debuffsInfinite = CreateSettingsCheckButton("Infinite Duration", tab,
                path .. "debuffs.showInfiniteDuration",
                function() srslylawlUI.Party_HandleAuras_ALL() srslylawlUI.Main_HandleAuras_ALL() end)
            AddTooltip(debuffsInfinite, "Show/hide debuffs with no expiration time")

            local debuffsLong = CreateSettingsCheckButton("Long Duration", tab, path .. "debuffs.showLongDuration",
                function() srslylawlUI.Party_HandleAuras_ALL() srslylawlUI.Main_HandleAuras_ALL() end)
            AddTooltip(debuffsLong, "Show/hide buffs with a base duration longer than 180 seconds")

            debuffVisibility:Add(debuffsDefault, debuffsPlayer, debuffsInfinite, debuffsLong)

            anchor = debuffVisibility
        end

        local showBlizzardFrames = CreateConfigControl(tab, "Show Blizzard Frames (requires UI reload)")
        showBlizzardFrames:AppendToControl(anchor)

        local player = CreateSettingsCheckButton("Player Frame", tab, "blizzard.player.enabled", nil)

        local target = CreateSettingsCheckButton("Target Frame", tab, "blizzard.target.enabled", nil)

        local party = CreateSettingsCheckButton("Party Frames", tab, "blizzard.party.enabled", nil)

        local auras = CreateSettingsCheckButton("Auras", tab, "blizzard.auras.enabled", nil)

        local castbar = CreateSettingsCheckButton("Castbar", tab, "blizzard.castbar.enabled", nil)

        local focus = CreateSettingsCheckButton("Focus", tab, "blizzard.focus.enabled", nil)

        local boss = CreateSettingsCheckButton("Boss Frames", tab, "blizzard.boss.enabled", nil)
        AddTooltip(boss,
            "Boss Frames are special frames that exist only in boss encounters, such as in raids or some dungeons and scenarios.")

        showBlizzardFrames:Add(player, target, party, auras, castbar, focus, boss)

        local other = CreateConfigControl(tab, "Other")
        other:AppendToControl(showBlizzardFrames)

        local enableAnnouncements = CreateSettingsCheckButton("Addon Announcements", tab, "announcements", nil)
        AddTooltip(enableAnnouncements,
            "Enable/Disable the addon printing anything to the chat.\nExamples include: Successful save/load, learning a new defensive/absorb spell, errors, etc.")
        other:Add(enableAnnouncements)

        local h = 0
        for _, v in pairs(tab.controls) do
            h = h + v
        end

        tab:SetHeight(h)
    end

    local function FillPartyFramesTab(tab)
        local path = "party."
        --party health bars
        local healthControl = CreateConfigControl(tab, "Party Health", nil, "party")
        healthControl:SetPoint("TOPLEFT", tab, "TOPLEFT", 0, -15)

        local hpWidth = CreateCustomSlider("Maximum Width", tab, 1, 3000, path .. "hp.width", 1, 0,
            srslylawlUI.UpdateEverything)
        local hpHeight = CreateCustomSlider("Height", tab, 1, 2000, path .. "hp.height", 1, 0,
            srslylawlUI.UpdateEverything)
        local minWidthPercent = CreateCustomSlider("Minimum Width %", tab, .01, 1, path .. "hp.minWidthPercent", .01, 2,
            srslylawlUI.UpdateEverything)
        AddTooltip(minWidthPercent, "Minimum percent of Max Width a bar can be scaled to. Default: 0.55")
        local fontSize = CreateCustomSlider("FontSize", tab, 0.5, 100, path .. "hp.fontSize", 0.5, 1,
            srslylawlUI.UpdateEverything)
        local absorbHeight = CreateCustomSlider("Absorb Frame Height %", tab, 0.1, 1, path .. "hp.absorbHeightPercent",
            0.05, 2, srslylawlUI.Party_HandleAuras_ALL)
        local reverseFill = CreateSettingsCheckButton("Reverse fill direction", tab, "party.hp.reversed",
            srslylawlUI.Frame_UpdatePartyHealthBarAlignment)
        local partyAnchors = CreateAnchoringPanel(tab, "party.header.position", srslylawlUI_PartyHeader)
        healthControl:Add(hpWidth, hpHeight, minWidthPercent, fontSize, reverseFill, absorbHeight)
        healthControl:Add(unpack(partyAnchors))

        --raidIcon
        local raidIconControl = CreateConfigControl(tab, "Party Raid Icon", nil, "party")
        local raidEnable = CreateSettingsCheckButton("Enable", tab, path .. "raidIcon.enabled",
            function(self) for _, unit in pairs(srslylawlUI.partyUnits) do unit.unitFrame.unit.RaidIcon:SetEnabled(self:
                        GetChecked())
                end
            end)
        local raidAnchor = CreateCustomDropDown("Point", 100, tab, path .. "raidIcon.position.1", srslylawlUI.anchorTable
            , srslylawlUI.Frame_Party_ResetDimensions_ALL)
        local raidX = CreateCustomSlider("X Offset", tab, -2000, 2000, path .. "raidIcon.position.2", 1, 0,
            srslylawlUI.Frame_Party_ResetDimensions_ALL)
        local raidY = CreateCustomSlider("Y Offset", tab, -2000, 2000, path .. "raidIcon.position.3", 1, 0,
            srslylawlUI.Frame_Party_ResetDimensions_ALL)
        local raidSize = CreateCustomSlider("Size", tab, 1, 100, path .. "raidIcon.size", 1, 0,
            srslylawlUI.Frame_Party_ResetDimensions_ALL)
        raidIconControl:Add(raidEnable, raidSize, raidAnchor, raidX, raidY)
        raidIconControl:ChainToControl(healthControl)

        --party powerbars
        local powerBars = CreateConfigControl(tab, "Party Power", nil, "party")
        powerBars:ChainToControl(raidIconControl)
        local powerBarWidth = CreateCustomSlider("Width", tab, 1, 100, path .. "power.width", 1, 0,
            srslylawlUI.Frame_Party_ResetDimensions_ALL)
        local showText = CreateSettingsCheckButton("Show Text", tab, "party.power.text",
            function() for _, unit in pairs(srslylawlUI.partyUnitsTable) do srslylawlUI.Frame_ResetUnitButton(srslylawlUI
                        .partyUnits[unit].unitFrame.unit, unit)
                end
            end)
        powerBars:Add(powerBarWidth, showText)

        --party petbars
        local petBars = CreateConfigControl(tab, "Party Pet", nil, "party")
        petBars:ChainToControl(powerBars, "RIGHT")
        local petEnable = CreateSettingsCheckButton("Enable", tab, path .. "pet.enabled",
            function() for _, unit in pairs(srslylawlUI.partyUnitsTable) do srslylawlUI.srslylawlUI.Frame_ResetPetButton(srslylawlUI
                        .partyUnits[unit].unitFrame.unit, unit)
                end
            end)
        local petBarWidth = CreateCustomSlider("Width", tab, 1, 100, path .. "pet.width", 1, 0,
            srslylawlUI.Frame_Party_ResetDimensions_ALL)
        petBars:Add(petEnable, petBarWidth)

        --cc bar
        local ccBars = CreateConfigControl(tab, "Party Crowd Control", nil, "party")
        ccBars:ChainToControl(powerBars)
        local ccBarEnabled = CreateSettingsCheckButton("Enabled", tab, path .. "ccbar.enabled",
            srslylawlUI.Frame_Party_ResetDimensions_ALL)
        local ccBarWidth = CreateCustomSlider("Width", tab, 1, 1000, path .. "ccbar.width", 1, 0,
            srslylawlUI.Frame_Party_ResetDimensions_ALL)
        local ccBarHeight = CreateCustomSlider("Height %", tab, .01, 1, path .. "ccbar.heightPercent", .01, 2,
            srslylawlUI.Frame_Party_ResetDimensions_ALL)
        local ccBarReverseFill = CreateSettingsCheckButton("Reverse fill direction", tab, path .. "ccbar.reversed",
            srslylawlUI.Frame_Party_ResetDimensions_ALL)

        AddTooltip(ccBarHeight, "Percentage of HP Bar height")
        ccBars:Add(ccBarEnabled, ccBarWidth, ccBarHeight, ccBarReverseFill)

        local anchor = ccBars
        local function ResetAuraAll()
            for _, unit in pairs(srslylawlUI.partyUnitsTable) do
                srslylawlUI.SetAuraPointsAll(unit, "partyUnits")
            end
        end

        for i = 1, 2 do
            local path = "party."
            local anchorTable = i == 1 and { "Frame", "Debuffs" } or { "Frame", "Buffs" }
            local aType = i == 1 and "buff" or "debuff"
            local typeCap = i == 1 and "Buff" or "Debuff"
            local auraControl = CreateConfigControl(tab, "Party " .. typeCap .. " Frames", nil, "party")
            auraControl:SetPoint("TOPLEFT", anchor.bounds, "BOTTOMLEFT", 0, 0)
            local pointOnInitValueFunc = function(info, value)
                if i == 1 then
                    --Is Buff Anchor
                    --Disable button if Debuff Anchor is anchored to buffs
                    local debuffAnchorPoint = srslylawlUI.GetSetting(path .. "debuff" .. "s.anchoredTo", true)
                    if value == "Debuffs" then
                        info.disabled = debuffAnchorPoint == "Buffs"
                    end
                else
                    --Is Debuff Anchor
                    --Disable button if Buff Anchor is anchored to debuffs
                    local buffAnchorPoint = srslylawlUI.GetSetting(path .. "buff" .. "s.anchoredTo", true)
                    if value == "Buffs" then
                        info.disabled = buffAnchorPoint == "Debuffs"
                    end
                end
            end
            local frameAnchor = CreateCustomDropDown("Anchor To", 100, tab, path .. aType .. "s.anchoredTo", anchorTable
                , nil, pointOnInitValueFunc)
            local auraAnchor = CreateCustomDropDown("AnchorPoint", 100, tab, path .. aType .. "s.anchor",
                srslylawlUI.auraSortMethodTable, function() ResetAuraAll() end)
            --disabling the auraanchor dropdown, should we anchor to other auratype
            local onChanged = function(self, newValue)
                ResetAuraAll()
                if newValue ~= "Frame" then
                    UIDropDownMenu_DisableDropDown(auraAnchor)
                else
                    UIDropDownMenu_EnableDropDown(auraAnchor)
                end
            end
            frameAnchor.onChangeFunc = onChanged
            if srslylawlUI.GetSetting(path .. aType .. "s.anchoredTo") ~= "Frame" then
                UIDropDownMenu_DisableDropDown(auraAnchor)
            end
            local maxAuras = CreateCustomSlider("Max " .. typeCap .. "s", tab, 0, 40, path ..
                aType .. "s.max" .. typeCap .. "s", 1, 0, function()
                for _, unit in pairs(srslylawlUI.partyUnitsTable) do
                    srslylawlUI.CreateBuffFrames(srslylawlUI.partyUnits[unit].unitFrame, unit)
                end
                ResetAuraAll()
                srslylawlUI.Party_HandleAuras_ALL()
            end)
            local auraSize = CreateCustomSlider("Size", tab, 0, 200, path .. aType .. "s.size", 1, 0, function()
                srslylawlUI.Party_HandleAuras_ALL()
                ResetAuraAll()
            end)
            local xOffset = CreateCustomSlider("X Offset", tab, -500, 500, path .. aType .. "s.xOffset", 1, 0,
                ResetAuraAll)
            local yOffset = CreateCustomSlider("Y Offset", tab, -500, 500, path .. aType .. "s.yOffset", 1, 0,
                ResetAuraAll)
            auraControl:Add(frameAnchor, auraAnchor, xOffset, yOffset, auraSize, maxAuras)
            anchor = auraControl
        end

        --portrait
        local portraitControl = CreateConfigControl(tab, "Party Portrait", nil, "party")
        local portraitEnabled = CreateSettingsCheckButton("Enabled", tab, path .. "portrait.enabled",
            function() for _, unit in pairs(srslylawlUI.partyUnits) do unit.unitFrame:TogglePortrait() end end)
        local portraitPosition = CreateCustomDropDown("Position", 100, tab, path .. "portrait.position",
            { "LEFT", "RIGHT" },
            function() for _, unit in pairs(srslylawlUI.partyUnits) do unit.unitFrame:TogglePortrait() end end)
        local portraitAnchor = CreateCustomDropDown("Anchor", 100, tab, path .. "portrait.anchor",
            { "Frame", "Powerbar" }
            , function() for _, unit in pairs(srslylawlUI.partyUnits) do unit.unitFrame:TogglePortrait() end end)
        portraitControl:Add(portraitEnabled, portraitPosition, portraitAnchor)
        portraitControl:ChainToControl(anchor)

        --combaticon
        local combatIconControl = CreateConfigControl(tab, "Party Combat Icon", nil, "party")
        local combatIconEnabled = CreateSettingsCheckButton("Enabled", tab, path .. "combatRestIcon.enabled",
            srslylawlUI.Frame_Party_ResetDimensions_ALL)
        local combatIconSize = CreateCustomSlider("Size", tab, 1, 200, path .. "combatRestIcon.size", 1, 0,
            srslylawlUI.Frame_Party_ResetDimensions_ALL)
        local combatIconAnchor = CreateCustomDropDown("Point", 100, tab, path .. "combatRestIcon.position.1",
            srslylawlUI.anchorTable, srslylawlUI.Frame_Party_ResetDimensions_ALL)
        local combatIconX = CreateCustomSlider("X Offset", tab, -2000, 2000, path .. "combatRestIcon.position.2", 1, 0,
            srslylawlUI.Frame_Party_ResetDimensions_ALL)
        local combatIconY = CreateCustomSlider("Y Offset", tab, -2000, 2000, path .. "combatRestIcon.position.3", 1, 0,
            srslylawlUI.Frame_Party_ResetDimensions_ALL)
        combatIconControl:Add(combatIconEnabled, combatIconSize, combatIconAnchor, combatIconX, combatIconY)
        combatIconControl:ChainToControl(portraitControl)

        local h = 0
        for _, v in pairs(tab.controls) do
            h = h + v
        end

        tab:SetHeight(h)
    end

    local function Tab_OnClick(self)
        local parent = self:GetParent()
        parent.selectedTab = self:GetID()
        -- PanelTemplates_SetTab(parent, self:GetID())
        self:SetSelected(true)
        self:OnSelected(true)
        self.content:Show()

        for k, tab in ipairs(parent.Tabs) do
            if tab:GetID() ~= parent.selectedTab then
                if tab.selected then
                    tab:SetSelected(false)
                    tab.content:Hide()
                end
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
            tab = CreateFrame("Button", "$parent_Tab" .. n, frame, "MinimalTabTemplate")

            -- frame.Tabs:AddButton(tab)
            tab:SetID(i)
            tab.Text:SetText(n)
            tab:SetScript("OnClick", Tab_OnClick)

            -- local width = tab:GetWidth()
            PanelTemplates_TabResize(tab, 10, nil, width)
            tab.content = CreateFrame("Frame", "$parent_" .. n .. "Content", frame)
            tab.content:SetAllPoints()
            tab.content:Hide()
            tab.content.tabButton = tab

            frame.Tabs[i] = tab
            table.insert(contents, tab.content)

            if i == 1 then
                tab:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 5, -1)
            else
                tab:SetPoint("BOTTOMLEFT", frame.Tabs[i - 1], "BOTTOMRIGHT", 5, 0)
            end
        end

        -- frame.Tabs:SelectAtIndex(1);


        Tab_OnClick(frame.Tabs[1])

        return unpack(contents)
    end

    local function GenerateSpellList(spellListKey, filter, auraType)
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

        spellList = srslylawlUI_Saved[auraType][spellListKey]


        if spellList == nil then
            srslylawlUI.Log("spell list nil " .. spellListKey .. " " .. auraType .. " Generating new...")
            srslylawlUI_Saved[auraType][spellListKey] = {}
            return
        end
        -- sort list
        local sortedSpellList = {}
        local exactMatch = nil
        for spellId, _ in pairs(spellList) do
            local name, _, icon = GetSpellInfo(spellId)
            if name == nil then
                --spell was probably removed from game or file is corrupted, remove spell from list
                srslylawlUI_Saved[auraType][spellListKey][spellId] = nil
                srslylawlUI.Log("Spell with ID " ..
                    spellId ..
                    " no longer recognized by WoW client. Might have been removed - removing from saved variables.")
            else

                local spell = { name = name, spellId = spellId, icon = icon }
                if tostring(spellId) == tostring(filter) then
                    exactMatch = spell
                elseif startsWith(name, filter) or startsWith(spellId, filter) or contains(name, filter) then
                    table.insert(sortedSpellList, spell)
                end
            end
        end

        table.sort(sortedSpellList, function(a, b) return b.name > a.name end)

        if exactMatch ~= nil then
            table.insert(sortedSpellList, 1, exactMatch)
        end

        srslylawlUI.sortedSpellLists[auraType][spellListKey] = sortedSpellList
    end

    local function OpenSpellAttributePanel(parentTab, spellId)
        --auraType "buffs" or "debuffs"
        local function SetEnableButtons(attributePanel, auraType, checked)
            if auraType == "buffs" then
                attributePanel.isDefensive:SetEnabled(not checked)
                attributePanel.DefensiveAmount:SetEnabled(not attributePanel.AutoDetectDefensiveAmount:GetChecked())
                attributePanel.isAbsorb:SetEnabled(not checked)
                attributePanel.DefensiveAmount:SetShown(attributePanel.isDefensive:GetChecked())
                attributePanel.AutoDetectDefensiveAmount:SetShown(attributePanel.isDefensive:GetChecked())
            elseif auraType == "debuffs" then
                if (checked) then
                    UIDropDownMenu_DisableDropDown(attributePanel.CCType)
                else
                    UIDropDownMenu_EnableDropDown(attributePanel.CCType)
                end
            end
        end

        local function CreatePanel(parentTab, auraType)
            local attributePanel = CreateFrame("Frame", "$parent_AttributePanel", parentTab, "BackdropTemplate")
            parentTab:GetParent().AttributePanel = attributePanel --make the attribute panel unique to the auratype buff
            attributePanel:SetBackdrop(
                {
                    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                    edgeSize = 10,
                    insets = { left = 4, right = 4, top = 4, bottom = 4 }
                })
            attributePanel:SetBackdropColor(1, 1, 1, .4)

            local function ButtonCheckFunction(auraType, category, attribute)
                return function(self)
                    local panel = self.bounds:GetParent()
                    local id = panel:GetAttribute("spellId")
                    local checked = self:GetChecked()

                    srslylawlUI_Saved[auraType].known[id][attribute] = checked

                    if checked then
                        srslylawlUI_Saved[auraType][category][id] = srslylawlUI_Saved[auraType].known[id]

                        --remove from opposite list
                        if category == "whiteList" then
                            srslylawlUI_Saved[auraType].blackList[id] = nil
                            panel.isBlacklisted:SetChecked(not checked)
                        elseif category == "blackList" then
                            srslylawlUI_Saved[auraType].whiteList[id] = nil
                            panel.isWhitelisted:SetChecked(not checked)
                        end
                    else
                        srslylawlUI_Saved[auraType][category][id] = nil
                    end



                    --refresh buttons to reflect new list
                    parentTab:GetParent():Hide()
                    parentTab:GetParent():Show()
                    srslylawlUI.Party_HandleAuras_ALL()
                    srslylawlUI.Main_HandleAuras_ALL()
                end
            end

            attributePanel.SpellIconFrame = CreateFrame("Frame", "$parent_SpellIconFrame", attributePanel)
            attributePanel.SpellIconFrame:SetSize(75, 75)
            attributePanel.SpellIconFrame:SetPoint("TOPLEFT", attributePanel, "TOPLEFT", 5, -5)
            attributePanel.SpellIcon = attributePanel.SpellIconFrame:CreateTexture("$parent_SpellIcon")
            attributePanel.SpellIcon:SetAllPoints(true)


            attributePanel.SpellName = attributePanel:CreateFontString("$parent_SpellName", "OVERLAY",
                "GameFontGreenLarge")
            attributePanel.SpellName:SetPoint("LEFT", attributePanel.SpellIcon, "RIGHT", 15, 0)

            attributePanel.isWhitelisted = CreateCheckButton("Whitelisted", attributePanel)
            attributePanel.isWhitelisted:SetScript("OnClick", ButtonCheckFunction(auraType, "whiteList", "isWhitelisted"))
            attributePanel.isWhitelisted:SetPoint("TOPLEFT", attributePanel.SpellIcon, "BOTTOMLEFT", 5, -5)

            attributePanel.isBlacklisted = CreateCheckButton("Blacklisted", attributePanel)
            attributePanel.isBlacklisted:SetScript("OnClick", ButtonCheckFunction(auraType, "blackList", "isBlacklisted"))
            attributePanel.isBlacklisted:SetPoint("TOPLEFT", attributePanel.isWhitelisted, "BOTTOMLEFT")

            attributePanel.AutoDetect = CreateCheckButton("Auto-Detect settings", attributePanel)
            attributePanel.AutoDetect:SetPoint("TOPLEFT", attributePanel.isBlacklisted, "BOTTOMLEFT")

            AddTooltip(attributePanel.AutoDetect,
                "Automatically detect if spell has damage reduction or absorb, based on spell tooltip.\nThis will automatically detect if, for example, a rogue has skilled his feint.\nDisable this if auto settings aren't accurate for this spell, recommended for non-english language clients")
            attributePanel.AutoDetect:SetScript("OnClick", function(self)
                local id = self.bounds:GetParent():GetAttribute("spellId")
                local checked = self:GetChecked()

                srslylawlUI_Saved[auraType].known[id].autoDetect = checked

                SetEnableButtons(attributePanel, auraType, checked)
            end)

            attributePanel.LastParsedText = CreateFrame("Frame", "$parent_LastParsedText", attributePanel)
            attributePanel.LastParsedText.title = attributePanel.LastParsedText:CreateFontString("$parent_Title",
                "OVERLAY", "GameFontNormal")
            attributePanel.LastParsedText.title:SetText("<last seen tooltip>")

            attributePanel.LastParsedText:SetPoint("TOPRIGHT", attributePanel, "TOPRIGHT")
            attributePanel.LastParsedText:SetPoint("BOTTOMLEFT", attributePanel, "TOPRIGHT",
                -attributePanel.LastParsedText.title:GetStringWidth() - 5,
                -attributePanel.LastParsedText.title:GetStringHeight() - 5)
            attributePanel.LastParsedText.title:ClearAllPoints(true)
            attributePanel.LastParsedText.title:SetPoint("CENTER")

            if auraType == "buffs" then
                attributePanel.isDefensive = CreateCheckButton("is Defensive effect", attributePanel)
                attributePanel.isDefensive:SetPoint("TOPLEFT", attributePanel.AutoDetect, "BOTTOMRIGHT", -5, 0)
                attributePanel.isDefensive:SetScript("OnClick",
                    ButtonCheckFunction(auraType, "defensives", "isDefensive"))
                AddTooltip(attributePanel.isDefensive,
                    "Does this buff provide % damage reduction?\nDisabling this will stop the effect from being used in effective health calculations")

                attributePanel.DefensiveAmount = CreateCustomEditBox(attributePanel, "Reduction Amount")
                attributePanel.DefensiveAmount:SetNumeric(true)
                attributePanel.DefensiveAmount.bounds:SetPoint("LEFT", attributePanel.isDefensive.text, "RIGHT")
                attributePanel.DefensiveAmount:SetScript("OnEnterPressed", function(self)
                    local amount = self:GetNumber();
                    local id = self.bounds:GetParent():GetAttribute("spellId")
                    local old = srslylawlUI_Saved.buffs.known[id].reductionAmount
                    srslylawlUI_Saved.buffs.known[id].reductionAmount = amount
                    srslylawlUI_Saved.buffs.defensives[id] = srslylawlUI_Saved.buffs.known[id]

                    srslylawlUI_Saved.buffs.known[id].reductionAmount = amount
                    srslylawlUI_Saved.buffs.defensives[id] = srslylawlUI_Saved.buffs.known[id]

                    if old then
                        srslylawlUI.Log("Damage reduction amount for spell " ..
                            GetSpellInfo(id) .. " set from " .. old .. "% to " .. amount .. "%!")
                    else
                        srslylawlUI.Log("Damage reduction amount for spell " ..
                            GetSpellInfo(id) .. " set to " .. amount .. "%!")
                    end
                end)
                AddTooltip(attributePanel.DefensiveAmount,
                    "Set custom damage reduction effect (per stack) in % and confirm with [ENTER]-Key.\n(For example: Enter 15 for 15% damage reduction)\n\nSetting this to 100 will cause this spell to be treated as an immunity")

                attributePanel.AutoDetectDefensiveAmount = CreateCheckButton("Auto-Detect amount", attributePanel)
                attributePanel.AutoDetectDefensiveAmount.bounds:SetPoint("LEFT", attributePanel.DefensiveAmount.bounds,
                    "RIGHT")
                attributePanel.AutoDetectDefensiveAmount:SetScript("OnClick", function(self)
                    local id = self.bounds:GetParent():GetAttribute("spellId")
                    local checked = self:GetChecked()
                    srslylawlUI_Saved[auraType].known[id].autoDetectAmount = checked
                    SetEnableButtons(attributePanel, auraType, attributePanel.AutoDetect:GetChecked())
                end)
                AddTooltip(attributePanel.AutoDetectDefensiveAmount,
                    "Auto-detecting the defensive amount is recommended for most spells, however, some spells with multiple reduction values are inconsistent to parse.\nFor such spells, such as Feint or Die by the Sword, I'd recommend setting a custom value.")


                attributePanel.isAbsorb = CreateCheckButton("is Absorb effect", attributePanel)
                attributePanel.isAbsorb:SetPoint("TOPLEFT", attributePanel.isDefensive, "BOTTOMLEFT")
                attributePanel.isAbsorb:SetScript("OnClick", ButtonCheckFunction(auraType, "absorbs", "isAbsorb"))
                AddTooltip(attributePanel.isAbsorb,
                    "Does this buff provide damage absorption?\nDisabling this will stop the effect from being displayed as an absorb segment.\n\nNote: will cause errors if spell is not actually an absorb effect")
                AddTooltip(attributePanel.isWhitelisted, "Whitelisted buffs will always be displayed as buff frames")
                AddTooltip(attributePanel.isBlacklisted,
                    "Blacklisted buffs won't be displayed as buffs.\n\nNote: [SHIFT]-[RIGHTCLICK]ing an active buff (or debuff) will automatically blacklist it")
            elseif auraType == "debuffs" then
                AddTooltip(attributePanel.isWhitelisted, "Whitelisted debuffs will always be displayed")
                AddTooltip(attributePanel.isBlacklisted,
                    "Blacklisted debuffs won't be displayed.\n\nNote: [SHIFT]-[RIGHTCLICK]ing an active debuff (or buff) will automatically blacklist it")

                attributePanel.CCType = CreateFrame("FRAME", "$parent_CCType", attributePanel, "UIDropDownMenuTemplate")
                attributePanel.CCType:SetPoint("TOPLEFT", attributePanel.AutoDetect, "BOTTOMLEFT", -15, 0)
                UIDropDownMenu_SetWidth(attributePanel.CCType, 200)
                UIDropDownMenu_SetText(attributePanel.CCType, "Crowd Control Type")
            end

            attributePanel.RemoveSpell = CreateFrame("Button", "$parent_RemoveSpell", attributePanel,
                "UIPanelButtonTemplate")
            attributePanel.RemoveSpell:SetSize(200, 25)
            attributePanel.RemoveSpell:SetPoint("BOTTOMRIGHT", attributePanel, "BOTTOMRIGHT", -5, 5)
            attributePanel.RemoveSpell:SetScript("OnClick", function(self)
                local spellId = attributePanel:GetAttribute("spellId")
                local auraType = parentTab:GetAttribute("auraType")
                srslylawlUI.Auras_ManuallyRemoveSpell(spellId, auraType)

                parentTab:GetParent():Hide()
                parentTab:GetParent():Show()
                srslylawlUI.Party_HandleAuras_ALL()
                srslylawlUI.Main_HandleAuras_ALL()
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
        attributePanel:SetPoint("TOPLEFT", parentTab.borderFrame, "TOPRIGHT")
        attributePanel:SetPoint("BOTTOMRIGHT", parentTab, "BOTTOMRIGHT", -5, 5)

        if spellId == nil then
            --only adjusting parenting (switched/opened tabs)
            if not srslylawlUI_Saved[auraType].known[attributePanel:GetAttribute("spellId")] then
                attributePanel:Hide()
            end
            return
        end

        attributePanel:SetAttribute("spellId", spellId)


        attributePanel.SpellIcon:SetTexture(select(3, GetSpellInfo(spellId)))
        AddSpellTooltip(attributePanel.SpellIconFrame, spellId)
        attributePanel.SpellName:SetText(select(1, GetSpellInfo(spellId)))
        attributePanel.RemoveSpell:SetText("Remove Spell from " .. auraType)
        AddTooltip(attributePanel.RemoveSpell,
            "WARNING: this will remove the spell from every >\"" ..
            auraType ..
            "\"< category, including \"Encountered\".\nIf you just want to change its sub-category, use the appropriate checkbox/dropdown")

        local isBlacklisted = srslylawlUI_Saved[auraType].blackList[spellId] ~= nil or false
        local isWhitelisted = srslylawlUI_Saved[auraType].whiteList[spellId] ~= nil or false
        local autoDetect = srslylawlUI_Saved[auraType].known[spellId].autoDetect == nil or
            srslylawlUI_Saved[auraType].known[spellId].autoDetect
        AddTooltip(attributePanel.LastParsedText,
            srslylawlUI_Saved[auraType].known[spellId].text or "<Aura either has no tooltip or was never encountered>")
        attributePanel.AutoDetect:SetChecked(autoDetect)
        attributePanel.isBlacklisted:SetChecked(isBlacklisted)
        attributePanel.isWhitelisted:SetChecked(isWhitelisted)
        if auraType == "buffs" then
            attributePanel.isDefensive:SetChecked(srslylawlUI_Saved.buffs.known[spellId].isDefensive)
            attributePanel.isAbsorb:SetChecked(srslylawlUI_Saved.buffs.known[spellId].isAbsorb)
            attributePanel.DefensiveAmount:SetNumber(srslylawlUI_Saved[auraType].known[spellId].reductionAmount or 0)
            attributePanel.AutoDetectDefensiveAmount:SetChecked(srslylawlUI_Saved[auraType].known[spellId].autoDetectAmount
                ~= false)
        elseif auraType == "debuffs" then
            --dropdown cctype
            local dropDown = attributePanel.CCType
            UIDropDownMenu_SetText(attributePanel.CCType,
                "Crowd Control Type: " ..
                srslylawlUI.Utils_CCTableTranslation(srslylawlUI_Saved[auraType].known[spellId].crowdControlType))
            UIDropDownMenu_Initialize(dropDown,
                function(self)
                    local info = UIDropDownMenu_CreateInfo()
                    local checkFunc = function(self)
                        return self.value ==
                            srslylawlUI.Utils_CCTableTranslation(srslylawlUI_Saved[auraType].known[spellId].crowdControlType)
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
                local spell = srslylawlUI_Saved[auraType].known[spellId]
                local old = spell.crowdControlType
                UIDropDownMenu_SetText(attributePanel.CCType, "Crowd Control Type: " .. newValue)
                newValue = srslylawlUI.Utils_CCTableTranslation(newValue)

                if old ~= "none" then
                    srslylawlUI_Saved[auraType][old][spellId] = nil
                end

                if newValue ~= "none" then
                    srslylawlUI_Saved[auraType][newValue][spellId] = spell
                end

                srslylawlUI_Saved[auraType].known[spellId].crowdControlType = newValue

                parentTab:Hide()
                parentTab:Show()
            end

        end
        SetEnableButtons(attributePanel, auraType, autoDetect)
    end

    local function CreateFauxScrollFrame(parent, spellList)
        --fauxscrollframe doesnt actually create a button for every item, it just creates max amount of buttons once and then updates them during scrolling
        local function CreateButtons(parent, count, tab)
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
            for i = 1, count do
                button = CreateFrame("CheckButton", parent:GetName() .. "ListButton" .. i, anchorParent,
                    "UIMenuButtonStretchTemplate")
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
            local newValue = old - delta * valueStep
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
        ScrollFrame:SetScript("OnVerticalScroll",
            function(self, offset) FauxScrollFrame_OnVerticalScroll(self, offset, self.ButtonHeight, ScrollFrame_Update) end)
        ScrollFrame:SetScript("OnShow", function(self)
            local tab = self:GetParent():GetParent()
            local filterText = tab.FilterFrame.EditBox:GetText()
            GenerateSpellList(spellList, filterText or "", tab:GetAttribute("auraType"))
            ScrollFrame_Update(self)
            OpenSpellAttributePanel(tab)
        end)
        return ScrollFrame
    end

    local function CreateAuraTabsScrollFrame(parent)
        parent.borderFrame = CreateFrame("Frame", "$parent_BorderFrame", parent, "BackdropTemplate")
        parent.borderFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
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
        parent.FilterFrame.EditBox = CreateCustomEditBox(parent.FilterFrame, "filterFrame")
        parent.FilterFrame.EditBox:SetScript("OnTextChanged",
            function(self)
                local listKey = parent:GetAttribute("spellList")
                local filterText = self:GetText()
                GenerateSpellList(listKey, filterText, parent:GetAttribute("auraType"))
                ScrollFrame_Update(parent.ScrollFrame)
            end)
        parent.FilterFrame.EditBox:SetMaxLetters(20)
        parent.FilterFrame.EditBox.bounds:SetAllPoints(true)
        --Allowing to add a new spell
        parent.AddNewSpellFrame = CreateFrame("Button", "$parent_AddNewSpell", parent.FilterFrame,
            "UIPanelButtonTemplate")
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
            CreateAuraTabsScrollFrame(tab)
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
            CreateAuraTabsScrollFrame(tab)
            tab.borderFrame:SetBackdropColor(1, .5, .5, .4)
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

    local function SetupScrollingTabContent(tab)
        Mixin(tab, BackdropTemplateMixin)
        tab:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        tab:SetBackdropColor(0, 0, 0, .4)
        local ScrollFrame = CreateFrame("ScrollFrame", "$parent_ScrollFrame", tab, "UIPanelScrollFrameTemplate")
        ScrollFrame:SetClipsChildren(true)
        ScrollFrame:SetPoint("TOPLEFT", tab, "TOPLEFT", 5, -5)
        ScrollFrame:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", -5, 5)
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
        ScrollFrame.child:SetSize(tab:GetWidth() - 30, 1600)
        ScrollFrame:SetScrollChild(ScrollFrame.child)

        return ScrollFrame.child
    end

    local function FillMainUnitFramesTab(player, target, targettarget, focus)
        local cFrame = srslylawlUI_ConfigFrame

        local anchor = player
        local tabParent
        for _, unit in pairs(srslylawlUI.mainUnitsTable) do
            if unit == "target" then
                anchor = target
            elseif unit == "targettarget" then
                anchor = targettarget
            elseif unit == "focus" then
                anchor = focus
            end
            tabParent = anchor
            tabParent = SetupScrollingTabContent(tabParent)
            anchor = tabParent
            local unitName = unit:sub(1, 1):upper() .. unit:sub(2)
            local playerFrameControl = CreateConfigControl(tabParent, unitName .. " Frame", nil, unit)
            playerFrameControl.title:SetFont("Fonts\\FRIZQT__.TTF", 25, "")
            local path = "player." .. unit .. "Frame."
            local unitFrame = srslylawlUI.mainUnits[unit].unitFrame

            playerFrameControl:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, -15)

            local enable = CreateSettingsCheckButton("Enable", tabParent, path .. "enabled", function(self)
                local checked = self:GetChecked()
                if checked then
                    RegisterUnitWatch(unitFrame)
                    if UnitExists(unit) then
                        unitFrame:SetShown(checked)
                    end
                else
                    UnregisterUnitWatch(unitFrame)
                    unitFrame:SetShown(checked)
                end

            end)
            local hpWidth = CreateCustomSlider("Width", tabParent, 1, 3000, path .. "hp.width", 1, 0,
                function() srslylawlUI.Frame_ResetDimensions(unitFrame) end)
            local hpHeight = CreateCustomSlider("Height", tabParent, 1, 2000, path .. "hp.height", 1, 0,
                function() srslylawlUI.Frame_ResetDimensions(unitFrame) end)
            local fontSize = CreateCustomSlider("FontSize", tabParent, 0.5, 100, path .. "hp.fontSize", 0.5, 1,
                function() srslylawlUI.Frame_ResetDimensions(unitFrame) end)
            local reverseFill = CreateSettingsCheckButton("Reverse fill direction", tabParent, path .. "hp.reversed",
                srslylawlUI.Frame_UpdateMainHealthBarAlignment)

            if unit == "targettarget" then
                playerFrameControl:Add(enable, hpWidth, hpHeight, fontSize, reverseFill)
            else
                local absorbHeight = CreateCustomSlider("Absorb Frame Height %", tabParent, 0.1, 1,
                    path .. "hp.absorbHeightPercent", 0.05, 2, srslylawlUI.Main_HandleAuras_ALL)
                playerFrameControl:Add(enable, hpWidth, hpHeight, fontSize, reverseFill, absorbHeight)
            end

            local playerPosControl = CreateConfigControl(tabParent, unitName .. " Frame Position", nil, unit)
            playerPosControl:ChainToControl(playerFrameControl)
            local aTable
            if unit == "player" then
                aTable = { "Screen", "TargetFrame" }
            elseif unit == "target" then
                aTable = { "Screen", "PlayerFrame" }
            elseif unit == "focus" then
                aTable = { "Screen", "PlayerFrame", "TargetFrame" }
            end

            local anchorElements = CreateAnchoringPanel(tabParent, path .. "position", unitFrame.unit, aTable)
            playerPosControl:Add(unpack(anchorElements))

            local raidIconControl = CreateConfigControl(tabParent, unitName .. " Raid Icon", nil, unit)
            local raidEnable = CreateSettingsCheckButton("Enable", tabParent, path .. "raidIcon.enabled",
                function(self) unitFrame.unit.RaidIcon:SetEnabled(self:GetChecked()) end)
            local raidPos = CreateAnchoringPanel(tabParent, path .. "raidIcon.position", unitFrame.unit.RaidIcon, nil,
                true)
            local raidSize = CreateCustomSlider("Size", tabParent, 1, 100, path .. "raidIcon.size", 1, 0,
                function() unitFrame.unit.RaidIcon:Resize() end)
            raidIconControl:Add(raidEnable, raidSize, unpack(raidPos))
            raidIconControl:ChainToControl(playerPosControl)
            anchor = raidIconControl

            if unit ~= "targettarget" then
                for i = 1, 2 do
                    local anchorTable = i == 1 and { "Frame", "Debuffs" } or { "Frame", "Buffs" }
                    local aType = i == 1 and "buff" or "debuff"
                    local typeCap = i == 1 and "Buff" or "Debuff"
                    local auraControl = CreateConfigControl(tabParent, unitName .. " " .. typeCap .. " Frames", nil, unit)
                    auraControl:ChainToControl(anchor)
                    local pointOnInitValueFunc = function(info, value)
                        if i == 1 then
                            --Is Buff Anchor
                            --Disable button if Debuff Anchor is anchored to buffs
                            local debuffAnchorPoint = srslylawlUI.GetSetting(path .. "debuff" .. "s.anchoredTo", true)
                            if value == "Debuffs" then
                                info.disabled = debuffAnchorPoint == "Buffs"
                            end
                        else
                            --Is Debuff Anchor
                            --Disable button if Buff Anchor is anchored to debuffs
                            local buffAnchorPoint = srslylawlUI.GetSetting(path .. "buff" .. "s.anchoredTo", true)
                            if value == "Buffs" then
                                info.disabled = buffAnchorPoint == "Debuffs"
                            end
                        end
                    end
                    local frameAnchor = CreateCustomDropDown("Anchor To", 100, tabParent, path .. aType .. "s.anchoredTo"
                        ,
                        anchorTable, nil, pointOnInitValueFunc)
                    local auraAnchor = CreateCustomDropDown("AnchorPoint", 100, tabParent, path .. aType .. "s.anchor",
                        srslylawlUI.auraSortMethodTable, function() srslylawlUI.SetAuraPointsAll(unit, "mainUnits") end)

                    --disabling the auraanchor dropdown, should we anchor to other auratype
                    local onChanged = function(self, newValue)
                        srslylawlUI.SetAuraPointsAll(unit, "mainUnits")
                        if newValue ~= "Frame" then
                            UIDropDownMenu_DisableDropDown(auraAnchor)
                        else
                            UIDropDownMenu_EnableDropDown(auraAnchor)
                        end
                    end
                    frameAnchor.onChangeFunc = onChanged
                    if srslylawlUI.GetSetting(path .. aType .. "s.anchoredTo") ~= "Frame" then
                        UIDropDownMenu_DisableDropDown(auraAnchor)
                    end
                    local maxAuras = CreateCustomSlider("Max " .. typeCap .. "s", tabParent, 0, 40,
                        path .. aType .. "s.max" .. typeCap .. "s", 1, 0, function()
                        srslylawlUI.CreateBuffFrames(unitFrame, unit)
                        srslylawlUI.SetAuraPointsAll(unit, "mainUnits")
                        srslylawlUI.HandleAuras(unitFrame, unit, nil, "configMaxAuras")
                    end)
                    local auraSize = CreateCustomSlider("Size", tabParent, 0, 200, path .. aType .. "s.size", 1, 0,
                        function()
                            srslylawlUI.HandleAuras(unitFrame, unit, nil, "configAuraSize")
                            srslylawlUI.SetAuraPointsAll(unit, "mainUnits")
                        end)
                    local scaledAuraSize = CreateCustomSlider("Scaled Size", tabParent, 0, 200,
                        path .. aType .. "s.scaledSize"
                        , 1, 0, function()
                        srslylawlUI.HandleAuras(unitFrame, unit, nil, "configScaledAuraSize")
                        srslylawlUI.SetAuraPointsAll(unit, "mainUnits")
                    end)
                    if unit == "target" then
                        if aType == "buff" then
                            AddTooltip(scaledAuraSize, "Extra size of stealable/purgeable/dispellable buffs")
                        else
                            AddTooltip(scaledAuraSize, "Extra size of debuffs applied by yourself")
                        end
                    else
                        if aType == "buff" then
                            AddTooltip(scaledAuraSize, "Extra size of buffs applied by yourself")
                        else
                            AddTooltip(scaledAuraSize, "Extra size of debuffs applied by yourself")
                        end
                    end
                    local xOffset = CreateCustomSlider("X Offset", tabParent, -500, 500, path .. aType .. "s.xOffset", 1
                        , 0,
                        function()
                            srslylawlUI.SetAuraPointsAll(unit, "mainUnits")
                        end)
                    local yOffset = CreateCustomSlider("Y Offset", tabParent, -500, 500, path .. aType .. "s.yOffset", 1
                        , 0,
                        function()
                            srslylawlUI.SetAuraPointsAll(unit, "mainUnits")
                        end)
                    auraControl:Add(frameAnchor, auraAnchor, xOffset, yOffset, auraSize, scaledAuraSize, maxAuras)
                    anchor = auraControl

                end

                --combaticon
                local combatIconControl = CreateConfigControl(tabParent, unitName .. " Combat Icon", nil, unit)
                local combatIconEnabled = CreateSettingsCheckButton("Enabled", tabParent,
                    path .. "combatRestIcon.enabled",
                    function() srslylawlUI.Frame_ResetCombatIcon(unitFrame) end)
                local combatIconSize = CreateCustomSlider("Size", tabParent, 1, 200, path .. "combatRestIcon.size", 1, 0
                    ,
                    function() srslylawlUI.Frame_ResetCombatIcon(unitFrame) end)
                local combatIconAnchor = CreateCustomDropDown("Point", 100, tabParent,
                    path .. "combatRestIcon.position.1",
                    srslylawlUI.anchorTable, function() srslylawlUI.Frame_ResetCombatIcon(unitFrame) end)
                local combatIconX = CreateCustomSlider("X Offset", tabParent, -2000, 2000,
                    path .. "combatRestIcon.position.2"
                    , 1, 0, function() srslylawlUI.Frame_ResetCombatIcon(unitFrame) end)
                local combatIconY = CreateCustomSlider("Y Offset", tabParent, -2000, 2000,
                    path .. "combatRestIcon.position.3"
                    , 1, 0, function() srslylawlUI.Frame_ResetCombatIcon(unitFrame) end)
                combatIconControl:Add(combatIconEnabled, combatIconSize, combatIconAnchor, combatIconX, combatIconY)
                combatIconControl:ChainToControl(anchor)
                anchor = combatIconControl
            end

            if unit == "player" then
                local portraitControl = CreateConfigControl(tabParent, unitName .. " Portrait", nil, unit)
                local portraitEnabled = CreateSettingsCheckButton("Enabled", tabParent, path .. "portrait.enabled",
                    function() unitFrame:TogglePortrait() end)
                local portraitPosition = CreateCustomDropDown("Position", 100, tabParent, path .. "portrait.position",
                    { "LEFT", "RIGHT" }, function() unitFrame:TogglePortrait() end)
                -- local portraitAnchor = CreateCustomDropDown("Anchor", 100, tab, path .. "portrait.anchor",
                --     { "Frame", "Powerbar" }, function() unitFrame:TogglePortrait() end)
                portraitControl:Add(portraitEnabled, portraitPosition)
                portraitControl:ChainToControl(anchor)
                anchor = portraitControl
                local petControl = CreateConfigControl(tabParent, unitName .. " Pet Frame", nil, unit)
                local petEnable = CreateSettingsCheckButton("Enable", tabParent, path .. "pet.enabled",
                    function() srslylawlUI.Frame_ResetPetButton(unitFrame, unit .. "pet") end)
                local petWidth = CreateCustomSlider("Width", tabParent, 1, 200, path .. "pet.width", 1, 0,
                    function() srslylawlUI.Frame_ResetDimensions_Pet(unitFrame) end)
                petControl:Add(petEnable, petWidth)
                petControl:ChainToControl(anchor)
                anchor = petControl
                --powerbarsetup
                local function SetPlayerPowerBarOptions()
                    local specIndex = GetSpecialization()
                    local specID = GetSpecializationInfo(specIndex)
                    local isDruid = specID >= 102 and specID <= 105
                    local currentStance = isDruid and GetShapeshiftFormID() or 0
                    currentStance = currentStance or 0
                    local barTable = srslylawlUI.mainUnits.player.unitFrame.BarHandler.bars
                    local newTable = {}
                    for i = 1, #barTable do
                        table.insert(newTable, barTable[i])
                    end
                    cFrame.playerPowerBars = newTable
                    if not cFrame.playerPowerBarControls then
                        cFrame.playerPowerBarControls = {}
                    end
                    for i, frame in ipairs(cFrame.playerPowerBarControls) do
                        frame.control:Hide()
                    end
                    local cAnchor = petControl
                    local exists
                    for i = 1, #newTable do
                        exists = false
                        local name = newTable[i].bar.name
                        for _, v in ipairs(cFrame.playerPowerBarControls) do
                            if v.name == name and v.spec == specID and v.stance == currentStance then
                                exists = v
                                break
                            end
                        end
                        local p = "player.playerFrame.power.overrides." .. specID .. "." .. name
                        if isDruid then
                            local currentStance = GetShapeshiftFormID() or 0
                            p = "player.playerFrame.power.overrides." .. specID .. "." .. currentStance .. "." .. name
                        end
                        if name == "CastBar" then
                            p = "player.playerFrame.cast"
                        end
                        if not exists then
                            local barControl = CreateConfigControl(tabParent, "Player " .. name, nil, unit)
                            local barEnabled = CreateSettingsCheckButton("Disable", tabParent, p .. ".disabled",
                                function()
                                    unitFrame:ReRegisterAll()
                                end, true)
                            local barHeight = CreatePowerBarSlider("Height", tabParent, name, specID, "height",
                                newTable[i].height, function()
                                unitFrame:ReRegisterAll()
                            end)
                            local barPriority = CreatePowerBarSlider("Order", tabParent, name, specID, "priority",
                                newTable[i].priority, function()
                                unitFrame:ReRegisterAll()
                            end)
                            local reverseFill = CreateSettingsCheckButton("Reverse fill direction", tabParent,
                                p .. ".reversed"
                                , function() unitFrame:ReRegisterAll() end, true)
                            if name ~= "CastBar" then
                                local barHide = CreateSettingsCheckButton("Show when inactive", tabParent,
                                    p .. ".showWhenInactive", function() unitFrame:ReRegisterAll() end, true)
                                barControl:Add(barEnabled, barHeight, barPriority, reverseFill, barHide)
                                AddTooltip(barHide,
                                    "Display bar even when it's idle, such as having full mana/energy, or combopoints/rage being empty")
                            else
                                barControl:Add(barEnabled, barHeight, barPriority, reverseFill)
                            end
                            barControl:SetPoint("TOPLEFT", cAnchor.bounds, "BOTTOMLEFT", 0, 0)
                            table.insert(cFrame.playerPowerBarControls, #cFrame.playerPowerBarControls + 1,
                                { name = newTable[i].bar.name, control = barControl, enabled = barEnabled,
                                    height = barHeight, prio = barPriority, spec = specID, stance = currentStance })
                            cAnchor = barControl
                            anchor = barControl
                            cFrame.lastPlayerPowerBarAnchor = barControl
                        else
                            exists.control:SetPoint("TOPLEFT", cAnchor.bounds, "BOTTOMLEFT", 0, 0)
                            cAnchor = exists.control
                            anchor = exists.control
                            exists.control:Show()
                            cFrame.lastPlayerPowerBarAnchor = exists.control
                            exists.enabled:SetChecked(srslylawlUI.GetSetting(p .. ".disabled", true) or false)
                            exists.height:SetValueClean(srslylawlUI.GetSetting(p .. ".height", true) or
                                newTable[i].height)
                            exists.prio:SetValueClean(srslylawlUI.GetSetting(p .. ".priority", true) or
                                newTable[i].priority)
                        end
                        if i == 1 and not cFrame.infoBox then
                            cFrame.infoBox = CreateInfoBox(tabParent,
                                "Cast/Powerbar settings are saved per spec and druid shapeshift form. \nOnly currently active powerbars are shown here. \nSwitching spec and/or shapeshift form will update displayed settings."
                                , 280)
                            cFrame.infoBox.bounds:SetPoint("TOPLEFT", petControl, "TOPRIGHT", 0, 8)
                        elseif i == 2 and isDruid then
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
                            local form = currentStance == 0 and "Humanoid" or currentStance == 1 and "Cat Form" or
                                currentStance == 5 and "Bear Form" or currentStance == 31 and "Moonkin Form" or
                                "Travel Form"
                            if not cFrame.shapeShiftBox then
                                cFrame.shapeShiftBox = CreateInfoBox(tabParent,
                                    "Settings for current shapeshift form: " ..
                                    form, 150)
                            else
                                cFrame.shapeShiftBox:SetText("Settings for current shapeshift form: " .. form)
                            end
                            cFrame.shapeShiftBox.bounds:SetPoint("TOPLEFT", cFrame.infoBox.bounds, "TOPRIGHT", 0, 0)
                        end
                    end
                    -- if cFrame.nextControlAfterPlayerPower then
                    --     cFrame.nextControlAfterPlayerPower:AppendToControl(cFrame.lastPlayerPowerBarAnchor)
                    -- end
                end

                tabParent:SetScript("OnShow", SetPlayerPowerBarOptions)
                tabParent:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
                tabParent:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "player")
                tabParent:SetScript("OnEvent", SetPlayerPowerBarOptions)
                SetPlayerPowerBarOptions()
                --should place bars again once spec/druidform changes
            else
                local powerBarControl = CreateConfigControl(tabParent, unitName .. " Powerbar", nil, unit)
                local powerBarEnable = CreateSettingsCheckButton("Enable", tabParent, path .. "power.enabled",
                    function() srslylawlUI.Frame_ResetUnitButton(unitFrame.unit, unit) end, true)
                local powerBarWidth = CreateCustomSlider("Width", tabParent, 0, 100, path .. "power.width", 1, 0,
                    function()
                        srslylawlUI.Frame_ResetDimensions_PowerBar(unitFrame)
                    end)
                local powerBarText = CreateSettingsCheckButton("Show Text", tabParent, path .. "power.text",
                    function() srslylawlUI.Frame_ResetUnitButton(unitFrame.unit, unit) end)
                local position = CreateCustomDropDown("Position", 100, tabParent, path .. "power.position",
                    { "LEFT", "RIGHT" }
                    , function()
                    srslylawlUI.Frame_ResetDimensions_PowerBar(unitFrame)
                end)
                powerBarControl:Add(powerBarEnable, powerBarWidth, powerBarText, position)
                powerBarControl:ChainToControl(anchor)
                if unit == "targettarget" then
                    anchor = powerBarControl
                elseif unit == "target" or unit == "focus" then
                    local castBarControl = CreateConfigControl(tabParent, unitName .. " CastBar", nil, unit)
                    local castBarEnabled = CreateSettingsCheckButton("Disable", tabParent, path .. "cast.disabled",
                        function()
                            unitFrame:ReRegisterAll()
                        end, true)
                    local castBarHeight = CreateCustomSlider("Height", tabParent, 0, 100, path .. "cast.height", 1, 0,
                        function()
                            unitFrame:ReRegisterAll()
                        end)
                    local castBarPriority = CreateCustomSlider("Order", tabParent, 0, 10, path .. "cast.priority", 1, 0,
                        function()
                            unitFrame:ReRegisterAll()
                        end)
                    local castReverseFill = CreateSettingsCheckButton("Reverse fill direction", tabParent,
                        path .. "cast.reversed", function() unitFrame:ReRegisterAll() end, true)
                    castBarControl:Add(castBarEnabled, castBarHeight, castBarPriority, castReverseFill)
                    castBarControl:ChainToControl(powerBarControl)
                    local ccbarControl = CreateConfigControl(tabParent, unitName .. " CrowdControl", nil, unit)
                    local ccbarEnabled = CreateSettingsCheckButton("Disable", tabParent, path .. "ccbar.disabled",
                        function()
                            unitFrame:ReRegisterAll()
                        end, true)
                    local ccbarHeight = CreateCustomSlider("Height", tabParent, 0, 100, path .. "ccbar.height", 1, 0,
                        function()
                            unitFrame:ReRegisterAll()
                        end)
                    local ccbarPriority = CreateCustomSlider("Order", tabParent, 0, 10, path .. "ccbar.priority", 1, 0,
                        function()
                            unitFrame:ReRegisterAll()
                        end)
                    local ccBarReverseFill = CreateSettingsCheckButton("Reverse fill direction", tabParent,
                        path .. "ccbar.reversed", function() unitFrame:ReRegisterAll() end, true)
                    ccbarControl:Add(ccbarEnabled, ccbarHeight, ccbarPriority, ccBarReverseFill)
                    ccbarControl:ChainToControl(castBarControl)
                    local portraitControl = CreateConfigControl(tabParent, unitName .. " Portrait", nil, unit)
                    local portraitEnabled = CreateSettingsCheckButton("Enabled", tabParent, path .. "portrait.enabled",
                        function() unitFrame:TogglePortrait() end)
                    local portraitPosition = CreateCustomDropDown("Position", 100, tabParent, path .. "portrait.position"
                        ,
                        { "LEFT", "RIGHT" }, function() unitFrame:TogglePortrait() end)
                    local portraitAnchor = CreateCustomDropDown("Anchor", 100, tabParent, path .. "portrait.anchor",
                        { "Frame", "Powerbar" }, function() unitFrame:TogglePortrait() end)
                    portraitControl:Add(portraitEnabled, portraitPosition, portraitAnchor)
                    portraitControl:ChainToControl(ccbarControl)

                    local anchorT = unit == "target" and { "TargetFrame", "TargetFramePortrait" } or
                        { "FocusFrame", "FocusFramePortrait" }

                    local unitLevelControl = CreateConfigControl(tabParent, unitName .. " Level", nil, unit)
                    local elements = CreateAnchoringPanel(tabParent, path .. "unitLevel.position", unitFrame.unitLevel,
                        anchorT)
                    local unitClassificationEnable = CreateSettingsCheckButton("Show Classification", unitLevelControl,
                        path .. "unitLevel.showClassification",
                        function()
                            local show = srslylawlUI.GetSettingByUnit("unitLevel.showClassification", "mainUnits", unit)
                            unitFrame.unitLevel.showClassification = show
                            unitFrame:UpdateUnitLevel()
                        end)
                    AddTooltip(unitClassificationEnable,
                        "Indicate if target is rare ('R'), elite ('E') or rareelite ('RE') by appending the respective letters to the level.")
                    unitLevelControl:Add(unpack(elements))
                    unitLevelControl:Add(unitClassificationEnable)
                    unitLevelControl:ChainToControl(portraitControl)
                    anchor = unitLevelControl
                end
            end
            local h = 0
            for _, v in pairs(tabParent.controls) do
                h = h + v
            end
            tabParent:SetHeight(h)
        end
    end

    srslylawlUI_ConfigFrame = CreateFrame("Frame", "srslylawlUI_Config", UIParent, "SettingsFrameTemplate")

    local cFrame = srslylawlUI_ConfigFrame
    local cFrameSizeX = 750
    local cFrameSizeY = 500

    cFrame.fakeFramesToggled = false

    local lockFrames = CreateCheckButton("Preview settings and make frames moveable", cFrame)
    cFrame.lockFramesButton = lockFrames
    lockFrames:SetPoint("TOPLEFT", cFrame, "TOPLEFT", 10, -20)
    lockFrames:SetScript("OnClick", function(self)
        ToggleFakeFrames(self:GetChecked())
        cFrame.fakeFramesToggled = self:GetChecked()
    end)



    -- Main Config Frame
    cFrame.name = "srslylawlUI"
    cFrame:SetSize(cFrameSizeX, cFrameSizeY)
    cFrame:SetPoint("CENTER")
    cFrame.NineSlice.Text:SetText("srslylawlUI Configuration")
    srslylawlUI.Frame_MakeFrameMoveable(cFrame)
    cFrame:SetScript("OnHide", function() ToggleFakeFrames(false) end)
    cFrame:SetFrameLevel(20)

    cFrame.body = CreateConfigBody("$parent_Body", cFrame)

    CreateSaveLoadButtons(cFrame)

    local generalTab, mainUnitFrames, partyFramesTab, buffsTab, debuffsTab = SetTabs(cFrame.body, "General",
        "Player/Target/Focus Frames", "Party Frames", "Buffs", "Debuffs")

    -- Create General Tab
    Mixin(generalTab, BackdropTemplateMixin)
    generalTab:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    generalTab:SetBackdropColor(0, 0, 0, .4)
    local general = SetupScrollingTabContent(generalTab)
    FillGeneralTab(general)

    -- Create Main Unit Frames Tab
    mainUnitFrames:ClearAllPoints()
    mainUnitFrames:SetPoint("TOP", cFrame.body, "TOP", 0, -35)
    mainUnitFrames:SetPoint("BOTTOMLEFT", cFrame.body, "BOTTOMLEFT", 4, 4)
    mainUnitFrames:SetPoint("BOTTOMRIGHT", cFrame.body, "BOTTOMRIGHT", -4, 2)
    Mixin(mainUnitFrames, BackdropTemplateMixin)
    mainUnitFrames:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    mainUnitFrames:SetBackdropColor(0, 0, 0, .4)
    local player, target, targettarget, focus = SetTabs(mainUnitFrames, "Player", "Target", "Target of Target", "Focus")
    FillMainUnitFramesTab(player, target, targettarget, focus)

    -- Create Party Frames Tab
    local party = SetupScrollingTabContent(partyFramesTab)
    FillPartyFramesTab(party)

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
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    buffsTab:SetBackdropColor(0, 0, 0, .4)

    -- Buffs Tab buttons
    local knownBuffs, absorbs, defensives, whiteList, blackList =
    SetTabs(buffsTab, "Encountered", "Absorbs", "Defensives", "Whitelist", "Blacklist")
    AddTooltip(knownBuffs.tabButton, "List of all encountered buffs")
    AddTooltip(absorbs.tabButton, "Buffs with absorb effects, will be shown as segments")
    AddTooltip(defensives.tabButton, "Buffs with damage reduction effects, will increase your effective health")
    AddTooltip(whiteList.tabButton, "Whitelisted buffs will always appear as buff frames")
    AddTooltip(blackList.tabButton, "Buffs that will not be displayed on the interface")

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
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    debuffsTab:SetBackdropColor(0, 0, 0, .4)

    local knownDebuffs, whiteList, blackList, stuns, incaps, disorients, silences, roots = SetTabs(debuffsTab,
        "Encountered", "Whitelist", "Blacklist", "Stuns", "Incapacitates", "Disorients", "Silences", "Roots")
    CreateDebuffTabs(knownDebuffs, whiteList, blackList, stuns, incaps, disorients, silences, roots)
    AddTooltip(knownDebuffs.tabButton, "List of all encountered debuffs")
    AddTooltip(whiteList.tabButton, "Whitelisted debuffs will always be displayed")
    AddTooltip(blackList.tabButton, "Blacklisted debuffs will never be displayed")


    srslylawlUI.ToggleConfigVisible(true)
    InterfaceOptions_AddCategory(srslylawlUI_ConfigFrame)
end
