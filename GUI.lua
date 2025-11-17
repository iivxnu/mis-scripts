local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Esperar a que el juego cargue
repeat 
    task.wait() 
until game:IsLoaded() and LocalPlayer

-- Cargar una librería UI más confiable
local success, Orion = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
end)

if not success then
    -- Fallback a otra librería si Orion no carga
    Orion = loadstring(game:HttpGet("https://raw.githubusercontent.com/flkitt/venyx/main/UI-Library-V2.1"))()
end

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
    },
    ["Ninja"] = {
        Idle = 656117400,
        Walk = 656121766,
        Run = 656118852,
        Jump = 656117878,
        Fall = 656115606,
        Idle2 = 656118341
    },
    ["Vampire"] = {
        Idle = 1083445855,
        Walk = 1083473930,
        Run = 1083462077,
        Jump = 1083455352,
        Fall = 1083443587,
        Idle2 = 1083450166
    },
    ["Bubbly"] = {
        Idle = 910004836,
        Walk = 910034870,
        Run = 910025107,
        Jump = 910016857,
        Fall = 910001910,
        Idle2 = 910009958
    }
}

-- Función para esperar a que el personaje esté listo
local function waitForCharacter()
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    repeat task.wait() until LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    return LocalPlayer.Character
end

-- Función para aplicar animaciones
local function ApplyAnimations(animationData)
    local character = waitForCharacter()
    if not character then 
        warn("No se pudo encontrar el character")
        return 
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then 
        warn("No se pudo encontrar el humanoid")
        return 
    end
    
    -- Esperar a que el script Animate exista
    local animateScript = character:WaitForChild("Animate", 5)
    if not animateScript then
        warn("No se encontró el script Animate")
        return
    end
    
    -- Detener animaciones actuales
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
    
    -- Aplicar nuevas animaciones con verificación de errores
    local function safeApplyAnimation(scriptPart, animationId)
        if animationId and animationId ~= "" then
            pcall(function()
                if scriptPart:IsA("Animation") then
                    scriptPart.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                elseif scriptPart:FindFirstChildOfClass("Animation") then
                    scriptPart:FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                end
            end)
        end
    end

    -- Aplicar animaciones
    if animationData.Idle then
        local idle = animateScript:FindFirstChild("idle")
        if idle then
            safeApplyAnimation(idle.Animation1, animationData.Idle)
            if animationData.Idle2 then
                safeApplyAnimation(idle.Animation2, animationData.Idle2)
            end
        end
    end
    
    if animationData.Walk then
        safeApplyAnimation(animateScript.walk, animationData.Walk)
    end
    
    if animationData.Run then
        safeApplyAnimation(animateScript.run, animationData.Run)
    end
    
    if animationData.Jump then
        safeApplyAnimation(animateScript.jump, animationData.Jump)
    end
    
    if animationData.Fall then
        safeApplyAnimation(animateScript.fall, animationData.Fall)
    end
    
    -- Aplicar velocidad
    if getgenv().AnimationSettings.AnimationSpeed then
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(getgenv().AnimationSettings.AnimationSpeed)
        end
    end
end

-- Función para aplicar animación individual
local function ApplySingleAnimation(animationType, animationId)
    if not animationId or animationId == "" then return end
    
    local character = waitForCharacter()
    if not character then return end
    
    local animateScript = character:FindFirstChild("Animate")
    if not animateScript then return end
    
    local animationFolder = animateScript:FindFirstChild(animationType:lower())
    if animationFolder then
        pcall(function()
            local animation = animationFolder:FindFirstChildOfClass("Animation")
            if animation then
                animation.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
            end
        end)
    end
end

-- Crear la interfaz
local Window = Orion:MakeWindow({
    Name = "Animations Changer",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "AnimationsConfig",
    IntroEnabled = false  -- Deshabilitar intro para evitar problemas
})

-- Tabs principales
local MainTab = Window:MakeTab({
    Name = "Animaciones",
    Icon = "rbxassetid://10723427954",
    PremiumOnly = false
})

local IndividualTab = Window:MakeTab({
    Name = "Animaciones Individuales",
    Icon = "rbxassetid://10723428312",
    PremiumOnly = false
})

local CustomTab = Window:MakeTab({
    Name = "Personalizado",
    Icon = "rbxassetid://10723428664",
    PremiumOnly = false
})

local SettingsTab = Window:MakeTab({
    Name = "Configuración",
    Icon = "rbxassetid://10723428664",
    PremiumOnly = false
})

-- Sección de animaciones predefinidas
MainTab:AddSection({
    Name = "Paquetes de Animaciones Completas"
})

local packageOptions = {}
for packageName, _ in pairs(AnimationLibrary) do
    table.insert(packageOptions, packageName)
end

local AnimationDropdown = MainTab:AddDropdown({
    Name = "Seleccionar Paquete Completo",
    Default = "",
    Options = packageOptions,
    Callback = function(selected)
        if selected ~= "" and AnimationLibrary[selected] then
            getgenv().AnimationSettings.SelectedAnimation = selected
            ApplyAnimations(AnimationLibrary[selected])
            Orion:MakeNotification({
                Name = "Paquete Aplicado",
                Content = "Paquete " .. selected .. " aplicado completamente",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        end
    end
})

MainTab:AddButton({
    Name = "Aplicar Paquete Seleccionado",
    Callback = function()
        local selected = getgenv().AnimationSettings.SelectedAnimation
        if selected ~= "" and AnimationLibrary[selected] then
            ApplyAnimations(AnimationLibrary[selected])
        else
            Orion:MakeNotification({
                Name = "Error",
                Content = "Selecciona un paquete primero",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        end
    end
})

-- Animaciones individuales
local function createIndividualSection(tab, sectionName, animationType, displayName)
    tab:AddSection({
        Name = sectionName
    })
    
    tab:AddDropdown({
        Name = "Seleccionar Animación " .. displayName,
        Default = "",
        Options = packageOptions,
        Callback = function(selected)
            if selected ~= "" and AnimationLibrary[selected] and AnimationLibrary[selected][animationType] then
                ApplySingleAnimation(animationType:lower(), AnimationLibrary[selected][animationType])
                Orion:MakeNotification({
                    Name = displayName .. " Aplicado",
                    Content = displayName .. " " .. selected .. " aplicado",
                    Image = "rbxassetid://10723427954",
                    Time = 2
                })
            end
        end
    })
end

-- Crear secciones individuales
createIndividualSection(IndividualTab, "🎭 Animación IDLE (Reposo)", "Idle", "IDLE")
createIndividualSection(IndividualTab, "🚶 Animación WALK (Caminar)", "Walk", "WALK")
createIndividualSection(IndividualTab, "🏃 Animación RUN (Correr)", "Run", "RUN")
createIndividualSection(IndividualTab, "🦘 Animación JUMP (Saltar)", "Jump", "JUMP")
createIndividualSection(IndividualTab, "📉 Animación FALL (Caer)", "Fall", "FALL")

-- Botón para aplicar todas las animaciones individuales de un paquete
IndividualTab:AddSection({
    Name = "Aplicación Rápida"
})

IndividualTab:AddDropdown({
    Name = "Aplicar Todas las Animaciones de:",
    Default = "",
    Options = packageOptions,
    Callback = function(selected)
        if selected ~= "" and AnimationLibrary[selected] then
            ApplyAnimations(AnimationLibrary[selected])
            Orion:MakeNotification({
                Name = "Todas Aplicadas",
                Content = "Todas las animaciones de " .. selected .. " aplicadas",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        end
    end
})

-- Sección de animaciones personalizadas
CustomTab:AddSection({
    Name = "Animaciones Personalizadas"
})

local customIds = {}
local animationTypes = {"Idle", "Walk", "Run", "Jump", "Fall"}

for _, animType in pairs(animationTypes) do
    CustomTab:AddTextbox({
        Name = "ID Animación " .. animType,
        Default = "",
        TextDisappear = true,
        Callback = function(value)
            customIds[animType] = value
        end
    })
end

CustomTab:AddButton({
    Name = "Aplicar Animaciones Personalizadas",
    Callback = function()
        ApplyAnimations(customIds)
        Orion:MakeNotification({
            Name = "Animaciones Aplicadas",
            Content = "Animaciones personalizadas aplicadas",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
})

-- Aplicación individual
CustomTab:AddSection({
    Name = "Aplicar Animación Individual"
})

local currentAnimationID = ""
local currentAnimationType = "idle"

CustomTab:AddTextbox({
    Name = "ID de Animación",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        currentAnimationID = value
    end
})

CustomTab:AddDropdown({
    Name = "Tipo de Animación",
    Default = "idle",
    Options = {"idle", "walk", "run", "jump", "fall"},
    Callback = function(selected)
        currentAnimationType = selected
    end
})

CustomTab:AddButton({
    Name = "Aplicar Animación Individual",
    Callback = function()
        if currentAnimationID and currentAnimationID ~= "" then
            ApplySingleAnimation(currentAnimationType, currentAnimationID)
            Orion:MakeNotification({
                Name = "Animación Aplicada",
                Content = "Animación " .. currentAnimationType .. " aplicada",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        else
            Orion:MakeNotification({
                Name = "Error",
                Content = "Ingresa un ID de animación válido",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        end
    end
})

-- Botones de control general
MainTab:AddSection({
    Name = "Controles Generales"
})

MainTab:AddButton({
    Name = "Resetear a Animaciones Normales",
    Callback = function()
        getgenv().AnimationSettings.SelectedAnimation = ""
        -- Crear datos de animaciones por defecto (normales)
        local defaultAnimations = {
            Idle = 180435571,
            Walk = 180426354,
            Run = 180426354,
            Jump = 125750702,
            Fall = 180436148
        }
        ApplyAnimations(defaultAnimations)
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
    task.wait(1)
    
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
    task.wait(3) -- Esperar un poco más para asegurar que todo esté cargado
    local selected = getgenv().AnimationSettings.SelectedAnimation
    if selected ~= "" and AnimationLibrary[selected] then
        ApplyAnimations(AnimationLibrary[selected])
    end
end)

print("Animations Changer cargado correctamente!")
