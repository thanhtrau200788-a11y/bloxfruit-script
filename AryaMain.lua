task.wait(2)
repeat task.wait() until game:IsLoaded()

print("⏳ Game đã load xong. Đang chờ thêm 10 giây để ổn định tài nguyên...")
task.wait(10)
print("🚀 Bắt đầu chạy Script!")
-- ==========================================

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")

-- Đảm bảo LocalPlayer đã sẵn sàng
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    LocalPlayer = Players.LocalPlayer
    task.wait(0.5)
end
local plr = LocalPlayer

-- ==========================================
-- JOIN MARINES
-- ==========================================
print("⚓ Đang tiến hành vào phe Marine trước...")

local targetTeam = "Marines"
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

while true do
    if plr.Team == nil or plr.Team.Name ~= targetTeam then
        pcall(function()
            remote:InvokeServer("SetTeam", targetTeam)
        end)
    else
        break
    end
    task.wait(1)
end

print("✅ Đã xác nhận: Bạn đang ở phe Marine!")
task.wait(2)

-- ==========================================
-- KIỂM TRA SHARKMAN KARATE
-- ==========================================
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

-- ==========================================
-- HÀM BAY MỚI: safeFly (Chống nước biển + Noclip)
-- ==========================================
local noclipConnection
local speed = 320

local function enableNoclip(character)
    noclipConnection = RunService.Stepped:Connect(function()
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

local function safeFly(targetPos)
    -- Lấy lại character & rootPart tươi mỗi lần bay (tránh stale reference)
    local character = plr.Character or plr.CharacterAdded:Wait()
    local rootPart  = character:WaitForChild("HumanoidRootPart")

    enableNoclip(character)

    -- Tạo BodyVelocity giữ nhân vật lơ lửng trong suốt hành trình
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity  = Vector3.new(0, 0, 0)
    bv.Parent    = rootPart

    -- Nếu đang dưới nước (Y < 50), ngoi lên độ cao an toàn trước
    if rootPart.Position.Y < 50 then
        local safeHeight = 350
        local ascendPos  = Vector3.new(rootPart.Position.X, safeHeight, rootPart.Position.Z)
        local distUp     = (rootPart.Position - ascendPos).Magnitude
        local timeUp     = distUp / speed

        local tweenUp = TweenService:Create(
            rootPart,
            TweenInfo.new(timeUp, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            {CFrame = CFrame.new(ascendPos)}
        )
        tweenUp:Play()
        tweenUp.Completed:Wait() -- Chờ ngoi lên xong mới đi tiếp
    end

    -- Bay đến đích chính
    local distance  = (rootPart.Position - targetPos).Magnitude
    local tweenTime = distance / speed

    local tweenMain = TweenService:Create(
        rootPart,
        TweenInfo.new(tweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
        {CFrame = CFrame.new(targetPos)}
    )
    tweenMain:Play()
    tweenMain.Completed:Wait() -- ✅ FIX: :Wait() thay vì :Connect() → đợi bay xong mới tiếp tục

    -- Dọn dẹp sau khi đến nơi
    disableNoclip()
    bv:Destroy()
end

-- ==========================================
-- MUA SHARKMAN KARATE NẾU CHƯA CÓ
-- ==========================================
local npcPos = Vector3.new(-4972.51611328125, 314.8302307128906, -3222.7587890625)

if hasSharkmanKarate() then
    print("✅ Hệ thống xác nhận: Đã có Sharkman Karate. Khởi động BananaHub ngay...")
else
    print("❌ Chưa thấy Sharkman Karate. Đang chuẩn bị đi mua...")

    safeFly(npcPos)

    print("📍 Đã đến nơi, bắt đầu spam mua...")

    while not hasSharkmanKarate() do
        pcall(function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.CFrame = CFrame.new(npcPos)
            end
            ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate")
        end)
        task.wait(2)
    end

    print("✅ Mua Sharkman Karate thành công!")
end

-- =========================
-- RUN BANANAHUB
-- =========================
if getgenv().tmconfig and getgenv().tmconfig.chuoikey then
    getgenv().Key = getgenv().tmconfig.chuoikey
else
    getgenv().Key = "" -- Key dự phòng nếu quên điền ở Executor
end

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
    ["Input WalkSpeed"] = 200,
    ["Select Zone"] = "Zone 6",
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
    ["Auto Trade Bone"] = true,
    ["Teleport Boat Other CFrame if Rough Sea"] = true,
    ["Auto Turn On V3 Near Door"] = false,
    ["Auto Turn On Buso"] = true,
    ["White Screen"] = true,
    ["Distance Farm Aura"] = 300,
    ["Auto UP Observation V2"] = false,
    ["Attack No Animation "] = true,
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
        ["F"] = false
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
    ["Tween Until Have Sea Event"] = true,
    ["Attack Darkbeard"] = false,
    ["Auto Finish Train Draco Quest"] = false,
    ["Speed Boat Auto Drive"] = 300,
    ["Reset Teleport"] = true,
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
    ["Auto Buy Legendary Sword"] = false,
    ["Auto Craft Item Shark Anchor"] = true,
    ["Use Skill when Kill Player"] = false,
    ["Remove Notifications"] = false,
    ["Use Click M1 Skull Guitar For Sea Event"] = false,
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
