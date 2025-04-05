-- 📌 Chargement des services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- 📌 Paramètres
local Settings = {
    ESP_Enabled = false,
    AimAssist_Enabled = false,
    AimAssist_FOV = 200,
    AimAssist_Smoothness = 0.4,
    ESP_MaxDistance = 150,
    NoRecoil_Enabled = true,
    NoRecoil_Power = 0.8
}

local ESP_Boxes = {}
local Health_Texts = {}

-- 📌 Dessin du cercle FOV pour Aim Assist
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Color = Color3.fromRGB(255, 0, 0)
FOV_Circle.Radius = Settings.AimAssist_FOV
FOV_Circle.Thickness = 1
FOV_Circle.NumSides = 100
FOV_Circle.Filled = false
FOV_Circle.Transparency = 1
FOV_Circle.Visible = true

-- 📌 Création ESP avec texte de vie
function CreateESP(player)
    if ESP_Boxes[player] then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    box.Visible = false

    local healthText = Drawing.new("Text")
    healthText.Size = 18
    healthText.Color = Color3.fromRGB(255, 255, 255)
    healthText.Outline = true
    healthText.Visible = false

    ESP_Boxes[player] = box
    Health_Texts[player] = healthText
end

-- 📌 Suppression ESP quand un joueur quitte
function RemoveESP(player)
    if ESP_Boxes[player] then
        ESP_Boxes[player]:Remove()
        ESP_Boxes[player] = nil
    end
    if Health_Texts[player] then
        Health_Texts[player]:Remove()
        Health_Texts[player] = nil
    end
end

-- 📌 Mise à jour ESP avec texte de vie
function UpdateESP()
    if not Settings.ESP_Enabled then 
        for _, box in pairs(ESP_Boxes) do
            box.Visible = false
        end
        for _, text in pairs(Health_Texts) do
            text.Visible = false
        end
        return
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local rootPart = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
            
            if distance <= Settings.ESP_MaxDistance then
                local pos, visible = Camera:WorldToViewportPoint(rootPart.Position)
                
                if not ESP_Boxes[player] then
                    CreateESP(player)
                end

                local box = ESP_Boxes[player]
                local healthText = Health_Texts[player]
                local size = Vector2.new(2500 / pos.Z, 3500 / pos.Z)
                local position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)

                box.Size = size
                box.Position = position
                box.Visible = Settings.ESP_Enabled
                box.Color = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

                -- Mise à jour du texte de vie
                healthText.Text = string.format("%d/%d", math.floor(humanoid.Health), humanoid.MaxHealth)
                healthText.Position = Vector2.new(pos.X, pos.Y - size.Y / 2 - 15)
                healthText.Visible = Settings.ESP_Enabled
            elseif ESP_Boxes[player] then
                ESP_Boxes[player].Visible = false
                Health_Texts[player].Visible = false
            end
        elseif ESP_Boxes[player] then
            ESP_Boxes[player].Visible = false
            Health_Texts[player].Visible = false
        end
    end
end

-- 📌 Trouver le joueur le plus proche pour Aim Assist
function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Settings.AimAssist_FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, visible = Camera:WorldToViewportPoint(head.Position)

            if visible then
                local playerDistance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if playerDistance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = playerDistance
                end
            end
        end
    end
    return closestPlayer
end

-- 📌 AIMBOT + NO RECOIL
RunService.RenderStepped:Connect(function()
    FOV_Circle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOV_Circle.Radius = Settings.AimAssist_FOV

    if Settings.AimAssist_Enabled then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head
            local screenPos, visible = Camera:WorldToViewportPoint(head.Position)

            if visible then
                local moveX = (screenPos.X - Mouse.X) * Settings.AimAssist_Smoothness
                local moveY = (screenPos.Y - Mouse.Y) * Settings.AimAssist_Smoothness
                mousemoverel(moveX, moveY)
            end
        end
    end
end)

-- 📌 Détection du tir pour activer No Recoil
LocalPlayer:GetMouse().Button1Down:Connect(function()
    if Settings.NoRecoil_Enabled then
        local originalCFrame = Camera.CFrame
        wait()
        Camera.CFrame = originalCFrame:Lerp(Camera.CFrame, Settings.NoRecoil_Power)
    end
end)

-- 📌 Touche F2 pour activer/désactiver l'ESP
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F2 then
        Settings.ESP_Enabled = not Settings.ESP_Enabled
        print("ESP: " .. tostring(Settings.ESP_Enabled))
    elseif input.KeyCode == Enum.KeyCode.CapsLock then
        Settings.AimAssist_Enabled = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        Settings.AimAssist_Enabled = false
    end
end)

-- 📌 Mise à jour ESP en continu
RunService.RenderStepped:Connect(function()
    UpdateESP()
end)

Players.PlayerRemoving:Connect(RemoveESP)

print("🔥 ESP avec texte de vie, Aim Assist & No Recoil Chargé ! F2 = ESP | Shift = Aim Assist | No Recoil Auto | by narcop")
