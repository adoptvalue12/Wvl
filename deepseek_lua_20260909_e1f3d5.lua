--[[
    Adopt Me Value Checker & Trade Evaluator
    Inspired by Elvebredd.com
    Mobile-friendly, with themes, pet images, and live suggestions
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local guiService = game:GetService("GuiService")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- ============================================================================
-- PET VALUE DATABASE (from screenshots)
-- ============================================================================
local petValues = {
    -- HIGH TIER
    ["bat dragon"] = 943,
    ["shadow dragon"] = 844,
    ["shadow"] = 844,
    ["giraffe"] = 476,
    ["frost dragon"] = 326,
    ["frost"] = 326,
    ["owl"] = 247,
    ["parrot"] = 247,
    ["giant panda"] = 220,
    ["crow"] = 220,
    ["balloon unicorn"] = 202,
    ["balloon ur"] = 202,
    ["blazing lion"] = 202,
    ["blazing lice"] = 202,
    ["cryptid"] = 196,
    ["haetae"] = 196,
    ["orchid butterfly"] = 116,
    ["orchid bur"] = 116,
    ["evil unicorn"] = 109,
    ["undead jousting horse"] = 93,
    ["undead joc"] = 93,
    ["diamond egg"] = 96,
    ["diamond e"] = 96,
    ["arctic reindeer"] = 95,
    ["arctic rel"] = 95,
    ["frostbite eagle"] = 94,
    ["frostbite e"] = 94,
    ["monkey king"] = 92,
    ["monkey ki"] = 92,
    ["jekyll hydra"] = 83,
    -- MID TIER
    ["diamond"] = 73,
    ["monkey k"] = 66,
    ["arctic rel"] = 51,
    ["frostbite"] = 40,
    ["hot doggo"] = 36,
    ["strawberry"] = 34.5,
    ["chocolate"] = 33.75,
    ["grim dragon"] = 31,
    ["werewolf"] = 30,
    ["sugar glider"] = 27.5,
    ["mermicorn"] = 27,
    ["turtle"] = 23,
    ["strawberry"] = 24.5,
    ["bush elephant"] = 21.5,
    ["tortoiseshell"] = 21,
    ["fairy bat dragon"] = 19,
    ["candyfloss"] = 19.5,
    ["kangaroo"] = 18,
    ["royal mist"] = 19.5,
    ["tío de nac"] = 19.25,
    ["emperor c"] = 19,
    ["silverback"] = 19,
    ["black-che"] = 19,
    ["albino mo"] = 19,
    ["pirate ghost"] = 18.5,
    ["sugar axo"] = 18.5,
    ["mechapup"] = 18.25,
    ["frost unic"] = 18.25,
    ["winged tic"] = 15,
    ["shark pup"] = 15,
    ["vampire d"] = 14,
    ["ocirooster"] = 14,
    ["jousting"] = 14,
    ["phantom"] = 14,
    ["moonbean"] = 13,
    ["hero gibb"] = 13,
    ["shark pup"] = 12.5,
    ["jousting"] = 11,
    ["phantom"] = 10.75,
    ["hero gibb"] = 10.5,
    ["candicom"] = 9.75,
    ["aurora fox"] = 7.25,
    ["ballet swa"] = 7,
    ["midnight"] = 7,
    ["red dutch"] = 7,
    ["cupid dra"] = 6.75,
    ["nessie"] = 6.5,
    ["strawberry"] = 6.5,
    ["sakura sp"] = 6,
    ["diamond a"] = 5.75,
    ["halloween"] = 5.5,
    ["papa moo"] = 5.5,
    -- LOW TIER
    ["field moul"] = 5.25,
    ["glacier kli"] = 5.25,
    ["lava drag"] = 5.25,
    ["frost fury"] = 5,
    ["cerberus"] = 4.75,
    ["owlbear"] = 4.75,
    ["2d doggy"] = 4.5,
    ["aestus"] = 4.5,
    ["caelum cae"] = 4.5,
    ["solaris"] = 4.5,
    ["diamond a"] = 4.25,
    ["giant gold"] = 4.25,
    ["fallow deer"] = 4,
    ["glormy le"] = 3.75,
    ["arctic dus"] = 3.65,
    ["diamond i"] = 3.5,
    ["dancing d"] = 3.25,
    ["ice golem"] = 3.25,
    ["rose drag"] = 3.15,
    ["latte kits"] = 3,
    ["scorching"] = 3,
    ["dragonfrui"] = 2.85,
    ["kelp capta"] = 2.75,
    ["moose cali"] = 2.75,
    ["dango pe"] = 2.5,
    ["pineapple"] = 2.5,
    ["majestic f"] = 2.25,
    ["skole-rex"] = 2.25,
    ["cheetah"] = 2.15,
    ["glormy ho"] = 2.15,
    ["lavender i"] = 2.15,
    ["frost phoe"] = 2,
    ["kiwi kiwi"] = 2,
    ["queen bee"] = 2,
    ["tree kang"] = 2,
    ["corn dog"] = 1.85,
    ["golden pea"] = 1.8,
    ["candy hair"] = 1.75,
    ["lava wolf"] = 1.75,
    ["leviathan"] = 1.75,
    ["violet butt"] = 1.75,
    ["albino gor"] = 1.65,
    ["golden ch"] = 1.65,
    ["scarebear"] = 1.65,
    ["diamond"] = 1.5,
    ["moonbear"] = 1.5,
    ["naughty"] = 1.5,
    ["peahen"] = 1.5,
    ["2d kitty"] = 1.35,
    ["diamond l"] = 1.35,
    ["ninja mon"] = 1.35,
    ["green but"] = 1.25,
    ["prismatic"] = 1.2,
    ["rainbow"] = 1.15,
    ["yule log"] = 1.1,
    ["dire stag"] = 1.05,
    ["firefly"] = 1.05,
    ["astronaut"] = 1,
    ["dodo"] = 1,
    ["golden rat"] = 1,
    ["phoenix"] = 1,
    ["shark"] = 1,
    ["black widow"] = 0.97,
    ["goldhorn"] = 0.96,
    ["capricorn"] = 0.95,
    ["pirate hero"] = 0.94,
    ["spinosaurus"] = 0.93,
    ["axolotl"] = 0.88,
    ["peacock"] = 0.88,
    ["cactus fri"] = 0.85,
    ["emberliqh"] = 0.85,
    ["royal cap"] = 0.83,
    ["apple owl"] = 0.82,
    ["peach owl"] = 0.82,
    ["golden w"] = 0.8,
    ["volcanic f"] = 0.8,
    ["guardian l"] = 0.79,
    ["gargoyle"] = 0.78,
    ["princess c"] = 0.78,
    ["influencer"] = 0.77,
    ["naga drag"] = 0.77,
    ["unicorn"] = 0.77,
    ["white am"] = 0.77,
    ["netland pc"] = 0.76,
    ["chameleon"] = 0.76,
    ["snow owl"] = 0.75,
    ["cuddly ca"] = 0.75,
    ["white amoeba"] = 0.73,
    ["cuddly cat"] = 0.7,
    ["golden lizard"] = 0.7,
    ["mushroom"] = 0.7,
    ["squid"] = 0.7,
    ["sunrise duck"] = 0.67,
    ["billy goat"] = 0.6,
    ["gilded snail"] = 0.6,
    ["green-chicken"] = 0.6,
    ["winged horse"] = 0.6,
    ["cinnamon"] = 0.01,
    ["dalmatian"] = 0.01,
    ["dalmatian"] = 61.5,
}

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================
local function getPetValue(petName)
    if not petName or petName == "" then return nil end
    local lower = string.lower(petName)
    if petValues[lower] then return petValues[lower] end
    for key, value in pairs(petValues) do
        if string.find(lower, key) or string.find(key, lower) then
            return value
        end
    end
    return nil
end

local function findClosestPet(query)
    if not query or query == "" then return nil end
    local lower = string.lower(query)
    local bestMatch, bestScore = nil, 0
    for key, _ in pairs(petValues) do
        local score = 0
        if string.find(key, lower) then score = #lower
        elseif string.find(lower, key) then score = #key end
        if score > bestScore then bestScore = score; bestMatch = key end
    end
    return bestMatch
end

local function getAllPetNames()
    local names = {}
    for k, _ in pairs(petValues) do table.insert(names, k) end
    table.sort(names)
    return names
end

-- ============================================================================
-- GUI CREATION
-- ============================================================================
local function createMainGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdoptMeValueChecker"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    -- ===== MAIN FRAME =====
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 440, 0, 620)
    mainFrame.Position = UDim2.new(0.5, -220, 0.5, -310)
    mainFrame.BackgroundColor3 = Color3.fromRGB(245, 245, 250) -- Light theme
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = mainFrame

    -- Shadow (slight drop)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045058" -- shadow
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ZIndex = 0
    shadow.Parent = mainFrame

    -- ===== TITLE BAR =====
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
    titleBar.BackgroundTransparency = 0
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 16)
    titleCorner.Parent = titleBar
    -- only top corners rounded
    local titleCorner2 = Instance.new("UICorner")
    titleCorner2.CornerRadius = UDim.new(0, 16)
    titleCorner2.Parent = titleBar
    -- We'll use a separate frame to mask bottom corners later

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "𝖄𝖚𝖓𝖔 𝖛𝖆𝖑𝖚𝖊"  -- fancy text
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 22
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 34, 0, 34)
    closeBtn.Position = UDim2.new(1, -44, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeBtn.BackgroundTransparency = 0
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- ===== TAB BUTTONS =====
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 48)
    tabContainer.Position = UDim2.new(0, 0, 0, 50)
    tabContainer.BackgroundColor3 = Color3.fromRGB(230, 235, 245)
    tabContainer.BackgroundTransparency = 0
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame

    local tabs = {"🔍 Value", "⚖️ Trade", "🎨 Theme"}
    local tabButtons = {}
    for i, text in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = "Tab" .. i .. "Btn"
        btn.Size = UDim2.new(1 / #tabs, -4, 1, -4)
        btn.Position = UDim2.new((i-1) / #tabs + 0.02, 0, 0, 2)
        btn.BackgroundColor3 = i == 1 and Color3.fromRGB(60, 100, 200) or Color3.fromRGB(220, 225, 235)
        btn.BackgroundTransparency = 0
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = i == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 70, 90)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.Parent = tabContainer
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        tabButtons[i] = btn
    end

    -- ===== CONTENT AREA =====
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, 0, 1, -98)
    contentArea.Position = UDim2.new(0, 0, 0, 98)
    contentArea.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
    contentArea.BackgroundTransparency = 0
    contentArea.BorderSizePixel = 0
    contentArea.ClipsDescendants = true
    contentArea.Parent = mainFrame

    -- ===== TAB 1: VALUE LOOKUP =====
    local tab1Content = Instance.new("Frame")
    tab1Content.Name = "Tab1Content"
    tab1Content.Size = UDim2.new(1, 0, 1, 0)
    tab1Content.BackgroundTransparency = 1
    tab1Content.Visible = true
    tab1Content.Parent = contentArea

    -- Search Box with suggestions
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, -24, 0, 44)
    searchBox.Position = UDim2.new(0, 12, 0, 12)
    searchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.BackgroundTransparency = 0
    searchBox.BorderSizePixel = 1
    searchBox.BorderColor3 = Color3.fromRGB(200, 200, 210)
    searchBox.PlaceholderText = "Search for a pet..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
    searchBox.TextColor3 = Color3.fromRGB(40, 40, 60)
    searchBox.TextSize = 16
    searchBox.Font = Enum.Font.Gotham
    searchBox.Text = ""
    searchBox.Parent = tab1Content

    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 10)
    searchCorner.Parent = searchBox

    -- Suggestions dropdown
    local suggestionsFrame = Instance.new("ScrollingFrame")
    suggestionsFrame.Name = "Suggestions"
    suggestionsFrame.Size = UDim2.new(1, -24, 0, 150)
    suggestionsFrame.Position = UDim2.new(0, 12, 0, 60)
    suggestionsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    suggestionsFrame.BackgroundTransparency = 0
    suggestionsFrame.BorderSizePixel = 0
    suggestionsFrame.Visible = false
    suggestionsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    suggestionsFrame.ScrollBarThickness = 0
    suggestionsFrame.Parent = tab1Content

    local suggCorner = Instance.new("UICorner")
    suggCorner.CornerRadius = UDim.new(0, 8)
    suggCorner.Parent = suggestionsFrame

    -- Result display
    local resultFrame = Instance.new("Frame")
    resultFrame.Name = "ResultFrame"
    resultFrame.Size = UDim2.new(1, -24, 0, 160)
    resultFrame.Position = UDim2.new(0, 12, 0, 220)
    resultFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    resultFrame.BackgroundTransparency = 0
    resultFrame.BorderSizePixel = 1
    resultFrame.BorderColor3 = Color3.fromRGB(200, 200, 210)
    resultFrame.Visible = false
    resultFrame.Parent = tab1Content

    local resultCorner = Instance.new("UICorner")
    resultCorner.CornerRadius = UDim.new(0, 10)
    resultCorner.Parent = resultFrame

    -- Pet image placeholder
    local petImage = Instance.new("ImageLabel")
    petImage.Name = "PetImage"
    petImage.Size = UDim2.new(0, 80, 0, 80)
    petImage.Position = UDim2.new(0, 12, 0, 12)
    petImage.BackgroundTransparency = 1
    petImage.Image = "rbxassetid://131603476" -- generic pet icon
    petImage.Parent = resultFrame

    local petNameLabel = Instance.new("TextLabel")
    petNameLabel.Name = "PetNameLabel"
    petNameLabel.Size = UDim2.new(1, -110, 0, 30)
    petNameLabel.Position = UDim2.new(0, 100, 0, 12)
    petNameLabel.BackgroundTransparency = 1
    petNameLabel.Text = "Pet Name"
    petNameLabel.TextColor3 = Color3.fromRGB(40, 40, 60)
    petNameLabel.TextSize = 20
    petNameLabel.Font = Enum.Font.GothamBold
    petNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    petNameLabel.Parent = resultFrame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(1, -110, 0, 40)
    valueLabel.Position = UDim2.new(0, 100, 0, 45)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = "Value: 0.00"
    valueLabel.TextColor3 = Color3.fromRGB(60, 100, 200)
    valueLabel.TextSize = 28
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = resultFrame

    local notFoundLabel = Instance.new("TextLabel")
    notFoundLabel.Name = "NotFoundLabel"
    notFoundLabel.Size = UDim2.new(1, -24, 0, 40)
    notFoundLabel.Position = UDim2.new(0, 12, 0, 140)
    notFoundLabel.BackgroundTransparency = 1
    notFoundLabel.Text = "⚠️ Pet not found"
    notFoundLabel.TextColor3 = Color3.fromRGB(200, 100, 50)
    notFoundLabel.TextSize = 16
    notFoundLabel.Font = Enum.Font.Gotham
    notFoundLabel.TextXAlignment = Enum.TextXAlignment.Center
    notFoundLabel.Visible = false
    notFoundLabel.Parent = tab1Content

    -- ===== SUGGESTION LOGIC =====
    local allPetNames = getAllPetNames()
    local function updateSuggestions(query)
        if query == "" then
            suggestionsFrame.Visible = false
            return
        end
        local lower = string.lower(query)
        local matches = {}
        for _, name in ipairs(allPetNames) do
            if string.find(name, lower) then
                table.insert(matches, name)
                if #matches >= 8 then break end
            end
        end
        if #matches == 0 then
            suggestionsFrame.Visible = false
            return
        end
        -- Clear old
        for _, child in pairs(suggestionsFrame:GetChildren()) do
            if child.Name == "SuggestionItem" then child:Destroy() end
        end
        local y = 4
        for _, name in ipairs(matches) do
            local item = Instance.new("TextButton")
            item.Name = "SuggestionItem"
            item.Size = UDim2.new(1, -8, 0, 28)
            item.Position = UDim2.new(0, 4, 0, y)
            item.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
            item.BackgroundTransparency = 0
            item.BorderSizePixel = 0
            item.Text = name
            item.TextColor3 = Color3.fromRGB(40, 40, 60)
            item.TextSize = 14
            item.Font = Enum.Font.Gotham
            item.TextXAlignment = Enum.TextXAlignment.Left
            item.Parent = suggestionsFrame
            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 4)
            itemCorner.Parent = item
            item.MouseButton1Click:Connect(function()
                searchBox.Text = name
                suggestionsFrame.Visible = false
                performSearch(name)
            end)
            y = y + 32
        end
        suggestionsFrame.CanvasSize = UDim2.new(0, 0, 0, y + 4)
        suggestionsFrame.Visible = true
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        updateSuggestions(searchBox.Text)
    end)

    searchBox.FocusLost:Connect(function()
        wait(0.2)
        suggestionsFrame.Visible = false
    end)

    -- ===== SEARCH FUNCTION =====
    local function performSearch(query)
        if query == "" then
            resultFrame.Visible = false
            notFoundLabel.Visible = false
            return
        end
        local value = getPetValue(query)
        if value then
            local matchKey = findClosestPet(query) or query
            petNameLabel.Text = string.upper(string.sub(matchKey, 1, 1)) .. string.sub(matchKey, 2)
            valueLabel.Text = "Value: " .. string.format("%.2f", value)
            -- Try to get a pet image (using a generic one for now)
            petImage.Image = "rbxassetid://131603476" -- placeholder
            resultFrame.Visible = true
            notFoundLabel.Visible = false
        else
            resultFrame.Visible = false
            notFoundLabel.Visible = true
            notFoundLabel.Text = '⚠️ "' .. query .. '" not found in database'
        end
    end

    -- Enter key triggers search
    searchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            performSearch(searchBox.Text)
            suggestionsFrame.Visible = false
        end
    end)

    -- ===== TAB 2: TRADE EVALUATOR =====
    local tab2Content = Instance.new("Frame")
    tab2Content.Name = "Tab2Content"
    tab2Content.Size = UDim2.new(1, 0, 1, 0)
    tab2Content.BackgroundTransparency = 1
    tab2Content.Visible = false
    tab2Content.Parent = contentArea

    -- Left side (Your Offer)
    local leftFrame = Instance.new("Frame")
    leftFrame.Name = "LeftFrame"
    leftFrame.Size = UDim2.new(0.48, -6, 1, -10)
    leftFrame.Position = UDim2.new(0, 4, 0, 4)
    leftFrame.BackgroundColor3 = Color3.fromRGB(230, 250, 235)
    leftFrame.BackgroundTransparency = 0
    leftFrame.BorderSizePixel = 1
    leftFrame.BorderColor3 = Color3.fromRGB(180, 220, 190)
    leftFrame.Parent = tab2Content
    local leftCorner = Instance.new("UICorner"); leftCorner.CornerRadius = UDim.new(0, 10); leftCorner.Parent = leftFrame

    local leftTitle = Instance.new("TextLabel")
    leftTitle.Size = UDim2.new(1, 0, 0, 30)
    leftTitle.Position = UDim2.new(0, 0, 0, 4)
    leftTitle.BackgroundTransparency = 1
    leftTitle.Text = "🟢 Your Offer"
    leftTitle.TextColor3 = Color3.fromRGB(40, 160, 80)
    leftTitle.TextSize = 14
    leftTitle.Font = Enum.Font.GothamBold
    leftTitle.TextXAlignment = Enum.TextXAlignment.Center
    leftTitle.Parent = leftFrame

    local leftInput = Instance.new("TextBox")
    leftInput.Size = UDim2.new(1, -12, 0, 32)
    leftInput.Position = UDim2.new(0, 6, 0, 38)
    leftInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    leftInput.BorderSizePixel = 1
    leftInput.BorderColor3 = Color3.fromRGB(200, 200, 210)
    leftInput.PlaceholderText = "Pet name..."
    leftInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
    leftInput.TextColor3 = Color3.fromRGB(40, 40, 60)
    leftInput.TextSize = 13
    leftInput.Font = Enum.Font.Gotham
    leftInput.Text = ""
    leftInput.Parent = leftFrame
    local leftInputCorner = Instance.new("UICorner"); leftInputCorner.CornerRadius = UDim.new(0, 6); leftInputCorner.Parent = leftInput

    local leftAddBtn = Instance.new("TextButton")
    leftAddBtn.Size = UDim2.new(0, 50, 0, 32)
    leftAddBtn.Position = UDim2.new(1, -56, 0, 38)
    leftAddBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
    leftAddBtn.BorderSizePixel = 0
    leftAddBtn.Text = "+"
    leftAddBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    leftAddBtn.TextSize = 20
    leftAddBtn.Font = Enum.Font.GothamBold
    leftAddBtn.Parent = leftFrame
    local leftAddCorner = Instance.new("UICorner"); leftAddCorner.CornerRadius = UDim.new(0, 6); leftAddCorner.Parent = leftAddBtn

    local leftList = Instance.new("ScrollingFrame")
    leftList.Size = UDim2.new(1, -12, 1, -80)
    leftList.Position = UDim2.new(0, 6, 0, 76)
    leftList.BackgroundColor3 = Color3.fromRGB(240, 248, 242)
    leftList.BorderSizePixel = 0
    leftList.CanvasSize = UDim2.new(0, 0, 0, 0)
    leftList.ScrollBarThickness = 4
    leftList.Parent = leftFrame
    local leftListCorner = Instance.new("UICorner"); leftListCorner.CornerRadius = UDim.new(0, 6); leftListCorner.Parent = leftList

    -- Right side (Their Offer)
    local rightFrame = Instance.new("Frame")
    rightFrame.Name = "RightFrame"
    rightFrame.Size = UDim2.new(0.48, -6, 1, -10)
    rightFrame.Position = UDim2.new(0.52, 2, 0, 4)
    rightFrame.BackgroundColor3 = Color3.fromRGB(250, 235, 235)
    rightFrame.BackgroundTransparency = 0
    rightFrame.BorderSizePixel = 1
    rightFrame.BorderColor3 = Color3.fromRGB(220, 180, 180)
    rightFrame.Parent = tab2Content
    local rightCorner = Instance.new("UICorner"); rightCorner.CornerRadius = UDim.new(0, 10); rightCorner.Parent = rightFrame

    local rightTitle = Instance.new("TextLabel")
    rightTitle.Size = UDim2.new(1, 0, 0, 30)
    rightTitle.Position = UDim2.new(0, 0, 0, 4)
    rightTitle.BackgroundTransparency = 1
    rightTitle.Text = "🔴 Their Offer"
    rightTitle.TextColor3 = Color3.fromRGB(200, 60, 60)
    rightTitle.TextSize = 14
    rightTitle.Font = Enum.Font.GothamBold
    rightTitle.TextXAlignment = Enum.TextXAlignment.Center
    rightTitle.Parent = rightFrame

    local rightInput = Instance.new("TextBox")
    rightInput.Size = UDim2.new(1, -12, 0, 32)
    rightInput.Position = UDim2.new(0, 6, 0, 38)
    rightInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    rightInput.BorderSizePixel = 1
    rightInput.BorderColor3 = Color3.fromRGB(200, 200, 210)
    rightInput.PlaceholderText = "Pet name..."
    rightInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
    rightInput.TextColor3 = Color3.fromRGB(40, 40, 60)
    rightInput.TextSize = 13
    rightInput.Font = Enum.Font.Gotham
    rightInput.Text = ""
    rightInput.Parent = rightFrame
    local rightInputCorner = Instance.new("UICorner"); rightInputCorner.CornerRadius = UDim.new(0, 6); rightInputCorner.Parent = rightInput

    local rightAddBtn = Instance.new("TextButton")
    rightAddBtn.Size = UDim2.new(0, 50, 0, 32)
    rightAddBtn.Position = UDim2.new(1, -56, 0, 38)
    rightAddBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    rightAddBtn.BorderSizePixel = 0
    rightAddBtn.Text = "+"
    rightAddBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rightAddBtn.TextSize = 20
    rightAddBtn.Font = Enum.Font.GothamBold
    rightAddBtn.Parent = rightFrame
    local rightAddCorner = Instance.new("UICorner"); rightAddCorner.CornerRadius = UDim.new(0, 6); rightAddCorner.Parent = rightAddBtn

    local rightList = Instance.new("ScrollingFrame")
    rightList.Size = UDim2.new(1, -12, 1, -80)
    rightList.Position = UDim2.new(0, 6, 0, 76)
    rightList.BackgroundColor3 = Color3.fromRGB(248, 240, 240)
    rightList.BorderSizePixel = 0
    rightList.CanvasSize = UDim2.new(0, 0, 0, 0)
    rightList.ScrollBarThickness = 4
    rightList.Parent = rightFrame
    local rightListCorner = Instance.new("UICorner"); rightListCorner.CornerRadius = UDim.new(0, 6); rightListCorner.Parent = rightList

    -- Result bar (bottom)
    local resultBar = Instance.new("Frame")
    resultBar.Size = UDim2.new(1, -24, 0, 50)
    resultBar.Position = UDim2.new(0, 12, 1, -56)
    resultBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    resultBar.BorderSizePixel = 1
    resultBar.BorderColor3 = Color3.fromRGB(200, 200, 210)
    resultBar.Parent = tab2Content
    local resultBarCorner = Instance.new("UICorner"); resultBarCorner.CornerRadius = UDim.new(0, 10); resultBarCorner.Parent = resultBar

    local resultText = Instance.new("TextLabel")
    resultText.Size = UDim2.new(0.7, 0, 1, 0)
    resultText.Position = UDim2.new(0, 10, 0, 0)
    resultText.BackgroundTransparency = 1
    resultText.Text = "Add pets to both sides"
    resultText.TextColor3 = Color3.fromRGB(60, 70, 90)
    resultText.TextSize = 13
    resultText.Font = Enum.Font.Gotham
    resultText.TextXAlignment = Enum.TextXAlignment.Left
    resultText.Parent = resultBar

    local calcBtn = Instance.new("TextButton")
    calcBtn.Size = UDim2.new(0, 100, 1, -8)
    calcBtn.Position = UDim2.new(1, -110, 0, 4)
    calcBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
    calcBtn.BorderSizePixel = 0
    calcBtn.Text = "Evaluate"
    calcBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    calcBtn.TextSize = 14
    calcBtn.Font = Enum.Font.GothamBold
    calcBtn.Parent = resultBar
    local calcCorner = Instance.new("UICorner"); calcCorner.CornerRadius = UDim.new(0, 6); calcCorner.Parent = calcBtn

    -- ===== TRADE EVALUATOR LOGIC =====
    local leftPets, rightPets = {}, {}
    local function updateList(scrollFrame, petList, isLeft)
        for _, child in pairs(scrollFrame:GetChildren()) do if child.Name == "PetItem" then child:Destroy() end end
        local y = 4
        for i, petName in ipairs(petList) do
            local item = Instance.new("Frame")
            item.Name = "PetItem"
            item.Size = UDim2.new(1, -8, 0, 28)
            item.Position = UDim2.new(0, 4, 0, y)
            item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            item.BorderSizePixel = 1
            item.BorderColor3 = Color3.fromRGB(200, 200, 210)
            item.Parent = scrollFrame
            local itemCorner = Instance.new("UICorner"); itemCorner.CornerRadius = UDim.new(0, 4); itemCorner.Parent = item

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -30, 1, 0)
            nameLabel.Position = UDim2.new(0, 6, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = petName
            nameLabel.TextColor3 = Color3.fromRGB(40, 40, 60)
            nameLabel.TextSize = 12
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = item

            local removeBtn = Instance.new("TextButton")
            removeBtn.Size = UDim2.new(0, 22, 0, 22)
            removeBtn.Position = UDim2.new(1, -26, 0, 3)
            removeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            removeBtn.BorderSizePixel = 0
            removeBtn.Text = "✕"
            removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            removeBtn.TextSize = 12
            removeBtn.Font = Enum.Font.GothamBold
            removeBtn.Parent = item
            local removeCorner = Instance.new("UICorner"); removeCorner.CornerRadius = UDim.new(0, 4); removeCorner.Parent = removeBtn

            removeBtn.MouseButton1Click:Connect(function()
                table.remove(petList, i)
                updateList(scrollFrame, petList, isLeft)
                evaluateTrade()
            end)
            y = y + 32
        end
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(y + 4, scrollFrame.Size.Y.Offset + 4))
    end

    local function evaluateTrade()
        local leftTotal, rightTotal = 0, 0
        local leftMissing, rightMissing = {}, {}
        for _, pet in ipairs(leftPets) do
            local v = getPetValue(pet)
            if v then leftTotal = leftTotal + v else table.insert(leftMissing, pet) end
        end
        for _, pet in ipairs(rightPets) do
            local v = getPetValue(pet)
            if v then rightTotal = rightTotal + v else table.insert(rightMissing, pet) end
        end
        local diff = leftTotal - rightTotal
        local msg = ""
        if #leftPets == 0 and #rightPets == 0 then
            msg = "Add pets to both sides"
            resultText.TextColor3 = Color3.fromRGB(60, 70, 90)
        elseif #leftPets == 0 or #rightPets == 0 then
            msg = "Fill both sides to evaluate"
            resultText.TextColor3 = Color3.fromRGB(60, 70, 90)
        elseif #leftMissing > 0 or #rightMissing > 0 then
            local missing = {}
            for _, m in ipairs(leftMissing) do table.insert(missing, m) end
            for _, m in ipairs(rightMissing) do table.insert(missing, m) end
            msg = "⚠️ Unknown: " .. table.concat(missing, ", ")
            resultText.TextColor3 = Color3.fromRGB(200, 150, 50)
        elseif math.abs(diff) < 0.01 then
            msg = "⚖️ FAIR (" .. string.format("%.2f", leftTotal) .. " = " .. string.format("%.2f", rightTotal) .. ")"
            resultText.TextColor3 = Color3.fromRGB(200, 200, 50)
        elseif diff > 0 then
            msg = "✅ WIN by " .. string.format("%.2f", diff) .. " (You: " .. string.format("%.2f", leftTotal) .. " | Them: " .. string.format("%.2f", rightTotal) .. ")"
            resultText.TextColor3 = Color3.fromRGB(60, 200, 60)
        else
            msg = "❌ LOSE by " .. string.format("%.2f", math.abs(diff)) .. " (You: " .. string.format("%.2f", leftTotal) .. " | Them: " .. string.format("%.2f", rightTotal) .. ")"
            resultText.TextColor3 = Color3.fromRGB(200, 60, 60)
        end
        resultText.Text = msg
    end

    local function addPetToList(inputBox, petList, scrollFrame, isLeft)
        local name = inputBox.Text
        if name == "" then return end
        local val = getPetValue(name)
        if not val then
            local closest = findClosestPet(name)
            if closest then table.insert(petList, closest) else table.insert(petList, name) end
        else
            table.insert(petList, name)
        end
        inputBox.Text = ""
        updateList(scrollFrame, petList, isLeft)
        evaluateTrade()
    end

    leftAddBtn.MouseButton1Click:Connect(function() addPetToList(leftInput, leftPets, leftList, true) end)
    leftInput.FocusLost:Connect(function(enter) if enter then addPetToList(leftInput, leftPets, leftList, true) end end)
    rightAddBtn.MouseButton1Click:Connect(function() addPetToList(rightInput, rightPets, rightList, false) end)
    rightInput.FocusLost:Connect(function(enter) if enter then addPetToList(rightInput, rightPets, rightList, false) end end)
    calcBtn.MouseButton1Click:Connect(evaluateTrade)

    -- ===== TAB 3: THEMES =====
    local tab3Content = Instance.new("Frame")
    tab3Content.Name = "Tab3Content"
    tab3Content.Size = UDim2.new(1, 0, 1, 0)
    tab3Content.BackgroundTransparency = 1
    tab3Content.Visible = false
    tab3Content.Parent = contentArea

    local themeLabel = Instance.new("TextLabel")
    themeLabel.Size = UDim2.new(1, 0, 0, 40)
    themeLabel.Position = UDim2.new(0, 0, 0, 20)
    themeLabel.BackgroundTransparency = 1
    themeLabel.Text = "Choose a theme:"
    themeLabel.TextColor3 = Color3.fromRGB(40, 40, 60)
    themeLabel.TextSize = 18
    themeLabel.Font = Enum.Font.GothamBold
    themeLabel.TextXAlignment = Enum.TextXAlignment.Center
    themeLabel.Parent = tab3Content

    local themes = {
        {name = "Light", bg = Color3.fromRGB(245, 245, 250), bar = Color3.fromRGB(60, 100, 200), text = Color3.fromRGB(40, 40, 60)},
        {name = "Dark", bg = Color3.fromRGB(30, 30, 40), bar = Color3.fromRGB(80, 80, 150), text = Color3.fromRGB(220, 220, 240)},
        {name = "Pastel", bg = Color3.fromRGB(250, 240, 245), bar = Color3.fromRGB(200, 150, 200), text = Color3.fromRGB(80, 60, 80)},
    }
    local currentTheme = 1

    for i, theme in ipairs(themes) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.3, -10, 0, 40)
        btn.Position = UDim2.new((i-1)*0.33 + 0.02, 0, 0, 70)
        btn.BackgroundColor3 = theme.bg
        btn.BorderSizePixel = 1
        btn.BorderColor3 = theme.bar
        btn.Text = theme.name
        btn.TextColor3 = theme.text
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.Parent = tab3Content
        local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 8); btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            currentTheme = i
            -- Apply theme
            mainFrame.BackgroundColor3 = theme.bg
            titleBar.BackgroundColor3 = theme.bar
            tabContainer.BackgroundColor3 = theme.bg
            contentArea.BackgroundColor3 = theme.bg
            -- Update tab buttons
            for j, tabBtn in ipairs(tabButtons) do
                if j == 1 then -- we'll keep active tab logic, but just change colors
                    tabBtn.BackgroundColor3 = (i == 1 and theme.bar) or Color3.fromRGB(220, 225, 235)
                    tabBtn.TextColor3 = (i == 1 and Color3.fromRGB(255,255,255)) or theme.text
                end
            end
            -- More updates could be added
        end)
    end

    -- ===== TAB SWITCHING =====
    local function switchTab(tabIndex)
        for i, btn in ipairs(tabButtons) do
            if i == tabIndex then
                btn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                btn.BackgroundColor3 = Color3.fromRGB(220, 225, 235)
                btn.TextColor3 = Color3.fromRGB(60, 70, 90)
            end
        end
        tab1Content.Visible = (tabIndex == 1)
        tab2Content.Visible = (tabIndex == 2)
        tab3Content.Visible = (tabIndex == 3)
    end

    for i, btn in ipairs(tabButtons) do
        btn.MouseButton1Click:Connect(function() switchTab(i) end)
    end

    -- ===== DRAG (Mouse & Touch) =====
    local dragData = {dragging = false, startPos = nil, framePos = nil}
    local function onDragStart(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragData.dragging = true
            dragData.startPos = input.Position
            dragData.framePos = mainFrame.Position
        end
    end
    local function onDragEnd(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragData.dragging = false
        end
    end
    local function onDragMove(input)
        if dragData.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragData.startPos
            mainFrame.Position = UDim2.new(dragData.framePos.X.Scale, dragData.framePos.X.Offset + delta.X,
                                           dragData.framePos.Y.Scale, dragData.framePos.Y.Offset + delta.Y)
        end
    end

    titleBar.InputBegan:Connect(onDragStart)
    titleBar.InputEnded:Connect(onDragEnd)
    userInputService.InputChanged:Connect(onDragMove)

    -- ===== KEYBOARD SHORTCUTS =====
    userInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Escape then screenGui:Destroy() end
        if input.KeyCode == Enum.KeyCode.One then switchTab(1) end
        if input.KeyCode == Enum.KeyCode.Two then switchTab(2) end
        if input.KeyCode == Enum.KeyCode.Three then switchTab(3) end
    end)

    -- Init
    switchTab(1)

    return screenGui
end

-- ============================================================================
-- INIT
-- ============================================================================
repeat wait() until player and player.PlayerGui
local gui = createMainGUI()
print("✅ Yuno Value Checker loaded! | " .. #petValues .. " pets indexed.")