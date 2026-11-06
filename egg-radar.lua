-- EGG RADAR v2.0 - interface demonstrativa para Roblox Android
-- Analisa somente objetos que ja foram replicados para o cliente.
-- Nao acessa dados privados, nao revela pets de outros servidores e nao garante deteccao.
-- O ciclo de 4 minutos e um temporizador manual baseado na observacao do jogador.

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local old = nil
pcall(function()
    old = game:GetService("CoreGui"):FindFirstChild("EggRadar")
    if old then old:Destroy() end
end)

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        pcall(function() obj[k] = v end)
    end
    obj.Parent = parent
    return obj
end

local guiParent = game:GetService("CoreGui")
local gui = make("ScreenGui", {
    Name = "EggRadar",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, guiParent)

local main = make("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.new(0.94, 0, 0.72, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Color3.fromRGB(16, 12, 24),
    BorderSizePixel = 0
}, gui)
make("UISizeConstraint", {MinSize = Vector2.new(280, 300), MaxSize = Vector2.new(620, 520)}, main)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, main)
make("UIStroke", {Color = Color3.fromRGB(126, 65, 180), Thickness = 1.5}, main)

local header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = Color3.fromRGB(34, 21, 49),
    BorderSizePixel = 0
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, header)
make("TextLabel", {
    Size = UDim2.new(1, -58, 1, 0),
    Position = UDim2.fromOffset(13, 0),
    BackgroundTransparency = 1,
    Text = "EGG RADAR  v2.0",
    TextColor3 = Color3.fromRGB(220, 190, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left
}, header)

local close = make("TextButton", {
    Size = UDim2.fromOffset(34, 32),
    Position = UDim2.new(1, -42, 0, 8),
    BackgroundColor3 = Color3.fromRGB(103, 48, 145),
    Text = "X",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 15
}, header)
make("UICorner", {CornerRadius = UDim.new(0, 8)}, close)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local sidebar = make("Frame", {
    Position = UDim2.fromOffset(0, 48),
    Size = UDim2.new(0, 112, 1, -48),
    BackgroundColor3 = Color3.fromRGB(27, 19, 39),
    BorderSizePixel = 0
}, main)

local content = make("Frame", {
    Position = UDim2.fromOffset(112, 48),
    Size = UDim2.new(1, -112, 1, -48),
    BackgroundTransparency = 1
}, main)

local pages = {}
local function newPage(name)
    local page = make("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.fromOffset(8, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    }, content)
    make("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)
    pages[name] = page
    return page
end

local function label(parent, text, height)
    return make("TextLabel", {
        Size = UDim2.new(1, -3, 0, height or 38),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(39, 27, 56),
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Color3.fromRGB(235, 225, 245),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextWrapped = true
    }, parent)
end

local function button(parent, text, callback)
    local b = make("TextButton", {
        Size = UDim2.new(1, -3, 0, 36),
        BackgroundColor3 = Color3.fromRGB(105, 54, 151),
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 12
    }, parent)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, b)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function textBox(parent, placeholder)
    local t = make("TextBox", {
        Size = UDim2.new(1, -3, 0, 36),
        BackgroundColor3 = Color3.fromRGB(39, 27, 56),
        BorderSizePixel = 0,
        PlaceholderText = placeholder,
        Text = "",
        ClearTextOnFocus = false,
        TextColor3 = Color3.new(1, 1, 1),
        PlaceholderColor3 = Color3.fromRGB(180, 160, 195),
        Font = Enum.Font.Gotham,
        TextSize = 12
    }, parent)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, t)
    return t
end

local home = newPage("Início")
label(home, "PAINEL PRINCIPAL", 30)
label(home, "EGG RADAR v2.0 carregado. Use Atualizar para analisar os objetos visiveis nesta partida.", 55)
local scanStatus = label(home, "Estado: aguardando analise.", 42)

local eggsPage = newPage("Ovos")
label(eggsPage, "OVOS ENCONTRADOS NO CLIENTE", 38)
local eggStatus = label(eggsPage, "Toque em ATUALIZAR para procurar nomes que contenham egg ou ovo.", 48)
local eggResults = label(eggsPage, "Nenhuma analise realizada.", 70)

local petsPage = newPage("Pets raros")
label(petsPage, "PETS / NOMES RELACIONADOS", 38)
local petStatus = label(petsPage, "A busca considera somente nomes de objetos replicados ao seu cliente.", 48)
local petResults = label(petsPage, "Nenhuma analise realizada.", 70)

local espPage = newPage("ESP")
label(espPage, "DESTAQUE VISUAL", 34)
label(espPage, "ESP nao ativado nesta versao. Primeiro precisamos confirmar os nomes e a estrutura dos objetos do jogo para evitar marcar coisas erradas.", 90)

local serversPage = newPage("Servidores")
label(serversPage, "SERVIDOR ATUAL", 32)
local currentJob = label(serversPage, "JobId: " .. tostring(game.JobId), 54)
button(serversPage, "COPIAR JOB ID ATUAL", function()
    local ok = pcall(function()
        if setclipboard then setclipboard(tostring(game.JobId)) else error("clipboard indisponivel") end
    end)
    currentJob.Text = ok and ("JobId copiado: " .. tostring(game.JobId)) or ("Copie manualmente: " .. tostring(game.JobId))
end)
label(serversPage, "ENTRAR EM OUTRO SERVIDOR", 32)
local jobInput = textBox(serversPage, "Cole aqui o JobId")
button(serversPage, "TENTAR ENTRAR", function()
    local job = jobInput.Text:gsub("%s+", "")
    if job == "" then
        currentJob.Text = "Cole um JobId primeiro."
        return
    end
    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, job, LocalPlayer)
    end)
    currentJob.Text = ok and "Pedido de teleporte enviado; o Roblox pode recusar." or ("Falha: " .. tostring(err))
end)
label(serversPage, "O JobId identifica uma instancia, mas nao informa quais pets existem nela.", 55)

local timerPage = newPage("Temporizador")
label(timerPage, "CICLO DE 4 MINUTOS", 34)
local timerText = label(timerPage, "04:00", 56)
local timerState = label(timerPage, "Temporizador parado. Inicie quando quiser marcar o ciclo.", 48)
local timerRunning = false
local timerToken = 0
local function startTimer()
    timerToken = timerToken + 1
    local myToken = timerToken
    timerRunning = true
    timerState.Text = "Temporizador ativo."
    task.spawn(function()
        local finishAt = os.clock() + 240
        while timerRunning and myToken == timerToken and gui.Parent do
            local left = math.max(0, math.ceil(finishAt - os.clock()))
            timerText.Text = string.format("%02d:%02d", math.floor(left / 60), left % 60)
            if left <= 0 then
                timerState.Text = "4 minutos completos. Confira o jogo e reinicie se desejar."
                timerRunning = false
                break
            end
            task.wait(0.25)
        end
    end)
end
button(timerPage, "INICIAR / REINICIAR 4 MIN", startTimer)
button(timerPage, "PARAR TEMPORIZADOR", function()
    timerRunning = false
    timerToken = timerToken + 1
    timerText.Text = "04:00"
    timerState.Text = "Temporizador parado."
end)

local historyPage = newPage("Histórico")
label(historyPage, "HISTORICO DE ANALISES", 34)
local historyText = label(historyPage, "Nenhuma analise registrada nesta sessao.", 70)
local historyLines = {}

local settingsPage = newPage("Configurações")
label(settingsPage, "CONFIGURACOES", 34)
label(settingsPage, "Tema: preto e roxo | Idioma: portugues | Analise manual", 50)
button(settingsPage, "FECHAR MENU", function() gui:Destroy() end)

local function addHistory(message)
    table.insert(historyLines, 1, os.date("%H:%M:%S") .. " - " .. message)
    while #historyLines > 12 do table.remove(historyLines) end
    historyText.Text = table.concat(historyLines, "\n")
end

local function scanObjects()
    local eggMatches, petMatches = {}, {}
    local eggSeen, petSeen = {}, {}
    local descendants = workspace:GetDescendants()
    for _, obj in ipairs(descendants) do
        local n = string.lower(obj.Name or "")
        if (string.find(n, "egg", 1, true) or string.find(n, "ovo", 1, true)) and not eggSeen[obj.Name] then
            eggSeen[obj.Name] = true
            table.insert(eggMatches, obj.Name)
        end
        if (string.find(n, "pet", 1, true) or string.find(n, "rare", 1, true)
            or string.find(n, "legend", 1, true) or string.find(n, "myth", 1, true)) and not petSeen[obj.Name] then
            petSeen[obj.Name] = true
            table.insert(petMatches, obj.Name)
        end
    end
    table.sort(eggMatches)
    table.sort(petMatches)
    local function formatList(list)
        if #list == 0 then return "Nenhum nome correspondente encontrado no Workspace do cliente." end
        local out = {}
        for i = 1, math.min(#list, 35) do
            out[#out + 1] = "• " .. tostring(list[i])
        end
        if #list > 35 then out[#out + 1] = "... e mais " .. tostring(#list - 35) end
        return table.concat(out, "\n")
    end
    eggResults.Text = formatList(eggMatches)
    petResults.Text = formatList(petMatches)
    eggStatus.Text = "Nomes unicos encontrados: " .. tostring(#eggMatches)
    petStatus.Text = "Nomes unicos encontrados: " .. tostring(#petMatches)
    scanStatus.Text = "Ultima analise: " .. os.date("%H:%M:%S") .. " | Ovos: " .. #eggMatches .. " | Pets/raridade: " .. #petMatches
    addHistory("Analise concluida - ovos: " .. #eggMatches .. ", pets/raridade: " .. #petMatches)
end

button(eggsPage, "ATUALIZAR BUSCA DE OVOS", function()
    eggStatus.Text = "Analisando objetos do cliente..."
    task.spawn(scanObjects)
end)
button(petsPage, "ATUALIZAR BUSCA DE PETS", function()
    petStatus.Text = "Analisando objetos do cliente..."
    task.spawn(scanObjects)
end)
button(home, "ANALISAR AGORA", function()
    task.spawn(scanObjects)
end)

local navNames = {"Início", "Ovos", "Pets raros", "ESP", "Servidores", "Temporizador", "Histórico", "Configurações"}
for i, name in ipairs(navNames) do
    local b = make("TextButton", {
        Size = UDim2.new(1, -12, 0, 32),
        Position = UDim2.fromOffset(6, 7 + (i - 1) * 38),
        BackgroundColor3 = Color3.fromRGB(54, 35, 73),
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = Color3.fromRGB(240, 225, 255),
        Font = Enum.Font.GothamSemibold,
        TextSize = 10
    }, sidebar)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, b)
    b.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        pages[name].Visible = true
    end)
end
pages["Início"].Visible = true

-- Arrastar pela barra superior (toque ou mouse)
local dragging, dragStart, startPos
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
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
