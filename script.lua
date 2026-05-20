-- ✅ Lucky Blocks Battleground v3.0 | por João.S


local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

local old = pg:FindFirstChild("LuckyBlocksGUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "LuckyBlocksGUI"
gui.ResetOnSpawn = false
gui.Parent = pg

--====================================================
-- HELPERS
--====================================================

local function getCharacter()
	local char = lp.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		return char
	end
end

local function notify(msg, time)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 300, 0, 35)
	label.Position = UDim2.new(0.5, -150, 0, 10)
	label.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
	label.TextColor3 = Color3.new(1,1,1)
	label.Text = msg
	label.Font = Enum.Font.Gotham
	label.TextSize = 14
	label.BorderSizePixel = 0
	label.Parent = gui
	Debris:AddItem(label, time or 2)
end

local function clearLabels(parent)
	for _, v in ipairs(parent:GetChildren()) do
		if v:IsA("TextLabel") then
			v:Destroy()
		end
	end
end

local function createButton(parent, text, size, pos, color)
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = pos
	b.Text = text
	b.BackgroundColor3 = color or Color3.fromRGB(80,80,80)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.BorderSizePixel = 0
	b.Parent = parent
		local buttonCorner = Instance.new("UICorner")
		buttonCorner.CornerRadius = UDim.new(0, 6)
		buttonCorner.Parent = b
	return b
end

--====================================================
-- MAIN FRAME
--====================================================

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 320)
frame.Position = UDim2.new(0.5, -210, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 8)
	frameCorner.Parent = frame
	
	local closeBtn = createButton(
		frame,
		"X",
		UDim2.new(0,30,0,30),
		UDim2.new(1,-30,0,0),
		Color3.fromRGB(200,60,60)
	)
	closeBtn.TextSize = 18
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)
title.Text = "Lucky Blocks GUI v2"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

--====================================================
-- TABS SYSTEM
--====================================================

local tabs = {}
local pages = {}

local tabNames = {"Exploits","Teleporte","Slot"}

local function switchTab(index)
	for i,v in ipairs(pages) do
		v.Visible = (i == index)
	end
end

for i,name in ipairs(tabNames) do
	local tab = createButton(
		frame,
		name,
		UDim2.new(0,120,0,30),
		UDim2.new(0, 10 + ((i-1)*130), 0, 40)
	)

	local page = Instance.new("Frame")
	page.Size = UDim2.new(1,-20,0,220)
	page.Position = UDim2.new(0,10,0,80)
	page.BackgroundColor3 = Color3.fromRGB(40,40,40)
	page.Visible = false
	page.Parent = frame

	tab.MouseButton1Click:Connect(function()
		switchTab(i)
	end)

	tabs[i] = tab
	pages[i] = page
end

switchTab(1)

--====================================================
-- ABA 1: EXPLOITS
--====================================================

local exploitPage = pages[1]

local collecting = false
local autoOpening = false

local collectBtn = createButton(
	exploitPage,
	"Pegar TODOS os Blocos",
	UDim2.new(1,-20,0,35),
	UDim2.new(0,10,0,10),
	Color3.fromRGB(20,120,20)
)

local autoOpenBtn = createButton(
	exploitPage,
	"Auto-Abrir Blocos: OFF",
	UDim2.new(1,-20,0,35),
	UDim2.new(0,10,0,50),
	Color3.fromRGB(200,100,0)
)

local function doCollectBlocks()
	if collecting then
		return notify("Já executando.",2)
	end

	local char = getCharacter()
	if not char then
		return notify("Personagem não encontrado.",2)
	end

	collecting = true
	collectBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)

	local names = {
		"LuckyBlock",
		"SuperBlock",
		"DiamondBlock",	
		"RainbowBlock",
		"GalaxyBlock"
	}

	local total = 0

	for _ = 1,100 do
		for _,name in ipairs(names) do
			local remote = game.ReplicatedStorage:FindFirstChild("Spawn"..name)
			if remote and remote:IsA("RemoteEvent") then
				pcall(function()
					remote:FireServer()
					total += 1
				end)
			end
		end
		task.wait(0.05)
	end

	collecting = false
	collectBtn.BackgroundColor3 = Color3.fromRGB(20,120,20)
	notify("Concluído: "..total,3)
end

collectBtn.MouseButton1Click:Connect(doCollectBlocks)

autoOpenBtn.MouseButton1Click:Connect(function()
	autoOpening = not autoOpening
	if autoOpening then
		autoOpenBtn.Text = "Auto-Abrir Blocos: ON"
		autoOpenBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
		notify("Auto-Abrir Blocos ATIVADO", 2)
		
		-- Start auto-opening loop in a new thread
		spawn(function()
			while autoOpening do
				doCollectBlocks()
				task.wait(1) -- Wait 1 second before next attempt
			end
		end)
	else
		autoOpenBtn.Text = "Auto-Abrir Blocos: OFF"
		autoOpenBtn.BackgroundColor3 = Color3.fromRGB(200,100,0)
		notify("Auto-Abrir Blocos DESATIVADO", 2)
	end
end)

--====================================================
-- ABA 2: TELEPORT
--====================================================

local tpPage = pages[2]

local searchBox = Instance.new("TextBox")
	searchBox.Size = UDim2.new(1,-20,0,30)
	searchBox.Position = UDim2.new(0,10,0,5)
	searchBox.PlaceholderText = "Pesquisar jogador..."
	searchBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
	searchBox.TextColor3 = Color3.new(1,1,1)
	searchBox.Font = Enum.Font.Gotham
	searchBox.TextSize = 14
	searchBox.Parent = tpPage

	local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,-20,1,-10)
scroll.Position = UDim2.new(0,10,0,40)
scroll.CanvasSize = UDim2.new()
scroll.ScrollBarThickness = 4
scroll.BackgroundColor3 = Color3.fromRGB(50,50,50)
scroll.Parent = tpPage

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,5)
layout.Parent = scroll

local playerButtons = {}

local function updatePlayers(filterText)
		filterText = filterText or ""
		filterText = string.lower(filterText)
	for _,btn in pairs(playerButtons) do
		btn:Destroy()
	end
	table.clear(playerButtons)

	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp and string.find(string.lower(plr.Name), filterText) then
			local b = createButton(
				scroll,
				"TP "..plr.Name,
				UDim2.new(1,-10,0,30),
				UDim2.new()
			)

			b.MouseButton1Click:Connect(function()
				local char = getCharacter()
				if not char then return end

				local target = plr.Character
				if target and target:FindFirstChild("HumanoidRootPart") then
					char:MoveTo(target.HumanoidRootPart.Position + Vector3.new(0,3,0))
					notify("Teleportado para "..plr.Name,2)
				end
			end)

			playerButtons[plr.UserId] = b
		end
	end

	task.wait()
	scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end

updatePlayers(searchBox.Text)
Players.PlayerAdded:Connect(function() updatePlayers(searchBox.Text) end)
Players.PlayerRemoving:Connect(function() updatePlayers(searchBox.Text) end)

	searchBox.Changed:Connect(function(prop)
		if prop == "Text" then
			updatePlayers(searchBox.Text)
		end
	end)

--====================================================
-- ABA 3: SLOT
--====================================================

local slotPage = pages[3]

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1,-20,1,-50)
list.Position = UDim2.new(0,10,0,10)
list.BackgroundColor3 = Color3.fromRGB(20,20,20)
list.ScrollBarThickness = 4
list.Parent = slotPage

local slotLayout = Instance.new("UIListLayout")
slotLayout.Padding = UDim.new(0,2)
slotLayout.Parent = list

local function addSlotItem(text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,-5,0,20)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1,1,1)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.Code
	label.TextSize = 13
	label.Parent = list

	task.wait()
	list.CanvasSize = UDim2.new(0,0,0,slotLayout.AbsoluteContentSize.Y + 10)
end

local scan = createButton(
	slotPage,
	"Escanear",
	UDim2.new(0.48,-5,0,30),
	UDim2.new(0,10,1,-35),
	Color3.fromRGB(70,130,255)
)

local clear = createButton(
	slotPage,
	"Limpar",
	UDim2.new(0.48,-5,0,30),
	UDim2.new(0.52,5,1,-35),
	Color3.fromRGB(200,60,60)
)

scan.MouseButton1Click:Connect(function()
	clearLabels(list)

	local count = 0
	local char = getCharacter()

	if not char then
		return addSlotItem("(Sem personagem)")
	end

	for _,tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") then
			addSlotItem("[CHAR] "..tool.Name)
			count += 1
		end
	end

	local backpack = lp:FindFirstChild("Backpack")
	if backpack then
		for _,tool in ipairs(backpack:GetChildren()) do
			if tool:IsA("Tool") then
				addSlotItem("[BACKPACK] "..tool.Name)
				count += 1
			end
		end
	end

	if count == 0 then
		addSlotItem("(Nenhum item)")
	end
end)

clear.MouseButton1Click:Connect(function()
	clearLabels(list)
	notify("Slot limpo",1)
end)
