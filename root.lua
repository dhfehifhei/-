-- ==========================================================
--  MellHack // @ruzoxu  |  Delta Mobile Edition
-- ==========================================================

local function safeLog(msg, extra)
    pcall(function()
        warn("[MellHack] " .. tostring(msg) .. (extra and (" " .. tostring(extra)) or ""))
    end)
end

local function httpGet(url)
    local ok, body = pcall(function()
        if syn and syn.request then
            return syn.request({ Url = url, Method = "GET" }).Body
        elseif http_request then
            return http_request({ Url = url, Method = "GET" }).Body
        elseif request then
            return request({ Url = url, Method = "GET" }).Body
        elseif game.HttpGet then
            return game:HttpGet(url)
        end
    end)
    if ok and body and #body > 500 then return body end
    return nil
end

local CoreGui          = game:GetService("CoreGui")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local Workspace        = game:GetService("Workspace")
local TweenService     = game:GetService("TweenService")
local TextChatService  = game:GetService("TextChatService")
local HttpService      = game:GetService("HttpService")
local StarterGui       = game:GetService("StarterGui")
local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()
local Camera           = Workspace.CurrentCamera

pcall(function()
    for _, v in pairs(getconnections(LocalPlayer.Idled)) do v:Disable() end
end)

if getgenv().MellHackLoaded then
    pcall(function() getgenv().MellHackUnload() end)
end
getgenv().MellHackLoaded = true

local Connections      = {}
local ObjectsToCleanup = {}

local function trackConn(c) table.insert(Connections, c) return c end
local function trackObj(o)  table.insert(ObjectsToCleanup, o) return o end

local function getRoot(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso") or char:FindFirstChild("RootPart")
end
local function getHumanoid(char)
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end
local function getHead(char)
    if not char then return nil end
    return char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso")
end
local function r15(plr)
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildOfClass('Humanoid')
        if hum then return hum.RigType == Enum.HumanoidRigType.R15 end
    end
    return false
end

-- ==========================================================
--  WindUI
-- ==========================================================
local WindUI = getgenv().WindUI_Cache
if not WindUI then
    local src
    for _, url in ipairs({
        "https://cdn.jsdelivr.net/gh/Footagesus/WindUI@main/dist/main.lua",
        "https://raw.githack.com/Footagesus/WindUI/main/dist/main.lua",
        "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua",
    }) do
        src = httpGet(url)
        if src then safeLog("WindUI downloaded from " .. url); break end
    end
    if not src then
        safeLog("WindUI download failed")
        StarterGui:SetCore("SendNotification", {
            Title = "MellHack", Text = "WindUI download failed", Duration = 8,
        })
        return
    end
    local fn, err = loadstring(src)
    if not fn then safeLog("loadstring err", err); return end
    local ok, res = pcall(fn)
    if not ok or not res then safeLog("WindUI init err", res); return end
    WindUI = res
    getgenv().WindUI_Cache = WindUI
end

-- ==========================================================
--  Window
-- ==========================================================
local Window = WindUI:CreateWindow({
    Title    = "MellHack",
    Author   = "@ruzoxu",
    Icon     = "rbxassetid://120997033468887",
    Size     = UDim2.fromOffset(580, 440),
    MinSize  = Vector2.new(460, 360),
    MaxSize  = Vector2.new(950, 680),
    Transparent = true,
    Acrylic  = false,
    Theme    = "Dark",
    User     = { Enabled = false, Anonymous = true, Callback = function() end },
    Topbar   = { Height = 52, ButtonsType = "Default" },
    Resizable = true,
    HideSearchBar = true,
    ScrollBarEnabled = true,
    NewElements = true,
    IgnoreAlerts = true,
})

-- ==========================================================
--  Settings
-- ==========================================================
local Settings = {
    Fly = false, FlySpeed = 127,
    Speed = false, WalkSpeedVal = 80,
    Jump = false, JumpPowerVal = 250,
    Bhop = false, Strafes = false, StrafeSpeed = 35,
    PixelSurf = false, InfiniteJump = false, Noclip = false,
    LongJump = false, SuperGlide = false, WallHop = false,
    AirBoost = false, EdgeBug = false,
    WallClimb = false, NoFallDamage = false, AutoRespawn = false,

    Aimbot = false, SilentAim = false, WallCheck = true,
    CamLock = false, TeamCheck = true, AimFOV = 350,
    AimSmooth = 4, DrawFOV = true, AimPart = "Head",
    AimPrediction = 0.15, AimHitChance = 100,
    Triggerbot = false, TriggerbotDelay = 0.05,
    TriggerbotFOV = 150, TriggerbotWallCheck = true,
    Autoclicker = false, AutoclickerCPS = 15,
    Killaura = false, KillauraRange = 20,
    HitboxExpander = false, HitboxSize = 8,

    ESPBox = true, HPBar = true, Tracers = true,
    SkeletonESP = true, NameESP = true, Chams = true,
    Crosshair = false, BulletTracers = false,
    TeamESP = true, Watermark = true,

    ColorMenu         = Color3.fromRGB(255, 40, 90),
    ColorWindow       = Color3.fromRGB(16, 16, 22),
    ColorPanel        = Color3.fromRGB(12, 12, 16),
    ColorText         = Color3.fromRGB(240, 238, 245),
    ColorSubText      = Color3.fromRGB(140, 135, 155),

    ColorBox          = Color3.fromRGB(255, 40, 90),
    ColorTracer       = Color3.fromRGB(255, 40, 90),
    ColorSkeleton     = Color3.fromRGB(255, 255, 255),
    ColorName         = Color3.fromRGB(255, 255, 255),
    ColorHPFull       = Color3.fromRGB(0, 255, 80),
    ColorHPEmpty      = Color3.fromRGB(0, 0, 0),
    ColorFOV          = Color3.fromRGB(255, 40, 90),
    ColorCrosshair    = Color3.fromRGB(255, 255, 255),
    ColorBulletTracer = Color3.fromRGB(255, 200, 0),

    ColorChams        = Color3.fromRGB(255, 40, 90),
    ColorChamsOutline = Color3.fromRGB(255, 255, 255),

    AlphaMenu         = 0.15,
    AlphaWindow       = 0.15,
    AlphaPanel        = 0.15,
    AlphaText         = 0.0,
    AlphaSubText      = 0.0,

    AlphaBox          = 0.0,
    AlphaTracer       = 0.0,
    AlphaSkeleton     = 0.0,
    AlphaName         = 0.0,
    AlphaHPFull       = 0.0,
    AlphaHPEmpty      = 0.0,
    AlphaFOV          = 0.2,
    AlphaCrosshair    = 0.0,
    AlphaBulletTracer = 0.0,

    AlphaChams        = 0.5,
    AlphaChamsOutline = 0.0,

    Fullbright = false, Xray = false, SkyColor = {135,206,235},
    CustomFog = false, FogColor = {200,200,200}, FogEnd = 500,

    Invisible = false, Godmode = false, SpinBot = false,
    SpinSpeed = 1000, AntiAim = false, AntiAimMode = "Spin",
    YawOffset = 0, HideHead = false, JitterRange = 45,
    BodyShake = false,
    Freecam = false, FreecamSpeed = 50, Earthquake = false,
    ClickTeleport = false, ChatFlood = false,
    FloodText = "MellHack by @ruzoxu", FloodDelay = 1,
    AutoHeal = false,

    FOVChanger = false, CustomFOV = 90,
    Jerk = false, Bang = false, Fling = false, AntiFling = false,
}

-- ==========================================================
--  Apply colors to WindUI theme
-- ==========================================================
local function ApplyMenuColorsToTheme()
    if not WindUI or not WindUI.Themes then return end
    for _, key in ipairs({"Dark", "Light"}) do
        local t = WindUI.Themes[key]
        if t then
            t.Accent = Settings.ColorMenu
            t.Primary = Settings.ColorMenu
            t.Button = Settings.ColorMenu
            t.Slider = Settings.ColorMenu
            t.Toggle = Settings.ColorMenu
            t.Checkbox = Settings.ColorMenu
            t.WindowBackground = Settings.ColorWindow
            t.Background = Settings.ColorWindow
            t.PanelBackground = Settings.ColorPanel
            t.TabBackground = Settings.ColorPanel
            t.TabBackgroundActive = Settings.ColorPanel
            t.Text = Settings.ColorText
            t.Placeholder = Settings.ColorSubText
            t.Icon = Settings.ColorSubText
            t.BackgroundTransparency = Settings.AlphaWindow
            t.PanelBackgroundTransparency = Settings.AlphaPanel
            t.TabBackgroundActiveTransparency = Settings.AlphaPanel
            t.TabBackgroundHoverTransparency = math.clamp(Settings.AlphaPanel + 0.05, 0, 1)
            t.WindowBackgroundTransparency = Settings.AlphaWindow
        end
    end
    if WindUI.Creator and WindUI.Creator.UpdateTheme then
        pcall(function() WindUI.Creator.UpdateTheme(nil, false, false) end)
    end
end

-- ==========================================================
--  ESP / Crosshair / Watermark / BulletTracers GUI
-- ==========================================================
local gethuiFn = gethui or function()
    return (RunService:IsStudio() and LocalPlayer:WaitForChild("PlayerGui")) or CoreGui
end
local ParentGui
pcall(function() ParentGui = gethuiFn() end)
if not ParentGui then ParentGui = CoreGui end

local ESPGui = trackObj(Instance.new("ScreenGui"))
ESPGui.Name = "MellHack_ESP"
ESPGui.ResetOnSpawn = false
ESPGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ESPGui.IgnoreGuiInset = true
ESPGui.Parent = ParentGui

local function newFrame(props)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    f.BackgroundColor3 = Color3.new(1,1,1)
    if props then for k,v in pairs(props) do f[k] = v end end
    return trackObj(f)
end
local function newStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.new(1,1,1)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

-- ==========================================================
--  ESP
-- ==========================================================
local ESPCache = {}
local function ensureESP(player)
    if ESPCache[player] then return ESPCache[player] end
    local data = {}

    data.Billboard = Instance.new("BillboardGui")
    data.Billboard.Name = "MellESP_" .. player.Name
    data.Billboard.AlwaysOnTop = true
    data.Billboard.LightInfluence = 0
    data.Billboard.Size = UDim2.fromOffset(0, 0)
    data.Billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
    data.Billboard.Parent = ESPGui
    trackObj(data.Billboard)

    data.BoxFrame = newFrame({
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = data.Billboard,
    })
    data.BoxStroke = newStroke(data.BoxFrame, Settings.ColorBox, 1.5, Settings.AlphaBox)

    data.NameLabel = Instance.new("TextLabel")
    data.NameLabel.BackgroundTransparency = 1
    data.NameLabel.Size = UDim2.new(1, 0, 0, 16)
    data.NameLabel.Position = UDim2.new(0, 0, 0, -18)
    data.NameLabel.Font = Enum.Font.GothamBold
    data.NameLabel.TextSize = 13
    data.NameLabel.TextColor3 = Settings.ColorName
    data.NameLabel.TextTransparency = Settings.AlphaName
    data.NameLabel.TextStrokeTransparency = 0.4
    data.NameLabel.Text = ""
    data.NameLabel.Visible = false
    data.NameLabel.Parent = data.Billboard
    trackObj(data.NameLabel)

    data.HPBarBack = newFrame({
        Size = UDim2.new(0, 3, 1, 0),
        Position = UDim2.new(1, 4, 0, 0),
        BackgroundColor3 = Settings.ColorHPEmpty,
        BackgroundTransparency = Settings.AlphaHPEmpty,
        Parent = data.Billboard,
    })
    data.HPBarFill = newFrame({
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Settings.ColorHPFull,
        BackgroundTransparency = Settings.AlphaHPFull,
        Parent = data.HPBarBack,
    })

    ESPCache[player] = data
    return data
end

local function destroyESP(player)
    local d = ESPCache[player]
    if d and d.Billboard then d.Billboard:Destroy() end
    ESPCache[player] = nil
end
trackConn(Players.PlayerRemoving:Connect(destroyESP))

-- ==========================================================
--  Tracers
-- ==========================================================
local TracerCache = {}
local function ensureTracer(player)
    if TracerCache[player] then return TracerCache[player] end
    local line = newFrame({
        BackgroundTransparency = Settings.AlphaTracer,
        BackgroundColor3 = Settings.ColorTracer,
        Size = UDim2.new(0, 1, 0, 1),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = ESPGui,
        Visible = false,
    })
    TracerCache[player] = { Frame = line }
    return TracerCache[player]
end
local function destroyTracer(player)
    local t = TracerCache[player]
    if t and t.Frame then t.Frame:Destroy() end
    TracerCache[player] = nil
end
trackConn(Players.PlayerRemoving:Connect(destroyTracer))

-- ==========================================================
--  SkeletonESP
-- ==========================================================
local SkeletonCache = {}
local function ensureSkeleton(player)
    if SkeletonCache[player] then return SkeletonCache[player] end
    local bones = {}
    for i = 1, 6 do
        local line = newFrame({
            BackgroundTransparency = Settings.AlphaSkeleton,
            BackgroundColor3 = Settings.ColorSkeleton,
            Size = UDim2.new(0, 1, 0, 1),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Parent = ESPGui,
            Visible = false,
        })
        bones[i] = line
    end
    SkeletonCache[player] = bones
    return bones
end
local function destroySkeleton(player)
    local b = SkeletonCache[player]
    if b then for _, l in ipairs(b) do l:Destroy() end end
    SkeletonCache[player] = nil
end
trackConn(Players.PlayerRemoving:Connect(destroySkeleton))

local function drawLine(frame, fromPos, toPos, color, transparency)
    if not frame then return end
    if not fromPos or not toPos then frame.Visible = false; return end
    local delta = toPos - fromPos
    local length = delta.Magnitude
    if length < 1 then frame.Visible = false; return end
    local center = (fromPos + toPos) / 2
    local angle = math.deg(math.atan2(delta.Y, delta.X))
    frame.Visible = true
    frame.Position = UDim2.fromOffset(center.X, center.Y)
    frame.Size = UDim2.fromOffset(length, 1.5)
    frame.Rotation = angle
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = transparency
end

-- ==========================================================
--  Crosshair
-- ==========================================================
local crosshairParts = {}
for i = 1, 4 do
    crosshairParts[i] = newFrame({
        BackgroundTransparency = Settings.AlphaCrosshair,
        BackgroundColor3 = Settings.ColorCrosshair,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = ESPGui,
        Visible = false,
    })
end

-- ==========================================================
--  Watermark
-- ==========================================================
local watermarkLabel = Instance.new("TextLabel")
watermarkLabel.Name = "MellWatermark"
watermarkLabel.BackgroundTransparency = 1
watermarkLabel.Size = UDim2.fromOffset(400, 24)
watermarkLabel.Position = UDim2.fromOffset(20, 20)
watermarkLabel.Font = Enum.Font.GothamBold
watermarkLabel.TextSize = 15
watermarkLabel.TextColor3 = Color3.fromRGB(255,255,255)
watermarkLabel.TextStrokeTransparency = 0.4
watermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
watermarkLabel.Text = "MellHack | @ruzoxu"
watermarkLabel.Parent = ESPGui
trackObj(watermarkLabel)

local fpsCounter = { count = 0, last = tick(), fps = 0 }
trackConn(RunService.RenderStepped:Connect(function()
    fpsCounter.count = fpsCounter.count + 1
    local now = tick()
    if now - fpsCounter.last >= 1 then
        fpsCounter.fps = fpsCounter.count
        fpsCounter.count = 0
        fpsCounter.last = now
    end
end))

trackConn(RunService.RenderStepped:Connect(function()
    watermarkLabel.Visible = Settings.Watermark
    if Settings.Watermark then
        local server = Players:GetPlayers()
        watermarkLabel.Text = string.format("MellHack | %s | %d FPS | %d players",
            LocalPlayer.Name, fpsCounter.fps, #server)
        watermarkLabel.TextColor3 = Settings.ColorText
    end
end))

-- ==========================================================
--  BulletTracers
-- ==========================================================
local bulletTracers = {}
local function spawnBulletTracer(fromPos, toPos)
    local line = newFrame({
        BackgroundTransparency = Settings.AlphaBulletTracer,
        BackgroundColor3 = Settings.ColorBulletTracer,
        Parent = ESPGui,
    })
    local fromScreen = Camera:WorldToViewportPoint(fromPos)
    local toScreen   = Camera:WorldToViewportPoint(toPos)
    local delta = Vector2.new(toScreen.X - fromScreen.X, toScreen.Y - fromScreen.Y)
    local length = delta.Magnitude
    local center = Vector2.new((fromScreen.X + toScreen.X)/2, (fromScreen.Y + toScreen.Y)/2)
    line.Position = UDim2.fromOffset(center.X, center.Y)
    line.Size = UDim2.fromOffset(length, 2)
    line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    table.insert(bulletTracers, {Frame = line, Birth = tick()})
end

trackConn(RunService.RenderStepped:Connect(function()
    for i = #bulletTracers, 1, -1 do
        local t = bulletTracers[i]
        local age = tick() - t.Birth
        if age > 1 then
            t.Frame:Destroy()
            table.remove(bulletTracers, i)
        else
            t.Frame.BackgroundTransparency = math.clamp(Settings.AlphaBulletTracer + age, 0, 1)
        end
    end
end))

local function onToolActivated()
    if not Settings.BulletTracers then return end
    local char = LocalPlayer.Character
    local hrp = getRoot(char)
    if not hrp then return end
    local fromPos = hrp.Position + Vector3.new(0, 1, 0)
    local targetPos = nil
    local minDst = 9999
    local mousePos = UserInputService:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = getHead(p.Character)
            if h then
                local sp, onScreen = Camera:WorldToViewportPoint(h.Position)
                if onScreen then
                    local d = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                    if d < minDst then minDst = d; targetPos = h.Position end
                end
            end
        end
    end
    if not targetPos then
        targetPos = Camera.CFrame.Position + Camera.CFrame.LookVector * 100
    end
    spawnBulletTracer(fromPos, targetPos)
end

trackConn(LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            child.Activated:Connect(onToolActivated)
        end
    end)
    for _, c in pairs(char:GetChildren()) do
        if c:IsA("Tool") then c.Activated:Connect(onToolActivated) end
    end
end))
if LocalPlayer.Character then
    for _, c in pairs(LocalPlayer.Character:GetChildren()) do
        if c:IsA("Tool") then c.Activated:Connect(onToolActivated) end
    end
end
trackConn(LocalPlayer.Backpack.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        child.Activated:Connect(onToolActivated)
    end
end))

-- ==========================================================
--  Fly
-- ==========================================================
local ControlModule
pcall(function()
    ControlModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
end)

local function initFlyObjects()
    pcall(function()
        if _G.fly_rp then _G.fly_rp:Destroy() end
        if _G.fly_bg then _G.fly_bg:Destroy() end
    end)
    local ch = LocalPlayer.Character
    if not ch then return end
    local hum  = getHumanoid(ch)
    local root = getRoot(ch)
    if not hum or not root then return end

    local rp_h = 1e4
    _G.fly_bg = Instance.new('BodyGyro', root)
    _G.fly_rp = Instance.new('RocketPropulsion', root)
    local md = Instance.new('Model')
    _G.fly_pt = Instance.new('Part', md)
    _G.fly_rp.MaxTorque = Vector3.new(rp_h, rp_h, rp_h)
    _G.fly_bg.MaxTorque = Vector3.new()
    md.PrimaryPart = _G.fly_pt
    _G.fly_pt.Anchored = true
    _G.fly_pt.CanCollide = false
    _G.fly_rp.CartoonFactor = 1
    _G.fly_rp.Target = _G.fly_pt
    _G.fly_rp.MaxSpeed = Settings.FlySpeed
    _G.fly_rp.MaxThrust = 5e5
    _G.fly_rp.ThrustP = 1e5
    _G.fly_rp.ThrustD = math.huge
    _G.fly_rp.TurnP = 1e5
    _G.fly_rp.TurnD = 2e2
    _G.fly_bg.P = 3e4
end
trackConn(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1); initFlyObjects()
end))
initFlyObjects()

trackConn(RunService.RenderStepped:Connect(function()
    if not _G.fly_rp or not getgenv().MellHackLoaded then return end
    local char = LocalPlayer.Character
    local root = getRoot(char)
    local hum  = getHumanoid(char)
    if not char or not root or not hum then return end

    local moveVec = Vector3.new()
    if ControlModule then moveVec = ControlModule:GetMoveVector() end
    local kb = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then kb += Vector3.new(0,0,-1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then kb += Vector3.new(0,0,1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then kb += Vector3.new(-1,0,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then kb += Vector3.new(1,0,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then kb += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then kb += Vector3.new(0,-1,0) end
    local finalMove = (kb.Magnitude > 0) and kb or moveVec

    if Settings.Fly then
        hum.AutoRotate = false
        hum.PlatformStand = true
        _G.fly_bg.MaxTorque = Vector3.new(3e4, 3e4, 3e4)
        _G.fly_rp.MaxTorque = Vector3.new(1e4, 1e4, 1e4)
        if finalMove.Magnitude > 0 then
            pcall(function() _G.fly_rp:Fire() end)
            local camCF = Camera.CFrame
            local targetDir = (camCF.RightVector * finalMove.X)
                          - (camCF.LookVector  * finalMove.Z)
                          + Vector3.new(0, finalMove.Y * 2, 0)
            _G.fly_pt.Position = root.Position + (targetDir * 1000)
            _G.fly_bg.CFrame = Camera.CFrame
        else
            pcall(function() _G.fly_rp:Abort() end)
            root.Velocity = Vector3.new(0,0,0)
        end
    else
        hum.AutoRotate = true
        hum.PlatformStand = false
        _G.fly_bg.MaxTorque = Vector3.new()
        _G.fly_rp.MaxTorque = Vector3.new()
        pcall(function() _G.fly_rp:Abort() end)
    end
end))

-- ==========================================================
--  Config
-- ==========================================================
local CONFIG_DIR = "MellHack"
local CONFIG_FILE = CONFIG_DIR .. "/config.json"

local function saveConfig()
    if not writefile then
        WindUI:Notify({ Title = "MellHack", Content = "writefile unavailable", Icon = "x", Duration = 4 })
        return
    end
    if not isfolder(CONFIG_DIR) then makefolder(CONFIG_DIR) end
    local clean = {}
    for k, v in pairs(Settings) do
        if typeof(v) == "Color3" then
            clean[k] = {__color = true, r = v.R, g = v.G, b = v.B}
        else
            clean[k] = v
        end
    end
    local ok, json = pcall(function() return HttpService:JSONEncode(clean) end)
    if ok then
        writefile(CONFIG_FILE, json)
        WindUI:Notify({ Title = "MellHack", Content = "Config saved", Icon = "check", Duration = 3 })
    end
end

local function loadConfig()
    if not (isfile and readfile) then return end
    if not isfile(CONFIG_FILE) then
        WindUI:Notify({ Title = "MellHack", Content = "Config not found", Icon = "x", Duration = 3 })
        return
    end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(CONFIG_FILE))
    end)
    if not ok or not data then
        WindUI:Notify({ Title = "MellHack", Content = "Config read failed", Icon = "x", Duration = 3 })
        return
    end
    for k, v in pairs(data) do
        if type(v) == "table" and v.__color then
            Settings[k] = Color3.new(v.r, v.g, v.b)
        else
            Settings[k] = v
        end
    end
    ApplyMenuColorsToTheme()
    WindUI:Notify({ Title = "MellHack", Content = "Config loaded", Icon = "check", Duration = 3 })
end

local function resetConfig()
    local defaults = {
        FlySpeed = 127, WalkSpeedVal = 80, JumpPowerVal = 250,
        AimFOV = 350, AimSmooth = 4, AimPrediction = 0.15, AimHitChance = 100,
        TriggerbotFOV = 150, TriggerbotDelay = 0.05,
        AutoclickerCPS = 15, KillauraRange = 20, HitboxSize = 8,
        StrafeSpeed = 35, FreecamSpeed = 50, SpinSpeed = 1000,
        JitterRange = 45, YawOffset = 0, FogEnd = 500, CustomFOV = 90,
        ColorMenu = Color3.fromRGB(255, 40, 90),
        ColorBox = Color3.fromRGB(255, 40, 90),
        ColorTracer = Color3.fromRGB(255, 40, 90),
        ColorSkeleton = Color3.fromRGB(255, 255, 255),
        ColorName = Color3.fromRGB(255, 255, 255),
        ColorHPFull = Color3.fromRGB(0, 255, 80),
        ColorHPEmpty = Color3.fromRGB(0, 0, 0),
        ColorFOV = Color3.fromRGB(255, 40, 90),
        ColorCrosshair = Color3.fromRGB(255, 255, 255),
        ColorBulletTracer = Color3.fromRGB(255, 200, 0),
        ColorChams = Color3.fromRGB(255, 40, 90),
        ColorChamsOutline = Color3.fromRGB(255, 255, 255),
        AlphaBox = 0.0, AlphaTracer = 0.0, AlphaSkeleton = 0.0,
        AlphaName = 0.0, AlphaHPFull = 0.0, AlphaHPEmpty = 0.0,
        AlphaFOV = 0.2, AlphaCrosshair = 0.0, AlphaBulletTracer = 0.0,
        AlphaChams = 0.5, AlphaChamsOutline = 0.0,
    }
    for k, v in pairs(defaults) do Settings[k] = v end
    ApplyMenuColorsToTheme()
    WindUI:Notify({ Title = "MellHack", Content = "Settings reset", Icon = "check", Duration = 3 })
end

local function notifyState(name, enabled)
    WindUI:Notify({
        Title = "MellHack",
        Content = name .. (enabled and " ON" or " OFF"),
        Icon = enabled and "check" or "x",
        Duration = 2,
    })
end

-- ==========================================================
--  Tabs
-- ==========================================================
local TabMovement = Window:Tab({ Title = "Movement",   Icon = "move" })
local TabCombat   = Window:Tab({ Title = "Combat",     Icon = "crosshair" })
local TabVisuals  = Window:Tab({ Title = "Visuals",    Icon = "eye" })
local TabColors   = Window:Tab({ Title = "Colors",     Icon = "palette" })
local TabExtras   = Window:Tab({ Title = "Extras",     Icon = "sparkles" })
local TabShaders  = Window:Tab({ Title = "Shaders",    Icon = "sun" })
local TabRage     = Window:Tab({ Title = "Rage & Fun", Icon = "bomb" })
local TabBinds    = Window:Tab({ Title = "Keybinds",   Icon = "keyboard" })
local TabSettings = Window:Tab({ Title = "Settings",   Icon = "settings" })

-- ==========================================================
--  Movement
-- ==========================================================
TabMovement:Section({ Title = "Character Physics" })
TabMovement:Toggle({ Title = "Fly", Value = false, Callback = function(v)
    Settings.Fly = v; notifyState("Fly", v)
end })
TabMovement:Slider({ Title = "Fly Speed", Value = { Min = 10, Max = 300, Default = 127 },
    Callback = function(v) Settings.FlySpeed = v; if _G.fly_rp then _G.fly_rp.MaxSpeed = v end end })
TabMovement:Toggle({ Title = "SpeedHack", Value = false,
    Callback = function(v)
        Settings.Speed = v; notifyState("SpeedHack", v)
        if not v and LocalPlayer.Character then
            local hum = getHumanoid(LocalPlayer.Character)
            if hum then hum.WalkSpeed = 16 end
        end
    end })
TabMovement:Slider({ Title = "WalkSpeed", Value = { Min = 16, Max = 400, Default = 80 },
    Callback = function(v) Settings.WalkSpeedVal = v end })
TabMovement:Toggle({ Title = "Super Jump", Value = false,
    Callback = function(v)
        Settings.Jump = v; notifyState("Super Jump", v)
        if not v and LocalPlayer.Character then
            local hum = getHumanoid(LocalPlayer.Character)
            if hum then hum.JumpPower = 50 end
        end
    end })
TabMovement:Slider({ Title = "Jump Height", Value = { Min = 50, Max = 800, Default = 250 },
    Callback = function(v) Settings.JumpPowerVal = v end })

TabMovement:Section({ Title = "Advanced Movement" })
TabMovement:Toggle({ Title = "Auto-Bhop", Value = false, Callback = function(v) Settings.Bhop = v; notifyState("Bhop", v) end })
TabMovement:Toggle({ Title = "Air Strafes", Value = false, Callback = function(v) Settings.Strafes = v; notifyState("Strafes", v) end })
TabMovement:Slider({ Title = "Strafe Speed", Value = { Min = 10, Max = 100, Default = 35 }, Callback = function(v) Settings.StrafeSpeed = v end })
TabMovement:Toggle({ Title = "Pixel Surf", Value = false, Callback = function(v) Settings.PixelSurf = v end })
TabMovement:Toggle({ Title = "Long Jump", Value = false, Callback = function(v) Settings.LongJump = v end })
TabMovement:Toggle({ Title = "Super Glide", Value = false, Callback = function(v) Settings.SuperGlide = v end })
TabMovement:Toggle({ Title = "Wall Hop", Value = false, Callback = function(v) Settings.WallHop = v end })
TabMovement:Toggle({ Title = "Wall Climb", Value = false, Callback = function(v) Settings.WallClimb = v end })
TabMovement:Toggle({ Title = "Air Boost", Value = false, Callback = function(v) Settings.AirBoost = v end })
TabMovement:Toggle({ Title = "Edge Bug", Value = false, Callback = function(v) Settings.EdgeBug = v end })
TabMovement:Toggle({ Title = "Infinite Jump", Value = false, Callback = function(v) Settings.InfiniteJump = v end })
TabMovement:Toggle({ Title = "No Fall Damage", Value = false, Callback = function(v) Settings.NoFallDamage = v end })
TabMovement:Toggle({ Title = "Auto Respawn", Value = false, Callback = function(v) Settings.AutoRespawn = v end })
TabMovement:Toggle({ Title = "Noclip", Value = false,
    Callback = function(v)
        Settings.Noclip = v; notifyState("Noclip", v)
        if not v and LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end })

-- ==========================================================
--  Combat
-- ==========================================================
TabCombat:Section({ Title = "Aimbot" })
TabCombat:Toggle({ Title = "Aimbot (Cam Lock)", Value = false, Callback = function(v) Settings.Aimbot = v; notifyState("Aimbot", v) end })
TabCombat:Toggle({ Title = "Silent Aim", Value = false, Callback = function(v) Settings.SilentAim = v; notifyState("Silent Aim", v) end })
TabCombat:Toggle({ Title = "Wall Check", Value = true, Callback = function(v) Settings.WallCheck = v end })
TabCombat:Toggle({ Title = "Team Check", Value = true, Callback = function(v) Settings.TeamCheck = v end })
TabCombat:Dropdown({
    Title = "Aim Part",
    Values = { "Head", "Torso", "Closest" },
    Value = "Head",
    Callback = function(v) Settings.AimPart = v end,
})
TabCombat:Slider({ Title = "Aim FOV", Value = { Min = 50, Max = 1000, Default = 350 }, Callback = function(v) Settings.AimFOV = v end })
TabCombat:Slider({ Title = "Aim Smooth", Value = { Min = 1, Max = 10, Default = 4 }, Callback = function(v) Settings.AimSmooth = v end })
TabCombat:Slider({ Title = "Aim Prediction", Value = { Min = 0, Max = 1, Default = 0.15 }, Callback = function(v) Settings.AimPrediction = v end })
TabCombat:Slider({ Title = "Hit Chance %", Value = { Min = 0, Max = 100, Default = 100 }, Callback = function(v) Settings.AimHitChance = v end })
TabCombat:Toggle({ Title = "Draw FOV", Value = true, Callback = function(v) Settings.DrawFOV = v end })

TabCombat:Section({ Title = "Triggerbot" })
TabCombat:Toggle({ Title = "Triggerbot", Value = false, Callback = function(v) Settings.Triggerbot = v; notifyState("Triggerbot", v) end })
TabCombat:Toggle({ Title = "Wall Check", Value = true, Callback = function(v) Settings.TriggerbotWallCheck = v end })
TabCombat:Slider({ Title = "Trigger FOV", Value = { Min = 30, Max = 500, Default = 150 }, Callback = function(v) Settings.TriggerbotFOV = v end })
TabCombat:Slider({ Title = "Trigger Delay", Value = { Min = 0.0, Max = 1, Default = 0.05 }, Callback = function(v) Settings.TriggerbotDelay = v end })

TabCombat:Section({ Title = "Other Combat" })
TabCombat:Toggle({ Title = "Autoclicker", Value = false, Callback = function(v) Settings.Autoclicker = v end })
TabCombat:Slider({ Title = "CPS", Value = { Min = 1, Max = 50, Default = 15 }, Callback = function(v) Settings.AutoclickerCPS = v end })
TabCombat:Toggle({ Title = "Killaura", Value = false, Callback = function(v) Settings.Killaura = v; notifyState("Killaura", v) end })
TabCombat:Slider({ Title = "Killaura Range", Value = { Min = 5, Max = 60, Default = 20 }, Callback = function(v) Settings.KillauraRange = v end })
TabCombat:Toggle({ Title = "Hitbox Expander", Value = false,
    Callback = function(v)
        Settings.HitboxExpander = v; notifyState("Hitbox Expander", v)
        if not v then
            for _, p in pairs(Players:GetPlayers()) do
                local head = getHead(p.Character)
                if head then head.Size = Vector3.new(2,1,1); head.Transparency = 0 end
            end
        end
    end })
TabCombat:Slider({ Title = "Hitbox Size", Value = { Min = 2, Max = 40, Default = 8 }, Callback = function(v) Settings.HitboxSize = v end })

-- ==========================================================
--  Visuals
-- ==========================================================
TabVisuals:Section({ Title = "ESP" })
TabVisuals:Toggle({ Title = "ESP Boxes", Value = true, Callback = function(v) Settings.ESPBox = v end })
TabVisuals:Toggle({ Title = "HP Bar", Value = true, Callback = function(v) Settings.HPBar = v end })
TabVisuals:Toggle({ Title = "Tracers", Value = true, Callback = function(v) Settings.Tracers = v end })
TabVisuals:Toggle({ Title = "Skeleton ESP", Value = true, Callback = function(v) Settings.SkeletonESP = v end })
TabVisuals:Toggle({ Title = "Name ESP", Value = true, Callback = function(v) Settings.NameESP = v end })
TabVisuals:Toggle({ Title = "Chams", Value = false, Callback = function(v) Settings.Chams = v end })

TabVisuals:Section({ Title = "Screen" })
TabVisuals:Toggle({ Title = "Crosshair", Value = false, Callback = function(v) Settings.Crosshair = v end })
TabVisuals:Toggle({ Title = "Bullet Tracers", Value = false, Callback = function(v) Settings.BulletTracers = v end })
TabVisuals:Toggle({ Title = "FOV Changer", Value = false, Callback = function(v) Settings.FOVChanger = v end })
TabVisuals:Slider({ Title = "Game FOV", Value = { Min = 30, Max = 120, Default = 90 }, Callback = function(v) Settings.CustomFOV = v end })
TabVisuals:Toggle({ Title = "Watermark", Value = true, Callback = function(v) Settings.Watermark = v end })

-- ==========================================================
--  Colors
-- ==========================================================
TabColors:Section({ Title = "Menu" })
TabColors:Colorpicker({ Title = "Accent", Default = Settings.ColorMenu, Transparency = Settings.AlphaMenu,
    Callback = function(c, a) Settings.ColorMenu = c; if a then Settings.AlphaMenu = a end; ApplyMenuColorsToTheme() end })
TabColors:Colorpicker({ Title = "Window Background", Default = Settings.ColorWindow, Transparency = Settings.AlphaWindow,
    Callback = function(c, a) Settings.ColorWindow = c; if a then Settings.AlphaWindow = a end; ApplyMenuColorsToTheme() end })
TabColors:Colorpicker({ Title = "Panel Background", Default = Settings.ColorPanel, Transparency = Settings.AlphaPanel,
    Callback = function(c, a) Settings.ColorPanel = c; if a then Settings.AlphaPanel = a end; ApplyMenuColorsToTheme() end })
TabColors:Colorpicker({ Title = "Text", Default = Settings.ColorText, Transparency = Settings.AlphaText,
    Callback = function(c, a) Settings.ColorText = c; if a then Settings.AlphaText = a end; ApplyMenuColorsToTheme() end })
TabColors:Colorpicker({ Title = "Sub Text", Default = Settings.ColorSubText, Transparency = Settings.AlphaSubText,
    Callback = function(c, a) Settings.ColorSubText = c; if a then Settings.AlphaSubText = a end; ApplyMenuColorsToTheme() end })

TabColors:Section({ Title = "ESP" })
TabColors:Colorpicker({ Title = "Box", Default = Settings.ColorBox, Transparency = Settings.AlphaBox,
    Callback = function(c, a) Settings.ColorBox = c; if a then Settings.AlphaBox = a end end })
TabColors:Colorpicker({ Title = "Tracer", Default = Settings.ColorTracer, Transparency = Settings.AlphaTracer,
    Callback = function(c, a) Settings.ColorTracer = c; if a then Settings.AlphaTracer = a end end })
TabColors:Colorpicker({ Title = "Skeleton", Default = Settings.ColorSkeleton, Transparency = Settings.AlphaSkeleton,
    Callback = function(c, a) Settings.ColorSkeleton = c; if a then Settings.AlphaSkeleton = a end end })
TabColors:Colorpicker({ Title = "Name", Default = Settings.ColorName, Transparency = Settings.AlphaName,
    Callback = function(c, a) Settings.ColorName = c; if a then Settings.AlphaName = a end end })
TabColors:Colorpicker({ Title = "HP Full", Default = Settings.ColorHPFull, Transparency = Settings.AlphaHPFull,
    Callback = function(c, a) Settings.ColorHPFull = c; if a then Settings.AlphaHPFull = a end end })
TabColors:Colorpicker({ Title = "HP Empty", Default = Settings.ColorHPEmpty, Transparency = Settings.AlphaHPEmpty,
    Callback = function(c, a) Settings.ColorHPEmpty = c; if a then Settings.AlphaHPEmpty = a end end })
TabColors:Colorpicker({ Title = "FOV Circle", Default = Settings.ColorFOV, Transparency = Settings.AlphaFOV,
    Callback = function(c, a) Settings.ColorFOV = c; if a then Settings.AlphaFOV = a end end })
TabColors:Colorpicker({ Title = "Crosshair", Default = Settings.ColorCrosshair, Transparency = Settings.AlphaCrosshair,
    Callback = function(c, a) Settings.ColorCrosshair = c; if a then Settings.AlphaCrosshair = a end end })
TabColors:Colorpicker({ Title = "Bullet Tracer", Default = Settings.ColorBulletTracer, Transparency = Settings.AlphaBulletTracer,
    Callback = function(c, a) Settings.ColorBulletTracer = c; if a then Settings.AlphaBulletTracer = a end end })

TabColors:Section({ Title = "Chams" })
TabColors:Colorpicker({
    Title = "Chams Fill", Default = Settings.ColorChams, Transparency = Settings.AlphaChams,
    Callback = function(c, a)
        Settings.ColorChams = c; if a then Settings.AlphaChams = a end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hl = p.Character:FindFirstChild("MellChams")
                if hl then hl.FillColor = c; hl.FillTransparency = Settings.AlphaChams end
            end
        end
    end,
})
TabColors:Colorpicker({
    Title = "Chams Outline", Default = Settings.ColorChamsOutline, Transparency = Settings.AlphaChamsOutline,
    Callback = function(c, a)
        Settings.ColorChamsOutline = c; if a then Settings.AlphaChamsOutline = a end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hl = p.Character:FindFirstChild("MellChams")
                if hl then hl.OutlineColor = c; hl.OutlineTransparency = Settings.AlphaChamsOutline end
            end
        end
    end,
})

TabColors:Section({ Title = "Presets" })
TabColors:Button({ Title = "Reset All Colors", Icon = "rotate-ccw", Callback = resetConfig })

-- ==========================================================
--  Extras
-- ==========================================================
TabExtras:Section({ Title = "Config" })
TabExtras:Button({ Title = "Save Config", Icon = "save", Callback = saveConfig })
TabExtras:Button({ Title = "Load Config", Icon = "folder-open", Callback = loadConfig })
TabExtras:Button({ Title = "Reset Settings", Icon = "rotate-ccw", Callback = resetConfig })

TabExtras:Section({ Title = "Teleport" })
TabExtras:Dropdown({
    Title = "Teleport to Player",
    Values = (function()
        local t = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(t, p.Name) end
        end
        return t
    end)(),
    Value = nil,
    Callback = function(v)
        if not v then return end
        local target = Players:FindFirstChild(v)
        if target and target.Character then
            local hrp = getRoot(target.Character)
            local myHrp = getRoot(LocalPlayer.Character)
            if hrp and myHrp then
                myHrp.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 3, 0))
            end
        end
    end,
})
TabExtras:Toggle({ Title = "Click Teleport", Value = false, Callback = function(v) Settings.ClickTeleport = v end })

TabExtras:Section({ Title = "Utility" })
TabExtras:Button({ Title = "Reset Character", Icon = "rotate-ccw",
    Callback = function()
        local hum = getHumanoid(LocalPlayer.Character)
        if hum then hum.Health = 0 end
    end })
TabExtras:Button({ Title = "Rejoin Server", Icon = "log-out",
    Callback = function() pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end) end })
TabExtras:Button({ Title = "Server Hop", Icon = "shuffle",
    Callback = function()
        task.spawn(function()
            pcall(function()
                local body = httpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
                if not body then WindUI:Notify({ Title = "MellHack", Content = "HTTP unavailable", Icon = "x" }); return end
                local data = HttpService:JSONDecode(body)
                local servers = {}
                for _, s in pairs(data.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        table.insert(servers, s.id)
                    end
                end
                if #servers > 0 then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
                else
                    WindUI:Notify({ Title = "MellHack", Content = "No servers found", Icon = "x" })
                end
            end)
        end)
    end })

-- ==========================================================
--  Shaders
-- ==========================================================
TabShaders:Section({ Title = "Lighting" })
TabShaders:Toggle({ Title = "Fullbright", Value = false,
    Callback = function(v)
        Settings.Fullbright = v
        if not v then Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.GlobalShadows = true end
    end })
TabShaders:Toggle({ Title = "X-Ray", Value = false,
    Callback = function(v)
        Settings.Xray = v
        if not v then
            for _, p in pairs(Workspace:GetDescendants()) do
                if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end
            end
        end
    end })
TabShaders:Toggle({ Title = "Custom Fog", Value = false,
    Callback = function(v) Settings.CustomFog = v; if not v then Lighting.FogEnd = 100000 end end })
TabShaders:Slider({ Title = "Fog Distance", Value = { Min = 50, Max = 5000, Default = 500 }, Callback = function(v) Settings.FogEnd = v end })

TabShaders:Section({ Title = "Shaders" })
TabShaders:Toggle({ Title = "Cinema Bloom", Value = false,
    Callback = function(v)
        local b = Lighting:FindFirstChild("MellBloom")
        if v and not b then
            b = Instance.new("BloomEffect", Lighting); b.Name = "MellBloom"
            b.Intensity = 1.8; b.Size = 56; b.Threshold = 0.45
        elseif not v and b then b:Destroy() end
    end })
TabShaders:Toggle({ Title = "Color Correction", Value = false,
    Callback = function(v)
        local cc = Lighting:FindFirstChild("MellCC")
        if v and not cc then
            cc = Instance.new("ColorCorrectionEffect", Lighting); cc.Name = "MellCC"
            cc.Saturation = 0.6; cc.Contrast = 0.4; cc.TintColor = Color3.fromRGB(240,220,200)
        elseif not v and cc then cc:Destroy() end
    end })
TabShaders:Toggle({ Title = "God Rays", Value = false,
    Callback = function(v)
        local s = Lighting:FindFirstChild("MellSunRays")
        if v and not s then
            s = Instance.new("SunRaysEffect", Lighting); s.Name = "MellSunRays"
            s.Intensity = 0.45; s.Spread = 1
        elseif not v and s then s:Destroy() end
    end })
TabShaders:Toggle({ Title = "Depth of Field", Value = false,
    Callback = function(v)
        local d = Lighting:FindFirstChild("MellDOF")
        if v and not d then
            d = Instance.new("DepthOfFieldEffect", Lighting); d.Name = "MellDOF"
            d.FarIntensity = 0.6; d.FocusDistance = 20; d.InFocusRadius = 12
        elseif not v and d then d:Destroy() end
    end })

-- ==========================================================
--  Rage
-- ==========================================================
TabRage:Section({ Title = "Rage" })
TabRage:Toggle({ Title = "Chat Flood", Value = false, Callback = function(v) Settings.ChatFlood = v end })
TabRage:Slider({ Title = "Flood Delay", Value = { Min = 0.2, Max = 5, Default = 1 }, Callback = function(v) Settings.FloodDelay = v end })
TabRage:Toggle({ Title = "Freecam", Value = false, Callback = function(v) Settings.Freecam = v end })
TabRage:Slider({ Title = "Freecam Speed", Value = { Min = 10, Max = 200, Default = 50 }, Callback = function(v) Settings.FreecamSpeed = v end })
TabRage:Toggle({ Title = "Earthquake", Value = false, Callback = function(v) Settings.Earthquake = v end })
TabRage:Toggle({ Title = "Invisibility", Value = false,
    Callback = function(v)
        Settings.Invisible = v
        local char = LocalPlayer.Character
        if char then
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency = v and 1 or 0 end
            end
        end
    end })
TabRage:Toggle({ Title = "Godmode", Value = false, Callback = function(v) Settings.Godmode = v; notifyState("Godmode", v) end })
TabRage:Toggle({ Title = "Auto Heal", Value = false, Callback = function(v) Settings.AutoHeal = v end })

TabRage:Section({ Title = "Fun" })
TabRage:Toggle({
    Title = "Jerk", Value = false,
    Callback = function(v)
        Settings.Jerk = v
        if v then
            task.spawn(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
                local bp  = LocalPlayer:FindFirstChildWhichIsA("Backpack")
                if not hum or not bp then return end
                local tool = Instance.new("Tool"); tool.Name = "Jerk Off Tool"
                tool.RequiresHandle = false; tool.Parent = bp
                local track
                while Settings.Jerk and getgenv().MellHackLoaded do
                    local isR15 = r15(LocalPlayer)
                    if not track then
                        local anim = Instance.new("Animation")
                        anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
                        track = hum:LoadAnimation(anim)
                    end
                    track:Play(); track:AdjustSpeed(isR15 and 0.7 or 0.65); track.TimePosition = 0.6
                    task.wait(0.1)
                    while track and track.TimePosition < (not isR15 and 0.65 or 0.7) and Settings.Jerk do task.wait(0.1) end
                    if track then track:Stop(); track = nil end
                    task.wait(0.05)
                end
                if tool then tool:Destroy() end
            end)
        end
    end,
})
TabRage:Toggle({
    Title = "Bang", Value = false,
    Callback = function(v)
        Settings.Bang = v
        if v then
            task.spawn(function()
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
                if not hum then return end
                local anim = Instance.new("Animation")
                anim.AnimationId = not r15(LocalPlayer) and "rbxassetid://148840371" or "rbxassetid://5918726674"
                local bang = hum:LoadAnimation(anim); bang:Play(0.1,1,1); bang:AdjustSpeed(3)
                while Settings.Bang and getgenv().MellHackLoaded do
                    pcall(function()
                        local target = Players:GetPlayers()[math.random(1, #Players:GetPlayers())]
                        if target ~= LocalPlayer and target.Character then
                            local oRoot = getRoot(target.Character)
                            local hRoot = getRoot(LocalPlayer.Character)
                            if oRoot and hRoot then hRoot.CFrame = oRoot.CFrame * CFrame.new(0,0,1.1) end
                        end
                    end)
                    task.wait(0.1)
                end
                bang:Stop(); anim:Destroy()
            end)
        end
    end,
})
TabRage:Toggle({
    Title = "Fling", Value = false,
    Callback = function(v)
        Settings.Fling = v
        if v then
            task.spawn(function()
                while Settings.Fling and getgenv().MellHackLoaded do
                    pcall(function()
                        local myRoot = getRoot(LocalPlayer.Character)
                        if myRoot then
                            for _, p in pairs(Players:GetPlayers()) do
                                if p ~= LocalPlayer and p.Character then
                                    local eRoot = getRoot(p.Character)
                                    local eHum  = getHumanoid(p.Character)
                                    if eRoot and eHum and (myRoot.Position - eRoot.Position).Magnitude < 12 then
                                        eRoot.AssemblyLinearVelocity = (eRoot.Position - myRoot.Position).Unit * 350 + Vector3.new(0,150,0)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.05)
                end
            end)
        end
    end,
})

TabRage:Section({ Title = "Anti-Aim" })
TabRage:Toggle({ Title = "Spin-Bot", Value = false, Callback = function(v) Settings.SpinBot = v end })
TabRage:Slider({ Title = "Spin-Bot Speed", Value = { Min = 100, Max = 5000, Default = 1000 }, Callback = function(v) Settings.SpinSpeed = v end })
TabRage:Toggle({ Title = "Anti-Aim", Value = false, Callback = function(v) Settings.AntiAim = v; notifyState("Anti-Aim", v) end })
TabRage:Dropdown({
    Title = "Anti-Aim Mode",
    Values = { "Spin", "Jitter", "Random", "Static" },
    Value = "Spin",
    Callback = function(v) Settings.AntiAimMode = v end,
})
TabRage:Slider({ Title = "Jitter Range", Value = { Min = 10, Max = 180, Default = 90 }, Callback = function(v) Settings.JitterRange = v end })
TabRage:Slider({ Title = "Yaw Offset", Value = { Min = -180, Max = 180, Default = 0 }, Callback = function(v) Settings.YawOffset = v end })
TabRage:Toggle({ Title = "Body Shake", Value = false, Callback = function(v) Settings.BodyShake = v end })
TabRage:Toggle({ Title = "Hide Head", Value = false, Callback = function(v) Settings.HideHead = v end })

-- ==========================================================
--  Keybinds
-- ==========================================================
TabBinds:Section({ Title = "Keybinds" })
TabBinds:Keybind({ Title = "Toggle Fly", Value = "F", Callback = function() Settings.Fly = not Settings.Fly; notifyState("Fly", Settings.Fly) end })
TabBinds:Keybind({ Title = "Toggle Noclip", Value = "G", Callback = function() Settings.Noclip = not Settings.Noclip; notifyState("Noclip", Settings.Noclip) end })
TabBinds:Keybind({ Title = "Toggle Speed", Value = "H", Callback = function() Settings.Speed = not Settings.Speed; notifyState("Speed", Settings.Speed) end })

-- ==========================================================
--  Settings
-- ==========================================================
TabSettings:Section({ Title = "Menu" })
TabSettings:Toggle({ Title = "White Theme", Value = false,
    Callback = function(v) WindUI:SetTheme(v and "Light" or "Dark"); task.defer(ApplyMenuColorsToTheme) end })
TabSettings:Slider({ Title = "Menu Transparency", Value = { Min = 0, Max = 90, Default = 15 },
    Callback = function(v)
        Settings.AlphaWindow = v / 100
        Settings.AlphaPanel  = v / 100
        Settings.AlphaMenu   = v / 100
        ApplyMenuColorsToTheme()
    end })

TabSettings:Section({ Title = "Script" })
TabSettings:Toggle({ Title = "Unload Script", Value = false,
    Callback = function(v) if v then task.defer(function() getgenv().MellHackUnload() end) end end })

-- ==========================================================
--  Helpers
-- ==========================================================
local function isEnemy(player)
    if not Settings.TeamCheck then return true end
    return player.Team ~= LocalPlayer.Team
end

local function isVisible(targetPart)
    if not Settings.WallCheck then return true end
    local char = LocalPlayer.Character
    local cam = Camera
    if not char or not cam then return false end
    local origin = cam.CFrame.Position
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {char, targetPart.Parent}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.IgnoreWater = true
    local result = Workspace:Raycast(origin, targetPart.Position - origin, rp)
    return result == nil
end
local function isTriggerVisible(targetPart)
    if not Settings.TriggerbotWallCheck then return true end
    return isVisible(targetPart)
end

local function getAimPart(player)
    local char = player.Character
    if not char then return nil end
    if Settings.AimPart == "Head" then
        return char:FindFirstChild("Head")
    elseif Settings.AimPart == "Torso" then
        return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    else
        local best, bestDist
        for _, partName in ipairs({"Head", "UpperTorso", "Torso", "HumanoidRootPart"}) do
            local part = char:FindFirstChild(partName)
            if part then
                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local d = (Vector2.new(sp.X, sp.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if not bestDist or d < bestDist then bestDist = d; best = part end
                end
            end
        end
        return best or char:FindFirstChild("HumanoidRootPart")
    end
end

-- ==========================================================
--  ESP render loop
-- ==========================================================
trackConn(RunService.RenderStepped:Connect(function()
    if not getgenv().MellHackLoaded then return end

    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        local hrp = getRoot(char)
        local hum = getHumanoid(char)
        local head = getHead(char)

        local shouldShow = char and hrp and hum and hum.Health > 0
            and (Settings.TeamESP and isEnemy(p) or not Settings.TeamESP)

        local esp = ESPCache[p]
        local tracer = TracerCache[p]
        local skeleton = SkeletonCache[p]

        if not shouldShow then
            if esp then esp.Billboard.Enabled = false end
            if tracer then tracer.Frame.Visible = false end
            if skeleton then for _, l in ipairs(skeleton) do l.Visible = false end end
            continue
        end

        if Settings.Chams then
            if not char:FindFirstChild("MellChams") then
                local hl = Instance.new("Highlight", char)
                hl.Name = "MellChams"
                hl.FillColor = Settings.ColorChams
                hl.FillTransparency = Settings.AlphaChams
                hl.OutlineColor = Settings.ColorChamsOutline
                hl.OutlineTransparency = Settings.AlphaChamsOutline
            else
                local hl = char.MellChams
                hl.FillColor = Settings.ColorChams
                hl.FillTransparency = Settings.AlphaChams
                hl.OutlineColor = Settings.ColorChamsOutline
                hl.OutlineTransparency = Settings.AlphaChamsOutline
            end
        elseif char:FindFirstChild("MellChams") then
            char.MellChams:Destroy()
        end

        local topPos, onScreen = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
        local bottomPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        if onScreen and topPos.Z > 0 then
            esp = esp or ensureESP(p)
            local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
            local heightPixels = math.abs(topPos.Y - bottomPos.Y)
            local widthPixels = heightPixels * 0.5
            if widthPixels < 10 then widthPixels = 10 end
            if heightPixels < 10 then heightPixels = 10 end

            esp.Billboard.Adornee = hrp
            esp.Billboard.Enabled = true
            esp.Billboard.Size = UDim2.fromOffset(widthPixels, heightPixels)
            esp.Billboard.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)

            esp.BoxFrame.Visible = Settings.ESPBox
            esp.BoxStroke.Enabled = Settings.ESPBox
            esp.BoxStroke.Color = Settings.ColorBox
            esp.BoxStroke.Transparency = Settings.AlphaBox
            esp.BoxStroke.Thickness = 1.5

            esp.NameLabel.Visible = Settings.NameESP
            esp.NameLabel.TextColor3 = Settings.ColorName
            esp.NameLabel.TextTransparency = Settings.AlphaName
            esp.NameLabel.Text = string.format("%s [%dm]", p.Name, math.floor(distance))

            esp.HPBarBack.Visible = Settings.HPBar
            esp.HPBarBack.BackgroundColor3 = Settings.ColorHPEmpty
            esp.HPBarBack.BackgroundTransparency = Settings.AlphaHPEmpty
            esp.HPBarFill.BackgroundColor3 = Settings.ColorHPFull
            esp.HPBarFill.BackgroundTransparency = Settings.AlphaHPFull
            if hum then
                local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                esp.HPBarFill.Size = UDim2.new(1, 0, pct, 0)
                esp.HPBarFill.Position = UDim2.new(0, 0, 1 - pct, 0)
            end

            if Settings.Tracers then
                local t = tracer or ensureTracer(p)
                local bottomScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                local targetScreen = Vector2.new(topPos.X, topPos.Y + heightPixels / 2)
                drawLine(t.Frame, bottomScreen, targetScreen, Settings.ColorTracer, Settings.AlphaTracer)
            elseif tracer then
                tracer.Frame.Visible = false
            end

            if Settings.SkeletonESP and head then
                local bones = skeleton or ensureSkeleton(p)
                local upperTorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                local lowerTorso = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
                local leftArm = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
                local rightArm = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
                local leftLeg = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
                local rightLeg = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")

                local function screen(pos)
                    if not pos then return nil end
                    local sp, on = Camera:WorldToViewportPoint(pos.Position)
                    if not on then return nil end
                    return Vector2.new(sp.X, sp.Y)
                end

                local hS  = screen(head)
                local utS = screen(upperTorso)
                local ltS = screen(lowerTorso)
                local laS = screen(leftArm)
                local raS = screen(rightArm)
                local llS = screen(leftLeg)
                local rlS = screen(rightLeg)

                drawLine(bones[1], hS, utS, Settings.ColorSkeleton, Settings.AlphaSkeleton)
                drawLine(bones[2], utS, ltS, Settings.ColorSkeleton, Settings.AlphaSkeleton)
                drawLine(bones[3], ltS, llS, Settings.ColorSkeleton, Settings.AlphaSkeleton)
                drawLine(bones[4], ltS, rlS, Settings.ColorSkeleton, Settings.AlphaSkeleton)
                drawLine(bones[5], utS, laS, Settings.ColorSkeleton, Settings.AlphaSkeleton)
                drawLine(bones[6], utS, raS, Settings.ColorSkeleton, Settings.AlphaSkeleton)
            elseif skeleton then
                for _, l in ipairs(skeleton) do l.Visible = false end
            end
        else
            if esp then esp.Billboard.Enabled = false end
            if tracer then tracer.Frame.Visible = false end
            if skeleton then for _, l in ipairs(skeleton) do l.Visible = false end end
        end
    end
end))

-- ==========================================================
--  FOV circle
-- ==========================================================
local fovFrame = newFrame({
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Parent = ESPGui,
    Visible = false,
    Size = UDim2.fromOffset(100, 100),
})
fovFrame.Name = "MellFOV"
local fovStroke = newStroke(fovFrame, Settings.ColorFOV, 1.5, Settings.AlphaFOV)
local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovFrame
trackObj(fovCorner)

trackConn(RunService.RenderStepped:Connect(function()
    if not getgenv().MellHackLoaded then return end
    if (Settings.Aimbot or Settings.SilentAim) and Settings.DrawFOV then
        local r = Settings.AimFOV * 2
        fovFrame.Visible = true
        fovFrame.Size = UDim2.fromOffset(r, r)
        fovFrame.Position = UDim2.fromOffset(
            UserInputService:GetMouseLocation().X,
            UserInputService:GetMouseLocation().Y
        )
        fovStroke.Color = Settings.ColorFOV
        fovStroke.Transparency = Settings.AlphaFOV
    else
        fovFrame.Visible = false
    end
end))

-- ==========================================================
--  Crosshair
-- ==========================================================
trackConn(RunService.RenderStepped:Connect(function()
    if not getgenv().MellHackLoaded then return end
    if Settings.Crosshair then
        local center = Camera.ViewportSize / 2
        local gap, len = 6, 12
        for i = 1, 4 do
            crosshairParts[i].Visible = true
            crosshairParts[i].BackgroundColor3 = Settings.ColorCrosshair
            crosshairParts[i].BackgroundTransparency = Settings.AlphaCrosshair
        end
        crosshairParts[1].Size = UDim2.fromOffset(1.5, len)
        crosshairParts[1].Position = UDim2.fromOffset(center.X, center.Y - gap - len/2)
        crosshairParts[2].Size = UDim2.fromOffset(1.5, len)
        crosshairParts[2].Position = UDim2.fromOffset(center.X, center.Y + gap + len/2)
        crosshairParts[3].Size = UDim2.fromOffset(len, 1.5)
        crosshairParts[3].Position = UDim2.fromOffset(center.X - gap - len/2, center.Y)
        crosshairParts[4].Size = UDim2.fromOffset(len, 1.5)
        crosshairParts[4].Position = UDim2.fromOffset(center.X + gap + len/2, center.Y)
    else
        for i = 1, 4 do crosshairParts[i].Visible = false end
    end
end))

-- ==========================================================
--  Autoclicker
-- ==========================================================
trackConn(task.spawn(function()
    while getgenv().MellHackLoaded do
        if Settings.Autoclicker then
            pcall(function() mouse1click() end)
            task.wait(1 / Settings.AutoclickerCPS)
        else
            task.wait(0.1)
        end
    end
end))

-- ==========================================================
--  InfiniteJump
-- ==========================================================
trackConn(UserInputService.JumpRequest:Connect(function()
    if not getgenv().MellHackLoaded then return end
    local char = LocalPlayer.Character
    local hum  = getHumanoid(char)
    if Settings.InfiniteJump and char and hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

-- ==========================================================
--  SilentAim
-- ==========================================================
pcall(function()
    if not hookmetamethod or not getnamecallmethod then return end
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        if not getgenv().MellHackLoaded or not Settings.SilentAim then
            return oldNamecall(self, ...)
        end
        local method = getnamecallmethod()
        local args = {...}
        if method == "FireServer" or method == "InvokeServer" then
            local targetPart, minDst = nil, Settings.AimFOV
            local mousePos = UserInputService:GetMouseLocation()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and isEnemy(p) and p.Character then
                    local hum = getHumanoid(p.Character)
                    if hum and hum.Health > 0 then
                        local part = getAimPart(p)
                        if part and isVisible(part) then
                            if Settings.AimHitChance < 100 and math.random(1,100) > Settings.AimHitChance then
                                continue
                            end
                            local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local dst = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                                if dst < minDst then minDst = dst; targetPart = part end
                            end
                        end
                    end
                end
            end
            if targetPart then
                local predictedPos = targetPart.Position
                if Settings.AimPrediction > 0 then
                    predictedPos = targetPart.Position + (targetPart.AssemblyLinearVelocity * Settings.AimPrediction)
                end
                for i, arg in pairs(args) do
                    if typeof(arg) == "Vector3" then
                        args[i] = predictedPos
                    elseif typeof(arg) == "CFrame" then
                        args[i] = CFrame.new(arg.Position, predictedPos)
                    end
                end
                return oldNamecall(self, unpack(args))
            end
        end
        return oldNamecall(self, ...)
    end)
end)

-- ==========================================================
--  Triggerbot
-- ==========================================================
local lastTrigger = 0
trackConn(RunService.RenderStepped:Connect(function()
    if not getgenv().MellHackLoaded or not Settings.Triggerbot then return end
    local now = tick()
    if now - lastTrigger < Settings.TriggerbotDelay then return end
    local mousePos = UserInputService:GetMouseLocation()
    local target, minDst = nil, Settings.TriggerbotFOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and isEnemy(p) and p.Character then
            local hum = getHumanoid(p.Character)
            if hum and hum.Health > 0 then
                local part = getAimPart(p) or getRoot(p.Character)
                if part and isTriggerVisible(part) then
                    local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dst = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                        if dst < minDst then minDst = dst; target = p end
                    end
                end
            end
        end
    end
    if target then
        pcall(function() mouse1click() end)
        lastTrigger = now
    end
end))

-- ==========================================================
--  Main loop
-- ==========================================================
trackConn(RunService.RenderStepped:Connect(function()
    if not getgenv().MellHackLoaded then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = getRoot(char)
    local humanoid = getHumanoid(char)
    if not hrp or not humanoid then return end

    if Settings.Speed  then humanoid.WalkSpeed = Settings.WalkSpeedVal end
    if Settings.Jump   then humanoid.JumpPower = Settings.JumpPowerVal end
    if Settings.Godmode then humanoid.Health = humanoid.MaxHealth end
    if Settings.AutoHeal and humanoid.Health < humanoid.MaxHealth then humanoid.Health = humanoid.MaxHealth end
    if Settings.FOVChanger then Camera.FieldOfView = Settings.CustomFOV end

    if Settings.Noclip then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    if Settings.AntiFling then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, part in pairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end

    if Settings.Bhop and humanoid.FloorMaterial ~= Enum.Material.Air then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    if Settings.Strafes and humanoid.FloorMaterial == Enum.Material.Air then
        local md = humanoid.MoveDirection
        if md.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = Vector3.new(md.X * Settings.StrafeSpeed, hrp.AssemblyLinearVelocity.Y, md.Z * Settings.StrafeSpeed)
        end
    end

    if Settings.PixelSurf then
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local l = Workspace:Raycast(hrp.Position, -hrp.CFrame.RightVector * 3.5, params)
        local r = Workspace:Raycast(hrp.Position,  hrp.CFrame.RightVector * 3.5, params)
        local f = Workspace:Raycast(hrp.Position,  hrp.CFrame.LookVector  * 3.5, params)
        local b = Workspace:Raycast(hrp.Position, -hrp.CFrame.LookVector  * 3.5, params)
        if (l or r or f or b) and humanoid.FloorMaterial == Enum.Material.Air then
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z)
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
                local md = humanoid.MoveDirection
                if md.Magnitude > 0 then hrp.CFrame += md * (Settings.StrafeSpeed/60) end
            end
        end
    end

    if Settings.LongJump and humanoid.FloorMaterial ~= Enum.Material.Air and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        hrp.AssemblyLinearVelocity = hrp.CFrame.LookVector * 90 + Vector3.new(0, 40, 0)
    end

    if Settings.SuperGlide then
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local ledge = Workspace:Raycast(hrp.Position + Vector3.new(0,2,0), hrp.CFrame.LookVector * 4, params)
        if ledge and humanoid.FloorMaterial == Enum.Material.Air then
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 15, hrp.AssemblyLinearVelocity.Z * 3)
        end
    end

    if Settings.WallHop and humanoid.FloorMaterial == Enum.Material.Air then
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local wall = Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 3, params)
        if wall and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 65, hrp.AssemblyLinearVelocity.Z)
        end
    end

    if Settings.WallClimb then
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {char}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local wall = Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 3, params)
        if wall and humanoid.MoveDirection.Magnitude > 0 then
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 40, hrp.AssemblyLinearVelocity.Z)
        end
    end

    if Settings.AirBoost and humanoid.FloorMaterial == Enum.Material.Air and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        hrp.AssemblyLinearVelocity += Camera.CFrame.LookVector * 5
    end

    if Settings.EdgeBug and hrp.AssemblyLinearVelocity.Y < -50 and humanoid.FloorMaterial == Enum.Material.Air then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
    end

    if Settings.NoFallDamage and hrp.AssemblyLinearVelocity.Y < -50 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -50, hrp.AssemblyLinearVelocity.Z)
    end

    if Settings.AutoRespawn and humanoid.Health <= 0 then
        task.spawn(function() task.wait(3); pcall(function() LocalPlayer:LoadCharacter() end) end)
    end

    if Settings.SpinBot then
        hrp.CFrame *= CFrame.Angles(0, math.rad(Settings.SpinSpeed), 0)
    elseif Settings.AntiAim then
        local mode = Settings.AntiAimMode or "Spin"
        local yawOffsetRad = math.rad(Settings.YawOffset)
        local finalAngle
        if mode == "Spin" then
            finalAngle = (tick() * Settings.SpinSpeed * 20) + yawOffsetRad
        elseif mode == "Jitter" then
            finalAngle = yawOffsetRad + math.rad(math.random(-Settings.JitterRange, Settings.JitterRange))
        elseif mode == "Random" then
            finalAngle = math.rad(math.random(0, 360))
        else
            finalAngle = yawOffsetRad
        end
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, finalAngle, 0)
    end

    if Settings.BodyShake then
        hrp.CFrame *= CFrame.new(math.random(-1,1)*0.2, math.random(-1,1)*0.2, math.random(-1,1)*0.2)
    end

    if Settings.HideHead then
        local head = getHead(char)
        if head then
            head.Transparency = 1
            head.CanCollide = false
            for _, c in pairs(head:GetChildren()) do
                if c:IsA("SpecialMesh") or c:IsA("DataModelMesh") or c:IsA("Decal") then
                    c.Transparency = 1
                end
            end
        end
    end

    if Settings.Freecam then
        Camera.CameraType = Enum.CameraType.Scriptable
        local md = Vector3.new(0,0,0)
        local camCF = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then md += camCF.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then md -= camCF.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then md -= camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then md += camCF.RightVector end
        Camera.CFrame = camCF + (md * (Settings.FreecamSpeed / 30))
    elseif Camera.CameraType == Enum.CameraType.Scriptable then
        Camera.CameraType = Enum.CameraType.Custom
    end

    if Settings.Earthquake then
        Camera.CFrame *= CFrame.new(math.random(-1,1)*0.1, math.random(-1,1)*0.1, 0)
    end

    if Settings.Fullbright then
        Lighting.Brightness = 3; Lighting.ClockTime = 12; Lighting.GlobalShadows = false
    end

    if Settings.CustomFog then
        Lighting.FogEnd = Settings.FogEnd
        Lighting.FogColor = Color3.fromRGB(Settings.FogColor[1], Settings.FogColor[2], Settings.FogColor[3])
    end

    if Settings.Xray then
        for _, p in pairs(Workspace:GetDescendants()) do
            if p:IsA("BasePart") and p.Transparency < 0.5 and not p:IsDescendantOf(char) then
                p.LocalTransparencyModifier = 0.6
            end
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (not Settings.TeamCheck or isEnemy(p)) and p.Character then
            local head = getHead(p.Character)
            if head then
                if Settings.HitboxExpander then
                    head.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                    head.Transparency = 0.5
                    head.CanCollide = false
                else
                    head.Size = Vector3.new(2,1,1)
                    head.Transparency = 0
                end
            end
        end
    end

    if Settings.Killaura then
        for _, p in pairs(Players:GetPlayers()) do
            local eRoot = getRoot(p.Character)
            if p ~= LocalPlayer and isEnemy(p) and p.Character and eRoot then
                if (hrp.Position - eRoot.Position).Magnitude < Settings.KillauraRange then
                    pcall(function() mouse1click() end)
                end
            end
        end
    end

    if Settings.Aimbot then
        local targetPart, minDst = nil, Settings.AimFOV
        local mousePos = UserInputService:GetMouseLocation()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isEnemy(p) and p.Character then
                local hum = getHumanoid(p.Character)
                if hum and hum.Health > 0 then
                    local part = getAimPart(p)
                    if part and isVisible(part) then
                        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dst = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                            if dst < minDst then minDst = dst; targetPart = part end
                        end
                    end
                end
            end
        end
        if targetPart then
            local predictedPos = targetPart.Position
            if Settings.AimPrediction > 0 then
                predictedPos = targetPart.Position + (targetPart.AssemblyLinearVelocity * Settings.AimPrediction)
            end
            local goalCF = CFrame.new(Camera.CFrame.Position, predictedPos)
            Camera.CFrame = Camera.CFrame:Lerp(goalCF, 1 / Settings.AimSmooth)
        end
    end
end))

-- ==========================================================
--  ChatFlood
-- ==========================================================
trackConn(task.spawn(function()
    while getgenv().MellHackLoaded do
        if Settings.ChatFlood and Settings.FloodText ~= "" then
            pcall(function()
                if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                    local ch = TextChatService.TextChannels.RBXGeneral
                    if ch then ch:SendAsync(Settings.FloodText) end
                else
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents
                        .SayMessageRequest:FireServer(Settings.FloodText, "All")
                end
            end)
        end
        task.wait(Settings.FloodDelay)
    end
end))

trackConn(LocalPlayer.Idled:Connect(function()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end))

-- ==========================================================
--  Unload
-- ==========================================================
getgenv().MellHackUnload = function()
    getgenv().MellHackLoaded = false
    for _, conn in pairs(Connections) do
        if conn and conn.Connected then pcall(function() conn:Disconnect() end) end
    end
    for _, obj in pairs(ObjectsToCleanup) do
        if obj and obj.Parent then pcall(function() obj:Destroy() end) end
    end
    pcall(function()
        if ESPGui then ESPGui:Destroy() end
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        Camera.FieldOfView = 70
        for _, name in ipairs({"MellCustomSky","MellBloom","MellCC","MellSunRays","MellDOF","MellBlur"}) do
            local o = Lighting:FindFirstChild(name)
            if o then o:Destroy() end
        end
        if _G.fly_rp then _G.fly_rp:Destroy() end
        if _G.fly_bg then _G.fly_bg:Destroy() end
    end)
end

-- ==========================================================
--  Init
-- ==========================================================
task.defer(ApplyMenuColorsToTheme)

WindUI:Notify({
    Title    = "MellHack",
    Content  = "MellHack успешно загружен",
    Duration = 6,
    Icon     = "check",
})

safeLog("loaded successfully")