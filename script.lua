-- ✅ Lucky Blocks GUI by ChatGPT + João (v1.2 com aba Sniffer)
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

-- Restaurar
local restoreBtn = Instance.new("TextButton", gui)
restoreBtn.Size = UDim2.new(0, 80, 0, 30)
restoreBtn.Position = UDim2.new(0.5, -40, 0.65, -15)
restoreBtn.Text = "JCR7"
restoreBtn.Visible = false
restoreBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
restoreBtn.TextColor3 = Color3.new(1, 1, 1)
restoreBtn.Font = Enum.Font.Gotham
restoreBtn.TextSize = 14
restoreBtn.Active = true
restoreBtn.Draggable = true

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

local tab3 = Instance.new("TextButton", frame)
tab3.Size = UDim2.new(0, 100, 0, 30)
tab3.Position = UDim2.new(0, 230, 0, 40)
tab3.Text = "Sniffer"
tab3.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
tab3.TextColor3 = Color3.new(1, 1, 1)

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

local sniffPage = Instance.new("Frame", frame)
sniffPage.Size = exploitsPage.Size
sniffPage.Position = exploitsPage.Position
sniffPage.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sniffPage.Visible = false

-- Alternar abas
tab1.MouseButton1Click:Connect(function()
	exploitsPage.Visible = true
	tpPage.Visible = false
	sniffPage.Visible = false
end)

tab2.MouseButton1Click:Connect(function()
	exploitsPage.Visible = false
	tpPage.Visible = true
	sniffPage.Visible = false
end)

tab3.MouseButton1Click:Connect(function()
	exploitsPage.Visible = false
	tpPage.Visible = false
	sniffPage.Visible = true
end)

-- Conteúdo da aba Exploits
local blockName = "LuckyBlock"
local howmany = 1

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

local allBtn = Instance.new("TextButton", exploitsPage)
allBtn.Size = UDim2.new(1, -20, 0, 30)
allBtn.Position = UDim2.new(0, 10, 0, 130)
allBtn.Text = "Pegar TODOS os Blocos"
allBtn.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
allBtn.TextColor3 = Color3.new(1,1,1)
allBtn.MouseButton1Click:Connect(function()
	for i = 1, 100 do
		for _, name in pairs({"LuckyBlock", "SuperBlock", "DiamondBlock", "RainbowBlock", "GalaxyBlock"}) do
			local e = game:GetService("ReplicatedStorage"):FindFirstChild("Spawn"..name)
			if e then e:FireServer() end
		end
	end
end)

-- Conteúdo da aba Teleporte
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

-- 📦 Sniffer + Scanner de Inventário (Aba Sniffer)

local sniffing = false

local logFrame = Instance.new("ScrollingFrame", sniffPage)
logFrame.Size = UDim2.new(1, -20, 1, -90)
logFrame.Position = UDim2.new(0, 10, 0, 10)
logFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
logFrame.BorderSizePixel = 0
logFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
logFrame.ScrollBarThickness = 3
logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local function addLog(text, color)
	local label = Instance.new("TextLabel", logFrame)
	label.Size = UDim2.new(1, -10, 0, 20)
	label.Position = UDim2.new(0, 5, 0, (#logFrame:GetChildren() - 1) * 20)
	label.BackgroundTransparency = 1
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.Font = Enum.Font.Code
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
end

-- 🔘 Botão: Ativar/Desativar Sniffer
local toggleSniff = Instance.new("TextButton", sniffPage)
toggleSniff.Size = UDim2.new(0.48, -15, 0, 30)
toggleSniff.Position = UDim2.new(0, 10, 1, -35)
toggleSniff.Text = "Ativar Sniffer"
toggleSniff.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
toggleSniff.TextColor3 = Color3.new(1, 1, 1)
toggleSniff.Font = Enum.Font.Gotham
toggleSniff.TextSize = 14

-- 🔘 Botão: Escanear Inventário
local invBtn = Instance.new("TextButton", sniffPage)
invBtn.Size = UDim2.new(0.48, -15, 0, 30)
invBtn.Position = UDim2.new(0.52, 5, 1, -35)
invBtn.Text = "Escanear Inventários"
invBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 160)
invBtn.TextColor3 = Color3.new(1, 1, 1)
invBtn.Font = Enum.Font.Gotham
invBtn.TextSize = 14

toggleSniff.MouseButton1Click:Connect(function()
	sniffing = not sniffing
	toggleSniff.Text = sniffing and "Desativar Sniffer" or "Ativar Sniffer"
	addLog(sniffing and "[SNIFFER ATIVADO]" or "[Sniffer desativado]", Color3.fromRGB(0, 200, 255))
end)

-- 📡 Escutar RemoteEvents por OnClientEvent
task.spawn(function()
	for _, remote in ipairs(game:GetDescendants()) do
		if remote:IsA("RemoteEvent") then
			pcall(function()
				remote.OnClientEvent:Connect(function(...)
					if sniffing then
						local args = {...}
						local str = ""
						for _, v in pairs(args) do
							str = str .. tostring(v) .. " | "
						end
						addLog("[Remote] "..remote.Name.." → "..str, Color3.fromRGB(0, 255, 140))
					end
				end)
			end)
		end
	end
end)

-- 📡 Capturar RemoteEvents dinâmicos
game.DescendantAdded:Connect(function(obj)
	if obj:IsA("RemoteEvent") then
		pcall(function()
			obj.OnClientEvent:Connect(function(...)
				if sniffing then
					local args = {...}
					local str = ""
					for _, v in pairs(args) do
						str = str .. tostring(v) .. " | "
					end
					addLog("[Novo Remote] "..obj.Name.." → "..str, Color3.fromRGB(255, 200, 0))
				end
			end)
		end)
	end
end)

-- 🎒 Scanner de Inventários de Todos os Jogadores
invBtn.MouseButton1Click:Connect(function()
	addLog("[📦 ESCANEANDO INVENTÁRIOS]", Color3.fromRGB(0, 255, 255))
	for _, plr in pairs(game.Players:GetPlayers()) do
		if plr ~= lp and plr:FindFirstChild("Backpack") then
			for _, item in pairs(plr.Backpack:GetChildren()) do
				addLog("["..plr.Name.."] → "..item.Name, Color3.fromRGB(255, 255, 140))
			end
		end
	end
end)
