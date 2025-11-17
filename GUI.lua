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
    },
    ["Elder"] = {
        Idle = 845397899,
        Walk = 845400520,
        Run = 845398858,
        Jump = 845398058,
        Fall = 845396835,
        Idle2 = 845398658
    },
    ["Knight"] = {
        Idle = 657595757,
        Walk = 657568135,
        Run = 657552124,
        Jump = 658409194,
        Fall = 657600338,
        Idle2 = 658360781
    },
    ["Mage"] = {
        Idle = 707742142,
        Walk = 707855907,
        Run = 707861613,
        Jump = 707853694,
        Fall = 707829716,
        Idle2 = 707853423
    }
}

-- Función mejorada para aplicar animaciones
local function ApplyAnimations(animationData)
    local character = LocalPlayer.Character
    if not character then 
        Orion:MakeNotification({
            Name = "Error",
            Content = "Personaje no encontrado",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
        return 
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then 
        Orion:MakeNotification({
            Name = "Error",
            Content = "Humanoid no encontrado",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
        return 
    end
    
    -- Detener animaciones actuales
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
    
    -- Aplicar nuevas animaciones con manejo de errores
    local animateScript = character:FindFirstChild("Animate")
    if animateScript then
        -- Función segura para aplicar animaciones
        local function safeApplyAnimation(part, animId)
            if animId and animId ~= "" then
                pcall(function()
                    if part:IsA("Animation") then
                        part.AnimationId = "http://www.roblox.com/asset/?id=" .. animId
                    elseif part:FindFirstChildOfClass("Animation") then
                        local anim = part:FindFirstChildOfClass("Animation")
                        anim.AnimationId = "http://www.roblox.com/asset/?id=" .. animId
                    end
                end)
            end
        end

        -- Aplicar cada tipo de animación
        if animationData.Idle and animateScript:FindFirstChild("idle") then
            local idle = animateScript.idle
            safeApplyAnimation(idle.Animation1, animationData.Idle)
            if animationData.Idle2 then
                safeApplyAnimation(idle.Animation2, animationData.Idle2)
            end
        end
        
        if animationData.Walk and animateScript:FindFirstChild("walk") then
            safeApplyAnimation(animateScript.walk, animationData.Walk)
        end
        
        if animationData.Run and animateScript:FindFirstChild("run") then
            safeApplyAnimation(animateScript.run, animationData.Run)
        end
        
        if animationData.Jump and animateScript:FindFirstChild("jump") then
            safeApplyAnimation(animateScript.jump, animationData.Jump)
        end
        
        if animationData.Fall and animateScript:FindFirstChild("fall") then
            safeApplyAnimation(animateScript.fall, animationData.Fall)
        end
        
        -- Aplicar velocidad
        if getgenv().AnimationSettings.AnimationSpeed then
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:AdjustSpeed(getgenv().AnimationSettings.AnimationSpeed)
            end
        end
    else
        Orion:MakeNotification({
            Name = "Error",
            Content = "Script Animate no encontrado",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
end

-- Función para aplicar animación individual
local function ApplySingleAnimation(animationType, animationId)
    if not animationId or animationId == "" then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local animateScript = character:FindFirstChild("Animate")
    if not animateScript then return end
    
    pcall(function()
        local animationFolder = animateScript:FindFirstChild(animationType:lower())
        if animationFolder then
            local animation = animationFolder:FindFirstChildOfClass("Animation")
            if animation then
                animation.AnimationId = "http://www.roblox.com/asset/?id=" .. animationId
                
                -- Aplicar velocidad también a animaciones individuales
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and getgenv().AnimationSettings.AnimationSpeed then
                    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                        if track.Name == animationType then
                            track:AdjustSpeed(getgenv().AnimationSettings.AnimationSpeed)
                        end
                    end
                end
            end
        end
    end)
end

-- Crear la interfaz
local Window = Orion:MakeWindow({
    Name = "Animations Changer",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "AnimationsConfig",
    IntroEnabled = true,
    IntroText = "Animations System v2.0"
})

-- Tabs principales
local MainTab = Window:MakeTab({
    Name = "🎭 Animaciones",
    Icon = "rbxassetid://10723427954",
    PremiumOnly = false
})

local IndividualTab = Window:MakeTab({
    Name = "🔧 Individuales",
    Icon = "rbxassetid://10723428312",
    PremiumOnly = false
})

local CustomTab = Window:MakeTab({
    Name = "✨ Personalizado",
    Icon = "rbxassetid://10723428664",
    PremiumOnly = false
})

local SettingsTab = Window:MakeTab({
    Name = "⚙️ Configuración",
    Icon = "rbxassetid://10723428916",
    PremiumOnly = false
})

-- ========== TAB ANIMACIONES ==========
MainTab:AddSection({
    Name = "🎯 Paquetes de Animaciones Completas"
})

-- Dropdown para seleccionar paquete
local packageOptions = {}
for packageName, _ in pairs(AnimationLibrary) do
    table.insert(packageOptions, packageName)
end

local AnimationDropdown = MainTab:AddDropdown({
    Name = "Seleccionar Paquete Completo",
    Default = getgenv().AnimationSettings.SelectedAnimation or "",
    Options = packageOptions,
    Callback = function(selected)
        if selected ~= "" and AnimationLibrary[selected] then
            getgenv().AnimationSettings.SelectedAnimation = selected
            ApplyAnimations(AnimationLibrary[selected])
            Orion:MakeNotification({
                Name = "✅ Paquete Aplicado",
                Content = "Paquete " .. selected .. " aplicado completamente",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        end
    end
})

MainTab:AddButton({
    Name = "🔄 Aplicar Paquete Seleccionado",
    Callback = function()
        local selected = getgenv().AnimationSettings.SelectedAnimation
        if selected ~= "" and AnimationLibrary[selected] then
            ApplyAnimations(AnimationLibrary[selected])
            Orion:MakeNotification({
                Name = "✅ Éxito",
                Content = "Paquete " .. selected .. " aplicado",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        else
            Orion:MakeNotification({
                Name = "❌ Error",
                Content = "Selecciona un paquete primero",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        end
    end
})

MainTab:AddSection({
    Name = "🎮 Controles Generales"
})

MainTab:AddButton({
    Name = "🔄 Resetear a Animaciones Normales",
    Callback = function()
        getgenv().AnimationSettings.SelectedAnimation = ""
        -- Animaciones por defecto de Roblox
        local defaultAnimations = {
            Idle = 180435571,
            Walk = 180426354,
            Run = 180426354,
            Jump = 125750702,
            Fall = 180436148,
            Idle2 = 180435792
        }
        ApplyAnimations(defaultAnimations)
        Orion:MakeNotification({
            Name = "✅ Animaciones Reseteadas",
            Content = "Animaciones restauradas a las normales",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
})

MainTab:AddButton({
    Name = "⏸️ Detener Todas las Animaciones",
    Callback = function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
                Orion:MakeNotification({
                    Name = "✅ Animaciones Detenidas",
                    Content = "Todas las animaciones fueron detenidas",
                    Image = "rbxassetid://10723427954",
                    Time = 3
                })
            end
        end
    end
})

-- ========== TAB INDIVIDUALES ==========
IndividualTab:AddSection({
    Name = "🎭 Animación IDLE (Reposo)"
})

IndividualTab:AddDropdown({
    Name = "Seleccionar Animación IDLE",
    Default = "",
    Options = packageOptions,
    Callback = function(selected)
        if selected ~= "" and AnimationLibrary[selected] and AnimationLibrary[selected].Idle then
            ApplySingleAnimation("idle", AnimationLibrary[selected].Idle)
            Orion:MakeNotification({
                Name = "✅ IDLE Aplicado",
                Content = "IDLE " .. selected .. " aplicado",
                Image = "rbxassetid://10723427954",
                Time = 2
            })
        end
    end
})

IndividualTab:AddSection({
    Name = "🚶 Animación WALK (Caminar)"
})

IndividualTab:AddDropdown({
    Name = "Seleccionar Animación WALK",
    Default = "",
    Options = packageOptions,
    Callback = function(selected)
        if selected ~= "" and AnimationLibrary[selected] and AnimationLibrary[selected].Walk then
            ApplySingleAnimation("walk", AnimationLibrary[selected].Walk)
            Orion:MakeNotification({
                Name = "✅ WALK Aplicado",
                Content = "WALK " .. selected .. " aplicado",
                Image = "rbxassetid://10723427954",
                Time = 2
            })
        end
    end
})

IndividualTab:AddSection({
    Name = "🏃 Animación RUN (Correr)"
})

IndividualTab:AddDropdown({
    Name = "Seleccionar Animación RUN",
    Default = "",
    Options = packageOptions,
    Callback = function(selected)
        if selected ~= "" and AnimationLibrary[selected] and AnimationLibrary[selected].Run then
            ApplySingleAnimation("run", AnimationLibrary[selected].Run)
            Orion:MakeNotification({
                Name = "✅ RUN Aplicado",
                Content = "RUN " .. selected .. " aplicado",
                Image = "rbxassetid://10723427954",
                Time = 2
            })
        end
    end
})

IndividualTab:AddSection({
    Name = "🦘 Animación JUMP (Saltar)"
})

IndividualTab:AddDropdown({
    Name = "Seleccionar Animación JUMP",
    Default = "",
    Options = packageOptions,
    Callback = function(selected)
        if selected ~= "" and AnimationLibrary[selected] and AnimationLibrary[selected].Jump then
            ApplySingleAnimation("jump", AnimationLibrary[selected].Jump)
            Orion:MakeNotification({
                Name = "✅ JUMP Aplicado",
                Content = "JUMP " .. selected .. " aplicado",
                Image = "rbxassetid://10723427954",
                Time = 2
            })
        end
    end
})

IndividualTab:AddSection({
    Name = "📉 Animación FALL (Caer)"
})

IndividualTab:AddDropdown({
    Name = "Seleccionar Animación FALL",
    Default = "",
    Options = packageOptions,
    Callback = function(selected)
        if selected ~= "" and AnimationLibrary[selected] and AnimationLibrary[selected].Fall then
            ApplySingleAnimation("fall", AnimationLibrary[selected].Fall)
            Orion:MakeNotification({
                Name = "✅ FALL Aplicado",
                Content = "FALL " .. selected .. " aplicado",
                Image = "rbxassetid://10723427954",
                Time = 2
            })
        end
    end
})

IndividualTab:AddSection({
    Name = "⚡ Aplicación Rápida"
})

IndividualTab:AddDropdown({
    Name = "Aplicar Todas las Animaciones de:",
    Default = "",
    Options = packageOptions,
    Callback = function(selected)
        if selected ~= "" and AnimationLibrary[selected] then
            ApplyAnimations(AnimationLibrary[selected])
            Orion:MakeNotification({
                Name = "✅ Todas Aplicadas",
                Content = "Todas las animaciones de " .. selected .. " aplicadas",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        end
    end
})

-- ========== TAB PERSONALIZADO ==========
CustomTab:AddSection({
    Name = "🔧 Animaciones Personalizadas"
})

-- Campos para IDs personalizados
local customIds = {}

CustomTab:AddTextbox({
    Name = "ID Animación Idle",
    Default = getgenv().AnimationSettings.CustomAnimations.Idle or "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Idle = value
        customIds.Idle = value
    end
})

CustomTab:AddTextbox({
    Name = "ID Animación Walk",
    Default = getgenv().AnimationSettings.CustomAnimations.Walk or "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Walk = value
        customIds.Walk = value
    end
})

CustomTab:AddTextbox({
    Name = "ID Animación Run",
    Default = getgenv().AnimationSettings.CustomAnimations.Run or "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Run = value
        customIds.Run = value
    end
})

CustomTab:AddTextbox({
    Name = "ID Animación Jump",
    Default = getgenv().AnimationSettings.CustomAnimations.Jump or "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Jump = value
        customIds.Jump = value
    end
})

CustomTab:AddTextbox({
    Name = "ID Animación Fall",
    Default = getgenv().AnimationSettings.CustomAnimations.Fall or "",
    TextDisappear = true,
    Callback = function(value)
        getgenv().AnimationSettings.CustomAnimations.Fall = value
        customIds.Fall = value
    end
})

CustomTab:AddButton({
    Name = "✅ Aplicar Animaciones Personalizadas",
    Callback = function()
        ApplyAnimations(getgenv().AnimationSettings.CustomAnimations)
        Orion:MakeNotification({
            Name = "✅ Animaciones Aplicadas",
            Content = "Animaciones personalizadas aplicadas",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
})

CustomTab:AddSection({
    Name = "🎯 Aplicar Animación Individual"
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
    Options = {"idle", "walk", "run", "jump", "fall", "climb", "swim"},
    Callback = function(selected)
        currentAnimationType = selected
    end
})

CustomTab:AddButton({
    Name = "🎯 Aplicar Animación Individual",
    Callback = function()
        if currentAnimationID and currentAnimationID ~= "" then
            ApplySingleAnimation(currentAnimationType, currentAnimationID)
            Orion:MakeNotification({
                Name = "✅ Animación Aplicada",
                Content = "Animación " .. currentAnimationType .. " aplicada",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        else
            Orion:MakeNotification({
                Name = "❌ Error",
                Content = "Ingresa un ID de animación válido",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        end
    end
})

-- ========== TAB CONFIGURACIÓN ==========
SettingsTab:AddSection({
    Name = "⚙️ Opciones Generales"
})

SettingsTab:AddToggle({
    Name = "🔄 Auto Aplicar al Respawn",
    Default = false,
    Callback = function(value)
        getgenv().AutoApply = value
        Orion:MakeNotification({
            Name = value and "✅ Auto Aplicar Activado" or "❌ Auto Aplicar Desactivado",
            Content = value and "Las animaciones se aplicarán automáticamente al respawn" or "Auto aplicar desactivado",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
})

SettingsTab:AddSection({
    Name = "🎚️ Configuración de Velocidad"
})

SettingsTab:AddSlider({
    Name = "Velocidad de Animación",
    Min = 0.1,
    Max = 5,
    Default = getgenv().AnimationSettings.AnimationSpeed or 1,
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
        Orion:MakeNotification({
            Name = "✅ Velocidad Actualizada",
            Content = "Velocidad de animación: " .. value,
            Image = "rbxassetid://10723427954",
            Time = 2
        })
    end
})

SettingsTab:AddSection({
    Name = "⌨️ Controles"
})

SettingsTab:AddBind({
    Name = "Toggle UI",
    Default = Enum.KeyCode.RightControl,
    Hold = false,
    Callback = function()
        Orion:ToggleUI()
    end
})

SettingsTab:AddButton({
    Name = "💾 Guardar Configuración",
    Callback = function()
        Orion:MakeNotification({
            Name = "✅ Configuración Guardada",
            Content = "Tus ajustes han sido guardados",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
})

SettingsTab:AddButton({
    Name = "🗑️ Restablecer Configuración",
    Callback = function()
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
        Orion:MakeNotification({
            Name = "✅ Configuración Restablecida",
            Content = "Todos los ajustes han sido restablecidos",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
})

-- ========== FUNCIONALIDADES ADICIONALES ==========

-- Función para manejar el respawn del personaje
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1) -- Esperar a que el personaje esté completamente cargado
    
    if getgenv().AutoApply then
        local selected = getgenv().AnimationSettings.SelectedAnimation
        if selected ~= "" and AnimationLibrary[selected] then
            task.wait(0.5)
            ApplyAnimations(AnimationLibrary[selected])
            Orion:MakeNotification({
                Name = "✅ Animaciones Auto-Aplicadas",
                Content = "Paquete " .. selected .. " aplicado automáticamente",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        end
    end
end)

-- Notificación de carga
Orion:MakeNotification({
    Name = "🎭 Sistema de Animaciones Cargado",
    Content = "Presiona RightControl para abrir/cerrar el menu\nVersión 2.0 - Mejorado",
    Image = "rbxassetid://10723427954",
    Time = 5
})

-- Aplicar animaciones si hay una seleccionada al iniciar
task.spawn(function()
    task.wait(2)
    local selected = getgenv().AnimationSettings.SelectedAnimation
    if selected ~= "" and AnimationLibrary[selected] then
        ApplyAnimations(AnimationLibrary[selected])
        Orion:MakeNotification({
            Name = "✅ Animaciones Iniciales Aplicadas",
            Content = "Paquete " .. selected .. " aplicado al iniciar",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
end)

print("🎭 Animations Changer v2.0 cargado correctamente!")
