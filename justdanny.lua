-- ========== SISTEM KEAMANAN (WHITELIST) ==========
local Player = game.Players.LocalPlayer
local UserId = Player.UserId

-- Masukkan Link RAW dari file database.lua yang kamu buat di Langkah 1 di sini:
local URL_DATABASE = "https://raw.githubusercontent.com/danigompal26-ui/JDN/refs/heads/main/database.lua"

local success, whitelist = pcall(function()
    return loadstring(game:HttpGet(URL_DATABASE))()
end)

if not success or type(whitelist) ~= "table" then
    -- Jika gagal mengambil data (misal internet error atau link salah)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Error!",
        Text = "Gagal terhubung ke database whitelist.",
        Duration = 5
    })
    return -- Stop script
end

-- Cek apakah UserID ada di daftar
if not whitelist[UserId] then
    -- JIKA TIDAK TERDAFTAR
    game.StarterGui:SetCore("SendNotification", {
        Title = "AKSES DITOLAK",
        Text = "Kamu tidak memiliki izin menggunakan script ini!",
        Duration = 10
    })
    
    -- Opsional: Kick player
    -- Player:Kick("Script ini Premium. Hubungi Admin untuk akses.")
    
    return -- MATIKAN SCRIPT DI SINI AGAR KODE DI BAWAH TIDAK JALAN
end

-- JIKA LOLOS PENGECEKAN, LANJUT KE SCRIPT ASLI:
print("✅ Akses Diterima! Menjalankan Fish It V1.0...")

-- ========== FISH IT: v.1.1 (SAVE ALL LOGS TO TXT) ==========
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local virtualInput = game:GetService("VirtualInputManager")
local workspace = game:GetService("Workspace")
local camera = workspace.CurrentCamera
local textChatService = game:GetService("TextChatService")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- ====================================================
-- [ 🚨 SAFETY PROTOCOL ]
-- ====================================================
if getgenv().FishItLoop then
    getgenv().FishItLoop:Disconnect()
    getgenv().FishItLoop = nil
end

if getgenv().ChatConn then 
    for _, c in pairs(getgenv().ChatConn) do c:Disconnect() end
    getgenv().ChatConn = {}
else
    getgenv().ChatConn = {}
end

pcall(function()
    if playerGui:FindFirstChild("SpeedHackGui") then playerGui.SpeedHackGui:Destroy() end
    if workspace:FindFirstChild("JesusPlatform") then workspace.JesusPlatform:Destroy() end
end)

-- ===== DATABASE & VARIABLES =====
local IslandLocations = {
    {Name = "Ancient Jungle", CFrame = CFrame.new(1476, 10, -375)},
    {Name = "Ancient Ruin", CFrame = CFrame.new(6050, -586, 4721)},
    {Name = "Carter Island", CFrame = CFrame.new(977, 2, 5016)},
    {Name = "Coral Reefs", CFrame = CFrame.new(-3162, 3, 2285)},
    {Name = "Crystal Depths", CFrame = CFrame.new(5752, -905, 15389)},
    {Name = "Esoteric Depths", CFrame = CFrame.new(3256, -1301, 1391)},
    {Name = "Fisherman Island", CFrame = CFrame.new(27, 9, 2811)},
    {Name = "Kohana Island", CFrame = CFrame.new(-637, 16, 604)},
    {Name = "Kohana Lava", CFrame = CFrame.new(-600, 59, 103)},
    {Name = "Leviathan Cove", CFrame = CFrame.new(3439, -292, 3379)},
    {Name = "Pirate Cove", CFrame = CFrame.new(3502, 10, 3430)},
    {Name = "Pirate Treasure", CFrame = CFrame.new(3341, -300, 3103)},
    {Name = "Secret Temple", CFrame = CFrame.new(1475, -22, -628)},
    {Name = "Sisyphus Statue", CFrame = CFrame.new(-3704, -136, -1016)},
    {Name = "Treasure Room", CFrame = CFrame.new(-3601, -283, -1637)},
    {Name = "Tropical Grove", CFrame = CFrame.new(-2048, 6, 3662)},
}

-- DATABASE REKAP
local SecretStats = {} 

-- ===== CONFIG =====
local config = {
    enabled = false,
    speed = 0.1,
    waterWalk = false,
    waterHeight = nil,
    infJump = false,
    autoClick = false
}

local waterPart = nil
local lastClickTime = 0

print("\n✅ v1.1 Loaded: All Logs Saver Ready!")

-- ===== GUI LAYOUT =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedHackGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Restore Button
local restoreBtn = Instance.new("TextButton")
restoreBtn.Name = "RestoreButton"
restoreBtn.Size = UDim2.new(0, 80, 0, 30)
restoreBtn.Position = UDim2.new(0, 5, 0.5, -15)
restoreBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
restoreBtn.Text = "MENU"
restoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
restoreBtn.Font = Enum.Font.GothamBlack
restoreBtn.TextSize = 12
restoreBtn.Visible = false
restoreBtn.Parent = screenGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
-- UKURAN WIDE 550px
panel.Size = UDim2.new(0, 550, 0, 300) 
panel.Position = UDim2.new(0.5, -275, 0.5, -150)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
panel.BorderSizePixel = 2
panel.BorderColor3 = Color3.fromRGB(0, 150, 255)
panel.Active = true
panel.Draggable = true
panel.Parent = screenGui

-- Header
local titleLabel = Instance.new("TextLabel"); titleLabel.Size = UDim2.new(1, -60, 0, 25); titleLabel.BackgroundColor3 = Color3.fromRGB(0, 120, 220); titleLabel.Text = "  Danny Mobile V48 (Log Saver)"; titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255); titleLabel.Font = Enum.Font.GothamBlack; titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.Parent = panel ; titleLabel.TextSize=12
local closeBtn = Instance.new("TextButton"); closeBtn.Size = UDim2.new(0, 25, 0, 25); closeBtn.Position = UDim2.new(1, -25, 0, 0); closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); closeBtn.Font = Enum.Font.GothamBlack; closeBtn.Parent = panel; closeBtn.TextSize=12
local minBtn = Instance.new("TextButton"); minBtn.Size = UDim2.new(0, 25, 0, 25); minBtn.Position = UDim2.new(1, -55, 0, 0); minBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0); minBtn.Text = "-"; minBtn.TextColor3 = Color3.fromRGB(255, 255, 255); minBtn.Font = Enum.Font.GothamBlack; minBtn.TextYAlignment = Enum.TextYAlignment.Bottom; minBtn.Parent = panel; minBtn.TextSize=18
local vLine = Instance.new("Frame"); vLine.Size = UDim2.new(0, 1, 1, -50); vLine.Position = UDim2.new(0.32, 0, 0, 30); vLine.BackgroundColor3 = Color3.fromRGB(60, 60, 80); vLine.BorderSizePixel = 0; vLine.Parent = panel

-- === KIRI: PLAYER FEATURES (30%) ===
local lblLeft = Instance.new("TextLabel"); lblLeft.Text = "PLAYER"; lblLeft.Size = UDim2.new(0.30, 0, 0, 20); lblLeft.Position = UDim2.new(0, 5, 0, 30); lblLeft.BackgroundTransparency = 1; lblLeft.TextColor3 = Color3.fromRGB(255, 200, 50); lblLeft.Font = Enum.Font.GothamBold; lblLeft.TextSize = 11; lblLeft.Parent = panel

local leftContainer = Instance.new("Frame"); leftContainer.Size = UDim2.new(0.30, 0, 0.72, 0); leftContainer.Position = UDim2.new(0, 5, 0, 50); leftContainer.BackgroundTransparency = 1; leftContainer.Parent = panel
local listLayout = Instance.new("UIListLayout"); listLayout.Parent = leftContainer; listLayout.Padding = UDim.new(0, 5)

local btnToggle = Instance.new("TextButton"); btnToggle.Text = "SPEED: OFF (Z)"; btnToggle.Size = UDim2.new(1, 0, 0, 25); btnToggle.BackgroundColor3 = Color3.fromRGB(255, 80, 80); btnToggle.TextColor3 = Color3.fromRGB(255, 255, 255); btnToggle.Font = Enum.Font.GothamBold; btnToggle.TextSize = 10; btnToggle.Parent = leftContainer
local speedRow = Instance.new("Frame"); speedRow.Size = UDim2.new(1, 0, 0, 25); speedRow.BackgroundTransparency = 1; speedRow.Parent = leftContainer
local speedLayout = Instance.new("UIListLayout"); speedLayout.Parent = speedRow; speedLayout.FillDirection = Enum.FillDirection.Horizontal; speedLayout.Padding = UDim.new(0, 3)
local txtSpeed = Instance.new("TextBox"); txtSpeed.Text = ""; txtSpeed.PlaceholderText = "1-100"; txtSpeed.Size = UDim2.new(0.60, 0, 1, 0); txtSpeed.BackgroundColor3 = Color3.fromRGB(40, 40, 50); txtSpeed.TextColor3 = Color3.fromRGB(0, 255, 150); txtSpeed.Font = Enum.Font.GothamBold; txtSpeed.TextSize = 10; txtSpeed.Parent = speedRow
local btnApply = Instance.new("TextButton"); btnApply.Text = "SET"; btnApply.Size = UDim2.new(0.38, 0, 1, 0); btnApply.BackgroundColor3 = Color3.fromRGB(0, 180, 100); btnApply.TextColor3 = Color3.fromRGB(255, 255, 255); btnApply.Font = Enum.Font.GothamBold; btnApply.TextSize = 10; btnApply.Parent = speedRow
local btnWater = Instance.new("TextButton"); btnWater.Text = "WATER: OFF"; btnWater.Size = UDim2.new(1, 0, 0, 25); btnWater.BackgroundColor3 = Color3.fromRGB(0, 100, 200); btnWater.TextColor3 = Color3.fromRGB(255, 255, 255); btnWater.Font = Enum.Font.GothamBold; btnWater.TextSize = 10; btnWater.Parent = leftContainer
local btnJump = Instance.new("TextButton"); btnJump.Text = "JUMP: OFF"; btnJump.Size = UDim2.new(1, 0, 0, 25); btnJump.BackgroundColor3 = Color3.fromRGB(150, 50, 150); btnJump.TextColor3 = Color3.fromRGB(255, 255, 255); btnJump.Font = Enum.Font.GothamBold; btnJump.TextSize = 10; btnJump.Parent = leftContainer
local btnClicker = Instance.new("TextButton"); btnClicker.Text = "AUTO CLICK (X)"; btnClicker.Size = UDim2.new(1, 0, 0, 25); btnClicker.BackgroundColor3 = Color3.fromRGB(200, 50, 50); btnClicker.TextColor3 = Color3.fromRGB(255, 255, 255); btnClicker.Font = Enum.Font.GothamBold; btnClicker.TextSize = 10; btnClicker.Parent = leftContainer

-- === KANAN: TABS (65%) ===
local rightSidePos = 0.34
local rightSideWidth = 0.65

local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(rightSideWidth, 0, 0, 25)
tabContainer.Position = UDim2.new(rightSidePos, 0, 0, 30)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = panel

local tabLayout = Instance.new("UIListLayout"); tabLayout.Parent = tabContainer; tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.Padding = UDim.new(0, 5)

local btnTabTeleport = Instance.new("TextButton"); btnTabTeleport.Text="TELEPORT"; btnTabTeleport.Size=UDim2.new(0.31,0,1,0); btnTabTeleport.BackgroundColor3=Color3.fromRGB(255,150,0); btnTabTeleport.TextColor3=Color3.new(1,1,1); btnTabTeleport.Font=Enum.Font.GothamBold; btnTabTeleport.TextSize=9; btnTabTeleport.Parent=tabContainer
local btnTabLogs = Instance.new("TextButton"); btnTabLogs.Text="ALL LOGS"; btnTabLogs.Size=UDim2.new(0.31,0,1,0); btnTabLogs.BackgroundColor3=Color3.fromRGB(50,50,70); btnTabLogs.TextColor3=Color3.new(1,1,1); btnTabLogs.Font=Enum.Font.GothamBold; btnTabLogs.TextSize=9; btnTabLogs.Parent=tabContainer
local btnTabSecrets = Instance.new("TextButton"); btnTabSecrets.Text="SECRETS"; btnTabSecrets.Size=UDim2.new(0.31,0,1,0); btnTabSecrets.BackgroundColor3=Color3.fromRGB(50,50,70); btnTabSecrets.TextColor3=Color3.new(1,1,1); btnTabSecrets.Font=Enum.Font.GothamBold; btnTabSecrets.TextSize=9; btnTabSecrets.Parent=tabContainer

-- 1. FRAME TELEPORT
local frameTeleport = Instance.new("Frame")
frameTeleport.Size = UDim2.new(rightSideWidth, 0, 0.72, 0)
frameTeleport.Position = UDim2.new(rightSidePos, 0, 0, 60)
frameTeleport.BackgroundTransparency = 1
frameTeleport.Visible = true
frameTeleport.Parent = panel

local playerTpRow = Instance.new("Frame"); playerTpRow.Size = UDim2.new(1, 0, 0, 25); playerTpRow.BackgroundTransparency = 1; playerTpRow.Parent = frameTeleport
local ptpLayout = Instance.new("UIListLayout"); ptpLayout.Parent = playerTpRow; ptpLayout.FillDirection = Enum.FillDirection.Horizontal; ptpLayout.Padding = UDim.new(0, 3)
local txtPlayerName = Instance.new("TextBox"); txtPlayerName.PlaceholderText = "Name..."; txtPlayerName.Text = ""; txtPlayerName.Size = UDim2.new(0.65, 0, 1, 0); txtPlayerName.BackgroundColor3 = Color3.fromRGB(40, 40, 50); txtPlayerName.TextColor3 = Color3.fromRGB(255, 255, 0); txtPlayerName.Font = Enum.Font.GothamBold; txtPlayerName.TextSize = 10; txtPlayerName.Parent = playerTpRow
local btnTpPlayer = Instance.new("TextButton"); btnTpPlayer.Text = "GO"; btnTpPlayer.Size = UDim2.new(0.33, 0, 1, 0); btnTpPlayer.BackgroundColor3 = Color3.fromRGB(255, 150, 0); btnTpPlayer.TextColor3 = Color3.fromRGB(255, 255, 255); btnTpPlayer.Font = Enum.Font.GothamBold; btnTpPlayer.TextSize = 10; btnTpPlayer.Parent = playerTpRow

local scrollTeleport = Instance.new("ScrollingFrame")
scrollTeleport.Size = UDim2.new(1, 0, 1, -30) 
scrollTeleport.Position = UDim2.new(0, 0, 0, 30)
scrollTeleport.BackgroundColor3=Color3.fromRGB(30,30,40); scrollTeleport.BorderColor3=Color3.fromRGB(0,100,200); scrollTeleport.BorderSizePixel=1; scrollTeleport.ScrollBarThickness=4; scrollTeleport.Parent=frameTeleport
local uiList2 = Instance.new("UIListLayout"); uiList2.Parent=scrollTeleport; uiList2.SortOrder=Enum.SortOrder.LayoutOrder; uiList2.Padding=UDim.new(0,3)
for _, location in ipairs(IslandLocations) do
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, -5, 0, 25); btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70); btn.Text = location.Name; btn.TextColor3 = Color3.fromRGB(200, 200, 255); btn.Font = Enum.Font.GothamBold; btn.TextSize = 10; btn.Parent = scrollTeleport
    btn.MouseButton1Click:Connect(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame = location.CFrame end end)
end
scrollTeleport.CanvasSize = UDim2.new(0, 0, 0, #IslandLocations * 28)

-- 2. FRAME LOGS (WITH SEARCH & SAVE)
local frameLogs = Instance.new("Frame")
frameLogs.Size = UDim2.new(rightSideWidth, 0, 0.72, 0)
frameLogs.Position = UDim2.new(rightSidePos, 0, 0, 60)
frameLogs.BackgroundTransparency = 1
frameLogs.Visible = false
frameLogs.Parent = panel

-- Search Bar
local searchContainer = Instance.new("Frame")
searchContainer.Size = UDim2.new(1, 0, 0, 25)
searchContainer.Position = UDim2.new(0,0,0,0)
searchContainer.BackgroundTransparency = 1
searchContainer.Parent = frameLogs

local txtSearchLogs = Instance.new("TextBox")
txtSearchLogs.PlaceholderText = "Search Logs..."
txtSearchLogs.Text = ""
txtSearchLogs.Size = UDim2.new(1, -5, 1, 0)
txtSearchLogs.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
txtSearchLogs.TextColor3 = Color3.fromRGB(0, 255, 255)
txtSearchLogs.Font = Enum.Font.GothamBold
txtSearchLogs.TextSize = 10
txtSearchLogs.Parent = searchContainer

-- Save Button (NEW)
local saveLogContainer = Instance.new("Frame")
saveLogContainer.Size = UDim2.new(1, 0, 0, 25)
saveLogContainer.Position = UDim2.new(0,0,0,30)
saveLogContainer.BackgroundTransparency = 1
saveLogContainer.Parent = frameLogs

local btnSaveLogs = Instance.new("TextButton")
btnSaveLogs.Text = "SAVE THIS LIST (TXT)"
btnSaveLogs.Size = UDim2.new(1, -5, 1, 0)
btnSaveLogs.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
btnSaveLogs.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSaveLogs.Font = Enum.Font.GothamBold
btnSaveLogs.TextSize = 10
btnSaveLogs.Parent = saveLogContainer

-- Scroll Logs (Pushed down)
local scrollLogs = Instance.new("ScrollingFrame")
scrollLogs.Size = UDim2.new(1, 0, 1, -60) 
scrollLogs.Position = UDim2.new(0, 0, 0, 60)
scrollLogs.BackgroundColor3=Color3.fromRGB(20,20,30); scrollLogs.BorderColor3=Color3.fromRGB(0,100,200); scrollLogs.BorderSizePixel=1; scrollLogs.ScrollBarThickness=4; scrollLogs.Parent=frameLogs
local logLayout = Instance.new("UIListLayout"); logLayout.Parent=scrollLogs; logLayout.SortOrder=Enum.SortOrder.LayoutOrder; logLayout.Padding=UDim.new(0,2)

-- 3. FRAME SECRETS RECAP (WITH SAVE BUTTON)
local frameSecrets = Instance.new("Frame")
frameSecrets.Size = UDim2.new(rightSideWidth, 0, 0.72, 0)
frameSecrets.Position = UDim2.new(rightSidePos, 0, 0, 60)
frameSecrets.BackgroundTransparency = 1
frameSecrets.Visible = false
frameSecrets.Parent = panel

local saveContainer = Instance.new("Frame")
saveContainer.Size = UDim2.new(1, 0, 0, 25)
saveContainer.BackgroundTransparency = 1
saveContainer.Parent = frameSecrets

local btnSaveTxt = Instance.new("TextButton")
btnSaveTxt.Text = "SAVE RECAP TO TXT"
btnSaveTxt.Size = UDim2.new(1, -5, 1, 0)
btnSaveTxt.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
btnSaveTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSaveTxt.Font = Enum.Font.GothamBold
btnSaveTxt.TextSize = 10
btnSaveTxt.Parent = saveContainer

local scrollSecrets = Instance.new("ScrollingFrame")
scrollSecrets.Size = UDim2.new(1, 0, 1, -30) -- Kurangi tinggi utk tombol save
scrollSecrets.Position = UDim2.new(0, 0, 0, 30)
scrollSecrets.BackgroundColor3=Color3.fromRGB(20,30,20); scrollSecrets.BorderColor3=Color3.fromRGB(0,255,100); scrollSecrets.BorderSizePixel=1; scrollSecrets.ScrollBarThickness=4; scrollSecrets.Parent=frameSecrets
local secretLayout = Instance.new("UIListLayout"); secretLayout.Parent=scrollSecrets; secretLayout.SortOrder=Enum.SortOrder.LayoutOrder; secretLayout.Padding=UDim.new(0,2)

-- ==========================================
-- [ 📝 LOGIC SYSTEM 📝 ]
-- ==========================================

-- LOGIC SEARCH FILTER
local function filterLogs()
    local query = string.lower(txtSearchLogs.Text)
    for _, lbl in pairs(scrollLogs:GetChildren()) do
        if lbl:IsA("TextLabel") then
            if query == "" then
                lbl.Visible = true
            else
                if string.lower(lbl.Text):find(query) then
                    lbl.Visible = true
                else
                    lbl.Visible = false
                end
            end
        end
    end
    scrollLogs.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y)
end
txtSearchLogs:GetPropertyChangedSignal("Text"):Connect(filterLogs)

-- LOGIC SAVE ALL LOGS (NEW)
btnSaveLogs.MouseButton1Click:Connect(function()
    if not writefile then
        game.StarterGui:SetCore("SendNotification", {Title="ERROR", Text="Executor unsupported!", Duration=5})
        return
    end
    
    -- Format Nama File: FishLog_22-01-2026_14-30.txt
    local timestampName = os.date("%d-%m-%Y_%H-%M")
    local fileName = "FishLog_" .. timestampName .. ".txt"
    
    local content = "=== FISHING LOG DUMP ===\n"
    content = content .. "Saved at: " .. os.date("%d/%m/%Y %H:%M") .. "\n"
    content = content .. "Search Filter: " .. (txtSearchLogs.Text == "" and "NONE" or txtSearchLogs.Text) .. "\n\n"
    
    -- Loop semua log yg terlihat
    local count = 0
    for _, lbl in pairs(scrollLogs:GetChildren()) do
        if lbl:IsA("TextLabel") and lbl.Visible then
            content = content .. lbl.Text .. "\n"
            count = count + 1
        end
    end
    
    writefile(fileName, content)
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "LOG SAVED!",
        Text = "Saved: " .. fileName .. " (" .. count .. " lines)",
        Duration = 5
    })
    
    btnSaveLogs.Text = "SAVED: " .. fileName
    wait(2)
    btnSaveLogs.Text = "SAVE THIS LIST (TXT)"
end)

-- LOGIC ADD LOG ENTRY
local function addLogEntry(text, color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -5, 0, 25)
    lbl.BackgroundTransparency = 0.8
    lbl.BackgroundColor3 = Color3.fromRGB(0,0,0)
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 11
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = scrollLogs
    
    local query = string.lower(txtSearchLogs.Text)
    if query ~= "" and not string.lower(text):find(query) then
        lbl.Visible = false
    end
    
    scrollLogs.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y)
    if query == "" then scrollLogs.CanvasPosition = Vector2.new(0, 9999) end
end

-- Update Tampilan Tab "SECRETS"
local function updateSecretUI()
    for _, v in pairs(scrollSecrets:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
    
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
        lbl.Text = string.format("[#%d] %s (Total: %d)\n   🐟 List: %s", i, data.Name, data.Count, listString)
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

-- LOGIC SAVE SECRET RECAP
btnSaveTxt.MouseButton1Click:Connect(function()
    if not writefile then
        game.StarterGui:SetCore("SendNotification", {Title="ERROR", Text="Executor unsupported!", Duration=5})
        return
    end
    
    -- Format Nama File: FishSecrets_22-01-2026.txt
    local fileName = "FishSecrets_" .. os.date("%d-%m-%Y") .. ".txt"
    
    local content = "=== FISH IT SECRET RECAP ===\n"
    content = content .. "Saved at: " .. os.date("%d/%m/%Y %H:%M") .. "\n\n"
    
    local sortTable = {}
    for name, data in pairs(SecretStats) do
        table.insert(sortTable, {Name = name, Count = data.Count, FishList = data.FishList})
    end
    table.sort(sortTable, function(a, b) return a.Count > b.Count end)
    
    for i, data in ipairs(sortTable) do
        content = content .. string.format("[#%d] %s (Total: %d)\n", i, data.Name, data.Count)
        content = content .. "   List: " .. table.concat(data.FishList, ", ") .. "\n"
        content = content .. "------------------------------------------------\n"
    end
    
    writefile(fileName, content)
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "FILE SAVED!",
        Text = "Cek folder workspace/" .. fileName,
        Duration = 5
    })
    btnSaveTxt.Text = "SAVED: " .. fileName
    wait(2)
    btnSaveTxt.Text = "SAVE RECAP TO TXT"
end)

local function stripTags(str)
    return string.gsub(str, "<.->", "")
end

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
            if not SecretStats[playerName] then
                SecretStats[playerName] = {Count = 0, FishList = {}}
            end
            SecretStats[playerName].Count = SecretStats[playerName].Count + 1
            table.insert(SecretStats[playerName].FishList, fishInfo)
            updateSecretUI()
            
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://4590657391"
            sound.Volume = 8 
            sound.Parent = playerGui
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 3)
        end
    end
end

if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    local conn = textChatService.MessageReceived:Connect(function(msg)
        parseChat(msg.Text)
    end)
    table.insert(getgenv().ChatConn, conn)
else
    local chatEvents = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    local msgEvent = chatEvents and chatEvents:FindFirstChild("OnMessageDoneFiltering")
    if msgEvent then
        local conn = msgEvent.OnClientEvent:Connect(function(data)
            if data and data.Message then parseChat(data.Message) end
        end)
        table.insert(getgenv().ChatConn, conn)
    end
end

-- Author Msg
local authorLabel = Instance.new("TextLabel")
authorLabel.Name = "AuthorMsg"
authorLabel.Text = "Script by JustDanny v1.1 (2026)"
authorLabel.Size = UDim2.new(1, 0, 0, 20)
authorLabel.Position = UDim2.new(0, 0, 1, -20)
authorLabel.BackgroundTransparency = 1
authorLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
authorLabel.Font = Enum.Font.Gotham
authorLabel.TextSize = 10
authorLabel.Parent = panel

-- ===== HELPER FUNCTIONS =====
local function updateWaterWalk()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = player.Character.HumanoidRootPart
    if config.waterWalk then
        if not waterPart or not waterPart.Parent then
            waterPart = Instance.new("Part"); waterPart.Name = "JesusPlatform"; waterPart.Size = Vector3.new(50, 1, 50); waterPart.Transparency = 0.6; waterPart.Color = Color3.fromRGB(0, 255, 255); waterPart.Material = Enum.Material.ForceField; waterPart.Anchored = true; waterPart.CanCollide = true; waterPart.CastShadow = false; waterPart.Parent = workspace
            if not config.waterHeight then config.waterHeight = root.Position.Y - 3.2 end
        end
        if config.waterHeight then waterPart.CFrame = CFrame.new(root.Position.X, config.waterHeight, root.Position.Z); waterPart.AssemblyLinearVelocity = Vector3.new(0,0,0) end
    else
        if waterPart then waterPart:Destroy(); waterPart = nil; config.waterHeight = nil end
    end
end

local function toggleClicker()
    config.autoClick = not config.autoClick
    if config.autoClick then
        btnClicker.Text = "CLICKER: ON (X)"
        btnClicker.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        btnClicker.Text = "CLICKER: OFF (X)"
        btnClicker.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end

local function toggleSpeed()
    config.enabled = not config.enabled
    btnToggle.Text = config.enabled and "SPEED: ON (Z)" or "SPEED: OFF (Z)"
    btnToggle.BackgroundColor3 = config.enabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 80, 80)
    if player.Character then local h = player.Character:FindFirstChild("Humanoid"); if h then h.WalkSpeed = config.enabled and 16 + (config.speed * 8) or 16 end end
end

-- LOGIC GANTI TAB (3 TABS)
local function switchTab(tabName)
    frameTeleport.Visible = false
    frameLogs.Visible = false
    frameSecrets.Visible = false
    
    btnTabTeleport.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btnTabLogs.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btnTabSecrets.BackgroundColor3 = Color3.fromRGB(50, 50, 70)

    if tabName == "TP" then
        frameTeleport.Visible = true
        btnTabTeleport.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    elseif tabName == "LOG" then
        frameLogs.Visible = true
        btnTabLogs.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    elseif tabName == "SEC" then
        frameSecrets.Visible = true
        btnTabSecrets.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    end
end

btnTabTeleport.MouseButton1Click:Connect(function() switchTab("TP") end)
btnTabLogs.MouseButton1Click:Connect(function() switchTab("LOG") end)
btnTabSecrets.MouseButton1Click:Connect(function() switchTab("SEC") end)

-- ===== TOMBOL LOGIC =====
closeBtn.MouseButton1Click:Connect(function() 
    if getgenv().FishItLoop then getgenv().FishItLoop:Disconnect() end
    if getgenv().ChatConn then for _, c in pairs(getgenv().ChatConn) do c:Disconnect() end end
    config.enabled=false; config.waterWalk=false; config.infJump=false; config.autoClick=false
    if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = 16 end
    updateWaterWalk()
    screenGui:Destroy() 
end)

minBtn.MouseButton1Click:Connect(function() panel.Visible = false; restoreBtn.Visible = true end)
restoreBtn.MouseButton1Click:Connect(function() panel.Visible = true; restoreBtn.Visible = false end)

btnToggle.MouseButton1Click:Connect(toggleSpeed)
btnApply.MouseButton1Click:Connect(function() local v=tonumber(txtSpeed.Text); if v then config.speed=v end end)
btnWater.MouseButton1Click:Connect(function() config.waterWalk = not config.waterWalk; btnWater.Text = config.waterWalk and "WATER: ON" or "WATER: OFF"; btnWater.BackgroundColor3 = config.waterWalk and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(0, 100, 200); config.waterHeight = nil; updateWaterWalk() end)
btnJump.MouseButton1Click:Connect(function() config.infJump = not config.infJump; btnJump.Text = config.infJump and "JUMP: ON" or "JUMP: OFF"; btnJump.BackgroundColor3 = config.infJump and Color3.fromRGB(200, 50, 255) or Color3.fromRGB(150, 50, 150) end)

btnClicker.MouseButton1Click:Connect(toggleClicker)

-- TP Logic
btnTpPlayer.MouseButton1Click:Connect(function()
    local targetName = txtPlayerName.Text
    if targetName == "" then return end
    local found = false
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and (string.sub(string.lower(p.Name), 1, #targetName) == string.lower(targetName) or string.sub(string.lower(p.DisplayName), 1, #targetName) == string.lower(targetName)) then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                txtPlayerName.Text = "TP: " .. p.DisplayName
                found = true
                break
            end
        end
    end
    if not found then txtPlayerName.Text = "404"; wait(1); txtPlayerName.Text = targetName end
end)

-- Keybinds
userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.X then toggleClicker()
        elseif input.KeyCode == Enum.KeyCode.Z then toggleSpeed()
        elseif input.KeyCode == Enum.KeyCode.M then
            if panel.Visible then panel.Visible = false; restoreBtn.Visible = true
            else panel.Visible = true; restoreBtn.Visible = false end
        end
    end
end)

-- Jump Logic
userInputService.JumpRequest:Connect(function()
    if config.infJump and player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Main Loop
local mainLoop = runService.Heartbeat:Connect(function()
    if not screenGui.Parent then return end 
    pcall(function()
        if player.Character and config.enabled then 
            local h = player.Character:FindFirstChild("Humanoid")
            if h then h.WalkSpeed = 16 + (config.speed * 8) end
        end
        updateWaterWalk()

        -- Auto Clicker
        if config.autoClick and tick() - lastClickTime > 0.05 then
            local viewport = camera.ViewportSize
            local clickX, clickY = viewport.X * 0.85, viewport.Y * 0.65 
            virtualInput:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
            virtualInput:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
            lastClickTime = tick()
        end
    end)
end)

getgenv().FishItLoop = mainLoop
