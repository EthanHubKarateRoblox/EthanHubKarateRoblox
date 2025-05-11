-- Load Linoria UI Library
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

-- Main Window Setup
local Window = Library:CreateWindow({
    Title = "EthanHub",
    Footer = "AutoBlock Script",
    Icon = 95816097006870,
    Center = true,
    AutoShow = true,
    NotifySide = "Right"
})

local Tabs = {
    Main = Window:AddTab("EthanHub", "shield"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings")
}

-- Group
local MainGroup = Tabs.Main:AddLeftGroupbox("AutoBlock")

-- State Variables
local autoblockEnabled = false
local blockRadius = 10
local chosenKey = Enum.KeyCode.R
local toggleKey = Enum.KeyCode.RightShift
local arenaOnlyBlock = false  -- Toggle for blocking only the opponent in the same arena
local spherePart = nil
local CurrentArena = nil
local Opponent = nil

-- Required Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Known attack animations
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

-- UI Elements
MainGroup:AddToggle("AutoBlockToggle", {
    Text = "Enable AutoBlock",
    Default = false,
    Callback = function(value)
        autoblockEnabled = value
        Library:Notify("AutoBlock " .. (value and "enabled" or "disabled"))
    end
})

MainGroup:AddSlider("RangeSlider", {
    Text = "Detection Range",
    Min = 0,
    Max = 20,
    Default = 10,
    Rounding = 1,
    Suffix = " studs",
    Callback = function(value)
        blockRadius = value
        if spherePart then
            spherePart.Size = Vector3.new(blockRadius * 2, blockRadius * 2, blockRadius * 2)
        end
    end
})

MainGroup:AddToggle("RangeSphereToggle", {
    Text = "Show Block Range",
    Default = false,
    Callback = function(value)
        if value then
            if not spherePart then
                spherePart = Instance.new("Part")
                spherePart.Anchored = true
                spherePart.CanCollide = false
                spherePart.Transparency = 0.7
                spherePart.Material = Enum.Material.Neon
                spherePart.Color = Color3.fromRGB(0, 170, 255)
                spherePart.Shape = Enum.PartType.Ball
                spherePart.Name = "BlockRangeVisualizer"
                spherePart.Parent = workspace
            end

            task.spawn(function()
                while Toggles.RangeSphereToggle.Value and spherePart do
                    local hrp = Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        spherePart.Position = hrp.Position + Vector3.new(0, 4, 0)
                        spherePart.Size = Vector3.new(blockRadius * 2, blockRadius * 2, blockRadius * 2)
                    end
                    task.wait(0.05)
                end
                if spherePart then
                    spherePart:Destroy()
                    spherePart = nil
                end
            end)
        else
            if spherePart then
                spherePart:Destroy()
                spherePart = nil
            end
        end
    end
})

MainGroup:AddToggle("ArenaOnlyToggle", {
    Text = "Block Only in Arena",
    Default = false,
    Callback = function(value)
        arenaOnlyBlock = value
        Library:Notify("Blocking only in arena: " .. (value and "enabled" or "disabled"))
    end
})

MainGroup:AddLabel("AutoBlock Keybind")
    :AddKeyPicker("AutoBlockKey", {
        Default = "R",
        SyncToggleState = false,
        Mode = "Toggle",
        Text = "Keybind",
        NoUI = false,
        Callback = function()
            autoblockEnabled = not autoblockEnabled
            Toggles.AutoBlockToggle:SetValue(autoblockEnabled)
            Library:Notify("AutoBlock " .. (autoblockEnabled and "enabled" or "disabled"))
        end,
        ChangedCallback = function(newKey)
            chosenKey = newKey
        end
    })

-- Input Simulation
local function simulateRightClick()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 1, true, game, 0)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 1, false, game, 0)
end

-- Get the Current Arena and Opponent
local function GetCurrentArena()
    CurrentArena = nil
    Opponent = nil
    for _, Arena in pairs(workspace.Arenas:GetChildren()) do
        local Info = Arena:FindFirstChild("Info")
        local P1 = Info and Info:FindFirstChild("P1", true)
        local P2 = Info and Info:FindFirstChild("P2", true)

        if Info and Info:FindFirstChild("Active") and Info.Active.Value then
            if P1 and P2 then
                local T1 = P1.Title.Text
                local T2 = P2.Title.Text

                if T1 == game.Players.LocalPlayer.Name then
                    CurrentArena = Arena
                    Opponent = T2
                elseif T2 == game.Players.LocalPlayer.Name then
                    CurrentArena = Arena
                    Opponent = T1
                end
            end
        end
    end
end

-- Keybind handling
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == toggleKey then
        -- Always toggle UI on RightShift
        Library:ToggleUI()
        return
    end

    if input.KeyCode == chosenKey then
        autoblockEnabled = not autoblockEnabled
        Toggles.AutoBlockToggle:SetValue(autoblockEnabled)
        Library:Notify("AutoBlock " .. (autoblockEnabled and "enabled" or "disabled"))
    end
end)

-- AutoBlock Logic, modified for arena-only blocking
RunService.RenderStepped:Connect(function()
    if not autoblockEnabled then return end

    -- Update current arena and opponent
    GetCurrentArena()

    local myRoot = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not Opponent then return end

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            -- Only block if the opponent is in the same arena, or if the "ArenaOnly" toggle is off
            local enemyRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            if enemyRoot and (myRoot.Position - enemyRoot.Position).Magnitude <= blockRadius then
                if not arenaOnlyBlock or (arenaOnlyBlock and Opponent == plr.Name) then
                    -- Simulate the right click to block
                    simulateRightClick()
                    break
                end
            end
        end
    end
end)

-- Theme & Save Manager Setup
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()