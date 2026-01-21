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
print("✅ Akses Diterima! Menjalankan Fish It V29...")

-- ====================================================
-- [ 👇 KODE FISH IT V29 DIMULAI DARI SINI 👇 ]
-- ====================================================

-- ... (Copy Paste seluruh isi Script V29 yang tadi di bawah sini) ...
