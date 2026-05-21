-- ✅ Lucky Blocks Battleground v5.0 | por João.========      




-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configurações Globais
local CONFIG = {
    THEME_COLOR_PRIMARY = Color3.fromRGB(30, 30, 30), -- Fundo principal
    THEME_COLOR_SECONDARY = Color3.fromRGB(45, 45, 45), -- Elementos secundários
    THEME_COLOR_ACCENT = Color3.fromRGB(0, 150, 255), -- Destaque (azul)
    THEME_COLOR_SUCCESS = Color3.fromRGB(0, 180, 0), -- Sucesso (verde)
    THEME_COLOR_WARNING = Color3.fromRGB(255, 165, 0), -- Aviso (laranja)
    THEME_COLOR_ERROR = Color3.fromRGB(200, 60, 60), -- Erro (vermelho)
    TEXT_COLOR_PRIMARY = Color3.new(1, 1, 1), -- Texto branco
    TEXT_COLOR_SECONDARY = Color3.fromRGB(180, 180, 180), -- Texto cinza claro
    FONT = Enum.Font.Gotham,
    FONT_BOLD = Enum.Font.GothamBold,
    CORNER_RADIUS = UDim.new(0, 8),
    ANIMATION_TIME = 0.2,
    MIN_WINDOW_SIZE = Vector2.new(300, 200),
    MAX_WINDOW_SIZE = Vector2.new(800, 600),
}

-- Destruir GUIs antigas para evitar conflitos
for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui.Name == "LuckyBlocksGUI" or gui.Name == "LuckyBlocksEnhancedGUI" then
        gui:Destroy()
    end
end

-- Módulo: Utils (Funções de Utilidade)
local Utils = {}

function Utils.getCharacter()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char
    end
    return nil
end

function Utils.notify(msg, time, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 300, 0, 35)
    label.Position = UDim2.new(0.5, -150, 0, 10)
    label.BackgroundColor3 = color or CONFIG.THEME_COLOR_SUCCESS
    label.TextColor3 = CONFIG.TEXT_COLOR_PRIMARY
    label.Text = msg
    label.Font = CONFIG.FONT
    label.TextSize = 14
    label.BorderSizePixel = 0
    label.ZIndex = 10 -- Sempre acima de outros elementos
    label.Parent = PlayerGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = CONFIG.CORNER_RADIUS
    corner.Parent = label

    Debris:AddItem(label, time or 3)
end

function Utils.createButton(parent, text, size, pos, color, textColor, font, textSize)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = color or CONFIG.THEME_COLOR_SECONDARY
    b.TextColor3 = textColor or CONFIG.TEXT_COLOR_PRIMARY
    b.Font = font or CONFIG.FONT
    b.TextSize = textSize or 14
    b.BorderSizePixel = 0
    b.Parent = parent
    b.AutoButtonColor = false -- Para controlar o hover manualmente

    local corner = Instance.new("UICorner")
    corner.CornerRadius = CONFIG.CORNER_RADIUS
    corner.Parent = b

    -- Efeitos de hover
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = b.BackgroundColor3:Lerp(Color3.new(1,1,1), 0.2)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = color or CONFIG.THEME_COLOR_SECONDARY}):Play()
    end)

    return b
end

function Utils.createFrame(parent, size, pos, color, cornerRadius)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = pos
    frame.BackgroundColor3 = color or CONFIG.THEME_COLOR_SECONDARY
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = cornerRadius or CONFIG.CORNER_RADIUS
    corner.Parent = frame

    return frame
end

function Utils.createLabel(parent, text, size, pos, textColor, font, textSize, textXAlignment)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = pos
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = textColor or CONFIG.TEXT_COLOR_PRIMARY
    label.Font = font or CONFIG.FONT
    label.TextSize = textSize or 14
    label.TextXAlignment = textXAlignment or Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

function Utils.createTextBox(parent, placeholder, size, pos, color, textColor, font, textSize)
    local textBox = Instance.new("TextBox")
    textBox.Size = size
    textBox.Position = pos
    textBox.PlaceholderText = placeholder
    textBox.BackgroundColor3 = color or CONFIG.THEME_COLOR_SECONDARY
    textBox.TextColor3 = textColor or CONFIG.TEXT_COLOR_PRIMARY
    textBox.Font = font or CONFIG.FONT
    textBox.TextSize = textSize or 14
    textBox.BorderSizePixel = 0
    textBox.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = CONFIG.CORNER_RADIUS
    corner.Parent = textBox

    return textBox
end

-- Módulo: Core (Gerenciamento da Janela Principal e Abas)
local Core = {}
Core.MainGui = Instance.new("ScreenGui")
Core.MainGui.Name = "PremiumHUB"
Core.MainGui.ResetOnSpawn = false
Core.MainGui.Parent = PlayerGui

Core.Window = nil -- Será o frame principal do HUB
Core.Header = nil -- Barra superior da janela
Core.TabsFrame = nil -- Frame para os botões das abas
Core.PagesFrame = nil -- Frame para o conteúdo das abas

Core.tabs = {}
Core.pages = {}
Core.activeTab = nil

function Core.init()
    -- Carregar posição salva da janela
    local savedPosition = LocalPlayer:GetAttribute("PremiumHUB_Position")
    local initialPosition = UDim2.new(0.5, -250, 0.5, -175) -- Posição central padrão
    if savedPosition then
        initialPosition = UDim2.new(savedPosition.X.Scale, savedPosition.X.Offset, savedPosition.Y.Scale, savedPosition.Y.Offset)
    end

    Core.Window = Utils.createFrame(Core.MainGui, UDim2.new(0, 500, 0, 350), initialPosition, CONFIG.THEME_COLOR_PRIMARY, CONFIG.CORNER_RADIUS)
    Core.Window.Name = "MainWindow"
    Core.Window.Active = true
    Core.Window.Draggable = true

    -- Adicionar sombra leve
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(0,0,0)
    shadow.Transparency = 0.7
    shadow.Thickness = 2
    shadow.Parent = Core.Window

    -- Header (Barra superior para título e botões de controle)
    Core.Header = Utils.createFrame(Core.Window, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), CONFIG.THEME_COLOR_SECONDARY, UDim.new(0,0))
    Core.Header.Name = "Header"
    Core.Header.ClipsDescendants = true

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = CONFIG.CORNER_RADIUS
    headerCorner.CornerRoundness = 0.5 -- Apenas os cantos superiores
    headerCorner.Parent = Core.Header

    local titleLabel = Utils.createLabel(Core.Header, "Premium HUB", UDim2.new(1, -90, 1, 0), UDim2.new(0, 10, 0, 0), CONFIG.TEXT_COLOR_PRIMARY, CONFIG.FONT_BOLD, 16, Enum.TextXAlignment.Left)
    titleLabel.Name = "TitleLabel"

    -- Botões de controle da janela (Minimizar, Restaurar, Fechar)
    local closeBtn = Utils.createButton(Core.Header, "X", UDim2.new(0, 30, 1, 0), UDim2.new(1, -30, 0, 0), CONFIG.THEME_COLOR_ERROR, CONFIG.TEXT_COLOR_PRIMARY, CONFIG.FONT_BOLD, 18)
    closeBtn.Name = "CloseButton"
    closeBtn.MouseButton1Click:Connect(function()
        Core.hideWindow()
    end)

    local minimizeBtn = Utils.createButton(Core.Header, "_", UDim2.new(0, 30, 1, 0), UDim2.new(1, -60, 0, 0), CONFIG.THEME_COLOR_SECONDARY, CONFIG.TEXT_COLOR_PRIMARY, CONFIG.FONT_BOLD, 18)
    minimizeBtn.Name = "MinimizeButton"
    minimizeBtn.MouseButton1Click:Connect(function()
        Core.minimizeWindow()
    end)

    -- Frame para os botões das abas
    Core.TabsFrame = Utils.createFrame(Core.Window, UDim2.new(0, 100, 1, -30), UDim2.new(0, 0, 0, 30), CONFIG.THEME_COLOR_SECONDARY, UDim.new(0,0))
    Core.TabsFrame.Name = "TabsFrame"

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.FillDirection = Enum.FillDirection.Vertical
    tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabsLayout.Padding = UDim.new(0, 5)
    tabsLayout.Parent = Core.TabsFrame

    -- Frame para o conteúdo das abas
    Core.PagesFrame = Utils.createFrame(Core.Window, UDim2.new(1, -110, 1, -40), UDim2.new(0, 105, 0, 35), CONFIG.THEME_COLOR_SECONDARY, CONFIG.CORNER_RADIUS)
    Core.PagesFrame.Name = "PagesFrame"
    Core.PagesFrame.ClipsDescendants = true

    -- Adicionar sistema de arrastar e redimensionar
    Core.setupWindowControls()

    -- Salvar posição da janela ao arrastar
    Core.Window.PositionChanged:Connect(function()
        LocalPlayer:SetAttribute("PremiumHUB_Position", Core.Window.Position)
    end)
end

function Core.addTab(name, contentCallback)
    local tabButton = Utils.createButton(
        Core.TabsFrame,
        name,
        UDim2.new(1, -10, 0, 30),
        UDim2.new(),
        CONFIG.THEME_COLOR_SECONDARY
    )
    tabButton.Name = name .. "TabButton"

    local pageFrame = Utils.createFrame(Core.PagesFrame, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), CONFIG.THEME_COLOR_SECONDARY, CONFIG.CORNER_RADIUS)
    pageFrame.Name = name .. "Page"
    pageFrame.Visible = false

    Core.tabs[name] = tabButton
    Core.pages[name] = pageFrame

    tabButton.MouseButton1Click:Connect(function()
        Core.switchTab(name)
    end)

    -- Chamar o callback para preencher o conteúdo da aba
    if contentCallback then
        contentCallback(pageFrame)
    end
end

function Core.switchTab(name)
    if Core.activeTab == name then return end

    for tabName, page in pairs(Core.pages) do
        page.Visible = (tabName == name)
        local button = Core.tabs[tabName]
        if button then
            TweenService:Create(button, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = (tabName == name) and CONFIG.THEME_COLOR_ACCENT or CONFIG.THEME_COLOR_SECONDARY}):Play()
        end
    end
    Core.activeTab = name
end

function Core.hideWindow()
    TweenService:Create(Core.Window, TweenInfo.new(CONFIG.ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
    task.wait(CONFIG.ANIMATION_TIME)
    Core.MainGui.Enabled = false
end

function Core.showWindow()
    Core.MainGui.Enabled = true
    local savedPosition = LocalPlayer:GetAttribute("PremiumHUB_Position")
    local initialPosition = UDim2.new(0.5, -250, 0.5, -175)
    if savedPosition then
        initialPosition = UDim2.new(savedPosition.X.Scale, savedPosition.X.Offset, savedPosition.Y.Scale, savedPosition.Y.Offset)
    end
    Core.Window.Position = initialPosition
    TweenService:Create(Core.Window, TweenInfo.new(CONFIG.ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 500, 0, 350)}):Play()
end

function Core.minimizeWindow()
    local targetSize = UDim2.new(0, 150, 0, 30) -- Tamanho minimizado
    local targetPosition = UDim2.new(1, -160, 1, -40) -- Canto inferior direito

    TweenService:Create(Core.Window, TweenInfo.new(CONFIG.ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = targetSize,
        Position = targetPosition
    }):Play()

    -- Esconder conteúdo das abas e botões de controle, exceto o header
    Core.TabsFrame.Visible = false
    Core.PagesFrame.Visible = false
    Core.Window.Draggable = false -- Desativar arrastar quando minimizado

    -- Mudar o botão de minimizar para restaurar
    local minimizeBtn = Core.Header:FindFirstChild("MinimizeButton")
    if minimizeBtn then
        minimizeBtn.Text = "[]" -- Ícone de restaurar
        minimizeBtn.MouseButton1Click:DisconnectAll()
        minimizeBtn.MouseButton1Click:Connect(function()
            Core.restoreWindow()
        end)
    end
end

function Core.restoreWindow()
    local targetSize = UDim2.new(0, 500, 0, 350) -- Tamanho original
    local savedPosition = LocalPlayer:GetAttribute("PremiumHUB_Position")
    local targetPosition = UDim2.new(0.5, -250, 0.5, -175)
    if savedPosition then
        targetPosition = UDim2.new(savedPosition.X.Scale, savedPosition.X.Offset, savedPosition.Y.Scale, savedPosition.Y.Offset)
    end

    TweenService:Create(Core.Window, TweenInfo.new(CONFIG.ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = targetSize,
        Position = targetPosition
    }):Play()

    -- Mostrar conteúdo das abas e botões de controle
    Core.TabsFrame.Visible = true
    Core.PagesFrame.Visible = true
    Core.Window.Draggable = true -- Reativar arrastar

    -- Mudar o botão de restaurar para minimizar
    local minimizeBtn = Core.Header:FindFirstChild("MinimizeButton")
    if minimizeBtn then
        minimizeBtn.Text = "_" -- Ícone de minimizar
        minimizeBtn.MouseButton1Click:DisconnectAll()
        minimizeBtn.MouseButton1Click:Connect(function()
            Core.minimizeWindow()
        end)
    end
end

function Core.setupWindowControls()
    local isDragging = false
    local dragStartPos = Vector2.new(0, 0)
    local frameStartPos = UDim2.new(0, 0, 0, 0)

    -- Arrastar
    Core.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStartPos = UserInputService:GetMouseLocation()
            frameStartPos = Core.Window.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = UserInputService:GetMouseLocation()
            local delta = mousePos - dragStartPos

            local newXOffset = frameStartPos.X.Offset + delta.X
            local newYOffset = frameStartPos.Y.Offset + delta.Y

            -- Limitar a janela dentro da tela
            local screenX = UserInputService.ViewportSize.X
            local screenY = UserInputService.ViewportSize.Y

            local minX = 0
            local maxX = screenX - Core.Window.Size.X.Offset
            local minY = 0
            local maxY = screenY - Core.Window.Size.Y.Offset

            newXOffset = math.clamp(newXOffset, minX, maxX)
            newYOffset = math.clamp(newYOffset, minY, maxY)

            Core.Window.Position = UDim2.new(0, newXOffset, 0, newYOffset)
        end
    end)

    -- Redimensionar (simplificado para auto-ajuste ou botões específicos)
    -- Por enquanto, o redimensionamento será tratado por botões ou auto-ajuste de conteúdo.
    -- Para um sistema de redimensionamento manual, seria necessário adicionar 'resize handles'.
end

-- Módulo: PlayerManager (Gerenciamento de Jogadores)
local PlayerManager = {}
PlayerManager.selectedPlayers = {}
PlayerManager.playerListFrame = nil
PlayerManager.playerSearchBox = nil
PlayerManager.playerListLayout = nil
PlayerManager.playerButtons = {}

function PlayerManager.init(parentFrame)
    -- Barra de pesquisa
    PlayerManager.playerSearchBox = Utils.createTextBox(
        parentFrame,
        "Pesquisar jogador...",
        UDim2.new(1, -20, 0, 30),
        UDim2.new(0, 10, 0, 5),
        CONFIG.THEME_COLOR_SECONDARY
    )
    PlayerManager.playerSearchBox.Name = "PlayerSearchBox"
    PlayerManager.playerSearchBox.Changed:Connect(function(prop)
        if prop == "Text" then
            PlayerManager.updatePlayerList(PlayerManager.playerSearchBox.Text)
        end
    end)

    -- ScrollingFrame para a lista de jogadores
    PlayerManager.playerListFrame = Instance.new("ScrollingFrame")
    PlayerManager.playerListFrame.Size = UDim2.new(1, -20, 1, -40)
    PlayerManager.playerListFrame.Position = UDim2.new(0, 10, 0, 40)
    PlayerManager.playerListFrame.BackgroundColor3 = CONFIG.THEME_COLOR_PRIMARY
    PlayerManager.playerListFrame.ScrollBarThickness = 6
    PlayerManager.playerListFrame.Parent = parentFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = CONFIG.CORNER_RADIUS
    corner.Parent = PlayerManager.playerListFrame

    PlayerManager.playerListLayout = Instance.new("UIListLayout")
    PlayerManager.playerListLayout.FillDirection = Enum.FillDirection.Vertical
    PlayerManager.playerListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PlayerManager.playerListLayout.Padding = UDim.new(0, 5)
    PlayerManager.playerListLayout.Parent = PlayerManager.playerListFrame

    -- Atualizar lista inicialmente e conectar eventos de entrada/saída de jogadores
    PlayerManager.updatePlayerList("")
    Players.PlayerAdded:Connect(function() PlayerManager.updatePlayerList(PlayerManager.playerSearchBox.Text) end)
    Players.PlayerRemoving:Connect(function() PlayerManager.updatePlayerList(PlayerManager.playerSearchBox.Text) end)
end

function PlayerManager.updatePlayerList(filterText)
    filterText = string.lower(filterText or "")

    -- Limpar botões existentes
    for _, btn in pairs(PlayerManager.playerButtons) do
        btn:Destroy()
    end
    table.clear(PlayerManager.playerButtons)

    -- Adicionar jogadores à lista
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and (string.find(string.lower(plr.Name), filterText) or string.find(string.lower(plr.DisplayName), filterText)) then
            local playerButton = Utils.createButton(
                PlayerManager.playerListFrame,
                plr.Name .. " (" .. plr.DisplayName .. ") - ID: " .. plr.UserId,
                UDim2.new(1, -10, 0, 40),
                UDim2.new(),
                CONFIG.THEME_COLOR_SECONDARY
            )
            playerButton.Name = "PlayerButton_" .. plr.UserId
            playerButton.TextXAlignment = Enum.TextXAlignment.Left
            playerButton.TextSize = 12

            -- Efeito de hover personalizado para botões de jogador
            playerButton.MouseEnter:Connect(function()
                TweenService:Create(playerButton, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = CONFIG.THEME_COLOR_ACCENT:Lerp(Color3.new(1,1,1), 0.2)}):Play()
            end)
            playerButton.MouseLeave:Connect(function()
                local isSelected = table.find(PlayerManager.selectedPlayers, plr)
                TweenService:Create(playerButton, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = isSelected and CONFIG.THEME_COLOR_ACCENT or CONFIG.THEME_COLOR_SECONDARY}):Play()
            end)

            playerButton.MouseButton1Click:Connect(function()
                -- Seleção múltipla
                local index = table.find(PlayerManager.selectedPlayers, plr)
                if index then
                    table.remove(PlayerManager.selectedPlayers, index)
                    TweenService:Create(playerButton, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = CONFIG.THEME_COLOR_SECONDARY}):Play()
                else
                    table.insert(PlayerManager.selectedPlayers, plr)
                    TweenService:Create(playerButton, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = CONFIG.THEME_COLOR_ACCENT}):Play()
                end
                Utils.notify("Selecionado: " .. plr.Name .. ", Total: " .. #PlayerManager.selectedPlayers, 1)
            end)

            PlayerManager.playerButtons[plr.UserId] = playerButton
        end
    end)

    -- Ajustar CanvasSize para scroll suave
    task.wait()
    PlayerManager.playerListFrame.CanvasSize = UDim2.new(0, 0, 0, PlayerManager.playerListLayout.AbsoluteContentSize.Y + 10)
end

function PlayerManager.getSelectedPlayers()
    return PlayerManager.selectedPlayers
end

function PlayerManager.clearSelectedPlayers()
    for _, plr in ipairs(PlayerManager.selectedPlayers) do
        local btn = PlayerManager.playerButtons[plr.UserId]
        if btn then
            TweenService:Create(btn, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = CONFIG.THEME_COLOR_SECONDARY}):Play()
        end
    end
    table.clear(PlayerManager.selectedPlayers)
end

-- Módulo: Exploits (Funcionalidades de Exploit)
local Exploits = {}
Exploits.blockNames = {
    "LuckyBlock", "SuperBlock", "DiamondBlock", "RainbowBlock", "GalaxyBlock", "GlitchBlock"
}
Exploits.collecting = false
Exploits.autoOpening = false
Exploits.itemScanList = nil
Exploits.itemScanLayout = nil
Exploits.itemButtons = {}

function Exploits.init(parentFrame)
    -- Seção de Coleta de Blocos
    local blockCollectFrame = Utils.createFrame(parentFrame, UDim2.new(1, -20, 0, 100), UDim2.new(0, 10, 0, 10), CONFIG.THEME_COLOR_SECONDARY)
    blockCollectFrame.Name = "BlockCollectFrame"

    Utils.createLabel(blockCollectFrame, "Coleta de Blocos", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0), CONFIG.TEXT_COLOR_PRIMARY, CONFIG.FONT_BOLD, 16, Enum.TextXAlignment.Center)

    local collectBtn = Utils.createButton(
        blockCollectFrame,
        "Pegar TODOS os Blocos",
        UDim2.new(1, -20, 0, 35),
        UDim2.new(0, 10, 0, 25),
        CONFIG.THEME_COLOR_SUCCESS
    )
    collectBtn.Name = "CollectBlocksButton"
    collectBtn.MouseButton1Click:Connect(function()
        Exploits.doCollectBlocks(collectBtn)
    end)

    local autoOpenBtn = Utils.createButton(
        blockCollectFrame,
        "Auto-Abrir Blocos: OFF",
        UDim2.new(1, -20, 0, 35),
        UDim2.new(0, 10, 0, 65),
        CONFIG.THEME_COLOR_WARNING
    )
    autoOpenBtn.Name = "AutoOpenBlocksButton"
    autoOpenBtn.MouseButton1Click:Connect(function()
        Exploits.toggleAutoOpen(autoOpenBtn)
    end)

    -- Seção de Gerenciamento de Itens
    local itemManagementFrame = Utils.createFrame(parentFrame, UDim2.new(1, -20, 1, -130), UDim2.new(0, 10, 0, 120), CONFIG.THEME_COLOR_SECONDARY)
    itemManagementFrame.Name = "ItemManagementFrame"

    Utils.createLabel(itemManagementFrame, "Gerenciamento de Itens", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0), CONFIG.TEXT_COLOR_PRIMARY, CONFIG.FONT_BOLD, 16, Enum.TextXAlignment.Center)

    Exploits.itemScanList = Instance.new("ScrollingFrame")
    Exploits.itemScanList.Size = UDim2.new(1, -20, 1, -60)
    Exploits.itemScanList.Position = UDim2.new(0, 10, 0, 25)
    Exploits.itemScanList.BackgroundColor3 = CONFIG.THEME_COLOR_PRIMARY
    Exploits.itemScanList.ScrollBarThickness = 6
    Exploits.itemScanList.Parent = itemManagementFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = CONFIG.CORNER_RADIUS
    corner.Parent = Exploits.itemScanList

    Exploits.itemScanLayout = Instance.new("UIListLayout")
    Exploits.itemScanLayout.FillDirection = Enum.FillDirection.Vertical
    Exploits.itemScanLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    Exploits.itemScanLayout.Padding = UDim.new(0, 5)
    Exploits.itemScanLayout.Parent = Exploits.itemScanList

    local scanItemsBtn = Utils.createButton(
        itemManagementFrame,
        "Escanear Itens",
        UDim2.new(0.48, -5, 0, 30),
        UDim2.new(0, 10, 1, -35),
        CONFIG.THEME_COLOR_ACCENT
    )
    scanItemsBtn.Name = "ScanItemsButton"
    scanItemsBtn.MouseButton1Click:Connect(function()
        Exploits.scanItems()
    end)

    local clearItemsBtn = Utils.createButton(
        itemManagementFrame,
        "Limpar Lista",
        UDim2.new(0.48, -5, 0, 30),
        UDim2.new(0.52, 5, 1, -35),
        CONFIG.THEME_COLOR_ERROR
    )
    clearItemsBtn.Name = "ClearItemsButton"
    clearItemsBtn.MouseButton1Click:Connect(function()
        Exploits.clearItemScanList()
    end)

    -- Atualizar lista de itens automaticamente
    task.spawn(function()
        while task.wait(5) do -- Atualiza a cada 5 segundos
            if parentFrame.Visible then -- Apenas se a aba estiver visível
                Exploits.scanItems(true) -- true para atualização silenciosa
            end
        end
    end)
end

function Exploits.doCollectBlocks(button)
    if Exploits.collecting then
        return Utils.notify("Já executando a coleta.", 2, CONFIG.THEME_COLOR_WARNING)
    end

    local char = Utils.getCharacter()
    if not char then
        return Utils.notify("Personagem não encontrado.", 2, CONFIG.THEME_COLOR_ERROR)
    end

    Exploits.collecting = true
    if button then
        TweenService:Create(button, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = CONFIG.THEME_COLOR_SECONDARY}):Play()
    end

    local total = 0

    task.spawn(function()
        for _ = 1, 100 do -- Loop ajustável para coleta
            if not Exploits.collecting then break end -- Parar se a coleta for desativada
            for _, name in ipairs(Exploits.blockNames) do
                local remote = ReplicatedStorage:FindFirstChild("Spawn" .. name)
                if remote and remote:IsA("RemoteEvent") then
                    pcall(function()
                        remote:FireServer()
                        total = total + 1
                    end)
                end
            end
            task.wait(0.05)
        end

        Exploits.collecting = false
        if button then
            TweenService:Create(button, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = CONFIG.THEME_COLOR_SUCCESS}):Play()
        end
        Utils.notify("Coleta concluída: " .. total .. " blocos.", 3, CONFIG.THEME_COLOR_SUCCESS)
    end)
end

function Exploits.toggleAutoOpen(button)
    Exploits.autoOpening = not Exploits.autoOpening
    if Exploits.autoOpening then
        button.Text = "Auto-Abrir Blocos: ON"
        TweenService:Create(button, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = CONFIG.THEME_COLOR_SUCCESS}):Play()
        Utils.notify("Auto-Abrir Blocos ATIVADO", 2, CONFIG.THEME_COLOR_SUCCESS)
        task.spawn(function()
            while Exploits.autoOpening do
                Exploits.doCollectBlocks() -- Chama a função de coleta, que já tem sua própria lógica de threading
                task.wait(1) -- Espera 1 segundo antes da próxima tentativa
            end
        end)
    else
        button.Text = "Auto-Abrir Blocos: OFF"
        TweenService:Create(button, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = CONFIG.THEME_COLOR_WARNING}):Play()
        Utils.notify("Auto-Abrir Blocos DESATIVADO", 2, CONFIG.THEME_COLOR_WARNING)
    end
end

function Exploits.scanItems(silentUpdate)
    if not Exploits.itemScanList then return end

    local currentItems = {}
    local char = Utils.getCharacter()
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(currentItems, "[CHAR] " .. tool.Name)
            end
        end
    end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(currentItems, "[BACKPACK] " .. tool.Name)
            end
        end
    end

    -- Comparar com a lista atual para evitar recriação desnecessária
    local existingItems = {}
    for _, itemLabel in ipairs(Exploits.itemScanList:GetChildren()) do
        if itemLabel:IsA("TextLabel") then
            table.insert(existingItems, itemLabel.Text)
        end
    end

    local itemsToAdd = {}
    local itemsToRemove = {}

    for _, item in ipairs(currentItems) do
        if not table.find(existingItems, item) then
            table.insert(itemsToAdd, item)
        end
    end

    for _, item in ipairs(existingItems) do
        if not table.find(currentItems, item) then
            table.insert(itemsToRemove, item)
        end
    end

    -- Remover itens antigos
    for _, itemText in ipairs(itemsToRemove) do
        for _, itemLabel in ipairs(Exploits.itemScanList:GetChildren()) do
            if itemLabel:IsA("TextLabel") and itemLabel.Text == itemText then
                itemLabel:Destroy()
                break
            end
        end
    end

    -- Adicionar novos itens
    for _, itemText in ipairs(itemsToAdd) do
        local label = Utils.createLabel(
            Exploits.itemScanList,
            itemText,
            UDim2.new(1, -5, 0, 20),
            UDim2.new(),
            CONFIG.TEXT_COLOR_PRIMARY,
            CONFIG.FONT,
            13,
            Enum.TextXAlignment.Left
        )
        label.Name = "ItemLabel_" .. itemText:gsub("[^%w%]", "_") -- Nome seguro para o Instance
    end

    if #currentItems == 0 and #Exploits.itemScanList:GetChildren() == 0 then
        Utils.createLabel(
            Exploits.itemScanList,
            "(Nenhum item detectado)",
            UDim2.new(1, -5, 0, 20),
            UDim2.new(),
            CONFIG.TEXT_COLOR_SECONDARY,
            CONFIG.FONT,
            13,
            Enum.TextXAlignment.Center
        )
    end

    task.wait()
    Exploits.itemScanList.CanvasSize = UDim2.new(0, 0, 0, Exploits.itemScanLayout.AbsoluteContentSize.Y + 10)

    if not silentUpdate then
        Utils.notify("Itens escaneados! Total: " .. #currentItems, 2, CONFIG.THEME_COLOR_ACCENT)
    end
end

function Exploits.clearItemScanList()
    for _, child in ipairs(Exploits.itemScanList:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    Utils.notify("Lista de itens limpa.", 1, CONFIG.THEME_COLOR_WARNING)
end

-- Módulo: Exploits (Funcionalidades de Exploit)
local Exploits = {}
Exploits.blockNames = {
    "LuckyBlock", "SuperBlock", "DiamondBlock", "RainbowBlock", "GalaxyBlock", "GlitchBlock"
}
Exploits.collecting = false
Exploits.autoOpening = false
Exploits.itemScanList = nil
Exploits.itemScanLayout = nil
Exploits.itemButtons = {}

function Exploits.init(parentFrame)
    -- Seção de Coleta de Blocos
    local blockCollectFrame = Utils.createFrame(parentFrame, UDim2.new(1, -20, 0, 100), UDim2.new(0, 10, 0, 10), CONFIG.THEME_COLOR_SECONDARY)
    blockCollectFrame.Name = "BlockCollectFrame"

    Utils.createLabel(blockCollectFrame, "Coleta de Blocos", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0), CONFIG.TEXT_COLOR_PRIMARY, CONFIG.FONT_BOLD, 16, Enum.TextXAlignment.Center)

    local collectBtn = Utils.createButton(
        blockCollectFrame,
        "Pegar TODOS os Blocos",
        UDim2.new(1, -20, 0, 35),
        UDim2.new(0, 10, 0, 25),
        CONFIG.THEME_COLOR_SUCCESS
    )
    collectBtn.Name = "CollectBlocksButton"
    collectBtn.MouseButton1Click:Connect(function()
        Exploits.doCollectBlocks(collectBtn)
    end)

    local autoOpenBtn = Utils.createButton(
        blockCollectFrame,
        "Auto-Abrir Blocos: OFF",
        UDim2.new(1, -20, 0, 35),
        UDim2.new(0, 10, 0, 65),
        CONFIG.THEME_COLOR_WARNING
    )
    autoOpenBtn.Name = "AutoOpenBlocksButton"
    autoOpenBtn.MouseButton1Click:Connect(function()
        Exploits.toggleAutoOpen(autoOpenBtn)
    end)

    -- Seção de Gerenciamento de Itens
    local itemManagementFrame = Utils.createFrame(parentFrame, UDim2.new(1, -20, 1, -130), UDim2.new(0, 10, 0, 120), CONFIG.THEME_COLOR_SECONDARY)
    itemManagementFrame.Name = "ItemManagementFrame"

    Utils.createLabel(itemManagementFrame, "Gerenciamento de Itens", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0), CONFIG.TEXT_COLOR_PRIMARY, CONFIG.FONT_BOLD, 16, Enum.TextXAlignment.Center)

    Exploits.itemScanList = Instance.new("ScrollingFrame")
    Exploits.itemScanList.Size = UDim2.new(1, -20, 1, -60)
    Exploits.itemScanList.Position = UDim2.new(0, 10, 0, 25)
    Exploits.itemScanList.BackgroundColor3 = CONFIG.THEME_COLOR_PRIMARY
    Exploits.itemScanList.ScrollBarThickness = 6
    Exploits.itemScanList.Parent = itemManagementFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = CONFIG.CORNER_RADIUS
    corner.Parent = Exploits.itemScanList

    Exploits.itemScanLayout = Instance.new("UIListLayout")
    Exploits.itemScanLayout.FillDirection = Enum.FillDirection.Vertical
    Exploits.itemScanLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    Exploits.itemScanLayout.Padding = UDim.new(0, 5)
    Exploits.itemScanLayout.Parent = Exploits.itemScanList

    local scanItemsBtn = Utils.createButton(
        itemManagementFrame,
        "Escanear Itens",
        UDim2.new(0.48, -5, 0, 30),
        UDim2.new(0, 10, 1, -35),
        CONFIG.THEME_COLOR_ACCENT
    )
    scanItemsBtn.Name = "ScanItemsButton"
    scanItemsBtn.MouseButton1Click:Connect(function()
        Exploits.scanItems()
    end)

    local clearItemsBtn = Utils.createButton(
        itemManagementFrame,
        "Limpar Lista",
        UDim2.new(0.48, -5, 0, 30),
        UDim2.new(0.52, 5, 1, -35),
        CONFIG.THEME_COLOR_ERROR
    )
    clearItemsBtn.Name = "ClearItemsButton"
    clearItemsBtn.MouseButton1Click:Connect(function()
        Exploits.clearItemScanList()
    end)

    -- Atualizar lista de itens automaticamente
    task.spawn(function()
        while task.wait(5) do -- Atualiza a cada 5 segundos
            if parentFrame.Visible then -- Apenas se a aba estiver visível
                Exploits.scanItems(true) -- true para atualização silenciosa
            end
        end
    end)
end

function Exploits.doCollectBlocks(button)
    if Exploits.collecting then
        return Utils.notify("Já executando a coleta.", 2, CONFIG.THEME_COLOR_WARNING)
    end

    local char = Utils.getCharacter()
    if not char then
        return Utils.notify("Personagem não encontrado.", 2, CONFIG.THEME_COLOR_ERROR)
    end

    Exploits.collecting = true
    if button then
        TweenService:Create(button, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = CONFIG.THEME_COLOR_SECONDARY}):Play()
    end

    local total = 0

    task.spawn(function()
        for _ = 1, 100 do -- Loop ajustável para coleta
            if not Exploits.collecting then break end -- Parar se a coleta for desativada
            for _, name in ipairs(Exploits.blockNames) do
                local remote = ReplicatedStorage:FindFirstChild("Spawn" .. name)
                if remote and remote:IsA("RemoteEvent") then
                    pcall(function()
                        remote:FireServer()
                        total = total + 1
                    end)
                end
            end
            task.wait(0.05)
        end

        Exploits.collecting = false
        if button then
            TweenService:Create(button, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = CONFIG.THEME_COLOR_SUCCESS}):Play()
        end
        Utils.notify("Coleta concluída: " .. total .. " blocos.", 3, CONFIG.THEME_COLOR_SUCCESS)
    end)
end

function Exploits.toggleAutoOpen(button)
    Exploits.autoOpening = not Exploits.autoOpening
    if Exploits.autoOpening then
        button.Text = "Auto-Abrir Blocos: ON"
        TweenService:Create(button, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = CONFIG.THEME_COLOR_SUCCESS}):Play()
        Utils.notify("Auto-Abrir Blocos ATIVADO", 2, CONFIG.THEME_COLOR_SUCCESS)
        task.spawn(function()
            while Exploits.autoOpening do
                Exploits.doCollectBlocks() -- Chama a função de coleta, que já tem sua própria lógica de threading
                task.wait(1) -- Espera 1 segundo antes da próxima tentativa
            end
        end)
    else
        button.Text = "Auto-Abrir Blocos: OFF"
        TweenService:Create(button, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = CONFIG.THEME_COLOR_WARNING}):Play()
        Utils.notify("Auto-Abrir Blocos DESATIVADO", 2, CONFIG.THEME_COLOR_WARNING)
    end
end

function Exploits.scanItems(silentUpdate)
    if not Exploits.itemScanList then return end

    local currentItems = {}
    local char = Utils.getCharacter()
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(currentItems, "[CHAR] " .. tool.Name)
            end
        end
    end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(currentItems, "[BACKPACK] " .. tool.Name)
            end
        end
    end

    -- Comparar com a lista atual para evitar recriação desnecessária
    local existingItems = {}
    for _, itemLabel in ipairs(Exploits.itemScanList:GetChildren()) do
        if itemLabel:IsA("TextLabel") then
            table.insert(existingItems, itemLabel.Text)
        end
    end

    local itemsToAdd = {}
    local itemsToRemove = {}

    for _, item in ipairs(currentItems) do
        if not table.find(existingItems, item) then
            table.insert(itemsToAdd, item)
        end
    end

    for _, item in ipairs(existingItems) do
        if not table.find(currentItems, item) then
            table.insert(itemsToRemove, item)
        end
    end

    -- Remover itens antigos
    for _, itemText in ipairs(itemsToRemove) do
        for _, itemLabel in ipairs(Exploits.itemScanList:GetChildren()) do
            if itemLabel:IsA("TextLabel") and itemLabel.Text == itemText then
                itemLabel:Destroy()
                break
            end
        end
    end

    -- Adicionar novos itens
    for _, itemText in ipairs(itemsToAdd) do
        local label = Utils.createLabel(
            Exploits.itemScanList,
            itemText,
            UDim2.new(1, -5, 0, 20),
            UDim2.new(),
            CONFIG.TEXT_COLOR_PRIMARY,
            CONFIG.FONT,
            13,
            Enum.TextXAlignment.Left
        )
        label.Name = "ItemLabel_" .. itemText:gsub("[^%w%]", "_") -- Nome seguro para o Instance
    end

    if #currentItems == 0 and #Exploits.itemScanList:GetChildren() == 0 then
        Utils.createLabel(
            Exploits.itemScanList,
            "(Nenhum item detectado)",
            UDim2.new(1, -5, 0, 20),
            UDim2.new(),
            CONFIG.TEXT_COLOR_SECONDARY,
            CONFIG.FONT,
            13,
            Enum.TextXAlignment.Center
        )
    end

    task.wait()
    Exploits.itemScanList.CanvasSize = UDim2.new(0, 0, 0, Exploits.itemScanLayout.AbsoluteContentSize.Y + 10)

    if not silentUpdate then
        Utils.notify("Itens escaneados! Total: " .. #currentItems, 2, CONFIG.THEME_COLOR_ACCENT)
    end
end

function Exploits.clearItemScanList()
    for _, child in ipairs(Exploits.itemScanList:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    Utils.notify("Lista de itens limpa.", 1, CONFIG.THEME_COLOR_WARNING)
end

-- Módulo: Teleport (Funcionalidades de Teletransporte)
local Teleport = {}

function Teleport.init(parentFrame)
    local teleportFrame = Utils.createFrame(parentFrame, UDim2.new(1, -20, 1, -20), UDim2.new(0, 10, 0, 10), CONFIG.THEME_COLOR_SECONDARY)
    teleportFrame.Name = "TeleportFrame"

    Utils.createLabel(teleportFrame, "Teletransporte", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0), CONFIG.TEXT_COLOR_PRIMARY, CONFIG.FONT_BOLD, 16, Enum.TextXAlignment.Center)

    local tpSelectedBtn = Utils.createButton(
        teleportFrame,
        "Teleportar para Selecionados",
        UDim2.new(1, -20, 0, 35),
        UDim2.new(0, 10, 0, 30),
        CONFIG.THEME_COLOR_ACCENT
    )
    tpSelectedBtn.Name = "TeleportSelectedButton"
    tpSelectedBtn.MouseButton1Click:Connect(function()
        local selectedPlayers = PlayerManager.getSelectedPlayers()
        if #selectedPlayers > 0 then
            for _, plr in ipairs(selectedPlayers) do
                Teleport.toPlayer(plr)
            end
        else
            Utils.notify("Nenhum jogador selecionado para teletransporte.", 2, CONFIG.THEME_COLOR_WARNING)
        end
    end)

    local clearSelectionBtn = Utils.createButton(
        teleportFrame,
        "Limpar Seleção de Jogadores",
        UDim2.new(1, -20, 0, 35),
        UDim2.new(0, 10, 0, 70),
        CONFIG.THEME_COLOR_ERROR
    )
    clearSelectionBtn.Name = "ClearSelectionButton"
    clearSelectionBtn.MouseButton1Click:Connect(function()
        PlayerManager.clearSelectedPlayers()
        Utils.notify("Seleção de jogadores limpa.", 2, CONFIG.THEME_COLOR_WARNING)
    end)
end

function Teleport.toPlayer(targetPlayer)
    local char = Utils.getCharacter()
    if not char then return Utils.notify("Seu personagem não encontrado.", 2, CONFIG.THEME_COLOR_ERROR) end

    local targetChar = targetPlayer.Character
    if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
        char:MoveTo(targetChar.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
        Utils.notify("Teleportado para " .. targetPlayer.Name, 2, CONFIG.THEME_COLOR_SUCCESS)
    else
        Utils.notify("Personagem do alvo " .. targetPlayer.Name .. " não encontrado.", 2, CONFIG.THEME_COLOR_ERROR)
    end
}

-- Módulo: Trolls (Funcionalidades de Troll)
local Trolls = {}

function Trolls.init(parentFrame)
    local trollsFrame = Utils.createFrame(parentFrame, UDim2.new(1, -20, 1, -20), UDim2.new(0, 10, 0, 10), CONFIG.THEME_COLOR_SECONDARY)
    trollsFrame.Name = "TrollsFrame"

    Utils.createLabel(trollsFrame, "Ferramentas de Troll", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0), CONFIG.TEXT_COLOR_PRIMARY, CONFIG.FONT_BOLD, 16, Enum.TextXAlignment.Center)

    -- Seção de Controle de Movimento
    local movementControlFrame = Utils.createFrame(trollsFrame, UDim2.new(1, -20, 0, 120), UDim2.new(0, 10, 0, 30), CONFIG.THEME_COLOR_PRIMARY)
    movementControlFrame.Name = "MovementControlFrame"
    Utils.createLabel(movementControlFrame, "Controle de Movimento", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0), CONFIG.TEXT_COLOR_PRIMARY, CONFIG.FONT_BOLD, 14, Enum.TextXAlignment.Center)

    local freezeBtn = Utils.createButton(movementControlFrame, "Congelar Jogador", UDim2.new(0.48, -5, 0, 30), UDim2.new(0, 10, 0, 25), CONFIG.THEME_COLOR_ACCENT)
    freezeBtn.Name = "FreezeButton"
    freezeBtn.MouseButton1Click:Connect(function()
        Trolls.applyToSelectedPlayers(Trolls.freezePlayer)
    end)

    local unfreezeBtn = Utils.createButton(movementControlFrame, "Descongelar Jogador", UDim2.new(0.48, -5, 0, 30), UDim2.new(0.52, 5, 0, 25), CONFIG.THEME_COLOR_ERROR)
    unfreezeBtn.Name = "UnfreezeButton"
    unfreezeBtn.MouseButton1Click:Connect(function()
        Trolls.applyToSelectedPlayers(Trolls.unfreezePlayer)
    end)

    local speedTextBox = Utils.createTextBox(movementControlFrame, "Velocidade (ex: 16)", UDim2.new(0.48, -5, 0, 30), UDim2.new(0, 10, 0, 60), CONFIG.THEME_COLOR_SECONDARY)
    speedTextBox.Name = "SpeedTextBox"
    local setSpeedBtn = Utils.createButton(movementControlFrame, "Definir Velocidade", UDim2.new(0.48, -5, 0, 30), UDim2.new(0.52, 5, 0, 60), CONFIG.THEME_COLOR_ACCENT)
    setSpeedBtn.Name = "SetSpeedButton"
    setSpeedBtn.MouseButton1Click:Connect(function()
        local speed = tonumber(speedTextBox.Text)
        if speed then
            Trolls.applyToSelectedPlayers(Trolls.setSpeed, speed)
        else
            Utils.notify("Velocidade inválida.", 2, CONFIG.THEME_COLOR_WARNING)
        end
    end)

    local jumpPowerTextBox = Utils.createTextBox(movementControlFrame, "Pulo (ex: 50)", UDim2.new(0.48, -5, 0, 30), UDim2.new(0, 10, 0, 95), CONFIG.THEME_COLOR_SECONDARY)
    jumpPowerTextBox.Name = "JumpPowerTextBox"
    local setJumpPowerBtn = Utils.createButton(movementControlFrame, "Definir Pulo", UDim2.new(0.48, -5, 0, 30), UDim2.new(0.52, 5, 0, 95), CONFIG.THEME_COLOR_ACCENT)
    setJumpPowerBtn.Name = "SetJumpPowerButton"
    setJumpPowerBtn.MouseButton1Click:Connect(function()
        local jumpPower = tonumber(jumpPowerTextBox.Text)
        if jumpPower then
            Trolls.applyToSelectedPlayers(Trolls.setJumpPower, jumpPower)
        else
            Utils.notify("Pulo inválido.", 2, CONFIG.THEME_COLOR_WARNING)
        end
    end)

    -- Seção de Efeitos Visuais (Placeholder)
    local visualEffectsFrame = Utils.createFrame(trollsFrame, UDim2.new(1, -20, 1, -160), UDim2.new(0, 10, 0, 160), CONFIG.THEME_COLOR_PRIMARY)
    visualEffectsFrame.Name = "VisualEffectsFrame"
    Utils.createLabel(visualEffectsFrame, "Efeitos Visuais (Em Breve)", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0), CONFIG.TEXT_COLOR_SECONDARY, CONFIG.FONT, 14, Enum.TextXAlignment.Center)
end

function Trolls.applyToSelectedPlayers(func, ...)
    local selectedPlayers = PlayerManager.getSelectedPlayers()
    if #selectedPlayers == 0 then
        return Utils.notify("Nenhum jogador selecionado.", 2, CONFIG.THEME_COLOR_WARNING)
    end

    for _, plr in ipairs(selectedPlayers) do
        func(plr, ...)
    end
end

function Trolls.freezePlayer(player)
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = 0
        char.Humanoid.JumpPower = 0
        Utils.notify("Jogador " .. player.Name .. " congelado.", 2, CONFIG.THEME_COLOR_ACCENT)
    else
        Utils.notify("Não foi possível congelar " .. player.Name .. ". Personagem não encontrado.", 2, CONFIG.THEME_COLOR_ERROR)
    end
end

function Trolls.unfreezePlayer(player)
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = 16 -- Velocidade padrão do Roblox
        char.Humanoid.JumpPower = 50 -- Pulo padrão do Roblox
        Utils.notify("Jogador " .. player.Name .. " descongelado.", 2, CONFIG.THEME_COLOR_ACCENT)
    else
        Utils.notify("Não foi possível descongelar " .. player.Name .. ". Personagem não encontrado.", 2, CONFIG.THEME_COLOR_ERROR)
    end
end

function Trolls.setSpeed(player, speed)
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = speed
        Utils.notify("Velocidade de " .. player.Name .. " definida para " .. speed .. ".", 2, CONFIG.THEME_COLOR_ACCENT)
    else
        Utils.notify("Não foi possível definir a velocidade de " .. player.Name .. ". Personagem não encontrado.", 2, CONFIG.THEME_COLOR_ERROR)
    end
end

function Trolls.setJumpPower(player, jumpPower)
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = jumpPower
        Utils.notify("Pulo de " .. player.Name .. " definido para " .. jumpPower .. ".", 2, CONFIG.THEME_COLOR_ACCENT)
    else
        Utils.notify("Não foi possível definir o pulo de " .. player.Name .. ". Personagem não encontrado.", 2, CONFIG.THEME_COLOR_ERROR)
    end
end



-- Inicialização do HUB
Core.init()

-- Adicionar abas
Core.addTab("Main", function(pageFrame)
    -- Conteúdo da aba Main
    Utils.createLabel(pageFrame, "Bem-vindo ao Premium HUB!", UDim2.new(1,0,0,30), UDim2.new(0,0,0,0), CONFIG.TEXT_COLOR_PRIMARY, CONFIG.FONT_BOLD, 18, Enum.TextXAlignment.Center)
    Utils.createLabel(pageFrame, "Selecione uma aba para começar.", UDim2.new(1,0,0,20), UDim2.new(0,0,0,30), CONFIG.TEXT_COLOR_SECONDARY, CONFIG.FONT, 14, Enum.TextXAlignment.Center)
end)

Core.addTab("Exploits", function(pageFrame)
    Exploits.init(pageFrame)
end)

Core.addTab("Teleport", function(pageFrame)
    Teleport.init(pageFrame)
end)

Core.addTab("Trolls", function(pageFrame)
    Trolls.init(pageFrame)
end)

Core.addTab("Visual", function(pageFrame)
    -- Módulo: Visual (Configurações Visuais)
    local Visual = {}
    function Visual.init(parentFrame)
        local visualFrame = Utils.createFrame(parentFrame, UDim2.new(1, -20, 1, -20), UDim2.new(0, 10, 0, 10), CONFIG.THEME_COLOR_SECONDARY)
        visualFrame.Name = "VisualFrame"
        Utils.createLabel(visualFrame, "Configurações Visuais (Em Breve)", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0), CONFIG.TEXT_COLOR_PRIMARY, CONFIG.FONT_BOLD, 16, Enum.TextXAlignment.Center)
    end
    Visual.init(pageFrame)
end)

Core.addTab("Player", function(pageFrame)
    -- Módulo: Player (Informações e Ações do Jogador)
    local Player = {}
    function Player.init(parentFrame)
        PlayerManager.init(parentFrame)
    end
    Player.init(pageFrame)
end)

Core.addTab("Misc", function(pageFrame)
    -- Módulo: Misc (Outras Funcionalidades)
    local Misc = {}
    function Misc.init(parentFrame)
        local miscFrame = Utils.createFrame(parentFrame, UDim2.new(1, -20, 1, -20), UDim2.new(0, 10, 0, 10), CONFIG.THEME_COLOR_SECONDARY)
        miscFrame.Name = "MiscFrame"
        Utils.createLabel(miscFrame, "Miscelânea (Em Breve)", UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0), CONFIG.TEXT_COLOR_PRIMARY, CONFIG.FONT_BOLD, 16, Enum.TextXAlignment.Center)
    end
    Misc.init(pageFrame)
end)

-- Ativar a primeira aba por padrão
Core.switchTab("Main")

-- Mostrar o HUB
Core.showWindow()

-- Listener para o botão de abrir/fechar (ex: um botão na tela ou comando de chat)
-- Por enquanto, o HUB é visível por padrão. Um botão de toggle pode ser adicionado posteriormente.
-- Exemplo de toggle (pode ser um Keybind ou um botão na tela do jogo):
-- UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
-- if input.KeyCode == Enum.KeyCode.RightControl and not gameProcessedEvent then
-- if Core.MainGui.Enabled then
-- Core.hideWindow()
-- else
-- Core.showWindow()
-- end
-- end
-- end)

-- Otimização: Limitar a janela dentro da tela em tempo real (para mobile e redimensionamento)
RunService.RenderStepped:Connect(function()
    if Core.Window and Core.MainGui.Enabled then
        local screenX = UserInputService.ViewportSize.X
        local screenY = UserInputService.ViewportSize.Y

        local currentX = Core.Window.Position.X.Offset
        local currentY = Core.Window.Position.Y.Offset
        local currentWidth = Core.Window.Size.X.Offset
        local currentHeight = Core.Window.Size.Y.Offset

        -- Limitar a janela dentro da tela em tempo real
        local newX = math.clamp(currentX, 0, screenX - currentWidth)
        local newY = math.clamp(currentY, 0, screenY - currentHeight)

        if newX ~= currentX or newY ~= currentY then
            Core.Window.Position = UDim2.new(0, newX, 0, newY)
        end

        -- Responsividade: Ajustar tamanho da janela para mobile/PC
        -- Se a largura da tela for menor que um certo valor, ajustar o tamanho da janela para mobile.
        if screenX < 768 then -- Exemplo de breakpoint para mobile
            local targetWidth = math.min(screenX * 0.95, CONFIG.MAX_WINDOW_SIZE.X)
            local targetHeight = math.min(screenY * 0.95, CONFIG.MAX_WINDOW_SIZE.Y)
            if Core.Window.Size.X.Offset ~= targetWidth or Core.Window.Size.Y.Offset ~= targetHeight then
                TweenService:Create(Core.Window, TweenInfo.new(CONFIG.ANIMATION_TIME), {
                    Size = UDim2.new(0, targetWidth, 0, targetHeight),
                    Position = UDim2.new(0.5, -targetWidth/2, 0.5, -targetHeight/2)
                }):Play()
            end
        else -- Para PC, restaurar tamanho padrão se estiver minimizado ou ajustado para mobile
            local defaultWidth = 500
            local defaultHeight = 350
            if Core.Window.Size.X.Offset ~= defaultWidth or Core.Window.Size.Y.Offset ~= defaultHeight then
                TweenService:Create(Core.Window, TweenInfo.new(CONFIG.ANIMATION_TIME), {
                    Size = UDim2.new(0, defaultWidth, 0, defaultHeight),
                    Position = UDim2.new(0.5, -defaultWidth/2, 0.5, -defaultHeight/2)
                }):Play()
            end
        end
    end
end)
