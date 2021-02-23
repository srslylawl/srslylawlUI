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

function srslylawlUI.CreateTestBar(x, y)
    local physicalWidth, physicalHeight = GetPhysicalScreenSize()
    local ingameHeight = GetScreenHeight() * UIParent:GetScale()
    local ingameWidth = GetScreenWidth() * UIParent:GetScale()
    local scaleX, scaleY = ingameWidth/physicalWidth, ingameHeight/physicalHeight

    local totalSize = x
    local height = y - 2
    local buttons = 5
    local totalpadding = (buttons+1)*1
    totalSize = totalSize - totalpadding
    local barSize = srslylawlUI.Utils_ScuffedRound(totalSize/buttons)
    totalSize = barSize*buttons+totalpadding
    print("totalSize: ", totalSize)
    if not TESTBAR1 then
       TESTHOLDER = CreateFrame("Frame", "TESTHOLDER")
       Mixin(TESTHOLDER, BackdropTemplateMixin)
       TESTHOLDER:SetBackdrop({
             bgFile = "Interface/Tooltips/UI-Tooltip-Background"
       })
       TESTHOLDER:SetBackdropColor(0, 0, 0, .4)
       TESTBAR1 = CreateFrame("StatusBar", "TESTBAR11", nil)
       --TESTBAR1.tex = TESTBAR1:CreateTexture(nil, "OVERLAY")
       --TESTBAR1.tex:SetAllPoints(true)
       --TESTBAR1.tex:SetColorTexture(1, 1, 1, 1)
       TESTBAR1:SetStatusBarColor(1, 1, 1, 1)
       TESTBAR1:SetStatusBarTexture(srslylawlUI.textures.PowerBarSprite)
       TESTBAR1:SetMinMaxValues(0, 1)
       TESTBAR1:SetValue(1)
       TESTBAR1:Show()

       for x=2, buttons do
          local bar = CreateFrame("StatusBar", "TESTBAR"..x..1, nil)
          --bar.tex = bar:CreateTexture(nil, "OVERLAY")
          --bar.tex:SetAllPoints(true)
          --bar.tex:SetColorTexture(1, 1, 1, 1)
          bar:SetMinMaxValues(0, 1)
          bar:SetValue(1)
          bar:SetStatusBarTexture(srslylawlUI.textures.PowerBarSprite)

          bar:SetPoint("TOPLEFT", "TESTBAR"..(x-1)..1, "TOPRIGHT", 1*scaleX, 0)
          bar:SetSize(barSize*scaleX,height*scaleY)
          bar:Show()
       end

    end

    TESTHOLDER:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
    TESTHOLDER:SetSize((totalSize)*scaleX, (height+2)*scaleY)
    --TESTBAR1:SetPoint("BOTTOMLEFT", TESTHOLDER, "BOTTOMLEFT", 1*scaleX, 1*scaleY)
    --TESTBAR1:SetSize(barSize*scaleX,height*scaleY)

    TESTHOLDER:SetScript("OnUpdate", function(self, elapsed)
          local point = {self:GetPoint()}
          point[4] = point[4] + elapsed
          point[5] = point[5] + elapsed
          self:SetPoint(unpack(point))
    end)

end