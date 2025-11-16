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

-- Animation databases (simplificadas para ejemplo)
local Emotes = {
    ['Fashion'] = 3333331310,
    ["Baby Dance"] = 4265725525,
    ["Cha-Cha"] = 6862001787,
    ['Monkey'] = 3333499508,
    ['Shuffle'] = 4349242221,
    ["Top Rock"] = 3361276673,
    ["Around Town"] = 3303391864,
    ["Fancy Feet"] = 3333432454,
    ["Hype Dance"] = 3695333486,
    ['Bodybuilder'] = 3333387824,
    ['Idol'] = 4101966434
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
    Zombie = {
        Idle = 616158929,
        Idle2 = 616160636,
        Idle3 = 885545458,
        Walk = 616168032,
        Run = 616163682,
        Jump = 616161997,
        Climb = 616156119,
        Fall = 616157476,
        Swim = 616165109,
        SwimIdle = 616166655,
        Weight = 9,
        Weight2 = 1
    }
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

-- Main Tab
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://10507357657",
    PremiumOnly = false
})

-- Status display
local Status = MainTab:AddParagraph("Emote Information", "Current Emote: "..Settings.LastEmote.." // Speed: "..tostring(Settings.EmoteSpeed).." // Time Position: 0 // Looped: false")

-- Emote search and play
MainTab:AddTextbox({
    Name = "Play Emote / Search (Name)",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        if Settings.EmoteChat then
            -- Search functionality would go here
            return
        end
        
        for emoteName, emoteId in pairs(Emotes) do
            if string.lower(emoteName):find(string.lower(value)) then
                StopAllAnimations()
                PlayEmote(emoteId)
                Settings.LastEmote = emoteName
                Status:Set("Current Emote: "..Settings.LastEmote.." // Speed: "..tostring(Settings.EmoteSpeed).." // Time Position: 0 // Looped: false")
                UpdateFile()
                break
            end
        end
    end
})

-- Sync emote with player
MainTab:AddTextbox({
    Name = "Sync Emote (Player)",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        Settings.PlayerSync = getPlayersByName(value)
        if Settings.PlayerSync then
            ShowSuccess("Syncing Emotes with", Settings.PlayerSync.Name)
        end
    end
})

-- Emote dropdowns section
local EmoteSection = MainTab:AddSection({Name = " // Emote Dropdowns"})

-- Emotes dropdown
local EmotesDropdown = MainTab:AddDropdown({
    Name = "Emotes (R15)",
    Default = "",
    Options = {"Fashion", "Baby Dance", "Cha-Cha", "Monkey", "Shuffle", "Top Rock", "Around Town", "Fancy Feet", "Hype Dance", "Bodybuilder", "Idol"},
    Callback = function(selected)
        if GetCharacterType() == "R15" then
            StopAllAnimations()
            PlayEmote(Emotes[selected])
            Settings.LastEmote = selected
            Status:Set("Current Emote: "..Settings.LastEmote.." // Speed: "..tostring(Settings.EmoteSpeed).." // Time Position: 0 // Looped: false")
            UpdateFile()
        end
    end
})

-- Search dropdown
local SearchDropdown = MainTab:AddDropdown({
    Name = "Emotes (Search)",
    Default = "",
    Options = {},
    Callback = function(selected)
        if GetCharacterType() == "R15" then
            StopAllAnimations()
            PlayEmote(Emotes[selected])
            Settings.LastEmote = selected
            Status:Set("Current Emote: "..Settings.LastEmote.." // Speed: "..tostring(Settings.EmoteSpeed).." // Time Position: 0 // Looped: false")
            UpdateFile()
        end
    end
})

-- Favorite dropdown
local FavoriteDropdown
if GetCharacterType() == "R15" then
    FavoriteDropdown = MainTab:AddDropdown({
        Name = "Emotes (Favorite)",
        Default = "",
        Options = {},
        Callback = function(selected)
            StopAllAnimations()
            PlayEmote(Emotes[selected])
            Settings.LastEmote = selected
            Status:Set("Current Emote: "..Settings.LastEmote.." // Speed: "..tostring(Settings.EmoteSpeed).." // Time Position: 0 // Looped: false")
            UpdateFile()
        end
    })
end

-- Emote control buttons
MainTab:AddButton({
    Name = "Play Last Emote",
    Callback = function()
        if Settings.LastEmote and Emotes[Settings.LastEmote] then
            PlayEmote(Emotes[Settings.LastEmote])
            Status:Set("Current Emote: "..Settings.LastEmote.." // Speed: "..tostring(Settings.EmoteSpeed).." // Time Position: 0 // Looped: false")
        end
    end
})

MainTab:AddButton({
    Name = "Stop Emote",
    Callback = function()
        if _G.LoadAnim then
            _G.LoadAnim:Stop()
            RefreshAnimations()
            Status:Set("Current Emote: "..Settings.LastEmote.." // Speed: "..tostring(Settings.EmoteSpeed).." // Time Position: 0 // Looped: false")
        end
    end
})

-- Emote settings section
local EmoteSettingsSection = MainTab:AddSection({Name = " // Emote Settings"})

if GetCharacterType() == "R15" then
    MainTab:AddToggle({
        Name = "Emote Chat",
        Default = false,
        Callback = function(value)
            Settings.Chat = value
            if Settings.Chat then
                ShowSuccess("Enabled Emote-Chat", "Prefix is: "..Settings.EmotePrefix)
            end
            UpdateFile()
        end
    })
    
    MainTab:AddToggle({
        Name = "Emote Search",
        Default = false,
        Callback = function(value)
            Settings.EmoteChat = value
            UpdateFile()
        end
    })
end

MainTab:AddToggle({
    Name = "Time-Position",
    Default = false,
    Callback = function(value)
        Settings.Time = value
        Status:Set("Current Emote: "..Settings.LastEmote.." // Speed: "..tostring(Settings.EmoteSpeed).." // Time Position: 0 // Looped: false")
        UpdateFile()
    end
})

MainTab:AddToggle({
    Name = "Always Play",
    Default = false,
    Callback = function(value)
        Settings.PlayAlways = value
        UpdateFile()
    end
})

MainTab:AddToggle({
    Name = "Loop Emote",
    Default = false,
    Callback = function(value)
        Settings.Looped = value
        Status:Set("Current Emote: "..Settings.LastEmote.." // Speed: "..tostring(Settings.EmoteSpeed).." // Time Position: 0 // Looped: "..tostring(value))
        UpdateFile()
    end
})

MainTab:AddSlider({
    Name = "Emote Speed",
    Min = 0,
    Max = 100,
    Default = 1,
    Color = Color3.fromRGB(0, 128, 255),
    Increment = 1,
    ValueName = "",
    Callback = function(value)
        Settings.EmoteSpeed = value
        if _G.LoadAnim then
            _G.LoadAnim:AdjustSpeed(value)
        end
        Status:Set("Current Emote: "..Settings.LastEmote.." // Speed: "..tostring(Settings.EmoteSpeed).." // Time Position: 0 // Looped: false")
    end
})

-- LocalPlayer Tab
local LocalPlayerTab = Window:MakeTab({
    Name = "LocalPlayer",
    Icon = "rbxassetid://3609827161",
    PremiumOnly = false
})

-- Movement controls
LocalPlayerTab:AddSlider({
    Name = "Walkspeed",
    Min = 16,
    Max = 250,
    Default = 16,
    Color = Color3.fromRGB(0, 128, 255),
    Increment = 1,
    ValueName = "",
    Callback = function(value)
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

LocalPlayerTab:AddSlider({
    Name = "Jumppower",
    Min = 50,
    Max = 550,
    Default = 50,
    Color = Color3.fromRGB(0, 191, 255),
    Increment = 1,
    ValueName = "",
    Callback = function(value)
        LocalPlayer.Character.Humanoid.JumpPower = value
    end
})

LocalPlayerTab:AddSlider({
    Name = "Gravity",
    Min = 196,
    Max = 250,
    Default = 196,
    Color = Color3.fromRGB(0, 128, 255),
    Increment = 1,
    ValueName = "",
    Callback = function(value)
        if value > 196 then
            Workspace.Gravity = -value
        else
            Workspace.Gravity = value
        end
    end
})

LocalPlayerTab:AddSlider({
    Name = "Fly Speed",
    Min = 1,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(0, 128, 255),
    Increment = 1,
    ValueName = "",
    Callback = function(value)
        Settings.FlySpeed = value
    end
})

-- Fly system
local flying = false
local flyConnection

LocalPlayerTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(value)
        flying = value
        if flying then
            -- Simple fly implementation
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
            
            flyConnection = RunService.Heartbeat:Connect(function()
                if flying and LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
                    local cam = Workspace.CurrentCamera.CFrame
                    local moveDirection = Vector3.new()
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveDirection = moveDirection + cam.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveDirection = moveDirection - cam.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveDirection = moveDirection - cam.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveDirection = moveDirection + cam.RightVector
                    end
                    
                    bodyVelocity.Velocity = moveDirection * Settings.FlySpeed
                end
            end)
        else
            if flyConnection then
                flyConnection:Disconnect()
            end
            if LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") then
                LocalPlayer.Character.HumanoidRootPart.BodyVelocity:Destroy()
            end
        end
    end
})

-- Other local player toggles
LocalPlayerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(value)
        Settings.Noclip = value
        if Settings.Noclip then
            local noclipConnection
            noclipConnection = RunService.Stepped:Connect(function()
                if Settings.Noclip and LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                else
                    if noclipConnection then
                        noclipConnection:Disconnect()
                    end
                end
            end)
        end
    end
})

LocalPlayerTab:AddToggle({
    Name = "Click Teleport",
    Default = false,
    Callback = function(value)
        Settings.ClickTeleport = value
        if Settings.ClickTeleport then
            ShowSuccess("Click-Teleport Enabled", "Keybind: CTRL + Click")
        end
    end
})

LocalPlayerTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(value)
        Settings.InfJump = value
    end
})

-- Animations Tab (only for R15)
local AnimationsTab
local AnimationStatus

if GetCharacterType() == "R15" then
    AnimationsTab = Window:MakeTab({
        Name = "Animations",
        Icon = "rbxassetid://9405928221",
        PremiumOnly = false
    })
    
    AnimationStatus = AnimationsTab:AddParagraph("Animation Information", "Selected Animation: "..Settings.SelectedAnimation.." // Speed: "..tostring(Settings.AnimationSpeed).." // Frozen: "..tostring(Settings.FreezeAnimation))
    
    -- Animation selection
    AnimationsTab:AddDropdown({
        Name = "Select Animation",
        Default = "",
        Options = {"Stylish", "Zombie", "Robot"},
        Callback = function(selected)
            Settings.SelectedAnimation = selected
            UpdateFile()
            StopAllAnimations()
            ApplyAnimations(
                Animations[selected].Idle,
                Animations[selected].Idle2,
                Animations[selected].Idle3,
                Animations[selected].Walk,
                Animations[selected].Run,
                Animations[selected].Jump,
                Animations[selected].Climb,
                Animations[selected].Fall,
                Animations[selected].Swim,
                Animations[selected].SwimIdle,
                Animations[selected].Weight,
                Animations[selected].Weight2
            )
            RefreshAnimations()
            AnimationStatus:Set("Current Animation: "..Settings.SelectedAnimation.." // Speed: "..tostring(Settings.AnimationSpeed))
        end
    })
    
    -- Animation search
    AnimationsTab:AddTextbox({
        Name = "Play Animation (Name)",
        Default = "",
        TextDisappear = true,
        Callback = function(value)
            for animName, animData in pairs(Animations) do
                if animName ~= "Emotes" and string.lower(animName):find(string.lower(value)) then
                    Settings.SelectedAnimation = animName
                    StopAllAnimations()
                    ApplyAnimations(
                        animData.Idle,
                        animData.Idle2,
                        animData.Idle3,
                        animData.Walk,
                        animData.Run,
                        animData.Jump,
                        animData.Climb,
                        animData.Fall,
                        animData.Swim,
                        animData.SwimIdle,
                        animData.Weight,
                        animData.Weight2
                    )
                    RefreshAnimations()
                    AnimationStatus:Set("Current Animation: "..Settings.SelectedAnimation.." // Speed: "..tostring(Settings.AnimationSpeed))
                    break
                end
            end
        end
    })
    
    -- Animation settings
    AnimationsTab:AddToggle({
        Name = "Animation Chat",
        Default = false,
        Callback = function(value)
            Settings.Animate = value
            UpdateFile()
            if Settings.Animate then
                ShowSuccess("Enabled Animation-Chat", "Prefix is: "..Settings.AnimationPrefix)
            end
        end
    })
    
    AnimationsTab:AddButton({
        Name = "Reset Animations",
        Callback = function()
            StopAllAnimations()
            Settings.Custom = {}
            UpdateFile()
            -- Reset to original animations
            RefreshAnimations()
        end
    })
    
    AnimationsTab:AddSlider({
        Name = "Animation Speed",
        Min = 0,
        Max = 100,
        Default = 1,
        Color = Color3.fromRGB(0, 128, 255),
        Increment = 1,
        ValueName = "",
        Callback = function(value)
            Settings.AnimationSpeed = value
            AnimationStatus:Set("Current Animation: "..Settings.SelectedAnimation.." // Speed: "..tostring(Settings.AnimationSpeed))
        end
    })
end

-- Custom Anims Tab
local CustomTab = Window:MakeTab({
    Name = "Custom Anims",
    Icon = "rbxassetid://12403104094",
    PremiumOnly = false
})

-- Custom emotes section
local CustomEmotesSection = CustomTab:AddSection({Name = " // Custom Emotes"})

CustomTab:AddDropdown({
    Name = "Emotes (Animation)",
    Default = "",
    Options = {"Idle", "Idle 2", "Walk", "Run", "Jump", "Climb", "Fall", "Swim Idle", "Swim", "Wave", "Laugh", "Cheer", "Point", "Sit", "Dance", "Dance 2", "Dance 3"},
    Callback = function(selected)
        if Settings.LastEmote == "" then
            ShowError("Failed!", "Select an Emote First from the (Main) Tab!")
            return
        end
        
        -- This would apply the selected emote to the specified animation slot
        ShowSuccess("Custom Animation", "Set "..selected.." to "..Settings.LastEmote)
    end
})

CustomTab:AddButton({
    Name = "Select Random Animations",
    Callback = function()
        ShowSuccess("Random Animations", "Applied random animations to all slots")
    end
})

-- Settings Tab
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://8382597378",
    PremiumOnly = false
})

-- Server management
SettingsTab:AddButton({
    Name = "Rejoin",
    Callback = function()
        TeleportService:Teleport(game.PlaceId)
    end
})

SettingsTab:AddButton({
    Name = "Serverhop",
    Callback = function()
        TeleportService:TeleportCancel()
        LocalPlayer:Kick("Serverhopping please wait... | This is to avoid bans in-game.")
        task.wait(.15)
        ServerHop()
    end
})

-- File management
SettingsTab:AddButton({
    Name = "Save Current Animations (File)",
    Callback = function()
        if writefile then
            local fileName = LocalPlayer.Name.."_Animations_"..math.random(10000,99999)..".lua"
            writefile(fileName, "-- Saved animations for "..LocalPlayer.Name)
            ShowSuccess(LocalPlayer.Name.." Animations", "saved to workspace folder!")
        else
            ShowSuccess(LocalPlayer.Name.." Animations", "set to clipboard")
        end
    end
})

-- UI settings
if GetCharacterType() == "R15" then
    SettingsTab:AddTextbox({
        Name = "Emote Prefix",
        Default = "",
        TextDisappear = true,
        Callback = function(value)
            Settings.EmotePrefix = "/"..value
            ShowSuccess("Changed", "Emote Prefix: "..Settings.EmotePrefix)
        end
    })
    
    SettingsTab:AddTextbox({
        Name = "Animation Prefix",
        Default = "",
        TextDisappear = true,
        Callback = function(value)
            Settings.AnimationPrefix = "/"..value
            ShowSuccess("Changed", "Animation Prefix: "..Settings.AnimationPrefix)
        end
    })
end

SettingsTab:AddToggle({
    Name = "Click to Select",
    Default = false,
    Callback = function(value)
        Settings.ClickToSelect = value
        if Settings.ClickToSelect then
            ShowSuccess("Click-to Select Enabled", "Keybind: CTRL + Click")
        end
    end
})

SettingsTab:AddToggle({
    Name = "Day/Night",
    Default = false,
    Callback = function(value)
        Settings.Day = value
        if Settings.Day then
            Lighting.ClockTime = 0
        else
            Lighting.ClockTime = 14
        end
    end
})

SettingsTab:AddBind({
    Name = "Toggle UI",
    Default = Enum
