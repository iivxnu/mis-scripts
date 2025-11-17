local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Esperar a que el juego cargue y el personaje esté listo
repeat 
    task.wait() 
until game:IsLoaded() and LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")

-- Cargar UI Library
local Orion = loadstring(game:HttpGet("https://raw.githubusercontent.com/iivxnu/mis-scripts/refs/heads/main/UILibrary.lua"))()

-- Configuración inicial
getgenv().AnimationSettings = {
    SelectedAnimation = "",
    AnimationSpeed = 1,
    AutoApply = false,
    CustomAnimations = {
        Idle = "",
        Walk = "",
        Run = "",
        Jump = "",
        Fall = "",
        Idle2 = "",
        Climb = "",
        Swim = "",
        SwimIdle = ""
    }
}

-- Biblioteca completa de animaciones R15
local AnimationLibrary = {
    ["Stylish"] = {
        Idle = 616136790,
        Idle2 = 616138447,
        Walk = 616146177,
        Run = 616140816,
        Jump = 616139451,
        Climb = 616133594,
        Fall = 616134815,
        Swim = 616143378,
        SwimIdle = 616144772
    },
    ["Zombie"] = {
        Idle = 616158929,
        Idle2 = 616160636,
        Walk = 616168032,
        Run = 616163682,
        Jump = 616161997,
        Climb = 616156119,
        Fall = 616157476,
        Swim = 616165109,
        SwimIdle = 616166655
    },
    ["Robot"] = {
        Idle = 616088211,
        Idle2 = 616089559,
        Walk = 616095330,
        Run = 616091570,
        Jump = 616090535,
        Climb = 616086039,
        Fall = 616087089,
        Swim = 616092998,
        SwimIdle = 616094091
    },
    ["Cartoony"] = {
        Idle = 742637544,
        Idle2 = 742638445,
        Walk = 742640026,
        Run = 742638842,
        Jump = 742637942,
        Climb = 742636889,
        Fall = 742637151,
        Swim = 742639220,
        SwimIdle = 742639812
    },
    ["Superhero"] = {
        Idle = 616111295,
        Idle2 = 616113536,
        Walk = 616122287,
        Run = 616117076,
        Jump = 616115533,
        Climb = 616104706,
        Fall = 616108001,
        Swim = 616119360,
        SwimIdle = 616120861
    },
    ["Ninja"] = {
        Idle = 656117400,
        Idle2 = 656118341,
        Walk = 656121766,
        Run = 656118852,
        Jump = 656117878,
        Climb = 656114359,
        Fall = 656115606,
        Swim = 656119721,
        SwimIdle = 656121397
    },
    ["Mage"] = {
        Idle = 707742142,
        Idle2 = 707855907,
        Walk = 707897309,
        Run = 707861613,
        Jump = 707853694,
        Climb = 707826056,
        Fall = 707829716,
        Swim = 707876443,
        SwimIdle = 707894699
    },
    ["Elder"] = {
        Idle = 845397899,
        Idle2 = 845400520,
        Walk = 845403856,
        Run = 845386501,
        Jump = 845398858,
        Climb = 845392038,
        Fall = 845396048,
        Swim = 845401742,
        SwimIdle = 845403127
    },
    ["Knight"] = {
        Idle = 657595757,
        Idle2 = 657568135,
        Walk = 657552124,
        Run = 657564596,
        Jump = 658409194,
        Climb = 658360781,
        Fall = 657600338,
        Swim = 657560551,
        SwimIdle = 657557095
    },
    ["Vampire"] = {
        Idle = 1083445855,
        Idle2 = 1083450166,
        Walk = 1083473930,
        Run = 1083462077,
        Jump = 1083455352,
        Climb = 1083439238,
        Fall = 1083443587,
        Swim = 1083464683,
        SwimIdle = 1083467779
    },
    ["Bubbly"] = {
        Idle = 910004836,
        Idle2 = 910009958,
        Walk = 910034870,
        Run = 910025107,
        Jump = 910016857,
        Climb = 909997997,
        Fall = 910001910,
        Swim = 910028158,
        SwimIdle = 910030921
    },
    ["Pirate"] = {
        Idle = 750781874,
        Idle2 = 750782770,
        Walk = 750785693,
        Run = 750783738,
        Jump = 750782230,
        Climb = 750779899,
        Fall = 750780242,
        Swim = 750784579,
        SwimIdle = 750785176
    },
    ["Astronaut"] = {
        Idle = 891621366,
        Idle2 = 891633237,
        Walk = 891667138,
        Run = 891636393,
        Jump = 891627522,
        Climb = 891609353,
        Fall = 891617961,
        Swim = 891639666,
        SwimIdle = 891663592
    },
    ["Werewolf"] = {
        Idle = 1083195517,
        Idle2 = 1083214717,
        Walk = 1083178339,
        Run = 1083216690,
        Jump = 1083218792,
        Climb = 1083182000,
        Fall = 1083189019,
        Swim = 1083222527,
        SwimIdle = 1083225406
    },
    ["Toy"] = {
        Idle = 782841498,
        Idle2 = 782845736,
        Walk = 782843345,
        Run = 782842708,
        Jump = 782847020,
        Climb = 782843869,
        Fall = 782846423,
        Swim = 782844582,
        SwimIdle = 782845186
    },
    ["Rthro"] = {
        Idle = 2510196951,
        Idle2 = 2510197257,
        Walk = 2510202577,
        Run = 2510198475,
        Jump = 2510197830,
        Climb = 2510192778,
        Fall = 2510195892,
        Swim = 2510199791,
        SwimIdle = 2510201162
    }
}

-- Guardar animaciones originales
local OriginalAnimations = {}
local function SaveOriginalAnimations()
    local character = LocalPlayer.Character
    if not character then return end
    
    local animateScript = character:FindFirstChild("Animate")
    if animateScript then
        if animateScript:FindFirstChild("idle") then
            OriginalAnimations.Idle = animateScript.idle.Animation1.AnimationId
            if animateScript.idle.Animation2 then
                OriginalAnimations.Idle2 = animateScript.idle.Animation2.AnimationId
            end
        end
        
        local function saveAnimation(animationName)
            local animationFolder = animateScript:FindFirstChild(animationName)
            if animationFolder then
                local animation = animationFolder:FindFirstChildOfClass("Animation")
                if animation then
                    OriginalAnimations[animationName] = animation.AnimationId
                end
            end
        end
        
        saveAnimation("walk")
        saveAnimation("run")
        saveAnimation("jump")
        saveAnimation("climb")
        saveAnimation("fall")
        saveAnimation("swim")
        saveAnimation("swimidle")
    end
end

-- Función mejorada para aplicar animaciones
local function ApplyAnimations(animationData)
    local character = LocalPlayer.Character
    if not character then 
        return false, "Personaje no encontrado"
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then 
        return false, "Humanoid no encontrado"
    end
    
    local animateScript = character:FindFirstChild("Animate")
    if not animateScript then 
        return false, "Script Animate no encontrado"
    end
    
    -- Esperar un frame para asegurar que todo esté listo
    task.wait()
    
    -- Deshabilitar el script Animate
    animateScript.Disabled = true
    
    -- Función auxiliar para aplicar animación de forma segura
    local function applyAnimation(animationName, animationId)
        if animationId and animationId ~= "" then
            local animationFolder = animateScript:FindFirstChild(animationName)
            if animationFolder then
                local animation = animationFolder:FindFirstChildOfClass("Animation")
                if animation then
                    animation.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                    return true
                end
            end
        end
        return false
    end
    
    -- Aplicar animaciones básicas
    if animationData.Idle and animateScript:FindFirstChild("idle") then
        animateScript.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=" .. animationData.Idle
        if animationData.Idle2 then
            animateScript.idle.Animation2.AnimationId = "http://www.roblox.com/asset/?id=" .. animationData.Idle2
        end
    end
    
    -- Aplicar todas las animaciones
    applyAnimation("walk", animationData.Walk)
    applyAnimation("run", animationData.Run)
    applyAnimation("jump", animationData.Jump)
    applyAnimation("climb", animationData.Climb)
    applyAnimation("fall", animationData.Fall)
    applyAnimation("swim", animationData.Swim)
    applyAnimation("swimidle", animationData.SwimIdle)
    
    -- Re-habilitar el script
    task.wait(0.1)
    animateScript.Disabled = false
    
    -- Aplicar velocidad después de un breve delay
    task.wait(0.2)
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:AdjustSpeed(getgenv().AnimationSettings.AnimationSpeed)
    end
    
    return true, "Animaciones aplicadas correctamente"
end

-- Función para aplicar animación individual
local function ApplySingleAnimation(animationType, animationId)
    local character = LocalPlayer.Character
    if not character or not animationId or animationId == "" then 
        return false, "Datos inválidos"
    end
    
    local animateScript = character:FindFirstChild("Animate")
    if not animateScript then 
        return false, "Script Animate no encontrado"
    end
    
    local animationFolder = animateScript:FindFirstChild(animationType:lower())
    if not animationFolder then 
        return false, "Tipo de animación no encontrado: " .. animationType
    end
    
    local animation = animationFolder:FindFirstChildOfClass("Animation")
    if not animation then 
        return false, "Animation object no encontrado"
    end
    
    animation.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
    
    -- Forzar actualización
    animateScript.Disabled = true
    task.wait()
    animateScript.Disabled = false
    
    return true, "Animación individual aplicada"
end

-- Función para restaurar animaciones originales
local function RestoreOriginalAnimations()
    local character = LocalPlayer.Character
    if not character then return false end
    
    local animateScript = character:FindFirstChild("Animate")
    if not animateScript then return false end
    
    animateScript.Disabled = true
    
    -- Restaurar animaciones básicas
    if animateScript:FindFirstChild("idle") and OriginalAnimations.Idle then
        animateScript.idle.Animation1.AnimationId = OriginalAnimations.Idle
        if OriginalAnimations.Idle2 then
            animateScript.idle.Animation2.AnimationId = OriginalAnimations.Idle2
        end
    end
    
    -- Función auxiliar para restaurar animación
    local function restoreAnimation(animationName)
        if OriginalAnimations[animationName] then
            local animationFolder = animateScript:FindFirstChild(animationName)
            if animationFolder then
                local animation = animationFolder:FindFirstChildOfClass("Animation")
                if animation then
                    animation.AnimationId = OriginalAnimations[animationName]
                end
            end
        end
    end
    
    -- Restaurar todas las animaciones
    restoreAnimation("walk")
    restoreAnimation("run")
    restoreAnimation("jump")
    restoreAnimation("climb")
    restoreAnimation("fall")
    restoreAnimation("swim")
    restoreAnimation("swimidle")
    
    task.wait(0.1)
    animateScript.Disabled = false
    getgenv().AnimationSettings.SelectedAnimation = ""
    
    return true
end

-- Crear la interfaz sin emojis ni imágenes
local Window = Orion:MakeWindow({
    Name = "Animations Changer",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "AnimationsConfig",
    IntroEnabled = false
})

-- Tabs principales
local MainTab = Window:MakeTab({
    Name = "Animaciones",
    PremiumOnly = false
})

local CustomTab = Window:MakeTab({
    Name = "Personalizado",
    PremiumOnly = false
})

local SettingsTab = Window:MakeTab({
    Name = "Configuracion",
    PremiumOnly = false
})

-- Sección de animaciones predefinidas
MainTab:AddSection({
    Name = "Animaciones Predefinidas"
})

-- Crear lista de animaciones ordenadas alfabéticamente
local animationNames = {}
for name, _ in pairs(AnimationLibrary) do
    table.insert(animationNames, name)
end
table.sort(animationNames)

local AnimationDropdown = MainTab:AddDropdown({
    Name = "Seleccionar Pack de Animaciones",
    Default = "",
    Options = animationNames,
    Callback = function(selected)
        if selected ~= "" and AnimationLibrary[selected] then
            getgenv().AnimationSettings.SelectedAnimation = selected
            local success, message = ApplyAnimations(AnimationLibrary[selected])
            if success then
                Orion:MakeNotification({
                    Name = "Exito",
                    Content = "Pack " .. selected .. " aplicado correctamente",
                    Time = 3
                })
            else
                Orion:MakeNotification({
                    Name = "Error",
                    Content = message or "No se pudo aplicar la animacion",
                    Time = 3
                })
            end
        end
    end
})

MainTab:AddButton({
    Name = "Aplicar Animacion Seleccionada",
    Callback = function()
        local selected = getgenv().AnimationSettings.SelectedAnimation
        if selected ~= "" and AnimationLibrary[selected] then
            local success, message = ApplyAnimations(AnimationLibrary[selected])
            if success then
                Orion:MakeNotification({
                    Name = "Exito",
                    Content = "Animacion " .. selected .. " re-aplicada",
                    Time = 3
                })
            else
                Orion:MakeNotification({
                    Name = "Error",
                    Content = message or "Error al re-aplicar",
                    Time = 3
                })
            end
        else
            Orion:MakeNotification({
                Name = "Advertencia",
                Content = "No hay animacion seleccionada",
                Time = 3
            })
        end
    end
})

MainTab:AddButton({
    Name = "Resetear a Animaciones Normales",
    Callback = function()
        if RestoreOriginalAnimations() then
            getgenv().AnimationSettings.SelectedAnimation = ""
            Orion:MakeNotification({
                Name = "Exito",
                Content = "Animaciones restauradas a las normales",
                Time = 3
            })
        else
            Orion:MakeNotification({
                Name = "Error",
                Content = "No se pudieron restaurar las animaciones",
                Time = 3
            })
        end
    end
})

-- Sección de velocidad
MainTab:AddSection({
    Name = "Configuracion de Velocidad"
})

MainTab:AddSlider({
    Name = "Velocidad de Animacion",
    Min = 0.1,
    Max = 3,
    Default = 1,
    Color = Color3.fromRGB(0, 255, 127),
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
    Name = "ID Animacion Idle",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Idle = value
    end
})

CustomTab:AddTextbox({
    Name = "ID Animacion Idle 2",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Idle2 = value
    end
})

CustomTab:AddTextbox({
    Name = "ID Animacion Walk",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Walk = value
    end
})

CustomTab:AddTextbox({
    Name = "ID Animacion Run",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Run = value
    end
})

CustomTab:AddTextbox({
    Name = "ID Animacion Jump",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Jump = value
    end
})

CustomTab:AddTextbox({
    Name = "ID Animacion Climb",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Climb = value
    end
})

CustomTab:AddTextbox({
    Name = "ID Animacion Fall",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Fall = value
    end
})

CustomTab:AddTextbox({
    Name = "ID Animacion Swim",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Swim = value
    end
})

CustomTab:AddTextbox({
    Name = "ID Animacion SwimIdle",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.SwimIdle = value
    end
})

CustomTab:AddButton({
    Name = "Aplicar Animaciones Personalizadas",
    Callback = function()
        local success, message = ApplyAnimations(getgenv().AnimationSettings.CustomAnimations)
        if success then
            getgenv().AnimationSettings.SelectedAnimation = "Custom"
            Orion:MakeNotification({
                Name = "Exito",
                Content = "Animaciones personalizadas aplicadas",
                Time = 3
            })
        else
            Orion:MakeNotification({
                Name = "Error",
                Content = message or "No se pudieron aplicar las animaciones personalizadas",
                Time = 3
            })
        end
    end
})

CustomTab:AddButton({
    Name = "Limpiar Campos Personalizados",
    Callback = function()
        getgenv().AnimationSettings.CustomAnimations = {
            Idle = "", Walk = "", Run = "", Jump = "", 
            Fall = "", Idle2 = "", Climb = "", Swim = "", SwimIdle = ""
        }
        Orion:MakeNotification({
            Name = "Exito",
            Content = "Todos los campos personalizados fueron limpiados",
            Time = 3
        })
    end
})

-- Sección de aplicación individual
CustomTab:AddSection({
    Name = "Aplicar Animacion Individual"
})

CustomTab:AddTextbox({
    Name = "ID de Animacion",
    Default = "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().CurrentAnimationID = value
    end
})

CustomTab:AddDropdown({
    Name = "Tipo de Animacion",
    Default = "idle",
    Options = {"idle", "walk", "run", "jump", "fall", "climb", "swim", "swimidle"},
    Callback = function(selected)
        getgenv().CurrentAnimationType = selected
    end
})

CustomTab:AddButton({
    Name = "Aplicar Animacion Individual",
    Callback = function()
        if getgenv().CurrentAnimationID and getgenv().CurrentAnimationType then
            local success, message = ApplySingleAnimation(getgenv().CurrentAnimationType, getgenv().CurrentAnimationID)
            if success then
                Orion:MakeNotification({
                    Name = "Exito",
                    Content = "Animacion " .. getgenv().CurrentAnimationType .. " aplicada",
                    Time = 3
                })
            else
                Orion:MakeNotification({
                    Name = "Error",
                    Content = message or "No se pudo aplicar la animacion individual",
                    Time = 3
                })
            end
        else
            Orion:MakeNotification({
                Name = "Advertencia",
                Content = "Ingresa un ID y selecciona un tipo de animacion",
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
        getgenv().AnimationSettings.AutoApply = value
    end
})

SettingsTab:AddButton({
    Name = "Guardar Animaciones Originales",
    Callback = function()
        SaveOriginalAnimations()
        Orion:MakeNotification({
            Name = "Exito",
            Content = "Animaciones originales guardadas correctamente",
            Time = 3
        })
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

-- Información
SettingsTab:AddSection({
    Name = "Informacion"
})

SettingsTab:AddParagraph("Estado Actual", "Animacion seleccionada: " .. (getgenv().AnimationSettings.SelectedAnimation ~= "" and getgenv().AnimationSettings.SelectedAnimation or "Ninguna"))

-- Función mejorada para manejar el respawn del personaje
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(2) -- Esperar a que el personaje esté completamente cargado
    
    -- Esperar a que el Humanoid y Animate estén listos
    repeat
        task.wait()
    until character:FindFirstChild("Humanoid") and character:FindFirstChild("Animate")
    
    -- Guardar animaciones originales si es la primera vez
    if not next(OriginalAnimations) then
        SaveOriginalAnimations()
    end
    
    if getgenv().AnimationSettings.AutoApply then
        local selected = getgenv().AnimationSettings.SelectedAnimation
        if selected ~= "" then
            task.wait(0.5) -- Esperar adicional
            if selected == "Custom" then
                ApplyAnimations(getgenv().AnimationSettings.CustomAnimations)
            elseif AnimationLibrary[selected] then
                ApplyAnimations(AnimationLibrary[selected])
            end
        end
    end
end)

-- Inicialización mejorada
task.spawn(function()
    task.wait(3) -- Más tiempo de espera inicial
    
    -- Guardar animaciones originales al iniciar
    SaveOriginalAnimations()
    
    -- Aplicar animaciones si hay una seleccionada al iniciar
    local selected = getgenv().AnimationSettings.SelectedAnimation
    if selected ~= "" then
        task.wait(1)
        if selected == "Custom" then
            ApplyAnimations(getgenv().AnimationSettings.CustomAnimations)
        elseif AnimationLibrary[selected] then
            ApplyAnimations(AnimationLibrary[selected])
        end
    end
end)

-- Notificación de carga
Orion:MakeNotification({
    Name = "Sistema de Animaciones Cargado",
    Content = "Presiona RightControl para abrir/cerrar el menu\n" .. #animationNames .. " packs de animaciones disponibles",
    Time = 5
})
