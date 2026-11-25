--==================================================================
--  BRAINROT FINDER  |  RAREZA SECRET  > $20M/s  |  Delta
--  Juego: Roba un Brainrot (109983668079237)
--  Filtro por rareza, panel + avisos clickeables
--==================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

--========================= CONFIG =================================
local CONFIG = {
    MIN_MONEY_PER_SEC = 20000000,
    MIN_PLAYERS       = 1,
    MAX_PLAYERS       = 7,
    SCAN_WAIT         = 6,
    HOP_WAIT          = 4,
    MAX_POOL          = 100,
    MAX_RESULTS       = 60,
    TOAST_TIME        = 10,
    MAX_TOASTS        = 3,
    AUTO_JOIN         = false,
    IGNORE_OWN_JOB    = true,
    TRUST_RARITY      = true,   -- si el juego expone rareza, confia en ella sin tabla
    TOGGLE_KEY        = Enum.KeyCode.RightControl,
}
local PLACE_ID   = 109983668079237
local STATE_FILE = "brainrot_finder_state.json"
local SRC_FILE   = "brainrot_finder.lua"
--==================================================================

--==================== LISTA 1: RAREZAS PERMITIDAS =================
local RARITY_WHITELIST = {
    ["secret"] = true,
    -- ["celestial"] = true,
    -- ["godly"]     = true,
    -- ["mythic"]    = true,
}

--==================== LISTA 2: ALIAS DE RAREZA ====================
local RARITY_ALIASES = {
    ["secrets"]      = "secret",
    ["secret tier"]  = "secret",
    ["secrettier"]   = "secret",
    ["celestials"]   = "celestial",
    ["celestialtier"]= "celestial",
    ["godlys"]       = "godly",
    ["godlike"]      = "godly",
    ["mythics"]      = "mythic",
    ["mythical"]     = "mythic",
}

--============ LISTA 3: RESPALDO nombre -> valor/rareza ============
-- Solo se usa si el objeto no expone valor o rareza. Editable.
local BRAINROTS = {
    ["nuclearo dinossauro"]        = { 50000000, "secret" },
    ["chimpanzini bananini"]       = { 45000000, "secret" },
    ["bombardiro crocodilo"]       = { 40000000, "secret" },
    ["tralalero tralala"]          = { 38000000, "secret" },
    ["tung tung tung sahur"]       = { 35000000, "secret" },
    ["boneca ambalabu"]            = { 33000000, "secret" },
    ["brr brr patapim"]            = { 31000000, "secret" },
    ["cappuccino assassino"]       = { 30000000, "secret" },
    ["lirili larila"]              = { 28000000, "secret" },
    ["frigo camelo"]               = { 27000000, "secret" },
    ["orcalero orcala"]            = { 26000000, "secret" },
    ["espresso signora"]           = { 25000000, "secret" },
    ["ballerina cappuccina"]       = { 24500000, "secret" },
    ["la vacca saturno saturnita"] = { 24000000, "secret" },
    ["trippi troppi"]              = { 23500000, "secret" },
    ["bobrito bandito"]            = { 23000000, "secret" },
    ["tric trac baraboom"]         = { 22500000, "secret" },
    ["garama and madundung"]       = { 22000000, "secret" },
    ["los tralaleros"]             = { 21500000, "secret" },
    ["glorbo fruttodrillo"]        = { 21000000, "secret" },
    ["burbaloni loliloli"]         = { 20500000, "secret" },
    ["blueberrinni octopussini"]   = { 20200000, "secret" },
    ["girafa celestre"]            = { 20100000, "secret" },
}

--==================== LISTA 4: NOMBRES A IGNORAR ==================
local NAME_BLACKLIST = {
    ["brainrot"]   = true,
    ["baseplate"]  = true,
    ["spawn"]      = true,
}
--==================================================================

local HttpService     = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players         = game:GetService("Players")
local UIS             = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local player          = Players.LocalPlayer

local http = request or http_request or (syn and syn.request)
local qot  = queue_on_teleport or (syn and syn.queue_on_teleport)
local copy = setclipboard or toclipboard or (syn and syn.write_clipboard)

local function norm(s) return (tostring(s):lower():gsub("^%s+", ""):gsub("%s+$", "")) end

local function rarityKey(s)
    local k = norm(s)
    k = RARITY_ALIASES[k] or k
    k = k:gsub("^%s+", ""):gsub("%s+$", "")
    return k
end

local function fmt(n)
    if n <= 0 then return "valor desconocido" end
    if n >= 1e9 then return string.format("%.1fB/s", n / 1e9) end
    if n >= 1e6 then return string.format("%.1fM/s", n / 1e6) end
    if n >= 1e3 then return string.format("%.1fK/s", n / 1e3) end
    return tostring(n) .. "/s"
end

local state = { queue = {}, current = nil, seen = {}, results = {}, running = true, scanned = 0 }

local function loadState()
    if isfile and isfile(STATE_FILE) then
        local ok, d = pcall(function() return HttpService:JSONDecode(readfile(STATE_FILE)) end)
        if ok and type(d) == "table" then
            state.queue   = d.queue or {}
            state.current = d.current
            state.seen    = d.seen or {}
            state.results = d.results or {}
            state.scanned = d.scanned or 0
            if d.threshold then CONFIG.MIN_MONEY_PER_SEC = d.threshold end
        end
    end
end

local function save()
    if writefile then
        state.threshold = CONFIG.MIN_MONEY_PER_SEC
        pcall(function() writefile(STATE_FILE, HttpService:JSONEncode(state)) end)
    end
end

loadState()

--============================== UI ================================
local parent = (gethui and gethui()) or game:GetService("CoreGui")
local old = parent:FindFirstChild("BrainrotFinderUI")
if old then old:Destroy() end

local function new(class, props, kids)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if kids then for _, c in ipairs(kids) do c.Parent = o end end
    return o
end

local gui = new("ScreenGui", {
    Name = "BrainrotFinderUI", ResetOnSpawn = false,
    DisplayOrder = 999, IgnoreGuiInset = true, Parent = parent,
})

local panel = new("Frame", {
    Size = UDim2.fromOffset(360, 440), Position = UDim2.new(0, 40, 0, 90),
    BackgroundColor3 = Color3.fromRGB(16, 16, 24), BorderSizePixel = 0, Parent = gui,
}, {
    new("UICorner", { CornerRadius = UDim.new(0, 10) }),
    new("UIStroke", { Color = Color3.fromRGB(155, 89, 182), Thickness = 1.5 }),
})

local header = new("Frame", {
    Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(30, 20, 42),
    BorderSizePixel = 0, Parent = panel,
}, { new("UICorner", { CornerRadius = UDim.new(0, 10) }) })

new("TextLabel", {
    Size = UDim2.new(1, -80, 1, 0), Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(230, 200, 255),
    Text = "SECRET FINDER  ·  +20M/s", Parent = header,
})

local minBtn = new("TextButton", {
    Size = UDim2.fromOffset(28, 24), Position = UDim2.new(1, -66, 0, 7),
    BackgroundColor3 = Color3.fromRGB(60, 40, 80), BorderSizePixel = 0, Text = "–",
    Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.new(1, 1, 1),
    Parent = header,
}, { new("UICorner", { CornerRadius = UDim.new(0, 6) }) })

local closeBtn = new("TextButton", {
    Size = UDim2.fromOffset(28, 24), Position = UDim2.new(1, -34, 0, 7),
    BackgroundColor3 = Color3.fromRGB(120, 40, 60), BorderSizePixel = 0, Text = "×",
    Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.new(1, 1, 1),
    Parent = header,
}, { new("UICorner", { CornerRadius = UDim.new(0, 6) }) })

local body = new("Frame", {
    Size = UDim2.new(1, -20, 1, -100), Position = UDim2.fromOffset(10, 46),
    BackgroundTransparency = 1, Parent = panel,
})

local status = new("TextLabel", {
    Size = UDim2.new(1, -120, 0, 20), BackgroundTransparency = 1,
    Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = Color3.fromRGB(160, 160, 180), Text = "Iniciando...", Parent = body,
})

local thrBox = new("TextBox", {
    Size = UDim2.new(0, 110, 0, 24), Position = UDim2.new(1, -110, 0, 0),
    BackgroundColor3 = Color3.fromRGB(28, 28, 40), BorderSizePixel = 0,
    Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Color3.fromRGB(200, 255, 200),
    Text = tostring(CONFIG.MIN_MONEY_PER_SEC), PlaceholderText = "min $/s", Parent = body,
}, { new("UICorner", { CornerRadius = UDim.new(0, 6) }) })

local scroll = new("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -66), Position = UDim2.fromOffset(0, 32),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
    CanvasSize = UDim2.new(0, 0, 0, 0), Parent = body,
}, {
    new("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }),
})

local countLbl = new("TextLabel", {
    Size = UDim2.new(0, 150, 0, 22), Position = UDim2.new(1, -150, 1, -26),
    BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Color3.fromRGB(140, 140, 160),
    Text = "0 encontrados", Parent = body,
})

local toggleBtn = new("TextButton", {
    Size = UDim2.new(0, 90, 0, 22), Position = UDim2.new(0, 0, 1, -26),
    BackgroundColor3 = Color3.fromRGB(120, 40, 60), BorderSizePixel = 0,
    Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.new(1, 1, 1),
    Text = "PARAR", Parent = body,
}, { new("UICorner", { CornerRadius = UDim.new(0, 6) }) })

local function setStatus(t) status.Text = t end

local function updateToggle()
    if state.running then
        toggleBtn.Text = "PARAR"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 60)
    else
        toggleBtn.Text = "SEGUIR"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 60)
    end
end

--=========================== ARRASTRE =============================
local dragging, dragStart, startPos
header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, i.Position, panel.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    body.Visible = not minimized
    panel.Size = minimized and UDim2.fromOffset(360, 38) or UDim2.fromOffset(360, 440)
end)
closeBtn.MouseButton1Click:Connect(function() gui.Enabled = false end)

UIS.InputBegan:Connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == CONFIG.TOGGLE_KEY then gui.Enabled = not gui.Enabled end
end)

--======================== AVISOS CLICKEABLES ======================
local oldT = parent:FindFirstChild("BrainrotFinderToasts")
if oldT then oldT:Destroy() end

local tgui = new("ScreenGui", {
    Name = "BrainrotFinderToasts", ResetOnSpawn = false,
    DisplayOrder = 1000, IgnoreGuiInset = true, Parent = parent,
})

local holder = new("Frame", {
    Size = UDim2.fromOffset(310, 240), Position = UDim2.new(1, -326, 0, 60),
    BackgroundTransparency = 1, Parent = tgui,
}, { new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })

local activeToasts = {}

local function joinServer(jobId, name)
    state.running = false
    state.current = nil
    save()
    updateToggle()
    setStatus("Uniendose a " .. name .. "...")
    task.wait(0.2)
    local ok = pcall(function()
        TeleportService:TeleportToPlaceInstance(PLACE_ID, jobId, player)
    end)
    if not ok then
        setStatus("Fallo al unirse · servidor lleno o cerrado")
        state.running = true
        updateToggle()
        save()
    end
end

local function showToast(name, income, rarity, jobId, players)
    if #activeToasts >= CONFIG.MAX_TOASTS then
        local o = table.remove(activeToasts, 1)
        if o and o.Parent then o:Destroy() end
    end

    local card = new("TextButton", {
        Size = UDim2.fromOffset(310, 64), BackgroundColor3 = Color3.fromRGB(24, 18, 34),
        BorderSizePixel = 0, Text = "", AutoButtonColor = false, ClipsDescendants = true,
        Parent = holder,
    }, {
        new("UICorner", { CornerRadius = UDim.new(0, 8) }),
        new("UIStroke", { Color = Color3.fromRGB(155, 89, 182), Thickness = 1.5 }),
        new("UIScale", { Scale = 0.85 }),
    })

    new("TextLabel", {
        Size = UDim2.new(1, -18, 0, 18), Position = UDim2.fromOffset(9, 6),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.new(1, 1, 1),
        TextTruncate = Enum.TextTruncate.AtEnd, Text = name, Parent = card,
    })

    new("TextLabel", {
        Size = UDim2.new(1, -18, 0, 16), Position = UDim2.fromOffset(9, 24),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(110, 230, 130),
        Text = string.upper(rarity) .. "  ·  " .. fmt(income) .. "  ·  " .. players .. " jugadores",
        Parent = card,
    })

    new("TextLabel", {
        Size = UDim2.new(1, -18, 0, 14), Position = UDim2.fromOffset(9, 41),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(190, 160, 220),
        Text = "CLICK PARA ENTRAR AL SERVIDOR", Parent = card,
    })

    local bar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = Color3.fromRGB(155, 89, 182), BorderSizePixel = 0, Parent = card,
    })

    TweenService:Create(card.UIScale, TweenInfo.new(0.16), { Scale = 1 }):Play()
    TweenService:Create(bar, TweenInfo.new(CONFIG.TOAST_TIME, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 3) }):Play()

    card.MouseButton1Click:Connect(function()
        card:Destroy()
        joinServer(jobId, name)
    end)

    table.insert(activeToasts, card)
    task.delay(CONFIG.TOAST_TIME, function()
        for i, c in ipairs(activeToasts) do
            if c == card then table.remove(activeToasts, i) break end
        end
        if card.Parent then card:Destroy() end
    end)
end

--============================ RENDER ==============================
local function render()
    for _, c in ipairs(scroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    table.sort(state.results, function(a, b) return a.income > b.income end)

    for idx, r in ipairs(state.results) do
        if idx > CONFIG.MAX_RESULTS then break end
        local row = new("Frame", {
            Size = UDim2.new(1, -6, 0, 54), BackgroundColor3 = Color3.fromRGB(26, 22, 36),
            BorderSizePixel = 0, LayoutOrder = idx, Parent = scroll,
        }, { new("UICorner", { CornerRadius = UDim.new(0, 6) }) })

        new("TextLabel", {
            Size = UDim2.new(1, -80, 0, 18), Position = UDim2.fromOffset(8, 4),
            BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.new(1, 1, 1),
            TextTruncate = Enum.TextTruncate.AtEnd, Text = r.name, Parent = row,
        })

        new("TextLabel", {
            Size = UDim2.new(1, -80, 0, 16), Position = UDim2.fromOffset(8, 21),
            BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Color3.fromRGB(110, 230, 130),
            Text = string.upper(r.rarity) .. "   ·   " .. fmt(r.income) .. "   ·   " .. tostring(r.players) .. " jugadores",
            Parent = row,
        })

        local join = new("TextButton", {
            Size = UDim2.fromOffset(66, 20), Position = UDim2.new(1, -74, 0, 5),
            BackgroundColor3 = Color3.fromRGB(80, 50, 120), BorderSizePixel = 0,
            Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = Color3.new(1, 1, 1),
            Text = "UNIRSE", Parent = row,
        }, { new("UICorner", { CornerRadius = UDim.new(0, 5) }) })

        local cpb = new("TextButton", {
            Size = UDim2.fromOffset(66, 20), Position = UDim2.new(1, -74, 0, 29),
            BackgroundColor3 = Color3.fromRGB(45, 45, 60), BorderSizePixel = 0,
            Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Color3.fromRGB(200, 200, 210),
            Text = "copiar ID", Parent = row,
        }, { new("UICorner", { CornerRadius = UDim.new(0, 5) }) })

        join.MouseButton1Click:Connect(function() joinServer(r.jobId, r.name) end)
        cpb.MouseButton1Click:Connect(function()
            if copy then pcall(function() copy(r.jobId) end) end
            setStatus("Job ID copiado")
        end)
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, #state.results * 59)
    countLbl.Text = #state.results .. " encontrados"
end

toggleBtn.MouseButton1Click:Connect(function()
    state.running = not state.running
    if not state.running then
        state.current = nil
        setStatus("Detenido")
    else
        setStatus("Reanudando...")
    end
    updateToggle()
    save()
end)

thrBox.FocusLost:Connect(function()
    local n = tonumber((thrBox.Text:gsub("[^%d]", "")))
    if n and n > 0 then
        CONFIG.MIN_MONEY_PER_SEC = n
        save()
        setStatus("Umbral: " .. fmt(n))
    else
        thrBox.Text = tostring(CONFIG.MIN_MONEY_PER_SEC)
    end
end)

updateToggle()
render()

--========================= LECTURA DE DATOS =======================
local function readIncome(obj, fallback)
    for _, attr in ipairs({"MoneyPerSecond", "Income", "PerSecond", "Money", "Value"}) do
        local ok, v = pcall(function() return obj:GetAttribute(attr) end)
        if ok and type(v) == "number" and v > 0 then return v end
    end
    local ok2, kids = pcall(function() return obj:GetDescendants() end)
    if ok2 then
        for _, c in ipairs(kids) do
            if c:IsA("NumberValue") or c:IsA("IntValue") or c:IsA("StringValue") then
                local nm = c.Name:lower()
                if nm:find("money") or nm:find("income") or nm:find("per") then
                    local num = tonumber(c.Value)
                    if num and num > 0 then return num end
                end
            end
        end
    end
    return fallback or 0
end

local function readRarity(obj)
    for _, attr in ipairs({"Rarity", "Tier", "Category", "RarityName", "Class"}) do
        local ok, v = pcall(function() return obj:GetAttribute(attr) end)
        if ok and type(v) == "string" and v ~= "" then return rarityKey(v) end
    end
    local ok2, kids = pcall(function() return obj:GetDescendants() end)
    if ok2 then
        for _, c in ipairs(kids) do
            if c:IsA("StringValue") then
                local nm = c.Name:lower()
                if nm:find("rar") or nm:find("tier") or nm:find("categ") or nm:find("class") then
                    if c.Value ~= "" then return rarityKey(c.Value) end
                end
            end
        end
    end
    local p, depth = obj.Parent, 0
    while p and p ~= workspace and depth < 4 do
        local k = rarityKey(p.Name)
        if RARITY_WHITELIST[k] or RARITY_ALIASES[k] then return k end
        p = p.Parent
        depth = depth + 1
    end
    return nil
end

--============================= ESCANEO ============================
local function scanServer()
    local hits, seen = {}, {}
    local ok, desc = pcall(function() return workspace:GetDescendants() end)
    if not ok then return hits end

    for _, obj in ipairs(desc) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local key = norm(obj.Name)
            local entry = BRAINROTS[key]
            if not seen[key] and not NAME_BLACKLIST[key] then
                local rarity = readRarity(obj)
                if not rarity and entry then rarity = entry[2] end

                if rarity and RARITY_WHITELIST[rarity] then
                    seen[key] = true
                    local base = entry and entry[1] or 0
                    local income = readIncome(obj, base)

                    -- sin valor legible pero con rareza valida: se asume que pasa
                    local passes = income > 0 and income >= CONFIG.MIN_MONEY_PER_SEC
                    if income <= 0 and not CONFIG.TRUST_RARITY then passes = false end
                    if income <= 0 and CONFIG.TRUST_RARITY then passes = true end

                    if passes then
                        table.insert(hits, { name = obj.Name, income = income, rarity = rarity })
                    end
                end
            end
        end
    end
    table.sort(hits, function(a, b) return a.income > b.income end)
    return hits
end

local function fetchServers()
    local list, cursor = {}, nil
    repeat
        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?limit=100%s",
            PLACE_ID, cursor and ("&cursor=" .. cursor) or "")
        local ok, res = pcall(function() return http({ Url = url, Method = "GET" }) end)
        if not ok or not res or not res.Body then break end
        local okd, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
        if not okd or not data or not data.data then break end

        for _, s in ipairs(data.data) do
            if s.id and s.playing < s.maxPlayers and s.playing >= CONFIG.MIN_PLAYERS
               and s.playing <= CONFIG.MAX_PLAYERS and not state.seen[s.id]
               and not (CONFIG.IGNORE_OWN_JOB and s.id == game.JobId) then
                table.insert(list, s.id)
                if #list >= CONFIG.MAX_POOL then break end
            end
        end
        cursor = data.nextPageCursor
    until not cursor or #list >= CONFIG.MAX_POOL
    return list
end

local function queueSource()
    if not qot then return end
    local src = (debug.getinfo(1, "s").source or ""):gsub("^[=@]", "")
    local code
    if isfile and isfile(src) then code = readfile(src)
    elseif isfile and isfile(SRC_FILE) then code = readfile(SRC_FILE) end
    if code and #code > 0 then pcall(function() qot(code) end) end
end

--============================= FLUJO ==============================
if game.PlaceId ~= PLACE_ID then
    setStatus("Entrando al juego...")
    queueSource()
    pcall(function() TeleportService:Teleport(PLACE_ID, player) end)
    return
end

task.spawn(function()
    local target = state.current
    if not target and #state.queue == 0 and game.JobId ~= "" then target = game.JobId end

    if target and target == game.JobId then
        setStatus("Escaneando servidor...")
        task.wait(CONFIG.SCAN_WAIT)
        local hits = scanServer()
        state.scanned = state.scanned + 1
        state.seen[game.JobId] = true

        for _, h in ipairs(hits) do
            table.insert(state.results, 1, {
                name = h.name, income = h.income, rarity = h.rarity,
                jobId = game.JobId, players = #Players:GetPlayers(), t = os.time(),
            })
        end
        if #state.results > CONFIG.MAX_RESULTS then
            for i = #state.results, CONFIG.MAX_RESULTS + 1, -1 do state.results[i] = nil end
        end
        render()
        save()

        for _, h in ipairs(hits) do
            showToast(h.name, h.income, h.rarity, game.JobId, #Players:GetPlayers())
        end

        if #hits > 0 then
            setStatus("Encontrado: " .. hits[1].name .. " (" .. string.upper(hits[1].rarity) .. ")")
            if CONFIG.AUTO_JOIN then
                joinServer(game.JobId, hits[1].name)
                return
            end
        end
        state.current = nil
        save()
    end

    if not state.running then
        setStatus("Detenido · " .. state.scanned .. " escaneados")
        return
    end

    if #state.queue == 0 then
        setStatus("Buscando servidores...")
        state.queue = fetchServers()
        save()
        if #state.queue == 0 then
            setStatus("Sin servidores nuevos · reintento en 15s")
            task.wait(15)
            return
        end
    end

    local nxt = table.remove(state.queue, 1)
    state.current = nxt
    save()
    queueSource()
    setStatus("Saltando · " .. #state.queue .. " en cola")
    task.wait(CONFIG.HOP_WAIT)
    local ok = pcall(function() TeleportService:TeleportToPlaceInstance(PLACE_ID, nxt, player) end)
    if not ok then state.current = nil; save() end
end)
