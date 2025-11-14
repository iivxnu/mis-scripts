--[[ 
    Source script taken from: https://github.com/Roblox/creator-docs/blob/main/content/en-us/characters/emotes.md

    scriptblox: https://scriptblox.com/script/Universal-Script-7yd7-I-Emote-Script-48024
]]


if _G.EmotesGUIRunning then
    getgenv().Notify({
        Title = '7yd7 | Emote',
        Content = '⚠️ It works It actually works',
        Duration = 5
    })
    return
end
_G.EmotesGUIRunning = true

loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Menu-7yd7/refs/heads/Script/GUIS/Off-site/Notify.lua"))()

getgenv().Notify({
    Title = '7yd7 | Emote',
    Content = '⚠️ Script loading...',
    Duration = 5
})

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local emoteClickConnections = {}
local isMonitoringClicks = false
local currentTimer = nil

local currentMode = "emote"
local animationsData = {}
local originalAnimationsData = {}
local filteredAnimations = {}
local favoriteAnimations = {}
local favoriteAnimationsFileName = "FavoriteAnimations.json"
local emoteSearchTerm = ""
local animationSearchTerm = ""

getgenv().lastPlayedAnimation = getgenv().lastPlayedAnimation or nil
getgenv().autoReloadEnabled = getgenv().autoReloadEnabled or false

RunService.Heartbeat:Connect(function()
    if player.Character and player.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 then
        local errorMsg = CoreGui.RobloxGui.EmotesMenu.Children.ErrorMessage
        if errorMsg.Visible then
            errorMsg.ErrorText.Text = "Only r15 does not work r6"
        end
    end
end)

function ErrorMessage(text, duration)

    if currentTimer then
        task.cancel(currentTimer)
        currentTimer = nil
    end
    
    local errorMessage = CoreGui.RobloxGui.EmotesMenu.Children.ErrorMessage
    local errorText = errorMessage.ErrorText
    
    errorText.Text = text
    
    errorMessage.Visible = true
    
    currentTimer = task.delay(duration, function()
        errorMessage.Visible = false
        currentTimer = nil
    end)
end

local function stopEmotes()
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end
end

local emotesData = {}
local currentPage = 1
local itemsPerPage = 8
local totalPages = 1
local filteredEmotes = {}
local isLoading = false
local originalEmotesData = {}
local totalEmotesLoaded = 0
local scannedEmotes = {}
local favoriteEmotes = {}
local favoriteEnabled = false
local favoriteFileName = "FavoriteEmotes.json"
local emotesWalkEnabled = false
local currentEmoteTrack = nil
local currentCharacter = nil
local isGUICreated = false
local speedEmoteEnabled = false
local speedEmoteConfigFile = "SpeedEmoteConfig.json"

local Under, UIListLayout, _1left, _9right, _4pages, _3TextLabel, _2Routenumber, Top, EmoteWalkButton, UICorner1,
    UIListLayout_2, UICorner, Search, Favorite, UICorner2, UICorner_2, SpeedEmote, UICorner_4, SpeedBox, UICorner_5, Changepage,
    Reload, UICorner_6

local defaultButtonImage = "rbxassetid://71408678974152"
local enabledButtonImage = "rbxassetid://106798555684020"

local favoriteIconId = "rbxassetid://97307461910825" 
local notFavoriteIconId = "rbxassetid://124025954365505"

local function getCharacterAndHumanoid()
    local character = player.Character
    if not character then
        return nil, nil
    end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then
        return nil, nil
    end
    return character, humanoid
end

local function checkEmotesMenuExists()
    local coreGui = game:GetService("CoreGui")
    local robloxGui = coreGui:FindFirstChild("RobloxGui")
    if not robloxGui then
        return false
    end

    local emotesMenu = robloxGui:FindFirstChild("EmotesMenu")
    if not emotesMenu then
        return false
    end

    local children = emotesMenu:FindFirstChild("Children")
    if not children then
        return false
    end

    local main = children:FindFirstChild("Main")
    if not main then
        return false
    end

    local emotesWheel = main:FindFirstChild("EmotesWheel")
    if not emotesWheel then
        return false
    end

    return true, emotesWheel
end

local function getBackgroundOverlay()
    local success, result = pcall(function()
        return game:GetService("CoreGui").RobloxGui.EmotesMenu.Children.Main.EmotesWheel.Back.Background
                   .BackgroundCircleOverlay
    end)
    if success then
        return result
    end
    return nil
end

local function updateGUIColors()
    local backgroundOverlay = getBackgroundOverlay()
    if not backgroundOverlay then
        return
    end

    local bgColor = backgroundOverlay.BackgroundColor3
    local bgTransparency = backgroundOverlay.BackgroundTransparency

    if _1left then
        _1left.ImageColor3 = bgColor
        _1left.ImageTransparency = bgTransparency
    end

    if _9right then
        _9right.ImageColor3 = bgColor
        _9right.ImageTransparency = bgTransparency
    end

    if _4pages then
        _4pages.TextColor3 = bgColor
        _4pages.TextTransparency = bgTransparency
    end

    if _3TextLabel then
        _3TextLabel.TextColor3 = bgColor
        _3TextLabel.TextTransparency = bgTransparency
    end

    if _2Routenumber then
        _2Routenumber.TextColor3 = bgColor
        _2Routenumber.TextTransparency = bgTransparency
    end

    if Top then
        Top.BackgroundColor3 = bgColor
        Top.BackgroundTransparency = bgTransparency
    end

    if EmoteWalkButton then
        EmoteWalkButton.BackgroundColor3 = bgColor
        EmoteWalkButton.BackgroundTransparency = bgTransparency
    end

    if SpeedEmote then
        SpeedEmote.BackgroundColor3 = bgColor
        SpeedEmote.BackgroundTransparency = bgTransparency
    end

     if Changepage then
        Changepage.BackgroundColor3 = bgColor
        Changepage.BackgroundTransparency = bgTransparency
    end

    if SpeedBox then
        SpeedBox.BackgroundColor3 = bgColor
        SpeedBox.BackgroundTransparency = bgTransparency
    end

    if Favorite then
        Favorite.BackgroundColor3 = bgColor
        Favorite.BackgroundTransparency = bgTransparency
    end

if Reload then
    Reload.BackgroundColor3 = bgColor
    Reload.BackgroundTransparency = bgTransparency
    Reload.Visible = (currentMode == "animation")
end
end

local function urlToId(animationId)
    animationId = string.gsub(animationId, "http://www%.roblox%.com/asset/%?id=", "")
    animationId = string.gsub(animationId, "rbxassetid://", "")
    return animationId
end

local function saveFavorites()
    if writefile then
        local jsonData = HttpService:JSONEncode(favoriteEmotes)
        writefile(favoriteFileName, jsonData)
    end
end

local function saveFavoritesAnimations()
    if writefile then
        local jsonData = HttpService:JSONEncode(favoriteAnimations)
        writefile(favoriteAnimationsFileName, jsonData)
    end
end

local function loadFavorites()
    if readfile and isfile and isfile(favoriteFileName) then
        local success, result = pcall(function()
            local fileContent = readfile(favoriteFileName)
            return HttpService:JSONDecode(fileContent)
        end)
        if success and result then
            favoriteEmotes = result
        end
    end
end

local function loadFavoritesAnimations()
    if readfile and isfile and isfile(favoriteAnimationsFileName) then
        local success, result = pcall(function()
            local fileContent = readfile(favoriteAnimationsFileName)
            return HttpService:JSONDecode(fileContent)
        end)
        if success and result then
            favoriteAnimations = result
        end
    end
end

local function loadSpeedEmoteConfig()
    if readfile and isfile and isfile(speedEmoteConfigFile) then
        local success, result = pcall(function()
            local fileContent = readfile(speedEmoteConfigFile)
            return HttpService:JSONDecode(fileContent)
        end)
        if success and result then
            speedEmoteEnabled = result.Enabled or false
            if SpeedBox then
                SpeedBox.Text = tostring(result.SpeedValue or 1)
                SpeedBox.Visible = speedEmoteEnabled
            end
        end
    end
end

local function extractAssetId(imageUrl)
    local assetId = string.match(imageUrl, "Asset&id=(%d+)")
    return assetId
end

local function getEmoteName(assetId)
    local success, productInfo = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(tonumber(assetId))
    end)
    
    if success and productInfo then
        return productInfo.Name
    else
        return "Emote_" .. tostring(assetId)
    end
end

local function isInFavorites(assetId)
    local favoriteList
    if currentMode == "animation" then
        favoriteList = favoriteAnimations
    else
        favoriteList = favoriteEmotes
    end

    for _, favorite in pairs(favoriteList) do
        if tostring(favorite.id) == tostring(assetId) then
            return true
        end
    end
    return false
end

local function updateAnimationImages(currentPageAnimations)
    local success, frontFrame = pcall(function()
        return game:GetService("CoreGui").RobloxGui.EmotesMenu.Children.Main.EmotesWheel.Front.EmotesButtons
    end)
    
    if not success or not frontFrame then
        return
    end
    
    local buttonIndex = 1
    for _, child in pairs(frontFrame:GetChildren()) do
        if child:IsA("ImageLabel") then
            if buttonIndex <= #currentPageAnimations then
                local animationData = currentPageAnimations[buttonIndex]
                child.Image = "rbxthumb://type=BundleThumbnail&id=" .. animationData.id .. "&w=420&h=420"
                
                local idValue = child:FindFirstChild("AnimationID") or Instance.new("IntValue")
                idValue.Name = "AnimationID"
                idValue.Value = animationData.id
                idValue.Parent = child

                buttonIndex = buttonIndex + 1
            else
                child.Image = ""
                local idValue = child:FindFirstChild("AnimationID")
                if idValue then 
                    idValue:Destroy() 
                end
            end
        end
    end
end


local function updateFavoriteIcon(imageLabel, assetId, isFavorite)
    local favoriteIcon = imageLabel:FindFirstChild("FavoriteIcon")
    
    if not favoriteIcon then
        favoriteIcon = Instance.new("ImageLabel")
        favoriteIcon.Name = "FavoriteIcon"
        favoriteIcon.Size = UDim2.new(0.3, 0, 0.3, 0) 
        favoriteIcon.Position = UDim2.new(0.7, 0, 0, 0)
        favoriteIcon.AnchorPoint = Vector2.new(0, 0)
        favoriteIcon.BackgroundTransparency = 1
        favoriteIcon.ZIndex = imageLabel.ZIndex + 5
        favoriteIcon.ScaleType = Enum.ScaleType.Fit
        favoriteIcon.Parent = imageLabel
    end
    
    if isFavorite then
        favoriteIcon.Image = favoriteIconId
    else
        favoriteIcon.Image = notFavoriteIconId 
    end
end

local function updateAllFavoriteIcons()
    local success, frontFrame = pcall(function()
        return game:GetService("CoreGui").RobloxGui.EmotesMenu.Children.Main.EmotesWheel.Front.EmotesButtons
    end)
    
    if success and frontFrame then
        for _, child in pairs(frontFrame:GetChildren()) do
            if child:IsA("ImageLabel") and child.Image ~= "" then
                local assetId
                if currentMode == "animation" then
                    local idValue = child:FindFirstChild("AnimationID")
                    if idValue then
                        assetId = idValue.Value
                    end
                else
                    assetId = extractAssetId(child.Image)
                end
                
                if assetId then
                    local isFavorite = isInFavorites(assetId)
                    updateFavoriteIcon(child, assetId, isFavorite)
                end
            end
        end
    end
end

local function updateAnimations()
    local character, humanoid = getCharacterAndHumanoid()
    if not character or not humanoid then
        return
    end

    local humanoidDescription = humanoid.HumanoidDescription
    if not humanoidDescription then
        return
    end

    local currentPageAnimations = {}
    local animationTable = {}
    local equippedAnimations = {}

    local favoritesToUse = _G.filteredFavoritesAnimationsForDisplay or favoriteAnimations
    local hasFavorites = #favoritesToUse > 0
    local favoritePagesCount = hasFavorites and math.ceil(#favoritesToUse / itemsPerPage) or 0
    local isInFavoritesPages = currentPage <= favoritePagesCount

    if isInFavoritesPages and hasFavorites then
        local startIndex = (currentPage - 1) * itemsPerPage + 1
        local endIndex = math.min(startIndex + itemsPerPage - 1, #favoritesToUse)

        for i = startIndex, endIndex do
            if favoritesToUse[i] then
                table.insert(currentPageAnimations, {
                    id = tonumber(favoritesToUse[i].id),
                    name = favoritesToUse[i].name
                })
            end
        end
    else
        local normalAnimations = {}
        for _, animation in pairs(filteredAnimations) do
            if not isInFavorites(animation.id) then
                table.insert(normalAnimations, animation)
            end
        end

        local adjustedPage = currentPage - favoritePagesCount
        local startIndex = (adjustedPage - 1) * itemsPerPage + 1
        local endIndex = math.min(startIndex + itemsPerPage - 1, #normalAnimations)

        for i = startIndex, endIndex do
            if normalAnimations[i] then
                table.insert(currentPageAnimations, normalAnimations[i])
            end
        end
    end

    for _, animation in pairs(currentPageAnimations) do
        local animationName = animation.name
        local animationId = animation.id
        animationTable[animationName] = {animationId}
        table.insert(equippedAnimations, animationName)
    end

    humanoidDescription:SetEmotes(animationTable)
    humanoidDescription:SetEquippedEmotes(equippedAnimations)
    
    task.wait(0.1)
    updateAnimationImages(currentPageAnimations)

    task.delay(0.2, function()
        if favoriteEnabled then
            updateAllFavoriteIcons()
        end
    end)
end

local function updateEmotes()
    local character, humanoid = getCharacterAndHumanoid()
    if not character or not humanoid then
        return
    end

    if currentMode == "animation" then
        updateAnimations()
        return
    end

    local humanoidDescription = humanoid.HumanoidDescription
    if not humanoidDescription then
        return
    end

    local currentPageEmotes = {}
    local emoteTable = {}
    local equippedEmotes = {}

    local favoritesToUse = _G.filteredFavoritesForDisplay or favoriteEmotes
    local hasFavorites = #favoritesToUse > 0
    local favoritePagesCount = hasFavorites and math.ceil(#favoritesToUse / itemsPerPage) or 0
    local isInFavoritesPages = currentPage <= favoritePagesCount

    if isInFavoritesPages and hasFavorites then
        local startIndex = (currentPage - 1) * itemsPerPage + 1
        local endIndex = math.min(startIndex + itemsPerPage - 1, #favoritesToUse)

        for i = startIndex, endIndex do
            if favoritesToUse[i] then
                table.insert(currentPageEmotes, {
                    id = tonumber(favoritesToUse[i].id),
                    name = favoritesToUse[i].name
                })
            end
        end
    else
        local normalEmotes = {}
        for _, emote in pairs(filteredEmotes) do
            if not isInFavorites(emote.id) then
                table.insert(normalEmotes, emote)
            end
        end

        local adjustedPage = currentPage - favoritePagesCount
        local startIndex = (adjustedPage - 1) * itemsPerPage + 1
        local endIndex = math.min(startIndex + itemsPerPage - 1, #normalEmotes)

        for i = startIndex, endIndex do
            if normalEmotes[i] then
                table.insert(currentPageEmotes, normalEmotes[i])
            end
        end
    end

    for _, emote in pairs(currentPageEmotes) do
        local emoteName = emote.name
        local emoteId = emote.id
        emoteTable[emoteName] = {emoteId}
        table.insert(equippedEmotes, emoteName)
    end

    humanoidDescription:SetEmotes(emoteTable)
    humanoidDescription:SetEquippedEmotes(equippedEmotes)
    
    task.delay(0.2, function()
        if favoriteEnabled then
            updateAllFavoriteIcons()
        end
    end)
end

local function calculateTotalPages()
      if currentMode == "animation" then
        local favoritesToUse = _G.filteredFavoritesAnimationsForDisplay or favoriteAnimations
        local hasFavorites = #favoritesToUse > 0
        local normalAnimationsCount = 0

        for _, animation in pairs(filteredAnimations) do
            if not isInFavorites(animation.id) then
                normalAnimationsCount = normalAnimationsCount + 1
            end
        end

        local pages = 0
        if hasFavorites then
            pages = pages + math.ceil(#favoritesToUse / itemsPerPage)
        end
        if normalAnimationsCount > 0 then
            pages = pages + math.ceil(normalAnimationsCount / itemsPerPage)
        end
        return math.max(pages, 1)
    end
    
    local favoritesToUse = _G.filteredFavoritesForDisplay or favoriteEmotes
    local hasFavorites = #favoritesToUse > 0
    local normalEmotesCount = 0

    for _, emote in pairs(filteredEmotes) do
        if not isInFavorites(emote.id) then
            normalEmotesCount = normalEmotesCount + 1
        end
    end

    local pages = 0

    if hasFavorites then
        pages = pages + math.ceil(#favoritesToUse / itemsPerPage)
    end

    if normalEmotesCount > 0 then
        pages = pages + math.ceil(normalEmotesCount / itemsPerPage)
    end

    return math.max(pages, 1)
end

local function isGivenAnimation(animationHolder, animationId)
    for _, animation in animationHolder:GetChildren() do
        if animation:IsA("Animation") and urlToId(animation.AnimationId) == animationId then
            return true
        end
    end
    return false
end

local function isDancing(character, animationTrack)
    local animationId = urlToId(animationTrack.Animation.AnimationId)
    for _, animationHolder in character.Animate:GetChildren() do
        if animationHolder:IsA("StringValue") then
            local sharesAnimationId = isGivenAnimation(animationHolder, animationId)
            if sharesAnimationId then
                return false
            end
        end
    end
    return true
end

local function createGUIElements()
    local exists, emotesWheel = checkEmotesMenuExists()
    if not exists then
        return false
    end

    if emotesWheel:FindFirstChild("Under") then
        emotesWheel.Under:Destroy()
    end
    if emotesWheel:FindFirstChild("Top") then
        emotesWheel.Top:Destroy()
    end
    if emotesWheel:FindFirstChild("EmoteWalkButton") then
        emotesWheel.EmoteWalkButton:Destroy()
    end
    if emotesWheel:FindFirstChild("Favorite") then
        emotesWheel.Favorite:Destroy()
    end
    if emotesWheel:FindFirstChild("SpeedEmote") then
        emotesWheel.SpeedEmote:Destroy()
    end
    if emotesWheel:FindFirstChild("Changepage") then
        emotesWheel.Changepage:Destroy()
    end
    if emotesWheel:FindFirstChild("SpeedBox") then
        emotesWheel.SpeedBox:Destroy()
    end
    if emotesWheel:FindFirstChild("Reload") then
        emotesWheel.Reload:Destroy()
    end

    Under = Instance.new("Frame")
    UIListLayout = Instance.new("UIListLayout")
    _1left = Instance.new("ImageButton")
    _9right = Instance.new("ImageButton")
    _4pages = Instance.new("TextLabel")
    _3TextLabel = Instance.new("TextLabel")
    _2Routenumber = Instance.new("TextBox")
    EmoteWalkButton = Instance.new("ImageButton")
    UICorner1 = Instance.new("UICorner")
    Top = Instance.new("Frame")
    UIListLayout_2 = Instance.new("UIListLayout")
    UICorner = Instance.new("UICorner")
    Search = Instance.new("TextBox")
    Favorite = Instance.new("ImageButton")
    UICorner2 = Instance.new("UICorner")
    SpeedBox = Instance.new("TextBox")
    UICorner_4 = Instance.new("UICorner")
    SpeedEmote = Instance.new("ImageButton")
    UICorner_2 = Instance.new("UICorner")
    Changepage = Instance.new("ImageButton")
     UICorner_5 = Instance.new("UICorner")
     Reload = Instance.new("ImageButton")
     UICorner_6 = Instance.new("UICorner")

    Under.Name = "Under"
    Under.Parent = emotesWheel
    Under.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Under.BackgroundTransparency = 1.000
    Under.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Under.BorderSizePixel = 0
    Under.Position = UDim2.new(0.129999995, 0, 1, 0)
    Under.Size = UDim2.new(0.737500012, 0, 0.132499993, 0)

    UIListLayout.Parent = Under
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    _1left.Name = "1left"
    _1left.Parent = Under
    _1left.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    _1left.BackgroundTransparency = 1.000
    _1left.BorderColor3 = Color3.fromRGB(0, 0, 0)
    _1left.BorderSizePixel = 0
    _1left.Position = UDim2.new(0.0289389063, 0, -0.0849056691, 0)
    _1left.Rotation = 7456.000
    _1left.Size = UDim2.new(0.169491529, 0, 0.94339627, 0)
    _1left.Image = "rbxassetid://93111945058621"
    _1left.ImageColor3 = Color3.fromRGB(0, 0, 0)
    _1left.ImageTransparency = 0.400

    _9right.Name = "9right"
    _9right.Parent = Under
    _9right.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    _9right.BackgroundTransparency = 1.000
    _9right.BorderColor3 = Color3.fromRGB(0, 0, 0)
    _9right.BorderSizePixel = 0
    _9right.Position = UDim2.new(0.0289389063, 0, -0.0849056691, 0)
    _9right.Rotation = 7456.000
    _9right.Size = UDim2.new(0.169491529, 0, 0.94339627, 0)
    _9right.Image = "rbxassetid://107938916240738"
    _9right.ImageColor3 = Color3.fromRGB(0, 0, 0)
    _9right.ImageTransparency = 0.400

    _4pages.Name = "4pages"
    _4pages.Parent = Under
    _4pages.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    _4pages.BackgroundTransparency = 1.000
    _4pages.BorderColor3 = Color3.fromRGB(0, 0, 0)
    _4pages.BorderSizePixel = 0
    _4pages.Position = UDim2.new(0.630225062, 0, 0.188679263, 0)
    _4pages.Size = UDim2.new(0.159322038, 0, 0.811320841, 0)
    _4pages.Font = Enum.Font.SourceSansBold
    _4pages.Text = "1"
    _4pages.TextColor3 = Color3.fromRGB(0, 0, 0)
    _4pages.TextScaled = true
    _4pages.TextSize = 14.000
    _4pages.TextTransparency = 0.400
    _4pages.TextWrapped = true

    _3TextLabel.Name = "3TextLabel"
    _3TextLabel.Parent = Under
    _3TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    _3TextLabel.BackgroundTransparency = 1.000
    _3TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    _3TextLabel.BorderSizePixel = 0
    _3TextLabel.Position = UDim2.new(0.363344043, 0, 0.0283018891, 0)
    _3TextLabel.Size = UDim2.new(0.338983059, 0, 0.94339627, 0)
    _3TextLabel.Font = Enum.Font.SourceSansBold
    _3TextLabel.Text = " ------ "
    _3TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    _3TextLabel.TextScaled = true
    _3TextLabel.TextSize = 14.000
    _3TextLabel.TextTransparency = 0.400
    _3TextLabel.TextWrapped = true

    _2Routenumber.Name = "2Route-number"
    _2Routenumber.Parent = Under
    _2Routenumber.Active = true
    _2Routenumber.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    _2Routenumber.BackgroundTransparency = 1.000
    _2Routenumber.BorderColor3 = Color3.fromRGB(0, 0, 0)
    _2Routenumber.BorderSizePixel = 0
    _2Routenumber.Position = UDim2.new(0.138263673, 0, 0.0283018891, 0)
    _2Routenumber.Selectable = true
    _2Routenumber.Size = UDim2.new(0.159322038, 0, 0.811320841, 0)
    _2Routenumber.Font = Enum.Font.SourceSansBold
    _2Routenumber.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
    _2Routenumber.Text = "1"
    _2Routenumber.TextColor3 = Color3.fromRGB(0, 0, 0)
    _2Routenumber.TextScaled = true
    _2Routenumber.TextSize = 14.000
    _2Routenumber.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    _2Routenumber.TextTransparency = 0.400
    _2Routenumber.TextWrapped = true

    Top.Name = "Top"
    Top.Parent = emotesWheel
    Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Top.BackgroundTransparency = 0.400
    Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Top.BorderSizePixel = 0
    Top.Position = UDim2.new(0.127499998, 0, -0.109999999, 0)
    Top.Size = UDim2.new(0.737500012, 0, 0.0949999914, 0)

    UIListLayout_2.Parent = Top
    UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

    UICorner.CornerRadius = UDim.new(0, 20)
    UICorner.Parent = Top

    Search.Name = "Search"
    Search.Parent = Top
    Search.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Search.BackgroundTransparency = 1.000
    Search.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Search.Position = UDim2.new(0.0677966103, 0, 0)
    Search.Size = UDim2.new(0.864406765, 0, 0.81578958, 0)
    Search.Font = Enum.Font.SourceSansBold
    Search.PlaceholderText = "Search/ID"
    Search.Text = ""
    Search.TextColor3 = Color3.fromRGB(255, 255, 255)
    Search.TextScaled = true
    Search.TextSize = 14.000
    Search.TextWrapped = true

    EmoteWalkButton.Name = "EmoteWalkButton"
    EmoteWalkButton.Parent = emotesWheel
    EmoteWalkButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    EmoteWalkButton.BackgroundTransparency = 0.400
    EmoteWalkButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    EmoteWalkButton.BorderSizePixel = 0
    EmoteWalkButton.Position = UDim2.new(0.889999986, 0, -0.107500002, 0)
    EmoteWalkButton.Size = UDim2.new(0.0874999985, 0, 0.0874999985, 0)
    EmoteWalkButton.Image = defaultButtonImage

    UICorner1.CornerRadius = UDim.new(0, 10)
    UICorner1.Parent = EmoteWalkButton

    Favorite.Name = "Favorite"
    Favorite.Parent = emotesWheel
    Favorite.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Favorite.BackgroundTransparency = 0.400
    Favorite.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Favorite.BorderSizePixel = 0
    Favorite.Position = UDim2.new(0.0189999994, 0, -0.108000003, 0)
    Favorite.Size = UDim2.new(0.0874999985, 0, 0.0874999985, 0)
    Favorite.Image = "rbxassetid://124025954365505"

    UICorner2.CornerRadius = UDim.new(0, 10)
    UICorner2.Parent = Favorite

    SpeedBox.Name = "SpeedBox"
    SpeedBox.Parent = emotesWheel
    SpeedBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    SpeedBox.BackgroundTransparency = 0.400
    SpeedBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SpeedBox.BorderSizePixel = 0
    SpeedBox.Position = UDim2.new(0.0189999398, 0, -0.000499992399, 0)
    SpeedBox.Size = UDim2.new(0.0874999985, 0, 0.0874999985, 0)
    SpeedBox.Visible = false
    SpeedBox.Font = Enum.Font.SourceSansBold
    SpeedBox.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
    SpeedBox.Text = "1"
    SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedBox.TextScaled = true
    SpeedBox.TextWrapped = true
    SpeedBox:GetPropertyChangedSignal("Text"):Connect(function()
       SpeedBox.Text = SpeedBox.Text:gsub("[^%d.]", "")
    end)
    SpeedBox.ZIndex = 2

    UICorner_4.CornerRadius = UDim.new(0, 10)
    UICorner_4.Parent = SpeedBox

    SpeedEmote.Name = "SpeedEmote"
    SpeedEmote.Parent = emotesWheel
    SpeedEmote.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    SpeedEmote.BackgroundTransparency = 0.400
    SpeedEmote.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SpeedEmote.BorderSizePixel = 0
    SpeedEmote.Position = UDim2.new(0.888999999, 0, -0, 0)
    SpeedEmote.Size = UDim2.new(0.0874999985, 0, 0.0874999985, 0)
    SpeedEmote.Image = "rbxassetid://116056570415896"
    SpeedEmote.ZIndex = 2

    UICorner_2.CornerRadius = UDim.new(0, 10)
    UICorner_2.Parent = SpeedEmote

Changepage.Name = "Changepage"
Changepage.Parent = emotesWheel
Changepage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Changepage.BackgroundTransparency = 0.400
Changepage.BorderColor3 = Color3.fromRGB(0, 0, 0)
Changepage.BorderSizePixel = 0
Changep
