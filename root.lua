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
local SoundService     = game:GetService("SoundService")
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

local Window = WindUI:CreateWindow({
    Title    = "MellHack",
    Author   = "@ruzoxu",
    Icon     = "rbxassetid://120997033468887",
    Size     = UDim2.fromOffset(600, 480),
    MinSize  = Vector2.new(480, 400),
    MaxSize  = Vector2.new(950, 720),
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

    DroneEnabled     = false,
    DroneSpeed       = 200,
    DroneAccel       = 8,
    DroneCamera      = "TPV",
    DroneDamage      = 100,
    DroneHUDCorner   = "TR",
    DroneShowExplosion = true,
    DroneKnockback   = true,
    DroneAutoDestroy = true,
    DroneCameraBack  = 10,
    DroneFPVEffects  = true,
    DroneFPVFOV      = 100,
    DroneFPVShake    = true,
    DroneShowVignette = true,
    DroneSoundVolume = 0.6,
}

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

do
    local userPanel = Instance.new("Frame")
    userPanel.Name = "MellUserPanel"
    userPanel.Size = UDim2.fromOffset(180, 48)
    userPanel.Position = UDim2.new(0, 16, 1, -64)
    userPanel.AnchorPoint = Vector2.new(0, 0)
    userPanel.BackgroundColor3 = Settings.ColorPanel
    userPanel.BackgroundTransparency = 0.35
    userPanel.BorderSizePixel = 0
    userPanel.ZIndex = 99999
    userPanel.Parent = WindUI and WindUI.ScreenGui or ESPGui
    trackObj(userPanel)

    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(0, 12)
    pc.Parent = userPanel

    local ps = Instance.new("UIStroke")
    ps.Color = Settings.ColorMenu
    ps.Thickness = 1.5
    ps.Transparency = 0.35
    ps.Parent = userPanel

    local avatarFrame = Instance.new("Frame")
    avatarFrame.Name = "AvatarFrame"
    avatarFrame.Size = UDim2.fromOffset(36, 36)
    avatarFrame.Position = UDim2.new(0, 6, 0.5, -18)
    avatarFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    avatarFrame.BackgroundTransparency = 0.4
    avatarFrame.BorderSizePixel = 0
    avatarFrame.ZIndex = 100000
    avatarFrame.Parent = userPanel

    local ac = Instance.new("UICorner")
    ac.CornerRadius = UDim.new(1, 0)
    ac.Parent = avatarFrame

    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Size = UDim2.fromScale(1, 1)
    avatar.BackgroundTransparency = 1
    avatar.ZIndex = 100001
    avatar.Parent = avatarFrame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, -50, 0, 18)
    nameLabel.Position = UDim2.new(0, 48, 0, 8)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = Settings.ColorText
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = LocalPlayer.DisplayName
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.ZIndex = 100000
    nameLabel.Parent = userPanel
    trackObj(nameLabel)

    local userLabel = Instance.new("TextLabel")
    userLabel.Name = "Username"
    userLabel.BackgroundTransparency = 1
    userLabel.Size = UDim2.new(1, -50, 0, 14)
    userLabel.Position = UDim2.new(0, 48, 0, 26)
    userLabel.Font = Enum.Font.Gotham
    userLabel.TextSize = 11
    userLabel.TextColor3 = Settings.ColorSubText
    userLabel.TextXAlignment = Enum.TextXAlignment.Left
    userLabel.Text = "@" .. LocalPlayer.Name
    userLabel.TextTruncate = Enum.TextTruncate.AtEnd
    userLabel.ZIndex = 100000
    userLabel.Parent = userPanel
    trackObj(userLabel)

    task.spawn(function()
        local ok, image = pcall(function()
            return Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size150x150
            )
        end)
        if ok and image then
            avatar.Image = image
        end
    end)

    local function updateUserPanel()
        if userPanel then userPanel.BackgroundColor3 = Settings.ColorPanel end
        if ps then ps.Color = Settings.ColorMenu end
        if nameLabel then nameLabel.TextColor3 = Settings.ColorText end
        if userLabel then userLabel.TextColor3 = Settings.ColorSubText end
    end
    task.spawn(function()
        while getgenv().MellHackLoaded do
            task.wait(1)
            updateUserPanel()
        end
    end)
end

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
        if child:IsA("Tool") then child.Activated:Connect(onToolActivated) end
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
    if child:IsA("Tool") then child.Activated:Connect(onToolActivated) end
end))

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

local CONFIG_ROOT   = "MellHack"
local CONFIG_DIR    = CONFIG_ROOT .. "/configs"
local AUTOLOAD_FILE = CONFIG_ROOT .. "/autoload.txt"

local function ensureDirs()
    if not isfolder then return end
    if not isfolder(CONFIG_ROOT) then pcall(makefolder, CONFIG_ROOT) end
    if not isfolder(CONFIG_DIR) then pcall(makefolder, CONFIG_DIR) end
end
ensureDirs()

local function sanitizeName(name)
    name = tostring(name or ""):gsub("[^%w_%-%s]", "")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    if #name == 0 then name = "MellHack" end
    if #name > 50 then name = name:sub(1, 50) end
    return name
end

local function serializeSettings()
    local out = {}
    for k, v in pairs(Settings) do
        if typeof(v) == "Color3" then
            out[k] = { __color = true, r = v.R, g = v.G, b = v.B }
        else
            out[k] = v
        end
    end
    return out
end

local function deserializeSettings(tbl)
    for k, v in pairs(tbl) do
        if type(v) == "table" and v.__color then
            Settings[k] = Color3.new(v.r, v.g, v.b)
        else
            Settings[k] = v
        end
    end
end

local function nextDefaultName()
    local i = 1
    while true do
        local name = string.format("MellHack_%02d", i)
        local path = CONFIG_DIR .. "/" .. name .. ".json"
        if not (isfile and isfile(path)) then return name end
        i = i + 1
        if i > 999 then return "MellHack_" .. tostring(os.time()) end
    end
end

local function configExists(name)
    if not isfile then return false end
    return isfile(CONFIG_DIR .. "/" .. sanitizeName(name) .. ".json")
end

local function saveConfigAs(name)
    if not (writefile and isfolder) then return false end
    ensureDirs()
    name = sanitizeName(name)
    local path = CONFIG_DIR .. "/" .. name .. ".json"
    local payload = {
        __meta = { name = name, created = os.time(), author = LocalPlayer.Name, placeId = game.PlaceId, version = "12.0" },
        settings = serializeSettings(),
    }
    local ok, json = pcall(function() return HttpService:JSONEncode(payload) end)
    if not ok then return false end
    pcall(writefile, path, json)
    return true
end

local function loadConfigByName(name)
    if not (isfile and readfile) then return false end
    name = sanitizeName(name)
    local path = CONFIG_DIR .. "/" .. name .. ".json"
    if not isfile(path) then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if not ok or not data then return false end
    deserializeSettings(data.settings or data)
    ApplyMenuColorsToTheme()
    return true
end

local function deleteConfigByName(name)
    if not (delfile and isfile) then return false end
    name = sanitizeName(name)
    local path = CONFIG_DIR .. "/" .. name .. ".json"
    if not isfile(path) then return false end
    pcall(delfile, path)
    return true
end

local function renameConfig(oldName, newName)
    if not (readfile and writefile and delfile and isfile) then return false end
    oldName = sanitizeName(oldName)
    newName = sanitizeName(newName)
    if oldName == newName then return true end
    local oldPath = CONFIG_DIR .. "/" .. oldName .. ".json"
    local newPath = CONFIG_DIR .. "/" .. newName .. ".json"
    if not isfile(oldPath) then return false end
    if isfile(newPath) then return false end
    local ok, content = pcall(readfile, oldPath)
    if not ok then return false end
    local parsedOk, parsed = pcall(function() return HttpService:JSONDecode(content) end)
    if parsedOk and parsed and parsed.__meta then
        parsed.__meta.name = newName
        local encOk, encoded = pcall(function() return HttpService:JSONEncode(parsed) end)
        if encOk then content = encoded end
    end
    pcall(writefile, newPath, content)
    pcall(delfile, oldPath)
    return true
end

local function listConfigs()
    local out = {}
    if not (listfiles and isfolder) then return out end
    if not isfolder(CONFIG_DIR) then return out end
    for _, f in ipairs(listfiles(CONFIG_DIR)) do
        local name = f:match("([^/\\]+)%.json$")
        if name then table.insert(out, name) end
    end
    table.sort(out)
    return out
end

local function getConfigJSON(name)
    if not (isfile and readfile) then return nil end
    name = sanitizeName(name)
    local path = CONFIG_DIR .. "/" .. name .. ".json"
    if not isfile(path) then return nil end
    local ok, content = pcall(readfile, path)
    if ok then return content end
    return nil
end

local function copyConfigToClipboard(name)
    local json = getConfigJSON(name)
    if not json then return false end
    if setclipboard then
        pcall(setclipboard, json)
        WindUI:Notify({ Title = "MellHack", Content = "JSON copied: " .. name, Icon = "check", Duration = 3 })
        return true
    end
    return false
end

local function importConfigFromJSON(json, saveAs)
    if not (writefile and isfolder) then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(json) end)
    if not ok or not data then
        WindUI:Notify({ Title = "MellHack", Content = "Invalid JSON", Icon = "x", Duration = 4 })
        return false
    end
    ensureDirs()
    local name
    if saveAs and #saveAs > 0 then
        name = sanitizeName(saveAs)
        if configExists(name) then name = name .. "_" .. tostring(os.time() % 10000) end
    else
        name = (data.__meta and sanitizeName(data.__meta.name)) or nextDefaultName()
        if configExists(name) then name = name .. "_" .. tostring(os.time() % 10000) end
    end
    local payload
    if data.settings then
        payload = data
        payload.__meta = payload.__meta or { name = name, created = os.time(), version = "12.0" }
        payload.__meta.name = name
    else
        payload = { __meta = { name = name, created = os.time(), version = "12.0" }, settings = data }
    end
    local encOk, encoded = pcall(function() return HttpService:JSONEncode(payload) end)
    if not encOk then return false end
    pcall(writefile, CONFIG_DIR .. "/" .. name .. ".json", encoded)
    WindUI:Notify({ Title = "MellHack", Content = "Imported: " .. name, Icon = "check", Duration = 3 })
    return true
end

local function getAutoLoadName()
    if not (isfile and readfile) then return nil end
    if not isfile(AUTOLOAD_FILE) then return nil end
    local ok, name = pcall(readfile, AUTOLOAD_FILE)
    if ok and name and #name > 0 then return name end
    return nil
end
local function setAutoLoadName(name)
    if not writefile then return end
    ensureDirs()
    pcall(writefile, AUTOLOAD_FILE, tostring(name or ""))
end

local autoName = getAutoLoadName()
if autoName and #autoName > 0 and configExists(autoName) then
    task.defer(function()
        task.wait(1)
        loadConfigByName(autoName)
        WindUI:Notify({ Title = "MellHack", Content = "Auto-loaded: " .. autoName, Icon = "check", Duration = 3 })
    end)
end

local Drone = {
    model        = nil,
    base         = nil,
    hum          = nil,
    hrp          = nil,
    oldCameraType   = nil,
    oldCameraSubject= nil,
    oldFOV       = nil,
    active       = false,
    lastHit      = "",
    hitTimer     = 0,
    props        = {},
    destroyed    = false,
    deathTimer   = 0,
    currentVel   = Vector3.new(0,0,0),
    droneCF      = CFrame.new(),
    fpvShakeOff  = Vector3.new(0,0,0),
    fpvRoll      = 0,
    camYaw       = 0,
    camPitch     = -0.15,
    soundEngine  = nil,
    soundStartup = nil,
    soundHit     = nil,
}

local SOUND_ENGINE  = "rbxassetid://9120386436"
local SOUND_STARTUP = "rbxassetid://9125402237"
local SOUND_HIT     = "rbxassetid://9120386675"

local function createSounds()
    local engine = Instance.new("Sound")
    engine.Name = "MellDroneEngine"
    engine.SoundId = SOUND_ENGINE
    engine.Looped = true
    engine.Volume = 0
    engine.PlaybackSpeed = 1
    engine.Parent = SoundService
    trackObj(engine)
    Drone.soundEngine = engine

    local startup = Instance.new("Sound")
    startup.Name = "MellDroneStartup"
    startup.SoundId = SOUND_STARTUP
    startup.Looped = false
    startup.Volume = Settings.DroneSoundVolume
    startup.Parent = SoundService
    trackObj(startup)
    Drone.soundStartup = startup

    local hitSnd = Instance.new("Sound")
    hitSnd.Name = "MellDroneHit"
    hitSnd.SoundId = SOUND_HIT
    hitSnd.Looped = false
    hitSnd.Volume = Settings.DroneSoundVolume
    hitSnd.Parent = SoundService
    trackObj(hitSnd)
    Drone.soundHit = hitSnd
end

local function buildDroneModel()
    local model = Instance.new("Model")
    model.Name = "MellDroneAdvanced"

    local DARK   = Color3.fromRGB(22, 24, 30)
    local DARKER = Color3.fromRGB(12, 13, 16)
    local LIGHT  = Color3.fromRGB(210, 215, 225)
    local GRAY   = Color3.fromRGB(60, 64, 72)
    local ACCENT = Color3.fromRGB(255, 40, 90)

    local core = Instance.new("Part")
    core.Name = "CoreBody"
    core.Size = Vector3.new(1.6, 0.45, 2.8)
    core.Color = DARK
    core.Material = Enum.Material.SmoothPlastic
    core.Anchored = true
    core.CanCollide = true
    core.Massless = false
    core.Parent = model
    model.PrimaryPart = core

    local hullTop = Instance.new("Part")
    hullTop.Name = "HullTop"
    hullTop.Size = Vector3.new(1.3, 0.2, 2.4)
    hullTop.Color = DARKER
    hullTop.Material = Enum.Material.SmoothPlastic
    hullTop.Anchored = true
    hullTop.CanCollide = false
    hullTop.Massless = true
    hullTop.Parent = model
    hullTop.CFrame = core.CFrame * CFrame.new(0, 0.3, 0)

    local neonStripe = Instance.new("Part")
    neonStripe.Name = "NeonStripe"
    neonStripe.Size = Vector3.new(1.62, 0.06, 0.2)
    neonStripe.Color = ACCENT
    neonStripe.Material = Enum.Material.Neon
    neonStripe.Anchored = true
    neonStripe.CanCollide = false
    neonStripe.Massless = true
    neonStripe.Parent = model
    neonStripe.CFrame = core.CFrame * CFrame.new(0, 0.32, 0)

    local nosePart = Instance.new("Part")
    nosePart.Name = "NosePart"
    nosePart.Shape = Enum.PartType.Ball
    nosePart.Size = Vector3.new(1.3, 0.35, 0.8)
    nosePart.Color = DARK
    nosePart.Material = Enum.Material.SmoothPlastic
    nosePart.Anchored = true
    nosePart.CanCollide = false
    nosePart.Massless = true
    nosePart.Parent = model
    nosePart.CFrame = core.CFrame * CFrame.new(0, 0, -1.35)

    local gimbalHolder = Instance.new("Part")
    gimbalHolder.Name = "GimbalHolder"
    gimbalHolder.Size = Vector3.new(0.5, 0.25, 0.5)
    gimbalHolder.Color = GRAY
    gimbalHolder.Material = Enum.Material.SmoothPlastic
    gimbalHolder.Anchored = true
    gimbalHolder.CanCollide = false
    gimbalHolder.Massless = true
    gimbalHolder.Parent = model
    gimbalHolder.CFrame = core.CFrame * CFrame.new(0, -0.5, -0.6)

    local camCore = Instance.new("Part")
    camCore.Name = "CameraCore"
    camCore.Shape = Enum.PartType.Ball
    camCore.Size = Vector3.new(0.6, 0.6, 0.6)
    camCore.Color = DARKER
    camCore.Material = Enum.Material.SmoothPlastic
    camCore.Anchored = true
    camCore.CanCollide = false
    camCore.Massless = true
    camCore.Parent = model
    camCore.CFrame = core.CFrame * CFrame.new(0, -0.65, -0.6)

    local lens = Instance.new("Part")
    lens.Name = "Lens"
    lens.Shape = Enum.PartType.Cylinder
    lens.Size = Vector3.new(0.08, 0.36, 0.36)
    lens.Color = Color3.fromRGB(5, 8, 15)
    lens.Material = Enum.Material.Glass
    lens.Transparency = 0.05
    lens.Anchored = true
    lens.CanCollide = false
    lens.Massless = true
    lens.Parent = model
    lens.CFrame = core.CFrame * CFrame.new(0, -0.65, -0.9) * CFrame.Angles(0, 0, math.rad(90))

    for i, data in ipairs({
        { pos = Vector3.new( 0.6, -0.45,  0.8) },
        { pos = Vector3.new(-0.6, -0.45,  0.8) },
        { pos = Vector3.new( 0.6, -0.45, -0.5) },
        { pos = Vector3.new(-0.6, -0.45, -0.5) },
    }) do
        local leg = Instance.new("Part")
        leg.Size = Vector3.new(0.09, 0.4, 0.09)
        leg.Color = DARKER
        leg.Material = Enum.Material.SmoothPlastic
        leg.Anchored = true
        leg.CanCollide = false
        leg.Massless = true
        leg.Parent = model
        leg.CFrame = core.CFrame * CFrame.new(data.pos)

        local pad = Instance.new("Part")
        pad.Size = Vector3.new(0.14, 0.05, 0.32)
        pad.Color = DARKER
        pad.Material = Enum.Material.SmoothPlastic
        pad.Anchored = true
        pad.CanCollide = false
        pad.Massless = true
        pad.Parent = model
        pad.CFrame = core.CFrame * CFrame.new(data.pos.X, data.pos.Y - 0.2, data.pos.Z)
    end

    for i, data in ipairs({
        { off = Vector3.new( 1.6, 0.05,  1.6) },
        { off = Vector3.new(-1.6, 0.05,  1.6) },
        { off = Vector3.new( 1.6, 0.05, -1.6) },
        { off = Vector3.new(-1.6, 0.05, -1.6) },
    }) do
        local off = data.off
        local armAngle = math.atan2(off.X, off.Z)

        local arm = Instance.new("Part")
        arm.Size = Vector3.new(2.4, 0.16, 0.26)
        arm.Color = DARK
        arm.Material = Enum.Material.SmoothPlastic
        arm.Anchored = true
        arm.CanCollide = false
        arm.Massless = true
        arm.Parent = model
        arm.CFrame = core.CFrame * CFrame.new(off.X / 2, off.Y, off.Z / 2) * CFrame.Angles(0, armAngle, 0)

        local motor = Instance.new("Part")
        motor.Shape = Enum.PartType.Cylinder
        motor.Size = Vector3.new(0.48, 0.52, 0.52)
        motor.Color = DARKER
        motor.Material = Enum.Material.SmoothPlastic
        motor.Anchored = true
        motor.CanCollide = false
        motor.Massless = true
        motor.Parent = model
        motor.CFrame = core.CFrame * CFrame.new(off) * CFrame.Angles(0, 0, math.rad(90))

        local blade1 = Instance.new("Part")
        blade1.Size = Vector3.new(2.1, 0.025, 0.16)
        blade1.Color = LIGHT
        blade1.Material = Enum.Material.SmoothPlastic
        blade1.Transparency = 0.05
        blade1.Anchored = true
        blade1.CanCollide = false
        blade1.Massless = true
        blade1.Parent = model
        blade1.CFrame = core.CFrame * CFrame.new(off + Vector3.new(0, 0.34, 0))

        local blade2 = Instance.new("Part")
        blade2.Size = Vector3.new(0.16, 0.025, 2.1)
        blade2.Color = LIGHT
        blade2.Material = Enum.Material.SmoothPlastic
        blade2.Transparency = 0.05
        blade2.Anchored = true
        blade2.CanCollide = false
        blade2.Massless = true
        blade2.Parent = model
        blade2.CFrame = core.CFrame * CFrame.new(off + Vector3.new(0, 0.34, 0))

        local blur = Instance.new("Part")
        blur.Shape = Enum.PartType.Cylinder
        blur.Size = Vector3.new(0.02, 2.0, 2.0)
        blur.Material = Enum.Material.Neon
        blur.Color = Color3.fromRGB(200, 210, 230)
        blur.Transparency = 0.85
        blur.Anchored = true
        blur.CanCollide = false
        blur.Massless = true
        blur.Parent = model
        blur.CFrame = core.CFrame * CFrame.new(off + Vector3.new(0, 0.35, 0)) * CFrame.Angles(0, 0, math.rad(90))

        table.insert(Drone.props, {
            core = core,
            blades = {blade1, blade2},
            blur = blur,
            baseLocalCF = CFrame.new(off + Vector3.new(0, 0.34, 0)),
            baseLocalBlurCF = CFrame.new(off + Vector3.new(0, 0.35, 0)) * CFrame.Angles(0, 0, math.rad(90)),
        })
    end

    return model
end

local function setDroneCFrame(model, core, targetCF)
    local oldCoreCF = core.CFrame
    local delta = targetCF * oldCoreCF:Inverse()

    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CFrame = delta * part.CFrame
        end
    end
end

local function destroyDroneModel()
    if Drone.model then
        pcall(function() Drone.model:Destroy() end)
    end
    Drone.model = nil
    Drone.base = nil
    Drone.props = {}
end

local function setCharacterHidden(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, p in pairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.Transparency = state and 1 or 0
            p.CanCollide = not state
        elseif p:IsA("Decal") then
            p.Transparency = state and 1 or 0
        end
    end
end

local function spawnExplosion(position)
    if not Settings.DroneShowExplosion then return end
    pcall(function()
        local exp = Instance.new("Explosion")
        exp.Position = position
        exp.BlastRadius = 8
        exp.BlastPressure = 0
        exp.DestroyJointRadiusPercent = 0
        exp.ExplosionType = Enum.ExplosionType.NoCraters
        exp.Parent = Workspace
    end)

    local ball = Instance.new("Part")
    ball.Shape = Enum.PartType.Ball
    ball.Size = Vector3.new(3, 3, 3)
    ball.Material = Enum.Material.Neon
    ball.Color = Color3.fromRGB(255, 160, 30)
    ball.Anchored = true
    ball.CanCollide = false
    ball.CFrame = CFrame.new(position)
    ball.Parent = Workspace

    TweenService:Create(ball, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(16, 16, 16),
        Transparency = 1,
    }):Play()

    task.delay(0.45, function()
        pcall(function() ball:Destroy() end)
    end)
end

local function knockbackPlayer(player, fromPos)
    if not Settings.DroneKnockback then return end
    local char = player.Character
    if not char then return end
    local hrp = getRoot(char)
    if not hrp then return end
    local dir = (hrp.Position - fromPos)
    if dir.Magnitude < 0.1 then dir = Vector3.new(0, 1, 0) end
    dir = dir.Unit
    hrp.AssemblyLinearVelocity = dir * 90 + Vector3.new(0, 45, 0)
end

local function tryDamagePlayer(player)
    local char = player.Character
    if not char then return end
    local hum = getHumanoid(char)
    if not hum then return end
    pcall(function() hum:TakeDamage(Settings.DroneDamage) end)
end

local function triggerDroneCrash(position)
    if Drone.destroyed then return end
    Drone.destroyed = true
    Drone.deathTimer = 1.0

    if Drone.soundHit then
        pcall(function()
            Drone.soundHit.Volume = Settings.DroneSoundVolume
            Drone.soundHit:Play()
        end)
    end

    spawnExplosion(position)

    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude
    overlapParams.FilterDescendantsInstances = {Drone.model, LocalPlayer.Character}

    local partsInRadius = Workspace:GetPartsInPart(Drone.base, overlapParams)
    local hitPlayers = {}
    for _, part in ipairs(partsInRadius) do
        local char = part.Parent
        local plr = Players:GetPlayerFromCharacter(char)
        if plr and plr ~= LocalPlayer and not hitPlayers[plr] then
            if not Settings.TeamCheck or plr.Team ~= LocalPlayer.Team then
                hitPlayers[plr] = true
                knockbackPlayer(plr, position)
                tryDamagePlayer(plr)
            end
        end
    end

    WindUI:Notify({
        Title = "Drone",
        Content = "BOOM! Crash detected. Respawning new drone...",
        Icon = "bomb",
        Duration = 3,
    })

    task.delay(1.0, function()
        if Drone.active then
            Drone:Stop()
            task.wait(0.2)
            Drone:Start()
        end
    end)
end

function Drone:Start()
    if self.active then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = getHumanoid(char)
    local hrp = getRoot(char)
    if not hum or not hrp then return end

    self.hum = hum
    self.hrp = hrp
    self.destroyed = false
    self.lastHit = ""
    self.props = {}
    self.currentVel = Vector3.new(0,0,0)
    self.droneCF = hrp.CFrame * CFrame.new(0, 4, 0)
    self.fpvShakeOff = Vector3.new(0,0,0)
    self.fpvRoll = 0

    local lookDir = Camera.CFrame.LookVector
    self.camYaw = math.atan2(-lookDir.X, -lookDir.Z)
    self.camPitch = math.asin(math.clamp(lookDir.Y, -1, 1))

    setCharacterHidden(true)

    local model = buildDroneModel()
    model.Parent = Workspace
    self.model = model
    self.base = model.PrimaryPart
    self.base.CFrame = self.droneCF

    setDroneCFrame(model, self.base, self.droneCF)

    if not self.soundEngine then createSounds() end
    if self.soundStartup then
        pcall(function()
            self.soundStartup.Volume = Settings.DroneSoundVolume
            self.soundStartup:Play()
        end)
    end
    if self.soundEngine then
        task.delay(0.4, function()
            pcall(function()
                if Drone.active and Drone.soundEngine then
                    Drone.soundEngine.Volume = Settings.DroneSoundVolume * 0.6
                    Drone.soundEngine:Play()
                end
            end)
        end)
    end

    self.oldCameraType = Camera.CameraType
    self.oldCameraSubject = Camera.CameraSubject
    self.oldFOV = Camera.FieldOfView
    Camera.CameraType = Enum.CameraType.Scriptable

    pcall(function()
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end)

    self.active = true
    WindUI:Notify({ Title = "Drone", Content = "New drone deployed!", Icon = "plane", Duration = 2 })
end

function Drone:Stop()
    if not self.active then return end
    self.active = false
    self.destroyed = false

    destroyDroneModel()
    setCharacterHidden(false)

    if self.soundEngine then
        pcall(function()
            TweenService:Create(self.soundEngine, TweenInfo.new(0.4), {Volume = 0}):Play()
        end)
        task.delay(0.5, function()
            pcall(function()
                if Drone.soundEngine then
                    Drone.soundEngine:Stop()
                    Drone.soundEngine.Volume = 0
                end
            end)
        end)
    end

    pcall(function()
        Camera.CameraType = self.oldCameraType or Enum.CameraType.Custom
        Camera.CameraSubject = self.oldCameraSubject or self.hum
        if self.oldFOV then Camera.FieldOfView = self.oldFOV end
    end)
end

local fpvVignette = Instance.new("Frame")
fpvVignette.Name = "MellFPVVignette"
fpvVignette.Size = UDim2.fromScale(1, 1)
fpvVignette.BackgroundTransparency = 1
fpvVignette.BorderSizePixel = 0
fpvVignette.Visible = false
fpvVignette.ZIndex = 50
fpvVignette.Parent = ESPGui
trackObj(fpvVignette)

local function addVignetteSide(pos, size)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos
    f.BorderSizePixel = 0
    f.BackgroundColor3 = Color3.new(0,0,0)
    f.BackgroundTransparency = 0.35
    f.ZIndex = 50
    f.Parent = fpvVignette
    return f
end

local vTop    = addVignetteSide(UDim2.fromScale(0, 0),     UDim2.fromScale(1, 0.12))
local vBottom = addVignetteSide(UDim2.fromScale(0, 0.88),  UDim2.fromScale(1, 0.12))
local vLeft   = addVignetteSide(UDim2.fromScale(0, 0),     UDim2.fromScale(0.12, 1))
local vRight  = addVignetteSide(UDim2.fromScale(0.88, 0),  UDim2.fromScale(0.12, 1))

local fpvCrosshair = Instance.new("Frame")
fpvCrosshair.Name = "MellFPVCrosshair"
fpvCrosshair.Size = UDim2.fromOffset(40, 40)
fpvCrosshair.Position = UDim2.fromScale(0.5, 0.5)
fpvCrosshair.AnchorPoint = Vector2.new(0.5, 0.5)
fpvCrosshair.BackgroundTransparency = 1
fpvCrosshair.BorderSizePixel = 0
fpvCrosshair.Visible = false
fpvCrosshair.ZIndex = 51
fpvCrosshair.Parent = ESPGui
trackObj(fpvCrosshair)

local function mkCrossBar(pos, size)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = Color3.fromRGB(255, 40, 90)
    f.BorderSizePixel = 0
    f.Position = pos
    f.Size = size
    f.ZIndex = 51
    f.Parent = fpvCrosshair
    return f
end
mkCrossBar(UDim2.fromOffset(19, 4), UDim2.fromOffset(2, 12))
mkCrossBar(UDim2.fromOffset(19, 24), UDim2.fromOffset(2, 12))
mkCrossBar(UDim2.fromOffset(4, 19), UDim2.fromOffset(12, 2))
mkCrossBar(UDim2.fromOffset(24, 19), UDim2.fromOffset(12, 2))

local fpvInfo = Instance.new("TextLabel")
fpvInfo.Name = "MellFPVInfo"
fpvInfo.BackgroundTransparency = 1
fpvInfo.Size = UDim2.fromOffset(200, 20)
fpvInfo.Position = UDim2.new(0, 20, 1, -40)
fpvInfo.AnchorPoint = Vector2.new(0, 1)
fpvInfo.Font = Enum.Font.Code
fpvInfo.TextSize = 14
fpvInfo.TextColor3 = Color3.fromRGB(255, 40, 90)
fpvInfo.TextStrokeTransparency = 0.5
fpvInfo.TextXAlignment = Enum.TextXAlignment.Left
fpvInfo.Text = "VEL 000 | CAM FPV"
fpvInfo.Visible = false
fpvInfo.ZIndex = 51
fpvInfo.Parent = ESPGui
trackObj(fpvInfo)

local MobileCamControl = {
    active = false,
    lastPos = nil,
    touchInput = nil,
    sens = 0.005,
}

trackConn(UserInputService.TouchStarted:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not Drone.active then return end
    local screenX = input.Position.X
    local halfX = Camera.ViewportSize.X / 2
    if screenX > halfX then
        MobileCamControl.active = true
        MobileCamControl.lastPos = Vector2.new(input.Position.X, input.Position.Y)
        MobileCamControl.touchInput = input
    end
end))

trackConn(UserInputService.TouchMoved:Connect(function(input, gameProcessed)
    if not Drone.active then return end
    if not MobileCamControl.active then return end
    if MobileCamControl.touchInput and input ~= MobileCamControl.touchInput then return end

    local currentPos = Vector2.new(input.Position.X, input.Position.Y)
    if MobileCamControl.lastPos then
        local delta = currentPos - MobileCamControl.lastPos
        Drone.camYaw = Drone.camYaw - delta.X * MobileCamControl.sens
        Drone.camPitch = math.clamp(
            Drone.camPitch + delta.Y * MobileCamControl.sens,
            -math.rad(85),
            math.rad(85)
        )
    end
    MobileCamControl.lastPos = currentPos
end))

trackConn(UserInputService.TouchEnded:Connect(function(input, gameProcessed)
    if MobileCamControl.touchInput and input == MobileCamControl.touchInput then
        MobileCamControl.active = false
        MobileCamControl.touchInput = nil
        MobileCamControl.lastPos = nil
    end
end))

local pcLookActive = false
trackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not Drone.active then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        pcLookActive = true
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrent
    end
end))

trackConn(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        pcLookActive = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end))

trackConn(UserInputService.InputChanged:Connect(function(input)
    if not Drone.active then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement and (pcLookActive or Settings.DroneCamera == "FPV") then
        local delta = input.Delta
        Drone.camYaw = Drone.camYaw - delta.X * 0.004
        Drone.camPitch = math.clamp(
            Drone.camPitch - delta.Y * 0.004,
            -math.rad(85),
            math.rad(85)
        )
    end
end))

local mobileJumpHeld = false
trackConn(UserInputService.JumpRequest:Connect(function()
    if Drone.active then
        mobileJumpHeld = true
        task.delay(0.2, function() mobileJumpHeld = false end)
    end
end))

trackConn(RunService.RenderStepped:Connect(function(dt)
    if not Drone.active or not Drone.base then return end
    dt = math.clamp(dt, 0, 0.1)

    if Drone.destroyed then
        Drone.deathTimer = Drone.deathTimer - dt
        Drone.droneCF = Drone.droneCF * CFrame.new(0, -35 * dt, 0)
        if Drone.model then
            setDroneCFrame(Drone.model, Drone.base, Drone.droneCF)
        end
        return
    end

    local moveInput = Vector3.new(0, 0, 0)
    if ControlModule then
        local ok, vec = pcall(function() return ControlModule:GetMoveVector() end)
        if ok and vec then moveInput = vec end
    end

    if moveInput.Magnitude < 0.05 then
        local kb = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then kb += Vector3.new(0, 0, -1) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then kb += Vector3.new(0, 0, 1)  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then kb += Vector3.new(-1, 0, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then kb += Vector3.new(1, 0, 0)  end
        moveInput = kb
    end

    local yaw = Drone.camYaw
    local pitch = Drone.camPitch
    local rotationCF = CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)

    local camCF
    if Settings.DroneCamera == "FPV" then
        local camPos = Drone.droneCF * CFrame.new(0, 0.4, -0.6).Position
        local lookDir = rotationCF * Vector3.new(0, 0, -1)
        camCF = CFrame.lookAt(camPos, camPos + lookDir)
    else
        local camOffset = Settings.DroneCameraBack
        local offset = rotationCF * CFrame.new(0, 0, camOffset)
        local camPos = Drone.droneCF.Position + offset.Position + Vector3.new(0, camOffset * 0.3, 0)
        camCF = CFrame.lookAt(camPos, Drone.droneCF.Position)
    end

    local camLook = rotationCF * Vector3.new(0, 0, -1)
    local moveDir = Vector3.new(0, 0, 0)

    if moveInput.Magnitude > 0.05 then
        local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
        local flatRight = Vector3.new(flatLook.Z, 0, -flatLook.X)
        moveDir = (flatLook * -moveInput.Z) + (flatRight * moveInput.X)
    end

    local vert = 0
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vert = vert + 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vert = vert - 1 end
    if mobileJumpHeld then vert = vert + 1 end

    if vert ~= 0 then
        moveDir = moveDir + Vector3.new(0, vert, 0)
    end

    if moveDir.Magnitude > 1 then
        moveDir = moveDir.Unit
    end

    local targetVel = moveDir * Settings.DroneSpeed
    local accel = math.clamp(Settings.DroneAccel * dt, 0, 1)
    Drone.currentVel = Drone.currentVel:Lerp(targetVel, accel)

    if Drone.currentVel.Magnitude > 0.1 then
        local step = Drone.currentVel * dt
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {Drone.model, LocalPlayer.Character}

        local hit = Workspace:Raycast(Drone.droneCF.Position, step, params)
        if hit then
            triggerDroneCrash(hit.Position)
            return
        else
            Drone.droneCF = Drone.droneCF + step
        end
    end

    local lookDir
    if Drone.currentVel.Magnitude > 5 then
        lookDir = Drone.currentVel.Unit
    else
        lookDir = Vector3.new(camLook.X, 0, camLook.Z)
        if lookDir.Magnitude < 0.01 then lookDir = Vector3.new(0, 0, -1) end
        lookDir = lookDir.Unit
    end

    local pitchAngle = -math.clamp(Drone.currentVel.Magnitude / math.max(Settings.DroneSpeed, 1), 0, 1) * math.rad(15)
    local targetCF = CFrame.lookAt(Drone.droneCF.Position, Drone.droneCF.Position + lookDir) * CFrame.Angles(pitchAngle, 0, 0)

    Drone.droneCF = Drone.droneCF:Lerp(targetCF, 0.3)
    setDroneCFrame(Drone.model, Drone.base, Drone.droneCF)

    Camera.CameraType = Enum.CameraType.Scriptable

    if Settings.DroneCamera == "FPV" then
        local targetFOV = Settings.DroneFPVEffects and Settings.DroneFPVFOV or 90
        Camera.FieldOfView = Camera.FieldOfView + (targetFOV - Camera.FieldOfView) * 0.15

        local speedNorm = math.clamp(Drone.currentVel.Magnitude / math.max(Settings.DroneSpeed, 1), 0, 1)
        local shakeAmp = Settings.DroneFPVShake and (speedNorm * 0.06) or 0
        Drone.fpvShakeOff = Vector3.new(
            (math.random() - 0.5) * shakeAmp,
            (math.random() - 0.5) * shakeAmp,
            0
        )

        local targetRoll = math.rad(-moveInput.X * 5)
        Drone.fpvRoll = Drone.fpvRoll + (targetRoll - Drone.fpvRoll) * 0.15

        Camera.CFrame = camCF * CFrame.Angles(Drone.fpvShakeOff.Y, Drone.fpvShakeOff.X, Drone.fpvRoll)
    else
        Camera.FieldOfView = Camera.FieldOfView + (90 - Camera.FieldOfView) * 0.15
        Camera.CFrame = camCF
    end

    if Drone.soundEngine then
        local speedNorm = math.clamp(Drone.currentVel.Magnitude / math.max(Settings.DroneSpeed, 1), 0, 1)
        local targetVol = Settings.DroneSoundVolume * (0.35 + speedNorm * 0.65)
        local targetPitch = 0.85 + speedNorm * 0.5
        pcall(function()
            Drone.soundEngine.Volume = Drone.soundEngine.Volume + (targetVol - Drone.soundEngine.Volume) * 0.15
            Drone.soundEngine.PlaybackSpeed = Drone.soundEngine.PlaybackSpeed + (targetPitch - Drone.soundEngine.PlaybackSpeed) * 0.15
        end)
    end

    local isFPV = Settings.DroneCamera == "FPV" and Settings.DroneFPVEffects
    fpvVignette.Visible = isFPV and Settings.DroneShowVignette
    fpvCrosshair.Visible = isFPV
    fpvInfo.Visible = isFPV

    if isFPV then
        fpvInfo.Text = string.format("VEL %03d | CAM FPV | SPD %d",
            math.floor(Drone.currentVel.Magnitude),
            Settings.DroneSpeed
        )
    end
end))

local propellerAngle = 0
trackConn(RunService.Heartbeat:Connect(function(dt)
    if not Drone.active or Drone.destroyed then return end
    dt = math.clamp(dt, 0, 0.1)
    propellerAngle = propellerAngle + math.rad(3000) * dt

    local coreCF = Drone.droneCF
    for _, p in ipairs(Drone.props) do
        if p.blades then
            for i, blade in ipairs(p.blades) do
                if blade and blade.Parent then
                    local localRot
                    if i == 1 then
                        localRot = CFrame.Angles(0, propellerAngle, 0)
                    else
                        localRot = CFrame.Angles(0, propellerAngle + math.rad(90), 0)
                    end
                    blade.CFrame = coreCF * p.baseLocalCF * localRot
                end
            end
        end
        if p.blur and p.blur.Parent then
            p.blur.CFrame = coreCF * p.baseLocalBlurCF
            p.blur.Transparency = 0.75 + math.sin(tick() * 35) * 0.05
        end
    end
end))

trackConn(RunService.Heartbeat:Connect(function(dt)
    if Drone.hitTimer > 0 then
        Drone.hitTimer = Drone.hitTimer - dt
    end
end))

local droneHUD = Instance.new("Frame")
droneHUD.Name = "MellDroneHUD"
droneHUD.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
droneHUD.BackgroundTransparency = 0.35
droneHUD.BorderSizePixel = 0
droneHUD.Size = UDim2.fromOffset(220, 120)
droneHUD.Visible = false
droneHUD.Parent = ESPGui
trackObj(droneHUD)

local hudCorner = Instance.new("UICorner")
hudCorner.CornerRadius = UDim.new(0, 10)
hudCorner.Parent = droneHUD

local hudStroke = Instance.new("UIStroke")
hudStroke.Color = Color3.fromRGB(255, 40, 90)
hudStroke.Thickness = 1.5
hudStroke.Transparency = 0.2
hudStroke.Parent = droneHUD

local function setHUDCorner()
    local c = Settings.DroneHUDCorner
    if c == "TL" then
        droneHUD.Position = UDim2.fromOffset(20, 60)
        droneHUD.AnchorPoint = Vector2.new(0, 0)
    elseif c == "TR" then
        droneHUD.Position = UDim2.new(1, -20, 0, 60)
        droneHUD.AnchorPoint = Vector2.new(1, 0)
    elseif c == "BL" then
        droneHUD.Position = UDim2.new(0, 20, 1, -170)
        droneHUD.AnchorPoint = Vector2.new(0, 1)
    else
        droneHUD.Position = UDim2.new(1, -20, 1, -170)
        droneHUD.AnchorPoint = Vector2.new(1, 1)
    end
end
setHUDCorner()

local viewport = Instance.new("ViewportFrame")
viewport.Size = UDim2.fromOffset(90, 90)
viewport.Position = UDim2.fromOffset(10, 15)
viewport.BackgroundTransparency = 1
viewport.Ambient = Color3.fromRGB(180, 180, 180)
viewport.LightColor = Color3.fromRGB(255, 255, 255)
viewport.Parent = droneHUD

local viewCam = Instance.new("Camera")
viewCam.FieldOfView = 45
viewport.CurrentCamera = viewCam

local hudModel = Instance.new("Model")
hudModel.Parent = viewport

local hudCore = Instance.new("Part")
hudCore.Name = "Core"
hudCore.Size = Vector3.new(1.4, 0.35, 2.6)
hudCore.Color = Color3.fromRGB(22, 24, 30)
hudCore.Material = Enum.Material.SmoothPlastic
hudCore.Anchored = true
hudCore.CanCollide = false
hudCore.Parent = hudModel

local hudTitle = Instance.new("TextLabel")
hudTitle.BackgroundTransparency = 1
hudTitle.Position = UDim2.fromOffset(105, 10)
hudTitle.Size = UDim2.fromOffset(110, 20)
hudTitle.Font = Enum.Font.GothamBold
hudTitle.TextSize = 14
hudTitle.TextColor3 = Color3.fromRGB(255, 40, 90)
hudTitle.TextXAlignment = Enum.TextXAlignment.Left
hudTitle.Text = "FPV DRONE"
hudTitle.Parent = droneHUD

local hudSpeed = Instance.new("TextLabel")
hudSpeed.BackgroundTransparency = 1
hudSpeed.Position = UDim2.fromOffset(105, 32)
hudSpeed.Size = UDim2.fromOffset(110, 16)
hudSpeed.Font = Enum.Font.Gotham
hudSpeed.TextSize = 13
hudSpeed.TextColor3 = Color3.fromRGB(240, 238, 245)
hudSpeed.TextXAlignment = Enum.TextXAlignment.Left
hudSpeed.Text = "Speed: 0"
hudSpeed.Parent = droneHUD

local hudMode = Instance.new("TextLabel")
hudMode.BackgroundTransparency = 1
hudMode.Position = UDim2.fromOffset(105, 50)
hudMode.Size = UDim2.fromOffset(110, 16)
hudMode.Font = Enum.Font.Gotham
hudMode.TextSize = 13
hudMode.TextColor3 = Color3.fromRGB(140, 135, 155)
hudMode.TextXAlignment = Enum.TextXAlignment.Left
hudMode.Text = "Mode: TPV"
hudMode.Parent = droneHUD

local hudStatus = Instance.new("TextLabel")
hudStatus.BackgroundTransparency = 1
hudStatus.Position = UDim2.fromOffset(10, 100)
hudStatus.Size = UDim2.fromOffset(200, 14)
hudStatus.Font = Enum.Font.Gotham
hudStatus.TextSize = 11
hudStatus.TextColor3 = Color3.fromRGB(140, 135, 155)
hudStatus.TextXAlignment = Enum.TextXAlignment.Left
hudStatus.Text = "Idle"
hudStatus.Parent = droneHUD

trackConn(RunService.RenderStepped:Connect(function(dt)
    droneHUD.Visible = Drone.active and Settings.DroneEnabled
    if not droneHUD.Visible then return end

    local t = tick() * 1.2
    viewCam.CFrame = CFrame.new(
        hudCore.Position + Vector3.new(math.cos(t) * 6, 3, math.sin(t) * 6),
        hudCore.Position
    )

    hudSpeed.Text = "Speed: " .. math.floor(Drone.currentVel.Magnitude)
    hudMode.Text  = "Mode: " .. Settings.DroneCamera

    if Drone.destroyed then
        hudStatus.Text = "DESTROYED / RESPAWNING"
    elseif Drone.active then
        hudStatus.Text = "FLYING"
    else
        hudStatus.Text = "Idle"
    end
end))

local function notifyState(name, enabled)
    WindUI:Notify({
        Title = "MellHack",
        Content = name .. (enabled and " ON" or " OFF"),
        Icon = enabled and "check" or "x",
        Duration = 2,
    })
end

local TabMovement = Window:Tab({ Title = "Movement",   Icon = "move" })
local TabCombat   = Window:Tab({ Title = "Combat",     Icon = "crosshair" })
local TabVisuals  = Window:Tab({ Title = "Visuals",    Icon = "eye" })
local TabColors   = Window:Tab({ Title = "Colors",     Icon = "palette" })
local TabConfig   = Window:Tab({ Title = "Configs",    Icon = "save" })
local TabDrone    = Window:Tab({ Title = "Drone",      Icon = "plane" })
local TabExtras   = Window:Tab({ Title = "Extras",     Icon = "sparkles" })
local TabShaders  = Window:Tab({ Title = "Shaders",    Icon = "sun" })
local TabRage     = Window:Tab({ Title = "Rage & Fun", Icon = "bomb" })
local TabBinds    = Window:Tab({ Title = "Keybinds",   Icon = "keyboard" })
local TabSettings = Window:Tab({ Title = "Settings",   Icon = "settings" })

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
TabColors:Button({ Title = "Reset All Colors", Icon = "rotate-ccw", Callback = function()
    Settings.ColorMenu = Color3.fromRGB(255, 40, 90)
    Settings.ColorWindow = Color3.fromRGB(16, 16, 22)
    Settings.ColorPanel = Color3.fromRGB(12, 12, 16)
    Settings.ColorText = Color3.fromRGB(240, 238, 245)
    Settings.ColorSubText = Color3.fromRGB(140, 135, 155)
    Settings.ColorBox = Color3.fromRGB(255, 40, 90)
    Settings.ColorTracer = Color3.fromRGB(255, 40, 90)
    Settings.ColorSkeleton = Color3.fromRGB(255, 255, 255)
    Settings.ColorName = Color3.fromRGB(255, 255, 255)
    Settings.ColorHPFull = Color3.fromRGB(0, 255, 80)
    Settings.ColorHPEmpty = Color3.fromRGB(0, 0, 0)
    Settings.ColorFOV = Color3.fromRGB(255, 40, 90)
    Settings.ColorCrosshair = Color3.fromRGB(255, 255, 255)
    Settings.ColorBulletTracer = Color3.fromRGB(255, 200, 0)
    Settings.ColorChams = Color3.fromRGB(255, 40, 90)
    Settings.ColorChamsOutline = Color3.fromRGB(255, 255, 255)
    ApplyMenuColorsToTheme()
    WindUI:Notify({ Title = "MellHack", Content = "Colors reset", Icon = "check", Duration = 3 })
end })

local renameBuffer = ""
local importBuffer = ""

local function rebuildConfigList()
    local list = listConfigs()
    local text = #list == 0 and "No configs yet" or table.concat(list, ", ")
    WindUI:Notify({ Title = "Configs", Content = text, Icon = "list", Duration = 6 })
    return list
end

TabConfig:Section({ Title = "Save / Import" })
TabConfig:Input({
    Title = "New config name (empty = MellHack_NN)",
    Placeholder = "MellHack_01",
    Callback = function(text) renameBuffer = text end,
})
TabConfig:Button({
    Title = "Save New Config",
    Icon = "save",
    Callback = function()
        local name = renameBuffer
        if not name or #name == 0 then name = nextDefaultName() end
        if configExists(name) then name = name .. "_" .. tostring(os.time() % 10000) end
        if saveConfigAs(name) then
            WindUI:Notify({ Title = "MellHack", Content = "Saved: " .. name, Icon = "check", Duration = 3 })
            rebuildConfigList()
        end
    end,
})
TabConfig:Button({
    Title = "Import from clipboard (as new)",
    Icon = "clipboard-paste",
    Callback = function()
        if not getclipboard then
            WindUI:Notify({ Title = "MellHack", Content = "getclipboard unavailable", Icon = "x", Duration = 3 })
            return
        end
        local ok, clip = pcall(getclipboard)
        if not ok or not clip or #clip < 10 then
            WindUI:Notify({ Title = "MellHack", Content = "Clipboard empty", Icon = "x", Duration = 3 })
            return
        end
        if importConfigFromJSON(clip, nil) then rebuildConfigList() end
    end,
})
TabConfig:Input({
    Title = "Paste JSON to import",
    Placeholder = '{"settings":{...}}',
    Callback = function(text) importBuffer = text end,
})
TabConfig:Button({
    Title = "Import JSON above",
    Icon = "import",
    Callback = function()
        if not importBuffer or #importBuffer < 10 then
            WindUI:Notify({ Title = "MellHack", Content = "Paste JSON first", Icon = "x", Duration = 3 })
            return
        end
        if importConfigFromJSON(importBuffer, nil) then rebuildConfigList() end
    end,
})

TabConfig:Section({ Title = "Actions on Current Name" })
TabConfig:Button({
    Title = "Load Current Name",
    Icon = "folder-open",
    Callback = function()
        if not renameBuffer or #renameBuffer == 0 then return end
        if loadConfigByName(renameBuffer) then
            WindUI:Notify({ Title = "MellHack", Content = "Loaded: " .. renameBuffer, Icon = "check", Duration = 3 })
        else
            WindUI:Notify({ Title = "MellHack", Content = "Not found", Icon = "x", Duration = 3 })
        end
    end,
})
TabConfig:Input({
    Title = "Rename: new name",
    Placeholder = "new name",
    Callback = function(text) importBuffer = text end,
})
TabConfig:Button({
    Title = "Confirm Rename (Old → New)",
    Icon = "edit",
    Callback = function()
        if not renameBuffer or #renameBuffer == 0 then
            WindUI:Notify({ Title = "MellHack", Content = "Type OLD name above first", Icon = "x", Duration = 3 })
            return
        end
        if not importBuffer or #importBuffer == 0 then
            WindUI:Notify({ Title = "MellHack", Content = "Type NEW name in 'Rename: new name'", Icon = "x", Duration = 3 })
            return
        end
        if renameConfig(renameBuffer, importBuffer) then
            WindUI:Notify({ Title = "MellHack", Content = "Renamed → " .. importBuffer, Icon = "check", Duration = 3 })
            rebuildConfigList()
        else
            WindUI:Notify({ Title = "MellHack", Content = "Rename failed", Icon = "x", Duration = 3 })
        end
    end,
})
TabConfig:Button({
    Title = "Copy Current as JSON",
    Icon = "copy",
    Callback = function()
        if not renameBuffer or #renameBuffer == 0 then return end
        copyConfigToClipboard(renameBuffer)
    end,
})
TabConfig:Button({
    Title = "Delete Current Name",
    Icon = "trash",
    Callback = function()
        if not renameBuffer or #renameBuffer == 0 then return end
        if deleteConfigByName(renameBuffer) then
            WindUI:Notify({ Title = "MellHack", Content = "Deleted: " .. renameBuffer, Icon = "x", Duration = 3 })
            rebuildConfigList()
        end
    end,
})

TabConfig:Section({ Title = "Auto-Load" })
TabConfig:Button({
    Title = "Set Current Name as Auto-Load",
    Icon = "power",
    Callback = function()
        if not renameBuffer or #renameBuffer == 0 then return end
        setAutoLoadName(renameBuffer)
        WindUI:Notify({ Title = "MellHack", Content = "Auto-load: " .. renameBuffer, Icon = "check", Duration = 3 })
    end,
})
TabConfig:Button({
    Title = "Disable Auto-Load",
    Icon = "x",
    Callback = function()
        setAutoLoadName("")
        WindUI:Notify({ Title = "MellHack", Content = "Auto-load disabled", Icon = "x", Duration = 3 })
    end,
})

TabConfig:Section({ Title = "Your Configs" })
TabConfig:Button({
    Title = "Show Config List",
    Icon = "list",
    Callback = rebuildConfigList,
})

do
    local list = listConfigs()
    if #list > 0 then
        for _, cfg in ipairs(list) do
            TabConfig:Section({ Title = "Config: " .. cfg })
            TabConfig:Button({
                Title = "Load " .. cfg,
                Icon = "folder-open",
                Callback = function()
                    if loadConfigByName(cfg) then
                        WindUI:Notify({ Title = "MellHack", Content = "Loaded: " .. cfg, Icon = "check", Duration = 3 })
                    end
                end,
            })
            TabConfig:Button({
                Title = "Copy JSON of " .. cfg,
                Icon = "copy",
                Callback = function() copyConfigToClipboard(cfg) end,
            })
            TabConfig:Button({
                Title = "Delete " .. cfg,
                Icon = "trash",
                Callback = function()
                    if deleteConfigByName(cfg) then
                        WindUI:Notify({ Title = "MellHack", Content = "Deleted: " .. cfg, Icon = "x", Duration = 3 })
                    end
                end,
            })
        end
    end
end

TabDrone:Section({ Title = "Drone" })
TabDrone:Toggle({
    Title = "Enable Drone",
    Value = false,
    Callback = function(v)
        Settings.DroneEnabled = v
        if v then Drone:Start() else Drone:Stop() end
    end,
})
TabDrone:Slider({
    Title = "Speed",
    Value = { Min = 50, Max = 1000, Default = 200 },
    Callback = function(v) Settings.DroneSpeed = v end,
})
TabDrone:Slider({
    Title = "Acceleration",
    Value = { Min = 1, Max = 20, Default = 8 },
    Callback = function(v) Settings.DroneAccel = v end,
})
TabDrone:Slider({
    Title = "Camera Distance (TPV)",
    Value = { Min = 4, Max = 30, Default = 10 },
    Callback = function(v) Settings.DroneCameraBack = v end,
})
TabDrone:Dropdown({
    Title = "Camera",
    Values = { "FPV", "TPV" },
    Value = "TPV",
    Callback = function(v)
        Settings.DroneCamera = v
        if Drone.active then
            if v == "FPV" and Settings.DroneFPVEffects then
                Camera.FieldOfView = Settings.DroneFPVFOV
            else
                Camera.FieldOfView = 90
            end
        end
    end,
})
TabDrone:Dropdown({
    Title = "HUD Corner",
    Values = { "TL", "TR", "BL", "BR" },
    Value = "TR",
    Callback = function(v)
        Settings.DroneHUDCorner = v
        setHUDCorner()
    end,
})
TabDrone:Slider({
    Title = "Damage on hit",
    Value = { Min = 0, Max = 500, Default = 100 },
    Callback = function(v) Settings.DroneDamage = v end,
})

TabDrone:Section({ Title = "Sound" })
TabDrone:Slider({
    Title = "Sound Volume",
    Value = { Min = 0, Max = 2, Default = 0.6 },
    Callback = function(v)
        Settings.DroneSoundVolume = v
        if Drone.soundEngine then
            Drone.soundEngine.Volume = v * 0.6
        end
    end,
})

TabDrone:Section({ Title = "FPV Effects" })
TabDrone:Toggle({
    Title = "FPV Effects (fish-eye, shake, crosshair)",
    Value = true,
    Callback = function(v) Settings.DroneFPVEffects = v end,
})
TabDrone:Slider({
    Title = "FPV FOV",
    Value = { Min = 70, Max = 130, Default = 100 },
    Callback = function(v) Settings.DroneFPVFOV = v end,
})
TabDrone:Toggle({
    Title = "FPV Shake",
    Value = true,
    Callback = function(v) Settings.DroneFPVShake = v end,
})
TabDrone:Toggle({
    Title = "FPV Vignette",
    Value = true,
    Callback = function(v) Settings.DroneShowVignette = v end,
})

TabDrone:Section({ Title = "Explosion" })
TabDrone:Toggle({
    Title = "Show Explosion",
    Value = true,
    Callback = function(v) Settings.DroneShowExplosion = v end,
})
TabDrone:Toggle({
    Title = "Knockback",
    Value = true,
    Callback = function(v) Settings.DroneKnockback = v end,
})
TabDrone:Toggle({
    Title = "Auto-Destroy on Hit",
    Value = true,
    Callback = function(v) Settings.DroneAutoDestroy = v end,
})

TabDrone:Section({ Title = "Controls" })
TabDrone:Button({
    Title = "Launch Drone",
    Icon = "play",
    Callback = function() Drone:Start() end,
})
TabDrone:Button({
    Title = "Land Drone",
    Icon = "square",
    Callback = function() Drone:Stop() end,
})

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

TabBinds:Section({ Title = "Keybinds" })
TabBinds:Keybind({ Title = "Toggle Fly", Value = "F", Callback = function() Settings.Fly = not Settings.Fly; notifyState("Fly", Settings.Fly) end })
TabBinds:Keybind({ Title = "Toggle Noclip", Value = "G", Callback = function() Settings.Noclip = not Settings.Noclip; notifyState("Noclip", Settings.Noclip) end })
TabBinds:Keybind({ Title = "Toggle Speed", Value = "H", Callback = function() Settings.Speed = not Settings.Speed; notifyState("Speed", Settings.Speed) end })
TabBinds:Keybind({ Title = "Toggle Drone", Value = "J", Callback = function()
    Settings.DroneEnabled = not Settings.DroneEnabled
    if Settings.DroneEnabled then Drone:Start() else Drone:Stop() end
end })

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

trackConn(UserInputService.JumpRequest:Connect(function()
    if not getgenv().MellHackLoaded then return end
    local char = LocalPlayer.Character
    local hum  = getHumanoid(char)
    if Settings.InfiniteJump and char and hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

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

trackConn(RunService.RenderStepped:Connect(function()
    if not getgenv().MellHackLoaded then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = getRoot(char)
    local humanoid = getHumanoid(char)
    if not hrp or not humanoid then return end

    if not Drone.active then
        if Settings.Speed  then humanoid.WalkSpeed = Settings.WalkSpeedVal end
        if Settings.Jump   then humanoid.JumpPower = Settings.JumpPowerVal end
        if Settings.Godmode then humanoid.Health = humanoid.MaxHealth end
        if Settings.AutoHeal and humanoid.Health < humanoid.MaxHealth then humanoid.Health = humanoid.MaxHealth end
    end

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

    if not Drone.active then
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
        elseif Camera.CameraType == Enum.CameraType.Scriptable and not Drone.active then
            Camera.CameraType = Enum.CameraType.Custom
        end

        if Settings.Earthquake then
            Camera.CFrame *= CFrame.new(math.random(-1,1)*0.1, math.random(-1,1)*0.1, 0)
        end
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

    if Settings.Aimbot and not Drone.active then
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

getgenv().MellHackUnload = function()
    getgenv().MellHackLoaded = false
    pcall(function() if Drone.active then Drone:Stop() end end)
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

task.defer(ApplyMenuColorsToTheme)

WindUI:Notify({
    Title    = "MellHack",
    Content  = "MellHack успешно загружен",
    Duration = 6,
    Icon     = "check",
})

safeLog("loaded successfully")
