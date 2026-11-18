--[[
    FUSION BRAINROT JUMP
    Roblox - Delta Executor Android
    Mode: CARRY
    Jump Power: 100
    UI: FLOATING
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local JumpValue = 100
local Enabled = false

local Character
local Humanoid
local OriginalJumpPower
local OriginalJumpHeight
local OriginalUseJumpPower

-- Detectar personaje
local function SetupCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")

    OriginalJumpPower = Humanoid.JumpPower
    OriginalJumpHeight = Humanoid.JumpHeight
    OriginalUseJumpPower = Humanoid.UseJumpPower

    if Enabled then
        if Humanoid.UseJumpPower then
            Humanoid.JumpPower = JumpValue
        else
            Humanoid.JumpHeight = JumpValue
        end
    end
end

if Player.Character then
    SetupCharacter(Player.Character)
end

Player.CharacterAdded:Connect(SetupCharacter)

-- Aplicar salto
local function ApplyJump()
    if not Humanoid or Humanoid.Health <= 0 then
        return
    end

    if Humanoid.UseJumpPower then
        Humanoid.JumpPower = JumpValue
    else
        Humanoid.JumpHeight = JumpValue
    end
end

local function RestoreJump()
    if not Humanoid then return end

    if OriginalJumpPower then
        Humanoid.JumpPower = OriginalJumpPower
    end

    if OriginalJumpHeight then
        Humanoid.JumpHeight = OriginalJumpHeight
    end
end

-- Interfaz
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FusionBrainrotJump"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 220, 0, 145)
Main.Position = UDim2.new(0.5, -110, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius =
    UDim.new(0, 12)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 180, 255)
Stroke.Thickness = 1.5
Stroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "FUSION BRAINROT JUMP"
Title.TextColor3 = Color3.fromRGB(0, 190, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Position = UDim2.new(0, 0, 0, 38)
Status.Size = UDim2.new(1, 0, 0, 25)
Status.BackgroundTransparency = 1
Status.Text = "STATUS: OFF"
Status.TextColor3 = Color3.fromRGB(255, 100, 100)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 12
Status.Parent = Main

local Toggle = Instance.new("TextButton")
Toggle.Position = UDim2.new(0.1, 0, 0, 75)
Toggle.Size = UDim2.new(0.8, 0, 0, 38)
Toggle.BackgroundColor3 = Color3.fromRGB(0, 110, 180)
Toggle.Text = "ACTIVAR SUPER JUMP"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 12
Toggle.Parent = Main

Instance.new("UICorner", Toggle).CornerRadius =
    UDim.new(0, 8)

local Info = Instance.new("TextLabel")
Info.Position = UDim2.new(0, 0, 0, 117)
Info.Size = UDim2.new(1, 0, 0, 20)
Info.BackgroundTransparency = 1
Info.Text = "JUMP POWER: 100"
Info.TextColor3 = Color3.fromRGB(180, 190, 205)
Info.TextSize = 10
Info.Font = Enum.Font.Gotham
Info.Parent = Main

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled

    if Enabled then
        ApplyJump()
        Status.Text = "STATUS: ON"
        Status.TextColor3 = Color3.fromRGB(0, 255, 130)
        Toggle.Text = "DESACTIVAR SUPER JUMP"
    else
        RestoreJump()
        Status.Text = "STATUS: OFF"
        Status.TextColor3 = Color3.fromRGB(255, 100, 100)
        Toggle.Text = "ACTIVAR SUPER JUMP"
    end
end)

-- Arrastrar ventana en Android
local dragging = false
local dragStart
local startPosition

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement
    ) then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Limpieza
ScreenGui.Destroying:Connect(function()
    Enabled = false
    RestoreJump()
end)

print("FUSION BRAINROT JUMP cargado correctamente")
