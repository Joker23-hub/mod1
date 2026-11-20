--==================================================
-- FUSION BRAINROT TOOLKIT V7 STEALTH
-- JUMP ONLY | DELTA ANDROID
-- VELOCITY BASED | NO PROPIEDADES TOCADAS
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local Enabled = false

local Impulse = 55
local AirFactor = 0.85
local GravityReduction = 0.55
local MaxAirJumps = math.huge

local ASCENT_TOO = false
local JUMP_DEBOUNCE = 0.10

local MIN_IMPULSE = 25
local MAX_IMPULSE = 95
local IMPULSE_STEP = 5

local MIN_REDUCTION = 0.05
local MAX_REDUCTION = 0.85
local REDUCTION_STEP = 0.05

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

--==================================================
-- GRAVEDAD EMULADA
--==================================================

local function OnPhysics(dt)

if not Enabled then return end
if GravityReduction <= 0 then return end

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
workspace.Gravity * GravityReduction * math.min(dt, 1 / 30)

hrp.AssemblyLinearVelocity =
Vector3.new(v.X, v.Y + extra, v.Z)

end

local function StartGravity()

if gravityConn then return end

gravityConn = RunService.Heartbeat:Connect(OnPhysics)

end

local function StopGravity()

if gravityConn then
    gravityConn:Disconnect()
    gravityConn = nil
end

end

--==================================================
-- SALTO
--==================================================

UIS.JumpRequest:Connect(function()

if not Enabled then return end

local hum = Humanoid
if not hum or hum.Health <= 0 then return end

local now = os.clock()
if now - lastJump < JUMP_DEBOUNCE then return end

if IsAirborne(hum) then

    if MaxAirJumps ~= math.huge then

        if MaxAirJumps <= 0 then return end
        if airJumps >= MaxAirJumps then return end

    end

    airJumps += 1
    lastJump = now

    hum:SetStateEnabled(
        Enum.HumanoidStateType.Jumping,
        true
    )

    hum:ChangeState(Enum.HumanoidStateType.Jumping)

    SetVertical(Impulse * AirFactor)

else

    airJumps = 0
    lastJump = now

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
Gui.Name = "FusionBrainrotV7"
Gui.ResetOnSpawn = false

local ok = pcall(function()
Gui.Parent = game:GetService("CoreGui")
end)

if not ok or not Gui.Parent then
Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(255, 272)
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
Title.Text = "FUSION BRAINROT V7"
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
3, 22, 14
)

Status.TextColor3 = Color3.fromRGB(255, 90, 90)

local Value = CreateLabel(
"Value",
"IMPULSO: " .. Impulse,
27, 20, 13
)

local Minus = CreateButton(
"Minus", "-", 30, 49, 65, 34
)

local Plus = CreateButton(
"Plus", "+", 160, 49, 65, 34
)

local GravValue = CreateLabel(
"GravValue",
"FLOTACIÓN: " .. math.floor(GravityReduction * 100) .. "%",
88, 20, 13
)

local GravMinus = CreateButton(
"GravMinus", "-", 30, 110, 65, 34
)

local GravPlus = CreateButton(
"GravPlus", "+", 160, 110, 65, 34
)

local AirBtn = CreateButton(
"AirBtn",
"SALTOS EN AIRE: INF",
30, 148, 195, 30
)

AirBtn.TextSize = 13

local Toggle = CreateButton(
"Toggle", "ACTIVAR SUPER JUMP",
30, 182, 195, 38
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

GravValue.Text =
"FLOTACIÓN: " .. math.floor(GravityReduction * 100) .. "%"

AirBtn.Text = AirText()

end

--==================================================
-- BOTONES
--==================================================

Minus.MouseButton1Click:Connect(function()

Impulse = math.max(MIN_IMPULSE, Impulse - IMPULSE_STEP)
UpdateInterface()

end)

Plus.MouseButton1Click:Connect(function()

Impulse = math.min(MAX_IMPULSE, Impulse + IMPULSE_STEP)
UpdateInterface()

end)

GravMinus.MouseButton1Click:Connect(function()

GravityReduction = math.max(
MIN_REDUCTION,
GravityReduction - REDUCTION_STEP
)

UpdateInterface()

end)

GravPlus.MouseButton1Click:Connect(function()

GravityReduction = math.min(
MAX_REDUCTION,
GravityReduction + REDUCTION_STEP
)

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

Toggle.MouseButton1Click:Connect(function()

Enabled = not Enabled

if Enabled then

    airJumps = 0
    StartGravity()

    Status.Text = "SUPER JUMP: ON"
    Status.TextColor3 = Color3.fromRGB(0, 255, 130)

    Toggle.Text = "DESACTIVAR SUPER JUMP"

else

    StopGravity()
    RestoreHumanoid()

    Status.Text = "SUPER JUMP: OFF"
    Status.TextColor3 = Color3.fromRGB(255, 90, 90)

    Toggle.Text = "ACTIVAR SUPER JUMP"

end

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
        StopGravity()
    end)
)

if Enabled then
    StartGravity()
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
    Main.Size = UDim2.fromOffset(255, 272)
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

Enabled = false

StopGravity()
RestoreHumanoid()
DisconnectCharacter()

end)

print("[FUSION BRAINROT V7 STEALTH] LOADED")
