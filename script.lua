-- ✅ Lucky Blocks GUI v1.4 | por João + ChatGPT
-- 💡 Compatível com KRNL Mobile | Com função SLOT limpa e simples

local lp = game.Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

if pg:FindFirstChild("LuckyBlocksGUI") then
	pg:FindFirstChild("LuckyBlocksGUI"):Destroy()
end

local gui = Instance.new("ScreenGui", pg)
gui.Name = "LuckyBlocksGUI"
gui.ResetOnSpawn = false

-- Frame principal
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 300)
frame.Position = UDim2.new(0.5, -200, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

-- Título
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Lucky Blocks - GUI v1.4"
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
local tabs = {}
local pages = {}

local function createTab(name, posX)
	local tab = Instance.new("TextButton", frame)
	tab.Size = UDim2.new(0, 100, 0, 30)
	tab.Position = UDim2.new(0, posX, 0, 40)
	tab.Text = name
	tab.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	tab.TextColor3 = Color3.new(1, 1, 1)
	tab.Font = Enum.Font.Gotham
	tab.TextSize = 14
	tabs[#tabs + 1] = tab
	return tab
end

local function createPage()
	local page = Instance.new("Frame", frame)
	page.Size = UDim2.new(1, -20, 0, 180)
	page.Position = UDim2.new(0, 10, 0, 80)
	page.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	page.Visible = false
	pages[#pages + 1] = page
	return page
end

local tabNames = {"Exploits", "Teleporte", "Slot"}
local tabX = {10, 120, 230}

for i = 1, #tabNames do
	tabs[i] = createTab(tabNames[i], tabX[i])
	pages[i] = createPage()
end

-- Alternar abas
for i = 1, #tabs do
	tabs[i].MouseButton1Click:Connect(function()
		for j = 1, #pages do
			pages[j].Visible = false
		end
		pages[i].Visible = true
	end)
end
pages[1].Visible = true

-- Aba Exploits
local exploitsPage = pages[1]
local howmany = 1

local btn = Instance.new("TextButton", exploitsPage)
btn.Size = UDim2.new(1, -20, 0, 30)
btn.Position = UDim2.new(0, 10, 0, 10)
btn.Text = "Pegar TODOS os Blocos"
btn.BackgroundColor3 = Color3.fromRGB(20, 120, 20)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.Gotham
btn.TextSize = 14

btn.MouseButton1Click:Connect(function()
	for i = 1, 100 do
		for _, name in pairs({"LuckyBlock", "SuperBlock", "DiamondBlock", "RainbowBlock", "GalaxyBlock"}) do
			local e = game:GetService("ReplicatedStorage"):FindFirstChild("Spawn"..name)
			if e then e:FireServer() end
		end
	end
end)

-- Aba Teleporte
local tpPage = pages[2]
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
			b.Font = Enum.Font.Gotham
			b.TextSize = 13
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

-- Aba Slot (você pediu!)
local slotPage = pages[3]

local listFrame = Instance.new("ScrollingFrame", slotPage)
listFrame.Size = UDim2.new(1, -20, 1, -50)
listFrame.Position = UDim2.new(0, 10, 0, 10)
listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
listFrame.ScrollBarThickness = 4
listFrame.CanvasSize = UDim2.new(0, 0, 2, 0)

local function logSlotItem(text)
	local label = Instance.new("TextLabel", listFrame)
	label.Size = UDim2.new(1, -10, 0, 20)
	label.Position = UDim2.new(0, 5, 0, (#listFrame:GetChildren() - 1) * 20)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.Code
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
end

local scanBtn = Instance.new("TextButton", slotPage)
scanBtn.Size = UDim2.new(0.48, -5, 0, 30)
scanBtn.Position = UDim2.new(0, 10, 1, -35)
scanBtn.Text = "Escanear SLOT"
scanBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
scanBtn.TextColor3 = Color3.new(1, 1, 1)
scanBtn.Font = Enum.Font.Gotham
scanBtn.TextSize = 14

local clearBtn = Instance.new("TextButton", slotPage)
clearBtn.Size = UDim2.new(0.48, -5, 0, 30)
clearBtn.Position = UDim2.new(0.52, 5, 1, -35)
clearBtn.Text = "Limpar SLOT"
clearBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
clearBtn.TextColor3 = Color3.new(1, 1, 1)
clearBtn.Font = Enum.Font.Gotham
clearBtn.TextSize = 14

scanBtn.MouseButton1Click:Connect(function()
	listFrame:ClearAllChildren()
	if lp.Character then
		for _, tool in pairs(lp.Character:GetChildren()) do
			if tool:IsA("Tool") then
				logSlotItem("• "..tool.Name)
			end
		end
	end
end)

clearBtn.MouseButton1Click:Connect(function()
	listFrame:ClearAllChildren()
end)
