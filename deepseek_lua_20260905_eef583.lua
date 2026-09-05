-- ============================================================
-- Yuno Hub - Pet & Toy Spawner (standalone, draggable)
-- Full pet spawner: high tier, all variants, 50 random pets.
-- No trade features.
-- ============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

pcall(function() setthreadidentity(2) end)

local Fsys = require(ReplicatedStorage:WaitForChild("Fsys"))
local load = Fsys.load

local ClientData = load("ClientData")
local InventoryDB = load("InventoryDB")
local KindDB = load("KindDB")
local DownloadClient = load("DownloadClient")
local UIManager = load("UIManager")

if not ClientData or not InventoryDB or not KindDB then
    error("Required modules not loaded (ClientData, InventoryDB, KindDB)")
end

-- Anti‑stack
do
    local ok, HashHelper = pcall(function() return load("BackpackItemStackHashHelper") end)
    if ok and HashHelper and HashHelper.get_item_data_hash and not HashHelper._antiStackInstalled then
        HashHelper._antiStackInstalled = true
        local _orig = HashHelper.get_item_data_hash
        HashHelper.get_item_data_hash = function(item_data)
            if item_data and item_data.unique then
                return "nostack_" .. item_data.unique
            end
            return _orig(item_data)
        end
    end
end

-- ============================================================
-- Spawner state
-- ============================================================
local petFlags = { F = false, R = false, N = false, M = false }
local selectedAge = 6

local NewnessGroups = {
    mega_neon_flyable_rideable = 990000,
    mega_neon_flyable = 980000,
    mega_neon_rideable = 970000,
    mega_neon = 960000,
    neon_flyable_rideable = 950000,
    neon_flyable = 940000,
    neon_rideable = 930000,
    neon = 920000,
    flyable_rideable = 910000,
    flyable = 900000,
    rideable = 890000,
    regular = 880000,
}

local function GetPropertyGroup(properties)
    local m = properties.mega_neon or false
    local n = properties.neon or false
    local f = properties.flyable or false
    local r = properties.rideable or false
    if m then
        if f and r then return "mega_neon_flyable_rideable"
        elseif f then return "mega_neon_flyable"
        elseif r then return "mega_neon_rideable"
        else return "mega_neon" end
    elseif n then
        if f and r then return "neon_flyable_rideable"
        elseif f then return "neon_flyable"
        elseif r then return "neon_rideable"
        else return "neon" end
    else
        if f and r then return "flyable_rideable"
        elseif f then return "flyable"
        elseif r then return "rideable"
        else return "regular" end
    end
end

function FindPetKind(petName)
    if not petName or petName == "" then return nil end
    for id, item in pairs(InventoryDB.pets or {}) do
        if item.name and item.name:lower() == petName:lower() then
            return id
        end
    end
    return nil
end

function FindToyKind(toyName)
    if not toyName or toyName == "" then return nil end
    for id, item in pairs(InventoryDB.toys or {}) do
        if item.name and item.name:lower() == toyName:lower() then
            return id
        end
    end
    return nil
end

function BPCreateInventoryItem(itemId, category, properties)
    local uniqueId = HttpService:GenerateGUID(false)
    local kd = KindDB[itemId]
    if not kd then return nil end
    properties = properties or {}
    local newnessValue
    if category == "pets" then
        local gk = GetPropertyGroup(properties)
        NewnessGroups[gk] = (NewnessGroups[gk] or 990000) - 1
        newnessValue = NewnessGroups[gk]
        if properties.rp_name == nil then properties.rp_name = "" end
        if properties.xp == nil then properties.xp = 0 end
    else
        newnessValue = math.random(1, 900000)
    end
    local itemData = {
        unique = uniqueId,
        category = category,
        id = itemId,
        kind = kd.kind or itemId,
        newness_order = newnessValue,
        properties = properties,
        _source = "yuno_hub",
    }
    pcall(function() setthreadidentity(2) end)
    local inv = ClientData.get("inventory")
    if inv and inv[category] then
        inv[category][uniqueId] = itemData
    end
    pcall(function() setthreadidentity(8) end)
    task.defer(function()
        pcall(function()
            if UIManager and UIManager.apps and UIManager.apps.BackpackApp then
                UIManager.apps.BackpackApp:refresh_rendered_items()
            end
        end)
    end)
    return itemData
end

function SpawnPetByName(petName)
    local kind = FindPetKind(petName)
    if not kind then return nil, "Pet not found: " .. petName end
    local props = {
        flyable = petFlags.F,
        rideable = petFlags.R,
        neon = petFlags.N,
        mega_neon = petFlags.M,
        age = selectedAge,
        xp = 0,
        rp_name = "",
    }
    local item = BPCreateInventoryItem(kind, "pets", props)
    if item then
        return item, "Spawned " .. petName
    else
        return nil, "Failed to spawn " .. petName
    end
end

function SpawnToyByName(toyName)
    local kind = FindToyKind(toyName)
    if not kind then return nil, "Toy not found: " .. toyName end
    local props = {}
    local item = BPCreateInventoryItem(kind, "toys", props)
    if item then
        return item, "Spawned " .. toyName
    else
        return nil, "Failed to spawn " .. toyName
    end
end

function SpawnAllVariants(petName)
    local kind = FindPetKind(petName)
    if not kind then return 0, "Pet not found" end
    local count = 0
    local variants = {
        { F=true,  R=true,  N=false, M=true  },
        { F=true,  R=true,  N=true,  M=false },
        { F=true,  R=true,  N=false, M=false },
    }
    for i = 1, 2 do
        local f = math.random(0,1) == 1
        local r = math.random(0,1) == 1
        local roll = math.random(1,3)
        table.insert(variants, {F=f, R=r, N=(roll==2), M=(roll==3)})
    end
    for _, v in ipairs(variants) do
        local props = {
            flyable = v.F,
            rideable = v.R,
            neon = v.N,
            mega_neon = v.M,
            age = 6,
            xp = 0,
            rp_name = "",
        }
        BPCreateInventoryItem(kind, "pets", props)
        count = count + 1
    end
    return count, "Spawned " .. count .. " variants of " .. petName
end

function SpawnRandomHighTier()
    local HIGH_TIER_NAMES = {
        "Bat Dragon", "Shadow Dragon", "Giraffe", "Frost Dragon", "Owl", "Parrot",
        "Balloon Unicorn", "Crow", "African Wild Dog", "Giant Panda", "HaeTae",
        "Cryptid", "Evil Unicorn", "Blazing Lion", "Hedgehog", "Orchid Butterfly",
        "Diamond Butterfly", "Dalmatian", "Arctic Reindeer", "Mini Pig",
        "Jekyll Hydra", "Hot Doggo", "Mermicorn", "Pelican", "Cow",
        "Strawberry Shortcake Bat Dragon", "Goose", "Chocolate Chip Bat Dragon",
        "Cabbit", "Turtle", "Peppermint Penguin", "Monkey King",
        "Undead Jousting Horse", "Flamingo", "Kangaroo"
    }
    local name = HIGH_TIER_NAMES[math.random(1, #HIGH_TIER_NAMES)]
    return SpawnPetByName(name)
end

function SpawnRandomPets(amount)
    amount = amount or 50
    local HIGH_TIER_NAMES = {
        "Bat Dragon", "Shadow Dragon", "Giraffe", "Frost Dragon", "Owl", "Parrot",
        "Balloon Unicorn", "Crow", "African Wild Dog", "Giant Panda", "HaeTae",
        "Cryptid", "Evil Unicorn", "Blazing Lion", "Hedgehog", "Orchid Butterfly",
        "Diamond Butterfly", "Dalmatian", "Arctic Reindeer", "Mini Pig",
        "Jekyll Hydra", "Hot Doggo", "Mermicorn", "Pelican", "Cow",
        "Strawberry Shortcake Bat Dragon", "Goose", "Chocolate Chip Bat Dragon",
        "Cabbit", "Turtle", "Peppermint Penguin", "Monkey King",
        "Undead Jousting Horse", "Flamingo", "Kangaroo"
    }
    local highTierKinds = {}
    for _, name in ipairs(HIGH_TIER_NAMES) do
        local k = FindPetKind(name)
        if k then highTierKinds[k] = true end
    end
    local allKinds = {}
    for id, item in pairs(InventoryDB.pets or {}) do
        if item.name and not highTierKinds[id] then
            table.insert(allKinds, id)
        end
    end
    if #allKinds == 0 then return 0, "No non-high-tier pets found" end
    local count = 0
    for i = 1, amount do
        local kind = allKinds[math.random(1, #allKinds)]
        local props = {
            flyable = petFlags.F,
            rideable = petFlags.R,
            neon = petFlags.N,
            mega_neon = petFlags.M,
            age = selectedAge,
            xp = 0,
            rp_name = "",
        }
        BPCreateInventoryItem(kind, "pets", props)
        count = count + 1
    end
    return count, "Spawned " .. count .. " random pets"
end

-- ============================================================
-- GUI – Draggable Hub
-- ============================================================

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "YunoHub"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 360)
mainFrame.Position = UDim2.new(0.5, -120, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 24)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8, 0, 0)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Yuno Hub"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextColor3 = Color3.fromRGB(220, 200, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 1, 0)
closeBtn.Position = UDim2.new(1, -24, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.Parent = titleBar
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local dragging = false
local dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -16, 1, -30)
content.Position = UDim2.new(0, 8, 0, 28)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)
layout.Parent = content

-- Tabs
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 0, 28)
tabContainer.BackgroundTransparency = 1
tabContainer.LayoutOrder = 0
tabContainer.Parent = content

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 4)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.Parent = tabContainer

local petsTab = Instance.new("TextButton")
petsTab.Size = UDim2.new(0, 70, 1, 0)
petsTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
petsTab.Text = "Pets"
petsTab.Font = Enum.Font.GothamBold
petsTab.TextSize = 12
petsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
petsTab.Parent = tabContainer
Instance.new("UICorner", petsTab).CornerRadius = UDim.new(0, 4)
local petsStroke = Instance.new("UIStroke")
petsStroke.Color = Color3.fromRGB(108, 75, 171)
petsStroke.Thickness = 1
petsStroke.Transparency = 0.2
petsStroke.Parent = petsTab

local toysTab = Instance.new("TextButton")
toysTab.Size = UDim2.new(0, 70, 1, 0)
toysTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
toysTab.Text = "Toys"
toysTab.Font = Enum.Font.GothamBold
toysTab.TextSize = 12
toysTab.TextColor3 = Color3.fromRGB(255, 255, 255)
toysTab.Parent = tabContainer
Instance.new("UICorner", toysTab).CornerRadius = UDim.new(0, 4)
local toysStroke = Instance.new("UIStroke")
toysStroke.Color = Color3.fromRGB(108, 75, 171)
toysStroke.Thickness = 1
toysStroke.Transparency = 0.5
toysStroke.Parent = toysTab

-- Pets Panel
local petsPanel = Instance.new("Frame")
petsPanel.Size = UDim2.new(1, 0, 0, 285)
petsPanel.BackgroundTransparency = 1
petsPanel.LayoutOrder = 1
petsPanel.Parent = content

local petsLayout = Instance.new("UIListLayout")
petsLayout.SortOrder = Enum.SortOrder.LayoutOrder
petsLayout.Padding = UDim.new(0, 4)
petsLayout.Parent = petsPanel

local petNameBox = Instance.new("TextBox")
petNameBox.Size = UDim2.new(1, 0, 0, 26)
petNameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
petNameBox.Text = ""
petNameBox.PlaceholderText = "Enter Pet Name to Spawn"
petNameBox.Font = Enum.Font.SourceSans
petNameBox.TextSize = 12
petNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
petNameBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 110)
petNameBox.ClearTextOnFocus = false
petNameBox.TextXAlignment = Enum.TextXAlignment.Left
petNameBox.LayoutOrder = 0
petNameBox.Parent = petsPanel
Instance.new("UICorner", petNameBox).CornerRadius = UDim.new(0, 4)
local pPad = Instance.new("UIPadding")
pPad.PaddingLeft = UDim.new(0, 8)
pPad.PaddingRight = UDim.new(0, 8)
pPad.Parent = petNameBox

local flagsRow = Instance.new("Frame")
flagsRow.Size = UDim2.new(1, 0, 0, 28)
flagsRow.BackgroundTransparency = 1
flagsRow.LayoutOrder = 1
flagsRow.Parent = petsPanel
local flagsLayout = Instance.new("UIListLayout")
flagsLayout.FillDirection = Enum.FillDirection.Horizontal
flagsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
flagsLayout.Padding = UDim.new(0, 6)
flagsLayout.Parent = flagsRow

local flagDefs = {
    { key="F", label="Fly",  off=Color3.fromRGB(30,30,45), on=Color3.fromRGB(50,100,220) },
    { key="R", label="Ride", off=Color3.fromRGB(30,30,45), on=Color3.fromRGB(200,50,50) },
    { key="N", label="Neon", off=Color3.fromRGB(30,30,45), on=Color3.fromRGB(30,180,90) },
    { key="M", label="Mega", off=Color3.fromRGB(30,30,45), on=Color3.fromRGB(130,50,210) },
}
local flagButtons = {}
for _, def in ipairs(flagDefs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 36, 1, 0)
    btn.BackgroundColor3 = def.off
    btn.Text = def.label
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = Color3.fromRGB(120, 120, 140)
    btn.Parent = flagsRow
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.fromRGB(60, 60, 80)
    stroke.Thickness = 1
    stroke.Parent = btn
    flagButtons[def.key] = { btn = btn, stroke = stroke, def = def }
    btn.MouseButton1Click:Connect(function()
        local k = def.key
        if k == "M" and not petFlags.M then petFlags.N = false end
        if k == "N" and not petFlags.N then petFlags.M = false end
        petFlags[k] = not petFlags[k]
        for key, ref in pairs(flagButtons) do
            local on = petFlags[key]
            ref.btn.BackgroundColor3 = on and ref.def.on or ref.def.off
            ref.btn.TextColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(120,120,140)
            ref.stroke.Color = on and ref.def.on or Color3.fromRGB(60,60,80)
        end
    end)
end

local ageRow = Instance.new("Frame")
ageRow.Size = UDim2.new(1, 0, 0, 24)
ageRow.BackgroundTransparency = 1
ageRow.LayoutOrder = 2
ageRow.Parent = petsPanel
local ageLayout = Instance.new("UIListLayout")
ageLayout.FillDirection = Enum.FillDirection.Horizontal
ageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ageLayout.Padding = UDim.new(0, 4)
ageLayout.Parent = ageRow

local ageLabels = { "NB", "Jr", "PT", "T", "PoT", "FG" }
local ageValues = { 1, 2, 3, 4, 5, 6 }
local ageButtons = {}
for i, label in ipairs(ageLabels) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 28, 1, 0)
    btn.BackgroundColor3 = (selectedAge == ageValues[i]) and Color3.fromRGB(70,45,110) or Color3.fromRGB(35,35,48)
    btn.Text = label
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.TextColor3 = (selectedAge == ageValues[i]) and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,130,150)
    btn.Parent = ageRow
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = (selectedAge == ageValues[i]) and Color3.fromRGB(108,75,171) or Color3.fromRGB(60,60,80)
    stroke.Thickness = 1
    stroke.Parent = btn
    local val = ageValues[i]
    btn.MouseButton1Click:Connect(function()
        selectedAge = val
        for idx, ref in ipairs(ageButtons) do
            local on = ref.value == selectedAge
            ref.btn.BackgroundColor3 = on and Color3.fromRGB(70,45,110) or Color3.fromRGB(35,35,48)
            ref.btn.TextColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,130,150)
            ref.stroke.Color = on and Color3.fromRGB(108,75,171) or Color3.fromRGB(60,60,80)
        end
    end)
    table.insert(ageButtons, { btn = btn, stroke = stroke, value = val })
end

local petSpawnRow = Instance.new("Frame")
petSpawnRow.Size = UDim2.new(1, 0, 0, 26)
petSpawnRow.BackgroundTransparency = 1
petSpawnRow.LayoutOrder = 3
petSpawnRow.Parent = petsPanel
local psLayout = Instance.new("UIListLayout")
psLayout.FillDirection = Enum.FillDirection.Horizontal
psLayout.Padding = UDim.new(0, 4)
psLayout.SortOrder = Enum.SortOrder.LayoutOrder
psLayout.Parent = petSpawnRow

local function makePetBtn(text, order, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.48, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.LayoutOrder = order
    btn.Parent = petSpawnRow
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = color or Color3.fromRGB(108, 75, 171)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
    stroke.Parent = btn
    return btn
end

local spawnPetBtn = makePetBtn("Spawn Pet", 1)
local spawnHighBtn = makePetBtn("Spawn High Tier", 2, Color3.fromRGB(200, 150, 60))

spawnPetBtn.MouseButton1Click:Connect(function()
    local name = petNameBox.Text
    if name == "" then
        game.StarterGui:SetCore("SendNotification", {Title = "Yuno Hub", Text = "Enter a pet name.", Duration = 3})
        return
    end
    local item, msg = SpawnPetByName(name)
    game.StarterGui:SetCore("SendNotification", {Title = "Yuno Hub", Text = msg, Duration = 3})
end)

spawnHighBtn.MouseButton1Click:Connect(function()
    local item, msg = SpawnRandomHighTier()
    if item then
        petNameBox.Text = item.kind
    end
    game.StarterGui:SetCore("SendNotification", {Title = "Yuno Hub", Text = msg, Duration = 3})
end)

local variantsBtn = Instance.new("TextButton")
variantsBtn.Size = UDim2.new(1, 0, 0, 26)
variantsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
variantsBtn.Text = "Spawn All Variants"
variantsBtn.Font = Enum.Font.GothamBold
variantsBtn.TextSize = 11
variantsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
variantsBtn.LayoutOrder = 4
variantsBtn.Parent = petsPanel
Instance.new("UICorner", variantsBtn).CornerRadius = UDim.new(0, 4)
local varStroke = Instance.new("UIStroke")
varStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
varStroke.Color = Color3.fromRGB(50, 180, 80)
varStroke.Thickness = 1.5
varStroke.Transparency = 0.3
varStroke.Parent = variantsBtn

variantsBtn.MouseButton1Click:Connect(function()
    local name = petNameBox.Text
    if name == "" then
        game.StarterGui:SetCore("SendNotification", {Title = "Yuno Hub", Text = "Enter a pet name first.", Duration = 3})
        return
    end
    local count, msg = SpawnAllVariants(name)
    game.StarterGui:SetCore("SendNotification", {Title = "Yuno Hub", Text = msg, Duration = 3})
end)

local randomBtn = Instance.new("TextButton")
randomBtn.Size = UDim2.new(1, 0, 0, 26)
randomBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
randomBtn.Text = "Spawn 50 Random Pets"
randomBtn.Font = Enum.Font.GothamBold
randomBtn.TextSize = 11
randomBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
randomBtn.LayoutOrder = 5
randomBtn.Parent = petsPanel
Instance.new("UICorner", randomBtn).CornerRadius = UDim.new(0, 4)
local randStroke = Instance.new("UIStroke")
randStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
randStroke.Color = Color3.fromRGB(60, 130, 200)
randStroke.Thickness = 1.5
randStroke.Transparency = 0.3
randStroke.Parent = randomBtn

randomBtn.MouseButton1Click:Connect(function()
    local count, msg = SpawnRandomPets(50)
    game.StarterGui:SetCore("SendNotification", {Title = "Yuno Hub", Text = msg, Duration = 3})
end)

-- Toys Panel
local toysPanel = Instance.new("Frame")
toysPanel.Size = UDim2.new(1, 0, 0, 100)
toysPanel.BackgroundTransparency = 1
toysPanel.LayoutOrder = 1
toysPanel.Visible = false
toysPanel.Parent = content

local toysLayout = Instance.new("UIListLayout")
toysLayout.SortOrder = Enum.SortOrder.LayoutOrder
toysLayout.Padding = UDim.new(0, 4)
toysLayout.Parent = toysPanel

local toyNameBox = Instance.new("TextBox")
toyNameBox.Size = UDim2.new(1, 0, 0, 26)
toyNameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
toyNameBox.Text = ""
toyNameBox.PlaceholderText = "Enter Toy Name to Spawn"
toyNameBox.Font = Enum.Font.SourceSans
toyNameBox.TextSize = 12
toyNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
toyNameBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 110)
toyNameBox.ClearTextOnFocus = false
toyNameBox.TextXAlignment = Enum.TextXAlignment.Left
toyNameBox.LayoutOrder = 0
toyNameBox.Parent = toysPanel
Instance.new("UICorner", toyNameBox).CornerRadius = UDim.new(0, 4)
local tPad = Instance.new("UIPadding")
tPad.PaddingLeft = UDim.new(0, 8)
tPad.PaddingRight = UDim.new(0, 8)
tPad.Parent = toyNameBox

local toySpawnBtn = Instance.new("TextButton")
toySpawnBtn.Size = UDim2.new(1, 0, 0, 26)
toySpawnBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
toySpawnBtn.Text = "Spawn Toy"
toySpawnBtn.Font = Enum.Font.GothamBold
toySpawnBtn.TextSize = 12
toySpawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toySpawnBtn.LayoutOrder = 1
toySpawnBtn.Parent = toysPanel
Instance.new("UICorner", toySpawnBtn).CornerRadius = UDim.new(0, 4)
local toyStroke = Instance.new("UIStroke")
toyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
toyStroke.Color = Color3.fromRGB(108, 75, 171)
toyStroke.Thickness = 1.5
toyStroke.Transparency = 0.3
toyStroke.Parent = toySpawnBtn

toySpawnBtn.MouseButton1Click:Connect(function()
    local name = toyNameBox.Text
    if name == "" then
        game.StarterGui:SetCore("SendNotification", {Title = "Yuno Hub", Text = "Enter a toy name.", Duration = 3})
        return
    end
    local item, msg = SpawnToyByName(name)
    game.StarterGui:SetCore("SendNotification", {Title = "Yuno Hub", Text = msg, Duration = 3})
end)

-- Tab switching
local function switchTab(tab)
    if tab == "Pets" then
        petsPanel.Visible = true
        toysPanel.Visible = false
        petsTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        petsStroke.Transparency = 0.2
        toysTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        toysStroke.Transparency = 0.5
    else
        petsPanel.Visible = false
        toysPanel.Visible = true
        toysTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        toysStroke.Transparency = 0.2
        petsTab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        petsStroke.Transparency = 0.5
    end
end

petsTab.MouseButton1Click:Connect(function() switchTab("Pets") end)
toysTab.MouseButton1Click:Connect(function() switchTab("Toys") end)

switchTab("Pets")

print("Yuno Hub loaded successfully!")