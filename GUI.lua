local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

repeat 
    task.wait() 
until game:IsLoaded() and LocalPlayer

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/iivxnu/mis-scripts/refs/heads/main/UILibrary.lua"))()

local AnimationLibrary = {
    ["Stylish"] = {Idle = 616136790, Walk = 616146177, Run = 616140816, Jump = 616139451, Fall = 616134815},
    ["Zombie"] = {Idle = 616158929, Walk = 616168032, Run = 616163682, Jump = 616161997, Fall = 616157476},
    ["Robot"] = {Idle = 616088211, Walk = 616095330, Run = 616091570, Jump = 616090535, Fall = 616087089}
}

local function ApplyAnimations(animationData)
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
    
    local animateScript = character:FindFirstChild("Animate")
    if animateScript then
        if animationData.Idle and animateScript.idle then
            animateScript.idle.Animation1.AnimationId = "http://www.roblox.com/asset/?id=" .. animationData.Idle
        end
        if animationData.Walk and animateScript.walk then
            animateScript.walk:FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=" .. animationData.Walk
        end
        if animationData.Run and animateScript.run then
            animateScript.run:FindFirstChildOfClass("Animation").AnimationId = "http://www.roblox.com/asset/?id=" .. animationData.Run
        end
    end
end

local Window = OrionLib:MakeWindow({
    Name = "Animations Changer",
    HidePremium = false,
    SaveConfig = false,
    IntroEnabled = true,
    IntroText = "Simple Animation System"
})

local MainTab = Window:MakeTab({Name = "Animaciones", Icon = "rbxassetid://10723427954"})

MainTab:AddSection({Name = "Paquetes de Animaciones"})

MainTab:AddDropdown({
    Name = "Seleccionar Animación",
    Default = "",
    Options = {"Stylish", "Zombie", "Robot"},
    Callback = function(selected)
        if selected ~= "" and AnimationLibrary[selected] then
            ApplyAnimations(AnimationLibrary[selected])
            OrionLib:MakeNotification({
                Name = "Animación Aplicada",
                Content = selected .. " aplicado",
                Image = "rbxassetid://10723427954",
                Time = 3
            })
        end
    end
})

MainTab:AddButton({
    Name = "Resetear Animaciones",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Reset",
            Content = "Animaciones reseteadas",
            Image = "rbxassetid://10723427954",
            Time = 3
        })
    end
})

OrionLib:MakeNotification({
    Name = "Sistema Cargado",
    Content = "UI funcionando correctamente",
    Image = "rbxassetid://10723427954",
    Time = 5
})

print("Animations Changer - Versión Simple Cargada!")
