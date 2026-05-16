local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

-- 1. ĐIỀN LINK FIREBASE CỦA BẠN (Nhớ thêm .json vào cuối link)
local DatabaseURL = "https://phuoc-245b8-default-rtdb.asia-southeast1.firebasedatabase.app/KeySystem.json"

local TIME_3_MINS = 180
local TIME_7_DAYS = 7 * 24 * 60 * 60
local TIME_30_DAYS = 30 * 24 * 60 * 60
local PERMANENT = -1

local KeyCategories = {
    [TIME_3_MINS] = { -- Nhóm 3 phút (Test)
        "test-3p-1",
        "test-3p-2",
        "29448vnj-cjjend9"
    },
    
    [TIME_7_DAYS] = { -- Nhóm 7 ngày
        "key-7ngay-abc",
        "PLso4H3j-N8sj4rn-84ndo4sd",
        "K9a2mPzL-XjW3qR1-Vn8mLo2p",
        "B1v5nM9k-Qp0zL4s-Xa7jR2wI",
        "Z3m8xK4j-Lp9sQ2n-Vb1vM5oC",
        "R6n2vB9m-Xk4jL1p-Qz0sW3aD",
        "M4p8zL1s-Vn9jK2m-Bq3vX5nW",
        "J7s2nK9l-Qw0vR4m-Xz1pL8aB",
        "F5v9mB2n-Lk3sP1z-Qj4rM6oX",
        "D2n8xL4k-Vp7mS1w-Za0vB9jQ",
        "H1k5mP3z-Xq9rL2n-Vb4sJ7oW",
        "S3v2nB8m-Lj1pQ4k-Xz5mR9oD",
        "G9n4xL2p-Vq1sM3z-Bw0vK8aR",
        "Y6p2mK1s-Xj4nL9v-Qz7rB3oW",
        "A4v8nB3m-Lp0sR2k-Vz9mJ1oX",
        "E7n1xL5j-Qw4vP9z-Bk2sM8aR",
        "T2k8mP1s-Vn3rL4m-Xq0zJ9oW",
        "U5v9nB2k-Lj7sQ1p-Xz4mR6oD",
        "I1n4xL8m-Vq0sP3z-Bw2vK9aR",
        "O3p2mK7s-Xj9nL1v-Qz5rB4oW",
        "P8v1nB4m-Lp3sR9k-Vz0mJ2oX",
        "farm-7d-001"
    },
    
    [TIME_30_DAYS] = { -- Nhóm 30 ngày
        "vip-30day-xyz",
        "Xj3nL9v1-Qz7rB5oW-2k8mP1sV",
        "Vn3rL4m0-Xq0zJ9oW-5v9nB2kL",
        "Lj7sQ1p4-Xz4mR6oD-1n4xL8mV",
        "Vq0sP3z2-Bw2vK9aR-3p2mK7sX",
        "Xj9nL1v5-Qz5rB4oW-8v1nB4mL",
        "Lp3sR9k0-Vz0mJ2oX-6n7xL2jQ",
        "Qw5vP1z9-Bk9sM3aR-4k2mP8sV",
        "Vn0rL5m1-Xq1zJ7oW-9v5nB1kL",
        "Lj4sQ3p8-Xz8mR2oD-2n9xL4mV",
        "Vq7sP0z1-Bw1vK5aR-5p8mK3sX",
        "Xj2nL6v1-Qz1rB9oW-0v3nB7mL",
        "Lp1sR4k8-Vz8mJ5oX-7n2xL9jQ",
        "Qw8vP3z0-Bk0sM4aR-3k9mP5sV",
        "Vn1rL2m7-Xq7zJ0oW-1v4nB8kL",
        "Lj0sQ9p2-Xz2mR3oD-6n0xL3mV",
        "key-thang-99"
    },
    
    [PERMANENT] = { -- Nhóm vĩnh viễn
        "key-vinh-vien-1",
        "admin-full-life",
        "boss-server-infinity"
    }
}

local Config = {
    LockedHWID = (getgenv().tmconfig and getgenv().tmconfig.key2hi),

    MyKey =  (getgenv().tmconfig and getgenv().tmconfig.key) or "key-mac-dinh",
    MaxTabs = (getgenv().tmconfig and getgenv().tmconfig.max_tabs) or 40,
    DanhSachKey = {}
}

local CurrentPC_HWID = RbxAnalyticsService:GetClientId()
if CurrentPC_HWID ~= Config.LockedHWID then
    game.Players.LocalPlayer:Kick("\n[LỖI BẢO MẬT H]\nThiết bị không trùng khớp với script!\nH: " .. CurrentPC_H)
    return -- Dừng toàn bộ script
end

-- Tự động chuyển danh sách nhóm vào danh sách tổng để script check
for duration, keys in pairs(KeyCategories) do
    for _, kName in ipairs(keys) do
        Config.DanhSachKey[kName] = duration
    end
end

local function GetDB()
    local success, response = pcall(function()
        return request({
            Url = DatabaseURL,
            Method = "GET"
        })
    end)
    if success and response.StatusCode == 200 and response.Body ~= "null" then
        return HttpService:JSONDecode(response.Body)
    end
    return {}
end

local function SaveDB(db)
    pcall(function()
        request({
            Url = DatabaseURL,
            Method = "PUT",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(db)
        })
    end)
end

local function FormatTime(seconds)
    if seconds == -1 then return "Vĩnh viễn" end
    if seconds <= 0 then return "Đã hết hạn" end
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    if days > 0 then return string.format("%d ngày, %d giờ", days, hours) end
    return string.format("%d phút, %d giây", mins, seconds % 60)
end

local MyTabID = tostring(math.random(100000, 999999))

local function CheckAuth()
    local inputKey = Config.MyKey
    local currentTime = os.time()
    local db = GetDB()

    -- 1. Check xem key có trong danh sách trắng không
    local keyDuration = Config.DanhSachKey[inputKey]
    if not keyDuration then 
        return false, "Key không tồn tại trong hệ thống!" 
    end

    -- 2. Lấy dữ liệu trên Firebase
    if not db[inputKey] then
        db[inputKey] = {StartTime = 0, IsExpired = false, ActiveTabs = {}}
    end
    local kData = db[inputKey]

    -- 3. Check xem đã bị khóa vĩnh viễn chưa
    if kData.IsExpired then 
        return false, "Key này đã hết hạn sử dụng trước đó!" 
    end

    -- 4. Kích hoạt lần đầu
    if kData.StartTime == 0 then
        kData.StartTime = currentTime
    end

    -- 5. Tính toán thời gian còn lại
    local timeLeft = -1
    if keyDuration ~= -1 then
        local timePassed = currentTime - kData.StartTime
        timeLeft = keyDuration - timePassed
        
        if timePassed >= keyDuration then
            kData.IsExpired = true
            db[inputKey] = kData
            SaveDB(db)
            return false, "Thời hạn key đã hết ("..FormatTime(keyDuration)..")!"
        end
    end

    -- 6. Quản lý số Tab (Concurrency)
    local updatedTabs = {}
    local onlineCount = 0
    for id, lastSeen in pairs(kData.ActiveTabs or {}) do
        if (currentTime - lastSeen) < 15 then
            updatedTabs[id] = lastSeen
            onlineCount = onlineCount + 1
        end
    end

    if not updatedTabs[MyTabID] then
        if onlineCount >= Config.MaxTabs then
            return false, "Key đã đạt giới hạn " .. Config.MaxTabs .. " tab!"
        end
        onlineCount = onlineCount + 1
    end

    updatedTabs[MyTabID] = currentTime
    kData.ActiveTabs = updatedTabs
    db[inputKey] = kData
    
    SaveDB(db)
    return true, onlineCount, timeLeft
end

-- ==========================================
-- 6. THỰC THI
-- ==========================================
local function StartFarmScript()
repeat task.wait() until game:IsLoaded()

print("⏳ Game đã load xong. Đang chờ thêm 10 giây để ổn định tài nguyên...")
task.wait(10) 
print("🚀 Bắt đầu chạy Script!")
-- ==========================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer
repeat task.wait() until plr

print("⚓ Đang tiến hành vào phe Marine trước...")

local function JoinMarine()
    pcall(function()
        if not plr.Team or plr.Team.Name ~= "Marines" then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
        end
    end)
end

-- Spam lệnh join cho đến khi thực sự vào team
repeat 
    JoinMarine()
    task.wait(3)
until plr.Team and plr.Team.Name == "Marines"

print("✅ Đã xác nhận: Bạn đang ở phe Marine!")
task.wait(6) -- Nghỉ 1 nhịp cho game ổn định

-- Tọa độ chuẩn của NPC Sharkman Karate
local npcPos = Vector3.new(-4972.51611328125, 314.8302307128906, -3222.7587890625)

-- Hàm kiểm tra Sharkman Karate
local function hasSharkmanKarate()
    -- 1. Kiểm tra trong Folder Data
    local data = plr:FindFirstChild("Data")
    if data and data:FindFirstChild("FightingStyle") then
        local style = tostring(data.FightingStyle.Value)
        if style:find("Sharkman") or style:find("Karate") then
            return true
        end
    end

    -- 2. Kiểm tra trên nhân vật
    local char = plr.Character
    if char then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("Tool") and (v.Name:find("Sharkman") or v.Name:find("Karate")) then
                return true
            end
        end
    end

    -- 3. Kiểm tra trong Backpack
    for _, v in ipairs(plr.Backpack:GetChildren()) do
        if v:IsA("Tool") and (v.Name:find("Sharkman") or v.Name:find("Karate")) then
            return true
        end
    end

    return false
end

local function tweenTo(pos)
    local chr = plr.Character or plr.CharacterAdded:Wait()
    local hrp = chr:WaitForChild("HumanoidRootPart")
    
    -- Bật Noclip để không đâm vào tường khi bay
    local noclipConn
    noclipConn = RunService.Stepped:Connect(function()
        if chr then
            for _, v in pairs(chr:GetChildren()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)

    -- SỬA LỖI: Bay thẳng đến pos (độ cao 314) thay vì ép xuống 150
    local targetPos = pos 
    local distance = (hrp.Position - targetPos).Magnitude
    
    -- Tính toán tốc độ (300 stud/giây)
    local info = TweenInfo.new(distance/300, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, info, {CFrame = CFrame.new(targetPos)})
    
    tween:Play()
    tween.Completed:Wait()

    -- Tắt Noclip sau khi đến nơi
    if noclipConn then noclipConn:Disconnect() end

    -- GIỮ NHÂN VẬT KHÔNG BỊ RƠI
    hrp.Velocity = Vector3.zero -- Ngắt lực quán tính
    
    -- Tạo bệ đỡ vô hình dưới chân để đứng mua cho chắc
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(10, 1, 10)
    platform.Position = targetPos - Vector3.new(0, 3.5, 0)
    platform.Anchored = true
    platform.Transparency = 1 
    platform.Parent = workspace
    
    -- Xóa bệ đỡ sau 10 giây (đủ thời gian mua)
    game:GetService("Debris"):AddItem(platform, 10)
end


if hasSharkmanKarate() then
    print("✅ Hệ thống xác nhận: Đã có Sharkman Karate. Khởi động BananaHub ngay...")
else
    print("❌ Chưa thấy Sharkman Karate. Đang chuẩn bị đi mua...")
    
    -- Gọi hàm Tween mới
    tweenTo(npcPos)
    
    print("📍 Đã đến nơi, bắt đầu spam mua...")
    
    while not hasSharkmanKarate() do
        pcall(function()
            -- Cố gắng đứng yên tại chỗ
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(npcPos)
            end
            ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate")
        end)
        task.wait(2)
    end
end

-- =========================
-- RUN BANANAHUB
-- =========================
getgenv().Key = "e9a69dd3337d46a4551c49a1" 
getgenv().Config = {
    ["Auto Join Dungeon"] = false,
    ["Auto Fire Shoot Heart Leviathan"] = false,
    ["Noti Profile"] = false,
    ["Teleport To Fruit"] = false,
    ["Auto Slap Battle"] = false,
    ["No Frog"] = false,
    ["Auto Dodge Skill Mobs"] = false,
    ["Ignore Craft Volcanic Magnet"] = false,
    ["Auto Trade Azure Ember"] = false,
    ["Auto Present Event"] = false,
    ["Auto Turn On V3"] = true,
    ["Tween Boat To Frozen Dimension"] = false,
    ["Change Size Reel"] = false,
    ["Auto Aimbot Gun"] = false,
    ["Distance Teleport Y"] = 800,
    ["Auto New World"] = false,
    ["Drive Boat To Hydra"] = false,
    ["Random Devil Fruit [ Winter ]"] = false,
    ["Summon Dough King"] = false,
    ["Auto Store Fruit"] = true,
    ["Auto Start Leviathan"] = false,
    ["Auto Sell Fishing"] = false,
    ["ESP Berry"] = false,
    ["Account Pick Slot Raid"] = false,
    ["Auto Multi Raid"] = false,
    ["Select Skills Sword"] = {
        ["Z"] = true,
        ["X"] = true
    },
    ["Auto Get Rainbow Haki"] = false,
    ["Boost Fps"] = false,
    ["Auto Spawn Kitsune Island"] = false,
    ["Fully Trial Draco"] = false,
    ["Auto Trial"] = false,
    ["Account Buy Chip"] = false,
    ["Auto Attack Dungeon"] = false,
    ["Kill players When complete Trial"] = false,
    ["Hop Server Elite Hunter"] = false,
    ["Random Devil Fruit"] = true,
    ["Use skill fast dont hold"] = false,
    ["Auto Collect Bone"] = false,
    ["Speed Tween"] = 350,
    ["Auto Turn On Observation"] = true,
    ["Values Azure Ember"] = 10,
    ["Auto Tween To Event Fishing Spot"] = false,
    ["Auto Summon Rip Indra"] = false,
    ["Noclip"] = false,
    ["Walk On Water "] = true,
    ["Hop Find Katakuri"] = false,
    ["Input WalkSpeed"] = 200,
    ["Select Zone"] = "Zone 6",
    ["Auto Touch Pad Haki"] = false,
    ["Webhook Find Mirage"] = false,
    ["Attack Dough King"] = false,
    ["Auto Pick Card Dungeon"] = false,
    ["Select Skills Gun"] = {
        ["Z"] = true,
        ["X"] = true
    },
    ["Spam Join"] = false,
    ["Use Portal Teleport"] = false,
    ["Auto Turn On V4"] = true,
    ["Auto Finish Train Quest"] = false,
    ["Teleport Y"] = true,
    ["ESP Player"] = false,
    ["Buy Blox Fruit Sniper Shop"] = false,
    ["Select Stats"] = {
		["Sword"] = true,
		["Defense"] = true,
		["Melee"] = true
    },
    ["Auto Yoru Mini"] = false,
    ["Auto Dodge Skill Terrorshark"] = false,
    ["Auto Upgrade Gun Inventory"] = false,
    ["Auto Trade Bone"] = true,
    ["Auto Chest Hop"] = false,
    ["Auto Get Cyborg"] = false,
    ["Teleport Boat Other CFrame if Rough Sea"] = true,
    ["Auto Turn On V3 Near Door"] = false,
    ["Auto Yoru Mini (Hop Server)"] = false,
    ["Auto Awake Fruit"] = false,
    ["Auto Soul Guitar"] = false,
    ["Hop Server [ Haki color or Legendary Sword]"] = false,
    ["Auto Open Chest"] = false,
    ["Auto Factory"] = false,
    ["Attack Multi Segments Leviathan"] = false,
    ["Ignore Attack Katakuri"] = false,
    ["Auto Turn On Buso"] = true,
    ["White Screen"] = false,
    ["Auto Saber"] = false,
    ["Auto Fishing"] = false,
    ["Change Speed Boat"] = false,
    ["Auto Summon Soul Ember"] = false,
    ["Distance Farm Aura"] = 300,
    ["Auto UP Observation V2"] = false,
    ["Attack No Animation "] = true,
    ["Auto Attack Leviathan"] = false,
    ["Hop Find Darkbeard"] = false,
    ["Kill Mob"] = false,
    ["Webhook Store Fruit"] = false,
    ["Auto TTK"] = false,
    ["Auto Buy Spy"] = false,
    ["Drive Boat To Tiki"] = false,
    ["Auto Dodge Skill Seabeast"] = false,
    ["Auto Collect Egg"] = false,
    ["% Health Player"] = 40,
    ["Auto Upgrade Race V2-V3"] = false,
    ["Auto Find Leviathan"] = false,
    ["Select Boat"] = "Guardian",
    ["Farm Material"] = false,
    ["Hop Server [Trial Or Pull Lever]"] = false,
    ["Use Your Boat Beast Hunter"] = false,
    ["Select Skills Blox Fruit"] = {
        ["X"] = true,
        ["C"] = true,
        ["Z"] = true,
        ["V"] = true,
        ["F"] = true
    },
    ["Get Fruit In Inventory Low Beli"] = false,
    ["Bring Mob Count"] = 2,
    ["Teleport Frozen Dimension"] = false,
    ["Will Back When over 10km"] = true,
    ["Black Screen"] = false,
    ["Auto Click"] = true,
    ["Auto Find Mirage"] = false,
    ["Select Weapons Use Skill"] = {
        ["Melee"] = true,
        ["Sword"] = true
    },
    ["Auto Collect Soul Ember"] = false,
    ["Farm Observation"] = false,
    ["Hop Find Berry"] = false,
    ["Auto Trial Draco"] = false,
    ["Hop Server Kitsune Island"] = false,
    ["Tween Until Have Sea Event"] = true,
    ["Attack Darkbeard"] = false,
    ["Auto Finish Train Draco Quest"] = false,
    ["Start Farm"] = false,
    ["Auto Pirate Raid"] = false,
    ["Webhook Destroy IDK"] = false,
    ["Speed Boat Auto Drive"] = 300,
    ["Auto Choose Gears"] = false,
    ["Auto Collect Berry"] = false,
    ["Select Sea Events"] = {
        ["Shark"] = true,
        ["Terrorshark"] = true,
        ["Ship"] = true,
        ["Piranha"] = true
    },
    ["Auto Buy Gear Draco"] = false,
    ["Auto Get Fully Cyborg"] = false,
    ["Value Speed Fly Boat"] = 3,
    ["Auto Elite Hunter"] = false,
    ["Teleport To Kitsune Island"] = false,
    ["ESP Fruit"] = false,
    ["Time Hop Server"] = 10,
    ["Health %"] = 40,
    ["Teleport Acient Clock"] = false,
    ["Select Skills Melee"] = {
        ["X"] = true,
        ["C"] = true,
        ["Z"] = true
    },
    ["Attack Rip Indra"] = false,
    ["Fly Boat"] = false,
    ["Ping Discord"] = false,
    ["Value Collect Chest to Hop"] = 20,
    ["Bring Mob"] = true,
    ["Hop Server Get Ghoul"] = false,
    ["Reset Character Buy Boat"] = true,
    ["Auto Sea Event"] = true,
    ["Auto Stats"] = true,
    ["Teleport To Fruit [ Hop Server ]"] = false,
    ["Select Weapon"] = "Melee",
    ["Auto Get Cyborg Hop Collect Chest"] = false,
    ["Auto Sea Event With Friend"] = false,
    ["Auto Reset Character"] = true,
    ["Auto Third World"] = false,
    ["Auto Chest"] = false,
    ["Auto Raid"] = false,
    ["Auto Buy Legendary Sword"] = false,
    ["Kill Aura With DragonStorm"] = false,
    ["Auto Buy Haki Color"] = false,
    ["Auto Craft Item Shark Anchor"] = true,
    ["Use Skill when Kill Player"] = false,
    ["Remove Notifications"] = false,
    ["Use Click M1 Skull Guitar For Sea Event"] = false,
    ["Auto CDK"] = false,
    ["Auto Crafting Volcanic Magnet"] = false,
    ["Tween Safe if have Items"] = false,
    ["Ignore Collect Bone"] = false,
    ["Input JumpPower"] = 200,
    ["Change JumpPower"] = false,
    ["Value Speed Boat"] = 200
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua"))()
task.wait(8)
-- [[ GENERATED BY Phuocloc - SCRIPT MANAGER ]] --

local Config = {
    Script1_Enabled = true,  -- Bật/Tắt Script 1 (Auto Sea 3)
    Script2_Enabled = true, -- Bật/Tắt Script 2 (Auto Code/Refund/Stats)
    Script3_Enabled = true,  -- Bật/Tắt Script 3 (Remove Fruit)
    DelayBetween = 10        -- Thời gian chờ giữa các script (giây)
}


-- --- SCRIPT 1: AUTO JOIN SEA 3 ---
local function Run_Script1()
    print("🚀 Đang chạy Script 1...")
    repeat task.wait() until game:IsLoaded()
    
    print("⏳ Game đã load. Đang chờ 20 giây cho ổn định...")
    task.wait(15)
    print("🚀 Đã xong chờ đợi. Bắt đầu kiểm tra...")

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Sea3_ID = 7449423635
    local Current_ID = game.PlaceId

    local function TravelToSea3()
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelCaptain", "3")
            ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou") 
        end)
    end

    if Current_ID == Sea3_ID then
        print("✅ Bạn ĐÃ Ở Sea 3. Script dừng hoạt động.")
    else
        print("🌊 Đang ở Sea 1 hoặc 2. Đang yêu cầu Thuyền Trưởng đưa sang Sea 3...")
        task.spawn(function() -- Chạy vòng lặp trong luồng riêng để không kẹt manager
            while game.PlaceId ~= Sea3_ID do
                TravelToSea3()
                print("🔄 Đã gửi lệnh TravelCaptain... Đang chờ game phản hồi...")
                task.wait(6)
            end
        end)
    end
end

-- --- SCRIPT 2: AUTO CODE & REFUND ---
local function Run_Script2()
    print("🚀 Đang chạy Script 2...")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    local codeList = {"KITT_RESET", "Sub2UncleKizaru", "SUB2GAMERROBOT_RESET1"}
    local redeemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Redeem")

    -- 1. Nhập code
    for _, code in ipairs(codeList) do
        task.spawn(function()
            redeemRemote:InvokeServer(code)
        end)
        task.wait(0.5)
    end

    -- 2. Refund & Stats (Chạy trong luồng riêng)
    task.spawn(function()
        task.wait(20)
        local data = player:WaitForChild("Data", 20)
        local stats = data and data:WaitForChild("Stats", 20)

        if stats then
            local fruitLevel = stats:WaitForChild("Sword"):WaitForChild("Level").Value
            if fruitLevel <= 1 then
                local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
                pcall(function() CommF:InvokeServer("redeemRefundPoints", "Refund Points") end)
            end
        end

        -- Auto Stats
        local statsToUpgrade = {"Melee", "Defense", "Sword"}
        while task.wait(0.1) do
            pcall(function()
                if player.Data.Points.Value > 0 then
                    for _, stat in pairs(statsToUpgrade) do
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", stat, 2800)
                    end
                end
            end)
        end
    end)
end

-- --- SCRIPT 3: REMOVE FRUIT ---
local function Run_Script3()
    print("🚀 Đang chạy Script 3...")
    task.spawn(function()
        task.wait(20)
        game.ReplicatedStorage.Remotes.CommF_:InvokeServer("RemoveFruit", "Beli")
        print("✅ Đã thực hiện Remove Fruit.")
    end)
end

-- ==========================================
-- TRÌNH QUẢN LÝ CHÍNH (MAIN CONTROLLER)
-- ==========================================

-- Chạy Script 1
if Config.Script1_Enabled then
    Run_Script1()
    print("⏱️ Chờ " .. Config.DelayBetween .. "s trước khi sang script tiếp theo...")
    task.wait(Config.DelayBetween)
end

-- Chạy Script 2
if Config.Script2_Enabled then
    Run_Script2()
    print("⏱️ Chờ " .. Config.DelayBetween .. "s trước khi sang script tiếp theo...")
    task.wait(Config.DelayBetween)
end

-- Chạy Script 3
if Config.Script3_Enabled then
    Run_Script3()
end

print("🏁 Tất cả script đã được kích hoạt theo cấu hình.")
task.wait(10)
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game:GetService("Players").LocalPlayer

-- --- CẤU HÌNH THỜI GIAN CHỜ ---
local WAIT_LOAD_TIME = 20 -- Thời gian chờ game load hẳn (giây)

-- Thông báo bắt đầu chờ
warn("Script đã kích hoạt! Đang chờ " .. WAIT_LOAD_TIME .. " giây để game load dữ liệu...")
task.wait(WAIT_LOAD_TIME) 
warn("Đã hết thời gian chờ. Bắt đầu kiểm tra item!")

-- --- KHAI BÁO BIẾN ---
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local plr = Players.LocalPlayer
local CommF_ = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

local TARGET_MAIN = "Terror Jaw"            -- Mục tiêu chính (Ưu tiên 1)
local TARGET_SUB = "Shark Tooth Necklace"   -- Mục tiêu phụ (Ưu tiên 2)

-- --- CÁC HÀM HỖ TRỢ (GIỮ NGUYÊN) ---
local function norm(s)
    return tostring(s or ""):lower():gsub("%s+", "")
end

local function findItemByName(inv, target)
    if typeof(inv) ~= "table" then return nil end
    for _, it in pairs(inv) do
        if typeof(it) == "table" then
            local name = it.Name
            if name and norm(name) == norm(target) then
                return it
            end
        end
    end
    local function walk(node)
        if typeof(node) ~= "table" then return nil end
        if node.Name and norm(node.Name) == norm(target) then
            return node
        end
        for _, v in pairs(node) do
            if typeof(v) == "table" then
                local got = walk(v)
                if got then return got end
            end
        end
        return nil
    end
    return walk(inv)
end

local function LoadItem(networkedUID)
    local ok, result = pcall(function()
        return CommF_:InvokeServer("LoadItem", networkedUID)
    end)
    if not ok then
        warn("[LoadItem] Failed:", result)
        return nil
    end
    warn("[LoadItem] Success:", result)
    return result
end

-- --- LOGIC CHÍNH ---

local function AutoEquipLogic()
    -- CHECK 1: Nếu nhân vật đã đeo Terror Jaw rồi thì dừng luôn
    -- Check lại Character vì sau 20s có thể nhân vật đã reset
    if plr.Character and plr.Character:FindFirstChild(TARGET_MAIN) then
        warn("Bạn đã trang bị " .. TARGET_MAIN .. ". Script dừng hoạt động.")
        return 
    end

    while true do
        -- Lấy dữ liệu túi đồ
        local ok, inv = pcall(function()
            return CommF_:InvokeServer("getInventory")
        end)

        if ok and typeof(inv) == "table" then
            
            -- CHECK 2: Tìm Terror Jaw (Mục tiêu tối thượng)
            local terrorJawItem = findItemByName(inv, TARGET_MAIN)
            
            if terrorJawItem then
                local uid = terrorJawItem.NetworkedUID
                if uid and uid ~= "" then
                    warn(">>> Tìm thấy " .. TARGET_MAIN .. "! Đang trang bị...")
                    LoadItem(uid)
                    warn(">>> Đã trang bị xong " .. TARGET_MAIN .. ". Script kết thúc.")
                    break -- Dừng script
                end
            else
                -- Nếu KHÔNG thấy Terror Jaw, kiểm tra Shark Tooth Necklace
                local sharkItem = findItemByName(inv, TARGET_SUB)
                
                -- Kiểm tra xem đang đeo Shark Tooth chưa để tránh spam
                local isWearingShark = plr.Character and plr.Character:FindFirstChild(TARGET_SUB)
                
                if sharkItem and not isWearingShark then
                    local uid = sharkItem.NetworkedUID
                    if uid and uid ~= "" then
                        warn("Chưa có Terror Jaw. Trang bị tạm: " .. TARGET_SUB)
                        LoadItem(uid)
                    end
                elseif isWearingShark then
                    -- Đã đeo Shark Tooth, im lặng đợi Terror Jaw
                else
                    warn("Chưa tìm thấy cả 2 item. Đang tìm kiếm...")
                end
            end
        else
            warn("Lỗi lấy inventory (Server lag?), thử lại sau...")
        end

        -- CHECK 3: Delay 30 giây
        warn("Chờ 30 giây check lại...")
        task.wait(30)
    end
end

-- Chạy hàm logic trong luồng riêng để không bị treo script khác
spawn(AutoEquipLogic)
task.wait(10)
-- Đợi game load hoàn tất mới bắt đầu chạy script
repeat task.wait() until game:IsLoaded()

--// CONFIG
local Config = {
    Sword = "Yama" -- Điền tên thanh kiếm vào đây
}

--// Service
local Players = game:GetService("Players")
local Rep = game:GetService("ReplicatedStorage")

-- Đảm bảo lấy được LocalPlayer trong môi trường Autoexec
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.5)
    LocalPlayer = Players.LocalPlayer
end

--// Các remote hỗ trợ load item
local function getRemotes()
    return Rep:FindFirstChild("Remotes") or Rep
end

local tryRemotesList = {"LoadItem", "LoadGear", "EquipItem", "Load", "LoadFromInv", "LoadItemFromInv", "GiveItem"}

-- Hàm gọi server để lấy kiếm
local function tryLoadSword(name)
    local Remotes = getRemotes()
    for _, r in ipairs(tryRemotesList) do
        local ok = pcall(function()
            local CommF = Remotes:FindFirstChild("CommF_")
            if CommF and CommF.InvokeServer then
                CommF:InvokeServer(r, name)
            elseif Remotes:FindFirstChild(r) and Remotes[r].InvokeServer then
                Remotes[r]:InvokeServer(r, name)
            end
        end)
        if ok then return true end
    end
    return false
end

-- Hàm cầm kiếm lên tay
local function equipToHand(name)
    local char = LocalPlayer.Character
    if not char then return false end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return false end
    
    local tool = backpack:FindFirstChild(name) or char:FindFirstChild(name)
    
    if tool and char:FindFirstChild("Humanoid") then
        pcall(function() 
            char.Humanoid:EquipTool(tool) 
        end)
        return true
    end
    return false
end

--// HÀM CHÍNH CHO AUTOEXEC
local function startScript()
    print("🚀 [Autoexec] Script đã tải. Đang chờ 40 giây để trang bị...")
    task.wait(40) 

    if Config.Sword == "" then 
        print("⚠️ [Autoexec] Chưa nhập tên kiếm!")
        return 
    end

    -- Đợi nhân vật xuất hiện hoàn toàn
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    task.wait(2) -- Chờ thêm 2s để chắc chắn dữ liệu nhân vật đã đồng bộ

    if not char:FindFirstChild(Config.Sword) then
        print("⚔️ [Autoexec] Đang lấy kiếm: " .. Config.Sword)
        
        tryLoadSword(Config.Sword)
        task.wait(1) -- Chờ server xử lý việc bỏ kiếm vào Backpack
        
        local success = equipToHand(Config.Sword)
        if success then
            print("✅ [Autoexec] Đã trang bị thành công!")
        else
            print("❌ [Autoexec] Thất bại. Có thể kiếm không có trong kho đồ.")
        end
    else
        print("✅ [Autoexec] Kiếm đã được trang bị sẵn.")
    end
end

-- Chạy hàm chính
task.spawn(startScript)
task.wait(10)
-- Cấu hình
task.wait(50)
local TIME_LIMIT = 230 -- 5 phút
local CHECK_INTERVAL = 10 -- Kiểm tra mỗi 10 giây
local DISTANCE_THRESHOLD = 1 -- Ngưỡng khoảng cách tối thiểu để coi là có di chuyển

-- Khởi tạo biến
local lastPosition = nil
local stuckTimer = 0
local player = game.Players.LocalPlayer

print("Hệ thống Anti-Stuck (Shutdown Mode) đã sẵn sàng...")

task.spawn(function()
    while task.wait(CHECK_INTERVAL) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local currentPosition = character.HumanoidRootPart.Position
            
            if lastPosition then
                local distance = (currentPosition - lastPosition).Magnitude
                
                if distance < DISTANCE_THRESHOLD then
                    stuckTimer = stuckTimer + CHECK_INTERVAL
                    -- In ra console để bạn dễ theo dõi nếu cần
                    print("Cảnh báo kẹt: " .. stuckTimer .. "/" .. TIME_LIMIT)
                else
                    stuckTimer = 0
                end
            end
            
            lastPosition = currentPosition
            
            -- Nếu kẹt quá 5 phút, thực hiện chuỗi lệnh shutdown
            if stuckTimer >= TIME_LIMIT then
                warn("Phát hiện kẹt quá lâu! Đang thực hiện chuỗi lệnh shutdown...")
                
                -- Thử các cách shutdown khác nhau theo yêu cầu của bạn
                pcall(function() game:Shutdown() end)
                task.wait(1)
                
                pcall(function() player:Kick("Change acc") end)
                task.wait(1)
                
                pcall(function()
                    local TeleportService = game:GetService("TeleportService")
                    TeleportService:Teleport(game.PlaceId)
                end)
                
                -- Ngắt vòng lặp sau khi đã thực hiện xong các lệnh trên
                break 
            end
        end
    end
end)
    print("ĐANG CHẠY...")
end

local success, result, timeLeft = CheckAuth()

if not success then
    game.Players.LocalPlayer:Kick("\n[HỆ THỐNG KEY ONLINE]\n" .. result)
else
    print("------------------------------------------")
    print("KEY: " .. Config.MyKey)
    print("HẠN DÙNG: " .. FormatTime(timeLeft))
    print("SỐ TAB: " .. result .. "/" .. Config.MaxTabs)
    print("------------------------------------------")

    StartFarmScript()
    
    task.spawn(function()
        while task.wait(5) do
            local ok, msg = CheckAuth()
            if not ok then
                game.Players.LocalPlayer:Kick("\n[CẢNH BÁO]\n" .. msg)
                break
            end
        end
    end)
end
