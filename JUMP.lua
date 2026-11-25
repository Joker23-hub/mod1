local WS = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local LP = game:GetService("Players").LocalPlayer
local lines = {}
local function out(...)
    local t = {}
    for i = 1, select("#", ...) do t[#t + 1] = tostring((select(i, ...))) end
    lines[#lines + 1] = table.concat(t, " ")
end
local function norm(s) return (tostring(s):lower():gsub("[^%w]", "")) end

local function countOv()
    local n = 0
    for _, g in ipairs(WS:GetDescendants()) do
        if g.Name == "AnimalOverhead" and g:IsA("LayerCollector") then n += 1 end
    end
    return n
end

-- [1] efecto del barrido por base
out("[1] BARRIDO (carteles antes -> despues | descendientes del plot antes -> despues)")
local pf = WS:FindFirstChild("Plots")
local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
out("carteles iniciales:", countOv())
if pf then
    for _, p in ipairs(pf:GetChildren()) do
        local okp, cf = pcall(function() return p:GetPivot() end)
        if okp then
            local o1, d1 = countOv(), #p:GetDescendants()
            local t0 = os.clock()
            local ok, err = pcall(function() LP:RequestStreamAroundAsync(cf.Position, 3) end)
            local dt = os.clock() - t0
            task.wait(2)
            local o2, d2 = countOv(), #p:GetDescendants()
            out(("  base Order=%s | ok=%s%s | %.2fs | carteles %d->%d | desc %d->%d | dist %s"):format(
                tostring(p:GetAttribute("Order")), tostring(ok), ok and "" or (" err=" .. tostring(err)),
                dt, o1, o2, d1, d2,
                hrp and tostring(math.floor((cf.Position - hrp.Position).Magnitude)) or "?"))
        end
    end
end

-- [2] modelos fisicos de animales (nombre de catalogo), fuera de la cinta
out("\n[2] MODELOS FISICOS CON NOMBRE DE CATALOGO")
local names = {}
pcall(function()
    for k, d in pairs(require(RS.Datas.Animals)) do
        if type(d) == "table" then
            names[norm(k)] = true
            names[norm(d.DisplayName or k)] = true
        end
    end
end)
local rma = WS:FindFirstChild("RenderedMovingAnimals")
local total, shown = 0, 0
for _, m in ipairs(WS:GetDescendants()) do
    if m:IsA("Model") and names[norm(m.Name)] and not m:FindFirstChildOfClass("Humanoid")
        and not (rma and m:IsDescendantOf(rma)) then
        total += 1
        if shown < 8 then
            shown += 1
            local at = {}
            for k, v in pairs(m:GetAttributes()) do at[#at + 1] = k .. "=" .. tostring(v) end
            out("  ", m:GetFullName(), "{" .. table.concat(at, ", ") .. "}")
        end
    end
end
out("  total:", total)

-- [3] datos replicados
local function list(label, inst)
    local t = {}
    if inst then
        for _, c in ipairs(inst:GetChildren()) do t[#t + 1] = c.Name .. "(" .. c.ClassName .. ")" end
    end
    out(label, #t > 0 and table.concat(t, ", ") or "(vacio o no existe)")
end
out("\n[3] REPLICATEDSTORAGE")
list("Datas:", RS:FindFirstChild("Datas"))
list("Packages:", RS:FindFirstChild("Packages"))
list("Shared:", RS:FindFirstChild("Shared"))
list("Overheads:", RS:FindFirstChild("Overheads"))

local text = table.concat(lines, "\n")
pcall(function() setclipboard(text) end)
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false; gui.DisplayOrder = 999
gui.Parent = LP.PlayerGui
local box = Instance.new("TextBox")
box.Size = UDim2.new(0.9, 0, 0.7, 0); box.Position = UDim2.new(0.05, 0, 0.15, 0)
box.BackgroundColor3 = Color3.fromRGB(20, 20, 20); box.TextColor3 = Color3.new(1, 1, 1)
box.TextXAlignment = Enum.TextXAlignment.Left; box.TextYAlignment = Enum.TextYAlignment.Top
box.TextSize = 14; box.ClearTextOnFocus = false; box.MultiLine = true
box.TextEditable = false; box.Text = text; box.Parent = gui
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 100, 0, 40); close.Position = UDim2.new(0.95, -100, 0.02, 0)
close.Text = "CERRAR"; close.Parent = gui
close.MouseButton1Click:Connect(function() gui:Destroy() end)
