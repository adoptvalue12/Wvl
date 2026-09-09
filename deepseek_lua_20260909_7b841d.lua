--[[
    Adopt Me Value Checker & Trade Evaluator
    Inspired by Elvebredd.com
    All values extracted from provided screenshots
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local guiService = game:GetService("GuiService")
local userInputService = game:GetService("UserInputService")

-- ============================================================================
-- PET VALUE DATABASE
-- ============================================================================
local petValues = {
    -- ===== HIGH TIER (900+) =====
    ["bat dragon"] = 943,
    ["shadow dragon"] = 844,
    ["shadow"] = 844,
    ["giraffe"] = 476,
    ["frost dragon"] = 326,
    ["frost"] = 326,

    -- ===== MID-HIGH TIER (100-250) =====
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

    -- ===== MID TIER (30-80) =====
    ["diamond"] = 73,
    ["diamond pet"] = 73,
    ["monkey k"] = 66,
    ["arctic rel"] = 51,
    ["frostbite"] = 40,
    ["hot doggo"] = 36,
    ["strawberry"] = 34.5,
    ["strawberry pet"] = 34.5,
    ["chocolate"] = 33.75,
    ["chocolate pet"] = 33.75,
    ["grim dragon"] = 31,
    ["grim drag"] = 31,
    ["werewolf"] = 30,
    ["sugar glider"] = 27.5,
    ["mermicorn"] = 27,
    ["turtle"] = 23,
    ["strawberry"] = 24.5,
    ["bush elephant"] = 21.5,
    ["tortoiseshell"] = 21,
    ["fairy bat dragon"] = 19,
    ["fairy bat d"] = 19,

    -- ===== MID-LOW TIER (10-25) =====
    ["candyfloss"] = 19.5,
    ["candyflos"] = 19.5,
    ["kangaroo"] = 18,
    ["royal mist"] = 19.5,
    ["tío de nac"] = 19.25,
    ["tio de nac"] = 19.25,
    ["emperor c"] = 19,
    ["silverback"] = 19,
    ["black-che"] = 19,
    ["albino mo"] = 19,
    ["pirate ghost"] = 18.5,
    ["pirate gho"] = 18.5,
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

    -- ===== LOW TIER (5-7) =====
    ["red dutch"] = 7,
    ["cupid dra"] = 6.75,
    ["nessie"] = 6.5,
    ["strawberry"] = 6.5,
    ["sakura sp"] = 6,
    ["diamond a"] = 5.75,
    ["halloween"] = 5.5,
    ["papa moo"] = 5.5,

    -- ===== VERY LOW TIER (1-5) =====
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
    ["caelum c"] = 4.5,
    ["solaris"] = 4.5,
    ["diamond"] = 4.25,
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
    ["diamond"] = 1.85,
    ["golden pea"] = 1.8,
    ["candy har"] = 1.75,
    ["lava wolf"] = 1.75,
    ["diamond"] = 1.85,
    ["golden pe"] = 1.8,
    ["candy hair"] = 1.75,
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
    -- Try exact match first
    if petValues[lower] then
        return petValues[lower]
    end
    -- Try partial match
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
    local bestMatch = nil
    local bestScore = 0
    for key, _ in pairs(petValues) do
        local score = 0
        if string.find(key, lower) then
            score = #lower
        elseif string.find(lower, key) then
            score = #key
        end
        if score > bestScore then
            bestScore = score
            bestMatch = key
        end
    end
    return bestMatch
end

-- ============================================================================
-- GUI CREATION
-- ============================================================================
local function createMainGUI()
    -- ===== SCREEN GUI =====
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdoptMeValueChecker"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    -- ===== MAIN FRAME =====
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 420, 0, 560)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -280)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    -- Shadow / Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- ===== TITLE BAR =====
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 44)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "🔍 Adopt Me Value Checker"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 7)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
    closeBtn.BackgroundTransparency = 0
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- ===== TAB BUTTONS =====
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 44)
    tabContainer.Position = UDim2.new(0, 0, 0, 44)
    tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    tabContainer.BackgroundTransparency = 0
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame

    local tab1Btn = Instance.new("TextButton")
    tab1Btn.Name = "Tab1Btn"
    tab1Btn.Size = UDim2.new(0.5, -2, 1, -4)
    tab1Btn.Position = UDim2.new(0, 2, 0, 2)
    tab1Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
    tab1Btn.BackgroundTransparency = 0
    tab1Btn.BorderSizePixel = 0
    tab1Btn.Text = "📊 Value Lookup"
    tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tab1Btn.TextSize = 14
    tab1Btn.Font = Enum.Font.GothamBold
    tab1Btn.Parent = tabContainer

    local tab1Corner = Instance.new("UICorner")
    tab1Corner.CornerRadius = UDim.new(0, 6)
    tab1Corner.Parent = tab1Btn

    local tab2Btn = Instance.new("TextButton")
    tab2Btn.Name = "Tab2Btn"
    tab2Btn.Size = UDim2.new(0.5, -2, 1, -4)
    tab2Btn.Position = UDim2.new(0.5, 2, 0, 2)
    tab2Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    tab2Btn.BackgroundTransparency = 0
    tab2Btn.BorderSizePixel = 0
    tab2Btn.Text = "⚖️ Trade Evaluator"
    tab2Btn.TextColor3 = Color3.fromRGB(180, 180, 200)
    tab2Btn.TextSize = 14
    tab2Btn.Font = Enum.Font.GothamBold
    tab2Btn.Parent = tabContainer

    local tab2Corner = Instance.new("UICorner")
    tab2Corner.CornerRadius = UDim.new(0, 6)
    tab2Corner.Parent = tab2Btn

    -- ===== CONTENT AREA =====
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, 0, 1, -88)
    contentArea.Position = UDim2.new(0, 0, 0, 88)
    contentArea.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    contentArea.BackgroundTransparency = 0
    contentArea.BorderSizePixel = 0
    contentArea.ClipsDescendants = true
    contentArea.Parent = mainFrame

    -- ===== TAB 1: VALUE LOOKUP =====
    local tab1Content = Instance.new("Frame")
    tab1Content.Name = "Tab1Content"
    tab1Content.Size = UDim2.new(1, 0, 1, 0)
    tab1Content.Position = UDim2.new(0, 0, 0, 0)
    tab1Content.BackgroundTransparency = 1
    tab1Content.Visible = true
    tab1Content.Parent = contentArea

    -- Search Box
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.Size = UDim2.new(1, -24, 0, 40)
    searchBox.Position = UDim2.new(0, 12, 0, 12)
    searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    searchBox.BackgroundTransparency = 0
    searchBox.BorderSizePixel = 0
    searchBox.PlaceholderText = "Search for a pet..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 170)
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.TextSize = 16
    searchBox.Font = Enum.Font.Gotham
    searchBox.Text = ""
    searchBox.Parent = tab1Content

    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(0, 8)
    searchCorner.Parent = searchBox

    -- Search Button
    local searchBtn = Instance.new("TextButton")
    searchBtn.Name = "SearchBtn"
    searchBtn.Size = UDim2.new(0, 80, 0, 40)
    searchBtn.Position = UDim2.new(1, -92, 0, 12)
    searchBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
    searchBtn.BackgroundTransparency = 0
    searchBtn.BorderSizePixel = 0
    searchBtn.Text = "Search"
    searchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBtn.TextSize = 14
    searchBtn.Font = Enum.Font.GothamBold
    searchBtn.Parent = tab1Content

    local searchBtnCorner = Instance.new("UICorner")
    searchBtnCorner.CornerRadius = UDim.new(0, 8)
    searchBtnCorner.Parent = searchBtn

    -- Result Display
    local resultFrame = Instance.new("Frame")
    resultFrame.Name = "ResultFrame"
    resultFrame.Size = UDim2.new(1, -24, 0, 140)
    resultFrame.Position = UDim2.new(0, 12, 0, 64)
    resultFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    resultFrame.BackgroundTransparency = 0
    resultFrame.BorderSizePixel = 0
    resultFrame.Visible = false
    resultFrame.Parent = tab1Content

    local resultCorner = Instance.new("UICorner")
    resultCorner.CornerRadius = UDim.new(0, 8)
    resultCorner.Parent = resultFrame

    local petNameLabel = Instance.new("TextLabel")
    petNameLabel.Name = "PetNameLabel"
    petNameLabel.Size = UDim2.new(1, -20, 0, 30)
    petNameLabel.Position = UDim2.new(0, 10, 0, 10)
    petNameLabel.BackgroundTransparency = 1
    petNameLabel.Text = "Pet Name"
    petNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    petNameLabel.TextSize = 20
    petNameLabel.Font = Enum.Font.GothamBold
    petNameLabel.TextXAlignment = Enum.TextXAlignment.Center
    petNameLabel.Parent = resultFrame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.new(1, -20, 0, 40)
    valueLabel.Position = UDim2.new(0, 10, 0, 45)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = "Value: 0.00"
    valueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    valueLabel.TextSize = 28
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center
    valueLabel.Parent = resultFrame

    local notFoundLabel = Instance.new("TextLabel")
    notFoundLabel.Name = "NotFoundLabel"
    notFoundLabel.Size = UDim2.new(1, -24, 0, 40)
    notFoundLabel.Position = UDim2.new(0, 12, 0, 80)
    notFoundLabel.BackgroundTransparency = 1
    notFoundLabel.Text = "⚠️ Pet not found in database"
    notFoundLabel.TextColor3 = Color3.fromRGB(255, 150, 100)
    notFoundLabel.TextSize = 16
    notFoundLabel.Font = Enum.Font.Gotham
    notFoundLabel.TextXAlignment = Enum.TextXAlignment.Center
    notFoundLabel.Visible = false
    notFoundLabel.Parent = tab1Content

    -- Search function
    local function performSearch()
        local query = searchBox.Text
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
            resultFrame.Visible = true
            notFoundLabel.Visible = false
        else
            resultFrame.Visible = false
            notFoundLabel.Visible = true
            notFoundLabel.Text = '⚠️ "' .. query .. '" not found in database'
        end
    end

    searchBtn.MouseButton1Click:Connect(performSearch)
    searchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            performSearch()
        end
    end)

    -- ===== TAB 2: TRADE EVALUATOR =====
    local tab2Content = Instance.new("Frame")
    tab2Content.Name = "Tab2Content"
    tab2Content.Size = UDim2.new(1, 0, 1, 0)
    tab2Content.Position = UDim2.new(0, 0, 0, 0)
    tab2Content.BackgroundTransparency = 1
    tab2Content.Visible = false
    tab2Content.Parent = contentArea

    -- Left side (Your Offer)
    local leftFrame = Instance.new("Frame")
    leftFrame.Name = "LeftFrame"
    leftFrame.Size = UDim2.new(0.5, -10, 1, -10)
    leftFrame.Position = UDim2.new(0, 6, 0, 4)
    leftFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 30)
    leftFrame.BackgroundTransparency = 0
    leftFrame.BorderSizePixel = 0
    leftFrame.Parent = tab2Content

    local leftCorner = Instance.new("UICorner")
    leftCorner.CornerRadius = UDim.new(0, 8)
    leftCorner.Parent = leftFrame

    local leftTitle = Instance.new("TextLabel")
    leftTitle.Name = "LeftTitle"
    leftTitle.Size = UDim2.new(1, 0, 0, 28)
    leftTitle.Position = UDim2.new(0, 0, 0, 4)
    leftTitle.BackgroundTransparency = 1
    leftTitle.Text = "🟢 Your Offer"
    leftTitle.TextColor3 = Color3.fromRGB(100, 255, 150)
    leftTitle.TextSize = 14
    leftTitle.Font = Enum.Font.GothamBold
    leftTitle.TextXAlignment = Enum.TextXAlignment.Center
    leftTitle.Parent = leftFrame

    -- Left input
    local leftInput = Instance.new("TextBox")
    leftInput.Name = "LeftInput"
    leftInput.Size = UDim2.new(1, -12, 0, 30)
    leftInput.Position = UDim2.new(0, 6, 0, 36)
    leftInput.BackgroundColor3 = Color3.fromRGB(18, 28, 22)
    leftInput.BackgroundTransparency = 0
    leftInput.BorderSizePixel = 0
    leftInput.PlaceholderText = "Pet name..."
    leftInput.PlaceholderColor3 = Color3.fromRGB(120, 150, 130)
    leftInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    leftInput.TextSize = 13
    leftInput.Font = Enum.Font.Gotham
    leftInput.Text = ""
    leftInput.Parent = leftFrame

    local leftInputCorner = Instance.new("UICorner")
    leftInputCorner.CornerRadius = UDim.new(0, 6)
    leftInputCorner.Parent = leftInput

    local leftAddBtn = Instance.new("TextButton")
    leftAddBtn.Name = "LeftAddBtn"
    leftAddBtn.Size = UDim2.new(0, 50, 0, 30)
    leftAddBtn.Position = UDim2.new(1, -56, 0, 36)
    leftAddBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
    leftAddBtn.BackgroundTransparency = 0
    leftAddBtn.BorderSizePixel = 0
    leftAddBtn.Text = "+"
    leftAddBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    leftAddBtn.TextSize = 18
    leftAddBtn.Font = Enum.Font.GothamBold
    leftAddBtn.Parent = leftFrame

    local leftAddCorner = Instance.new("UICorner")
    leftAddCorner.CornerRadius = UDim.new(0, 6)
    leftAddCorner.Parent = leftAddBtn

    -- Left pet list
    local leftList = Instance.new("ScrollingFrame")
    leftList.Name = "LeftList"
    leftList.Size = UDim2.new(1, -12, 1, -78)
    leftList.Position = UDim2.new(0, 6, 0, 72)
    leftList.BackgroundColor3 = Color3.fromRGB(14, 22, 18)
    leftList.BackgroundTransparency = 0
    leftList.BorderSizePixel = 0
    leftList.CanvasSize = UDim2.new(0, 0, 0, 0)
    leftList.ScrollBarThickness = 4
    leftList.Parent = leftFrame

    local leftListCorner = Instance.new("UICorner")
    leftListCorner.CornerRadius = UDim.new(0, 6)
    leftListCorner.Parent = leftList

    -- Right side (Their Offer)
    local rightFrame = Instance.new("Frame")
    rightFrame.Name = "RightFrame"
    rightFrame.Size = UDim2.new(0.5, -10, 1, -10)
    rightFrame.Position = UDim2.new(0.5, 4, 0, 4)
    rightFrame.BackgroundColor3 = Color3.fromRGB(35, 25, 30)
    rightFrame.BackgroundTransparency = 0
    rightFrame.BorderSizePixel = 0
    rightFrame.Parent = tab2Content

    local rightCorner = Instance.new("UICorner")
    rightCorner.CornerRadius = UDim.new(0, 8)
    rightCorner.Parent = rightFrame

    local rightTitle = Instance.new("TextLabel")
    rightTitle.Name = "RightTitle"
    rightTitle.Size = UDim2.new(1, 0, 0, 28)
    rightTitle.Position = UDim2.new(0, 0, 0, 4)
    rightTitle.BackgroundTransparency = 1
    rightTitle.Text = "🔴 Their Offer"
    rightTitle.TextColor3 = Color3.fromRGB(255, 150, 100)
    rightTitle.TextSize = 14
    rightTitle.Font = Enum.Font.GothamBold
    rightTitle.TextXAlignment = Enum.TextXAlignment.Center
    rightTitle.Parent = rightFrame

    -- Right input
    local rightInput = Instance.new("TextBox")
    rightInput.Name = "RightInput"
    rightInput.Size = UDim2.new(1, -12, 0, 30)
    rightInput.Position = UDim2.new(0, 6, 0, 36)
    rightInput.BackgroundColor3 = Color3.fromRGB(28, 18, 22)
    rightInput.BackgroundTransparency = 0
    rightInput.BorderSizePixel = 0
    rightInput.PlaceholderText = "Pet name..."
    rightInput.PlaceholderColor3 = Color3.fromRGB(150, 120, 130)
    rightInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    rightInput.TextSize = 13
    rightInput.Font = Enum.Font.Gotham
    rightInput.Text = ""
    rightInput.Parent = rightFrame

    local rightInputCorner = Instance.new("UICorner")
    rightInputCorner.CornerRadius = UDim.new(0, 6)
    rightInputCorner.Parent = rightInput

    local rightAddBtn = Instance.new("TextButton")
    rightAddBtn.Name = "RightAddBtn"
    rightAddBtn.Size = UDim2.new(0, 50, 0, 30)
    rightAddBtn.Position = UDim2.new(1, -56, 0, 36)
    rightAddBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
    rightAddBtn.BackgroundTransparency = 0
    rightAddBtn.BorderSizePixel = 0
    rightAddBtn.Text = "+"
    rightAddBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rightAddBtn.TextSize = 18
    rightAddBtn.Font = Enum.Font.GothamBold
    rightAddBtn.Parent = rightFrame

    local rightAddCorner = Instance.new("UICorner")
    rightAddCorner.CornerRadius = UDim.new(0, 6)
    rightAddCorner.Parent = rightAddBtn

    -- Right pet list
    local rightList = Instance.new("ScrollingFrame")
    rightList.Name = "RightList"
    rightList.Size = UDim2.new(1, -12, 1, -78)
    rightList.Position = UDim2.new(0, 6, 0, 72)
    rightList.BackgroundColor3 = Color3.fromRGB(22, 14, 18)
    rightList.BackgroundTransparency = 0
    rightList.BorderSizePixel = 0
    rightList.CanvasSize = UDim2.new(0, 0, 0, 0)
    rightList.ScrollBarThickness = 4
    rightList.Parent = rightFrame

    local rightListCorner = Instance.new("UICorner")
    rightListCorner.CornerRadius = UDim.new(0, 6)
    rightListCorner.Parent = rightList

    -- Trade result bar (bottom of tab2)
    local resultBar = Instance.new("Frame")
    resultBar.Name = "ResultBar"
    resultBar.Size = UDim2.new(1, -24, 0, 50)
    resultBar.Position = UDim2.new(0, 12, 1, -56)
    resultBar.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    resultBar.BackgroundTransparency = 0
    resultBar.BorderSizePixel = 0
    resultBar.Parent = tab2Content

    local resultBarCorner = Instance.new("UICorner")
    resultBarCorner.CornerRadius = UDim.new(0, 8)
    resultBarCorner.Parent = resultBar

    local resultText = Instance.new("TextLabel")
    resultText.Name = "ResultText"
    resultText.Size = UDim2.new(0.7, 0, 1, 0)
    resultText.Position = UDim2.new(0, 10, 0, 0)
    resultText.BackgroundTransparency = 1
    resultText.Text = "Add pets to both sides to evaluate"
    resultText.TextColor3 = Color3.fromRGB(200, 200, 220)
    resultText.TextSize = 14
    resultText.Font = Enum.Font.Gotham
    resultText.TextXAlignment = Enum.TextXAlignment.Left
    resultText.Parent = resultBar

    local calcBtn = Instance.new("TextButton")
    calcBtn.Name = "CalcBtn"
    calcBtn.Size = UDim2.new(0, 100, 1, -8)
    calcBtn.Position = UDim2.new(1, -110, 0, 4)
    calcBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
    calcBtn.BackgroundTransparency = 0
    calcBtn.BorderSizePixel = 0
    calcBtn.Text = "Evaluate"
    calcBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    calcBtn.TextSize = 14
    calcBtn.Font = Enum.Font.GothamBold
    calcBtn.Parent = resultBar

    local calcCorner = Instance.new("UICorner")
    calcCorner.CornerRadius = UDim.new(0, 6)
    calcCorner.Parent = calcBtn

    -- ===== TRADE EVALUATOR LOGIC =====
    local leftPets = {}
    local rightPets = {}

    local function updateList(scrollFrame, petList, isLeft)
        -- Clear existing items
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child.Name == "PetItem" then
                child:Destroy()
            end
        end

        local yOffset = 4
        local totalHeight = 0

        for i, petName in ipairs(petList) do
            local item = Instance.new("Frame")
            item.Name = "PetItem"
            item.Size = UDim2.new(1, -8, 0, 28)
            item.Position = UDim2.new(0, 4, 0, yOffset)
            item.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            item.BackgroundTransparency = 0
            item.BorderSizePixel = 0
            item.Parent = scrollFrame

            local itemCorner = Instance.new("UICorner")
            itemCorner.CornerRadius = UDim.new(0, 4)
            itemCorner.Parent = item

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "NameLabel"
            nameLabel.Size = UDim2.new(1, -30, 1, 0)
            nameLabel.Position = UDim2.new(0, 6, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = petName
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 12
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = item

            local removeBtn = Instance.new("TextButton")
            removeBtn.Name = "RemoveBtn"
            removeBtn.Size = UDim2.new(0, 22, 0, 22)
            removeBtn.Position = UDim2.new(1, -26, 0, 3)
            removeBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
            removeBtn.BackgroundTransparency = 0
            removeBtn.BorderSizePixel = 0
            removeBtn.Text = "✕"
            removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            removeBtn.TextSize = 12
            removeBtn.Font = Enum.Font.GothamBold
            removeBtn.Parent = item

            local removeCorner = Instance.new("UICorner")
            removeCorner.CornerRadius = UDim.new(0, 4)
            removeCorner.Parent = removeBtn

            removeBtn.MouseButton1Click:Connect(function()
                table.remove(petList, i)
                updateList(scrollFrame, petList, isLeft)
                -- Auto evaluate
                evaluateTrade()
            end)

            yOffset = yOffset + 32
            totalHeight = yOffset + 4
        end

        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(totalHeight, scrollFrame.Size.Y.Offset + 4))
    end

    local function evaluateTrade()
        local leftTotal = 0
        local rightTotal = 0
        local leftMissing = {}
        local rightMissing = {}

        for _, petName in ipairs(leftPets) do
            local val = getPetValue(petName)
            if val then
                leftTotal = leftTotal + val
            else
                table.insert(leftMissing, petName)
            end
        end

        for _, petName in ipairs(rightPets) do
            local val = getPetValue(petName)
            if val then
                rightTotal = rightTotal + val
            else
                table.insert(rightMissing, petName)
            end
        end

        local diff = leftTotal - rightTotal
        local resultMsg = ""

        if #leftPets == 0 and #rightPets == 0 then
            resultMsg = "Add pets to both sides to evaluate"
            resultText.TextColor3 = Color3.fromRGB(200, 200, 220)
        elseif #leftPets == 0 then
            resultMsg = "Add your pets (left side)"
            resultText.TextColor3 = Color3.fromRGB(200, 200, 220)
        elseif #rightPets == 0 then
            resultMsg = "Add their pets (right side)"
            resultText.TextColor3 = Color3.fromRGB(200, 200, 220)
        elseif #leftMissing > 0 or #rightMissing > 0 then
            local missing = {}
            for _, m in ipairs(leftMissing) do table.insert(missing, m) end
            for _, m in ipairs(rightMissing) do table.insert(missing, m) end
            resultMsg = "⚠️ Unknown pets: " .. table.concat(missing, ", ")
            resultText.TextColor3 = Color3.fromRGB(255, 180, 80)
        elseif math.abs(diff) < 0.01 then
            resultMsg = "⚖️ FAIR — Both sides are equal! (" .. string.format("%.2f", leftTotal) .. " = " .. string.format("%.2f", rightTotal) .. ")"
            resultText.TextColor3 = Color3.fromRGB(255, 255, 100)
        elseif diff > 0 then
            resultMsg = "✅ WIN — Your offer is better by " .. string.format("%.2f", diff) .. " (You: " .. string.format("%.2f", leftTotal) .. " | Them: " .. string.format("%.2f", rightTotal) .. ")"
            resultText.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            resultMsg = "❌ LOSE — Their offer is better by " .. string.format("%.2f", math.abs(diff)) .. " (You: " .. string.format("%.2f", leftTotal) .. " | Them: " .. string.format("%.2f", rightTotal) .. ")"
            resultText.TextColor3 = Color3.fromRGB(255, 100, 100)
        end

        resultText.Text = resultMsg
    end

    local function addPetToList(inputBox, petList, scrollFrame, isLeft)
        local petName = inputBox.Text
        if petName == "" then return end

        -- Check if pet exists
        local val = getPetValue(petName)
        if not val then
            -- Try to find closest match
            local closest = findClosestPet(petName)
            if closest then
                table.insert(petList, closest)
            else
                -- Still add it but with a warning
                table.insert(petList, petName)
            end
        else
            table.insert(petList, petName)
        end

        inputBox.Text = ""
        updateList(scrollFrame, petList, isLeft)
        evaluateTrade()
    end

    leftAddBtn.MouseButton1Click:Connect(function()
        addPetToList(leftInput, leftPets, leftList, true)
    end)

    leftInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            addPetToList(leftInput, leftPets, leftList, true)
        end
    end)

    rightAddBtn.MouseButton1Click:Connect(function()
        addPetToList(rightInput, rightPets, rightList, false)
    end)

    rightInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            addPetToList(rightInput, rightPets, rightList, false)
        end
    end)

    calcBtn.MouseButton1Click:Connect(evaluateTrade)

    -- ===== TAB SWITCHING =====
    local function switchTab(tabIndex)
        if tabIndex == 1 then
            tab1Content.Visible = true
            tab2Content.Visible = false
            tab1Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
            tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tab2Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            tab2Btn.TextColor3 = Color3.fromRGB(180, 180, 200)
        else
            tab1Content.Visible = false
            tab2Content.Visible = true
            tab2Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
            tab2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tab1Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            tab1Btn.TextColor3 = Color3.fromRGB(180, 180, 200)
        end
    end

    tab1Btn.MouseButton1Click:Connect(function() switchTab(1) end)
    tab2Btn.MouseButton1Click:Connect(function() switchTab(2) end)

    -- ===== DRAG TO MOVE =====
    local dragging = false
    local dragStart = nil
    local frameStart = nil

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = mainFrame.Position
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    userInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                frameStart.X.Scale,
                frameStart.X.Offset + delta.X,
                frameStart.Y.Scale,
                frameStart.Y.Offset + delta.Y
            )
        end
    end)

    -- ===== KEYBOARD SHORTCUTS =====
    userInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Escape then
            screenGui:Destroy()
        end
        if input.KeyCode == Enum.KeyCode.One then
            switchTab(1)
        end
        if input.KeyCode == Enum.KeyCode.Two then
            switchTab(2)
        end
    end)

    return screenGui
end

-- ============================================================================
-- INITIALIZE
-- ============================================================================
-- Wait for player to be fully loaded
repeat wait() until player and player.PlayerGui

-- Create the GUI
local gui = createMainGUI()

-- Print startup message
print("🔍 Adopt Me Value Checker loaded!")
print("📊 " .. #petValues .. " pet values loaded")
print("⚖️ Tab 1: Value Lookup | Tab 2: Trade Evaluator")
print("🔄 Drag title bar to move | ESC to close")