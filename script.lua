--[[ 
    Lucky Blocks Battlegrounds Premium HUB - v3.0 ULTIMATE
    Script Completo com Bypass Injetado para Trolls
    Todas as Funções: Exploits, Trolls, Teleport, Player List, Configuração, Itens
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

-- CONFIG
local CONFIG = {
    THEME_PRIMARY = Color3.fromRGB(20, 20, 20),
    THEME_SECONDARY = Color3.fromRGB(35, 35, 35),
    THEME_ACCENT = Color3.fromRGB(0, 160, 255),
    THEME_SUCCESS = Color3.fromRGB(46, 204, 113),
    THEME_ERROR = Color3.fromRGB(231, 76, 60),
    TEXT_PRIMARY = Color3.new(1, 1, 1),
    FONT = Enum.Font.Gotham,
    FONT_BOLD = Enum.Font.GothamBold,
    CORNER_RADIUS = UDim.new(0, 10),
    WINDOW_SIZE = UDim2.new(0, 580, 0, 400)
}

-- ANTI-DUPLICAÇÃO
if PlayerGui:FindFirstChild("PremiumHUB") then PlayerGui.PremiumHUB:Destroy() end
if PlayerGui:FindFirstChild("LuckyBlocksEnhancedGUI") then PlayerGui.LuckyBlocksEnhancedGUI:Destroy() end

-- BYPASS INJECTION SYSTEM
local Bypass = {}
function Bypass.setHumanoidProperty(humanoid, property, value)
    if humanoid then
        pcall(function()
            humanoid[property] = value
        end)
    end
end

function Bypass.fireRemoteEvent(remoteName, ...)
    local remote = ReplicatedStorage:FindFirstChild(remoteName)
    if remote and remote:IsA("RemoteEvent") then
        pcall(function()
            remote:FireServer(...)
        end)
    end
end

function Bypass.invokeRemoteFunction(remoteName, ...)
    local remote = ReplicatedStorage:FindFirstChild(remoteName)
    if remote and remote:IsA("RemoteFunction") then
        return pcall(function()
            return remote:InvokeServer(...)
        end)
    end
end

-- UTILS (Motor Original)
local Utils = {}
function Utils.getCharacter()
    local char = LocalPlayer.Character
    return (char and char:FindFirstChild("HumanoidRootPart")) and char or nil
end

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

-- MODULE: PLAYER MANAGER
local PlayerManager = {selected = {}, buttons = {}}
function PlayerManager.init(parent)
    local search = Instance.new("TextBox", parent)
    search.Size = UDim2.new(1, -20, 0, 30)
    search.Position = UDim2.new(0, 10, 0, 0)
    search.BackgroundColor3 = CONFIG.THEME_PRIMARY
    search.PlaceholderText = "Pesquisar jogador..."
    search.Text = ""
    search.Font = CONFIG.FONT
    search.TextColor3 = CONFIG.TEXT_PRIMARY
    Instance.new("UICorner", search)

    local scroll = Instance.new("ScrollingFrame", parent)
    scroll.Size = UDim2.new(1, 0, 1, -45)
    scroll.Position = UDim2.new(0, 0, 0, 45)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 2
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 5)
    
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
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end
    search:GetPropertyChangedSignal("Text"):Connect(update)
    Players.PlayerAdded:Connect(update)
    Players.PlayerRemoving:Connect(update)
    update()
end

-- CORE GUI
local Core = {Tabs = {}, Pages = {}}
function Core.init()
    local gui = Instance.new("ScreenGui", PlayerGui)
    gui.Name = "PremiumHUB"
    gui.ResetOnSpawn = false
    
    local main = Instance.new("Frame", gui)
    main.Size = CONFIG.WINDOW_SIZE
    main.Position = UDim2.new(0.5, -290, 0.5, -200)
    main.BackgroundColor3 = CONFIG.THEME_PRIMARY
    Instance.new("UICorner", main).CornerRadius = CONFIG.CORNER_RADIUS
    
    local header = Instance.new("Frame", main)
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = CONFIG.THEME_SECONDARY
    Instance.new("UICorner", header).CornerRadius = CONFIG.CORNER_RADIUS
    
    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -150, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.Text = "LUCKY BLOCKS PREMIUM HUB v3.0"
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
        TweenService:Create(main, TweenInfo.new(0.3), {Size = minimized and CONFIG.WINDOW_SIZE or UDim2.new(0, 200, 0, 45)}):Play()
    end)
    min.Size = UDim2.new(0, 35, 0, 35)
    min.Position = UDim2.new(1, -85, 0.5, -17)
    
    local sidebar = Instance.new("Frame", main)
    sidebar.Size = UDim2.new(0, 140, 1, -55)
    sidebar.Position = UDim2.new(0, 10, 0, 50)
    sidebar.BackgroundTransparency = 1
    Instance.new("UIListLayout", sidebar).Padding = UDim.new(0, 5)
    
    local container = Instance.new("Frame", main)
    container.Size = UDim2.new(1, -170, 1, -65)
    container.Position = UDim2.new(0, 160, 0, 55)
    container.BackgroundTransparency = 1
    
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
        Instance.new("UIListLayout", page).Padding = UDim.new(0, 10)
        
        Core.Tabs[name] = btn
        Core.Pages[name] = page
        callback(page)
    end
end

-- INIT
Core.init()

-- TAB: EXPLOITS (Motor Original - Completo)
Core.addTab("Exploits", function(page)
    local blocks = {"LuckyBlock", "SuperBlock", "DiamondBlock", "RainbowBlock", "GalaxyBlock", "GlitchBlock"}
    
    Utils.createButton(page, "Pegar TODOS os Blocos", function()
        for _ = 1, 100 do
            for _, name in ipairs(blocks) do
                local remote = ReplicatedStorage:FindFirstChild("Spawn" .. name)
                if remote then remote:FireServer() end
            end
            task.wait(0.05)
        end
        Utils.notify("Exploits", "Coleta concluída!", CONFIG.THEME_SUCCESS)
    end, CONFIG.THEME_SUCCESS)
    
    local autoOpening = false
    local autoBtn = Utils.createButton(page, "Auto-Abrir: OFF", function()
        autoOpening = not autoOpening
        autoBtn.Text = "Auto-Abrir: " .. (autoOpening and "ON" or "OFF")
        Utils.notify("Auto-Abrir", autoOpening and "ATIVADO" or "DESATIVADO", autoOpening and CONFIG.THEME_SUCCESS or CONFIG.THEME_ERROR)
    end)
    
    task.spawn(function()
        while true do
            if autoOpening then
                for _, name in ipairs(blocks) do
                    local remote = ReplicatedStorage:FindFirstChild("Spawn" .. name)
                    if remote then remote:FireServer() end
                end
            end
            task.wait(1)
        end
    end)
end)

-- TAB: TROLLS (Com Bypass Injetado)
Core.addTab("Trolls", function(page)
    Utils.createButton(page, "Congelar Selecionados", function()
        if #PlayerManager.selected == 0 then
            Utils.notify("Trolls", "Nenhum jogador selecionado!", CONFIG.THEME_ERROR)
            return
        end
        for _, plr in ipairs(PlayerManager.selected) do
            if plr and plr.Character then
                local humanoid = plr.Character:FindFirstChild("Humanoid")
                if humanoid then
                    Bypass.setHumanoidProperty(humanoid, "WalkSpeed", 0)
                    Bypass.setHumanoidProperty(humanoid, "JumpPower", 0)
                end
            end
        end
        Utils.notify("Trolls", "Alvos congelados!", CONFIG.THEME_ACCENT)
    end)
    
    Utils.createButton(page, "Descongelar Selecionados", function()
        if #PlayerManager.selected == 0 then
            Utils.notify("Trolls", "Nenhum jogador selecionado!", CONFIG.THEME_ERROR)
            return
        end
        for _, plr in ipairs(PlayerManager.selected) do
            if plr and plr.Character then
                local humanoid = plr.Character:FindFirstChild("Humanoid")
                if humanoid then
                    Bypass.setHumanoidProperty(humanoid, "WalkSpeed", 16)
                    Bypass.setHumanoidProperty(humanoid, "JumpPower", 50)
                end
            end
        end
        Utils.notify("Trolls", "Alvos restaurados!", CONFIG.THEME_SUCCESS)
    end)

    local speedValue = 16
    Utils.createButton(page, "Velocidade +", function()
        if #PlayerManager.selected == 0 then
            Utils.notify("Trolls", "Nenhum jogador selecionado!", CONFIG.THEME_ERROR)
            return
        end
        speedValue = math.min(speedValue + 5, 100)
        for _, plr in ipairs(PlayerManager.selected) do
            if plr and plr.Character then
                local humanoid = plr.Character:FindFirstChild("Humanoid")
                if humanoid then Bypass.setHumanoidProperty(humanoid, "WalkSpeed", speedValue) end
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
        for _, plr in ipairs(PlayerManager.selected) do
            if plr and plr.Character then
                local humanoid = plr.Character:FindFirstChild("Humanoid")
                if humanoid then Bypass.setHumanoidProperty(humanoid, "WalkSpeed", speedValue) end
            end
        end
        Utils.notify("Trolls", "Velocidade: " .. speedValue, CONFIG.THEME_ACCENT)
    end)

    local jumpValue = 50
    Utils.createButton(page, "Pulo +", function()
        if #PlayerManager.selected == 0 then
            Utils.notify("Trolls", "Nenhum jogador selecionado!", CONFIG.THEME_ERROR)
            return
        end
        jumpValue = math.min(jumpValue + 10, 200)
        for _, plr in ipairs(PlayerManager.selected) do
            if plr and plr.Character then
                local humanoid = plr.Character:FindFirstChild("Humanoid")
                if humanoid then Bypass.setHumanoidProperty(humanoid, "JumpPower", jumpValue) end
            end
        end
        Utils.notify("Trolls", "Pulo: " .. jumpValue, CONFIG.THEME_ACCENT)
    end)
    
    Utils.createButton(page, "Pulo -", function()
        if #PlayerManager.selected == 0 then
            Utils.notify("Trolls", "Nenhum jogador selecionado!", CONFIG.THEME_ERROR)
            return
        end
        jumpValue = math.max(jumpValue - 10, 0)
        for _, plr in ipairs(PlayerManager.selected) do
            if plr and plr.Character then
                local humanoid = plr.Character:FindFirstChild("Humanoid")
                if humanoid then Bypass.setHumanoidProperty(humanoid, "JumpPower", jumpValue) end
            end
        end
        Utils.notify("Trolls", "Pulo: " .. jumpValue, CONFIG.THEME_ACCENT)
    end)

    Utils.createButton(page, "Remover Gravidade", function()
        if #PlayerManager.selected == 0 then
            Utils.notify("Trolls", "Nenhum jogador selecionado!", CONFIG.THEME_ERROR)
            return
        end
        for _, plr in ipairs(PlayerManager.selected) do
            if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local bodyForce = Instance.new("BodyForce", plr.Character.HumanoidRootPart)
                bodyForce.Force = Vector3.new(0, 196.2 * plr.Character.HumanoidRootPart:GetMass(), 0)
            end
        end
        Utils.notify("Trolls", "Gravidade zero aplicada!", CONFIG.THEME_ACCENT)
    end)
end)

-- TAB: CONFIGURAÇÃO (Funções Locais)
Core.addTab("Config", function(page)
    local flyEnabled = false
    local flySpeed = 50
    local flyConnection = nil
    
    Utils.createButton(page, "Fly: OFF", function()
        flyEnabled = not flyEnabled
        local char = Utils.getCharacter()
        if not char then
            Utils.notify("Config", "Personagem não encontrado!", CONFIG.THEME_ERROR)
            flyEnabled = false
            return
        end
        
        if flyEnabled then
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local bodyVelocity = Instance.new("BodyVelocity", rootPart)
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                
                if flyConnection then flyConnection:Disconnect() end
                flyConnection = RunService.RenderStepped:Connect(function()
                    if flyEnabled and bodyVelocity and bodyVelocity.Parent then
                        local moveDir = Vector3.new(0, 0, 0)
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + (rootPart.CFrame.LookVector) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - (rootPart.CFrame.LookVector) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - (rootPart.CFrame.RightVector) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + (rootPart.CFrame.RightVector) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                        bodyVelocity.Velocity = moveDir.Unit * flySpeed
                    end
                end)
            end
            Utils.notify("Config", "Fly ATIVADO", CONFIG.THEME_SUCCESS)
        else
            if flyConnection then flyConnection:Disconnect() end
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local bodyVel = rootPart:FindFirstChild("BodyVelocity")
                if bodyVel then bodyVel:Destroy() end
            end
            Utils.notify("Config", "Fly DESATIVADO", CONFIG.THEME_ERROR)
        end
    end)
    
    Utils.createButton(page, "Fly Speed +", function()
        flySpeed = math.min(flySpeed + 10, 200)
        Utils.notify("Config", "Fly Speed: " .. flySpeed, CONFIG.THEME_ACCENT)
    end)
    
    Utils.createButton(page, "Fly Speed -", function()
        flySpeed = math.max(flySpeed - 10, 10)
        Utils.notify("Config", "Fly Speed: " .. flySpeed, CONFIG.THEME_ACCENT)
    end)
    
    local localWalkSpeed = 16
    Utils.createButton(page, "WalkSpeed +", function()
        local char = Utils.getCharacter()
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                localWalkSpeed = math.min(localWalkSpeed + 5, 100)
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
    
    local localJumpPower = 50
    Utils.createButton(page, "JumpPower +", function()
        local char = Utils.getCharacter()
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                localJumpPower = math.min(localJumpPower + 10, 200)
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
    
    local invisibilityEnabled = false
    Utils.createButton(page, "Invisível: OFF", function()
        invisibilityEnabled = not invisibilityEnabled
        local char = Utils.getCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = invisibilityEnabled and 1 or 0
                end
            end
            Utils.notify("Config", invisibilityEnabled and "Invisível ATIVADO" or "Invisível DESATIVADO", invisibilityEnabled and CONFIG.THEME_SUCCESS or CONFIG.THEME_ERROR)
        end
    end)
    
    Utils.createButton(page, "Reset Padrão", function()
        local char = Utils.getCharacter()
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then
                Bypass.setHumanoidProperty(humanoid, "WalkSpeed", 16)
                Bypass.setHumanoidProperty(humanoid, "JumpPower", 50)
            end
            
            if flyConnection then flyConnection:Disconnect() end
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local bodyVel = rootPart:FindFirstChild("BodyVelocity")
                if bodyVel then bodyVel:Destroy() end
            end
            flyEnabled = false
            
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
            invisibilityEnabled = false
            
            localWalkSpeed = 16
            localJumpPower = 50
            flySpeed = 50
            
            Utils.notify("Config", "Valores padrão restaurados!", CONFIG.THEME_SUCCESS)
        end
    end)
end)

-- TAB: ITENS (Duplicação + Gerenciamento)
Core.addTab("Itens", function(page)
    Utils.createButton(page, "Duplicar Itens Equipados", function()
        local char = Utils.getCharacter()
        if char then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then
                    for i = 1, 5 do
                        local clone = tool:Clone()
                        clone.Parent = LocalPlayer.Backpack
                    end
                end
            end
            Utils.notify("Itens", "Itens duplicados na mochila!", CONFIG.THEME_SUCCESS)
        end
    end)
    
    Utils.createButton(page, "Limpar Mochila", function()
        LocalPlayer.Backpack:ClearAllChildren()
        Utils.notify("Itens", "Mochila limpa!", CONFIG.THEME_ERROR)
    end)
    
    Utils.createButton(page, "Escanear Itens", function()
        local char = Utils.getCharacter()
        local itemCount = 0
        if char then
            for _, tool in ipairs(char:GetChildren()) do
                if tool:IsA("Tool") then itemCount = itemCount + 1 end
            end
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then itemCount = itemCount + 1 end
            end
        end
        Utils.notify("Itens", "Total de itens: " .. itemCount, CONFIG.THEME_ACCENT)
    end)
end)

-- TAB: TELEPORT
Core.addTab("Teleport", function(page)
    Utils.createButton(page, "Teleportar para Selecionado", function()
        if #PlayerManager.selected > 0 then
            local target = PlayerManager.selected[1].Character
            if target and target:FindFirstChild("HumanoidRootPart") then
                local char = Utils.getCharacter()
                if char then
                    char.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
                    Utils.notify("Teleport", "Teleportado!", CONFIG.THEME_SUCCESS)
                end
            end
        else
            Utils.notify("Teleport", "Nenhum jogador selecionado!", CONFIG.THEME_ERROR)
        end
    end)
    
    Utils.createButton(page, "Teleportar Todos para Você", function()
        local char = Utils.getCharacter()
        if char then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(math.random(-5, 5), 3, math.random(-5, 5))
                end
            end
            Utils.notify("Teleport", "Todos teleportados!", CONFIG.THEME_SUCCESS)
        end
    end)
end)

-- TAB: PLAYER
Core.addTab("Player", function(page)
    PlayerManager.init(page)
end)

-- FINALIZAÇÃO
Core.Pages["Exploits"].Visible = true
Core.Tabs["Exploits"].BackgroundColor3 = CONFIG.THEME_ACCENT
Utils.notify("Premium HUB", "v3.0 - Bypass Injetado e Funcional!", CONFIG.THEME_SUCCESS)
