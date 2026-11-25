--==================================================
-- BRAINROT FINDER V2
-- REPLICA INSPECTOR | DELTA ANDROID
-- SOLO AUDITORIA - NO TELEPORT - NO AUTO JOIN
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

local MAX_MODULES = 100
local MAX_MODELS = 120
local MAX_LABELS_PER_MODEL = 12
local MAX_REPORT_LENGTH = 45000

local report = {}
local function add(text)
    if #report >= 1200 then return end
    report[#report + 1] = tostring(text)
end

local function safeName(obj)
    local ok, result = pcall(function()
        return obj:GetFullName()
    end)
    return ok and result or obj.Name
end

local function safeAttributes(obj)
    local result = {}
    local ok, attrs = pcall(function()
        return obj:GetAttributes()
    end)

    if ok then
        for key, value in pairs(attrs) do
            table.insert(result, key .. "=" .. tostring(value))
        end
    end

    return #result > 0 and table.concat(result, ", ") or "-"
end

local function safeText(obj)
    local ok, value = pcall(function()
        return obj.Text
    end)
    return ok and tostring(value) or ""
end

add("======================================")
add("BRAINROT FINDER V2 - REPLICA INSPECTOR")
add("Jugador: " .. (Player and Player.Name or "Desconocido"))
add("Hora: " .. os.date("%Y-%m-%d %H:%M:%S"))
add("======================================")

--==================================================
-- 1. REPLICATED STORAGE: MODULOS
--==================================================

add("")
add("========== REPLICATED STORAGE ==========")

local moduleCount = 0

local okModules, descendants = pcall(function()
    return ReplicatedStorage:GetDescendants()
end)

if okModules then
    for _, obj in ipairs(descendants) do
        if obj:IsA("ModuleScript") then
            moduleCount = moduleCount + 1

            if moduleCount <= MAX_MODULES then
                add("")
                add("[MODULE] " .. safeName(obj))

                local children = obj:GetChildren()
                for i = 1, math.min(#children, 15) do
                    local child = children[i]
                    add("  CHILD: " .. child.Name ..
                        " | " .. child.ClassName)
                end

                add("  ATTRIBUTES: " .. safeAttributes(obj))
            end
        end
    end
end

add("")
add("TOTAL MODULES: " .. moduleCount)

--==================================================
-- 2. WORKSPACE: MODELOS Y METADATA
--==================================================

add("")
add("========== WORKSPACE MODELS ==========")

local modelCount = 0
local labelCount = 0

local okWorkspace, worldObjects = pcall(function()
    return Workspace:GetDescendants()
end)

if okWorkspace then
    for _, obj in ipairs(worldObjects) do
        if obj:IsA("Model") then
            modelCount = modelCount + 1

            if modelCount <= MAX_MODELS then
                local labels = {}
                local values = {}

                local okChildren, children = pcall(function()
                    return obj:GetDescendants()
                end)

                if okChildren then
                    for _, child in ipairs(children) do

                        if child:IsA("TextLabel")
                        or child:IsA("TextButton") then

                            local txt = safeText(child)

                            if txt ~= "" then
                                table.insert(labels,
                                    child.Name .. " = " .. txt)
                            end

                        elseif child:IsA("NumberValue")
                        or child:IsA("IntValue")
                        or child:IsA("StringValue") then

                            table.insert(values,
                                child.Name .. " = " ..
                                tostring(child.Value))
                        end
                    end
                end

                if #labels > 0 or #values > 0
                or next(obj:GetAttributes()) ~= nil then

                    add("")
                    add("[MODEL] " .. safeName(obj))
                    add("  ATTRIBUTES: " .. safeAttributes(obj))

                    for i = 1, math.min(#labels,
                        MAX_LABELS_PER_MODEL) do
                        add("  TEXT: " .. labels[i])
                        labelCount = labelCount + 1
                    end

                    for i = 1, math.min(#values, 10) do
                        add("  VALUE: " .. values[i])
                    end
                end
            end
        end
    end
end

add("")
add("TOTAL MODELS VISIBLES: " .. modelCount)
add("TEXT LABELS ENCONTRADOS: " .. labelCount)

--==================================================
-- 3. INTERFACES BILLBOARD GUI
--==================================================

add("")
add("========== BILLBOARD / SURFACE GUI ==========")

local guiCount = 0

if okWorkspace then
    for _, obj in ipairs(worldObjects) do
        if obj:IsA("BillboardGui")
        or obj:IsA("SurfaceGui") then

            guiCount = guiCount + 1

            if guiCount <= 100 then
                add("")
                add("[GUI] " .. safeName(obj))

                local okGui, guiChildren = pcall(function()
                    return obj:GetDescendants()
                end)

                if okGui then
                    for _, child in ipairs(guiChildren) do
                        if child:IsA("TextLabel")
                        or child:IsA("TextButton") then

                            local txt = safeText(child)

                            if txt ~= "" then
                                add("  " .. child.Name ..
                                    " = " .. txt)
                            end
                        end
                    end
                end
            end
        end
    end
end

add("")
add("TOTAL GUI: " .. guiCount)

--==================================================
-- 4. FINALIZAR Y EXPORTAR
--==================================================

add("")
add("======================================")
add("FIN DE AUDITORIA")
add("======================================")

local output = table.concat(report, "\n")

if #output > MAX_REPORT_LENGTH then
    output = string.sub(output, 1, MAX_REPORT_LENGTH)
    output = output .. "\n[REPORTE RECORTADO POR LIMITE]"
end

print(output)

local exported = false

if type(setclipboard) == "function" then
    local ok = pcall(setclipboard, output)
    if ok then
        exported = true
    end
end

if not exported and type(writefile) == "function" then
    local ok = pcall(function()
        writefile("Brainrot_Replica_Audit.txt", output)
    end)
    if ok then
        exported = true
    end
end

if exported then
    warn("[BRAINROT FINDER] Reporte exportado.")
else
    warn("[BRAINROT FINDER] Copia/exportacion no disponible. Revisar consola.")
end

warn("[BRAINROT FINDER] Auditoria terminada.")
