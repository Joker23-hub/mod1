--==================================================
-- FUSION BRAINROT TOOLKIT V8 STEALTH
-- JUMP ONLY | DELTA ANDROID
-- VELOCITY BASED | TOGGLES SEPARADOS
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local JumpEnabled = false
local FloatEnabled = false

local Impulse = 50
local AirFactor = 0.85
local GravityPct = 55
local MaxAirJumps = math.huge

local ASCENT_TOO = false
local JUMP_DEBOUNCE = 0.10

local MIN_IMPULSE = 1
local MAX_IMPULSE = 95
local MIN_PCT = 1
local MAX_PCT = 95

local AIR_OPTIONS = {math.huge, 0, 1, 2, 3}

local Humanoid
local Original = {}
local Connections = {}
local airJumps = 0
local lastJump = 0
local gravityConn

--==================================================
-- HELPERS
--==================================================

local BLOCKED = {
[Enum.HumanoidStateType.Climbing] = true,
[Enum.HumanoidStateType.Swimming] = true,
[Enum.HumanoidStateType.Seated] = true,
[Enum.HumanoidStateType.Dead] = true,
[Enum.HumanoidStateType.PlatformStanding] = true,
[Enum.HumanoidStateType.Ragdoll] = true,
}

local function Root()

local char = Player.Character
if not char then return nil end

local hrp = char:FindFirstChild("HumanoidRootPart")

if hrp and hrp:IsDescendantOf(workspace) then
    return hrp
end

return nil

end

local function IsAirborne(hum)

if not hum then return false end
if hum.Health <= 0 then return false end
if hum.FloorMaterial ~= Enum.Material.Air then return false end
if BLOCKED[hum:GetState()] then return false end

return true

end

local function SetVertical(vel)

local hrp = Root()
if not hrp then return end

local v = hrp.AssemblyLinearVelocity

hrp.AssemblyLinearVelocity =
Vector3.new(v.X, vel, v.Z)

end

local function RaiseVelocity(target)

local hrp = Root()
if not hrp then return end

local v = hrp.AssemblyLinearVelocity

if v.Y >= target then return end

hrp.AssemblyLinearVelocity =
Vector3.new(v.X, target, v.Z)

end

local function RestoreHumanoid()

if not Humanoid then return end
if Original.Jumping == nil then return end

pcall(function()
    Humanoid:SetStateEnabled(
        Enum.HumanoidStateType.Jumping,
        Original.Jumping
    )
end)

end

--==================================================
-- FLOTACIÓN
--==================================================

local function OnPhysics(dt)

if not FloatEnabled then return end

local hum = Humanoid

if not hum or hum.Health <= 0 then return end

if hum.FloorMaterial ~= Enum.Material.Air then
    airJumps = 0
    return
end

if BLOCKED[hum:GetState()] then return end

local hrp = Root()
if not hrp then return end

local v = hrp.AssemblyLinearVelocity

if v.Magnitude > 600 then return end
if v.Y >= 0 and not ASCENT_TOO then return end

local extra =
workspace.Gravity * (GravityPct / 100) * math.min(dt, 1 / 30)

hrp.AssemblyLinearVelocity =
Vector3.new(v.X, v.Y + extra, v.Z)

end

local function StartFloat()

if gravityConn then return end

gravityConn = RunService.Heartbeat:Connect(OnPhysics)

end

local function StopFloat()

if gravityConn then
    gravityConn:Disconnect()
    gravityConn = nil
end

end

--==================================================
-- SALTO
--==================================================

UIS.JumpRequest:Connect(function()

local hum = Humanoid
if not hum or hum.Health <= 0 then return end

if IsAirborne(hum) then

    if not JumpEnabled then return end

    if MaxAirJumps ~= math.huge then
        if MaxAirJumps <= 0 then return end
        if airJumps >= MaxAirJumps then return end
    end

    local now = os.clock()
    if now - lastJump < JUMP_DEBOUNCE then return end

    airJumps += 1
    lastJump = now

    RaiseVelocity(Impulse * AirFactor)

else

    airJumps = 0

    if not JumpEnabled then return end

    lastJump = os.clock()

    hum:SetStateEnabled(
        Enum.HumanoidStateType.Jumping,
        true
    )

    hum:ChangeState(Enum.HumanoidStateType.Jumping)

    SetVertical(Impulse)

end

end)

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "FusionBrainrotV8"
Gui.ResetOnSpawn = false

local ok = pcall(function()
Gui.Parent = game:GetService("CoreGui")
end)

if not ok or not Gui.Parent then
Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(255, 252)
Main.Position = UDim2.new(0.5, -127, 0.3, 0)
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
Title.Size = UDim2.new(1, -48, 0, 38)
Title.Position = UDim2.fromOffset(5, 0)
Title.BackgroundTransparency = 1
Title.Text = "FUSION BRAINROT V8"
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

local function CreateButton(name, text, x, y, w, h, size)

local button = Instance.new("TextButton")
button.Name = name
button.Position = UDim2.fromOffset(x, y)
button.Size = UDim2.fromOffset(w, h)
button.BackgroundColor3 = Color3.fromRGB(0, 105, 175)
button.Text = text
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBold
button.TextSize = size or 15
button.Parent = Content

Instance.new("UICorner", button).CornerRadius =
    UDim.new(0, 8)

return button

end

local Status = CreateLabel(
"Status",
"JUMP: OFF   FLOT: OFF",
3, 20, 12
)

Status.TextColor3 = Color3.fromRGB(255, 90, 90)

local Value = CreateLabel(
"Value",
"IMPULSO: " .. Impulse,
25, 18, 12
)

local Minus = CreateButton(
"Minus", "-", 30, 45, 65, 30
)

local Plus = CreateButton(
"Plus", "+", 160, 45, 65, 30
)

local GravValue = CreateLabel(
"GravValue",
"FLOTACIÓN: " .. GravityPct .. "%",
80, 18, 12
)

local GravMinus = CreateButton(
"GravMinus", "-", 30, 100, 65, 30
)

local GravPlus = CreateButton(
"GravPlus", "+", 160, 100, 65, 30
)

local AirBtn = CreateButton(
"AirBtn",
"SALTOS EN AIRE: INF",
30, 134, 195, 28, 12
)

local ToggleJump = CreateButton(
"ToggleJump",
"SUPER JUMP: OFF",
30, 168, 95, 32, 11
)

local ToggleFloat = CreateButton(
"ToggleFloat",
"FLOTACIÓN: OFF",
130, 168, 95, 32, 11
)

--==================================================
-- UPDATE
--==================================================

local function AirText()

if MaxAirJumps == math.huge then
    return "SALTOS EN AIRE: INF"
end

return "SALTOS EN AIRE: " .. MaxAirJumps

end

local function UpdateInterface()

Value.Text = "IMPULSO: " .. Impulse
GravValue.Text = "FLOTACIÓN: " .. GravityPct .. "%"
AirBtn.Text = AirText()

local jumpText = JumpEnabled and "ON" or "OFF"
local floatText = FloatEnabled and "ON" or "OFF"

Status.Text = "JUMP: " .. jumpText .. "   FLOT: " .. floatText

if JumpEnabled or FloatEnabled then
    Status.TextColor3 = Color3.fromRGB(0, 255, 130)
else
    Status.TextColor3 = Color3.fromRGB(255, 90, 90)
end

ToggleJump.Text = "SUPER JUMP: " .. jumpText
ToggleFloat.Text = "FLOTACIÓN: " .. floatText

ToggleJump.BackgroundColor3 = JumpEnabled
and Color3.fromRGB(0, 160, 90)
or Color3.fromRGB(0, 105, 175)

ToggleFloat.BackgroundColor3 = FloatEnabled
and Color3.fromRGB(0, 160, 90)
or Color3.fromRGB(0, 105, 175)

end

--==================================================
-- BOTONES
--==================================================

Minus.MouseButton1Click:Connect(function()
Impulse = math.max(MIN_IMPULSE, Impulse - 1)
UpdateInterface()
end)

Plus.MouseButton1Click:Connect(function()
Impulse = math.min(MAX_IMPULSE, Impulse + 1)
UpdateInterface()
end)

GravMinus.MouseButton1Click:Connect(function()
GravityPct = math.max(MIN_PCT, GravityPct - 1)
UpdateInterface()
end)

GravPlus.MouseButton1Click:Connect(function()
GravityPct = math.min(MAX_PCT, GravityPct + 1)
UpdateInterface()
end)

AirBtn.MouseButton1Click:Connect(function()

local index = 1

for i, value in ipairs(AIR_OPTIONS) do
    if value == MaxAirJumps then
        index = i
        break
    end
end

index = (index % #AIR_OPTIONS) + 1

MaxAirJumps = AIR_OPTIONS[index]
airJumps = 0

UpdateInterface()

end)

ToggleJump.MouseButton1Click:Connect(function()

JumpEnabled = not JumpEnabled

if not JumpEnabled then
    RestoreHumanoid()
end

airJumps = 0
lastJump = 0

UpdateInterface()

end)

ToggleFloat.MouseButton1Click:Connect(function()

FloatEnabled = not FloatEnabled

if FloatEnabled then
    StartFloat()
else
    StopFloat()
end

UpdateInterface()

end)

--==================================================
-- CHARACTER
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
    Jumping = Humanoid:GetStateEnabled(
        Enum.HumanoidStateType.Jumping
    )
}

airJumps = 0
lastJump = 0

table.insert(Connections,
    Humanoid.StateChanged:Connect(function(_, newState)

        if newState == Enum.HumanoidStateType.Landed
        or newState == Enum.HumanoidStateType.Running then
            airJumps = 0
        end

    end)
)

table.insert(Connections,
    Humanoid.Died:Connect(function()
        StopFloat()
        airJumps = 0
    end)
)

if FloatEnabled then
    StartFloat()
end

UpdateInterface()

end

Player.CharacterAdded:Connect(SetupCharacter)

if Player.Character then
SetupCharacter(Player.Character)
end

--==================================================
-- MINIMIZE
--==================================================

local Minimized = false

Minimize.MouseButton1Click:Connect(function()

Minimized = not Minimized

Content.Visible = not Minimized

if Minimized then
    Main.Size = UDim2.fromOffset(255, 40)
    Minimize.Text = "+"
else
    Main.Size = UDim2.fromOffset(255, 252)
    Minimize.Text = "-"
end

end)

--==================================================
-- DRAG
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

JumpEnabled = false
FloatEnabled = false

StopFloat()
RestoreHumanoid()
DisconnectCharacter()

end)

print("[FUSION BRAINROT V8 STEALTH] LOADED")
