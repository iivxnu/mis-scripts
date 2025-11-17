-- Animation Hub - Client Side Character Animations
-- Script para cambiar animaciones base del personaje

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Esperar a que todo cargue
repeat task.wait() until game:IsLoaded() and LocalPlayer.Character

-- Configuración
local Config = {
    CurrentPackage = "Default",
    AnimationSpeed = 1,
    GUIKey = Enum.KeyCode.RightShift,
    Enabled = true
}

-- Biblioteca de paquetes de animaciones
local AnimationPackages = {
    ["Default"] = {
        Idle = "http://www.roblox.com/asset/?id=616158929",
        Walk = "http://www.roblox.com/asset/?id=616146177",
        Run = "http://www.roblox.com/asset/?id=616140816",
        Jump = "http://www.roblox.com/asset/?id=616139451",
        Fall = "http://www.roblox.com/asset/?id=616134815",
        Swim = "http://www.roblox.com/asset/?id=616143378",
        SwimIdle = "http://www.roblox.com/asset/?id=616144772",
        Climb = "http://www.roblox.com/asset/?id=616133594"
    },
    
    ["Stylish"] = {
        Idle = "http://www.roblox.com/asset/?id=616136790",
        Idle2 = "http://www.roblox.com/asset/?id=616138447",
        Walk = "http://www.roblox.com/asset/?id=616146177",
        Run = "http://www.roblox.com/asset/?id=616140816",
        Jump = "http://www.roblox.com/asset/?id=616139451",
        Fall = "http://www.roblox.com/asset/?id=616134815",
        Swim = "http://www.roblox.com/asset/?id=616143378",
        SwimIdle = "http://www.roblox.com/asset/?id=616144772",
        Climb = "http://www.roblox.com/asset/?id=616133594"
    },
    
    ["Zombie"] = {
        Idle = "http://www.roblox.com/asset/?id=616158929",
        Walk = "http://www.roblox.com/asset/?id=616168032",
        Run = "http://www.roblox.com/asset/?id=616163682",
        Jump = "http://www.roblox.com/asset/?id=616161997",
        Fall = "http://www.roblox.com/asset/?id=616157476",
        Swim = "http://www.roblox.com/asset/?id=616165109",
        SwimIdle = "http://www.roblox.com/asset/?id=616166655",
        Climb = "http://www.roblox.com/asset/?id=616156119"
    },
    
    ["Robot"] = {
        Idle = "http://www.roblox.com/asset/?id=616088211",
        Walk = "http://www.roblox.com/asset/?id=616095330",
        Run = "http://www.roblox.com/asset/?id=616091570",
        Jump = "http://www.roblox.com/asset/?id=616090535",
        Fall = "http://www.roblox.com/asset/?id=616087089",
        Swim = "http://www.roblox.com/asset/?id=616092998",
        SwimIdle = "http://www.roblox.com/asset/?id=616094091",
        Climb = "http://www.roblox.com/asset/?id=616086039"
    },
    
    ["Vampire"] = {
        Idle = "http://www.roblox.com/asset/?id=1083445855",
        Walk = "http://www.roblox.com/asset/?id=1083473930",
        Run = "http://www.roblox.com/asset/?id=1083462077",
        Jump = "http://www.roblox.com/asset/?id=1083455352",
        Fall = "http://www.roblox.com/asset/?id=1083443587",
        Swim = "http://www.roblox.com/asset/?id=1083464683",
        SwimIdle = "http://www.roblox.com/asset/?id=1083467779",
        Climb = "http://www.roblox.com/asset/?id=1083439238"
    },
    
    ["Superhero"] = {
        Idle = "http://www.roblox.com/asset/?id=616111295",
        Walk = "http://www.roblox.com/asset/?id=616122287",
        Run = "http://www.roblox.com/asset/?id=616117076",
        Jump = "http://www.roblox.com/asset/?id=616115533",
        Fall = "http://www.roblox.com/asset/?id=616108001",
        Swim = "http://www.roblox.com/asset/?id=616119360",
        SwimIdle = "http://www.roblox.com/asset/?id=616120861",
        Climb = "http://www.roblox.com/asset/?id=616104706"
    },
    
    ["Ninja"] = {
        Idle = "http://www.roblox.com/asset/?id=656117400",
        Walk = "http://www.roblox.com/asset/?id=656121766",
        Run = "http://www.roblox.com/asset/?id=656118852",
        Jump = "http://www.roblox.com/asset/?id=656117878",
        Fall = "http://www.roblox.com/asset/?id=656115606",
        Swim = "http://www.roblox.com/asset/?id=656119721",
        SwimIdle = "http://www.roblox.com/asset/?id=656121397",
        Climb = "http://www.roblox.com/asset/?id=656114359"
    },
    
    ["Cartoony"] = {
        Idle = "http://www.roblox.com/asset/?id=742637544",
        Walk = "http://www.roblox.com/asset/?id=742640026",
        Run = "http://www.roblox.com/asset/?id=742638842",
        Jump = "http://www.roblox.com/asset/?id=742637942",
        Fall = "http://www.roblox.com/asset/?id=742637151",
        Swim = "http://www.roblox.com/asset/?id=742639220",
        SwimIdle = "http://www.roblox.com/asset/?id=742639812",
        Climb = "http://www.roblox.com/asset/?id=742636889"
    },
    
    ["Bubbly"] = {
        Idle = "http://www.roblox.com/asset/?id=910004836",
        Walk = "http://www.roblox.com/asset/?id=910034870",
        Run = "http://www.roblox.com/asset/?id=910025107",
        Jump = "http://www.roblox.com/asset/?id=910016857",
        Fall = "http://www.roblox.com/asset/?id=910001910",
        Swim = "http://www.roblox.com/asset/?id=910028158",
        SwimIdle = "http://www.roblox.com/asset/?id=910030921",
        Climb = "http://www.roblox.com/asset/?id=909997997"
    },
    
    ["Elder"] = {
        Idle = "http://www.roblox.com/asset/?id=845397899",
        Walk = "http://www.roblox.com/asset/?id=845403856",
        Run = "http://www.roblox.com/asset/?id=845386501",
        Jump = "http://www.roblox.com/asset/?id=845398858",
        Fall = "http://www.roblox.com/asset/?id=845396048",
        Swim = "http://www.roblox.com/asset/?id=845401742",
        SwimIdle = "http://www.roblox.com/asset/?id=845403127",
        Climb = "http://www.roblox.com/asset/?id=845392038"
    }
}

-- Variables
local ScreenGui, MainFrame
local OriginalAnimations = {}

-- Función para guardar animaciones originales
local function SaveOriginalAnimations()
    local character = LocalPlayer.Character
    if not character then return end
    
    local animate = character:FindFirstChild("Animate")
    if not animate then return end
    
    OriginalAnimations = {
        Idle1 = animate.idle.Animation1.AnimationId,
        Idle2 = animate.idle.Animation2.AnimationId,
        Walk = animate.walk.WalkAnim.AnimationId,
        Run = animate.run.RunAnim.AnimationId,
        Jump = animate.jump.JumpAnim.AnimationId,
        Fall = animate.fall.FallAnim.AnimationId,
        Swim = animate.swim.SwimAnim.AnimationId,
        SwimIdle = animate.swimidle.SwimIdleAnim.AnimationId,
        Climb = animate.climb.ClimbAnim.AnimationId
    }
end

-- Función para aplicar paquete de animaciones
local function ApplyAnimationPackage(packageName)
    local character = LocalPlayer.Character
    if not character then return end
    
    local animate = character:FindFirstChild("Animate")
    if not animate then return end
    
    local package = AnimationPackages[packageName]
    if not package then return end
    
    -- Aplicar animaciones
    if package.Idle then
        animate.idle.Animation1.AnimationId = package.Idle
        if package.Idle2 then
            animate.idle.Animation2.AnimationId = package.Idle2
        end
    end
    
    if package.Walk then
        animate.walk.WalkAnim.AnimationId = package.Walk
    end
    
    if package.Run then
        animate.run.RunAnim.AnimationId = package.Run
    end
    
    if package.Jump then
        animate.jump.JumpAnim.AnimationId = package.Jump
    end
    
    if package.Fall then
        animate.fall.FallAnim.AnimationId = package.Fall
    end
    
    if package.Swim then
        animate.swim.SwimAnim.AnimationId = package.Swim
    end
    
    if package.SwimIdle then
        animate.swimidle.SwimIdleAnim.AnimationId = package.SwimIdle
    end
    
    if package.Climb then
        animate.climb.ClimbAnim.AnimationId = package.Climb
    end
    
    Config.CurrentPackage = packageName
    UpdateStatus()
end

-- Función para restaurar animaciones originales
local function RestoreOriginalAnimations()
    local character = LocalPlayer.Character
    if not character then return end
    
    local animate = character:FindFirstChild("Animate")
    if not animate then return end
    
    if OriginalAnimations.Idle1 then
        animate.idle.Animation1.AnimationId = OriginalAnimations.Idle1
        animate.idle.Animation2.AnimationId = OriginalAnimations.Idle2
        animate.walk.WalkAnim.AnimationId = OriginalAnimations.Walk
        animate.run.RunAnim.AnimationId = OriginalAnimations.Run
        animate.jump.JumpAnim.AnimationId = OriginalAnimations.Jump
        animate.fall.FallAnim.AnimationId = OriginalAnimations.Fall
        animate.swim.SwimAnim.AnimationId = OriginalAnimations.Swim
        animate.swimidle.SwimIdleAnim.AnimationId = OriginalAnimations.SwimIdle
        animate.climb.ClimbAnim.AnimationId = OriginalAnimations.Climb
    end
    
    Config.CurrentPackage = "Default"
    UpdateStatus()
end

-- Función para actualizar estado
local function UpdateStatus()
    if MainFrame and MainFrame.StatusLabel then
        MainFrame.StatusLabel.Text = "Paquete: " .. Config.CurrentPackage .. " | Velocidad: " .. Config.AnimationSpeed
    end
end

-- Función para crear la GUI
local function CreateGUI()
    -- Crear ScreenGui
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AnimationHub"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Frame principal
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Parent = ScreenGui
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = MainFrame
    
    -- Sombra
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://5554236805"
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.BackgroundTransparency = 1
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.ZIndex = -1
    shadow.Parent = MainFrame
    
    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Parent = MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Text = "🎭 ANIMATION HUB"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Botón de cerrar
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    closeButton.BorderSizePixel = 0
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
    end)
    
    -- Frame de desplazamiento
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Name = "ScrollingFrame"
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.Size = UDim2.new(1, -20, 1, -120)
    scrollingFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollingFrame.ScrollBarThickness = 5
    scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
    scrollingFrame.Parent = MainFrame
    
    local layout = Instance.new("UIGridLayout")
    layout.CellSize = UDim2.new(0.5, -10, 0, 80)
    layout.CellPadding = UDim2.new(0, 10, 0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = scrollingFrame
    
    -- Crear botones para cada paquete
    for packageName, packageData in pairs(AnimationPackages) do
        local packageButton = Instance.new("TextButton")
        packageButton.Name = packageName
        packageButton.Text = packageName
        packageButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        packageButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        packageButton.BorderSizePixel = 0
        packageButton.Size = UDim2.new(1, 0, 1, 0)
        packageButton.Font = Enum.Font.GothamBold
        packageButton.TextSize = 14
        packageButton.Parent = scrollingFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = packageButton
        
        local buttonStroke = Instance.new("UIStroke")
        buttonStroke.Color = Color3.fromRGB(80, 80, 90)
        buttonStroke.Thickness = 2
        buttonStroke.Parent = packageButton
        
        packageButton.MouseEnter:Connect(function()
            TweenService:Create(packageButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(65, 65, 75)}):Play()
        end)
        
        packageButton.MouseLeave:Connect(function()
            TweenService:Create(packageButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
        end)
        
        packageButton.MouseButton1Click:Connect(function()
            ApplyAnimationPackage(packageName)
        end)
    end
    
    -- Ajustar tamaño del canvas
    task.spawn(function()
        task.wait(0.1)
        local packageCount = 0
        for _ in pairs(AnimationPackages) do
            packageCount += 1
        end
        local rows = math.ceil(packageCount / 2)
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, rows * 90)
    end)
    
    -- Barra inferior
    local bottomBar = Instance.new("Frame")
    bottomBar.Name = "BottomBar"
    bottomBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    bottomBar.BorderSizePixel = 0
    bottomBar.Size = UDim2.new(1, 0, 0, 60)
    bottomBar.Position = UDim2.new(0, 0, 1, -60)
    bottomBar.Parent = MainFrame
    
    -- Botón restaurar
    local restoreButton = Instance.new("TextButton")
    restoreButton.Name = "RestoreButton"
    restoreButton.Text = "🔄 Restaurar Original"
    restoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    restoreButton.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    restoreButton.BorderSizePixel = 0
    restoreButton.Size = UDim2.new(0, 150, 0, 35)
    restoreButton.Position = UDim2.new(0, 15, 0, 12)
    restoreButton.Font = Enum.Font.GothamBold
    restoreButton.TextSize = 12
    restoreButton.Parent = bottomBar
    
    local restoreCorner = Instance.new("UICorner")
    restoreCorner.CornerRadius = UDim.new(0, 6)
    restoreCorner.Parent = restoreButton
    
    restoreButton.MouseButton1Click:Connect(function()
        RestoreOriginalAnimations()
    end)
    
    -- Etiqueta de estado
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Text = "Paquete: " .. Config.CurrentPackage .. " | Velocidad: " .. Config.AnimationSpeed
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 1, -25)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = MainFrame
    
    MainFrame.StatusLabel = statusLabel
    
    -- Control de velocidad
    local speedFrame = Instance.new("Frame")
    speedFrame.Name = "SpeedFrame"
    speedFrame.BackgroundTransparency = 1
    speedFrame.Size = UDim2.new(0, 180, 0, 35)
    speedFrame.Position = UDim2.new(1, -195, 0, 12)
    speedFrame.Parent = bottomBar
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Text = "Velocidad:"
    speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Size = UDim2.new(0, 60, 1, 0)
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 12
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Parent = speedFrame
    
    local speedBox = Instance.new("TextBox")
    speedBox.Name = "SpeedBox"
    speedBox.Text = tostring(Config.AnimationSpeed)
    speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    speedFrame.BorderSizePixel = 0
    speedBox.Size = UDim2.new(0, 50, 1, 0)
    speedBox.Position = UDim2.new(0, 65, 0, 0)
    speedBox.Font = Enum.Font.Gotham
    speedBox.TextSize = 12
    speedBox.Parent = speedFrame
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 4)
    speedCorner.Parent = speedBox
    
    speedBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local newSpeed = tonumber(speedBox.Text)
            if newSpeed and newSpeed >= 0.1 and newSpeed <= 5 then
                Config.AnimationSpeed = newSpeed
                UpdateStatus()
            else
                speedBox.Text = tostring(Config.AnimationSpeed)
            end
        end
    end)
    
    -- Hacer la ventana arrastrable
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Función para inicializar
local function Initialize()
    CreateGUI()
    
    -- Guardar animaciones originales
    SaveOriginalAnimations()
    
    -- Tecla de toggle (RightShift)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Config.GUIKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)
    
    print("🎭 Animation Hub cargado correctamente")
    print("🎮 Presiona RightShift para mostrar/ocultar")
    print("📦 Paquetes disponibles: " .. tostring(#AnimationPackages))
end

-- Manejar cambios de personaje
local function SetupCharacter(character)
    task.wait(1) -- Esperar a que el personaje esté completamente cargado
    
    local humanoid = character:WaitForChild("Humanoid")
    local animate = character:WaitForChild("Animate")
    
    -- Guardar animaciones originales si es la primera vez
    if not next(OriginalAnimations) then
        SaveOriginalAnimations()
    end
    
    -- Re-aplicar el paquete actual si no es el default
    if Config.CurrentPackage ~= "Default" then
        ApplyAnimationPackage(Config.CurrentPackage)
    end
    
    humanoid.Died:Connect(function()
        task.wait(3) -- Esperar respawn
        if LocalPlayer.Character then
            SetupCharacter(LocalPlayer.Character)
        end
    end)
end

-- Inicializar cuando el personaje esté listo
if LocalPlayer.Character then
    SetupCharacter(LocalPlayer.Character)
    Initialize()
else
    LocalPlayer.CharacterAdded:Connect(function(character)
        SetupCharacter(character)
        if not ScreenGui then
            Initialize()
        end
    end)
end

-- Reconectar siempre que el personaje cambie
LocalPlayer.CharacterAdded:Connect(SetupCharacter)

return {
    Config = Config,
    AnimationPackages = AnimationPackages,
    ApplyAnimationPackage = ApplyAnimationPackage,
    RestoreOriginalAnimations = RestoreOriginalAnimations
}
