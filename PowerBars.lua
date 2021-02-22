local powerBar = {
}


function srslylawlUI.CreatePointPowerBar(amount, parent, padding)
    local function CreatePointFrame(parent, i)
        local frame = CreateFrame("StatusBar", "$parent_PointBar"..i, parent)
        frame:SetStatusBarTexture(srslylawlUI.textures.PowerBarSprite)
        frame:SetMinMaxValues(0, 1)
        frame:SetValue(1)
        return frame
    end
    
    local frame = CreateFrame("Frame", "$parent_PointPowerBar", parent)
    frame.padding = padding
    padding = srslylawlUI.Utils_GetPhysicalPixelSize(padding)

    frame.pointFrames = {}
    for i=1, amount do
        frame.pointFrames[i] = CreatePointFrame(frame, i)

        if i == 1 then
            frame.pointFrames[i]:SetPoint("TOPLEFT", frame, "TOPLEFT", padding, padding)
        else
            frame.pointFrames[i]:SetPoint("TOPLEFT", frame.pointFrames[i-1], "TOPRIGHT", padding, padding)
        end
    end

    function frame:ApplyLayout(buttonCount)
        if buttonCount then
            if buttonCount > #self.pointFrames then
                --create extra buttons
                local index = #self.pointFrames
                while buttonCount > index do
                    self.pointFrames[i+1] = CreatePointFrame(frame, i)
                    self.pointFrames[i+1]:SetPoint("TOPLEFT", frame.pointFrames[i], "TOPRIGHT", self.padding, self.padding)
                    index = index + 1
                end
            elseif buttonCount < #self.pointFrames then
                --hide excess buttons
                for i=buttonCount+1, #self.pointFrames do
                    self.pointFrames[i]:Hide()
                end
            end
        end
        
        local width = srslylawlUI.Utils_GetPhysicalPixelSize(self:GetWidth())
        local maxButtons = #self.pointFrames
        local buttonWidth = (width/maxButtons) - (self.padding*(maxButtons+1))
        buttonWidth = srslylawlUI.Utils_GetVirtualPixelSize(buttonWidth)
        local padding = srslylawlUI.Utils_GetPhysicalPixelSize(self.padding)

        print("virtual padding: ", padding)

        for i=1, maxButtons do
            if i == 1 then
                self.pointFrames[i]:SetPoint("TOPLEFT", frame, "TOPLEFT", padding, -padding)
                self.pointFrames[i]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", padding+buttonWidth, padding)
            else
                self.pointFrames[i]:SetPoint("TOPLEFT", self.pointFrames[i-1], "TOPRIGHT", padding, 0)
                self.pointFrames[i]:SetPoint("BOTTOMRIGHT", self.pointFrames[i-1], "BOTTOMRIGHT", buttonWidth, 0)
            end

            if self.color then
                print(unpack(self.color))
                self.pointFrames[i]:SetStatusBarColor(unpack(self.color))
            end
        end
    end

    return frame
end