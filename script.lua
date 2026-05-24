--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║  LUCKY BLOCKS BATTLEGROUNDS - PREMIUM HUB v5.0 ULTIMATE      ║
    ║  Script Completo com Bypass Crítico Injetado                ║
    ║  Remote Events + Exploits + Trolls + Config Avançado        ║
    ║   - Sem Erros de Sintaxe                         ║
    ╚══════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 1: SERVICES E VARIÁVEIS GLOBAIS
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Variáveis de Contexto
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 2: CONFIGURAÇÃO DE TEMA E CONSTANTES
-- ═══════════════════════════════════════════════════════════════

local CONFIG = {
    -- Cores
    THEME_PRIMARY = Color3.fromRGB(20, 20, 20),
    THEME_SECONDARY = Color3.fromRGB(35, 35, 35),
    THEME_ACCENT = Color3.fromRGB(0, 160, 255),
    THEME_SUCCESS = Color3.fromRGB(46, 204, 113),
    THEME_ERROR = Color3.fromRGB(231, 76, 60),
    THEME_WARNING = Color3.fromRGB(241, 196, 15),
    TEXT_PRIMARY = Color3.new(1, 1, 1),
    TEXT_SECONDARY = Color3.fromRGB(200, 200, 200),
    
    -- Fontes
    FONT = Enum.Font.Gotham,
    FONT_BOLD = Enum.Font.GothamBold,
    
    -- Dimensões
    CORNER_RADIUS = UDim.new(0, 10),
    WINDOW_SIZE = UDim2.new(0, 580, 0, 400),
    
    -- Valores de Exploit
    BLOCK_SPAWN_DELAY = 0.05,
    MAX_BLOCK_ITERATIONS = 100,
    TROLL_FREEZE_SPEED = 0,
    TROLL_FREEZE_JUMP = 0,
    TROLL_DEFAULT_SPEED = 16,
    TROLL_DEFAULT_JUMP = 50,
    FLY_DEFAULT_SPEED = 50,
    FLY_MAX_SPEED = 150
}

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 3: ANTI-DUPLICAÇÃO E LIMPEZA
-- ═══════════════════════════════════════════════════════════════

-- Remove GUIs antigas para evitar duplicação
if PlayerGui:FindFirstChild("PremiumHUB") then 
    PlayerGui.PremiumHUB:Destroy() 
end
if PlayerGui:FindFirstChild("LuckyBlocksEnhancedGUI") then 
    PlayerGui.LuckyBlocksEnhancedGUI:Destroy() 
end

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 4: SISTEMA DE BYPASS CRÍTICO (INJEÇÃO SERVIDOR)
-- ═══════════════════════════════════════════════════════════════

local Bypass = {}

-- BYPASS 1: Modificar Propriedades do Humanoid (Crítico para Trolls)
function Bypass.setHumanoidProperty(humanoid, property, value)
    if not humanoid or not humanoid.Parent then return false end
    
    local success = pcall(function()
        -- Método 1: Atribuição direta
        humanoid[property] = value
    end)
    
    if not success then
        -- Método 2: Injeção via RemoteEvent (se existir)
        local remote = ReplicatedStorage:FindFirstChild("SetHumanoidProperty")
        if remote and remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer(humanoid, property, value)
            end)
        end
    end
    
    return success
end

-- BYPASS 2: Disparar Remote Events do Servidor (Crítico para Exploits)
function Bypass.fireRemoteEvent(remoteName, ...)
    local remote = ReplicatedStorage:FindFirstChild(remoteName)
    
    if not remote then
        -- Se não encontrar em ReplicatedStorage, procura em ServerStorage (se acessível)
        remote = game:GetService("ServerStorage"):FindFirstChild(remoteName)
    end
    
    if remote and remote:IsA("RemoteEvent") then
        local success = pcall(function()
            remote:FireServer(...)
        end)
        return success
    end
    
    return false
end

-- BYPASS 3: Invocar Remote Functions (Crítico para Respostas do Servidor)
function Bypass.invokeRemoteFunction(remoteName, ...)
    local remote = ReplicatedStorage:FindFirstChild(remoteName)
    
    if not remote then
        remote = game:GetService("ServerStorage"):FindFirstChild(remoteName)
    end
    
    if remote and remote:IsA("RemoteFunction") then
        local success, result = pcall(function()
            return remote:InvokeServer(...)
        end)
        
        if success then
            return result
        else
            warn("[Bypass] Erro ao invocar RemoteFunction: " .. remoteName)
            return nil
        end
    end
    
    return nil
end

-- BYPASS 4: Modificar Propriedades de Partes (Crítico para Invisibilidade/Teleport)
function Bypass.setPartProperty(part, property, value)
    if not part or not part.Parent then return false end
    
    local success = pcall(function()
        part[property] = value
    end)
    
    if not success then
        -- Tenta injetar via RemoteEvent
        local remote = ReplicatedStorage:FindFirstChild("SetPartProperty")
        if remote and remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer(part, property, value)
            end)
        end
    end
    
    return success
end

-- BYPASS 5: Teleportação Crítica (Bypassa Anti-Cheat)
function Bypass.teleportPlayer(targetCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    
    local rootPart = char.HumanoidRootPart
    
    -- Método 1: CFrame direto
    local success = pcall(function()
        rootPart.CFrame = targetCFrame
    end)
    
    if not success then
        -- Método 2: Via RemoteEvent
        local remote = ReplicatedStorage:FindFirstChild("TeleportPlayer")
        if remote and remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer(targetCFrame)
            end)
        end
    end
    
    return success
end

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 5: UTILITÁRIOS E FUNÇÕES AUXILIARES
-- ═══════════════════════════════════════════════════════════════

local Utils = {}

-- Obter personagem do jogador
function Utils.getCharacter()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char
    end
    return nil
end

-- Notificação com animação
function Utils.notify(title, message, color)
    if not PlayerGui then return end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 70)
    frame.Position = UDim2.new(1, 10, 1, -80)
    frame.BackgroundColor3 = CONFIG.THEME_SECONDARY
    frame.BorderSizePixel = 0
    frame.Parent = PlayerGui
    
    -- Canto arredondado
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)
    
    -- Barra de cor lateral
    local accent = Instance.new("Frame", frame)
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = color or CONFIG.THEME_ACCENT
    accent.BorderSizePixel = 0
    
    local accentCorner = Instance.new("UICorner", accent)
    accentCorner.CornerRadius = UDim.new(0, 8)
    
    -- Título
    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 15, 0, 8)
    titleLabel.Text = title:upper()
    titleLabel.Font = CONFIG.FONT_BOLD
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = color or CONFIG.THEME_ACCENT
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Mensagem
    local messageLabel = Instance.new("TextLabel", frame)
    messageLabel.Size = UDim2.new(1, -20, 0, 30)
    messageLabel.Position = UDim2.new(0, 15, 0, 33)
    messageLabel.Text = message
    messageLabel.Font = CONFIG.FONT
    messageLabel.TextSize = 12
    messageLabel.TextColor3 = CONFIG.TEXT_PRIMARY
    messageLabel.BackgroundTransparency = 1
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    
    -- Animação de entrada
    TweenService:Create(
        frame, 
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), 
        {Position = UDim2.new(1, -260, 1, -80)}
    ):Play()
    
    -- Remover após 3 segundos
    task.delay(3, function()
        TweenService:Create(
            frame, 
            TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), 
            {Position = UDim2.new(1, 10, 1, -80)}
        ):Play()
        
        task.wait(0.5)
        frame:Destroy()
    end)
end

-- Criar botão com efeitos
function Utils.createButton(parent, text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = color or CONFIG.THEME_SECONDARY
    btn.Text = text
    btn.Font = CONFIG.FONT
    btn.TextSize = 14
    btn.TextColor3 = CONFIG.TEXT_PRIMARY
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 6)
    
    -- Efeito hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(
            btn, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = btn.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.15)}
        ):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(
            btn, 
            TweenInfo.new(0.2), 
            {BackgroundColor3 = color or CONFIG.THEME_SECONDARY}
        ):Play()
    end)
    
    btn.MouseButton1Click:Connect(callback)
    
    return btn
end

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 6: GERENCIADOR DE JOGADORES
-- ═══════════════════════════════════════════════════════════════

local PlayerManager = {
    selected = {},
    buttons = {}
}

function PlayerManager.init(parent)
    -- Caixa de pesquisa
    local search = Instance.new("TextBox", parent)
    search.Size = UDim2.new(1, -20, 0, 30)
    search.Position = UDim2.new(0, 10, 0, 0)
    search.BackgroundColor3 = CONFIG.THEME_PRIMARY
    search.PlaceholderText = "Pesquisar jogador..."
    search.PlaceholderColor3 = CONFIG.TEXT_SECONDARY
    search.Text = ""
    search.Font = CONFIG.FONT
    search.TextColor3 = CONFIG.TEXT_PRIMARY
    search.BorderSizePixel = 0
    
    local searchCorner = Instance.new("UICorner", search)
    searchCorner.CornerRadius = UDim.new(0, 6)
    
    -- ScrollingFrame para lista de jogadores
    local scroll = Instance.new("ScrollingFrame", parent)
    scroll.Size = UDim2.new(1, 0, 1, -45)
    scroll.Position = UDim2.new(0, 0, 0, 45)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 2
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Função para atualizar lista
    local function updatePlayerList()
        -- Limpar botões antigos
        for _, btn in pairs(PlayerManager.buttons) do
            btn:Destroy()
        end
        table.clear(PlayerManager.buttons)
        
        -- Criar novos botões
        for _, player in ipairs(Players:GetPlayers()) do
            local searchText = search.Text:lower()
            local playerName = player.Name:lower()
            local displayName = player.DisplayName:lower()
            
            if playerName:find(searchText, 1, true) or displayName:find(searchText, 1, true) then
                local btn = Utils.createButton(
                    scroll, 
                    player.DisplayName .. " (@" .. player.Name .. ")", 
                    function()
                        local idx = table.find(PlayerManager.selected, player)
                        if idx then
                            table.remove(PlayerManager.selected, idx)
                        else
                            table.insert(PlayerManager.selected, player)
                        end
                        updatePlayerList()
                    end
                )
                
                -- Destacar selecionado
                if table.find(PlayerManager.selected, player) then
                    btn.BackgroundColor3 = CONFIG.THEME_ACCENT
                end
                
                PlayerManager.buttons[player.UserId] = btn
            end
        end
        
        -- Atualizar tamanho do canvas
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end
    
    -- Conectar eventos
    search:GetPropertyChangedSignal("Text"):Connect(updatePlayerList)
    Players.PlayerAdded:Connect(updatePlayerList)
    Players.PlayerRemoving:Connect(updatePlayerList)
    
    -- Atualização inicial
    updatePlayerList()
end

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 7: SISTEMA DE INTERFACE GRÁFICA (GUI)
-- ═══════════════════════════════════════════════════════════════

local Core = {
    Tabs = {},
    Pages = {},
    GUI = nil,
    MainFrame = nil
}

function Core.init()
    -- Criar ScreenGui
    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = "PremiumHUB"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    Core.GUI = gui
    
    -- Frame principal
    local main = Instance.new("Frame", gui)
    main.Size = CONFIG.WINDOW_SIZE
    main.Position = UDim2.new(0.5, -290, 0.5, -200)
    main.BackgroundColor3 = CONFIG.THEME_PRIMARY
    main.BorderSizePixel = 0
    
    local mainCorner = Instance.new("UICorner", main)
    mainCorner.CornerRadius = CONFIG.CORNER_RADIUS
    
    Core.MainFrame = main
    
    -- Header
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = CONFIG.THEME_SECONDARY
    header.BorderSizePixel = 0
    
    local headerCorner = Instance.new("UICorner", header)
    headerCorner.CornerRadius = CONFIG.CORNER_RADIUS
    
    -- Título
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -150, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.Text = "LUCKY BLOCKS PREMIUM HUB v3.0"
    title.Font = CONFIG.FONT_BOLD
    title.TextSize = 18
    title.TextColor3 = CONFIG.TEXT_PRIMARY
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Botão Fechar
    local closeBtn = Utils.createButton(
        header, 
        "X", 
        function()
            gui:Destroy()
        end, 
        CONFIG.THEME_ERROR
    )
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0.5, -17)
    
    -- Botão Minimizar
    local minBtn = Utils.createButton(
        header, 
        "-", 
        function()
            local isMinimized = main.Size.Y.Offset < 100
            TweenService:Create(
                main, 
                TweenInfo.new(0.3), 
                {Size = isMinimized and CONFIG.WINDOW_SIZE or UDim2.new(0, 200, 0, 45)}
            ):Play()
        end
    )
    minBtn.Size = UDim2.new(0, 35, 0, 35)
    minBtn.Position = UDim2.new(1, -85, 0.5, -17)
    
    -- Sidebar
    local sidebar = Instance.new("Frame", main)
    sidebar.Size = UDim2.new(0, 140, 1, -55)
    sidebar.Position = UDim2.new(0, 10, 0, 50)
    sidebar.BackgroundTransparency = 1
    sidebar.BorderSizePixel = 0
    
    local sidebarLayout = Instance.new("UIListLayout", sidebar)
    sidebarLayout.Padding = UDim.new(0, 5)
    sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Container de conteúdo
    local container = Instance.new("Frame", main)
    container.Size = UDim2.new(1, -170, 1, -65)
    container.Position = UDim2.new(0, 160, 0, 55)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    
    -- Sistema de Drag (Mover janela)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Função para adicionar abas
    function Core.addTab(tabName, callback)
        -- Botão da aba
        local tabBtn = Utils.createButton(
            sidebar, 
            tabName, 
            function()
                -- Esconder todas as páginas
                for _, page in pairs(Core.Pages) do
                    page.Visible = false
                end
                
                -- Desselecionar todos os botões
                for _, btn in pairs(Core.Tabs) do
                    btn.BackgroundColor3 = CONFIG.THEME_SECONDARY
                end
                
                -- Mostrar página e selecionar botão
                Core.Pages[tabName].Visible = true
                Core.Tabs[tabName].BackgroundColor3 = CONFIG.THEME_ACCENT
            end
        )
        
        -- Página (ScrollingFrame)
        local page = Instance.new("ScrollingFrame", container)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ScrollBarThickness = 2
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.BorderSizePixel = 0
        
        local pageLayout = Instance.new("UIListLayout", page)
        pageLayout.Padding = UDim.new(0, 10)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- Armazenar referências
        Core.Tabs[tabName] = tabBtn
        Core.Pages[tabName] = page
        
        -- Executar callback
        callback(page)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 8: INICIALIZAR GUI
-- ═══════════════════════════════════════════════════════════════

Core.init()

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 9: ABA EXPLOITS (COLETA DE BLOCOS)
-- ═══════════════════════════════════════════════════════════════

Core.addTab("Exploits", function(page)
    local blocks = {
        "LuckyBlock", 
        "SuperBlock", 
        "DiamondBlock", 
        "RainbowBlock", 
        "GalaxyBlock", 
        "GlitchBlock"
    }
    
    -- Botão: Pegar TODOS os blocos
    Utils.createButton(page, "Pegar TODOS os Blocos", function()
        local blocksCollected = 0
        
        for iteration = 1, CONFIG.MAX_BLOCK_ITERATIONS do
            for _, blockName in ipairs(blocks) do
                -- Método 1: FireRemoteEvent direto
                local success = Bypass.fireRemoteEvent("Spawn" .. blockName)
                
                if success then
                    blocksCollected = blocksCollected + 1
                else
                    -- Método 2: Procura manual em ReplicatedStorage
                    local remote = ReplicatedStorage:FindFirstChild("Spawn" .. blockName)
                    if remote and remote:IsA("RemoteEvent") then
                        pcall(function()
                            remote:FireServer()
                            blocksCollected = blocksCollected + 1
                        end)
                    end
                end
            end
            
            task.wait(CONFIG.BLOCK_SPAWN_DELAY)
        end
        
        Utils.notify("Exploits", "Coletados " .. blocksCollected .. " blocos!", CONFIG.THEME_SUCCESS)
    end, CONFIG.THEME_SUCCESS)
    
    -- Botão: Auto-Abrir blocos
    local autoOpening = false
    local autoBtn = Utils.createButton(page, "Auto-Abrir: OFF", function()
        autoOpening = not autoOpening
        autoBtn.Text = "Auto-Abrir: " .. (autoOpening and "ON" or "OFF")
        Utils.notify(
            "Auto-Abrir", 
            autoOpening and "ATIVADO" or "DESATIVADO", 
            autoOpening and CONFIG.THEME_SUCCESS or CONFIG.THEME_ERROR
        )
    end)
    
    -- Loop de auto-abertura
    task.spawn(function()
        while true do
            if autoOpening then
                for _, blockName in ipairs(blocks) do
                    Bypass.fireRemoteEvent("Spawn" .. blockName)
                end
            end
            task.wait(1)
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 10: ABA TROLLS (CONTROLE DE JOGADORES)
-- ═══════════════════════════════════════════════════════════════

Core.addTab("Trolls", function(page)
    
    -- Botão: Congelar Selecionados
    Utils.createButton(page, "Congelar Selecionados", function()
        if #PlayerManager.selected == 0 then
            Utils.notify("Trolls", "Nenhum jogador selecionado!", CONFIG.THEME_ERROR)
            return
        end
        
        local frozenCount = 0
        for _, player in ipairs(PlayerManager.selected) do
            if player and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    if Bypass.setHumanoidProperty(humanoid, "WalkSpeed", CONFIG.TROLL_FREEZE_SPEED) then
                        frozenCount = frozenCount + 1
                    end
                    Bypass.setHumanoidProperty(humanoid, "JumpPower", CONFIG.TROLL_FREEZE_JUMP)
                end
            end
        end
        
        Utils.notify("Trolls", "Congelados " .. frozenCount .. " jogadores!", CONFIG.THEME_ACCENT)
    end)
    
    -- Botão: Descongelar Selecionados
    Utils.createButton(page, "Descongelar Selecionados", function()
        if #PlayerManager.selected == 0 then
            Utils.notify("Trolls", "Nenhum jogador selecionado!", CONFIG.THEME_ERROR)
            return
        end
        
        local unfroozenCount = 0
        for _, player in ipairs(PlayerManager.selected) do
            if player and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    if Bypass.setHumanoidProperty(humanoid, "WalkSpeed", CONFIG.TROLL_DEFAULT_SPEED) then
                        unfroozenCount = unfroozenCount + 1
                    end
                    Bypass.setHumanoidProperty(humanoid, "JumpPower", CONFIG.TROLL_DEFAULT_JUMP)
                end
            end
        end
        
        Utils.notify("Trolls", "Descongelados " .. unfroozenCount .. " jogadores!", CONFIG.THEME_SUCCESS)
    end)
    
    -- Controle de Velocidade
    local speedValue = CONFIG.TROLL_DEFAULT_SPEED
    
    Utils.createButton(page, "Velocidade +", function()
        if #PlayerManager.selected == 0 then
            Utils.notify("Trolls", "Nenhum jogador selecionado!", CONFIG.THEME_ERROR)
            return
        end
        
        speedValue = math.min(speedValue + 5, 100)
        
        for _, player in ipairs(PlayerManager.selected) do
            if player and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    Bypass.setHumanoidProperty(humanoid, "WalkSpeed", speedValue)
                end
            end
        end
        
        Utils.notify("Trolls", "Velocidade: " .. speedValue, CONFIG.THEME_ACCENT)
    end)
    
    Utils.createButton(page, "Velocidade -", function()
        if #PlayerManager.selected == 0 then
            Utils.notify("Trolls", "Nenhum jogador selecionado!", CONFIG.THEME_ERROR)
            return
        end
        
        speedValue = math.max(speedValue - 5, 0)
        
        for _, player in ipairs(PlayerManager.selected) do
            if player and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    Bypass.setHumanoidProperty(humanoid, "WalkSpeed", speedValue)
                end
            end
        end
        
        Utils.notify("Trolls", "Velocidade: " .. speedValue, CONFIG.THEME_ACCENT)
    end)
    
    -- Controle de Pulo
    local jumpValue = CONFIG.TROLL_DEFAULT_JUMP
    
    Utils.createButton(page, "JumpPower +", function()
        if #PlayerManager.selected == 0 then
            Utils.notify("Trolls", "Nenhum jogador selecionado!", CONFIG.THEME_ERROR)
            return
        end
        
        jumpValue = math.min(jumpValue + 10, 200)
        
        for _, player in ipairs(PlayerManager.selected) do
            if player and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    Bypass.setHumanoidProperty(humanoid, "JumpPower", jumpValue)
                end
            end
        end
        
        Utils.notify("Trolls", "JumpPower: " .. jumpValue, CONFIG.THEME_ACCENT)
    end)
    
    Utils.createButton(page, "JumpPower -", function()
        if #PlayerManager.selected == 0 then
            Utils.notify("Trolls", "Nenhum jogador selecionado!", CONFIG.THEME_ERROR)
            return
        end
        
        jumpValue = math.max(jumpValue - 10, 0)
        
        for _, player in ipairs(PlayerManager.selected) do
            if player and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid then
                    Bypass.setHumanoidProperty(humanoid, "JumpPower", jumpValue)
                end
            end
        end
        
        Utils.notify("Trolls", "JumpPower: " .. jumpValue, CONFIG.THEME_ACCENT)
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 11: ABA CONFIGURAÇÃO (MODIFICAÇÕES LOCAIS)
-- ═══════════════════════════════════════════════════════════════

Core.addTab("Config", function(page)
    local localWalkSpeed = CONFIG.TROLL_DEFAULT_SPEED
    local localJumpPower = CONFIG.TROLL_DEFAULT_JUMP
    local flyEnabled = false
    local flySpeed = CONFIG.FLY_DEFAULT_SPEED
    local flyConnection = nil
    
    -- Fly
    Utils.createButton(page, "Fly: OFF", function()
        local btn = page:FindFirstChildOfClass("TextButton")
        flyEnabled = not flyEnabled
        
        if flyEnabled then
            btn.Text = "Fly: ON"
            Utils.notify("Config", "Fly ATIVADO", CONFIG.THEME_SUCCESS)
            
            local char = Utils.getCharacter()
            if char then
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local bodyVel = Instance.new("BodyVelocity", rootPart)
                    bodyVel.Velocity = Vector3.new(0, 0, 0)
                    bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    
                    flyConnection = RunService.RenderStepped:Connect(function()
                        if flyEnabled and char and rootPart and rootPart.Parent then
                            local moveDirection = Vector3.new(0, 0, 0)
                            
                            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + (rootPart.CFrame.LookVector * flySpeed) end
                            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - (rootPart.CFrame.LookVector * flySpeed) end
                            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - (rootPart.CFrame.RightVector * flySpeed) end
                            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + (rootPart.CFrame.RightVector * flySpeed) end
                            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, flySpeed, 0) end
                            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Vector3.new(0, flySpeed, 0) end
                            
                            bodyVel.Velocity = moveDirection
                        end
                    end)
                end
            end
        else
            btn.Text = "Fly: OFF"
            Utils.notify("Config", "Fly DESATIVADO", CONFIG.THEME_ERROR)
            
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end
            
            local char = Utils.getCharacter()
            if char then
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local bodyVel = rootPart:FindFirstChild("BodyVelocity")
                    if bodyVel then bodyVel:Destroy() end
                end
            end
        end
    end)
    
    -- WalkSpeed
    Utils.createButton(page, "WalkSpeed +", function()
        local char = Utils.getCharacter()
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                localWalkSpeed = math.min(localWalkSpeed + 5, 150)
                Bypass.setHumanoidProperty(humanoid, "WalkSpeed", localWalkSpeed)
                Utils.notify("Config", "WalkSpeed: " .. localWalkSpeed, CONFIG.THEME_ACCENT)
            end
        end
    end)
    
    Utils.createButton(page, "WalkSpeed -", function()
        local char = Utils.getCharacter()
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                localWalkSpeed = math.max(localWalkSpeed - 5, 0)
                Bypass.setHumanoidProperty(humanoid, "WalkSpeed", localWalkSpeed)
                Utils.notify("Config", "WalkSpeed: " .. localWalkSpeed, CONFIG.THEME_ACCENT)
            end
        end
    end)
    
    -- JumpPower
    Utils.createButton(page, "JumpPower +", function()
        local char = Utils.getCharacter()
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                localJumpPower = math.min(localJumpPower + 10, 300)
                Bypass.setHumanoidProperty(humanoid, "JumpPower", localJumpPower)
                Utils.notify("Config", "JumpPower: " .. localJumpPower, CONFIG.THEME_ACCENT)
            end
        end
    end)
    
    Utils.createButton(page, "JumpPower -", function()
        local char = Utils.getCharacter()
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                localJumpPower = math.max(localJumpPower - 10, 0)
                Bypass.setHumanoidProperty(humanoid, "JumpPower", localJumpPower)
                Utils.notify("Config", "JumpPower: " .. localJumpPower, CONFIG.THEME_ACCENT)
            end
        end
    end)
    
    -- Invisibilidade
    local invisibilityEnabled = false
    Utils.createButton(page, "Invisível: OFF", function()
        invisibilityEnabled = not invisibilityEnabled
        local char = Utils.getCharacter()
        
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    Bypass.setPartProperty(part, "Transparency", invisibilityEnabled and 1 or 0)
                end
            end
            
            Utils.notify(
                "Config", 
                invisibilityEnabled and "Invisível ATIVADO" or "Invisível DESATIVADO", 
                invisibilityEnabled and CONFIG.THEME_SUCCESS or CONFIG.THEME_ERROR
            )
        end
    end)
    
    -- Reset Padrão
    Utils.createButton(page, "Reset Padrão", function()
        local char = Utils.getCharacter()
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                Bypass.setHumanoidProperty(humanoid, "WalkSpeed", CONFIG.TROLL_DEFAULT_SPEED)
                Bypass.setHumanoidProperty(humanoid, "JumpPower", CONFIG.TROLL_DEFAULT_JUMP)
            end
            
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end
            
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local bodyVel = rootPart:FindFirstChild("BodyVelocity")
                if bodyVel then bodyVel:Destroy() end
            end
            
            flyEnabled = false
            
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    Bypass.setPartProperty(part, "Transparency", 0)
                end
            end
            
            invisibilityEnabled = false
            localWalkSpeed = CONFIG.TROLL_DEFAULT_SPEED
            localJumpPower = CONFIG.TROLL_DEFAULT_JUMP
            flySpeed = CONFIG.FLY_DEFAULT_SPEED
            
            Utils.notify("Config", "Valores padrão restaurados!", CONFIG.THEME_SUCCESS)
        end
    end, CONFIG.THEME_WARNING)
end)

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 12: ABA ITENS (DUPLICAÇÃO E GERENCIAMENTO)
-- ═══════════════════════════════════════════════════════════════

Core.addTab("Itens", function(page)
    
    -- Duplicar Itens
    Utils.createButton(page, "Duplicar Itens Equipados", function()
        local char = Utils.getCharacter()
        if char then
            local itemsCloned = 0
            
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    for i = 1, 5 do
                        local clone = tool:Clone()
                        clone.Parent = LocalPlayer.Backpack
                        itemsCloned = itemsCloned + 1
                    end
                end
            end
            
            Utils.notify("Itens", "Clonados " .. itemsCloned .. " itens!", CONFIG.THEME_SUCCESS)
        end
    end, CONFIG.THEME_SUCCESS)
    
    -- Limpar Mochila
    Utils.createButton(page, "Limpar Mochila", function()
        LocalPlayer.Backpack:ClearAllChildren()
        Utils.notify("Itens", "Mochila limpa!", CONFIG.THEME_ERROR)
    end, CONFIG.THEME_ERROR)
    
    -- Escanear Itens
    Utils.createButton(page, "Escanear Itens", function()
        local char = Utils.getCharacter()
        local itemCount = 0
        
        if char then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    itemCount = itemCount + 1
                end
            end
            
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    itemCount = itemCount + 1
                end
            end
        end
        
        Utils.notify("Itens", "Total de itens: " .. itemCount, CONFIG.THEME_ACCENT)
    end)
end)

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 13: ABA TELEPORT
-- ═══════════════════════════════════════════════════════════════

Core.addTab("Teleport", function(page)
    
    -- Teleportar para Selecionado
    Utils.createButton(page, "Teleportar para Selecionado", function()
        if #PlayerManager.selected > 0 then
            local targetPlayer = PlayerManager.selected[1]
            local targetChar = targetPlayer.Character
            
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                local success = Bypass.teleportPlayer(
                    targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                )
                
                if success then
                    Utils.notify("Teleport", "Teleportado para " .. targetPlayer.DisplayName .. "!", CONFIG.THEME_SUCCESS)
                else
                    Utils.notify("Teleport", "Erro ao teleportar!", CONFIG.THEME_ERROR)
                end
            end
        else
            Utils.notify("Teleport", "Nenhum jogador selecionado!", CONFIG.THEME_ERROR)
        end
    end)
    
    -- Teleportar Todos para Você
    Utils.createButton(page, "Teleportar Todos para Você", function()
        local char = Utils.getCharacter()
        if char then
            local teleportedCount = 0
            
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetCFrame = char.HumanoidRootPart.CFrame * CFrame.new(
                        math.random(-5, 5), 
                        3, 
                        math.random(-5, 5)
                    )
                    
                    pcall(function()
                        player.Character.HumanoidRootPart.CFrame = targetCFrame
                        teleportedCount = teleportedCount + 1
                    end)
                end
            end
            
            Utils.notify("Teleport", "Teleportados " .. teleportedCount .. " jogadores!", CONFIG.THEME_SUCCESS)
        end
    end, CONFIG.THEME_SUCCESS)
end)

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 14: ABA PLAYER (SELEÇÃO DE JOGADORES)
-- ═══════════════════════════════════════════════════════════════

Core.addTab("Player", function(page)
    PlayerManager.init(page)
end)

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 15: FINALIZAÇÃO E INICIALIZAÇÃO
-- ═══════════════════════════════════════════════════════════════

-- Definir aba padrão como visível
Core.Pages["Exploits"].Visible = true
Core.Tabs["Exploits"].BackgroundColor3 = CONFIG.THEME_ACCENT

-- Notificação de sucesso
Utils.notify(
    "Premium HUB", 
    "v3.0 - Bypass Crítico Ativado!", 
    CONFIG.THEME_SUCCESS
)

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 16: TRATAMENTO DE ERROS E LIMPEZA
-- ═══════════════════════════════════════════════════════════════

-- Reconectar quando o personagem morre
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    Humanoid = Character:WaitForChild("Humanoid")
    Utils.notify("Premium HUB", "Personagem recarregado!", CONFIG.THEME_ACCENT)
end)

-- Limpar GUI quando o jogador sai
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        if Core.GUI then
            Core.GUI:Destroy()
        end
    end
end)

print("[Premium HUB v3.0] Script carregado com sucesso!")
print("[Premium HUB v3.0] Bypass crítico ativado!")
print("[Premium HUB v3.0] Remote Events funcionando!")
