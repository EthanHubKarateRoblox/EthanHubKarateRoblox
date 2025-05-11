if game.GameId == 2343912333 then

    --  Custom attack animations
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

    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
    local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"))()
    local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua"))()

    ThemeManager:SetLibrary(Library)
    ThemeManager:SetFolder("pudding")
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
    SaveManager:SetFolder("pudding/karate")

    local Window = Library:CreateWindow({
        Title = "Karate | EthanHub",
        Footer = "Made by EthanHub | (click to join Discord)",
        ShowCustomCursor = false
    })

    local MainTab = Window:AddTab("Main")
    local BlockGroup = MainTab:AddLeftGroupbox("Auto Blocker")

    BlockGroup:AddToggle("AutoBlock_Enabled", { Text = "Enabled" }):AddKeyPicker("AutoBlock_Enabled", {
        Default = "F", SyncToggleState = true, Mode = "Toggle", Text = "Auto Block Keybind"
    })

    BlockGroup:AddSlider("AutoBlock_BlockChance", {
        Text = "Block Chance", Default = 100, Min = 0, Max = 100, Rounding = 0, Suffix = "%"
    })

    BlockGroup:AddSlider("AutoBlock_Distance", {
        Text = "Max Block Distance", Default = 10, Min = 0, Max = 20, Rounding = 1, Suffix = " studs"
    })

    BlockGroup:AddToggle("AutoBlock_IgnorePlayersBehind", { Text = "Ignore Players Behind" })
    BlockGroup:AddToggle("AutoBlock_IgnoreNotInGame", { Text = "Ignore Outside of Arena" })

    BlockGroup:AddSlider("AutoBlock_StartDelay", {
        Text = "Block Start Delay", Default = 0, Min = 0, Max = 1000, Rounding = 0, Suffix = " ms"
    })

    BlockGroup:AddToggle("AutoBlock_RandomStart", { Text = "Randomize Start Delay" })

    BlockGroup:AddSlider("AutoBlock_ReleaseDelay", {
        Text = "Block Stop Delay", Default = 100, Min = 0, Max = 1000, Rounding = 0, Suffix = " ms"
    })

    BlockGroup:AddToggle("AutoBlock_RandomRelease", { Text = "Randomize Release Delay" })

    local MiscGroup = MainTab:AddRightGroupbox("Misc")
    MiscGroup:AddToggle("Misc_UseCombatController", { Text = "Use Combat Controller" })
    MiscGroup:AddToggle("Misc_DisableWhenAFK", { Text = "Disable when AFK" })
    MiscGroup:AddToggle("Misc_DisableWhenRoundEnds", { Text = "Disable when round ends" })

    local SettingsTab = Window:AddTab("Settings")
    local UIGroup = SettingsTab:AddRightGroupbox("UI")
    UIGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
        Default = "RightShift", NoUI = true, Text = "Menu Keybind"
    })

    Library.ToggleKeybind = Library.Options.MenuKeybind
    SaveManager:BuildConfigSection(SettingsTab)
    ThemeManager:ApplyToTab(SettingsTab)

    --  Core Services and Logic
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    local function Notify(msg)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "EthanHub AutoBlock",
                Text = msg,
                Duration = 3
            })
        end)
    end

    local function IsBehind(from, target)
        local dir = from.CFrame.LookVector
        local toTarget = (target.Position - from.Position).Unit
        return dir:Dot(toTarget) < -0.5
    end

    local function Block(press)
        local vim = game:GetService("VirtualInputManager")
        if mouse2press then
            if press then mouse2press() else mouse2release() end
        else
            vim:SendMouseButtonEvent(500, 500, 1, press, game, 1)
        end
    end

    local arenaModel, opponentName
    local function GetArenaOpponent()
        for _, arena in pairs(workspace.Arenas:GetChildren()) do
            local info = arena:FindFirstChild("Info")
            if info then
                local p1 = info:FindFirstChild("P1", true)
                local p2 = info:FindFirstChild("P2", true)
                local active = info:FindFirstChild("Active")
                if active and active.Value then
                    if p1 and p1.Title.Text == LocalPlayer.Name then
                        return arena, p2.Title.Text
                    elseif p2 and p2.Title.Text == LocalPlayer.Name then
                        return arena, p1.Title.Text
                    end
                end
            end
        end
        return nil, nil
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.F then
            local current = Library.Toggles.AutoBlock_Enabled.Value
            Library.Toggles.AutoBlock_Enabled:SetValue(not current)
            Notify("AutoBlock " .. (not current and "ENABLED ✅" or "DISABLED ❌"))
        end
    end)

    task.spawn(function()
        while task.wait(0.5) do
            arenaModel, opponentName = GetArenaOpponent()
        end
    end)

    task.spawn(function()
        while task.wait() do
            if not Library.Toggles.AutoBlock_Enabled.Value then continue end

            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            for _, plr in pairs(Players:GetPlayers()) do
                if plr == LocalPlayer then continue end
                if Library.Toggles.AutoBlock_IgnoreNotInGame.Value and plr.Name ~= opponentName then continue end

                local enemyChar = plr.Character
                local enemyRoot = enemyChar and enemyChar:FindFirstChild("HumanoidRootPart")
                local humanoid = enemyChar and enemyChar:FindFirstChild("Humanoid")
                if not (enemyRoot and humanoid and humanoid.Health > 0) then continue end

                if Library.Toggles.AutoBlock_IgnorePlayersBehind.Value and IsBehind(root, enemyRoot) then continue end
                if (root.Position - enemyRoot.Position).Magnitude > Library.Options.AutoBlock_Distance.Value then continue end

                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    local animId = track.Animation.AnimationId
                    local stripped = animId:gsub("rbxassetid://", "")
                    if not AttackAnimations[stripped] then continue end
                    if track.TimePosition < 0.05 or track.TimePosition > 0.1 then continue end

                    local delay = Library.Toggles.AutoBlock_RandomStart.Value and math.random(0, Library.Options.AutoBlock_StartDelay.Value) or Library.Options.AutoBlock_StartDelay.Value
                    local release = Library.Toggles.AutoBlock_RandomRelease.Value and math.random(0, Library.Options.AutoBlock_ReleaseDelay.Value) or Library.Options.AutoBlock_ReleaseDelay.Value

                    if math.random(1, 100) <= Library.Options.AutoBlock_BlockChance.Value then
                        task.wait(delay / 1000)
                        Block(true)
                        task.wait(release / 1000)
                        Block(false)
                    end
                    task.wait(track.Length)
                end
            end
        end
    end)

    -- 💬 Discord Button (click to copy)
    local DiscordButton = Instance.new("TextButton")
    DiscordButton.Size = UDim2.new(0, 200, 0, 20)
    DiscordButton.Position = UDim2.new(0, 10, 1, -30)
    DiscordButton.Text = "Click to copy Discord: discord.gg/CG4Uu4Fqr8"
    DiscordButton.TextColor3 = Color3.new(1, 1, 1)
    DiscordButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    DiscordButton.BorderSizePixel = 0
    DiscordButton.Font = Enum.Font.Gotham
    DiscordButton.TextSize = 12
    DiscordButton.Parent = game:GetService("CoreGui"):FindFirstChild("Obsidian") or game.CoreGui

    DiscordButton.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/CG4Uu4Fqr8")
        Library:Notify("Discord link copied to clipboard!")
    end)

end

