-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")

-- Local Player
local LocalPlayer = Players.LocalPlayer

-- Wait for game to load and character to be ready
repeat 
    task.wait() 
until game:IsLoaded() and LocalPlayer and LocalPlayer.Character and 
     LocalPlayer.Character:FindFirstChild("Animate") and 
     LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and 
     LocalPlayer.Character.Humanoid:FindFirstChild("Animator")

-- Variables
local Animate = LocalPlayer.Character.Animate
local AnimationBaseURL = "http://www.roblox.com/asset/?id="
local SelectedPlayer
local Workspace = Workspace

-- Global settings initialization
if not getgenv().OrigLighting then 
    getgenv().OrigLighting = Lighting.ClockTime 
end

if not getgenv().AlreadyLoaded then 
    getgenv().AlreadyLoaded = false 
end

-- Enable custom animations
game.StarterPlayer.AllowCustomAnimations = true
Workspace:SetAttribute("RbxLegacyAnimationBlending", true)

-- Store original animations
if not getgenv().OriginalAnimations then
    getgenv().OriginalAnimations = {}
    
    if Animate:FindFirstChild("pose") then
        local poseAnimation = Animate.pose:FindFirstChildOfClass("Animation")
        if poseAnimation then
            OriginalAnimations[3] = poseAnimation.AnimationId
        end
    end
    
    OriginalAnimations[1] = Animate.idle.Animation1.AnimationId
    OriginalAnimations[2] = Animate.idle.Animation2.AnimationId
    OriginalAnimations[4] = Animate.walk:FindFirstChildOfClass("Animation").AnimationId
    OriginalAnimations[5] = Animate.run:FindFirstChildOfClass("Animation").AnimationId
    OriginalAnimations[6] = Animate.jump:FindFirstChildOfClass("Animation").AnimationId
    OriginalAnimations[7] = Animate.climb:FindFirstChildOfClass("Animation").AnimationId
    OriginalAnimations[8] = Animate.fall:FindFirstChildOfClass("Animation").AnimationId
    
    if Animate:FindFirstChild("swim") then
        OriginalAnimations[9] = Animate.swim:FindFirstChildOfClass("Animation").AnimationId
        OriginalAnimations[10] = Animate.swimidle:FindFirstChildOfClass("Animation").AnimationId
    end
end

-- Helper function to get original animation
local function GetOriginalAnimation(index)
    return getgenv().OriginalAnimations[index]
end

-- Auto-rejoin script
if syn and syn.queue_on_teleport and not getgenv().AlreadyLoaded then
    syn.queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/Eazvy/public-scripts/main/Universal_Animations_Emotes.lua'))()")
elseif queue_on_teleport and not getgenv().AlreadyLoaded then
    queue_on_teleport([[
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua',true))()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Eazvy/public-scripts/main/Universal_Animations_Emotes.lua'))()
    ]])
end

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
end)

-- Animation and Emote counters
local EmoteCount = 0
local AnimationCount = 0

-- Settings configuration
getgenv().Settings = {
    Favorite = {},
    Custom = {
        Name = nil,
        Idle = nil,
        Idle2 = nil,
        Idle3 = nil,
        Walk = nil,
        Run = nil,
        Jump = nil,
        Climb = nil,
        Fall = nil,
        Swim = nil,
        SwimIdle = nil,
        Wave = 9527883498,
        Laugh = 507770818,
        Cheer = 507770677,
        Point = 507770453,
        Sit = 2506281703,
        Dance = 507771019,
        Dance2 = 507776043,
        Dance3 = 507777268,
        Weight = 9,
        Weight2 = 1
    },
    Chat = false,
    Day = false,
    Spy = false,
    Player = nil,
    EmoteChat = false,
    Animate = false,
    RandomAnim = false,
    Refresh = false,
    DeathPosition = nil,
    Noclip = false,
    RapePlayer = false,
    TwerkAss = false,
    TwerkAss2 = false,
    RandomEmote = false,
    Goto = false,
    Annoy = false,
    CopyMovement = false,
    SyncAnimations = false,
    PlayAlways = false,
    Platform = false,
    FlySpeed = 50,
    InfJump = false,
    ClickTeleport = false,
    ClickToSelect = false,
    SyncEmote = false,
    PlayerSync = nil,
    AnimationSpeedToggle = false,
    CurrentAnimation = "",
    FreezeAnimation = false,
    FreezeEmote = false,
    EmotePrefix = "/em",
    AnimationPrefix = "/a",
    EmoteSpeed = 1,
    AnimationSpeed = 1,
    ReverseSpeed = -1,
    SelectedAnimation = "",
    LastEmote = "",
    Looped = false,
    Reversed = false,
    Time = false,
    TimePosition = 1
}

-- File system functions
if makefolder and not isfile("Eazvy-Hub") then
    makefolder("Eazvy-Hub")
end

if isfile and not isfile("Eazvy-Hub/Animations_Settings.txt") and writefile then
    writefile('Eazvy-Hub/Animations_Settings.txt', HttpService:JSONEncode(getgenv().Settings))
end

function UpdateFile()
    if writefile then
        writefile('Eazvy-Hub/Animations_Settings.txt', HttpService:JSONEncode(getgenv().Settings))
    end
end

if readfile and isfile("Eazvy-Hub/Animations_Settings.txt") then
    getgenv().Settings = HttpService:JSONDecode(readfile('Eazvy-Hub/Animations_Settings.txt'))
    if Settings.EmotePrefix and Settings.EmotePrefix == "/e" then
        Settings.EmotePrefix = "/em"
        UpdateFile()
    end
end

-- HTTP request function
local Request = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request

-- Server hop function
local function ServerHop()
    local servers = {}
    local response = Request({
        Url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Desc&limit=100"
    })
    
    local data = HttpService:JSONDecode(response.Body)
    
    if data and data.data then
        for _, server in next, data.data do
            if type(server) == "table" and tonumber(server.playing) and tonumber(server.maxPlayers) and server.playing < server.maxPlayers then
                table.insert(servers, 1, server.id)
            end
        end
    end
    
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
    end
    
    TeleportService.TeleportInitFailed:Connect(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
    end)
end

-- Player search function
function getPlayersByName(playerName)
    local searchName, searchLength = string.lower(playerName), #playerName
    local players = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name ~= LocalPlayer.Name then
            if searchName:sub(0,1) == '@' then
                if string.sub(string.lower(player.Name), 1, searchLength-1) == searchName:sub(2) then
                    return player
                end
            else
                if string.sub(string.lower(player.Name), 1, searchLength) == searchName or 
                   string.sub(string.lower(player.DisplayName), 1, searchLength) == searchName then
                    return player
                end
            end
        end
    end
end

-- Load UI Library
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/iivxnu/mis-scripts/refs/heads/main/UILibrary.lua'))()

-- Notification functions
local function ShowError(title, content)
    OrionLib:MakeNotification({
        Name = "Animation - Error",
        Content = title .. "\n" .. content,
        Image = "rbxassetid://161551681",
        Time = 4
    })
end

local function ShowSuccess(title, content)
    OrionLib:MakeNotification({
        Name = "Animation - Success",
        Content = title .. "\n" .. content,
        Image = "rbxassetid://4914902889",
        Time = 4
    })
end

local function ShowTimedSuccess(title, content, duration)
    OrionLib:MakeNotification({
        Name = "Animation - Success",
        Content = title .. "\n" .. content,
        Image = "rbxassetid://4914902889",
        Time = duration
    })
end

-- Animation databases
local Emotes = {
    ['Fashion'] = 3333331310,
    ["Baby Dance"] = 4265725525,
    -- ... (todos los emotes del script original)
}

local Animations = {
    Emotes = {Weight = 9, Weight2 = 1},
    Stylish = {
        Idle = 616136790,
        Idle2 = 616138447,
        Idle3 = 886888594,
        Walk = 616146177,
        Run = 616140816,
        Jump = 616139451,
        Climb = 616133594,
        Fall = 616134815,
        Swim = 616143378,
        SwimIdle = 616144772,
        Weight = 9,
        Weight2 = 1
    },
    -- ... (todas las animaciones del script original)
}

local R6Emotes = {
    ['Balloon Float'] = {Emote = 148840371, Speed = 1, Time = 0, Weight = 1, Loop = true, Priority = 2},
    ['Idle'] = {Emote = 180435571, Speed = 1, Time = 0, Weight = 1, Loop = true, Priority = 2},
    -- ... (todos los emotes R6 del script original)
}

-- Animation management functions
local function StopAllAnimations()
    if not getgenv().AlreadyLoaded then return end
    
    repeat wait() until LocalPlayer.Character and 
           LocalPlayer.Character:FindFirstChild("Animate") and 
           LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and 
           LocalPlayer.Character.Humanoid:FindFirstChild("Animator")
    
    local Animator = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator")
    for _, track in ipairs(Animator:GetPlayingAnimationTracks()) do
        track:Stop()
    end
end

local function RefreshAnimations()
    if not getgenv().AlreadyLoaded then return end
    
    repeat wait() until LocalPlayer.Character and 
           LocalPlayer.Character:FindFirstChild("Animate") and 
           LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and 
           LocalPlayer.Character.Humanoid:FindFirstChild("Animator")
    
    local AnimateScript = LocalPlayer.Character:WaitForChild("Animate")
    AnimateScript.Disabled = true
    
    for _, track in ipairs(LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):GetPlayingAnimationTracks()) do
        track:AdjustSpeed(Settings.AnimationSpeed)
        track:Stop()
    end
    
    AnimateScript.Disabled = false
end

-- Main animation application function
local function ApplyAnimations(Idle1, Idle2, Idle3, Walk, Run, Jump, Climb, Fall, Swim, SwimIdle, Weight1, Weight2)
    repeat wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Animate")
    
    local AnimateScript = LocalPlayer.Character.Animate
    
    if AnimateScript:FindFirstChild("idle") then
        AnimateScript.idle.Animation1.AnimationId = AnimationBaseURL .. Idle1
        AnimateScript.idle.Animation1.Weight.Value = tostring(Weight1)
        AnimateScript.idle.Animation2.Weight.Value = tostring(Weight2)
        AnimateScript.idle.Animation2.AnimationId = AnimationBaseURL .. Idle2
    end
    
    if Idle3 and AnimateScript:FindFirstChild("pose") then
        AnimateScript.pose:FindFirstChildOfClass("Animation").AnimationId = AnimationBaseURL .. Idle3
    end
    
    AnimateScript.walk:FindFirstChildOfClass("Animation").AnimationId = AnimationBaseURL .. Walk
    AnimateScript.run:FindFirstChildOfClass("Animation").AnimationId = AnimationBaseURL .. Run
    AnimateScript.jump:FindFirstChildOfClass("Animation").AnimationId = AnimationBaseURL .. Jump
    AnimateScript.climb:FindFirstChildOfClass("Animation").AnimationId = AnimationBaseURL .. Climb
    AnimateScript.fall:FindFirstChildOfClass("Animation").AnimationId = AnimationBaseURL .. Fall
    
    if AnimateScript:FindFirstChild("swim") then
        AnimateScript.swim:FindFirstChildOfClass("Animation").AnimationId = AnimationBaseURL .. Swim
        AnimateScript.swimidle:FindFirstChildOfClass("Animation").AnimationId = AnimationBaseURL .. SwimIdle
    end
end

-- Single animation application
local function ApplySingleAnimation(animationType, animationId)
    repeat wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Animate")
    
    local AnimateScript = LocalPlayer.Character.Animate
    
    if animationType:match("idle") then
        if AnimateScript:FindFirstChild("pose") then
            AnimateScript.pose:FindFirstChildOfClass("Animation").AnimationId = AnimationBaseURL .. animationId
        end
    elseif animationType == "idle1" then
        AnimateScript.idle.Animation1.AnimationId = AnimationBaseURL .. animationId
    elseif animationType == "idle2" then
        AnimateScript.idle.Animation2.AnimationId = AnimationBaseURL .. animationId
    elseif animationType:match("dance") then
        for _, child in pairs(AnimateScript[animationType]:GetChildren()) do
            if child:IsA("Animation") then
                child.AnimationId = AnimationBaseURL .. animationId
            end
        end
    else
        local targetAnimation
        for _, child in pairs(AnimateScript:GetChildren()) do
            if child.Name == animationType then
                targetAnimation = child
                break
            end
        end
        
        if targetAnimation then
            targetAnimation:FindFirstChildOfClass("Animation").AnimationId = AnimationBaseURL .. animationId
        end
    end
    
    RefreshAnimations()
end

-- Emote playing function
local function PlayEmote(emoteId)
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. emoteId
    
    _G.LoadAnim = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):LoadAnimation(animation)
    _G.LoadAnim.Priority = Enum.AnimationPriority.Idle
    
    if not Settings.PlayAlways then
        _G.LoadAnim:Stop()
    end
    
    if Settings.Reversed then
        _G.LoadAnim:Play(0)
        _G.LoadAnim:AdjustSpeed(Settings.ReverseSpeed)
    else
        _G.LoadAnim:Play(0)
        _G.LoadAnim:AdjustSpeed(Settings.EmoteSpeed)
    end
    
    if Settings.Looped then
        _G.LoadAnim.Looped = Settings.Looped
    end
    
    if Settings.Time then
        _G.LoadAnim.TimePosition = _G.LoadAnim.TimePosition - Settings.TimePosition
    end
    
    if not LocalPlayer.Character.Animate.Disabled then
        LocalPlayer.Character.Animate.Disabled = true
    end
end

-- Character type detection
local function GetCharacterType()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
        return "R15"
    else
        return "R6"
    end
end

-- Initialize UI
local Window = OrionLib:MakeWindow({
    Name = "Eazvy Hub | Animations & Emotes",
    HidePremium = true,
    SaveConfig = false,
    ConfigFolder = "EazvyHub",
    IntroEnabled = false,
    IntroText = "Eazvy Hub - Animations/Emotes",
    IntroIcon = "rbxassetid://10932910166",
    Icon = "rbxassetid://4914902889"
})

-- Character added event for persistence
LocalPlayer.CharacterAdded:Connect(function(character)
    repeat wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Animate")
    
    character.Humanoid.Died:Connect(function()
        Settings.DeathPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
    end)
    
    if Settings.Refresh and LocalPlayer.Character and 
       LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
       Settings.DeathPosition then
        LocalPlayer.Character.HumanoidRootPart.CFrame = Settings.DeathPosition
    end
    
    wait(.15)
    StopAllAnimations()
    
    -- Reapply selected animations
    if Settings.SelectedAnimation ~= "" and GetCharacterType() == "R15" and 
       Settings.SelectedAnimation ~= "Custom" then
        
        local animData = Animations[Settings.SelectedAnimation]
        ApplyAnimations(
            animData.Idle or GetOriginalAnimation(1),
            animData.Idle2 or GetOriginalAnimation(2),
            animData.Idle3 or GetOriginalAnimation(3),
            animData.Walk or GetOriginalAnimation(4),
            animData.Run or GetOriginalAnimation(5),
            animData.Jump or GetOriginalAnimation(6),
            animData.Climb or GetOriginalAnimation(7),
            animData.Fall or GetOriginalAnimation(8),
            animData.Swim or GetOriginalAnimation(9),
            animData.SwimIdle or GetOriginalAnimation(10),
            animData.Weight,
            animData.Weight2
        )
        
        RefreshAnimations()
        
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid") or 
                        LocalPlayer.Character:FindFirstChildOfClass("AnimationController")
        local tracks = humanoid:GetPlayingAnimationTracks()
        
        for _, track in pairs(tracks) do
            track:AdjustSpeed(Settings.AnimationSpeed)
        end
    end
end)

-- Movement detection to stop emotes
LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):GetPropertyChangedSignal("MoveDirection"):Connect(function()
    if LocalPlayer.Character:FindFirstChildOfClass("Humanoid").MoveDirection.Magnitude > 0 then
        if GetCharacterType() == "R15" then
            if _G.LoadAnim and not Settings.PlayAlways then
                LocalPlayer.Character.Animate.Disabled = false
                _G.LoadAnim:Stop()
            end
        else
            if _G.LoadAnim and not Settings.PlayAlways then
                _G.LoadAnim:Stop()
                RefreshAnimations()
            end
        end
    end
end)

-- Animation speed adjustment loop
if not getgenv().AlreadyLoaded then
    task.spawn(function()
        while task.wait() do
            if Settings.AnimationSpeedToggle and LocalPlayer.Character and 
               (LocalPlayer.Character:FindFirstChildOfClass("Humanoid") or 
                LocalPlayer.Character:FindFirstChildOfClass("AnimationController")) then
                
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid") or 
                                LocalPlayer.Character:FindFirstChildOfClass("AnimationController")
                local tracks = humanoid:GetPlayingAnimationTracks()
                
                for _, track in pairs(tracks) do
                    track:AdjustSpeed(Settings.AnimationSpeed)
                end
            end
        end
    end)
end

-- Mark as loaded
if not getgenv().AlreadyLoaded then
    getgenv().AlreadyLoaded = true
end

-- Create UI tabs and elements here...
-- (El resto de la interfaz de usuario se mantendría igual pero mejor organizada)

-- Ejemplo de cómo se vería una sección (debes adaptar todo el UI)
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://10507357657",
    PremiumOnly = false
})

-- Agregar más elementos de UI según sea necesario...

OrionLib:Init()
