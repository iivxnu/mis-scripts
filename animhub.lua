-- Services básicos
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Esperar a que el juego cargue
repeat task.wait() until game:IsLoaded() and Players.LocalPlayer.Character

-- Cargar la librería UI
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/iivxnu/mis-scripts/refs/heads/main/UILibrary.lua'))()

-- Crear ventana principal
local Window = OrionLib:MakeWindow({
    Name = "Eazvy Hub | Animations & Emotes",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "EazvyHub"
})

-- Configuración básica
getgenv().Settings = {
    EmoteSpeed = 1,
    AnimationSpeed = 1,
    LastEmote = "",
    SelectedAnimation = ""
}

-- Función para reproducir emotes
local function PlayEmote(emoteId)
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. emoteId
    
    local humanoid = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local loadAnim = humanoid:LoadAnimation(animation)
        loadAnim:Play()
        loadAnim:AdjustSpeed(Settings.EmoteSpeed)
    end
end

-- Función para detener animaciones
local function StopAllAnimations()
    local humanoid = Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
    end
end
