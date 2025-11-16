local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

-- Configuración principal de OrionLib con tema Negro/Rosa
local OrionLib = {
    Elements = {},
    ThemeObjects = {},
    Connections = {},
    Flags = {},
    Themes = {
        BlackPink = {
            Main = Color3.fromRGB(20, 20, 20),        -- Negro principal
            Second = Color3.fromRGB(35, 35, 35),      -- Gris oscuro
            Stroke = Color3.fromRGB(60, 60, 60),      -- Gris medio para bordes
            Divider = Color3.fromRGB(80, 80, 80),     -- Gris claro para separadores
            Text = Color3.fromRGB(240, 240, 240),     -- Texto blanco
            TextDark = Color3.fromRGB(180, 180, 180), -- Texto gris claro
            Accent = Color3.fromRGB(255, 105, 180)    -- Rosa fuerte para detalles
        }
    },
    SelectedTheme = "BlackPink",
    Folder = nil,
    SaveCfg = false
}

-- Cargar íconos Feather
local Icons = {}
local Success, Response = pcall(function()
    Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/Baconamassado/lucideblox-icons/refs/heads/main/icons.json")).icons
end)

if not Success then
    warn("\nOrion Library - Failed to load Feather Icons. Error code: " .. Response .. "\n")
end 

-- Función para obtener íconos
local function GetIcon(IconName)
    return Icons[IconName]
end

-- Inicializar interfaz
local CoreGui = game:GetService("CoreGui")
local Orion = Instance.new("ScreenGui")
Orion.Name = _G.UIName or "Orion"
Orion.Parent = CoreGui

-- Limpiar interfaces duplicadas
for _, Interface in ipairs(CoreGui:GetChildren()) do
    if Interface.Name == Orion.Name and Interface ~= Orion then
        Interface:Destroy()
    end
end

-- Funciones de utilidad
function OrionLib:IsRunning()
    return Orion.Parent == CoreGui
end

local function AddConnection(Signal, Function)
    if not OrionLib:IsRunning() then return end
    local SignalConnect = Signal:Connect(Function)
    table.insert(OrionLib.Connections, SignalConnect)
    return SignalConnect
end

-- Limpiar conexiones cuando se destruye
task.spawn(function()
    while OrionLib:IsRunning() do
        wait()
    end
    for _, Connection in pairs(OrionLib.Connections) do
        Connection:Disconnect()
    end
end)

-- Sistema de arrastre
local function MakeDraggable(DragPoint, Main)
    pcall(function()
        local Dragging, DragInput, MousePos, FramePos = false
        AddConnection(DragPoint.InputBegan, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                MousePos = Input.Position
                FramePos = Main.Position

                Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)
        
        AddConnection(DragPoint.InputChanged, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement then
                DragInput = Input
            end
        end)
        
        AddConnection(UserInputService.InputChanged, function(Input)
            if Input == DragInput and Dragging then
                local Delta = Input.Position - MousePos
                Main.Position = UDim2.new(
                    FramePos.X.Scale, FramePos.X.Offset + Delta.X,
                    FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y
                )
            end
        end)
    end)
end

-- Funciones de creación de elementos
function tween(Instance, Properties, Duration, ...)
    local tweenInfo = TweenInfo.new(Duration, ...)
    local tween = TweenService:Create(Instance, tweenInfo, Properties)
    tween:Play()
    return tween
end

function create(_Instance, Properties, Children)
    local Object = Instance.new(_Instance)
    for Index, Property in pairs(Properties or {}) do
        Object[Index] = Property
    end
    for _, Child in pairs(Children or {}) do
        Child.Parent = Object
    end
    return Object
end

local function Create(Name, Properties, Children)
    local Object = Instance.new(Name)
    for i, v in pairs(Properties or {}) do
        Object[i] = v
    end
    for i, v in pairs(Children or {}) do
        v.Parent = Object
    end
    return Object
end

-- Sistema de elementos
local function CreateElement(ElementName, ElementFunction)
    OrionLib.Elements[ElementName] = function(...)
        return ElementFunction(...)
    end
end

local function MakeElement(ElementName, ...)
    return OrionLib.Elements[ElementName](...)
end

local function SetProps(Element, Props)
    for Property, Value in pairs(Props) do
        Element[Property] = Value
    end
    return Element
end

local function SetChildren(Element, Children)
    for _, Child in pairs(Children) do
        Child.Parent = Element
    end
    return Element
end

-- Funciones matemáticas
local function Round(Number, Factor)
    local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
    if Result < 0 then Result = Result + Factor end
    return Result
end

-- Sistema de temas
local function ReturnProperty(Object)
    if Object:IsA("Frame") or Object:IsA("TextButton") then
        return "BackgroundColor3"
    elseif Object:IsA("ScrollingFrame") then
        return "ScrollBarImageColor3"
    elseif Object:IsA("UIStroke") then
        return "Color"
    elseif Object:IsA("TextLabel") or Object:IsA("TextBox") then
        return "TextColor3"
    elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
        return "ImageColor3"
    end
end

local function AddThemeObject(Object, Type)
    if not OrionLib.ThemeObjects[Type] then
        OrionLib.ThemeObjects[Type] = {}
    end
    table.insert(OrionLib.ThemeObjects[Type], Object)
    Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Type]
    return Object
end

local function SetTheme()
    for Name, Type in pairs(OrionLib.ThemeObjects) do
        for _, Object in pairs(Type) do
            Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Name]
        end
    end
end

-- Sistema de configuración
local function PackColor(Color)
    return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end

local function UnpackColor(Color)
    return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
    local Data = HttpService:JSONDecode(Config)
    for a, b in pairs(Data) do
        if OrionLib.Flags[a] then
            spawn(function()
                if OrionLib.Flags[a].Type == "Colorpicker" then
                    OrionLib.Flags[a]:Set(UnpackColor(b))
                else
                    OrionLib.Flags[a]:Set(b)
                end
            end)
        else
            warn("Orion Library Config Loader - Could not find ", a, b)
        end
    end
end

local function SaveCfg(Name)
    if true then return end -- Deshabilitado temporalmente
    local Data = {}
    for i, v in pairs(OrionLib.Flags) do
        if v.Save then
            if v.Type == "Colorpicker" then
                Data[i] = PackColor(v.Value)
            else
                Data[i] = v.Value
            end
        end
    end
    writefile(OrionLib.Folder .. "/" .. Name .. ".txt", HttpService:JSONEncode(Data))
end

-- Definición de elementos básicos
CreateElement("Corner", function(Scale, Offset)
    return Create("UICorner", {
        CornerRadius = UDim.new(Scale or 0, Offset or 10)
    })
end)

CreateElement("Stroke", function(Color, Thickness)
    return Create("UIStroke", {
        Color = Color or OrionLib.Themes[OrionLib.SelectedTheme].Stroke,
        Thickness = Thickness or 1
    })
end)

CreateElement("List", function(Scale, Offset)
    return Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(Scale or 0, Offset or 0)
    })
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
    return Create("UIPadding", {
        PaddingBottom = UDim.new(0, Bottom or 4),
        PaddingLeft = UDim.new(0, Left or 4),
        PaddingRight = UDim.new(0, Right or 4),
        PaddingTop = UDim.new(0, Top or 4)
    })
end)

CreateElement("TFrame", function()
    return Create("Frame", {BackgroundTransparency = 1})
end)

CreateElement("Frame", function(Color)
    return Create("Frame", {
        BackgroundColor3 = Color or OrionLib.Themes[OrionLib.SelectedTheme].Main,
        BorderSizePixel = 0
    })
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
    return Create("Frame", {
        BackgroundColor3 = Color or OrionLib.Themes[OrionLib.SelectedTheme].Main,
        BorderSizePixel = 0
    }, {
        Create("UICorner", {CornerRadius = UDim.new(Scale, Offset)})
    })
end)

CreateElement("Button", function()
    return Create("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
end)

CreateElement("ScrollFrame", function(Color, Width)
    return Create("ScrollingFrame", {
        BackgroundTransparency = 1,
        MidImage = "rbxassetid://7445543667",
        BottomImage = "rbxassetid://7445543667",
        TopImage = "rbxassetid://7445543667",
        ScrollBarImageColor3 = Color or OrionLib.Themes[OrionLib.SelectedTheme].Accent,
        BorderSizePixel = 0,
        ScrollBarThickness = Width or 4,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
end)

CreateElement("Image", function(ImageID)
    local ImageNew = Create("ImageLabel", {
        Image = ImageID,
        BackgroundTransparency = 1
    })
    
    local Icon = GetIcon(ImageID)
    if Icon then
        ImageNew.Image = Icon
    end
    
    return ImageNew
end)

CreateElement("ImageButton", function(ImageID)
    return Create("ImageButton", {
        Image = ImageID,
        BackgroundTransparency = 1
    })
end)

CreateElement("Label", function(Text, TextSize, Transparency)
    return Create("TextLabel", {
        Text = Text or "",
        TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Text,
        TextTransparency = Transparency or 0,
        TextSize = TextSize or 15,
        Font = Enum.Font.Gotham,
        RichText = true,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
end)

-- Sistema de notificaciones
local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
    SetProps(MakeElement("List"), {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 5)
    })
}), {
    Position = UDim2.new(1, -25, 1, -25),
    Size = UDim2.new(0, 300, 1, -25),
    AnchorPoint = Vector2.new(1, 1),
    Parent = Orion
})

function OrionLib:MakeNotification(NotificationConfig)
    spawn(function()
        NotificationConfig.Name = NotificationConfig.Name or "Notification"
        NotificationConfig.Content = NotificationConfig.Content or "Test"
        NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4384403532"
        NotificationConfig.Time = NotificationConfig.Time or 15

        local NotificationParent = SetProps(MakeElement("TFrame"), {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Parent = NotificationHolder
        })

        local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", OrionLib.Themes[OrionLib.SelectedTheme].Main, 0, 10), {
            Parent = NotificationParent, 
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(1, -55, 0, 0),
            BackgroundTransparency = 0,
            BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Main,
            AutomaticSize = Enum.AutomaticSize.Y
        }), {
            MakeElement("Stroke", OrionLib.Themes[OrionLib.SelectedTheme].Accent, 1.2), -- Borde rosa
            MakeElement("Padding", 12, 12, 12, 12),
            SetProps(MakeElement("Image", NotificationConfig.Image), {
                Size = UDim2.new(0, 20, 0, 20),
                ImageColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent, -- Icono rosa
                Name = "Icon"
            }),
            SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
                Size = UDim2.new(1, -30, 0, 20),
                Position = UDim2.new(0, 30, 0, 0),
                Font = Enum.Font.GothamBold,
                Name = "Title"
            }),
            SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 25),
                Font = Enum.Font.GothamSemibold,
                Name = "Content",
                AutomaticSize = Enum.AutomaticSize.Y,
                TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].TextDark,
                TextWrapped = true
            })
        })

        TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()

        wait(NotificationConfig.Time - 0.88)
        TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
        TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
        wait(0.3)
        TweenService:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
        TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
        TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
        wait(0.05)

        NotificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0), 'In', 'Quint', 0.8, true)
        wait(1.35)
        NotificationFrame:Destroy()
    end)
end

-- Función para crear bordes rosas animados
local function CreatePinkBorder(Parent)
    local AnimatedBorder = Instance.new("UIStroke", Parent)
    AnimatedBorder.Color = OrionLib.Themes[OrionLib.SelectedTheme].Accent
    AnimatedBorder.Thickness = 2
    
    -- Gradiente animado para el borde
    local BorderGradient = Instance.new("UIGradient", AnimatedBorder)
    BorderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 105, 180)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 20, 147)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(199, 21, 133))
    })
    
    -- Animación del gradiente
    game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        BorderGradient.Offset += Vector2.new(deltaTime * 0.5, 0)
        if BorderGradient.Offset.X >= 1 then
            BorderGradient.Offset = Vector2.new(0, 0)
        end
    end)
    
    return AnimatedBorder
end

-- Función principal para crear ventanas
function OrionLib:MakeWindow(WindowConfig)
    local FirstTab = true
    local Minimized = false
    local UIHidden = false

    -- Configuración por defecto
    WindowConfig = WindowConfig or {}
    WindowConfig.Name = WindowConfig.Name or "Orion Library"
    WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
    WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
    WindowConfig.HidePremium = WindowConfig.HidePremium or false
    if WindowConfig.IntroEnabled == nil then
        WindowConfig.IntroEnabled = true
    end
    WindowConfig.IntroText = WindowConfig.IntroText or "Black & Pink Theme"
    WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
    WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
    WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
    WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
    
    OrionLib.Folder = WindowConfig.ConfigFolder
    OrionLib.SaveCfg = WindowConfig.SaveConfig

    -- Crear carpeta de configuración si es necesario
    if WindowConfig.SaveConfig and not isfolder(WindowConfig.ConfigFolder) then
        makefolder(WindowConfig.ConfigFolder)
    end

    local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", OrionLib.Themes[OrionLib.SelectedTheme].Accent, 4), {
        Size = UDim2.new(1, 0, 1, -50)
    }), {
        MakeElement("List"),
        MakeElement("Padding", 8, 0, 0, 8)
    }), "Divider")
    
    OrionLib.Internal = {}
    OrionLib.Internal.TabHolder = TabHolder

    AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
    end)

    local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1
    }), {
        AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
            Position = UDim2.new(0, 9, 0, 6),
            Size = UDim2.new(0, 18, 0, 18)
        }), "Text")
    })
    
    local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1
    }), {
        AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
            Position = UDim2.new(0, 9, 0, 6),
            Size = UDim2.new(0, 18, 0, 18),
            Name = "Ico"
        }), "Text")
    })

    local DragPoint = SetProps(MakeElement("TFrame"), {
        Size = UDim2.new(1, 0, 0, 50)
    })

    local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", OrionLib.Themes[OrionLib.SelectedTheme].Second, 0, 10), {
        Size = UDim2.new(0, 150, 1, -50),
        Position = UDim2.new(0, 0, 0, 50)
    }), {
        AddThemeObject(SetProps(MakeElement("Frame"), {
            Size = UDim2.new(1, 0, 0, 10),
            Position = UDim2.new(0, 0, 0, 0)
        }), "Second"), 
        AddThemeObject(SetProps(MakeElement("Frame"), {
            Size = UDim2.new(0, 10, 1, 0),
            Position = UDim2.new(1, -10, 0, 0)
        }), "Second"), 
        AddThemeObject(SetProps(MakeElement("Frame"), {
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(1, -1, 0, 0)
        }), "Stroke"), 
        TabHolder,
        SetChildren(SetProps(MakeElement("TFrame"), {
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0, 0, 1, -50)
        }), {
            AddThemeObject(SetProps(MakeElement("Frame"), {
                Size = UDim2.new(1, 0, 0, 1)
            }), "Stroke"), 
            AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(0, 10, 0.5, 0)
            }), {
                SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=".. LocalPlayer.UserId .."&width=420&height=420&format=png"), {
                    Size = UDim2.new(1, 0, 1, 0)
                }),
                AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {
                    Size = UDim2.new(1, 0, 1, 0),
                }), "Second"),
                MakeElement("Corner", 1)
            }), "Divider"),
            SetChildren(SetProps(MakeElement("TFrame"), {
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(0, 10, 0.5, 0)
            }), {
                AddThemeObject(MakeElement("Stroke"), "Stroke"),
                MakeElement("Corner", 1)
            }),
            AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, WindowConfig.HidePremium and 14 or 13), {
                Size = UDim2.new(1, -60, 0, 13),
                Position = WindowConfig.HidePremium and UDim2.new(0, 50, 0, 19) or UDim2.new(0, 50, 0, 12),
                Font = Enum.Font.GothamBold,
                ClipsDescendants = true
            }), "Text"),
            AddThemeObject(SetProps(MakeElement("Label", "", 12), {
                Size = UDim2.new(1, -60, 0, 12),
                Position = UDim2.new(0, 50, 1, -25),
                Visible = not WindowConfig.HidePremium
            }), "TextDark")
        }),
    }), "Second")

    local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
        Size = UDim2.new(1, -30, 2, 0),
        Position = UDim2.new(0, 25, 0, -24),
        Font = Enum.Font.GothamBlack,
        TextSize = 20
    }), "Text")

    local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1)
    }), "Accent") -- Línea rosa

    local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", OrionLib.Themes[OrionLib.SelectedTheme].Main, 0, 10), {
        Parent = Orion,
        Position = UDim2.new(0.5, -307, 0.5, -172),
        Size = UDim2.new(0, 550, 0, 400),
        ClipsDescendants = true
    }), {
        SetChildren(SetProps(MakeElement("TFrame"), {
            Size = UDim2.new(1, 0, 0, 50),
            Name = "TopBar"
        }), {
            WindowName,
            WindowTopBarLine,
            AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", OrionLib.Themes[OrionLib.SelectedTheme].Second, 0, 7), {
                Size = UDim2.new(0, 70, 0, 30),
                Position = UDim2.new(1, -90, 0, 10)
            }), {
                AddThemeObject(MakeElement("Stroke", OrionLib.Themes[OrionLib.SelectedTheme].Accent, 1), "Stroke"), -- Borde rosa
                AddThemeObject(SetProps(MakeElement("Frame"), {
                    Size = UDim2.new(0, 1, 1, 0),
                    Position = UDim2.new(0.5, 0, 0, 0)
                }), "Accent"), -- Separador rosa
                CloseBtn,
                MinimizeBtn,
            }), "Second"), 
        }),
        DragPoint,
        WindowStuff
    }), "Main")

    -- Aplicar borde rosa animado a la ventana principal
    CreatePinkBorder(MainWindow)

    -- Sombra de la ventana
    local Shadow = Instance.new("Frame", MainWindow)
    Shadow.ZIndex = 0
    Shadow.BorderSizePixel = 0
    Shadow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Size = UDim2.new(1, 35, 1, 35)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Name = "Shadow"

    local ShadowImage = Instance.new("ImageLabel", Shadow)
    ShadowImage.ZIndex = 0
    ShadowImage.BorderSizePixel = 0
    ShadowImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ShadowImage.ImageColor3 = Color3.fromRGB(10, 10, 10)
    ShadowImage.ImageTransparency = 0.7
    ShadowImage.AnchorPoint = Vector2.new(0.5, 0.5)
    ShadowImage.Image = "rbxassetid://5587865193"
    ShadowImage.Size = UDim2.new(1.6, 0, 1.3, 0)
    ShadowImage.Name = "Image"
    ShadowImage.BackgroundTransparency = 1
    ShadowImage.Position = UDim2.new(0.5, 0, 0.5, 0)

    if WindowConfig.ShowIcon then
        WindowName.Position = UDim2.new(0, 50, 0, -24)
        local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 25, 0, 15),
            ImageColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent -- Icono rosa
        })
        WindowIcon.Parent = MainWindow.TopBar
    end 

    MakeDraggable(DragPoint, MainWindow)

    AddConnection(CloseBtn.MouseButton1Up, function()
        MainWindow.Visible = false
        UIHidden = true
        OrionLib:MakeNotification({
            Name = "Interface Hidden",
            Content = 'Press "Q" to reopen the interface',
            Time = 10,
            Image = "rbxassetid://13321848320"
        })
        WindowConfig.CloseCallback()
    end)

    AddConnection(UserInputService.InputBegan, function(Input)
        if Input.KeyCode == Enum.KeyCode.Q and UIHidden then
            MainWindow.Visible = true
        end
    end)

    AddConnection(MinimizeBtn.MouseButton1Up, function()
        if Minimized then
            TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 550, 0, 400)}):Play()
            MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
        else
            MinimizeBtn.Ico.Image = "rbxassetid://7072720870"
            TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50)}):Play()
            wait(0.1)
            WindowStuff.Visible = false 
        end
        Minimized = not Minimized    
    end)

    -- Secuencia de carga intro
    local function LoadSequence()
        MainWindow.Visible = false
        local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
            Parent = Orion,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.4, 0),
            Size = UDim2.new(0, 28, 0, 28),
            ImageColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent, -- Logo rosa
            ImageTransparency = 1
        })

        local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 14), {
            Parent = Orion,
            Size = UDim2.new(1, 0, 1, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 19, 0.5, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
            Font = Enum.Font.GothamBold,
            TextTransparency = 1
        })

        TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
        wait(0.8)
        TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X/2), 0.5, 0)}):Play()
        wait(0.3)
        TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        wait(2)
        TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
        MainWindow.Visible = true
        LoadSequenceLogo:Destroy()
        LoadSequenceText:Destroy()
    end 
    
    if WindowConfig.IntroEnabled then
        LoadSequence()
    end 
    
    local TabFunction = {}
    
    function TabFunction:MakeTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""
        TabConfig.PremiumOnly = TabConfig.PremiumOnly or false
        
        local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
            Size = UDim2.new(1, 0, 0, 30),
            Parent = TabHolder
        }), {
            AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
                AnchorPoint = Vector2.new(0, 0.5),
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 10, 0.5, 0),
                ImageTransparency = 0.4,
                Name = "Ico",
                ImageColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent -- Icono rosa
            }), "Text"),
            AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
                Size = UDim2.new(1, -35, 1, 0),
                Position = UDim2.new(0, 35, 0, 0),
                Font = Enum.Font.GothamSemibold,
                TextTransparency = 0.4,
                Name = "Title"
            }), "Text")
        })

        if GetIcon(TabConfig.Icon) ~= nil then
            TabFrame.Ico.Image = GetIcon(TabConfig.Icon)
        end 
        
        local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", OrionLib.Themes[OrionLib.SelectedTheme].Accent, 5), {
            Size = UDim2.new(1, -150, 1, -50),
            Position = UDim2.new(0, 150, 0, 50),
            Parent = MainWindow,
            Visible = false,
            Name = "ItemContainer" .. TabConfig.Name,
            ScrollBarThickness = 5
        }), {
            MakeElement("List", 0, 6),
            MakeElement("Padding", 15, 10, 10, 15)
        }), "Second")

        AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
        end)

        if FirstTab then
            FirstTab = false
            TabFrame.Ico.ImageTransparency = 0
            TabFrame.Title.TextTransparency = 0
            TabFrame.Title.Font = Enum.Font.GothamBlack
            Container.Visible = true
        end    
        
        AddConnection(TabFrame.MouseButton1Click, function()
            for _, Tab in next, TabHolder:GetChildren() do
                if Tab:IsA("TextButton") then
                    Tab.Title.Font = Enum.Font.GothamSemibold
                    TweenService:Create(Tab.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.4}):Play()
                    TweenService:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
                end    
            end
            for _, ItemContainer in next, MainWindow:GetChildren() do
                if string.find(ItemContainer.Name, "ItemContainer") then
                    ItemContainer.Visible = false
                end    
            end  
            TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
            TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
            TabFrame.Title.Font = Enum.Font.GothamBlack
            Container.Visible = true   
        end)

        local function GetElements(ItemParent)
            local ElementFunction = {}
            
            function ElementFunction:AddLabel(Text)
                local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", OrionLib.Themes[OrionLib.SelectedTheme].Second, 0, 5), {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 0.7,
                    Parent = ItemParent
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
                        Size = UDim2.new(1, -12, 1, 0),
                        Position = UDim2.new(0, 12, 0, 0),
                        Font = Enum.Font.GothamBold,
                        Name = "Content"
                    }), "Text"),
                    AddThemeObject(MakeElement("Stroke", OrionLib.Themes[OrionLib.SelectedTheme].Accent, 1), "Stroke") -- Borde rosa
                }), "Second")

                local LabelFunction = {}
                function LabelFunction:Set(ToChange)
                    LabelFrame.Content.Text = ToChange
                end
                return LabelFunction
            end

            function ElementFunction:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Name = ButtonConfig.Name or "Button"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end

                local Button = {}

                local Click = SetProps(MakeElement("Button"), {
                    Size = UDim2.new(1, 0, 1, 0)
                })

                local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", OrionLib.Themes[OrionLib.SelectedTheme].Second, 0, 5), {
                    Size = UDim2.new(1, 0, 0, 33),
                    Parent = ItemParent
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {
                        Size = UDim2.new(1, -12, 1, 0),
                        Position = UDim2.new(0, 12, 0, 0),
                        Font = Enum.Font.GothamBold,
                        Name = "Content"
                    }), "Text"),
                    AddThemeObject(MakeElement("Stroke", OrionLib.Themes[OrionLib.SelectedTheme].Accent, 1), "Stroke"), -- Borde rosa
                    Click
                }), "Second")

                -- Efectos hover en rosa
                AddConnection(Click.MouseEnter, function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    }):Play()
                    TweenService:Create(ButtonFrame.UIStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        Color = OrionLib.Themes[OrionLib.SelectedTheme].Accent
                    }):Play()
                end)

                AddConnection(Click.MouseLeave, function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second
                    }):Play()
                    TweenService:Create(ButtonFrame.UIStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        Color = OrionLib.Themes[OrionLib.SelectedTheme].Accent
                    }):Play()
                end)

                AddConnection(Click.MouseButton1Click, function()
                    -- Efecto de click rosa
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    }):Play()
                    wait(0.1)
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    }):Play()
                    
                    ButtonConfig.Callback()
                end)

                function Button:Set(ButtonText)
                    ButtonFrame.Content.Text = ButtonText
                end 

                return Button
            end    

            function ElementFunction:AddToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                ToggleConfig.Name = ToggleConfig.Name or "Toggle"
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end
                ToggleConfig.Color = ToggleConfig.Color or OrionLib.Themes[OrionLib.SelectedTheme].Accent -- Rosa por defecto
                ToggleConfig.Flag = ToggleConfig.Flag or nil

                local Toggle = {Value = ToggleConfig.Default}

                local Click = SetProps(MakeElement("Button"), {
                    Size = UDim2.new(1, 0, 1, 0),
                })

                local ToggleBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", ToggleConfig.Color, 0, 4), {
                    Size = UDim2.new(0, 24, 0, 24),
                    Position = UDim2.new(1, -24, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                }), {
                    SetProps(MakeElement("Stroke"), {
                        Color = ToggleConfig.Color,
                        Name = "Stroke",
                        Transparency = 0.5
                    }),
                    SetProps(MakeElement("Image", "rbxassetid://3944680095"), {
                        Size = UDim2.new(0, 20, 0, 20),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        ImageColor3 = Color3.fromRGB(255, 255, 255),
                        Name = "Ico"
                    }),
                }), "Main")
                
                local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", OrionLib.Themes[OrionLib.SelectedTheme].Second, 0, 5), {
                    Size = UDim2.new(1, 0, 0, 38),
                    Parent = ItemParent
                }), {
                    AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {
                        Size = UDim2.new(1, -12, 1, 0),
                        Position = UDim2.new(0, 12, 0, 0),
                        Font = Enum.Font.GothamBold,
                        Name = "Content"
                    }), "Text"),
                    AddThemeObject(MakeElement("Stroke", OrionLib.Themes[OrionLib.SelectedTheme].Accent, 1), "Stroke"), -- Borde rosa
                    ToggleBox,
                    Click
                }), "Second")

                function Toggle:Set(Value)
                    Toggle.Value = Value
                    TweenService:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Toggle.Value and ToggleConfig.Color or OrionLib.Themes[OrionLib.SelectedTheme].Main}):Play()
                    TweenService:Create(ToggleBox.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Toggle.Value and ToggleConfig.Color or OrionLib.Themes[OrionLib.SelectedTheme].Stroke}):Play()
                    TweenService:Create(ToggleBox.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = Toggle.Value and 0 or 1, Size = Toggle.Value and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 8, 0, 8)}):Play()
                    ToggleConfig.Callback(Toggle.Value)
                end    

                Toggle:Set(Toggle.Value)

                AddConnection(Click.MouseEnter, function()
                    TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
                end)

                AddConnection(Click.MouseLeave, function()
                    TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
                end)

                AddConnection(Click.MouseButton1Up, function()
                    Toggle:Set(not Toggle.Value)
                end)

                if ToggleConfig.Flag then
                    OrionLib.Flags[ToggleConfig.Flag] = Toggle
                end 
                return Toggle
            end  

            return ElementFunction   
        end 

        local ElementFunction = {}

        function ElementFunction:AddSection(SectionConfig)
            SectionConfig.Name = SectionConfig.Name or "Section"

            local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
                Size = UDim2.new(1, 0, 0, 26),
                Parent = Container
            }), {
                AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {
                    Size = UDim2.new(1, -12, 0, 16),
                    Position = UDim2.new(0, 0, 0, 3),
                    Font = Enum.Font.GothamSemibold,
                    TextColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Accent -- Título de sección rosa
                }), "Text"),
                SetChildren(SetProps(MakeElement("TFrame"), {
                    AnchorPoint = Vector2.new(0, 0),
                    Size = UDim2.new(1, 0, 1, -24),
                    Position = UDim2.new(0, 0, 0, 23),
                    Name = "Holder"
                }), {
                    MakeElement("List", 0, 6)
                }),
            })

            AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
                SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
                SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
            end)

            local SectionFunction = {}
            for i, v in next, GetElements(SectionFrame.Holder) do
                SectionFunction[i] = v 
            end
            return SectionFunction
        end 

        for i, v in next, GetElements(Container) do
            ElementFunction[i] = v 
        end

        return ElementFunction   
    end  

    return TabFunction
end

-- Función de inicialización
function OrionLib:Init(Window)
    if OrionLib.SaveCfg then
        pcall(function()
            if isfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt") then
                LoadCfg(readfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt"))
                OrionLib:MakeNotification({
                    Name = "Configuration",
                    Content = "Auto-loaded configuration for the game " .. game.GameId .. ".",
                    Time = 5
                })
            end
        end)
    end
end

-- Función para destruir la interfaz
function OrionLib:Destroy()
    Orion:Destroy()
end

return OrionLib
