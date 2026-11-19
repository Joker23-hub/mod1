--==================================================
-- FUSION BRAINROT TOOLKIT V6
-- JUMP ONLY | DELTA ANDROID
-- MINIMIZE / RESTORE
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer

local Enabled = false
local JumpPower = 55
local JumpHeight = 8.5

local MIN_POWER = 40
local MAX_POWER = 65
local MIN_HEIGHT = 7
local MAX_HEIGHT = 20

local Humanoid
local Original = {}
local Connections = {}

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "FusionBrainrotV6"
Gui.ResetOnSpawn = false

local ok = pcall(function()
    Gui.Parent = game:GetService("CoreGui")
end)

if not ok or not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(255, 190)
Main.Position = UDim2.new(0.5, -127, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(17, 19, 27)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius =
    UDim.new(0, 14)

local Border = Instance.new("UIStroke", Main)
Border.Color = Color3.fromRGB(0, 180, 255)
Border.Thickness = 2

--==================================================
-- HEADER
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -48, 0, 38)
Title.Position = UDim2.fromOffset(5, 0)
Title.BackgroundTransparency = 1
Title.Text = "FUSION BRAINROT V6"
Title.TextColor3 = Color3.fromRGB(0, 190, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(32, 28)
Minimize.Position = UDim2.new(1, -39, 0, 5)
Minimize.BackgroundColor3 = Color3.fromRGB(0, 105, 175)
Minimize.Text = "-"
Minimize.TextColor3 = Color3.new(1, 1, 1)
Minimize.TextSize = 20
Minimize.Font = Enum.Font.GothamBold
Minimize.Parent = Main

Instance.new("UICorner", Minimize).CornerRadius =
    UDim.new(0, 7)

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Position = UDim2.fromOffset(0, 40)
Content.Size = UDim2.new(1, 0, 1, -40)
Content.BackgroundTransparency = 1
Content.Parent = Main

local function CreateLabel(name, text, y, height, size)

    local label = Instance.new("TextLabel")
    label.Name = name
    label.Position = UDim2.fromOffset(5, y)
    label.Size = UDim2.new(1, -10, 0, height)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = size or 13
    label.Parent = Content

    return label
end

local function CreateButton(name, text, x, y, w, h)

    local button = Instance.new("TextButton")
    button.Name = name
    button.Position = UDim2.fromOffset(x, y)
    button.Size = UDim2.fromOffset(w, h)
    button.BackgroundColor3 = Color3.fromRGB(0, 105, 175)
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 15
    button.Parent = Content

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 8)

    return button
end

local Status = CreateLabel(
    "Status",
    "SUPER JUMP: OFF",
    3, 25, 14
)

Status.TextColor3 = Color3.fromRGB(255, 90, 90)

local Value = CreateLabel(
    "Value",
    "JUMP HEIGHT: 8.5",
    31, 25, 13
)

local Minus = CreateButton(
    "Minus", "-", 30, 65, 65, 38
)

local Plus = CreateButton(
    "Plus", "+", 160, 65, 65, 38
)

local Toggle = CreateButton(
    "Toggle", "ACTIVAR SUPER JUMP",
    30, 115, 195, 38
)

--==================================================
-- JUMP SYSTEM
--==================================================

local function ApplyJump()

    if not Enabled then return end
    if not Humanoid then return end
    if Humanoid.Health <= 0 then return end

    if Humanoid.UseJumpPower then

        if Humanoid.JumpPower ~= JumpPower then
            Humanoid.JumpPower = JumpPower
        end

    else

        if Humanoid.JumpHeight ~= JumpHeight then
            Humanoid.JumpHeight = JumpHeight
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

--==================================================
-- UPDATE INTERFACE
--==================================================

local function UpdateInterface()

    if Humanoid and Humanoid.UseJumpPower then

        Value.Text = "JUMP POWER: " .. JumpPower

    else

        Value.Text = "JUMP HEIGHT: " .. JumpHeight

    end

    ApplyJump()
end

--==================================================
-- BUTTONS
--==================================================

Minus.MouseButton1Click:Connect(function()

    if Humanoid and Humanoid.UseJumpPower then

        JumpPower = math.max(
            MIN_POWER,
            JumpPower - 2
        )

    else

        JumpHeight = math.max(
            MIN_HEIGHT,
            JumpHeight - 1
        )

    end

    UpdateInterface()
end)

Plus.MouseButton1Click:Connect(function()

    if Humanoid and Humanoid.UseJumpPower then

        JumpPower = math.min(
            MAX_POWER,
            JumpPower + 2
        )

    else

        JumpHeight = math.min(
            MAX_HEIGHT,
            JumpHeight + 1
        )

    end

    UpdateInterface()
end)

Toggle.MouseButton1Click:Connect(function()

    Enabled = not Enabled

    if Enabled then

        ApplyJump()

        Status.Text = "SUPER JUMP: ON"
        Status.TextColor3 = Color3.fromRGB(0, 255, 130)

        Toggle.Text = "DESACTIVAR SUPER JUMP"

    else

        RestoreJump()

        Status.Text = "SUPER JUMP: OFF"
        Status.TextColor3 = Color3.fromRGB(255, 90, 90)

        Toggle.Text = "ACTIVAR SUPER JUMP"

    end
end)

--==================================================
-- CHARACTER SETUP
--==================================================

local function DisconnectCharacter()

    for _, connection in ipairs(Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    Connections = {}
end

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

    table.insert(Connections,
        Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(
            function()
                if Enabled then ApplyJump() end
            end
        )
    )

    table.insert(Connections,
        Humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(
            function()
                if Enabled then ApplyJump() end
            end
        )
    )

    table.insert(Connections,
        Humanoid:GetPropertyChangedSignal("UseJumpPower"):Connect(
            function()
                UpdateInterface()
            end
        )
    )

    UpdateInterface()
end

Player.CharacterAdded:Connect(SetupCharacter)

if Player.Character then
    SetupCharacter(Player.Character)
end

--==================================================
-- MINIMIZE / RESTORE
--==================================================

local Minimized = false

Minimize.MouseButton1Click:Connect(function()

    Minimized = not Minimized

    Content.Visible = not Minimized

    if Minimized then

        Main.Size = UDim2.fromOffset(255, 40)
        Minimize.Text = "+"

    else

        Main.Size = UDim2.fromOffset(255, 190)
        Minimize.Text = "-"

    end
end)

--==================================================
-- DRAG WINDOW
--==================================================

local dragging = false
local dragStart
local startPosition

Title.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position

    end
end)

UIS.InputChanged:Connect(function(input)

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

print("[FUSION BRAINROT V6] LOADED")
