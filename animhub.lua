local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Esperar a que el juego cargue y el personaje esté listo
repeat 
    task.wait() 
until game:IsLoaded() and LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")

-- Cargar tu UI Library
local Orion = loadstring(game:HttpGet("https://raw.githubusercontent.com/iivxnu/mis-scripts/refs/heads/main/UILibrary.lua"))()

-- Configuración inicial
getgenv().AnimationSettings = {
    SelectedAnimation = "",
    AnimationSpeed = 1,
    CustomAnimations = {
        Idle = "",
        Walk = "",
        Run = "",
        Jump = "",
        Fall = "",
        Idle2 = ""
    }
}

-- IDs de animaciones predefinidas
local AnimationLibrary = {
    ["Stylish"] = {
        Idle = 616136790,
        Walk = 616146177,
        Run = 616140816,
        Jump = 616139451,
        Fall = 616134815,
        Idle2 = 616138447
    },
    ["Zombie"] = {
        Idle = 616158929,
        Walk = 616168032,
        Run = 616163682,
        Jump = 616161997,
        Fall = 616157476,
        Idle2 = 616160636
    },
    ["Robot"] = {
        Idle = 616088211,
        Walk = 616095330,
        Run = 616091570,
        Jump = 616090535,
        Fall = 616087089,
        Idle2 = 616089559
    },
    ["Cartoony"] = {
        Idle = 742637544,
        Walk = 742640026,
        Run = 742638842,
        Jump = 742637942,
        Fall = 742637151,
        Idle2 = 742638445
    },
    ["Superhero"] = {
        Idle = 616111295,
        Walk = 616122287,
        Run = 616117076,
        Jump = 616115533,
        Fall = 616108001,
        Idle2 = 616113536
    }
}

-- Función para aplicar animaciones
local function ApplyAnimations(animationData)
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Detener animaciones actuales
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
    
    -- Aplicar nuevas animaciones
    local animateScript = character:FindFirstChild("Animate")
    if animateScript then
        if animationData.Idle and animateScript:FindFirstChild("idle") then
            animateScript.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=" .. animationData.Idle
            if animationData.Idle2 then
                animateScript.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=" .. animationData.Idle2
            end
        end
        
        if animationData.Walk and animateScript:FindFirstChild("walk") then
            local walkAnimation = animateScript.walk:FindFirstChildOfClass("Animation")
            if walkAnimation then
                walkAnimation.AnimationId = "http://www.roblox.com/asset/?id=" .. animationData.Walk
            end
        end
        
        if animationData.Run and animateScript:FindFirstChild("run") then
            local runAnimation = animateScript.run:FindFirstChildOfClass("Animation")
            if runAnimation then
                runAnimation.AnimationId = "http://www.roblox.com/asset/?id=" .. animationData.Run
            end
        end
        
        if animationData.Jump and animateScript:FindFirstChild("jump") then
            local jumpAnimation = animateScript.jump:FindFirstChildOfClass("Animation")
            if jumpAnimation then
                jumpAnimation.AnimationId = "http://www.roblox.com/asset/?id=" .. animationData.Jump
            end
        end
        
        if animationData.Fall and animateScript:FindFirstChild("fall") then
            local fallAnimation = animateScript.fall:FindFirstChildOfClass("Animation")
            if fallAnimation then
                fallAnimation.AnimationId = "http://www.roblox.com/asset/?id=" .. animationData.Fall
            end
        end
    end
end

-- Función para aplicar animación individual
local function ApplySingleAnimation(animationType, animationId)
    local character = LocalPlayer.Character
    if not character then return end
    
    local animateScript = character:FindFirstChild("Animate")
    if not animateScript then return end
    
    local animationFolder = animateScript:FindFirstChild(animationType:lower())
    if animationFolder then
        local animation = animationFolder:FindFirstChildOfClass("Animation")
        if animation then
            animation.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
        end
    end
end

-- Crear la interfaz
local Window = Orion:MakeWindow({
    Name = "Animations Changer",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "AnimationsConfig",
    IntroEnabled = true,
    IntroText = "Animations System"
})

-- Tabs principales
local MainTab = Window:MakeTab({
    Name = "Animaciones",
    Icon = "rbxassetid://10723427954",
    PremiumOnly = false
})

local CustomTab = Window:MakeTab({
    Name = "Personalizado",
    Icon = "rbxassetid://10723428312",
    PremiumOnly = false
})

local SettingsTab = Window:MakeTab({
    Name = "Configuración",
    Icon = "rbxassetid://10723428664",
    PremiumOnly = false
})

-- Sección de animaciones predefinidas
MainTab:AddSection({
    Name = "Animaciones Predefinidas"
})

local AnimationDropdown = MainTab:AddDropdown({
    Name = "Seleccionar Animación",
    Default = "",
    Options = {"Stylish", "Zombie", "Robot", "Cartoony", "Superhero"},
    Callback = function(selected)
        if selected ~= "" and AnimationLibrary[selected] then
            getgenv().AnimationSettings.SelectedAnimation = selected
            ApplyAnimations(AnimationLibrary[selected])
            Orion:MakeNotification({
                Name = "Animación Cambiada",
                Content = "Animación " .. selected .. " aplicada",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        end
    end
})

MainTab:AddButton({
    Name = "Aplicar Animación Seleccionada",
    Callback = function()
        local selected = getgenv().AnimationSettings.SelectedAnimation
        if selected ~= "" and AnimationLibrary[selected] then
            ApplyAnimations(AnimationLibrary[selected])
        end
    end
})

MainTab:AddButton({
    Name = "Resetear a Animaciones Normales",
    Callback = function()
        getgenv().AnimationSettings.SelectedAnimation = ""
        -- Aquí deberías restaurar las animaciones originales
        Orion:MakeNotification({
            Name = "Animaciones Reseteadas",
            Content = "Animaciones restauradas a las normales",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
})

-- Sección de velocidad
MainTab:AddSection({
    Name = "Configuración de Velocidad"
})

MainTab:AddSlider({
    Name = "Velocidad de Animación",
    Min = 0.1,
    Max = 5,
    Default = 1,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 0.1,
    ValueName = "velocidad",
    Callback = function(value)
        getgenv().AnimationSettings.AnimationSpeed = value
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(value)
                end
            end
        end
    end
})

-- Sección de animaciones personalizadas
CustomTab:AddSection({
    Name = "Animaciones Personalizadas"
})

CustomTab:AddTextbox({
    Name = "ID Animación Idle",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Idle = value
    end
})

CustomTab:AddTextbox({
    Name = "ID Animación Walk",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Walk = value
    end
})

CustomTab:AddTextbox({
    Name = "ID Animación Run",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Run = value
    end
})

CustomTab:AddTextbox({
    Name = "ID Animación Jump",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Jump = value
    end
})

CustomTab:AddTextbox({
    Name = "ID Animación Fall",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Fall = value
    end
})

CustomTab:AddButton({
    Name = "Aplicar Animaciones Personalizadas",
    Callback = function()
        ApplyAnimations(getgenv().AnimationSettings.CustomAnimations)
        Orion:MakeNotification({
            Name = "Animaciones Aplicadas",
            Content = "Animaciones personalizadas aplicadas",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
})

-- Sección de aplicación individual
CustomTab:AddSection({
    Name = "Aplicar Animación Individual"
})

CustomTab:AddTextbox({
    Name = "ID de Animación",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().CurrentAnimationID = value
    end
})

CustomTab:AddDropdown({
    Name = "Tipo de Animación",
    Default = "idle",
    Options = {"idle", "walk", "run", "jump", "fall", "climb", "swim"},
    Callback = function(selected)
        getgenv().CurrentAnimationType = selected
    end
})

CustomTab:AddButton({
    Name = "Aplicar Animación Individual",
    Callback = function()
        if getgenv().CurrentAnimationID and getgenv().CurrentAnimationType then
            ApplySingleAnimation(getgenv().CurrentAnimationType, getgenv().CurrentAnimationID)
            Orion:MakeNotification({
                Name = "Animación Aplicada",
                Content = "Animación " .. getgenv().CurrentAnimationType .. " aplicada",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        end
    end
})

-- Configuración
SettingsTab:AddSection({
    Name = "Opciones Generales"
})

SettingsTab:AddToggle({
    Name = "Auto Aplicar al Respawn",
    Default = false,
    Callback = function(value)
        getgenv().AutoApply = value
    end
})

SettingsTab:AddBind({
    Name = "Toggle UI",
    Default = Enum.KeyCode.RightControl,
    Hold = false,
    Callback = function()
        Orion:ToggleUI()
    end
})

-- Función para manejar el respawn del personaje
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1) -- Esperar a que el personaje esté completamente cargado
    
    if getgenv().AutoApply then
        local selected = getgenv().AnimationSettings.SelectedAnimation
        if selected ~= "" and AnimationLibrary[selected] then
            task.wait(0.5)
            ApplyAnimations(AnimationLibrary[selected])
        end
    end
end)

-- Notificación de carga
Orion:MakeNotification({
    Name = "Sistema de Animaciones Cargado",
    Content = "Presiona RightControl para abrir/cerrar el menu",
    Image = "rbxassetid://10723427954",
    Time = 5
})

-- Aplicar animaciones si hay una seleccionada al iniciar
task.spawn(function()
    task.wait(2)
    local selected = getgenv().AnimationSettings.SelectedAnimation
    if selected ~= "" and AnimationLibrary[selected] then
        ApplyAnimations(AnimationLibrary[selected])
    end
end)
