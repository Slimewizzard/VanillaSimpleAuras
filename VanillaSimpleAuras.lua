-- VanillaSimpleAuras.lua
-- Author: Slimewizzard

--------------------------------------------------------------------------------
-- Variables & Defaults
--------------------------------------------------------------------------------
VanillaSimpleAurasDB = VanillaSimpleAurasDB or {}
local defaults = {
    unlock = false,
    scale = 1.0,
    consumes = {}, -- key -> bool
    updateInterval = 0.2,
    consumeInterval = 5.0,
    items = {
        -- Example structure:
        -- { type = "SPELL", name = "Holy Shock", icon = "Spell_Holy_SearingLight", enabled = true },
        -- { type = "BUFF", name = "Judgement", icon = "Ability_Paladin_JudgementBlue", enabled = true },
    }
}

local VSA_PREDEFINED_CONSUMES = {
    { key = "food_salad", name = "Empowering Herbal Salad", icon = "inv_misc_food_salad", buff = "spell_nature_healingway" },
    { key = "elixir_dreamshard", name = "Dreamshard Elixir", icon = "inv_potion_113", buff = "inv_potion_113" },
}

local VSA_Frame = CreateFrame("Frame") -- Event handler frame
local VSA_AlertFrame = nil
local VSA_ConsumeFrame = nil
local VSA_OptionsFrame = nil
local VSA_ConsumeOptionsFrame = nil
local spellCache = {} -- Name -> ID mapping
local activeIcons = {} -- Reusable icon frames
local activeConsumeIcons = {} -- Reusable icon frames for consumes

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------
local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00FF00[VanillaSimpleAuras]|r " .. msg)
end

local function CopyDefaults(src, dst)
    if type(src) ~= "table" then return end
    if type(dst) ~= "table" then return end
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = dst[k] or {}
            CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

local function BuildSpellCache()
    spellCache = {}
    local i = 1
    while true do
        local spellName, rank = GetSpellName(i, BOOKTYPE_SPELL)
        if not spellName then break end
        spellCache[spellName] = i
        i = i + 1
    end
end

--------------------------------------------------------------------------------
-- Core Logic
--------------------------------------------------------------------------------
local function CheckCondition(item)
    if not item.enabled then return false, 0 end

    if item.type == "SPELL" then
        -- Check if spell is ready (cooldown == 0)
        -- We need to find the spell ID first
        local id = spellCache[item.name]
        if not id then 
            -- Try rebuilding cache if missing (maybe learned new spell)
            BuildSpellCache()
            id = spellCache[item.name]
        end
        
        if id then
            local start, duration, enabled = GetSpellCooldown(id, BOOKTYPE_SPELL)
            -- If start is 0, it's ready. checks if global cooldown is active roughly (gcd is usually short)
            -- However, GetSpellCooldown returns 0 if ready.
            if start == 0 and enabled == 1 then
                return true, 0
            end
        end

    elseif item.type == "BUFF" then
        -- Check if player has buff with matching icon
        -- Use GetPlayerBuff loop to access stack counts
        local i = 0
        while true do
            local buffIndex = GetPlayerBuff(i, "HELPFUL")
            if buffIndex == -1 then break end
            
            local texture = GetPlayerBuffTexture(buffIndex)
            
            if texture then
                -- User input might be "Ability_Paladin_JudgementBlue" or "Interface\\Icons\\Ability..."
                local normTexture = string.lower(texture)
                local searchIcon = string.lower(item.icon)
                
                if string.find(normTexture, searchIcon) then
                    local count = GetPlayerBuffApplications(buffIndex)
                    return true, count
                end
            end
            i = i + 1
        end
    end

    return false, 0
end

--------------------------------------------------------------------------------
-- Display / UI
--------------------------------------------------------------------------------
local function CreateIconFrame(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetWidth(40)
    f:SetHeight(40)
    
    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints(f)
    f.texture = tex
    
    local cd = f:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
    cd:SetPoint("CENTER", f, "CENTER", 0, 0)
    f.text = cd
    
    return f
end

local function UpdateConsumes()
    if not VSA_ConsumeFrame then return end
    
    -- Reset consume icons
    for _, icon in pairs(activeConsumeIcons) do icon:Hide() end



    local consumeCount = 0
    local iconSize = 40
    local spacing = 5
    
    for i, item in ipairs(VSA_PREDEFINED_CONSUMES) do
        -- Only check if enabled in DB
        if VanillaSimpleAurasDB.consumes[item.key] then
            -- Logic: Check if player has buff. If NOT, show icon.
            local found = false
            local k = 1
            while true do
                local texture = UnitBuff("player", k)
                if not texture then break end
                
                -- Check texture match
                if string.find(string.lower(texture), string.lower(item.buff)) then
                    found = true
                    break
                end
                k = k + 1
            end
            
            if not found then
                consumeCount = consumeCount + 1
                local icon = activeConsumeIcons[consumeCount]
                if not icon then
                    icon = CreateIconFrame(VSA_ConsumeFrame)
                    activeConsumeIcons[consumeCount] = icon
                end
                
                -- Set Icon
                local texPath = item.icon
                if not string.find(string.lower(texPath), "interface\\icons\\") then
                    texPath = "Interface\\Icons\\" .. texPath
                end
                icon.texture:SetTexture(texPath)
                
                icon:ClearAllPoints()
                icon:SetPoint("LEFT", VSA_ConsumeFrame, "LEFT", (consumeCount - 1) * (iconSize + spacing), 0)
                icon:Show()
            end
        end
    end
    if consumeCount > 0 then
        VSA_ConsumeFrame:SetWidth(consumeCount * iconSize + (consumeCount - 1) * spacing)
        VSA_ConsumeFrame:Show()
    else
        if VanillaSimpleAurasDB.unlock then
            VSA_ConsumeFrame:SetWidth(100)
            VSA_ConsumeFrame:SetAlpha(0.5)
            VSA_ConsumeFrame:Show()
        else
            VSA_ConsumeFrame:Hide()
        end
    end
end

local function UpdateDisplay()
    if not VSA_AlertFrame then return end
    
    -- Reset all icons
    for _, icon in pairs(activeIcons) do
        icon:Hide()
    end
    
    local activeCount = 0
    local iconSize = 40
    local spacing = 5
    
    for i, item in ipairs(VanillaSimpleAurasDB.items) do
        local active, count = CheckCondition(item)
        if active then
            activeCount = activeCount + 1
            
            -- Get or create icon frame
            local icon = activeIcons[activeCount]
            if not icon then
                icon = CreateIconFrame(VSA_AlertFrame)
                activeIcons[activeCount] = icon
            end
            
            -- Set Texture
            -- If user provided full path, use it. If just name, append path.
            local texPath = item.icon
            if not string.find(string.lower(texPath), "interface\\icons\\") then
                texPath = "Interface\\Icons\\" .. texPath
            end
            icon.texture:SetTexture(texPath)
            
            -- Set Stack Count
            if count and count > 1 then
                icon.text:SetText(count)
            else
                icon.text:SetText("")
            end
            
            -- Position
            icon:ClearAllPoints()
            -- Horizontal layout
            icon:SetPoint("LEFT", VSA_AlertFrame, "LEFT", (activeCount - 1) * (iconSize + spacing), 0)
            icon:Show()
        end
    end
    
    -- Resize container based on active count (optional, but good for centering if we wanted)
    if activeCount > 0 then
        VSA_AlertFrame:SetWidth(activeCount * iconSize + (activeCount - 1) * spacing)
        VSA_AlertFrame:Show()
    else
        -- Hide if nothing to show, UNLESS unlocked
        if VanillaSimpleAurasDB.unlock then
            VSA_AlertFrame:SetWidth(100)
            VSA_AlertFrame:SetAlpha(0.5)
            VSA_AlertFrame:Show()
        else
            VSA_AlertFrame:Hide()
        end
    end
end

local function CreateAlertFrame()
    local f = CreateFrame("Frame", "VanillaSimpleAurasAlertFrame", UIParent)
    f:SetWidth(100)
    f:SetHeight(40)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    
    -- Dragging
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function()
        if VanillaSimpleAurasDB.unlock then this:StartMoving() end
    end)
    f:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
        -- Save position if we wanted (SetPoint calls) but 1.12 usually saves automatically if setup right, or we manually save.
        -- For simplicity, we assume standard layout-cache. If not, we can add layout saving later.
    end)
    
    -- Background for unlock mode
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(f)
    bg:SetTexture(0, 0, 0, 0.5)
    f.bg = bg
    
    f:Hide()
    return f
end

--------------------------------------------------------------------------------
-- Options UI
--------------------------------------------------------------------------------
local function CreateConsumeFrame()
    local f = CreateFrame("Frame", "VanillaSimpleAurasConsumeFrame", UIParent)
    f:SetWidth(100)
    f:SetHeight(40)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, -50)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function()
        if VanillaSimpleAurasDB.unlock then this:StartMoving() end
    end)
    f:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
    end)
    
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(f)
    bg:SetTexture(0, 0, 0, 0.5)
    f.bg = bg
    
    local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER", f, "CENTER", 0, 0)
    label:SetText("Consumes")
    f.label = label

    f:Hide()
    return f
end

local function CreateOptionsFrame()
    -- Main Frame
    local f = CreateFrame("Frame", "VanillaSimpleAurasOptions", UIParent)
    f:SetWidth(550) -- Increased width to fit headers/buttons
    f:SetHeight(450)
    f:SetPoint("CENTER", UIParent, "CENTER")
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function() this:StartMoving() end)
    f:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    
    -- Title
    local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOP", f, "TOP", 0, -20)
    title:SetText("VanillaSimpleAuras Config")
    
    -- Close Button
    local close = CreateFrame("Button", "VanillaSimpleAurasCloseBtn", f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -5)
    
    -- Add New Section
    local yOffset = -60
    
    -- Name Input
    local nameInput = CreateFrame("EditBox", "VanillaSimpleAurasNameEdit", f, "InputBoxTemplate")
    nameInput:SetWidth(150)
    nameInput:SetHeight(20)
    nameInput:SetPoint("TOPLEFT", f, "TOPLEFT", 30, yOffset)
    nameInput:SetAutoFocus(false)
    
    local nameLabel = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    nameLabel:SetPoint("BOTTOMLEFT", nameInput, "TOPLEFT", 0, 0)
    nameLabel:SetText("Spell/Buff Name")
    
    -- Icon Input
    local iconInput = CreateFrame("EditBox", "VanillaSimpleAurasIconEdit", f, "InputBoxTemplate")
    iconInput:SetWidth(150)
    iconInput:SetHeight(20)
    iconInput:SetPoint("LEFT", nameInput, "RIGHT", 30, 0)
    iconInput:SetAutoFocus(false)
    
    local iconLabel = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    iconLabel:SetPoint("BOTTOMLEFT", iconInput, "TOPLEFT", 0, 0)
    iconLabel:SetText("Icon Name (e.g. Spell_Holy_...)")
    
    -- Type Toggle
    local typeButton = CreateFrame("Button", "VanillaSimpleAurasTypeBtn", f, "UIPanelButtonTemplate")
    typeButton:SetWidth(80)
    typeButton:SetHeight(22)
    typeButton:SetPoint("LEFT", iconInput, "RIGHT", 20, 0)
    typeButton:SetText("SPELL")
    f.addType = "SPELL"
    typeButton:SetScript("OnClick", function()
        if f.addType == "SPELL" then
            f.addType = "BUFF"
            this:SetText("BUFF")
        else
            f.addType = "SPELL"
            this:SetText("SPELL")
        end
    end)
    
    -- Add Button
    local addButton = CreateFrame("Button", "VanillaSimpleAurasAddBtn", f, "UIPanelButtonTemplate")
    addButton:SetWidth(60)
    addButton:SetHeight(22)
    addButton:SetPoint("LEFT", typeButton, "RIGHT", 5, 0)
    addButton:SetText("Add")
    addButton:SetScript("OnClick", function()
        local name = nameInput:GetText()
        local icon = iconInput:GetText()
        if name ~= "" and icon ~= "" then
            table.insert(VanillaSimpleAurasDB.items, {
                type = f.addType,
                name = name,
                icon = icon,
                enabled = true
            })
            Print("Added " .. f.addType .. ": " .. name)
            VSA_UpdateOptionsList()
            nameInput:SetText("")
            iconInput:SetText("")
            nameInput:ClearFocus()
            iconInput:ClearFocus()
        end
    end)
    
    -- Headers for List
    local listHeaderY = yOffset - 50
    local h1 = f:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    h1:SetPoint("TOPLEFT", f, "TOPLEFT", 30, listHeaderY)
    h1:SetText("Current Items")

    -- ScrollFrame Logic
    local scrollFrame = CreateFrame("ScrollFrame", "VanillaSimpleAurasScrollFrame", f, "FauxScrollFrameTemplate")
    scrollFrame:SetWidth(480)
    scrollFrame:SetHeight(200) -- visible height
    scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 30, listHeaderY - 20)
    
    -- Use a generic OnVerticalScroll handler
    scrollFrame:SetScript("OnVerticalScroll", function()
        FauxScrollFrame_OnVerticalScroll(20, VSA_UpdateOptionsList)
    end)
    
    f.scrollFrame = scrollFrame
    
    -- Row Container (visual rows)
    f.rows = {}
    local NUM_ROWS = 8
    for i = 1, NUM_ROWS do
        local row = CreateFrame("Frame", "VanillaSimpleAurasRow"..i, f)
        row:SetWidth(480)
        row:SetHeight(20)
        row:SetPoint("TOPLEFT", f, "TOPLEFT", 35, listHeaderY - 20 - (i-1)*20)
        
        -- Text
        local txt = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        txt:SetPoint("LEFT", row, "LEFT", 0, 0)
        txt:SetJustifyH("LEFT")
        txt:SetWidth(420)
        row.text = txt
        
        -- Delete
        local del = CreateFrame("Button", "VanillaSimpleAurasDel"..i, row, "UIPanelButtonTemplate")
        del:SetWidth(20)
        del:SetHeight(20)
        del:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        del:SetText("X")
        del:SetScript("OnClick", function()
            local idx = row.index
            if idx and VanillaSimpleAurasDB.items[idx] then
                table.remove(VanillaSimpleAurasDB.items, idx)
                VSA_UpdateOptionsList()
            end
        end)
        row.del = del
        
        f.rows[i] = row
    end
    
    -- Update Interval Slider
    local slider = CreateFrame("Slider", "VanillaSimpleAurasUpdateSlider", f, "OptionsSliderTemplate")
    slider:SetWidth(180)
    slider:SetHeight(16)
    slider:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 160, 25)
    slider:SetMinMaxValues(0.1, 2.0)
    slider:SetValueStep(0.1)
    slider:SetValue(VanillaSimpleAurasDB.updateInterval or 0.2)
    getglobal(slider:GetName() .. "Text"):SetText("Update Speed: " .. (VanillaSimpleAurasDB.updateInterval or 0.2) .. "s")
    getglobal(slider:GetName() .. "Low"):SetText("0.1")
    getglobal(slider:GetName() .. "High"):SetText("2.0")
    slider:SetScript("OnValueChanged", function()
        local val = math.floor(this:GetValue() * 10 + 0.5) / 10 -- Round to 1 decimal
        VanillaSimpleAurasDB.updateInterval = val
        getglobal(this:GetName() .. "Text"):SetText("Update Speed: " .. val .. "s")
    end)
    
    -- Unlock Button
    local unlockBtn = CreateFrame("Button", "VanillaSimpleAurasUnlockBtn", f, "UIPanelButtonTemplate")
    unlockBtn:SetWidth(120)
    unlockBtn:SetHeight(25)
    unlockBtn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 20, 20)
    unlockBtn:SetText(VanillaSimpleAurasDB.unlock and "Lock Frame" or "Unlock Frame")
    unlockBtn:SetScript("OnClick", function()
        VanillaSimpleAurasDB.unlock = not VanillaSimpleAurasDB.unlock
        this:SetText(VanillaSimpleAurasDB.unlock and "Lock Frame" or "Unlock Frame")
        if VanillaSimpleAurasDB.unlock then
            VSA_AlertFrame.bg:Show()
            VSA_AlertFrame:Show()
            VSA_AlertFrame:SetAlpha(1)
            
            VSA_ConsumeFrame.bg:Show()
            VSA_ConsumeFrame.label:Show()
            VSA_ConsumeFrame:Show()
            VSA_ConsumeFrame:SetAlpha(1)
        else
            VSA_AlertFrame.bg:Hide()
            VSA_ConsumeFrame.bg:Hide()
            VSA_ConsumeFrame.label:Hide()
            
            UpdateDisplay()
            UpdateConsumes()
        end
    end)

    -- "Consume List" Button
    local consumeBtn = CreateFrame("Button", "VanillaSimpleAurasConsumeBtn", f, "UIPanelButtonTemplate")
    consumeBtn:SetWidth(100)
    consumeBtn:SetHeight(25)
    consumeBtn:SetPoint("RIGHT", f, "BOTTOMRIGHT", -20, 20)
    consumeBtn:SetText("Consume List")
    consumeBtn:SetScript("OnClick", function()
        if VSA_ConsumeOptionsFrame:IsShown() then
            VSA_ConsumeOptionsFrame:Hide()
        else
            VSA_ConsumeOptionsFrame:Show()
        end
    end)
    
    f:Hide()
    return f
end

function VSA_UpdateOptionsList()
    if not VSA_OptionsFrame then return end
    
    local items = VanillaSimpleAurasDB.items or {}
    local numItems = table.getn(items)
    local NUM_ROWS = 8
    
    FauxScrollFrame_Update(VSA_OptionsFrame.scrollFrame, numItems, NUM_ROWS, 20)
    local offset = FauxScrollFrame_GetOffset(VSA_OptionsFrame.scrollFrame)
    
    for i = 1, NUM_ROWS do
        local row = VSA_OptionsFrame.rows[i]
        local idx = offset + i
        if idx <= numItems then
            local item = items[idx]
            row.text:SetText("["..item.type.."] " .. item.name .. " (" .. item.icon .. ")")
            row.index = idx
            row:Show()
        else
            row:Hide()
        end
    end
end

-- Side Window for Consumes
local function CreateConsumeOptionsFrame()
    local f = CreateFrame("Frame", "VanillaSimpleAurasConsumeOptions", UIParent)
    f:SetWidth(250)
    f:SetHeight(300)
    f:SetPoint("TOPLEFT", VSA_OptionsFrame, "TOPRIGHT", 0, 0)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:Hide() -- Hide immediately
    
    local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOP", f, "TOP", 0, -20)
    title:SetText("Consume List")
    
    -- Close
    local close = CreateFrame("Button", "VSA_ConsumeClose", f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -5)
    
    -- List container
    local yVal = -50
    for i, item in ipairs(VSA_PREDEFINED_CONSUMES) do
        local thisItem = item -- Capture for closure
        local cb = CreateFrame("CheckButton", "VSA_ConsumeCheck"..i, f, "OptionsCheckButtonTemplate")
        cb:SetWidth(24)
        cb:SetHeight(24)
        cb:SetPoint("TOPLEFT", f, "TOPLEFT", 20, yVal)
        
        cb.label = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        cb.label:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        cb.label:SetText(thisItem.name)
        
        -- Init
        cb:SetChecked(VanillaSimpleAurasDB.consumes[thisItem.key])
        
        cb:SetScript("OnClick", function()
             VanillaSimpleAurasDB.consumes[thisItem.key] = this:GetChecked() and true or nil
             UpdateConsumes()
        end)
        
        yVal = yVal - 30
    end
    
    -- Consume Interval Slider
    local slider = CreateFrame("Slider", "VanillaSimpleAurasConsumeSlider", f, "OptionsSliderTemplate")
    slider:SetWidth(180)
    slider:SetHeight(16)
    slider:SetPoint("BOTTOM", f, "BOTTOM", 0, 20)
    slider:SetMinMaxValues(1, 20)
    slider:SetValueStep(1)
    slider:SetValue(VanillaSimpleAurasDB.consumeInterval or 5.0)
    getglobal(slider:GetName() .. "Text"):SetText("Check Speed: " .. (VanillaSimpleAurasDB.consumeInterval or 5.0) .. "s")
    getglobal(slider:GetName() .. "Low"):SetText("1s")
    getglobal(slider:GetName() .. "High"):SetText("20s")
    slider:SetScript("OnValueChanged", function()
        local val = math.floor(this:GetValue() + 0.5) -- Round to integer
        VanillaSimpleAurasDB.consumeInterval = val
        getglobal(this:GetName() .. "Text"):SetText("Check Speed: " .. val .. "s")
    end)
    
    return f
end

local function VSA_Initialize()
    if VSA_OptionsFrame then return end -- Already initialized
    
    CopyDefaults(defaults, VanillaSimpleAurasDB)
    Print("Loaded. Type /vsa to configure.")
    
    VSA_AlertFrame = CreateAlertFrame()
    VSA_ConsumeFrame = CreateConsumeFrame()
    VSA_OptionsFrame = CreateOptionsFrame()
    VSA_ConsumeOptionsFrame = CreateConsumeOptionsFrame()
    
    -- Start loop
    VSA_Frame:SetScript("OnUpdate", function()
        this.timer = (this.timer or 0) + arg1
        this.consumeTimer = (this.consumeTimer or 0) + arg1
        
        -- High freq update for spells/timer accuracy
        if this.timer > (VanillaSimpleAurasDB.updateInterval or 0.2) then
            UpdateDisplay()
            this.timer = 0
        end
        
        -- Low freq update for Consumes (performance)
        if this.consumeTimer > (VanillaSimpleAurasDB.consumeInterval or 5.0) then
            UpdateConsumes()
            this.consumeTimer = 0
        end
    end)
end

VSA_Frame:RegisterEvent("ADDON_LOADED")
VSA_Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
VSA_Frame:RegisterEvent("SPELLS_CHANGED")

VSA_Frame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "VanillaSimpleAuras" then
        VSA_Initialize()
    elseif event == "PLAYER_ENTERING_WORLD" or event == "SPELLS_CHANGED" then
        BuildSpellCache()
    end
end)

--------------------------------------------------------------------------------
-- Slash Command
--------------------------------------------------------------------------------
SLASH_VANILLASIMPLEAURAS1 = "/vsa"
SLASH_VANILLASIMPLEAURAS2 = "/vanillasimpleauras"
SlashCmdList["VANILLASIMPLEAURAS"] = function(msg)
    if not VSA_OptionsFrame then VSA_Initialize() end
    
    if VSA_OptionsFrame:IsShown() then
        VSA_OptionsFrame:Hide()
        VSA_ConsumeOptionsFrame:Hide()
    else
        VSA_OptionsFrame:Show()
        VSA_UpdateOptionsList()
    end
end
