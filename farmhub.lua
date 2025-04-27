--// LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

--// SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

--// VARIABLES
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local espFolder = Instance.new("Folder", Workspace)
espFolder.Name = "ESPFolder"

local autofarm = false
local autoattack = false
local espEnabled = false
local modeSilentKill = false

--// FUNCTIONS

local function Notify(title, content)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = 3,
        Image = nil,
    })
end

local function getClosestEnemy()
    local closest, distance = nil, math.huge
    for _, model in ipairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and model:FindFirstChildOfClass("Humanoid") and model ~= character then
            local dist = (rootPart.Position - model.HumanoidRootPart.Position).Magnitude
            if dist < distance then
                distance = dist
                closest = model
            end
        end
    end
    return closest
end

local function safeTweenTo(targetCFrame)
    local goal = {}
    goal.CFrame = targetCFrame

    local dist = (rootPart.Position - targetCFrame.Position).Magnitude
    local time = math.clamp(dist / 50, 0.5, 2)

    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = TweenService:Create(rootPart, tweenInfo, goal)
    tween:Play()
end

local function attack(enemy)
    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid:TakeDamage(15) -- Damage bisa diubah
    end
end

local function silentKill(enemy)
    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid.Health = 0
    end
end

local function createESP(target)
    if espFolder:FindFirstChild(target.Name) then return end

    local adorn = Instance.new("BoxHandleAdornment")
    adorn.Adornee = target
    adorn.Size = Vector3.new(4,6,2)
    local distance = (rootPart.Position - target.Position).Magnitude

    if distance < 30 then
        adorn.Color3 = Color3.new(0, 1, 0) -- Hijau dekat
    elseif distance < 60 then
        adorn.Color3 = Color3.new(1, 1, 0) -- Kuning sedang
    else
        adorn.Color3 = Color3.new(1, 0, 0) -- Merah jauh
    end

    adorn.Transparency = 0.5
    adorn.AlwaysOnTop = true
    adorn.ZIndex = 5
    adorn.Parent = espFolder
end

local function refreshESP()
    espFolder:ClearAllChildren()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj:FindFirstChildOfClass("Humanoid") and obj ~= character then
            createESP(obj)
        end
    end
end

local function AutoReconnect()
    while true do
        task.wait(10)
        if not game:IsLoaded() then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
        end
    end
end

--// UI SETUP
local Window = Rayfield:CreateWindow({
    Name = "Premium Farm Hub",
    LoadingTitle = "Connecting...",
    LoadingSubtitle = "By ChatGPT",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PremiumFarm", 
        FileName = "Settings"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Callback = function(Value)
        autofarm = Value
        Notify("Auto Farm", Value and "ON" or "OFF")
    end,
})

MainTab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(Value)
        espEnabled = Value
        if not espEnabled then
            espFolder:ClearAllChildren()
        end
        Notify("ESP", Value and "ON" or "OFF")
    end,
})

MainTab:CreateToggle({
    Name = "Auto Attack",
    CurrentValue = false,
    Callback = function(Value)
        autoattack = Value
        Notify("Auto Attack", Value and "ON" or "OFF")
    end,
})

MainTab:CreateToggle({
    Name = "Silent Kill Mode",
    CurrentValue = false,
    Callback = function(Value)
        modeSilentKill = Value
        Notify("Silent Kill", Value and "OFF" or "ON")
    end,
})

--// MAIN LOOP
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            character = player.Character or player.CharacterAdded:Wait()
            rootPart = character:WaitForChild("HumanoidRootPart")

            if autofarm then
                local enemy = getClosestEnemy()
                if enemy then
                    if modeSilentKill then
                        silentKill(enemy)
                    else
                        safeTweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0,0,5))
                        if autoattack then
                            task.wait(1)
                            attack(enemy)
                        end
                    end
                end
            end

            if espEnabled then
                refreshESP()
            end
        end)
    end
end)

--// AUTORECONNECT (opsional aktifin)
--task.spawn(AutoReconnect)
