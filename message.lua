-- 📌 Chargement des services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- 📌 Paramètres
local Settings = {
    ESP_Enabled = true,
    AimAssist_Enabled = false,
    AimAssist_FOV = 200,
    AimAssist_Smoothness = 0.4,
    ESP_MaxDistance = 150,
    NoRecoil_Enabled = true,
    NoRecoil_Power = 0.8
}

local ESP_Boxes = {}
local Health_Texts = {}

-- 📌 Cercle de FOV (désactivé ici pour test)
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Color = Color3.fromRGB(255, 0, 0)
FOV_Circle.Radius = Settings.AimAssist_FOV
FOV_Circle.Thickness = 1
FOV_Circle.NumSides = 100
FOV_Circle.Filled = false
FOV_Circle.Transparency = 1
FOV_Circle.Visible = false -- désactivé temporairement

-- 📌 Création ESP
function CreateESP(player)
    if ESP_Boxes[player] then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    box.Visible = false

    local healthText = Drawing.new("Text")
    healthText.Size = 16
    healthText.Color = Color3.fromRGB(255, 255, 255)
    healthText.Outline = true
    healthText.Center = true
    healthText.Visible = false

    ESP_Boxes[player] = box
    Health_Texts[player] = healthText
end

-- 📌 Suppression ESP
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

-- 📌 Fonction de couleur multicolore dynamique
function GetRainbowColor()
    local hue = tick() % 5 / 5 -- valeur entre 0 et 1
    return Color3.fromHSV(hue, 1, 1)
end

-- 📌 Mise à jour ESP
function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local rootPart = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid
            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude

            if distance <= Settings.ESP_MaxDistance then
                local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

                if not ESP_Boxes[player] then
                    CreateESP(player)
                end

                local box = ESP_Boxes[player]
                local healthText = Health_Texts[player]

                local size = Vector2.new(2500 / pos.Z, 3500 / pos.Z)
                local position = Vector2.new(pos.X - size.X / 2, pos.Y - size.Y / 2)

                -- 🎨 Couleur multicolore
                local rainbow = GetRainbowColor()

                box.Size = size
                box.Position = position
                box.Visible = onScreen and Settings.ESP_Enabled
                box.Color = rainbow

                healthText.Position = Vector2.new(pos.X, pos.Y - size.Y / 2 - 15)
                healthText.Text = math.floor(humanoid.Health) .. " HP"
                healthText.Visible = onScreen and Settings.ESP_Enabled
                healthText.Color = rainbow
            else
                if ESP_Boxes[player] then ESP_Boxes[player].Visible = false end
                if Health_Texts[player] then Health_Texts[player].Visible = false end
            end
        elseif ESP_Boxes[player] then
            ESP_Boxes[player].Visible = false
            Health_Texts[player].Visible = false
        end
    end
end

-- 📌 Mise à jour continue
RunService.RenderStepped:Connect(function()
    UpdateESP()
end)

-- 📌 Suppression des ESP quand un joueur quitte
Players.PlayerRemoving:Connect(RemoveESP)
