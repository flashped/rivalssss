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
    healthText.Size = 50
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
... (91lignes restantes)
