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
    -- Food
    { category = "Food", key = "food_dumplings", name = "Smoked Desert Dumplings", icon = "inv_misc_food_64", buff = "spell_misc_food" },
    { category = "Food", key = "food_squid", name = "Grilled Squid", icon = "inv_misc_fish_13", buff = "inv_gauntlets_19" },
    { category = "Food", key = "food_nightfin", name = "Nightfin Soup", icon = "inv_drink_17", buff = "spell_nature_manaregentotem" },
    { category = "Food", key = "food_runntum", name = "Runn Tum Tuber Surprise", icon = "inv_misc_food_63", buff = "inv_misc_organ_03" },
    { category = "Food", key = "food_dirges", name = "Dirge's Kickin' Chimaerok Chops", icon = "inv_misc_food_65", buff = "inv_boots_plate_03" },
    { category = "Food", key = "food_sagefish", name = "Sagefish Delight", icon = "inv_misc_fish_16", buff = "inv_misc_fish_16" },
    { category = "Food", key = "food_salmon", name = "Poached Sunscale Salmon", icon = "inv_misc_fish_15", buff = "inv_misc_fish_15" },
    { category = "Food", key = "food_sunfruit", name = "Blessed Sunfruit", icon = "inv_misc_food_41", buff = "inv_misc_food_41" },
    { category = "Food", key = "food_sunfruit_j", name = "Blessed Sunfruit Juice", icon = "inv_drink_13", buff = "inv_drink_13" },
    { category = "Food", key = "food_chili", name = "Dragonbreath Chili", icon = "inv_drink_23", buff = "spell_fire_incinerate" },
    { category = "Food", key = "food_fruit_sorbet", name = "Fruit Sorbet", icon = "inv_misc_food_56", buff = "spell_misc_food" },
    { category = "Food", key = "food_monster_omelet", name = "Monster Omelet", icon = "inv_misc_food_51", buff = "spell_misc_food" },

    -- Flasks
    { category = "Flasks", key = "flask_titans", name = "Flask of the Titans", icon = "inv_potion_62", buff = "inv_potion_62" },
    { category = "Flasks", key = "flask_supreme", name = "Flask of Supreme Power", icon = "inv_potion_41", buff = "inv_potion_41" },
    { category = "Flasks", key = "flask_wisdom", name = "Flask of Distilled Wisdom", icon = "inv_potion_120", buff = "inv_potion_120" },
    { category = "Flasks", key = "flask_chromatic", name = "Flask of Chromatic Resistance", icon = "inv_potion_63", buff = "inv_potion_63" },
    { category = "Flasks", key = "flask_petri", name = "Flask of Petrification", icon = "inv_potion_01", buff = "spell_shadow_teleport" },

    -- Elixirs
    { category = "Elixirs", key = "elixir_mongoose", name = "Elixir of the Mongoose", icon = "inv_potion_32", buff = "inv_potion_32" },
    { category = "Elixirs", key = "elixir_greater_agi", name = "Elixir of Greater Agility", icon = "inv_potion_94", buff = "inv_potion_94" },
    { category = "Elixirs", key = "elixir_brute_force", name = "Elixir of Brute Force", icon = "inv_potion_79", buff = "inv_potion_79" },
    { category = "Elixirs", key = "elixir_giants", name = "Elixir of Giants", icon = "inv_potion_61", buff = "inv_potion_61" },
    { category = "Elixirs", key = "elixir_fortitude", name = "Elixir of Fortitude", icon = "inv_potion_43", buff = "inv_potion_44" },
    { category = "Elixirs", key = "elixir_defense", name = "Elixir of Superior Defense", icon = "inv_potion_66", buff = "inv_potion_86" },
    { category = "Elixirs", key = "elixir_shadow", name = "Elixir of Shadow Power", icon = "inv_potion_46", buff = "inv_potion_46" },
    { category = "Elixirs", key = "elixir_firepower", name = "Elixir of Greater Firepower", icon = "inv_potion_60", buff = "inv_potion_60" },
    { category = "Elixirs", key = "elixir_frost", name = "Elixir of Frost Power", icon = "inv_potion_115", buff = "inv_potion_03" },
    { category = "Elixirs", key = "elixir_arcane", name = "Greater Arcane Elixir", icon = "inv_potion_25", buff = "inv_potion_25" },
    { category = "Elixirs", key = "elixir_sages", name = "Elixir of the Sages", icon = "inv_potion_78", buff = "inv_potion_78" },
    { category = "Elixirs", key = "juju_might", name = "Juju Might", icon = "inv_misc_monsterscales_07", buff = "inv_misc_monsterscales_07" },
    { category = "Elixirs", key = "juju_power", name = "Juju Power", icon = "inv_misc_monsterscales_11", buff = "inv_misc_monsterscales_11" },
    { category = "Elixirs", key = "juju_flurry", name = "Juju Flurry", icon = "inv_misc_monsterscales_17", buff = "inv_misc_monsterscales_17" },

    -- Potions (Buff-giving)
    { category = "Potions", key = "potion_mageblood", name = "Mageblood Potion", icon = "inv_potion_45", buff = "inv_potion_45" },
    { category = "Potions", key = "potion_stoneshield", name = "Greater Stoneshield Potion", icon = "inv_potion_69", buff = "inv_potion_69" },
    { category = "Potions", key = "potion_firewater", name = "Winterfall Firewater", icon = "inv_potion_92", buff = "inv_potion_92" },
    { category = "Potions", key = "potion_zanza", name = "Spirit of Zanza", icon = "inv_potion_30", buff = "inv_potion_30" },
    { category = "Potions", key = "potion_fap", name = "Free Action Potion", icon = "inv_potion_04", buff = "inv_potion_04" },
    { category = "Potions", key = "potion_lip", name = "Limited Invulnerability Potion", icon = "inv_potion_62", buff = "inv_potion_62" },

    -- Weapons
    { category = "Weapons", key = "weapon_wizard_brilliant", name = "Brilliant Wizard Oil", icon = "inv_potion_105", isWeaponEnchant = true, slot = "mainhand" },
    { category = "Weapons", key = "weapon_mana_brilliant", name = "Brilliant Mana Oil", icon = "inv_potion_100", isWeaponEnchant = true, slot = "mainhand" },
    { category = "Weapons", key = "weapon_ele_main", name = "Elemental Sharpe. Stone (Main)", icon = "inv_stone_02", isWeaponEnchant = true, slot = "mainhand" },
    { category = "Weapons", key = "weapon_ele_off", name = "Elemental Sharpe. Stone (Off)", icon = "inv_stone_02", isWeaponEnchant = true, slot = "offhand" },
    { category = "Weapons", key = "weapon_dense_main", name = "Dense Sharpening Stone (Main)", icon = "inv_stone_sharpeningstone_05", isWeaponEnchant = true, slot = "mainhand" },
    { category = "Weapons", key = "weapon_dense_off", name = "Dense Sharpening Stone (Off)", icon = "inv_stone_sharpeningstone_05", isWeaponEnchant = true, slot = "offhand" },
    { category = "Weapons", key = "weapon_instant_main", name = "Instant Poison (Main)", icon = "ability_poisons", isWeaponEnchant = true, slot = "mainhand" },
    { category = "Weapons", key = "weapon_instant_off", name = "Instant Poison (Off)", icon = "ability_poisons", isWeaponEnchant = true, slot = "offhand" },

    -- World Buffs
    { category = "World", key = "wb_ony", name = "Rallying Cry (Ony/Nef)", icon = "inv_misc_head_dragon_01", buff = "inv_misc_head_dragon_01" },
    { category = "World", key = "wb_zandalar", name = "Spirit of Zandalar", icon = "ability_creature_hardenedhide", buff = "ability_creature_hardenedhide" },
    { category = "World", key = "wb_wcb", name = "Warchief's Blessing", icon = "spell_arcane_teleportdestardub", buff = "spell_arcane_teleportdestardub" },
    { category = "World", key = "wb_songflower", name = "Songflower Serenade", icon = "spell_holy_mindvision", buff = "spell_holy_mindvision" },
    { category = "World", key = "wb_dmt_stamina", name = "Fengus' Ferocity (DMT Str)", icon = "spell_nature_undyingstrength", buff = "spell_nature_undyingstrength" },
    { category = "World", key = "wb_dmt_crit", name = "Slip'kik's Savvy (DMT Crit)", icon = "spell_holy_lesserheal01", buff = "spell_holy_lesserheal01" },
    { category = "World", key = "wb_dmt_hp", name = "Mol'dar's Moxie (DMT Stam)", icon = "spell_holy_prayeroffortitude", buff = "spell_holy_prayeroffortitude" },
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

-- Compatibility helper for UnitBuff
local function GetBuffTexture(unit, index)
    local arg1, arg2 = UnitBuff(unit, index)
    if not arg1 then return nil end
    if type(arg2) == "string" or type(arg2) == "number" then
        -- Modern WoW (1.15+) returns name, texture, ...
        return arg2
    else
        -- Vanilla (1.12) returns texture
        return arg1
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
        local i = 1
        while true do
            local texture = GetBuffTexture("player", i)
            if not texture then break end
            
            -- User input might be "Ability_Paladin_JudgementBlue" or "Interface\\Icons\\Ability..."
            local normTexture = string.lower(texture)
            local searchIcon = string.lower(item.icon)
            
            if string.find(normTexture, searchIcon) then
                -- For stack counts in modern WoW, we need more return values
                local _, _, count = UnitBuff("player", i)
                return true, count or 0
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
            
            if item.isWeaponEnchant then
                local hasMainHandEnchant, mainHandExpiration, mainHandCharges, hasOffHandEnchant, offHandExpiration, offHandCharges = GetWeaponEnchantInfo()
                
                if item.slot == "mainhand" and hasMainHandEnchant then
                    found = true
                elseif item.slot == "offhand" and hasOffHandEnchant then
                    found = true
                end
                
            else
                local k = 1
                while true do
                    local texture = GetBuffTexture("player", k)
                    if not texture then break end
                    
                    -- Check texture match
                    if string.find(string.lower(texture), string.lower(item.buff)) then
                        found = true
                        break
                    end
                    k = k + 1
                end
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
    f:SetScript("OnDragStart", function(self)
        if VanillaSimpleAurasDB.unlock then self:StartMoving() end
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
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
    f:SetScript("OnDragStart", function(self)
        if VanillaSimpleAurasDB.unlock then self:StartMoving() end
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
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
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    
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
    typeButton:SetScript("OnClick", function(self)
        if f.addType == "SPELL" then
            f.addType = "BUFF"
            self:SetText("BUFF")
        else
            f.addType = "SPELL"
            self:SetText("SPELL")
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
        del:SetScript("OnClick", function(self)
            local idx = self:GetParent().index
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
    _G[slider:GetName() .. "Text"]:SetText("Update Speed: " .. (VanillaSimpleAurasDB.updateInterval or 0.2) .. "s")
    _G[slider:GetName() .. "Low"]:SetText("0.1")
    _G[slider:GetName() .. "High"]:SetText("2.0")
    slider:SetScript("OnValueChanged", function(self)
        local val = math.floor(self:GetValue() * 10 + 0.5) / 10 -- Round to 1 decimal
        VanillaSimpleAurasDB.updateInterval = val
        _G[self:GetName() .. "Text"]:SetText("Update Speed: " .. val .. "s")
    end)
    
    -- Unlock Button
    local unlockBtn = CreateFrame("Button", "VanillaSimpleAurasUnlockBtn", f, "UIPanelButtonTemplate")
    unlockBtn:SetWidth(120)
    unlockBtn:SetHeight(25)
    unlockBtn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 20, 20)
    unlockBtn:SetText(VanillaSimpleAurasDB.unlock and "Lock Frame" or "Unlock Frame")
    unlockBtn:SetScript("OnClick", function(self)
        VanillaSimpleAurasDB.unlock = not VanillaSimpleAurasDB.unlock
        self:SetText(VanillaSimpleAurasDB.unlock and "Lock Frame" or "Unlock Frame")
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
    local numItems = #items
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
local function VSA_RefreshConsumeList(category)
    if not VSA_ConsumeOptionsFrame then return end
    local f = VSA_ConsumeOptionsFrame
    
    -- Hide all existing checks
    if f.checks then
        for _, cb in pairs(f.checks) do cb:Hide() end
    else
        f.checks = {}
    end
    
    -- Filter items
    local yVal = -10
    local count = 0
    for i, item in ipairs(VSA_PREDEFINED_CONSUMES) do
        if item.category == category then
            count = count + 1
            local cb = f.checks[count]
            if not cb then
                cb = CreateFrame("CheckButton", "VSA_ConsumeCheck"..count, f.content, "OptionsCheckButtonTemplate")
                cb:SetWidth(24)
                cb:SetHeight(24)
                f.checks[count] = cb
            end
            
            cb:ClearAllPoints()
            cb:SetPoint("TOPLEFT", f.content, "TOPLEFT", 10, yVal)
            
            cb.label = _G[cb:GetName().."Text"]
            cb.label:SetText(item.name)
            
            cb:SetChecked(VanillaSimpleAurasDB.consumes[item.key])
            cb.itemKey = item.key
            cb:SetScript("OnClick", function(self)
                 VanillaSimpleAurasDB.consumes[self.itemKey] = self:GetChecked() and true or nil
                 UpdateConsumes()
            end)

            cb:Show()
            yVal = yVal - 26
        end
    end
end

local function CreateConsumeOptionsFrame()
    local f = CreateFrame("Frame", "VanillaSimpleAurasConsumeOptions", UIParent)
    f:SetWidth(400) -- Wider for tabs
    f:SetHeight(350)
    f:SetPoint("TOPLEFT", VSA_OptionsFrame, "TOPRIGHT", 0, 0)
    f:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    f:Hide()
    
    local title = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOP", f, "TOP", 0, -20)
    title:SetText("Consume List")
    
    local close = CreateFrame("Button", "VSA_ConsumeClose", f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -5)
    
    -- Category Buttons (Left side)
    local categories = {"Elixirs", "Flasks", "Food", "Potions", "Weapons", "World", "Misc"}
    local yVal = -50
    f.catButtons = {}
    
    for i, cat in ipairs(categories) do
        local btn = CreateFrame("Button", "VSA_CatBtn"..i, f, "UIPanelButtonTemplate")
        btn:SetWidth(80)
        btn:SetHeight(24)
        btn:SetPoint("TOPLEFT", f, "TOPLEFT", 15, yVal)
        btn:SetText(cat)
        btn.category = cat -- Store on button to avoid closure issues
        btn:SetScript("OnClick", function(self)
            VSA_RefreshConsumeList(self.category)
        end)
        f.catButtons[i] = btn
        yVal = yVal - 28
    end
    
    -- Content Area (Right side)
    local content = CreateFrame("Frame", nil, f)
    content:SetWidth(270)
    content:SetHeight(250)
    content:SetPoint("TOPLEFT", f, "TOPLEFT", 100, -50)
    -- content:SetBackdrop(...) -- Optional visual separation
    f.content = content
    
    -- Default selection
    f:SetScript("OnShow", function()
        VSA_RefreshConsumeList("Elixirs")
    end)
    
    -- Consume Interval Slider
    local slider = CreateFrame("Slider", "VanillaSimpleAurasConsumeSlider", f, "OptionsSliderTemplate")
    slider:SetWidth(180)
    slider:SetHeight(16)
    slider:SetPoint("BOTTOM", f, "BOTTOM", 0, 20)
    slider:SetMinMaxValues(1, 20)
    slider:SetValueStep(1)
    slider:SetValue(VanillaSimpleAurasDB.consumeInterval or 5.0)
    _G[slider:GetName() .. "Text"]:SetText("Check Speed: " .. (VanillaSimpleAurasDB.consumeInterval or 5.0) .. "s")
    _G[slider:GetName() .. "Low"]:SetText("1s")
    _G[slider:GetName() .. "High"]:SetText("20s")
    slider:SetScript("OnValueChanged", function(self)
        local val = math.floor(self:GetValue() + 0.5) -- Round to integer
        VanillaSimpleAurasDB.consumeInterval = val
        _G[self:GetName() .. "Text"]:SetText("Check Speed: " .. val .. "s")
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
