local function LoadRickHub()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    local Window = Rayfield:CreateWindow({
        Name = "Rick Hub | Executor | Universal BR",
        Icon = "rotate-3d",
        LoadingTitle = "Carregando Rick Hub",
        LoadingSubtitle = "Criador: Rick220",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "RICK HUB",
            FileName = "Config"
        },
        KeySystem = false,
        Theme = "DarkBlue"
    })

    local ESPTab = Window:CreateTab("ESP", "eye")

    local ESPSettings = {
        Box = true,
        Name = true,
        Distance = true,
        Health = true,
        Tracers = true,
        TracersFromBottom = true,
        ShowFOV = true,
        FOV = 100,
        BoxColor = Color3.fromRGB(255, 0, 0)
    }

    local ESPSection = ESPTab:CreateSection("Configurações de ESP")

    ESPTab:CreateToggle({Name = "Mostrar Box", CurrentValue = ESPSettings.Box, Callback = function(v) ESPSettings.Box = v end})
    ESPTab:CreateToggle({Name = "Mostrar Nome", CurrentValue = ESPSettings.Name, Callback = function(v) ESPSettings.Name = v end})
    ESPTab:CreateToggle({Name = "Mostrar Distância", CurrentValue = ESPSettings.Distance, Callback = function(v) ESPSettings.Distance = v end})
    ESPTab:CreateToggle({Name = "Mostrar Vida", CurrentValue = ESPSettings.Health, Callback = function(v) ESPSettings.Health = v end})
    ESPTab:CreateToggle({Name = "Mostrar Tracers", CurrentValue = ESPSettings.Tracers, Callback = function(v) ESPSettings.Tracers = v end})
    ESPTab:CreateToggle({Name = "Tracers do Chão", CurrentValue = ESPSettings.TracersFromBottom, Callback = function(v) ESPSettings.TracersFromBottom = v end})
    ESPTab:CreateToggle({Name = "Mostrar FOV", CurrentValue = ESPSettings.ShowFOV, Callback = function(v) ESPSettings.ShowFOV = v end})
    ESPTab:CreateSlider({Name = "Tamanho do FOV", Range = {10, 500}, Increment = 5, CurrentValue = ESPSettings.FOV, Callback = function(v) ESPSettings.FOV = v end})
    ESPTab:CreateColorPicker({Name = "Cor da Box", Color = ESPSettings.BoxColor, Callback = function(v) ESPSettings.BoxColor = v end})

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    local UserInputService = game:GetService("UserInputService")
    local ESPStorage = {}

    local function CreateESP(player)
        local box = Drawing.new("Square") box.Thickness = 1 box.Filled = false box.Visible = false
        local name = Drawing.new("Text") name.Size = 16 name.Center = true name.Outline = true name.Visible = false
        local distance = Drawing.new("Text") distance.Size = 16 distance.Center = true distance.Outline = true distance.Visible = false
        local health = Drawing.new("Text") health.Size = 16 health.Center = true health.Outline = true health.Visible = false
        local tracer = Drawing.new("Line") tracer.Thickness = 1 tracer.Visible = false

        ESPStorage[player] = {
            Box = box,
            Name = name,
            Distance = distance,
            Health = health,
            Tracer = tracer
        }
    end

    local function RemoveESP(player)
        if ESPStorage[player] then
            for _, v in pairs(ESPStorage[player]) do v:Remove() end
            ESPStorage[player] = nil
        end
    end

    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.NumSides = 100
    FOVCircle.Radius = ESPSettings.FOV
    FOVCircle.Filled = false
    FOVCircle.Visible = false

    local function UpdateESP()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
                local rootPart = player.Character.HumanoidRootPart
                local humanoid = player.Character.Humanoid
                local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

                if not ESPStorage[player] then CreateESP(player) end
                if not onScreen or humanoid.Health <= 0 then
                    for _, v in pairs(ESPStorage[player]) do v.Visible = false end
                    continue
                end

                local height = math.clamp(2 / pos.Z * 1000, 2, 100)
                local width = height / 2

                if ESPSettings.Box then
                    local box = ESPStorage[player].Box
                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                    box.Color = ESPSettings.BoxColor
                    box.Visible = true
                else
                    ESPStorage[player].Box.Visible = false
                end

                if ESPSettings.Name then
                    local name = ESPStorage[player].Name
                    name.Text = player.Name
                    name.Position = Vector2.new(pos.X, pos.Y - height - 15)
                    name.Color = ESPSettings.BoxColor
                    name.Visible = true
                else
                    ESPStorage[player].Name.Visible = false
                end

                if ESPSettings.Distance then
                    local dist = (Camera.CFrame.Position - rootPart.Position).Magnitude
                    local distance = ESPStorage[player].Distance
                    distance.Text = string.format("%.1f studs", dist)
                    distance.Position = Vector2.new(pos.X, pos.Y + height + 5)
                    distance.Color = ESPSettings.BoxColor
                    distance.Visible = true
                else
                    ESPStorage[player].Distance.Visible = false
                end

                if ESPSettings.Health then
                    local health = ESPStorage[player].Health
                    health.Text = string.format("HP: %d", humanoid.Health)
                    health.Position = Vector2.new(pos.X, pos.Y + height + 20)
                    health.Color = ESPSettings.BoxColor
                    health.Visible = true
                else
                    ESPStorage[player].Health.Visible = false
                end

                if ESPSettings.Tracers then
                    local tracer = ESPStorage[player].Tracer
                    tracer.From = ESPSettings.TracersFromBottom and Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    tracer.To = Vector2.new(pos.X, pos.Y + height)
                    tracer.Color = ESPSettings.BoxColor
                    tracer.Visible = true
                else
                    ESPStorage[player].Tracer.Visible = false
                end
            elseif ESPStorage[player] then
                for _, v in pairs(ESPStorage[player]) do v.Visible = false end
            end
        end
    end

    RunService.RenderStepped:Connect(function()
        if ESPSettings.ShowFOV then
            FOVCircle.Visible = true
            FOVCircle.Position = UserInputService:GetMouseLocation()
            FOVCircle.Radius = ESPSettings.FOV
            FOVCircle.Color = ESPSettings.BoxColor
        else
            FOVCircle.Visible = false
        end
        UpdateESP()
    end)

    Players.PlayerRemoving:Connect(function(p) RemoveESP(p) end)

    local OtherTab = Window:CreateTab("Outras pastas", "folder")

    OtherTab:CreateButton({
        Name = "Abrir Dex furtivo",
        Callback = function()
            local dexSource = game:HttpGet("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua")
            local dexEnv = gethui and gethui() or game:GetService("CoreGui")
            local success, result = pcall(function()
                local dex = loadstring(dexSource)()
                if typeof(dex) == "Instance" and dex:IsA("ScreenGui") then dex.Parent = dexEnv end
            end)
            if not success then warn("Falha ao carregar o Dex:", result) end
        end
    })

    OtherTab:CreateButton({
        Name = "Abrir Infinity Yield",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
            end)
            if not success then warn("Falha ao carregar o Infinity Yield:", result) end
        end
    })
end

return LoadRickHub
