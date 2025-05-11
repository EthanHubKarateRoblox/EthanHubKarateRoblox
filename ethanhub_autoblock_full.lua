--// Load Vape UI Library
local repo = "https://raw.githubusercontent.com/Glitchfiend/Vape-Roblox/main/"
local VapeUI = loadstring(game:HttpGet(repo .. "VapeUI.lua"))()

--// Create the main window
local Window = VapeUI.CreateWindow("EthanHub")
local MainTab = Window:AddTab("Main", "shield")
local SettingsTab = Window:AddTab("Settings", "settings")

--// State Variables
local autoblockEnabled = false
local blockRadius = 10
local arenaOnly = false
local chosenKey = Enum.KeyCode.R
local toggleKey = Enum.KeyCode.RightShift
local spherePart = nil
local opponent = nil

--// Staff List (example)
local staffList = {
    Eyroku = true, realkeatos123456 = true, Capybarabruv = true, kurosfx = true,
    PancakesHDD = true, OSCARsdb1 = true, missionslayer = true, ["80poplic"] = true,
    ["32MAF"] = true, clexa123456 = true, YugoGrace = true, NotMistiCat = true,
    MinishWasntTaken = true, risingnixillium = true, evas84832 = true, benyibandz = true,
    Marko_Sans = true, ["2j2ij2j"] = true, AZ_PRO2020 = true, ruri_kuu = true,
    tidypop = true, Turboohh = true, kitakro = true, hitakru = true,
    kyasuji = true, kyesumi = true
}

--// AutoBlock toggle button
local AutoBlockToggle = MainTab:AddToggle("AutoBlock", "Enable AutoBlock", false, function(value)
    autoblockEnabled = value
    if autoblockEnabled then
        VapeUI:Notify("AutoBlock Enabled")
    else
        VapeUI:Notify("AutoBlock Disabled")
    end
end)

--// Toggle for Arena-Only Mode
local ArenaOnlyToggle = MainTab:AddToggle("ArenaOnly", "Arena Only Mode", false, function(value)
    arenaOnly = value
    if arenaOnly then
        VapeUI:Notify("Arena Only Mode Enabled")
    else
        VapeUI:Notify("Arena Only Mode Disabled")
    end
end)

--// Server Hop Toggle (Set to false if you don't want it)
local ServerHopToggle = MainTab:AddToggle("ServerHop", "Enable Server Hop on Staff Detection", false, function(value)
    -- Your server hop logic goes here
end)

--// Keybind setup for AutoBlock (Default is "R")
local Keybind = MainTab:AddKeybind("AutoBlock Keybind", "Set AutoBlock Keybind", Enum.KeyCode.R, function(newKey)
    chosenKey = newKey
    VapeUI:Notify("AutoBlock Keybind set to " .. chosenKey.Name)
end)

--// Keybind setup for GUI Toggle (Default is RightShift)
local GuiKeybind = SettingsTab:AddKeybind("GUI Keybind", "Set GUI Toggle Keybind", Enum.KeyCode.RightShift, function(newKey)
    toggleKey = newKey
    VapeUI:Notify("GUI Keybind set to " .. toggleKey.Name)
end)

--// Show Block Range (Visualization)
local ShowRangeToggle = MainTab:AddToggle("Show Range", "Show Block Range", false, function(value)
    if value then
        if not spherePart then
            spherePart = Instance.new("Part")
            spherePart.Anchored = true
            spherePart.CanCollide = false
            spherePart.Transparency = 0.7
            spherePart.Material = Enum.Material.Neon
            spherePart.Color = Color3.fromRGB(0, 170, 255)
            spherePart.Shape = Enum.PartType.Ball
            spherePart.Parent = workspace
        end
    else
        if spherePart then
            spherePart:Destroy()
            spherePart = nil
        end
    end
end)

--// Attack Animations (example)
local AttackAnimations = {
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

--// Keybind handling
game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == toggleKey then
        -- Always toggle GUI on GUI keybind
        Window:Toggle()
        return
    end

    if input.KeyCode == chosenKey then
        autoblockEnabled = not autoblockEnabled
        AutoBlockToggle:SetValue(autoblockEnabled)
        VapeUI:Notify("AutoBlock " .. (autoblockEnabled and "enabled" or "disabled"))
    end
end)

--// Get Current Arena and Opponent
local function GetCurrentArena()
    local CurrentArena, Opponent
    for _, Arena in ipairs(workspace.Arenas:GetChildren()) do
        local Info = Arena:FindFirstChild("Info")
        if Info then
            local P1 = Info:FindFirstChild("P1")
            local P2 = Info:FindFirstChild("P2")
            if P1 and P2 and (Info:FindFirstChild("Active") and Info.Active.Value) then
                if P1.Title.Text == game.Players.LocalPlayer.Name then
                    CurrentArena = Arena
                    Opponent = P2.Title.Text
                elseif P2.Title.Text == game.Players.LocalPlayer.Name then
                    CurrentArena = Arena
                    Opponent = P1.Title.Text
                end
            end
        end
    end
    return CurrentArena, Opponent
end

--// AutoBlock Logic
game:GetService("RunService").RenderStepped:Connect(function()
    if not autoblockEnabled then return end

    local myRoot = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local currentArena, opponentName = GetCurrentArena()

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            -- Only block the opponent if ArenaOnly is enabled
            if arenaOnly then
                if opponentName == plr.Name then
                    for _, track in ipairs(plr.Character.Humanoid:GetPlayingAnimationTracks()) do
                        local animId = track.Animation.AnimationId:match("%d+")
                        if animId and AttackAnimations[animId] then
                            local enemyRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                            if enemyRoot and (myRoot.Position - enemyRoot.Position).Magnitude <= blockRadius then
                                simulateRightClick()
                                break
                            end
                        end
                    end
                end
            else
                for _, track in ipairs(plr.Character.Humanoid:GetPlayingAnimationTracks()) do
                    local animId = track.Animation.AnimationId:match("%d+")
                    if animId and AttackAnimations[animId] then
                        local enemyRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                        if enemyRoot and (myRoot.Position - enemyRoot.Position).Magnitude <= blockRadius then
                            simulateRightClick()
                            break
                        end
                    end
                end
            end
        end
    end
end)

--// Utility to simulate right-click event (for blocking)
local function simulateRightClick()
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 1, true, game, 0)
    game:GetService("VirtualInputManager"):SendMouseButtonEvent(0, 0, 1, false, game, 0)
end