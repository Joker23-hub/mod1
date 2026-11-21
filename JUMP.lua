--==================================================
-- V13 VUELO (ANTI-FLAG: RAMPA + SIN PLATFORMSTAND)
--==================================================

local FPlayer = game:GetService("Players").LocalPlayer
local FUIS = game:GetService("UserInputService")
local FRun = game:GetService("RunService")

local FOn = false
local FSpeed = 25
local FCFrame = false
local FPlatform = false
local FFwd, FBack, FLeft, FRight = false, false, false, false
local FUp, FDown = false, false
local FLoop
local FBody
local FAttach
local FApplied = Vector3.zero
local FCurHrp

local function FGetChar()
    local c = FPlayer.Character
    if c and c.Parent then return c end
    return nil
end

local function FGetHum()
    local c = FGetChar()
    if not c then return nil end
    return c:FindFirstChildOfClass("Humanoid")
end

local function FGetHrp()
    local c = FGetChar()
    if not c then return nil end
    local h = c:FindFirstChild("HumanoidRootPart")
    if h and h:IsDescendantOf(workspace) then return h end
    return nil
end

local FGui = Instance.new("ScreenGui")
FGui.Name = "FusionFlyV13"
FGui.ResetOnSpawn = false
FGui.DisplayOrder = 60

local fok = pcall(function()
    FGui.Parent = game:GetService("CoreGui")
end)

if not fok or not FGui.Parent then
    FGui.Parent = FPlayer:WaitForChild("PlayerGui")
end

local FMain = Instance.new("Frame")
FMain.Size = UDim2.fromOffset(200, 330)
FMain.Position = UDim2.new(0, 8, 1, -338)
FMain.BackgroundColor3 = Color3.fromRGB(14, 16, 23)
FMain.BorderSizePixel = 0
FMain.Active = true
FMain.ZIndex = 5
FMain.Parent = FGui

Instance.new("UICorner", FMain).CornerRadius = UDim.new(0, 12)

local FBorder = Instance.new("UIStroke", FMain)
FBorder.Color = Color3.fromRGB(190, 0, 255)
FBorder.Thickness = 2

local FTitle = Instance.new("TextLabel")
FTitle.Size = UDim2.new(1, -34, 0, 32)
FTitle.Position = UDim2.fromOffset(5, 0)
FTitle.BackgroundTransparency = 1
FTitle.Text = "VUELO V13"
FTitle.TextColor3 = Color3.fromRGB(190, 0, 255)
FTitle.TextSize = 13
FTitle.Font = Enum.Font.GothamBold
FTitle.ZIndex = 6
FTitle.Parent = FMain

local FMin = Instance.new("TextButton")
FMin.Size = UDim2.fromOffset(26, 24)
FMin.Position = UDim2.new(1, -30, 0, 4)
FMin.BackgroundColor3 = Color3.fromRGB(110, 0, 160)
FMin.Text = "-"
FMin.TextColor3 = Color3.new(1, 1, 1)
FMin.TextSize = 18
FMin.Font = Enum.Font.GothamBold
FMin.ZIndex = 6
FMin.Parent = FMain

Instance.new("UICorner", FMin).CornerRadius = UDim.new(0, 6)

local FContent = Instance.new("Frame")
FContent.Position = UDim2.fromOffset(0, 34)
FContent.Size = UDim2.new(1, 0, 1, -34)
FContent.BackgroundTransparency = 1
FContent.ZIndex = 5
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
    b.ZIndex = 6
    b.Parent = FContent

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    return b
end

local FDiag = Instance.new("TextLabel")
FDiag.Position = UDim2.fromOffset(5, 0)
FDiag.Size = UDim2.new(1, -10, 0, 40)
FDiag.BackgroundTransparency = 1
FDiag.Text = "DIAG: listo"
FDiag.TextColor3 = Color3.fromRGB(255, 170, 0)
FDiag.Font = Enum.Font.GothamBold
FDiag.TextSize = 10
FDiag.TextWrapped = true
FDiag.TextYAlignment = Enum.TextYAlignment.Top
FDiag.ZIndex = 6
FDiag.Parent = FContent

local FSpeedLabel = Instance.new("TextLabel")
FSpeedLabel.Position = UDim2.fromOffset(5, 42)
FSpeedLabel.Size = UDim2.new(1, -10, 0, 16)
FSpeedLabel.BackgroundTransparency = 1
FSpeedLabel.Text = "VELOCIDAD: " .. FSpeed
FSpeedLabel.TextColor3 = Color3.new(1, 1, 1)
FSpeedLabel.Font = Enum.Font.GothamBold
FSpeedLabel.TextSize = 12
FSpeedLabel.ZIndex = 6
FSpeedLabel.Parent = FContent

local FSMinus = FButton("-", 15, 60, 55, 26)
local FSPlus = FButton("+", 130, 60, 55, 26)

local FLeftBtn = FButton("<<", 15, 92, 55, 38)
local FUpBtn = FButton("^", 72, 92, 55, 38)
local FRightBtn = FButton(">>", 130, 92, 55, 38)
local FDownBtn = FButton("v", 72, 134, 55, 38)

local FAltUp = FButton("SUBIR", 15, 134, 55, 38, 11)
local FAltDown = FButton("BAJAR", 130, 134, 55, 38, 11)

local FHold = FButton("HOVER", 15, 176, 170, 26, 12)

local FMode = FButton("MODO: FISICA", 15, 206, 82, 24, 10)
local FPlat = FButton("PLATFORM: OFF", 103, 206, 82, 24, 10)

local FToggle = FButton("ACTIVAR VUELO", 15, 234, 170, 28, 12)
local FTest = FButton("PROBAR", 15, 266, 170, 20, 11)

--==================================================
-- CUERPO
--==================================================

local function FDestroyBody()

    if FBody then
        pcall(function() FBody:Destroy() end)
        FBody = nil
    end

    if FAttach then
        pcall(function() FAttach:Destroy() end)
        FAttach = nil
    end
end

local function FCreateBody(hrp)

    FDestroyBody()

    local made = pcall(function()

        local att = Instance.new("Attachment")
        att.Parent = hrp

        local lv = Instance.new("LinearVelocity")
        lv.Attachment0 = att
        lv.RelativeTo = Enum.ActuatorRelativeTo.World
        lv.MaxForce = 45000
        lv.Velocity = Vector3.zero
        lv.Parent = hrp

        FAttach = att
        FBody = lv
    end)

    if not made or not FBody then

        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(45000, 45000, 45000)
        bv.P = 900
        bv.Velocity = Vector3.zero
        bv.Parent = hrp

        FBody = bv
    end
end

--==================================================
-- MOTOR
--==================================================

local function FClearInput()
    FFwd, FBack = false, false
    FLeft, FRight = false, false
    FUp, FDown = false, false
end

local function FStop()

    if FLoop then
        FLoop:Disconnect()
        FLoop = nil
    end

    FDestroyBody()
    FClearInput()

    FApplied = Vector3.zero

    local hum = FGetHum()

    if hum and hum.Health > 0 and FPlatform then
        pcall(function() hum.PlatformStand = false end)
    end

    FCurHrp = nil
end

local function FDirection()

    local cam = workspace.CurrentCamera
    if not cam then return Vector3.zero end

    local look = cam.CFrame.LookVector
    local right = cam.CFrame.RightVector

    local dir = Vector3.zero

    if FFwd then dir += Vector3.new(look.X, 0, look.Z).Unit end
    if FBack then dir -= Vector3.new(look.X, 0, look.Z).Unit end
    if FRight then dir += Vector3.new(right.X, 0, right.Z).Unit end
    if FLeft then dir -= Vector3.new(right.X, 0, right.Z).Unit end
    if FUp then dir += Vector3.yAxis end
    if FDown then dir -= Vector3.yAxis end

    if dir.Magnitude > 0 then
        return dir.Unit * FSpeed
    end

    return Vector3.zero
end

local function FStep(dt)

    if not FOn then return end

    local hum = FGetHum()
    local hrp = FGetHrp()

    if not hum or not hrp or hum.Health <= 0 then
        FDiag.Text = "DIAG: sin personaje / HRP"
        FDestroyBody()
        FCurHrp = nil
        return
    end

    if hrp ~= FCurHrp then
        FCurHrp = hrp
        FCreateBody(hrp)
    end

    if FPlatform then
        pcall(function() hum.PlatformStand = true end)
    end

    local target = FDirection()

    local factor = math.min(dt * 9, 1)

    FApplied = FApplied:Lerp(target, factor)

    if target.Magnitude == 0 and FApplied.Magnitude < 0.6 then
        FApplied = Vector3.zero
    end

    if FCFrame then

        if FApplied.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + FApplied * dt
        end

        pcall(function()
            hrp.AssemblyLinearVelocity = FApplied
        end)

    else

        if FBody then
            FBody.Velocity = FApplied
        end
    end

    FDiag.Text = "DIAG: OK | " ..
        (FCFrame and "CFRAME" or "FISICA") ..
        " | plat=" .. tostring(FPlatform) ..
        " | vel=" .. string.format("%.1f", FApplied.Magnitude)
end

local function FStart()

    if FLoop then FLoop:Disconnect() end

    FApplied = Vector3.zero

    FLoop = FRun.RenderStepped:Connect(FStep)
    FDiag.Text = "DIAG: bucle activo"
end

local function FBind(button, flag)

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

FBind(FUpBtn, function(v) FFwd = v end)
FBind(FLeftBtn, function(v) FLeft = v end)
FBind(FRightBtn, function(v) FRight = v end)
FBind(FDownBtn, function(v) FBack = v end)
FBind(FAltUp, function(v) FUp = v end)
FBind(FAltDown, function(v) FDown = v end)

--==================================================
-- BOTONES
--==================================================

FSMinus.MouseButton1Click:Connect(function()
    FSpeed = math.max(5, FSpeed - 5)
    FSpeedLabel.Text = "VELOCIDAD: " .. FSpeed
end)

FSPlus.MouseButton1Click:Connect(function()
    FSpeed = math.min(150, FSpeed + 5)
    FSpeedLabel.Text = "VELOCIDAD: " .. FSpeed
end)

FHold.MouseButton1Click:Connect(function()
    FClearInput()
end)

FMode.MouseButton1Click:Connect(function()

    FCFrame = not FCFrame

    FMode.Text = "MODO: " .. (FCFrame and "CFRAME" or "FISICA")
end)

FPlat.MouseButton1Click:Connect(function()

    FPlatform = not FPlatform

    FPlat.Text = "PLATFORM: " .. (FPlatform and "ON" or "OFF")

    local hum = FGetHum()

    if hum and hum.Health > 0 and not FPlatform then
        pcall(function() hum.PlatformStand = false end)
    end
end)

FTest.MouseButton1Click:Connect(function()

    local char = FGetChar()
    local hum = FGetHum()
    local hrp = FGetHrp()

    local parts = {}

    table.insert(parts, "char=" .. (char and "si" or "NO"))
    table.insert(parts, "hum=" .. (hum and "si" or "NO"))
    table.insert(parts, "hrp=" .. (hrp and "si" or "NO"))

    if hrp then
        table.insert(parts, "anchor=" .. tostring(hrp.Anchored))
    end

    FDiag.Text = "DIAG: " .. table.concat(parts, " | ")
end)

FToggle.MouseButton1Click:Connect(function()

    FOn = not FOn

    if FOn then

        FStart()

        FToggle.Text = "DESACTIVAR VUELO"
        FToggle.BackgroundColor3 = Color3.fromRGB(0, 160, 90)

    else

        FStop()

        FToggle.Text = "ACTIVAR VUELO"
        FToggle.BackgroundColor3 = Color3.fromRGB(110, 0, 160)

        FDiag.Text = "DIAG: apagado"
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
        FMain.Size = UDim2.fromOffset(200, 32)
        FMin.Text = "+"
    else
        FMain.Size = UDim2.fromOffset(200, 330)
        FMin.Text = "-"
    end
end)

local fDrag = false
local fStart
local fPos

FTitle.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        fDrag = true
        fStart = input.Position
        fPos = FMain.Position
    end
end)

FUIS.InputChanged:Connect(function(input)

    if fDrag and (
        input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement
    ) then

        local delta = input.Position - fStart

        FMain.Position = UDim2.new(
            fPos.X.Scale,
            fPos.X.Offset + delta.X,
            fPos.Y.Scale,
            fPos.Y.Offset + delta.Y
        )
    end
end)

FUIS.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        fDrag = false
    end
end)

FGui.Destroying:Connect(function()

    FOn = false
    FStop()
end)

print("[FUSION BRAINROT V13 VUELO] LOADED")
