local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

do
    local bgUrl = "https://raw.githubusercontent.com/adoptvalue12/Wvl/refs/heads/main/images%20(36).jpeg"
    local bgAsset = nil
    pcall(function()
        if getcustomasset and writefile then
            writefile("yuno_bg.jpeg", game:HttpGet(bgUrl))
            bgAsset = getcustomasset("yuno_bg.jpeg")
        end
    end)
    local bgGui = Instance.new("ScreenGui")
    bgGui.Name = "YunoBackground"
    bgGui.ResetOnSpawn = false
    bgGui.IgnoreGuiInset = true
    bgGui.DisplayOrder = -1
    pcall(function() bgGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
    if not bgGui.Parent then bgGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end
    local bgImg = Instance.new("ImageLabel")
    bgImg.Size = UDim2.new(1, 0, 1, 0)
    bgImg.BackgroundTransparency = 1
    bgImg.Image = bgAsset or bgUrl
    bgImg.ScaleType = Enum.ScaleType.Crop
    bgImg.Parent = bgGui
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local ProximityPromptService = game:GetService("ProximityPromptService")
local SoundService = game:GetService("SoundService")
local Stats = game:GetService("Stats")
local AssetService = game:GetService("AssetService")
local MarketplaceService = game:GetService("MarketplaceService")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")
local LP = Players.LocalPlayer

if _G.YunoHub and type(_G.YunoHub.Unload) == "function" then pcall(_G.YunoHub.Unload) end
local HUB = { conns = {}, drawings = {}, dead = false }
_G.YunoHub = HUB
local function track(c) if c then table.insert(HUB.conns, c) end return c end
local function trackDrawing(d) if d then table.insert(HUB.drawings, d) end return d end

local function findChar() return LP.Character end
local function findHum() local c = LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function findHRP() local c = LP.Character; return c and (c:FindFirstChild("HumanoidRootPart") or c.PrimaryPart) end
local function GetCamera() return Workspace.CurrentCamera end
local function preciseWait(s) if not s or s <= 0 then return end local e = 0 while e < s do e = e + RunService.Heartbeat:Wait() end end
local function safeCallback(fn) return function(...) local ok, err = pcall(fn, ...) if not ok then warn("[Yuno] " .. tostring(err)) end end end

local EggState, PlotState, AreasData, RarityData, AssetsData, EggToolDisplay, AreaEggSlotIdentity
local Assets, Save, AssetItems, ItemDisplay, AssetRoster
local EggRecords, AssetGender, AssetEarnings, AssetComponent, AssetRigFactory
local LiveBatch, LiveBillboards, SyncAssets

pcall(function() EggState = require(RS.Client.EggState) end)
pcall(function() PlotState = require(RS.Client.PlotState) end)
pcall(function() AreasData = require(RS.Data.Areas) end)
pcall(function() RarityData = require(RS.Data.Rarity) end)
pcall(function() AssetsData = require(RS.Data.Assets) end)
pcall(function() EggToolDisplay = require(RS.Shared.Eggs.EggToolDisplay) end)
pcall(function()
    AreaEggSlotIdentity = (RS:FindFirstChild("Shared") and RS.Shared:FindFirstChild("Util") and require(RS.Shared.Util.AreaEggSlotIdentity))
        or (RS:FindFirstChild("Util") and require(RS.Util.AreaEggSlotIdentity))
end)
pcall(function() Assets = require(RS.Data.Assets) end)
pcall(function() Save = require(RS.Shared.Save) end)
pcall(function() AssetItems = require(RS.Shared.Util.AssetItems) end)
pcall(function() ItemDisplay = require(RS.Shared.Modules.ItemDisplay) end)
pcall(function() AssetRoster = require(RS.Client.AssetRoster) end)
pcall(function()
    local ctrl = LP.PlayerScripts.Game.Plots.ActiveAssetsController
    AssetComponent = require(ctrl.AssetComponent)
    EggRecords = require(RS.Shared.Util.EggRecords)
    AssetGender = require(RS.Shared.Util.AssetGender)
    AssetEarnings = require(RS.Shared.Util.AssetEarnings)
    AssetRigFactory = require(RS.Shared.Modules.AssetRigFactory)
end)
pcall(function()
    if not AssetComponent then return end
    local ctrl = LP.PlayerScripts.Game.Plots.ActiveAssetsController
    local MB = require(ctrl.AssetMovementBatch)
    local BB = require(ctrl.AssetBillboardController)
    if not getgc then return end
    for _, f in ipairs(getgc(false)) do
        if type(f) == "function" and not (iscclosure and iscclosure(f)) then
            local good, info = pcall(debug.getinfo, f)
            local src = good and info and tostring(info.source) or ""
            if src:find("ActiveAssetsController", 1, true) and not src:find("%.Asset") and not src:find("PerformanceTest") then
                for i = 1, (info.nups or 0) do
                    local okv, val = pcall(debug.getupvalue, f, i)
                    if okv and type(val) == "table" then
                        local okm, mt = pcall(getmetatable, val)
                        if okm then
                            if mt == MB and not LiveBatch then LiveBatch = val end
                            if mt == BB and not LiveBillboards then LiveBillboards = val end
                        end
                    end
                end
            end
        end
        if LiveBatch and LiveBillboards then break end
    end
end)
do
    if getgc then
        for _, v in ipairs(getgc(false)) do
            if type(v) == "function" and not (iscclosure and iscclosure(v)) then
                local good, info = pcall(debug.getinfo, v)
                if good and info and info.name == "syncAssetsFromSave" then SyncAssets = v break end
            end
        end
    end
end
local function refreshInventory() if SyncAssets then pcall(SyncAssets) end end

local function GetNetRemote(name)
    local net = RS:FindFirstChild("Packages") and RS.Packages:FindFirstChild("Networking")
    return net and net:FindFirstChild(name)
end

pcall(function()
    if typeof(filtergc) ~= "function" or typeof(debug) ~= "table" or typeof(debug.getupvalues) ~= "function" then return end
    local ok, fn = pcall(function() return filtergc("function", { Constants = { "gmatch", "GetFullName" } }, true) end)
    if not ok or type(fn) ~= "function" then return end
    local setMeta = (typeof(setrawmetatable) == "function" and setrawmetatable) or setmetatable
    if not setMeta then return end
    local okUv, ups = pcall(debug.getupvalues, fn)
    if not okUv or type(ups) ~= "table" then return end
    for _, tbl in pairs(ups) do
        if typeof(tbl) == "table" then pcall(setMeta, tbl, { __newindex = function() end }) end
    end
end)

pcall(function()
    local getgc = getgc or (debug and debug.getgc)
    local setmeta = setrawmetatable or setmetatable
    local getmeta = getrawmetatable or getmetatable
    if getgc and setmeta then
        for _, obj in ipairs(getgc(true)) do
            if typeof(obj) == "table" and not (getmeta and getmeta(obj)) then
                local mainrun = false
                for _, v in pairs(obj) do if v == obj then mainrun = true break end end
                if mainrun then
                    for _, v in pairs(obj) do
                        if typeof(v) == "number" and v >= 1 and v <= 3 and obj[v] == nil then
                            pcall(setmeta, obj, { __newindex = function() end })
                            break
                        end
                    end
                end
            end
        end
    end
end)

pcall(function()
    local getconstants = getconstants or (debug and debug.getconstants)
    local setconstant = setconstant or (debug and debug.setconstant)
    local islclosure = islclosure or function(Function) return not pcall(setfenv, getfenv(Function)) end
    if getgc and getconstants and setconstant then
        for _, Function in ipairs(getgc(true)) do
            if typeof(Function) == "function" and islclosure(Function) then
                local ok, Source = pcall(debug.info, Function, "s")
                if ok and type(Source) == "string" and Source:find("ReplicatedFirst", 1, true) and Source:find("UGI", 1, true) then
                    local okC, Constants = pcall(getconstants, Function)
                    if okC and type(Constants) == "table" then
                        for Index, Constant in next, Constants do
                            if type(Constant) == "string" and Constant == "Humanoid" then
                                pcall(setconstant, Function, Index, "")
                            end
                        end
                    end
                end
            end
        end
    end
end)

pcall(function()
    local getconstants = getconstants or (debug and debug.getconstants)
    local islclosure = islclosure or function(fn) return not pcall(setfenv, getfenv(fn)) end
    local HookFn = hookfunction or replaceclosure or hookfunc
    if getgc and getconstants and HookFn and debug and debug.getstack and debug.setstack then
        for _, fn in ipairs(getgc(true)) do
            if typeof(fn) == "function" and islclosure(fn) then
                local ok, consts = pcall(getconstants, fn)
                if ok and type(consts) == "table" and table.find(consts, "X-14") then
                    local cb = nil
                    cb = HookFn(fn, function(...)
                        local stack = debug.getstack(1)
                        if type(stack) == "table" then
                            for idx, val in pairs(stack) do
                                if val == "X-14" then pcall(debug.setstack, 1, idx, nil) end
                            end
                        end
                        if cb then return cb(...) end
                    end)
                end
            end
        end
    end
end)

pcall(function()
    local getgc = getgc or (debug and debug.getgc)
    local islclosure = islclosure or function(v) return not pcall(setfenv, getfenv(v)) end
    local getupvalues = getupvalues or (debug and debug.getupvalues)
    local getupvalue = getupvalue or (debug and debug.getupvalue)
    local setupvalue = setupvalue or (debug and debug.setupvalue)
    local clonefunction = clonefunction or function(f) return function(...) return f(...) end end
    if getgc and getupvalues and getupvalue and setupvalue then
        for _, v in ipairs(getgc(true)) do
            if typeof(v) == "function" and islclosure(v) then
                local ok, upvs = pcall(getupvalues, v)
                if ok and upvs and #upvs == 19 then
                    local ok2, u2 = pcall(getupvalue, v, 2)
                    if ok2 and typeof(u2) == "function" then
                        local old = clonefunction(u2)
                        pcall(setupvalue, v, 2, function(a, b)
                            if b and typeof(b) == "table" then pcall(setmetatable, b, {}) end
                            return old(a, b)
                        end)
                    end
                end
            end
        end
    end
end)

do
    local bxor = bit32.bxor
    local unpack = table.unpack
    local function isGuid(n) return #n == 36 and n:sub(9,9)=="-" and n:sub(14,14)=="-" and n:sub(19,19)=="-" and n:sub(24,24)=="-" and n:gsub("-",""):match("^%x+$") ~= nil end
    local remoteSet, anyRemote = {}, nil
    local function scanRemotes()
        for _, s in ipairs(game:GetChildren()) do
            local ok, list = pcall(s.GetDescendants, s)
            if ok and list then
                for _, o in ipairs(list) do
                    if o:IsA("RemoteEvent") and isGuid(o.Name) then
                        remoteSet[o] = true
                        anyRemote = anyRemote or o
                    end
                end
            end
        end
    end
    scanRemotes()
    local function parseCounter(v) if type(v) ~= "string" then return end local n = v:match("^X%-(%d+)$") return n and tonumber(n) end
    local function looksLikeState(t, r)
        if type(t) ~= "table" then return false end
        local hR, hM = false, false
        local ok = pcall(function()
            for _, v in pairs(t) do
                if v == r then hR = true elseif type(v) == "string" and v:match("^X%-%d+$") then hM = true end
            end
        end)
        return ok and hR and hM
    end
    local function findState(r)
        for l = 2, 24 do
            local _, fn = pcall(debug.info, l, "f")
            if type(fn) == "function" then
                local _, ups = pcall(debug.getupvalues, fn)
                if type(ups) == "table" then
                    for _, v in pairs(ups) do
                        if looksLikeState(v, r) then return v end
                        if type(v) == "table" then
                            local nested
                            pcall(function() for _, x in pairs(v) do if looksLikeState(x, r) then nested = x return end end end)
                            if nested then return nested end
                        end
                    end
                end
            end
        end
    end
    local function mapState(st, a1, a2)
        local m = {}
        for k, v in pairs(st) do
            if type(v) == "string" then
                if v:match("^X%-%d+$") then m.marker = m.marker or k
                elseif a1 and v == a1 then m.arg1 = m.arg1 or k
                elseif a2 and v == a2 then m.arg2 = m.arg2 or k end
            end
        end
        return m
    end
    local model = nil
    local function digits(n) n = n % 1000 return math.floor(n/100), math.floor(n/10)%10, n%10 end
    local function encode(m, c)
        local d1, d2, d3 = digits(c)
        return m.prefix .. string.char(bxor(d1, m.k1), bxor(d2, m.k2), bxor(d3, m.k3))
    end
    local function learn(r, a1, a2)
        local st = findState(r) if not st then return end
        local map = mapState(st, a1, a2) if not map.marker then return end
        local c = parseCounter(rawget(st, map.marker)) if not c then return end
        local d1, d2, d3 = digits(c)
        local m = {
            state = st, map = map, remote = r,
            prefix = a1:sub(1, 9),
            k1 = bxor(a1:byte(10), d1), k2 = bxor(a1:byte(11), d2), k3 = bxor(a1:byte(12), d3),
            offset = c - os.time(), arg2 = a2,
        }
        if encode(m, c) == a1 then return m end
    end
    local function liveCounter(m)
        if m.state and m.map.marker then
            local _, raw = pcall(rawget, m.state, m.map.marker)
            local c = parseCounter(raw)
            if c and math.abs((c - os.time()) - m.offset) <= 5 then return c end
        end
        return os.time() + m.offset
    end
    local function refreshArg2(m)
        if m.state and m.map.arg2 then
            local _, v = pcall(rawget, m.state, m.map.arg2)
            if type(v) == "string" then m.arg2 = v end
        end
        return m.arg2
    end
    local HookFn = hookfunction or replaceclosure or hookfunc or detour_function
    if anyRemote and HookFn then
        local oldFire
        oldFire = HookFn(anyRemote.FireServer, function(self, ...)
            local args = table.pack(...)
            if not remoteSet[self] then return oldFire(self, unpack(args, 1, args.n)) end
            local a1 = args[1]
            if type(a1) == "string" and #a1 == 12 then
                if not model then model = learn(self, a1, args[2])
                else
                    local c = parseCounter(rawget(model.state, model.map.marker))
                    if c and encode(model, c) ~= a1 then
                        local m = learn(self, a1, args[2])
                        if m then m.spoofed = model.spoofed model = m end
                    end
                end
                return oldFire(self, unpack(args, 1, args.n))
            end
            if model and type(a1) == "string" and #a1 == 4 then
                local c = liveCounter(model)
                args[1] = encode(model, c)
                args[2] = refreshArg2(model)
                model.spoofed = (model.spoofed or 0) + 1
                return oldFire(self, unpack(args, 1, math.max(args.n, 2)))
            end
            return oldFire(self, unpack(args, 1, args.n))
        end)
        task.spawn(function()
            while not HUB.dead do
                task.wait(10)
                local alive = false
                for r in pairs(remoteSet) do if r:IsDescendantOf(game) then alive = true break end end
                if not alive then table.clear(remoteSet) anyRemote = nil model = nil scanRemotes() end
            end
        end)
    end
end

task.spawn(function()
    if not getgc then return end
    local st = nil
    local function findIntegrityTable()
        local ok, objs = pcall(getgc, true)
        if ok and objs then
            for _, o in pairs(objs) do
                if type(o) == "table" then
                    local hit = false
                    pcall(function()
                        hit = (rawget(o, "ValidationLocked") ~= nil and rawget(o, "Evidence") ~= nil)
                            or (rawget(o, "ThreatLevel") ~= nil and rawget(o, "LastObservedSample") ~= nil)
                    end)
                    if hit then return o end
                end
            end
        end
    end
    track(LP.CharacterAdded:Connect(function() task.wait(1) st = findIntegrityTable() end))
    while not HUB.dead do
        if not st then st = findIntegrityTable() end
        if st then
            pcall(function()
                local ev = rawget(st, "Evidence")
                if type(ev) == "table" then
                    if (tonumber(ev.Speed) or 0) > 0 then rawset(ev, "Speed", 0) end
                    if (tonumber(ev.Teleport) or 0) > 0 then rawset(ev, "Teleport", 0) end
                    if (tonumber(ev.Flight) or 0) > 0 then rawset(ev, "Flight", 0) end
                end
                if rawget(st, "ThreatLevel") ~= "Trusted" then rawset(st, "ThreatLevel", "Trusted") end
                if rawget(st, "ValidationLocked") == true then rawset(st, "ValidationLocked", false) end
                if rawget(st, "FirstSuspiciousAt") ~= nil then rawset(st, "FirstSuspiciousAt", nil) end
                if rawget(st, "KickQueued") == true then rawset(st, "KickQueued", false) end
                if rawget(st, "TamperScore") ~= nil then rawset(st, "TamperScore", 0) end
                if rawget(st, "InvalidHeartbeatCount") ~= nil then rawset(st, "InvalidHeartbeatCount", 0) end
                local los = rawget(st, "LastObservedSample")
                if los ~= nil then
                    if rawget(st, "LastGameplayTrustedSample") == nil then rawset(st, "LastGameplayTrustedSample", los) end
                    if rawget(st, "LastValidatedSample") == nil then rawset(st, "LastValidatedSample", los) end
                    if rawget(st, "LastValidatedGroundedSample") == nil then rawset(st, "LastValidatedGroundedSample", los) end
                    if rawget(st, "LastConfirmedGroundSample") == nil then rawset(st, "LastConfirmedGroundSample", los) end
                    if rawget(st, "LastGoodSample") == nil then rawset(st, "LastGoodSample", los) end
                end
            end)
        end
        task.wait(0.2)
    end
end)

local antiSlideEnabled = true
local antiRagdollEnabled = true
local antiKnockbackEnabled = true
local HighGripPhysics = PhysicalProperties.new(100, 10, 0, 100, 100)

local function enforceGrip(character)
    if not character or not antiSlideEnabled then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CustomPhysicalProperties = HighGripPhysics
            part.CanCollide = true
        end
    end
end

local BLOCKED_CLASSES = {
    BodyVelocity = true, BodyThrust = true, BodyForce = true,
    VectorForce = true, LinearVelocity = true,
    BallSocketConstraint = true, RopeConstraint = true,
}
local function neutralizeMover(instance)
    if not antiRagdollEnabled then return end
    if not BLOCKED_CLASSES[instance.ClassName] then return end
    if instance:IsA("Constraint") then instance.Enabled = false else instance:Destroy() end
end
local function stiffenJoints(char)
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("Motor6D") then d.Enabled = true
        elseif d:IsA("BallSocketConstraint") or d:IsA("HingeConstraint") then d.Enabled = false end
    end
end

local MAX_KNOCKBACK_SPEED = 40
local KNOCKBACK_DECAY_RATE = 8
local MAX_UPWARD_VELOCITY = 50
local PUSH_DETECTION_THRESHOLD = 8
local RETURN_STOP_THRESHOLD = 1.5
local RETURN_DURATION = 0.35

local function setupCharacter(char)
    local humanoid = char:WaitForChild("Humanoid", 5)
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if not humanoid or not root then return end
    for _, d in ipairs(char:GetDescendants()) do neutralizeMover(d) end
    track(char.DescendantAdded:Connect(neutralizeMover))
    humanoid.BreakJointsOnDeath = false
    humanoid.RequiresNeck = false
    humanoid.PlatformStand = false
    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
    end)
    track(humanoid.StateChanged:Connect(function(_, newState)
        if not antiRagdollEnabled then return end
        if newState == Enum.HumanoidStateType.Ragdoll or newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.FallingDown then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end))
    track(humanoid.HealthChanged:Connect(function()
        if antiRagdollEnabled then humanoid.PlatformStand = false stiffenJoints(char) end
    end))
    if antiRagdollEnabled then stiffenJoints(char) end
    enforceGrip(char)

    local knockbackVelocity = Vector3.new(0, 0, 0)
    local pushActive = false
    local preKnockbackPosition = nil
    local activeTween = nil
    local lastSetHorizontal = Vector3.new(0, 0, 0)
    local hasLastSet = false
    local function cancelReturnTween() if activeTween then activeTween:Cancel() activeTween = nil end end
    local function playReturnTween()
        if not preKnockbackPosition then return end
        cancelReturnTween()
        local targetCFrame = CFrame.new(preKnockbackPosition) * (root.CFrame - root.CFrame.Position)
        activeTween = TweenService:Create(root, TweenInfo.new(RETURN_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = targetCFrame })
        activeTween:Play()
        activeTween.Completed:Connect(function() activeTween = nil preKnockbackPosition = nil hasLastSet = false end)
    end
    track(RunService.Heartbeat:Connect(function(dt)
        if HUB.dead then return end
        if antiRagdollEnabled and humanoid.PlatformStand then humanoid.PlatformStand = false end
        if not antiKnockbackEnabled then return end
        local moveDirection = humanoid.MoveDirection
        local desiredSpeed = humanoid.WalkSpeed
        local desiredVelocity = Vector3.new(moveDirection.X * desiredSpeed, 0, moveDirection.Z * desiredSpeed)
        if activeTween and moveDirection.Magnitude > 0.1 then
            cancelReturnTween() preKnockbackPosition = nil hasLastSet = false
        end
        if activeTween then return end
        local currentVelocity = root.AssemblyLinearVelocity
        local currentHorizontal = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
        if hasLastSet then
            local pushDelta = currentHorizontal - lastSetHorizontal
            if pushDelta.Magnitude > PUSH_DETECTION_THRESHOLD then
                if not pushActive then preKnockbackPosition = root.Position pushActive = true end
                knockbackVelocity = knockbackVelocity + pushDelta
                if knockbackVelocity.Magnitude > MAX_KNOCKBACK_SPEED then knockbackVelocity = knockbackVelocity.Unit * MAX_KNOCKBACK_SPEED end
            end
        end
        knockbackVelocity = knockbackVelocity * math.clamp(1 - KNOCKBACK_DECAY_RATE * dt, 0, 1)
        if pushActive and knockbackVelocity.Magnitude < RETURN_STOP_THRESHOLD then
            pushActive = false
            knockbackVelocity = Vector3.new(0, 0, 0)
            playReturnTween()
            return
        end
        local verticalVelocity = currentVelocity.Y
        if verticalVelocity > MAX_UPWARD_VELOCITY then verticalVelocity = MAX_UPWARD_VELOCITY end
        local finalVelocity = desiredVelocity + knockbackVelocity
        root.AssemblyLinearVelocity = Vector3.new(finalVelocity.X, verticalVelocity, finalVelocity.Z)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        lastSetHorizontal = Vector3.new(finalVelocity.X, 0, finalVelocity.Z)
        hasLastSet = true
    end))
end

if LP.Character then task.spawn(function() setupCharacter(LP.Character) end) end
track(LP.CharacterAdded:Connect(function(c) task.wait(0.2) enforceGrip(c) setupCharacter(c) end))

pcall(function()
    track(ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, player)
        if player == LP and prompt.Name == "CarryAreaEgg" then prompt.HoldDuration = 0 end
    end))
end)

do
    local debris = Workspace:WaitForChild("__DEBRIS", 10)
    if debris then
        local function processChild(child)
            local hitbox = child:FindFirstChild("Hitbox")
            if hitbox then
                local ti = hitbox:FindFirstChild("TouchInterest") or hitbox:FindFirstChildOfClass("TouchInterest")
                if ti then ti:Destroy() end
                track(hitbox.ChildAdded:Connect(function(newChild)
                    if newChild:IsA("TouchInterest") or newChild.Name == "TouchInterest" then
                        RunService.Heartbeat:Wait()
                        newChild:Destroy()
                    end
                end))
            end
        end
        for _, child in ipairs(debris:GetChildren()) do processChild(child) end
        track(debris.ChildAdded:Connect(processChild))
    end
end

local avoidTrapsEnabled = true
local function NeutralizeTraps()
    local debris = Workspace:FindFirstChild("__DEBRIS")
    if not debris then return end
    for _, d in ipairs(debris:GetChildren()) do
        if d.Name == "PlayerTrap" and d:GetAttribute("Owner") ~= LP.Name then
            if d:IsA("BasePart") then d.CanTouch = false d.CanQuery = false end
            for _, c in ipairs(d:GetChildren()) do
                if c:IsA("BasePart") then
                    c.CanTouch = false c.CanQuery = false
                    if c.Name == "Hitbox" then c.CFrame = CFrame.new(0, -999, 0) end
                end
            end
            local tt = d:FindFirstChildWhichIsA("TouchTransmitter", true)
            if tt then pcall(function() tt:Destroy() end) end
        end
    end
end

task.spawn(function()
    while not HUB.dead do
        if avoidTrapsEnabled then pcall(NeutralizeTraps) end
        task.wait(1.5)
    end
end)

local WalkSpeedSettings = { WalkSpeed = 200, ArrivalThreshold = 5, MovementSpeed = 650 }
local isWalkingToTarget = false
local activeTargetSpeed = nil
local currentWalkToken = 0
local activeHumanoid = nil
local DISABLE_WALK_ACTION = "YunoDisableWalk"

local function setMovementControlsEnabled(enabled)
    if not enabled then
        CAS:BindActionAtPriority(DISABLE_WALK_ACTION, function() return Enum.ContextActionResult.Sink end,
            false, 3000, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
            Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right, Enum.KeyCode.Space)
    else
        CAS:UnbindAction(DISABLE_WALK_ACTION)
    end
end

local function stopCurrentWalking(shouldDropEgg)
    currentWalkToken = currentWalkToken + 1
    isWalkingToTarget = false
    activeTargetSpeed = nil
    setMovementControlsEnabled(true)
    task.spawn(function()
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = activeHumanoid or (char and char:FindFirstChildOfClass("Humanoid"))
        if hum then hum:Move(Vector3.zero, false) if root then hum:MoveTo(root.Position) end end
        if shouldDropEgg then
            preciseWait(0.2)
            local drop = GetNetRemote("RF/EggWorld/AskFieldEggDrop")
            if drop then pcall(function() drop:InvokeServer({ Reason = "PlayerRequest" }) end) end
        end
    end)
end

local function resolvePosition(t)
    if typeof(t) == "Vector3" then return t
    elseif typeof(t) == "Instance" then
        if t:IsA("BasePart") then return t.Position
        elseif t:IsA("Model") then return t:GetPivot().Position end
    end
end

local function walkDirect(targetPos, speed, threshold, thisToken)
    isWalkingToTarget = true
    activeTargetSpeed = speed or WalkSpeedSettings.WalkSpeed
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = activeHumanoid or (char and char:FindFirstChildOfClass("Humanoid"))
    if not root or not hum then isWalkingToTarget = false return false end
    hum.WalkSpeed = activeTargetSpeed
    hum:MoveTo(targetPos)
    local targetX, targetZ = targetPos.X, targetPos.Z
    local reqThreshold = threshold or WalkSpeedSettings.ArrivalThreshold
    while currentWalkToken == thisToken and isWalkingToTarget and not HUB.dead and root and hum do
        hum.WalkSpeed = activeTargetSpeed
        local currentPos = root.Position
        local dx = targetX - currentPos.X
        local dz = targetZ - currentPos.Z
        if dx * dx + dz * dz <= (reqThreshold * reqThreshold) then break end
        hum:MoveTo(targetPos)
        RunService.Heartbeat:Wait()
    end
    return currentWalkToken == thisToken and not HUB.dead
end

local function walkToTarget(targetDestination, customSpeed, customThreshold)
    stopCurrentWalking(false)
    currentWalkToken = currentWalkToken + 1
    local thisToken = currentWalkToken
    task.spawn(function()
        local finalPos = resolvePosition(targetDestination)
        if not finalPos then return end
        setMovementControlsEnabled(false)
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local targetZWaypoint = Vector3.new(root.Position.X, root.Position.Y, finalPos.Z)
            if not walkDirect(targetZWaypoint, customSpeed, customThreshold, thisToken) then setMovementControlsEnabled(true) return end
            if not walkDirect(finalPos, customSpeed, customThreshold, thisToken) then setMovementControlsEnabled(true) return end
        end
        if currentWalkToken == thisToken then
            local hum = activeHumanoid or (LP.Character and LP.Character:FindFirstChildOfClass("Humanoid"))
            local rootPart = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hum and rootPart then hum:Move(Vector3.zero, false) hum:MoveTo(rootPart.Position) end
            isWalkingToTarget = false
            activeTargetSpeed = nil
            setMovementControlsEnabled(true)
        end
    end)
end

local disableCameraShake = true
task.spawn(function()
    local cam = GetCamera()
    if cam then pcall(function() cam.CameraSubject = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") end) end
    local playerScripts = LP:WaitForChild("PlayerScripts", 5)
    if playerScripts then
        for _, v in ipairs(playerScripts:GetDescendants()) do
            if v:IsA("LocalScript") or v:IsA("ModuleScript") then
                local n = v.Name:lower()
                if n:find("shake") or n:find("camshake") or n:find("recoil") then v.Disabled = true end
            end
        end
    end
    track(RunService.RenderStepped:Connect(function()
        if HUB.dead or not disableCameraShake then return end
        local c = GetCamera()
        if c and c.CameraType == Enum.CameraType.Scriptable then c.CameraType = Enum.CameraType.Custom end
    end))
end)

local fpsBoosterActive = false
local TARGET_NAMES = { ["AssetRandomIdleSound"] = true, ["AssetWalkSound"] = true, ["AssetWalkSoundEmitterWeld"] = true }
local function freezeInstance(instance)
    if instance:IsA("BasePart") then
        instance.Anchored = true
        instance.AssemblyLinearVelocity = Vector3.zero
        instance.AssemblyAngularVelocity = Vector3.zero
    end
    if instance:IsA("AnimationController") or instance:IsA("Humanoid") then
        local animator = instance:FindFirstChildOfClass("Animator")
        if animator then for _, t in ipairs(animator:GetPlayingAnimationTracks()) do t:Stop() end end
    end
    if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then instance.Enabled = false end
end
local function cleanTargetElement(instance)
    local cur = instance
    while cur and cur ~= game do
        if cur:IsA("Model") and Players:GetPlayerFromCharacter(cur) then return end
        cur = cur.Parent
    end
    if TARGET_NAMES[instance.Name] then pcall(function() instance:Destroy() end) return end
    if instance:IsA("Animator") or instance:IsA("AnimationController") then
        pcall(function() for _, t in ipairs(instance:GetPlayingAnimationTracks()) do t:Stop() end instance:Destroy() end)
    elseif instance:IsA("Animation") then instance.AnimationId = "" pcall(function() instance:Destroy() end)
    elseif instance:IsA("Motor6D") or instance:IsA("Motor") or instance:IsA("Weld") then pcall(function() instance.Transform = CFrame.identity end)
    elseif instance:IsA("ParticleEmitter") or instance:IsA("Trail") or instance:IsA("Smoke") or instance:IsA("Fire") or instance:IsA("Sparkles") then
        instance.Enabled = false
        pcall(function() instance:Clear() end)
        pcall(function() instance:Destroy() end)
    elseif instance:IsA("Beam") then instance.Enabled = false pcall(function() instance:Destroy() end)
    elseif instance:IsA("Atmosphere") or instance:IsA("Clouds") then pcall(function() instance:Destroy() end)
    elseif instance:IsA("Texture") or instance:IsA("Decal") then
        local n = instance.Name:lower()
        if n:find("water") or n:find("river") or n:find("flow") or n:find("wave") or n:find("lava") or n:find("fire") then instance.Transparency = 1 end
    elseif instance:IsA("Script") or instance:IsA("LocalScript") then
        local n = instance.Name:lower()
        if n:find("anim") or n:find("pet") or n:find("float") or n:find("bob") or n:find("rotate") or n:find("spin") or n:find("water") or n:find("river") then instance.Disabled = true end
    end
end
local function toggleFpsBooster(state)
    fpsBoosterActive = (state == nil) and not fpsBoosterActive or state == true
    if fpsBoosterActive then
        pcall(function()
            Lighting.FogStart = 1e10
            Lighting.FogEnd = 1e10
            for _, c in ipairs(Lighting:GetChildren()) do
                if c:IsA("Atmosphere") or c:IsA("Clouds") or c:IsA("PostEffect") then c.Enabled = false end
            end
        end)
        if Terrain then
            pcall(function()
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterWaveSize = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 1
            end)
        end
        local af = Workspace:FindFirstChild("ClientRenderedAssets")
        if af then for _, d in ipairs(af:GetDescendants()) do freezeInstance(d) end end
        for _, i in ipairs(Workspace:GetDescendants()) do cleanTargetElement(i) end
        if not _G.YunoFpsConn then
            _G.YunoFpsConn = track(Workspace.DescendantAdded:Connect(function(d)
                if not HUB.dead and fpsBoosterActive then
                    local f = Workspace:FindFirstChild("ClientRenderedAssets")
                    if f and d:IsDescendantOf(f) then freezeInstance(d) end
                    cleanTargetElement(d)
                end
            end))
        end
    end
end
task.spawn(function()
    while not HUB.dead do
        task.wait(0.5)
        if fpsBoosterActive then
            local af = Workspace:FindFirstChild("ClientRenderedAssets")
            if af then
                for _, d in ipairs(af:GetDescendants()) do
                    if d:IsA("BasePart") and not d.Anchored then freezeInstance(d) end
                    if TARGET_NAMES[d.Name] then pcall(function() d:Destroy() end) end
                end
            end
        end
    end
end)

local walkSpeedEnabled = false
local walkSpeedVal = 24
local jumpPowerEnabled = false
local jumpPowerVal = 60
local infiniteJump = false
local flying = false
local flySpeed = 60
local antiAFK = false

track(RunService.Stepped:Connect(function()
    if HUB.dead then return end
    local hum = activeHumanoid or findHum()
    if hum then
        if walkSpeedEnabled then hum.WalkSpeed = walkSpeedVal end
        if jumpPowerEnabled then hum.UseJumpPower = true hum.JumpPower = jumpPowerVal end
    end
end))

track(UIS.JumpRequest:Connect(function()
    if HUB.dead or not infiniteJump then return end
    local hum = findHum()
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end))

local flyBodyGyro, flyConn
local function startFly()
    if flying then return end
    local hrp, hum = findHRP(), findHum()
    if not hrp or not hum then return end
    flying = true
    hrp.Anchored = true
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 1e5
    flyBodyGyro.P = 1e5
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.Parent = hrp
    flyConn = track(RunService.RenderStepped:Connect(function(dt)
        if not flying or HUB.dead then return end
        local cam = GetCamera()
        if not cam then return end
        local look, right = cam.CFrame.LookVector, cam.CFrame.RightVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        flatLook = flatLook.Magnitude > 0.001 and flatLook.Unit or Vector3.new(0, 0, -1)
        local flatRight = Vector3.new(right.X, 0, right.Z)
        flatRight = flatRight.Magnitude > 0.001 and flatRight.Unit or Vector3.new(1, 0, 0)
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + flatLook end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - flatLook end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - flatRight end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + flatRight end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        if dir.Magnitude > 0 then hrp.CFrame = hrp.CFrame + dir.Unit * flySpeed * math.min(dt, 0.1) end
        flyBodyGyro.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + look)
    end))
end
local function stopFly()
    flying = false
    if flyConn then pcall(function() flyConn:Disconnect() end) flyConn = nil end
    local hrp = findHRP()
    if hrp then hrp.Anchored = false end
    if flyBodyGyro then pcall(function() flyBodyGyro:Destroy() end) flyBodyGyro = nil end
end

local antiAfkConn
local function setAntiAFK(v)
    antiAFK = v
    if v and not antiAfkConn then
        antiAfkConn = track(LP.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end))
    elseif not v and antiAfkConn then
        pcall(function() antiAfkConn:Disconnect() end) antiAfkConn = nil
    end
end

local defaultAmbient = Lighting.Ambient
local defaultOutdoor = Lighting.OutdoorAmbient
local defaultBrightness = Lighting.Brightness
local defaultClockTime = Lighting.ClockTime
local function setFullbright(v)
    if v then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
    else
        Lighting.Ambient = defaultAmbient
        Lighting.OutdoorAmbient = defaultOutdoor
        Lighting.Brightness = defaultBrightness
        Lighting.ClockTime = defaultClockTime
    end
end

local glideSpeed = 750
local stealMovementMethod = "Tween Glide"
local savedReturnCFrame = nil
local MAIN_ROAD_Z = -364.5
local SAFE_BOUNDARY_X = 580
local SAFE_ZONE_SPEED = 245
local BYPASS_LEG_OFFSET = Vector3.new(0, -6.7, 0)
local BYPASS_TP_OFFSET = Vector3.new(0, 6.7, 0)

local function heartbeatTP(cfTarget, holdTime)
    local root = findHRP() if not root then return end
    local ch = LP.Character
    if ch then for _, p in ipairs(ch:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end end end
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local r = findHRP()
        if r and r.Parent then
            r.CFrame = cfTarget
            r.AssemblyLinearVelocity = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
        end
    end)
    task.wait(holdTime or 0.25)
    if conn then conn:Disconnect() end
    local r2 = findHRP()
    if r2 then r2.CFrame = cfTarget r2.AssemblyLinearVelocity = Vector3.zero r2.AssemblyAngularVelocity = Vector3.zero end
end

local function restoreCollisions()
    local ch = LP.Character
    if not ch or not ch.Parent then return end
    for _, p in ipairs(ch:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end
    end
end

local function bypassReturnTP(safeCFrame, holdTime)
    local hrp = findHRP() if not hrp then return false end
    local targetPart = Workspace:FindFirstChild("SpawnLocation", true)
    if not targetPart or not targetPart:IsA("BasePart") then heartbeatTP(safeCFrame, holdTime or 0.3) return true end
    pcall(function() targetPart.CanCollide = false end)
    local ch = LP.Character
    if ch then for _, p in ipairs(ch:GetDescendants()) do if p:IsA("BasePart") then pcall(function() p.CanCollide = false end) end end end
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local r = findHRP() if not r or not r.Parent then return end
        pcall(function() targetPart.CFrame = r.CFrame * CFrame.new(BYPASS_LEG_OFFSET) end)
        r.CFrame = safeCFrame + BYPASS_TP_OFFSET
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
        pcall(function() targetPart.CFrame = safeCFrame end)
    end)
    task.wait(holdTime or 0.35)
    if conn then conn:Disconnect() end
    local r2 = findHRP()
    if r2 then r2.CFrame = safeCFrame r2.AssemblyLinearVelocity = Vector3.zero r2.AssemblyAngularVelocity = Vector3.zero end
    return true
end

local function MoveToPoint(target, speed, easeOut)
    local hrp = findHRP() if not hrp or not target then return false end
    local start = hrp.Position
    local dist = (target - start).Magnitude
    if dist < 1.0 then
        hrp.CFrame = CFrame.new(target.X, math.max(target.Y, 70.0), target.Z)
        hrp.AssemblyLinearVelocity = Vector3.zero hrp.AssemblyAngularVelocity = Vector3.zero
        return true
    end
    speed = math.clamp(tonumber(speed) or glideSpeed, 50, 750)
    local t0 = os.clock()
    local totalDist = dist
    while not HUB.dead do
        local dt = RunService.Heartbeat:Wait()
        local curPos = hrp.Position
        local toTarget = target - curPos
        local remain = toTarget.Magnitude
        if remain < 1.0 then break end
        local stepSpeed = speed
        if easeOut then
            local progress = 1 - math.clamp(remain / totalDist, 0, 1)
            stepSpeed = math.max(speed * (1 - progress * 0.8), 35)
        end
        local step = math.min(stepSpeed * dt, remain)
        local dir = toTarget.Unit
        local nextPos = curPos + dir * step
        hrp.CFrame = CFrame.lookAt(nextPos, nextPos + dir)
        hrp.AssemblyLinearVelocity = Vector3.zero hrp.AssemblyAngularVelocity = Vector3.zero
        if os.clock() - t0 > (totalDist / 50 + 5) then break end
    end
    hrp.CFrame = CFrame.new(target.X, math.max(target.Y, 70.0), target.Z)
    hrp.AssemblyLinearVelocity = Vector3.zero hrp.AssemblyAngularVelocity = Vector3.zero
    return true
end

local function FlyToPoint(target, speed, easeOut)
    local hrp = findHRP() if not hrp or not target then return false end
    local start = hrp.Position
    local dist = (target - start).Magnitude
    if dist < 1.0 then
        hrp.CFrame = CFrame.new(target.X, math.max(target.Y, 70.0), target.Z)
        hrp.AssemblyLinearVelocity = Vector3.zero hrp.AssemblyAngularVelocity = Vector3.zero
        return true
    end
    speed = math.clamp(tonumber(speed) or glideSpeed, 50, 750)
    local moveTime = math.max(dist / speed, 0.02)
    if easeOut then moveTime = moveTime * 1.25 end
    local t0 = os.clock()
    local delta = target - start
    local dir = delta.Magnitude > 0.001 and delta.Unit or Vector3.new(1, 0, 0)
    while os.clock() - t0 < moveTime and not HUB.dead do
        local dt = RunService.Heartbeat:Wait()
        local alpha = math.clamp((os.clock() - t0) / moveTime, 0, 1)
        local a = easeOut and math.sin(alpha * (math.pi / 2)) or alpha
        local cur = start:Lerp(target, a)
        hrp.CFrame = CFrame.lookAt(cur, cur + dir)
        local curSpeed = easeOut and math.max(speed * (1 - alpha * 0.8), 35) or speed
        hrp.AssemblyLinearVelocity = Vector3.new(dir.X * curSpeed, math.clamp(dir.Y * curSpeed, -15, 150), dir.Z * curSpeed)
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    hrp.CFrame = CFrame.new(target.X, math.max(target.Y, 70.0), target.Z)
    hrp.AssemblyLinearVelocity = Vector3.zero hrp.AssemblyAngularVelocity = Vector3.zero
    return true
end

local function TravelRoadPath(targetPos, speed, isApproach)
    local hrp = findHRP() if not hrp or not targetPos then return false end
    if avoidTrapsEnabled then pcall(NeutralizeTraps) end
    local startPos = hrp.Position
    local safeY = math.max(startPos.Y, targetPos.Y, 70.4)
    local isReturningToBase = (targetPos.X < 560)
    speed = speed or glideSpeed
    if isReturningToBase and startPos.X > SAFE_BOUNDARY_X then
        MoveToPoint(Vector3.new(startPos.X, safeY, MAIN_ROAD_Z), speed, false)
        MoveToPoint(Vector3.new(SAFE_BOUNDARY_X, safeY, MAIN_ROAD_Z), speed, false)
        MoveToPoint(Vector3.new(targetPos.X, safeY, MAIN_ROAD_Z), SAFE_ZONE_SPEED, false)
        MoveToPoint(targetPos + Vector3.new(0, 1.2, 0), SAFE_ZONE_SPEED, isApproach == true)
    else
        MoveToPoint(Vector3.new(startPos.X, safeY, MAIN_ROAD_Z), speed, false)
        MoveToPoint(Vector3.new(targetPos.X, safeY, MAIN_ROAD_Z), speed, false)
        MoveToPoint(targetPos + Vector3.new(0, 1.2, 0), speed, isApproach == true)
    end
    return true
end

local function TravelFlyDirect(targetPos, speed, isApproach)
    local hrp = findHRP() if not hrp or not targetPos then return false end
    if avoidTrapsEnabled then pcall(NeutralizeTraps) end
    local startPos = hrp.Position
    local isReturningToBase = (targetPos.X < 560)
    local flyAltitude = math.max(startPos.Y, targetPos.Y, 70.4) + 28
    speed = speed or glideSpeed
    if isReturningToBase and startPos.X > SAFE_BOUNDARY_X then
        FlyToPoint(Vector3.new(startPos.X, flyAltitude, startPos.Z), speed, false)
        FlyToPoint(Vector3.new(SAFE_BOUNDARY_X, flyAltitude, MAIN_ROAD_Z), speed, false)
        FlyToPoint(Vector3.new(SAFE_BOUNDARY_X, 70.4, MAIN_ROAD_Z), SAFE_ZONE_SPEED, false)
        MoveToPoint(Vector3.new(targetPos.X, 70.4, MAIN_ROAD_Z), SAFE_ZONE_SPEED, false)
        MoveToPoint(targetPos + Vector3.new(0, 1.2, 0), SAFE_ZONE_SPEED, isApproach == true)
    else
        local totalDist = (targetPos - startPos).Magnitude
        if totalDist < 25 then
            FlyToPoint(Vector3.new(targetPos.X, math.max(targetPos.Y, 70.0) + 1.2, targetPos.Z), speed, isApproach == true)
            return true
        end
        FlyToPoint(Vector3.new(startPos.X, flyAltitude, startPos.Z), speed, false)
        FlyToPoint(Vector3.new(targetPos.X, flyAltitude, targetPos.Z), speed, false)
        FlyToPoint(Vector3.new(targetPos.X, math.max(targetPos.Y, 70.0) + 1.2, targetPos.Z), speed, isApproach == true)
    end
    return true
end

local function TravelSafeWalk(targetPos)
    local hum = findHum()
    local hrp = findHRP()
    if not hum or not hrp or not targetPos then return false end
    if avoidTrapsEnabled then pcall(NeutralizeTraps) end
    local startPos = hrp.Position
    local pts = {
        Vector3.new(startPos.X, startPos.Y, MAIN_ROAD_Z),
        Vector3.new(targetPos.X, targetPos.Y, MAIN_ROAD_Z),
        targetPos + Vector3.new(0, 1.2, 0),
    }
    for _, pt in ipairs(pts) do
        if HUB.dead then break end
        hum:MoveTo(pt)
        local t0 = os.clock()
        while (hrp.Position - pt).Magnitude > 4.5 and os.clock() - t0 < 5 and not HUB.dead do task.wait(0.05) end
    end
    return true
end

local function TravelToDestination(targetPos, speed, isApproach)
    if stealMovementMethod == "Fly Glide" then return TravelFlyDirect(targetPos, speed, isApproach)
    elseif stealMovementMethod == "Safe Walk" then return TravelSafeWalk(targetPos)
    else return TravelRoadPath(targetPos, speed, isApproach) end
end

local RARITY_SCORE_MAP = {
    Titan=1100, Divine=1000, Transcendent=1000, Superior=1000,
    Eternal=900, Limited=900, Secret=800, Exotic=800, Cosmic=700,
    Exclusive=700, Admin=700, Mythic=600, Mythical=600, Prismatic=600,
    Rainbow=600, ["Squishy God"]=600, BrainrotGod=600, Legendary=500,
    Epic=400, Rare=300, SuperRare=200, Celestial=200, Uncommon=200,
    Basic=100, Common=100,
}
local AREA_COORDINATES = {
    ["Base / Plot"]      = Vector3.new(491.7, 70.4, -364.4),
    ["Stands & Shops"]   = Vector3.new(539.5, 68.0, -364.5),
    ["Forest"]           = Vector3.new(596.0, 68.0, -328.0),
    ["Lake"]             = Vector3.new(744.0, 68.5, -408.0),
    ["Desert"]           = Vector3.new(948.0, 69.5, -323.0),
    ["Jungle"]           = Vector3.new(1188.0, 68.5, -408.0),
    ["Snow"]             = Vector3.new(1492.0, 69.0, -315.0),
    ["Volcano"]          = Vector3.new(1882.0, 68.0, -398.0),
    ["Abyss Ocean"]      = Vector3.new(2280.0, 68.0, -326.0),
    ["Prehistoric"]      = Vector3.new(2812.0, 69.0, -398.0),
    ["Cosmic"]           = Vector3.new(3390.0, 68.0, -324.0),
    ["Cherry Blossom"]   = Vector3.new(4028.0, 68.5, -396.0),
    ["Titan Temple"]     = Vector3.new(4796.0, 69.5, -328.0),
    ["Monster Event"]    = Vector3.new(539.5, 68.0, -411.3),
    ["Dragon Event"]     = Vector3.new(539.5, 68.0, -318.0),
}
local AREA_NAMES = { "Forest","Lake","Desert","Jungle","Snow","Volcano","Abyss Ocean","Prehistoric","Cosmic","Cherry Blossom","Titan Temple","Monster Event","Dragon Event" }
local RARITY_NAMES = { "Titan","Divine","Superior","Eternal","Limited","Secret","Exotic","Cosmic","Exclusive","Mythic","Rainbow","Squishy God","Legendary","Epic","Rare","Uncommon","Common" }
local MUTATION_FILTERS = { "Normal Only","Mutated Only","Parasite / Infested","Rainbow Only","Gold Only","Silver Only","Monstrous" }

local function GetEggRarityInfo(egg)
    if not egg then return "Common", 100 end
    if egg.Rarity then
        local r = egg.Rarity
        local name = type(r) == "table" and (r.DisplayName or r._id or r.Name) or tostring(r)
        return name, RARITY_SCORE_MAP[name] or 100
    end
    local cat = egg.AssetCategory or egg.Category or egg.Name
    if cat and AssetsData then
        local dir = AssetsData.Directory or AssetsData
        local info = dir[cat]
        if info and info.Rarity then
            local r = info.Rarity
            local name = type(r) == "table" and (r.DisplayName or r._id or r.Name) or tostring(r)
            return name, RARITY_SCORE_MAP[name] or 100
        end
    end
    local areaData = AreasData and (AreasData.Directory or AreasData)[egg.AreaId]
    local rarity = areaData and areaData.Rarity
    local rid = (type(rarity) == "table" and (rarity._id or rarity.DisplayName or rarity.Name)) or (type(rarity) == "string" and rarity) or "Common"
    return rid, RARITY_SCORE_MAP[rid] or 100
end

local function isRarityAllowed(name, filter)
    if not filter or next(filter) == nil then return true end
    if filter[name] == true then return true end
    local l = string.lower(tostring(name))
    for k, v in pairs(filter) do
        if type(v) == "string" and string.lower(v) == l then return true end
        if type(k) == "string" and string.lower(k) == l and v == true then return true end
    end
    return false
end
local function isAreaAllowed(id, filter)
    if not filter or next(filter) == nil then return true end
    if filter[id] == true then return true end
    local l = string.lower(tostring(id))
    for k, v in pairs(filter) do
        if type(v) == "string" and string.lower(v) == l then return true end
        if type(k) == "string" and string.lower(k) == l and v == true then return true end
    end
    return false
end

local stealParasiteOnly = false
local stealBigEggsOnly = false
local function isMutationAllowed(muts, record, filter)
    local isParasite = (record and record.HasParasite == true)
        or (type(muts) == "table" and (table.find(muts, "Parasite") or table.find(muts, "Monstrous")))
        or (record and (record.BaseMutation == "Parasite" or record.BaseMutation == "Monstrous"))
    if stealParasiteOnly and not isParasite then return false end
    if not filter or next(filter) == nil then return true end
    local hasMut = type(muts) == "table" and #muts > 0
    for _, opt in pairs(filter) do
        if type(opt) == "string" then
            if opt == "Normal Only" and not hasMut and not isParasite then return true end
            if opt == "Mutated Only" and (hasMut or isParasite) then return true end
            if (opt == "Parasite / Infested" or opt == "Monstrous") and isParasite then return true end
            if opt == "Silver Only" and type(muts) == "table" and table.find(muts, "Silver") then return true end
            if opt == "Gold Only" and type(muts) == "table" and (table.find(muts, "Gold") or table.find(muts, "Golden")) then return true end
            if opt == "Rainbow Only" and type(muts) == "table" and table.find(muts, "Rainbow") then return true end
        end
    end
    return false
end

local function isBigEgg(record)
    if not record then return false end
    local s = tonumber(record.AssetScale) or 1
    local ns = tonumber(record.NestScale) or 1
    return s >= 1.35 or ns >= 1.0
end

local selectedStealRarities, selectedStealAreas, selectedMutationTypes = {}, {}, {}
local ignoredEggs = {}

local function GetMatchingFieldEggs()
    if not EggState or not EggState.ReadFieldEggs then return {} end
    local ok, snap = pcall(EggState.ReadFieldEggs)
    if not ok or not snap or not snap.Records then return {} end
    local matched = {}
    for _, r in ipairs(snap.Records) do
        if r.State == "Slot" and r.BoundsCFrame then
            local isIgn = ignoredEggs[r.Uid] and (os.clock() - ignoredEggs[r.Uid] < 2.5)
            if not isIgn and (not stealBigEggsOnly or isBigEgg(r)) then
                local rarityName, baseScore = GetEggRarityInfo(r)
                local muts = r.Mutations or {}
                if isAreaAllowed(r.AreaId, selectedStealAreas) and isRarityAllowed(rarityName, selectedStealRarities) and isMutationAllowed(muts, r, selectedMutationTypes) then
                    local bonus = 0
                    for _, m in ipairs(muts) do
                        if m == "Rainbow" then bonus = bonus + 35
                        elseif m == "Gold" or m == "Golden" then bonus = bonus + 20
                        elseif m == "Silver" then bonus = bonus + 10 end
                    end
                    if r.HasParasite then bonus = bonus + 800 end
                    if isBigEgg(r) then bonus = bonus + 600 end
                    table.insert(matched, { record = r, rarity = rarityName, score = baseScore + bonus })
                end
            end
        end
    end
    if #matched > 1 then table.sort(matched, function(a, b) return a.score > b.score end) end
    return matched
end

local function EnsureSavedReturnPosition()
    if not savedReturnCFrame then
        local hrp = findHRP()
        if hrp then savedReturnCFrame = hrp.CFrame end
    end
end

local function isPlayerCarryingEgg()
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    local dropGui = pg and pg:FindFirstChild("DropHeldEgg")
    if dropGui and dropGui.Enabled then return true end
    local ch = LP.Character
    if ch then
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Model") and (t.Name:lower():find("egg") or t:GetAttribute("Uid")) then return true end
            if t:IsA("Tool") then
                if EggToolDisplay and EggToolDisplay.IsEggTool and EggToolDisplay.IsEggTool(t) then return true end
                if t:GetAttribute("IsEgg") == true or t:GetAttribute("Uid") ~= nil then return true end
                local tn = t.Name:lower()
                if tn:find("egg") then return true end
            end
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and EggToolDisplay and EggToolDisplay.IsEggTool and EggToolDisplay.IsEggTool(t) then return true end
        end
    end
    return false
end

local function PlantAllCarriedEggsInPen()
    local uids = {}
    local ch = LP.Character
    if ch then
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") and EggToolDisplay and EggToolDisplay.IsEggTool and EggToolDisplay.IsEggTool(t) then
                local uid = EggToolDisplay.GetToolUid(t)
                if uid then table.insert(uids, uid) end
            end
        end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and EggToolDisplay and EggToolDisplay.IsEggTool and EggToolDisplay.IsEggTool(t) then
                local uid = EggToolDisplay.GetToolUid(t)
                if uid then table.insert(uids, uid) end
            end
        end
    end
    local planted = 0
    for _, uid in ipairs(uids) do
        for attempt = 1, 3 do
            local offset = CFrame.new(math.random(-6, 6), 0, math.random(-6, 6))
            local ok, res = pcall(function() return EggState and EggState.PlantEgg and EggState.PlantEgg(uid, offset) end)
            if ok and res then planted = planted + 1 break end
            task.wait(0.1)
        end
    end
    return planted
end

local function StealSpecificEggRobust(targetItem)
    local record = targetItem.record or targetItem
    if not record or not record.Uid or not record.BoundsCFrame then return false end
    if EggState and EggState.ReadFieldEggs then
        local ok, snap = pcall(EggState.ReadFieldEggs)
        if ok and snap and snap.Records then
            local stillThere = false
            for _, r in ipairs(snap.Records) do
                if r.Uid == record.Uid and r.State == "Slot" then stillThere = true record = r break end
            end
            if not stillThere then return false end
        end
    end
    local hrp = findHRP()
    if not hrp then return false end
    if not savedReturnCFrame then savedReturnCFrame = hrp.CFrame end

    local targetPos = record.BoundsCFrame.Position
    local speed = math.clamp(tonumber(glideSpeed) or 750, 50, 750)
    local isInstantTP = (stealMovementMethod == "Anti Guard")

    TravelToDestination(targetPos + Vector3.new(0, 1.2, 0), speed, true)
    if hrp then
        hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 1.2, 0))
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    task.wait(isInstantTP and 0.25 or 0.5)

    local slotKey = nil
    if AreaEggSlotIdentity and AreaEggSlotIdentity.LooksLikeFirstAreaUid and AreaEggSlotIdentity.LooksLikeFirstAreaUid(record.Uid) then
        slotKey = AreaEggSlotIdentity.SlotKey(record.AreaId, record.NestId)
    end
    local net = RS:FindFirstChild("Packages") and RS.Packages:FindFirstChild("Networking")
    local carryRemote = net and net:FindFirstChild("RF/EggWorld/AskFieldEggCarry")
    if carryRemote then pcall(function() carryRemote:InvokeServer({ Uid = record.Uid, FirstAreaSlotKey = slotKey }) end) end
    pcall(function() if EggState and EggState.CarryFieldEgg then EggState.CarryFieldEgg(record.Uid, slotKey) end end)

    local prompt
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Name == "CarryAreaEgg" and d.Enabled then
            local act = (d.ActionText or ""):lower()
            local obj = (d.ObjectText or ""):lower()
            if not act:find("skip") and not act:find("robux") and not obj:find("skip") and not obj:find("robux") then
                local p = d.Parent
                if p and p:IsA("Attachment") then p = p.Parent end
                if p and (p.Position - hrp.Position).Magnitude < 14 then prompt = d break end
            end
        end
    end
    if prompt then
        prompt.HoldDuration = 0
        pcall(function() fireproximityprompt(prompt) end)
        pcall(function() fireproximityprompt(prompt, 0) end)
    end

    local safePlotCenter = Vector3.new(464.7, 70.4, -364.0)
    if PlotState and PlotState.ResolvePlot then
        local plotObj = PlotState.ResolvePlot()
        local cp = plotObj and plotObj.CenterPoint
        if cp then safePlotCenter = Vector3.new(cp.X, math.max(cp.Y, 70.4), cp.Z) end
    end
    local safeCFrame = CFrame.new(safePlotCenter + Vector3.new(0, 1.2, 0))

    local tPickup = os.clock()
    local carried = false
    local instantFired = false
    local conns = {}
    local function fireInstantNow()
        if instantFired then return end
        instantFired = true
        carried = true
        task.spawn(function()
            bypassReturnTP(safeCFrame, 0.35)
            pcall(restoreCollisions)
            pcall(PlantAllCarriedEggsInPen)
        end)
    end
    if isInstantTP then
        local ch = LP.Character
        local bp = LP:FindFirstChild("Backpack")
        local pg = LP:FindFirstChildOfClass("PlayerGui")
        pcall(function()
            if ch then table.insert(conns, ch.ChildAdded:Connect(function() if isPlayerCarryingEgg() then fireInstantNow() end end)) end
            if bp then table.insert(conns, bp.ChildAdded:Connect(function() if isPlayerCarryingEgg() then fireInstantNow() end end)) end
            if pg then
                table.insert(conns, pg.ChildAdded:Connect(function(c) if c.Name == "DropHeldEgg" then fireInstantNow() end end))
                local dg = pg:FindFirstChild("DropHeldEgg")
                if dg then table.insert(conns, dg:GetPropertyChangedSignal("Enabled"):Connect(function() if dg.Enabled then fireInstantNow() end end)) end
            end
        end)
    end

    local maxWait = isInstantTP and 1.2 or 1.5
    while os.clock() - tPickup < maxWait and not HUB.dead do
        if carried or instantFired then carried = true break end
        if isPlayerCarryingEgg() then carried = true break end
        pcall(function() if EggState and EggState.CarryFieldEgg then EggState.CarryFieldEgg(record.Uid, slotKey) end end)
        if prompt then prompt.HoldDuration = 0 pcall(function() fireproximityprompt(prompt) end) end
        task.wait(isInstantTP and 0 or 0.08)
    end
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end

    if not carried then
        ignoredEggs[record.Uid] = os.clock()
        if isInstantTP then bypassReturnTP(safeCFrame, 0.2) restoreCollisions() end
        return false
    end

    do
        local guardHitEnabled = true
        if guardHitEnabled and carried then
            local tGuardStart = os.clock()
            local startHealth = 100
            local hum0 = findHum()
            if hum0 then startHealth = hum0.Health end
            local wasHit = false
            while os.clock() - tGuardStart < 4.0 and not HUB.dead do
                if not isPlayerCarryingEgg() then wasHit = true break end
                local h = findHum()
                if h then
                    local hs = h:GetState()
                    if h.Health < startHealth - 1.5 or hs == Enum.HumanoidStateType.Physics or hs == Enum.HumanoidStateType.Ragdoll or hs == Enum.HumanoidStateType.FallingDown then
                        wasHit = true
                        local tPost = os.clock()
                        while os.clock() - tPost < 0.85 and not HUB.dead do
                            if not isPlayerCarryingEgg() then break end
                            task.wait(0.05)
                        end
                        break
                    end
                end
                task.wait(0.05)
            end
            if wasHit or not isPlayerCarryingEgg() then
                task.wait(0.65)
                do
                    local tRag = os.clock()
                    while os.clock() - tRag < 3.2 and not HUB.dead do
                        local h = findHum() if not h then break end
                        local hs = h:GetState()
                        if hs ~= Enum.HumanoidStateType.Physics and hs ~= Enum.HumanoidStateType.Ragdoll and hs ~= Enum.HumanoidStateType.FallingDown then break end
                        pcall(function() h:ChangeState(Enum.HumanoidStateType.GettingUp) end)
                        task.wait(0.12)
                    end
                    task.wait(0.35)
                end
                local hrpNow = findHRP()
                if hrpNow and (hrpNow.Position - targetPos).Magnitude > 14 then
                    pcall(function()
                        hrpNow.CFrame = CFrame.new(targetPos + Vector3.new(0, 1.8, 0))
                        hrpNow.AssemblyLinearVelocity = Vector3.zero
                        hrpNow.AssemblyAngularVelocity = Vector3.zero
                    end)
                    task.wait(0.35)
                end
                do
                    local tStand = os.clock()
                    while os.clock() - tStand < 1.5 and not HUB.dead do
                        local h = findHum()
                        if h and h:GetState() ~= Enum.HumanoidStateType.Physics and h:GetState() ~= Enum.HumanoidStateType.Ragdoll then break end
                        task.wait(0.08)
                    end
                end
                do
                    local tGS = os.clock()
                    while os.clock() - tGS < 4.5 and not HUB.dead do
                        local asleep = false
                        pcall(function()
                            local areasRoot = Workspace:FindFirstChild("__OBJECTS") and Workspace.__OBJECTS:FindFirstChild("Areas") and Workspace.__OBJECTS.Areas:FindFirstChild("GuardAreas")
                            local guardModel = nil
                            if areasRoot and record.AreaId then
                                local af = areasRoot:FindFirstChild(record.AreaId)
                                if af then guardModel = af:FindFirstChild("Guard") or af:FindFirstChildWhichIsA("Model", true) end
                            end
                            if not guardModel then
                                local nearest, nd = nil, 1e9
                                for _, m in ipairs(Workspace:GetDescendants()) do
                                    if m:IsA("Model") and m.Name:lower():find("guard") and m.PrimaryPart then
                                        local d = (m.PrimaryPart.Position - targetPos).Magnitude
                                        if d < nd and d < 90 then nd = d nearest = m end
                                    end
                                end
                                guardModel = nearest
                            end
                            if guardModel then
                                local alert = guardModel:GetAttribute("Alert") or guardModel:GetAttribute("Alerted")
                                local sleeping = guardModel:GetAttribute("Sleeping") or guardModel:GetAttribute("Asleep")
                                local state = guardModel:GetAttribute("State")
                                if sleeping == true then asleep = true
                                elseif alert == false or alert == nil then
                                    local hum = guardModel:FindFirstChildOfClass("Humanoid")
                                    local hrp = guardModel.PrimaryPart or guardModel:FindFirstChild("HumanoidRootPart")
                                    local eggPoint = guardModel:FindFirstChild("EggPoint", true)
                                    if hrp and eggPoint then
                                        local distHome = (hrp.Position - eggPoint.Position).Magnitude
                                        if distHome < 7 and (not hum or hum.MoveDirection.Magnitude < 0.12) then asleep = true
                                        elseif distHome < 12 and os.clock() - tGS > 1.2 and (not hum or hum.MoveDirection.Magnitude < 0.15) then asleep = true end
                                    elseif state and tostring(state):lower():find("sleep") then asleep = true
                                    elseif alert == nil and sleeping == nil and state == nil and os.clock() - tGS > 1.6 then asleep = true
                                    elseif alert == false then asleep = true end
                                end
                            else
                                if os.clock() - tGS > 1.4 then asleep = true end
                            end
                        end)
                        if asleep then break end
                        task.wait(0.14)
                    end
                    task.wait(0.08)
                end
                pcall(function() if carryRemote then carryRemote:InvokeServer({ Uid = record.Uid, FirstAreaSlotKey = slotKey }) end end)
                pcall(function() if EggState and EggState.CarryFieldEgg then EggState.CarryFieldEgg(record.Uid, slotKey) end end)
                task.wait(0.08)
                local prompt2
                for _, d in ipairs(Workspace:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Name == "CarryAreaEgg" and d.Enabled then
                        local p = d.Parent
                        if p and p:IsA("Attachment") then p = p.Parent end
                        if p then
                            local dist = (p.Position - (findHRP() and findHRP().Position or targetPos)).Magnitude
                            if dist < 16 then
                                local act = (d.ActionText or ""):lower()
                                if not act:find("skip") and not act:find("robux") then prompt2 = d break end
                            end
                        end
                    end
                end
                if prompt2 then prompt2.HoldDuration = 0 pcall(function() fireproximityprompt(prompt2) end) end
                local tP2 = os.clock()
                while os.clock() - tP2 < 2.2 and not HUB.dead do
                    if isPlayerCarryingEgg() then carried = true isInstantTP = false break end
                    pcall(function() if EggState and EggState.CarryFieldEgg then EggState.CarryFieldEgg(record.Uid, slotKey) end end)
                    if prompt2 then pcall(function() fireproximityprompt(prompt2) end) end
                    task.wait(0.06)
                end
                if isPlayerCarryingEgg() then carried = true isInstantTP = false end
            end
        end
    end

    if isInstantTP then
        if not instantFired then
            bypassReturnTP(safeCFrame, 0.35)
            task.spawn(function() pcall(restoreCollisions) pcall(PlantAllCarriedEggsInPen) end)
        end
    else
        if speed > 250 then
            local hrpNow = findHRP()
            local curPos = hrpNow and hrpNow.Position or targetPos
            local toBase = safePlotCenter - curPos
            local distBase = toBase.Magnitude
            if distBase > 45 then
                local stagePos = safePlotCenter - toBase.Unit * 35
                stagePos = Vector3.new(stagePos.X, math.max(stagePos.Y, 70.4), stagePos.Z)
                TravelToDestination(stagePos, speed, false)
                local hrp2 = findHRP()
                if hrp2 then hrp2.AssemblyLinearVelocity = Vector3.zero hrp2.AssemblyAngularVelocity = Vector3.zero end
                task.wait(0.35)
            end
            TravelToDestination(safePlotCenter, 240, true)
        else
            TravelToDestination(safePlotCenter, speed, true)
        end
    end

    local tDeliver = os.clock()
    while os.clock() - tDeliver < 1.5 and isPlayerCarryingEgg() and not HUB.dead do task.wait(0.08) end
    PlantAllCarriedEggsInPen()

    local char = LP.Character
    local h = char and char:FindFirstChild("HumanoidRootPart")
    local hu = char and char:FindFirstChildOfClass("Humanoid")
    if h then
        h.CFrame = CFrame.new(safePlotCenter.X, math.max(safePlotCenter.Y, 70.4), safePlotCenter.Z)
        h.AssemblyLinearVelocity = Vector3.zero
        h.AssemblyAngularVelocity = Vector3.zero
    end
    if hu then
        hu.PlatformStand = false
        hu.AutoRotate = true
        pcall(function() hu:ChangeState(Enum.HumanoidStateType.Running) end)
    end
    return carried or isPlayerCarryingEgg()
end

local function HatchAllReadyEggs()
    if not EggState or not EggState.ReadOwnedEggs then return 0 end
    local ok, snap = pcall(EggState.ReadOwnedEggs, LP.UserId)
    if not ok or not snap then return 0 end
    local count = 0
    local records = snap.Records or snap
    if typeof(records) == "table" then
        for uid, data in pairs(records) do
            if typeof(data) == "table" then
                local ready = EggState.IsReadyToHatch and EggState.IsReadyToHatch(data) or (data.Placement ~= nil)
                if ready then
                    pcall(function()
                        if EggState.BeginHatch then EggState.BeginHatch(uid) end
                        task.wait(0.05)
                        if EggState.FinishHatch then EggState.FinishHatch(uid) end
                        count = count + 1
                    end)
                end
            end
        end
    end
    return count
end

local function UpgradeHomesteadBase()
    local a = GetNetRemote("RE/Homestead/AskNearbyPurchase")
    if a then pcall(function() a:FireServer() end) end
    local b = GetNetRemote("RE/Homestead/AskBaseTierRaise")
    if b then pcall(function() b:FireServer() end) end
end
local function UpgradeTreadmillTier()
    local rf = GetNetRemote("RF/Treadmill/AskTierRaise")
    if rf then pcall(function() rf:InvokeServer() end) end
end
local function EquipBestPets()
    local rf = GetNetRemote("RF/Haul/WearBest") or GetNetRemote("RF/PenRoster/ConfirmEquipBestBadge")
    if rf then pcall(function() rf:InvokeServer() end) end
end
local function GetMyMonsterPosition()
    local my = Workspace:FindFirstChild("MonsterParasiteMonsters") and Workspace.MonsterParasiteMonsters:FindFirstChild("Monster_" .. LP.UserId)
    if my then return (my.PrimaryPart and my.PrimaryPart.Position) or my:GetPivot().Position end
    local pad = Workspace:FindFirstChild("Stands") and Workspace.Stands:FindFirstChild("Pads") and Workspace.Stands.Pads:FindFirstChild("Monster")
    if pad then return pad.Position end
    return Vector3.new(545.1, 68.0, -413.4)
end
local function ClaimMonsterChests()
    pcall(function()
        local rf1 = GetNetRemote("RF/MonsterParasite/AskChestClaim") if rf1 then rf1:InvokeServer() end
        local rf2 = GetNetRemote("RF/MonsterParasite/AskChestTake") if rf2 then rf2:InvokeServer() end
    end)
end
local function FeedMonsterParasite()
    local rf = GetNetRemote("RF/MonsterParasite/AskFeed")
    if not rf then return false end
    local hrp = findHRP() if not hrp then return false end
    local mPos = GetMyMonsterPosition()
    local savedSpot
    if (hrp.Position - mPos).Magnitude > 12 then
        savedSpot = hrp.CFrame
        TravelToDestination(mPos + Vector3.new(0, 1.2, 0), glideSpeed, true)
        task.wait(0.08)
    end
    local ok, res = pcall(function() return rf:InvokeServer() end)
    if savedSpot then
        task.wait(0.1)
        TravelToDestination(savedSpot.Position, glideSpeed, true)
        local h = findHRP() if h then h.CFrame = savedSpot end
    end
    return ok and res
end
local function BuyAffordableTrails()
    local rf = GetNetRemote("RF/Trailwear/AskPurchase")
    local TrailsData = RS:FindFirstChild("Data") and RS.Data:FindFirstChild("Trails") and require(RS.Data.Trails)
    local save
    pcall(function() save = Save and Save.Get and Save.Get() end)
    if not rf or not TrailsData or not save then return end
    local money = tonumber(save.Money) or 0
    local inv = save.TrailInventory or {}
    for _, t in pairs(TrailsData.Directory or TrailsData) do
        if type(t) == "table" and t._id and not inv[t._id] then
            local price = tonumber(t.Price) or math.huge
            if money >= price then
                pcall(function() rf:InvokeServer(t._id) end)
                task.wait(0.25)
            end
        end
    end
end
local function SellSelectedPets(selectedSellPetRarities)
    local re = GetNetRemote("RE/PetSatchel/SellPet")
    if not re or not Save then return end
    local save
    pcall(function() save = Save.Get and Save.Get() end)
    local inv = save and save.Inventory
    if type(inv) ~= "table" then return end
    for uid, pet in pairs(inv) do
        if type(pet) == "table" and not pet.Locked then
            local r = pet.Rarity or "Common"
            if (not selectedSellPetRarities or next(selectedSellPetRarities) == nil) or selectedSellPetRarities[r] then
                pcall(function() re:FireServer(uid) end)
                task.wait(0.08)
            end
        end
    end
end
local function SellSelectedEggs()
    if not Save then return end
    local save
    pcall(function() save = Save.Get and Save.Get() end)
    if not save then return end
    local inv = save.EggInventory
    if type(inv) ~= "table" then return end
    local wear = GetNetRemote("RF/EggWorld/AskWearTool")
    local sell = GetNetRemote("RE/PetSatchel/SellPet")
    if not wear or not sell then return end
    for uid, egg in pairs(inv) do
        if type(egg) == "table" and not egg.Placement and not egg.Locked then
            local rName = GetEggRarityInfo(egg)
            if (RARITY_SCORE_MAP[rName] or 100) <= 600 then
                pcall(function() wear:InvokeServer(uid) end)
                pcall(function() sell:FireServer({ uid }) end)
                task.wait(0.1)
            end
        end
    end
end
local function DeleteOwnPetRenders()
    local count = 0
    local function sweep(c)
        if not c then return end
        for _, ch in ipairs(c:GetChildren()) do
            if ch:IsA("Model") or ch:IsA("BasePart") then pcall(function() ch:Destroy() count = count + 1 end) end
        end
    end
    sweep(Workspace:FindFirstChild("Pets"))
    sweep(Workspace:FindFirstChild("RenderedPets"))
    return count
end
local function ClaimAllAvailableRewards()
    pcall(function() local rf = GetNetRemote("RF/AwayEarnings/AskCollect") if rf then rf:InvokeServer() end end)
    pcall(function() local rf = GetNetRemote("RF/Codex/AskRedeemAll") if rf then rf:InvokeServer() end end)
    pcall(function() local rf = GetNetRemote("RF/GroupPerk/RedeemPerk") if rf then rf:InvokeServer() end end)
    pcall(ClaimMonsterChests)
end

local hookV1Enabled = false
local hookV2Enabled = false
local BaseDropPosition = Vector3.new(533.931, 70.767, -366.707)
local HookDelay = 0.1
local DropEggDelay = 0.2

local function dropEggServerFS()
    pcall(function()
        local drop = GetNetRemote("RF/EggWorld/AskFieldEggDrop")
        if drop then drop:InvokeServer({ Reason = "PlayerRequest" }) end
    end)
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if not HUB.dead and method == "InvokeServer" and self.Name == "RF/EggWorld/AskFieldEggCarry" then
        local result = oldNamecall(self, unpack(args))
        if result == true then
            if hookV1Enabled then
                task.spawn(function()
                    preciseWait(HookDelay)
                    if hookV1Enabled and not HUB.dead then
                        local targetPos = BaseDropPosition
                        if targetPos then
                            walkToTarget(targetPos, WalkSpeedSettings.MovementSpeed, 3)
                            repeat RunService.Heartbeat:Wait() until not isWalkingToTarget or HUB.dead
                            if not HUB.dead and hookV1Enabled then
                                preciseWait(DropEggDelay)
                                dropEggServerFS()
                            end
                        end
                    end
                end)
            elseif hookV2Enabled then
                task.spawn(function()
                    preciseWait(HookDelay)
                    if hookV2Enabled and not HUB.dead then
                        local forestBounds = Workspace:FindFirstChild("__OBJECTS")
                            and Workspace.__OBJECTS:FindFirstChild("Areas")
                            and Workspace.__OBJECTS.Areas:FindFirstChild("GuardAreas")
                            and Workspace.__OBJECTS.Areas.GuardAreas:FindFirstChild("Forest")
                            and Workspace.__OBJECTS.Areas.GuardAreas.Forest:FindFirstChild("Bounds")
                        local targetPos = resolvePosition(forestBounds) or BaseDropPosition
                        if targetPos then
                            walkToTarget(targetPos, WalkSpeedSettings.MovementSpeed, 3)
                            repeat RunService.Heartbeat:Wait() until not isWalkingToTarget or HUB.dead
                            if not HUB.dead and hookV2Enabled then
                                preciseWait(DropEggDelay)
                                dropEggServerFS()
                            end
                        end
                    end
                end)
            end
        else
            stopCurrentWalking(true)
        end
        return result
    end
    return oldNamecall(self, ...)
end))

local function makePromptInstant(prompt)
    if prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = math.max(prompt.MaxActivationDistance, 10)
        prompt.RequiresLineOfSight = false
    end
end
for _, d in ipairs(Workspace:GetDescendants()) do makePromptInstant(d) end
track(Workspace.DescendantAdded:Connect(function(d)
    if not HUB.dead and d:IsA("ProximityPrompt") then preciseWait(0.05) makePromptInstant(d) end
end))

track(UIS.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Space then
        pcall(function()
            local re = GetNetRemote("RF/Treadmill/AskDoff")
            if re then re:InvokeServer() end
        end)
    end
end))

local waypoints = {}
local function addWaypoint(name, cframe, pos) table.insert(waypoints, { name = name, cframe = cframe, position = pos }) end
local function teleportToWaypoint(index)
    if waypoints[index] then
        local r = findHRP()
        if r then r.CFrame = waypoints[index].cframe r.AssemblyLinearVelocity = Vector3.zero r.AssemblyAngularVelocity = Vector3.zero end
    end
end

local FAKE_PETS = _G.__YunoFakePets or {}
_G.__YunoFakePets = FAKE_PETS
local HOOK_VERSION = 6
if _G.__YunoPetHookVersion ~= HOOK_VERSION and AssetRoster then
    _G.__YunoPetHookVersion = HOOK_VERSION
    _G.__YunoPetOriginals = _G.__YunoPetOriginals or { WearAsset = AssetRoster.WearAsset, DoffAsset = AssetRoster.DoffAsset }
    local ORIG = _G.__YunoPetOriginals
    AssetRoster.WearAsset = function(uid, ...)
        if FAKE_PETS[uid] then return true, nil, nil end
        return ORIG.WearAsset(uid, ...)
    end
    AssetRoster.DoffAsset = function(uid, ...)
        if uid == nil or FAKE_PETS[uid] then return true, nil end
        return ORIG.DoffAsset(uid, ...)
    end
end

local PET_MODELS = RS:FindFirstChild("AssetModels")
local CATALOG = {}
if Assets then
    for id, cfg in pairs(Assets.Directory) do
        if not PET_MODELS or PET_MODELS:FindFirstChild(id) then
            table.insert(CATALOG, {
                id = id, display = cfg.DisplayName or id,
                rate = tonumber(cfg.EarningRate) or 0,
                rarity = (type(cfg.Rarity) == "table" and cfg.Rarity.Name) or "?",
                icon = cfg.Icon or "",
                baseScale = tonumber(cfg.BaseModelScale) or 1,
            })
        end
    end
    table.sort(CATALOG, function(a, b)
        if a.rate == b.rate then return a.display < b.display end
        return a.rate > b.rate
    end)
end

local spawnedTools = {}
local injectedUids = {}
local spawnCounter = 0
local currentMutation = "None"
local currentSize = 1
local placedComponents = {}
local fakeIncome = 0
local petAutoEquip = true
local serverMoney = 0
local lastMoney = nil
local serverMps = 0
local lastMps = nil
local earned = 0

local function petContainer()
    local f = Workspace:FindFirstChild("YunoPets")
    if not f then f = Instance.new("Folder") f.Name = "YunoPets" f.Parent = Workspace end
    return f
end

local function findPetArea()
    if not PlotState then return nil end
    local good, slot = pcall(PlotState.ResolveLocalSlot)
    if not good or slot == nil then return nil end
    local folder = PlotState.ResolveFolder()
    local plot = folder and folder:FindFirstChild(tostring(slot))
    local upd = plot and plot:FindFirstChild("ToUpdate")
    local area = upd and upd:FindFirstChild("PetArea")
    return (area and area:IsA("BasePart")) and area or nil
end

local function clampToArea(pos, area)
    local half = area.Size * 0.5
    local lp = area.CFrame:PointToObjectSpace(pos)
    local x = math.clamp(lp.X, -half.X + 2, half.X - 2)
    local z = math.clamp(lp.Z, -half.Z + 2, half.Z - 2)
    return (area.CFrame * CFrame.new(x, 0, z)).Position
end

local function buildItemData(entry)
    local rng = Random.new()
    local egg = EggRecords.NewEgg(entry.id, rng)
    egg.AssetGender = AssetGender.Settle(entry.id, nil, rng)
    local itemData = EggRecords.ToAssetItemData(egg)
    itemData.HasBeenFirstPlaced = true
    itemData.Scale = (itemData.Scale or entry.baseScale) * currentSize
    if currentMutation ~= "None" then
        itemData.Mutations = { currentMutation }
        itemData.BaseMutation = currentMutation
    else
        itemData.Mutations = {}
        itemData.BaseMutation = nil
    end
    return itemData, rng
end

local function doSpawnPet(entry)
    if not (Save and AssetItems and ItemDisplay) then return end
    spawnCounter = spawnCounter + 1
    local uid = ("yunopet_%s_%d_%d"):format(entry.id:lower():gsub("[^%a%d]", "_"), spawnCounter, math.random(1000, 9999))
    local mutations, baseMutation = {}, nil
    if currentMutation ~= "None" then mutations, baseMutation = { currentMutation }, currentMutation end
    local itemData = {
        HasBeenFirstPlaced = false, Category = entry.id, Scale = entry.baseScale * currentSize,
        EyeColor = "ffffff", ColorSeed = math.random(0, 2147483647), ColorIndex = 1,
        Mutations = mutations, BaseMutation = baseMutation,
    }
    local ok, encoded = pcall(AssetItems.Encode, itemData)
    if not ok then return end
    pcall(Save.ApplyLocalFieldEntry, "Inventory", uid, encoded)
    injectedUids[uid] = true
    FAKE_PETS[uid] = true
    local okTool, tool = pcall(ItemDisplay.CreateTool, itemData, uid, LP)
    refreshInventory()
    if okTool and typeof(tool) == "Instance" then
        table.insert(spawnedTools, tool)
        if petAutoEquip then
            task.wait(0.15)
            local hum = findHum()
            if hum then pcall(function() hum:EquipTool(tool) end) end
        end
    end
end

local function placeAt(entry, cframe, existingItemData)
    local petArea = findPetArea()
    if not petArea then return false end
    if not (AssetComponent and LiveBatch and LiveBillboards) then return false end
    spawnCounter = spawnCounter + 1
    local uid = ("yunopet_%s_%d_%d"):format(entry.id:lower():gsub("[^%a%d]", "_"), spawnCounter, math.random(1000, 9999))
    local itemData, rng = buildItemData(entry)
    if existingItemData then itemData = existingItemData end
    local record = {
        OwnerUserId = LP.UserId, UID = uid, ItemData = itemData,
        MoneyPerSecond = AssetEarnings.LiveRatePerSecond(itemData),
        Seed = rng:NextInteger(1, 2147483647),
    }
    local ok, comp = pcall(AssetComponent.new, record, LP, petArea, petContainer(), LiveBillboards, LiveBatch, cframe)
    if not ok or not comp then return false end
    local model = comp:GetModel()
    pcall(function() LiveBillboards:Add(model, record.ItemData, record.MoneyPerSecond) end)
    task.spawn(function()
        task.wait(0.1)
        pcall(function()
            local _, size = model:GetBoundingBox()
            local center = model:FindFirstChild("CENTER", true)
            local lift = (size.Y * 0.5) + 2.5
            if center then lift = (model:GetBoundingBox().Position.Y + size.Y * 0.5) - center.Position.Y + 2.5 end
            for _, d in ipairs(model:GetDescendants()) do
                if d:IsA("BillboardGui") then
                    d.StudsOffsetWorldSpace = Vector3.new(0, lift, 0)
                    d.AlwaysOnTop = true
                    d.Enabled = true
                end
            end
        end)
    end)
    table.insert(placedComponents, comp)
    fakeIncome = fakeIncome + (tonumber(record.MoneyPerSecond) or 0)
    return true
end

local function clearAllSpawnedPets()
    local hum = findHum()
    if hum then pcall(function() hum:UnequipTools() end) end
    for _, t in ipairs(spawnedTools) do pcall(function() t:Destroy() end) end
    spawnedTools = {}
    for uid in pairs(injectedUids) do
        FAKE_PETS[uid] = nil
        if Save then pcall(Save.ApplyLocalFieldEntry, "Inventory", uid, nil) end
    end
    injectedUids = {}
    refreshInventory()
    for _, comp in ipairs(placedComponents) do
        pcall(function()
            local model = comp:GetModel()
            if LiveBillboards then LiveBillboards:Remove(model) end
            if LiveBatch then LiveBatch:Remove(model) end
        end)
        pcall(function() comp:Destroy() end)
    end
    placedComponents = {}
    fakeIncome = 0
    local holder = Workspace:FindFirstChild("YunoPets")
    if holder then pcall(function() holder:Destroy() end) end
end

pcall(function()
    local profile = Save and Save.Get and Save.Get()
    if profile and typeof(profile.Money) == "number" then serverMoney = profile.Money end
end)
pcall(function()
    if not Save or not Save.WatchFields then return end
    Save.WatchFields("Money", function()
        local profile = Save.Get()
        local v = profile and profile.Money
        if typeof(v) ~= "number" then return end
        if lastMoney and math.abs(v - lastMoney) < 0.01 then return end
        serverMoney = v
    end)
end)
pcall(function()
    local ls = LP:WaitForChild("leaderstats", 5)
    local mps = ls and ls:FindFirstChild("Money/s")
    if not mps then return end
    serverMps = mps.Value
    mps.Changed:Connect(function(v)
        if lastMps and math.abs(v - lastMps) < 0.01 then return end
        serverMps = v
    end)
end)
task.spawn(function()
    local acc = 0
    while not HUB.dead do
        local dt = task.wait(0.25)
        if fakeIncome > 0 then
            acc = acc + fakeIncome * (dt or 0.25)
            if acc >= 1 then earned = earned + acc acc = 0 end
            pcall(function()
                local ls = LP:FindFirstChild("leaderstats")
                local mps = ls and ls:FindFirstChild("Money/s")
                if mps then lastMps = serverMps + fakeIncome mps.Value = lastMps end
                lastMoney = serverMoney + earned
                if Save then Save.ApplyLocalField("Money", lastMoney) end
            end)
        end
    end
end)

local hopAutoEnabled = false
local hopAutoThread = nil

local function getRandomServer()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local ok, raw = pcall(function() return game:HttpGet(url) end)
    if not ok or not raw or raw == "" then return nil end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 or not data or not data.data or #data.data == 0 then return nil end
    local current = tostring(game.JobId)
    local cands = {}
    for _, s in ipairs(data.data) do
        if s.id and tostring(s.id) ~= current then table.insert(cands, tostring(s.id)) end
    end
    if #cands == 0 then return nil end
    return cands[math.random(1, #cands)]
end

local function findLowServer()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true&_=" .. tostring(os.time())
    local ok, raw = pcall(function() return game:HttpGet(url) end)
    if not ok or not raw then return nil end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok2 or not data or not data.data then return nil end
    local current = tostring(game.JobId)
    local valid = {}
    for _, s in ipairs(data.data) do
        if s.id ~= current and (s.playing or 0) < (s.maxPlayers or 0) then
            table.insert(valid, s)
        end
    end
    table.sort(valid, function(a, b)
        if (a.playing or 0) ~= (b.playing or 0) then return (a.playing or 0) < (b.playing or 0) end
        return (a.ping or 999) < (b.ping or 999)
    end)
    return valid[1]
end

local function hopOnce(threshold)
    threshold = math.max(1, math.floor(tonumber(threshold) or 1))
    local current = #Players:GetPlayers()
    if current <= threshold then return false, "Server OK (" .. current .. ")" end
    local serverId = getRandomServer()
    if not serverId then return false, "No server" end
    local ok, err = pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, LP) end)
    if not ok then return false, tostring(err) end
    return true
end

local esp = {
    enabled = false, eggs = true, traps = false, players = false,
    rareEggsOnly = false, showPetIcons = true, maxDistance = 800,
    eggColor = Color3.fromRGB(255, 200, 50),
    rareEggColor = Color3.fromRGB(255, 60, 220),
    trapColor = Color3.fromRGB(255, 60, 60),
    playerColor = Color3.fromRGB(100, 220, 100),
}
local hasDrawing = type(Drawing) == "table" and type(Drawing.new) == "function"
local trackedEspObjects = {}
local espBillboards = {}
local espContainer = nil

local function getEspContainer()
    if espContainer and espContainer.Parent then return espContainer end
    local p
    pcall(function() p = (gethui and gethui()) end)
    if not p then pcall(function() p = game:GetService("CoreGui") end) end
    if not p then p = LP:FindFirstChild("PlayerGui") or Workspace end
    pcall(function()
        for _, c in ipairs(p:GetChildren()) do
            if c:IsA("Folder") and c.Name == "Yuno_Esp_Holder" then c:Destroy() end
        end
    end)
    espContainer = Instance.new("Folder")
    espContainer.Name = "Yuno_Esp_Holder"
    pcall(function() espContainer.Parent = p end)
    return espContainer
end

local function updateEggBillboard(key, pos, icon)
    local bb = espBillboards[key]
    if not bb or not bb.gui or not bb.gui.Parent then
        local holder = getEspContainer()
        local part = Instance.new("Part")
        part.Name = "EspAnchor"
        part.Size = Vector3.new(1, 1, 1)
        part.Transparency = 1
        part.Anchored = true
        part.CanCollide = false
        part.CanQuery = false
        part.CanTouch = false
        part.CFrame = CFrame.new(pos)
        part.Parent = holder
        local gui = Instance.new("BillboardGui")
        gui.Adornee = part
        gui.Size = UDim2.fromOffset(28, 28)
        gui.StudsOffset = Vector3.new(-2.2, 1.2, 0)
        gui.AlwaysOnTop = true
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = part
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.fromScale(1, 1)
        img.BackgroundTransparency = 1
        img.ScaleType = Enum.ScaleType.Fit
        img.Image = icon or ""
        img.Parent = gui
        bb = { part = part, gui = gui, img = img }
        espBillboards[key] = bb
    else
        bb.part.CFrame = CFrame.new(pos)
        bb.img.Image = icon or ""
        bb.gui.Enabled = (icon ~= nil and icon ~= "")
    end
end

track(RunService.RenderStepped:Connect(function()
    if HUB.dead or not esp.enabled or not hasDrawing then
        for _, obj in pairs(trackedEspObjects) do
            if obj.name then obj.name.Visible = false end
            if obj.dist then obj.dist.Visible = false end
        end
        for _, bb in pairs(espBillboards) do if bb.gui then bb.gui.Enabled = false end end
        return
    end
    local hrp = findHRP()
    local myPos = hrp and hrp.Position or Vector3.zero
    local cam = GetCamera()
    local renderItems = {}
    local activeBbKeys = {}
    if esp.eggs and EggState and EggState.ReadFieldEggs then
        local ok, snap = pcall(EggState.ReadFieldEggs)
        if ok and snap and snap.Records then
            for _, egg in ipairs(snap.Records) do
                if egg.State == "Slot" and egg.BoundsCFrame then
                    local pos = egg.BoundsCFrame.Position
                    local dist = (pos - myPos).Magnitude
                    if esp.maxDistance <= 0 or dist <= esp.maxDistance then
                        local muts = egg.Mutations or {}
                        local isRare = #muts > 0
                        if not esp.rareEggsOnly or isRare then
                            local rarityName = GetEggRarityInfo(egg)
                            local mutText = isRare and (" [" .. table.concat(muts, ",") .. "]") or ""
                            local label = (egg.AssetCategory or "Egg") .. " (" .. rarityName .. ")" .. mutText
                            local cat = egg.AssetCategory
                            local aInfo = AssetsData and (AssetsData.Directory or AssetsData) and (AssetsData.Directory or AssetsData)[cat]
                            local petIcon = aInfo and (aInfo.Icon or (aInfo.Egg and aInfo.Egg.Icon)) or ""
                            table.insert(renderItems, { Key = egg.Uid, Pos = pos, Name = label, Color = isRare and esp.rareEggColor or esp.eggColor, Dist = dist })
                            if esp.showPetIcons and petIcon ~= "" then
                                activeBbKeys[egg.Uid] = true
                                updateEggBillboard(egg.Uid, pos, petIcon)
                            end
                        end
                    end
                end
            end
        end
    end
    if esp.traps then
        local debris = Workspace:FindFirstChild("__DEBRIS")
        if debris then
            for _, trap in ipairs(debris:GetChildren()) do
                if trap.Name == "PlayerTrap" and trap:IsA("BasePart") then
                    local pos = trap.Position
                    local dist = (pos - myPos).Magnitude
                    if esp.maxDistance <= 0 or dist <= esp.maxDistance then
                        table.insert(renderItems, { Key = trap, Pos = pos + Vector3.new(0, 1.5, 0), Name = "[TRAP] @" .. (trap:GetAttribute("Owner") or "Enemy"), Color = esp.trapColor, Dist = dist })
                    end
                end
            end
        end
    end
    if esp.players then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local oHrp = p.Character:FindFirstChild("HumanoidRootPart")
                if oHrp then
                    local dist = (oHrp.Position - myPos).Magnitude
                    if esp.maxDistance <= 0 or dist <= esp.maxDistance then
                        table.insert(renderItems, { Key = p, Pos = oHrp.Position, Name = p.DisplayName .. " (@" .. p.Name .. ")", Color = esp.playerColor, Dist = dist })
                    end
                end
            end
        end
    end
    for k, bb in pairs(espBillboards) do
        if not activeBbKeys[k] and bb.gui then bb.gui.Enabled = false end
    end
    local activeKeys = {}
    for _, item in ipairs(renderItems) do
        activeKeys[item.Key] = true
        local obj = trackedEspObjects[item.Key]
        if not obj then
            obj = {}
            obj.name = trackDrawing(Drawing.new("Text"))
            obj.name.Size = 13 obj.name.Center = true obj.name.Outline = true obj.name.Visible = false
            obj.dist = trackDrawing(Drawing.new("Text"))
            obj.dist.Size = 11 obj.dist.Center = true obj.dist.Outline = true obj.dist.Visible = false
            trackedEspObjects[item.Key] = obj
        end
        local screenPos, onScreen = nil, false
        if cam then screenPos, onScreen = cam:WorldToViewportPoint(item.Pos) end
        if onScreen and screenPos then
            if obj.name then
                obj.name.Text = item.Name
                obj.name.Position = Vector2.new(screenPos.X, screenPos.Y - 14)
                obj.name.Color = item.Color
                obj.name.Visible = true
            end
            if obj.dist then
                obj.dist.Text = math.floor(item.Dist) .. " studs"
                obj.dist.Position = Vector2.new(screenPos.X, screenPos.Y + 2)
                obj.dist.Color = Color3.fromRGB(220, 220, 220)
                obj.dist.Visible = true
            end
        else
            if obj.name then obj.name.Visible = false end
            if obj.dist then obj.dist.Visible = false end
        end
    end
    for k, obj in pairs(trackedEspObjects) do
        if not activeKeys[k] then
            if obj.name then obj.name.Visible = false end
            if obj.dist then obj.dist.Visible = false end
        end
    end
end))

local Window = WindUI:CreateWindow({
    Title = "Yuno Hub | Steal an Egg",
    Author = "by Halil Tasty",
    Folder = "YunoHub",
    Icon = "flame",
    Size = UDim2.new(0, 640, 0, 500),
    Transparent = true,
    BackgroundTransparency = 0.4,
    Theme = "Dark",
    SideBarWidth = 200,
    OpenButton = {
        Title = "Yuno Hub",
        CornerRadius = UDim.new(0.5, 0),
        Enabled = true,
        Draggable = true,
        Color = ColorSequence.new(Color3.fromHex("#7C3AED"), Color3.fromHex("#22D3EE")),
    },
    User = { Enabled = true, Anonymous = false },
})

local function Notify(title, content, kind, dur)
    pcall(function() WindUI:Notify({ Title = title, Content = content, Icon = "info", Duration = dur or 2.5 }) end)
end

local autoStealEnabled = false
local stealDelay = 1.5
local autoHatchEnabled = false
local autoPlantEnabled = false
local hatchDelay = 2.0
local autoUpgradeBase = false
local autoUpgradeTreadmill = false
local autoEquipBestPets = false
local autoClaimRewards = false
local autoSellPets = false
local autoBuyTrails = false
local autoClaimMonsterChests = false
local autoFeedMonster = false
local batAuraEnabled = false
local batAuraRadius = 20
local batAuraDelay = 0.2
local instantPickupEnabled = true
local noKnockbackEnabled = true

task.spawn(function()
    while not HUB.dead do
        if autoStealEnabled then
            pcall(function()
                pcall(HatchAllReadyEggs)
                local eggs = GetMatchingFieldEggs()
                if #eggs > 0 then StealSpecificEggRobust(eggs[1]) end
            end)
        end
        task.wait(stealDelay)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoHatchEnabled then pcall(HatchAllReadyEggs) end
        if autoPlantEnabled then pcall(PlantAllCarriedEggsInPen) end
        task.wait(hatchDelay)
    end
end)
task.spawn(function()
    while not HUB.dead do
        if autoUpgradeBase then pcall(UpgradeHomesteadBase) end
        if autoUpgradeTreadmill then pcall(UpgradeTreadmillTier) end
        if autoEquipBestPets then pcall(EquipBestPets) end
        if autoClaimRewards then pcall(ClaimAllAvailableRewards) end
        if autoSellPets then pcall(SellSelectedPets, nil) end
        if autoBuyTrails then pcall(BuyAffordableTrails) end
        if autoClaimMonsterChests then pcall(ClaimMonsterChests) end
        if autoFeedMonster then pcall(FeedMonsterParasite) end
        task.wait(2.5)
    end
end)
task.spawn(function()
    local re = GetNetRemote("RE/BatSwing/Trigger")
    while not HUB.dead do
        if batAuraEnabled and re then
            local hrp = findHRP()
            if hrp then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local oHrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if oHrp and (oHrp.Position - hrp.Position).Magnitude <= batAuraRadius then
                            pcall(function() re:FireServer() end)
                            break
                        end
                    end
                end
            end
        end
        task.wait(batAuraDelay)
    end
end)

track(UIS.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.Z then stopCurrentWalking(true) end
end))
track(RunService.Heartbeat:Connect(function()
    if HUB.dead or not antiRagdollEnabled then return end
    local hum = findHum()
    if hum and hum:GetState() == Enum.HumanoidStateType.Physics then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end))

local Section = Window:Section({ Title = "Yuno Hub", Icon = "flame", Opened = true })

local EggsTab = Section:Tab({ Title = "Eggs", Icon = "egg" })
EggsTab:Toggle({ Flag = "steal_auto", Title = "Auto Steal Eggs", Desc = "Auto-steal filtered eggs", Default = false,
    Callback = function(v) autoStealEnabled = v if v then EnsureSavedReturnPosition() end Notify("Auto Steal", v and "Enabled" or "Disabled") end })
EggsTab:Dropdown({ Flag = "steal_method", Title = "Movement", Desc = "Travel method",
    Values = { { Title = "Tween Glide" }, { Title = "Fly Glide" }, { Title = "Safe Walk" }, { Title = "Anti Guard" } },
    Value = "Tween Glide",
    Callback = function(s) stealMovementMethod = s.Title end })
EggsTab:Slider({ Flag = "glide_speed", Title = "Glide Speed", Desc = "Studs/s", Step = 10,
    Value = { Min = 50, Max = 750, Default = 750 }, Callback = function(v) glideSpeed = v end })
EggsTab:Slider({ Flag = "steal_gap", Title = "Steal Delay", Desc = "Seconds", Step = 0.1,
    Value = { Min = 0.5, Max = 10, Default = 1.5 }, Callback = function(v) stealDelay = v end })
EggsTab:MultiDropdown({ Flag = "steal_rarities", Title = "Filter Rarity", Values = RARITY_NAMES, Default = {},
    Callback = function(sel) selectedStealRarities = {} for _, v in ipairs(sel) do selectedStealRarities[v] = true end end })
EggsTab:MultiDropdown({ Flag = "steal_areas", Title = "Filter Area", Values = AREA_NAMES, Default = {},
    Callback = function(sel) selectedStealAreas = {} for _, v in ipairs(sel) do selectedStealAreas[v] = true end end })
EggsTab:MultiDropdown({ Flag = "steal_muts", Title = "Filter Mutation", Values = MUTATION_FILTERS, Default = {},
    Callback = function(sel) selectedMutationTypes = {} for _, v in ipairs(sel) do selectedMutationTypes[v] = true end end })
EggsTab:Toggle({ Flag = "steal_parasite_only", Title = "Parasite Eggs Only", Default = false, Callback = function(v) stealParasiteOnly = v end })
EggsTab:Toggle({ Flag = "steal_big_only", Title = "Big Eggs Only", Default = false, Callback = function(v) stealBigEggsOnly = v end })
EggsTab:Button({ Title = "Steal Best Egg (1x)", Justify = "Center",
    Callback = function()
        local eggs = GetMatchingFieldEggs()
        if #eggs == 0 then Notify("Steal", "No matching egg") return end
        local ok = StealSpecificEggRobust(eggs[1])
        Notify("Steal", ok and "Egg stolen" or "Failed")
    end })
EggsTab:Section({ Title = "Hatch & Plant", TextSize = 16 })
EggsTab:Toggle({ Flag = "hatch_auto", Title = "Auto Hatch", Default = false, Callback = function(v) autoHatchEnabled = v end })
EggsTab:Toggle({ Flag = "plant_auto", Title = "Auto Plant (pen)", Default = false, Callback = function(v) autoPlantEnabled = v end })
EggsTab:Slider({ Flag = "hatch_gap", Title = "Hatch Check Delay", Step = 0.5, Value = { Min = 0.5, Max = 10, Default = 2.0 }, Callback = function(v) hatchDelay = v end })
EggsTab:Button({ Title = "Hatch Now", Justify = "Center", Callback = function() local c = HatchAllReadyEggs() Notify("Hatch", c .. " hatched") end })
EggsTab:Button({ Title = "Plant Now", Justify = "Center", Callback = function() local c = PlantAllCarriedEggsInPen() Notify("Plant", c .. " planted") end })

local PetsTab = Section:Tab({ Title = "Pets", Icon = "paw-print" })
PetsTab:Dropdown({ Flag = "pet_mutation", Title = "Mutation",
    Values = { "None", "Golden", "Rainbow", "Silver", "Sakura", "GreatBloom" }, Value = "None",
    Callback = function(s) currentMutation = s.Title end })
PetsTab:Dropdown({ Flag = "pet_size", Title = "Size",
    Values = { "1x", "2x", "5x", "10x", "25x" }, Value = "1x",
    Callback = function(s) currentSize = tonumber(s.Title:match("%d+")) or 1 end })
PetsTab:Toggle({ Flag = "pet_auto_equip", Title = "Auto Equip Spawned", Default = true, Callback = function(v) petAutoEquip = v end })
PetsTab:Button({ Title = "Clear Spawned Pets", Justify = "Center", Callback = function() clearAllSpawnedPets() Notify("Pets", "Cleared") end })
if #CATALOG > 0 then
    local petNames = {}
    for _, p in ipairs(CATALOG) do table.insert(petNames, p.display) end
    PetsTab:Dropdown({ Flag = "pet_pick", Title = "Spawn Pet", Values = petNames, Value = petNames[1],
        Callback = function(sel)
            for _, p in ipairs(CATALOG) do if p.display == sel.Title then task.spawn(function() doSpawnPet(p) end) break end end
        end })
end
PetsTab:Section({ Title = "Base / Rewards / Sell", TextSize = 16 })
PetsTab:Toggle({ Flag = "up_base", Title = "Auto Upgrade Base", Default = false, Callback = function(v) autoUpgradeBase = v end })
PetsTab:Toggle({ Flag = "up_tread", Title = "Auto Upgrade Treadmill", Default = false, Callback = function(v) autoUpgradeTreadmill = v end })
PetsTab:Toggle({ Flag = "equip_best", Title = "Auto Equip Best Pets", Default = false, Callback = function(v) autoEquipBestPets = v end })
PetsTab:Toggle({ Flag = "claim_rewards", Title = "Auto Claim Rewards", Default = false, Callback = function(v) autoClaimRewards = v end })
PetsTab:Toggle({ Flag = "buy_trails", Title = "Auto Buy Trails", Default = false, Callback = function(v) autoBuyTrails = v end })
PetsTab:Toggle({ Flag = "sell_low", Title = "Auto Sell Low-Tier Pets", Default = false, Callback = function(v) autoSellPets = v end })

local BaseTab = Section:Tab({ Title = "Base & Events", Icon = "home" })
BaseTab:Button({ Title = "Upgrade Base Now", Justify = "Center", Callback = function() UpgradeHomesteadBase() Notify("Base", "Requested") end })
BaseTab:Button({ Title = "Upgrade Treadmill Now", Justify = "Center", Callback = function() UpgradeTreadmillTier() Notify("Treadmill", "Requested") end })
BaseTab:Button({ Title = "Equip Best Pets Now", Justify = "Center", Callback = function() EquipBestPets() Notify("Pets", "Equipped") end })
BaseTab:Button({ Title = "Claim All Rewards Now", Justify = "Center", Callback = function() ClaimAllAvailableRewards() Notify("Rewards", "Claimed") end })
BaseTab:Button({ Title = "Claim Monster Chest", Justify = "Center", Callback = function() ClaimMonsterChests() Notify("Monster", "Claimed") end })
BaseTab:Button({ Title = "Feed Monster Parasite", Justify = "Center", Callback = function() FeedMonsterParasite() Notify("Monster", "Fed") end })
BaseTab:Button({ Title = "Buy All Affordable Trails", Justify = "Center", Callback = function() BuyAffordableTrails() Notify("Trails", "Purchased") end })
BaseTab:Button({ Title = "Sell Low-Tier Pets", Justify = "Center", Callback = function() SellSelectedPets(nil) Notify("Sell", "Sold") end })
BaseTab:Button({ Title = "Sell Low-Tier Eggs", Justify = "Center", Callback = function() SellSelectedEggs() Notify("Sell", "Sold") end })

local PlayerTab = Section:Tab({ Title = "Player", Icon = "user" })
PlayerTab:Toggle({ Flag = "ws_enabled", Title = "Enable WalkSpeed", Default = false,
    Callback = function(v) walkSpeedEnabled = v if not v then local h = findHum() if h then h.WalkSpeed = 16 end end end })
PlayerTab:Slider({ Flag = "ws_val", Title = "WalkSpeed", Step = 1, Value = { Min = 16, Max = 1000, Default = 24 }, Callback = function(v) walkSpeedVal = v end })
PlayerTab:Toggle({ Flag = "jp_enabled", Title = "Enable JumpPower", Default = false, Callback = function(v) jumpPowerEnabled = v end })
PlayerTab:Slider({ Flag = "jp_val", Title = "JumpPower", Step = 1, Value = { Min = 50, Max = 300, Default = 60 }, Callback = function(v) jumpPowerVal = v end })
PlayerTab:Toggle({ Flag = "inf_jump", Title = "Infinite Jump", Default = false, Callback = function(v) infiniteJump = v end })
PlayerTab:Toggle({ Flag = "fly", Title = "Fly (WASD + Space/Shift)", Default = false, Callback = function(v) if v then startFly() else stopFly() end end })
PlayerTab:Slider({ Flag = "fly_speed", Title = "Fly Speed", Step = 5, Value = { Min = 20, Max = 250, Default = 60 }, Callback = function(v) flySpeed = v end })
PlayerTab:Toggle({ Flag = "anti_afk", Title = "Anti-AFK", Default = false, Callback = function(v) setAntiAFK(v) end })

local CombatTab = Section:Tab({ Title = "Combat", Icon = "sword" })
CombatTab:Toggle({ Flag = "bat_aura", Title = "Bat Aura", Default = false, Callback = function(v) batAuraEnabled = v end })
CombatTab:Slider({ Flag = "bat_radius", Title = "Aura Radius", Step = 1, Value = { Min = 5, Max = 50, Default = 20 }, Callback = function(v) batAuraRadius = v end })
CombatTab:Slider({ Flag = "bat_delay", Title = "Swing Delay", Step = 0.05, Value = { Min = 0.05, Max = 1, Default = 0.2 }, Callback = function(v) batAuraDelay = v end })
CombatTab:Button({ Title = "Swing Bat Now", Justify = "Center",
    Callback = function() local re = GetNetRemote("RE/BatSwing/Trigger") if re then pcall(function() re:FireServer() end) end Notify("Bat", "Swing") end })
CombatTab:Toggle({ Flag = "anti_ragdoll", Title = "Anti-Ragdoll", Default = true, Callback = function(v) antiRagdollEnabled = v end })
CombatTab:Toggle({ Flag = "anti_slide", Title = "Anti-Slide", Default = true,
    Callback = function(v) antiSlideEnabled = v if v and LP.Character then enforceGrip(LP.Character) end end })
CombatTab:Toggle({ Flag = "anti_kb", Title = "Anti-Knockback", Default = true, Callback = function(v) antiKnockbackEnabled = v end })
CombatTab:Toggle({ Flag = "avoid_traps", Title = "Anti-Trap", Default = true, Callback = function(v) avoidTrapsEnabled = v if v then pcall(NeutralizeTraps) end end })

local TravelTab = Section:Tab({ Title = "Travel", Icon = "move" })
local selectedAreaTP = "Base / Plot"
local areaKeys = {}
for k in pairs(AREA_COORDINATES) do table.insert(areaKeys, k) end
table.sort(areaKeys)
TravelTab:Dropdown({ Flag = "tp_area", Title = "Area", Values = areaKeys, Value = "Base / Plot", Callback = function(s) selectedAreaTP = s.Title end })
TravelTab:Button({ Title = "Travel to Area", Justify = "Center",
    Callback = function()
        local pos = AREA_COORDINATES[selectedAreaTP]
        if pos then Notify("Travel", "To " .. selectedAreaTP) TravelRoadPath(pos, glideSpeed) Notify("Travel", "Arrived") end
    end })
local selectedPlotNum = "My Plot"
local plotOptions = { "Plot 1","Plot 2","Plot 3","Plot 4","Plot 5","Plot 6","Plot 7","My Plot" }
TravelTab:Dropdown({ Flag = "tp_plot", Title = "Plot", Values = plotOptions, Value = "My Plot", Callback = function(s) selectedPlotNum = s.Title end })
TravelTab:Button({ Title = "Travel to Plot", Justify = "Center",
    Callback = function()
        local slotNum = selectedPlotNum == "My Plot" and 1 or tonumber(selectedPlotNum:match("%d+")) or 1
        local plotsFolder = Workspace:FindFirstChild("Plots")
        local plot = plotsFolder and plotsFolder:FindFirstChild(tostring(slotNum))
        if plot then
            local center = plot:FindFirstChild("CenterPoint")
            local targetPos = center and center.Position or plot:GetPivot().Position
            TravelRoadPath(targetPos + Vector3.new(0, 2, 0), glideSpeed)
            Notify("Plot", "Arrived Plot " .. slotNum)
        end
    end })
local selectedPlayerName
TravelTab:Dropdown({ Flag = "tp_plr", Title = "Player",
    Values = (function() local n = {} for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then table.insert(n, p.Name) end end return n end)(),
    Value = nil, Callback = function(s) selectedPlayerName = s.Title end })
TravelTab:Button({ Title = "Travel to Player", Justify = "Center",
    Callback = function()
        if not selectedPlayerName then return end
        local p = Players:FindFirstChild(selectedPlayerName)
        local hrp = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if hrp then TravelRoadPath(hrp.Position + Vector3.new(0, 2, 0), glideSpeed) Notify("Travel", "Arrived at " .. selectedPlayerName) end
    end })
TravelTab:Section({ Title = "Waypoints", TextSize = 16 })
local wpInput = "Waypoint"
TravelTab:Input({ Flag = "wp_name", Title = "Waypoint Name", Placeholder = "Name", Callback = function(v) wpInput = v end })
TravelTab:Button({ Title = "Save Current Waypoint", Justify = "Center",
    Callback = function()
        local r = findHRP()
        if r then addWaypoint(wpInput ~= "" and wpInput or ("WP " .. (#waypoints + 1)), r.CFrame, r.Position) Notify("Waypoint", "Saved: " .. wpInput) end
    end })
for i, wp in ipairs(waypoints) do
    TravelTab:Button({ Title = wp.name .. " (" .. string.format("%.0f,%.0f,%.0f", wp.position.X, wp.position.Y, wp.position.Z) .. ")", Justify = "Center", Callback = function() teleportToWaypoint(i) end })
end

local HookTab = Section:Tab({ Title = "Auto Hook", Icon = "anchor" })
HookTab:Toggle({ Flag = "hook_v1", Title = "Auto Hook v1 (Base drop)", Default = false, Callback = function(v) hookV1Enabled = v if v then hookV2Enabled = false end end })
HookTab:Toggle({ Flag = "hook_v2", Title = "Auto Hook v2 (Forest drop)", Default = false, Callback = function(v) hookV2Enabled = v if v then hookV1Enabled = false end end })
HookTab:Slider({ Flag = "hook_delay", Title = "Hook Delay", Step = 0.05, Value = { Min = 0, Max = 1, Default = 0.1 }, Callback = function(v) HookDelay = v end })
HookTab:Slider({ Flag = "drop_delay", Title = "Drop Egg Delay", Step = 0.05, Value = { Min = 0, Max = 1, Default = 0.2 }, Callback = function(v) DropEggDelay = v end })
HookTab:Input({ Flag = "base_drop_x", Title = "Base Drop X", Value = tostring(BaseDropPosition.X),
    Callback = function(v) BaseDropPosition = Vector3.new(tonumber(v) or BaseDropPosition.X, BaseDropPosition.Y, BaseDropPosition.Z) end })

local PerfTab = Section:Tab({ Title = "Performance", Icon = "zap" })
PerfTab:Toggle({ Flag = "fps_boost", Title = "FPS Booster", Default = false, Callback = function(v) toggleFpsBooster(v) end })
PerfTab:Button({ Title = "Fullbright ON", Justify = "Center", Callback = function() setFullbright(true) Notify("Visual", "Fullbright ON") end })
PerfTab:Button({ Title = "Fullbright OFF", Justify = "Center", Callback = function() setFullbright(false) Notify("Visual", "Fullbright OFF") end })
PerfTab:Button({ Title = "Delete Own Pet Renders", Justify = "Center", Callback = function() local c = DeleteOwnPetRenders() Notify("Perf", c .. " removed") end })

local EspTab = Section:Tab({ Title = "ESP", Icon = "eye" })
EspTab:Toggle({ Flag = "esp_eggs", Title = "Egg ESP", Default = false, Callback = function(v) esp.enabled = v end })
EspTab:Toggle({ Flag = "esp_pet_icons", Title = "Show Pet Icon Badges", Default = true, Callback = function(v) esp.showPetIcons = v end })
EspTab:Toggle({ Flag = "esp_traps", Title = "Trap ESP", Default = false, Callback = function(v) esp.traps = v end })
EspTab:Toggle({ Flag = "esp_players", Title = "Player ESP", Default = false, Callback = function(v) esp.players = v end })
EspTab:Toggle({ Flag = "esp_rare_only", Title = "Rare Eggs Only", Default = false, Callback = function(v) esp.rareEggsOnly = v end })
EspTab:Slider({ Flag = "esp_dist", Title = "Max Distance", Step = 50, Value = { Min = 100, Max = 2500, Default = 800 }, Callback = function(v) esp.maxDistance = v end })

local ServerTab = Section:Tab({ Title = "Server", Icon = "globe" })
local hopThreshold = 1
ServerTab:Input({ Flag = "hop_max", Title = "Max Players", Value = "1", Callback = function(v) hopThreshold = tonumber(v) or 1 end })
ServerTab:Button({ Title = "Hop Now", Justify = "Center",
    Callback = function() local ok, err = hopOnce(hopThreshold) Notify("Hop", ok and "Teleporting..." or ("Failed: " .. tostring(err))) end })
ServerTab:Button({ Title = "Find Low Server", Justify = "Center",
    Callback = function()
        task.spawn(function()
            local target = findLowServer()
            if target then
                Notify("Server", "Joining low server...")
                pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, LP) end)
            else
                Notify("Server", "No server found")
            end
        end)
    end })
ServerTab:Toggle({ Flag = "hop_auto", Title = "Auto Hop", Default = false,
    Callback = function(v)
        hopAutoEnabled = v
        if v then
            if hopAutoThread then task.cancel(hopAutoThread) end
            hopAutoThread = task.spawn(function()
                while hopAutoEnabled and not HUB.dead do
                    local c = #Players:GetPlayers()
                    if c <= hopThreshold then task.wait(3) else hopOnce(hopThreshold) task.wait(5) end
                end
            end)
        else
            if hopAutoThread then pcall(task.cancel, hopAutoThread) hopAutoThread = nil end
        end
    end })

local SettingsTab = Section:Tab({ Title = "Settings", Icon = "settings" })
SettingsTab:Keybind({ Flag = "ui_key", Title = "Toggle UI Key", Value = "RightControl", Callback = function(k) pcall(function() Window:SetToggleKey(Enum.KeyCode[k]) end) end })
SettingsTab:Button({ Title = "Unload Yuno Hub", Justify = "Center", Callback = function() pcall(function() HUB.Unload() end) end })
SettingsTab:Section({ Title = "Yuno Hub by Halil Tasty | Merged 6 scripts", TextSize = 13 })

HUB.Unload = function()
    HUB.dead = true
    stopFly()
    setFullbright(false)
    clearAllSpawnedPet = nil
    pcall(clearAllSpawnedPets)
    stopCurrentWalking(false)
    if _G.YunoFpsConn then pcall(function() _G.YunoFpsConn:Disconnect() end) _G.YunoFpsConn = nil end
    for _, c in ipairs(HUB.conns) do pcall(function() c:Disconnect() end) end
    HUB.conns = {}
    for _, d in ipairs(HUB.drawings) do pcall(function() d:Remove() end) end
    HUB.drawings = {}
    local hum = findHum()
    if hum then
        hum.PlatformStand = false
        hum.WalkSpeed = 16
        hum.JumpPower = 50
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    end
    pcall(function() if Window then Window:Destroy() end end)
    _G.YunoHub = nil
end

Notify("Yuno Hub", "by Halil Tasty — loaded ✓", "Success", 3.5)