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
