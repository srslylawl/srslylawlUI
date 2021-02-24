local powerBar = {
}


function srslylawlUI.CreatePointPowerBar(amount, parent, padding, sizeX, sizeY)
    if amount < 1 then error("Param1 'Amount' must be 1 or higher") return end
    local frame = CreateFrame("Frame", "$parent_PointPowerBar", parent)
    frame.padding = padding
    frame.desiredButtonCount = amount
    frame.sizeX = sizeX
    frame.sizeY = sizeY
    frame.bg = frame:CreateTexture("$parent_BG", "BACKGROUND")
    
    frame.bg:SetColorTexture(0, 0, 0, .5)


    frame.pointFrames = {}

    local function CreatePointFrame(parent, i)
        local frame = CreateFrame("StatusBar", "$parent_PointBar"..i, parent)
        frame:SetStatusBarTexture(srslylawlUI.textures.PowerBarSprite)
        frame:SetMinMaxValues(0, 1)
        frame:SetValue(1)
        return frame
    end
    function frame:SetColor(color)
        self.color = color
        self:SetPoints()
    end

    function frame:SetPoints(newButtonCount)
        if newButtonCount then
            self.desiredButtonCount = newButtonCount
        end
        local physicalWidth, physicalHeight = GetPhysicalScreenSize()
        local ingameHeight = GetScreenHeight() * UIParent:GetScale()
        local ingameWidth = GetScreenWidth() * UIParent:GetScale()
        local scaleX, scaleY = ingameWidth/physicalWidth, ingameHeight/physicalHeight

        if self.desiredButtonCount > #self.pointFrames then
            local index = #self.pointFrames
            while self.desiredButtonCount > index do
                self.pointFrames[index+1] = CreatePointFrame(frame, index)
                index = index + 1
            end
        end

        local totalSize = self.sizeX
        local height = self.sizeY - 2*self.padding
        local buttons = self.desiredButtonCount
        local totalpadding = (buttons+1)*self.padding
        totalSize = totalSize - totalpadding
        local barSize = srslylawlUI.Utils_ScuffedRound(totalSize/buttons)
        totalSize = barSize*buttons+totalpadding
        print("totalSize: ", totalSize, "barheight", height, "barsize", barSize)
        for i=1, #self.pointFrames do
            local current = self.pointFrames[i]
            if i > self.desiredButtonCount then
                current:Hide()
            else
                current:Show()
            end
            if i == 1 then
                srslylawlUI.Utils_SetPointPixelPerfect(current, "BOTTOMLEFT", self, "BOTTOMLEFT", self.padding, self.padding)
            else
                srslylawlUI.Utils_SetPointPixelPerfect(current, "BOTTOMLEFT", self.pointFrames[i-1], "BOTTOMRIGHT", self.padding, 0)
            end
            srslylawlUI.Utils_SetSizePixelPerfect(current, barSize, height)
 
            if self.color then
                current:SetStatusBarColor(unpack(self.color))
            end
        end
        print("final:", totalSize, (height+2))
        srslylawlUI.Utils_SetSizePixelPerfect(self, totalSize, height+2)
        self.bg:SetAllPoints()
        self:SetPoint("BOTTOMLEFT", nil, "BOTTOMLEFT", 0, 0)

        srslylawlUI.Frame_MakeFrameMoveable(self)

    end

    frame:SetPoints()
    return frame
end