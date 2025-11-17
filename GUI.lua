local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Esperar a que el juego cargue
repeat 
    task.wait() 
until game:IsLoaded() and LocalPlayer

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

-- Crear la interfaz UI manualmente
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimationsChangerUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = game:GetService("CoreGui")

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 500)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Corner radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Shadow effect
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.8
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Parent = mainFrame
shadow.ZIndex = -1

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Animations Changer"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

-- Tabs container
local tabsContainer = Instance.new("Frame")
tabsContainer.Name = "TabsContainer"
tabsContainer.Size = UDim2.new(1, 0, 0, 40)
tabsContainer.Position = UDim2.new(0, 0, 0, 40)
tabsContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
tabsContainer.BorderSizePixel = 0
tabsContainer.Parent = mainFrame

-- Content frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -20, 1, -100)
contentFrame.Position = UDim2.new(0, 10, 0, 90)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Scrolling frame para el contenido
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
scrollFrame.Parent = contentFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 10)
uiListLayout.Parent = scrollFrame

-- Variables para controlar la UI
local currentTab = "Animaciones"
local tabs = {}
local tabButtons = {}

-- Función para crear un botón de tab
local function createTabButton(tabName)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = tabName .. "Tab"
    tabButton.Size = UDim2.new(0.25, 0, 1, 0)
    tabButton.Position = UDim2.new((#tabButtons * 0.25), 0, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    tabButton.BorderSizePixel = 0
    tabButton.Text = tabName
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.TextSize = 12
    tabButton.Font = Enum.Font.Gotham
    tabButton.Parent = tabsContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 4)
    tabCorner.Parent = tabButton
    
    table.insert(tabButtons, tabButton)
    return tabButton
end

-- Crear tabs
local tabNames = {"Animaciones", "Individual", "Personalizado", "Config"}
for i, tabName in ipairs(tabNames) do
    local tabButton = createTabButton(tabName)
    tabs[tabName] = {Button = tabButton, Content = {}}
    
    tabButton.MouseButton1Click:Connect(function()
        -- Actualizar tab activo
        currentTab = tabName
        updateTabContent()
    end)
end

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
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Esperar a que el script Animate exista
    local animateScript = character:WaitForChild("Animate", 5)
    if not animateScript then
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

-- Función para crear un botón en la UI
local function createButton(text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

-- Función para crear un dropdown
local function createDropdown(text, options, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 60)
    container.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(1, 0, 0, 35)
    dropdown.Position = UDim2.new(0, 0, 0, 25)
    dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    dropdown.BorderSizePixel = 0
    dropdown.Text = "Seleccionar..."
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.TextSize = 12
    dropdown.Font = Enum.Font.Gotham
    dropdown.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = dropdown
    
    dropdown.MouseButton1Click:Connect(function()
        -- Aquí podrías implementar un dropdown real, pero por simplicidad usaremos el primero
        if options and #options > 0 then
            local selected = options[1]
            dropdown.Text = selected
            if callback then
                callback(selected)
            end
        end
    end)
    
    return container
end

-- Función para crear una sección
local function createSection(titleText)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 40)
    section.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = titleText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = section
    
    return section
end

-- Función para actualizar el contenido del tab
local function updateTabContent()
    -- Limpiar contenido anterior
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if currentTab == "Animaciones" then
        -- Contenido del tab Animaciones
        local section1 = createSection("Paquetes de Animaciones Completas")
        section1.Parent = scrollFrame
        
        local packageOptions = {}
        for packageName, _ in pairs(AnimationLibrary) do
            table.insert(packageOptions, packageName)
        end
        
        local dropdown = createDropdown("Seleccionar Paquete Completo", packageOptions, function(selected)
            if selected and AnimationLibrary[selected] then
                getgenv().AnimationSettings.SelectedAnimation = selected
                ApplyAnimations(AnimationLibrary[selected])
            end
        end)
        dropdown.Parent = scrollFrame
        
        local applyButton = createButton("Aplicar Paquete Seleccionado", function()
            local selected = getgenv().AnimationSettings.SelectedAnimation
            if selected ~= "" and AnimationLibrary[selected] then
                ApplyAnimations(AnimationLibrary[selected])
            end
        end)
        applyButton.Parent = scrollFrame
        
        local section2 = createSection("Controles Generales")
        section2.Parent = scrollFrame
        
        local resetButton = createButton("Resetear a Animaciones Normales", function()
            getgenv().AnimationSettings.SelectedAnimation = ""
            local defaultAnimations = {
                Idle = 180435571,
                Walk = 180426354,
                Run = 180426354,
                Jump = 125750702,
                Fall = 180436148
            }
            ApplyAnimations(defaultAnimations)
        end)
        resetButton.Parent = scrollFrame
        
    elseif currentTab == "Individual" then
        -- Contenido del tab Individual
        local animationTypes = {
            {"IDLE (Reposo)", "Idle"},
            {"WALK (Caminar)", "Walk"}, 
            {"RUN (Correr)", "Run"},
            {"JUMP (Saltar)", "Jump"},
            {"FALL (Caer)", "Fall"}
        }
        
        for _, animData in ipairs(animationTypes) do
            local section = createSection(animData[1])
            section.Parent = scrollFrame
            
            local packageOptions = {}
            for packageName, _ in pairs(AnimationLibrary) do
                table.insert(packageOptions, packageName)
            end
            
            local dropdown = createDropdown("Seleccionar " .. animData[2], packageOptions, function(selected)
                if selected and AnimationLibrary[selected] and AnimationLibrary[selected][animData[2]] then
                    ApplySingleAnimation(animData[2]:lower(), AnimationLibrary[selected][animData[2]])
                end
            end)
            dropdown.Parent = scrollFrame
        end
        
    elseif currentTab == "Personalizado" then
        -- Contenido del tab Personalizado
        local section = createSection("Animaciones Personalizadas")
        section.Parent = scrollFrame
        
        local applyCustomButton = createButton("Aplicar Animaciones Personalizadas", function()
            ApplyAnimations(getgenv().AnimationSettings.CustomAnimations)
        end)
        applyCustomButton.Parent = scrollFrame
        
    elseif currentTab == "Config" then
        -- Contenido del tab Configuración
        local section = createSection("Configuración")
        section.Parent = scrollFrame
        
        local speedInfo = Instance.new("TextLabel")
        speedInfo.Size = UDim2.new(1, 0, 0, 30)
        speedInfo.BackgroundTransparency = 1
        speedInfo.Text = "Velocidad: " .. getgenv().AnimationSettings.AnimationSpeed
        speedInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
        speedInfo.TextSize = 12
        speedInfo.Font = Enum.Font.Gotham
        speedInfo.TextXAlignment = Enum.TextXAlignment.Left
        speedInfo.Parent = scrollFrame
        
        local speedButton = createButton("Aumentar Velocidad", function()
            getgenv().AnimationSettings.AnimationSpeed = math.min(5, getgenv().AnimationSettings.AnimationSpeed + 0.5)
            speedInfo.Text = "Velocidad: " .. getgenv().AnimationSettings.AnimationSpeed
            
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                        track:AdjustSpeed(getgenv().AnimationSettings.AnimationSpeed)
                    end
                end
            end
        end)
        speedButton.Parent = scrollFrame
    end
    
    -- Actualizar el tamaño del canvas
    task.wait()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
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

-- Configurar el botón de cerrar
closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

-- Función para toggle UI
local function toggleUI()
    screenGui.Enabled = not screenGui.Enabled
end

-- Bind para toggle UI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightControl then
        toggleUI()
    end
end)

-- Inicializar la UI
updateTabContent()

-- Notificación en consola
print("Animations Changer cargado! Presiona RightControl para abrir/cerrar el menu")

-- Aplicar animaciones si hay una seleccionada al iniciar
task.spawn(function()
    task.wait(3)
    local selected = getgenv().AnimationSettings.SelectedAnimation
    if selected ~= "" and AnimationLibrary[selected] then
        ApplyAnimations(AnimationLibrary[selected])
    end
end)
