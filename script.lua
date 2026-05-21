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
    if gui.Name == "LuckyBlocksGUI" or gui.Name == "LuckyBlocksEnhancedGUI" or gui.Name == "PremiumHUB" then
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
    label.ZIndex = 100 -- Sempre acima de outros elementos
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
    b.AutoButtonColor = false

    local corner = Instance.new("UICorner")
    corner.CornerRadius = CONFIG.CORNER_RADIUS
    corner.Parent = b

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

Core.Window = nil
Core.Header = nil
Core.TabsFrame = nil
Core.PagesFrame = nil

Core.tabs = {}
Core.pages = {}
Core.activeTab = nil

function Core.init()
    local initialPosition = UDim2.new(0.5, -250, 0.5, -175)
    Core.Window = Utils.createFrame(Core.MainGui, UDim2.new(0, 500, 0, 350), initialPosition, CONFIG.THEME_COLOR_PRIMARY, CONFIG.CORNER_RADIUS)
    Core.Window.Name = "MainWindow"
    Core.Window.Active = true

    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(0,0,0)
    shadow.Transparency = 0.7
    shadow.Thickness = 2
    shadow.Parent = Core.Window

    Core.Header = Utils.createFrame(Core.Window, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), CONFIG.THEME_COLOR_SECONDARY, UDim.new(0,0))
    Core.Header.Name = "Header"
    Core.Header.ClipsDescendants = true

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = CONFIG.CORNER_RADIUS
    headerCorner.Parent = Core.Header

    Utils.createLabel(Core.Header, "Premium HUB", UDim2.new(1, -90, 1, 0), UDim2.new(0, 10, 0, 0), CONFIG.TEXT_COLOR_PRIMARY, CONFIG.FONT_BOLD, 16, Enum.TextXAlignment.Left)

    local closeBtn = Utils.createButton(Core.Header, "X", UDim2.new(0, 30, 1, 0), UDim2.new(1, -30, 0, 0), CONFIG.THEME_COLOR_ERROR, CONFIG.TEXT_COLOR_PRIMARY, CONFIG.FONT_BOLD, 18)
    closeBtn.MouseButton1Click:Connect(function()
        Core.hideWindow()
    end)

    local minimizeBtn = Utils.createButton(Core.Header, "_", UDim2.new(0, 30, 1, 0), UDim2.new(1, -60, 0, 0), CONFIG.THEME_COLOR_SECONDARY, CONFIG.TEXT_COLOR_PRIMARY, CONFIG.FONT_BOLD, 18)
    minimizeBtn.MouseButton1Click:Connect(function()
        Core.minimizeWindow()
    end)

    Core.TabsFrame = Utils.createFrame(Core.Window, UDim2.new(0, 100, 1, -30), UDim2.new(0, 0, 0, 30), CONFIG.THEME_COLOR_SECONDARY, UDim.new(0,0))
    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.Padding = UDim.new(0, 5)
    tabsLayout.Parent = Core.TabsFrame

    Core.PagesFrame = Utils.createFrame(Core.Window, UDim2.new(1, -110, 1, -40), UDim2.new(0, 105, 0, 35), CONFIG.THEME_COLOR_SECONDARY, CONFIG.CORNER_RADIUS)
    Core.PagesFrame.ClipsDescendants = true

    Core.setupWindowControls()
end

function Core.addTab(name, contentCallback)
    local tabButton = Utils.createButton(Core.TabsFrame, name, UDim2.new(1, -10, 0, 30), UDim2.new(), CONFIG.THEME_COLOR_SECONDARY)
    local pageFrame = Utils.createFrame(Core.PagesFrame, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), CONFIG.THEME_COLOR_SECONDARY, CONFIG.CORNER_RADIUS)
    pageFrame.Visible = false

    Core.tabs[name] = tabButton
    Core.pages[name] = pageFrame

    tabButton.MouseButton1Click:Connect(function()
        Core.switchTab(name)
    end)

    if contentCallback then contentCallback(pageFrame) end
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
    TweenService:Create(Core.Window, TweenInfo.new(CONFIG.ANIMATION_TIME), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
    task.wait(CONFIG.ANIMATION_TIME)
    Core.MainGui.Enabled = false
end

function Core.showWindow()
    Core.MainGui.Enabled = true
    Core.Window.Size = UDim2.new(0, 0, 0, 0)
    Core.Window.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(Core.Window, TweenInfo.new(CONFIG.ANIMATION_TIME), {Size = UDim2.new(0, 500, 0, 350), Position = UDim2.new(0.5, -250, 0.5, -175)}):Play()
end

function Core.minimizeWindow()
    Core.TabsFrame.Visible = false
    Core.PagesFrame.Visible = false
    TweenService:Create(Core.Window, TweenInfo.new(CONFIG.ANIMATION_TIME), {Size = UDim2.new(0, 150, 0, 30), Position = UDim2.new(1, -160, 1, -40)}):Play()
end

function Core.restoreWindow()
    Core.TabsFrame.Visible = true
    Core.PagesFrame.Visible = true
    TweenService:Create(Core.Window, TweenInfo.new(CONFIG.ANIMATION_TIME), {Size = UDim2.new(0, 500, 0, 350), Position = UDim2.new(0.5, -250, 0.5, -175)}):Play()
end

function Core.setupWindowControls()
    local dragging, dragInput, dragStart, startPos
    Core.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Core.Window.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            
            local screenX = UserInputService.ViewportSize.X
            local screenY = UserInputService.ViewportSize.Y
            local winX = Core.Window.Size.X.Offset
            local winY = Core.Window.Size.Y.Offset
            
            local clampedX = math.clamp(newPos.X.Offset, 0, screenX - winX)
            local clampedY = math.clamp(newPos.Y.Offset, 0, screenY - winY)
            Core.Window.Position = UDim2.new(0, clampedX, 0, clampedY)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Módulo: PlayerManager (Gerenciamento de Jogadores)
local PlayerManager = {}
PlayerManager.selectedPlayers = {}
PlayerManager.playerButtons = {}

function PlayerManager.init(parentFrame)
    local listFrame = Utils.createFrame(parentFrame, UDim2.new(1, -20, 1, -60), UDim2.new(0, 10, 0, 10), CONFIG.THEME_COLOR_PRIMARY)
    local searchBox = Utils.createTextBox(parentFrame, "Pesquisar jogador...", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 1, -40))
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -10)
    scroll.Position = UDim2.new(0, 5, 0, 5)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.Parent = listFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll

    local function updateList()
        for _, v in pairs(PlayerManager.playerButtons) do v:Destroy() end
        table.clear(PlayerManager.playerButtons)
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name:lower():find(searchBox.Text:lower()) or plr.DisplayName:lower():find(searchBox.Text:lower()) then
                local btn = Utils.createButton(scroll, plr.DisplayName .. " (@" .. plr.Name .. ")", UDim2.new(1, -10, 0, 30), UDim2.new(), CONFIG.THEME_COLOR_SECONDARY)
                PlayerManager.playerButtons[plr.UserId] = btn
                
                if table.find(PlayerManager.selectedPlayers, plr) then
                    btn.BackgroundColor3 = CONFIG.THEME_COLOR_ACCENT
                end

                btn.MouseButton1Click:Connect(function()
                    local index = table.find(PlayerManager.selectedPlayers, plr)
                    if index then
                        table.remove(PlayerManager.selectedPlayers, index)
                        TweenService:Create(btn, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = CONFIG.THEME_COLOR_SECONDARY}):Play()
                    else
                        table.insert(PlayerManager.selectedPlayers, plr)
                        TweenService:Create(btn, TweenInfo.new(CONFIG.ANIMATION_TIME), {BackgroundColor3 = CONFIG.THEME_COLOR_ACCENT}):Play()
                    end
                end)
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(updateList)
    Players.PlayerAdded:Connect(updateList)
    Players.PlayerRemoving:Connect(updateList)
    updateList()
end

function PlayerManager.getSelectedPlayers()
    return PlayerManager.selectedPlayers
end

function PlayerManager.clearSelectedPlayers()
    table.clear(PlayerManager.selectedPlayers)
    for _, btn in pairs(PlayerManager.playerButtons) do
        btn.BackgroundColor3 = CONFIG.THEME_COLOR_SECONDARY
    end
end

-- Módulo: Exploits (Funcionalidades de Exploit)
local Exploits = {}
Exploits.blockNames = {"LuckyBlock", "SuperBlock", "DiamondBlock", "RainbowBlock", "GalaxyBlock", "GlitchBlock"}
Exploits.collecting = false
Exploits.autoOpening = false

function Exploits.init(parentFrame)
    local collectBtn = Utils.createButton(parentFrame, "Pegar TODOS os Blocos", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 10), CONFIG.THEME_COLOR_SUCCESS)
    collectBtn.MouseButton1Click:Connect(function()
        Exploits.doCollectBlocks()
    end)

    local autoOpenBtn = Utils.createButton(parentFrame, "Auto-Abrir: OFF", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 60), CONFIG.THEME_COLOR_WARNING)
    autoOpenBtn.MouseButton1Click:Connect(function()
        Exploits.autoOpening = not Exploits.autoOpening
        autoOpenBtn.Text = "Auto-Abrir: " .. (Exploits.autoOpening and "ON" or "OFF")
        autoOpenBtn.BackgroundColor3 = Exploits.autoOpening and CONFIG.THEME_COLOR_SUCCESS or CONFIG.THEME_COLOR_WARNING
        
        task.spawn(function()
            while Exploits.autoOpening do
                Exploits.doCollectBlocks()
                task.wait(1)
            end
        end)
    end)
end

function Exploits.doCollectBlocks()
    for _, name in ipairs(Exploits.blockNames) do
        local remote = ReplicatedStorage:FindFirstChild("Spawn" .. name)
        if remote then remote:FireServer() end
    end
end

-- Módulo: Teleport
local Teleport = {}
function Teleport.init(parentFrame)
    local tpBtn = Utils.createButton(parentFrame, "Teleportar para Selecionados", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 10), CONFIG.THEME_COLOR_ACCENT)
    tpBtn.MouseButton1Click:Connect(function()
        local selected = PlayerManager.getSelectedPlayers()
        local char = Utils.getCharacter()
        if char and #selected > 0 then
            local target = selected[1].Character
            if target and target:FindFirstChild("HumanoidRootPart") then
                char:MoveTo(target.HumanoidRootPart.Position)
            end
        end
    end)
end

-- Módulo: Trolls
local Trolls = {}
function Trolls.init(parentFrame)
    local freezeBtn = Utils.createButton(parentFrame, "Congelar Selecionados", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 10), CONFIG.THEME_COLOR_ACCENT)
    freezeBtn.MouseButton1Click:Connect(function()
        for _, plr in ipairs(PlayerManager.getSelectedPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.WalkSpeed = 0
            end
        end
    end)

    local unfreezeBtn = Utils.createButton(parentFrame, "Descongelar Selecionados", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 60), CONFIG.THEME_COLOR_SUCCESS)
    unfreezeBtn.MouseButton1Click:Connect(function()
        for _, plr in ipairs(PlayerManager.getSelectedPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.WalkSpeed = 16
            end
        end
    end)
end

-- Main Tab
Core.init()
Core.addTab("Main", function(p) Utils.createLabel(p, "Bem-vindo ao Premium HUB!", UDim2.new(1, 0, 0, 20), UDim2.new(0, 10, 0, 10)) end)
Core.addTab("Exploits", Exploits.init)
Core.addTab("Trolls", Trolls.init)
Core.addTab("Teleport", Teleport.init)
Core.addTab("Player", PlayerManager.init)

Core.switchTab("Main")
Core.showWindow()

