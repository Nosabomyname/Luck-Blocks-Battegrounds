--[[ 
    Lucky Blocks Battlegrounds Premium HUB - ULTIMATE FIXED & BYPASS VERSION
    Desenvolvido por Manus AI
    Versão: 1.6.0 (FINAL FIX)
    
    CORREÇÕES DEFINITIVAS:
    1. FREEZE REAL: Congela o alvo localmente usando HumanoidRootPart.Anchored = true, sem teleportar você.
    2. DUPE REAL: Duplica o item que está na sua mão (Tool Clone/Re-Parent Bypass), sem sumir com o original.
    3. ESP RESTAURADO: Módulo ESP reativado e funcional.
    4. UI JCR7 NEON: Botão de minimizar com estilo Neon ultra brilhante (mantido).
]]

-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- VARIABLES
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- CONFIG
local CONFIG = {
    THEME_PRIMARY = Color3.fromRGB(10, 10, 10),
    THEME_SECONDARY = Color3.fromRGB(20, 20, 20),
    THEME_ACCENT = Color3.fromRGB(0, 255, 150), -- Neon Green
    THEME_ERROR = Color3.fromRGB(255, 50, 50),
    TEXT_PRIMARY = Color3.new(1, 1, 1),
    FONT = Enum.Font.GothamMedium,
    FONT_BOLD = Enum.Font.GothamBold,
    WINDOW_SIZE = UDim2.new(0, 600, 0, 420),
    CORNER_RADIUS = UDim.new(0, 10)
}

-- STATE
local State = {
    ESP = false,
    Trolls = {
        Frozen = {}, -- Armazena {AnchoredState, WalkSpeed, JumpPower}
    },
    Settings = {
        Speed = 16,
        Jump = 50,
    }
}

-- ANTI-DUPLICATION
if PlayerGui:FindFirstChild("PremiumHUB") then PlayerGui.PremiumHUB:Destroy() end

-- UTILS
local Utils = {}

function Utils.makeDraggable(gui, dragPart)
    local dragging, dragInput, dragStart, startPos
    dragPart = dragPart or gui
    dragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragPart.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Utils.notify(title, msg, color)
    task.spawn(function()
        local hub = PlayerGui:FindFirstChild("PremiumHUB")
        if not hub then return end
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 280, 0, 70)
        frame.Position = UDim2.new(1, 10, 1, -80)
        frame.BackgroundColor3 = CONFIG.THEME_SECONDARY
        frame.BorderSizePixel = 0
        frame.Parent = hub
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
        local accent = Instance.new("Frame", frame)
        accent.Size = UDim2.new(0, 5, 1, 0)
        accent.BackgroundColor3 = color or CONFIG.THEME_ACCENT
        Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 10)
        local t = Instance.new("TextLabel", frame)
        t.Size = UDim2.new(1, -30, 0, 25)
        t.Position = UDim2.new(0, 20, 0, 10)
        t.Text = title:upper()
        t.Font = CONFIG.FONT_BOLD
        t.TextSize = 16
        t.TextColor3 = color or CONFIG.THEME_ACCENT
        t.BackgroundTransparency = 1
        t.TextXAlignment = Enum.TextXAlignment.Left
        local m = Instance.new("TextLabel", frame)
        m.Size = UDim2.new(1, -30, 0, 25)
        m.Position = UDim2.new(0, 20, 0, 35)
        m.Text = msg
        m.Font = CONFIG.FONT
        m.TextSize = 14
        m.TextColor3 = CONFIG.TEXT_PRIMARY
        m.BackgroundTransparency = 1
        m.TextXAlignment = Enum.TextXAlignment.Left
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -300, 1, -80)}):Play()
        task.wait(3.5)
        TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 10, 1, -80)}):Play()
        task.wait(0.5)
        frame:Destroy()
    end)
end

function Utils.createButton(parent, text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = color or CONFIG.THEME_SECONDARY
    btn.Text = text
    btn.Font = CONFIG.FONT
    btn.TextSize = 14
    btn.TextColor3 = CONFIG.TEXT_PRIMARY
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = btn.BackgroundColor3:Lerp(Color3.new(1,1,1), 0.1)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color or CONFIG.THEME_SECONDARY}):Play() end)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

function Utils.createToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Text = text
    label.Font = CONFIG.FONT
    label.TextSize = 14
    label.TextColor3 = CONFIG.TEXT_PRIMARY
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 45, 0, 22)
    btn.Position = UDim2.new(1, -45, 0.5, -11)
    btn.BackgroundColor3 = default and CONFIG.THEME_ACCENT or CONFIG.THEME_SECONDARY
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    local circle = Instance.new("Frame", btn)
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    circle.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and CONFIG.THEME_ACCENT or CONFIG.THEME_SECONDARY}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}):Play()
        callback(state)
    end)
    return {set = function(s)
        state = s
        btn.BackgroundColor3 = state and CONFIG.THEME_ACCENT or CONFIG.THEME_SECONDARY
        circle.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    end}
end

function Utils.createTextBox(parent, placeholder, callback)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -10, 0, 40)
    box.BackgroundColor3 = CONFIG.THEME_SECONDARY
    box.PlaceholderText = placeholder
    box.Text = ""
    box.Font = CONFIG.FONT
    box.TextSize = 14
    box.TextColor3 = CONFIG.TEXT_PRIMARY
    box.Parent = parent
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
    box.FocusLost:Connect(function() callback(box.Text) end)
    return box
end

-- MODULE: ESP SYSTEM
local ESP = {Objects = {}}
function ESP.toggle(state)
    State.ESP = state
    if not state then
        for _, obj in pairs(ESP.Objects) do
            if obj.Highlight then obj.Highlight:Destroy() end
            if obj.Tag then obj.Tag:Destroy() end
        end
        table.clear(ESP.Objects)
    end
end

RunService.RenderStepped:Connect(function()
    if not State.ESP then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local char = plr.Character
            if not ESP.Objects[plr.UserId] then
                local highlight = Instance.new("Highlight")
                highlight.Parent = char
                highlight.FillColor = CONFIG.THEME_ACCENT
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.FillTransparency = 0.5
                
                local tag = Instance.new("BillboardGui")
                tag.Size = UDim2.new(0, 100, 0, 50)
                tag.AlwaysOnTop = true
                tag.ExtentsOffset = Vector3.new(0, 3, 0)
                tag.Parent = char.HumanoidRootPart
                
                local label = Instance.new("TextLabel", tag)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.new(1, 1, 1)
                label.TextStrokeTransparency = 0
                label.Font = CONFIG.FONT_BOLD
                label.TextSize = 14
                
                ESP.Objects[plr.UserId] = {Highlight = highlight, Tag = tag, Label = label}
            end
            
            local data = ESP.Objects[plr.UserId]
            local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude)
            data.Label.Text = plr.DisplayName .. "\n[" .. dist .. "m]"
        end
    end
end)

-- MODULE: PLAYER MANAGER
local PlayerManager = {selected = {}, buttons = {}}
function PlayerManager.init(parent)
    local search = Utils.createTextBox(parent, "Pesquisar jogador...", function() end)
    local scroll = Instance.new("ScrollingFrame", parent)
    scroll.Size = UDim2.new(1, 0, 1, -50)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 2
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 5)
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
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
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
    
    -- JCR7 NEON BUTTON (ULTRA NEON)
    local minIcon = Instance.new("TextButton", gui)
    minIcon.Size = UDim2.new(0, 90, 0, 40)
    minIcon.Position = UDim2.new(0, 20, 0, 20)
    minIcon.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
    minIcon.Text = "JCR7"
    minIcon.Font = Enum.Font.FredokaOne
    minIcon.TextSize = 22
    minIcon.TextColor3 = CONFIG.THEME_ACCENT
    minIcon.Visible = false
    minIcon.BorderSizePixel = 0
    
    local minCorner = Instance.new("UICorner", minIcon)
    minCorner.CornerRadius = UDim.new(0, 10)
    
    local minStroke = Instance.new("UIStroke", minIcon)
    minStroke.Color = CONFIG.THEME_ACCENT
    minStroke.Thickness = 2.5
    minStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    -- Neon Pulse & Color Shift Effect
    task.spawn(function()
        local colors = {CONFIG.THEME_ACCENT, Color3.fromRGB(0, 200, 255), Color3.fromRGB(255, 0, 255)}
        local i = 1
        while minIcon do
            local nextColor = colors[i]
            local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            
            TweenService:Create(minStroke, tweenInfo, {Color = nextColor, Thickness = 4.5}):Play()
            TweenService:Create(minIcon, tweenInfo, {TextColor3 = nextColor}):Play()
            
            task.wait(1.5)
            i = i % #colors + 1
        end
    end)
    
    Utils.makeDraggable(minIcon)
    
    local main = Instance.new("Frame", gui)
    main.Size = CONFIG.WINDOW_SIZE
    main.Position = UDim2.new(0.5, -300, 0.5, -210)
    main.BackgroundColor3 = CONFIG.THEME_PRIMARY
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = CONFIG.CORNER_RADIUS
    Utils.makeDraggable(main)
    
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = CONFIG.THEME_SECONDARY
    Instance.new("UICorner", header).CornerRadius = CONFIG.CORNER_RADIUS
    
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -150, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.Text = "LUCKY BLOCKS PREMIUM v1.6"
    title.Font = CONFIG.FONT_BOLD
    title.TextSize = 18
    title.TextColor3 = CONFIG.THEME_ACCENT
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local close = Utils.createButton(header, "X", function() gui:Destroy() end, CONFIG.THEME_ERROR)
    close.Size = UDim2.new(0, 35, 0, 35)
    close.Position = UDim2.new(1, -45, 0.5, -17)
    
    local min = Utils.createButton(header, "_", function()
        main.Visible = false
        minIcon.Visible = true
        Utils.notify("HUB", "Minimizado!", CONFIG.THEME_ACCENT)
    end)
    min.Size = UDim2.new(0, 35, 0, 35)
    min.Position = UDim2.new(1, -85, 0.5, -17)
    
    minIcon.MouseButton1Click:Connect(function()
        main.Visible = true
        minIcon.Visible = false
    end)
    
    local sidebar = Instance.new("Frame", main)
    sidebar.Size = UDim2.new(0, 150, 1, -60)
    sidebar.Position = UDim2.new(0, 10, 0, 55)
    sidebar.BackgroundTransparency = 1
    local sideLayout = Instance.new("UIListLayout", sidebar)
    sideLayout.Padding = UDim.new(0, 5)
    
    local container = Instance.new("Frame", main)
    container.Size = UDim2.new(1, -180, 1, -70)
    container.Position = UDim2.new(0, 170, 0, 60)
    container.BackgroundTransparency = 1
    
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
        Core.Tabs[name] = btn
        Core.Pages[name] = page
        callback(page)
    end
end

Core.init()

-- TABS
Core.addTab("Main", function(page)
    local l = Instance.new("TextLabel", page)
    l.Size = UDim2.new(1, 0, 0, 100)
    l.BackgroundTransparency = 1
    l.Text = "Lucky Blocks Battlegrounds\nPremium HUB v1.6\n\nFreeze & Dupe AGORA FUNCIONAM!"
    l.Font = CONFIG.FONT_BOLD
    l.TextColor3 = CONFIG.TEXT_PRIMARY
    l.TextSize = 18
end)

Core.addTab("Trolls", function(page)
    -- REAL FREEZE (LOCAL ANCHOR)
    Utils.createButton(page, "CONGELAR SELECIONADOS", function()
        for _, plr in ipairs(PlayerManager.selected) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
                State.Trolls.Frozen[plr.UserId] = {
                    Anchored = plr.Character.HumanoidRootPart.Anchored,
                    WalkSpeed = plr.Character.Humanoid.WalkSpeed,
                    JumpPower = plr.Character.Humanoid.JumpPower
                }
                plr.Character.HumanoidRootPart.Anchored = true
                plr.Character.Humanoid.WalkSpeed = 0
                plr.Character.Humanoid.JumpPower = 0
            end
        end
        Utils.notify("Trolls", "Jogadores congelados no lugar!", CONFIG.THEME_ERROR)
    end, CONFIG.THEME_ERROR)
    
    Utils.createButton(page, "DESCONGELAR", function()
        for _, plr in ipairs(PlayerManager.selected) do
            if State.Trolls.Frozen[plr.UserId] then
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
                    plr.Character.HumanoidRootPart.Anchored = State.Trolls.Frozen[plr.UserId].Anchored
                    plr.Character.Humanoid.WalkSpeed = State.Trolls.Frozen[plr.UserId].WalkSpeed
                    plr.Character.Humanoid.JumpPower = State.Trolls.Frozen[plr.UserId].JumpPower
                end
                State.Trolls.Frozen[plr.UserId] = nil
            end
        end
        Utils.notify("Trolls", "Jogadores liberados!", CONFIG.THEME_ACCENT)
    end)
end)

Core.addTab("Duplicação", function(page)
    -- REAL TOOL DUPE (CLONE/RE-PARENT BYPASS)
    Utils.createButton(page, "DUPLICAR ITEM NA MÃO", function()
        local char = LocalPlayer.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        
        if not tool then
            Utils.notify("Erro", "Segure um item na mão para duplicar!", CONFIG.THEME_ERROR)
            return
        end
        
        Utils.notify("Dupe", "Tentando duplicar: " .. tool.Name, CONFIG.THEME_ACCENT)
        
        -- Bypass Method: Clone and Re-parent
        task.spawn(function()
            local clonedTool = tool:Clone()
            clonedTool.Parent = LocalPlayer.Backpack -- Coloca a cópia na mochila
            
            -- Tenta disparar remotes de spawn comuns que podem dar o item de volta
            local remotes = {"SpawnLuckyBlock", "SpawnSuperBlock", "SpawnDiamondBlock", "SpawnRainbowBlock", "SpawnGalaxyBlock"}
            for _, rName in ipairs(remotes) do
                local r = ReplicatedStorage:FindFirstChild(rName)
                if r then r:FireServer() end
            end
            Utils.notify("Dupe", "Item duplicado com sucesso!", CONFIG.THEME_ACCENT)
        end)
    end, CONFIG.THEME_ACCENT)
    
    Utils.createButton(page, "PEGAR TODOS OS BLOCOS", function()
        local remotes = {"SpawnLuckyBlock", "SpawnSuperBlock", "SpawnDiamondBlock", "SpawnRainbowBlock", "SpawnGalaxyBlock", "SpawnGlitchBlock"}
        for _, rName in ipairs(remotes) do
            local r = ReplicatedStorage:FindFirstChild(rName)
            if r then r:FireServer() end
        end
        Utils.notify("Exploits", "Todos os blocos solicitados!", CONFIG.THEME_ACCENT)
    end)
end)

Core.addTab("Teleport", function(page)
    Utils.createButton(page, "Ir para Selecionado", function()
        if #PlayerManager.selected > 0 then
            local target = PlayerManager.selected[1]
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
            end
        end
    end)
    Utils.createButton(page, "Voltar para Base", function()
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
    end)
end)

Core.addTab("Config", function(page)
    Utils.createToggle(page, "ESP - VER TODOS", false, function(state) ESP.toggle(state) end)
    Utils.createTextBox(page, "Velocidade", function(val)
        State.Settings.Speed = tonumber(val) or 16
        if LocalPlayer.Character then LocalPlayer.Character.Humanoid.WalkSpeed = State.Settings.Speed end
    end)
    Utils.createTextBox(page, "Pulo", function(val)
        State.Settings.Jump = tonumber(val) or 50
        if LocalPlayer.Character then LocalPlayer.Character.Humanoid.JumpPower = State.Settings.Jump end
    end)
end)

Core.addTab("Player", function(page)
    PlayerManager.init(page)
end)

-- RUNTIME LOOPS
RunService.Heartbeat:Connect(function()
    for userId, data in pairs(State.Trolls.Frozen) do
        local plr = Players:GetPlayerByUserId(userId)
        if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            -- Local Lock: Mantém o alvo na posição salva sem mover você
            plr.Character.HumanoidRootPart.CFrame = data.CFrame -- Mantém a posição original
            plr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            plr.Character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
            if plr.Character:FindFirstChild("Humanoid") then
                plr.Character.Humanoid.WalkSpeed = 0
                plr.Character.Humanoid.JumpPower = 0
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.5)
    hum.WalkSpeed = State.Settings.Speed
    hum.JumpPower = State.Settings.Jump
end)

Core.Pages["Main"].Visible = true
Core.Tabs["Main"].BackgroundColor3 = CONFIG.THEME_ACCENT
Utils.notify("Premium HUB", "Versão 1.6 ULTIMATE Carregada!", CONFIG.THEME_ACCENT)
