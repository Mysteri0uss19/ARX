if not game:IsLoaded() then
    game.Loaded:Wait()
end

if game.PlaceId ~= 18923620224 then
    warn("Failed to load: This script only supports Anime Warriors III")
    return
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if not WindUI then return end

local Players             = game:GetService("Players")
local Workspace           = game:GetService("Workspace")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local TeleportService     = game:GetService("TeleportService")
local VirtualUser         = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local CoreGui             = game:GetService("CoreGui")
local HttpService         = game:GetService("HttpService")

local player    = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local EnemiesFolder = Workspace:WaitForChild("World"):WaitForChild("Enemies")

-- ============================================================
--  SAVE CONFIG
-- ============================================================
local CONFIG_FOLDER = "GhostHub"
local CONFIG_FILE   = "GhostHub/AW3_config.json"

local Options = {
    ToggleUIKey        = "RightControl",
    AntiAFK            = false,
    AutoRejoin         = false,
    SelectedEggName    = "Nemak",
    SelectedBossNames  = {},
    SelectedEnemyNames = {},
    AutoFarm           = false,
    AutoFarmBoss       = false,
    AutoEgg            = false,
    AutoEquip          = false,
    AutoWeapon         = false,
    AutoSendUnit       = false,
    SendAllUnits       = false,
    NoRetreat          = false,
    AutoGauntlet       = false,
    AutoSelectCard     = false,
    AutoLeaveGauntlet  = false,
    GauntletMaxFloor   = 6,
    CardPriorityList   = {},
    SelectedQuestId    = "",
    AutoQuest          = false,
    GauntletTeamSlot   = "1",
    RaidTeamSlot       = "1",
}

local function SaveConfig()
    pcall(function()
        if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
        writefile(CONFIG_FILE, HttpService:JSONEncode(Options))
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile(CONFIG_FILE) then
            local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
            for k, v in pairs(data) do
                Options[k] = v
            end
        end
    end)
end

LoadConfig()

-- ============================================================
--  REMOTES
-- ============================================================
local RemoContainer = ReplicatedStorage
    :WaitForChild("rbxts_include")
    :WaitForChild("node_modules")
    :WaitForChild("@rbxts")
    :WaitForChild("remo")
    :WaitForChild("src")
    :WaitForChild("container")

local SendUnitRemote       = RemoContainer:WaitForChild("enemies.sendAndRetreat")
local OpenEggRemote        = RemoContainer:WaitForChild("eggs.open")
local UnequipAllRemote     = RemoContainer:WaitForChild("warriors.unequipAll")
local EquipBestRemote      = RemoContainer:WaitForChild("warriors.equipBest")
local SetStateRemote       = RemoContainer:WaitForChild("automation.setState")
local SettingsSetRemote    = RemoContainer:WaitForChild("settings.set")
local ToolbarEquipRemote   = RemoContainer:WaitForChild("toolbar.equip")
local GauntletCreateRemote = RemoContainer:WaitForChild("gauntlet.create")
local GauntletStartRemote  = RemoContainer:WaitForChild("lobbies.start")
local GauntletCardsRemote  = RemoContainer:WaitForChild("gauntlet.displayCards")
local GauntletVoteRemote   = RemoContainer:WaitForChild("gauntlet.voteCard")
local GauntletClearRemote  = RemoContainer:WaitForChild("gauntlet.clearButton")
local QuestClaimRemote     = RemoContainer:WaitForChild("quests.claimPart")
local BossRaidCreateRemote = RemoContainer:WaitForChild("bossRaids.create")
local BossRaidLeaveRemote  = RemoContainer:WaitForChild("bossRaids.leaveRaid")
local TeamsLoadRemote      = RemoContainer:WaitForChild("warriors.teams.load")

pcall(function()
    SettingsSetRemote:FireServer("enemy_render_distance", "500 Studs")
end)

-- ============================================================
--  TEAM SLOTS
-- ============================================================
local TEAM_SLOTS = {"1","2","3","4","5","6","7","8"}

local gauntletTeamSlot = Options.GauntletTeamSlot or "1"
local raidTeamSlot     = Options.RaidTeamSlot     or "1"

local function loadTeam(slot)
    pcall(function()
        TeamsLoadRemote:FireServer(tostring(slot))
    end)
end

-- ============================================================
--  CONTINUE BUTTON DETECTION
-- ============================================================
local lastRaidContinueFire = 0

local function isGuiActuallyVisible(guiObject)
    local current = guiObject
    while current and current ~= PlayerGui and current ~= CoreGui do
        if current:IsA("GuiObject") and current.Visible == false then
            return false
        end
        if current:IsA("ScreenGui") and current.Enabled == false then
            return false
        end
        current = current.Parent
    end
    return true
end

local function isRaidContinueVisible()
    for _, rootGui in ipairs({ PlayerGui, CoreGui }) do
        for _, gui in ipairs(rootGui:GetDescendants()) do
            if (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Visible and isGuiActuallyVisible(gui) then
                local text = tostring(gui.Text or ""):lower()
                if text:find("continue", 1, true) then
                    return true
                end
            end
        end
    end
    return false
end

local function fireRaidContinueIfVisible()
    if not isRaidContinueVisible() then return false end
    if tick() - lastRaidContinueFire >= 1.5 then
        lastRaidContinueFire = tick()
        pcall(function()
            for _, root in ipairs({ PlayerGui, CoreGui }) do
                for _, gui in ipairs(root:GetDescendants()) do
                    if (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Visible and isGuiActuallyVisible(gui) then
                        local text = tostring(gui.Text or ""):lower()
                        if text:find("continue") then
                            -- คลิกปุ่มโดยตรง
                            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                                pcall(function() gui:Activate() end)
                            end
                            -- หา parent ที่เป็นปุ่ม
                            local btn = gui
                            while btn and btn ~= root do
                                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                                    pcall(function() btn:Activate() end)
                                    break
                                end
                                btn = btn.Parent
                            end
                            local targetUI = (btn and btn ~= root) and btn or gui
                            local absPos   = targetUI.AbsolutePosition
                            local absSize  = targetUI.AbsoluteSize
                            local clickX   = absPos.X + (absSize.X / 2)
                            local clickY   = absPos.Y + (absSize.Y / 2) + 58
                            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true,  game, 1)
                            task.wait(0.1)
                            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
                            VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.Return, false, game)
                            task.wait(0.05)
                            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                            break
                        end
                    end
                end
            end
        end)
        pcall(function() BossRaidLeaveRemote:FireServer() end)
    end
    return true
end

-- ============================================================
--  CARD DATA
-- ============================================================
local ALL_CARDS    = {}
local CARD_WEIGHTS = {}

pcall(function()
    local gauntletModule = require(
        ReplicatedStorage
            :WaitForChild("src")
            :WaitForChild("common")
            :WaitForChild("content")
            :WaitForChild("gamemodes")
            :WaitForChild("gauntlet")
    )
    local cardsPool = gauntletModule
        and gauntletModule.gauntletContent
        and gauntletModule.gauntletContent["Normal"]
        and gauntletModule.gauntletContent["Normal"].cardsPool
    if cardsPool then
        local seen = {}
        for cardName, weight in pairs(cardsPool) do
            local baseName = cardName:gsub("%s+[IVX]+$", "")
            if not seen[baseName] then
                seen[baseName] = true
                table.insert(ALL_CARDS, baseName)
                CARD_WEIGHTS[baseName] = weight
            end
        end
        table.sort(ALL_CARDS)
    end
end)

if #ALL_CARDS == 0 then
    ALL_CARDS = {
        "All or Nothing","Battle Momentum","Boss Killer","Cursed Greed",
        "Elite Calling","Endless Horde","Fate Rewrite","Glass Cannon",
        "Kingslayer","Lucky Blessing","Overflowing Wealth","Path of the Conqueror",
        "Reinforcements","Sacrificial Offering","Time Rush","Warrior Blessing",
    }
end

-- ============================================================
--  RAID CONFIG
-- ============================================================
local RaidConfig = {}

pcall(function()
    local raidModule = require(
        ReplicatedStorage
            :WaitForChild("src")
            :WaitForChild("common")
            :WaitForChild("content")
            :WaitForChild("gamemodes")
            :WaitForChild("raids")
    )
    local content = raidModule and raidModule.raidsContent
    if content then
        for raidName, data in pairs(content) do
            local cfg = data.config or {}
            RaidConfig[raidName] = {
                light = cfg.lightEnemy or {},
                tank  = cfg.tankEnemy  or nil,
            }
        end
    end
end)

local function ensureRaidConfig(raidName)
    if RaidConfig[raidName] then return end
    local fallback = {
        ["Destroyed Nemak"] = { light = {"Barta", "Jays"},     tank = nil          },
        ["Red Ribbon Base"]  = { light = {"Plasma"},            tank = nil          },
        ["Clan Hideout"]     = { light = {"Itochi (Crow)"},     tank = nil          },
        ["Desert Kingdom"]   = { light = {"Matsui", "Ibiboro"}, tank = "Water Tank" },
    }
    RaidConfig[raidName] = fallback[raidName] or { light = {}, tank = nil }
end

-- ============================================================
--  RAID PORTAL SIGN PATHS
-- ============================================================
local RaidPortalPaths = {
    ["Desert Kingdom"]  = { "Sky Island",   "Components", "Portal", "sign", "SurfaceGui", "TextLabel" },
    ["Clan Hideout"]    = { "Sand Village",  "Components", "Portal", "sign", "SurfaceGui", "TextLabel" },
    ["Destroyed Nemak"] = { "Planet Nemak",  "Components", "Portal", "sign", "SurfaceGui", "TextLabel" },
    ["Red Ribbon Base"] = { "Future City",   "Components", "Portal", "sign", "SurfaceGui", "TextLabel" },
}

local function getRaidPortalLabel(raidName)
    local pathParts = RaidPortalPaths[raidName]
    if not pathParts then return nil end
    local map = Workspace:WaitForChild("World", 3):FindFirstChild("Map")
    if not map then return nil end
    local node = map
    for _, part in ipairs(pathParts) do
        node = node:FindFirstChild(part)
        if not node then return nil end
    end
    return node
end

local function getInstanceCFrame(instance)
    if not instance then return nil end
    if instance:IsA("BasePart") then return instance.CFrame end
    if instance:IsA("Model") then
        local ok, cf = pcall(function() return instance:GetPivot() end)
        if ok and cf then return cf end
        if instance.PrimaryPart then return instance.PrimaryPart.CFrame end
    end
    for _, child in ipairs(instance:GetDescendants()) do
        if child:IsA("BasePart") then return child.CFrame end
        if child:IsA("Model") then
            local ok, cf = pcall(function() return child:GetPivot() end)
            if ok and cf then return cf end
            if child.PrimaryPart then return child.PrimaryPart.CFrame end
        end
    end
    return nil
end

local function getRaidPortalObject(raidName)
    local pathParts = RaidPortalPaths[raidName]
    if not pathParts then return nil end
    local map = Workspace:WaitForChild("World", 3):FindFirstChild("Map")
    if not map then return nil end
    local node = map
    for i = 1, math.min(3, #pathParts) do
        node = node:FindFirstChild(pathParts[i])
        if not node then return nil end
    end
    return node
end

local function getRaidSignObject(raidName)
    local pathParts = RaidPortalPaths[raidName]
    if not pathParts then return nil end
    local map = Workspace:WaitForChild("World", 3):FindFirstChild("Map")
    if not map then return nil end
    local node = map
    for i = 1, math.min(4, #pathParts) do
        node = node:FindFirstChild(pathParts[i])
        if not node then return nil end
    end
    return node
end

local function getRaidPortalCFrame(raidName)
    local sign = getRaidSignObject(raidName)
    local cf = getInstanceCFrame(sign)
    if cf then return cf end
    local portal = getRaidPortalObject(raidName)
    cf = getInstanceCFrame(portal)
    if cf then return cf end
    local pathParts = RaidPortalPaths[raidName]
    local worldName = pathParts and pathParts[1]
    local locations = Workspace:FindFirstChild("World")
        and Workspace.World:FindFirstChild("Teleports")
        and Workspace.World.Teleports:FindFirstChild("Locations")
    local worldLocation = locations and worldName and locations:FindFirstChild(worldName)
    cf = getInstanceCFrame(worldLocation)
    if cf then return cf end
    local node = getRaidPortalLabel(raidName)
    while node do
        cf = getInstanceCFrame(node)
        if cf then return cf end
        node = node.Parent
    end
    return nil
end

local function teleportToRaidPortal(raidName)
    local cf = getRaidPortalCFrame(raidName)
    if not cf then return false end
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp  = char and char:WaitForChild("HumanoidRootPart", 3)
    if not hrp then return false end
    local targetPos = cf.Position + Vector3.new(0, 5, 8)
    hrp.CFrame = CFrame.lookAt(targetPos, cf.Position)
    hrp.AssemblyLinearVelocity  = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    return true
end

local function getRaidStatusFromPortal(raidName)
    local node = getRaidPortalLabel(raidName)
    if not node then return nil end
    local text  = node.Text or ""
    local plain = text:gsub("<[^>]+>", ""):gsub("^%s+", ""):gsub("%s+$", "")
    return plain:match("[^\n]+$") or plain
end

local function getRaidCooldownSecondsFromStatus(status)
    if type(status) ~= "string" then return nil end
    local lower = status:lower()
    if not lower:find("open in") then return nil end
    local minutes, seconds = lower:match("(%d+)%s*:%s*(%d+)")
    if minutes and seconds then
        return (tonumber(minutes) or 0) * 60 + (tonumber(seconds) or 0)
    end
    local onlySeconds = lower:match("open in:%s*(%d+)")
    if onlySeconds then return tonumber(onlySeconds) end
    return nil
end

local function isRaidOpen(raidName)
    local pathParts = RaidPortalPaths[raidName]
    if not pathParts then return true end
    local ok, result = pcall(function()
        local plain = getRaidStatusFromPortal(raidName)
        if not plain then return nil end
        if plain:lower():find("open in") then return false end
        return plain:match("%f[%a]Open%f[%A]") ~= nil
    end)
    if ok and result ~= nil then return result end
    return false
end

local function getRaidStatusText(raidName)
    local pathParts = RaidPortalPaths[raidName]
    if not pathParts then return "[Unknown]" end
    local ok, result = pcall(function()
        return getRaidStatusFromPortal(raidName)
    end)
    if ok and result then return result end
    return "?"
end

local function checkRaidOpenAtPortal(raidName)
    local teleported = false
    pcall(function()
        teleported = teleportToRaidPortal(raidName)
    end)
    task.wait(0.75)
    local status
    local open = false
    for _ = 1, 8 do
        status = getRaidStatusText(raidName)
        open   = isRaidOpen(raidName)
        if open or (type(status) == "string" and status ~= "?") then break end
        task.wait(0.5)
    end
    return open, status, getRaidCooldownSecondsFromStatus(status), teleported
end

-- ============================================================
--  WORLD DATA
-- ============================================================
local WorldsData = {}

pcall(function()
    local worldsModule = require(
        ReplicatedStorage
            :WaitForChild("src")
            :WaitForChild("common")
            :WaitForChild("content")
            :WaitForChild("world")
            :WaitForChild("worlds")
    )
    if worldsModule and worldsModule.worldsContent then
        WorldsData = worldsModule.worldsContent
    end
end)

if next(WorldsData) == nil then
    WorldsData = {
        ["Planet Nemak"] = {
            displayName = "Planet Nemak", order = 1,
            baseMaterial = "Dragon Fragment", lesserMaterial = "Magic Bean",
            quest = "PlanetNemak", eggs = { "Nemak" }, raids = { "Destroyed Nemak" },
            enemies = { normal = { "Dodo", "Carbon", "Barta", "Jays" }, miniBoss = { "Genyu" }, boss = { "Freeze" } },
        },
        ["Future City"] = {
            displayName = "Future City", order = 2,
            baseMaterial = "Capsule Fragment", lesserMaterial = "Capsule",
            quest = "FutureCity", eggs = { "Corps" }, raids = { "Red Ribbon Base" },
            enemies = { normal = { "Cel Jr.", "Android 19", "Android 20", "Android 18" }, miniBoss = { "Android 17" }, boss = { "Cel (Prime)" } },
        },
        ["Sand Village"] = {
            displayName = "Sand Village", order = 3,
            baseMaterial = "Sand Fragment", lesserMaterial = "Headband",
            quest = "SandVillage", eggs = { "Ninja" }, raids = { "Clan Hideout" },
            enemies = { normal = { "Sand Ninja", "Sand Elder", "Puppeteer", "Temmuri" }, miniBoss = { "Gurra" }, boss = { "Orochi (Disguised)" } },
        },
        ["Sky Island"] = {
            displayName = "Sky Island", order = 4,
            baseMaterial = "Ancient Tablet Fragment", lesserMaterial = "Sky Fish",
            quest = "SkyIslandQuest", eggs = { "Sky" }, raids = { "Desert Kingdom" },
            enemies = { normal = { "Sky Guard", "Saturn", "Geda", "Shuri" }, miniBoss = { "Ohem" }, boss = { "Enil" } },
        },
    }
end

local function getWorldNames()
    local names = {}
    for name, data in pairs(WorldsData) do
        table.insert(names, { name = data.displayName or name, order = data.order or 999 })
    end
    table.sort(names, function(a, b) return a.order < b.order end)
    local result = {}
    for _, entry in ipairs(names) do table.insert(result, entry.name) end
    return result
end

local function getWorldData(worldName)
    if WorldsData[worldName] then return WorldsData[worldName] end
    for _, data in pairs(WorldsData) do
        if data.displayName == worldName then return data end
    end
    return nil
end

-- ============================================================
--  QUEST DATA
-- ============================================================
local QuestData     = {}
local QuestLabelMap = {}

local function buildQuestLabelMap()
    QuestLabelMap = {}
    local orderedIds = {}
    for id in pairs(QuestData) do table.insert(orderedIds, id) end
    table.sort(orderedIds)
    for _, id in ipairs(orderedIds) do
        local quest = QuestData[id]
        if quest and quest.parts then
            for partIndex, part in ipairs(quest.parts) do
                local label = part.title or (id .. " Part " .. partIndex)
                if QuestLabelMap[label] then
                    label = label .. " (" .. (quest.title or id) .. ")"
                end
                QuestLabelMap[label] = { questId = id, partIndex = partIndex }
            end
        end
    end
end

task.spawn(function()
    local ok, questModule = pcall(function()
        return require(
            ReplicatedStorage
                :WaitForChild("src"):WaitForChild("common")
                :WaitForChild("content"):WaitForChild("world")
                :WaitForChild("quests")
        )
    end)
    if ok and questModule and questModule.questsContent then
        QuestData = questModule.questsContent
        buildQuestLabelMap()
    end
end)

local function getQuestList()
    local entries    = {}
    local orderedIds = {}
    for id in pairs(QuestData) do table.insert(orderedIds, id) end
    table.sort(orderedIds)
    for _, id in ipairs(orderedIds) do
        local quest = QuestData[id]
        if quest and quest.parts then
            for partIndex, part in ipairs(quest.parts) do
                local label   = part.title or (id .. " Part " .. partIndex)
                local tempMap = {}
                if tempMap[label] then label = label .. " (" .. (quest.title or id) .. ")" end
                tempMap[label] = true
                table.insert(entries, label)
            end
        end
    end
    if #entries == 0 then entries = {"(No quests found)"} end
    return entries
end

local function getQuestInfoFromLabel(label)
    local info = QuestLabelMap[label]
    if not info then return nil, nil, {} end
    local quest = QuestData[info.questId]
    if not quest or not quest.parts then return nil, nil, {} end
    local part = quest.parts[info.partIndex]
    if not part or not part.tasks then return nil, nil, {} end
    local tasks = {}
    for _, t in ipairs(part.tasks) do
        if t.tracker == "enemy-kills" and t.enemy then
            table.insert(tasks, { enemy = t.enemy, required = t.required or 1 })
        end
    end
    return info.questId, info.partIndex, tasks
end

-- ============================================================
--  STATE
-- ============================================================
local selectedEnemyNames  = Options.SelectedEnemyNames or {}
local selectedBossNames   = Options.SelectedBossNames  or {}
local isAutoFarm          = false
local isAutoSnipeBoss     = false
local isAutoEgg           = false
local selectedEggName     = Options.SelectedEggName    or "Nemak"
local isAutoEquip         = false
local isAutoWeapon        = false
local isAutoGauntlet      = false
local gauntletMaxFloor    = Options.GauntletMaxFloor   or 6
local cardPriorityList    = Options.CardPriorityList   or {}
local isGauntletFarm      = false
local isGauntletAutoCard  = false
local isGauntletAutoLeave = false
local isCardSelecting     = false
local isAutoQuest         = false
local selectedQuestId     = Options.SelectedQuestId    or ""

local BossList = {
    "Genyu","Freeze","Freeze (2nd)","Android 17",
    "Cel (Prime)","Super Cel (Prime)","Gurra",
    "Orochi (Disguised)","Orochi","Ohem","Enil","Enil (Storm)"
}

local EggsFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Eggs")

-- ============================================================
--  HELPERS — NPC
-- ============================================================
local function findQuestNPC(questId)
    local quest = QuestData[questId]
    if not quest then return nil end
    local world = Workspace:FindFirstChild("World")
    if not world then return nil end
    local npcNames = {
        PlanetNemak       = { "Carrot", "Quest Giver", "NPC" },
        FutureCity        = { "Rosha", "Master Rosha", "Quest Giver", "NPC" },
        SandVillage       = { "Kokoshi", "Quest Giver", "NPC" },
        SkyIslandQuest    = { "Robin", "Quest Giver", "NPC" },
        SingularityQuest  = { "Singularity", "Quest Giver", "NPC" },
        SingularityQuest2 = { "Singularity", "Quest Giver", "NPC" },
        KokoshiWaystone   = { "Kokoshi", "Quest Giver", "NPC" },
        RobinWaystone     = { "Robin", "Quest Giver", "NPC" },
        CarrotWaystone    = { "Carrot", "Quest Giver", "NPC" },
        RoshaWaystone     = { "Rosha", "Master Rosha", "Quest Giver", "NPC" },
    }
    local targets = npcNames[questId] or { "Quest Giver", "NPC" }
    local function searchIn(folder)
        for _, obj in ipairs(folder:GetChildren()) do
            for _, name in ipairs(targets) do
                if obj.Name:lower():find(name:lower()) then return obj end
            end
            if obj:IsA("Folder") or obj:IsA("Model") then
                local found = searchIn(obj)
                if found then return found end
            end
        end
        return nil
    end
    return searchIn(world)
end

local function goToNPCAndClaim(questId)
    local npc = findQuestNPC(questId)
    if npc then
        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local npcCF
            if npc:IsA("Model") then
                if npc.PrimaryPart then npcCF = npc.PrimaryPart.CFrame
                else pcall(function() npcCF = npc:GetPivot() end) end
            elseif npc:IsA("BasePart") then
                npcCF = npc.CFrame
            end
            if npcCF then
                hrp.CFrame = npcCF * CFrame.new(0, 0, 3)
                hrp.AssemblyLinearVelocity = Vector3.zero
                task.wait(0.5)
            end
        end
    end
    task.wait(0.3)
    local ok = pcall(function() return QuestClaimRemote:InvokeServer(questId) end)
    if not ok then pcall(function() QuestClaimRemote:FireServer(questId) end) end
    task.wait(1)
end

-- ============================================================
--  HELPERS — EGG
-- ============================================================
local function getEggNames()
    local names = {}
    if EggsFolder then
        for _, egg in ipairs(EggsFolder:GetChildren()) do table.insert(names, egg.Name) end
        table.sort(names)
    end
    return names
end

local function getEggCFrame(eggName)
    local eggAsset = EggsFolder and EggsFolder:FindFirstChild(eggName)
    if eggAsset then
        local ok, cf = pcall(function() return eggAsset:GetPivot() end)
        if ok and cf then return cf end
        if eggAsset.PrimaryPart then return eggAsset.PrimaryPart.CFrame end
    end
    local worldFolder = Workspace:FindFirstChild("World")
    if worldFolder then
        for _, desc in ipairs(worldFolder:GetDescendants()) do
            if desc.Name == eggName then
                if desc:IsA("Model") then
                    if desc.PrimaryPart then return desc.PrimaryPart.CFrame end
                    local ok2, cf2 = pcall(function() return desc:GetPivot() end)
                    if ok2 then return cf2 end
                elseif desc:IsA("BasePart") then return desc.CFrame end
            end
        end
    end
    return nil
end

local function teleportToEgg(eggName)
    local cf = getEggCFrame(eggName)
    if cf then
        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local eggPos       = cf.Position
            local targetPos    = eggPos + Vector3.new(0, 10, 3)
            local targetCFrame = CFrame.lookAt(targetPos, Vector3.new(eggPos.X, targetPos.Y, eggPos.Z))
            local hrpPosXZ     = Vector3.new(hrp.Position.X, 0, hrp.Position.Z)
            local targetPosXZ  = Vector3.new(targetPos.X, 0, targetPos.Z)
            if (hrpPosXZ - targetPosXZ).Magnitude > 5 then
                hrp.CFrame = targetCFrame
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end
            end
        end
        return true
    end
    return false
end

-- ============================================================
--  HELPERS — ENEMY
-- ============================================================
local function getEnemyCFrame(entity)
    if not entity then return nil end
    local hrp = entity:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp.CFrame end
    if entity:IsA("Model") then
        if entity.PrimaryPart then return entity.PrimaryPart.CFrame end
        local ok, cf = pcall(function() return entity:GetPivot() end)
        if ok then return cf end
    elseif entity:IsA("BasePart") then return entity.CFrame end
    for _, child in ipairs(entity:GetDescendants()) do
        if child.Name == "HumanoidRootPart" and child:IsA("BasePart") then return child.CFrame end
    end
    for _, child in ipairs(entity:GetDescendants()) do
        if child:IsA("BasePart") then return child.CFrame end
    end
    return nil
end

local function getMyUnits()
    local units = {}
    local warriorsFolder = Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Warriors")
    if warriorsFolder then
        for _, warrior in ipairs(warriorsFolder:GetChildren()) do
            if warrior:GetAttribute("Owner") == player.Name or warrior.Name == player.Name then
                if warrior.Name == player.Name then
                    for _, child in ipairs(warrior:GetChildren()) do table.insert(units, child.Name) end
                else
                    table.insert(units, warrior.Name)
                end
            end
        end
    end
    return units
end

local function teleportUnitsTo(targetCFrame)
    local warriorsFolder = Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Warriors")
    if warriorsFolder then
        for _, warrior in ipairs(warriorsFolder:GetChildren()) do
            if warrior:GetAttribute("Owner") == player.Name or warrior.Name == player.Name then
                if warrior.Name == player.Name then
                    for _, child in ipairs(warrior:GetChildren()) do
                        if child:IsA("Model") then pcall(function() child:PivotTo(targetCFrame) end) end
                    end
                else
                    if warrior:IsA("Model") then pcall(function() warrior:PivotTo(targetCFrame) end) end
                end
            end
        end
    end
end

local function getAvailableEnemyNames()
    local names, seen = {}, {}
    if not EnemiesFolder then return names end
    for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
        if enemy:GetAttribute("dead") == true then continue end
        local overheadUI = PlayerGui:FindFirstChild("enemy-overhead-" .. enemy.Name)
        if overheadUI and overheadUI:FindFirstChild("Frame") and overheadUI.Frame:FindFirstChild("TextLabel") then
            local realName = overheadUI.Frame.TextLabel.Text
            if realName and realName ~= "" and not seen[realName] then
                seen[realName] = true
                table.insert(names, realName)
            end
        end
    end
    table.sort(names)
    return names
end

local function getTargetEnemy(nameToFind)
    if not EnemiesFolder then return nil end
    for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
        if enemy:GetAttribute("dead") == true then continue end
        local overheadUI = PlayerGui:FindFirstChild("enemy-overhead-" .. enemy.Name)
        if overheadUI and overheadUI:FindFirstChild("Frame") and overheadUI.Frame:FindFirstChild("TextLabel") then
            if overheadUI.Frame.TextLabel.Text == nameToFind then return enemy end
        end
    end
    return nil
end

local function findEnemyMulti(nameList)
    if not EnemiesFolder then return nil end
    local allowSet = {}
    for _, n in ipairs(nameList) do allowSet[n] = true end
    local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        and player.Character.HumanoidRootPart.Position) or Vector3.zero
    local best, bestDist = nil, math.huge
    for _, e in ipairs(EnemiesFolder:GetChildren()) do
        if e:GetAttribute("dead") == true then continue end
        local overheadUI = PlayerGui:FindFirstChild("enemy-overhead-" .. e.Name)
        if overheadUI and overheadUI:FindFirstChild("Frame") and overheadUI.Frame:FindFirstChild("TextLabel") then
            local realName = overheadUI.Frame.TextLabel.Text
            if next(allowSet) == nil or allowSet[realName] then
                local cf = getEnemyCFrame(e)
                if cf then
                    local d = (cf.Position - myPos).Magnitude
                    if d < bestDist then bestDist = d best = e end
                end
            end
        end
    end
    return best
end

local function attackTarget(target)
    local lastActionTick = 0
    while (isAutoFarm or isAutoSnipeBoss) and target and target.Parent do
        if target:GetAttribute("dead") == true then break end
        local char      = player.Character
        local hrp       = char and char:FindFirstChild("HumanoidRootPart")
        local myUnits   = getMyUnits()
        local targetPos = getEnemyCFrame(target)
        if targetPos then
            if hrp then
                hrp.CFrame = targetPos * CFrame.new(0, 5, 0)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
            if tick() - lastActionTick >= 0.2 then
                lastActionTick = tick()
                teleportUnitsTo(targetPos)
                pcall(function() SendUnitRemote:FireServer(target.Name, myUnits) end)
            end
        end
        task.wait()
    end
end

-- ============================================================
--  HELPERS — RAID ENEMIES
-- ============================================================
local RAID_MAX_RANGE = 1000

local function getEnemyRealName(enemy)
    local overheadUI = PlayerGui:FindFirstChild("enemy-overhead-" .. enemy.Name)
    if overheadUI then
        local frame = overheadUI:FindFirstChild("Frame")
        local lbl   = frame and frame:FindFirstChild("TextLabel")
        if lbl and lbl.Text and lbl.Text ~= "" then return lbl.Text end
    end
    return enemy.Name
end

local function isEnemyAlive(enemy)
    if enemy:GetAttribute("dead") == true then return false end
    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then return false end
    return true
end

local function getAllRaidEnemies()
    local enemies = {}
    local char    = player.Character
    local hrp     = char and char:FindFirstChild("HumanoidRootPart")
    local myPos   = hrp and hrp.Position or Vector3.zero
    local worldEnemies = Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Enemies")
    if worldEnemies then
        for _, enemy in ipairs(worldEnemies:GetChildren()) do
            if not isEnemyAlive(enemy) then continue end
            local cf = getEnemyCFrame(enemy)
            if cf then
                local dist = (cf.Position - myPos).Magnitude
                if dist <= RAID_MAX_RANGE then
                    table.insert(enemies, { obj = enemy, dist = dist, realName = getEnemyRealName(enemy) })
                end
            end
        end
    end
    table.sort(enemies, function(a, b) return a.dist < b.dist end)
    return enemies
end

local function findRaidEnemyByName(name)
    local worldEnemies = Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Enemies")
    if not worldEnemies then return nil end
    local char  = player.Character
    local hrp   = char and char:FindFirstChild("HumanoidRootPart")
    local myPos = hrp and hrp.Position or Vector3.zero
    local nameLower = name:lower()
    local best, bestDist = nil, math.huge
    for _, e in ipairs(worldEnemies:GetChildren()) do
        if not isEnemyAlive(e) then continue end
        local cf = getEnemyCFrame(e)
        if not cf then continue end
        local dist = (cf.Position - myPos).Magnitude
        if dist > RAID_MAX_RANGE then continue end
        local realName = getEnemyRealName(e)
        if realName:lower():find(nameLower, 1, true) or nameLower:find(realName:lower(), 1, true) then
            if dist < bestDist then bestDist = dist best = e end
        end
    end
    return best
end

local function pickRaidTarget(raidName)
    ensureRaidConfig(raidName)
    local cfg        = RaidConfig[raidName]
    local allEnemies = getAllRaidEnemies()
    local function findByName(name)
        local nameLower = name:lower()
        for _, e in ipairs(allEnemies) do
            if e.realName:lower():find(nameLower, 1, true) or nameLower:find(e.realName:lower(), 1, true) then
                return e.obj
            end
        end
        return nil
    end
    for _, lightName in ipairs(cfg.light) do
        local e = findByName(lightName)
        if e then return e, "light" end
    end
    if cfg.tank then
        local e = findByName(cfg.tank)
        if e then return e, "tank" end
    end
    if allEnemies[1] then return allEnemies[1].obj, "boss" end
    return nil, nil
end

-- ============================================================
--  HELPERS — LEAVE RAID VIA UI
-- ============================================================
local function leaveRaidViaUI()
    local function tryClick(root)
        for _, desc in ipairs(root:GetDescendants()) do
            if (desc:IsA("TextButton") or desc:IsA("ImageButton")) and isGuiActuallyVisible(desc) then
                local t = (desc.Text or ""):lower()
                if t:find("leave") or t:find("quit") or t:find("exit") then
                    pcall(function() desc:Activate() end)
                    task.wait(0.3)
                    return true
                end
            end
        end
        return false
    end
    if tryClick(PlayerGui) then return end
    if tryClick(CoreGui)   then return end
    pcall(function() BossRaidLeaveRemote:FireServer() end)
end

-- ============================================================
--  RAID RUNNER — แก้ไข: เพิ่ม raidCompleted flag
-- ============================================================
local function runSingleRaid(raidName, isActiveFunc)
    ensureRaidConfig(raidName)
    local cfg           = RaidConfig[raidName]
    local raidStart     = tick()
    local noEnemyTimer  = 0
    local lastPhase     = nil
    local raidCompleted = false  -- flag สำหรับ break ออก outer loop

    local lightStr = table.concat(cfg.light, ", ")
    local tankStr  = cfg.tank and (" -> " .. cfg.tank) or ""
    WindUI:Notify({
        Title    = string.format("[%s] Started", raidName),
        Content  = (#cfg.light > 0)
                   and string.format("Priority: %s%s -> Boss", lightStr, tankStr)
                   or  "No light enemies — going straight to boss",
        Duration = 4,
    })

    while isActiveFunc() and not raidCompleted do
        -- เช็ค Continue ใน outer loop
        if fireRaidContinueIfVisible() then
            raidCompleted = true
            break
        end

        if tick() - raidStart > 900 then
            WindUI:Notify({
                Title    = string.format("[%s] Timed Out", raidName),
                Content  = "15 min limit reached.",
                Duration = 4,
            })
            break
        end

        local target, targetType = pickRaidTarget(raidName)

        if not target then
            noEnemyTimer += 0.3
            if noEnemyTimer >= 10 then
                WindUI:Notify({
                    Title    = string.format("[%s] Complete!", raidName),
                    Content  = "All enemies cleared!",
                    Duration = 4,
                })
                break
            end
            task.wait(0.3)
            continue
        end

        noEnemyTimer = 0

        if targetType ~= lastPhase then
            lastPhase = targetType
            local msgs = {
                light = "Clearing light enemies...",
                tank  = "Attacking tank enemy...",
                boss  = "Engaging boss!",
            }
            WindUI:Notify({
                Title    = string.format("[%s]", raidName),
                Content  = msgs[targetType] or "",
                Duration = 3,
            })
        end

        local attackTimeout  = targetType == "light" and 5 or targetType == "tank" and 8 or 20
        local tStart         = tick()
        local lastAttackTick = 0

        while isActiveFunc() do
            -- เช็ค Continue ใน inner loop ด้วย → set flag แล้ว break
            if fireRaidContinueIfVisible() then
                raidCompleted = true
                break
            end
            if tick() - tStart > attackTimeout     then break end
            if not target or not target.Parent     then break end
            if target:GetAttribute("dead") == true then break end

            if targetType ~= "light" and #cfg.light > 0 then
                local hasLight = false
                for _, ln in ipairs(cfg.light) do
                    if findRaidEnemyByName(ln) then hasLight = true break end
                end
                if hasLight then break end
            end

            local char    = player.Character
            local hrp     = char and char:FindFirstChild("HumanoidRootPart")
            local myUnits = getMyUnits()
            local tPos    = getEnemyCFrame(target)

            if tPos and hrp then
                local dist = (hrp.Position - tPos.Position).Magnitude
                if dist <= RAID_MAX_RANGE then
                    if dist > 20 then
                        hrp.CFrame = tPos * CFrame.new(0, 5, 0)
                        hrp.AssemblyLinearVelocity = Vector3.zero
                    end
                    if tick() - lastAttackTick >= 0.15 then
                        lastAttackTick = tick()
                        teleportUnitsTo(tPos)
                        pcall(function() SendUnitRemote:FireServer(target.Name, myUnits) end)
                    end
                end
            end
            task.wait(0.08)
        end

        -- ถ้า inner loop set raidCompleted ให้ break outer loop ทันที
        if raidCompleted then break end
    end
end

-- ============================================================
--  RAID STATE & QUEUE SYSTEM
-- ============================================================
local RAID_ORDER = { "Destroyed Nemak", "Red Ribbon Base", "Clan Hideout", "Desert Kingdom" }
local RAID_COOLDOWN_DURATION = 20 * 60

local RaidStates  = {
    ["Destroyed Nemak"] = false,
    ["Red Ribbon Base"]  = false,
    ["Clan Hideout"]     = false,
    ["Desert Kingdom"]   = false,
}
local RaidCooldowns  = {}
local isQueueRunning = false
local queueThread    = nil

local updateRaidStatus

local function getActiveRaids()
    local active = {}
    for _, name in ipairs(RAID_ORDER) do
        if RaidStates[name] then table.insert(active, name) end
    end
    return active
end

local function pickNextRaid()
    local active   = getActiveRaids()
    local now      = tick()
    local best     = nil
    local bestWait = math.huge
    for _, name in ipairs(active) do
        local cdEnd = RaidCooldowns[name]
        if not cdEnd or now >= cdEnd then
            return name, 0
        else
            local wait = cdEnd - now
            if wait < bestWait then bestWait = wait best = name end
        end
    end
    return best, bestWait
end

local function startQueueRunner()
    if isQueueRunning then return end
    isQueueRunning = true

    queueThread = task.spawn(function()
        while true do
            if #getActiveRaids() == 0 then
                isQueueRunning = false
                queueThread    = nil
                return
            end

            local raidName, waitSec = pickNextRaid()
            if not raidName then task.wait(5) continue end

            if waitSec > 0 then
                local mins = math.floor(waitSec / 60)
                local secs = math.floor(waitSec % 60)
                WindUI:Notify({
                    Title    = "All Raids on Cooldown",
                    Content  = string.format("Next: [%s] in %02d:%02d\nWaiting...", raidName, mins, secs),
                    Duration = 6,
                })
                local waited = 0
                local target = waitSec + 2
                while waited < target do
                    task.wait(5)
                    waited += 5
                    pcall(updateRaidStatus)
                    local newRaid, newWait = pickNextRaid()
                    if newWait == 0 then raidName = newRaid break end
                    if #getActiveRaids() == 0 then
                        isQueueRunning = false
                        queueThread    = nil
                        return
                    end
                end
                if RaidCooldowns[raidName] and tick() >= RaidCooldowns[raidName] then
                    RaidCooldowns[raidName] = nil
                end
            end

            if not RaidStates[raidName] then continue end

            WindUI:Notify({
                Title    = string.format("[%s] Checking Portal", raidName),
                Content  = "Teleporting to portal...",
                Duration = 2,
            })
            task.wait(1)

            local raidOpen, raidStatus, cooldownLeft, teleported = checkRaidOpenAtPortal(raidName)
            pcall(updateRaidStatus)

            if not teleported then
                WindUI:Notify({
                    Title    = string.format("[%s] Portal Not Found", raidName),
                    Content  = "Cannot locate portal. Skipping...",
                    Duration = 4,
                })
                RaidCooldowns[raidName] = tick() + 20
                continue
            end

            if not raidOpen then
                local waitPortal = cooldownLeft or 120
                if waitPortal <= 90 then
                    WindUI:Notify({
                        Title    = string.format("[%s] Opening Soon", raidName),
                        Content  = string.format("Waiting %ds for portal...", math.max(1, waitPortal)),
                        Duration = 4,
                    })
                    local w = 0
                    while w < waitPortal + 3 and RaidStates[raidName] do task.wait(1) w += 1 end
                    raidOpen, raidStatus, cooldownLeft = checkRaidOpenAtPortal(raidName)
                end
                if not raidOpen then
                    local storeSec = cooldownLeft and math.max(cooldownLeft, 30) or 60
                    RaidCooldowns[raidName] = tick() + storeSec
                    WindUI:Notify({
                        Title    = string.format("[%s] Closed", raidName),
                        Content  = string.format("Status: %s\nTrying next raid...", raidStatus or "?"),
                        Duration = 3,
                    })
                    pcall(updateRaidStatus)
                    continue
                end
            end

            if not RaidStates[raidName] then continue end

            WindUI:Notify({
                Title    = string.format("[%s] Raid Open!", raidName),
                Content  = "Loading team before entering...",
                Duration = 3,
            })

            loadTeam(raidTeamSlot)
            task.wait(1)
            loadTeam(raidTeamSlot)  
            task.wait(2)

            WindUI:Notify({
                Title    = string.format("[%s] Entering Raid", raidName),
                Content  = "Team loaded! Entering now...",
                Duration = 2,
            })

            pcall(function()
                BossRaidCreateRemote:InvokeServer(raidName, { friendsOnly = false, spawnNormal = false })
            end)
            task.wait(2)
            pcall(function() GauntletStartRemote:FireServer() end)
            task.wait(3)

            pcall(function()
                SetStateRemote:FireServer("attack", true)
                SetStateRemote:FireServer("clicker", true)
            end)

            runSingleRaid(raidName, function() return RaidStates[raidName] end)

            pcall(function()
                SetStateRemote:FireServer("attack", false)
                SetStateRemote:FireServer("clicker", false)
            end)

            leaveRaidViaUI()
pcall(function() BossRaidLeaveRemote:FireServer() end)
task.wait(3)

RaidCooldowns[raidName] = tick() + RAID_COOLDOWN_DURATION
pcall(updateRaidStatus)

WindUI:Notify({
    Title    = string.format("[%s] Done — CD 20min", raidName),
    Content  = "Checking next raid...",
    Duration = 3,
})
        end
    end)
end

local function stopQueueIfEmpty()
    if #getActiveRaids() == 0 then
        isQueueRunning = false
        if queueThread then
            pcall(function() task.cancel(queueThread) end)
            queueThread = nil
        end
    end
end

local function enableRaid(raidName)
    RaidStates[raidName] = true
    startQueueRunner()
    pcall(updateRaidStatus)
end

local function disableRaid(raidName)
    RaidStates[raidName]    = false
    RaidCooldowns[raidName] = nil
    stopQueueIfEmpty()
    pcall(updateRaidStatus)
end

-- ============================================================
--  HELPERS — GAUNTLET
-- ============================================================
local function getCurrentFloor()
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("TextLabel") then
            local text = tostring(v.Text or "")
            if text:find("Floor") then
                local floor = text:match("Floor%s*(%d+)")
                if floor then return tonumber(floor) end
            end
        end
    end
    return 0
end

local GauntletLeaveRemote
pcall(function()
    GauntletLeaveRemote = RemoContainer:FindFirstChild("gauntlet.leave")
                       or RemoContainer:FindFirstChild("lobbies.leave")
                       or RemoContainer:FindFirstChild("gauntlet.quit")
end)

local function leaveGauntlet()
    if GauntletLeaveRemote then
        pcall(function() GauntletLeaveRemote:FireServer() end)
        task.wait(0.5)
    end
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        for _, btn in ipairs(gui:GetDescendants()) do
            if btn:IsA("GuiButton") then
                local t = (btn.Text or ""):lower()
                if t == "quit" or t == "leave" or t == "exit" then
                    pcall(function() btn.Activated:Fire() end)
                    pcall(function() btn:Activate() end)
                    task.wait(0.5)
                    return
                end
            end
        end
    end
    pcall(function()
        local leaveRemote = RemoContainer:FindFirstChild("lobbies.leave")
        if leaveRemote then leaveRemote:FireServer() end
    end)
end

local function findGauntletCardsObject()
    local map = Workspace:FindFirstChild("World") and Workspace.World:FindFirstChild("Map")
    if not map then return nil end
    local bestFloor, bestCards = -1, nil
    for _, mapChild in ipairs(map:GetChildren()) do
        if mapChild.Name:sub(1, 9) == "gauntlet-" then
            for _, floorChild in ipairs(mapChild:GetChildren()) do
                local n = floorChild.Name:match("^floor%-(%d+)$")
                if n then
                    local cards = floorChild:FindFirstChild("GauntletCards")
                    if cards then
                        local fn = tonumber(n)
                        if fn > bestFloor then bestFloor = fn bestCards = cards end
                    end
                end
            end
        end
    end
    return bestCards
end

local function teleportAndInteractCards(cardsObj)
    if not cardsObj then return end
    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local cf
    if cardsObj:IsA("Model") then
        if cardsObj.PrimaryPart then cf = cardsObj.PrimaryPart.CFrame
        else pcall(function() cf = cardsObj:GetPivot() end) end
    elseif cardsObj:IsA("BasePart") then
        cf = cardsObj.CFrame
    else
        for _, child in ipairs(cardsObj:GetDescendants()) do
            if child:IsA("BasePart") then cf = child.CFrame break end
        end
    end
    if cf then
        hrp.CFrame = cf * CFrame.new(0, 4, 3)
        hrp.AssemblyLinearVelocity  = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        task.wait(0.4)
    end
    for _, child in ipairs(cardsObj:GetDescendants()) do
        if child:IsA("BasePart") then
            pcall(function() local cd = child:FindFirstChildOfClass("ClickDetector") if cd then fireclickdetector(cd) end end)
            pcall(function() local pp = child:FindFirstChildOfClass("ProximityPrompt") if pp then fireproximityprompt(pp) end end)
            pcall(function() local hrp2 = player.Character and player.Character:FindFirstChild("HumanoidRootPart") if hrp2 then child.Touched:Fire(hrp2) end end)
        end
    end
    if cardsObj:IsA("BasePart") then
        pcall(function() local cd = cardsObj:FindFirstChildOfClass("ClickDetector") if cd then fireclickdetector(cd) end end)
        pcall(function() local pp = cardsObj:FindFirstChildOfClass("ProximityPrompt") if pp then fireproximityprompt(pp) end end)
        pcall(function() local hrp2 = player.Character and player.Character:FindFirstChild("HumanoidRootPart") if hrp2 then cardsObj.Touched:Fire(hrp2) end end)
    end
end

local function pickBestCard(availableCards)
    for _, priority in ipairs(cardPriorityList) do
        if priority and priority ~= "" then
            for _, card in ipairs(availableCards) do
                if card.baseName == priority
                or card.baseName:sub(1, #priority) == priority
                or priority:sub(1, #card.baseName) == card.baseName then
                    return card.fullName
                end
            end
        end
    end
    return availableCards[1] and availableCards[1].fullName or nil
end

local function doCardSelection()
    if isCardSelecting then return end
    isCardSelecting = true
    local cardsObj = findGauntletCardsObject()
    if cardsObj then teleportAndInteractCards(cardsObj) task.wait(0.5) end
    pcall(function() GauntletCardsRemote:FireServer() end)
    task.wait(1.5)
    local function getBaseName(text) return (text:gsub("%s+[IVX]+$", "")) end
    local function scanForCards()
        local found, seenFull = {}, {}
        for _, gui in ipairs(PlayerGui:GetChildren()) do
            for _, label in ipairs(gui:GetDescendants()) do
                if label:IsA("TextLabel") or label:IsA("TextButton") then
                    local t = (label.Text or ""):match("^%s*(.-)%s*$")
                    if t ~= "" and not seenFull[t] then
                        local base = getBaseName(t)
                        for _, cardName in ipairs(ALL_CARDS) do
                            if base == cardName then
                                seenFull[t] = true
                                table.insert(found, { fullName = t, baseName = base })
                                break
                            end
                        end
                    end
                end
            end
        end
        return found
    end
    local shownCards = {}
    local scanEnd = tick() + 8
    while tick() < scanEnd do
        shownCards = scanForCards()
        if #shownCards > 0 then break end
        if cardsObj then teleportAndInteractCards(cardsObj) end
        pcall(function() GauntletCardsRemote:FireServer() end)
        task.wait(0.5)
    end
    if #shownCards == 0 then
        for _, cardName in ipairs(ALL_CARDS) do
            table.insert(shownCards, { fullName = cardName, baseName = cardName })
        end
    end
    local chosenFull = pickBestCard(shownCards)
    if chosenFull then
        pcall(function() GauntletVoteRemote:FireServer(chosenFull) end)
        task.wait(0.3)
        WindUI:Notify({ Title = "Card Selected", Content = "Selected: " .. chosenFull, Duration = 3 })
    end
    pcall(function() GauntletClearRemote:FireServer() end)
    task.wait(0.5)
    isCardSelecting = false
end

local function attackNearestEnemyOnce()
    if not EnemiesFolder then return end
    local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        and player.Character.HumanoidRootPart.Position) or Vector3.zero
    local best, bestDist = nil, math.huge
    for _, e in ipairs(EnemiesFolder:GetChildren()) do
        if e:GetAttribute("dead") == true then continue end
        local cf = getEnemyCFrame(e)
        if cf then
            local d = (cf.Position - myPos).Magnitude
            if d < bestDist then bestDist = d best = e end
        end
    end
    if not best then return end
    local char      = player.Character
    local hrp       = char and char:FindFirstChild("HumanoidRootPart")
    local myUnits   = getMyUnits()
    local targetPos = getEnemyCFrame(best)
    if targetPos then
        if hrp then hrp.CFrame = targetPos * CFrame.new(0, 5, 0) hrp.AssemblyLinearVelocity = Vector3.zero end
        teleportUnitsTo(targetPos)
        pcall(function() SendUnitRemote:FireServer(best.Name, myUnits) end)
    end
end

-- ============================================================
--  WIND UI — THEME
-- ============================================================
WindUI:AddTheme({
    Name                          = "GhostHub",
    Accent                        = Color3.fromHex("#1a0a0a"),
    Background                    = Color3.fromHex("#0d0d0d"),
    BackgroundTransparency         = 0,
    Outline                       = Color3.fromHex("#c0392b"),
    Text                          = Color3.fromHex("#f0f0f0"),
    Placeholder                   = Color3.fromHex("#7a3030"),
    Button                        = Color3.fromHex("#7f1d1d"),
    Icon                          = Color3.fromHex("#e87070"),
    Hover                         = Color3.fromHex("#f0f0f0"),
    WindowBackground              = Color3.fromHex("#0d0d0d"),
    WindowShadow                  = Color3.fromHex("#000000"),
    DialogBackground              = Color3.fromHex("#0d0d0d"),
    DialogBackgroundTransparency   = 0,
    DialogTitle                   = Color3.fromHex("#f0f0f0"),
    DialogContent                 = Color3.fromHex("#cccccc"),
    DialogIcon                    = Color3.fromHex("#e87070"),
    WindowTopbarButtonIcon         = Color3.fromHex("#e87070"),
    WindowTopbarTitle             = Color3.fromHex("#f0f0f0"),
    WindowTopbarAuthor            = Color3.fromHex("#cccccc"),
    WindowTopbarIcon              = Color3.fromHex("#f0f0f0"),
    TabBackground                 = Color3.fromHex("#1a0a0a"),
    TabTitle                      = Color3.fromHex("#f0f0f0"),
    TabIcon                       = Color3.fromHex("#e87070"),
    ElementBackground             = Color3.fromHex("#1f0d0d"),
    ElementTitle                  = Color3.fromHex("#f0f0f0"),
    ElementDesc                   = Color3.fromHex("#aaaaaa"),
    ElementIcon                   = Color3.fromHex("#e87070"),
    PopupBackground               = Color3.fromHex("#0d0d0d"),
    PopupBackgroundTransparency    = 0,
    PopupTitle                    = Color3.fromHex("#f0f0f0"),
    PopupContent                  = Color3.fromHex("#cccccc"),
    PopupIcon                     = Color3.fromHex("#e87070"),
    Toggle                        = Color3.fromHex("#7f1d1d"),
    ToggleBar                     = Color3.fromHex("#e84040"),
    Checkbox                      = Color3.fromHex("#7f1d1d"),
    CheckboxIcon                  = Color3.fromHex("#f0f0f0"),
    Slider                        = Color3.fromHex("#7f1d1d"),
    SliderThumb                   = Color3.fromHex("#e84040"),
})

local Window = WindUI:CreateWindow({
    Title                       = "Anime Warrior 3 — Ghost Hub",
    Icon                        = "rbxassetid://110552700896064",
    Author                      = "GhostHub",
    Folder                      = "GhostHub/AW3",
    Size                        = UDim2.fromOffset(620, 500),
    MinSize                     = Vector2.new(560, 380),
    MaxSize                     = Vector2.new(860, 580),
    Transparent                 = true,
    Theme                       = "GhostHub",
    AccentColor                 = Color3.fromHex("#c0392b"),
    Resizable                   = true,
    SideBarWidth                = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar               = true,
    ScrollBarEnabled            = false,
})
Window:Tag({Title = "Beta",   Icon = "badge-alert", Color = Color3.fromHex("#0011ff"), Radius = 6})
Window:Tag({Title = "v.0.0.2",Icon = "",            Color = Color3.fromHex("#30ff6a"), Radius = 6})

Window:SetToggleKey(Enum.KeyCode[Options.ToggleUIKey] or Enum.KeyCode.RightControl)

local FarmTab     = Window:Tab({ Title = "Farming",  Icon = "crosshair"    })
local SummonTab   = Window:Tab({ Title = "Summon",   Icon = "star"         })
local UnitTab     = Window:Tab({ Title = "Units",    Icon = "users"        })
local WorldTab    = Window:Tab({ Title = "Teleport", Icon = "navigation"   })
local QuestTab    = Window:Tab({ Title = "Quest",    Icon = "scroll"       })
local RaidTab     = Window:Tab({ Title = "Raid",     Icon = "shield-alert" })
local GauntletTab = Window:Tab({ Title = "Gauntlet", Icon = "zap"          })
local SettingTab  = Window:Tab({ Title = "Settings", Icon = "cog"          })

-- ============================================================
--  FARMING TAB
-- ============================================================
FarmTab:Section({ Title = "Farming MOB" })

local EnemyDropdown = FarmTab:Dropdown({
    Title    = "Select Monster",
    Icon     = "target",
    Values   = getAvailableEnemyNames(),
    Value    = selectedEnemyNames,
    Multi    = true,
    Callback = function(v)
        selectedEnemyNames         = type(v) == "table" and v or (v ~= "" and {v} or {})
        Options.SelectedEnemyNames = selectedEnemyNames
        SaveConfig()
    end
})

FarmTab:Button({
    Title    = "Refresh Monsters",
    Icon     = "refresh-cw",
    Callback = function() EnemyDropdown:Refresh(getAvailableEnemyNames()) end
})

FarmTab:Toggle({
    Title    = "Auto Equip Weapon",
    Icon     = "sword",
    Type     = "Checkbox",
    Value    = Options.AutoWeapon or false,
    Callback = function(v)
        isAutoWeapon       = v
        Options.AutoWeapon = v
        SaveConfig()
        if isAutoWeapon then
            task.spawn(function()
                while isAutoWeapon do
                    pcall(function() ToolbarEquipRemote:FireServer("weapon") end)
                    task.wait(15)
                end
            end)
        end
    end
})

FarmTab:Toggle({
    Title    = "Auto Farm",
    Icon     = "play",
    Type     = "Checkbox",
    Value    = Options.AutoFarm or false,
    Callback = function(v)
        isAutoFarm       = v
        Options.AutoFarm = v
        SaveConfig()
        if isAutoFarm then
            pcall(function()
                SetStateRemote:FireServer("attack", true)
                SetStateRemote:FireServer("clicker", true)
            end)
            task.spawn(function()
                while isAutoFarm do
                    if isAutoSnipeBoss then task.wait(1) continue end
                    if #selectedEnemyNames == 0 then task.wait(1) continue end
                    local target = findEnemyMulti(selectedEnemyNames)
                    if target then attackTarget(target) else task.wait(0.1) end
                end
                if not isAutoSnipeBoss then
                    pcall(function()
                        SetStateRemote:FireServer("attack", false)
                        SetStateRemote:FireServer("clicker", false)
                    end)
                end
            end)
        end
    end
})

FarmTab:Divider()
FarmTab:Section({ Title = "Farming Boss" })

FarmTab:Dropdown({
    Title    = "Select Boss",
    Icon     = "skull",
    Values   = BossList,
    Value    = selectedBossNames,
    Multi    = true,
    Callback = function(v)
        selectedBossNames         = type(v) == "table" and v or (v ~= "" and {v} or {})
        Options.SelectedBossNames = selectedBossNames
        SaveConfig()
    end
})

FarmTab:Toggle({
    Title    = "Auto Farm Boss",
    Icon     = "crosshair",
    Type     = "Checkbox",
    Value    = Options.AutoFarmBoss or false,
    Callback = function(v)
        isAutoSnipeBoss      = v
        Options.AutoFarmBoss = v
        SaveConfig()
        if isAutoSnipeBoss then
            pcall(function()
                SetStateRemote:FireServer("attack", true)
                SetStateRemote:FireServer("clicker", true)
            end)
            task.spawn(function()
                while isAutoSnipeBoss do
                    if #selectedBossNames == 0 then task.wait(1) continue end
                    local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        and player.Character.HumanoidRootPart.Position) or Vector3.zero
                    local bestTarget, bestDist = nil, math.huge
                    for _, bossName in ipairs(selectedBossNames) do
                        local t = getTargetEnemy(bossName)
                        if t then
                            local cf = getEnemyCFrame(t)
                            if cf then
                                local d = (cf.Position - myPos).Magnitude
                                if d < bestDist then bestDist = d bestTarget = t end
                            end
                        end
                    end
                    if bestTarget then attackTarget(bestTarget) else task.wait(1) end
                end
                if not isAutoFarm then
                    pcall(function()
                        SetStateRemote:FireServer("attack", false)
                        SetStateRemote:FireServer("clicker", false)
                    end)
                end
            end)
        end
    end
})

-- ============================================================
--  SUMMON TAB
-- ============================================================
SummonTab:Section({ Title = "Egg Settings" })

local eggNames = getEggNames()
if #eggNames == 0 then eggNames = {"(No eggs found)"} end
if not table.find(eggNames, selectedEggName) then selectedEggName = eggNames[1] or "Nemak" end

local EggDropdown = SummonTab:Dropdown({
    Title    = "Select Egg",
    Icon     = "package",
    Values   = eggNames,
    Value    = selectedEggName,
    Multi    = false,
    Callback = function(v)
        if v and v ~= "" and v ~= "(No eggs found)" then
            selectedEggName         = v
            Options.SelectedEggName = v
            SaveConfig()
        end
    end
})

SummonTab:Button({
    Title    = "Refresh Egg List",
    Icon     = "refresh-cw",
    Callback = function()
        local newNames = getEggNames()
        if #newNames == 0 then newNames = {"(No eggs found)"} end
        EggDropdown:Refresh(newNames)
    end
})

SummonTab:Toggle({
    Title    = "Auto Open Egg",
    Icon     = "package",
    Type     = "Checkbox",
    Value    = Options.AutoEgg or false,
    Callback = function(v)
        isAutoEgg       = v
        Options.AutoEgg = v
        SaveConfig()
        if isAutoEgg then
            task.spawn(function()
                while isAutoEgg do
                    pcall(function() teleportToEgg(selectedEggName) end)
                    task.wait(1)
                    pcall(function() OpenEggRemote:InvokeServer(selectedEggName) end)
                    task.wait(1)
                end
            end)
        end
    end
})

-- ============================================================
--  UNITS TAB
-- ============================================================
UnitTab:Section({ Title = "Unit Settings" })

UnitTab:Toggle({
    Title    = "Send All Units",
    Icon     = "users",
    Type     = "Checkbox",
    Value    = Options.SendAllUnits or false,
    Callback = function(v)
        Options.SendAllUnits = v
        SaveConfig()
        pcall(function() SettingsSetRemote:FireServer("send_all", v) end)
    end
})

UnitTab:Toggle({
    Title    = "No Retreat",
    Icon     = "shield",
    Type     = "Checkbox",
    Value    = Options.NoRetreat or false,
    Callback = function(v)
        Options.NoRetreat = v
        SaveConfig()
        pcall(function() SettingsSetRemote:FireServer("no_retreat", v) end)
    end
})

UnitTab:Toggle({
    Title    = "Auto Equip Best",
    Icon     = "user-check",
    Type     = "Checkbox",
    Value    = Options.AutoEquip or false,
    Callback = function(v)
        isAutoEquip       = v
        Options.AutoEquip = v
        SaveConfig()
        if isAutoEquip then
            task.spawn(function()
                while isAutoEquip do
                    pcall(function()
                        UnequipAllRemote:FireServer()
                        task.wait(0.5)
                        EquipBestRemote:FireServer()
                    end)
                    task.wait(60)
                end
            end)
        end
    end
})

UnitTab:Divider()
UnitTab:Section({ Title = "Team Slots" })

-- Gauntlet Team
UnitTab:Dropdown({
    Title    = "Gauntlet Team Slot",
    Icon     = "layers",
    Desc     = "Load this team when entering Gauntlet",
    Values   = TEAM_SLOTS,
    Value    = gauntletTeamSlot,
    Multi    = false,
    Callback = function(v)
        if v and v ~= "" then
            gauntletTeamSlot         = v
            Options.GauntletTeamSlot = v
            SaveConfig()
        end
    end
})

UnitTab:Button({
    Title    = "Load Gauntlet Team Now",
    Icon     = "zap",
    Desc     = "Manually load selected Gauntlet team",
    Callback = function()
        loadTeam(gauntletTeamSlot)
        WindUI:Notify({ Title = "Team Loaded", Content = "Gauntlet Team Slot " .. gauntletTeamSlot .. " loaded!", Duration = 3 })
    end
})

UnitTab:Divider()

-- Raid Team
UnitTab:Dropdown({
    Title    = "Raid Team Slot",
    Icon     = "shield-alert",
    Desc     = "Load this team when entering Raid",
    Values   = TEAM_SLOTS,
    Value    = raidTeamSlot,
    Multi    = false,
    Callback = function(v)
        if v and v ~= "" then
            raidTeamSlot         = v
            Options.RaidTeamSlot = v
            SaveConfig()
        end
    end
})

UnitTab:Button({
    Title    = "Load Raid Team Now",
    Icon     = "shield",
    Desc     = "Manually load selected Raid team",
    Callback = function()
        loadTeam(raidTeamSlot)
        WindUI:Notify({ Title = "Team Loaded", Content = "Raid Team Slot " .. raidTeamSlot .. " loaded!", Duration = 3 })
    end
})

UnitTab:Divider()

-- Manual load any slot
local manualTeamSlot = "1"
UnitTab:Dropdown({
    Title    = "Manual Load Any Slot",
    Icon     = "refresh-cw",
    Desc     = "Load any team slot manually",
    Values   = TEAM_SLOTS,
    Value    = "1",
    Multi    = false,
    Callback = function(v)
        if v and v ~= "" then manualTeamSlot = v end
    end
})

UnitTab:Button({
    Title    = "Load Selected Slot",
    Icon     = "play",
    Callback = function()
        loadTeam(manualTeamSlot)
        WindUI:Notify({ Title = "Team Loaded", Content = "Team Slot " .. manualTeamSlot .. " loaded!", Duration = 3 })
    end
})

-- ============================================================
--  QUEST TAB
-- ============================================================
QuestTab:Section({ Title = "Quest Settings" })

local questList = getQuestList()
if #questList == 0 or questList[1] == "(No quests found)" then
    task.spawn(function()
        task.wait(3)
        buildQuestLabelMap()
        questList = getQuestList()
    end)
end

if not table.find(questList, selectedQuestId) then selectedQuestId = questList[1] or "" end

local QuestDropdown = QuestTab:Dropdown({
    Title    = "Select Quest Part",
    Icon     = "scroll",
    Values   = questList,
    Value    = selectedQuestId,
    Multi    = false,
    Callback = function(v)
        if v and v ~= "" and v ~= "(No quests found)" then
            selectedQuestId         = v
            Options.SelectedQuestId = v
            SaveConfig()
        end
    end
})

QuestTab:Button({
    Title    = "Refresh Quest List",
    Icon     = "refresh-cw",
    Callback = function()
        task.spawn(function()
            local ok, questModule = pcall(function()
                return require(
                    ReplicatedStorage
                        :WaitForChild("src"):WaitForChild("common")
                        :WaitForChild("content"):WaitForChild("world")
                        :WaitForChild("quests")
                )
            end)
            if ok and questModule and questModule.questsContent then
                QuestData = questModule.questsContent
                buildQuestLabelMap()
            end
            QuestDropdown:Refresh(getQuestList())
        end)
    end
})

QuestTab:Toggle({
    Title    = "Auto Quest",
    Icon     = "check-square",
    Type     = "Checkbox",
    Value    = Options.AutoQuest or false,
    Callback = function(v)
        isAutoQuest       = v
        Options.AutoQuest = v
        SaveConfig()
        if isAutoQuest then
            task.spawn(function()
                while isAutoQuest do
                    if selectedQuestId == "" or selectedQuestId == "(No quests found)" then task.wait(1) continue end
                    local questId, partIndex, tasks = getQuestInfoFromLabel(selectedQuestId)
                    if not questId then task.wait(1) continue end
                    WindUI:Notify({ Title = "Auto Quest", Content = string.format("Starting: %s (%d tasks)", selectedQuestId, #tasks), Duration = 4 })
                    local allDone = true
                    for taskIdx, taskInfo in ipairs(tasks) do
                        if not isAutoQuest then allDone = false break end
                        local enemyName = taskInfo.enemy
                        local required  = taskInfo.required
                        local killCount = 0
                        WindUI:Notify({ Title = string.format("Task %d / %d", taskIdx, #tasks), Content = string.format("Target: [%s]  Need: %d kills", enemyName, required), Duration = 4 })
                        while isAutoQuest and killCount < required do
                            local target = getTargetEnemy(enemyName)
                            if not target then task.wait(0.5) continue end
                            local char      = player.Character
                            local hrp       = char and char:FindFirstChild("HumanoidRootPart")
                            local myUnits   = getMyUnits()
                            local targetPos = getEnemyCFrame(target)
                            if targetPos then
                                if hrp then hrp.CFrame = targetPos * CFrame.new(0, 5, 0) hrp.AssemblyLinearVelocity = Vector3.zero end
                                teleportUnitsTo(targetPos)
                                pcall(function() SendUnitRemote:FireServer(target.Name, myUnits) end)
                            end
                            while isAutoQuest and target and target.Parent do
                                if target:GetAttribute("dead") == true then
                                    killCount += 1
                                    WindUI:Notify({ Title = string.format("Kill %d / %d", killCount, required), Content = string.format("[%s] Killed!", enemyName), Duration = 2 })
                                    break
                                end
                                local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if curHRP then
                                    local curPos = getEnemyCFrame(target)
                                    if curPos and (curHRP.Position - curPos.Position).Magnitude > 8 then
                                        curHRP.CFrame = curPos * CFrame.new(0, 5, 0)
                                        curHRP.AssemblyLinearVelocity = Vector3.zero
                                        teleportUnitsTo(curPos)
                                        pcall(function() SendUnitRemote:FireServer(target.Name, getMyUnits()) end)
                                    end
                                end
                                task.wait(0.2)
                            end
                        end
                        if isAutoQuest then
                            WindUI:Notify({ Title = string.format("Task %d / %d Done", taskIdx, #tasks), Content = string.format("[%s] x%d Complete!", enemyName, required), Duration = 3 })
                        end
                    end
                    if isAutoQuest and allDone then
                        WindUI:Notify({ Title = "Going to NPC", Content = string.format("All tasks done! Claiming [%s]...", selectedQuestId), Duration = 3 })
                        task.wait(0.5)
                        goToNPCAndClaim(questId)
                        WindUI:Notify({ Title = "Reward Claimed!", Content = string.format("[%s] reward collected!", selectedQuestId), Duration = 4 })
                    end
                    task.wait(2)
                end
            end)
        end
    end
})

-- ============================================================
--  RAID TAB — STATUS
-- ============================================================
RaidTab:Section({ Title = "Raid Status" })
local raidStatusLabel = RaidTab:Section({ Title = "Enable a raid below to start" })

updateRaidStatus = function()
    local lines = {}
    for _, raidName in ipairs(RAID_ORDER) do
        if RaidStates[raidName] then
            local now   = tick()
            local cdEnd = RaidCooldowns[raidName]
            if cdEnd and now < cdEnd then
                local remaining = math.ceil(cdEnd - now)
                local mins = math.floor(remaining / 60)
                local secs = remaining % 60
                table.insert(lines, string.format("[CD] %s — %02d:%02d", raidName, mins, secs))
            else
                table.insert(lines, string.format("[ON] %s — Queued", raidName))
            end
        end
    end
    if #lines == 0 then
        raidStatusLabel:SetTitle("Enable a raid below to start")
    else
        raidStatusLabel:SetTitle(table.concat(lines, "\n"))
    end
end

task.spawn(function()
    while true do task.wait(5) pcall(updateRaidStatus) end
end)

RaidTab:Section({ Title = "Auto Raid (Multi-Select)" })

RaidTab:Toggle({
    Title    = "Destroyed Nemak",
    Icon     = "shield",
    Type     = "Checkbox",
    Value    = false,
    Callback = function(v)
        if v then enableRaid("Destroyed Nemak") else disableRaid("Destroyed Nemak") end
    end
})

RaidTab:Toggle({
    Title    = "Red Ribbon Base",
    Icon     = "shield",
    Type     = "Checkbox",
    Value    = false,
    Callback = function(v)
        if v then enableRaid("Red Ribbon Base") else disableRaid("Red Ribbon Base") end
    end
})

RaidTab:Toggle({
    Title    = "Clan Hideout",
    Icon     = "shield",
    Type     = "Checkbox",
    Value    = false,
    Callback = function(v)
        if v then enableRaid("Clan Hideout") else disableRaid("Clan Hideout") end
    end
})

RaidTab:Toggle({
    Title    = "Desert Kingdom",
    Icon     = "shield",
    Type     = "Checkbox",
    Value    = false,
    Callback = function(v)
        if v then enableRaid("Desert Kingdom") else disableRaid("Desert Kingdom") end
    end
})

RaidTab:Button({
    Title    = "Refresh Status",
    Icon     = "refresh-cw",
    Callback = function()
        pcall(updateRaidStatus)
        WindUI:Notify({ Title = "Raid Status", Content = "Status refreshed!", Duration = 2 })
    end
})

-- ============================================================
--  GAUNTLET TAB
-- ============================================================
GauntletTab:Section({ Title = "Card Priority" })

local prioritySlots = 5
for i = 1, prioritySlots do
    local slotIndex = i
    GauntletTab:Dropdown({
        Title    = "Priority " .. i,
        Icon     = "star",
        Values   = ALL_CARDS,
        Value    = cardPriorityList[i] or "",
        Multi    = false,
        Callback = function(v)
            cardPriorityList[slotIndex]         = (v and v ~= "") and v or nil
            Options.CardPriorityList[slotIndex] = cardPriorityList[slotIndex]
            SaveConfig()
        end
    })
end

GauntletTab:Divider()

GauntletTab:Slider({
    Title    = "Leave at Floor",
    Icon     = "log-out",
    Step     = 1,
    Value    = { Min = 1, Max = 50, Default = Options.GauntletMaxFloor or 6 },
    Callback = function(v)
        gauntletMaxFloor         = math.floor(v)
        Options.GauntletMaxFloor = gauntletMaxFloor
        SaveConfig()
    end
})

GauntletTab:Toggle({
    Title    = "Auto Leave",
    Icon     = "log-out",
    Type     = "Checkbox",
    Value    = Options.AutoLeaveGauntlet or false,
    Callback = function(v)
        isGauntletAutoLeave       = v
        Options.AutoLeaveGauntlet = v
        SaveConfig()
    end
})

GauntletTab:Divider()
GauntletTab:Section({ Title = "Controls" })

GauntletTab:Toggle({
    Title    = "Auto Select Card",
    Icon     = "layers",
    Type     = "Checkbox",
    Value    = Options.AutoSelectCard or false,
    Callback = function(v)
        isGauntletAutoCard     = v
        Options.AutoSelectCard = v
        SaveConfig()
    end
})

GauntletTab:Toggle({
    Title    = "Auto Farm Gauntlet",
    Icon     = "zap",
    Type     = "Checkbox",
    Value    = Options.AutoGauntlet or false,
    Callback = function(v)
        isGauntletFarm       = v
        Options.AutoGauntlet = v
        SaveConfig()
        if not isGauntletFarm then return end

        task.spawn(function()
            local function waitForNextMinute()
                local now     = tick()
                local secLeft = 60 - (now % 60)
                if secLeft < 58 then
                    WindUI:Notify({
                        Title    = "Gauntlet",
                        Content  = string.format("Waiting %ds for next minute...", math.floor(secLeft)),
                        Duration = math.min(secLeft, 6),
                    })
                    task.wait(secLeft)
                end
            end

            waitForNextMinute()

            while isGauntletFarm do
            WindUI:Notify({
                Title   = "Gauntlet",
                Content = "Loading team...",
                Duration = 2,
            })
            loadTeam(gauntletTeamSlot)
            task.wait(1)
            loadTeam(gauntletTeamSlot)  -- fire ซ้ำกันค้าง
            task.wait(2)

            pcall(function()
                GauntletCreateRemote:InvokeServer("Normal", { friendsOnly = false })
            end)
            task.wait(1.5)
            pcall(function() GauntletStartRemote:FireServer() end)
            task.wait(2)


                pcall(function()
                    SetStateRemote:FireServer("attack", true)
                    SetStateRemote:FireServer("clicker", true)
                end)

                task.wait(3)

                local lastCardFloor = -1
                local attackTick    = 0

                while isGauntletFarm do
                    local currentFloor = getCurrentFloor()

                    if isGauntletAutoLeave and currentFloor > 0 and currentFloor >= gauntletMaxFloor then
                        pcall(function()
                            SetStateRemote:FireServer("attack", false)
                            SetStateRemote:FireServer("clicker", false)
                        end)
                        WindUI:Notify({
                            Title    = "Auto Leave",
                            Content  = string.format("Reached Floor %d / %d — waiting 5s then leaving!", currentFloor, gauntletMaxFloor),
                            Duration = 5,
                        })
                        task.wait(5)
                        leaveGauntlet()
                        task.wait(3)
                        break
                    end

                    if isGauntletAutoCard
                        and currentFloor > 0
                        and currentFloor % 5 == 0
                        and currentFloor ~= lastCardFloor
                    then
                        lastCardFloor = currentFloor
                        task.spawn(doCardSelection)
                    end

                    if tick() - attackTick >= 0.15 then
                        attackTick = tick()
                        pcall(attackNearestEnemyOnce)
                    end

                    task.wait(0.05)
                end

                task.wait(3)
            end

            pcall(function()
                SetStateRemote:FireServer("attack", false)
                SetStateRemote:FireServer("clicker", false)
            end)
        end)
    end
})

-- ============================================================
--  WORLD TAB
-- ============================================================
WorldTab:Section({ Title = "World" })

local worldNames = getWorldNames()
if #worldNames == 0 then worldNames = { "(No worlds found)" } end
local selectedWorldName = worldNames[1] or ""

local WorldDropdown = WorldTab:Dropdown({
    Title    = "Select World",
    Icon     = "globe",
    Values   = worldNames,
    Value    = selectedWorldName,
    Multi    = false,
    Callback = function(v)
        if v and v ~= "" and v ~= "(No worlds found)" then selectedWorldName = v end
    end
})

WorldTab:Button({
    Title    = "Refresh",
    Icon     = "refresh-cw",
    Callback = function()
        worldNames = getWorldNames()
        if #worldNames == 0 then worldNames = { "(No worlds found)" } end
        WorldDropdown:Refresh(worldNames)
    end
})

WorldTab:Button({
    Title    = "Teleport",
    Icon     = "navigation",
    Callback = function()
        if selectedWorldName == "" or selectedWorldName == "(No worlds found)" then
            WindUI:Notify({ Title = "World", Content = "No world selected!", Duration = 3 })
            return
        end
        local teleported = false
        pcall(function()
            local locations = Workspace:FindFirstChild("World")
                and Workspace.World:FindFirstChild("Teleports")
                and Workspace.World.Teleports:FindFirstChild("Locations")
            if not locations then return end
            local loc = locations:FindFirstChild(selectedWorldName)
            if not loc then
                local function normalize(s) return s:lower():gsub("[%-%_ ]", "") end
                local target = normalize(selectedWorldName)
                for _, child in ipairs(locations:GetChildren()) do
                    if normalize(child.Name) == target then loc = child break end
                end
            end
            if loc then
                local cf
                if loc:IsA("Model") then
                    if loc.PrimaryPart then cf = loc.PrimaryPart.CFrame
                    else pcall(function() cf = loc:GetPivot() end) end
                elseif loc:IsA("BasePart") then cf = loc.CFrame end
                if cf then
                    local char = player.Character
                    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = cf * CFrame.new(0, 5, 0)
                        hrp.AssemblyLinearVelocity  = Vector3.zero
                        hrp.AssemblyAngularVelocity = Vector3.zero
                        teleported = true
                    end
                end
            end
        end)
        WindUI:Notify({
            Title   = "World",
            Content = teleported and ("Teleported to " .. selectedWorldName) or ("Not found: " .. selectedWorldName),
            Duration = 3,
        })
    end
})

WorldTab:Divider()
WorldTab:Section({ Title = "Locations" })

local function getLocationNames()
    local names = {}
    pcall(function()
        local locations = Workspace:FindFirstChild("World")
            and Workspace.World:FindFirstChild("Teleports")
            and Workspace.World.Teleports:FindFirstChild("Locations")
        if locations then
            local function normalize(s) return s:lower():gsub("[%-%_ ]", "") end
            local worldNorm = {}
            for _, wn in ipairs(worldNames) do worldNorm[normalize(wn)] = true end
            for _, loc in ipairs(locations:GetChildren()) do
                if not worldNorm[normalize(loc.Name)] then table.insert(names, loc.Name) end
            end
            table.sort(names)
        end
    end)
    if #names == 0 then names = { "(No extra locations)" } end
    return names
end

local locationNames        = getLocationNames()
local selectedLocationName = locationNames[1] or ""

local LocationDropdown = WorldTab:Dropdown({
    Title    = "Select Location",
    Icon     = "map-pin",
    Values   = locationNames,
    Value    = selectedLocationName,
    Multi    = false,
    Callback = function(v)
        if v and v ~= "" and v ~= "(No extra locations)" then selectedLocationName = v end
    end
})

WorldTab:Button({
    Title    = "Refresh",
    Icon     = "refresh-cw",
    Callback = function()
        locationNames = getLocationNames()
        LocationDropdown:Refresh(locationNames)
    end
})

WorldTab:Button({
    Title    = "Teleport",
    Icon     = "navigation",
    Callback = function()
        if selectedLocationName == "" or selectedLocationName == "(No extra locations)" then
            WindUI:Notify({ Title = "Location", Content = "No location selected!", Duration = 3 })
            return
        end
        local teleported = false
        pcall(function()
            local locations = Workspace:FindFirstChild("World")
                and Workspace.World:FindFirstChild("Teleports")
                and Workspace.World.Teleports:FindFirstChild("Locations")
            if locations then
                local loc = locations:FindFirstChild(selectedLocationName)
                if loc then
                    local cf
                    if loc:IsA("Model") then
                        if loc.PrimaryPart then cf = loc.PrimaryPart.CFrame
                        else pcall(function() cf = loc:GetPivot() end) end
                    elseif loc:IsA("BasePart") then cf = loc.CFrame end
                    if cf then
                        local char = player.Character
                        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = cf * CFrame.new(0, 5, 0)
                            hrp.AssemblyLinearVelocity  = Vector3.zero
                            hrp.AssemblyAngularVelocity = Vector3.zero
                            teleported = true
                        end
                    end
                end
            end
        end)
        WindUI:Notify({
            Title   = "Location",
            Content = teleported and ("Teleported to " .. selectedLocationName) or ("Not found: " .. selectedLocationName),
            Duration = 3,
        })
    end
})

-- ============================================================
--  SETTINGS TAB
-- ============================================================
SettingTab:Section({ Title = "General" })

SettingTab:Keybind({
    Title    = "Toggle UI Key",
    Desc     = "Keybind to show/hide the window",
    Value    = Options.ToggleUIKey or "RightControl",
    Callback = function(v)
        Options.ToggleUIKey = tostring(v)
        SaveConfig()
        local key = typeof(v) == "EnumItem" and v or Enum.KeyCode[v]
        Window:SetToggleKey(key)
    end
})

SettingTab:Toggle({
    Title    = "Anti AFK",
    Icon     = "shield",
    Type     = "Checkbox",
    Value    = Options.AntiAFK or false,
    Callback = function(v) Options.AntiAFK = v SaveConfig() end
})

SettingTab:Toggle({
    Title    = "Auto Rejoin",
    Icon     = "plug",
    Desc     = "Reconnect automatically on disconnect",
    Type     = "Checkbox",
    Value    = Options.AutoRejoin or false,
    Callback = function(v)
        Options.AutoRejoin = v
        SaveConfig()
        if v then
            task.spawn(function()
                local overlay = CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
                if not getgenv().RejoinConnection then
                    getgenv().RejoinConnection = overlay.ChildAdded:Connect(function(child)
                        if Options.AutoRejoin and child.Name == "ErrorPrompt" then
                            task.wait(5)
                            TeleportService:Teleport(game.PlaceId, player)
                        end
                    end)
                end
            end)
        end
    end
})

-- ============================================================
--  ANTI AFK LOOP
-- ============================================================
task.spawn(function()
    while true do
        task.wait(120)
        if Options.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true,  Enum.KeyCode.Space, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
        end
    end
end)

-- ============================================================
--  DRAGGABLE TOGGLE BUTTON
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "AW3ToggleGui"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = (gethui and gethui()) or CoreGui

local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Parent                 = ScreenGui
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Position               = UDim2.new(0.5, 0, 0, 40)
ToggleBtn.Size                   = UDim2.new(0, 50, 0, 50)
ToggleBtn.Image                  = "rbxassetid://110552700896064"
ToggleBtn.AnchorPoint            = Vector2.new(0.5, 0.5)
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

local s2 = Instance.new("UIStroke", ToggleBtn)
s2.Thickness       = 2
s2.Color           = Color3.fromRGB(124, 58, 237)
s2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local dragging, dragStart, startPos

ToggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        dragging  = true
        dragStart = i.Position
        startPos  = ToggleBtn.Position
        TweenService:Create(ToggleBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 42, 0, 42)}):Play()
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1
    or i.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            dragging = false
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(0, 50, 0, 50)}):Play()
            if dragStart and (i.Position - dragStart).Magnitude < 10 then
                local key = Enum.KeyCode[Options.ToggleUIKey] or Enum.KeyCode.RightControl
                VirtualInputManager:SendKeyEvent(true,  key, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, key, false, game)
            end
        end
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if (i.UserInputType == Enum.UserInputType.MouseMovement
    or  i.UserInputType == Enum.UserInputType.Touch) and dragging then
        local d = i.Position - dragStart
        ToggleBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)

FarmTab:Select()
