--==================================================
-- V11.1 VUELO / HOVER (CORREGIDO)
--==================================================

local FEnabled = false
local FSpeed = 45
local FForward, FBack, FLeft, FRight = false, false, false, false
local FUp, FDown = false, false
local FConn
local FBody
local FAttach
local FLastHrp

local FGui = Instance.new("ScreenGui")
FGui.Name = "FusionBrainrotFly"
FGui.ResetOnSpawn = false

local fok = pcall(function()
    FGui.Parent = game:GetService("CoreGui")
end)

if not fok or not FGui.Parent then
    FGui.Parent = Player:WaitForChild("PlayerGui")
end

local FMain = Instance.new("Frame")
FMain.Size = UDim2.fromOffset(190, 250)
FMain.Position = UDim2.new(0, 10, 0.52, 0)
FMain.BackgroundColor3 = Color3.fromRGB(14, 16, 23)
FMain.BorderSizePixel = 0
FMain.Active = true
FMain.Parent = FGui

Instance.new("UICorner", FMain).CornerRadius = UDim.new(0, 12)

local FBorder = Instance.new("UIStroke", FMain)
FBorder.Color = Color3.fromRGB(190, 0, 255)
FBorder.Thickness = 2

local FTitle = Instance.new("TextLabel")
FTitle.Size = UDim2.new(1, -34, 0, 32)
FTitle.Position = UDim2.fromOffset(5, 0)
FTitle.BackgroundTransparency = 1
FTitle.Text = "VUELO V11.1"
FTitle.TextColor3 = Color3.fromRGB(190, 0, 255)
FTitle.TextSize = 13
FTitle.Font = Enum.Font.GothamBold
FTitle.Parent = FMain

local FMin = Instance.new("TextButton")
FMin.Size = UDim2.fromOffset(26, 24)
FMin.Position = UDim2.new(1, -30, 0, 4)
FMin.BackgroundColor3 = Color3.fromRGB(110, 0, 160)
FMin.Text = "-"
FMin.TextColor3 = Color3.new(1, 1, 1)
FMin.TextSize = 18
FMin.Font = Enum.Font.GothamBold
FMin.Parent = FMain

Instance.new("UICorner", FMin).CornerRadius = UDim.new(0, 6)

local FContent = Instance.new("Frame")
FContent.Position = UDim2.fromOffset(0, 34)
FContent.Size = UDim2.new(1, 0, 1, -34)
FContent.BackgroundTransparency = 1
FContent.Parent = FMain

local function FButton(text, x, y, w, h, size)

    local b = Instance.new("TextButton")
    b.Position = UDim2.fromOffset(x, y)
    b.Size = UDim2.fromOffset(w, h)
    b.BackgroundColor3 = Color3.fromRGB(110, 0, 160)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = size or 15
    b.Parent = FContent

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    return b
end

local FStatus = Instance.new("TextLabel")
FStatus.Position = UDim2.fromOffset(5, 0)
FStatus.Size = UDim2.new(1, -10, 0, 16)
FStatus.BackgroundTransparency = 1
FStatus.Text = "ESTADO: APAGADO"
FStatus.TextColor3 = Color3.fromRGB(255, 90, 90)
FStatus.Font = Enum.Font.GothamBold
FStatus.TextSize = 11
FStatus.Parent = FContent

local FSpeedLabel = Instance.new("TextLabel")
FSpeedLabel.Position = UDim2.fromOffset(5, 18)
FSpeedLabel.Size = UDim2.new(1, -10, 0, 16)
FSpeedLabel.BackgroundTransparency = 1
FSpeedLabel.Text = "VELOCIDAD: " .. FSpeed
FSpeedLabel.TextColor3 = Color3.new(1, 1, 1)
FSpeedLabel.Font = Enum.Font.GothamBold
FSpeedLabel.TextSize = 12
FSpeedLabel.Parent = FContent

local FSMinus = FButton("-", 15, 38, 50, 26)
local FSPlus = FButton("+", 125, 38, 50, 26)

local FLeftBtn = FButton("<<", 15, 72, 50, 38)
local FUpBtn = FButton("^", 70, 72, 50, 38)
local FRightBtn = FButton(">>", 125, 72, 50, 38)
local FDownBtn = FButton("v", 70, 114, 50, 38)

local FAltUp = FButton("SUBIR", 15, 114, 50, 38, 11)
local FAltDown = FButton("BAJAR", 125, 114, 50, 38, 11)

local FHold = FButton("HOVER", 15, 158, 160, 28, 12)
local FToggle = FButton("ACTIVAR VUELO", 15, 192, 160, 30, 12)

--==================================================
-- CUERPO
--==================================================

local function DestroyBody()

    if FBody then
        pcall(function() FBody:Destroy() end)
        FBody = nil
    end

    if FAttach then
        pcall(function() FAttach:Destroy() end)
        FAttach = nil
    end
end

local function CreateBody(hrp)

    DestroyBody()

    local made = pcall(function()

        local att = Instance.new("Attachment")
        att.Parent = hrp

        local lv = Instance.new("LinearVelocity")
        lv.Attachment0 = att
        lv.RelativeTo = Enum.ActuatorRelativeTo.World
        lv.ForceLimitMode = Enum.ForceLimitMode.Magnitude
        lv.MaxForce = 1e6
        lv.Velocity = Vector3.zero
        lv.Parent = hrp

        FAttach = att
        FBody = lv
    end)

    if not made or not FBody then

        local bv = Instance.new("BodyVelocity")
        bv.Name = "FusionFly"
        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bv.P = 1250
        bv.Velocity = Vector3.zero
        bv.Parent = hrp

        FBody = bv
    end
end

--==================================================
-- MOTOR
--==================================================

local function ClearInput()

    FForward, FBack = false, false
    FLeft, FRight = false, false
    FUp, FDown = false, false
end

local function StopFly()

    if FConn then
        FConn:Disconnect()
        FConn = nil
    end

    DestroyBody()
    ClearInput()

    FLastHrp = nil

    local hum = Humanoid

    if hum and hum.Health > 0 then
        pcall(function()
            hum.PlatformStand = false
        end)
    end
end

local function FlyStep()

    if not FEnabled then return end

    local hum = Humanoid
    local hrp = Root()

    if not hrp or not hum or hum.Health <= 0 then

        FStatus.Text = "ESTADO: SIN PERSONAJE"
        FStatus.TextColor3 = Color3.fromRGB(255, 170, 0)

        DestroyBody()
        FLastHrp = nil

        return
    end

    if hrp ~= FLastHrp or not FBody or FBody.Parent ~= hrp then
        CreateBody(hrp)
        FLastHrp = hrp
    end

    if not FBody then
        FStatus.Text = "ESTADO: SIN CUERPO"
        return
    end

    pcall(function()
        hum.PlatformStand = true
    end)

    local cam = workspace.CurrentCamera
    if not cam then return end

    local look = cam.CFrame.LookVector
    local right = cam.CFrame.RightVector

    local dir = Vector3.zero

    if FForward then
        dir += Vector3.new(look.X, 0, look.Z).Unit
    end

    if FBack then
        dir -= Vector3.new(look.X, 0, look.Z).Unit
    end

    if FRight then
        dir += Vector3.new(right.X, 0, right.Z).Unit
    end

    if FLeft then
        dir -= Vector3.new(right.X, 0, right.Z).Unit
    end

    if FUp then
        dir += Vector3.yAxis
    end

    if FDown then
        dir -= Vector3.yAxis
    end

    if dir.Magnitude > 0 then
        dir = dir.Unit * FSpeed
        FStatus.Text = "ESTADO: MOVIENDO"
        FStatus.TextColor3 = Color3.fromRGB(0, 255, 130)
    else
        FStatus.Text = "ESTADO: HOVER"
        FStatus.TextColor3 = Color3.fromRGB(0, 200, 255)
    end

    FBody.Velocity = dir
end

local function StartFly()

    if FConn then
        FConn:Disconnect()
    end

    FConn = RunService.RenderStepped:Connect(FlyStep)

    FStatus.Text = "ESTADO: ACTIVO"
    FStatus.TextColor3 = Color3.fromRGB(0, 255, 130)
end

local function BindHold(button, flag)

    button.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            flag(true)
        end
    end)

    button.InputEnded:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            flag(false)
        end
    end)
end

BindHold(FUpBtn, function(v) FForward = v end)
BindHold(FLeftBtn, function(v) FLeft = v end)
BindHold(FRightBtn, function(v) FRight = v end)
BindHold(FDownBtn, function(v) FBack = v end)
BindHold(FAltUp, function(v) FUp = v end)
BindHold(FAltDown, function(v) FDown = v end)

--==================================================
-- TECLADO
--==================================================

UIS.InputBegan:Connect(function(input, processed)

    if not FEnabled or processed then return end

    if input.KeyCode == Enum.KeyCode.W then FForward = true end
    if input.KeyCode == Enum.KeyCode.S then FBack = true end
    if input.KeyCode == Enum.KeyCode.A then FLeft = true end
    if input.KeyCode == Enum.KeyCode.D then FRight = true end
    if input.KeyCode == Enum.KeyCode.Space then FUp = true end
    if input.KeyCode == Enum.KeyCode.LeftControl then FDown = true end
end)

UIS.InputEnded:Connect(function(input)

    if input.KeyCode == Enum.KeyCode.W then FForward = false end
    if input.KeyCode == Enum.KeyCode.S then FBack = false end
    if input.KeyCode == Enum.KeyCode.A then FLeft = false end
    if input.KeyCode == Enum.KeyCode.D then FRight = false end
    if input.KeyCode == Enum.KeyCode.Space then FUp = false end
    if input.KeyCode == Enum.KeyCode.LeftControl then FDown = false end
end)

--==================================================
-- BOTONES
--==================================================

FSMinus.MouseButton1Click:Connect(function()
    FSpeed = math.max(5, FSpeed - 5)
    FSpeedLabel.Text = "VELOCIDAD: " .. FSpeed
end)

FSPlus.MouseButton1Click:Connect(function()
    FSpeed = math.min(250, FSpeed + 5)
    FSpeedLabel.Text = "VELOCIDAD: " .. FSpeed
end)

FHold.MouseButton1Click:Connect(function()
    ClearInput()
end)

FToggle.MouseButton1Click:Connect(function()

    FEnabled = not FEnabled

    if FEnabled then

        StartFly()

        FToggle.Text = "DESACTIVAR VUELO"
        FToggle.BackgroundColor3 = Color3.fromRGB(0, 160, 90)

    else

        StopFly()

        FToggle.Text = "ACTIVAR VUELO"
        FToggle.BackgroundColor3 = Color3.fromRGB(110, 0, 160)

        FStatus.Text = "ESTADO: APAGADO"
        FStatus.TextColor3 = Color3.fromRGB(255, 90, 90)
    end
end)

--==================================================
-- MINIMIZAR / ARRASTRAR
--==================================================

local FMinimized = false

FMin.MouseButton1Click:Connect(function()

    FMinimized = not FMinimized

    FContent.Visible = not FMinimized

    if FMinimized then
        FMain.Size = UDim2.fromOffset(190, 32)
        FMin.Text = "+"
    else
        FMain.Size = UDim2.fromOffset(190, 250)
        FMin.Text = "-"
    end
end)

local fDragging = false
local fDragStart
local fStartPos

FTitle.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then

        fDragging = true
        fDragStart = input.Position
        fStartPos = FMain.Position
    end
end)

UIS.InputChanged:Connect(function(input)

    if fDragging and (
        input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement
    ) then

        local delta = input.Position - fDragStart

        FMain.Position = UDim2.new(
            fStartPos.X.Scale,
            fStartPos.X.Offset + delta.X,
            fStartPos.Y.Scale,
            fStartPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        fDragging = false
    end
end)

FGui.Destroying:Connect(function()

    FEnabled = false
    StopFly()
end)

print("[FUSION BRAINROT V11.1 VUELO] LOADED")
