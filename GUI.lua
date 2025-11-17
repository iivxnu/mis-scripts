local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Esperar a que el juego cargue
repeat 
    task.wait() 
until game:IsLoaded() and LocalPlayer

-- Cargar tu UI Library personalizada
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/iivxnu/mis-scripts/refs/heads/main/UILibrary.lua"))()

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
    }
}

-- Función para esperar el personaje
local function waitForCharacter()
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    repeat task.wait() until LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    return LocalPlayer.Character
end

-- Función mejorada para aplicar animaciones
local function ApplyAnimations(animationData)
    local success, errorMsg = pcall(function()
        local character = waitForCharacter()
        if not character then 
            OrionLib:MakeNotification({
                Name = "❌ Error",
                Content = "Personaje no encontrado",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
            return 
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then 
            OrionLib:MakeNotification({
                Name = "❌ Error",
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
        
        -- Aplicar nuevas animaciones
        local animateScript = character:WaitForChild("Animate", 3)
        if animateScript then
            -- Función segura para aplicar animaciones
            local function safeApply(part, animId)
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

            if animationData.Idle and animateScript:FindFirstChild("idle") then
                local idle = animateScript.idle
                safeApply(idle.Animation1, animationData.Idle)
                if animationData.Idle2 then
                    safeApply(idle.Animation2, animationData.Idle2)
                end
            end
            
            if animationData.Walk and animateScript:FindFirstChild("walk") then
                safeApply(animateScript.walk, animationData.Walk)
            end
            
            if animationData.Run and animateScript:FindFirstChild("run") then
                safeApply(animateScript.run, animationData.Run)
            end
            
            if animationData.Jump and animateScript:FindFirstChild("jump") then
                safeApply(animateScript.jump, animationData.Jump)
            end
            
            if animationData.Fall and animateScript:FindFirstChild("fall") then
                safeApply(animateScript.fall, animationData.Fall)
            end
            
            -- Aplicar velocidad
            if getgenv().AnimationSettings.AnimationSpeed then
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    track:AdjustSpeed(getgenv().AnimationSettings.AnimationSpeed)
                end
            end
            
            return true
        else
            OrionLib:MakeNotification({
                Name = "❌ Error",
                Content = "Script Animate no encontrado",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
            return false
        end
    end)
    
    if not success then
        warn("Error aplicando animaciones: " .. tostring(errorMsg))
        OrionLib:MakeNotification({
            Name = "❌ Error",
            Content = "Error al aplicar animaciones",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
    
    return success
end

-- Función para aplicar animación individual
local function ApplySingleAnimation(animationType, animationId)
    if not animationId or animationId == "" then return end
    
    pcall(function()
        local character = waitForCharacter()
        if not character then return end
        
        local animateScript = character:FindFirstChild("Animate")
        if not animateScript then return end
        
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

-- Crear la ventana principal con tu tema Negro/Rosa
local Window = OrionLib:MakeWindow({
    Name = "🎭 Animations Changer",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "AnimationsConfig",
    IntroEnabled = true,
    IntroText = "Black & Pink Animation System",
    ShowIcon = true,
    Icon = "rbxassetid://10723427954"
})

-- Crear los tabs
local MainTab = Window:MakeTab({
    Name = "🎯 Animaciones",
    Icon = "rbxassetid://10723427954"
})

local IndividualTab = Window:MakeTab({
    Name = "🔧 Individuales",
    Icon = "rbxassetid://10723428312"
})

local CustomTab = Window:MakeTab({
    Name = "✨ Personalizado", 
    Icon = "rbxassetid://10723428664"
})

local SettingsTab = Window:MakeTab({
    Name = "⚙️ Configuración",
    Icon = "rbxassetid://10723428916"
})

-- ========== TAB ANIMACIONES ==========
MainTab:AddSection({
    Name = "🎯 Paquetes Completos"
})

-- Obtener opciones para dropdown
local packageOptions = {}
for packageName, _ in pairs(AnimationLibrary) do
    table.insert(packageOptions, packageName)
end
table.sort(packageOptions)

local selectedPackage = ""

local AnimationDropdown = MainTab:AddDropdown({
    Name = "Seleccionar Paquete",
    Default = getgenv().AnimationSettings.SelectedAnimation or "",
    Options = packageOptions,
    Callback = function(selected)
        if selected ~= "" and AnimationLibrary[selected] then
            selectedPackage = selected
            getgenv().AnimationSettings.SelectedAnimation = selected
        end
    end
})

MainTab:AddButton({
    Name = "🔄 Aplicar Paquete",
    Callback = function()
        if selectedPackage ~= "" and AnimationLibrary[selectedPackage] then
            local success = ApplyAnimations(AnimationLibrary[selectedPackage])
            if success then
                OrionLib:MakeNotification({
                    Name = "✅ Éxito",
                    Content = "Paquete " .. selectedPackage .. " aplicado",
                    Image = "rbxassetid://10723427954",
                    Time = 3
                })
            end
        else
            OrionLib:MakeNotification({
                Name = "❌ Error",
                Content = "Selecciona un paquete primero",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        end
    end
})

MainTab:AddSection({
    Name = "🎮 Controles Rápidos"
})

MainTab:AddButton({
    Name = "🔄 Resetear a Default",
    Callback = function()
        getgenv().AnimationSettings.SelectedAnimation = ""
        selectedPackage = ""
        -- Animaciones por defecto de Roblox
        local defaultAnimations = {
            Idle = 180435571,
            Walk = 180426354,
            Run = 180426354,
            Jump = 125750702,
            Fall = 180436148
        }
        ApplyAnimations(defaultAnimations)
        OrionLib:MakeNotification({
            Name = "✅ Reset Completo",
            Content = "Animaciones restauradas",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
})

MainTab:AddButton({
    Name = "⏸️ Detener Animaciones",
    Callback = function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    track:Stop()
                end
                OrionLib:MakeNotification({
                    Name = "✅ Detenidas",
                    Content = "Animaciones paradas",
                    Image = "rbxassetid://10723427954",
                    Time = 2
                })
            end
        end
    end
})

-- ========== TAB INDIVIDUALES ==========
IndividualTab:AddSection({
    Name = "🔧 Animaciones Individuales"
})

-- Crear dropdowns para cada tipo de animación
local animationTypes = {
    {"Idle", "🪑 Reposo"},
    {"Walk", "🚶 Caminar"}, 
    {"Run", "🏃 Correr"},
    {"Jump", "🦘 Saltar"},
    {"Fall", "📉 Caer"}
}

for _, animData in ipairs(animationTypes) do
    IndividualTab:AddSection({
        Name = animData[2]
    })
    
    IndividualTab:AddDropdown({
        Name = "Seleccionar " .. animData[1],
        Default = "",
        Options = packageOptions,
        Callback = function(selected)
            if selected ~= "" and AnimationLibrary[selected] and AnimationLibrary[selected][animData[1]] then
                ApplySingleAnimation(animData[1]:lower(), AnimationLibrary[selected][animData[1]])
                OrionLib:MakeNotification({
                    Name = "✅ " .. animData[1] .. " Aplicado",
                    Content = animData[1] .. " " .. selected .. " aplicado",
                    Image = "rbxassetid://10723427954",
                    Time = 2
                })
            end
        end
    })
end

IndividualTab:AddSection({
    Name = "⚡ Aplicación Rápida"
})

IndividualTab:AddDropdown({
    Name = "Aplicar Todo de:",
    Default = "",
    Options = packageOptions,
    Callback = function(selected)
        if selected ~= "" and AnimationLibrary[selected] then
            ApplyAnimations(AnimationLibrary[selected])
            OrionLib:MakeNotification({
                Name = "✅ Todo Aplicado",
                Content = "Todas las animaciones de " .. selected,
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        end
    end
})

-- ========== TAB PERSONALIZADO ==========
CustomTab:AddSection({
    Name = "✨ IDs Personalizados"
})

-- Campos para IDs personalizados
local customFields = {
    {"Idle", "🪑 Idle"},
    {"Walk", "🚶 Walk"}, 
    {"Run", "🏃 Run"},
    {"Jump", "🦘 Jump"},
    {"Fall", "📉 Fall"}
}

for _, fieldData in ipairs(customFields) do
    CustomTab:AddTextbox({
        Name = fieldData[2],
        Default = getgenv().AnimationSettings.CustomAnimations[fieldData[1]] or "",
        TextDisappear = false,
        Callback = function(value)
            getgenv().AnimationSettings.CustomAnimations[fieldData[1]] = value
        end
    })
end

CustomTab:AddButton({
    Name = "✅ Aplicar Personalizadas",
    Callback = function()
        ApplyAnimations(getgenv().AnimationSettings.CustomAnimations)
        OrionLib:MakeNotification({
            Name = "✅ Personalizadas Aplicadas",
            Content = "Animaciones custom aplicadas",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
})

CustomTab:AddSection({
    Name = "🎯 Aplicación Individual"
})

local currentCustomAnim = {
    ID = "",
    Type = "idle"
}

CustomTab:AddTextbox({
    Name = "🔢 ID de Animación",
    Default = "",
    TextDisappear = false,
    Callback = function(value)
        currentCustomAnim.ID = value
    end
})

CustomTab:AddDropdown({
    Name = "📝 Tipo de Animación",
    Default = "idle",
    Options = {"idle", "walk", "run", "jump", "fall"},
    Callback = function(selected)
        currentCustomAnim.Type = selected
    end
})

CustomTab:AddButton({
    Name = "🎯 Aplicar Individual",
    Callback = function()
        if currentCustomAnim.ID and currentCustomAnim.ID ~= "" then
            ApplySingleAnimation(currentCustomAnim.Type, currentCustomAnim.ID)
            OrionLib:MakeNotification({
                Name = "✅ Individual Aplicada",
                Content = "Animación " .. currentCustomAnim.Type .. " aplicada",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "❌ Error",
                Content = "Ingresa un ID válido",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        end
    end
})

-- ========== TAB CONFIGURACIÓN ==========
SettingsTab:AddSection({
    Name = "⚙️ Ajustes Generales"
})

local autoApplyToggle = SettingsTab:AddToggle({
    Name = "🔄 Auto-Aplicar al Respawn",
    Default = false,
    Callback = function(value)
        getgenv().AutoApply = value
        OrionLib:MakeNotification({
            Name = value and "✅ Auto-Aplicar ON" or "❌ Auto-Aplicar OFF",
            Content = value and "Se aplicará al respawn" or "No se aplicará al respawn",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
})

SettingsTab:AddSection({
    Name = "🎚️ Velocidad"
})

SettingsTab:AddSlider({
    Name = "Velocidad de Animación",
    Min = 0.1,
    Max = 5,
    Default = getgenv().AnimationSettings.AnimationSpeed or 1,
    Color = Color3.fromRGB(255, 105, 180), -- Color rosa para el slider
    Increment = 0.1,
    ValueName = "x",
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
        OrionLib:MakeNotification({
            Name = "✅ Velocidad Cambiada",
            Content = "Velocidad: " .. value .. "x",
            Image = "rbxassetid://10723427954",
            Time = 2
        })
    end
})

SettingsTab:AddSection({
    Name = "⌨️ Controles"
})

SettingsTab:AddBind({
    Name = "Mostrar/Ocultar UI",
    Default = Enum.KeyCode.RightControl,
    Hold = false,
    Callback = function()
        OrionLib:ToggleUI()
    end
})

SettingsTab:AddButton({
    Name = "💾 Guardar Configuración",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "✅ Config Guardada",
            Content = "Ajustes guardados correctamente",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
})

SettingsTab:AddButton({
    Name = "🗑️ Limpiar Todo",
    Callback = function()
        getgenv().AnimationSettings = {
            SelectedAnimation = "",
            AnimationSpeed = 1,
            CustomAnimations = {
                Idle = "", Walk = "", Run = "", Jump = "", Fall = "", Idle2 = ""
            }
        }
        selectedPackage = ""
        autoApplyToggle:Set(false)
        OrionLib:MakeNotification({
            Name = "✅ Todo Limpiado",
            Content = "Configuración resetada",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
})

-- ========== FUNCIONALIDADES ==========

-- Manejar respawn del personaje
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(2) -- Esperar más tiempo para asegurar carga
    
    if getgenv().AutoApply then
        local selected = getgenv().AnimationSettings.SelectedAnimation
        if selected ~= "" and AnimationLibrary[selected] then
            task.wait(1)
            ApplyAnimations(AnimationLibrary[selected])
            OrionLib:MakeNotification({
                Name = "✅ Auto-Aplicado",
                Content = selected .. " aplicado al respawn",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        end
    end
end)

-- Notificación inicial
task.spawn(function()
    task.wait(2)
    OrionLib:MakeNotification({
        Name = "🎭 Animations Changer",
        Content = "UI Cargada - RightControl para toggle\nTema Negro/Rosa Activado",
        Image = "rbxassetid://10723427954",
        Time = 6
    })
end)

-- Aplicar al iniciar si hay selección
task.spawn(function()
    task.wait(3)
    local selected = getgenv().AnimationSettings.SelectedAnimation
    if selected ~= "" and AnimationLibrary[selected] then
        ApplyAnimations(AnimationLibrary[selected])
        OrionLib:MakeNotification({
            Name = "✅ Animaciones Iniciales",
            Content = "Paquete " .. selected .. " aplicado al iniciar",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
end)

-- Inicializar la librería
OrionLib:Init()

print("🎭 Animations Changer - UI Negro/Rosa Cargada!")
