-- EthanHub AutoBlock Script
-- Discord: https://discord.gg/w6fyk64B95

-- Settings
local settings = {
    Enabled = false,
    Delay = 0,
    Radius = 10,
    BlockBehind = false,
    Keybind = Enum.KeyCode.RightShift,
    UseClashFallback = false, -- Disabled per user request
}

local staffUsernames = {
    Eyroku = true, realkeatos123456 = true, Capybarabruv = true, kurosfx = true,
    PancakesHDD = true, OSCARsdb1 = true, missionslayer = true, ["80poplic"] = true,
    ["32MAF"] = true, clexa123456 = true, YugoGrace = true, NotMistiCat = true,
    MinishWasntTaken = true, risingnixillium = true, evas84832 = true,
    benyibandz = true, Marko_Sans = true, ["2j2ij2j"] = true, AZ_PRO2020 = true,
    ruri_kuu = true, tidypop = true, Turboohh = true, kitakro = true,
    hitakru = true, kyasuji = true, kyesumi = true,
}

local Players, UserInputService, RunService = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "EthanHubAutoBlock"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 180)
Main.Position = UDim2.new(0.5, -140, 0.5, -90)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "EthanHub AutoBlock"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20

local function makeToggle(name, default, yPos, callback)
    local toggle = Instance.new("TextButton", Main)
    toggle.Size = UDim2.new(1, -20, 0, 25)
    toggle.Position = UDim2.new(0, 10, 0, yPos)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Font = Enum.Font.Gotham
    toggle.TextSize = 14
    toggle.Text = name .. ": " .. (default and "ON" or "OFF")
    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = name .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

local function makeSlider(name, min, max, default, yPos, callback)
    local label = Instance.new("TextLabel", Main)
    label.Position = UDim2.new(0, 10, 0, yPos)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Text = name .. ": " .. default

    local slider = Instance.new("TextBox", Main)
    slider.Position = UDim2.new(0, 10, 0, yPos + 20)
    slider.Size = UDim2.new(1, -20, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    slider.TextColor3 = Color3.new(1, 1, 1)
    slider.Font = Enum.Font.Gotham
    slider.TextSize = 14
    slider.Text = tostring(default)
    slider.FocusLost:Connect(function()
        local val = tonumber(slider.Text)
        if val then
            val = math.clamp(val, min, max)
            label.Text = name .. ": " .. val
            callback(val)
        end
    end)
end

makeToggle("AutoBlock", false, 40, function(v) settings.Enabled = v end)
makeSlider("Delay", 0, 100, 0, 70, function(v) settings.Delay = v end)
makeSlider("Radius", 0, 20, 10, 120, function(v) settings.Radius = v end)

-- RightShift to toggle GUI
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == settings.Keybind then
        Main.Visible = not Main.Visible
    end
end)

-- Staff Detection
Players.PlayerAdded:Connect(function(player)
    if staffUsernames[player.Name] then
        game.StarterGui:SetCore("SendNotification", {
            Title = "Warning",
            Text = player.DisplayName .. " (Staff) has joined. High risk!",
            Duration = 8
        })
    end
end)

-- AutoBlock Detection (placeholder animation IDs)
local blockAnimations = {
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

-- Main Loop
RunService.Heartbeat:Connect(function()
    if not settings.Enabled then return end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            local animator = humanoid:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                    if blockAnimations[tostring(track.Animation.AnimationId:match("%d+"))] then
                        local distance = (plr.Character:GetPrimaryPartCFrame().Position - LocalPlayer.Character:GetPrimaryPartCFrame().Position).Magnitude
                        if distance <= settings.Radius then
                            if not settings.BlockBehind then
                                local direction = (plr.Character:GetPrimaryPartCFrame().Position - LocalPlayer.Character:GetPrimaryPartCFrame().Position).Unit
                                local forward = LocalPlayer.Character:GetPrimaryPartCFrame().LookVector
                                if forward:Dot(direction) < 0 then return end
                            end
                            task.wait(settings.Delay / 1000)
                            mouse2press() task.wait(0.1) mouse2release()
                        end
                    end
                end
            end
        end
    end
end)
