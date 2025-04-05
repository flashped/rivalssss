local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Création du GUI
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "CheatMenu"
screenGui.ResetOnSpawn = false

-- 📌 Paramètres
local Settings = {
    AimbotEnabled = false,
    ShowFOV = true,
    FOVRadius = 200,
    ESPEnabled = true,
    ESPRainbow = true,
    ESPColor = Color3.fromRGB(255, 255, 255)
}

-- 📌 Cercle FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Radius = Settings.FOVRadius
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = Settings.ShowFOV

-- 📌 Mise à jour FOV à l’écran
game:GetService("RunService").RenderStepped:Connect(function()
    FOVCircle.Position = workspace.CurrentCamera.ViewportSize / 2
    FOVCircle.Visible = Settings.ShowFOV
    FOVCircle.Radius = Settings.FOVRadius
end)

-- Fonction pour créer un bouton
local function createButton(parent, text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 30)
    button.Position = position
    button.Text = text
    button.TextSize = 16
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Parent = parent
    button.MouseButton1Click:Connect(callback)
    return button
end

-- 📌 Onglet principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 300)
frame.Position = UDim2.new(0, 20, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Parent = screenGui

-- 📌 Onglets
local tab = "aimbot" -- actif par défaut

local function updateTabs()
    for _, obj in pairs(frame:GetChildren()) do
        if obj:IsA("TextButton") and obj.Name ~= "TabAimbot" and obj.Name ~= "TabESP" then
            obj.Visible = (tab == "aimbot" and obj.Name:match("^Aimbot")) or (tab == "esp" and obj.Name:match("^ESP"))
        end
    end
end

local tabAimbot = createButton(frame, "🎯 Aimbot", UDim2.new(0, 0, 0, 0), function()
    tab = "aimbot"
    updateTabs()
end)
tabAimbot.Name = "TabAimbot"

local tabESP = createButton(frame, "🧿 ESP", UDim2.new(0, 110, 0, 0), function()
    tab = "esp"
    updateTabs()
end)
tabESP.Name = "TabESP"

-- 📌 Boutons Aimbot
createButton(frame, "Aimbot: OFF", UDim2.new(0, 10, 0, 40), function(self)
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    self.Text = "Aimbot: " .. (Settings.AimbotEnabled and "ON" or "OFF")
end).Name = "AimbotToggle"

createButton(frame, "FOV: ON", UDim2.new(0, 10, 0, 80), function(self)
    Settings.ShowFOV = not Settings.ShowFOV
    self.Text = "FOV: " .. (Settings.ShowFOV and "ON" or "OFF")
end).Name = "AimbotFOVToggle"

createButton(frame, "FOV +", UDim2.new(0, 10, 0, 120), function()
    Settings.FOVRadius = Settings.FOVRadius + 20
end).Name = "AimbotFOVPlus"

createButton(frame, "FOV -", UDim2.new(0, 110, 0, 120), function()
    Settings.FOVRadius = math.max(20, Settings.FOVRadius - 20)
end).Name = "AimbotFOVMinus"

-- 📌 Boutons ESP
createButton(frame, "ESP: ON", UDim2.new(0, 10, 0, 40), function(self)
    Settings.ESPEnabled = not Settings.ESPEnabled
    self.Text = "ESP: " .. (Settings.ESPEnabled and "ON" or "OFF")
end).Name = "ESPToggle"

createButton(frame, "Rainbow: ON", UDim2.new(0, 10, 0, 80), function(self)
    Settings.ESPRainbow = not Settings.ESPRainbow
    self.Text = "Rainbow: " .. (Settings.ESPRainbow and "ON" or "OFF")
end).Name = "ESPRainbowToggle"

createButton(frame, "Couleur: Rouge", UDim2.new(0, 10, 0, 120), function(self)
    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 255, 255)
    }
    local names = {"Rouge", "Vert", "Bleu", "Jaune", "Blanc"}
    local currentIndex = table.find(colors, Settings.ESPColor) or 0
    local nextIndex = currentIndex + 1
    if nextIndex > #colors then nextIndex = 1 end
    Settings.ESPColor = colors[nextIndex]
    self.Text = "Couleur: " .. names[nextIndex]
end).Name = "ESPColorPicker"

updateTabs()
