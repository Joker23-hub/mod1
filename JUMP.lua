--====================================================
-- FUSION BRAINROT TOOLKIT V5
-- JUMP + SPEED | DELTA ANDROID
--====================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- CONFIGURATION
local JumpEnabled = false
local SpeedEnabled = false
local CarryMode = false

local JumpPower = 55
local JumpHeight = 8.5

local NormalSpeed = 30
local CarrySpeed = 20

local MIN_SPEED = 16
local MAX_SPEED = 30
local MAX_POWER = 65
local MIN_POWER = 40
local MAX_HEIGHT = 20
local MIN_HEIGHT = 7

local Humanoid
local Original = {}
local Connections = {}

--====================================================
-- CHARACTER CONNECTIONS
--====================================================

local function DisconnectCharacter()
    for _, c in ipairs(Connections) do
        pcall(function()
            c:Disconnect()
        end)
    end
    Connections = {}
end

--====================================================
-- JUMP SYSTEM
--====================================================

local function ApplyJump()
    if not JumpEnabled or not Humanoid then return end
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
end

--====================================================
-- SPEED SYSTEM
--====================================================

local function GetTargetSpeed()
    if CarryMode then
        return CarrySpeed
    end

    return NormalSpeed
end

local function ApplySpeed()
    if not SpeedEnabled or not Humanoid then return end
    if Humanoid.Health <= 0 then return end

    local target = GetTargetSpeed()

    if Humanoid.WalkSpeed ~= target then
        Humanoid.WalkSpeed = target
    end
end

local function RestoreSpeed()
    if not Humanoid then return end

    if Original.WalkSpeed ~= nil then
        Humanoid.WalkSpeed = Original.WalkSpeed
    end
end

--====================================================
-- INTERFACE
--====================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "FusionBrainrotV5"
Gui.ResetOnSpawn = false

local ok = pcall(function()
    Gui.Parent = game:GetService("CoreGui")
end)

if not ok or not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(290, 335)
Main.Position = UDim2.new(0.5, -145, 0.35, 0)
Main.BackgroundColor3 = Color3.fromRGB(17, 19, 27)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius =
    UDim.new(0, 14)

local Border = Instance.new("UIStroke")
Border.Color = Color3.fromRGB(0, 180, 255)
Border.Thickness = 2
Border.Parent = Main

local function Label(name, text, y, height, size)
    local obj = Instance.new("TextLabel")
    obj.Name = name
    obj.Position = UDim2.fromOffset(5, y)
    obj.Size = UDim2.new(1, -10, 0, height)
    obj.BackgroundTransparency = 1
    obj.Text = text
    obj.TextColor3 = Color3.new(1, 1, 1)
    obj.Font = Enum.Font.GothamBold
    obj.TextSize = size or 13
    obj.Parent = Main
    return obj
end

local function Button(name, text, x, y, w, h)
    local b = Instance.new("TextButton")
    b.Name = name
    b.Position = UDim2.fromOffset(x, y)
    b.Size = UDim2.fromOffset(w, h)
    b.BackgroundColor3 = Color3.fromRGB(0, 105, 175)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.Parent = Main

    Instance.new("UICorner", b).CornerRadius =
        UDim.new(0, 8)

    return b
end

-- TITLE
local Title = Label(
    "Title",
    "FUSION BRAINROT TOOLKIT V5",
    8, 30, 15
)
Title.TextColor3 = Color3.fromRGB(0, 190, 255)

-- JUMP
local JumpStatus = Label(
    "JumpStatus",
    "SUPER JUMP: OFF",
    42, 23, 13
)

local JumpValue = Label(
    "JumpValue",
    "JUMP HEIGHT: 8.5",
    66, 22, 12
)

local JumpMinus = Button(
    "JumpMinus", "-", 30, 92, 55, 32
)

local JumpPlus = Button(
    "JumpPlus", "+", 205, 92, 55, 32
)

local JumpToggle = Button(
    "JumpToggle", "ACTIVAR JUMP", 30, 132, 230, 34
)

-- SPEED
local SpeedStatus = Label(
    "SpeedStatus",
    "SPEED: OFF",
    176, 22, 13
)

local SpeedValue = Label(
    "SpeedValue",
    "NORMAL SPEED: 30",
    199, 22, 12
)

local SpeedMinus = Button(
    "SpeedMinus", "-", 30, 225, 55, 32
)

local SpeedPlus = Button(
    "SpeedPlus", "+", 205, 225, 55, 32
)

local SpeedToggle = Button(
    "SpeedToggle", "ACTIVAR SPEED", 30, 265, 230, 32
)

-- CARRY MODE
local CarryToggle = Button(
    "CarryToggle", "CARRY MODE: OFF", 30, 305, 230, 25
)

CarryToggle.TextSize = 11

--====================================================
-- UPDATE INTERFACE
--====================================================

local function UpdateInterface()

    if Humanoid and Humanoid.UseJumpPower then
        JumpValue.Text = "JUMP POWER: " .. JumpPower
    else
        JumpValue.Text = "JUMP HEIGHT: " .. JumpHeight
    end

    JumpStatus.Text = JumpEnabled and
        "SUPER JUMP: ON" or "SUPER JUMP: OFF"

    JumpStatus.TextColor3 = JumpEnabled and
        Color3.fromRGB(0, 255, 130) or
        Color3.fromRGB(255, 100, 100)

    SpeedStatus.Text = SpeedEnabled and
        "SPEED: ON" or "SPEED: OFF"

    SpeedStatus.TextColor3 = SpeedEnabled and
        Color3.fromRGB(0, 255, 130) or
        Color3.fromRGB(255, 100, 100)

    SpeedValue.Text = "NORMAL: " .. NormalSpeed ..
        " | CARRY: " .. CarrySpeed

    CarryToggle.Text = CarryMode and
        "CARRY MODE: ON (20)" or
        "CARRY MODE: OFF"

    CarryToggle.BackgroundColor3 = CarryMode and
        Color3.fromRGB(0, 145, 90) or
        Color3.fromRGB(0, 105, 175)
end

--====================================================
-- JUMP CONTROLS
--====================================================

JumpMinus.MouseButton1Click:Connect(function()

    if Humanoid and Humanoid.UseJumpPower then
        JumpPower = math.max(MIN_POWER, JumpPower - 2)
    else
        JumpHeight = math.max(MIN_HEIGHT, JumpHeight - 1)
    end

    ApplyJump()
    UpdateInterface()
end)

JumpPlus.MouseButton1Click:Connect(function()

    if Humanoid and Humanoid.UseJumpPower then
        JumpPower = math.min(MAX_POWER, JumpPower + 2)
    else
        JumpHeight = math.min(MAX_HEIGHT, JumpHeight + 1)
    end

    ApplyJump()
    UpdateInterface()
end)

JumpToggle.MouseButton1Click:Connect(function()

    JumpEnabled = not JumpEnabled

    if JumpEnabled then
        ApplyJump()
        JumpToggle.Text = "DESACTIVAR JUMP"
    else
        RestoreJump()
        JumpToggle.Text = "ACTIVAR JUMP"
    end

    UpdateInterface()
end)

--====================================================
-- SPEED CONTROLS
--====================================================

SpeedMinus.MouseButton1Click:Connect(function()

    NormalSpeed = math.max(
        MIN_SPEED,
        NormalSpeed - 1
    )

    ApplySpeed()
    UpdateInterface()
end)

SpeedPlus.MouseButton1Click:Connect(function()

    NormalSpeed = math.min(
        MAX_SPEED,
        NormalSpeed + 1
    )

    ApplySpeed()
    UpdateInterface()
end)

SpeedToggle.MouseButton1Click:Connect(function()

    SpeedEnabled = not SpeedEnabled

    if SpeedEnabled then
        ApplySpeed()
        SpeedToggle.Text = "DESACTIVAR SPEED"
    else
        RestoreSpeed()
        SpeedToggle.Text = "ACTIVAR SPEED"
    end

    UpdateInterface()
end)

--====================================================
-- CARRY MODE
--====================================================

CarryToggle.MouseButton1Click:Connect(function()

    CarryMode = not CarryMode

    ApplySpeed()
    UpdateInterface()
end)

--====================================================
-- CHARACTER SETUP
--====================================================

local function SetupCharacter(Character)

    DisconnectCharacter()

    Humanoid = Character:WaitForChild("Humanoid")

    Original = {
        JumpPower = Humanoid.JumpPower,
        JumpHeight = Humanoid.JumpHeight,
        WalkSpeed = Humanoid.WalkSpeed
    }

    if JumpEnabled then
        ApplyJump()
    end

    if SpeedEnabled then
        ApplySpeed()
    end

    table.insert(Connections,
        Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(
            function()
                if JumpEnabled then ApplyJump() end
            end
        )
    )

    table.insert(Connections,
        Humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(
            function()
                if JumpEnabled then ApplyJump() end
            end
        )
    )

    table.insert(Connections,
        Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(
            function()
                if SpeedEnabled then ApplySpeed() end
            end
        )
    )

    table.insert(Connections,
        Humanoid:GetPropertyChangedSignal("UseJumpPower"):Connect(
            function()
                UpdateInterface()
                ApplyJump()
            end
        )
    )

    UpdateInterface()
end

Player.CharacterAdded:Connect(SetupCharacter)

if Player.Character then
    SetupCharacter(Player.Character)
end

--====================================================
-- FLOATING WINDOW DRAG
--====================================================

local dragging = false
local dragStart
local startPos

Title.InputBegan:Connect(function(input)

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

--====================================================
-- CLEANUP
--====================================================

Gui.Destroying:Connect(function()

    JumpEnabled = false
    SpeedEnabled = false

    RestoreJump()
    RestoreSpeed()

    DisconnectCharacter()
end)

print("[FUSION TOOLKIT V5] LOADED SUCCESSFULLY")
