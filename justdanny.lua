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

--JustDanny Script v1.0 
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local virtualInput = game:GetService("VirtualInputManager")
local workspace = game:GetService("Workspace")
local camera = workspace.CurrentCamera


-- SAFETY PROTOCOL 

if getgenv().FishItLoop then
    getgenv().FishItLoop:Disconnect()
    getgenv().FishItLoop = nil
end

pcall(function()
    if playerGui:FindFirstChild("SpeedHackGui") then playerGui.SpeedHackGui:Destroy() end
    if workspace:FindFirstChild("JesusPlatform") then workspace.JesusPlatform:Destroy() end
end)

-- DATABASE LOKASI TELEPORT 

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

-- CONFIG 
local config = {
    enabled = false,    -- Speed
    speed = 0.1,
    waterWalk = false,  -- Water Walk
    waterHeight = nil,
    infJump = false,    -- Infinity Jump
    autoClick = false,  -- Auto Clicker
}

local waterPart = nil
local lastClickTime = 0

print("\n✅ V1.0 Loaded: Press Z (Speed) & M (Minimize)!")

-- GUI LAYOUT 
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
panel.Size = UDim2.new(0, 380, 0, 270) 
panel.Position = UDim2.new(0.5, -190, 0.5, -135)
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
panel.BorderSizePixel = 2
panel.BorderColor3 = Color3.fromRGB(0, 150, 255)
panel.Active = true
panel.Draggable = true
panel.Parent = screenGui

-- Header
local titleLabel = Instance.new("TextLabel"); titleLabel.Size = UDim2.new(1, -60, 0, 25); titleLabel.BackgroundColor3 = Color3.fromRGB(0, 120, 220); titleLabel.Text = "JustDanny Script v.1.0"; titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255); titleLabel.Font = Enum.Font.GothamBlack; titleLabel.TextXAlignment = Enum.TextXAlignment.Left; titleLabel.Parent = panel ; titleLabel.TextSize=12
local closeBtn = Instance.new("TextButton"); closeBtn.Size = UDim2.new(0, 25, 0, 25); closeBtn.Position = UDim2.new(1, -25, 0, 0); closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50); closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); closeBtn.Font = Enum.Font.GothamBlack; closeBtn.Parent = panel; closeBtn.TextSize=12
local minBtn = Instance.new("TextButton"); minBtn.Size = UDim2.new(0, 25, 0, 25); minBtn.Position = UDim2.new(1, -55, 0, 0); minBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0); minBtn.Text = "-"; minBtn.TextColor3 = Color3.fromRGB(255, 255, 255); minBtn.Font = Enum.Font.GothamBlack; minBtn.TextYAlignment = Enum.TextYAlignment.Bottom; minBtn.Parent = panel; minBtn.TextSize=18
local vLine = Instance.new("Frame"); vLine.Size = UDim2.new(0, 1, 1, -50); vLine.Position = UDim2.new(0.5, 0, 0, 30); vLine.BackgroundColor3 = Color3.fromRGB(60, 60, 80); vLine.BorderSizePixel = 0; vLine.Parent = panel

-- KIRI: PLAYER FEATURES 
local lblLeft = Instance.new("TextLabel"); lblLeft.Text = "PLAYER"; lblLeft.Size = UDim2.new(0.45, 0, 0, 20); lblLeft.Position = UDim2.new(0, 5, 0, 30); lblLeft.BackgroundTransparency = 1; lblLeft.TextColor3 = Color3.fromRGB(255, 200, 50); lblLeft.Font = Enum.Font.GothamBold; lblLeft.TextSize = 11; lblLeft.Parent = panel

local leftContainer = Instance.new("Frame"); leftContainer.Size = UDim2.new(0.48, 0, 0.72, 0); leftContainer.Position = UDim2.new(0, 5, 0, 50); leftContainer.BackgroundTransparency = 1; leftContainer.Parent = panel
local listLayout = Instance.new("UIListLayout"); listLayout.Parent = leftContainer; listLayout.Padding = UDim.new(0, 5)

-- Buttons Left
local btnToggle = Instance.new("TextButton"); btnToggle.Text = "SPEED: OFF (Z)"; btnToggle.Size = UDim2.new(1, 0, 0, 25); btnToggle.BackgroundColor3 = Color3.fromRGB(255, 80, 80); btnToggle.TextColor3 = Color3.fromRGB(255, 255, 255); btnToggle.Font = Enum.Font.GothamBold; btnToggle.TextSize = 10; btnToggle.Parent = leftContainer
local speedRow = Instance.new("Frame"); speedRow.Size = UDim2.new(1, 0, 0, 25); speedRow.BackgroundTransparency = 1; speedRow.Parent = leftContainer
local speedLayout = Instance.new("UIListLayout"); speedLayout.Parent = speedRow; speedLayout.FillDirection = Enum.FillDirection.Horizontal; speedLayout.Padding = UDim.new(0, 3)
local txtSpeed = Instance.new("TextBox"); txtSpeed.Text = ""; txtSpeed.PlaceholderText = "1-100"; txtSpeed.Size = UDim2.new(0.65, 0, 1, 0); txtSpeed.BackgroundColor3 = Color3.fromRGB(40, 40, 50); txtSpeed.TextColor3 = Color3.fromRGB(0, 255, 150); txtSpeed.Font = Enum.Font.GothamBold; txtSpeed.TextSize = 10; txtSpeed.Parent = speedRow
local btnApply = Instance.new("TextButton"); btnApply.Text = "SET"; btnApply.Size = UDim2.new(0.33, 0, 1, 0); btnApply.BackgroundColor3 = Color3.fromRGB(0, 180, 100); btnApply.TextColor3 = Color3.fromRGB(255, 255, 255); btnApply.Font = Enum.Font.GothamBold; btnApply.TextSize = 10; btnApply.Parent = speedRow
local btnWater = Instance.new("TextButton"); btnWater.Text = "WATER: OFF"; btnWater.Size = UDim2.new(1, 0, 0, 25); btnWater.BackgroundColor3 = Color3.fromRGB(0, 100, 200); btnWater.TextColor3 = Color3.fromRGB(255, 255, 255); btnWater.Font = Enum.Font.GothamBold; btnWater.TextSize = 10; btnWater.Parent = leftContainer
local btnJump = Instance.new("TextButton"); btnJump.Text = "JUMP: OFF"; btnJump.Size = UDim2.new(1, 0, 0, 25); btnJump.BackgroundColor3 = Color3.fromRGB(150, 50, 150); btnJump.TextColor3 = Color3.fromRGB(255, 255, 255); btnJump.Font = Enum.Font.GothamBold; btnJump.TextSize = 10; btnJump.Parent = leftContainer
local btnClicker = Instance.new("TextButton"); btnClicker.Text = "AUTO CLICK (X)"; btnClicker.Size = UDim2.new(1, 0, 0, 25); btnClicker.BackgroundColor3 = Color3.fromRGB(200, 50, 50); btnClicker.TextColor3 = Color3.fromRGB(255, 255, 255); btnClicker.Font = Enum.Font.GothamBold; btnClicker.TextSize = 10; btnClicker.Parent = leftContainer

-- KANAN: TELEPORT FEATURES 
local lblTPList = Instance.new("TextLabel"); lblTPList.Text = "TELEPORT"; lblTPList.Size = UDim2.new(0.45, 0, 0, 20); lblTPList.Position = UDim2.new(0.5, 5, 0, 30); lblTPList.BackgroundTransparency = 1; lblTPList.TextColor3 = Color3.fromRGB(255, 200, 50); lblTPList.Font = Enum.Font.GothamBold; lblTPList.TextSize = 11; lblTPList.Parent = panel

-- 1. PLAYER TELEPORT SECTION
local playerTpRow = Instance.new("Frame")
playerTpRow.Size = UDim2.new(0.46, 0, 0, 25)
playerTpRow.Position = UDim2.new(0.5, 5, 0, 50)
playerTpRow.BackgroundTransparency = 1
playerTpRow.Parent = panel

local ptpLayout = Instance.new("UIListLayout"); ptpLayout.Parent = playerTpRow; ptpLayout.FillDirection = Enum.FillDirection.Horizontal; ptpLayout.Padding = UDim.new(0, 3)

local txtPlayerName = Instance.new("TextBox")
txtPlayerName.PlaceholderText = "Name..."
txtPlayerName.Text = ""
txtPlayerName.Size = UDim2.new(0.65, 0, 1, 0)
txtPlayerName.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
txtPlayerName.TextColor3 = Color3.fromRGB(255, 255, 0)
txtPlayerName.Font = Enum.Font.GothamBold
txtPlayerName.TextSize = 10
txtPlayerName.Parent = playerTpRow

local btnTpPlayer = Instance.new("TextButton")
btnTpPlayer.Text = "GO"
btnTpPlayer.Size = UDim2.new(0.33, 0, 1, 0)
btnTpPlayer.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
btnTpPlayer.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTpPlayer.Font = Enum.Font.GothamBold
btnTpPlayer.TextSize = 10
btnTpPlayer.Parent = playerTpRow

-- 2. ISLAND LIST (SCROLLING FRAME)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0.46, 0, 0, 165) 
scrollFrame.Position = UDim2.new(0.5, 5, 0, 80)
scrollFrame.BackgroundColor3=Color3.fromRGB(30,30,40); scrollFrame.BorderColor3=Color3.fromRGB(0,100,200); scrollFrame.BorderSizePixel=1; scrollFrame.ScrollBarThickness=4; scrollFrame.Parent=panel
local uiList2 = Instance.new("UIListLayout"); uiList2.Parent=scrollFrame; uiList2.SortOrder=Enum.SortOrder.LayoutOrder; uiList2.Padding=UDim.new(0,3)

for _, location in ipairs(IslandLocations) do
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1, -5, 0, 25); btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70); btn.Text = location.Name; btn.TextColor3 = Color3.fromRGB(200, 200, 255); btn.Font = Enum.Font.GothamBold; btn.TextSize = 10; btn.Parent = scrollFrame
    btn.MouseButton1Click:Connect(function() if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame = location.CFrame end end)
end
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #IslandLocations * 28)

-- AUTHOR MESSAGE (FOOTER) 

local authorLabel = Instance.new("TextLabel")
authorLabel.Name = "AuthorMsg"
authorLabel.Text = "Script v1.0 by JustDanny 2026"
authorLabel.Size = UDim2.new(1, 0, 0, 20)
authorLabel.Position = UDim2.new(0, 0, 1, -20)
authorLabel.BackgroundTransparency = 1
authorLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
authorLabel.Font = Enum.Font.Gotham
authorLabel.TextSize = 10
authorLabel.Parent = panel

-- HELPER FUNCTIONS 
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

-- FUNCTION TOGGLE SPEED
local function toggleSpeed()
    config.enabled = not config.enabled
    btnToggle.Text = config.enabled and "SPEED: ON (Z)" or "SPEED: OFF (Z)"
    btnToggle.BackgroundColor3 = config.enabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 80, 80)
    
    -- Update Physics Langsung saat Toggle
    if player.Character then 
        local h = player.Character:FindFirstChild("Humanoid")
        if h then 
            if config.enabled then
                h.WalkSpeed = 16 + (config.speed * 8)
            else
                h.WalkSpeed = 16 
            end
        end 
    end
end

-- TOMBOL LOGIC 
closeBtn.MouseButton1Click:Connect(function() 
    if getgenv().FishItLoop then getgenv().FishItLoop:Disconnect() end
    config.enabled=false; config.waterWalk=false; config.infJump=false; config.autoClick=false 
    if player.Character and player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid.WalkSpeed = 16 end
    updateWaterWalk()
    screenGui:Destroy() 
end)

-- Tombol GUI Minimize/Restore
minBtn.MouseButton1Click:Connect(function() panel.Visible = false; restoreBtn.Visible = true end)
restoreBtn.MouseButton1Click:Connect(function() panel.Visible = true; restoreBtn.Visible = false end)

-- Connect Tombol GUI ke Fungsi ToggleSpeed
btnToggle.MouseButton1Click:Connect(toggleSpeed)

btnApply.MouseButton1Click:Connect(function() local v=tonumber(txtSpeed.Text); if v then config.speed=v end end)
btnWater.MouseButton1Click:Connect(function() config.waterWalk = not config.waterWalk; btnWater.Text = config.waterWalk and "WATER: ON" or "WATER: OFF"; btnWater.BackgroundColor3 = config.waterWalk and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(0, 100, 200); config.waterHeight = nil; updateWaterWalk() end)
btnJump.MouseButton1Click:Connect(function() config.infJump = not config.infJump; btnJump.Text = config.infJump and "JUMP: ON" or "JUMP: OFF"; btnJump.BackgroundColor3 = config.infJump and Color3.fromRGB(200, 50, 255) or Color3.fromRGB(150, 50, 150) end)

btnClicker.MouseButton1Click:Connect(toggleClicker)

-- LOGIC PLAYER TP
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
    
    if not found then
        txtPlayerName.Text = "404"
        wait(1)
        txtPlayerName.Text = targetName
    end
end)

-- KEYBINDS: X (Click), Z (Speed), M (Min) 

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.X then
            toggleClicker()
        elseif input.KeyCode == Enum.KeyCode.Z then
            toggleSpeed()
        elseif input.KeyCode == Enum.KeyCode.M then
            if panel.Visible then
                panel.Visible = false
                restoreBtn.Visible = true
            else
                panel.Visible = true
                restoreBtn.Visible = false
            end
        end
    end
end)

-- LOGIKA JUMP

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
        -- Loop Speed logic
        if player.Character and config.enabled then 
            local h = player.Character:FindFirstChild("Humanoid")
            if h then h.WalkSpeed = 16 + (config.speed * 8) end
        end
        
        updateWaterWalk()

        if config.autoClick then
            if tick() - lastClickTime > 0.05 then
                local viewport = camera.ViewportSize
                -- Koordinat Aman
                local clickX = viewport.X * 0.85
                local clickY = viewport.Y * 0.65 
                virtualInput:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                virtualInput:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
                lastClickTime = tick()
            end
        end
    end)
end)

getgenv().FishItLoop = mainLoop
