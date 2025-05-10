--// Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

--// Staff Detection (DisplayName-based)
local staffList = {
	Eyroku = true, realkeatos123456 = true, Capybarabruv = true, kurosfx = true,
	PancakesHDD = true, OSCARsdb1 = true, missionslayer = true, ["80poplic"] = true,
	["32MAF"] = true, clexa123456 = true, YugoGrace = true, NotMistiCat = true,
	MinishWasntTaken = true, risingnixillium = true, evas84832 = true, benyibandz = true,
	Marko_Sans = true, ["2j2ij2j"] = true, AZ_PRO2020 = true, ruri_kuu = true,
	tidypop = true, Turboohh = true, kitakro = true, hitakru = true,
	kyasuji = true, kyesumi = true
}

Players.PlayerAdded:Connect(function(player)
	if staffList[player.Name] then
		player:GetPropertyChangedSignal("DisplayName"):Connect(function()
			StarterGui:SetCore("SendNotification", {
				Title = "EthanHub Warning",
				Text = player.DisplayName .. " has joined. RISKY. Disable AutoBlock or leave.",
				Duration = 10
			})
		end)
		StarterGui:SetCore("SendNotification", {
			Title = "EthanHub Warning",
			Text = player.DisplayName .. " has joined. RISKY. Disable AutoBlock or leave.",
			Duration = 10
		})
	end
end)

--// GUI Setup
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "EthanHubGUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 300, 0, 230)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

--// Custom Manual Drag Support
local dragging, dragInput, dragStart, startPos
Frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position
	end
end)
Frame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

--// UI Components
local function makeLabel(parent, text, yPos)
	local lbl = Instance.new("TextLabel", parent)
	lbl.Text = text
	lbl.Size = UDim2.new(1, -20, 0, 30)
	lbl.Position = UDim2.new(0, 10, 0, yPos)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
	lbl.TextScaled = true
	return lbl
end

local function makeBox(parent, placeholder, yPos)
	local box = Instance.new("TextBox", parent)
	box.Size = UDim2.new(0, 280, 0, 30)
	box.Position = UDim2.new(0, 10, 0, yPos)
	box.PlaceholderText = placeholder
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.TextScaled = true
	return box
end

local title = makeLabel(Frame, "EthanHub AutoBlock", 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local toggle = Instance.new("TextButton", Frame)
toggle.Position = UDim2.new(0, 10, 0, 40)
toggle.Size = UDim2.new(0, 280, 0, 30)
toggle.Text = "Toggle AutoBlock (OFF)"
toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextScaled = true

local delaySlider = makeBox(Frame, "Set Delay (ms, default: 0)", 80)
local radiusSlider = makeBox(Frame, "Set Range (studs, default: 10)", 120)
local keybindBox = makeBox(Frame, "Keybind (ex: R)", 160)
local hideText = makeLabel(Frame, "Press Right Shift to hide/show GUI", 195)

--// Logic
local autoblockEnabled = false
local chosenKey = Enum.KeyCode.R
local delay = 0 -- kept for GUI compatibility, but not used
local radius = 10

toggle.MouseButton1Click:Connect(function()
	autoblockEnabled = not autoblockEnabled
	toggle.Text = "Toggle AutoBlock (" .. (autoblockEnabled and "ON" or "OFF") .. ")"
	StarterGui:SetCore("SendNotification", {
		Title = "EthanHub",
		Text = "AutoBlock " .. (autoblockEnabled and "enabled" or "disabled"),
		Duration = 4
	})
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.RightShift then
			Frame.Visible = not Frame.Visible
		elseif input.KeyCode == chosenKey and not UIS:GetFocusedTextBox() then
			autoblockEnabled = not autoblockEnabled
			toggle.Text = "Toggle AutoBlock (" .. (autoblockEnabled and "ON" or "OFF") .. ")"
			StarterGui:SetCore("SendNotification", {
				Title = "EthanHub",
				Text = "AutoBlock " .. (autoblockEnabled and "enabled" or "disabled"),
				Duration = 4
			})
		end
	end
end)

keybindBox.FocusLost:Connect(function()
	local key = keybindBox.Text:upper()
	local kc = Enum.KeyCode[key]
	if kc then chosenKey = kc end
end)

delaySlider.FocusLost:Connect(function()
	local val = tonumber(delaySlider.Text)
	if val then delay = math.clamp(val, 0, 100) end
end)

radiusSlider.FocusLost:Connect(function()
	local val = tonumber(radiusSlider.Text)
	if val then radius = math.clamp(val, 0, 20) end
end)

--// Arena Detection
local function GetCurrentArena()
	local CurrentArena = nil
	local Opponent = nil

	for _, Arena in pairs(workspace:WaitForChild("Arenas"):GetChildren()) do
		local Info = Arena:FindFirstChild("Info")
		local P1 = Info and Info:FindFirstChild("P1", true)
		local P2 = Info and Info:FindFirstChild("P2", true)
		local Active = Info and Info:FindFirstChild("Active")

		if Active and Active.Value then
			if P1 and P2 then
				local T1 = P1:FindFirstChild("Title") and P1.Title.Text
				local T2 = P2:FindFirstChild("Title") and P2.Title.Text

				if T1 == LocalPlayer.Name then
					CurrentArena = Arena
					Opponent = T2
				elseif T2 == LocalPlayer.Name then
					CurrentArena = Arena
					Opponent = T1
				end
			end
		end
	end

	return CurrentArena, Opponent
end

--// Animation Detection (with zero delay)
local targetAnimations = {
	["82911091354553"] = true, ["103336801329780"] = true, ["105150646815272"] = true,
	["98318926280319"] = true, ["108913510610406"] = true, ["107740883402248"] = true,
	["122701861229121"] = true, ["125018409349026"] = true, ["114221477824657"] = true,
	["83802329098847"] = true, ["118480299660805"] = true, ["113684712729173"] = true,
	["72927149141988"] = true, ["126662379286392"] = true, ["75572200914356"] = true,
	["121198390506303"] = true, ["122913161645160"] = true, ["114218990397580"] = true,
	["106497344112583"] = true, ["131037233929491"] = true, ["112272301704366"] = true,
	["99933226512298"] = true, ["121357948303216"] = true, ["130596967059494"] = true,
	["83407779189782"] = true, ["131738926005737"] = true, ["77211220327972"] = true,
	["106329559025355"] = true, ["100775133196683"] = true, ["107606309178933"] = true,
	["85410000959765"] = true, ["76496360985151"] = true, ["74555786900330"] = true
}

--// Core autoblock
RS.RenderStepped:Connect(function()
	if not autoblockEnabled then return end
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
			for _, track in pairs(plr.Character.Humanoid:GetPlayingAnimationTracks()) do
				if targetAnimations[track.Animation.AnimationId:match("%d+")] then
					local root1 = Character:FindFirstChild("HumanoidRootPart")
					local root2 = plr.Character:FindFirstChild("HumanoidRootPart")
					if root1 and root2 then
						local dist = (root1.Position - root2.Position).Magnitude
						if dist <= radius then
							mouse2click() -- instant block (no delay)
						end
					end
				end
			end
		end
	end
end)



