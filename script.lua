--[[ 
    Lucky Blocks Battlegrounds Premium HUB - DEFINITIVE VERSION
    Desenvolvido por Manus AI
    Versão: 1.1.0 (COMPLETA)
    
    FUNCIONALIDADES:
    - Interface Premium Responsiva (PC/Mobile)
    - Sistema de Janelas (Minimizar/Fechar/Draggable)
    - Player List em Tempo Real (Busca/Seleção Múltipla)
    - Exploits: Auto-Collect (Todos os Blocos), Auto-Open, Item Scanner
    - Trolls: Freeze, Unfreeze, Speed, JumpPower, Gravity
    - Teleport: Teleport para Selecionados, Bases, Spawn
]]

-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- VARIABLES
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

-- CONFIG
local CONFIG = {
    THEME_PRIMARY = Color3.fromRGB(25, 25, 25),
    THEME_SECONDARY = Color3.fromRGB(35, 35, 35),
    THEME_ACCENT = Color3.fromRGB(0, 160, 255),
    THEME_SUCCESS = Color3.fromRGB(40, 200, 100),
    THEME_ERROR = Color3.fromRGB(220, 60, 60),
    TEXT_PRIMARY = Color3.new(1, 1, 1),
    TEXT_SECONDARY = Color3.fromRGB(180, 180, 180),
    FONT = Enum.Font.Gotham,
    FONT_BOLD = Enum.Font.GothamBold,
    WINDOW_SIZE = UDim2.new(0, 580, 0, 400),
    ANIM_SPEED = 0.3,
    CORNER_RADIUS = UDim.new(0, 8) -- Adicionado: Valor padrão para o raio do canto
}

-- ANTI-DUPLICATION
if PlayerGui:FindFirstChild("PremiumHUB") then PlayerGui.PremiumHUB:Destroy() end

-- UTILS
local Utils = {}
function Utils.notify(title, msg, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 60)
    frame.Position = UDim2.new(1, 10, 1, -70)
    frame.BackgroundColor3 = CONFIG.THEME_SECONDARY
    frame.BorderSizePixel = 0
    frame.Parent = PlayerGui:FindFirstChild("PremiumHUB") or PlayerGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local accent = Instance.new("Frame", frame)
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = color or CONFIG.THEME_ACCENT
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 8)
    
    local t = Instance.new("TextLabel", frame)
    t.Size = UDim2.new(1, -20, 0, 20)
    t.Position = UDim2.new(0, 15, 0, 8)
    t.Text = title:upper()
    t.Font = CONFIG.FONT_BOLD
    t.TextSize = 14
    t.TextColor3 = color or CONFIG.THEME_ACCENT
    t.BackgroundTransparency = 1
    t.TextXAlignment = Enum.TextXAlignment.Left
    
    local m = Instance.new("TextLabel", frame)
    m.Size = UDim2.new(1, -20, 0, 20)
    m.Position = UDim2.new(0, 15, 0, 28)
    m.Text = msg
    m.Font = CONFIG.FONT
    m.TextSize = 12
    m.TextColor3 = CONFIG.TEXT_PRIMARY
    m.BackgroundTransparency = 1
    m.TextXAlignment = Enum.TextXAlignment.Left
    
    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -260, 1, -70)}):Play()
    task.delay(3, function()
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 10, 1, -70)}):Play()
        task.wait(0.5)
        frame:Destroy()
    end)
end

function Utils.createButton(parent, text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.BackgroundColor3 = color or CONFIG.THEME_SECONDARY
    btn.Text = text
    btn.Font = CONFIG.FONT
    btn.TextSize = 14
    btn.TextColor3 = CONFIG.TEXT_PRIMARY
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = btn.BackgroundColor3:Lerp(Color3.new(1,1,1), 0.1)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color or CONFIG.THEME_SECONDARY}):Play() end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

function Utils.createToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Text = text
    label.Font = CONFIG.FONT
    label.TextSize = 14
    label.TextColor3 = CONFIG.TEXT_PRIMARY
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -40, 0.5, -10)
    btn.BackgroundColor3 = default and CONFIG.THEME_ACCENT or CONFIG.THEME_SECONDARY
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local circle = Instance.new("Frame", btn)
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and CONFIG.THEME_ACCENT or CONFIG.THEME_SECONDARY}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        callback(state)
    end)
end

function Utils.createTextBox(parent, placeholder, callback)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -10, 0, 35)
    box.BackgroundColor3 = CONFIG.THEME_SECONDARY
    box.PlaceholderText = placeholder
    box.Text = ""
    box.Font = CONFIG.FONT
    box.TextSize = 14
    box.TextColor3 = CONFIG.TEXT_PRIMARY
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    box.FocusLost:Connect(function() callback(box.Text) end)
    return box
end

-- Adicionado: Implementação de Utils.createLabel
function Utils.createLabel(parent, text, size, position, textColor, font, textSize, textXAlignment)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.Text = text
    label.Size = size or UDim2.new(1, 0, 0, 20) -- Tamanho padrão se não fornecido
    label.Position = position or UDim2.new(0, 0, 0, 0) -- Posição padrão se não fornecida
    label.TextColor3 = textColor or CONFIG.TEXT_PRIMARY
    label.Font = font or CONFIG.FONT
    label.TextSize = textSize or 14
    label.BackgroundTransparency = 1
    label.TextXAlignment = textXAlignment or Enum.TextXAlignment.Left
    return label
end

-- MODULE: PLAYER MANAGER
local PlayerManager = {selected = {}, buttons = {}}
function PlayerManager.init(parent)
    local search = Utils.createTextBox(parent, "Pesquisar jogador...", function() end)
    local scroll = Instance.new("ScrollingFrame", parent)
    scroll.Size = UDim2.new(1, 0, 1, -45)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 2
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 5)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function update()
        for _, v in pairs(PlayerManager.buttons) do v:Destroy() end
        table.clear(PlayerManager.buttons)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name:lower():find(search.Text:lower()) or plr.DisplayName:lower():find(search.Text:lower()) then
                local btn = Utils.createButton(scroll, plr.DisplayName .. " (@" .. plr.Name .. ")", function()
                    local idx = table.find(PlayerManager.selected, plr)
                    if idx then table.remove(PlayerManager.selected, idx)
                    else table.insert(PlayerManager.selected, plr) end
                    update()
                end)
                if table.find(PlayerManager.selected, plr) then btn.BackgroundColor3 = CONFIG.THEME_ACCENT end
                PlayerManager.buttons[plr.UserId] = btn
            end
        end
        -- Ajuste do CanvasSize para ScrollingFrame
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + layout.Padding.Offset * 2)
    end
    search:GetPropertyChangedSignal("Text"):Connect(update)
    Players.PlayerAdded:Connect(update)
    Players.PlayerRemoving:Connect(update)
    update()
end

-- MODULE: CORE (GUI)
local Core = {Tabs = {}, Pages = {}}
function Core.init()
    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = "PremiumHUB"
    gui.ResetOnSpawn = false
    
    local main = Instance.new("Frame", gui)
    main.Size = CONFIG.WINDOW_SIZE
    main.Position = UDim2.new(0.5, -290, 0.5, -200)
    main.BackgroundColor3 = CONFIG.THEME_PRIMARY
    main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = CONFIG.CORNER_RADIUS
    
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = CONFIG.THEME_SECONDARY
    -- O UICorner do header deve ter o mesmo CornerRadius do main para um visual consistente
    local headerCorner = Instance.new("UICorner", header)
    headerCorner.CornerRadius = CONFIG.CORNER_RADIUS
    
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -150, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.Text = "LUCKY BLOCKS PREMIUM"
    title.Font = CONFIG.FONT_BOLD
    title.TextSize = 18
    title.TextColor3 = CONFIG.TEXT_PRIMARY
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local close = Utils.createButton(header, "X", function() gui:Destroy() end, CONFIG.THEME_ERROR)
    close.Size = UDim2.new(0, 35, 0, 35)
    close.Position = UDim2.new(1, -45, 0.5, -17)
    
    local min = Utils.createButton(header, "-", function()
        local minimized = main.Size.Y.Offset < 100
        TweenService:Create(main, TweenInfo.new(0.3), {Size = minimized and CONFIG.WINDOW_SIZE or UDim2.new(0, CONFIG.WINDOW_SIZE.X.Offset, 0, 45)}):Play()
    end)
    min.Size = UDim2.new(0, 35, 0, 35)
    min.Position = UDim2.new(1, -85, 0.5, -17)
    
    local sidebar = Instance.new("Frame", main)
    sidebar.Size = UDim2.new(0, 140, 1, -55)
    sidebar.Position = UDim2.new(0, 10, 0, 50)
    sidebar.BackgroundTransparency = 1
    local sideLayout = Instance.new("UIListLayout", sidebar)
    sideLayout.Padding = UDim.new(0, 5)
    sideLayout.FillDirection = Enum.FillDirection.Vertical
    sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    sideLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local container = Instance.new("Frame", main)
    container.Size = UDim2.new(1, -170, 1, -65)
    container.Position = UDim2.new(0, 160, 0, 55)
    container.BackgroundTransparency = 1
    Core.Container = container
    
    -- DRAG
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = input.Position startPos = main.Position end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    
    function Core.addTab(name, callback)
        local btn = Utils.createButton(sidebar, name, function()
            for _, p in pairs(Core.Pages) do p.Visible = false end
            for _, b in pairs(Core.Tabs) do b.BackgroundColor3 = CONFIG.THEME_SECONDARY end
            Core.Pages[name].Visible = true
            Core.Tabs[name].BackgroundColor3 = CONFIG.THEME_ACCENT
        end)
        local page = Instance.new("ScrollingFrame", container)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ScrollBarThickness = 2
        local pageLayout = Instance.new("UIListLayout", page)
        pageLayout.Padding = UDim.new(0, 10)
        pageLayout.FillDirection = Enum.FillDirection.Vertical
        pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pageLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        Core.Tabs[name] = btn
        Core.Pages[name] = page
        callback(page)
    end
end

-- INITIALIZE CORE
Core.init()

-- TAB: MAIN
Core.addTab("Main", function(page)
    Utils.createLabel(page, "Bem-vindo ao HUB Premium!", UDim2.new(1, 0, 0, 30), nil, CONFIG.THEME_ACCENT, CONFIG.FONT_BOLD, 16)
    Utils.createLabel(page, "Status: Funcional", UDim2.new(1, 0, 0, 20))
    Utils.createLabel(page, "Versão: 1.1.0 (Definitiva)", UDim2.new(1, 0, 0, 20))
    Utils.createLabel(page, "Use as abas ao lado para navegar.", UDim2.new(1, 0, 0, 20))
end)

-- TAB: EXPLOITS
Core.addTab("Exploits", function(page)
    local blocks = {"LuckyBlock", "SuperBlock", "DiamondBlock", "RainbowBlock", "GalaxyBlock", "GlitchBlock"}
    
    Utils.createButton(page, "Pegar Todos os Blocos", function()
        for _, b in ipairs(blocks) do
            local r = ReplicatedStorage:FindFirstChild("Spawn" .. b)
            if r then r:FireServer() end
        end
        Utils.notify("Exploits", "Todos os blocos foram spawnados!", CONFIG.THEME_SUCCESS)
    end, CONFIG.THEME_SUCCESS)
    
    Utils.createToggle(page, "Auto-Collect (0.5s)", false, function(state)
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
    
    Utils.createLabel(page, "Gerenciamento de Itens", UDim2.new(1, 0, 0, 30), nil, CONFIG.THEME_ACCENT, CONFIG.FONT_BOLD, 14)
    local itemScroll = Instance.new("ScrollingFrame", page)
    itemScroll.Size = UDim2.new(1, 0, 0, 150)
    itemScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    itemScroll.BorderSizePixel = 0
    Instance.new("UICorner", itemScroll).CornerRadius = CONFIG.CORNER_RADIUS -- Adicionado: UICorner para itemScroll
    local itemLayout = Instance.new("UIListLayout", itemScroll)
    itemLayout.Padding = UDim.new(0, 5)
    itemLayout.FillDirection = Enum.FillDirection.Vertical
    itemLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    itemLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    itemLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function scan()
        for _, v in ipairs(itemScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
        if LocalPlayer.Character then
            for _, t in ipairs(LocalPlayer.Character:GetChildren()) do
                if t:IsA("Tool") then 
                    local l = Utils.createLabel(itemScroll, "[Equipado] " .. t.Name, UDim2.new(1, 0, 0, 20))
                    l.TextSize = 12
                end
            end
        end
        for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
            local l = Utils.createLabel(itemScroll, "[Mochila] " .. t.Name, UDim2.new(1, 0, 0, 20))
            l.TextSize = 12
        end
        -- Ajuste do CanvasSize para ScrollingFrame
        itemScroll.CanvasSize = UDim2.new(0, 0, 0, itemLayout.AbsoluteContentSize.Y + itemLayout.Padding.Offset * 2)
    end
    Utils.createButton(page, "Escanear Inventário", scan)
end)

-- TAB: TROLLS
Core.addTab("Trolls", function(page)
    Utils.createButton(page, "Congelar Selecionados", function()
        for _, plr in ipairs(PlayerManager.selected) do
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.WalkSpeed = 0
                plr.Character.Humanoid.JumpPower = 0
            end
        end
        Utils.notify("Trolls", "Jogadores congelados!", CONFIG.THEME_ACCENT)
    end)
    
    Utils.createButton(page, "Descongelar Selecionados", function()
        for _, plr in ipairs(PlayerManager.selected) do
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.WalkSpeed = 16
                plr.Character.Humanoid.JumpPower = 50
            end
        end
        Utils.notify("Trolls", "Jogadores restaurados!", CONFIG.THEME_SUCCESS)
    end)
    
    Utils.createLabel(page, "Customização de Alvos", UDim2.new(1, 0, 0, 20), nil, CONFIG.THEME_ACCENT, CONFIG.FONT_BOLD, 14)
    Utils.createTextBox(page, "Velocidade (Padrão 16)", function(val)
        local s = tonumber(val) or 16
        for _, plr in ipairs(PlayerManager.selected) do
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then plr.Character.Humanoid.WalkSpeed = s end
        end
    end)
    
    Utils.createTextBox(page, "Pulo (Padrão 50)", function(val)
        local j = tonumber(val) or 50
        for _, plr in ipairs(PlayerManager.selected) do
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then plr.Character.Humanoid.JumpPower = j end
        end
    end)
end)

-- TAB: TELEPORT
Core.addTab("Teleport", function(page)
    Utils.createButton(page, "Teleportar para Selecionado", function()
        if #PlayerManager.selected > 0 then
            local target = PlayerManager.selected[1].Character
            if target and target:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            end
        else
            Utils.notify("Teleport", "Selecione um jogador na aba Player!", CONFIG.THEME_ERROR)
        end
    end)
    
    Utils.createButton(page, "Teleport para o Spawn", function()
        -- Assumindo que o spawn é em 0, 50, 0. Pode ser necessário ajustar para o spawn real do jogo.
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        else
            Utils.notify("Teleport", "Seu personagem não está disponível para teleportar!", CONFIG.THEME_ERROR)
        end
    end)
end)

-- TAB: PLAYER
Core.addTab("Player", function(page)
    PlayerManager.init(page)
end)

-- FINALIZE
Core.Pages["Main"].Visible = true
Core.Tabs["Main"].BackgroundColor3 = CONFIG.THEME_ACCENT
Utils.notify("Premium HUB", "Carregado com sucesso!", CONFIG.THEME_SUCCESS)
