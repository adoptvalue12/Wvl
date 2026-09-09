--[[
    Yuno Hub – Adopt Me Value Checker & Trade Evaluator
    Base de données enrichie avec toutes les valeurs des captures
    Bouton flottant pour rouvrir la fenêtre, version mobile-friendly
]]

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local guiService = game:GetService("GuiService")
local userInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera

-- ============================================================================
-- BASE DE DONNÉES COMPLÈTE (pets + œufs)
-- ============================================================================
local petValues = {
    -- ===== ŒUFS =====
    ["safari egg"] = 205,
    ["jungle egg"] = 80,
    ["farm egg"] = 78,
    ["christmas i"] = 18,
    ["aussie egg"] = 5.5,
    ["royal dese"] = 1,
    ["wrapped i"] = 0.8,
    ["fossil egg"] = 0.7,
    ["ocean egg"] = 0.5,
    ["urban egg"] = 0.5,
    ["danger egg"] = 0.45,
    ["diamond e"] = 0.4,
    ["royal azte"] = 0.4,
    ["royal moo"] = 0.4,
    ["fool egg"] = 0.35,
    ["mythic egg"] = 0.3,
    ["woodland"] = 0.3,
    ["zodiac mini"] = 0.3,
    ["japan egg"] = 0.18,
    ["southeast"] = 0.17,
    ["desert egg"] = 0.12,
    ["garden egg"] = 0.1,
    ["golden egg"] = 0.1,
    ["moon egg"] = 0.09,
    ["christmas"] = 0.6,
    ["easter 202"] = 1.75,
    ["basic egg"] = 0.02,
    ["cracked egg"] = 0.02,
    ["retired egg"] = 0.05,
    ["pet egg"] = 0.04,

    -- ===== ANCIENS / RARES =====
    ["african wif"] = 155,
    ["hedgehog"] = 68.5,
    ["dalmatian"] = 61.5,        -- déjà présent
    ["mini pig"] = 40,
    ["pelican"] = 37,
    ["goose"] = 36.5,
    ["cow"] = 34,
    ["peppermint"] = 28.75,
    ["cabbit"] = 27.5,
    ["siamese c"] = 21.75,
    ["alpaca"] = 21.5,
    ["flamingo"] = 19.5,
    ["caterpillar"] = 19.5,
    ["elephant"] = 15.75,
    ["lion"] = 13.25,
    ["zombie bug"] = 13.5,
    ["crocodile"] = 13,
    ["bald eagle"] = 13,
    ["blue dog"] = 12.5,
    ["border co"] = 11.5,
    ["sea slug"] = 9.75,
    ["jellyfish"] = 9.5,
    ["munchkin"] = 9.5,
    ["tri-horned"] = 9.25,
    ["irish water"] = 9,
    ["pig"] = 7.5,
    ["lion cub"] = 7.5,
    ["christmas"] = 7,
    ["goat"] = 7,
    ["many mac"] = 7,
    ["pink cat"] = 6.75,
    ["giant ante"] = 6.75,
    ["tortuga de"] = 6.75,
    ["sheeeep"] = 6,
    ["arctic fox"] = 6,
    ["meerkat"] = 5.25,
    ["glacier mo"] = 5.25,
    ["shrew"] = 5,
    ["honey ba"] = 5,
    ["puffin"] = 4.75,
    ["hyena"] = 4.25,
    ["ring-tailes"] = 4.75,
    ["brown bears"] = 4,
    ["polar bears"] = 3.75,
    ["slime"] = 4.65,
    ["groundhog"] = 4.5,
    ["platypus"] = 4.25,
    ["happy cla"] = 4.25,
    ["hare"] = 3.15,
    ["mule"] = 3.15,
    ["purple butterfly"] = 3.25,
    ["zombie wolf"] = 3,
    ["ghost dog"] = 2.15,
    ["alley cat"] = 2.85,
    ["ghost bunny"] = 2.85,
    ["ice wolf"] = 2.5,
    ["kookaburra"] = 2.5,
    ["llama"] = 2.25,
    ["husky"] = 2,
    ["swan"] = 1.85,
    ["leopard s"] = 2.15,
    ["rhino"] = 2,
    ["french bull"] = 1.85,
    ["english sh"] = 1.58,
    ["evil rock"] = 1.43,
    ["kiwi"] = 1.25,
    ["reindeer"] = 0.95,
    ["silly duck"] = 2,
    ["wild boar"] = 1.5,
    ["capybara"] = 1.35,
    ["black panther"] = 1.25,
    ["drake"] = 1.15,
    ["royal corgi"] = 1.53,
    ["woolly rhino"] = 1.48,
    ["ram"] = 1.38,
    ["tuxedo cat"] = 1.3,
    ["snow mon"] = 1.22,
    ["german shorthair"] = 1.1,
    ["s'mores ra"] = 1.08,
    ["chef gorill"] = 1.01,
    ["headless"] = 2.15,
    ["ice cream"] = 2.15,
    ["flaming f"] = 2,
    ["turkey"] = 2,
    ["wood pigeon"] = 2,
    ["gaelic fae"] = 1.8,
    ["lamb"] = 1.8,
    ["chocolate"] = 1.73,

    -- ===== VALEURS DÉJÀ PRÉSENTES (on les garde, mais on ajoute les nouvelles) =====
    -- ... (le reste de la base existante est conservé ci‑dessous)
}

-- On fusionne avec l'ancienne base pour ne rien perdre
local existingValues = {
    -- Haut de gamme
    ["bat dragon"] = 943, ["shadow dragon"] = 844, ["shadow"] = 844,
    ["giraffe"] = 476, ["frost dragon"] = 326, ["frost"] = 326,
    ["owl"] = 247, ["parrot"] = 247, ["giant panda"] = 220,
    ["crow"] = 220, ["balloon unicorn"] = 202, ["balloon ur"] = 202,
    ["blazing lion"] = 202, ["blazing lice"] = 202, ["cryptid"] = 196,
    ["haetae"] = 196, ["orchid butterfly"] = 116, ["orchid bur"] = 116,
    ["evil unicorn"] = 109, ["undead jousting horse"] = 93, ["undead joc"] = 93,
    ["diamond egg"] = 96, ["diamond e"] = 96, ["arctic reindeer"] = 95,
    ["arctic rel"] = 95, ["frostbite eagle"] = 94, ["frostbite e"] = 94,
    ["monkey king"] = 92, ["monkey ki"] = 92, ["jekyll hydra"] = 83,
    -- Moyen-haut
    ["diamond"] = 73, ["monkey k"] = 66, ["arctic rel"] = 51,
    ["frostbite"] = 40, ["hot doggo"] = 36, ["strawberry"] = 34.5,
    ["chocolate"] = 33.75, ["grim dragon"] = 31, ["werewolf"] = 30,
    ["sugar glider"] = 27.5, ["mermicorn"] = 27, ["turtle"] = 23,
    ["bush elephant"] = 21.5, ["tortoiseshell"] = 21, ["fairy bat dragon"] = 19,
    ["candyfloss"] = 19.5, ["kangaroo"] = 18, ["royal mist"] = 19.5,
    ["tío de nac"] = 19.25, ["emperor c"] = 19, ["silverback"] = 19,
    ["black-che"] = 19, ["albino mo"] = 19, ["pirate ghost"] = 18.5,
    ["sugar axo"] = 18.5, ["mechapup"] = 18.25, ["frost unic"] = 18.25,
    ["winged tic"] = 15, ["shark pup"] = 15, ["vampire d"] = 14,
    ["ocirooster"] = 14, ["jousting"] = 14, ["phantom"] = 14,
    ["moonbean"] = 13, ["hero gibb"] = 13, ["shark pup"] = 12.5,
    ["jousting"] = 11, ["phantom"] = 10.75, ["hero gibb"] = 10.5,
    ["candicom"] = 9.75, ["aurora fox"] = 7.25, ["ballet swa"] = 7,
    ["midnight"] = 7, ["red dutch"] = 7, ["cupid dra"] = 6.75,
    ["nessie"] = 6.5, ["strawberry"] = 6.5, ["sakura sp"] = 6,
    ["diamond a"] = 5.75, ["halloween"] = 5.5, ["papa moo"] = 5.5,
    ["field moul"] = 5.25, ["glacier kli"] = 5.25, ["lava drag"] = 5.25,
    ["frost fury"] = 5, ["cerberus"] = 4.75, ["owlbear"] = 4.75,
    ["2d doggy"] = 4.5, ["aestus"] = 4.5, ["caelum cae"] = 4.5,
    ["solaris"] = 4.5, ["diamond a"] = 4.25, ["giant gold"] = 4.25,
    ["fallow deer"] = 4, ["glormy le"] = 3.75, ["arctic dus"] = 3.65,
    ["diamond i"] = 3.5, ["dancing d"] = 3.25, ["ice golem"] = 3.25,
    ["rose drag"] = 3.15, ["latte kits"] = 3, ["scorching"] = 3,
    ["dragonfrui"] = 2.85, ["kelp capta"] = 2.75, ["moose cali"] = 2.75,
    ["dango pe"] = 2.5, ["pineapple"] = 2.5, ["majestic f"] = 2.25,
    ["skole-rex"] = 2.25, ["cheetah"] = 2.15, ["glormy ho"] = 2.15,
    ["lavender i"] = 2.15, ["frost phoe"] = 2, ["kiwi kiwi"] = 2,
    ["queen bee"] = 2, ["tree kang"] = 2, ["corn dog"] = 1.85,
    ["golden pea"] = 1.8, ["candy hair"] = 1.75, ["lava wolf"] = 1.75,
    ["leviathan"] = 1.75, ["violet butt"] = 1.75, ["albino gor"] = 1.65,
    ["golden ch"] = 1.65, ["scarebear"] = 1.65, ["diamond"] = 1.5,
    ["moonbear"] = 1.5, ["naughty"] = 1.5, ["peahen"] = 1.5,
    ["2d kitty"] = 1.35, ["diamond l"] = 1.35, ["ninja mon"] = 1.35,
    ["green but"] = 1.25, ["prismatic"] = 1.2, ["rainbow"] = 1.15,
    ["yule log"] = 1.1, ["dire stag"] = 1.05, ["firefly"] = 1.05,
    ["astronaut"] = 1, ["dodo"] = 1, ["golden rat"] = 1,
    ["phoenix"] = 1, ["shark"] = 1, ["black widow"] = 0.97,
    ["goldhorn"] = 0.96, ["capricorn"] = 0.95, ["pirate hero"] = 0.94,
    ["spinosaurus"] = 0.93, ["axolotl"] = 0.88, ["peacock"] = 0.88,
    ["cactus fri"] = 0.85, ["emberliqh"] = 0.85, ["royal cap"] = 0.83,
    ["apple owl"] = 0.82, ["peach owl"] = 0.82, ["golden w"] = 0.8,
    ["volcanic f"] = 0.8, ["guardian l"] = 0.79, ["gargoyle"] = 0.78,
    ["princess c"] = 0.78, ["influencer"] = 0.77, ["naga drag"] = 0.77,
    ["unicorn"] = 0.77, ["white am"] = 0.77, ["netland pc"] = 0.76,
    ["chameleon"] = 0.76, ["snow owl"] = 0.75, ["cuddly ca"] = 0.75,
    ["white amoeba"] = 0.73, ["cuddly cat"] = 0.7, ["golden lizard"] = 0.7,
    ["mushroom"] = 0.7, ["squid"] = 0.7, ["sunrise duck"] = 0.67,
    ["billy goat"] = 0.6, ["gilded snail"] = 0.6, ["green-chicken"] = 0.6,
    ["winged horse"] = 0.6, ["cinnamon"] = 0.01, ["dalmatian"] = 61.5,
}

-- Fusion : on garde les nouvelles valeurs, on écrase les anciennes si conflit (mais normalement c'est propre)
for k, v in pairs(existingValues) do
    petValues[k] = v
end

-- ============================================================================
-- FONCTIONS UTILITAIRES
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

local function tableFind(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then return i end
    end
    return nil
end

-- ============================================================================
-- CRÉATION DE L'INTERFACE (avec bouton flottant)
-- ============================================================================
local function createMainGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YunoHub"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui

    -- Dimensions adaptées à l'écran
    local viewportSize = camera.ViewportSize
    local winWidth = math.min(460, viewportSize.X * 0.92)
    local winHeight = math.min(640, viewportSize.Y * 0.85)

    -- ===== FENÊTRE PRINCIPALE =====
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, winWidth, 0, winHeight)
    mainFrame.Position = UDim2.new(0.5, -winWidth/2, 0.5, -winHeight/2)
    mainFrame.BackgroundColor3 = Color3.fromRGB(252, 245, 250)
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = mainFrame

    -- Ombre
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045058"
    shadow.ImageColor3 = Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = 0.4
    shadow.ZIndex = 0
    shadow.Parent = mainFrame

    -- ===== HEADER (barre de titre + onglets) =====
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 90)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(255, 180, 200)
    header.BorderSizePixel = 0
    header.ClipsDescendants = true
    header.Parent = mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = header

    local headerMask = Instance.new("Frame")
    headerMask.Size = UDim2.new(1, 0, 0, 90)
    headerMask.Position = UDim2.new(0, 0, 0, 0)
    headerMask.BackgroundColor3 = header.BackgroundColor3
    headerMask.BorderSizePixel = 0
    headerMask.Parent = header

    -- Zone de drag transparente
    local dragArea = Instance.new("Frame")
    dragArea.Name = "DragArea"
    dragArea.Size = UDim2.new(1, 0, 1, 0)
    dragArea.Position = UDim2.new(0, 0, 0, 0)
    dragArea.BackgroundTransparency = 1
    dragArea.ZIndex = 0
    dragArea.Parent = header

    -- Titre
    local titleRow = Instance.new("Frame")
    titleRow.Size = UDim2.new(1, 0, 0, 50)
    titleRow.Position = UDim2.new(0, 0, 0, 0)
    titleRow.BackgroundTransparency = 1
    titleRow.ZIndex = 1
    titleRow.Parent = header

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -140, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Yuno Hub"  -- nom normal
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 22
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleRow

    -- Bouton minimiser (cache la fenêtre)
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 36, 0, 36)
    minBtn.Position = UDim2.new(1, -88, 0, 7)
    minBtn.BackgroundColor3 = Color3.fromRGB(255, 220, 220)
    minBtn.BorderSizePixel = 0
    minBtn.Text = "—"
    minBtn.TextColor3 = Color3.fromRGB(80, 40, 50)
    minBtn.TextSize = 24
    minBtn.Font = Enum.Font.GothamBold
    minBtn.ZIndex = 2
    minBtn.Parent = titleRow
    local minCorner = Instance.new("UICorner"); minCorner.CornerRadius = UDim.new(0, 8); minCorner.Parent = minBtn

    -- Bouton fermer (détruit la GUI)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 36, 0, 36)
    closeBtn.Position = UDim2.new(1, -44, 0, 7)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 120)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 2
    closeBtn.Parent = titleRow
    local closeCorner = Instance.new("UICorner"); closeCorner.CornerRadius = UDim.new(0, 8); closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)
    minBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        -- On affiche le bouton flottant
        floatingBtn.Visible = true
    end)

    -- Onglets
    local tabRow = Instance.new("Frame")
    tabRow.Size = UDim2.new(1, 0, 0, 40)
    tabRow.Position = UDim2.new(0, 0, 0, 50)
    tabRow.BackgroundTransparency = 1
    tabRow.ZIndex = 1
    tabRow.Parent = header

    local tabNames = {"🔍 Valeur", "⚖️ Trade", "❤️ Favoris", "🎨 Thème"}
    local tabButtons = {}
    for i, name in ipairs(tabNames) do
        local btn = Instance.new("TextButton")
        btn.Name = "Tab" .. i
        btn.Size = UDim2.new(1 / #tabNames, -4, 1, -4)
        btn.Position = UDim2.new((i-1) / #tabNames + 0.02, 0, 0, 2)
        btn.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 180, 200) or Color3.fromRGB(240, 230, 235)
        btn.BorderSizePixel = 0
        btn.Text = name
        btn.TextColor3 = i == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(100, 70, 80)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamBold
        btn.ZIndex = 2
        btn.Parent = tabRow
        local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 10); btnCorner.Parent = btn
        tabButtons[i] = btn
    end

    -- ===== ZONE DE CONTENU =====
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, 0, 1, -90)
    contentArea.Position = UDim2.new(0, 0, 0, 90)
    contentArea.BackgroundColor3 = Color3.fromRGB(252, 245, 250)
    contentArea.BorderSizePixel = 0
    contentArea.ClipsDescendants = true
    contentArea.Parent = mainFrame

    -- ===== TAB 1 : VALEUR =====
    local tab1 = Instance.new("Frame")
    tab1.Size = UDim2.new(1, 0, 1, 0)
    tab1.BackgroundTransparency = 1
    tab1.Visible = true
    tab1.Parent = contentArea

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -24, 0, 50)
    searchBox.Position = UDim2.new(0, 12, 0, 12)
    searchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.BorderSizePixel = 0
    searchBox.PlaceholderText = "Cherche un pet ou un œuf..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(180, 160, 170)
    searchBox.TextColor3 = Color3.fromRGB(60, 40, 50)
    searchBox.TextSize = 16
    searchBox.Font = Enum.Font.Gotham
    searchBox.Text = ""
    searchBox.Parent = tab1
    local searchCorner = Instance.new("UICorner"); searchCorner.CornerRadius = UDim.new(0, 12); searchCorner.Parent = searchBox

    local suggestions = Instance.new("ScrollingFrame")
    suggestions.Size = UDim2.new(1, -24, 0, 140)
    suggestions.Position = UDim2.new(0, 12, 0, 68)
    suggestions.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    suggestions.BorderSizePixel = 0
    suggestions.Visible = false
    suggestions.CanvasSize = UDim2.new(0, 0, 0, 0)
    suggestions.ScrollBarThickness = 0
    suggestions.Parent = tab1
    local suggCorner = Instance.new("UICorner"); suggCorner.CornerRadius = UDim.new(0, 10); suggCorner.Parent = suggestions

    local resultFrame = Instance.new("Frame")
    resultFrame.Size = UDim2.new(1, -24, 0, 180)
    resultFrame.Position = UDim2.new(0, 12, 0.35, 0)
    resultFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    resultFrame.BorderSizePixel = 0
    resultFrame.Visible = false
    resultFrame.Parent = tab1
    local resCorner = Instance.new("UICorner"); resCorner.CornerRadius = UDim.new(0, 12); resCorner.Parent = resultFrame

    local petImg = Instance.new("ImageLabel")
    petImg.Size = UDim2.new(0, 80, 0, 80)
    petImg.Position = UDim2.new(0, 12, 0, 12)
    petImg.BackgroundTransparency = 1
    petImg.Image = "rbxassetid://131603476"
    petImg.Parent = resultFrame

    local petNameLabel = Instance.new("TextLabel")
    petNameLabel.Size = UDim2.new(1, -110, 0, 32)
    petNameLabel.Position = UDim2.new(0, 100, 0, 12)
    petNameLabel.BackgroundTransparency = 1
    petNameLabel.Text = "Pet"
    petNameLabel.TextColor3 = Color3.fromRGB(60, 40, 50)
    petNameLabel.TextSize = 20
    petNameLabel.Font = Enum.Font.GothamBold
    petNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    petNameLabel.Parent = resultFrame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, -110, 0, 40)
    valueLabel.Position = UDim2.new(0, 100, 0, 46)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = "Valeur : 0.00"
    valueLabel.TextColor3 = Color3.fromRGB(255, 150, 180)
    valueLabel.TextSize = 26
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = resultFrame

    local favBtn = Instance.new("TextButton")
    favBtn.Size = UDim2.new(0, 140, 0, 36)
    favBtn.Position = UDim2.new(1, -152, 1, -44)
    favBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 220)
    favBtn.BorderSizePixel = 0
    favBtn.Text = "❤️ Ajouter"
    favBtn.TextColor3 = Color3.fromRGB(200, 60, 100)
    favBtn.TextSize = 14
    favBtn.Font = Enum.Font.GothamBold
    favBtn.Parent = resultFrame
    local favCorner = Instance.new("UICorner"); favCorner.CornerRadius = UDim.new(0, 8); favCorner.Parent = favBtn

    local notFound = Instance.new("TextLabel")
    notFound.Size = UDim2.new(1, -24, 0, 40)
    notFound.Position = UDim2.new(0, 12, 0.45, 0)
    notFound.BackgroundTransparency = 1
    notFound.Text = "⚠️ Inconnu"
    notFound.TextColor3 = Color3.fromRGB(200, 100, 50)
    notFound.TextSize = 16
    notFound.Font = Enum.Font.Gotham
    notFound.TextXAlignment = Enum.TextXAlignment.Center
    notFound.Visible = false
    notFound.Parent = tab1

    -- ===== SUGGESTIONS =====
    local allPetNames = getAllPetNames()
    local function updateSuggestions(query)
        if query == "" then suggestions.Visible = false return end
        local lower = string.lower(query)
        local matches = {}
        for _, name in ipairs(allPetNames) do
            if string.find(name, lower) then
                table.insert(matches, name)
                if #matches >= 8 then break end
            end
        end
        if #matches == 0 then suggestions.Visible = false return end
        for _, child in pairs(suggestions:GetChildren()) do if child.Name == "SuggestionItem" then child:Destroy() end end
        local y = 4
        for _, name in ipairs(matches) do
            local btn = Instance.new("TextButton")
            btn.Name = "SuggestionItem"
            btn.Size = UDim2.new(1, -8, 0, 30)
            btn.Position = UDim2.new(0, 4, 0, y)
            btn.BackgroundColor3 = Color3.fromRGB(250, 240, 245)
            btn.BorderSizePixel = 0
            btn.Text = name
            btn.TextColor3 = Color3.fromRGB(60, 40, 50)
            btn.TextSize = 14
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = suggestions
            local itemCorner = Instance.new("UICorner"); itemCorner.CornerRadius = UDim.new(0, 4); itemCorner.Parent = btn
            btn.MouseButton1Click:Connect(function()
                searchBox.Text = name
                suggestions.Visible = false
                performSearch(name)
            end)
            y = y + 34
        end
        suggestions.CanvasSize = UDim2.new(0, 0, 0, y + 4)
        suggestions.Visible = true
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        updateSuggestions(searchBox.Text)
    end)
    searchBox.FocusLost:Connect(function()
        wait(0.2)
        suggestions.Visible = false
    end)

    -- ===== RECHERCHE =====
    local currentPetName = ""
    local function performSearch(query)
        if query == "" then
            resultFrame.Visible = false
            notFound.Visible = false
            return
        end
        local value = getPetValue(query)
        if value then
            local match = findClosestPet(query) or query
            currentPetName = match
            petNameLabel.Text = string.upper(string.sub(match, 1, 1)) .. string.sub(match, 2)
            valueLabel.Text = "Valeur : " .. string.format("%.2f", value)
            resultFrame.Visible = true
            notFound.Visible = false
        else
            resultFrame.Visible = false
            notFound.Visible = true
            notFound.Text = '⚠️ "' .. query .. '" introuvable'
        end
    end

    searchBox.FocusLost:Connect(function(enter)
        if enter then
            performSearch(searchBox.Text)
            suggestions.Visible = false
        end
    end)

    -- ===== FAVORIS =====
    local favorites = {}

    favBtn.MouseButton1Click:Connect(function()
        if currentPetName ~= "" and not tableFind(favorites, currentPetName) then
            table.insert(favorites, currentPetName)
            updateFavoritesTab()
            favBtn.Text = "✅ Ajouté !"
            favBtn.BackgroundColor3 = Color3.fromRGB(180, 255, 200)
            wait(0.5)
            favBtn.Text = "❤️ Ajouter"
            favBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 220)
        elseif currentPetName ~= "" then
            favBtn.Text = "⚠️ Déjà dans les favoris"
            wait(0.5)
            favBtn.Text = "❤️ Ajouter"
        end
    end)

    -- ===== TAB 2 : TRADE =====
    local tab2 = Instance.new("Frame")
    tab2.Size = UDim2.new(1, 0, 1, 0)
    tab2.BackgroundTransparency = 1
    tab2.Visible = false
    tab2.Parent = contentArea

    -- Côté gauche
    local leftFrame = Instance.new("Frame")
    leftFrame.Size = UDim2.new(0.48, -6, 1, -10)
    leftFrame.Position = UDim2.new(0, 4, 0, 4)
    leftFrame.BackgroundColor3 = Color3.fromRGB(240, 255, 240)
    leftFrame.BorderSizePixel = 0
    leftFrame.Parent = tab2
    local leftCorner = Instance.new("UICorner"); leftCorner.CornerRadius = UDim.new(0, 12); leftCorner.Parent = leftFrame

    local leftTitle = Instance.new("TextLabel")
    leftTitle.Size = UDim2.new(1, 0, 0, 28)
    leftTitle.Position = UDim2.new(0, 0, 0, 4)
    leftTitle.BackgroundTransparency = 1
    leftTitle.Text = "🟢 Votre offre"
    leftTitle.TextColor3 = Color3.fromRGB(60, 160, 80)
    leftTitle.TextSize = 13
    leftTitle.Font = Enum.Font.GothamBold
    leftTitle.TextXAlignment = Enum.TextXAlignment.Center
    leftTitle.Parent = leftFrame

    local leftInput = Instance.new("TextBox")
    leftInput.Size = UDim2.new(1, -12, 0, 34)
    leftInput.Position = UDim2.new(0, 6, 0, 36)
    leftInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    leftInput.BorderSizePixel = 0
    leftInput.PlaceholderText = "Pet..."
    leftInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    leftInput.TextColor3 = Color3.fromRGB(40, 40, 40)
    leftInput.TextSize = 14
    leftInput.Font = Enum.Font.Gotham
    leftInput.Text = ""
    leftInput.Parent = leftFrame
    local leftInputCorner = Instance.new("UICorner"); leftInputCorner.CornerRadius = UDim.new(0, 8); leftInputCorner.Parent = leftInput

    local leftAdd = Instance.new("TextButton")
    leftAdd.Size = UDim2.new(0, 50, 0, 34)
    leftAdd.Position = UDim2.new(1, -56, 0, 36)
    leftAdd.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
    leftAdd.BorderSizePixel = 0
    leftAdd.Text = "+"
    leftAdd.TextColor3 = Color3.fromRGB(255, 255, 255)
    leftAdd.TextSize = 22
    leftAdd.Font = Enum.Font.GothamBold
    leftAdd.Parent = leftFrame
    local leftAddCorner = Instance.new("UICorner"); leftAddCorner.CornerRadius = UDim.new(0, 8); leftAddCorner.Parent = leftAdd

    local leftList = Instance.new("ScrollingFrame")
    leftList.Size = UDim2.new(1, -12, 1, -80)
    leftList.Position = UDim2.new(0, 6, 0, 76)
    leftList.BackgroundColor3 = Color3.fromRGB(248, 255, 248)
    leftList.BorderSizePixel = 0
    leftList.CanvasSize = UDim2.new(0, 0, 0, 0)
    leftList.ScrollBarThickness = 4
    leftList.Parent = leftFrame
    local leftListCorner = Instance.new("UICorner"); leftListCorner.CornerRadius = UDim.new(0, 8); leftListCorner.Parent = leftList

    -- Côté droit
    local rightFrame = Instance.new("Frame")
    rightFrame.Size = UDim2.new(0.48, -6, 1, -10)
    rightFrame.Position = UDim2.new(0.52, 2, 0, 4)
    rightFrame.BackgroundColor3 = Color3.fromRGB(255, 240, 240)
    rightFrame.BorderSizePixel = 0
    rightFrame.Parent = tab2
    local rightCorner = Instance.new("UICorner"); rightCorner.CornerRadius = UDim.new(0, 12); rightCorner.Parent = rightFrame

    local rightTitle = Instance.new("TextLabel")
    rightTitle.Size = UDim2.new(1, 0, 0, 28)
    rightTitle.Position = UDim2.new(0, 0, 0, 4)
    rightTitle.BackgroundTransparency = 1
    rightTitle.Text = "🔴 Leur offre"
    rightTitle.TextColor3 = Color3.fromRGB(200, 60, 60)
    rightTitle.TextSize = 13
    rightTitle.Font = Enum.Font.GothamBold
    rightTitle.TextXAlignment = Enum.TextXAlignment.Center
    rightTitle.Parent = rightFrame

    local rightInput = Instance.new("TextBox")
    rightInput.Size = UDim2.new(1, -12, 0, 34)
    rightInput.Position = UDim2.new(0, 6, 0, 36)
    rightInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    rightInput.BorderSizePixel = 0
    rightInput.PlaceholderText = "Pet..."
    rightInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    rightInput.TextColor3 = Color3.fromRGB(40, 40, 40)
    rightInput.TextSize = 14
    rightInput.Font = Enum.Font.Gotham
    rightInput.Text = ""
    rightInput.Parent = rightFrame
    local rightInputCorner = Instance.new("UICorner"); rightInputCorner.CornerRadius = UDim.new(0, 8); rightInputCorner.Parent = rightInput

    local rightAdd = Instance.new("TextButton")
    rightAdd.Size = UDim2.new(0, 50, 0, 34)
    rightAdd.Position = UDim2.new(1, -56, 0, 36)
    rightAdd.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    rightAdd.BorderSizePixel = 0
    rightAdd.Text = "+"
    rightAdd.TextColor3 = Color3.fromRGB(255, 255, 255)
    rightAdd.TextSize = 22
    rightAdd.Font = Enum.Font.GothamBold
    rightAdd.Parent = rightFrame
    local rightAddCorner = Instance.new("UICorner"); rightAddCorner.CornerRadius = UDim.new(0, 8); rightAddCorner.Parent = rightAdd

    local rightList = Instance.new("ScrollingFrame")
    rightList.Size = UDim2.new(1, -12, 1, -80)
    rightList.Position = UDim2.new(0, 6, 0, 76)
    rightList.BackgroundColor3 = Color3.fromRGB(255, 248, 248)
    rightList.BorderSizePixel = 0
    rightList.CanvasSize = UDim2.new(0, 0, 0, 0)
    rightList.ScrollBarThickness = 4
    rightList.Parent = rightFrame
    local rightListCorner = Instance.new("UICorner"); rightListCorner.CornerRadius = UDim.new(0, 8); rightListCorner.Parent = rightList

    -- Barre de résultat
    local resultBar = Instance.new("Frame")
    resultBar.Size = UDim2.new(1, -24, 0, 54)
    resultBar.Position = UDim2.new(0, 12, 1, -60)
    resultBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    resultBar.BorderSizePixel = 0
    resultBar.Parent = tab2
    local barCorner = Instance.new("UICorner"); barCorner.CornerRadius = UDim.new(0, 12); barCorner.Parent = resultBar

    local resultLabel = Instance.new("TextLabel")
    resultLabel.Size = UDim2.new(0.6, 0, 1, 0)
    resultLabel.Position = UDim2.new(0, 10, 0, 0)
    resultLabel.BackgroundTransparency = 1
    resultLabel.Text = "Ajoute des pets des deux côtés"
    resultLabel.TextColor3 = Color3.fromRGB(100, 80, 90)
    resultLabel.TextSize = 13
    resultLabel.Font = Enum.Font.Gotham
    resultLabel.TextXAlignment = Enum.TextXAlignment.Left
    resultLabel.Parent = resultBar

    local evalBtn = Instance.new("TextButton")
    evalBtn.Size = UDim2.new(0, 100, 1, -8)
    evalBtn.Position = UDim2.new(1, -110, 0, 4)
    evalBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 200)
    evalBtn.BorderSizePixel = 0
    evalBtn.Text = "Évaluer"
    evalBtn.TextColor3 = Color3.fromRGB(80, 40, 50)
    evalBtn.TextSize = 13
    evalBtn.Font = Enum.Font.GothamBold
    evalBtn.Parent = resultBar
    local evalCorner = Instance.new("UICorner"); evalCorner.CornerRadius = UDim.new(0, 8); evalCorner.Parent = evalBtn

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 70, 1, -8)
    clearBtn.Position = UDim2.new(0.75, -80, 0, 4)
    clearBtn.BackgroundColor3 = Color3.fromRGB(220, 200, 200)
    clearBtn.BorderSizePixel = 0
    clearBtn.Text = "Effacer"
    clearBtn.TextColor3 = Color3.fromRGB(80, 40, 50)
    clearBtn.TextSize = 12
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.Parent = resultBar
    local clearCorner = Instance.new("UICorner"); clearCorner.CornerRadius = UDim.new(0, 8); clearCorner.Parent = clearBtn

    -- ===== TRADE LOGIC =====
    local leftPets, rightPets = {}, {}

    local function updateTradeList(scrollFrame, petList, isLeft)
        for _, child in pairs(scrollFrame:GetChildren()) do if child.Name == "PetItem" then child:Destroy() end end
        local y = 4
        for i, petName in ipairs(petList) do
            local item = Instance.new("Frame")
            item.Name = "PetItem"
            item.Size = UDim2.new(1, -8, 0, 30)
            item.Position = UDim2.new(0, 4, 0, y)
            item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            item.BorderSizePixel = 0
            item.Parent = scrollFrame
            local itemCorner = Instance.new("UICorner"); itemCorner.CornerRadius = UDim.new(0, 6); itemCorner.Parent = item

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1, -30, 1, 0)
            nameLbl.Position = UDim2.new(0, 6, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = petName
            nameLbl.TextColor3 = Color3.fromRGB(40, 40, 40)
            nameLbl.TextSize = 13
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.Parent = item

            local remove = Instance.new("TextButton")
            remove.Size = UDim2.new(0, 26, 0, 26)
            remove.Position = UDim2.new(1, -30, 0, 2)
            remove.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            remove.BorderSizePixel = 0
            remove.Text = "✕"
            remove.TextColor3 = Color3.fromRGB(255,255,255)
            remove.TextSize = 14
            remove.Font = Enum.Font.GothamBold
            remove.Parent = item
            local remCorner = Instance.new("UICorner"); remCorner.CornerRadius = UDim.new(0, 4); remCorner.Parent = remove

            remove.MouseButton1Click:Connect(function()
                table.remove(petList, i)
                updateTradeList(scrollFrame, petList, isLeft)
                evaluateTrade()
            end)
            y = y + 34
        end
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(y + 4, scrollFrame.Size.Y.Offset + 4))
    end

    local function evaluateTrade()
        local leftTotal, rightTotal = 0, 0
        local leftMiss, rightMiss = {}, {}
        for _, p in ipairs(leftPets) do
            local v = getPetValue(p)
            if v then leftTotal = leftTotal + v else table.insert(leftMiss, p) end
        end
        for _, p in ipairs(rightPets) do
            local v = getPetValue(p)
            if v then rightTotal = rightTotal + v else table.insert(rightMiss, p) end
        end
        local diff = leftTotal - rightTotal
        local msg = ""
        if #leftPets == 0 and #rightPets == 0 then
            msg = "Ajoute des pets des deux côtés"
            resultLabel.TextColor3 = Color3.fromRGB(100,80,90)
        elseif #leftPets == 0 or #rightPets == 0 then
            msg = "Remplis les deux côtés"
            resultLabel.TextColor3 = Color3.fromRGB(100,80,90)
        elseif #leftMiss > 0 or #rightMiss > 0 then
            local miss = {}
            for _, m in ipairs(leftMiss) do table.insert(miss, m) end
            for _, m in ipairs(rightMiss) do table.insert(miss, m) end
            msg = "⚠️ Inconnus : " .. table.concat(miss, ", ")
            resultLabel.TextColor3 = Color3.fromRGB(200,150,50)
        elseif math.abs(diff) < 0.01 then
            msg = "⚖️ ÉQUITABLE (" .. string.format("%.2f", leftTotal) .. " = " .. string.format("%.2f", rightTotal) .. ")"
            resultLabel.TextColor3 = Color3.fromRGB(200,200,50)
        elseif diff > 0 then
            msg = "✅ GAGNANT de " .. string.format("%.2f", diff) .. " (Vous: " .. string.format("%.2f", leftTotal) .. " | Eux: " .. string.format("%.2f", rightTotal) .. ")"
            resultLabel.TextColor3 = Color3.fromRGB(60,200,60)
        else
            msg = "❌ PERDANT de " .. string.format("%.2f", math.abs(diff)) .. " (Vous: " .. string.format("%.2f", leftTotal) .. " | Eux: " .. string.format("%.2f", rightTotal) .. ")"
            resultLabel.TextColor3 = Color3.fromRGB(200,60,60)
        end
        resultLabel.Text = msg
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
        updateTradeList(scrollFrame, petList, isLeft)
        evaluateTrade()
    end

    leftAdd.MouseButton1Click:Connect(function() addPetToList(leftInput, leftPets, leftList, true) end)
    leftInput.FocusLost:Connect(function(enter) if enter then addPetToList(leftInput, leftPets, leftList, true) end end)
    rightAdd.MouseButton1Click:Connect(function() addPetToList(rightInput, rightPets, rightList, false) end)
    rightInput.FocusLost:Connect(function(enter) if enter then addPetToList(rightInput, rightPets, rightList, false) end end)
    evalBtn.MouseButton1Click:Connect(evaluateTrade)

    clearBtn.MouseButton1Click:Connect(function()
        leftPets = {}
        rightPets = {}
        updateTradeList(leftList, leftPets, true)
        updateTradeList(rightList, rightPets, false)
        evaluateTrade()
        resultLabel.Text = "Listes vidées"
    end)

    -- ===== TAB 3 : FAVORIS =====
    local tab3 = Instance.new("Frame")
    tab3.Size = UDim2.new(1, 0, 1, 0)
    tab3.BackgroundTransparency = 1
    tab3.Visible = false
    tab3.Parent = contentArea

    local favTitle = Instance.new("TextLabel")
    favTitle.Size = UDim2.new(1, 0, 0, 40)
    favTitle.Position = UDim2.new(0, 0, 0, 10)
    favTitle.BackgroundTransparency = 1
    favTitle.Text = "❤️ Mes favoris"
    favTitle.TextColor3 = Color3.fromRGB(60, 40, 50)
    favTitle.TextSize = 20
    favTitle.Font = Enum.Font.GothamBold
    favTitle.TextXAlignment = Enum.TextXAlignment.Center
    favTitle.Parent = tab3

    local favList = Instance.new("ScrollingFrame")
    favList.Size = UDim2.new(1, -24, 1, -60)
    favList.Position = UDim2.new(0, 12, 0, 56)
    favList.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    favList.BorderSizePixel = 0
    favList.CanvasSize = UDim2.new(0, 0, 0, 0)
    favList.ScrollBarThickness = 4
    favList.Parent = tab3
    local favListCorner = Instance.new("UICorner"); favListCorner.CornerRadius = UDim.new(0, 12); favListCorner.Parent = favList

    local function updateFavoritesTab()
        for _, child in pairs(favList:GetChildren()) do if child.Name == "FavItem" then child:Destroy() end end
        local y = 4
        for i, name in ipairs(favorites) do
            local item = Instance.new("Frame")
            item.Name = "FavItem"
            item.Size = UDim2.new(1, -8, 0, 36)
            item.Position = UDim2.new(0, 4, 0, y)
            item.BackgroundColor3 = Color3.fromRGB(252, 245, 250)
            item.BorderSizePixel = 0
            item.Parent = favList
            local itemCorner = Instance.new("UICorner"); itemCorner.CornerRadius = UDim.new(0, 6); itemCorner.Parent = item

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1, -80, 1, 0)
            nameLbl.Position = UDim2.new(0, 6, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = name .. "  (Valeur: " .. string.format("%.2f", getPetValue(name) or 0) .. ")"
            nameLbl.TextColor3 = Color3.fromRGB(60, 40, 50)
            nameLbl.TextSize = 14
            nameLbl.Font = Enum.Font.Gotham
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.Parent = item

            local removeFav = Instance.new("TextButton")
            removeFav.Size = UDim2.new(0, 60, 0, 28)
            removeFav.Position = UDim2.new(1, -68, 0, 4)
            removeFav.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
            removeFav.BorderSizePixel = 0
            removeFav.Text = "Retirer"
            removeFav.TextColor3 = Color3.fromRGB(255,255,255)
            removeFav.TextSize = 12
            removeFav.Font = Enum.Font.GothamBold
            removeFav.Parent = item
            local remCorner = Instance.new("UICorner"); remCorner.CornerRadius = UDim.new(0, 4); remCorner.Parent = removeFav

            removeFav.MouseButton1Click:Connect(function()
                table.remove(favorites, i)
                updateFavoritesTab()
            end)
            y = y + 40
        end
        favList.CanvasSize = UDim2.new(0, 0, 0, math.max(y + 4, favList.Size.Y.Offset + 4))
    end

    -- ===== TAB 4 : THÈMES =====
    local tab4 = Instance.new("Frame")
    tab4.Size = UDim2.new(1, 0, 1, 0)
    tab4.BackgroundTransparency = 1
    tab4.Visible = false
    tab4.Parent = contentArea

    local themeLabel = Instance.new("TextLabel")
    themeLabel.Size = UDim2.new(1, 0, 0, 40)
    themeLabel.Position = UDim2.new(0, 0, 0, 20)
    themeLabel.BackgroundTransparency = 1
    themeLabel.Text = "Choisis ton thème :"
    themeLabel.TextColor3 = Color3.fromRGB(60, 40, 50)
    themeLabel.TextSize = 18
    themeLabel.Font = Enum.Font.GothamBold
    themeLabel.TextXAlignment = Enum.TextXAlignment.Center
    themeLabel.Parent = tab4

    local themes = {
        {name = "Preppy", bg = Color3.fromRGB(252, 245, 250), bar = Color3.fromRGB(255, 180, 200), text = Color3.fromRGB(60, 40, 50)},
        {name = "Dark", bg = Color3.fromRGB(30, 30, 40), bar = Color3.fromRGB(80, 80, 150), text = Color3.fromRGB(220, 220, 240)},
        {name = "Pastel", bg = Color3.fromRGB(250, 240, 245), bar = Color3.fromRGB(200, 150, 200), text = Color3.fromRGB(80, 60, 80)},
        {name = "Ocean", bg = Color3.fromRGB(235, 248, 255), bar = Color3.fromRGB(100, 180, 220), text = Color3.fromRGB(30, 60, 80)},
    }

    for i, theme in ipairs(themes) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.23, -10, 0, 48)
        btn.Position = UDim2.new((i-1)*0.25 + 0.02, 0, 0, 72)
        btn.BackgroundColor3 = theme.bar
        btn.BorderSizePixel = 0
        btn.Text = theme.name
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamBold
        btn.Parent = tab4
        local btnCorner = Instance.new("UICorner"); btnCorner.CornerRadius = UDim.new(0, 10); btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            mainFrame.BackgroundColor3 = theme.bg
            header.BackgroundColor3 = theme.bar
            headerMask.BackgroundColor3 = theme.bar
            contentArea.BackgroundColor3 = theme.bg
            for j, tb in ipairs(tabButtons) do
                if j == 1 then
                    tb.BackgroundColor3 = theme.bar
                    tb.TextColor3 = Color3.fromRGB(255,255,255)
                else
                    tb.BackgroundColor3 = Color3.fromRGB(240, 230, 235)
                    tb.TextColor3 = theme.text
                end
            end
        end)
    end

    -- ===== COMMUTATION DES ONGLETS =====
    local function switchTab(index)
        for i, btn in ipairs(tabButtons) do
            if i == index then
                btn.BackgroundColor3 = Color3.fromRGB(255, 180, 200)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                btn.BackgroundColor3 = Color3.fromRGB(240, 230, 235)
                btn.TextColor3 = Color3.fromRGB(100, 70, 80)
            end
        end
        tab1.Visible = (index == 1)
        tab2.Visible = (index == 2)
        tab3.Visible = (index == 3)
        tab4.Visible = (index == 4)
        if index == 3 then updateFavoritesTab() end
    end

    for i, btn in ipairs(tabButtons) do
        btn.MouseButton1Click:Connect(function() switchTab(i) end)
    end

    -- ===== DRAG =====
    local dragData = {dragging = false, startPos = nil, framePos = nil}
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragData.dragging = true
            dragData.startPos = input.Position
            dragData.framePos = mainFrame.Position
        end
    end)
    dragArea.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragData.dragging = false
        end
    end)
    userInputService.InputChanged:Connect(function(input)
        if dragData.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragData.startPos
            mainFrame.Position = UDim2.new(dragData.framePos.X.Scale, dragData.framePos.X.Offset + delta.X,
                                           dragData.framePos.Y.Scale, dragData.framePos.Y.Offset + delta.Y)
        end
    end)

    -- ===== BOUTON FLOTTANT (pour rouvrir la fenêtre) =====
    local floatingBtn = Instance.new("TextButton")
    floatingBtn.Name = "FloatingBtn"
    floatingBtn.Size = UDim2.new(0, 60, 0, 60)
    floatingBtn.Position = UDim2.new(1, -80, 1, -80)
    floatingBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 200)
    floatingBtn.BorderSizePixel = 0
    floatingBtn.Text = "Y"
    floatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatingBtn.TextSize = 28
    floatingBtn.Font = Enum.Font.GothamBold
    floatingBtn.ZIndex = 10
    floatingBtn.Visible = false  -- caché par défaut (la fenêtre est visible)
    floatingBtn.Parent = screenGui

    local floatCorner = Instance.new("UICorner")
    floatCorner.CornerRadius = UDim.new(0, 30)
    floatCorner.Parent = floatingBtn

    -- Ombre du bouton flottant
    local floatShadow = Instance.new("ImageLabel")
    floatShadow.Size = UDim2.new(1, 10, 1, 10)
    floatShadow.Position = UDim2.new(0, -5, 0, -5)
    floatShadow.BackgroundTransparency = 1
    floatShadow.Image = "rbxassetid://1316045058"
    floatShadow.ImageColor3 = Color3.fromRGB(0,0,0)
    floatShadow.ImageTransparency = 0.5
    floatShadow.ZIndex = 9
    floatShadow.Parent = floatingBtn

    floatingBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        floatingBtn.Visible = false
    end)

    -- ===== RACCOURCIS =====
    userInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Escape then screenGui:Destroy() end
        if input.KeyCode == Enum.KeyCode.One then switchTab(1) end
        if input.KeyCode == Enum.KeyCode.Two then switchTab(2) end
        if input.KeyCode == Enum.KeyCode.Three then switchTab(3) end
        if input.KeyCode == Enum.KeyCode.Four then switchTab(4) end
    end)

    switchTab(1)
    print("✅ Yuno Hub GUI créée avec succès !")
    return screenGui
end

-- ============================================================================
-- LANCEMENT
-- ============================================================================
repeat wait() until player and player.PlayerGui
local gui = createMainGUI()
print("🚀 Yuno Hub chargé ! " .. #petValues .. " éléments en base.")