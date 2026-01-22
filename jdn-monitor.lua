-- ========== FISH IT: MONITOR ONLY  ==========
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local textChatService = game:GetService("TextChatService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local starterGui = game:GetService("StarterGui")

-- [ 🚨 CLEANUP OLD GUI ]
if getgenv().MonitorConn then 
    for _, c in pairs(getgenv().MonitorConn) do c:Disconnect() end
    getgenv().MonitorConn = {}
else
    getgenv().MonitorConn = {}
end

pcall(function()
    if playerGui:FindFirstChild("FishMonitorGui") then playerGui.FishMonitorGui:Destroy() end
end)

-- [ VARIABLES ]
local SecretStats = {} 

print("\n✅ Fish Monitor V2 Loaded: Minimize Feature Added!")

-- [ GUI LAYOUT ]
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishMonitorGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 1. TOMBOL RESTORE (Kecil saat diminimize)
local restoreBtn = Instance.new("TextButton")
restoreBtn.Name = "RestoreButton"
restoreBtn.Size = UDim2.new(0, 50, 0, 50)
restoreBtn.Position = UDim2.new(0, 10, 0.5, -25)
restoreBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
restoreBtn.Text = "OPEN\nLOG"
restoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
restoreBtn.Font = Enum.Font.GothamBlack
restoreBtn.TextSize = 10
restoreBtn.Visible = false -- Default Hidden
restoreBtn.Parent = screenGui
-- Bikin tombolnya agak bulat
local uiCorner = Instance.new("UICorner"); uiCorner.CornerRadius = UDim.new(0, 8); uiCorner.Parent = restoreBtn

-- 2. PANEL UTAMA
local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.new(0, 500, 0, 350) 
panel.Position = UDim2.new(0.5, -250, 0.5, -175)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
panel.BorderSizePixel = 2
panel.BorderColor3 = Color3.fromRGB(0, 255, 150)
panel.Active = true
panel.Draggable = true
panel.Parent = screenGui

-- Header Components
local titleLabel = Instance.new("TextLabel"); titleLabel.Size = UDim2.new(1, -60, 0, 30); titleLabel.BackgroundColor3 = Color3.fromRGB(0, 100, 50); titleLabel.Text = "  SERVER FISH MONITOR "; titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255); titleLabel.Font = Enum.Font.GothamBlack; titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.Parent = panel; titleLabel.TextSize=12

-- Tombol Close (X)
local closeBtn = Instance.new("TextButton"); closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(1, -30, 0, 0); closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); closeBtn.Font = Enum.Font.GothamBlack; closeBtn.Parent = panel; closeBtn.TextSize=14

-- Tombol Minimize (-) [BARU]
local minBtn = Instance.new("TextButton"); minBtn.Size = UDim2.new(0, 30, 0, 30); minBtn.Position = UDim2.new(1, -60, 0, 0); minBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0); minBtn.Text = "-"; minBtn.TextColor3 = Color3.fromRGB(255, 255, 255); minBtn.Font = Enum.Font.GothamBlack; minBtn.TextYAlignment = Enum.TextYAlignment.Bottom; minBtn.Parent = panel; minBtn.TextSize=18

-- TABS
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -10, 0, 30)
tabContainer.Position = UDim2.new(0, 5, 0, 35)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = panel

local tabLayout = Instance.new("UIListLayout"); tabLayout.Parent = tabContainer; tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.Padding = UDim.new(0, 5)

local btnTabLogs = Instance.new("TextButton"); btnTabLogs.Text="LIVE LOGS"; btnTabLogs.Size=UDim2.new(0.49,0,1,0); btnTabLogs.BackgroundColor3=Color3.fromRGB(0, 150, 255); btnTabLogs.TextColor3=Color3.new(1,1,1); btnTabLogs.Font=Enum.Font.GothamBold; btnTabLogs.TextSize=11; btnTabLogs.Parent=tabContainer
local btnTabSecrets = Instance.new("TextButton"); btnTabSecrets.Text="SECRET HISTORY"; btnTabSecrets.Size=UDim2.new(0.49,0,1,0); btnTabSecrets.BackgroundColor3=Color3.fromRGB(50,50,70); btnTabSecrets.TextColor3=Color3.new(1,1,1); btnTabSecrets.Font=Enum.Font.GothamBold; btnTabSecrets.TextSize=11; btnTabSecrets.Parent=tabContainer

-- === FRAME 1: LIVE LOGS ===
local frameLogs = Instance.new("Frame")
frameLogs.Size = UDim2.new(1, -10, 1, -80)
frameLogs.Position = UDim2.new(0, 5, 0, 70)
frameLogs.BackgroundTransparency = 1
frameLogs.Visible = true
frameLogs.Parent = panel

local searchBar = Instance.new("TextBox"); searchBar.PlaceholderText = "Search Player / Fish Name..."; searchBar.Text = ""; searchBar.Size = UDim2.new(1, 0, 0, 25); searchBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50); searchBar.TextColor3 = Color3.fromRGB(0, 255, 255); searchBar.Font = Enum.Font.GothamBold; searchBar.TextSize = 11; searchBar.Parent = frameLogs

local scrollLogs = Instance.new("ScrollingFrame"); scrollLogs.Size = UDim2.new(1, 0, 1, -60); scrollLogs.Position = UDim2.new(0, 0, 0, 30); scrollLogs.BackgroundColor3=Color3.fromRGB(15,15,20); scrollLogs.BorderSizePixel=0; scrollLogs.ScrollBarThickness=4; scrollLogs.Parent=frameLogs
local logLayout = Instance.new("UIListLayout"); logLayout.Parent=scrollLogs; logLayout.SortOrder=Enum.SortOrder.LayoutOrder; logLayout.Padding=UDim.new(0,2)

local btnSaveLogs = Instance.new("TextButton"); btnSaveLogs.Text = "SAVE LOGS TO TXT"; btnSaveLogs.Size = UDim2.new(1, 0, 0, 25); btnSaveLogs.Position = UDim2.new(0, 0, 1, -25); btnSaveLogs.BackgroundColor3 = Color3.fromRGB(0, 100, 200); btnSaveLogs.TextColor3 = Color3.fromRGB(255, 255, 255); btnSaveLogs.Font = Enum.Font.GothamBold; btnSaveLogs.TextSize = 11; btnSaveLogs.Parent = frameLogs

-- === FRAME 2: SECRETS ===
local frameSecrets = Instance.new("Frame")
frameSecrets.Size = UDim2.new(1, -10, 1, -80)
frameSecrets.Position = UDim2.new(0, 5, 0, 70)
frameSecrets.BackgroundTransparency = 1
frameSecrets.Visible = false
frameSecrets.Parent = panel

local scrollSecrets = Instance.new("ScrollingFrame"); scrollSecrets.Size = UDim2.new(1, 0, 1, -30); scrollSecrets.BackgroundColor3=Color3.fromRGB(20,30,20); scrollSecrets.BorderSizePixel=0; scrollSecrets.ScrollBarThickness=4; scrollSecrets.Parent=frameSecrets
local secretLayout = Instance.new("UIListLayout"); secretLayout.Parent=scrollSecrets; secretLayout.SortOrder=Enum.SortOrder.LayoutOrder; secretLayout.Padding=UDim.new(0,2)

local btnSaveSecrets = Instance.new("TextButton"); btnSaveSecrets.Text = "SAVE HISTORY TO TXT"; btnSaveSecrets.Size = UDim2.new(1, 0, 0, 25); btnSaveSecrets.Position = UDim2.new(0, 0, 1, -25); btnSaveSecrets.BackgroundColor3 = Color3.fromRGB(0, 180, 100); btnSaveSecrets.TextColor3 = Color3.fromRGB(255, 255, 255); btnSaveSecrets.Font = Enum.Font.GothamBold; btnSaveSecrets.TextSize = 11; btnSaveSecrets.Parent = frameSecrets

-- [ LOGIC: MINIMIZE & TABS ]
minBtn.MouseButton1Click:Connect(function()
    panel.Visible = false
    restoreBtn.Visible = true
end)

restoreBtn.MouseButton1Click:Connect(function()
    panel.Visible = true
    restoreBtn.Visible = false
end)

btnTabLogs.MouseButton1Click:Connect(function()
    frameLogs.Visible = true; frameSecrets.Visible = false
    btnTabLogs.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    btnTabSecrets.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
end)

btnTabSecrets.MouseButton1Click:Connect(function()
    frameLogs.Visible = false; frameSecrets.Visible = true
    btnTabLogs.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btnTabSecrets.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
end)

closeBtn.MouseButton1Click:Connect(function()
    if getgenv().MonitorConn then for _, c in pairs(getgenv().MonitorConn) do c:Disconnect() end end
    screenGui:Destroy()
end)

-- [ LOGIC: FILTER & ENTRY ]
local function filterLogs()
    local query = string.lower(searchBar.Text)
    for _, lbl in pairs(scrollLogs:GetChildren()) do
        if lbl:IsA("TextLabel") then
            if query == "" then lbl.Visible = true
            elseif string.lower(lbl.Text):find(query) then lbl.Visible = true
            else lbl.Visible = false end
        end
    end
    scrollLogs.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y)
end
searchBar:GetPropertyChangedSignal("Text"):Connect(filterLogs)

local function addLogEntry(text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -5, 0, 20)
    lbl.BackgroundTransparency = 0.8
    lbl.BackgroundColor3 = Color3.fromRGB(0,0,0)
    lbl.Text = " " .. text
    lbl.TextColor3 = color
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 12
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = scrollLogs
    
    local query = string.lower(searchBar.Text)
    if query ~= "" and not string.lower(text):find(query) then lbl.Visible = false end
    
    scrollLogs.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y)
    if query == "" then scrollLogs.CanvasPosition = Vector2.new(0, 9999) end
end

local function updateSecretUI()
    for _, v in pairs(scrollSecrets:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
    
    local sortTable = {}
    for name, data in pairs(SecretStats) do
        table.insert(sortTable, {Name = name, Count = data.Count, FishList = data.FishList})
    end
    table.sort(sortTable, function(a, b) return a.Count > b.Count end)
    
    for i, data in ipairs(sortTable) do
        local listString = table.concat(data.FishList, ", ")
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 0.8
        lbl.BackgroundColor3 = Color3.fromRGB(0,0,0)
        lbl.Text = string.format(" [#%d] %s (Total: %d)\n    > %s", i, data.Name, data.Count, listString)
        lbl.TextColor3 = Color3.fromRGB(24, 255, 152) 
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextWrapped = true
        lbl.AutomaticSize = Enum.AutomaticSize.Y
        lbl.Size = UDim2.new(1, -5, 0, 0)
        lbl.Parent = scrollSecrets
    end
    scrollSecrets.CanvasSize = UDim2.new(0, 0, 0, secretLayout.AbsoluteContentSize.Y)
end

-- [ LOGIC: CHAT PARSING ]
local function stripTags(str) return string.gsub(str, "<.->", "") end

local function parseChat(rawMsg)
    local r, g, b = rawMsg:match('color="rgb%((%d+), (%d+), (%d+)%)"')
    
    local rarityTag = ""
    local msgColor = Color3.new(1,1,1)
    local isSpecial = false 
    local isSecret = false 

    if r and g and b then
        local R, G, B = tonumber(r), tonumber(g), tonumber(b)
        if R==255 and G==185 and B==43 then
            rarityTag = "[LEGEND]"
            msgColor = Color3.fromRGB(255, 185, 43)
            isSpecial = true
        elseif R==255 and G==25 and B==25 then
            rarityTag = "[MYTHIC]"
            msgColor = Color3.fromRGB(255, 25, 25)
            isSpecial = true
        elseif R==24 and G==255 and B==152 then
            rarityTag = "[SECRET]"
            msgColor = Color3.fromRGB(24, 255, 152)
            isSpecial = true
            isSecret = true 
        end
    end

    local cleanMsg = stripTags(rawMsg)
    if cleanMsg:find("obtained a") then
        local content = cleanMsg:gsub("%[Server%]: ", "")
        local playerName = content:match("^(%S+)") or "Unknown"
        local fishInfo = content:match("obtained a (.-%))")
        if not fishInfo then fishInfo = content:match("obtained a (.-) with") or content:match("obtained a (.*)") end
        
        if fishInfo and isSpecial then
            local timestamp = os.date("%d/%m/%Y %H:%M") 
            addLogEntry(string.format("[%s] %s %s: %s", timestamp, rarityTag, playerName, fishInfo), msgColor)
        end

        if fishInfo and isSecret then
            if not SecretStats[playerName] then SecretStats[playerName] = {Count = 0, FishList = {}} end
            SecretStats[playerName].Count = SecretStats[playerName].Count + 1
            table.insert(SecretStats[playerName].FishList, fishInfo)
            updateSecretUI()
            
            -- Alarm
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://4590657391"
            sound.Volume = 10
            sound.Parent = playerGui
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 3)
        end
    end
end

-- [ LOGIC: SAVE TXT ]
local function saveToFile(filename, content)
    if not writefile then 
        starterGui:SetCore("SendNotification", {Title="Error", Text="Executor not supported", Duration=3}) 
        return 
    end
    writefile(filename, content)
    starterGui:SetCore("SendNotification", {Title="Saved!", Text="File: "..filename, Duration=5})
end

btnSaveLogs.MouseButton1Click:Connect(function()
    local name = "FishLogs_" .. os.date("%d-%m-%Y_%H-%M") .. ".txt"
    local data = "=== FISH LOGS ===\nSaved: " .. os.date() .. "\n\n"
    for _, lbl in pairs(scrollLogs:GetChildren()) do
        if lbl:IsA("TextLabel") and lbl.Visible then data = data .. lbl.Text .. "\n" end
    end
    saveToFile(name, data)
end)

btnSaveSecrets.MouseButton1Click:Connect(function()
    local name = "FishSecrets_" .. os.date("%d-%m-%Y") .. ".txt"
    local data = "=== SECRET HISTORY ===\nSaved: " .. os.date() .. "\n\n"
    
    local sortTable = {}
    for name, d in pairs(SecretStats) do table.insert(sortTable, {Name=name, Count=d.Count, FishList=d.FishList}) end
    table.sort(sortTable, function(a, b) return a.Count > b.Count end)
    
    for i, d in ipairs(sortTable) do
        data = data .. string.format("#%d %s (Total: %d)\nList: %s\n\n", i, d.Name, d.Count, table.concat(d.FishList, ", "))
    end
    saveToFile(name, data)
end)

-- [ CONNECT CHAT ]
if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    local conn = textChatService.MessageReceived:Connect(function(msg) parseChat(msg.Text) end)
    table.insert(getgenv().MonitorConn, conn)
else
    local chatEvents = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    local msgEvent = chatEvents and chatEvents:FindFirstChild("OnMessageDoneFiltering")
    if msgEvent then
        local conn = msgEvent.OnClientEvent:Connect(function(data)
            if data and data.Message then parseChat(data.Message) end
        end)
        table.insert(getgenv().MonitorConn, conn)
    end
end
