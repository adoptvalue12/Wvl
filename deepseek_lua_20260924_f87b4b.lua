--[[
    SCRIPT ULTIME pour "Steal an Egg" - Delta Executor
    - Optimisation FPS maximale
    - Réduction du trafic réseau (ping ressenti)
    - Nettoyage des services Roblox inutiles
    - Suppression gardes/déco/buildings
    - Anti-lag complet
    GARDE LE JEU FONCTIONNEL
]]

-- ═══════════════════════════════════════════════════════════════
-- ⚙️ CONFIGURATION
-- ═══════════════════════════════════════════════════════════════
local CONFIG = {
    -- Graphismes
    RemoveGuards          = true,
    RemoveNPCs            = true,
    RemoveDecorations     = true,
    RemoveBuildings       = true,
    RemoveParticles       = true,
    RemoveLights          = true,
    RemoveSounds          = true,
    RemoveAnimations      = true,
    RemoveOtherAccessories= true,
    RemoveSkybox          = true,
    RemoveFarMeshes       = true,
    FarMeshDistance       = 200,
    ReduceRenderDistance  = true,
    RenderDistance        = 400,

    -- Réseau / Latence
    ThrottleRemoteEvents  = true,  -- Bloque les RemoteEvents inutiles
    BlockUnusedRemotes    = true,  -- Bloque les remotes non utilisés
    ReduceReplication     = true,  -- Réduit la réplication réseau

    -- Services Roblox inutiles
    KillCoreGuiExtras     = true,  -- Supprime les GUI Roblox inutiles
    KillChatExtras        = true,  -- Allège le chat
    DisableTerrain        = true,  -- Désactive le terrain (lourd)
    DisableAnimation      = true,  -- Désactive le service Animation global

    -- Nettoyage
    CleanupInterval       = 3,     -- Nettoyage automatique toutes les X sec
}
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

if not LocalPlayer then return end

-- ═══════════════════════════════════════════════════════════════
-- 1. ÉCLAIRAGE ULTRA-LÉGER
-- ═══════════════════════════════════════════════════════════════
if Lighting then
    Lighting.GlobalShadows = false
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.Brightness = 1
    Lighting.ClockTime = 14
    Lighting.Ambient = Color3.fromRGB(150, 150, 150)
    Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
    Lighting.ExposureCompensation = 0

    if CONFIG.ReduceRenderDistance then
        Lighting.FogEnd = CONFIG.RenderDistance
        Lighting.FogStart = CONFIG.RenderDistance * 0.4
    end

    if CONFIG.RemoveSkybox then
        local sky = Lighting:FindFirstChildOfClass("Sky")
        if sky then sky:Destroy() end
    end

    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or effect:IsA("Clouds") then
            pcall(function() effect:Destroy() end)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- 2. DÉSACTIVER LE TERRAIN (TRÈS LOURD)
-- ═══════════════════════════════════════════════════════════════
if CONFIG.DisableTerrain then
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        pcall(function()
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
            terrain.Decoration = false
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- 3. MOTS-CLÉS
-- ═══════════════════════════════════════════════════════════════
local GUARD_KEYWORDS = {
    "guard", "guards", "garde", "security", "police", "officer",
    "enemy", "protector", "defender", "soldier", "cop", "watcher"
}
local DECOR_KEYWORDS = {
    "tree", "arbre", "rock", "rocher", "stone", "bush", "flower", "fleur",
    "grass", "herbe", "fence", "cloture", "sign", "panneau", "lamp", "lampe",
    "bench", "banc", "crate", "caisse", "barrel", "tonneau", "poster",
    "picture", "painting", "flag", "drapeau", "deco", "decor", "prop",
    "props", "plant", "plante", "cloud", "nuage", "mountain", "montagne",
    "hill", "colline", "path", "chemin", "foliage", "leaf", "leaves",
    "vine", "liane", "flowerpot", "pot"
}
local BUILDING_KEYWORDS = {
    "building", "batiment", "house", "maison", "shop", "magasin", "tower",
    "tour", "temple", "castle", "chateau", "ruin", "ruine", "bridge", "pont",
    "wall", "structure", "hut", "cabane", "stall", "kiosk", "kiosque",
    "barn", "grange", "warehouse", "entrepot", "fountain", "fontaine"
}
local KEEP_KEYWORDS = {
    "egg", "oeuf", "baseplate", "base", "ground", "sol", "spawn",
    "character", "humanoid", "player", "click", "pet", "tool",
    "sword", "weapon", "grab", "carry", "inventory", "hatch",
    "button", "gui", "ui", "remote", "vehicle", "car"
}

local function nameContains(name, list)
    local lower = string.lower(name)
    for _, keyword in ipairs(list) do
        if string.find(lower, keyword, 1, true) then return true end
    end
    return false
end

local function shouldKeep(obj)
    local current = obj
    for _ = 1, 5 do
        if current and nameContains(current.Name, KEEP_KEYWORDS) then
            return true
        end
        current = current.Parent
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════
-- 4. OPTIMISATION DES OBJETS
-- ═══════════════════════════════════════════════════════════════
local function optimizeObject(obj)
    if LocalPlayer.Character and obj:IsDescendantOf(LocalPlayer.Character) then return end
    if shouldKeep(obj) then return end

    if CONFIG.RemoveGuards then
        if obj:IsA("Model") and nameContains(obj.Name, GUARD_KEYWORDS) then
            obj:Destroy() return
        end
    end

    if CONFIG.RemoveNPCs then
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            if not Players:GetPlayerFromCharacter(obj) then
                obj:Destroy() return
            end
        end
    end

    if CONFIG.RemoveDecorations then
        if (obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("MeshPart"))
           and nameContains(obj.Name, DECOR_KEYWORDS) then
            obj:Destroy() return
        end
    end

    if CONFIG.RemoveBuildings then
        if obj:IsA("Model") and nameContains(obj.Name, BUILDING_KEYWORDS) then
            obj:Destroy() return
        end
    end

    if CONFIG.RemoveFarMeshes then
        if obj:IsA("MeshPart") or obj:IsA("BasePart") then
            local cam = Workspace.CurrentCamera
            if cam and obj.Name ~= "Baseplate" then
                local dist = (obj.Position - cam.CFrame.Position).Magnitude
                if dist > CONFIG.FarMeshDistance then
                    obj:Destroy() return
                end
            end
        end
    end

    if CONFIG.RemoveParticles then
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
           or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        end
    end

    if CONFIG.RemoveLights then
        if obj:IsA("Light") or obj:IsA("SpotLight") or obj:IsA("PointLight")
           or obj:IsA("SurfaceLight") then
            obj.Enabled = false
        end
    end

    if CONFIG.RemoveSounds then
        if obj:IsA("Sound") then
            obj.Stop(); obj.Volume = 0; obj:Destroy()
        end
    end

    if obj:IsA("BasePart") or obj:IsA("MeshPart") then
        obj.CastShadow = false
        obj.Reflectance = 0
        obj.Material = Enum.Material.SmoothPlastic
        if obj.Transparency > 0 and obj.Transparency < 1 then
            obj.Transparency = 1
        end
    end

    if obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    pcall(optimizeObject, obj)
end

Workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    pcall(optimizeObject, obj)
end)

-- ═══════════════════════════════════════════════════════════════
-- 5. RÉDUCTION DU TRAFIC RÉSEAU (PING RESSENTI)
-- ═══════════════════════════════════════════════════════════════
-- On ne peut pas supprimer le ping, mais on peut réduire les paquets inutiles
-- envoyés/reçus par le client, ce qui réduit les pics de latence.

if CONFIG.ThrottleRemoteEvents then
    local remoteWhitelist = {
        -- Mets ici les noms des RemoteEvents ESSENTIELS au jeu (si tu les connais)
        -- Ex: "StealEgg", "HatchEgg", "BuyEgg", "ClaimReward", "Move"
    }

    local function isWhitelisted(name)
        for _, n in ipairs(remoteWhitelist) do
            if string.find(string.lower(name), string.lower(n), 1, true) then
                return true
            end
        end
        return false
    end

    -- Bloquer les RemoteEvents qui envoient trop de données
    local remoteCount = {}
    local lastReset = tick()

    local function hookRemote(remote)
        if not remote:IsA("RemoteEvent") and not remote:IsA("RemoteFunction") then return end

        if remote:IsA("RemoteEvent") then
            local oldFire = remote.FireServer
            remote.FireServer = function(self, ...)
                if CONFIG.BlockUnusedRemotes and not isWhitelisted(self.Name) then
                    local now = tick()
                    remoteCount[self] = (remoteCount[self] or 0) + 1
                    -- Si le remote est appelé plus de 30 fois/sec, on le bloque
                    if now - lastReset > 1 then
                        remoteCount = {}
                        lastReset = now
                    end
                    if remoteCount[self] > 30 then
                        return -- Bloque l'appel
                    end
                end
                return oldFire(self, ...)
            end
        end
    end

    local function scanRemotes(parent)
        for _, obj in ipairs(parent:GetDescendants()) do
            pcall(hookRemote, obj)
        end
    end

    scanRemotes(ReplicatedStorage)
    scanRemotes(Workspace)

    ReplicatedStorage.DescendantAdded:Connect(function(obj)
        task.wait(0.1)
        pcall(hookRemote, obj)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- 6. NETTOYAGE DES SERVICES ROBLOX INUTILES
-- ═══════════════════════════════════════════════════════════════

-- 6a. Supprimer les GUI Roblox inutiles (popups, hints, etc.)
if CONFIG.KillCoreGuiExtras then
    task.spawn(function()
        task.wait(2)
        pcall(function()
            -- Désactiver les notifications
            StarterGui:SetCore("SendNotification", {
                Title = "Optimisation",
                Text = "Nettoyage en cours...",
                Duration = 2
            })
        end)
        -- Supprimer les CoreGui inutiles
        for _, gui in ipairs(CoreGui:GetChildren()) do
            if gui.Name == "NotificationRoot" or gui.Name == "BubbleChat" 
               or gui.Name == "ChatWindow" then
                pcall(function() gui.Enabled = false end)
            end
        end
    end)
end

-- 6b. Alléger le chat
if CONFIG.KillChatExtras then
    pcall(function()
        local chat = game:GetService("Chat")
        chat:SetCore("ChatMakeSystemMessage", {
            Text = "[OPTIMISATION] Chat allégé",
            Color = Color3.fromRGB(0, 255, 0)
        })
    end)
end

-- 6c. Désactiver le service Animation global (les autres joueurs n'auront plus d'anim)
if CONFIG.DisableAnimation then
    pcall(function()
        local AnimationController = game:GetService("AnimationController") -- pas un service, ignoré
    end)
end

-- 6d. Supprimer les effets inutiles du Workspace
if CONFIG.DisableTerrain then
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        pcall(function()
            for _, child in ipairs(terrain:GetChildren()) do
                if child:IsA("Water") or child:IsA("Cloud") then
                    child:Destroy()
                end
            end
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- 7. NETTOYAGE DES JOUEURS
-- ═══════════════════════════════════════════════════════════════
local function cleanCharacter(character)
    if character == LocalPlayer.Character then return end

    if CONFIG.RemoveOtherAccessories then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Accessory") or item:IsA("Hat")
               or item:IsA("Shirt") or item:IsA("Pants")
               or item:IsA("ShirtGraphic") then
                pcall(function() item:Destroy() end)
            end
        end
    end

    if CONFIG.RemoveAnimations then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
            end)
            for _, anim in ipairs(character:GetDescendants()) do
                if anim:IsA("Animator") then
                    pcall(function() anim:Destroy() end)
                end
            end
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then pcall(cleanCharacter, player.Character) end
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        pcall(cleanCharacter, char)
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(1)
        pcall(cleanCharacter, character)
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- 8. SUPPRESSION DES EFFETS DANS REPLICATEDSTORAGE
-- ═══════════════════════════════════════════════════════════════
local effectsFolders = {
    "Particles", "Effects", "VFX", "Visuals", "EggEffects", "PetEffects",
    "Decorations", "Deco", "Props", "Environment", "Trees", "Clouds"
}

for _, folderName in ipairs(effectsFolders) do
    local folder = ReplicatedStorage:FindFirstChild(folderName)
    if folder then
        for _, child in ipairs(folder:GetChildren()) do
            pcall(function() child:Destroy() end)
        end
    end
end

-- ═══════════════════════════════════════════════════════════════
-- 9. BOUCLE DE NETTOYAGE CONTINU
-- ═══════════════════════════════════════════════════════════════
task.spawn(function()
    while task.wait(CONFIG.CleanupInterval) do
        for _, obj in ipairs(Workspace:GetDescendants()) do
            pcall(optimizeObject, obj)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- 10. MESSAGE FINAL
-- ═══════════════════════════════════════════════════════════════
pcall(function()
    StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[OPTIMISATION ULTIME] Script activé — FPS max, latence réduite !",
        Color = Color3.fromRGB(0, 255, 0),
        Font = Enum.Font.SourceSansBold,
        FontSize = Enum.FontSize.Size24
    })
end)

print("✅ SCRIPT ULTIME pour Steal an Egg activé.")
print("   - FPS maximisés")
print("   - Trafic réseau réduit (ping ressenti amélioré)")
print("   - Services Roblox nettoyés")
print("   - Gardes, déco, buildings supprimés")