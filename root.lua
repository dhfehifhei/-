-- ==========================================================
--  MellHack // @ruzoxu  (WindUI Edition + Full Colorpicker)
-- ==========================================================

local CoreGui        = game:GetService("CoreGui")
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting       = game:GetService("Lighting")
local Workspace      = game:GetService("Workspace")
local TweenService   = game:GetService("TweenService")
local TextChatService= game:GetService("TextChatService")
local LocalPlayer    = Players.LocalPlayer
local Mouse          = LocalPlayer:GetMouse()
local Camera         = Workspace.CurrentCamera

pcall(function()
    for _, v in pairs(getconnections(LocalPlayer.Idled)) do v:Disable() end
end)

if getgenv().MellHackLoaded then
    pcall(function() getgenv().MellHackUnload() end)
end

getgenv().MellHackLoaded = true
local Connections = {}
local ObjectsToCleanup = {}
local DrawingObjects = {}

local function trackConn(c) table.insert(Connections, c) return c end
local function trackObj(o)  table.insert(ObjectsToCleanup, o) return o end
local function trackDrawing(o) table.insert(DrawingObjects, o) return o end

-- helpers
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
--  ЗАГРУЗКА WindUI
-- ==========================================================
local WindUI
do
    local ok, result = pcall(function()
        local source = game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua")
        return loadstring(source)()
    end)
    if ok and result then
        WindUI = result
    else
        warn("[MellHack] Не удалось загрузить WindUI: " .. tostring(result))
        return
    end
end

-- ==========================================================
--  ОКНО
-- ==========================================================
local Window = WindUI:CreateWindow({
    Title    = "MellHack",
    Author   = "@ruzoxu",
    Icon     = "rbxassetid://120997033468887",
    Folder   = "MellHack",
    Size     = UDim2.fromOffset(640, 480),
    MinSize  = Vector2.new(520, 400),
    MaxSize  = Vector2.new(1000, 700),
    Transparent = true,
    Acrylic  = true,
    Theme    = "Dark",
    User = { Enabled = true, Anonymous = false, Callback = function() end },
    Topbar = { Height = 52, ButtonsType = "Default" },
    Resizable = true,
    HideSearchBar = false,
    ScrollBarEnabled = true,
    NewElements = true,
    IgnoreAlerts = true,
})

-- ==========================================================
--  НАСТРОЙКИ
-- ==========================================================
local Settings = {
    -- Movement
    Fly = false, FlySpeed = 127,
    Speed = false, WalkSpeedVal = 80,
    Jump = false, JumpPowerVal = 250,
    Bhop = false, Strafes = false, StrafeSpeed = 35,
    PixelSurf = false, InfiniteJump = false, Noclip = false,
    LongJump = false, SuperGlide = false, WallHop = false,
    AirBoost = false, EdgeBug = false,
    WallClimb = false, NoFallDamage = false, AutoRespawn = false,

    -- Combat
    Aimbot = false, SilentAim = false, WallCheck = true,
    CamLock = false, TeamCheck = true, AimFOV = 350,
    AimSmooth = 4, DrawFOV = true, AimPart = "Head",
    AimPrediction = 0.15, AimHitChance = 100,
    Triggerbot = false, TriggerbotDelay = 0.05,
    TriggerbotFOV = 150, TriggerbotWallCheck = true,
    Autoclicker = false, AutoclickerCPS = 15,
    Killaura = false, KillauraRange = 20,
    HitboxExpander = false, HitboxSize = 8,

    -- Visuals
    ESPBox = true, HPBar = true, Tracers = true,
    SkeletonESP = true, NameESP = true, Chams = true,
    Crosshair = false, BulletTracers = false,
    FOVIndicator = false, GlowESP = false,
    TeamESP = true, DistanceESP = true,

    -- ===== ЦВЕТА =====
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

    -- ===== ALPHA =====
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

    -- Shaders
    Fullbright = false, Xray = false, SkyColor = {135,206,235},
    CustomFog = false, FogColor = {200,200,200}, FogEnd = 500,

    -- Rage
    Invisible = false, Godmode = false, SpinBot = false,
    SpinSpeed = 1000, AntiAim = false, YawOffset = 0,
    HideHead = false, JitterRange = 45, BodyShake = false,
    Freecam = false, FreecamSpeed = 50, Earthquake = false,
    ClickTeleport = false, ChatFlood = false,
    FloodText = "MellHack by @ruzoxu", FloodDelay = 1,
    AutoHeal = false,

    FOVChanger = false, CustomFOV = 90,
    Jerk = false, Bang = false, Fling = false, AntiFling = false,

    -- Watermark
    Watermark = true,
}

-- ==========================================================
--  ПРИМЕНЕНИЕ ЦВЕТОВ К ТЕМЕ WindUI
--  (мутируем текущую активную тему напрямую + перерисовываем)
-- ==========================================================
local function ApplyMenuColorsToTheme()
    if not WindUI then return end

    -- активная тема
    local activeTheme = WindUI.Theme
    if not activeTheme then return end

    -- WindUI.Themes — таблица со всеми темами, у каждой ключ = name.
    -- Дополнительно мутируем "Dark" и "Light" чтобы переключение темы
    -- сохраняло цвет пользователя.
    for _, key in ipairs({"Dark", "Light"}) do
        local t = WindUI.Themes and WindUI.Themes[key]
        if t then
            t.Accent      = Settings.ColorMenu
            t.Primary     = Settings.ColorMenu
            t.Button      = Settings.ColorMenu
            t.Slider      = Settings.ColorMenu
            t.Toggle      = Settings.ColorMenu
            t.Checkbox    = Settings.ColorMenu

            t.WindowBackground = Settings.ColorWindow
            t.Background       = Settings.ColorWindow
            t.PanelBackground  = Settings.ColorPanel
            t.TabBackground    = Settings.ColorPanel
            t.TabBackgroundActive = Settings.ColorPanel

            t.Text        = Settings.ColorText
            t.Placeholder = Settings.ColorSubText
            t.Icon        = Settings.ColorSubText

            -- Прозрачности темы (AlphaXxx = 0..1)
            t.BackgroundTransparency          = Settings.AlphaWindow
            t.PanelBackgroundTransparency     = Settings.AlphaPanel
            t.TabBackgroundActiveTransparency = Settings.AlphaPanel
            t.TabBackgroundHoverTransparency  = math.clamp(Settings.AlphaPanel + 0.05, 0, 1)
            t.WindowBackgroundTransparency    = Settings.AlphaWindow
        end
    end

    -- Дёргаем перерисовку. У WindUI есть Creator.UpdateTheme(),
    -- прокинем через WindUI.Creator если доступно.
    if WindUI.Creator and WindUI.Creator.UpdateTheme then
        -- UpdateTheme(obj, animate, tween, style, dir)
        WindUI.Creator.UpdateTheme(nil, false, false)
    elseif WindUI.UpdateTheme then
        pcall(function() WindUI:UpdateTheme() end)
    end
end

-- ==========================================================
--  FLY
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
    task.wait(1)
    initFlyObjects()
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

    local keyboardMove = Vector3.new()
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then keyboardMove += Vector3.new(0,0,-1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then keyboardMove += Vector3.new(0,0,1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then keyboardMove += Vector3.new(-1,0,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then keyboardMove += Vector3.new(1,0,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then keyboardMove += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then keyboardMove += Vector3.new(0,-1,0) end

    local finalMove = (keyboardMove.Magnitude > 0) and keyboardMove or moveVec

    if Settings.Fly then
        hum.AutoRotate = false
        hum.PlatformStand = true
        if _G.fly_bg then _G.fly_bg.MaxTorque = Vector3.new(3e4, 3e4, 3e4) end
        if _G.fly_rp then _G.fly_rp.MaxTorque = Vector3.new(1e4, 1e4, 1e4) end

        if finalMove.Magnitude > 0 then
            pcall(function() _G.fly_rp:Fire() end)
            if _G.fly_pt then
                local camCF = Camera.CFrame
                local targetDir = (camCF.RightVector * finalMove.X)
                              - (camCF.LookVector  * finalMove.Z)
                              + Vector3.new(0, finalMove.Y * 2, 0)
                _G.fly_pt.Position = root.Position + (targetDir * 1000)
            end
            if _G.fly_bg then _G.fly_bg.CFrame = Camera.CFrame end
        else
            pcall(function() _G.fly_rp:Abort() end)
            root.Velocity = Vector3.new(0,0,0)
        end
    else
        hum.AutoRotate = true
        hum.PlatformStand = false
        if _G.fly_bg then _G.fly_bg.MaxTorque = Vector3.new() end
        if _G.fly_rp then _G.fly_rp.MaxTorque = Vector3.new() end
        pcall(function() _G.fly_rp:Abort() end)
    end
end))

-- ==========================================================
--  Teleport / Chat flood
-- ==========================================================
local function handleTeleport(pos)
    if Settings.ClickTeleport then
        local char = LocalPlayer.Character
        local hrp  = getRoot(char)
        if char and hrp then hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0)) end
    end
end

trackConn(Mouse.Button1Down:Connect(function()
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService.TouchEnabled then
        handleTeleport(Mouse.Hit.Position)
    end
end))

trackConn(UserInputService.TouchTapInWorld:Connect(function(position, processed)
    if not processed and Settings.ClickTeleport then
        local ray = Camera:ScreenPointToRay(position.X, position.Y)
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {LocalPlayer.Character}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
        if result then handleTeleport(result.Position) end
    end
end))

trackConn(task.spawn(function()
    while getgenv().MellHackLoaded do
        if Settings.ChatFlood and Settings.FloodText ~= "" then
            pcall(function()
                if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                    local channel = TextChatService.TextChannels.RBXGeneral
                    if channel then channel:SendAsync(Settings.FloodText) end
                else
                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents
                        .SayMessageRequest:FireServer(Settings.FloodText, "All")
                end
            end)
        end
        task.wait(Settings.FloodDelay)
    end
end))

-- Anti-AFK
trackConn(LocalPlayer.Idled:Connect(function()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end))

-- ==========================================================
--  ТАБЫ
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
--  MOVEMENT
-- ==========================================================
TabMovement:Section({ Title = "Character Physics" })
TabMovement:Toggle({ Title = "Fly / Полет", Value = false, Callback = function(v) Settings.Fly = v end })
TabMovement:Slider({ Title = "Fly Speed", Value = { Min = 10, Max = 300, Default = 127 },
    Callback = function(v) Settings.FlySpeed = v; if _G.fly_rp then _G.fly_rp.MaxSpeed = v end end })
TabMovement:Toggle({ Title = "SpeedHack", Value = false,
    Callback = function(v)
        Settings.Speed = v
        if not v and LocalPlayer.Character then
            local hum = getHumanoid(LocalPlayer.Character)
            if hum then hum.WalkSpeed = 16 end
        end
    end })
TabMovement:Slider({ Title = "WalkSpeed", Value = { Min = 16, Max = 400, Default = 80 },
    Callback = function(v) Settings.WalkSpeedVal = v end })
TabMovement:Toggle({ Title = "Super Jump", Value = false,
    Callback = function(v)
        Settings.Jump = v
        if not v and LocalPlayer.Character then
            local hum = getHumanoid(LocalPlayer.Character)
            if hum then hum.JumpPower = 50 end
        end
    end })
TabMovement:Slider({ Title = "Jump Height", Value = { Min = 50, Max = 800, Default = 250 },
    Callback = function(v) Settings.JumpPowerVal = v end })

TabMovement:Section({ Title = "Advanced Movement" })
TabMovement:Toggle({ Title = "Auto-Bhop",     Value = false, Callback = function(v) Settings.Bhop = v end })
TabMovement:Toggle({ Title = "Air Strafes",   Value = false, Callback = function(v) Settings.Strafes = v end })
TabMovement:Slider({ Title = "Strafe Speed",  Value = { Min = 10, Max = 100, Default = 35 }, Callback = function(v) Settings.StrafeSpeed = v end })
TabMovement:Toggle({ Title = "Pixel Surf",    Value = false, Callback = function(v) Settings.PixelSurf = v end })
TabMovement:Toggle({ Title = "Long Jump",     Value = false, Callback = function(v) Settings.LongJump = v end })
TabMovement:Toggle({ Title = "Super Glide",   Value = false, Callback = function(v) Settings.SuperGlide = v end })
TabMovement:Toggle({ Title = "Wall Hop",      Value = false, Callback = function(v) Settings.WallHop = v end })
TabMovement:Toggle({ Title = "Wall Climb",    Value = false, Callback = function(v) Settings.WallClimb = v end })
TabMovement:Toggle({ Title = "Air Boost",     Value = false, Callback = function(v) Settings.AirBoost = v end })
TabMovement:Toggle({ Title = "Edge Bug",      Value = false, Callback = function(v) Settings.EdgeBug = v end })
TabMovement:Toggle({ Title = "Infinite Jump", Value = false, Callback = function(v) Settings.InfiniteJump = v end })
TabMovement:Toggle({ Title = "No Fall Damage",Value = false, Callback = function(v) Settings.NoFallDamage = v end })
TabMovement:Toggle({ Title = "Auto Respawn",  Value = false, Callback = function(v) Settings.AutoRespawn = v end })
TabMovement:Toggle({ Title = "Noclip",        Value = false,
    Callback = function(v)
        Settings.Noclip = v
        if not v and LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end })

-- ==========================================================
--  COMBAT
-- ==========================================================
TabCombat:Section({ Title = "Aimbot" })
TabCombat:Toggle({ Title = "Aimbot (Cam Lock)", Value = false, Callback = function(v) Settings.Aimbot = v end })
TabCombat:Toggle({ Title = "Silent Aim",        Value = false, Callback = function(v) Settings.SilentAim = v end })
TabCombat:Toggle({ Title = "Wall Check",        Value = true,  Callback = function(v) Settings.WallCheck = v end })
TabCombat:Toggle({ Title = "Team Check",        Value = true,  Callback = function(v) Settings.TeamCheck = v end })
TabCombat:Dropdown({
    Title = "Aim Part",
    Values = { "Head", "Torso", "Closest" },
    Value = "Head",
    Callback = function(v) Settings.AimPart = v end,
})
TabCombat:Slider({ Title = "Aim FOV",    Value = { Min = 50, Max = 1000, Default = 350 },
    Callback = function(v) Settings.AimFOV = v end })
TabCombat:Slider({ Title = "Aim Smooth", Value = { Min = 1, Max = 10, Default = 4 },
    Callback = function(v) Settings.AimSmooth = v end })
TabCombat:Slider({ Title = "Aim Prediction", Value = { Min = 0, Max = 1, Default = 0.15 },
    Callback = function(v) Settings.AimPrediction = v end })
TabCombat:Slider({ Title = "Hit Chance %",   Value = { Min = 0, Max = 100, Default = 100 },
    Callback = function(v) Settings.AimHitChance = v end })
TabCombat:Toggle({ Title = "Draw FOV",   Value = true,  Callback = function(v) Settings.DrawFOV = v end })

TabCombat:Section({ Title = "Triggerbot" })
TabCombat:Toggle({ Title = "Triggerbot",         Value = false, Callback = function(v) Settings.Triggerbot = v end })
TabCombat:Toggle({ Title = "Wall Check",         Value = true,  Callback = function(v) Settings.TriggerbotWallCheck = v end })
TabCombat:Slider({ Title = "Trigger FOV",        Value = { Min = 30, Max = 500, Default = 150 },
    Callback = function(v) Settings.TriggerbotFOV = v end })
TabCombat:Slider({ Title = "Trigger Delay (сек)",Value = { Min = 0.0, Max = 1, Default = 0.05 },
    Callback = function(v) Settings.TriggerbotDelay = v end })

TabCombat:Section({ Title = "Other Combat" })
TabCombat:Toggle({ Title = "Autoclicker", Value = false, Callback = function(v) Settings.Autoclicker = v end })
TabCombat:Slider({ Title = "CPS", Value = { Min = 1, Max = 50, Default = 15 },
    Callback = function(v) Settings.AutoclickerCPS = v end })
TabCombat:Toggle({ Title = "Killaura",   Value = false, Callback = function(v) Settings.Killaura = v end })
TabCombat:Slider({ Title = "Killaura Range", Value = { Min = 5, Max = 60, Default = 20 },
    Callback = function(v) Settings.KillauraRange = v end })
TabCombat:Toggle({ Title = "Hitbox Expander", Value = false,
    Callback = function(v)
        Settings.HitboxExpander = v
        if not v then
            for _, p in pairs(Players:GetPlayers()) do
                local head = getHead(p.Character)
                if head then head.Size = Vector3.new(2,1,1); head.Transparency = 0 end
            end
        end
    end })
TabCombat:Slider({ Title = "Hitbox Size", Value = { Min = 2, Max = 40, Default = 8 },
    Callback = function(v) Settings.HitboxSize = v end })

-- ==========================================================
--  VISUALS
-- ==========================================================
TabVisuals:Section({ Title = "ESP & Visuals" })
TabVisuals:Toggle({ Title = "ESP Boxes",    Value = true,  Callback = function(v) Settings.ESPBox = v end })
TabVisuals:Toggle({ Title = "HP Bar",       Value = true,  Callback = function(v) Settings.HPBar = v end })
TabVisuals:Toggle({ Title = "Tracers",      Value = true,  Callback = function(v) Settings.Tracers = v end })
TabVisuals:Toggle({ Title = "Skeleton ESP", Value = true,  Callback = function(v) Settings.SkeletonESP = v end })
TabVisuals:Toggle({ Title = "Name ESP",     Value = true,  Callback = function(v) Settings.NameESP = v end })
TabVisuals:Toggle({ Title = "Chams",        Value = false, Callback = function(v) Settings.Chams = v end })
TabVisuals:Toggle({ Title = "Crosshair",    Value = false, Callback = function(v) Settings.Crosshair = v end })
TabVisuals:Toggle({ Title = "Bullet Tracers", Value = false, Callback = function(v) Settings.BulletTracers = v end })
TabVisuals:Toggle({ Title = "FOV Changer",  Value = false, Callback = function(v) Settings.FOVChanger = v end })
TabVisuals:Slider({ Title = "Game FOV",     Value = { Min = 30, Max = 120, Default = 90 },
    Callback = function(v) Settings.CustomFOV = v end })
TabVisuals:Toggle({ Title = "Watermark",    Value = true,  Callback = function(v) Settings.Watermark = v end })

-- ==========================================================
--  COLORS
-- ==========================================================
TabColors:Section({ Title = "Menu / Меню" })

TabColors:Colorpicker({
    Title = "Accent / Акцент",
    Default = Settings.ColorMenu,
    Transparency = Settings.AlphaMenu,
    Callback = function(color, alpha)
        Settings.ColorMenu = color
        if alpha then Settings.AlphaMenu = alpha end
        ApplyMenuColorsToTheme()
    end,
})
TabColors:Colorpicker({
    Title = "Window Background",
    Default = Settings.ColorWindow,
    Transparency = Settings.AlphaWindow,
    Callback = function(color, alpha)
        Settings.ColorWindow = color
        if alpha then Settings.AlphaWindow = alpha end
        ApplyMenuColorsToTheme()
    end,
})
TabColors:Colorpicker({
    Title = "Panel Background",
    Default = Settings.ColorPanel,
    Transparency = Settings.AlphaPanel,
    Callback = function(color, alpha)
        Settings.ColorPanel = color
        if alpha then Settings.AlphaPanel = alpha end
        ApplyMenuColorsToTheme()
    end,
})
TabColors:Colorpicker({
    Title = "Text",
    Default = Settings.ColorText,
    Transparency = Settings.AlphaText,
    Callback = function(color, alpha)
        Settings.ColorText = color
        if alpha then Settings.AlphaText = alpha end
        ApplyMenuColorsToTheme()
    end,
})
TabColors:Colorpicker({
    Title = "Sub Text",
    Default = Settings.ColorSubText,
    Transparency = Settings.AlphaSubText,
    Callback = function(color, alpha)
        Settings.ColorSubText = color
        if alpha then Settings.AlphaSubText = alpha end
        ApplyMenuColorsToTheme()
    end,
})

TabColors:Section({ Title = "ESP / Подсветка" })
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

TabColors:Section({ Title = "Chams / Чамсы" })
TabColors:Colorpicker({
    Title = "Chams Fill",
    Default = Settings.ColorChams,
    Transparency = Settings.AlphaChams,
    Callback = function(c, a)
        Settings.ColorChams = c
        if a then Settings.AlphaChams = a end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hl = p.Character:FindFirstChild("MellChams")
                if hl then
                    hl.FillColor = Settings.ColorChams
                    hl.FillTransparency = Settings.AlphaChams
                end
            end
        end
    end,
})
TabColors:Colorpicker({
    Title = "Chams Outline",
    Default = Settings.ColorChamsOutline,
    Transparency = Settings.AlphaChamsOutline,
    Callback = function(c, a)
        Settings.ColorChamsOutline = c
        if a then Settings.AlphaChamsOutline = a end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hl = p.Character:FindFirstChild("MellChams")
                if hl then
                    hl.OutlineColor = Settings.ColorChamsOutline
                    hl.OutlineTransparency = Settings.AlphaChamsOutline
                end
            end
        end
    end,
})

TabColors:Section({ Title = "Presets / Сброс" })
TabColors:Button({
    Title = "Reset All Colors",
    Icon = "rotate-ccw",
    Callback = function()
        Settings.ColorMenu         = Color3.fromRGB(255, 40, 90)
        Settings.ColorWindow       = Color3.fromRGB(16, 16, 22)
        Settings.ColorPanel        = Color3.fromRGB(12, 12, 16)
        Settings.ColorText         = Color3.fromRGB(240, 238, 245)
        Settings.ColorSubText      = Color3.fromRGB(140, 135, 155)
        Settings.ColorBox          = Color3.fromRGB(255, 40, 90)
        Settings.ColorTracer       = Color3.fromRGB(255, 40, 90)
        Settings.ColorSkeleton     = Color3.fromRGB(255, 255, 255)
        Settings.ColorName         = Color3.fromRGB(255, 255, 255)
        Settings.ColorHPFull       = Color3.fromRGB(0, 255, 80)
        Settings.ColorHPEmpty      = Color3.fromRGB(0, 0, 0)
        Settings.ColorFOV          = Color3.fromRGB(255, 40, 90)
        Settings.ColorCrosshair    = Color3.fromRGB(255, 255, 255)
        Settings.ColorBulletTracer = Color3.fromRGB(255, 200, 0)
        Settings.ColorChams        = Color3.fromRGB(255, 40, 90)
        Settings.ColorChamsOutline = Color3.fromRGB(255, 255, 255)

        Settings.AlphaMenu         = 0.15
        Settings.AlphaWindow       = 0.15
        Settings.AlphaPanel        = 0.15
        Settings.AlphaText         = 0.0
        Settings.AlphaSubText      = 0.0
        Settings.AlphaBox          = 0.0
        Settings.AlphaTracer       = 0.0
        Settings.AlphaSkeleton     = 0.0
        Settings.AlphaName         = 0.0
        Settings.AlphaHPFull       = 0.0
        Settings.AlphaHPEmpty      = 0.0
        Settings.AlphaFOV          = 0.2
        Settings.AlphaCrosshair    = 0.0
        Settings.AlphaBulletTracer = 0.0
        Settings.AlphaChams        = 0.5
        Settings.AlphaChamsOutline = 0.0

        ApplyMenuColorsToTheme()
        WindUI:Notify({ Title = "MellHack", Content = "Палитра сброшена.", Duration = 4, Icon = "check" })
    end,
})

-- ==========================================================
--  EXTRAS (новые фичи)
-- ==========================================================
TabExtras:Section({ Title = "Utility / Утилиты" })
TabExtras:Button({ Title = "Reset Character", Icon = "rotate-ccw",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local hum = getHumanoid(char)
            if hum then hum.Health = 0 end
        end
    end })
TabExtras:Button({ Title = "Rejoin Server", Icon = "log-out",
    Callback = function()
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end)
    end })
TabExtras:Button({ Title = "Server Hop", Icon = "shuffle",
    Callback = function()
        task.spawn(function()
            pcall(function()
                local req = (syn and syn.request) or (http and http.request) or http_request or request
                if not req then
                    WindUI:Notify({ Title = "MellHack", Content = "HTTP request недоступен.", Icon = "x" })
                    return
                end
                local res = req({ Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100", Method = "GET" })
                local data = game:GetService("HttpService"):JSONDecode(res.Body)
                local servers = {}
                for _, s in pairs(data.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        table.insert(servers, s.id)
                    end
                end
                if #servers > 0 then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
                else
                    WindUI:Notify({ Title = "MellHack", Content = "Серверов не найдено.", Icon = "x" })
                end
            end)
        end)
    end })

TabExtras:Section({ Title = "Anti-AFK" })
TabExtras:Toggle({ Title = "Anti-AFK (встроен)", Value = true, Callback = function() end })

-- ==========================================================
--  SHADERS
-- ==========================================================
TabShaders:Section({ Title = "Lighting & Sky" })
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
TabShaders:Slider({ Title = "Fog Distance", Value = { Min = 50, Max = 5000, Default = 500 },
    Callback = function(v) Settings.FogEnd = v end })

TabShaders:Section({ Title = "Shaders Pro" })
TabShaders:Toggle({ Title = "Cinema Bloom", Value = false,
    Callback = function(v)
        local b = Lighting:FindFirstChild("MellBloom")
        if v and not b then
            b = Instance.new("BloomEffect", Lighting); b.Name = "MellBloom"
            b.Intensity = 1.8; b.Size = 56; b.Threshold = 0.45
        elseif not v and b then b:Destroy() end
    end })
TabShaders:Toggle({ Title = "HDR Color Correction", Value = false,
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
--  RAGE
-- ==========================================================
TabRage:Section({ Title = "Rage & Fun" })
TabRage:Toggle({ Title = "Chat Flood",     Value = false, Callback = function(v) Settings.ChatFlood = v end })
TabRage:Slider({ Title = "Flood Delay",    Value = { Min = 0.2, Max = 5, Default = 1 }, Callback = function(v) Settings.FloodDelay = v end })
TabRage:Toggle({ Title = "Click Teleport", Value = false, Callback = function(v) Settings.ClickTeleport = v end })
TabRage:Toggle({ Title = "Freecam",        Value = false, Callback = function(v) Settings.Freecam = v end })
TabRage:Slider({ Title = "Freecam Speed",  Value = { Min = 10, Max = 200, Default = 50 }, Callback = function(v) Settings.FreecamSpeed = v end })
TabRage:Toggle({ Title = "Earthquake",     Value = false, Callback = function(v) Settings.Earthquake = v end })
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
TabRage:Toggle({ Title = "Godmode",   Value = false, Callback = function(v) Settings.Godmode = v end })
TabRage:Toggle({ Title = "Auto Heal", Value = false, Callback = function(v) Settings.AutoHeal = v end })

TabRage:Section({ Title = "IY Fun Exploits" })
TabRage:Toggle({
    Title = "Jerk (Jorkin it)", Value = false,
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
    Title = "Fling (IY Stable)", Value = false,
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
                                        eRoot.AssemblyLinearVelocity =
                                            (eRoot.Position - myRoot.Position).Unit * 350 + Vector3.new(0,150,0)
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

TabRage:Section({ Title = "Anti-Aim Pro" })
TabRage:Toggle({ Title = "Spin-Bot",       Value = false, Callback = function(v) Settings.SpinBot = v end })
TabRage:Slider({ Title = "Spin-Bot Speed", Value = { Min = 100, Max = 5000, Default = 1000 }, Callback = function(v) Settings.SpinSpeed = v end })
TabRage:Toggle({ Title = "Anti-Aim",       Value = false, Callback = function(v) Settings.AntiAim = v end })
TabRage:Slider({ Title = "Jitter Range",   Value = { Min = 10, Max = 180, Default = 90 }, Callback = function(v) Settings.JitterRange = v end })
TabRage:Slider({ Title = "Yaw Offset",     Value = { Min = -180, Max = 180, Default = 0 }, Callback = function(v) Settings.YawOffset = v end })
TabRage:Toggle({ Title = "Body Shake",     Value = false, Callback = function(v) Settings.BodyShake = v end })
TabRage:Toggle({ Title = "Hide Head",      Value = false, Callback = function(v) Settings.HideHead = v end })

-- ==========================================================
--  KEYBINDS
-- ==========================================================
TabBinds:Section({ Title = "Keybinds" })
TabBinds:Keybind({ Title = "Toggle Fly",    Value = "F", Callback = function() Settings.Fly = not Settings.Fly end })
TabBinds:Keybind({ Title = "Toggle Noclip", Value = "G", Callback = function() Settings.Noclip = not Settings.Noclip end })
TabBinds:Keybind({ Title = "Toggle Speed",  Value = "H", Callback = function() Settings.Speed = not Settings.Speed end })

-- ==========================================================
--  SETTINGS
-- ==========================================================
TabSettings:Section({ Title = "Menu Settings" })
TabSettings:Toggle({ Title = "White Theme", Value = false,
    Callback = function(v)
        WindUI:SetTheme(v and "Light" or "Dark")
        task.defer(ApplyMenuColorsToTheme)
    end })
TabSettings:Slider({ Title = "Menu Transparency", Value = { Min = 0, Max = 90, Default = 15 },
    Callback = function(v)
        Settings.AlphaWindow = v / 100
        Settings.AlphaPanel  = v / 100
        Settings.AlphaMenu   = v / 100
        ApplyMenuColorsToTheme()
    end })

TabSettings:Section({ Title = "Script Control" })
TabSettings:Toggle({ Title = "Unload Script", Value = false,
    Callback = function(v)
        if v then task.defer(function() getgenv().MellHackUnload() end) end
    end })

-- ==========================================================
--  ESP / AIM helpers
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

local function getAimPart(player)
    local char = player.Character
    if not char then return nil end
    if Settings.AimPart == "Head" then
        return char:FindFirstChild("Head")
    elseif Settings.AimPart == "Torso" then
        return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    else
        -- closest to mouse
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
--  ESP DRAWINGS
-- ==========================================================
local drawings = {}
trackConn(RunService.RenderStepped:Connect(function()
    if not getgenv().MellHackLoaded then return end

    -- Скрываем всё, что не будет использоваться
    for _, d in pairs(drawings) do
        pcall(function()
            d.Box.Visible=false; d.HPBack.Visible=false; d.HPFill.Visible=false
            d.Tracer.Visible=false; d.NameTag.Visible=false; d.Skeleton.Visible=false
        end)
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (not Settings.TeamCheck or isEnemy(p)) and p.Character then
            local hrp  = getRoot(p.Character)
            local hum  = getHumanoid(p.Character)
            local head = getHead(p.Character)

            if hrp then
                if not drawings[p] then
                    local b   = trackDrawing(Drawing.new("Square")); b.Thickness = 1.5; b.Filled = false
                    local hbp = trackDrawing(Drawing.new("Square")); hbp.Thickness = 1; hbp.Filled = true
                    local hbf = trackDrawing(Drawing.new("Square")); hbf.Thickness = 1; hbf.Filled = true
                    local tr  = trackDrawing(Drawing.new("Line"));   tr.Thickness = 1.5
                    local nt  = trackDrawing(Drawing.new("Text"));   nt.Size = 13; nt.Center = true; nt.Outline = true
                    local sk  = trackDrawing(Drawing.new("Line"));   sk.Thickness = 1.5
                    drawings[p] = {Box=b, HPBack=hbp, HPFill=hbf, Tracer=tr, NameTag=nt, Skeleton=sk}
                end

                local ui = drawings[p]

                local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local size = Vector2.new(2000 / vector.Z, 3000 / vector.Z)
                    local pos  = Vector2.new(vector.X - size.X/2, vector.Y - size.Y/2)

                    -- === BOX ===
                    if Settings.ESPBox then
                        ui.Box.Color        = Settings.ColorBox
                        ui.Box.Transparency = Settings.AlphaBox
                        ui.Box.Size         = size
                        ui.Box.Position     = pos
                        ui.Box.Visible      = true
                    end

                    -- === HP BAR ===
                    if Settings.HPBar and hum then
                        local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)

                        ui.HPBack.Color        = Settings.ColorHPEmpty
                        ui.HPBack.Transparency = Settings.AlphaHPEmpty
                        ui.HPBack.Size         = Vector2.new(3, size.Y)
                        ui.HPBack.Position     = Vector2.new(pos.X - 6, pos.Y)
                        ui.HPBack.Visible      = true

                        ui.HPFill.Color        = Settings.ColorHPFull
                        ui.HPFill.Transparency = Settings.AlphaHPFull
                        ui.HPFill.Size         = Vector2.new(3, size.Y * pct)
                        ui.HPFill.Position     = Vector2.new(pos.X - 6, pos.Y + (size.Y * (1 - pct)))
                        ui.HPFill.Visible      = true
                    end

                    -- === NAME ===
                    if Settings.NameESP then
                        local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                        ui.NameTag.Color        = Settings.ColorName
                        ui.NameTag.Transparency = Settings.AlphaName
                        ui.NameTag.Text         = string.format("%s [%dm]", p.Name, dist)
                        ui.NameTag.Position     = Vector2.new(pos.X + size.X/2, pos.Y - 18)
                        ui.NameTag.Visible      = true
                    end

                    -- === TRACER ===
                    if Settings.Tracers then
                        ui.Tracer.Color        = Settings.ColorTracer
                        ui.Tracer.Transparency = Settings.AlphaTracer
                        ui.Tracer.From         = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        ui.Tracer.To           = Vector2.new(vector.X, vector.Y + size.Y/2)
                        ui.Tracer.Visible      = true
                    end

                    -- === SKELETON ===
                    if Settings.SkeletonESP and head and hrp then
                        local hp = Camera:WorldToViewportPoint(head.Position)
                        local rp = Camera:WorldToViewportPoint(hrp.Position)
                        ui.Skeleton.Color        = Settings.ColorSkeleton
                        ui.Skeleton.Transparency = Settings.AlphaSkeleton
                        ui.Skeleton.From         = Vector2.new(hp.X, hp.Y)
                        ui.Skeleton.To           = Vector2.new(rp.X, rp.Y)
                        ui.Skeleton.Visible      = true
                    end
                end
            end
        end

        -- === CHAMS ===
        if p ~= LocalPlayer and p.Character then
            if Settings.Chams and not p.Character:FindFirstChild("MellChams") then
                local hl = Instance.new("Highlight", p.Character)
                hl.Name = "MellChams"
                hl.FillColor           = Settings.ColorChams
                hl.FillTransparency    = Settings.AlphaChams
                hl.OutlineColor        = Settings.ColorChamsOutline
                hl.OutlineTransparency = Settings.AlphaChamsOutline
            elseif not Settings.Chams and p.Character:FindFirstChild("MellChams") then
                p.Character.MellChams:Destroy()
            elseif p.Character and p.Character:FindFirstChild("MellChams") then
                local hl = p.Character.MellChams
                hl.FillColor           = Settings.ColorChams
                hl.FillTransparency    = Settings.AlphaChams
                hl.OutlineColor        = Settings.ColorChamsOutline
                hl.OutlineTransparency = Settings.AlphaChamsOutline
            end
        end
    end
end))

-- ==========================================================
--  FOV CIRCLE
-- ==========================================================
local fovCircle = Drawing.new("Circle")
trackDrawing(fovCircle)
fovCircle.Thickness = 1.5
fovCircle.NumSides = 60
fovCircle.Filled = false

trackConn(RunService.RenderStepped:Connect(function()
    if not getgenv().MellHackLoaded then return end
    if (Settings.Aimbot or Settings.SilentAim) and Settings.DrawFOV then
        fovCircle.Visible      = true
        fovCircle.Radius       = Settings.AimFOV
        fovCircle.Color        = Settings.ColorFOV
        fovCircle.Transparency = Settings.AlphaFOV
        fovCircle.Position     = UserInputService:GetMouseLocation()
    else
        fovCircle.Visible = false
    end
end))

-- ==========================================================
--  CROSSHAIR
-- ==========================================================
local crosshairLines = {
    Drawing.new("Line"), Drawing.new("Line"),
    Drawing.new("Line"), Drawing.new("Line"),
}
for _, l in ipairs(crosshairLines) do
    trackDrawing(l)
    l.Thickness = 1.5
    l.Visible = false
end

trackConn(RunService.RenderStepped:Connect(function()
    if not getgenv().MellHackLoaded then return end
    if Settings.Crosshair then
        local center = Camera.ViewportSize / 2
        local gap, len = 6, 12
        local c = Settings.ColorCrosshair
        local t = Settings.AlphaCrosshair
        for _, l in ipairs(crosshairLines) do
            l.Color = c
            l.Transparency = t
            l.Visible = true
        end
        -- top
        crosshairLines[1].From = Vector2.new(center.X, center.Y - gap)
        crosshairLines[1].To   = Vector2.new(center.X, center.Y - gap - len)
        -- bottom
        crosshairLines[2].From = Vector2.new(center.X, center.Y + gap)
        crosshairLines[2].To   = Vector2.new(center.X, center.Y + gap + len)
        -- left
        crosshairLines[3].From = Vector2.new(center.X - gap, center.Y)
        crosshairLines[3].To   = Vector2.new(center.X - gap - len, center.Y)
        -- right
        crosshairLines[4].From = Vector2.new(center.X + gap, center.Y)
        crosshairLines[4].To   = Vector2.new(center.X + gap + len, center.Y)
    else
        for _, l in ipairs(crosshairLines) do l.Visible = false end
    end
end))

-- ==========================================================
--  WATERMARK
-- ==========================================================
local watermark = Drawing.new("Text")
trackDrawing(watermark)
watermark.Size = 18
watermark.Center = false
watermark.Outline = true
watermark.Color = Color3.fromRGB(255, 255, 255)
watermark.Position = Vector2.new(20, 20)
watermark.Text = "MellHack | @ruzoxu"
watermark.Visible = true

trackConn(RunService.RenderStepped:Connect(function()
    if not getgenv().MellHackLoaded then return end
    watermark.Visible = Settings.Watermark
    if Settings.Watermark then
        local fps = math.floor(1 / math.max(RunService.RenderStepped:Wait(), 1e-4))
        watermark.Text = string.format("MellHack | %s | %d FPS", LocalPlayer.Name, math.floor(1 / (RunService.RenderStepped:Wait() or 0.016)))
    end
end))

-- ==========================================================
--  AUTOCLICKER
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
--  INFINITE JUMP
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
--  SILENT AIM (hookmetamethod)
-- ==========================================================
pcall(function()
    if not hookmetamethod then return end
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
                            -- Hitchance
                            if Settings.AimHitChance < 100 then
                                if math.random(1, 100) > Settings.AimHitChance then
                                    continue
                                end
                            end
                            local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                            if onScreen then
                                local dst = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                                if dst < minDst then
                                    minDst = dst
                                    targetPart = part
                                end
                            end
                        end
                    end
                end
            end

            if targetPart then
                -- Prediction
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
--  TRIGGERBOT (через Mouse.Target, FOV + wallcheck + delay)
-- ==========================================================
local lastTrigger = 0
trackConn(RunService.RenderStepped:Connect(function()
    if not getgenv().MellHackLoaded then return end
    if not Settings.Triggerbot then return end

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
                        if dst < minDst then
                            minDst = dst
                            target = p
                        end
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
--  ГЛАВНЫЙ RENDER-STEP
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

    -- Wall Climb
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

    -- No Fall Damage
    if Settings.NoFallDamage and hrp.AssemblyLinearVelocity.Y < -50 then
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -50, hrp.AssemblyLinearVelocity.Z)
    end

    -- Auto Respawn
    if Settings.AutoRespawn and humanoid.Health <= 0 then
        task.spawn(function()
            task.wait(3)
            pcall(function() LocalPlayer:LoadCharacter() end)
        end)
    end

    if Settings.SpinBot then
        hrp.CFrame *= CFrame.Angles(0, math.rad(Settings.SpinSpeed), 0)
    end

    if Settings.AntiAim and not Settings.SpinBot then
        local rotSpeed = Settings.SpinSpeed * 20
        local yawOffsetRad = math.rad(Settings.YawOffset)
        local jitterRad = math.rad(math.random(-Settings.JitterRange, Settings.JitterRange))
        local finalAngle = (tick() * rotSpeed) + yawOffsetRad + jitterRad
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
    else
        if Camera.CameraType == Enum.CameraType.Scriptable then
            Camera.CameraType = Enum.CameraType.Custom
        end
    end

    if Settings.Earthquake then
        Camera.CFrame *= CFrame.new(math.random(-1,1)*0.1, math.random(-1,1)*0.1, 0)
    end

    if Settings.Fullbright then
        Lighting.Brightness = 3
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = false
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

    -- Hitbox Expander
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

    -- Aimbot (Cam Lock)
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
--  ИНИЦИАЛИЗАЦИЯ
-- ==========================================================
task.defer(ApplyMenuColorsToTheme)

-- Уведомление с правильным текстом
WindUI:Notify({
    Title    = "MellHack",
    Content  = "MellHack успешно загружен",
    Duration = 6,
    Icon     = "check",
})

print("mellhack успешно лоадед from @ruzoxu и @crack_komarq (пж сабнись)")