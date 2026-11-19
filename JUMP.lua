--==================================================
-- FUSION BRAINROT TOOLKIT V8 - SAFE EDITION
-- SUPER JUMP + RAYOS BASES
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

--==================================================
-- CONFIGURACION
--==================================================

local Enabled = false
local SafeMode = true -- true = salto por velocidad (indetectable)

local JumpPower = 55
local JumpHeight = 8.5
local VELOCITY_JUMP = 95

local MIN_POWER = 40
local MAX_POWER = 65
local MIN_HEIGHT = 7
local MAX_HEIGHT = 20

local BaseEffectEnabled = false
local BASE_TRANSPARENCY = 0.70

local BASE_KEYWORDS = { "base", "plot", "terreno", "lote", "parcela" }

local EXCLUDED_KEYWORDS = {
    "brainrot", "pet", "egg", "tool", "character", "avatar", "npc"
}

local MAX_DEPTH = 3
local CHUNK = 150

local Humanoid
local RootPart
local Original = {}
local CharConnections = {}
local BaseConnections = {}

local AppliedParts = {}
local ScanToken = 0
local JumpGuard = false

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "FusionBrainrotV8"
Gui.ResetOnSpawn = false

local ok = pcall(function() Gui.Parent = game:GetService("CoreGui") end)
if not ok or not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(255, 320)
Main.Position = UDim2.new(0.5, -127, 0.35, 0)
Main.BackgroundColor3 = Color3.fromRGB(17, 19, 27)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

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

Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0, 7)

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Position = UDim2.fromOffset(0, 40)
Content.Size = UDim2.new(1, 0, 1, -40)
Content.BackgroundTransparency = 1
Content.Parent = Main

local function CreateLabel(text, y, height, size)
    local label = Instance.new("TextLabel")
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

local function CreateButton(text, x, y, w, h)
    local button = Instance.new("TextButton")
    button.Position = UDim2.fromOffset(x, y)
    button.Size = UDim2.fromOffset(w, h)
    button.BackgroundColor3 = Color3.fromRGB(0, 105, 175)
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.Parent = Content

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    return button
end

local Status = CreateLabel("SUPER JUMP: OFF", 3, 25, 14)
Status.TextColor3 = Color3.fromRGB(255, 90, 90)

local Value = CreateLabel("JUMP HEIGHT: 8.5", 31, 25, 13)

local Minus = CreateButton("-", 30, 65, 65, 38)
local Plus = CreateButton("+", 160, 65, 65, 38)
local Toggle = CreateButton("ACTIVAR SUPER JUMP", 30, 115, 195, 36)

local BaseStatus = CreateLabel("RAYOS BASES: OFF", 157, 23, 14)
BaseStatus.TextColor3 = Color3.fromRGB(255, 90, 90)

local BaseToggle = CreateButton("ACTIVAR RAYOS BASES", 30, 183, 195, 36)

local SafeStatus = CreateLabel("MODO SEGURO: ON", 226, 20, 12)
SafeStatus.TextColor3 = Color3.fromRGB(0, 255, 130)

local SafeToggle = CreateButton("CAMBIAR MODO", 30, 250, 195, 34)

--==================================================
-- HELPERS
--==================================================

local function ContainsKeyword(name, keywords)
    local lowerName = string.lower(name)
    for _, keyword in ipairs(keywords) do
        if string.find(lowerName, keyword, 1, true) then
            return true
        end
    end
    return false
end

local function IsBaseContainer(instance)
    if not instance:IsA("Model") and not instance:IsA("Folder") then
        return false
    end
    return ContainsKeyword(instance.Name, BASE_KEYWORDS)
end

local function FindBase(instance)
    local current = instance.Parent
    while current and current ~= Workspace do
        if IsBaseContainer(current) then return current end
        current = current.Parent
    end
    return nil
end

local function IsExcluded(instance, base)
    local current = instance.Parent
    while current and current ~= base do
        if ContainsKeyword(current.Name, EXCLUDED_KEYWORDS) then return true end
        if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
            return true
        end
        current = current.Parent
    end
    return false
end

--==================================================
-- DETECCION DE BASES (SOLO BASES, NO TODO EL MAPA)
--==================================================

local function CollectBases()
    local found = {}
    local seen = {}

    local function walk(inst, depth)
        if depth > MAX_DEPTH then return end
        for _, child in ipairs(inst:GetChildren()) do
            if IsBaseContainer(child) then
                if not seen[child] then
                    seen[child] = true
                    table.insert(found, child)
                end
            end
            walk(child, depth + 1)
        end
    end

    walk(Workspace, 1)
    return found
end

--==================================================
-- EFECTO VIDRIO
--==================================================

local function ApplyToPart(part)
    if not part:IsA("BasePart") then return end

    if AppliedParts[part] == nil then
        AppliedParts[part] = part.LocalTransparencyModifier
    end

    pcall(function()
        part.LocalTransparencyModifier = BASE_TRANSPARENCY
    end)
end

local function ScanBases()
    ScanToken += 1
    local token = ScanToken

    for _, base in ipairs(CollectBases()) do
        local count = 0

        for _, desc in ipairs(base:GetDescendants()) do
            if token ~= ScanToken or not BaseEffectEnabled then return end

            if desc:IsA("BasePart") and not IsExcluded(desc, base) then
                ApplyToPart(desc)
            end

            count += 1
            if count % CHUNK == 0 then task.wait() end
        end

        local conn = base.DescendantAdded:Connect(function(inst)
            if not BaseEffectEnabled then return end
            if not inst:IsA("BasePart") then return end
            task.defer(function()
                if not BaseEffectEnabled or not inst.Parent then return end
                local b = FindBase(inst)
                if b and not IsExcluded(inst, b) then ApplyToPart(inst) end
            end)
        end)

        table.insert(BaseConnections, conn)
    end
end

local function RestoreBases()
    ScanToken += 1

    for part, originalValue in pairs(AppliedParts) do
        if part and part.Parent then
            pcall(function()
                part.LocalTransparencyModifier = originalValue
            end)
        end
    end

    table.clear(AppliedParts)

    for _, conn in ipairs(BaseConnections) do
        pcall(function() conn:Disconnect() end)
    end

    BaseConnections = {}
end

local function SetBaseEffect(state)
    BaseEffectEnabled = state

    if BaseEffectEnabled then
        BaseStatus.Text = "RAYOS BASES: ON"
        BaseStatus.TextColor3 = Color3.fromRGB(0, 255, 130)
        BaseToggle.Text = "DESACTIVAR RAYOS BASES"
        task.spawn(ScanBases)
    else
        RestoreBases()
        BaseStatus.Text = "RAYOS BASES: OFF"
        BaseStatus.TextColor3 = Color3.fromRGB(255, 90, 90)
        BaseToggle.Text = "ACTIVAR RAYOS BASES"
    end
end

BaseToggle.MouseButton1Click:Connect(function()
    SetBaseEffect(not BaseEffectEnabled)
end)

--==================================================
-- SALTO
--==================================================

local function ApplyJump()
    if not Enabled or not Humanoid or Humanoid.Health <= 0 then return end
    if SafeMode or JumpGuard then return end

    JumpGuard = true

    if Humanoid.UseJumpPower then
        if Humanoid.JumpPower ~= JumpPower then
            Humanoid.JumpPower = JumpPower
        end
    else
        if Humanoid.JumpHeight ~= JumpHeight then
            Humanoid.JumpHeight = JumpHeight
        end
    end

    task.delay(0.15, function() JumpGuard = false end)
end

local function RestoreJump()
    if not Humanoid then return end

    if Original.JumpPower ~= nil then
        pcall(function() Humanoid.JumpPower = Original.JumpPower end)
    end

    if Original.JumpHeight ~= nil then
        pcall(function() Humanoid.JumpHeight = Original.JumpHeight end)
    end
end

local function UpdateInterface()
    if SafeMode then
        Value.Text = "SALTO VELOCIDAD: " .. VELOCITY_JUMP
    elseif Humanoid and Humanoid.UseJumpPower then
        Value.Text = "JUMP POWER: " .. JumpPower
    else
        Value.Text = "JUMP HEIGHT: " .. JumpHeight
    end

    ApplyJump()
end

--==================================================
-- BOTONES
--==================================================

Minus.MouseButton1Click:Connect(function()
    if SafeMode then
        VELOCITY_JUMP = math.max(60, VELOCITY_JUMP - 5)
    elseif Humanoid and Humanoid.UseJumpPower then
        JumpPower = math.max(MIN_POWER, JumpPower - 2)
    else
        JumpHeight = math.max(MIN_HEIGHT, JumpHeight - 1)
    end
    UpdateInterface()
end)

Plus.MouseButton1Click:Connect(function()
    if SafeMode then
        VELOCITY_JUMP = math.min(180, VELOCITY_JUMP + 5)
    elseif Humanoid and Humanoid.UseJumpPower then
        JumpPower = math.min(MAX_POWER, JumpPower + 2)
    else
        JumpHeight = math.min(MAX_HEIGHT, JumpHeight + 1)
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

    UpdateInterface()
end)

SafeToggle.MouseButton1Click:Connect(function()
    SafeMode = not SafeMode

    if SafeMode then
        RestoreJump()
        SafeStatus.Text = "MODO SEGURO: ON"
        SafeStatus.TextColor3 = Color3.fromRGB(0, 255, 130)
    else
        SafeStatus.Text = "MODO SEGURO: OFF"
        SafeStatus.TextColor3 = Color3.fromRGB(255, 200, 60)
    end

    UpdateInterface()
end)

--==================================================
-- PERSONAJE
--==================================================

local function DisconnectCharacter()
    for _, conn in ipairs(CharConnections) do
        pcall(function() conn:Disconnect() end)
    end
    CharConnections = {}
end

local function SetupCharacter(character)
    DisconnectCharacter()

    Humanoid = character:WaitForChild("Humanoid")
    RootPart = character:WaitForChild("HumanoidRootPart")

    Original = {
        JumpPower = Humanoid.JumpPower,
        JumpHeight = Humanoid.JumpHeight
    }

    table.insert(CharConnections, Humanoid.StateChanged:Connect(function(_, newState)
        if not Enabled or not SafeMode then return end
        if newState ~= Enum.HumanoidStateType.Jumping then return end
        if not RootPart or not RootPart.Parent then return end

        local velocity = RootPart.AssemblyLinearVelocity
        RootPart.AssemblyLinearVelocity = Vector3.new(velocity.X, VELOCITY_JUMP, velocity.Z)
    end))

    table.insert(CharConnections, Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(ApplyJump))
    table.insert(CharConnections, Humanoid:GetPropertyChangedSignal("JumpHeight"):Connect(ApplyJump))

    if Enabled then ApplyJump() end
    UpdateInterface()
end

Player.CharacterAdded:Connect(SetupCharacter)
if Player.Character then SetupCharacter(Player.Character) end

--==================================================
-- MINIMIZAR / ARRASTRAR
--==================================================

local Minimized = false

Minimize.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Content.Visible = not Minimized

    if Minimized then
        Main.Size = UDim2.fromOffset(255, 40)
        Minimize.Text = "+"
    else
        Main.Size = UDim2.fromOffset(255, 320)
        Minimize.Text = "-"
    end
end)

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
    if dragging and (input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
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
    BaseEffectEnabled = false
    RestoreJump()
    RestoreBases()
    DisconnectCharacter()
end)

print("[FUSION BRAINROT TOOLKIT V8] LOADED")
