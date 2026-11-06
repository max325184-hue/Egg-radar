-- EGG RADAR v2.2 - interface demonstrativa para Roblox Android
-- So analisa nomes de objetos replicados ao cliente. Nao detecta outros servidores
-- nem confirma raridade. O ciclo de 4 minutos e um temporizador manual.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")

local function getGuiParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    local ok, result = pcall(function() return game:GetService("CoreGui") end)
    if ok and result then return result end
    return player:WaitForChild("PlayerGui")
end

local root = getGuiParent()
pcall(function()
    local old = root:FindFirstChild("EggRadar")
    if old then old:Destroy() end
end)

local function make(class, props, parent)
    local ok, obj = pcall(function()
        local x = Instance.new(class)
        for k, v in pairs(props or {}) do x[k] = v end
        x.Parent = parent
        return x
    end)
    if ok then return obj end
end

local gui = make("ScreenGui", {
    Name = "EggRadar", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999
}, root)
if not gui then
    warn("[EGG RADAR] Nao foi possivel criar a interface neste ambiente.")
    return
end

local main = make("Frame", {
    Name = "Main", AnchorPoint = Vector2.new(.5, .5),
    Size = UDim2.new(.94, 0, .72, 0), Position = UDim2.new(.5, 0, .5, 0),
    BackgroundColor3 = Color3.fromRGB(16, 12, 24), BorderSizePixel = 0
}, gui)
make("UISizeConstraint", {MinSize = Vector2.new(275, 300), MaxSize = Vector2.new(650, 550)}, main)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, main)
make("UIStroke", {Color = Color3.fromRGB(140, 75, 195), Thickness = 1.5}, main)

local header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 46),
    BackgroundColor3 = Color3.fromRGB(39, 23, 56), BorderSizePixel = 0
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, header)
make("TextLabel", {
    Size = UDim2.new(1, -85, 1, 0), Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1, Text = "EGG RADAR v2.2",
    TextColor3 = Color3.fromRGB(230, 205, 255),
    Font = Enum.Font.GothamBold, TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left
}, header)

local function round(obj)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, obj)
    return obj
end

local close = round(make("TextButton", {
    Size = UDim2.fromOffset(32, 30), Position = UDim2.new(1, -40, 0, 8),
    BackgroundColor3 = Color3.fromRGB(110, 55, 155), Text = "X",
    TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 14
}, header))

local body = make("Frame", {
    Position = UDim2.fromOffset(0, 46), Size = UDim2.new(1, 0, 1, -46),
    BackgroundTransparency = 1
}, main)

local sidebar = make("ScrollingFrame", {
    Size = UDim2.new(0, 108, 1, 0), BackgroundColor3 = Color3.fromRGB(27, 19, 39),
    BorderSizePixel = 0, ScrollBarThickness = 3,
    AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new()
}, body)
local sideLayout = make("UIListLayout", {
    Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder
}, sidebar)
make("UIPadding", {
    PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 6),
    PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8)
}, sidebar)

local content = make("Frame", {
    Position = UDim2.new(0, 108, 0, 0), Size = UDim2.new(1, -108, 1, 0),
    BackgroundTransparency = 1
}, body)

local pages = {}
local function page(name)
    local p = make("ScrollingFrame", {
        Name = name, Size = UDim2.new(1, -14, 1, -14), Position = UDim2.fromOffset(7, 7),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Visible = false
    }, content)
    make("UIListLayout", {Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder}, p)
    make("UIPadding", {PaddingBottom = UDim.new(0, 8), PaddingRight = UDim.new(0, 4)}, p)
    pages[name] = p
    return p
end

local function label(parent, text, height)
    local l = make("TextLabel", {
        Size = UDim2.new(1, -3, 0, height or 44), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(40, 28, 57), BorderSizePixel = 0,
        Text = text, TextColor3 = Color3.fromRGB(240, 230, 248),
        Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center
    }, parent)
    round(l)
    make("UIPadding", {
        PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)
    }, l)
    return l
end

local function button(parent, text, callback)
    local b = round(make("TextButton", {
        Size = UDim2.new(1, -3, 0, 36), BackgroundColor3 = Color3.fromRGB(105, 54, 151),
        BorderSizePixel = 0, Text = text, TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold, TextSize = 11, TextWrapped = true
    }, parent))
    b.MouseButton1Click:Connect(function()
        local ok, err = pcall(callback)
        if not ok then warn("[EGG RADAR] " .. tostring(err)) end
    end)
    return b
end

local function textbox(parent, hint)
    local t = round(make("TextBox", {
        Size = UDim2.new(1, -3, 0, 36), BackgroundColor3 = Color3.fromRGB(40, 28, 57),
        BorderSizePixel = 0, PlaceholderText = hint, Text = "", ClearTextOnFocus = false,
        TextColor3 = Color3.new(1, 1, 1), PlaceholderColor3 = Color3.fromRGB(185, 165, 198),
        Font = Enum.Font.Gotham, TextSize = 11
    }, parent))
    return t
end

local home = page("Início")
label(home, "PAINEL PRINCIPAL", 32)
local homeStatus = label(home, "v2.2 carregado. A busca examina somente nomes de objetos replicados ao cliente.", 65)

local eggs = page("Ovos")
label(eggs, "RADAR DE OVOS", 32)
local eggStatus = label(eggs, "Aguardando busca.", 40)
local eggList = label(eggs, "Nenhum resultado ainda.", 90)

local pets = page("Pets raros")
label(pets, "PETS E NOMES DE RARIDADE", 32)
local petStatus = label(pets, "Aguardando busca.", 40)
local petList = make("ScrollingFrame", {
    Size = UDim2.new(1, -3, 0, 190), BackgroundColor3 = Color3.fromRGB(30, 21, 42),
    BorderSizePixel = 0, ScrollBarThickness = 4,
    AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new()
}, pets)
round(petList)
make("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, petList)
make("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5),
    PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5)}, petList)

local function clearPetResults()
    for _, child in ipairs(petList:GetChildren()) do
        if child:IsA("GuiObject") and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
end

local function addPetResult(petName, serverId)
    local row = make("Frame", {
        Size = UDim2.new(1, -4, 0, 68), BackgroundColor3 = Color3.fromRGB(48, 32, 65),
        BorderSizePixel = 0
    }, petList)
    round(row)
    make("TextLabel", {
        Size = UDim2.new(1, -8, 0, 27), Position = UDim2.fromOffset(5, 2),
        BackgroundTransparency = 1, Text = petName .. "  |  servidor registrado",
        TextColor3 = Color3.fromRGB(245, 230, 255), Font = Enum.Font.GothamBold,
        TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left
    }, row)
    local join = round(make("TextButton", {
        Size = UDim2.new(1, -10, 0, 30), Position = UDim2.fromOffset(5, 33),
        BackgroundColor3 = Color3.fromRGB(105, 54, 151), BorderSizePixel = 0,
        Text = "TENTAR ENTRAR NO SERVIDOR", TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold, TextSize = 9
    }, row))
    join.MouseButton1Click:Connect(function()
        if serverId == "" then
            petStatus.Text = "JobId do servidor não disponível."
            return
        end
        petStatus.Text = "Tentando entrar no servidor registrado..."
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, player)
        end)
        if not ok then
            petStatus.Text = "Falha no teleporte: " .. tostring(err)
        else
            petStatus.Text = "Pedido enviado. O Roblox/Delta ainda pode recusar."
        end
    end)
end

local esp = page("ESP")
label(esp, "DESTAQUE VISUAL", 32)
label(esp, "ESP nao ativado: precisamos confirmar os objetos corretos do jogo antes de marcar elementos. Esta versao evita mostrar marcacoes falsas.", 90)

local servers = page("Servidores")
label(servers, "SERVIDOR ATUAL", 32)
local jobLabel = label(servers, "JobId: " .. tostring(game.JobId), 55)
button(servers, "COPIAR JOB ID", function()
    local ok = false
    if type(setclipboard) == "function" then ok = pcall(setclipboard, tostring(game.JobId)) end
    jobLabel.Text = ok and ("Copiado: " .. tostring(game.JobId))
        or ("Clipboard indisponivel. JobId: " .. tostring(game.JobId))
end)
label(servers, "TENTAR ENTRAR EM OUTRO SERVIDOR", 38)
local jobBox = textbox(servers, "Cole o JobId")
button(servers, "TENTAR TELEPORTAR", function()
    local id = jobBox.Text:gsub("%s+", "")
    if id == "" then jobLabel.Text = "Cole um JobId primeiro." return end
    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, id, player)
    end)
    jobLabel.Text = ok and "Pedido enviado; o Roblox pode recusar."
        or ("Falha: " .. tostring(err))
end)
label(servers, "JobId identifica uma instancia, mas nao revela quais pets estao nela.", 52)

local timerPage = page("Temporizador")
label(timerPage, "TEMPORIZADOR MANUAL DE 4 MINUTOS", 42)
local timerText = label(timerPage, "04:00", 54)
local timerStatus = label(timerPage, "Parado. Inicie para acompanhar o ciclo observado.", 45)
local running, timerId = false, 0
button(timerPage, "INICIAR / REINICIAR 4 MIN", function()
    timerId = timerId + 1
    local id = timerId
    running = true
    timerStatus.Text = "Contagem em andamento."
    task.spawn(function()
        local finish = os.clock() + 240
        while running and timerId == id and gui.Parent do
            local left = math.max(0, math.ceil(finish - os.clock()))
            timerText.Text = string.format("%02d:%02d", math.floor(left / 60), left % 60)
            if left == 0 then
                running = false
                timerStatus.Text = "Quatro minutos completos. Confira o jogo."
                break
            end
            task.wait(.3)
        end
    end)
end)
button(timerPage, "PARAR E ZERAR", function()
    running = false
    timerId = timerId + 1
    timerText.Text = "04:00"
    timerStatus.Text = "Temporizador parado."
end)

local historyPage = page("Histórico")
label(historyPage, "HISTORICO DESTA SESSAO", 32)
local history = label(historyPage, "Sem registros.", 90)
local historyRows = {}
local function log(message)
    table.insert(historyRows, 1, os.date("%H:%M:%S") .. " | " .. message)
    while #historyRows > 12 do table.remove(historyRows) end
    history.Text = table.concat(historyRows, "\n")
end

local settings = page("Configurações")
label(settings, "CONFIGURACOES", 32)
label(settings, "Tema preto e roxo | Idioma portugues | Busca manual local.", 52)
button(settings, "FECHAR MENU", function() gui:Destroy() end)

local function scan()
    homeStatus.Text = "Analisando objetos do Workspace..."
    task.spawn(function()
        local ok, objects = pcall(function() return workspace:GetDescendants() end)
        if not ok then
            homeStatus.Text = "Nao foi possivel ler objetos: " .. tostring(objects)
            return
        end
        local eggNames, petNames = {}, {}
        local eggSeen, petSeen = {}, {}
        local count = 0
        for _, obj in ipairs(objects) do
            count = count + 1
            if count > 10000 then break end
            local name = tostring(obj.Name or "")
            local low = string.lower(name)
            if (string.find(low, "egg", 1, true) or string.find(low, "ovo", 1, true))
                and not eggSeen[name] then
                eggSeen[name] = true
                table.insert(eggNames, name)
            end
            if (string.find(low, "pet", 1, true) or string.find(low, "rare", 1, true)
                or string.find(low, "legend", 1, true) or string.find(low, "myth", 1, true))
                and not petSeen[name] then
                petSeen[name] = true
                table.insert(petNames, name)
            end
        end
        table.sort(eggNames)
        table.sort(petNames)
        local function format(items)
            if #items == 0 then return "Nenhum nome correspondente encontrado no Workspace do cliente." end
            local rows = {}
            for i = 1, math.min(#items, 28) do rows[#rows + 1] = "- " .. items[i] end
            if #items > 28 then rows[#rows + 1] = "... e mais " .. (#items - 28) end
            return table.concat(rows, "\n")
        end
        eggList.Text = format(eggNames)
        clearPetResults()
        if #petNames == 0 then
            make("TextLabel", {
                Size = UDim2.new(1, -4, 0, 42), BackgroundTransparency = 1,
                Text = "Nenhum nome correspondente encontrado nesta busca.",
                TextColor3 = Color3.fromRGB(230, 215, 240), Font = Enum.Font.Gotham,
                TextSize = 10, TextWrapped = true
            }, petList)
        else
            for i = 1, math.min(#petNames, 40) do
                addPetResult(petNames[i], tostring(game.JobId))
            end
        end
        eggStatus.Text = "Nomes unicos encontrados: " .. #eggNames
        petStatus.Text = "Pets/nomes encontrados: " .. #petNames
            .. " | JobId registrado: " .. tostring(game.JobId)
        homeStatus.Text = "Busca concluida. Objetos examinados: " .. math.min(count, 10000)
            .. " | ovos: " .. #eggNames .. " | pets/raridade: " .. #petNames
        log("Busca concluida: " .. #eggNames .. " nomes de ovos e " .. #petNames .. " de pets")
    end)
end

button(home, "ANALISAR AGORA", scan)
button(eggs, "ATUALIZAR BUSCA DE OVOS", scan)
button(pets, "ATUALIZAR BUSCA DE PETS", scan)

local tabNames = {"Início", "Ovos", "Pets raros", "ESP", "Servidores", "Temporizador", "Histórico", "Configurações"}
for _, name in ipairs(tabNames) do
    local b = round(make("TextButton", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = Color3.fromRGB(57, 36, 76),
        BorderSizePixel = 0, Text = name, TextColor3 = Color3.fromRGB(244, 230, 255),
        Font = Enum.Font.GothamSemibold, TextSize = 10, TextWrapped = true
    }, sidebar))
    b.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        pages[name].Visible = true
    end)
end
pages["Início"].Visible = true
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Arrastar com toque ou mouse.
local dragging, dragStart, startPos, dragInput
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

log("EGG RADAR v2.2 carregado")
print("[EGG RADAR] v2.2 carregado")
