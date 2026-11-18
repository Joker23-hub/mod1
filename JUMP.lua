-- FUSION BRAINROT JUMP V2
-- Delta Android | Carry Mode
-- Jump Power: 100

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer

local POWER = 100
local Enabled = false
local Humanoid
local Connections = {}
local Original = {}

local function DisconnectAll()
    for _, connection in ipairs(Connections) do
        connection:Disconnect()
    end
    table.clear(Connections)
end

local function ApplyJump()
    if not Enabled or not Humanoid or Humanoid.Health <= 0 then
        return
    end

    if Humanoid.UseJumpPower then
        if Humanoid.JumpPower ~= POWER then
            Humanoid.JumpPower = POWER
        end
    else
        if Humanoid.JumpHeight ~= POWER then
            Humanoid.JumpHeight = POWER
        end
    end

    Humanoid:SetStateEnabled(
        Enum.HumanoidStateType.Jumping, true
    )
end

local function Restore()
    if not Humanoid then return end

    if Original.JumpPower then
        Humanoid.JumpPower = Original.JumpPower
    end

    if Original.JumpHeight then
        Humanoid.JumpHeight = Original.JumpHeight
    end

    if Original.Jumping ~= nil then
        Humanoid:SetStateEnabled(
            Enum.HumanoidStateType.Jumping,
            Original.Jumping
        )
    end
end

local function SetupCharacter(Character)
    DisconnectAll()

    Humanoid = Character:WaitForChild("Humanoid")

    Original = {
        JumpPower = Humanoid.JumpPower,
        JumpHeight = Humanoid.JumpHeight,
        Jumping = Humanoid:GetStateEnabled(
            Enum.HumanoidStateType.Jumping
        )
    }

    if Enabled then
        ApplyJump()
    end

    table.insert(Connections,
        Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(
            ApplyJump
        )
    )

    table.insert(Connections,
        Humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(
            ApplyJump
        )
    )

    table.insert(Connections,
        Humanoid:GetPropertyChangedSignal("UseJumpPower"):Connect(
            ApplyJump
        )
    )
end

-- Interfaz
local Gui = Instance.new("ScreenGui")
Gui.Name = "FusionBrainrotJumpV2"
Gui.ResetOnSpawn = false

local success = pcall(function()
    Gui.Parent = game:GetService("CoreGui")
end)

if not success or not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(250, 165)
Main.Position = UDim2.new(0.5, -125, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(17, 19, 27)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius =
    UDim.new(0, 14)

local Border = Instance.new("UIStroke", Main)
Border.Color = Color3.fromRGB(0, 180, 255)
Border.Thickness = 2

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "FUSION BRAINROT JUMP V2"
Title.TextColor3 = Color3.fromRGB(0, 190, 255)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Position = UDim2.fromOffset(0, 43)
Status.Size = UDim2.new(1, 0, 0, 30)
Status.BackgroundTransparency = 1
Status.Text = "STATUS: OFF"
Status.TextColor3 = Color3.fromRGB(255, 90, 90)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 14
Status.Parent = Main

local Toggle = Instance.new("TextButton")
Toggle.Position = UDim2.fromOffset(20, 82)
Toggle.Size = UDim2.new(1, -40, 0, 43)
Toggle.BackgroundColor3 = Color3.fromRGB(0, 115, 190)
Toggle.Text = "ACTIVAR SUPER JUMP"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.TextSize = 13
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Main

Instance.new("UICorner", Toggle).CornerRadius =
    UDim.new(0, 9)

local Info = Instance.new("TextLabel")
Info.Position = UDim2.fromOffset(0, 133)
Info.Size = UDim2.new(1, 0, 0, 23)
Info.BackgroundTransparency = 1
Info.Text = "CARRY MODE | POWER: 100"
Info.TextColor3 = Color3.fromRGB(170, 180, 195)
Info.Font = Enum.Font.Gotham
Info.TextSize = 11
Info.Parent = Main

-- Activación
Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled

    if Enabled then
        ApplyJump()

        Status.Text = "STATUS: ON"
        Status.TextColor3 = Color3.fromRGB(0, 255, 130)
        Toggle.Text = "DESACTIVAR SUPER JUMP"
    else
        Restore()

        Status.Text = "STATUS: OFF"
        Status.TextColor3 = Color3.fromRGB(255, 90, 90)
        Toggle.Text = "ACTIVAR SUPER JUMP"
    end
end)

-- Compatibilidad con botón táctil
table.insert(Connections,
    UIS.JumpRequest:Connect(function()
        if Enabled and Humanoid and Humanoid.Health > 0 then
            ApplyJump()
            Humanoid.Jump = true
        end
    end)
)

-- Arrastrar ventana
local dragging = false
local dragStart
local startPos

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement
    ) then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Respawn
Player.CharacterAdded:Connect(SetupCharacter)

if Player.Character then
    SetupCharacter(Player.Character)
end

Gui.Destroying:Connect(function()
    Enabled = false
    Restore()
    DisconnectAll()
end)

print("[FUSION JUMP V2] Loaded")
