-- Animations GUI Script
-- Creado para Roblox

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Esperar a que el juego cargue
repeat task.wait() until game:IsLoaded() and LocalPlayer.Character

-- Configuración principal
local Config = {
    CurrentAnimation = "",
    AnimationSpeed = 1,
    GUIEnabled = true
}

-- Biblioteca de animaciones
local AnimationLibrary = {
    ["Idle Animations"] = {
        ["Relajado"] = "http://www.roblox.com/asset/?id=616158929",
        ["Estilo"] = "http://www.roblox.com/asset/?id=616136790",
        ["Robot"] = "http://www.roblox.com/asset/?id=616088211",
        ["Zombie"] = "http://www.roblox.com/asset/?id=616158929"
    },
    
    ["Walk Animations"] = {
        ["Normal"] = "http://www.roblox.com/asset/?id=616146177",
        ["Estilo"] = "http://www.roblox.com/asset/?id=616146177",
        ["Robot"] = "http://www.roblox.com/asset/?id=616095330",
        ["Zombie"] = "http://www.roblox.com/asset/?id=616168032"
    },
    
    ["Run Animations"] = {
        ["Normal"] = "http://www.roblox.com/asset/?id=616140816",
        ["Estilo"] = "http://www.roblox.com/asset/?id=616140816",
        ["Robot"] = "http://www.roblox.com/asset/?id=616091570",
        ["Zombie"] = "http://www.roblox.com/asset/?id=616163682"
    },
    
    ["Jump Animations"] = {
        ["Normal"] = "http://www.roblox.com/asset/?id=616139451",
        ["Estilo"] = "http://www.roblox.com/asset/?id=616139451",
        ["Robot"] = "http://www.roblox.com/asset/?id=616090535",
        ["Zombie"] = "http://www.roblox.com/asset/?id=616161997"
    },
    
    ["Emotes"] = {
        ["Ola"] = "http://www.roblox.com/asset/?id=9527883498",
        ["Baile 1"] = "http://www.roblox.com/asset/?id=507771019",
        ["Baile 2"] = "http://www.roblox.com/asset/?id=507776043",
        ["Baile 3"] = "http://www.roblox.com/asset/?id=507777268",
        ["Saludo"] = "http://www.roblox.com/asset/?id=507770677",
        ["Risa"] = "http://www.roblox.com/asset/?id=507770818"
    }
}

-- Variables globales
local ScreenGui, MainFrame
local CurrentAnimationTrack

-- Función para aplicar animación
local function ApplyAnimation(animationName, animationId)
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Detener animación actual
    if CurrentAnimationTrack then
        CurrentAnimationTrack:Stop()
        CurrentAnimationTrack = nil
    end
    
    -- Crear y reproducir nueva animación
    local animation = Instance.new("Animation")
    animation.AnimationId = animationId
    
    CurrentAnimationTrack = humanoid:LoadAnimation(animation)
    CurrentAnimationTrack:Play()
    CurrentAnimationTrack:AdjustSpeed(Config.AnimationSpeed)
    
    Config.CurrentAnimation = animationName
    UpdateStatusLabel()
end

-- Función para actualizar la etiqueta de estado
local function UpdateStatusLabel()
    if MainFrame and MainFrame.StatusLabel then
        MainFrame.StatusLabel.Text = "Animación: " .. (Config.CurrentAnimation or "Ninguna") .. " | Velocidad: " .. Config.AnimationSpeed
    end
end

-- Función para crear botones de animación
local function CreateAnimationButtons(categoryName, animations)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Name = categoryName
    sectionFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    sectionFrame.BorderSizePixel = 0
    sectionFrame.Size = UDim2.new(0.95, 0, 0, 40)
    sectionFrame.Parent = MainFrame.ScrollingFrame
    
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Name = "SectionLabel"
    sectionLabel.Text = categoryName
    sectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    sectionLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sectionLabel.BorderSizePixel = 0
    sectionLabel.Size = UDim2.new(1, 0, 0, 25)
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextSize = 14
    sectionLabel.Parent = sectionFrame
    
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "ButtonsFrame"
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Size = UDim2.new(1, 0, 0, 15)
    buttonsFrame.Position = UDim2.new(0, 0, 0, 25)
    buttonsFrame.Parent = sectionFrame
    
    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.Padding = UDim.new(0, 5)
    buttonLayout.Parent = buttonsFrame
    
    -- Crear botones para cada animación
    for animName, animId in pairs(animations) do
        local animButton = Instance.new("TextButton")
        animButton.Name = animName
        animButton.Text = animName
        animButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        animButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        animButton.BorderSizePixel = 0
        animButton.Size = UDim2.new(0, 80, 0, 25)
        animButton.Font = Enum.Font.Gotham
        animButton.TextSize = 12
        animButton.Parent = buttonsFrame
        
        animButton.MouseButton1Click:Connect(function()
            ApplyAnimation(animName, animId)
        end)
    end
    
    -- Ajustar tamaño de la sección basado en los botones
    sectionFrame.Size = UDim2.new(0.95, 0, 0, 40 + (#animations > 0 and 30 or 0))
end

-- Función para crear la GUI
local function CreateGUI()
    -- Crear ScreenGui
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AnimationsGUI"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Frame principal
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Size = UDim2.new(0, 350, 0, 400)
    MainFrame.Position = UDim2.new(0, 10, 0, 10)
    MainFrame.Parent = ScreenGui
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = MainFrame
    
    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Parent = MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Text = "🎭 Controlador de Animaciones"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.Parent = titleBar
    
    -- Botón de cerrar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Size = UDim2.new(0, 30, 0, 25)
    closeButton.Position = UDim2.new(1, -35, 0, 2)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 12
    closeButton.Parent = titleBar
    
    closeButton.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = not ScreenGui.Enabled
    end)
    
    -- Frame de desplazamiento
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Name = "ScrollingFrame"
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.Size = UDim2.new(1, 0, 1, -70)
    scrollingFrame.Position = UDim2.new(0, 0, 0, 35)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.ScrollBarThickness = 5
    scrollingFrame.Parent = MainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scrollingFrame
    
    -- Crear secciones de animaciones
    for category, animations in pairs(AnimationLibrary) do
        CreateAnimationButtons(category, animations)
    end
    
    -- Barra de control de velocidad
    local speedSection = Instance.new("Frame")
    speedSection.Name = "SpeedControl"
    speedSection.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    speedSection.BorderSizePixel = 0
    speedSection.Size = UDim2.new(0.95, 0, 0, 60)
    speedSection.Parent = scrollingFrame
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Text = "Velocidad de Animación"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    speedLabel.BorderSizePixel = 0
    speedLabel.Size = UDim2.new(1, 0, 0, 25)
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextSize = 14
    speedLabel.Parent = speedSection
    
    local speedSlider = Instance.new("Frame")
    speedSlider.Name = "SpeedSlider"
    speedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    speedSlider.BorderSizePixel = 0
    speedSlider.Size = UDim2.new(0.9, 0, 0, 20)
    speedSlider.Position = UDim2.new(0.05, 0, 0, 30)
    speedSlider.Parent = speedSection
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.Parent = speedSlider
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Name = "SliderButton"
    sliderButton.Text = ""
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.BorderSizePixel = 0
    sliderButton.Size = UDim2.new(0, 10, 1, 0)
    sliderButton.Position = UDim2.new(0.5, -5, 0, 0)
    sliderButton.Parent = speedSlider
    
    -- Función para actualizar velocidad
    local function UpdateSpeed(value)
        Config.AnimationSpeed = math.clamp(value, 0.1, 5)
        if CurrentAnimationTrack then
            CurrentAnimationTrack:AdjustSpeed(Config.AnimationSpeed)
        end
        UpdateStatusLabel()
    end
    
    sliderButton.MouseButton1Down:Connect(function()
        local connection
        connection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local sliderAbsolutePosition = speedSlider.AbsolutePosition.X
                local sliderAbsoluteSize = speedSlider.AbsoluteSize.X
                local mouseX = input.Position.X
                
                local relativeX = math.clamp(mouseX - sliderAbsolutePosition, 0, sliderAbsoluteSize)
                local percentage = relativeX / sliderAbsoluteSize
                
                sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                sliderButton.Position = UDim2.new(percentage, -5, 0, 0)
                
                UpdateSpeed(percentage * 4.9 + 0.1)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                connection:Disconnect()
            end
        end)
    end)
    
    -- Etiqueta de estado
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Text = "Animación: Ninguna | Velocidad: 1"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    statusLabel.BorderSizePixel = 0
    statusLabel.Size = UDim2.new(1, 0, 0, 30)
    statusLabel.Position = UDim2.new(0, 0, 1, -30)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.Parent = MainFrame
    
    MainFrame.StatusLabel = statusLabel
    
    -- Botón para detener animación
    local stopButton = Instance.new("TextButton")
    stopButton.Name = "StopButton"
    stopButton.Text = "⏹️ Detener Animación"
    stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    stopButton.BorderSizePixel = 0
    stopButton.Size = UDim2.new(0.9, 0, 0, 30)
    stopButton.Position = UDim2.new(0.05, 0, 1, -70)
    stopButton.Font = Enum.Font.GothamBold
    stopButton.TextSize = 12
    stopButton.Parent = MainFrame
    
    stopButton.MouseButton1Click:Connect(function()
        if CurrentAnimationTrack then
            CurrentAnimationTrack:Stop()
            CurrentAnimationTrack = nil
            Config.CurrentAnimation = ""
            UpdateStatusLabel()
        end
    end)
    
    -- Ajustar tamaño del canvas
    task.spawn(function()
        task.wait(0.1)
        local totalHeight = 0
        for _, child in pairs(scrollingFrame:GetChildren()) do
            if child:IsA("Frame") and child ~= layout then
                totalHeight += child.Size.Y.Offset + 10
            end
        end
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    end)
end

-- Función para inicializar
local function Initialize()
    CreateGUI()
    
    -- Tecla de toggle (F2)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F2 then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)
    
    print("✅ GUI de Animaciones cargada correctamente")
    print("📝 Presiona F2 para mostrar/ocultar la interfaz")
end

-- Inicializar cuando el personaje esté listo
if LocalPlayer.Character then
    Initialize()
else
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        Initialize()
    end)
end

-- Reconectar si el personaje muere
LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").Died:Connect(function()
        if CurrentAnimationTrack then
            CurrentAnimationTrack:Stop()
            CurrentAnimationTrack = nil
            Config.CurrentAnimation = ""
            UpdateStatusLabel()
        end
    end)
end)

return {
    Config = Config,
    AnimationLibrary = AnimationLibrary,
    ApplyAnimation = ApplyAnimation
}
