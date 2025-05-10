-- EthanHub AutoBlock – Free Version
-- Join our Discord: https://discord.gg/w6fyk64B95

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Camera = workspace.CurrentCamera

-- Configurable staff usernames (checks DisplayName on join)
local staffList = {
    Eyroku = true, realkeatos123456 = true, Capybarabruv = true, kurosfx = true,
    PancakesHDD = true, OSCARsdb1 = true, missionslayer = true, ["80poplic"] = true,
    ["32MAF"] = true, clexa123456 = true, YugoGrace = true, NotMistiCat = true,
    MinishWasntTaken = true, risingnixillium = true, evas84832 = true, benyibandz = true,
    Marko_Sans = true, ["2j2ij2j"] = true, AZ_PRO2020 = true, ruri_kuu = true,
    tidypop = true, Turboohh = true, kitakro = true, hitakru = true,
    kyasuji = true, kyesumi = true
}

-- Notify if a staff joins
Players.PlayerAdded:Connect(function(player)
    if staffList[player.Name] then
        player:GetPropertyChangedSignal("DisplayName"):Connect(function()
            StarterGui:SetCore("SendNotification", {
                Title = "EthanHub Warning",
                Text = player.DisplayName.." has joined the game. HIGH RISK! Turn off AutoBlock or leave.",
                Duration = 10
            })
        end)
        StarterGui:SetCore("SendNotification", {
            Title = "EthanHub Warning",
            Text = player.DisplayName.." has joined the game. HIGH RISK! Turn off AutoBlock or leave.",
            Duration = 10
        })
    end
end)

-- Create GUI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "EthanHubGUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 300, 0, 230)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Visible = true
Frame.Active = true
Frame.Draggable = true

local title = Instance.new("TextLabel", Frame)
title.Text = "EthanHub AutoBlock"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

local toggle = Instance.new("TextButton", Frame)
toggle.Position = UDim2.new(0, 10, 0, 40)
toggle.Size = UDim2.new(0, 280, 0, 30)
toggle.Text = "Toggle AutoBlock (OFF)"
toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextScaled = true

local delaySlider = Instance.new("TextBox", Frame)
delaySlider.Position = UDim2.new(0, 10, 0, 80)
delaySlider.Size = UDim2.new(0, 280, 0, 30)
delaySlider.PlaceholderText = "Set Delay (ms, default: 0)"
delaySlider.Text = ""
delaySlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
delaySlider.TextColor3 = Color3.new(1, 1, 1)
delaySlider.TextScaled = true

local radiusSlider = Instance.new("TextBox", Frame)
radiusSlider.Position = UDim2.new(0, 10, 0, 120)
radiusSlider.Size = UDim2.new(0, 280, 0, 30)
radiusSlider.PlaceholderText = "Set Range (studs, default: 10)"
radiusSlider.Text = ""
radiusSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
radiusSlider.TextColor3 = Color3.new(1, 1, 1)
radiusSlider.TextScaled = true

local keybindBox = Instance.new("TextBox", Frame)
keybindBox.Position = UDim2.new(0, 10, 0, 160)
keybindBox.Size = UDim2.new(0, 280, 0, 30)
keybindBox.PlaceholderText = "Keybind (ex: R)"
keybindBox.Text = ""
keybindBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
keybindBox.TextColor3 = Color3.new(1, 1, 1)
keybindBox.TextScaled = true

local hideText = Instance.new("TextLabel", Frame)
hideText.Position = UDim2.new(0, 10, 0, 195)
hideText.Size = UDim2.new(0, 280, 0, 30)
hideText.Text = "Press Right Shift to hide/show GUI"
hideText.TextColor3 = Color3.fromRGB(200, 200, 200)
hideText.BackgroundTransparency = 1
hideText.TextScaled = true

-- State
local autoblockEnabled = false
local chosenKey = Enum.KeyCode.R
local delay = 0
local radius = 10

toggle.MouseButton1Click:Connect(function()
    autoblockEnabled = not autoblockEnabled
    toggle.Text = "Toggle AutoBlock ("..(autoblockEnabled and "ON" or "OFF")..")"
    StarterGui:SetCore("SendNotification", {
        Title = "EthanHub",
        Text = "AutoBlock "..(autoblockEnabled and "enabled" or "disabled"),
        Duration = 4
    })
end)

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        Frame.Visible = not Frame.Visible
    elseif input.KeyCode == chosenKey then
        autoblockEnabled = not autoblockEnabled
        toggle.Text = "Toggle AutoBlock ("..(autoblockEnabled and "ON" or "OFF")..")"
        StarterGui:SetCore("SendNotification", {
            Title = "EthanHub",
            Text = "AutoBlock "..(autoblockEnabled and "enabled" or "disabled"),
            Duration = 4
        })
    end
end)

keybindBox.FocusLost:Connect(function()
    local key = keybindBox.Text:upper()
    local kc = Enum.KeyCode[key]
    if kc then
        chosenKey = kc
    end
end)

delaySlider.FocusLost:Connect(function()
    local val = tonumber(delaySlider.Text)
    if val then delay = math.clamp(val, 0, 100) end
end)

radiusSlider.FocusLost:Connect(function()
    local val = tonumber(radiusSlider.Text)
    if val then radius = math.clamp(val, 0, 20) end
end)

-- Animation IDs to detect (MUST be updated if animations change)
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
                            task.delay(delay / 1000, function()
                                -- Simulate block (right mouse down)
                                mouse1click() -- Use this for M1 if desired; use mouse2click() for M2
                            end)
                        end
                    end
                end
            end
        end
    end
end)

