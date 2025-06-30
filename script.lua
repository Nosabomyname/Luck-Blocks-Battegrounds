-- ✅ Lucky Blocks GUI by ChatGPT + João (v1.1 com botão JCR7 corrigido)
-- 💡 Funcional no KRNL MOBILE

local lp = game.Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

if pg:FindFirstChild("LuckyBlocksGUI") then
	pg:FindFirstChild("LuckyBlocksGUI"):Destroy()
end

local gui = Instance.new("ScreenGui", pg)
gui.Name = "LuckyBlocksGUI"
gui.ResetOnSpawn = false

-- Frame Principal
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 300)
frame.Position = UDim2.new(0.5, -200, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

-- Título
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Lucky Blocks - GUI por João"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

-- Minimizar
local minimizeBtn = Instance.new("TextButton", frame)
minimizeBtn.Size = UDim2.new(0, 80, 0, 30)
minimizeBtn.Position = UDim2.new(0, 10, 0, 260)
minimizeBtn.Text = "Minimizar"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.Font = Enum.Font.Gotham
minimizeBtn.TextSize = 14

-- ✅ Restaurar corrigido (posição corrigida + arrastável + visível corretamente em celular deitado)
local restoreBtn = Instance.new("TextButton", gui)
restoreBtn.Size = UDim2.new(0, 80, 0, 30)
restoreBtn.Position = UDim2.new(0.5, -40, 0.65, -15) -- 📌 ajustado para posição mais acima
restoreBtn.Text = "JCR7"
restoreBtn.Visible = false
restoreBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
restoreBtn.TextColor3 = Color3.new(1, 1, 1)
restoreBtn.Font = Enum.Font.Gotham
restoreBtn.TextSize = 14
restoreBtn.Active = true
restoreBtn.Draggable = true -- ✅ agora arrastável

minimizeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	restoreBtn.Visible = true
end)

restoreBtn.MouseButton1Click:Connect(function()
	frame.Visible = true
	restoreBtn.Visible = false
end)

-- Abas
local tab1 = Instance.new("TextButton", frame)
tab1.Size = UDim2.new(0, 100, 0, 30)
tab1.Position = UDim2.new(0, 10, 0, 40)
tab1.Text = "Exploits"
tab1.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
tab1.TextColor3 = Color3.new(1, 1, 1)

local tab2 = Instance.new("TextButton", frame)
tab2.Size = UDim2.new(0, 100, 0, 30)
tab2.Position = UDim2.new(0, 120, 0, 40)
tab2.Text = "Teleporte"
tab2.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
tab2.TextColor3 = Color3.new(1, 1, 1)

-- Páginas
local exploitsPage = Instance.new("Frame", frame)
exploitsPage.Size = UDim2.new(1, -20, 0, 180)
exploitsPage.Position = UDim2.new(0, 10, 0, 80)
exploitsPage.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
exploitsPage.Visible = true

local tpPage = Instance.new("Frame", frame)
tpPage.Size = exploitsPage.Size
tpPage.Position = exploitsPage.Position
tpPage.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tpPage.Visible = false

-- Alternar abas
tab1.MouseButton1Click:Connect(function()
	exploitsPage.Visible = true
	tpPage.Visible = false
end)

tab2.MouseButton1Click:Connect(function()
	exploitsPage.Visible = false
	tpPage.Visible = true
end)

-- Dropdown de blocos
local blockName = "LuckyBlock"
local dropdown = Instance.new("TextBox", exploitsPage)
dropdown.Size = UDim2.new(1, -20, 0, 30)
dropdown.Position = UDim2.new(0, 10, 0, 10)
dropdown.Text = "LuckyBlock"
dropdown.PlaceholderText = "Digite: LuckyBlock, SuperBlock, etc"
dropdown.TextColor3 = Color3.new(1, 1, 1)
dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dropdown.FocusLost:Connect(function()
	blockName = dropdown.Text
end)

-- Slider (quantidade)
local howmany = 1
local slider = Instance.new("TextBox", exploitsPage)
slider.Size = UDim2.new(1, -20, 0, 30)
slider.Position = UDim2.new(0, 10, 0, 50)
slider.Text = "1"
slider.PlaceholderText = "Quantos blocos abrir (1 a 20)"
slider.TextColor3 = Color3.new(1, 1, 1)
slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
slider.FocusLost:Connect(function()
	howmany = tonumber(slider.Text) or 1
end)

-- Botão: Abrir bloco
local openBtn = Instance.new("TextButton", exploitsPage)
openBtn.Size = UDim2.new(1, -20, 0, 30)
openBtn.Position = UDim2.new(0, 10, 0, 90)
openBtn.Text = "Abrir Bloco"
openBtn.BackgroundColor3 = Color3.fromRGB(20, 120, 20)
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.MouseButton1Click:Connect(function()
	for i = 1, howmany do
		local event = game:GetService("ReplicatedStorage"):FindFirstChild("Spawn"..blockName)
		if event then
			event:FireServer()
		end
	end
end)

-- Botão: Pegar todos
local allBtn = Instance.new("TextButton", exploitsPage)
allBtn.Size = UDim2.new(1, -20, 0, 30)
allBtn.Position = UDim2.new(0, 10, 0, 130)
allBtn.Text = "Pegar TODOS os Blocos"
allBtn.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
allBtn.TextColor3 = Color3.new(1,1,1)
allBtn.MouseButton1Click:Connect(function()
	for i = 1, 100 do
		for _, name in pairs({"LuckyBlock","SuperBlock","DiamondBlock","RainbowBlock","GalaxyBlock"}) do
			local e = game:GetService("ReplicatedStorage"):FindFirstChild("Spawn"..name)
			if e then e:FireServer() end
		end
	end
end)

-- Página de TP
local scroll = Instance.new("ScrollingFrame", tpPage)
scroll.Size = UDim2.new(1, -20, 1, -10)
scroll.Position = UDim2.new(0, 10, 0, 5)
scroll.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
scroll.ScrollBarThickness = 4

local function listarPlayers()
	for _, btn in pairs(scroll:GetChildren()) do
		if btn:IsA("TextButton") then btn:Destroy() end
	end

	for i, plr in pairs(game.Players:GetPlayers()) do
		if plr ~= lp then
			local b = Instance.new("TextButton", scroll)
			b.Size = UDim2.new(1, -10, 0, 30)
			b.Position = UDim2.new(0, 5, 0, (i - 1) * 35)
			b.Text = "Teleportar até "..plr.Name
			b.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			b.TextColor3 = Color3.new(1,1,1)
			b.MouseButton1Click:Connect(function()
				if lp.Character and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					lp.Character:MoveTo(plr.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
				end
			end)
		end
	end
end

listarPlayers()
game.Players.PlayerAdded:Connect(listarPlayers)
game.Players.PlayerRemoving:Connect(listarPlayers)
