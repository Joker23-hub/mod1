local CONFIG = {
    MIN_GEN = 20e6,   -- umbral de ingreso por segundo
    ESP = true,       -- marca los hallazgos sobre el animal
    SWEEP = true,     -- pide cargar cada base para cubrir todo el servidor
    SWEEP_WAIT = 1.5, -- segundos de espera tras pedir cada zona
    TOP = 5,          -- mejores N a mostrar aunque no lleguen al umbral
}

local WS = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local LP = game:GetService("Players").LocalPlayer

local lines = {}
local function out(...)
    local t = {}
    for i = 1, select("#", ...) do t[#t + 1] = tostring((select(i, ...))) end
    lines[#lines + 1] = table.concat(t, " ")
end

local SUF = {K=1e3, M=1e6, B=1e9, T=1e12, QA=1e15, QI=1e18, SX=1e21, SP=1e24, OC=1e27, NO=1e30, DC=1e33}
local badSuffix = {}
local function parseGen(text)
    local clean = tostring(text):gsub(",", "")
    local num, suf = clean:match("([%d%.]+)%s*(%a*)%s*/%s*s")
    num = tonumber(num)
    if not num then return nil end
    if suf == "" then return num end
    local m = SUF[suf:upper()]
    if not m then badSuffix[suf] = true return nil end
    return num * m
end
local function fmt(n)
    for _, u in ipairs({{1e12,"T"},{1e9,"B"},{1e6,"M"},{1e3,"K"}}) do
        if n >= u[1] then return string.format("%.2f%s", n / u[1], u[2]) end
    end
    return tostring(n)
end
local function norm(s) return (tostring(s):lower():gsub("[^%w]", "")) end
local function visible(o)
    while o and o ~= WS do
        if o:IsA("GuiObject") and not o.Visible then return false end
        if o:IsA("LayerCollector") and not o.Enabled then return false end
        o = o.Parent
    end
    return true
end
local function lbl(gui, n)
    local l = gui:FindFirstChild(n, true)
    if l and l:IsA("TextLabel") then return l.Text, visible(l) end
end

-- catalogo (solo para comparar, el cartel manda)
local cat = {}
pcall(function()
    for k, d in pairs(require(RS.Datas.Animals)) do
        if type(d) == "table" then
            local g = tonumber(d.Generation) or 0
            cat[norm(k)] = g
            cat[norm(d.DisplayName or k)] = g
        end
    end
end)

-- estado en pantalla
local sg = Instance.new("ScreenGui")
sg.Name = "BF_STATUS"; sg.ResetOnSpawn = false; sg.DisplayOrder = 998
sg.Parent = LP.PlayerGui
local st = Instance.new("TextLabel")
st.Size = UDim2.new(0, 360, 0, 36); st.Position = UDim2.new(0.5, -180, 0, 8)
st.BackgroundColor3 = Color3.fromRGB(20, 20, 20); st.TextColor3 = Color3.new(1, 1, 1)
st.TextScaled = true; st.Text = "Escaneando..."; st.Parent = sg

-- escaneo (acumula, porque con streaming las zonas se descargan)
local entries = {}
local function scan()
    for _, g in ipairs(WS:GetDescendants()) do
        if g.Name == "AnimalOverhead" and g:IsA("LayerCollector") then
            local gt, gv = lbl(g, "Generation")
            local gen = gv and gt and parseGen(gt)
            if gen then
                local part = g.Adornee or g.Parent
                if part and part:IsA("BasePart") then
                    local name = lbl(g, "DisplayName") or "?"
                    local rar, rv = lbl(g, "Rarity")
                    local mut, mv = lbl(g, "Mutation")
                    local stol, sv = lbl(g, "Stolen")
                    entries[g] = {
                        name = name, rarity = (rv and rar) or "?", gen = gen,
                        mut = (mv and mut) or "-", stolen = sv and stol or nil,
                        part = part, pos = part.Position,
                    }
                end
            end
        end
    end
end

-- barrido de bases
local function plotCenters()
    local list = {}
    local pf = WS:FindFirstChild("Plots")
    if pf then
        for _, p in ipairs(pf:GetChildren()) do
            local ok, cf = pcall(function() return p:GetPivot() end)
            if ok then list[#list + 1] = {order = p:GetAttribute("Order"), pos = cf.Position} end
        end
    end
    return list
end

scan()
if CONFIG.SWEEP then
    local centers = plotCenters()
    for i, c in ipairs(centers) do
        st.Text = ("Cargando base %d/%d..."):format(i, #centers)
        local ok, err = pcall(function() LP:RequestStreamAroundAsync(c.pos, 3) end)
        if not ok and i == 1 then out("[aviso] RequestStreamAroundAsync fallo:", tostring(err)) end
        task.wait(CONFIG.SWEEP_WAIT)
        scan()
    end
end

-- ubicacion: podio / cinta / otro (usando Order del plot, sin dueños)
local podiums = {}
local pf = WS:FindFirstChild("Plots")
if pf then
    for _, p in ipairs(pf:GetChildren()) do
        local pod = p:FindFirstChild("AnimalPodiums")
        if pod then
            for _, m in ipairs(pod:GetChildren()) do
                local ok, cf = pcall(function() return m:GetPivot() end)
                if ok then podiums[#podiums + 1] = {order = p:GetAttribute("Order"), name = m.Name, pos = cf.Position} end
            end
        end
    end
end
local belt = {}
local rma = WS:FindFirstChild("RenderedMovingAnimals")
if rma then
    for _, m in ipairs(rma:GetChildren()) do
        local ok, cf = pcall(function() return m:GetPivot() end)
        if ok then belt[#belt + 1] = cf.Position end
    end
end
local function locate(pos)
    local bd, bp
    for _, p in ipairs(podiums) do
        local d = (p.pos - pos).Magnitude
        if not bd or d < bd then bd, bp = d, p end
    end
    if bp and bd < 14 then return ("base %s podio %s"):format(tostring(bp.order), bp.name) end
    for _, b in ipairs(belt) do
        if (b - pos).Magnitude < 14 then return "cinta" end
    end
    return "otro"
end

-- resultados
local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local all = {}
for _, r in pairs(entries) do
    if r.part and r.part.Parent then
        r.pos = r.part.Position
        r.where = locate(r.pos)
        r.dist = hrp and math.floor((r.pos - hrp.Position).Magnitude) or "?"
        local base = cat[norm(r.name)]
        r.mult = (base and base > 0) and (r.gen / base) or nil
        all[#all + 1] = r
    end
end
table.sort(all, function(a, b) return a.gen > b.gen end)

local function line(i, r)
    local note = ""
    if r.mult and r.mult > 1.05 then note = string.format(" x%.2f", r.mult) end
    if r.mut == "-" and r.mult and r.mult > 1.05 then note = note .. " +mod?" end
    out(string.format("%d. %s | %s | mut:%s | %s/s%s | %s | %s studs%s",
        i, r.name, r.rarity, r.mut, fmt(r.gen), note, r.where, tostring(r.dist),
        r.stolen and " | STOLEN" or ""))
end

out("Carteles validos encontrados:", #all)
for s in pairs(badSuffix) do out("SUFIJO DESCONOCIDO:", s) end

out("\n=== SOBRE EL UMBRAL (>= " .. fmt(CONFIG.MIN_GEN) .. "/s) ===")
local hits = 0
for _, r in ipairs(all) do
    if r.gen >= CONFIG.MIN_GEN then hits += 1; line(hits, r) end
end
if hits == 0 then out("(ninguno)") end

out("\n=== TOP " .. CONFIG.TOP .. " ===")
for i = 1, math.min(CONFIG.TOP, #all) do line(i, all[i]) end

-- ESP
local old = LP.PlayerGui:FindFirstChild("BF_ESP")
if old then old:Destroy() end
local esp = Instance.new("ScreenGui")
esp.Name = "BF_ESP"; esp.ResetOnSpawn = false; esp.DisplayOrder = 50
esp.Parent = LP.PlayerGui
if CONFIG.ESP then
    for _, r in ipairs(all) do
        if r.gen >= CONFIG.MIN_GEN then
            local b = Instance.new("BillboardGui")
            b.Adornee = r.part; b.AlwaysOnTop = true
            b.Size = UDim2.new(0, 240, 0, 56); b.StudsOffset = Vector3.new(0, 5, 0)
            b.Parent = esp
            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1
            t.TextColor3 = Color3.fromRGB(255, 215, 0); t.TextStrokeTransparency = 0
            t.TextScaled = true
            t.Text = r.name .. "\n" .. fmt(r.gen) .. "/s"
            t.Parent = b
        end
    end
end

sg:Destroy()
local text = table.concat(lines, "\n")
pcall(function() setclipboard(text) end)
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false; gui.DisplayOrder = 999
gui.Parent = LP.PlayerGui
local box = Instance.new("TextBox")
box.Size = UDim2.new(0.9, 0, 0.6, 0); box.Position = UDim2.new(0.05, 0, 0.2, 0)
box.BackgroundColor3 = Color3.fromRGB(20, 20, 20); box.TextColor3 = Color3.new(1, 1, 1)
box.TextXAlignment = Enum.TextXAlignment.Left; box.TextYAlignment = Enum.TextYAlignment.Top
box.TextSize = 14; box.ClearTextOnFocus = false; box.MultiLine = true
box.TextEditable = false; box.Text = text; box.Parent = gui
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 100, 0, 40); close.Position = UDim2.new(0.95, -100, 0.02, 0)
close.Text = "CERRAR"; close.Parent = gui
close.MouseButton1Click:Connect(function() gui:Destroy() end)
