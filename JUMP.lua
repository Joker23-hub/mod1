--==================================================
-- FUSION BRAINROT JUMP V4
-- ROBLOX | DELTA ANDROID
-- CARRY CONTROL
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- CONFIGURATION
local Enabled = false
local Power = 55
local Height = 8.5

local MAX_POWER = 65
local MIN_POWER = 40

local MAX_HEIGHT = 20
local MIN_HEIGHT = 7

local Humanoid
local Original = {}
local CharacterConnections = {}

--==================================================
-- CONNECTION MANAGEMENT
--==================================================

local function DisconnectCharacter()
    for _, connection in ipairs(CharacterConnections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end

    table.clear(CharacterConnections)
end

--==================================================
-- APPLY JUMP
--==================================================

local function ApplyJump()
    if not Enabled then return end
    if not Humanoid then return end
    if Humanoid.Health <= 0 then return end

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

--==================================================
-- RESTORE ORIGINAL VALUES
--==================================================

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

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "FusionBrainrotJumpV4"
Gui.ResetOnSpawn = false

local success = pcall(function()
    Gui.Parent = game:GetService("CoreGui")
end)

if not success or not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(255, 205)
Main.Position = UDim2.new(0.5, -127, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(17, 19, 27)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius =
    UDim.new(0, 14)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 180, 255)
Stroke.Thickness = 2
Stroke.Parent = Main

--==================================================
-- LABEL FUNCTION
--==================================================

local function CreateLabel(name, text, position, size)

    local label = Instance.new("TextLabel")

    label.Name = name
    label.Position = position
    label.Size = size
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Parent = Main

    return label
end

local Title = CreateLabel(
    "Title",
    "FUSION BRAINROT JUMP V4",
    UDim2.fromOffset(0, 8),
    UDim2.new(1, 0, 0, 30)
)

Title.TextColor3 = Color3.fromRGB(0, 190, 255)

local Status = CreateLabel(
    "Status",
    "STATUS: OFF",
    UDim2.fromOffset(0, 40),
    UDim2.new(1, 0, 0, 25)
)

Status.TextColor3 = Color3.fromRGB(255, 90, 90)

local Value = CreateLabel(
    "Value",
    "POWER: 55",
    UDim2.fromOffset(0, 76),
    UDim2.new(1, 0, 0, 25)
)

--==================================================
-- BUTTON FUNCTION
--==================================================

local function CreateButton(name, text, position, size)

    local button = Instance.new("TextButton")

    button.Name = name
    button.Position = position
    button.Size = size
    button.BackgroundColor3 = Color3.fromRGB(0, 105, 175)
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 17
    button.Parent = Main

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 8)

    return button
end

local Minus = CreateButton(
    "Minus",
    "-",
    UDim2.fromOffset(30, 108),
    UDim2.fromOffset(55, 35)
)

local Plus = CreateButton(
    "Plus",
    "+",
    UDim2.fromOffset(170, 108),
    UDim2.fromOffset(55, 35)
)

local Toggle = CreateButton(
    "Toggle",
    "ACTIVAR",
    UDim2.fromOffset(30, 153),
    UDim2.fromOffset(195, 38)
)

--==================================================
-- UPDATE VALUE
--==================================================

local function UpdateValue()

    if Humanoid and Humanoid.UseJumpPower then

        Value.Text = "JUMP POWER: " .. Power

    else

        Value.Text = "JUMP HEIGHT: " .. Height

    end

    ApplyJump()
end

--==================================================
-- DECREASE
--==================================================

Minus.MouseButton1Click:Connect(function()

    if Humanoid and Humanoid.UseJumpPower then

        Power = math.max(
            MIN_POWER,
            Power - 2
        )

    else

        Height = math.max(
            MIN_HEIGHT,
            Height - 1
        )

    end

    UpdateValue()

end)

--==================================================
-- INCREASE
--==================================================

Plus.MouseButton1Click:Connect(function()

    if Humanoid and Humanoid.UseJumpPower then

        Power = math.min(
            MAX_POWER,
            Power + 2
        )

    else

        Height = math.min(
            MAX_HEIGHT,
            Height + 1
        )

    end

    UpdateValue()

end)

--==================================================
-- ON / OFF
--==================================================

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

--==================================================
-- CHARACTER SETUP
--==================================================

local function SetupCharacter(Character)

    DisconnectCharacter()

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

    table.insert(
        CharacterConnections,

        Humanoid:GetPropertyChangedSignal(
            "JumpPower"
        ):Connect(function()

            if Enabled then
                ApplyJump()
            end

        end)
    )

    table.insert(
        CharacterConnections,

        Humanoid:GetPropertyChangedSignal(
            "JumpHeight"
        ):Connect(function()

            if Enabled then
                ApplyJump()
            end

        end)
    )

    table.insert(
        CharacterConnections,

        Humanoid:GetPropertyChangedSignal(
            "UseJumpPower"
        ):Connect(function()

            UpdateValue()

        end)
    )

    UpdateValue()

end

--==================================================
-- RESPAWN
--==================================================

Player.CharacterAdded:Connect(SetupCharacter)

if Player.Character then
    SetupCharacter(Player.Character)
end

--==================================================
-- DRAGGABLE MOBILE GUI
--==================================================

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

--==================================================
-- CLEANUP
--==================================================

Gui.Destroying:Connect(function()

    Enabled = false

    RestoreJump()

    DisconnectCharacter()

end)

print("[FUSION BRAINROT JUMP V4] LOADED")
