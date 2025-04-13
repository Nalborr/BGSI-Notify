-- // CONFIG
local ChestWebhook = "https://canary.discord.com/api/webhooks/1361034797660508341/T3tJAPtNrfX7wAqBAUBE8O0dV8qgME7BDzkPzFGgZojyNp668eM-YN8VvnbqWoAGAoG5"
local EggWebhook = "https://canary.discord.com/api/webhooks/1361034696028454933/l8cIULT7v12iUckvWguD3xynw_mVf-vKTKZp3ry_1Uh-yvvLsqZAzGOi6gp2GV_g9HL7"
local IslandWebhook = "https://canary.discord.com/api/webhooks/1361073876955824159/Ms0lgC8kO8-PGghn6uKDuh32OthFC3tsKhst9SEvB9fSEtAiWMCfFrMYixKNNDUPKMdQ"

local RolePings = {
    chest = "<@&1360957212603973642>",
    egg = "<@&1360957171327570011>",
    island = "<@&1361072218553061537>"
}

-- // SERVICES
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Rifts = Workspace:WaitForChild("Rendered"):WaitForChild("Rifts")
local LocalPlayer = Players.LocalPlayer

-- // UI STATE
local trackChest = true
local trackIsland = true
local trackEggs = true

-- // FLAGS
local sentChest = false
local sentIsland = false
local sentEggs = {}

-- // INIT
print("[🔧] Скрипт отслеживания запущен с UI")

-- // WEBHOOK UTILS
local function sendWebhook(url, embed, content)
    local req = http_request or request or (syn and syn.request)
    if not req then
        warn("❌ HTTP запрос не поддерживается в этом эксплойте")
        return
    end

    -- Отправка запроса через выбранный метод
    req({
        Url = url,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            content = content or "",
            embeds = {embed}
        })
    })
end

-- // EMBED CREATION
local function getEmbedBase(title, description, color, iconUrl)
    return {
        title = title,
        description = description,
        color = color,
        thumbnail = {
            url = iconUrl or "https://cdn.discordapp.com/avatars/852650858394026005/0f61f3cc43323bd13ef690ddf43e1a40.gif?size=1024"  -- Иконка по умолчанию
        },
        footer = {
            text = "Toukima Software — Система уведомлений",
            icon_url = "https://cdn.discordapp.com/avatars/852650858394026005/0f61f3cc43323bd13ef690ddf43e1a40.gif?size=1024"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),  -- Время события в формате ISO
        author = {
            name = "Toukima Software",
            icon_url = "https://cdn.discordapp.com/avatars/852650858394026005/0f61f3cc43323bd13ef690ddf43e1a40.gif?size=1024"
        }
    }
end

-- // DETECTORS
local validEggs = {
    ["void-egg"] = true,
    ["hell-egg"] = true,
    ["nightmare-egg"] = true,
    ["rainbow-egg"] = true,
}

Rifts.ChildAdded:Connect(function(child)
    if child.Name == "royal-chest" and not sentChest and trackChest then
        sentChest = true
        print("[📦] Сундук задетектирован.")
        sendWebhook(ChestWebhook, getEmbedBase(
            "[📦] Появился Сундук!",
            "В игре появился **Royal Chest**. Не упустите шанс собрать его, пока он не исчез!",
            0xFFD700, "https://static.wikia.nocookie.net/bgs-infinity/images/7/7e/RoyalChest.png/revision/latest?cb=20250413113800"
        ), RolePings.chest)
    elseif child.Name == "man-egg" and not sentIsland and trackIsland then
        sentIsland = true
        print("[🏝️] Остров задетектирован.")
        sendWebhook(IslandWebhook, getEmbedBase(
            "[🏝️] Появилось Aura Egg!",
            "**Aura Egg** заспавнился. Это остров с яйцом — действуйте быстро, пока он не исчез!",
            0x00FFFF, "https://static.wikia.nocookie.net/bgs-infinity/images/2/2e/Aura_Egg.png/revision/latest/scale-to-width-down/1000?cb=20250413042632"
        ), RolePings.island)
    elseif validEggs[child.Name] and not sentEggs[child] and trackEggs then
        task.defer(function()
            local success = pcall(function()
                local luckLabel = child:WaitForChild("Display", 3)
                    :WaitForChild("SurfaceGui", 3)
                    :WaitForChild("Icon", 3)
                    :WaitForChild("Luck", 3)

                if luckLabel:IsA("TextLabel") and luckLabel.Text == "x25" then
                    sentEggs[child] = true
                    print("[🥚] Обнаружено яйцо x25:", child.Name)
                    sendWebhook(EggWebhook, getEmbedBase(
                        "[🥚] Яйцо с Удачей x25!",
                        string.format("Обнаружено **`%s`** с удачей **x25**!", child.Name),
                        0xFF69B4, "https://example.com/egg-icon.png"
                    ), RolePings.egg)
                end
            end)
        end)
    end
end)

-- // UI CREATION
local function createToggle(text, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 20, 0, 20)
    box.Position = UDim2.new(0, 5, 0, 5)
    box.Text = default and "✔️" or "❌"
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.SourceSansBold
    box.TextSize = 16
    box.Parent = container

    local label = Instance.new("TextLabel")
    label.Position = UDim2.new(0, 30, 0, 5)
    label.Size = UDim2.new(1, -35, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 16
    label.Parent = container

    box.MouseButton1Click:Connect(function()
        default = not default
        box.Text = default and "✔️" or "❌"
        callback(default)
    end)

    return container
end

-- // TEST BUTTON
local function createTestButton()
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Text = "🛠️ Тестовое сообщение"
    button.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.Parent = container

    button.MouseButton1Click:Connect(function()
        print("[🛠️] Тестовое сообщение отправлено!")
        sendWebhook(ChestWebhook, getEmbedBase(
            "Тестовое сообщение",
            "Это тестовое сообщение для проверки работы WebHook.",
            0x00FF00, "https://static.wikia.nocookie.net/bgs-infinity/images/4/43/Nightmare_Egg.png/revision/latest?cb=20250412170032"
        ), "")
    end)

    return container
end

-- // UI WINDOW
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "TrackerUI"

local main = Instance.new("Frame", ScreenGui)
main.Size = UDim2.new(0, 250, 0, 200)
main.Position = UDim2.new(1, -260, 0, 100)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "📡 Roblox Tracker"
title.Font = Enum.Font.SourceSansBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 20

local chestToggle = createToggle("Отслеживать Сундуки", true, function(state) trackChest = state end)
chestToggle.Position = UDim2.new(0, 0, 0, 30)
chestToggle.Parent = main

local eggToggle = createToggle("Отслеживать Яйца x25", true, function(state) trackEggs = state end)
eggToggle.Position = UDim2.new(0, 0, 0, 60)
eggToggle.Parent = main

local islandToggle = createToggle("Отслеживать Остров", true, function(state) trackIsland = state end)
islandToggle.Position = UDim2.new(0, 0, 0, 90)
islandToggle.Parent = main

-- Добавляем кнопку теста
local testButton = createTestButton()
testButton.Position = UDim2.new(0, 0, 0, 120)
testButton.Parent = main
