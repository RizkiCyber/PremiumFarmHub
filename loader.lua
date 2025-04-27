--// PREMIUM FARM HUB LOADER
repeat wait() until game:IsLoaded()

-- Check Executor
local executor = identifyexecutor and identifyexecutor() or "Unknown Executor"

-- Small Notification
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "PremiumFarmHub",
        Text = "Executor Detected: " .. executor,
        Duration = 5
    })
end)

-- Loading UI
local loadingGui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local label = Instance.new("TextLabel")

loadingGui.Name = "PremiumFarmHubLoading"
loadingGui.Parent = game.CoreGui
loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

frame.Parent = loadingGui
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Position = UDim2.new(0.4, 0, 0.4, 0)
frame.Size = UDim2.new(0, 300, 0, 100)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.2

label.Parent = frame
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "Loading PremiumFarmHub..."
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.TextScaled = true
label.Font = Enum.Font.GothamBold

-- Load Script with Retry
local function loadScript()
    local success, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/RizkiCyber/PremiumFarmHub/main/farmhub.lua")
    end)

    if success and result then
        loadstring(result)()
        return true
    else
        return false
    end
end

local attempts = 0
local maxAttempts = 3
local loaded = false

repeat
    attempts = attempts + 1
    loaded = loadScript()
    wait(2)
until loaded or attempts >= maxAttempts

-- Final Status
if loaded then
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "PremiumFarmHub",
            Text = "Loaded Successfully!",
            Duration = 5
        })
    end)
else
    warn("Failed to load PremiumFarmHub after "..maxAttempts.." attempts.")
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "PremiumFarmHub",
            Text = "Failed to load script.",
            Duration = 5
        })
    end)
end

-- Cleanup
loadingGui:Destroy()
