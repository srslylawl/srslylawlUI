srslylawlUI = srslylawlUI or {}

--[[
#############################################################
#                                                           #
#                  Created by Andreas S. G.                 #
#                  Discord: srslylawl#5257                  #
#                  BNET: INSANITY#22914                     #
#                                                           #
#############################################################
]]


srslylawlUI.loadedSettings = {}
srslylawlUI.buffs = {
    known = {},
    absorbs = {},
    whiteList = {},
    blackList = {},
    defensives = {},
}
srslylawlUI.debuffs = {
    known = {},
    whiteList = {},
    blackList = {},
    roots = {},
    stuns = {},
    incaps = {},
    silences = {},
    disorients = {},
}
srslylawlUI.sortedSpellLists = {
    buffs = {
        known = {},
        absorbs = {},
        defensives = {},
        whiteList = {},
        blackList = {}
    },
    debuffs = {
        known = {},
        whiteList = {},
        blackList = {}
    }
}
srslylawlUI.textures = {
    AbsorbFrame = "Interface/RAIDFRAME/Shield-Fill",
    HealthBar = "Interface/AddOns/srslylawlUI/media/powerBarSprite",--"Interface/Addons/srslylawlUI/media/healthBar",
    EffectiveHealth = "Interface/AddOns/srslylawlUI/media/eHealthBar",
    Immunity = "Interface/AddOns/srslylawlUI/media/immunitySprite",
    PowerBarSprite = "Interface/AddOns/srslylawlUI/media/powerBarSprite",
    AuraBorder32 = "Interface/AddOns/srslylawlUI/media/auraBorder_32",
    AuraBorder64 = "Interface/AddOns/srslylawlUI/media/auraBorder_64",
    AuraSwipe32 = "Interface/AddOns/srslylawlUI/media/auraSwipe_32",
    AuraSwipe64 = "Interface/AddOns/srslylawlUI/media/auraSwipe_64",
}
srslylawlUI.unsaved = {flag = false, buttons = {}}
srslylawlUI.keyPhrases = {
    defensive = {
        "reduces damage taken", "damage taken reduced", "reducing damage taken",
        "reducing all damage taken", "reduces all damage taken", "damage taken is redirected", "damage taken is transferred"
    },
    absorbs = {
        "absorb", "prevents"
    },
    immunity = {
        "immune to physical damage", "immune to all damage", "immune to all attacks", "immune to damage", "immune to magical damage"
    }
}

srslylawlUI.partyUnits = {
    player = {},
    party1 = {},
    party2 = {},
    party3 = {},
    party4 = {},
}
srslylawlUI.mainUnits = {
    player = {},
    target = {},
    targettarget = {}
}
srslylawlUI.fauxUnits = {}
srslylawlUI.customTooltip = CreateFrame("GameTooltip", "srslylawl_CustomTooltip", UIParent, "GameTooltipTemplate")
srslylawlUI.partyUnitsTable = { "player", "party1", "party2", "party3", "party4"}
srslylawlUI.mainUnitsTable = {"player", "target", "targettarget"}
srslylawlUI.crowdControlTable = { "stuns", "incaps", "disorients", "silences", "roots"}
srslylawlUI.anchorTable = {
    "TOP", "RIGHT", "BOTTOM", "LEFT", "CENTER", "TOPRIGHT", "TOPLEFT", "BOTTOMLEFT", "BOTTOMRIGHT"
}
srslylawlUI.auraSortMethodTable = {
    "TOPLEFT", "TOPRIGHT", "RIGHTTOP", "RIGHTBOTTOM", "BOTTOMRIGHT", "BOTTOMLEFT", "LEFTBOTTOM", "LEFTTOP"
}
srslylawlUI.FramesToAnchorTo = {
    "Screen",
    "PlayerFrame",
    "TargetFrame",
    "TargetFramePortrait"
}
srslylawlUI.unitHealthBars = {}
local unitHealthBars = srslylawlUI.unitHealthBars
srslylawlUI.sortTimerActive = false

local tooltipTextGrabber = CreateFrame("GameTooltip", "srslylawl_TooltipTextGrabber", UIParent, "GameTooltipTemplate")
local debugString = ""



--[[ TODO:
hide powerbar when inactive setting
non destro shards show timer sometimes
alt powerbar
seperate autodetect for auratype and defense values
fauxparty not showing on solo
totem bar GetTotemInfo(1)
focus frame
faux frames for player pet
powerbar fadeout
incoming ressurection
incoming summon
more sort methods?
vehiclestuff
faux frames absorb auras
revisit some of the sorting/resize logic, probably firing more often than necessary
]]

--Utils
function srslylawlUI.Log(text, ...)
    str = ""
    for i = 1, select('#', ...) do
        str = str .. (select(i, ...) .. " ")
    end
    print("|cff4D00FFsrslylawlUI:|r " .. text, str)
end
function srslylawlUI.Utils_ShortenString(str, start, numChars)
    -- This function can return a substring of a UTF-8 string, properly handling UTF-8 codepoints. Rather than taking a start index and optionally an end index, it takes the string, the start index, and
    -- the number of characters to select from the string.
    local currentIndex = start
    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        if char >= 240 then
            currentIndex = currentIndex + 4
        elseif char >= 225 then
            currentIndex = currentIndex + 3
        elseif char >= 192 then
            currentIndex = currentIndex + 2
        else
            currentIndex = currentIndex + 1
        end
        numChars = numChars - 1
    end
    return str:sub(start, currentIndex - 1)
end
function srslylawlUI.Utils_TableDeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[srslylawlUI.Utils_TableDeepCopy(orig_key)] = srslylawlUI.Utils_TableDeepCopy(orig_value)
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
function srslylawlUI.Utils_TableEquals(table1, table2)
    if table1 == table2 then return true end
    local table1Type = type(table1)
    local table2Type = type(table2)
    if table1Type ~= table2Type then return false end
    if table1Type ~= "table" then return false end

    local keySet = {}

    for key1, value1 in pairs(table1) do
        local value2 = table2[key1]
        if value2 == nil or srslylawlUI.Utils_TableEquals(value1, value2) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(table2) do if not keySet[key2] then return false end end
    return true
end
function srslylawlUI.Utils_GetTableLength(T)
    local count = 0
    if t == nil then return 0
    end
    for _ in pairs(T) do count = count + 1 end
    return count
end
function srslylawlUI.Utils_ScuffedRound(num)
    num = floor(num+0.5)
    return num
end
function srslylawlUI.Utils_DecimalRound(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
function srslylawlUI.Utils_DecimalRoundWithZero(num, numDecimalPlaces)
    local s = srslylawlUI.Utils_DecimalRound(num, numDecimalPlaces)
    s = tostring(s)
    if not string.find(s, '%.') then
        return s .. ".0"
    end
    return s
end
function srslylawlUI.Utils_GetUnitNameWithServer(unit)
    local name, server
    if (UnitExists(unit)) then
        name, server = UnitName(unit)
        if (server and server ~= "") then name = name .. "-" .. server end
    end
    return name
end
function srslylawlUI.Utils_CCTableTranslation(string)
    if string == "stuns" then return "stun"
    elseif string == "incaps" then return "incapacitate"
    elseif string == "disorients" then return "disorient"
    elseif string == "silences" then return "silence"
    elseif string == "roots" then return "root"
    elseif string == "root" then return "roots"
    elseif string == "silence" then return "silences"
    elseif string == "disorient" then return "disorients"
    elseif string == "incapacitate" then return "incaps"
    elseif string == "stun" then return "stuns"
    else return "none"
    end
end
function srslylawlUI.Utils_GetPixelScale()
    if not srslylawlUI.pixelScaleX then
        local physicalWidth, physicalHeight
        local isMaximized = GetCVar("gxMaximize") == 1 and true or false
        if isMaximized then
            physicalWidth, physicalHeight = GetPhysicalScreenSize()
        else
            local res = string.gmatch((GetScreenResolutions()), "%d+")
            physicalWidth, physicalHeight = res(), res()
        end
        local ingameWidth = srslylawlUI.Utils_ScuffedRound(GetScreenWidth() * UIParent:GetScale())
        local ingameHeight = srslylawlUI.Utils_ScuffedRound(GetScreenHeight() * UIParent:GetScale())
        srslylawlUI.pixelScaleX, srslylawlUI.pixelScaleY = ingameWidth/physicalWidth, ingameHeight/physicalHeight
    end
    return srslylawlUI.pixelScaleX, srslylawlUI.pixelScaleY
end
function srslylawlUI.Utils_SetWidthPixelPerfect(frame, width)
    local scaleX = srslylawlUI.Utils_GetPixelScale()
    width = srslylawlUI.Utils_ScuffedRound(width)
    frame:SetWidth(width*scaleX)
end
function srslylawlUI.Utils_SetHeightPixelPerfect(frame, height)
    local _, scaleY = srslylawlUI.Utils_GetPixelScale()
    height = srslylawlUI.Utils_ScuffedRound(height)
    frame:SetHeight(height*scaleY)
end
function srslylawlUI.Utils_SetSizePixelPerfect(frame, width, height)
    width = srslylawlUI.Utils_ScuffedRound(width)
    height = srslylawlUI.Utils_ScuffedRound(height)
    local scaleX, scaleY = srslylawlUI.Utils_GetPixelScale()
    frame:SetSize(width*scaleX, height*scaleY)
end
function srslylawlUI.Utils_SetPointPixelPerfect(frame, point, parent, relativeTo, offsetX, offsetY)
    local scaleX, scaleY = srslylawlUI.Utils_GetPixelScale()
    frame:SetPoint(point, parent, relativeTo, offsetX*scaleX, offsetY*scaleY)
end
function srslylawlUI.Utils_PixelFromCodeToScreen(width, height)
    if width and height then
        local scaleX, scaleY = srslylawlUI.Utils_GetPixelScale()

        return width*scaleX, height*scaleY
    elseif not height then
        local scaleX = srslylawlUI.Utils_GetPixelScale()

        return width*scaleX
    end
end
function srslylawlUI.Utils_PixelFromScreenToCode(width, height)
    if width and height then
        local scaleX, scaleY = srslylawlUI.Utils_GetPixelScale()
        return srslylawlUI.Utils_PixelRound(width/scaleX, 1*scaleX), srslylawlUI.Utils_PixelRound(height/scaleX, 1*scaleY)
    elseif not height then
        local scaleX = srslylawlUI.Utils_GetPixelScale()

        return srslylawlUI.Utils_PixelRound(width/scaleX, 1*scaleX)
    end
end
function srslylawlUI.Utils_AnchorInvert(position)
    if position == "TOP" then
        return "BOTTOM"
    elseif position == "RIGHT" then
        return "LEFT"
    elseif position == "BOTTOM" then
        return "TOP"
    elseif position == "LEFT" then
        return "RIGHT"
    elseif position == "CENTER" then
        return "CENTER"
    elseif position == "TOPRIGHT" then
        return "BOTTOMLEFT"
    elseif position == "TOPLEFT" then
        return "BOTTOMRIGHT"
    elseif position == "BOTTOMLEFT" then
        return "TOPRIGHT"
    elseif position == "BOTTOMRIGHT" then
        return "TOPLEFT"
    end
end
function srslylawlUI.Utils_StringHasKeyWord(str, keywordTable)
    local s = string.lower(str)
    for _, phrase in pairs(keywordTable) do
        if s:match(phrase) then return true end
    end

    return false
end
function srslylawlUI.Utils_TranslateTexY(texture, amount, isTiledTexture)
    --this bugs out if texture gets resized
    local coords = {texture:GetTexCoord()}
    if isTiledTexture then
        local original = {0, 0, 0, 1, 1, 0, 1, 1}
        local cont = false
        for i, v in ipairs(coords) do
            if coords[i] ~= original[i] then
                cont = true
                break
            end
        end
        if not cont then return end
    end
    coords[2] = coords[2] + amount
    coords[4] = coords[4] + amount
    coords[6] = coords[6] + amount
    coords[8] = coords[8] + amount

    texture:SetTexCoord(unpack(coords))
end
function srslylawlUI.Utils_TranslateTexX(texture, amount, isTiledTexture)
    --this bugs out if texture gets resized
    local coords = {texture:GetTexCoord()}

    if isTiledTexture then
        local original = {0, 0, 0, 1, 1, 0, 1, 1}
        local cont = false
        for i, v in ipairs(coords) do
            if coords[i] ~= original[i] then
                cont = true
                break
            end
        end
        if not cont then
            return
        end
    end

    coords[1] = coords[1] + amount
    coords[3] = coords[3] + amount
    coords[5] = coords[5] + amount
    coords[7] = coords[7] + amount

    texture:SetTexCoord(unpack(coords))
end
function srslylawlUI.Utils_SetLimitedText(fontstring, maxPixels, text, addDots)
    local substring
    local wasShortened = false
    for length = #text, 1, -1 do
        substring = srslylawlUI.Utils_ShortenString(text, 1, length)
        fontstring:SetText(wasShortened and addDots and substring..".." or substring)
        if fontstring:GetStringWidth() <= maxPixels then
            return
        end
        wasShortened = true
    end
end
function srslylawlUI.Utils_PixelRound(x, pixelSize)
    pixelSize = pixelSize or srslylawlUI.Utils_PixelFromCodeToScreen(1)
    if math.fmod(x, 1) >= pixelSize then
        return ceil(x)
    else
        return floor(x)
    end
end
function srslylawlUI.ShortenNumber(number)
    if number > 999999999 then
        number = tostring(srslylawlUI.Utils_ScuffedRound(number/100000000))
        if number:sub(string.len(number),string.len(number)) ~= '0' then
            number = number:sub(1,string.len(number)-1).."."..number:sub(string.len(number)).."B"
        else
            number = number:sub(1,string.len(number)-1).."B"
        end
    elseif number > 999999 then
        number = tostring(srslylawlUI.Utils_ScuffedRound(number/100000))
        if number:sub(string.len(number),string.len(number)) ~= '0' then
            number = number:sub(1,string.len(number)-1).."."..number:sub(string.len(number)).."M"
        else
            number = number:sub(1,string.len(number)-1).."M"
        end
    elseif number > 999 then
        number = tostring(srslylawlUI.Utils_ScuffedRound(number/100))
        if number:sub(string.len(number),string.len(number)) ~= '0' then
            number = number:sub(1,string.len(number)-1).."."..number:sub(string.len(number)).."K"
        else
            number = number:sub(1,string.len(number)-1).."K"
        end
    end
    return number
end
function srslylawlUI.TranslateFrameAnchor(anchor)
    if type(anchor) == "string" then
        if anchor == "Screen" then
            return nil
        elseif anchor == "PlayerFrame" then
            return srslylawlUI.mainUnits.player.unitFrame.unit
        elseif anchor == "TargetFrame" then
            return srslylawlUI.mainUnits.target.unitFrame.unit
        elseif anchor == "TargetFramePortrait" then
            return srslylawlUI.mainUnits.target.unitFrame.portrait
        end
    elseif type(anchor) == "table" then
        if anchor == srslylawlUI.mainUnits.player.unitFrame.unit then
            return "PlayerFrame"
        elseif anchor == srslylawlUI.mainUnits.target.unitFrame.unit then
            return "TargetFrame"
        elseif anchor == nil or UIParent then
            return "Screen"
        elseif anchor == srslylawlUI.mainUnits.target.unitFrame.portrait then
            return "TargetFramePortrait"
        end
    elseif anchor == nil then
        return "Screen"
    end
end
function srslylawlUI.Debug()
    if srslylawlUI.DebugWindow == nil then
        srslylawlUI.DebugWindow = CreateFrame("Frame", "srslylawlUI_DebugWindow", UIParent)
        srslylawlUI.DebugWindow:SetSize(500, 500)
        srslylawlUI.DebugWindow:SetPoint("CENTER")
        local scrollFrame = CreateFrame("ScrollFrame", "$parent_ScrollFrame", srslylawlUI.DebugWindow, "UIPanelScrollFrameTemplate,BackdropTemplate")
        scrollFrame:SetAllPoints()
        scrollFrame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 12,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
            })
        scrollFrame:SetBackdropColor(0.05, 0.05, .05, .5)
        srslylawlUI.DebugWindow.ScrollFrame = scrollFrame

        local editBox = CreateFrame("EditBox", "$parent_EditBox", srslylawlUI.DebugWindow.ScrollFrame)
        scrollFrame:SetScrollChild(editBox)
        editBox:SetTextInsets(5, 5, 15, 15)
        editBox:SetSize(450, 200)
        editBox:SetPoint("TOPLEFT")
        editBox:SetAutoFocus(false)
        editBox:SetFont("Fonts\\FRIZQT__.TTF", 10)
        editBox:SetNumeric(false)
        editBox:SetMultiLine(true)
        editBox:SetFontObject(ChatFontNormal)
        srslylawlUI.DebugWindow.EditBox = editBox
        srslylawlUI.DebugWindow.CloseButton = CreateFrame("Button", "srslylawlUI_DebugWindow_CloseButton", srslylawlUI.DebugWindow, "UIPanelCloseButton")
        srslylawlUI.DebugWindow.CloseButton:SetPoint("BOTTOMLEFT", srslylawlUI.DebugWindow, "TOPRIGHT", 0, 0)
        local text = "Debug \n"
        debugString = text
    end


    srslylawlUI.DebugWindow.EditBox:SetText(debugString)
    srslylawlUI.DebugWindow:Show()
end

function srslylawlUI.GetPartyHealth()

    local nameStringSortedByHealthDesc = {}
    local hasUnknownMember = false

    local highestHP, averageHP, memberCount = 0, 0, 0

    local currentUnit = "player"
    local partyIndex = 0
    if not UnitExists("player") then
        --error("player doesnt exist?")
        return nil
    else
        -- loop through all units
        repeat
            if unitHealthBars[currentUnit] == nil then
                unitHealthBars[currentUnit] = {}
            end
            local maxHealth = UnitHealthMax(currentUnit)
            if maxHealth > highestHP then highestHP = maxHealth end
            local name = srslylawlUI.Utils_GetUnitNameWithServer(currentUnit)

            if name == "Unknown" or maxHealth == 1 then
                hasUnknownMember = true
            end

            unitHealthBars[currentUnit]["maxHealth"] = maxHealth
            unitHealthBars[currentUnit]["unit"] = currentUnit
            unitHealthBars[currentUnit]["name"] = name

            averageHP = averageHP + maxHealth
            table.insert(nameStringSortedByHealthDesc,
                         unitHealthBars[currentUnit])
            memberCount = memberCount + 1
            currentUnit = "party" .. memberCount
        until not UnitExists(currentUnit)
    end

    table.sort(nameStringSortedByHealthDesc,
               function(a, b) return b.maxHealth < a.maxHealth end)
    averageHP = floor(averageHP / memberCount)

    return nameStringSortedByHealthDesc, highestHP, averageHP, hasUnknownMember
end
--Auras
function srslylawlUI.GetBuffText(buffIndex, unit)
    tooltipTextGrabber:SetOwner(srslylawlUI_PartyHeader, "ANCHOR_NONE")
    tooltipTextGrabber:SetUnitBuff(unit, buffIndex)
    local n2 = srslylawl_TooltipTextGrabberTextLeft2:GetText()
    tooltipTextGrabber:Hide()
    return n2
end
function srslylawlUI.GetDebuffText(debuffIndex, unit)
    tooltipTextGrabber:SetOwner(srslylawlUI_PartyHeader, "ANCHOR_NONE")
    tooltipTextGrabber:SetUnitDebuff(unit, debuffIndex)
    local n2 = srslylawl_TooltipTextGrabberTextLeft2:GetText()
    tooltipTextGrabber:Hide()
    return n2
end
function srslylawlUI.HandleAuras(unitbutton, unit)
    local unitsType = unitbutton:GetAttribute("unitsType")
    local function GetTypeOfAuraID(spellId)
        local auraType = nil
        if srslylawlUI_Saved.buffs.absorbs[spellId] ~= nil then
            auraType = "absorb"
        elseif srslylawlUI_Saved.buffs.defensives[spellId] ~= nil then
            --make sure that this instance actually is a defensive spell. for example, rogues feint will be updated dynamically and only be flagged as defensive when its actually talented
            auraType = srslylawlUI_Saved.buffs.known[spellId].isDefensive and "defensive" or nil
        end

        return auraType
    end
    local function TrackAura(source, spellId, count, name, index, absorb, icon, duration, expirationTime, auraType, verify)
        if auraType == nil then error("auraType is nil") end

        local byAura = auraType .. "Auras"
        local byIndex = "trackedAurasByIndex"

        if verify == nil or verify == false then end
        if source == nil then source = "unknown" end

        local aura = {["name"] = name, ["index"] = index}
        if srslylawlUI[unitsType][unit][byAura][source] == nil then
            srslylawlUI[unitsType][unit][byAura][source] = {[spellId] = aura}
        else
            srslylawlUI[unitsType][unit][byAura][source][spellId] = aura
        end

        local diff = 0
        if verify then
            if srslylawlUI[unitsType][unit][byIndex][index] ~= nil and
                srslylawlUI[unitsType][unit][byIndex][index].expiration ~= nil then
                diff = expirationTime - srslylawlUI[unitsType][unit][byIndex][index].expiration
            end
        end

        local flagRefreshed = (diff > 0.01)

        if srslylawlUI[unitsType][unit][byIndex][index] == nil then
            srslylawlUI[unitsType][unit][byIndex][index] = {}
        end
        local t = srslylawlUI[unitsType][unit][byIndex][index]
        -- doing it this way since we dont want our tracked fragment to reset
        t["source"] = source
        t["name"] = name
        t["spellId"] = spellId
        t["checkedThisEvent"] = true
        t["absorb"] = absorb
        t["icon"] = icon
        t["duration"] = duration
        t["expiration"] = expirationTime
        t["wasRefreshed"] = flagRefreshed
        t["index"] = index -- double index here to make it easier to get it again for tooltip
        t["auraType"] = auraType
        t["stacks"] = count
    end
    local function UntrackAura(index)
        local byIndex = "trackedAurasByIndex"
        local auraType = srslylawlUI[unitsType][unit][byIndex][index].auraType
        if auraType == nil then error("auraType is nil") end
        local byAura = auraType .. "Auras"

        if srslylawlUI[unitsType][unit][byIndex][index].source == nil then
            error("error while untracking an aura", srslylawlUI[unitsType][unit][byIndex][index].name)
        end

        local src = srslylawlUI[unitsType][unit][byIndex][index].source

        local s = srslylawlUI[unitsType][unit][byIndex][index].spellId

        if srslylawlUI[unitsType][unit][byAura][src] == nil or srslylawlUI[unitsType][unit][byAura][src][s] == nil then
            --error("error while untracking an aura", units[unit][byIndex][index].name)
        end

        srslylawlUI[unitsType][unit][byIndex][index] = nil

        if srslylawlUI[unitsType][unit][byAura][src] == nil then
            return;
        end
        srslylawlUI[unitsType][unit][byAura][src][s] = nil
        local t = srslylawlUI.Utils_GetTableLength(srslylawlUI[unitsType][unit][byAura][src])

        --No more auras being tracked for that unit, untrack source
        if t == 0 then srslylawlUI[unitsType][unit][byAura][src] = nil end
    end
    local function ChangeTrackingIndex(name, source, count, spellId, currentIndex, absorb, icon, duration, expirationTime, auraType)
        -- srslylawlUI.Log("index changed " .. name)
        local byAura = auraType .. "Auras"
        local byIndex = "trackedAurasByIndex"
        local oldIndex = srslylawlUI[unitsType][unit][byAura][source][spellId].index
        assert(oldIndex ~= nil)
        -- assign to current
        srslylawlUI[unitsType][unit][byAura][source][spellId].index = currentIndex

        -- flag for timer refresh
        local diff = 0
        if srslylawlUI[unitsType][unit][byIndex][oldIndex] ~= nil and srslylawlUI[unitsType][unit][byIndex][oldIndex].expiration ~= nil then
            diff = expirationTime - srslylawlUI[unitsType][unit][byIndex][oldIndex].expiration
        end

        local flagRefreshed = (diff > 0.1)

        if srslylawlUI[unitsType][unit][byIndex][currentIndex] == nil then
            srslylawlUI[unitsType][unit][byIndex][currentIndex] = {}
        end
        local t = srslylawlUI[unitsType][unit][byIndex][currentIndex]
        t["source"] = source
        t["name"] = name
        t["spellId"] = spellId
        t["checkedThisEvent"] = true
        t["absorb"] = absorb
        t["icon"] = icon
        t["duration"] = duration
        t["expiration"] = expirationTime
        t["wasRefreshed"] = flagRefreshed
        t["index"] = currentIndex
        t["stacks"] = count
        t["auraType"] = auraType
        
        --TODO: nil here
        if srslylawlUI[unitsType][unit][byIndex] and srslylawlUI[unitsType][unit][byIndex][oldIndex] then
            local tat = srslylawlUI[unitsType][unit][byIndex][oldIndex].trackedApplyTime
            if tat then
                t["trackedApplyTime"] = tat
            end
        end

        srslylawlUI[unitsType][unit][byIndex][oldIndex] = nil
    end
    local function IsAuraBeingTrackedAtOtherIndex(source, spellId, auraType)
        if srslylawlUI[unitsType][unit][auraType .. "Auras"][source] == nil then
            return false
        elseif srslylawlUI[unitsType][unit][auraType .. "Auras"][source][spellId] == nil then
            return false
        else
            return true
        end
    end
    local function AuraIsBeingTrackedAtIndex(index)
        return srslylawlUI[unitsType][unit].trackedAurasByIndex[index] ~= nil
    end
    local function ProcessAuraTracking(name, source, count, spellId, i, absorb, icon, duration, expirationTime, auraType)
        if IsAuraBeingTrackedAtOtherIndex(source, spellId, auraType) then
            -- aura is being tracked but at another index, change that
            ChangeTrackingIndex(name, source, count, spellId, i, absorb, icon, duration, expirationTime, auraType)
        else
            -- aura is not tracked at all, track it!
            TrackAura(source, spellId, count, name, i, absorb, icon, duration,
                      expirationTime, auraType)
        end
    end

    -- reset frame check verifier
    for k, v in pairs(srslylawlUI[unitsType][unit].trackedAurasByIndex) do
        v["checkedThisEvent"] = false
    end
    -- process buffs on unit
    local auraPointsChanged = false
    local buffBaseColor = srslylawlUI.GetSetting("colors.buffBaseColor")
    local buffIsStealableColor = srslylawlUI.GetSetting("colors.buffIsStealableColor")
    local buffIsEnemyColor = srslylawlUI.GetSetting("colors.buffIsEnemyColor")
    local currentBuffFrame = 1
    local maxBuffs = srslylawlUI.GetSettingByUnit("buffs.maxBuffs", unitsType, unit)
    local buffSize = srslylawlUI.GetSettingByUnit("buffs.size", unitsType, unit)
    local scaledBuffSize = buffSize + srslylawlUI.GetSettingByUnit("buffs.scaledSize", unitsType, unit)
    local size
    for i = 1, 40 do
        -- loop through all buffs and assign them to frames
        local f = srslylawlUI[unitsType][unit].buffFrames[currentBuffFrame]
        local name, icon, count, debuffType, duration, expirationTime, source,
              isStealable, nameplateShowPersonal, spellId, canApplyAura,
              isBossDebuff, castByPlayer, nameplateShowAll, timeMod, absorb =
            UnitAura(unit, i, "HELPFUL")
            if name then -- if aura on this index exists, assign it
            srslylawlUI.Auras_RememberBuff(i, unit)
            if srslylawlUI.Auras_ShouldDisplayBuff(unitsType, unit, UnitAura(unit, i, "HELPFUL")) and currentBuffFrame <= maxBuffs then
                CompactUnitFrame_UtilSetBuff(f, i, UnitAura(unit, i))
                if isStealable then
	                f.border:SetVertexColor(unpack(buffIsStealableColor))
                    size = scaledBuffSize
                elseif source and UnitIsEnemy(source, "player") then
                    f.border:SetVertexColor(unpack(buffIsEnemyColor))
                    size = buffSize
                elseif unitsType == "mainUnits" and source and UnitIsUnit(source, "player") and unit == "player" then
                    f.border:SetVertexColor(unpack(buffBaseColor))
                    size = scaledBuffSize
                else
                    f.border:SetVertexColor(unpack(buffBaseColor))
                    size = buffSize
                end
                if size ~= f.size then
                    f.size = size
                    auraPointsChanged = true
                end
                f:SetID(i)
                f:Show()
                currentBuffFrame = currentBuffFrame + 1
            end
            -- track auras, check if we care to track it
            local auraType = GetTypeOfAuraID(spellId)

            if auraType ~= nil then
                if AuraIsBeingTrackedAtIndex(i) then
                    if srslylawlUI[unitsType][unit].trackedAurasByIndex[i]["spellId"] ~= spellId then
                        -- different spell is being tracked
                        UntrackAura(i)
                        ProcessAuraTracking(name, source, count, spellId, i, absorb, icon, duration, expirationTime, auraType)
                    else
                        -- aura is tracked and at same index, update that we verified that this frame
                        TrackAura(source, spellId, count, name, i, absorb, icon, duration, expirationTime, auraType, true)
                    end
                else
                    -- no aura is currently tracked for that index
                    ProcessAuraTracking(name, source, count, spellId, i, absorb, icon, duration, expirationTime, auraType)
                end
            else
                if AuraIsBeingTrackedAtIndex(i) then
                    UntrackAura(i)
                end
            end
        end
    end
    for i = currentBuffFrame, 40 do
        local f = srslylawlUI[unitsType][unit].buffFrames[i]
        if f then
            f:Hide()
        end
    end
    -- process debuffs on unit

    local appliedCC = {}
    currentDebuffFrame = 1

    local debuffSize = srslylawlUI.GetSettingByUnit("debuffs.size", unitsType, unit)
    local scaledDebuffSize = debuffSize + srslylawlUI.GetSettingByUnit("debuffs.scaledSize", unitsType, unit)
    local maxDebuffs = srslylawlUI.GetSettingByUnit("debuffs.maxDebuffs", unitsType, unit)
    for i = 1, 40 do
        local f = srslylawlUI[unitsType][unit].debuffFrames[currentDebuffFrame]
        local name, icon, count, debuffType, duration, expirationTime, source,
              isStealable, nameplateShowPersonal, spellId, canApplyAura,
              isBossDebuff, castByPlayer, nameplateShowAll, timeMod, absorb =
            UnitAura(unit, i, "HARMFUL")
        if name then -- if aura on this index exists, assign it
            srslylawlUI.Auras_RememberDebuff(spellId, i, unit)
            --check if its CC
            if srslylawlUI_Saved.debuffs.known[spellId] ~= nil and srslylawlUI_Saved.debuffs.known[spellId].crowdControlType ~= "none" and srslylawlUI_Saved.debuffs.blackList[spellId] == nil then
                local cc = {
                    ["ID"] = spellId,
                    ["index"] = i,
                    ["expirationTime"] = expirationTime,
                    ["icon"] = icon,
                    ["debuffType"] = debuffType,
                    ["ccType"] = srslylawlUI_Saved.debuffs.known[spellId].crowdControlType,
                    ["remaining"] = expirationTime-GetTime()
                }
                table.insert(appliedCC, cc)
            end
            if srslylawlUI.Auras_ShouldDisplayDebuff(unitsType, unit, UnitAura(unit, i, "HARMFUL")) and currentDebuffFrame <= maxDebuffs then
                f.icon:SetTexture(icon)
                if ( count > 1 ) then
		            local countText = count;
		            if ( count >= 100 ) then
			            countText = BUFF_STACKS_OVERFLOW;
		            end
		            f.count:Show();
		            f.count:SetText(countText);
	            elseif f then
		            f.count:Hide();
	            end
                f:SetID(i)
                local enabled = expirationTime and expirationTime ~= 0;
	            if enabled then
		            local startTime = expirationTime - duration;
		            CooldownFrame_Set(f.cooldown, startTime, duration, true);
	            else
		            CooldownFrame_Clear(f.cooldown);
                end
                local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
	            f.border:SetVertexColor(color.r, color.g, color.b);

                if source and source == "player" then
                    size = scaledDebuffSize
                else
                    size = debuffSize
                end

                if f.size ~= size then
                    f.size = size
                    auraPointsChanged = true
                end
                f:Show()
                currentDebuffFrame = currentDebuffFrame + 1
            end
        end
    end
    for i = currentDebuffFrame, 40 do
        local f = srslylawlUI[unitsType][unit].debuffFrames[i]
        if f then
            f:Hide()
        end
    end
    if auraPointsChanged then
        srslylawlUI.SetAuraPointsAll(unit, unitsType)
    end

    --see if we want to display our cced frame
    local displayCC = #appliedCC > 0
    if unitsType == "partyUnits" then
        displayCC = displayCC and srslylawlUI.GetSetting("party.ccbar.enabled")
    elseif unit == "target" then
        displayCC = displayCC and not srslylawlUI.GetSetting("player.targetFrame.ccbar.disabled")
    end
    if displayCC and unitbutton.CCDurBar then
        --Decide which cc to display
        table.sort(appliedCC, function(a, b) return b.remaining < a.remaining end)
        local CCToDisplay = appliedCC[1]

        if CCToDisplay.ccType == "roots" then
            --if we picked a root, see if theres a hardcc applied as well, and if yes, display it instead
            for i=2, #appliedCC do
                if appliedCC[i].ccType ~= "roots" then
                    CCToDisplay = appliedCC[i]
                    break
                end
            end
        end
        local color = DebuffTypeColor[CCToDisplay.debuffType] or DebuffTypeColor["none"];

        local exists = unitbutton.CCDurBar.spellData ~= nil
        local differentSpell = exists and unitbutton.CCDurBar.spellData.ID ~= CCToDisplay.ID
        local differentExpTime = exists and unitbutton.CCDurBar.spellData.expirationTime ~= CCToDisplay.expirationTime
        local differentIndex = exists and unitbutton.CCDurBar.spellData.index ~= CCToDisplay.index

        --See if its already being displayed
        if not exists or differentSpell or differentExpTime or differentIndex then
            --not being displayed
            unitbutton.CCDurBar.spellData = CCToDisplay
            unitbutton.CCDurBar.icon:SetTexture(CCToDisplay.icon)
            unitbutton.CCDurBar.statusBar:SetStatusBarColor(color.r, color.g, color.b)
            local timer, duration, expirationTime, remaining = 0, 0, 0, 0
            local updateInterval = 0.02
            remaining = expirationTime-GetTime()
            unitbutton.CCDurBar.statusBar:SetValue(remaining/duration)
            local timerstring = tostring(remaining)
            timerstring = timerstring:match("%d+%p?%d")
            unitbutton.CCDurBar.timer:SetText(timerstring)

            unitbutton.CCDurBar:SetScript("OnUpdate",
                function(self, elapsed)
                    timer = timer + elapsed
                    _, _, _, _, duration, expirationTime = UnitAura(unit, self.spellData.index, "HARMFUL")
                    if expirationTime == nil then return end
                    if timer >= updateInterval then
                        if duration == 0 then
                            self.statusBar:SetValue(1)
                            self.timer:SetText("")
                        else
                            remaining = expirationTime-GetTime()
                            self.statusBar:SetValue(remaining/duration)
                            timerstring = tostring(remaining)
                            timerstring = timerstring:match("%d+%p?%d")
                            self.timer:SetText(timerstring)
                        end
                        timer = timer - updateInterval
                    end
                end)
        else
            --just update data
            unitbutton.CCDurBar.spellData = CCToDisplay
        end
        
    end
    if unitbutton.CCDurBar then
        unitbutton.CCDurBar:SetShown(displayCC)
    end
    -- we checked all frames, untrack any that are gone
    for k, v in pairs(srslylawlUI[unitsType][unit].trackedAurasByIndex) do
        if not v["checkedThisEvent"] then
            UntrackAura(k)
        end
    end

    -- -- we tracked all absorbs, now we have to visualize them
    srslylawlUI.HandleEffectiveHealth(srslylawlUI[unitsType][unit].trackedAurasByIndex, unit, unitsType)
    srslylawlUI.HandleAbsorbFrames(srslylawlUI[unitsType][unit].trackedAurasByIndex, unit, unitsType)
end
function srslylawlUI.Main_HandleAuras_ALL()
    for _, unit in pairs(srslylawlUI.mainUnitsTable) do
        if unit ~= "targettarget" then
            local f = srslylawlUI.Frame_GetFrameByUnit(unit, "mainUnits")
            if f.unit then
                srslylawlUI.HandleAuras(f.unit, unit)
            end
        end
    end
end
function srslylawlUI.Party_HandleAuras_ALL()
    for _k, unit in pairs(srslylawlUI.partyUnitsTable) do
        local f = srslylawlUI.Frame_GetFrameByUnit(unit, "partyUnits")

        if f.unit then
            srslylawlUI.HandleAuras(f.unit, unit)
        end
    end
end
function srslylawlUI.ChangeAbsorbSegment(frame, barWidth, absorbAmount, height, isHealPrediction)
    frame:SetAttribute("absorbAmount", absorbAmount)
    srslylawlUI.Utils_SetSizePixelPerfect(frame, barWidth, height)
    -- resize icon
    if isHealPrediction then
        frame.icon:Hide()
        frame.cooldown:Clear()
    else
        local minSize = 7
        local maxIconSize = floor(height * 0.8)
        if (barWidth < minSize) then
            --srslylawlUI.Utils_SetSizePixelPerfect(frame.icon, minSize, minSize)
            frame.icon:Hide()
        elseif (barWidth >= maxIconSize) then
            srslylawlUI.Utils_SetSizePixelPerfect(frame.icon, maxIconSize, maxIconSize)
            frame.icon:Show()
        else
            srslylawlUI.Utils_SetSizePixelPerfect(frame.icon, barWidth - 2, barWidth - 2)
            frame.icon:Show()
        end
    end
end
function srslylawlUI.MoveAbsorbAnchorWithHealth(unit, unitsType)
    local buttonFrame = srslylawlUI.Frame_GetFrameByUnit(unit, unitsType)
    local width = srslylawlUI.Utils_PixelFromScreenToCode(buttonFrame.unit.healthBar:GetWidth())
    local maxHP = UnitHealthMax(unit)
    local pixelPerHp = width / (maxHP ~= 0 and maxHP or 1)
    local playerCurrentHP = UnitHealth(unit)
    local baseAnchorOffset = playerCurrentHP * pixelPerHp
    local mergeOffset = 0
    local pixelOffset = 1
    if srslylawlUI[unitsType][unit]["absorbFramesOverlap"][1].isMerged then
        --offset by mergeamount
        mergeOffset = srslylawlUI[unitsType][unit]["absorbFramesOverlap"][1].mergeAmount + pixelOffset
    end
    srslylawlUI.Utils_SetPointPixelPerfect(srslylawlUI[unitsType][unit]["absorbFrames"][1], "TOPLEFT", buttonFrame.unit.healthBar,"TOPLEFT", baseAnchorOffset+pixelOffset, 0)
    srslylawlUI.Utils_SetPointPixelPerfect(srslylawlUI[unitsType][unit]["absorbFramesOverlap"][1], "TOPRIGHT", buttonFrame.unit.healthBar, "TOPLEFT", baseAnchorOffset+mergeOffset,0)
    srslylawlUI.Utils_SetPointPixelPerfect(srslylawlUI[unitsType][unit]["effectiveHealthFrames"][1], "TOPLEFT", buttonFrame.unit.healthBar,"TOPLEFT", baseAnchorOffset+pixelOffset-srslylawlUI[unitsType][unit]["effectiveHealthFrames"][1].offset, 0)
end
function srslylawlUI.Auras_ShouldDisplayBuff(unitsType, unit, ...)
    local name, icon, count, debuffType, duration, expirationTime, source,
              isStealable, nameplateShowPersonal, spellId, canApplyAura,
              isBossDebuff, castByPlayer, nameplateShowAll, timeMod, absorb = ...

    local function NotDefault(bool)
        return bool ~= srslylawlUI.GetSettingByUnit("buffs.showDefault", unitsType, unit)
    end
    if srslylawlUI_Saved.buffs.whiteList[spellId] then
        --always show whitelisted spells
        return true
    end

    if srslylawlUI_Saved.buffs.blackList[spellId] then
        --never show blacklisted spells
        return false
    end

    if srslylawlUI_Saved.buffs.absorbs[spellId] then
        --dont show absorb spells unless whitelisted
        return false
    end

    if srslylawlUI_Saved.buffs.defensives[spellId] then
        --its a defensive spell
        return srslylawlUI.GetSettingByUnit("buffs.showDefensives", unitsType, unit)
    end

    if duration == 0 then
        return srslylawlUI.GetSettingByUnit("buffs.showInfiniteDuration", unitsType, unit)
    end
    if duration > srslylawlUI.GetSettingByUnit("buffs.maxDuration", unitsType, unit) then
        return srslylawlUI.GetSettingByUnit("buffs.showLongDuration", unitsType, unit)
    end

    if source == "player" and castByPlayer then
        local b = srslylawlUI.GetSettingByUnit("buffs.showCastByPlayer", unitsType, unit)
        if NotDefault(b) then
            return b
        end
    end


    return srslylawlUI.GetSettingByUnit("buffs.showDefault", unitsType, unit)
end
function srslylawlUI.Auras_ShouldDisplayDebuff(unitsType, unit, ...)
    local name, icon, count, debuffType, duration, expirationTime, source,
        isStealable, nameplateShowPersonal, spellId, canApplyAura,
        isBossDebuff, castByPlayer, nameplateShowAll, timeMod, absorb = ...

    local function NotDefault(bool)
        return bool ~= srslylawlUI.GetSettingByUnit("debuffs.showDefault", unitsType, unit)
    end
    if srslylawlUI_Saved.debuffs.whiteList[spellId] then
        --always show whitelisted spells
        return true
    end

    if srslylawlUI_Saved.debuffs.blackList[spellId] then
        --never show blacklisted spells
        return false
    end

    if source == "player" and castByPlayer then
        local b = srslylawlUI.GetSettingByUnit("debuffs.showCastByPlayer", unitsType, unit)
        if NotDefault(b) then
            return b
        end
    end

    if duration == 0 then
        local b = srslylawlUI.GetSettingByUnit("debuffs.showInfiniteDuration", unitsType, unit)
        if NotDefault(b) then
            return b
        end
    end

    if duration > srslylawlUI.GetSettingByUnit("debuffs.maxDuration", unitsType, unit) then
        local b = srslylawlUI.GetSettingByUnit("debuffs.showLongDuration", unitsType, unit)
        if NotDefault(b) then
            return b
        end
    end


    return srslylawlUI.GetSettingByUnit("debuffs.showDefault", unitsType, unit)
end
function srslylawlUI.Auras_RememberBuff(buffIndex, unit)
    local function GetPercentValue(tooltipText)
            -- %d+ = multiple numbers in a row
            -- %% = the % sign
            -- so we are looking for something like 15%
            local valueWithSign = tooltipText:match("%d*%.?%d+%%")

            if not valueWithSign then return 0 end
            -- remove the percent sign now

            local number = valueWithSign:match("%d+")

            return tonumber(number) or 0
    end
    local function ProcessID(buffIndex, unit)
        local spellName, icon, stacks, debuffType, duration, expirationTime, source,
              isStealable, nameplateShowPersonal, spellId, canApplyAura,
              isBossDebuff, castByPlayer, nameplateShowAll, timeMod, arg1 =
            UnitAura(unit, buffIndex, "HELPFUL")
        local buffText = srslylawlUI.GetBuffText(buffIndex, unit)
        local buffLower = buffText ~= nil and string.lower(buffText) or ""
        local keyWordAbsorb = srslylawlUI.Utils_StringHasKeyWord(buffLower, srslylawlUI.keyPhrases.absorbs) and ((arg1 ~= nil) and (arg1 > 1))
        local keyWordDefensive = srslylawlUI.Utils_StringHasKeyWord(buffLower, srslylawlUI.keyPhrases.defensive)
        local keyWordImmunity = srslylawlUI.Utils_StringHasKeyWord(buffLower, srslylawlUI.keyPhrases.immunity)
        local isKnown = srslylawlUI_Saved.buffs.known[spellId] ~= nil
        local autoDetectDisabled = isKnown and srslylawlUI_Saved.buffs.known[spellId].autoDetect ~= nil and srslylawlUI_Saved.buffs.known[spellId].autoDetect == false

        if autoDetectDisabled then
            srslylawlUI_Saved.buffs.known[spellId].text = buffText
            return
        end

        local spell = {
            name = spellName,
            text = buffText,
            isAbsorb = keyWordAbsorb,
            isDefensive = keyWordDefensive or keyWordImmunity
        }
        local link = GetSpellLink(spellId)

        if keyWordAbsorb then
            if (srslylawlUI_Saved.buffs.absorbs[spellId] == nil) then
                -- first time entry
                srslylawlUI.Log("new absorb spell " .. link .. " encountered!")
            else
                -- srslylawlUI.Log("spell updated " .. spellName .. "!")
            end

            srslylawlUI_Saved.buffs.absorbs[spellId] = spell
        elseif keyWordImmunity then
            
            spell.reductionAmount = 100
            
            if (srslylawlUI_Saved.buffs.defensives[spellId] == nil) then
                local log = "new defensive spell " .. link .. " encountered as immunity!"
                -- first time entry
                srslylawlUI.Log(log)
            end
            srslylawlUI_Saved.buffs.defensives[spellId] = spell
        elseif keyWordDefensive then
            local amount = GetPercentValue(buffLower)
            local log = "new defensive spell " .. link .. " encountered with a reduction of " .. amount .. "%!"

            if stacks ~= 0 then
                amount = amount / stacks
                log = "new defensive spell " .. link .. " encountered with a reduction of " .. amount .. "% per stack!"
            end

            if abs(amount) ~= 0 then
                spell.reductionAmount = amount
            else
                error("reduction amount is 0 " .. spellName .. " " .. buffText)
            end
            if (srslylawlUI_Saved.buffs.defensives[spellId] == nil) then
                -- first time entry
                srslylawlUI.Log(log)
            else
                -- srslylawlUI.Log("spell updated " .. spellName .. "!")
            end
            srslylawlUI_Saved.buffs.defensives[spellId] = spell
        end

        if isKnown then
            -- make sure not to replace any other keys
            for key, _ in pairs(spell) do
                srslylawlUI_Saved.buffs.known[spellId][key] = spell[key]
            end
        else
            --srslylawlUI.Log("new spell encountered: " .. spellName .. "!")
            -- Add spell to known spell list
            srslylawlUI_Saved.buffs.known[spellId] = spell
        end

    end

    ProcessID(buffIndex, unit)
end
function srslylawlUI.Auras_RememberDebuff(spellId, debuffIndex, unit)
    local function GetCrowdControlType(tooltipText)
        local s = string.lower(tooltipText)

        if s:match("stunned") then
            return "stuns"
        elseif s:match("silenced") then
            return "silences"
        elseif s:match("disoriented") or s:match("feared") then
            return "disorients"
        elseif s:match("incapacitated") or s:match("sleep") then
            return "incaps"    
        end

        if s:match("rooted") or s:match("immobilized") or s:match("frozen") or s:match("pinned in place") or s:match("immobile") then
            return "roots"
        end

        return "none"
    end
    local function ProcessID(spellId, debuffIndex, unit, arg1)
        local spellName = GetSpellInfo(spellId)
        local debuffText = srslylawlUI.GetDebuffText(debuffIndex, unit)
        local debuffLower = debuffText ~= nil and string.lower(debuffText) or ""

        local CCType = GetCrowdControlType(debuffLower)
        local isKnown = srslylawlUI_Saved.debuffs.known[spellId] ~= nil
        local autoDetectDisabled = isKnown and srslylawlUI_Saved.debuffs.known[spellId].autoDetect ~= nil and srslylawlUI_Saved.debuffs.known[spellId].autoDetect == false

        if autoDetectDisabled then
            --only update last parsed text
            srslylawlUI_Saved.debuffs.known[spellId].text = debuffText
            return
        end

        local spell = {
            name = spellName,
            text = debuffText,
            crowdControlType = CCType
        }
        local link = GetSpellLink(spellId)

        if CCType ~= "none" then
            if srslylawlUI_Saved.debuffs.known[spellId] == nil then
                -- first time entry
                srslylawlUI.Log("new crowd control spell " .. link .. " encountered!")
            else
                -- srslylawlUI.Log("spell updated " .. spellName .. "!")
            end

            srslylawlUI_Saved.debuffs[CCType][spellId] = spell
        end

        if isKnown then
            -- make sure not to replace any other keys
            for key, _ in pairs(spell) do
                srslylawlUI_Saved.debuffs.known[spellId][key] = spell[key]
            end
        else
            --srslylawlUI.Log("new spell encountered: " .. spellName .. "!")
            -- Add spell to known spell list
            srslylawlUI_Saved.debuffs.known[spellId] = spell
        end
    end

    ProcessID(spellId, debuffIndex, unit, arg1)
end
function srslylawlUI.Auras_ManuallyAddSpell(IDorName, auraType)
    -- we dont have the same tooltip that we get from unit buffindex and slot, so we dont save it
    -- it should get added/updated though once we ever see it on any party members

    local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(IDorName)

    if name == nil then
        if IDorName == "" or IDorName == nil then
            srslylawlUI.Log("No spell ID entered, type one into the textbox.")
        else
            srslylawlUI.Log("Spell " .. IDorName .. " not found. Make sure you typed the name/spell ID correctly.")
        end
        return
    end

    local link = GetSpellLink(spellId)

    local isKnown = srslylawlUI_Saved[auraType].known[spellId] ~= nil

    if isKnown then
        srslylawlUI.Log(link .. " is already known.")
    else
        local spell = {}
        spell.name = name
        spell.text = ""


        if auraType == "buffs" then
            spell.isAbsorb = false
            spell.isDefensive = false
        elseif auraType == "debuffs" then
            spell.crowdControlType = "none"
        end


        srslylawlUI_Saved[auraType].known[spellId] = spell
        srslylawlUI.Log("New spell added: " .. link .. "!")
    end
end
function srslylawlUI.Auras_ManuallyRemoveSpell(spellId, auraType)

    srslylawlUI_Saved[auraType].known[spellId] = nil
    local link = GetSpellLink(spellId)

    for k, category in pairs(srslylawlUI_Saved[auraType]) do
        if category[spellId] ~= nil then
            category[spellId] = nil
            srslylawlUI_Saved[auraType][k][spellId] = nil
            srslylawlUI.Log(link .. " removed from "..k.."!")
        end
    end

    srslylawlUI.Log(link .. " removed from " .. auraType .. "!")


    -- see if the spell is somewhere else, if not then put it to unapproved spells
    -- no longer needed since unapproved is now just a blacklist
    -- local isInAbsorbs = srslylawlUI.spells.absorbs[spellId] ~= nil
    -- local isInDefensives = srslylawlUI.spells.defensives[spellId] ~= nil
    -- local isInWhiteList = srslylawlUI.spells.whiteList[spellId] ~= nil
    -- local isInUnapproved = srslylawlUI.spells.blackList[spellId] ~= nil
    -- local isSomeWhere = isInAbsorbs or isInDefensives or isInWhiteList or
    --                         isInUnapproved or false

    -- if srslylawlUI.spells.blackList[spellId] == nil and not isSomeWhere then
    --     srslylawlUI.spells.blackList[spellId] = spell
    -- end
end
function srslylawlUI.Auras_BlacklistSpell(spellId, auraType)
    local spell = srslylawlUI_Saved[auraType].known[spellId]
    local str = spell.name

    srslylawlUI_Saved[auraType].blackList[spellId] = spell

    if srslylawlUI_Saved[auraType].whiteList[spellId] ~= nil then
        srslylawlUI_Saved[auraType].whiteList[spellID] = nil
        str = str .. " removed from whitelist and "
    end
    
    srslylawlUI.Log(str .. " blacklisted, will no longer be shown.")
end
function srslylawlUI.HandleAbsorbFrames(trackedAurasByIndex, unit, unitsType)
    local height, width
    local _, highestMaxHP
    if unitsType == "partyUnits" then
        height = srslylawlUI.GetSetting("party.hp.height")*0.7
        width = srslylawlUI.GetSetting("party.hp.width")
        _, highestMaxHP = srslylawlUI.GetPartyHealth()
    elseif unitsType == "mainUnits" then
        height = srslylawlUI.GetSetting("player."..unit.."Frame.hp.height")*0.7
        width = srslylawlUI.GetSetting("player."..unit.."Frame.hp.width")
        highestMaxHP = UnitHealthMax(unit)
    end
    local pixelPerHp = width / highestMaxHP
    local playerCurrentHP = UnitHealth(unit)
    local currentBarLength = playerCurrentHP * pixelPerHp
    local totalAbsorbBarLength = 0
    local overlapBarIndex, curBarIndex, curBarOverlapIndex = 1, 1, 1 --overlapBarIndex 1 means we havent filled the bar up with absorbs, 2 means we are now overlaying absorbs over the healthbar
    local variousAbsorbAmount = 0  -- some absorbs are too small to display, so we group them together and display them if they reach a certain amount
    local absorbSegments = {}
    local incomingHeal = UnitGetIncomingHeals(unit)
    local healAbsorb = UnitGetTotalHealAbsorbs(unit)
    local sortedAbsorbAuras, incomingHealWidth, variousFrameWidth, healAbsorbWidth
    local pixelSize = srslylawlUI.Utils_PixelFromCodeToScreen(1)

    local function NewAbsorbSegment(amount, width, sType, oIndex, tAura)
        return {
            ["amount"] = amount,
            ["width"] = width,
            ["tAura"] = tAura,
            ["sType"] = sType,
            ["oIndex"] = oIndex
        }
    end
    local function SortAbsorbBySpellIDDesc(absorbAuraTable)
        local t = {}
        for k, _ in pairs(absorbAuraTable) do
            if absorbAuraTable[k].auraType == "absorb" then
                t[#t + 1] = absorbAuraTable[k]
            end
        end
        table.sort(t, function(a, b) return b.spellId < a.spellId end)
        return t
    end
    local function CalcSegment(amount, sType, tAura)
        local absorbAmount = amount
        local barWidth
        if absorbAmount == nil then
            local errorMsg = "Aura " .. tAura.name .. " with ID " .. tAura.index .. " does not have an absorb amount. Make sure that it is the spellID of the actual buff, not of the spell that casts the buff."
            srslylawlUI.Log(errorMsg)
            return
        end
        while absorbAmount > 0 do
            barWidth = pixelPerHp * absorbAmount
            --caching the index so we display the segment correctly
            local oIndex = overlapBarIndex

            local pixelOverlap = (currentBarLength + barWidth) - width*overlapBarIndex
            --if we are already at overlapindex 2 and we have overlap, we are now at the left end of the bar
            --for now, ignore it and just let it stick out

            if pixelOverlap > 0 and overlapBarIndex < 3 then
                barWidth = barWidth-pixelOverlap
                if overlapBarIndex == 1 and barWidth > 1 then
                    barWidth = barWidth-1 --remove 1 for anchor spacing, if bar is smaller than 1 pixel it will be added to the last bar instead, thus no space necessary
                end
                absorbAmount = absorbAmount - barWidth/pixelPerHp
                overlapBarIndex = overlapBarIndex + 1
            elseif pixelOverlap <= 0 then
                absorbAmount = 0
            elseif overlapBarIndex == 3 then
                absorbAmount = 0
                barWidth = 0
            end

            local totalOverlap = (totalAbsorbBarLength + barWidth) - width
            if totalOverlap > 0 then
                barWidth = barWidth - totalOverlap
                absorbAmount = 0
            end

            totalAbsorbBarLength = totalAbsorbBarLength + barWidth

            if srslylawlUI.Utils_PixelRound(barWidth, pixelSize) >= 1 then
                currentBarLength = currentBarLength + barWidth + 1
                absorbSegments[#absorbSegments + 1] = NewAbsorbSegment(absorbAmount, barWidth, sType, oIndex, tAura)
            else
                if absorbSegments[#absorbSegments] then
                    absorbSegments[#absorbSegments].width = absorbSegments[#absorbSegments].width + barWidth
                    currentBarLength = currentBarLength + barWidth
                end
            end
        end
    end
    local function SetupSegment(tAura, bar, absorbAmount, barWidth, height)
        local iconID = tAura.icon
        local duration = tAura.duration
        local expirationTime = tAura.expiration
        local currentBar = bar
        srslylawlUI.ChangeAbsorbSegment(currentBar, barWidth, absorbAmount, height)
        local t
        if tAura.wasRefreshed or tAura["trackedApplyTime"] == nil then
            -- we only want to refresh the expiration timer if the aura has actually just been reapplied
            t = GetTime()
            duration = expirationTime - t
            tAura["trackedApplyTime"] = t
        else
            -- may display wrong time on certain auras that are still active if ui has just been reloaded, very niche case though
            t = tAura["trackedApplyTime"]
            duration = expirationTime - t
        end
        CooldownFrame_Set(currentBar.cooldown, t, duration, true)
        if currentBar.wasHealthPrediction then
            currentBar.texture:SetTexture(srslylawlUI.textures.AbsorbFrame)
            currentBar.texture:SetVertexColor(1, 1, 1, 0.9)
            currentBar.wasHealthPrediction = false
        end
        currentBar:SetAttribute("buffIndex", tAura.index)
        currentBar.icon:SetTexture(iconID)
        currentBar:Show()
    end
    local function DisplayFrames(absorbSegments)
        local segment, bar, pool, i, shouldMerge
        local roundingError = 0
        for k, _ in ipairs(absorbSegments) do
            segment = absorbSegments[k]
            i = segment.oIndex > 1 and curBarOverlapIndex or curBarIndex
            pool = segment.oIndex > 1 and srslylawlUI[unitsType][unit]["absorbFramesOverlap"] or srslylawlUI[unitsType][unit]["absorbFrames"]
            bar = pool[i]
            shouldMerge = false

            --these width values are "real" pixels, which will have to be rounded in order to be displayed correctly.
            --when we have multiple frames, this rounding can accumulate and cause us to be off by a few pixels
            --in order to achieve pixel perfection, we have to account for that here
            local rounded = srslylawlUI.Utils_PixelRound(segment.width, pixelSize)
            roundingError = roundingError + (rounded - segment.width)
            segment.width = rounded
            --see if this is the last frame for current index, and add the rounding error on top if it is
            if not absorbSegments[k+1] or absorbSegments[k+1].oIndex > segment.oIndex then
                segment.width = srslylawlUI.Utils_PixelRound(segment.width - roundingError, pixelSize)
                roundingError = 0
            end

            if k > 1 and segment.oIndex > 1 then
                local typeMatch = segment.sType == absorbSegments[1].sType
                local firstSegmentIsNotOverlap = absorbSegments[1].oIndex == 1
                local tAuraMatch = segment.tAura == absorbSegments[1].tAura

                if typeMatch and firstSegmentIsNotOverlap and tAuraMatch then
                    shouldMerge = true
                end
            end

            if shouldMerge then
                --hiding the non overlap frame and instead making the overlap frame bigger
                srslylawlUI[unitsType][unit]["absorbFrames"][1].hide = true
                bar.isMerged = true
                bar.mergeAmount = absorbSegments[1].width
                segment.width = segment.width + bar.mergeAmount
            end
            
            if segment.sType == "incomingHeal" then
                bar.texture:SetTexture(srslylawlUI.textures.HealthBar, ARTWORK)
                bar.texture:SetVertexColor(.2, .9, .1, .9)
                bar.wasHealthPrediction = true
                srslylawlUI.ChangeAbsorbSegment(bar, segment.width, segment.amount, height, true)
                bar:Show()
            elseif segment.sType == "healAbsorb" then
                bar.texture:SetTexture(srslylawlUI.textures.HealthBar, ARTWORK)
                bar.texture:SetVertexColor(.43, .01, .98, .9)
                bar.wasHealthPrediction = true
                srslylawlUI.ChangeAbsorbSegment(bar, segment.width, segment.amount, height, true)
                bar:Show()
            elseif segment.sType == "various" then
                if bar.wasHealthPrediction then
                    bar.texture:SetTexture(srslylawlUI.textures.AbsorbFrame)
                    bar.texture:SetVertexColor(1, 1, 1, 0.9)
                    bar.wasHealthPrediction = false
                end
                srslylawlUI.ChangeAbsorbSegment(bar, segment.width, segment.amount, height)
                bar:Show()
            else
                SetupSegment(segment.tAura, bar, segment.amount, segment.width, height)
            end
            bar.hide = false
            
            if segment.oIndex > 1 then
                curBarOverlapIndex = curBarOverlapIndex + 1
            else
                curBarIndex = curBarIndex + 1
            end
        end
    end
    sortedAbsorbAuras = SortAbsorbBySpellIDDesc(trackedAurasByIndex)

    if incomingHeal ~= nil then
        incomingHealWidth = floor(incomingHeal * pixelPerHp)
        if incomingHealWidth > 2 then
            CalcSegment(incomingHeal, "incomingHeal", nil)
        end
    end
    -- absorb auras seem to get consumed in order by their spellid, ascending (confirmed false)
    -- so we sort by descending to visualize which one gets removed first
    for _, value in ipairs(sortedAbsorbAuras) do
        CalcSegment(value.absorb, "aura", value)
    end
    variousFrameWidth = floor(variousAbsorbAmount * pixelPerHp)
    if variousFrameWidth >= 2 then
        CalcSegment(variousAbsorbAmount, "various", nil)
    end
    if healAbsorb > 0 then
        healAbsorbWidth = floor(healAbsorb * pixelPerHp)
        
        if healAbsorbWidth > 2 then
            CalcSegment(healAbsorb, "healAbsorb", nil)
        end
    end
    --flag all bars as hide
    for _, bar in pairs(srslylawlUI[unitsType][unit]["absorbFramesOverlap"]) do
        bar.hide = true
    end
    srslylawlUI[unitsType][unit]["absorbFramesOverlap"][1].isMerged = false
    for _, bar in pairs(srslylawlUI[unitsType][unit]["absorbFrames"]) do
        bar.hide = true
    end

    if #absorbSegments > 0 then
        DisplayFrames(absorbSegments)
    end


    --hide the ones we didnt use
    for _, bar in pairs(srslylawlUI[unitsType][unit]["absorbFramesOverlap"]) do
        if bar.hide then
            bar:Hide()
        end
    end
    for _, bar in pairs(srslylawlUI[unitsType][unit]["absorbFrames"]) do
        if bar.hide then
            bar:Hide()
        end
    end
        -- make sure that our first absorb anchor moves with the bar fill amount
    srslylawlUI.MoveAbsorbAnchorWithHealth(unit, unitsType)
end
function srslylawlUI.HandleEffectiveHealth(trackedAurasByIndex, unit, unitsType)
    local function FilterDefensives(trackedAuras)
        local sortedTable = {}
        for index, aura in pairs(trackedAuras) do
            if aura.auraType == "defensive" then
                table.insert(sortedTable, aura)
            end
        end

        table.sort(sortedTable, function(a, b)
            -- spells that expire first are last in the list
            if a.expiration > b.expiration then return true end
        end)

        return sortedTable
    end
    --Display effective health

    srslylawlUI[unitsType][unit].effectiveHealthSegments = FilterDefensives(trackedAurasByIndex)
    local effectiveHealthMod = 1
    if #srslylawlUI[unitsType][unit].effectiveHealthSegments > 0 then
        local stackMultiplier = 1
        local reducAmount
        for _, v in ipairs(srslylawlUI[unitsType][unit].effectiveHealthSegments) do
            stackMultiplier = v.stacks > 1 and v.stacks or 1
            reducAmount = srslylawlUI_Saved.buffs.known[v.spellId].reductionAmount / 100
    
            effectiveHealthMod = effectiveHealthMod * (1 - (reducAmount * stackMultiplier))
        end
    end
    local hasDefensive = effectiveHealthMod ~= 1
    local eHealth = -1
    local hpBar = srslylawlUI.Frame_GetFrameByUnit(unit, unitsType).unit.healthBar
    local showFrames = false
    if hasDefensive then
        local width = srslylawlUI.Utils_PixelFromScreenToCode(hpBar:GetWidth()) --need to convert here since we will later reapply the pixel scaling
        local height = srslylawlUI.Utils_PixelFromScreenToCode(hpBar:GetHeight())
        local playerHealthMax = UnitHealthMax(unit)
        local playerCurrentHP = UnitHealth(unit)
        local pixelPerHp = width / playerHealthMax
        local playerMissingHP = playerHealthMax - playerCurrentHP
        local maxWidth = playerMissingHP*pixelPerHp - 1
        local barWidth

        eHealth = playerCurrentHP / effectiveHealthMod
        local additionalHealth = eHealth - playerCurrentHP
        barWidth = math.min(pixelPerHp*playerHealthMax, additionalHealth * pixelPerHp)
        srslylawlUI[unitsType][unit]["effectiveHealthFrames"][1].offset = math.max(barWidth - maxWidth, 0)

        showFrames = barWidth >= 2
        if showFrames then
            srslylawlUI.ChangeAbsorbSegment(srslylawlUI[unitsType][unit]["effectiveHealthFrames"][1], barWidth, eHealth, height)
        end
        srslylawlUI[unitsType][unit]["effectiveHealthFrames"][1]:SetShown(showFrames)
    else
        srslylawlUI[unitsType][unit]["effectiveHealthFrames"][1]:Hide()
    end
end

--Config
function srslylawlUI.ToggleConfigVisible(visible)
    if visible then
        if not srslylawlUI_ConfigFrame then
            srslylawlUI.CreateConfigWindow()
        end
        srslylawlUI_ConfigFrame:Show()
    else
        srslylawlUI_ConfigFrame:Hide()
    end
end
function srslylawlUI.LoadSettings(reset, announce)
    if announce then srslylawlUI.Log("Settings Loaded") end

    if not srslylawlUI_Saved.settings or not srslylawlUI_Saved.settings.player then
        srslylawlUI_Saved.settings = srslylawlUI.Utils_TableDeepCopy(srslylawlUI.defaultSettings)
        srslylawlUI.Log("No saved settings found, default settings loaded.")
    end
    srslylawlUI.loadedSettings = srslylawlUI.Utils_TableDeepCopy(srslylawlUI_Saved.settings)

    for _, elementTable in pairs(srslylawlUI.ConfigElements) do
        for _, element in pairs(elementTable) do
            element:Reset()
        end
    end
    srslylawlUI.RemoveDirtyFlag()
    if reset then
        srslylawlUI.Frame_UpdateVisibility()
        srslylawlUI.UpdateEverything()
    end
end
function srslylawlUI.SaveSettings()
    srslylawlUI.Log("Settings Saved")
    srslylawlUI_Saved.settings = srslylawlUI.Utils_TableDeepCopy(srslylawlUI.loadedSettings)
    srslylawlUI.RemoveDirtyFlag()
end
function srslylawlUI.SetDirtyFlag()
    if srslylawlUI.unsaved.flag == true then return end
    srslylawlUI.unsaved.flag = true
    for _, v in ipairs(srslylawlUI.unsaved.buttons) do v:Enable() end
end
function srslylawlUI.RemoveDirtyFlag()
    srslylawlUI.unsaved.flag = false
    for _, v in ipairs(srslylawlUI.unsaved.buttons) do v:Disable() end
end
local function CreateValueAtPath(value, path, tableObject)
    local subTable = tableObject[path[1]]
    if subTable and type(subTable) == "table" and #path > 1 then
        table.remove(path, 1)
        CreateValueAtPath(value, path, subTable)
    elseif not subTable and #path > 1 then
        local path1 = path[1]
        table.remove(path, 1)
        tableObject[path1] = {}
        CreateValueAtPath(value, path, tableObject[path1])
    elseif #path == 1 then
        local n = tonumber(path[1])
        if n then
            tableObject[n] = value
        else
            tableObject[path[1]] = value
        end
    end
end
local function FindInTable(tableObject, path)
    if path and #path > 0 then
        if #path == 1 then
            local n = tonumber(path[1])
            if n then
                return tableObject[n]
            end
        end
        local entry = tableObject[path[1]]
        if entry and type(entry) == "table" then
            table.remove(path, 1)
            return FindInTable(entry, path)
        else
            return entry
        end
    else
        return tableObject
    end
end
local function SplitStringAtChar(str, splitChar)
    local t = {}
    local curr = ""
    for i=1, string.len(str) do 
       local c = string.sub(str, i, i)
       if c == splitChar then
          table.insert(t, curr)
          curr = ""
       else
          curr = curr .. c
       end
    end
    if curr ~= "" then
       table.insert(t, curr)
    end
    return t
end
function srslylawlUI.GetSetting(path, canBeNil)
    local pathTable = SplitStringAtChar(path, ".")
    local variable = FindInTable(srslylawlUI.loadedSettings, {unpack(pathTable)})
    if variable == nil then
        --not in loaded settings
        variable = FindInTable(srslylawlUI_Saved.settings, {unpack(pathTable)})
        if variable == nil then
            --not in saved settings
            variable = FindInTable(srslylawlUI.defaultSettings, {unpack(pathTable)})
            if variable == nil then
                --not in default settings either, doesnt exist
                if canBeNil then
                    return nil
                else
                    error("setting "..path.." does not exist")
                end
            else
                --found in default settings, just wasnt loaded
                local printVar = type(variable) ~= "table" and ": "..tostring(variable).." " or " "
                srslylawlUI.Log("Variable not found in saved settings: '" .. path .. "'. Default value"..printVar.."used instead. Seeing this message after updating this addon should be fine.")
                CreateValueAtPath(variable, pathTable, srslylawlUI_Saved.settings)
            end
        end
    end

    if type(variable) == "table" then
        variable = srslylawlUI.Utils_TableDeepCopy(variable)
    end
    return variable
end
function srslylawlUI.GetSettingByUnit(path, unitsType, unit, canBeNil)
    local s
    if unitsType == "partyUnits" or unitsType == "fauxUnits" then
        s = "party."..path
    elseif unit and unitsType == "mainUnits" or unitsType == "mainFauxUnits" then
        s = "player."..unit.."Frame."..path
    else
        error("couldnt get setting by unit")
    end

    return srslylawlUI.GetSetting(s, canBeNil)
end
function srslylawlUI.GetDefault(path)
    local pathTable = SplitStringAtChar(path, ".")
    local variable = FindInTable(srslylawlUI.defaultSettings, {unpack(pathTable)})
    if variable == nil then
        error("setting "..path.." does not exist")
    end

    if type(variable) == "table" then
        variable = srslylawlUI.Utils_TableDeepCopy(variable)
    end
    return variable
end
function srslylawlUI.GetDefaultByUnit(path, unitsType, unit)
    local s
    if unitsType == "partyUnits" or unitsType == "fauxUnits" then
        s = "party."..path
    elseif unit and unitsType == "mainUnits" or unitsType == "mainFauxUnits" then
        s = "player."..unit.."Frame."..path
    else
        error("couldn't get setting by unit")
    end
    return srslylawlUI.GetDefault(s)
end
function srslylawlUI.ChangeSetting(path, variable)
    local pathTable = SplitStringAtChar(path, ".")
    CreateValueAtPath(variable, pathTable, srslylawlUI.loadedSettings)
    srslylawlUI.SetDirtyFlag()
end

local function Initialize()
    local function CreateSlashCommands()
        -- Setting Slash Commands
        SLASH_SRSLYLAWLUI1 = "/srslylawlUI"
        SLASH_SRSLYLAWLUI2 = "/srslylawlUI"
        SLASH_SRSLYLAWLUI3 = "/srsUI"
        SLASH_SRSLYLAWLUI4 = "/srslylawl"
        SLASH_SRSLYLAWLUI5 = "/srslylawl save"
        SLASH_SRSLYLAWLUIDEBUG1 = "/srsdbg"

        SLASH_SRLYLAWLAPPROVESPELL1 = "/approvespell id"

        SlashCmdList["SRSLYLAWLUI"] = function(msg, txt)
            if InCombatLockdown() then
                srslylawlUI.Log("Can't access menu while in combat.")
                return
            end
            if msg and msg == "save" then
                srslylawlUI.SaveSettings()
            else
                srslylawlUI.ToggleConfigVisible(true)
            end
        end

        SlashCmdList["SRSLYLAWLUIDEBUG"] = function()
            srslylawlUI.Debug()
        end
    end
    local function HideBlizzardFrames()
        local function Hide(frame)
            frame:SetScript("OnEvent", nil)
            frame:Hide()
        end
        local showPlayer = srslylawlUI.GetSetting("blizzard.player.enabled")
        local showTarget = srslylawlUI.GetSetting("blizzard.target.enabled")
        local showParty = srslylawlUI.GetSetting("blizzard.party.enabled")
        local showCastbar = srslylawlUI.GetSetting("blizzard.castbar.enabled")
        local showAuras = srslylawlUI.GetSetting("blizzard.auras.enabled")

        if not showPlayer then
            Hide(PlayerFrame)
        end
        if not showTarget then
            Hide(TargetFrame)
        end
        if not showParty then
            for i=1, 4 do
                Hide(_G["PartyMemberFrame"..i])
            end
        end
        if not showCastbar then
            Hide(CastingBarFrame)
        end
        if not showAuras then
            Hide(BuffFrame)
        end

        UIParent:HookScript("OnHide", function(self)
            srslylawlUI.ToggleAllFrames(false)
        end)
        UIParent:HookScript("OnShow", function(self)
            srslylawlUI.ToggleAllFrames(true)
        end)
    end
    srslylawlUI.LoadSettings()
    srslylawlUI.FrameSetup()
    HideBlizzardFrames()
    CreateSlashCommands()
end
srslylawlUI_EventFrame = CreateFrame("Frame")
srslylawlUI_EventFrame:RegisterEvent("PLAYER_LOGIN")
srslylawlUI_EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
srslylawlUI_EventFrame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if (event == "PLAYER_LOGIN") then
        Initialize()
        srslylawlUI.SortAfterLogin()
        self:UnregisterEvent("PLAYER_LOGIN")
    elseif event == "UNIT_MAXHEALTH" or event == "GROUP_ROSTER_UPDATE" then
        -- delay since it bugs if it happens on the same frame for some reason
        if event == "UNIT_MAXHEALTH" and not (arg1 == "player" or arg1 == "party1" or arg1 == "party2" or arg1 == "party3" or arg1 == "party4") then
            --this event fires for all nameplates etc, but we only care about our party members
            return
        end
        C_Timer.After(.1, function()
            srslylawlUI.SortPartyFrames()
            srslylawlUI.Frame_ResizeHealthBarScale()
        end)

        if event == "GROUP_ROSTER_UPDATE" then
            srslylawlUI.Frame_UpdateVisibility()
            srslylawlUI.Party_HandleAuras_ALL()
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if not (arg1 or arg2) then
            -- just zoning between maps
        elseif arg1 then
            -- srslylawlUI.SortAfterLogin()
            -- since it takes a while for everything to load, we just wait until all our frames are visible before we do anything else
            srslylawlUI.SortPartyFrames()
        elseif arg2 then
            -- reload ui
            srslylawlUI.Frame_ResizeHealthBarScale()
            srslylawlUI.SortPartyFrames()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- regen enabled sort
        srslylawlUI.UpdateEverything()
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end)
-- since events seem to fire in arbitrary order after login, we use this frame for the first time the maxhealth event fires
srslylawlUI_FirstMaxHealthEventFrame = CreateFrame("Frame")
srslylawlUI_FirstMaxHealthEventFrame:RegisterEvent("UNIT_MAXHEALTH")
srslylawlUI_FirstMaxHealthEventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_MAXHEALTH" then
        srslylawlUI.SortAfterLogin()
        self:UnregisterEvent("UNIT_MAXHEALTH")
    end
end)