-- Animation Hub - Simple Version
-- Script para cambiar animaciones base del personaje

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Esperar a que el juego cargue
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Esperar al personaje
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

local Character = LocalPlayer.Character
local Humanoid = Character:WaitForChild("Humanoid")
local Animate = Character:WaitForChild("Animate")

-- Biblioteca de animaciones
local AnimationPackages = {
    ["Default"] = {
        Idle = "http://www.roblox.com/asset/?id=616158929",
        Walk = "http://www.roblox.com/asset/?id=616146177", 
        Run = "http://www.roblox.com/asset/?id=616140816",
        Jump = "http://www.roblox.com/asset/?id=616139451",
        Climb = "http://www.roblox.com/asset/?id=616133594",
        Fall = "http://www.roblox.com/asset/?id=616134815"
    },
    
    ["Zombie"] = {
        Idle = "http://www.roblox.com/asset/?id=616158929",
        Walk = "http://www.roblox.com/asset/?id=616168032",
        Run = "http://www.roblox.com/asset/?id=616163682", 
        Jump = "http://www.roblox.com/asset/?id=616161997",
        Climb = "http://www.roblox.com/asset/?id=616156119",
        Fall = "http://www.roblox.com/asset/?id=616157476"
    },
    
    ["Robot"] = {
        Idle = "http://www.roblox.com/asset/?id=616088211",
        Walk = "http://www.roblox.com/asset/?id=616095330",
        Run = "http://www.roblox.com/asset/?id=616091570",
        Jump = "http://www.roblox.com/asset/?id=616090535",
        Climb = "http://www.roblox.com/asset/?id=616086039",
        Fall = "http://www.roblox.com/asset/?id=616087089"
    },
    
    ["Ninja"] = {
        Idle = "http://www.roblox.com/asset/?id=656117400",
        Walk = "http://www.roblox.com/asset/?id=656121766",
        Run = "http://www.roblox.com/asset/?id=656118852",
        Jump = "http://www.roblox.com/asset/?id=656117878",
        Climb = "http://www.roblox.com/asset/?id=656114359",
        Fall = "http://www.roblox.com/asset/?id=656115606"
    },
    
    ["Superhero"] = {
        Idle = "http://www.roblox.com/asset/?id=616111295",
        Walk = "http://www.roblox.com/asset/?id=616122287",
        Run = "http://www.roblox.com/asset/?id=616117076",
        Jump = "http://www.roblox.com/asset/?id=616115533",
        Climb = "http://www.roblox.com/asset/?id=616104706",
        Fall = "http://www.roblox.com/asset/?id=616108001"
    }
}

-- Guardar animaciones originales
local OriginalAnimations = {
    Idle1 = Animate.idle.Animation1.AnimationId,
    Idle2 = Animate.idle.Animation2.AnimationId,
    Walk = Animate.walk.WalkAnim.AnimationId,
    Run = Animate.run.RunAnim.AnimationId,
    Jump = Animate.jump.JumpAnim.AnimationId,
    Climb = Animate.climb.ClimbAnim.AnimationId,
    Fall = Animate.fall.FallAnim.AnimationId
}

-- Función para aplicar animaciones
local function ApplyAnimationPackage(packageName)
    local package = AnimationPackages[packageName]
    if not package then return end
    
    -- Aplicar las animaciones
    if package.Idle then
        Animate.idle.Animation1.AnimationId = package.Idle
        Animate.idle.Animation2.AnimationId = package.Idle
    end
    
    if package.Walk then
        Animate.walk.WalkAnim.AnimationId = package.Walk
    end
    
    if package.Run then
        Animate.run.RunAnim.AnimationId = package.Run
    end
    
    if package.Jump then
        Animate.jump.JumpAnim.AnimationId = package.Jump
    end
    
    if package.Climb then
        Animate.climb.ClimbAnim.AnimationId = package.Climb
    end
    
    if package.Fall then
        Animate.fall.FallAnim.AnimationId = package.Fall
    end
    
    print("✅ Animaciones " .. packageName .. " aplicadas")
end

-- Función para restaurar animaciones originales
local function RestoreOriginalAnimations()
    Animate.idle.Animation1.AnimationId = OriginalAnimations.Idle1
    Animate.idle.Animation2.AnimationId = OriginalAnimations.Idle2
    Animate.walk.WalkAnim.AnimationId = OriginalAnimations.Walk
    Animate.run.RunAnim.AnimationId = OriginalAnimations.Run
    Animate.jump.JumpAnim.AnimationId = OriginalAnimations.Jump
    Animate.climb.ClimbAnim.AnimationId = OriginalAnimations.Climb
    Animate.fall.FallAnim.AnimationId = OriginalAnimations.Fall
    
    print("✅ Animaciones originales restauradas")
end

-- Crear la GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnimationHub"
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
MainFrame.BorderSizePixel = 0
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Text = "🎭 ANIMATION HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.Parent = TitleBar

-- Botón de cerrar
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
end)

-- Frame de botones
local ButtonsFrame = Instance.new("ScrollingFrame")
ButtonsFrame.Name = "ButtonsFrame"
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.Size = UDim2.new(1, -20, 1, -100)
ButtonsFrame.Position = UDim2.new(0, 10, 0, 50)
ButtonsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ButtonsFrame.ScrollBarThickness = 5
ButtonsFrame.Parent = MainFrame

local ButtonsLayout = Instance.new("UIListLayout")
ButtonsLayout.Padding = UDim.new(0, 10)
ButtonsLayout.Parent = ButtonsFrame

-- Crear botones para cada paquete
for packageName, _ in pairs(AnimationPackages) do
    local Button = Instance.new("TextButton")
    Button.Name = packageName
    Button.Text = packageName
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Button.BorderSizePixel = 0
    Button.Size = UDim2.new(1, 0, 0, 50)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 14
    Button.Parent = ButtonsFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        ApplyAnimationPackage(packageName)
    end)
end

-- Ajustar tamaño del canvas
task.spawn(function()
    task.wait(0.1)
    local buttonCount = 0
    for _ in pairs(AnimationPackages) do
        buttonCount += 1
    end
    ButtonsFrame.CanvasSize = UDim2.new(0, 0, 0, (buttonCount * 60))
end)

-- Botón restaurar
local RestoreButton = Instance.new("TextButton")
RestoreButton.Name = "RestoreButton"
RestoreButton.Text = "🔄 RESTAURAR ORIGINAL"
RestoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RestoreButton.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
RestoreButton.BorderSizePixel = 0
RestoreButton.Size = UDim2.new(1, -20, 0, 40)
RestoreButton.Position = UDim2.new(0, 10, 1, -50)
RestoreButton.Font = Enum.Font.GothamBold
RestoreButton.TextSize = 12
RestoreButton.Parent = MainFrame

local RestoreCorner = Instance.new("UICorner")
RestoreCorner.CornerRadius = UDim.new(0, 6)
RestoreCorner.Parent = RestoreButton

RestoreButton.MouseButton1Click:Connect(function()
    RestoreOriginalAnimations()
end)

-- Hacer la ventana arrastrable
local Dragging = false
local DragInput, DragStart, StartPos

local function Update(input)
    local delta = input.Position - DragStart
    MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        DragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        Update(input)
    end
end)

-- Tecla para toggle (F9)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F9 then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Manejar respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(2) -- Esperar a que el personaje cargue completamente
    
    Character = character
    Humanoid = character:WaitForChild("Humanoid")
    Animate = character:WaitForChild("Animate")
    
    -- Volver a guardar animaciones originales
    OriginalAnimations = {
        Idle1 = Animate.idle.Animation1.AnimationId,
        Idle2 = Animate.idle.Animation2.AnimationId,
        Walk = Animate.walk.WalkAnim.AnimationId,
        Run = Animate.run.RunAnim.AnimationId,
        Jump = Animate.jump.JumpAnim.AnimationId,
        Climb = Animate.climb.ClimbAnim.AnimationId,
        Fall = Animate.fall.FallAnim.AnimationId
    }
end)

print("🎭 ANIMATION HUB CARGADO!")
print("🎮 Presiona F9 para mostrar/ocultar")
print("📦 Paquetes disponibles: " .. tostring(#AnimationPackages))
