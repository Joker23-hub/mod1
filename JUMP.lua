-- FUSION BRAINROT JUMP V3
-- CARRY CONTROL | DELTA ANDROID

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer

local Enabled = false
local Power = 55
local Height = 8.5

local Humanoid
local Original = {}
local CharacterConnections = {}

local function DisconnectCharacter()
    for _, c in ipairs(CharacterConnections) do
        c:Disconnect()
    end
    table.clear(CharacterConnections)
end

local function ApplyJump()
    if not Enabled or not Humanoid or Humanoid.Health <= 0 then
        return
    end

    if Humanoid.UseJumpPower then
        if Humanoid.JumpPower ~= Power then
            Humanoid.JumpPower = Power
        end
    else
        if Humanoid.JumpHeight ~= Height then
            Humanoid.JumpHeight = Height
        end
    end
end

local function RestoreJump()
    if not Humanoid then return end

    if Original.JumpPower ~= nil then
        Humanoid.JumpPower = Original.JumpPower
    end

    if Original.JumpHeight ~= nil then
        Humanoid.JumpHeight = Original.JumpHeight
    end

    if Original.Jumping ~= nil then
        Humanoid:SetStateEnabled(
            Enum.HumanoidStateType.Jumping,
            Original.Jumping
        )
    end
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "FusionBrainrotJumpV3"
Gui.ResetOnSpawn = false

local ok = pcall(function()
    Gui.Parent = game:GetService("CoreGui")
end)

if not ok or not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(255, 205)
Main.Position = UDim2.new(0.5, -127, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(17, 19, 27)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius =
    UDim.new(0, 14)

local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(0, 180, 255)
Stroke.Thickness = 2

local function Label(name, text, position, size)
    local obj = Instance.new("TextLabel")
    obj.Name = name
    obj.Position = position
    obj.Size = size
    obj.BackgroundTransparency = 1
    obj.Text = text
    obj.TextColor3 = Color3.new(1, 1, 1)
    obj.Font = Enum.Font.GothamBold
    obj.TextSize = 13
    obj.Parent = Main
    return obj
end

Label("Title", "FUSION BRAINROT JUMP V3",
    UDim2.fromOffset(0, 8), UDim2.new(1, 0, 0, 30)
).TextColor3 = Color3.fromRGB(0, 190, 255)

local Status = Label("Status", "STATUS: OFF",
    UDim2.fromOffset(0, 40), UDim2.new(1, 0, 0, 25)
)

Status.TextColor3 = Color3.fromRGB(255, 90, 90)

local Value = Label("Value", "POWER: 55",
    UDim2.fromOffset(0, 76), UDim2.new(1, 0, 0, 25)
)

local function Button(name, text, pos, size)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Position = pos
    b.Size = size
    b.BackgroundColor3 = Color3.fromRGB(0, 105, 175)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 17
    b.Parent = Main
    Instance.new("UICorner", b).CornerRadius =
        UDim.new(0, 8)
    return b
end

local Minus = Button("Minus", "-",
    UDim2.fromOffset(30, 108),
    UDim2.fromOffset(55, 35)
)

local Plus = Button("Plus", "+",
    UDim2.fromOffset(170, 108),
    UDim2.fromOffset(55, 35)
)

local Toggle = Button("Toggle", "ACTIVAR",
    UDim2.fromOffset(30, 153),
    UDim2.fromOffset(195, 38)
)

local function UpdateValue()
    if Humanoid and Humanoid.UseJumpPower then
        Value.Text = "JUMP POWER: " .. Power
    else
        Value.Text = "JUMP HEIGHT: " .. Height
    end

    ApplyJump()
end

Minus.MouseButton1Click:Connect(function()
    if Humanoid and Humanoid.UseJumpPower then
        Power = math.max(40, Power - 2)
    else
        Height = math.max(7, Height - 0.5)
    end

    UpdateValue()
end)

Plus.MouseButton1Click:Connect(function()
    if Humanoid and Humanoid.UseJumpPower then
        Power = math.min(65, Power + 2)
    else
        Height = math.min(11, Height + 0.5)
    end

    UpdateValue()
end)

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled

    if Enabled then
        ApplyJump()
        Status.Text = "STATUS: ON"
        Status.TextColor3 = Color3.fromRGB(0, 255, 130)
        Toggle.Text = "DESACTIVAR"
    else
        RestoreJump()
        Status.Text = "STATUS: OFF"
        Status.TextColor3 = Color3.fromRGB(255, 90, 90)
        Toggle.Text = "ACTIVAR"
    end
end)

local function SetupCharacter(char)
    DisconnectCharacter()

    Humanoid = char:WaitForChild("Humanoid")

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

    table.insert(CharacterConnections,
        Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(
            function()
                if Enabled then ApplyJump() end
            end
        )
    )

    table.insert(CharacterConnections,
        Humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(
            function()
                if Enabled then ApplyJump() end
            end
        )
    )

    table.insert(CharacterConnections,
        Humanoid:GetPropertyChangedSignal("UseJumpPower"):Connect(
            function()
                UpdateValue()
            end
        )
    )

    UpdateValue()
end

Player.CharacterAdded:Connect(SetupCharacter)

if Player.Character then
    SetupCharacter(Player.Character)
end

-- Ventana desplazable
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

Gui.Destroying:Connect(function()
    Enabled = false
    RestoreJump()
    DisconnectCharacter()
end)

print("[FUSION JUMP V3] CARRY CONTROL LOADED")
