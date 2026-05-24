--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║  LUCKY BLOCKS BATTLEGROUNDS - PREMIUM HUB v3.0 ULTIMATE      ║
    ║  Script Corrigido para Executor Delta                        ║
    ║  Remote Events + Exploits + Trolls + Config Avançado        ║
    ║  Revisado e Otimizado                                        ║
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
    MAX_BLOCK_ITERATIONS = 50, -- Reduzido para evitar lag/kick
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

if PlayerGui:FindFirstChild("PremiumHUB") then 
    PlayerGui.PremiumHUB:Destroy() 
end

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 4: SISTEMA DE BYPASS E REMOTES
-- ═══════════════════════════════════════════════════════════════

local Bypass = {}

function Bypass.setHumanoidProperty(humanoid, property, value)
    if not humanoid or not humanoid.Parent then return false end
    local success = pcall(function()
        humanoid[property] = value
    end)
    return success
end

function Bypass.fireRemoteEvent(remoteName, ...)
    local remote = ReplicatedStorage:FindFirstChild(remoteName)
    if remote and remote:IsA("RemoteEvent") then
        local success = pcall(function()
            remote:FireServer(...)
        end)
        return success
    end
    return false
end

function Bypass.teleportPlayer(targetCFrame)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local success = pcall(function()
        char.HumanoidRootPart.CFrame = targetCFrame
    end)
    return success
end

function Bypass.setPartProperty(part, property, value)
    if not part or not part.Parent then return false end
    local success = pcall(function()
        part[property] = value
    end)
    return success
end

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 5: UTILITÁRIOS
-- ═══════════════════════════════════════════════════════════════

local Utils = {}

function Utils.getCharacter()
    return LocalPlayer.Character
end

function Utils.notify(title, message, color)
    local frame = Instance.new("Frame")
    frame.Name = "Notification"
    frame.Size = UDim2.new(0, 250, 0, 70)
    frame.Position = UDim2.new(1, 10, 1, -80)
    frame.BackgroundColor3 = CONFIG.THEME_SECONDARY
    frame.BorderSizePixel = 0
    frame.Parent = PlayerGui:FindFirstChild("PremiumHUB") or PlayerGui
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local accent = Instance.new("Frame", frame)
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = color or CONFIG.THEME_ACCENT
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 8)
    
    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 15, 0, 8)
    titleLabel.Text = title:upper()
    titleLabel.Font = CONFIG.FONT_BOLD
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = color or CONFIG.THEME_ACCENT
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
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
    
    TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -260, 1, -80)}):Play()
    
    task.delay(3, function()
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(1, 10, 1, -80)}):Play()
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
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = btn.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.15)}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color or CONFIG.THEME_SECONDARY}):Play()
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
    Instance.new("UICorner", search).CornerRadius = UDim.new(0, 6)
    
    local scroll = Instance.new("ScrollingFrame", parent)
    scroll.Size = UDim2.new(1, 0, 1, -45)
    scroll.Position = UDim2.new(0, 0, 0, 45)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 2
    scroll.BorderSizePixel = 0
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local function updatePlayerList()
        for _, btn in pairs(PlayerManager.buttons) do btn:Destroy() end
        table.clear(PlayerManager.buttons)
        
        for _, player in ipairs(Players:GetPlayers()) do
            local searchText = search.Text:lower()
            if player.Name:lower():find(searchText) or player.DisplayName:lower():find(searchText) then
                local btn = Utils.createButton(scroll, player.DisplayName .. " (@" .. player.Name .. ")", function()
                    local idx = table.find(PlayerManager.selected, player)
                    if idx then table.remove(PlayerManager.selected, idx) else table.insert(PlayerManager.selected, player) end
                    updatePlayerList()
                end)
                if table.find(PlayerManager.selected, player) then btn.BackgroundColor3 = CONFIG.THEME_ACCENT end
                PlayerManager.buttons[player.UserId] = btn
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end
    
    search:GetPropertyChangedSignal("Text"):Connect(updatePlayerList)
    Players.PlayerAdded:Connect(updatePlayerList)
    Players.PlayerRemoving:Connect(updatePlayerList)
    updatePlayerList()
end

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 7: CORE GUI
-- ═══════════════════════════════════════════════════════════════

local Core = { Tabs = {}, Pages = {} }

function Core.init()
    local sg = Instance.new("ScreenGui", PlayerGui)
    sg.Name = "PremiumHUB"
    sg.ResetOnSpawn = false
    Core.GUI = sg
    
    local main = Instance.new("Frame", sg)
    main.Size = CONFIG.WINDOW_SIZE
    main.Position = UDim2.new(0.5, -290, 0.5, -200)
    main.BackgroundColor3 = CONFIG.THEME_PRIMARY
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true -- Delta suporta Draggable legado, mas vamos manter simples
    Instance.new("UICorner", main).CornerRadius = CONFIG.CORNER_RADIUS
    
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = CONFIG.THEME_SECONDARY
    header.BorderSizePixel = 0
    local headerCorner = Instance.new("UICorner", header)
    headerCorner.CornerRadius = CONFIG.CORNER_RADIUS
    
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "PREMIUM HUB v3.0 - DELTA EDITION"
    title.Font = CONFIG.FONT_BOLD
    title.TextColor3 = CONFIG.THEME_ACCENT
    title.TextSize = 16
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local sidebar = Instance.new("Frame", main)
    sidebar.Size = UDim2.new(0, 150, 1, -50)
    sidebar.Position = UDim2.new(0, 10, 0, 50)
    sidebar.BackgroundTransparency = 1
    local sideLayout = Instance.new("UIListLayout", sidebar)
    sideLayout.Padding = UDim.new(0, 5)
    
    local container = Instance.new("Frame", main)
    container.Size = UDim2.new(1, -180, 1, -50)
    container.Position = UDim2.new(0, 170, 0, 50)
    container.BackgroundTransparency = 1
    
    function Core.addTab(tabName, callback)
        local tabBtn = Utils.createButton(sidebar, tabName, function()
            for _, page in pairs(Core.Pages) do page.Visible = false end
            for _, btn in pairs(Core.Tabs) do btn.BackgroundColor3 = CONFIG.THEME_SECONDARY end
            Core.Pages[tabName].Visible = true
            Core.Tabs[tabName].BackgroundColor3 = CONFIG.THEME_ACCENT
        end)
        
        local page = Instance.new("ScrollingFrame", container)
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.ScrollBarThickness = 2
        page.BorderSizePixel = 0
        local pageLayout = Instance.new("UIListLayout", page)
        pageLayout.Padding = UDim.new(0, 10)
        
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 10)
        end)
        
        Core.Tabs[tabName] = tabBtn
        Core.Pages[tabName] = page
        callback(page)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- SEÇÃO 8: ABAS E FUNÇÕES
-- ═══════════════════════════════════════════════════════════════

Core.init()

-- Aba Exploits
Core.addTab("Exploits", function(page)
    local blocks = {"LuckyBlock", "SuperBlock", "DiamondBlock", "RainbowBlock", "GalaxyBlock", "GlitchBlock"}
    
    Utils.createButton(page, "Pegar TODOS os Blocos", function()
        local count = 0
        for i = 1, CONFIG.MAX_BLOCK_ITERATIONS do
            for _, b in ipairs(blocks) do
                if Bypass.fireRemoteEvent("Spawn" .. b) then count = count + 1 end
            end
            task.wait(CONFIG.BLOCK_SPAWN_DELAY)
        end
        Utils.notify("Exploits", "Tentativa de coleta finalizada!", CONFIG.THEME_SUCCESS)
    end, CONFIG.THEME_SUCCESS)
    
    local autoOpening = false
    local autoBtn = Utils.createButton(page, "Auto-Abrir: OFF", function()
        autoOpening = not autoOpening
        autoBtn.Text = "Auto-Abrir: " .. (autoOpening and "ON" or "OFF")
    end)
    
    task.spawn(function()
        while true do
            if autoOpening then
                for _, b in ipairs(blocks) do Bypass.fireRemoteEvent("Spawn" .. b) end
            end
            task.wait(1)
        end
    end)
end)

-- Aba Trolls
Core.addTab("Trolls", function(page)
    Utils.createButton(page, "Congelar Selecionados", function()
        for _, p in ipairs(PlayerManager.selected) do
            if p.Character and p.Character:FindFirstChild("Humanoid") then
                Bypass.setHumanoidProperty(p.Character.Humanoid, "WalkSpeed", 0)
                Bypass.setHumanoidProperty(p.Character.Humanoid, "JumpPower", 0)
            end
        end
        Utils.notify("Trolls", "Ação executada!", CONFIG.THEME_ACCENT)
    end)
    
    Utils.createButton(page, "Descongelar Selecionados", function()
        for _, p in ipairs(PlayerManager.selected) do
            if p.Character and p.Character:FindFirstChild("Humanoid") then
                Bypass.setHumanoidProperty(p.Character.Humanoid, "WalkSpeed", 16)
                Bypass.setHumanoidProperty(p.Character.Humanoid, "JumpPower", 50)
            end
        end
    end)
end)

-- Aba Config
Core.addTab("Config", function(page)
    local flyEnabled = false
    local flySpeed = 50
    local bodyVel = nil
    
    local flyBtn = Utils.createButton(page, "Fly: OFF", function()
        flyEnabled = not flyEnabled
        local char = Utils.getCharacter()
        if flyEnabled and char and char:FindFirstChild("HumanoidRootPart") then
            bodyVel = Instance.new("BodyVelocity", char.HumanoidRootPart)
            bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            Utils.notify("Config", "Fly Ativado", CONFIG.THEME_SUCCESS)
        else
            if bodyVel then bodyVel:Destroy() end
            Utils.notify("Config", "Fly Desativado", CONFIG.THEME_ERROR)
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if flyEnabled and bodyVel and bodyVel.Parent then
            local move = Vector3.new(0,0,0)
            local root = bodyVel.Parent
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + root.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - root.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - root.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + root.CFrame.RightVector end
            bodyVel.Velocity = move * flySpeed
        end
    end)
    
    Utils.createButton(page, "WalkSpeed +", function()
        local h = Utils.getCharacter() and Utils.getCharacter():FindFirstChild("Humanoid")
        if h then h.WalkSpeed = h.WalkSpeed + 10 end
    end)
    
    Utils.createButton(page, "Invisível (Local)", function()
        local char = Utils.getCharacter()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.Transparency = 0.5 end
            end
        end
    end)
end)

-- Aba Itens
Core.addTab("Itens", function(page)
    Utils.createButton(page, "Duplicar Equipado", function()
        local char = Utils.getCharacter()
        if char then
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") then
                    for i=1,5 do t:Clone().Parent = LocalPlayer.Backpack end
                end
            end
        end
    end)
    
    Utils.createButton(page, "Limpar Mochila", function()
        LocalPlayer.Backpack:ClearAllChildren()
    end, CONFIG.THEME_ERROR)
end)

-- Aba Teleport
Core.addTab("Teleport", function(page)
    Utils.createButton(page, "Ir para Selecionado", function()
        if #PlayerManager.selected > 0 then
            local target = PlayerManager.selected[1].Character
            if target and target:FindFirstChild("HumanoidRootPart") then
                Bypass.teleportPlayer(target.HumanoidRootPart.CFrame * CFrame.new(0,3,0))
            end
        end
    end)
end)

-- Aba Player
Core.addTab("Player", function(page)
    PlayerManager.init(page)
end)

-- Finalização
Core.Pages["Exploits"].Visible = true
Core.Tabs["Exploits"].BackgroundColor3 = CONFIG.THEME_ACCENT
Utils.notify("Premium HUB", "Carregado com Sucesso!", CONFIG.THEME_SUCCESS)
print("[Premium HUB] Pronto para uso no Delta.")
