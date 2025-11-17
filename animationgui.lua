-- Servicios 
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")

-- Variables locales
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Animate = Character:WaitForChild("Animate")
local Animator = Humanoid:WaitForChild("Animator")

-- Esperar a que el juego cargue completamente
repeat task.wait() until game:IsLoaded() and LocalPlayer and Character and Animate and Humanoid and Animator

-- Configuración inicial
local ANIMATION_BASE_URL = "http://www.roblox.com/asset/?id="

-- Configuración global
if not getgenv().OrigLighting then
    getgenv().OrigLighting = Lighting.ClockTime
end

if not getgenv().AlreadyLoaded then
    getgenv().AlreadyLoaded = false
end

-- Habilitar animaciones personalizadas
game.StarterPlayer.AllowCustomAnimations = true
Workspace:SetAttribute("RbxLegacyAnimationBlending", true)

-- Guardar animaciones originales
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

-- Función para obtener animación original
local function GetOriginalAnimation(index)
    return getgenv().OriginalAnimations[index]
end

-- Configuración de teletransporte
if syn and syn.queue_on_teleport and not getgenv().AlreadyLoaded then
    syn.queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/iivxnu/mis-scripts/refs/heads/main/animationgui.lua'))()")
elseif queue_on_teleport and not getgenv().AlreadyLoaded then
    queue_on_teleport([[
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua',true))()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/iivxnu/mis-scripts/refs/heads/main/animationgui.lua'))()
    ]])
end

-- Anti-AFK
local VirtualInput = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    VirtualInput:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualInput:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

-- Contadores
local EmoteCount = 0
local AnimationCount = 0

-- Configuración principal
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

-- Sistema de archivos
if makefolder and not isfile("Animation-gui") then
    makefolder("Animation-gui")
end

if isfile and not isfile("Animation-gui_Settings.txt") and writefile then
    writefile('Animation-gui_Settings.txt', HttpService:JSONEncode(getgenv().Settings))
end

function UpdateFile()
    if writefile then
        writefile('Animation-gui_Settings.txt', HttpService:JSONEncode(getgenv().Settings))
    end
end

if readfile and isfile("Animation-gui_Settings.txt") then
    getgenv().Settings = HttpService:JSONDecode(readfile('Animation-gui_Settings.txt'))
    if Settings.EmotePrefix and Settings.EmotePrefix == "/e" then
        Settings.EmotePrefix = "/em"
        UpdateFile()
    end
end

-- Funciones de utilidad
local Request = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request

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

function GetPlayersByName(name)
    local searchName, searchLength = string.lower(name), #name
    local foundPlayers = {}
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if name:sub(1, 1) == '@' then
                if string.sub(string.lower(player.Name), 1, searchLength - 1) == name:sub(2) then
                    return player
                end
            else
                if string.sub(string.lower(player.Name), 1, searchLength) == name or 
                   string.sub(string.lower(player.DisplayName), 1, searchLength) == name then
                    return player
                end
            end
        end
    end
end

-- Interfaz de usuario
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/iivxnu/mis-scripts/refs/heads/main/UILibrary.lua'))()

local function ShowError(title, message)
    OrionLib:MakeNotification({
        Name = "Animation - Error",
        Content = title .. "\n" .. message,
        Image = "rbxassetid://161551681",
        Time = 4
    })
end

local function ShowSuccess(title, message)
    OrionLib:MakeNotification({
        Name = "Animation - Success",
        Content = title .. "\n" .. message,
        Image = "rbxassetid://4914902889",
        Time = 4
    })
end

local function ShowTimedSuccess(title, message, duration)
    OrionLib:MakeNotification({
        Name = "Animation - Success",
        Content = title .. "\n" .. message,
        Image = "rbxassetid://4914902889",
        Time = duration
    })
end

-- Cargar notificación inicial
task.spawn(function()
    if getgenv().Teleported and game.CoreGui:FindFirstChild("Orion") then
        game.CoreGui.Orion.Enabled = false
        ShowSuccess("Successfully Loaded Animations Script", "Press Q to Toggle UI we've minimized it because you're coming from a different server.")
    end
end)

-- =============================================================================
-- TABLA DE EMOTES (E)
-- =============================================================================
local E = {
    -- Dance Emotes
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
    ['Idol'] = 4101966434,
    ['Curtsy'] = 4555816777,
    ['Happy'] = 4841405708,
    ["Quiet Waves"] = 7465981288,
    ['Sleep'] = 4686925579,
    ["Floss Dance"] = 5917459365,
    ['Shy'] = 3337978742,
    ['Godlike'] = 3337994105,
    ["Hero Landing"] = 5104344710,
    ["High Wave"] = 5915690960,
    
    -- Action Emotes
    ['Cower'] = 4940563117,
    ['Bored'] = 5230599789,
    ["Show Dem Wrists -KSI"] = 7198989668,
    ['Celebrate'] = 3338097973,
    ['Dash'] = 582855105,
    ['Beckon'] = 5230598276,
    ['Haha'] = 3337966527,
    ["Lasso Turn - Tai Verdes"] = 7942896991,
    ["Line Dance"] = 4049037604,
    ['Shrug'] = 3334392772,
    ['Point2'] = 3344585679,
    ['Stadium'] = 3338055167,
    ['Confused'] = 4940561610,
    ['Side to Side'] = 3333136415,
    
    -- Music Related Emotes
    ["Old Town Road Dance - Lil Nas X"] = 5937560570,
    ['Dolphin Dance'] = 5918726674,
    ['Samba'] = 6869766175,
    ['Break Dance'] = 5915648917,
    ["Hips Poppin' - Zara Larsson"] = 6797888062,
    ['Wake Up Call - KSI'] = 7199000883,
    ['Greatest'] = 3338042785,
    ["On The Outside - Twenty One"] = 7422779536,
    ['Boxing Punch - KSI'] = 7202863182,
    
    -- Emotional Emotes
    ['Sad'] = 4841407203,
    ['Flowing Breeze'] = 7465946930,
    ['Twirl'] = 3334968680,
    ['Jumping Wave'] = 4940564896,
    ["HOLIDAY Dance - Lil Nas X (LNX)"] = 5937558680,
    ["Take Me Under - Zara Larsson"] = 6797890377,
    ['Dizzy'] = 3361426436,
    ["Dancing' Shoes - Twenty One"] = 7404878500,
    ['Fashionable'] = 3333331310,
    ['Fast Hands'] = 4265701731,
    
    -- Pose Emotes
    ['Tree'] = 4049551434,
    ['Agree'] = 4841397952,
    ['Power Blast'] = 4841403964,
    ['Swoosh'] = 3361481910,
    ['Jumping Cheer'] = 5895324424,
    ['Disagree'] = 4841401869,
    ["Rodeo Dance - Lil Nas X (LNX)"] = 5918728267,
    ["It Ain't My Fault - Zara Larsson"] = 6797891807,
    ['Rock On'] = 5915714366,
    ['Block Partier'] = 6862022283,
    
    -- Character Emotes
    ['Dorky Dance'] = 4212455378,
    ['Zombie'] = 4210116953,
    ['AOK - Tai Verdes'] = 7942885103,
    ['T'] = 3338010159,
    ['Cobra Arms - Tai Verdes'] = 7942890105,
    ['Panini Dance - Lil Nas X (LNX)"] = 5915713518,
    ['Fishing'] = 3334832150,
    ['Robot'] = 3338025566,
    ['Keeping Time'] = 4555808220,
    ['Air Dance'] = 4555782893,
    
    -- Music Artist Emotes
    ['Rock Guitar - Royal Blood'] = 6532134724,
    ["Borock's Rage"] = 3236842542,
    ["Ud'zal's Summoning"] = 3303161675,
    ['Y'] = 4349285876,
    ['Swan Dance'] = 7465997989,
    ['Louder'] = 3338083565,
    ['Up and Down - Twenty One'] = 7422797678,
    ['Drummer Moves - Twenty One'] = 7422527690,
    ['Sneaky'] = 3334424322,
    ['Heisman Pose'] = 3695263073,
    
    -- Sport Emotes
    ['Jacks'] = 3338066331,
    ['Cha-Cha 2'] = 3695322025,
    ['Superhero Reveal'] = 3695373233,
    ['Air Guitar'] = 3695300085,
    ['Dismissive Wave'] = 3333272779,
    ["Country Line Dance - Lil Nas X"] = 5915712534,
    ['Salute'] = 3333474484,
    ['Applaud'] = 5915693819,
    ['Get Out'] = 3333272779,
    ['Bunny Hop'] = 4641985101,
    
    -- K-Pop Emotes
    ['Hwaiting (화이팅)'] = 9527885267,
    ['Annyeong (안녕)'] = 9527883498,
    ['Gashina - SUNMI'] = 9527886709,
    
    -- Brand Emotes
    ['BURBERRY LOLA ATTITUDE - NIMBUS'] = 10147821284,
    ['BURBERRY LOLA ATTITUDE - GEM'] = 10147815602,
    ['BURBERRY LOLA ATTITUDE - HYDRO'] = 10147823318,
    ['BURBERRY LOLA ATTITUDE - BLOOM'] = 10147817997,
    
    -- Modern Emotes
    ['Sandwich Dance'] = 4406555273,
    ['Hyperfast 5G Dance Move'] = 9408617181,
    ['Victory - 24kGoldn'] = 9178377686,
    ['Tantrum'] = 5104341999,
    ['Rock Star - Royal Blood'] = 10714400171,
    ['Drum Solo - Royal Blood'] = 6532839007,
    ['Drum Master - Royal Blood'] = 6531483720,
    ['High Hands'] = 9710985298,
    ['Tilt'] = 3334538554,
    ['Chicken Dance'] = 4841399916,
    
    -- [Continúa con más emotes...]
    ["You can't sit with us - Sunmi"] = 9983520970,
    ["Frosty Flair - Tommy Hilfiger"] = 10214311282,
    ["Floor Rock Freeze - Tommy Hilfiger"] = 10214314957,
    ['Boom Boom Clap - George Ezra'] = 10370346995,
    ['Cartwheel - George Ezra'] = 10370351535,
    ['Chill Vibes - George Ezra'] = 10370353969,
    ['Sidekicks - George Ezra'] = 10370362157,
    ['The Conductor - George Ezra'] = 10370359115,
    
    -- Gaming & Internet Culture
    ['Super Charge'] = 10478338114,
    ['Swag Walk'] = 10478341260,
    ['Mean Mug - Tommy Hilfiger'] = 10214317325,
    ['V Pose - Tommy Hilfiger'] = 10214319518,
    ['Uprise - Tommy Hilfiger'] = 10275008655,
    ["2 Baddies Dance Move - NCT 127"] = 12259828678,
    ["Kick It Dance Move - NCT 127"] = 12259826609,
    ["Sticker Dance Move - NCT 127"] = 12259825026,
    
    -- Artist Collaboration Emotes
    ['Elton John - Rock Out'] = 11753474067,
    ['Elton John - Heart Skip'] = 11309255148,
    ['Elton John - Still Standing'] = 11444443576,
    ['Elton John - Elevate'] = 11394033602,
    ['Elton John - Cat Man'] = 11444441914,
    ['Elton John - Piano Jump'] = 11453082181,
    
    -- Yoga & Fitness
    ['Alo Yoga Pose - Triangle'] = 12507084541,
    ['Alo Yoga Pose - Warrior II'] = 12507083048,
    ['Alo Yoga Pose - Lotus Position'] = 12507085924,
    
    -- K-Pop Groups
    ['TWICE-Moonlight-Sunrise'] = 12714233242,
    ['TWICE-Set-Me-Free-Dance-1'] = 12714228341,
    ['TWICE-Set-Me-Free-Dance-2'] = 12714231087,
    ['Ay-Yo-Dance-Move-NCT-127'] = 12804157977,
    ['TWICE-The-Feels'] = 12874447851,
    ['Zombie'] = 10714089137,
    ['Rise-Above-The-Chainsmokers'] = 12992262118,
    ['TWICE-What-Is-Love'] = 13327655243,
    
    -- Sports & Athletics
    ['Man-City-Bicycle-Kick'] = 13421057998,
    ['TWICE-Fancy'] = 13520524517,
    ['TWICE Pop by Nayeon'] = 13768941455,
    ['Man City Backflip'] = 13694100677,
    ['Man-City-Scorpion-Kick'] = 13694096724,
    
    -- Modern Dance
    ['Arm Twist'] = 10713968716,
    ['Tommy - Archer'] = 13823324057,
    ['YUNGBLUD – HIGH KICK'] = 14022936101,
    ['TWICE Like Ooh-Ahh'] = 14123781004,
    
    -- Baby Queen Series
    ['Baby Queen - Air Guitar & Knee Slide'] = 14352335202,
    ['Baby Queen - Dramatic Bow'] = 14352337694,
    ['Baby Queen - Face Frame'] = 14352340648,
    ['Baby Queen - Bouncy Twirl'] = 14352343065,
    ['Baby Queen - Strut'] = 14352362059,
    
    -- BLACKPINK Series
    ['BLACKPINK Pink Venom - Get em Get em Get em'] = 14548619594,
    ['BLACKPINK Pink Venom - I Bring the Pain Like…'] = 14548620495,
    ['BLACKPINK Pink Venom - Straight to Ya Dome'] = 14548621256,
    ['TWICE LIKEY'] = 14899979575,
    ['TWICE Feel Special'] = 14899980745,
    ['BLACKPINK Shut Down - Part 1'] = 14901306096,
    ['BLACKPINK Shut Down - Part 2'] = 14901308987,
    
    -- Seasonal & Special
    ["Bone Chillin' Bop"] = 15122972413,
    ['Paris Hilton - Sliving For The Groove'] = 15392759696,
    ['Paris Hilton - Iconic IT-Grrrl'] = 15392756794,
    ['Paris Hilton - Checking My Angles'] = 15392752812,
    
    -- BLACKPINK Solo
    ['BLACKPINK JISOO Flower'] = 15439354020,
    ['BLACKPINK JENNIE You and Me'] = 15439356296,
    
    -- Rock & Metal
    ['Rock n Roll'] = 15505458452,
    ['Air Guitar'] = 15505454268,
    ['Victory Dance'] = 15505456446,
    ['Flex Walk'] = 15505459811,
    
    -- Olivia Rodrigo Series
    ['Olivia Rodrigo Head Bop'] = 15517864808,
    ['Olivia Rodrigo good 4 u'] = 15517862739,
    ['Olivia Rodrigo Fall Back to Float'] = 15549124879,
    
    -- Nicki Minaj Series
    ["Nicki Minaj That's That Super Bass"] = 15571446961,
    ['Nicki Minaj Boom Boom Boom'] = 15571448688,
    ['Nicki Minaj Anaconda'] = 15571450952,
    ['Nicki Minaj Starships'] = 15571453761,
    
    -- Yungblud Series
    ['Yungblud Happier Jump'] = 15609995579,
    
    -- Festival & Celebration
    ['Festive Dance'] = 15679621440,
    ['BLACKPINK LISA Money'] = 15679623052,
    ['BLACKPINK ROSÉ On The Ground'] = 15679624464,
    
    -- Music Video Dances
    ['Imagine Dragons - "Bones" Dance'] = 15689279687,
    ['GloRilla - "Tomorrow" Dance'] = 15689278184,
    ['d4vd - Backflip'] = 15693621070,
    ['ericdoa - dance'] = 15698402762,
    ['Cuco - Levitate'] = 15698404340,
    
    -- Movie & TV Inspired
    ['Mean Girls Dance Break'] = 15963314052,
    ['Paris Hilton Sanasa'] = 16126469463,
    
    -- BLACKPINK Hits
    ['BLACKPINK Ice Cream'] = 16181797368,
    ['BLACKPINK Kill This Love'] = 16181798319,
    
    -- TWICE Series
    ['TWICE I GOT YOU part 1'] = 16215030041,
    ['TWICE I GOT YOU part 2'] = 16256203246,
    
    -- Artist Series
    ["Dave's Spin Move - Glass Animals"] = 16272432203,
    ['Sol de Janeiro - Samba'] = 16270690701,
    ['Beauty Touchdown'] = 16302968986,
    ['Skadoosh Emote - Kung Fu Panda 4'] = 16371217304,
    ['Jawny - Stomp'] = 16392075853,
    ['Mae Stephens - Piano Hands'] = 16553163212,
    
    -- More BLACKPINK
    ['BLACKPINK Boombayah Emote'] = 16553164850,
    ['BLACKPINK DDU-DU DDU-DU'] = 16553170471,
    ['HIPMOTION - Amaarae'] = 16572740012,
    ['Mae Stephens – Arm Wave'] = 16584481352,
    
    -- Interactive Emotes
    ['Wanna play?'] = 16646423316,
    ['BLACKPINK-How-You-Like-That'] = 16874470507,
    ['BLACKPINK - Lovesick Girls'] = 16874472321,
    
    -- Character Emotes
    ['Mini Kong'] = 17000021306,
    ["HUGO Let's Drive!"] = 17360699557,
    ['Wisp - air guitar'] = 17370775305,
    ['Vans Ollie'] = 18305395285,
    
    -- TikTok & Social Media Dances
    ['Sturdy Dance - Ice Spice'] = 17746180844,
    ['Shuffle'] = 17748314784,
    ['Rolling Stones Guitar Strum'] = 18148804340,
    ['Rock Out - Bebe Rexha'] = 18225053113,
    
    -- Movie & Cartoon Inspired
    ['SpongeBob Imaginaaation 🌈'] = 18443237526,
    ['SpongeBob Dance'] = 18443245017,
    ['Shrek Roar'] = 18524313628,
    
    -- Sports Emotes
    ['Team USA Breaking Emote'] = 18526288497,
    ['NBA WNBA Fadeaway'] = 18526362841,
    ['Vroom Vroom'] = 18526397037,
    ['TMNT Dance'] = 18665811005,
    ['Olympic Dismount'] = 18665825805,
    
    -- More BLACKPINK Classics
    ["BLACKPINK As If It's Your Last"] = 18855536648,
    ["BLACKPINK Don't know what to do"] = 18855531354,
    
    -- TWICE Solo
    ['TWICE ABCD by Nayeon'] = 18933706381,
    ['Charli xcx - Apple Dance'] = 18946844622,
    
    -- Viral & Internet
    ['The Zabb'] = 129470135909814,
    ['Fashion Klossette - Runway my way'] = 80995190624232,
    ['ALTÉGO - Couldn't Care Less'] = 107875941017127,
    ['Fashion Roadkill'] = 136831243854748,
    ['Skibidi Toilet - Titan Speakerman Laser Spin'] = 134283166482394,
    
    -- Modern Pop Culture
    ['Chappell Roan HOT TO GO!'] = 85267023718407,
    ['Secret Handshake Dance'] = 71243990877913,
    ['KATSEYE - Touch'] = 135876612109535,
    ['Fashion Spin'] = 131669256082047,
    ['TWICE Strategy'] = 97311229290836,
    ['NBA Monster Dunk'] = 132748833449150,
    ['DearALICE - Ariana'] = 134318425949290,
    
    -- The Weeknd Series
    ['The Weeknd Starboy Strut'] = 71105746210464,
    ['The Weeknd Opening Night'] = 133110725387025,
    
    -- Movie Character Emotes
    ['Robot M3GAN'] = 125803725853577,
    ["M3GAN's Dance"] = 99649534578309,
    ['Rasputin – Boney M.'] = 114872820353992,
    
    -- Squid Game Inspired
    ['Thanos Happy Jump - Squid Game'] = 97611664803614,
    ['Young-hee Head Spin - Squid Game'] = 112011282168475,
    
    -- More TWICE
    ['TWICE Takedown'] = 140182843839424,
    ['Stray Kids Walkin On Water'] = 125064469983655
}

-- =============================================================================
-- TABLA DE ANIMACIONES (F)
-- =============================================================================
local F = {
    Emotes = {
        Weight = 9,
        Weight2 = 1
    },
    
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
    },
    
    Robot = {
        Idle = 616088211,
        Idle2 = 616089559,
        Idle3 = 885531463,
        Walk = 616095330,
        Run = 616091570,
        Jump = 616090535,
        Climb = 616086039,
        Fall = 616087089,
        Swim = 616092998,
        SwimIdle = 616094091,
        Weight = 9,
        Weight2 = 1
    },
    
    Toy = {
        Idle = 782841498,
        Idle2 = 782845736,
        Idle3 = 980952228,
        Walk = 782843345,
        Run = 782842708,
        Jump = 782847020,
        Climb = 782843869,
        Fall = 782846423,
        Swim = 782844582,
        SwimIdle = 782845186,
        Weight = 9,
        Weight2 = 1
    },
    
    Cartoony = {
        Idle = 742637544,
        Idle2 = 742638445,
        Idle3 = 885477856,
        Walk = 742640026,
        Run = 742638842,
        Jump = 742637942,
        Climb = 742636889,
        Fall = 742637151,
        Swim = 742639220,
        SwimIdle = 742639812,
        Weight = 9,
        Weight2 = 1
    },
    
    Superhero = {
        Idle = 616111295,
        Idle2 = 616113536,
        Idle3 = 885535855,
        Walk = 616122287,
        Run = 616117076,
        Jump = 616115533,
        Climb = 616104706,
        Fall = 616108001,
        Swim = 616119360,
        SwimIdle = 616120861,
        Weight = 9,
        Weight2 = 1
    },
    
    Mage = {
        Idle = 707742142,
        Idle2 = 707855907,
        Idle3 = 885508740,
        Walk = 707897309,
        Run = 707861613,
        Jump = 707853694,
        Climb = 707826056,
        Fall = 707829716,
        Swim = 707876443,
        SwimIdle = 707894699,
        Weight = 9,
        Weight2 = 1
    },
    
    Levitation = {
        Idle = 616006778,
        Idle2 = 616008087,
        Idle3 = 886862142,
        Walk = 616013216,
        Run = 616010382,
        Jump = 616008936,
        Climb = 616003713,
        Fall = 616005863,
        Swim = 616011509,
        SwimIdle = 616012453,
        Weight = 9,
        Weight2 = 1
    },
    
    Vampire = {
        Idle = 1083445855,
        Idle2 = 1083450166,
        Idle3 = 1088037547,
        Walk = 1083473930,
        Run = 1083462077,
        Jump = 1083455352,
        Climb = 1083439238,
        Fall = 1083443587,
        Swim = 1083464683,
        SwimIdle = 1083467779,
        Weight = 9,
        Weight2 = 1
    },
    
    Elder = {
        Idle = 845397899,
        Idle2 = 845400520,
        Idle3 = 901160519,
        Walk = 845403856,
        Run = 845386501,
        Jump = 845398858,
        Climb = 845392038,
        Fall = 845396048,
        Swim = 845401742,
        SwimIdle = 845403127,
        Weight = 9,
        Weight2 = 1
    },
    
    Werewolf = {
        Idle = 1083195517,
        Idle2 = 1083214717,
        Idle3 = 1099492820,
        Walk = 1083178339,
        Run = 1083216690,
        Jump = 1083218792,
        Climb = 1083182000,
        Fall = 1083189019,
        Swim = 1083222527,
        SwimIdle = 1083225406,
        Weight = 9,
        Weight2 = 1
    },
    
    Knight = {
        Idle = 657595757,
        Idle2 = 657568135,
        Idle3 = 885499184,
        Walk = 657552124,
        Run = 657564596,
        Jump = 658409194,
        Climb = 658360781,
        Fall = 657600338,
        Swim = 657560551,
        SwimIdle = 657557095,
        Weight = 9,
        Weight2 = 1
    },
    
    Bold = {
        Idle = 16738333868,
        Idle2 = 16738334710,
        Idle3 = 16738335517,
        Walk = 16738340646,
        Run = 16738337225,
        Jump = 16738336650,
        Climb = 16738332169,
        Fall = 16738333171,
        Swim = 16738339158,
        SwimIdle = 16738339817,
        Weight = 9,
        Weight2 = 1
    },
    
    Astronaut = {
        Idle = 891621366,
        Idle2 = 891633237,
        Idle3 = 1047759695,
        Walk = 891667138,
        Run = 891636393,
        Jump = 891627522,
        Climb = 891609353,
        Fall = 891617961,
        Swim = 891639666,
        SwimIdle = 891663592,
        Weight = 9,
        Weight2 = 1
    },
    
    Bubbly = {
        Idle = 910004836,
        Idle2 = 910009958,
        Idle3 = 1018536639,
        Walk = 910034870,
        Run = 910025107,
        Jump = 910016857,
        Climb = 909997997,
        Fall = 910001910,
        Swim = 910028158,
        SwimIdle = 910030921,
        Weight = 9,
        Weight2 = 1
    },
    
    Pirate = {
        Idle = 750781874,
        Idle2 = 750782770,
        Idle3 = 885515365,
        Walk = 750785693,
        Run = 750783738,
        Jump = 750782230,
        Climb = 750779899,
        Fall = 750780242,
        Swim = 750784579,
        SwimIdle = 750785176,
        Weight = 9,
        Weight2 = 1
    },
    
    Rthro = {
        Idle = 2510196951,
        Idle2 = 2510197257,
        Idle3 = 3711062489,
        Walk = 2510202577,
        Run = 2510198475,
        Jump = 2510197830,
        Climb = 2510192778,
        Fall = 2510195892,
        Swim = 2510199791,
        SwimIdle = 2510201162,
        Weight = 9,
        Weight2 = 1
    },
    
    Ninja = {
        Idle = 656117400,
        Idle2 = 656118341,
        Idle3 = 886742569,
        Walk = 656121766,
        Run = 656118852,
        Jump = 656117878,
        Climb = 656114359,
        Fall = 656115606,
        Swim = 656119721,
        SwimIdle = 656121397,
        Weight = 9,
        Weight2 = 1
    },
    
    Oldschool = {
        Idle = 5319828216,
        Idle2 = 5319831086,
        Idle3 = 5392107832,
        Walk = 5319847204,
        Run = 5319844329,
        Jump = 5319841935,
        Climb = 5319816685,
        Fall = 5319839762,
        Swim = 5319850266,
        SwimIdle = 5319852613,
        Weight = 9,
        Weight2 = 1
    },
    
    ['No Boundaries'] = {
        Idle = 18747067405,
        Idle2 = 18747063918,
        Idle3 = 18747063918,
        Walk = 18747074203,
        Run = 18747070484,
        Jump = 18747069148,
        Climb = 18747060903,
        Fall = 18747062535,
        Swim = 18747073181,
        SwimIdle = 18747071682,
        Weight = 9,
        Weight2 = 1
    },
    
    ['NFL Animation'] = {
        Idle = 92080889861410,
        Idle2 = 74451233229259,
        Idle3 = 80884010501210,
        Walk = 110358958299415,
        Run = 117333533048078,
        Jump = 119846112151352,
        Climb = 134630013742019,
        Fall = 129773241321032,
        Swim = 132697394189921,
        SwimIdle = 79090109939093,
        Weight = 9,
        Weight2 = 1
    },
    
    ['Adidas Sports'] = {
        Idle = 18537376492,
        Idle2 = 18537371272,
        Idle3 = 18537374150,
        Walk = 18537392113,
        Run = 18537384940,
        Jump = 18537380791,
        Climb = 18537363391,
        Fall = 18537367238,
        Swim = 18537389531,
        SwimIdle = 18537387180,
        Weight = 9,
        Weight2 = 1
    },
    
    ['Wickled Popular'] = {
        Idle = 118832222982049,
        Idle2 = 76049494037641,
        Idle3 = 138255200176080,
        Walk = 92072849924640,
        Run = 72301599441680,
        Jump = 104325245285198,
        Climb = 131326830509784,
        Fall = 121152442762481,
        Swim = 99384245425157,
        SwimIdle = 113199415118199,
        Weight = 9,
        Weight2 = 1
    },
    
    ['Catwalk Glam'] = {
        Idle = 133806214992291,
        Idle2 = 94970088341563,
        Idle3 = 87105332133518,
        Walk = 109168724482748,
        Run = 81024476153754,
        Jump = 116936326516985,
        Climb = 119377220967554,
        Fall = 92294537340807,
        Swim = 134591743181628,
        SwimIdle = 98854111361360,
        Weight = 9,
        Weight2 = 1
    },
    
    Princess = {
        Idle = 941003647,
        Idle2 = 941013098,
        Idle3 = 1159195712,
        Walk = 941028902,
        Run = 941015281,
        Jump = 941008832,
        Climb = 940996062,
        Fall = 941000007,
        Swim = 941018893,
        SwimIdle = 941025398,
        Weight = 9,
        Weight2 = 1
    },
    
    Confident = {
        Idle = 1069977950,
        Idle2 = 1069987858,
        Idle3 = 1116160740,
        Walk = 1070017263,
        Run = 1070001516,
        Jump = 1069984524,
        Climb = 1069946257,
        Fall = 1069973677,
        Swim = 1070009914,
        SwimIdle = 1070012133,
        Weight = 9,
        Weight2 = 1
    },
    
    Popstar = {
        Idle = 1212900985,
        Idle2 = 1150842221,
        Idle3 = 1239733474,
        Walk = 1212980338,
        Run = 1212980348,
        Jump = 1212954642,
        Climb = 1213044953,
        Fall = 1212900995,
        Swim = 1212852603,
        SwimIdle = 1070012133,
        Weight = 9,
        Weight2 = 1
    },
    
    Patrol = {
        Idle = 1149612882,
        Idle2 = 1150842221,
        Idle3 = 1159573567,
        Walk = 1151231493,
        Run = 1150967949,
        Jump = 1150944216,
        Climb = 1148811837,
        Fall = 1148863382,
        Swim = 1151204998,
        SwimIdle = 1151221899,
        Weight = 9,
        Weight2 = 1
    },
    
    Sneaky = {
        Idle = 1132473842,
        Idle2 = 1132477671,
        Idle3 = "None",
        Walk = 1132510133,
        Run = 1132494274,
        Jump = 1132489853,
        Climb = 1132461372,
        Fall = 1132469004,
        Swim = 1132500520,
        SwimIdle = 1132506407,
        Weight = 9,
        Weight2 = 1
    },
    
    Cowboy = {
        Idle = 1014390418,
        Idle2 = 1014398616,
        Idle3 = 1159487651,
        Walk = 1014421541,
        Run = 1014401683,
        Jump = 1014394726,
        Climb = 1014380606,
        Fall = 1014384571,
        Swim = 1014406523,
        SwimIdle = 1014411816,
        Weight = 9,
        Weight2 = 1
    },
    
    Ghost = {
        Idle = 616006778,
        Idle2 = 616008087,
        Idle3 = 616008087,
        Walk = 616013216,
        Run = 616013216,
        Jump = 616008936,
        Climb = 0,
        Fall = 616005863,
        Swim = 616011509,
        SwimIdle = 616012453,
        Weight = 9,
        Weight2 = 1
    },
    
    ['Ghost 2'] = {
        Idle = 1151221899,
        Idle2 = 1151221899,
        Idle3 = "None",
        Walk = 1151221899,
        Run = 1151221899,
        Jump = 1151221899,
        Climb = 0,
        Fall = 1151221899,
        Swim = 16738339158,
        SwimIdle = 1151221899,
        Weight = 9,
        Weight2 = 1
    },
    
    ['Mr. Toilet'] = {
        Idle = 4417977954,
        Idle2 = 4417978624,
        Idle3 = 4441285342,
        Walk = 2510202577,
        Run = 4417979645,
        Jump = 2510197830,
        Climb = 2510192778,
        Fall = 2510195892,
        Swim = 2510199791,
        SwimIdle = 2510201162,
        Weight = 9,
        Weight2 = 1
    },
    
    Udzal = {
        Idle = 3303162274,
        Idle2 = 3303162549,
        Idle3 = 3710161342,
        Walk = 3303162967,
        Run = 3236836670,
        Jump = 2510197830,
        Climb = 2510192778,
        Fall = 2510195892,
        Swim = 2510199791,
        SwimIdle = 2510201162,
        Weight = 9,
        Weight2 = 1
    },
    
    ['Oinan Thickhoof'] = {
        Idle = 657595757,
        Idle2 = 657568135,
        Idle3 = 885499184,
        Walk = 2510202577,
        Run = 3236836670,
        Jump = 2510197830,
        Climb = 2510192778,
        Fall = 2510195892,
        Swim = 2510199791,
        SwimIdle = 2510201162,
        Weight = 9,
        Weight2 = 1
    },
    
    Borock = {
        Idle = 3293641938,
        Idle2 = 3293642554,
        Idle3 = 3710131919,
        Walk = 2510202577,
        Run = 3236836670,
        Jump = 2510197830,
        Climb = 2510192778,
        Fall = 2510195892,
        Swim = 2510199791,
        SwimIdle = 2510201162,
        Weight = 9,
        Weight2 = 1
    },
    
    ['Blocky Mech'] = {
        Idle = 4417977954,
        Idle2 = 4417978624,
        Idle3 = 4441285342,
        Walk = 2510202577,
        Run = 4417979645,
        Jump = 2510197830,
        Climb = 2510192778,
        Fall = 2510195892,
        Swim = 2510199791,
        SwimIdle = 2510201162,
        Weight = 9,
        Weight2 = 1
    },
    
    ['Stylized Female'] = {
        Idle = 4708191566,
        Idle2 = 4708192150,
        Idle3 = 121221,
        Walk = 4708193840,
        Run = 4708192705,
        Jump = 4708188025,
        Climb = 4708184253,
        Fall = 4708186162,
        Swim = 4708189360,
        SwimIdle = 4708190607,
        Weight = 9,
        Weight2 = 1
    },
    
    R15 = {
        Idle = 4211217646,
        Idle2 = 4211218409,
        Idle3 = "None",
        Walk = 4211223236,
        Run = 4211220381,
        Jump = 4211219390,
        Climb = 4211214992,
        Fall = 4211216152,
        Swim = 4211221314,
        SwimIdle = 4374694239,
        Weight = 9,
        Weight2 = 1
    },
    
    Mocap = {
        Idle = 913367814,
        Idle2 = 913373430,
        Idle3 = "None",
        Walk = 913402848,
        Run = 913376220,
        Jump = 913370268,
        Climb = 913362637,
        Fall = 913365531,
        Swim = 913384386,
        SwimIdle = 913389285,
        Weight = 9,
        Weight2 = 1
    },
    
    ['Adidas Community'] = {
        Idle = 126354114956642,
        Idle2 = 102357151005774,
        Idle3 = "None",
        Walk = 106810508343012,
        Run = 124765145869332,
        Jump = 115715495289805,
        Climb = 123695349157584,
        Fall = 93993406355955,
        Swim = 106537993816942,
        SwimIdle = 109346520324160,
        Weight = 9,
        Weight2 = 1
    }
}

-- =============================================================================
-- TABLA DE EMOTES R6 
-- =============================================================================
local I = {
    ['Balloon Float'] = {
        Emote = 148840371,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Idle'] = {
        Emote = 180435571,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Arm Turbine'] = {
        Emote = 259438880,
        Speed = 1.5,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Floating Head'] = {
        Emote = 121572214,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Insane Rotation'] = {
        Emote = 121572214,
        Speed = 99,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Scream'] = {
        Emote = 180611870,
        Speed = 1.5,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Party Time'] = {
        Emote = 33796059,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Chop'] = {
        Emote = 33169596,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Weird Sway'] = {
        Emote = 248336677,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Goal!'] = {
        Emote = 28488254,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Rotation'] = {
        Emote = 136801964,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Spin'] = {
        Emote = 188632011,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Weird Float'] = {
        Emote = 248336459,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Pinch Nose'] = {
        Emote = 30235165,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Cry'] = {
        Emote = 180612465,
        Speed = 1.5,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Penguin Slide'] = {
        Emote = 282574440,
        Speed = 0,
        Time = 0,
        Weight = 1,
        Loop = true,
        R6 = true,
        Priority = 2
    },
    
    ['Zombie Arms'] = {
        Emote = 183294396,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Flying'] = {
        Emote = 46196309,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Stab'] = {
        Emote = 66703241,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Dance'] = {
        Emote = 35654637,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Random'] = {
        Emote = 48977286,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Hmmm'] = {
        Emote = 33855276,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Sword'] = {
        Emote = 35978879,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Arms Out'] = {
        Emote = 27432691,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Kick'] = {
        Emote = 45737360,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Insane Legs'] = {
        Emote = 87986341,
        Speed = 99,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Head Detach'] = {
        Emote = 35154961,
        Speed = 0,
        Time = 3,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Moon Walk'] = {
        Emote = 30196114,
        Speed = 0,
        Time = 3,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Crouch'] = {
        Emote = 287325678,
        Speed = 0,
        Time = 3,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Beat Box'] = {
        Emote = 45504977,
        Speed = 0,
        Time = 3,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Big Guns'] = {
        Emote = 161268368,
        Speed = 0,
        Time = 3,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Bigger Guns'] = {
        Emote = 225975820,
        Speed = 0,
        Time = 3,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Charleston'] = {
        Emote = 429703734,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Moon Dance'] = {
        Emote = 27789359,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Roar'] = {
        Emote = 163209885,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Weird Pose'] = {
        Emote = 248336163,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Spin Dance 2'] = {
        Emote = 186934910,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Bow Down'] = {
        Emote = 204292303,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Sword Slam'] = {
        Emote = 204295235,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Glitch Levitate'] = {
        Emote = 313762630,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Full Swing'] = {
        Emote = 218504594,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Full Punch'] = {
        Emote = 204062532,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Faint'] = {
        Emote = 181526230,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Floor Faint'] = {
        Emote = 181525546,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Jumping Jacks'] = {
        Emote = 429681631,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Spin Dance'] = {
        Emote = 429730430,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Arm Detach'] = {
        Emote = 33169583,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Mega Insane'] = {
        Emote = 184574340,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Dino Walk'] = {
        Emote = 204328711,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Tilt Head'] = {
        Emote = 283545583,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Dab'] = {
        Emote = 183412246,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Float Sit'] = {
        Emote = 179224234,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Clone Illusion'] = {
        Emote = 215384594,
        Speed = 1e7,
        Time = .5,
        Weight = 1,
        Loop = true,
        Priority = 2
    },
    
    ['Hero Jump'] = {
        Emote = 184574340,
        Speed = 1,
        Time = 0,
        Weight = 1,
        Loop = true,
        Priority = 2
    }
}

-- =============================================================================
-- LISTAS PARA DROPDOWNS
-- =============================================================================
local ChatCommands = {
    "/e dance3",
    "/e dance2", 
    "/e dance",
    "/e cheer",
    "/e wave",
    "/e laugh",
    "/e point"
}

-- Función para verificar comandos de chat
local function IsChatCommand(command)
    return table.find(ChatCommands, command)
end

-- Crear listas para los dropdowns
local R6EmotesList = {}
for emoteName, emoteData in pairs(I) do
    table.insert(R6EmotesList, emoteName)
end

local AnimationPacksList = {}
for packName, packData in pairs(F) do
    if packName ~= "Weight" and packName ~= "Weight2" and packName ~= "Custom" and packName ~= "Emotes" then
        table.insert(AnimationPacksList, packName)
        AnimationCount = AnimationCount + 1
    end
end

local R15EmotesList = {}
for emoteName, emoteId in pairs(E) do
    table.insert(R15EmotesList, emoteName)
    EmoteCount = EmoteCount + 1
end

-- Ordenar listas alfabéticamente
table.sort(AnimationPacksList, function(a, b)
    return a:lower() < b:lower()
end)

table.sort(R15EmotesList, function(a, b)
    return a:lower() < b:lower()
end)

table.sort(R6EmotesList, function(a, b)
    return a:lower() < b:lower()
end)

-- Mostrar notificación de carga
task.spawn(function()
    ShowTimedSuccess("Eazvy | Emotes & Animations", 
        "Loaded " .. AnimationCount .. " Animations and " .. EmoteCount .. " Emotes!", 9)
end)

-- Funciones principales de animación
local function StopAllAnimations()
    if not getgenv().AlreadyLoaded then return end
    
    repeat wait() until Character and Animate and Humanoid and Animator
    
    for _, track in ipairs(Animator:GetPlayingAnimationTracks()) do
        track:Stop()
    end
end

local function RefreshAnimations()
    if not getgenv().AlreadyLoaded then return end
    
    repeat wait() until Character and Animate and Humanoid and Animator
    
    Animate.Disabled = true
    for _, track in ipairs(Humanoid:GetPlayingAnimationTracks()) do
        track:AdjustSpeed(Settings.AnimationSpeed)
        track:Stop()
    end
    Animate.Disabled = false
end

local function ApplyAnimations(idle1, idle2, idle3, walk, run, jump, climb, fall, swim, swimIdle, weight1, weight2)
    repeat wait() until Character and Animate
    
    if Animate:FindFirstChild("idle") then
        Animate.idle.Animation1.AnimationId = ANIMATION_BASE_URL .. idle1
        Animate.idle.Animation1.Weight.Value = tostring(weight1)
        Animate.idle.Animation2.Weight.Value = tostring(weight2)
        Animate.idle.Animation2.AnimationId = ANIMATION_BASE_URL .. idle2
    end
    
    if idle3 and Animate:FindFirstChild("pose") then
        Animate.pose:FindFirstChildOfClass("Animation").AnimationId = ANIMATION_BASE_URL .. idle3
    end
    
    Animate.walk:FindFirstChildOfClass("Animation").AnimationId = ANIMATION_BASE_URL .. walk
    Animate.run:FindFirstChildOfClass("Animation").AnimationId = ANIMATION_BASE_URL .. run
    Animate.jump:FindFirstChildOfClass("Animation").AnimationId = ANIMATION_BASE_URL .. jump
    Animate.climb:FindFirstChildOfClass("Animation").AnimationId = ANIMATION_BASE_URL .. climb
    Animate.fall:FindFirstChildOfClass("Animation").AnimationId = ANIMATION_BASE_URL .. fall
    
    if Animate:FindFirstChild("swim") then
        Animate.swim:FindFirstChildOfClass("Animation").AnimationId = ANIMATION_BASE_URL .. swim
        Animate.swimidle:FindFirstChildOfClass("Animation").AnimationId = ANIMATION_BASE_URL .. swimIdle
    end
end

-- Aplicar animación específica
local function ApplySpecificAnimation(animationType, animationId)
    repeat wait() until Character and Animate
    
    if animationType:match("idle") then
        if Animate:FindFirstChild("pose") then
            Animate.pose:FindFirstChildOfClass("Animation").AnimationId = ANIMATION_BASE_URL .. animationId
        end
    end
    
    if animationType == "idle1" then
        Animate.idle.Animation1.AnimationId = ANIMATION_BASE_URL .. animationId
    elseif animationType == "idle2" then
        Animate.idle.Animation2.AnimationId = ANIMATION_BASE_URL .. animationId
    elseif animationType:match("dance") then
        for _, anim in pairs(Animate[animationType]:GetChildren()) do
            if anim:IsA("Animation") then
                anim.AnimationId = ANIMATION_BASE_URL .. animationId
            end
        end
    else
        local targetAnimation
        for _, anim in pairs(Animate:GetChildren()) do
            if anim.Name == animationType then
                targetAnimation = anim
                break
            end
        end
        
        if targetAnimation then
            targetAnimation:FindFirstChildOfClass("Animation").AnimationId = ANIMATION_BASE_URL .. animationId
        end
    end
    
    RefreshAnimations()
end

-- Cargar y reproducir emote
local function PlayEmote(animationId)
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. animationId
    
    _G.LoadAnim = Humanoid:LoadAnimation(animation)
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
    
    if not Animate.Disabled then
        Animate.Disabled = true
    end
end

-- Detectar tipo de rig
local function GetRigType()
    local humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
        return "R15"
    else
        return "R6"
    end
end

local function GetPlayerRigType(player)
    if not Settings.Player or not Settings.Player.Character or not Settings.Player.Character:FindFirstChildOfClass("Humanoid") then
        return
    end
    
    local humanoid = Settings.Player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.RigType == Enum.HumanoidRigType.R15 then
        return "R15"
    else
        return "R6"
    end
end

-- Funciones de búsqueda de emotes
local function PlayEmoteByName(emoteName)
    PlayEmote(E[emoteName])
end

local function FindAnimationByName(name)
    for animName, animData in pairs(F) do
        local lowerName = string.lower(animName)
        local lowerSearch = string.lower(name)
        if string.find(animName, name) or string.find(lowerName, lowerSearch) then
            return animName
        end
    end
end

local function SearchEmotes(searchTerm)
    local results = {}
    
    for emoteName, emoteId in pairs(E) do
        local upperName = string.upper(emoteName)
        local upperSearch = string.upper(searchTerm)
        if upperName == upperSearch then
            if not table.find(results, emoteName) then
                table.insert(results, emoteName)
            end
        end
    end
    
    for emoteName, emoteId in pairs(E) do
        local lowerName = string.lower(emoteName)
        local lowerSearch = string.lower(searchTerm)
        if string.find(emoteName, searchTerm) or string.find(lowerName, lowerSearch) then
            if not table.find(results, emoteName) then
                table.insert(results, emoteName)
            end
        end
    end
    
    return results
end

local function FindExactEmote(searchTerm)
    for emoteName, emoteId in pairs(E) do
        local upperName = string.upper(emoteName)
        local upperSearch = string.upper(searchTerm)
        if upperName == upperSearch then
            return emoteName
        end
    end
    
    for emoteName, emoteId in pairs(E) do
        local lowerName = string.lower(emoteName)
        local lowerSearch = string.lower(searchTerm)
        if string.find(emoteName, searchTerm) or string.find(lowerName, lowerSearch) then
            return emoteName
        end
    end
end

-- Aplicar animación seleccionada al inicio
if Settings.SelectedAnimation and Settings.SelectedAnimation ~= "" then
    repeat wait() until Character and Animate
    
    if Settings.SelectedAnimation == "Custom" and GetRigType() == "R15" then
        StopAllAnimations()
        ApplyAnimations(
            Settings.Custom.Idle or GetOriginalAnimation(1),
            Settings.Custom.Idle2 or GetOriginalAnimation(2),
            Settings.Custom.Idle3 or GetOriginalAnimation(3),
            Settings.Custom.Walk or GetOriginalAnimation(4),
            Settings.Custom.Run or GetOriginalAnimation(5),
            Settings.Custom.Jump or GetOriginalAnimation(6),
            Settings.Custom.Climb or GetOriginalAnimation(7),
            Settings.Custom.Fall or GetOriginalAnimation(8),
            Settings.Custom.Swim or GetOriginalAnimation(9),
            Settings.Custom.SwimIdle or GetOriginalAnimation(10),
            Settings.Custom.Weight,
            Settings.Custom.Weight2
        )
        
        -- Aplicar emotes personalizados
        if Settings.Custom.Wave then ApplySpecificAnimation("wave", Settings.Custom.Wave) end
        if Settings.Custom.Laugh then ApplySpecificAnimation("laugh", Settings.Custom.Laugh) end
        if Settings.Custom.Cheer then ApplySpecificAnimation("cheer", Settings.Custom.Cheer) end
        if Settings.Custom.Point then ApplySpecificAnimation("point", Settings.Custom.Point) end
        if Settings.Custom.Sit then ApplySpecificAnimation("sit", Settings.Custom.Sit) end
        if Settings.Custom.Dance then ApplySpecificAnimation("dance", Settings.Custom.Dance) end
        if Settings.Custom.Dance2 then ApplySpecificAnimation("dance2", Settings.Custom.Dance2) end
        if Settings.Custom.Dance3 then ApplySpecificAnimation("dance3", Settings.Custom.Dance3) end
        
    elseif GetRigType() == "R15" then
        StopAllAnimations()
        ApplyAnimations(
            F[Settings.SelectedAnimation].Idle,
            F[Settings.SelectedAnimation].Idle2,
            F[Settings.SelectedAnimation].Idle3,
            F[Settings.SelectedAnimation].Walk,
            F[Settings.SelectedAnimation].Run,
            F[Settings.SelectedAnimation].Jump,
            F[Settings.SelectedAnimation].Climb,
            F[Settings.SelectedAnimation].Fall,
            F[Settings.SelectedAnimation].Swim,
            F[Settings.SelectedAnimation].SwimIdle,
            F[Settings.SelectedAnimation].Weight,
            F[Settings.SelectedAnimation].Weight2
        )
        
        -- Aplicar emotes personalizados
        if Settings.Custom.Wave then ApplySpecificAnimation("wave", Settings.Custom.Wave) end
        if Settings.Custom.Laugh then ApplySpecificAnimation("laugh", Settings.Custom.Laugh) end
        if Settings.Custom.Cheer then ApplySpecificAnimation("cheer", Settings.Custom.Cheer) end
        if Settings.Custom.Point then ApplySpecificAnimation("point", Settings.Custom.Point) end
        if Settings.Custom.Sit then ApplySpecificAnimation("sit", Settings.Custom.Sit) end
        if Settings.Custom.Dance then ApplySpecificAnimation("dance", Settings.Custom.Dance) end
        if Settings.Custom.Dance2 then ApplySpecificAnimation("dance2", Settings.Custom.Dance2) end
        if Settings.Custom.Dance3 then ApplySpecificAnimation("dance3", Settings.Custom.Dance3) end
        
        RefreshAnimations()
        
        local animationController = Humanoid or Character:FindFirstChildOfClass("AnimationController")
        local playingTracks = animationController:GetPlayingAnimationTracks()
        for _, track in pairs(playingTracks) do
            track:AdjustSpeed(Settings.AnimationSpeed)
        end
    end
end

-- Sistema de chat para emotes
TextChatService.OnIncomingMessage = function(message)
    local speaker = tostring(message.TextSource)
    local text = tostring(message.Text)
    
    if speaker == LocalPlayer.Name and Settings.Chat and text:match(Settings.EmotePrefix) or 
       speaker == LocalPlayer.Name and Settings.Animate and text:match(Settings.AnimationPrefix) then
        message.Status = Enum.TextChatMessageStatus.InvalidTextChannelPermissions
    end
end

-- Funciones de utilidad para la UI
local function GetCurrentTimePosition()
    if _G.LoadAnim and _G.LoadAnim.TimePosition then
        return tostring(math.floor(_G.LoadAnim.TimePosition))
    end
    return "0"
end

local function IsLooped()
    if _G.LoadAnim and _G.LoadAnim.Looped then
        return tostring(_G.LoadAnim.Looped)
    end
    return "false"
end

-- Sistema de copia de movimiento en chat
if TextChatService:FindFirstChild("TextChannels") and not getgenv().AlreadyLoaded then
    TextChatService.TextChannels.RBXGeneral.MessageReceived:Connect(function(message)
        local speaker = tostring(message.TextSource)
        local text = tostring(message.Text)
        
        if Settings.Player and speaker == Settings.Player.Name and Settings.CopyMovement then
            TextChatService.TextChannels.RBXGeneral:SendAsync(text)
        end
    end)
end

if game.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and not getgenv().AlreadyLoaded then
    local chatEvents = game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents
    chatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(messageData)
        local speaker = messageData.FromSpeaker
        local message = messageData.Message or ""
        
        if Settings.Player and speaker == Settings.Player.Name and Settings.CopyMovement then
            game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
        end
    end)
end

-- Inicialización de la interfaz
local MainWindow = OrionLib:MakeWindow({
    Name = "iivxnu | Animations & Emotes",
    HidePremium = true,
    SaveConfig = false,
    ConfigFolder = "EazvyHub",
    IntroEnabled = false,
    IntroText = "Animations/Emotes",
    IntroIcon = "rbxassetid://10932910166",
    Icon = "rbxassetid://4914902889"
})

-- Sistema de teletransporte
LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started and queue_on_teleport then
        queue_on_teleport("repeat task.wait() until game:IsLoaded() getgenv().Teleported = true")
    end
end)

-- Crear pestañas principales
local MainTab = MainWindow:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://10507357657",
    PremiumOnly = false
})

-- [Aquí continuaría con la creación de los elementos de la UI...]

-- Sistema de actualización automática de velocidad de animación
if not getgenv().AlreadyLoaded then
    task.spawn(function()
        while task.wait() do
            if Settings.AnimationSpeedToggle and Character and Humanoid and Humanoid or 
               Settings.AnimationSpeedToggle and Character:FindFirstChildOfClass("AnimationController") then
                local animationController = Humanoid or Character:FindFirstChildOfClass("AnimationController")
                local playingTracks = animationController:GetPlayingAnimationTracks()
                for _, track in pairs(playingTracks) do
                    track:AdjustSpeed(Settings.AnimationSpeed)
                end
            end
        end
    end)
end

-- Sistema de respawn con posición guardada
CharacterAdded:Connect(function(newCharacter)
    repeat wait() until Character and Animate
    
    newCharacter.Humanoid.Died:Connect(function()
        Settings.DeathPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
    end)
    
    if Settings.Refresh and Character and Character:FindFirstChild("HumanoidRootPart") and Settings.DeathPosition then
        Character.HumanoidRootPart.CFrame = Settings.DeathPosition
    end
    
    wait(0.15)
    StopAllAnimations()
    
    -- Reaplicar animaciones después del respawn
    if Settings.SelectedAnimation ~= "" and GetRigType() == "R15" and Settings.SelectedAnimation ~= "Custom" or 
       Settings.LastEmote == "Play" and GetRigType() == "R15" and Settings.SelectedAnimation ~= "Custom" then
        ApplyAnimations(
            F[Settings.SelectedAnimation].Idle or GetOriginalAnimation(1),
            F[Settings.SelectedAnimation].Idle2 or GetOriginalAnimation(2),
            F[Settings.SelectedAnimation].Idle3 or GetOriginalAnimation(3),
            F[Settings.SelectedAnimation].Walk or GetOriginalAnimation(4),
            F[Settings.SelectedAnimation].Run or GetOriginalAnimation(5),
            F[Settings.SelectedAnimation].Jump or GetOriginalAnimation(6),
            F[Settings.SelectedAnimation].Climb or GetOriginalAnimation(7),
            F[Settings.SelectedAnimation].Fall or GetOriginalAnimation(8),
            F[Settings.SelectedAnimation].Swim or GetOriginalAnimation(9),
            F[Settings.SelectedAnimation].SwimIdle or GetOriginalAnimation(10),
            F[Settings.SelectedAnimation].Weight,
            F[Settings.SelectedAnimation].Weight2
        )
        
        -- Reaplicar emotes personalizados
        if Settings.Custom.Wave then ApplySpecificAnimation("wave", Settings.Custom.Wave) end
        if Settings.Custom.Laugh then ApplySpecificAnimation("laugh", Settings.Custom.Laugh) end
        if Settings.Custom.Cheer then ApplySpecificAnimation("cheer", Settings.Custom.Cheer) end
        if Settings.Custom.Point then ApplySpecificAnimation("point", Settings.Custom.Point) end
        if Settings.Custom.Sit then ApplySpecificAnimation("sit", Settings.Custom.Sit) end
        if Settings.Custom.Dance then ApplySpecificAnimation("dance", Settings.Custom.Dance) end
        if Settings.Custom.Dance2 then ApplySpecificAnimation("dance2", Settings.Custom.Dance2) end
        if Settings.Custom.Dance3 then ApplySpecificAnimation("dance3", Settings.Custom.Dance3) end
        
        RefreshAnimations()
        
        local animationController = Humanoid or Character:FindFirstChildOfClass("AnimationController")
        local playingTracks = animationController:GetPlayingAnimationTracks()
        for _, track in pairs(playingTracks) do
            track:AdjustSpeed(Settings.AnimationSpeed)
        end
    end
end)

-- Detener emotes al moverse
Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
    if Humanoid.MoveDirection.Magnitude > 0 then
        if GetRigType() == "R15" then
            if _G.LoadAnim and not Settings.PlayAlways then
                Animate.Disabled = false
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

-- Inicialización final
if not getgenv().AlreadyLoaded then
    getgenv().AlreadyLoaded = true
end
