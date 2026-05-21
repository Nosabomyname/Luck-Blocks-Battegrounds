
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configurações Globais
local CONFIG = {
    THEME_COLOR_PRIMARY = Color3.fromRGB(20, 20, 20), -- Fundo principal (mais escuro)
    THEME_COLOR_SECONDARY = Color3.fromRGB(35, 35, 35), -- Elementos secundários
    THEME_COLOR_ACCENT = Color3.fromRGB(0, 150, 255), -- Destaque (azul premium)
    THEME_COLOR_SUCCESS = Color3.fromRGB(46, 204, 113), -- Sucesso
    THEME_COLOR_WARNING = Color3.fromRGB(241, 196, 15), -- Aviso
    THEME_COLOR_ERROR = Color3.fromRGB(231, 76, 60), -- Erro
    TEXT_COLOR_PRIMARY = Color3.new(1, 1, 1),
    TEXT_COLOR_SECONDARY = Color3.fromRGB(180, 180, 180),
    FONT = Enum.Font.Gotham,
    FONT_BOLD = Enum.Font.GothamBold,
    CORNER_RADIUS = UDim.new(0, 10),
    ANIMATION_TIME = 0.3,
    WINDOW_SIZE = UDim2.new(0, 550, 0, 380)
}

-- Anti-Duplicação
if PlayerGui:FindFirstChild("PremiumHUB") then PlayerGui.PremiumHUB:Destroy() end

-- Módulo: Utils
local Utils = {}

function Utils.getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

function Utils.notify(title, msg, time, color)
    local notifyFrame = Instance.new("Frame")
    notifyFrame.Size = UDim2.new(0, 250, 0, 60)
    notifyFrame.Position = UDim2.new(1, 10, 1, -70)
    notifyFrame.BackgroundColor3 = CONFIG.THEME_COLOR_SECONDARY
    notifyFrame.BorderSizePixel = 0
    notifyFrame.Parent = PlayerGui:FindFirstChild("PremiumHUB") or PlayerGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notifyFrame

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = color or CONFIG.THEME_COLOR_ACCENT
    accent.Parent = notifyFrame
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 8)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -20, 0, 20)
    t.Position = UDim2.new(0, 12, 0, 8)
    t.Text = title
    t.Font = CONFIG.FONT_BOLD
    t.TextSize = 14
    t.TextColor3 = color or CONFIG.THEME_COLOR_ACCENT
    t.BackgroundTransparency = 1
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = notifyFrame

    local m = Instance.new("TextLabel")
    m.Size = UDim2.new(1, -20, 0, 20)
    m.Position = UDim2.new(0, 12, 0, 28)
    m.Text = msg
    m.Font = CONFIG.FONT
    m.TextSize = 12
    m.TextColor3 = CONFIG.TEXT_COLOR_PRIMARY
    m.BackgroundTransparency = 1
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.Parent = notifyFrame

    TweenService:Create(notifyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -260, 1, -70)}):Play()
    task.delay(time or 3, function()
        TweenService:Create(notifyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 10, 1, -70)}):Play()
        task.wait(0.5)
        notifyFrame:Destroy()
    end)
end

function Utils.createButton(parent, text, size, pos, color)
    local b = Instance.new("TextButton")
    b.Size = size or UDim2.new(1, -10, 0, 35)
    b.Position = pos or UDim2.new()
    b.BackgroundColor3 = color or CONFIG.THEME_COLOR_SECONDARY
    b.Text = text
    b.Font = CONFIG.FONT
    b.TextSize = 14
    b.TextColor3 = CONFIG.TEXT_COLOR_PRIMARY
    b.AutoButtonColor = false
    b.Parent = parent

    local corner = Instance.new("UICorner", b)
    corner.CornerRadius = UDim.new(0, 6)

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = b.BackgroundColor3:Lerp(Color3.new(1,1,1), 0.1)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = color or CONFIG.THEME_COLOR_SECONDARY}):Play()
    end)

    return b
end

function Utils.createToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Text = text
    label.Font = CONFIG.FONT
    label.TextSize = 14
    label.TextColor3 = CONFIG.TEXT_COLOR_PRIMARY
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -40, 0.5, -10)
    btn.BackgroundColor3 = default and CONFIG.THEME_COLOR_ACCENT or CONFIG.THEME_COLOR_SECONDARY
    btn.Text = ""
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    circle.Parent = btn
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and CONFIG.THEME_COLOR_ACCENT or CONFIG.THEME_COLOR_SECONDARY}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        callback(state)
    end)
end

-- Módulo: PlayerManager
local PlayerManager = {}
PlayerManager.selectedPlayers = {}
PlayerManager.playerButtons = {}

function PlayerManager.init(parent)
    local search = Instance.new("TextBox")
    search.Size = UDim2.new(1, -20, 0, 30)
    search.Position = UDim2.new(0, 10, 0, 10)
    search.BackgroundColor3 = CONFIG.THEME_COLOR_PRIMARY
    search.PlaceholderText = "Pesquisar jogador..."
    search.Text = ""
    search.Font = CONFIG.FONT
    search.TextColor3 = CONFIG.TEXT_COLOR_PRIMARY
    search.Parent = parent
    Instance.new("UICorner", search)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -50)
    scroll.Position = UDim2.new(0, 10, 0, 45)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 2
    scroll.Parent = parent

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 5)

    local function update()
        for _, v in pairs(PlayerManager.playerButtons) do v:Destroy() end
        table.clear(PlayerManager.playerButtons)
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name:lower():find(search.Text:lower()) or plr.DisplayName:lower():find(search.Text:lower()) then
                local btn = Utils.createButton(scroll, plr.DisplayName .. " (@" .. plr.Name .. ")")
                PlayerManager.playerButtons[plr.UserId] = btn
                
                if table.find(PlayerManager.selectedPlayers, plr) then
                    btn.BackgroundColor3 = CONFIG.THEME_COLOR_ACCENT
                end

                btn.MouseButton1Click:Connect(function()
                    local index = table.find(PlayerManager.selectedPlayers, plr)
                    if index then
                        table.remove(PlayerManager.selectedPlayers, index)
                        btn.BackgroundColor3 = CONFIG.THEME_COLOR_SECONDARY
                    else
                        table.insert(PlayerManager.selectedPlayers, plr)
                        btn.BackgroundColor3 = CONFIG.THEME_COLOR_ACCENT
                    end
                end)
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end

    search:GetPropertyChangedSignal("Text"):Connect(update)
    Players.PlayerAdded:Connect(update)
    Players.PlayerRemoving:Connect(update)
    update()
end

-- Módulo: Core
local Core = {}
function Core.init()
    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = "PremiumHUB"
    gui.ResetOnSpawn = false

    local win = Instance.new("Frame", gui)
    win.Size = CONFIG.WINDOW_SIZE
    win.Position = UDim2.new(0.5, -275, 0.5, -190)
    win.BackgroundColor3 = CONFIG.THEME_COLOR_PRIMARY
    win.ClipsDescendants = true
    Instance.new("UICorner", win).CornerRadius = CONFIG.CORNER_RADIUS
    Core.Window = win

    local header = Instance.new("Frame", win)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = CONFIG.THEME_COLOR_SECONDARY
    
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.Text = "PREMIUM HUB"
    title.Font = CONFIG.FONT_BOLD
    title.TextSize = 18
    title.TextColor3 = CONFIG.TEXT_COLOR_PRIMARY
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left

    local close = Utils.createButton(header, "X", UDim2.new(0, 30, 0, 30), UDim2.new(1, -40, 0.5, -15), CONFIG.THEME_COLOR_ERROR)
    close.MouseButton1Click:Connect(function() gui:Destroy() end)

    local min = Utils.createButton(header, "-", UDim2.new(0, 30, 0, 30), UDim2.new(1, -75, 0.5, -15))
    local minimized = false
    min.MouseButton1Click:Connect(function()
        minimized = not minimized
        TweenService:Create(win, TweenInfo.new(0.3), {Size = minimized and UDim2.new(0, 150, 0, 40) or CONFIG.WINDOW_SIZE}):Play()
    end)

    local sidebar = Instance.new("Frame", win)
    sidebar.Size = UDim2.new(0, 120, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = CONFIG.THEME_COLOR_SECONDARY
    
    local sideLayout = Instance.new("UIListLayout", sidebar)
    sideLayout.Padding = UDim.new(0, 2)
    sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local container = Instance.new("Frame", win)
    container.Size = UDim2.new(1, -130, 1, -50)
    container.Position = UDim2.new(0, 125, 0, 45)
    container.BackgroundTransparency = 1
    Core.Container = container

    -- Dragging
    local dragging, dragInput, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = win.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    Core.Tabs = {}
    function Core.addTab(name, callback)
        local btn = Utils.createButton(sidebar, name, UDim2.new(0.9, 0, 0, 35))
        local page = Instance.new("ScrollingFrame", container)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ScrollBarThickness = 2
        Instance.new("UIListLayout", page).Padding = UDim.new(0, 8)

        btn.MouseButton1Click:Connect(function()
            for _, p in pairs(Core.Tabs) do p.Visible = false end
            page.Visible = true
            for _, b in ipairs(sidebar:GetChildren()) do
                if b:IsA("TextButton") then b.BackgroundColor3 = CONFIG.THEME_COLOR_SECONDARY end
            end
            btn.BackgroundColor3 = CONFIG.THEME_COLOR_ACCENT
        end)
        Core.Tabs[name] = page
        callback(page)
    end
end

-- Funcionalidades
Core.init()

-- ABA: MAIN
Core.addTab("Main", function(page)
    Utils.createLabel(page, "Bem-vindo ao Lucky Blocks Ultimate!", UDim2.new(1, 0, 0, 30), nil, CONFIG.TEXT_COLOR_ACCENT, CONFIG.FONT_BOLD, 16)
    Utils.createLabel(page, "Selecione uma aba para começar.", UDim2.new(1, 0, 0, 20))
end)

-- ABA: EXPLOITS
Core.addTab("Exploits", function(page)
    local blocks = {"LuckyBlock", "SuperBlock", "DiamondBlock", "RainbowBlock", "GalaxyBlock", "GlitchBlock"}
    
    Utils.createButton(page, "Coletar Todos os Blocos", nil, nil, CONFIG.THEME_COLOR_SUCCESS).MouseButton1Click:Connect(function()
        for _, b in ipairs(blocks) do
            local r = ReplicatedStorage:FindFirstChild("Spawn" .. b)
            if r then r:FireServer() end
        end
        Utils.notify("Exploits", "Blocos coletados com sucesso!", 2, CONFIG.THEME_COLOR_SUCCESS)
    end)

    Utils.createToggle(page, "Auto Coletar (Loop)", false, function(state)
        _G.AutoCollect = state
        task.spawn(function()
            while _G.AutoCollect do
                for _, b in ipairs(blocks) do
                    local r = ReplicatedStorage:FindFirstChild("Spawn" .. b)
                    if r then r:FireServer() end
                end
                task.wait(0.5)
            end
        end)
    end)

    Utils.createLabel(page, "Gerenciamento de Itens", UDim2.new(1, 0, 0, 30), nil, CONFIG.TEXT_COLOR_ACCENT, CONFIG.FONT_BOLD, 14)
    local itemScroll = Instance.new("ScrollingFrame", page)
    itemScroll.Size = UDim2.new(1, 0, 0, 120)
    itemScroll.BackgroundTransparency = 0.8
    itemScroll.BackgroundColor3 = Color3.new(0,0,0)
    itemScroll.ScrollBarThickness = 2
    local itemLayout = Instance.new("UIListLayout", itemScroll)

    local function scan()
        for _, v in ipairs(itemScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
        local char = LocalPlayer.Character
        if char then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    local l = Utils.createLabel(itemScroll, "[Equipado] " .. tool.Name, UDim2.new(1, 0, 0, 20))
                    l.TextSize = 10
                end
            end
        end
        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
            local l = Utils.createLabel(itemScroll, "[Mochila] " .. tool.Name, UDim2.new(1, 0, 0, 20))
            l.TextSize = 10
        end
        itemScroll.CanvasSize = UDim2.new(0, 0, 0, itemLayout.AbsoluteContentSize.Y)
    end
    Utils.createButton(page, "Escanear Itens").MouseButton1Click:Connect(scan)
end)

-- ABA: TROLLS
Core.addTab("Trolls", function(page)
    Utils.createButton(page, "Congelar Selecionados", nil, nil, CONFIG.THEME_COLOR_ACCENT).MouseButton1Click:Connect(function()
        for _, plr in ipairs(PlayerManager.selectedPlayers) do
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.WalkSpeed = 0
                plr.Character.Humanoid.JumpPower = 0
            end
        end
        Utils.notify("Trolls", "Jogadores congelados!", 2)
    end)

    Utils.createButton(page, "Descongelar Selecionados", nil, nil, CONFIG.THEME_COLOR_SUCCESS).MouseButton1Click:Connect(function()
        for _, plr in ipairs(PlayerManager.selectedPlayers) do
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.WalkSpeed = 16
                plr.Character.Humanoid.JumpPower = 50
            end
        end
        Utils.notify("Trolls", "Jogadores descongelados!", 2)
    end)

    Utils.createLabel(page, "Controle Customizado", UDim2.new(1, 0, 0, 20), nil, CONFIG.TEXT_COLOR_ACCENT)
    local speedBox = Utils.createTextBox(page, "Velocidade (16)", UDim2.new(1, 0, 0, 30))
    Utils.createButton(page, "Aplicar Velocidade").MouseButton1Click:Connect(function()
        local s = tonumber(speedBox.Text) or 16
        for _, plr in ipairs(PlayerManager.selectedPlayers) do
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then plr.Character.Humanoid.WalkSpeed = s end
        end
    end)
end)

-- ABA: TELEPORT
Core.addTab("Teleport", function(page)
    Utils.createButton(page, "Ir para Jogador Selecionado").MouseButton1Click:Connect(function()
        if #PlayerManager.selectedPlayers > 0 then
            local target = PlayerManager.selectedPlayers[1].Character
            if target and target:FindFirstChild("HumanoidRootPart") then
                Utils.getCharacter().HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            end
        end
    end)
end)

-- ABA: PLAYER
Core.addTab("Player", function(page)
    PlayerManager.init(page)
end)

-- Finalização
Core.Tabs["Main"].Visible = true
Utils.notify("Premium HUB", "Carregado com sucesso!", 3, CONFIG.THEME_COLOR_SUCCESS)
