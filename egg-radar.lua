-- EGG RADAR - interface demonstrativa para Roblox Android
-- Observacao: este arquivo cria apenas a interface e ferramentas locais.
-- Ele NAO detecta pets raros em outros servidores nem revela dados privados do jogo.

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

local gui = make("ScreenGui", {
    Name = "EggRadar",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, game:GetService("CoreGui"))

local main = make("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(570, 365),
    Position = UDim2.new(0.5, -285, 0.5, -182),
    BackgroundColor3 = Color3.fromRGB(16, 12, 24),
    BorderSizePixel = 0
}, gui)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, main)
make("UIStroke", {Color = Color3.fromRGB(126, 65, 180), Thickness = 1.5}, main)

local header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 54),
    BackgroundColor3 = Color3.fromRGB(34, 21, 49),
    BorderSizePixel = 0
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 12)}, header)
make("TextLabel", {
    Size = UDim2.new(1, -65, 1, 0),
    Position = UDim2.fromOffset(16, 0),
    BackgroundTransparency = 1,
    Text = "🥚 EGG RADAR",
    TextColor3 = Color3.fromRGB(220, 190, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 22,
    TextXAlignment = Enum.TextXAlignment.Left
}, header)

local close = make("TextButton", {
    Size = UDim2.fromOffset(36, 34),
    Position = UDim2.new(1, -46, 0, 10),
    BackgroundColor3 = Color3.fromRGB(103, 48, 145),
    Text = "X",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 16
}, header)
make("UICorner", {CornerRadius = UDim.new(0, 8)}, close)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local sidebar = make("Frame", {
    Position = UDim2.fromOffset(0, 54),
    Size = UDim2.new(0, 155, 1, -54),
    BackgroundColor3 = Color3.fromRGB(27, 19, 39),
    BorderSizePixel = 0
}, main)

local content = make("Frame", {
    Position = UDim2.fromOffset(155, 54),
    Size = UDim2.new(1, -155, 1, -54),
    BackgroundTransparency = 1
}, main)

local pages = {}
local function newPage(name)
    local page = make("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, -24, 1, -24),
        Position = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false
    }, content)
    local layout = make("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder
    }, page)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8)
    end)
    pages[name] = page
    return page
end

local function label(parent, text, height)
    return make("TextLabel", {
        Size = UDim2.new(1, -4, 0, height or 34),
        BackgroundColor3 = Color3.fromRGB(39, 27, 56),
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Color3.fromRGB(235, 225, 245),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextWrapped = true
    }, parent)
end

local function button(parent, text, callback)
    local b = make("TextButton", {
        Size = UDim2.new(1, -4, 0, 38),
        BackgroundColor3 = Color3.fromRGB(105, 54, 151),
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 13
    }, parent)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, b)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function textBox(parent, placeholder)
    local t = make("TextBox", {
        Size = UDim2.new(1, -4, 0, 38),
        BackgroundColor3 = Color3.fromRGB(39, 27, 56),
        BorderSizePixel = 0,
        PlaceholderText = placeholder,
        Text = "",
        ClearTextOnFocus = false,
        TextColor3 = Color3.new(1, 1, 1),
        PlaceholderColor3 = Color3.fromRGB(180, 160, 195),
        Font = Enum.Font.Gotham,
        TextSize = 13
    }, parent)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, t)
    return t
end

local home = newPage("Início")
label(home, "PAINEL PRINCIPAL", 32)
label(home, "Interface carregada. A detecção automática depende de dados fornecidos pelo próprio jogo.", 58)
label(home, "Estado do radar: aguardando fonte de dados", 42)

local eggs = newPage("Ovos")
label(eggs, "OVOS", 32)
label(eggs, "Esta página está pronta para receber nomes/posições de ovos que o jogo disponibilize ao cliente.", 62)

local rares = newPage("Pets raros")
label(rares, "PETS RAROS", 32)
label(rares, "Nenhum pet reportado. O script não consegue consultar sozinho os outros servidores.", 58)

local esp = newPage("ESP")
label(esp, "DESTAQUE VISUAL", 32)
label(esp, "O ESP específico precisa conhecer os nomes e objetos usados por Steal an Egg. Não foi ativado para evitar marcações falsas.", 68)

local servers = newPage("Servidores")
label(servers, "SERVIDOR ATUAL", 32)
local currentJob = label(servers, "JobId: " .. game.JobId, 56)
button(servers, "COPIAR JOB ID ATUAL", function()
    if setclipboard then
        setclipboard(game.JobId)
        currentJob.Text = "JobId copiado: " .. game.JobId
    else
        currentJob.Text = "Copie manualmente: " .. game.JobId
    end
end)
label(servers, "ENTRAR EM OUTRO SERVIDOR", 32)
local jobInput = textBox(servers, "Cole aqui o JobId do servidor")
button(servers, "TENTAR ENTRAR NO SERVIDOR", function()
    local job = jobInput.Text:gsub("%s+", "")
    if job == "" then
        currentJob.Text = "Cole um JobId antes de continuar."
        return
    end
    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, job, LocalPlayer)
    end)
    if not ok then
        currentJob.Text = "Falha ao solicitar teleporte: " .. tostring(err)
    else
        currentJob.Text = "Solicitação enviada. O Roblox pode impedir o teleporte."
    end
end)
label(servers, "O JobId identifica uma instância, mas não informa qual pet apareceu nela.", 54)

local history = newPage("Histórico")
label(history, "HISTÓRICO", 32)
label(history, "Nenhuma aparição registrada nesta sessão.", 42)

local settings = newPage("Configurações")
label(settings, "CONFIGURAÇÕES", 32)
label(settings, "Tema: preto e roxo | Idioma: português", 38)
button(settings, "FECHAR MENU", function() gui:Destroy() end)

local navNames = {"Início", "Ovos", "Pets raros", "ESP", "Servidores", "Histórico", "Configurações"}
for i, name in ipairs(navNames) do
    local b = make("TextButton", {
        Size = UDim2.new(1, -16, 0, 36),
        Position = UDim2.fromOffset(8, 8 + (i - 1) * 42),
        BackgroundColor3 = Color3.fromRGB(54, 35, 73),
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = Color3.fromRGB(240, 225, 255),
        Font = Enum.Font.GothamSemibold,
        TextSize = 12
    }, sidebar)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, b)
    b.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        pages[name].Visible = true
    end)
end

pages["Início"].Visible = true

-- Arrastar o painel pela barra superior
local UserInputService = game:GetService("UserInputService")
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
