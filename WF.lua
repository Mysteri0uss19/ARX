if not game:IsLoaded() then
    game.Loaded:Wait()
end

if game.PlaceId ~= 95630541662383 then
    warn("Failed to load: This script only supports World Fighter Simulator")
    return
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
if not WindUI then
    warn("Failed to load UI! Please check your internet or try restarting your Executor")
    return
end

WindUI:SetNotificationLower(true)

WindUI:AddTheme({
    Name                         = "GhostHub",
    Accent                       = Color3.fromHex("#1a0a0a"),
    Background                   = Color3.fromHex("#0d0d0d"),
    BackgroundTransparency        = 0,
    Outline                      = Color3.fromHex("#c0392b"),
    Text                         = Color3.fromHex("#f0f0f0"),
    Placeholder                  = Color3.fromHex("#7a3030"),
    Button                       = Color3.fromHex("#7f1d1d"),
    Icon                         = Color3.fromHex("#e87070"),
    Hover                        = Color3.fromHex("#f0f0f0"),
    WindowBackground             = Color3.fromHex("#0d0d0d"),
    WindowShadow                 = Color3.fromHex("#000000"),
    DialogBackground             = Color3.fromHex("#0d0d0d"),
    DialogBackgroundTransparency  = 0,
    DialogTitle                  = Color3.fromHex("#f0f0f0"),
    DialogContent                = Color3.fromHex("#cccccc"),
    DialogIcon                   = Color3.fromHex("#e87070"),
    WindowTopbarButtonIcon        = Color3.fromHex("#e87070"),
    WindowTopbarTitle            = Color3.fromHex("#f0f0f0"),
    WindowTopbarAuthor           = Color3.fromHex("#cccccc"),
    WindowTopbarIcon             = Color3.fromHex("#f0f0f0"),
    TabBackground                = Color3.fromHex("#1a0a0a"),
    TabTitle                     = Color3.fromHex("#f0f0f0"),
    TabIcon                      = Color3.fromHex("#e87070"),
    ElementBackground            = Color3.fromHex("#1f0d0d"),
    ElementTitle                 = Color3.fromHex("#f0f0f0"),
    ElementDesc                  = Color3.fromHex("#aaaaaa"),
    ElementIcon                  = Color3.fromHex("#e87070"),
    PopupBackground              = Color3.fromHex("#0d0d0d"),
    PopupBackgroundTransparency   = 0,
    PopupTitle                   = Color3.fromHex("#f0f0f0"),
    PopupContent                 = Color3.fromHex("#cccccc"),
    PopupIcon                    = Color3.fromHex("#e87070"),
    Toggle                       = Color3.fromHex("#7f1d1d"),
    ToggleBar                    = Color3.fromHex("#e84040"),
    Checkbox                     = Color3.fromHex("#7f1d1d"),
    CheckboxIcon                 = Color3.fromHex("#f0f0f0"),
    Slider                       = Color3.fromHex("#7f1d1d"),
    SliderThumb                  = Color3.fromHex("#e84040"),
})

local Window = WindUI:CreateWindow({
    Title                       = "World Fighter — Ghost Hub",
    Icon                        = "rbxassetid://110552700896064",
    Author                      = "GhostHub",
    Folder                      = "GhostHub/WFS",
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


Window:Tag({Title = "Premiums", Icon = "key-round", Color = Color3.fromHex("#0011ff"), Radius = 6})
Window:Tag({Title = "v.3.0.2", Icon = "", Color = Color3.fromHex("#30ff6a"), Radius = 6})
task.defer(function() Window:SetToggleKey(Enum.KeyCode.LeftControl) end)

local FarmTab       = Window:Tab({ Title = "Farming",     Icon = "swords"    })
local GamemodeTab   = Window:Tab({ Title = "Gamemode",    Icon = "gamepad-2" })
local QuestTab      = Window:Tab({ Title = "Quest",       Icon = "list"      })
local SummonTab     = Window:Tab({ Title = "Summon",      Icon = "star"      })
local UnitTab       = Window:Tab({ Title = "Units",       Icon = "users"     })
local SwordTab      = Window:Tab({ Title = "Swords",      Icon = "sword"  })
local AccessoryTab  = Window:Tab({ Title = "Accessory",   Icon = "gem"       })
local GachaTab      = Window:Tab({ Title = "Gacha",       Icon = "dices"     })
local UpgradeTab    = Window:Tab({ Title = "Upgrade",     Icon = "arrow-up"  })
local ExchangeTab = Window:Tab({ Title = "Exchange", Icon = "arrow-left-right" })
local MiscTab       = Window:Tab({ Title = "Misc",        Icon = "gift"      })
local SettingTab    = Window:Tab({ Title = "Settings",    Icon = "cog"       })

-- ============================================================
--  CONFIG SYSTEM
-- ============================================================
local HttpService = game:GetService("HttpService")
local Options     = {}

local function GetConfigPath()
    return "GhostHub/WFS/" .. tostring(game.Players.LocalPlayer.Name) .. "_WFS.json"
end

local lastSaveRequest = 0
local function SaveConfig()
    lastSaveRequest = tick()
    local snap = lastSaveRequest
    task.delay(1, function()
        if lastSaveRequest ~= snap then return end
        if not (writefile and makefolder) then return end
        local path   = GetConfigPath()
        local folder = path:match("(.+)/")
        if not isfolder(folder) then
            local cur = ""
            for _, p in ipairs(folder:split("/")) do
                cur = cur .. p
                if not isfolder(cur) then makefolder(cur) end
                cur = cur .. "/"
            end
        end
        writefile(path, HttpService:JSONEncode(Options))
    end)
end

local function LoadConfig()
    if not (readfile and isfile) then return end
    local path = GetConfigPath()
    if isfile(path) then
        local ok, result = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if ok and result then
            for k, v in pairs(result) do Options[k] = v end
        end
    end
end
LoadConfig()

-- ============================================================
--  SERVICES & GLOBALS
-- ============================================================
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local RS                 = game:GetService("ReplicatedStorage")
local player             = Players.LocalPlayer

local dataRemoteEvent    = nil
local serverEnemiesWorld = nil

task.spawn(function()
    dataRemoteEvent    = RS:WaitForChild("BridgeNet", 15):WaitForChild("dataRemoteEvent", 15)
    serverEnemiesWorld = workspace:WaitForChild("Server", 15):WaitForChild("Enemies", 15):WaitForChild("World", 15)
end)

-- ============================================================
--  แก้ไข: fireRemote และ leaveGamemode ใช้ format ใหม่
-- ============================================================
local function fireRemote(args)
    if dataRemoteEvent then dataRemoteEvent:FireServer(unpack(args)) end
end

local function leaveGamemode(gamemodeName)
    -- ใช้ format args ใหม่ตามที่กำหนด
    local args = {
        {
            {
                "General",
                "Gamemodes",
                "Leave",
                gamemodeName,
                n = 4
            },
            "\002"
        }
    }
    if dataRemoteEvent then
        dataRemoteEvent:FireServer(unpack(args))
    end
end

-- ============================================================
--  TELEPORT HELPER
-- ============================================================
local function teleportToWorld(worldName, zoneNum)
    if worldName == "Leveling Verse" and zoneNum == 2 then
        local argsSpawn2 = {{{"Player","Teleport","Teleport","Leveling Verse",2,"Spawn2",n=6},"\002"}}
        if dataRemoteEvent then dataRemoteEvent:FireServer(unpack(argsSpawn2)) end
        task.wait(3)   
        local argsMain = {{{"Player","Teleport","Teleport","Leveling Verse",2,n=5},"\002"}}
        if dataRemoteEvent then dataRemoteEvent:FireServer(unpack(argsMain)) end
        task.wait(3)   
    else
        fireRemote({{{"Player","Teleport","Teleport",worldName,zoneNum,n=5},"\002"}})
        task.wait(3)
    end
end

-- ============================================================
--  STATE FLAGS
-- ============================================================
local S = {
    isAttacking          = false,
    isAutoFarm           = false,
    isAutoSummonActive   = false,
    globalBossActive     = false,
    isAutoGlobalBoss     = false,
    isAutoEquip          = false,
    isAutoAwaken         = false,
    isAutoSummon         = false,
    isAutoQuest          = false,
    isAutoReward         = false,
    isAutoAchieve        = false,
    isAutoDailyReward    = false,
    isAutoGacha          = false,
    isAutoFruit          = false,
    isAutoSword          = false,
    isAutoRollRace       = false,
    isAutoRollFightStyle = false,
    isAutoRollClass      = false,
    isAutoRollSlimePower = false,
    isAutoPrimordial     = false,
    isAutoRollFighters   = false,
    isAutoRollCursed     = false,
    isAutoFightStyle     = false,
    isAutoKiProgression  = false,
    isAutoDragonDefense  = false,
    isAutoAura           = false,
    isAutoDemonlord      = false,
    isAutoUpgradeDomain  = false,
    isAutoTempestInvasion= false,
    isReturning          = false,
    isInsideGamemode     = false,
    isAutoTrial          = false,
    isAutoLeaveTrial     = false,
    isInsideTrial        = false,
    isAutoTrialMedium    = false,
    isAutoLeaveTrialMed  = false,
    isInsideTrialMedium  = false,
    isAutoTrialHard      = false,
    isAutoLeaveTrialHard = false,
    isInsideTrialHard    = false,
    isReturningFromMode  = false,
    blackScreenGui       = nil,
    whiteScreenGui       = nil,
}

local selectedGlobalBoss  = Options.SelectedGlobalBoss or "All"
local selectedFarmEnemies = Options.SelectedEnemies or {}
local selectedStar        = Options.SelectedStar or "Dressrosa"
local selectedQuest       = Options.SelectedQuest or ""
local trialTargetWave     = Options.LeaveAtWave or 5
local trialMedTargetWave  = Options.LeaveAtWaveMed or 5
local trialHardTargetWave = Options.LeaveAtWaveHard or 5
local achieveConnections  = {}
local isClaimingAchieve   = false
local isAutoFarmOre       = Options.AutoFarmOre or false

-- ============================================================
--  OMNI DATA
-- ============================================================
local Omni      = nil
local omniReady = false

task.spawn(function()
    local ok, result = pcall(function() return require(RS:WaitForChild("Omni", 15)) end)
    if ok and result then Omni = result end
    omniReady = true
end)

local function getKeyCount(keyName)
    if not Omni then return 0 end
    local ok, n = pcall(function() return Omni.Data.Inventory.Items[keyName] or 0 end)
    return (ok and tonumber(n)) or 0
end

-- ============================================================
--  OMNI SHARED ENEMIES
-- ============================================================
local OMNI_WORLD_ZONES = {
    ["Cursed Verse"] = {"1"},
    ["Dragon Verse"] = {"1","2"},
    ["Fruits Verse"] = {"1","2"},
    ["Slime Verse"]  = {"1","2"},
    ["Hollow Verse"] = {"1"}, 
}
local omniEnemyNameCache = {}

task.spawn(function()
    local waited = 0
    while not omniReady and waited < 15 do task.wait(0.2) waited += 0.2 end
    for worldName, zones in pairs(OMNI_WORLD_ZONES) do
        omniEnemyNameCache[worldName] = {}
        for _, zoneStr in ipairs(zones) do
            local ok, zoneModule = pcall(function()
                return require(RS.Omni.Shared.Enemies[worldName][zoneStr])
            end)
            if ok and type(zoneModule) == "table" then
                local names = {}
                for enemyName in pairs(zoneModule) do table.insert(names, enemyName) end
                omniEnemyNameCache[worldName][zoneStr] = names
            else
                omniEnemyNameCache[worldName][zoneStr] = {}
            end
        end
    end
end)

local function getOmniEnemyNames(worldName, zoneStr)
    if not omniEnemyNameCache[worldName] then return {} end
    return omniEnemyNameCache[worldName][tostring(zoneStr)] or {}
end

-- ============================================================
--  HELPERS — TARGET FINDING
-- ============================================================
local function getClientEnemyTarget(allowedNames)
    local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        and player.Character.HumanoidRootPart.Position) or Vector3.zero
    local ce = workspace:FindFirstChild("Client") and workspace.Client:FindFirstChild("Enemies")
    if not ce then return nil, nil end
    local allowSet = nil
    if allowedNames and #allowedNames > 0 then
        allowSet = {}
        for _, n in ipairs(allowedNames) do allowSet[n] = true end
    end
    local bestTarget, bestID, bestDist = nil, nil, math.huge
    for _, enemy in ipairs(ce:GetChildren()) do
        if not allowSet or allowSet[enemy.Name] then
            local sID = enemy:GetAttribute("ID")
            local dead = enemy:GetAttribute("Died")
            local hp = tonumber(enemy:GetAttribute("Health")) or 0
            if sID and not dead and hp > 0 then
                local pos = enemy:IsA("Model") and enemy:GetPivot().Position
                         or (enemy:IsA("BasePart") and enemy.Position)
                if pos then
                    local d = (pos - myPos).Magnitude
                    if d < bestDist then bestDist=d bestTarget=enemy bestID=sID end
                end
            end
        end
    end
    return bestTarget, bestID
end

local function getServerWorldTarget(allowedNames)
    local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        and player.Character.HumanoidRootPart.Position) or Vector3.zero
    local bestTarget, bestID, bestDist = nil, nil, math.huge
    local sew = workspace:FindFirstChild("Server")
        and workspace.Server:FindFirstChild("Enemies")
        and workspace.Server.Enemies:FindFirstChild("World")
    if not sew then return nil, nil end
    local allowSet = nil
    if allowedNames and #allowedNames > 0 then
        allowSet = {}
        for _, n in ipairs(allowedNames) do allowSet[n] = true end
    end
    for _, wm in ipairs(sew:GetChildren()) do
        for _, g in ipairs(wm:GetChildren()) do
            for _, e in ipairs(g:GetChildren()) do
                if allowSet and not allowSet[e.Name] then continue end
                local sID  = e:GetAttribute("ID")
                local dead = e:GetAttribute("Died")
                local hp   = tonumber(e:GetAttribute("Health")) or 0
                local maxHp= tonumber(e:GetAttribute("MaxHealth")) or 0
                if maxHp > 0 and hp < maxHp then continue end
                if sID and not dead and hp > 0 then
                    local pos = e:IsA("Model") and e:GetPivot().Position
                             or (e:IsA("BasePart") and e.Position)
                    if pos then
                        local d = (pos - myPos).Magnitude
                        if d < bestDist then bestDist=d bestTarget=e bestID=sID end
                    end
                end
            end
        end
    end
    return bestTarget, bestID
end
-- ============================================================
--  HELPERS — WORLD / ZONE / ENEMY
-- ============================================================
local DifficultyRanks = { EASY=1, MEDIUM=2, HARD=3, INSANE=4, BOSS=5, SECRET=6 }

local function getEnemyDifficulty(enemyName)
    local score = 0
    local ok, subtitle = pcall(function()
        return workspace.Client.Enemies[enemyName].Head.EnemyHUD.Main.Subtitle
    end)
    if ok and subtitle then
        local raw = ""
        if subtitle:IsA("TextLabel") or subtitle:IsA("TextBox") then
            raw = subtitle.ContentText ~= "" and subtitle.ContentText or subtitle.Text
        elseif subtitle:IsA("StringValue") then raw = subtitle.Value end
        local up = string.upper(tostring(raw))
        for d, sc in pairs(DifficultyRanks) do
            if string.find(up, d) and sc > score then score = sc end
        end
        if score == 0 then
            local n = string.match(up, "%d+")
            if n then score = tonumber(n) end
        end
    end
    return score
end

local function getCurrentWorldName()
    local char  = player.Character
    local myHRP = char and char:FindFirstChild("HumanoidRootPart")
    if not myHRP then return "", 1 end
    local myPos, shortestDist, bestWorld, bestZone = myHRP.Position, math.huge, "", 1
    for _, worldMap in ipairs(serverEnemiesWorld:GetChildren()) do
        for _, group in ipairs(worldMap:GetChildren()) do
            local e = group:FindFirstChildWhichIsA("Model") or group:FindFirstChildWhichIsA("BasePart")
            if e then
                local pos = e:IsA("Model") and e:GetPivot().Position or e.Position
                if pos then
                    local d = (pos - myPos).Magnitude
                    if d < shortestDist then
                        shortestDist=d bestWorld=worldMap.Name bestZone=tonumber(group.Name) or 1
                    end
                end
            end
        end
    end
    return bestWorld, bestZone
end

local function getWorldsList()
    local t = {}
    for _, w in ipairs(serverEnemiesWorld:GetChildren()) do table.insert(t, w.Name) end
    table.sort(t)
    return t
end

local function getZonesList(worldName)
    local t = {}
    local w = serverEnemiesWorld:FindFirstChild(tostring(worldName))
    if w then for _, g in ipairs(w:GetChildren()) do table.insert(t, g.Name) end end
    table.sort(t, function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end)
    return t
end

local function getEnemiesList(worldName, zoneName)
    local t, d = {}, {}
    local w = serverEnemiesWorld:FindFirstChild(tostring(worldName))
    if w then
        local z = w:FindFirstChild(tostring(zoneName))
        if z then
            for _, e in ipairs(z:GetChildren()) do
                if not d[e.Name] then d[e.Name]=true table.insert(t, e.Name) end
            end
        end
    end
    for _, eName in ipairs(getOmniEnemyNames(worldName, zoneName)) do
        if not d[eName] then d[eName]=true table.insert(t, eName) end
    end
    table.sort(t, function(a, b)
        local da, db = getEnemyDifficulty(a), getEnemyDifficulty(b)
        if da ~= db then return da > db end
        return a < b
    end)
    return t
end

local function getValidTarget()
    local currentWorld = getCurrentWorldName()
    if currentWorld == "" then return nil, nil end
    local allowedNames = (#selectedFarmEnemies > 0) and selectedFarmEnemies or nil
    local target, id = getClientEnemyTarget(allowedNames)
    if target then return target, id end
    local targetWorld = serverEnemiesWorld:FindFirstChild(currentWorld)
    if not targetWorld then return nil, nil end
    local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        and player.Character.HumanoidRootPart.Position) or Vector3.zero
    local bestTarget, bestID, highestDiff, shortestDist = nil, nil, -1, math.huge
    local allowSet = nil
    if allowedNames then
        allowSet = {}
        for _, n in ipairs(allowedNames) do allowSet[n] = true end
    end
    for _, group in ipairs(targetWorld:GetChildren()) do
        for _, e in ipairs(group:GetChildren()) do
            local isDead = e:GetAttribute("Died")
            local hp = tonumber(e:GetAttribute("Health")) or 0
            if not isDead and hp > 0 then
                if not allowSet or allowSet[e.Name] then
                    local sID = e:GetAttribute("ID")
                    if sID then
                        local pos = e:IsA("Model") and e:GetPivot().Position or (e:IsA("BasePart") and e.Position)
                        if pos then
                            local dist = (pos - myPos).Magnitude
                            local diff = getEnemyDifficulty(e.Name)
                            if diff > highestDiff or (diff == highestDiff and dist < shortestDist) then
                                highestDiff=diff shortestDist=dist bestTarget=e bestID=sID
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget, bestID
end
-- ============================================================
-- =================  Hard+ enemies  ==========================
-- ============================================================
local function getHardPlusEnemyNames(worldName, zoneStr)
    local result = {}
    local hardMinScore = DifficultyRanks["HARD"] -- = 3
    local ok, zoneFolder = pcall(function()
        return workspace.Server.Enemies.World[worldName][tostring(zoneStr)]
    end)
    if ok and zoneFolder then
        local seen = {}
        for _, e in ipairs(zoneFolder:GetChildren()) do
            if not seen[e.Name] then
                seen[e.Name] = true
                local diff = getEnemyDifficulty(e.Name)
                if diff >= hardMinScore then
                    table.insert(result, e.Name)
                end
            end
        end
    end
    if #result == 0 then
        for _, eName in ipairs(getOmniEnemyNames(worldName, zoneStr)) do
            local diff = getEnemyDifficulty(eName)
            if diff >= hardMinScore then
                table.insert(result, eName)
            end
        end
    end
    return result
end
local function farmHollowKey(stopFn, targetCount)
    targetCount = targetCount or 10
    S.isInsideGamemode = true
    teleportToWorld("Hollow Verse", 1)
    task.wait(3)

    local allowedNames = getHardPlusEnemyNames("Hollow Verse", "1")
    if #allowedNames == 0 then
        task.wait(3)
        allowedNames = getHardPlusEnemyNames("Hollow Verse", "1")
    end

    WindUI:Notify({
        Title = "⚔ Hollow Key Farm",
        Content = "Farming Hard+ enemies at Hollow Verse Z1 (need "..targetCount..")\nTargets: "..(#allowedNames > 0 and table.concat(allowedNames, ", ") or "Any"),
        Duration = 5
    })

    while getKeyCount("Hollow Key") < targetCount and stopFn() do
        if S.globalBossActive then
            S.isInsideGamemode = false
            WindUI:Notify({ Title="⚔ Hollow Farm Paused", Content="Global Boss! Pausing...", Duration=3 })
            while S.globalBossActive and stopFn() do task.wait(1) end
            if not stopFn() then break end
            WindUI:Notify({ Title="⚔ Hollow Farm Resumed", Content="Resuming...", Duration=3 })
            S.isInsideGamemode = true
            teleportToWorld("Hollow Verse", 1)
            task.wait(3)
            allowedNames = getHardPlusEnemyNames("Hollow Verse", "1")
        end
        pcall(function()
            local best, bestID = getClientEnemyTarget(#allowedNames > 0 and allowedNames or nil)
            if not best then
                local ok2, zoneFolder = pcall(function()
                    return workspace.Server.Enemies.World["Hollow Verse"]["1"]
                end)
                if ok2 and zoneFolder then
                    local myPos2 = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        and player.Character.HumanoidRootPart.Position) or Vector3.zero
                    local allowSet = nil
                    if #allowedNames > 0 then
                        allowSet = {}
                        for _, n in ipairs(allowedNames) do allowSet[n] = true end
                    end
                    local bestD = math.huge
                    for _, e in ipairs(zoneFolder:GetChildren()) do
                        if allowSet and not allowSet[e.Name] then continue end
                        local isDead, hp = e:GetAttribute("Died"), e:GetAttribute("Health")
                        if not isDead and (not hp or tonumber(hp) > 0) then
                            local sID = e:GetAttribute("ID")
                            if sID then
                                local p = e:IsA("Model") and e:GetPivot().Position or (e:IsA("BasePart") and e.Position)
                                if p then
                                    local dd = (p - myPos2).Magnitude
                                    if dd < bestD then bestD=dd best=e bestID=sID end
                                end
                            end
                        end
                    end
                end
            end
            if not best then task.wait(0.5) return end
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local tPos = best:IsA("Model") and best:GetPivot() or (best:IsA("BasePart") and best.CFrame)
            if hrp and tPos then hrp.CFrame = tPos * CFrame.new(0,3,0) end
            while best and best.Parent and getKeyCount("Hollow Key") < targetCount and stopFn() do
                if S.globalBossActive then break end
                local isDead, hp = best:GetAttribute("Died"), best:GetAttribute("Health")
                if isDead or (hp and tonumber(hp) <= 0) then break end
                local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if curHRP then
                    local tCF = best:IsA("Model") and best:GetPivot() or (best:IsA("BasePart") and best.CFrame)
                    if tCF and (curHRP.Position - tCF.Position).Magnitude > 8 then
                        curHRP.CFrame = tCF * CFrame.new(0,3,0)
                    end
                end
                if bestID and not S.isAttacking then
                    fireRemote({{{ "General","Attack","Click",{ [tostring(bestID)]=true }, n=4 }, "\002" }})
                end
                task.wait(0.2)
            end
        end)
    end
    if getKeyCount("Hollow Key") >= targetCount then
        WindUI:Notify({ Title="✅ Hollow Key x"..math.floor(getKeyCount("Hollow Key")), Content="Done!", Duration=3 })
    end
    S.isInsideGamemode = false
end

-- ============================================================
--  HELPERS — QUEST
-- ============================================================
local questModules, questNames = {}, {}
local questsReady = false

task.spawn(function()
    local waited = 0
    while not omniReady and waited < 15 do task.wait(0.2) waited += 0.2 end
    local ok, qf = pcall(function() return RS.Omni.Shared.Quests.Main end)
    if ok and qf then
        for _, c in pairs(qf:GetChildren()) do
            questModules[c.Name] = c
            table.insert(questNames, c.Name)
        end
        table.sort(questNames)
        if selectedQuest == "" then selectedQuest = questNames[1] or "" end
    end
    questsReady = true
end)

local function getQuestData(name)
    if not questModules[name] then return nil end
    local ok, m = pcall(function() return require(questModules[name]) end)
    return (ok and m) and m or nil
end

local function getSlotProgress(slot)
    local ok, title = pcall(function()
        return player.PlayerGui.UI.HUD.Quests.List[slot].Progress.Title
    end)
    if not ok or not title then return 0, 0 end
    local c, m = title.ContentText:match("%[(%d+)/(%d+)%]")
    return tonumber(c) or 0, tonumber(m) or 0
end

local function isSlotDone(slot)
    local c, m = getSlotProgress(slot)
    return m > 0 and c >= m
end

local function getTargetEnemyFromQuest(slot)
    local ok, desc = pcall(function()
        return player.PlayerGui.UI.HUD.Quests.List[slot].Description.ContentText
    end)
    if not (ok and desc) then return nil end
    local best, bestLen = nil, 0
    for _, wm in ipairs(serverEnemiesWorld:GetChildren()) do
        for _, g in ipairs(wm:GetChildren()) do
            for _, e in ipairs(g:GetChildren()) do
                if string.find(desc, e.Name, 1, true) and #e.Name > bestLen then
                    best = e.Name bestLen = #e.Name
                end
            end
        end
    end
    return best
end

local function getQuestTarget(targetName)
    local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        and player.Character.HumanoidRootPart.Position) or Vector3.zero
    local bestTarget, bestID, bestWorld, bestZone, shortestDist = nil, nil, nil, nil, math.huge
    local ce = workspace:FindFirstChild("Client") and workspace.Client:FindFirstChild("Enemies")
    if ce then
        for _, child in ipairs(ce:GetChildren()) do
            if child.Name == targetName then
                local isDead, hp = child:GetAttribute("Died"), child:GetAttribute("Health")
                if not isDead and (not hp or tonumber(hp) > 0) then
                    local sID = child:GetAttribute("ID")
                    if sID then
                        local pos = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                        if pos then
                            local d = (pos - myPos).Magnitude
                            if d < shortestDist then shortestDist=d bestTarget=child bestID=sID end
                        end
                    end
                end
            end
        end
    end
    if not bestTarget then
        for _, wm in ipairs(serverEnemiesWorld:GetChildren()) do
            for _, g in ipairs(wm:GetChildren()) do
                for _, e in ipairs(g:GetChildren()) do
                    if e.Name == targetName then
                        local isDead, hp = e:GetAttribute("Died"), e:GetAttribute("Health")
                        if not isDead and (not hp or tonumber(hp) > 0) then
                            local sID = e:GetAttribute("ID")
                            if sID then
                                local pos = e:IsA("Model") and e:GetPivot().Position or e.Position
                                if pos then
                                    local d = (pos - myPos).Magnitude
                                    if d < shortestDist then
                                        shortestDist=d bestTarget=e bestID=sID
                                        bestWorld=wm.Name bestZone=tonumber(g.Name) or 1
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return bestTarget, bestID, bestWorld, bestZone
end

-- ============================================================
--  HELPERS — STAR / PASSIVE
-- ============================================================
local function teleportToStar(starName)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local ok, sm = pcall(function() return workspace.Server.Stars[starName] end)
    if not (ok and sm) then
        WindUI:Notify({ Title = "Teleport Failed", Content = "Star not found: " .. tostring(starName), Duration = 3 })
        return
    end
    local ok2, cf = pcall(function() return sm:GetPivot() end)
    if ok2 and cf then hrp.CFrame = cf * CFrame.new(0, 5, 0) end
end

-- ============================================================
--  PASSIVE PUNKS DATA
-- ============================================================
local PassivePunksData = {}
local passiveDataReady = false

task.spawn(function()
    local ok, data = pcall(function() return require(RS.Omni.Shared.PassivePunks) end)
    if ok and type(data) == "table" then PassivePunksData = data end
    passiveDataReady = true
end)

-- ============================================================
--  ENCHANT PUNKS DATA
-- ============================================================
local EnchantPunksData = {}
local enchantDataReady = false

task.spawn(function()
    local ok, data = pcall(function()
        return require(RS:WaitForChild("Omni",15):WaitForChild("Shared",10):WaitForChild("EnchantPunks",10))
    end)
    if ok and type(data) == "table" then EnchantPunksData = data end
    enchantDataReady = true
end)

local selectedUnitUID        = ""
local selectedTargetPassive  = ""
local selectedEnchantUnitUID = ""
local selectedTargetEnchant  = ""

-- ============================================================
--  PASSIVE / ENCHANT ORDERED LIST
-- ============================================================
local passiveOrderedList = {}
local function buildPassiveOrderedList()
    passiveOrderedList = {}
    local tmp = {}
    for name, data in pairs(PassivePunksData) do
        table.insert(tmp, { name=name, index=(type(data)=="table" and tonumber(data.Index)) or 999 })
    end
    table.sort(tmp, function(a,b) if a.index~=b.index then return a.index<b.index end return a.name<b.name end)
    for _, entry in ipairs(tmp) do table.insert(passiveOrderedList, entry.name) end
end

local function getPassiveCraftText(passiveName)
    if passiveName == "" then return "Select a Passive to view its recipe." end
    local config = PassivePunksData[passiveName]
    if not config then return "No data found for: " .. passiveName end
    local rarity = config.Rarity or "Unknown"
    if not config.Items or #config.Items == 0 then
        return "[ " .. passiveName .. " ] (" .. rarity .. ")\nNo materials required."
    end
    local lines = { "[ " .. passiveName .. " ] (" .. rarity .. ")", "" }
    for _, item in ipairs(config.Items) do
        local itemName = item.Name or "?"
        local required = tonumber(item.Amount) or 0
        local have = 0
        pcall(function() have = tonumber(Omni.Data.Inventory.Items[itemName]) or 0 end)
        local status = have >= required and "[OK]" or "[--]"
        table.insert(lines, string.format("%s  %s  x%d  (have: %d)", status, itemName, required, have))
    end
    return table.concat(lines, "\n")
end

local enchantOrderedList = {}
local function buildEnchantOrderedList()
    enchantOrderedList = {}
    local tmp = {}
    for name, data in pairs(EnchantPunksData) do
        table.insert(tmp, { name=name, index=(type(data)=="table" and tonumber(data.Index)) or 999 })
    end
    table.sort(tmp, function(a,b) if a.index~=b.index then return a.index<b.index end return a.name<b.name end)
    for _, entry in ipairs(tmp) do table.insert(enchantOrderedList, entry.name) end
end

local function getEnchantCraftText(enchantName)
    if enchantName == "" then return "Select an Enchant to view its recipe." end
    local config = EnchantPunksData[enchantName]
    if not config then return "No data found for: " .. enchantName end
    local rarity = config.Rarity or "Unknown"
    if not config.Items or #config.Items == 0 then
        return "[ " .. enchantName .. " ] (" .. rarity .. ")\nNo materials required."
    end
    local lines = { "[ " .. enchantName .. " ] (" .. rarity .. ")", "" }
    for _, item in ipairs(config.Items) do
        local itemName = item.Name or "?"
        local required = tonumber(item.Amount) or 0
        local have = 0
        pcall(function() have = tonumber(Omni.Data.Inventory.Items[itemName]) or 0 end)
        local status = have >= required and "[OK]" or "[--]"
        table.insert(lines, string.format("%s  %s  x%d  (have: %d)", status, itemName, required, have))
    end
    return table.concat(lines, "\n")
end

-- ============================================================
--  UNIT LIST HELPERS
-- ============================================================
local unitUIDMap = {}

local function getUnitList()
    local units = {}
    unitUIDMap = {}
    if not Omni then return { "Loading..." } end
    pcall(function()
        local inv = Omni.Data.Inventory.Units
        local baseUnitsData = Omni.Shared.Units.List
        if type(inv) == "table" then
            local nameCount = {}
            for uid, ud in pairs(inv) do
                if type(ud) == "table" then
                    local name = ud.CustomName or ud.Name or "Unknown"
                    local rarity = "Unknown"
                    if baseUnitsData and baseUnitsData[ud.Name] then
                        rarity = baseUnitsData[ud.Name].Rarity or "Unknown"
                    end
                    local equipTag = ud.Equipped and "[✔] " or ""
                    local buffs = ud.RenameBuffs or {}
                    local p = tonumber(buffs["Power"]) or 0
                    local d = tonumber(buffs["Damage"]) or 0
                    local c = tonumber(buffs["Crystals"]) or 0
                    local base = string.format("%s[%s] %s [P:%.2f, D:%.2f, C:%.2f]", equipTag, rarity, name, p, d, c)
                    nameCount[base] = (nameCount[base] or 0) + 1
                    local displayName = base .. " #" .. nameCount[base]
                    table.insert(units, displayName)
                    unitUIDMap[displayName] = uid
                end
            end
        end
    end)
    if #units == 0 then table.insert(units, "No Units Found") end
    table.sort(units)
    return units
end

local function getUnitListSimple()
    local units = {}
    unitUIDMap = {}
    if not Omni then return { "Loading..." } end
    pcall(function()
        local inv = Omni.Data.Inventory.Units
        local baseUnitsData = Omni.Shared.Units.List
        if type(inv) == "table" then
            local nameCount = {}
            for uid, ud in pairs(inv) do
                if type(ud) == "table" then
                    local name = ud.CustomName or ud.Name or "Unknown"
                    local rarity = "Unknown"
                    if baseUnitsData and baseUnitsData[ud.Name] then
                        rarity = baseUnitsData[ud.Name].Rarity or "Unknown"
                    end
                    local equipTag = ud.Equipped and "[✔] " or ""
                    local base = string.format("%s[%s] %s", equipTag, rarity, name)
                    nameCount[base] = (nameCount[base] or 0) + 1
                    local displayName = base .. " #" .. nameCount[base]
                    table.insert(units, displayName)
                    unitUIDMap[displayName] = uid
                end
            end
        end
    end)
    if #units == 0 then table.insert(units, "No Units Found") end
    table.sort(units)
    return units
end

-- ============================================================
--  HELPER — FARM UNTIL KEY
-- ============================================================
local function farmUntilKey(keyName, worldName, zoneNum, stopFn, targetCount)
    targetCount = targetCount or 1
    S.isInsideGamemode = true

    teleportToWorld(worldName, zoneNum)
    task.wait(3)

    WindUI:Notify({ Title = "⚔ Key Farming", Content = "Farming "..keyName.." at "..worldName.." Zone "..zoneNum.." (need "..targetCount..")", Duration = 4 })
    local allowedNames = getOmniEnemyNames(worldName, tostring(zoneNum))
    while getKeyCount(keyName) < targetCount and stopFn() do
        if S.globalBossActive then
            S.isInsideGamemode = false
            WindUI:Notify({ Title = "⚔ Key Farm Paused", Content = "Global Boss! Pausing key farm...", Duration = 3 })
            while S.globalBossActive and stopFn() do task.wait(1) end
            if not stopFn() then break end
            WindUI:Notify({ Title = "⚔ Key Farm Resumed", Content = "Boss done! Resuming...", Duration = 3 })
            S.isInsideGamemode = true
            teleportToWorld(worldName, zoneNum)
            task.wait(3)
        end
        pcall(function()
            local best, bestID = getClientEnemyTarget(#allowedNames > 0 and allowedNames or nil)
            if not best then
                local ok2, zoneFolder = pcall(function()
                    return workspace.Server.Enemies.World[worldName][tostring(zoneNum)]
                end)
                if ok2 and zoneFolder then
                    local myPos2 = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        and player.Character.HumanoidRootPart.Position) or Vector3.zero
                    local bestD = math.huge
                    for _, e in ipairs(zoneFolder:GetChildren()) do
                        local isDead, hp = e:GetAttribute("Died"), e:GetAttribute("Health")
                        if not isDead and (not hp or tonumber(hp) > 0) then
                            local sID = e:GetAttribute("ID")
                            if sID then
                                local p = e:IsA("Model") and e:GetPivot().Position or (e:IsA("BasePart") and e.Position)
                                if p then
                                    local dd = (p - myPos2).Magnitude
                                    if dd < bestD then bestD=dd best=e bestID=sID end
                                end
                            end
                        end
                    end
                end
            end
            if not best then task.wait(0.5) return end
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local tPos = best:IsA("Model") and best:GetPivot() or (best:IsA("BasePart") and best.CFrame)
            if hrp and tPos then hrp.CFrame = tPos * CFrame.new(0, 3, 0) end
            while best and best.Parent and getKeyCount(keyName) < targetCount and stopFn() do
                if S.globalBossActive then break end
                local isDead, hp = best:GetAttribute("Died"), best:GetAttribute("Health")
                if isDead or (hp and tonumber(hp) <= 0) then break end
                local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if curHRP then
                    local tCF = best:IsA("Model") and best:GetPivot() or (best:IsA("BasePart") and best.CFrame)
                    if tCF and (curHRP.Position - tCF.Position).Magnitude > 8 then
                        curHRP.CFrame = tCF * CFrame.new(0, 3, 0)
                    end
                end
                if bestID and not S.isAttacking then
                    fireRemote({{{ "General","Attack","Click",{ [tostring(bestID)]=true }, n=4 }, "\002" }})
                end
                task.wait(0.2)
            end
        end)
    end
    if getKeyCount(keyName) >= targetCount then
        WindUI:Notify({ Title = "✅ Key Obtained!", Content = keyName.." x"..math.floor(getKeyCount(keyName)).." — Done!", Duration = 3 })
    end
    S.isInsideGamemode = false
end

-- ============================================================
--  TAB: FARMING
-- ============================================================
local selectedFarmWorld = Options.SelectedFarmWorld or getWorldsList()[1] or ""
local selectedFarmZone  = Options.SelectedFarmZone  or getZonesList(selectedFarmWorld)[1] or ""
local WorldDropdown, ZoneDropdown, EnemyDropdown

FarmTab:Section({ Title = "Map & Enemy Selection" })

WorldDropdown = FarmTab:Dropdown({
    Title="Select World", Icon="globe", Values=getWorldsList(), Value=selectedFarmWorld,
    Callback = function(v)
        selectedFarmWorld = v Options.SelectedFarmWorld = v SaveConfig()
        local newZones = getZonesList(v)
        if ZoneDropdown then ZoneDropdown:Refresh(newZones) end
        if not table.find(newZones, selectedFarmZone) then
            selectedFarmZone = newZones[1] or "" Options.SelectedFarmZone = selectedFarmZone SaveConfig()
        end
        if EnemyDropdown then EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone)) end
    end
})

ZoneDropdown = FarmTab:Dropdown({
    Title="Select Zone", Icon="map-pin", Values=getZonesList(selectedFarmWorld), Value=selectedFarmZone,
    Callback = function(v)
        selectedFarmZone = v Options.SelectedFarmZone = v SaveConfig()
        if EnemyDropdown then EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone)) end
    end
})

EnemyDropdown = FarmTab:Dropdown({
    Title="Select Enemies", Icon="target", Values=getEnemiesList(selectedFarmWorld, selectedFarmZone),
    Value=selectedFarmEnemies, Multi=true,AllowNone = true,
    Callback = function(v)
        selectedFarmEnemies = type(v)=="table" and v or (type(v)=="string" and {v} or {})
        Options.SelectedEnemies = selectedFarmEnemies SaveConfig()
    end
})

FarmTab:Button({
    Title="Refresh Maps & Enemies", Icon="refresh-cw",
    Callback = function()
        WorldDropdown:Refresh(getWorldsList())
        ZoneDropdown:Refresh(getZonesList(selectedFarmWorld))
        EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone))
        WindUI:Notify({ Title="Updated", Content="Map & Enemy list refreshed!", Duration=2 })
    end
})

FarmTab:Divider()

FarmTab:Toggle({
    Title="Auto Farm", Icon="crosshair", Desc="Teleport to nearest allowed enemy and farm",
    Type="Checkbox", Value=Options.AutoFarm or false,
    Callback = function(v)
        S.isAutoFarm = v Options.AutoFarm = v SaveConfig()
        if S.isAutoFarm then
            task.spawn(function()
                local lastDeadID, lastDeadTime = nil, 0

                local function hasLiveOre()
                    if not isAutoFarmOre then return false end
                    if S.globalBossActive then return false end
                    local sores = workspace:FindFirstChild("Server")
                        and workspace.Server:FindFirstChild("Enemies")
                        and workspace.Server.Enemies:FindFirstChild("Ores")
                    if not sores then return false end
                    for _, ore in ipairs(sores:GetChildren()) do
                        if not ore:GetAttribute("Died") and (tonumber(ore:GetAttribute("Health")) or 0) > 0 then
                            return true
                        end
                        for _, child in ipairs(ore:GetChildren()) do
                            if not child:GetAttribute("Died") and (tonumber(child:GetAttribute("Health")) or 0) > 0 then
                                return true
                            end
                        end
                    end
                    return false
                end

                while S.isAutoFarm do
                if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard
                    or S.isInsideGamemode or S.isReturning or S.isAutoSummonActive or S.globalBossActive
                    or S.isAutoDragonDefense or S.isAutoTempestInvasion
                    then
                        task.wait(1) continue
                    end

                    if hasLiveOre() then task.wait(0.3) continue end

                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local target, id = getValidTarget()
                        if id and id == lastDeadID then
                            if tick() - lastDeadTime < 3 then task.wait(0.5) continue
                            else lastDeadID = nil end
                        end
                        if target and id then
                            local tCF = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                            if tCF and (hrp.Position - tCF.Position).Magnitude > 8 then hrp.CFrame = tCF * CFrame.new(0,3,0) end

                            while S.isAutoFarm and not S.isInsideTrial and not S.isInsideTrialMedium
                            and not S.isInsideTrialHard and not S.isInsideGamemode and not S.isReturning
                            and not S.isAutoSummonActive and not S.globalBossActive
                            and not S.isAutoDragonDefense and not S.isAutoTempestInvasion
                            and target and target.Parent do

                                if hasLiveOre() then break end
                                if S.isReturning then break end

                                local isDead = target:GetAttribute("Died")
                                local hp     = target:GetAttribute("Health")
                                if isDead or (hp and tonumber(hp) <= 0) then
                                    lastDeadID=id lastDeadTime=tick() break
                                end
                                local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if curHRP then
                                    local tCF2 = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                                    if tCF2 and (curHRP.Position - tCF2.Position).Magnitude > 8 then curHRP.CFrame = tCF2 * CFrame.new(0,3,0) end
                                end
                                if not S.isAttacking and id then
                                    fireRemote({{{ "General","Attack","Click",{ [tostring(id)]=true }, n=4 }, "\002" }})
                                    task.wait(0.2)
                                else task.wait(0.1) end
                            end
                        else task.wait(0.5) end
                    else task.wait(0.5) end
                end
            end)
        end
    end
})

-- Auto farm ore
FarmTab:Toggle({
    Title="Auto Farm Ore", Icon="gem", Desc="",
    Type="Checkbox", Value=Options.AutoFarmOre or false,
    Callback = function(v)
        isAutoFarmOre=v Options.AutoFarmOre=v SaveConfig()
        if isAutoFarmOre then
            task.spawn(function()
                while isAutoFarmOre do
                    if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard
                    or S.isInsideGamemode or S.globalBossActive or S.isReturning then
                        task.wait(1) continue
                    end
                    pcall(function()
                        local sores = workspace:FindFirstChild("Server")
                            and workspace.Server:FindFirstChild("Enemies")
                            and workspace.Server.Enemies:FindFirstChild("Ores")
                        if not sores then task.wait(1) return end
                        local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            and player.Character.HumanoidRootPart.Position) or Vector3.zero
                        local bestTarget, bestID, bestDist = nil, nil, math.huge
                        for _, ore in ipairs(sores:GetChildren()) do
                            local sID  = ore:GetAttribute("ID")
                            local dead = ore:GetAttribute("Died")
                            local hp   = tonumber(ore:GetAttribute("Health")) or 0
                            if sID and not dead and hp > 0 then
                                local pos = ore:IsA("Model") and ore:GetPivot().Position
                                         or (ore:IsA("BasePart") and ore.Position)
                                if pos then
                                    local d = (pos - myPos).Magnitude
                                    if d < bestDist then bestDist=d bestTarget=ore bestID=sID end
                                end
                            end
                            for _, child in ipairs(ore:GetChildren()) do
                                local cID   = child:GetAttribute("ID")
                                local cDead = child:GetAttribute("Died")
                                local cHp   = tonumber(child:GetAttribute("Health")) or 0
                                if cID and not cDead and cHp > 0 then
                                    local pos = child:IsA("BasePart") and child.Position
                                    if pos then
                                        local d = (pos - myPos).Magnitude
                                        if d < bestDist then bestDist=d bestTarget=child bestID=cID end
                                    end
                                end
                            end
                        end
                        if bestTarget and bestID then
                            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp and bestDist > 10 then
                                local tCF = bestTarget:IsA("Model") and bestTarget:GetPivot()
                                         or (bestTarget:IsA("BasePart") and bestTarget.CFrame)
                                if tCF then hrp.CFrame = tCF * CFrame.new(0,3,0) end
                            end
                            fireRemote({{{ "General","Attack","Click",{ [tostring(bestID)]=true }, n=4 }, "\002" }})
                        end
                    end)
                    task.wait(0.15)
                end
            end)
        end
    end
})

-- ============================================================
--  แก้ไข: Auto Fast Clicker — ตีหลายตัวพร้อมกัน (Multi-target)
-- ============================================================
FarmTab:Toggle({
    Title="Auto Fast Clicker", Icon="sword", Type="Checkbox", Value=Options.AutoFastClicker or false,
    Callback = function(v)
        S.isAttacking = v Options.AutoFastClicker = v SaveConfig()
        if S.isAttacking then
            task.spawn(function()
                while S.isAttacking do
                    pcall(function()
                        -- เก็บ ID ทุกตัวที่มีชีวิตในระยะ (multi-target)
                        local targetIDs = {}
                        local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            and player.Character.HumanoidRootPart.Position) or Vector3.zero

                        local function collectTarget(node)
                            local sID = node:GetAttribute("ID")
                            if sID and not node:GetAttribute("Died") then
                                local hp = node:GetAttribute("Health")
                                if not hp or tonumber(hp) > 0 then
                                    local pos = node:IsA("Model") and node:GetPivot().Position
                                             or (node:IsA("BasePart") and node.Position)
                                    if pos then
                                        targetIDs[tostring(sID)] = true
                                    end
                                end
                            end
                        end

                        -- Client Enemies
                        local ce = workspace:FindFirstChild("Client") and workspace.Client:FindFirstChild("Enemies")
                        if ce then
                            for _, e in ipairs(ce:GetChildren()) do
                                collectTarget(e)
                                if e:IsA("Folder") or e:IsA("Model") then
                                    for _, sub in ipairs(e:GetChildren()) do collectTarget(sub) end
                                end
                            end
                        end

                        -- Server World Enemies
                        local sew = workspace:FindFirstChild("Server")
                            and workspace.Server:FindFirstChild("Enemies")
                            and workspace.Server.Enemies:FindFirstChild("World")
                        if sew then
                            for _, wm in ipairs(sew:GetChildren()) do
                                for _, g in ipairs(wm:GetChildren()) do
                                    for _, e in ipairs(g:GetChildren()) do collectTarget(e) end
                                end
                            end
                        end

                        -- Gamemodes
                        local sg = workspace:FindFirstChild("Server")
                            and workspace.Server:FindFirstChild("Enemies")
                            and workspace.Server.Enemies:FindFirstChild("Gamemodes")
                        if sg then
                            for _, gm in ipairs(sg:GetChildren()) do
                                for _, e in ipairs(gm:GetChildren()) do
                                    collectTarget(e)
                                    if e:IsA("Folder") or e:IsA("Model") then
                                        for _, sub in ipairs(e:GetChildren()) do collectTarget(sub) end
                                    end
                                end
                            end
                        end

                        -- Global Bosses
                        local sgb = workspace:FindFirstChild("Server")
                            and workspace.Server:FindFirstChild("Enemies")
                            and workspace.Server.Enemies:FindFirstChild("Global Bosses")
                        if sgb then
                            for _, boss in ipairs(sgb:GetChildren()) do
                                collectTarget(boss)
                                for _, child in ipairs(boss:GetChildren()) do collectTarget(child) end
                            end
                        end

                        -- Ores
                        local sores = workspace:FindFirstChild("Server")
                            and workspace.Server:FindFirstChild("Enemies")
                            and workspace.Server.Enemies:FindFirstChild("Ores")
                        if sores then
                            for _, ore in ipairs(sores:GetChildren()) do
                                collectTarget(ore)
                                for _, child in ipairs(ore:GetChildren()) do collectTarget(child) end
                            end
                        end

                        -- ยิง remote ครั้งเดียวพร้อมทุก ID (multi-target)
                        if next(targetIDs) then
                            fireRemote({{{ "General","Attack","Click", targetIDs, n=4 }, "\002" }})
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end
})

serverEnemiesWorld.ChildAdded:Connect(function()
    task.wait(0.5)
    if WorldDropdown then WorldDropdown:Refresh(getWorldsList()) end
    if ZoneDropdown  then ZoneDropdown:Refresh(getZonesList(selectedFarmWorld)) end
    if EnemyDropdown then EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone)) end
end)
serverEnemiesWorld.ChildRemoved:Connect(function()
    task.wait(0.5)
    if WorldDropdown then WorldDropdown:Refresh(getWorldsList()) end
    if ZoneDropdown  then ZoneDropdown:Refresh(getZonesList(selectedFarmWorld)) end
    if EnemyDropdown then EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone)) end
end)

task.spawn(function()
    local lastWorld, lastZone = "", 0
    while true do
        task.wait(3)
        local cw, cz = getCurrentWorldName()
        if cw ~= "" and (cw ~= lastWorld or cz ~= lastZone) then
            lastWorld, lastZone = cw, cz
            local wl = getWorldsList()
            if table.find(wl, cw) then
                selectedFarmWorld = cw Options.SelectedFarmWorld = cw SaveConfig()
                if WorldDropdown then WorldDropdown:Refresh(wl) end
                local zl = getZonesList(cw)
                local zs = tostring(cz)
                if table.find(zl, zs) then
                    selectedFarmZone = zs Options.SelectedFarmZone = zs SaveConfig()
                end
                if ZoneDropdown  then ZoneDropdown:Refresh(zl) end
                if EnemyDropdown then EnemyDropdown:Refresh(getEnemiesList(selectedFarmWorld, selectedFarmZone)) end
            end
        end
    end
end)

-- ============================================================
--  GLOBAL BOSS
-- ============================================================
local globalBossFolder      = nil
local globalBossRespawnData = {}

task.spawn(function()
    local ok, f = pcall(function()
        return workspace:WaitForChild("Server",15):WaitForChild("Enemies",15):WaitForChild("Global Bosses",15)
    end)
    if ok and f then globalBossFolder = f end
end)

task.spawn(function()
    local waited = 0
    while not omniReady and waited < 15 do task.wait(0.2) waited += 0.2 end
    local ok, gbModule = pcall(function()
        return require(RS:WaitForChild("Omni",15):WaitForChild("Shared",10):WaitForChild("GlobalBosses",10))
    end)
    if ok and type(gbModule) == "table" then
        local list = gbModule.List or gbModule
        for bossName, data in pairs(list) do
            if type(data) == "table" then
                local r = tonumber(data["Respawn"]) or tonumber(data.Respawn)
                if r then globalBossRespawnData[bossName] = r end
            end
        end
    end
end)

local GlobalBossDropdown = nil

local function getGlobalBossList()
    local names = {"All"}
    if globalBossFolder then
        for _, boss in ipairs(globalBossFolder:GetChildren()) do
            if not table.find(names, boss.Name) then table.insert(names, boss.Name) end
        end
    end
    for bossName in pairs(globalBossRespawnData) do
        if not table.find(names, bossName) then table.insert(names, bossName) end
    end
    table.sort(names, function(a, b)
        if a == "All" then return true end
        if b == "All" then return false end
        return a < b
    end)
    return names
end

local function checkBossExists()
    if not globalBossFolder then return false end
    for _, boss in ipairs(globalBossFolder:GetChildren()) do
        if selectedGlobalBoss ~= "All" and boss.Name ~= selectedGlobalBoss then continue end
        local loaded = boss:GetAttribute("Loaded")
        local hp     = tonumber(boss:GetAttribute("Health")) or 0
        if loaded == true and hp > 0 then return true end
    end
    return false
end

local function getBestGlobalBossTarget()
    if not globalBossFolder then return nil, nil end
    local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        and player.Character.HumanoidRootPart.Position) or Vector3.zero
    local bestTarget, bestID, bestDist = nil, nil, math.huge

    for _, boss in ipairs(globalBossFolder:GetChildren()) do
        if selectedGlobalBoss ~= "All" and boss.Name ~= selectedGlobalBoss then continue end
        local loaded = boss:GetAttribute("Loaded")
        local hp     = tonumber(boss:GetAttribute("Health")) or 0
        local sID    = boss:GetAttribute("ID")
        if loaded == true and hp > 0 and sID then
            local pos = boss:IsA("Model") and boss:GetPivot().Position or (boss:IsA("BasePart") and boss.Position)
            if pos then
                local d = (pos - myPos).Magnitude
                if d < bestDist then bestDist=d bestTarget=boss bestID=sID end
            end
        end
    end

    if not bestTarget then
        local ce = workspace:FindFirstChild("Client") and workspace.Client:FindFirstChild("Enemies")
        if ce then
            local knownBossNames = { Sakana=true, Satoro=true, Yuje=true,
                ["Sakana Part"]=true, ["Satoro Part"]=true, ["Yuje Part"]=true }
            for _, child in ipairs(ce:GetDescendants()) do
                local sID  = child:GetAttribute("ID")
                local dead = child:GetAttribute("Died")
                local hp   = tonumber(child:GetAttribute("Health")) or 0
                if sID and not dead and hp > 0 then
                    local nameMatch = false
                    if selectedGlobalBoss == "All" then
                        nameMatch = knownBossNames[child.Name] ~= nil
                    else
                        nameMatch = child.Name == selectedGlobalBoss
                            or string.find(child.Name, selectedGlobalBoss, 1, true) ~= nil
                    end
                    if nameMatch then
                        local pos = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                        if pos then
                            local d = (pos - myPos).Magnitude
                            if d < bestDist then bestDist=d bestTarget=child bestID=sID end
                        end
                    end
                end
            end
        end
    end
    return bestTarget, bestID
end

local bossWorldMap = {
    ["Satoro"] = { world="Cursed Verse", zone=2, fallbackCF=CFrame.new(10810.6367, 659.341309, -5019.60352, 0.682592869, 0, 0.73079896, 0, 1, 0, -0.73079896, 0, 0.682592869) },
    ["Sakana"] = { world="Cursed Verse", zone=2, fallbackCF=CFrame.new(10572.9756, 659.354675, -5189.31104, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
    ["Yuje"]   = { world="Cursed Verse", zone=2, fallbackCF=CFrame.new(10873.502, 773.154114, -5159.50684, -1.1920929e-07, 0, 1.00000012, 0, 1, 0, -1.00000012, 0, -1.1920929e-07) },
}

local activeBossFight = false

local function doBossFight(bossName, bossData, snapshotWorld, snapshotZone)
    if not S.isAutoGlobalBoss then
        activeBossFight = false
        return
    end

    S.globalBossActive = true

    if S.isReturningFromMode then
        WindUI:Notify({ Title="⚔ Boss Queued", Content="รอ mode teleport กลับก่อน...", Duration=3 })
        local waitStart = tick()
        while S.isReturningFromMode and tick() - waitStart < 15 do
            task.wait(0.5)
        end
    end

    task.wait(1)

    if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard then
        WindUI:Notify({ Title="⚔ Boss Queued", Content="Trial in progress! Will teleport after.", Duration=4 })
        while S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard do
            task.wait(1)
        end
        if not S.isAutoGlobalBoss then
            S.globalBossActive = false
            activeBossFight = false
            return
        end
        local waitReturnAfterTrial = tick()
        while S.isReturningFromMode and tick() - waitReturnAfterTrial < 10 do
            task.wait(0.5)
        end
        task.wait(1)
    end

    local waitOut = tick()
    while S.isInsideGamemode and tick() - waitOut < 10 do task.wait(0.5) end
    leaveGamemode("Tempest Invasion")
    leaveGamemode("Dragon Defense")
    task.wait(1)
    S.isInsideGamemode = false

    WindUI:Notify({
        Title   = "Global Boss!",
        Content = "Teleporting to " .. bossData.world .. " Zone " .. bossData.zone .. "...",
        Duration = 3
    })
    fireRemote({{{"Player","Teleport","Teleport",bossData.world,bossData.zone,n=5},"\002"}})
    task.wait(5)

    if bossData.fallbackCF then
        local hrpFB = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrpFB then hrpFB.CFrame = bossData.fallbackCF * CFrame.new(0,5,0) end
    end

    local loadWait = tick()
    repeat task.wait(0.5) until getBestGlobalBossTarget() ~= nil or tick() - loadWait > 15

    local timeout = tick() + 300
    while S.isAutoGlobalBoss and tick() < timeout do
        if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard then
            WindUI:Notify({ Title="⚔ Boss Paused", Content="Trial started! Pausing boss fight...", Duration=3 })
            while S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard do task.wait(1) end
            if not S.isAutoGlobalBoss then break end
            WindUI:Notify({ Title="⚔ Boss Resumed", Content="Trial done! Returning to boss...", Duration=3 })
            local waitRet = tick()
            while S.isReturningFromMode and tick() - waitRet < 10 do task.wait(0.5) end
            task.wait(1)
            fireRemote({{{"Player","Teleport","Teleport",bossData.world,bossData.zone,n=5},"\002"}})
            task.wait(6)
            continue
        end

        local target, id = getBestGlobalBossTarget()
        if not target or not id then break end

        local hp     = tonumber(target:GetAttribute("Health")) or 0
        local loaded = target:GetAttribute("Loaded")
        local died   = target:GetAttribute("Died")

        if hp <= 0 or loaded == false or died == true or not target.Parent then break end

        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local ok2, tCF = pcall(function()
                return target:IsA("Model") and target:GetPivot() or target.CFrame
            end)
            if ok2 and tCF and (hrp.Position - tCF.Position).Magnitude > 8 then
                hrp.CFrame = tCF * CFrame.new(0,3,0)
            end
        end

        if not S.isAttacking and id then
            fireRemote({{{ "General","Attack","Click",{ [tostring(id)]=true }, n=4 }, "\002" }})
        end
        task.wait(0.3)
    end

    if snapshotWorld ~= "" then
        WindUI:Notify({ Title="⚔ Returning", Content="Returning to " .. snapshotWorld .. " Z" .. snapshotZone .. "...", Duration=3 })
        teleportToWorld(snapshotWorld, snapshotZone)
        task.wait(4)
    end
    S.globalBossActive = false
    activeBossFight    = false
end

-- ============================================================
--  NOTIFICATION LOOP
-- ============================================================
task.spawn(function()
    local lastNotifText = ""
    while true do
        task.wait(3)
        if not S.isAutoGlobalBoss then continue end

        local ok, notifList = pcall(function() return player.PlayerGui.Notifications.List end)
        if not (ok and notifList) then continue end

        for _, notif in ipairs(notifList:GetChildren()) do
            local notifText = ""
            pcall(function()
                for _, desc in ipairs(notif:GetDescendants()) do
                    if desc:IsA("TextLabel") or desc:IsA("TextBox") then
                        local t = desc.ContentText ~= "" and desc.ContentText or desc.Text
                        if #t > #notifText then notifText = t end
                    end
                end
            end)

            if notifText == lastNotifText then continue end

            if string.find(notifText, "%[SERVER%] Global Boss") and string.find(notifText, "has spawned") then
                lastNotifText = notifText

                for bossName, bossData in pairs(bossWorldMap) do
                    if not string.find(notifText, "'"..bossName.."'") then continue end
                    if selectedGlobalBoss ~= "All" and selectedGlobalBoss ~= bossName then continue end
                    if activeBossFight then break end

                    local snapshotWorld = selectedFarmWorld
                    local snapshotZone  = tonumber(selectedFarmZone) or 1

                    WindUI:Notify({
                        Title   = "Global Boss Spawned!",
                        Content = bossName .. " spawned!",
                        Duration = 4
                    })

                    activeBossFight = true
                    task.spawn(function()
                        doBossFight(bossName, bossData, snapshotWorld, snapshotZone)
                    end)
                    break
                end
            end
        end
    end
end)

task.spawn(function()
    local waited = 0
    while not globalBossFolder and waited < 20 do task.wait(0.5) waited += 0.5 end

    local lastPollBossName = ""

    while true do
        task.wait(5)
        if not S.isAutoGlobalBoss then
            lastPollBossName = ""
            continue
        end
        if activeBossFight then continue end
        if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard then continue end
        if not checkBossExists() then
            lastPollBossName = ""
            continue
        end

        local foundBossName = nil
        for _, boss in ipairs(globalBossFolder:GetChildren()) do
            if selectedGlobalBoss ~= "All" and boss.Name ~= selectedGlobalBoss then continue end
            local loaded = boss:GetAttribute("Loaded")
            local hp     = tonumber(boss:GetAttribute("Health")) or 0
            if loaded == true and hp > 0 then
                foundBossName = boss.Name
                break
            end
        end

        if not foundBossName then continue end
        if activeBossFight then continue end
        if foundBossName == lastPollBossName then continue end
        lastPollBossName = foundBossName

        local bossData = bossWorldMap[foundBossName]
        if not bossData then
            bossData = { world = "Cursed Verse", zone = 2 }
        end

        WindUI:Notify({
            Title   = "🔴 Global Boss Found!",
            Content = foundBossName .. " is alive in this server!",
            Duration = 4
        })

        local snapshotWorld = selectedFarmWorld
        local snapshotZone  = tonumber(selectedFarmZone) or 1

        activeBossFight = true
        task.spawn(function()
            doBossFight(foundBossName, bossData, snapshotWorld, snapshotZone)
        end)
    end
end)

FarmTab:Divider()

GlobalBossDropdown = FarmTab:Dropdown({
    Title="Select Global Boss", Icon="skull", Values=getGlobalBossList(), Value=Options.SelectedGlobalBoss or "All",
    Callback = function(v) selectedGlobalBoss=v Options.SelectedGlobalBoss=v SaveConfig() end
})

FarmTab:Button({
    Title="Refresh Boss List", Icon="refresh-cw",
    Callback = function()
        if GlobalBossDropdown then GlobalBossDropdown:Refresh(getGlobalBossList()) WindUI:Notify({ Title="Updated", Content="Boss list refreshed!", Duration=2 }) end
    end
})

FarmTab:Toggle({
    Title="Auto Farm Global Boss", Icon="skull", Desc="Auto farm the selected boss",
    Type="Checkbox", Value=Options.AutoGlobalBoss or false,
    Callback = function(v)
        S.isAutoGlobalBoss=v Options.AutoGlobalBoss=v SaveConfig()
        if not v then activeBossFight=false end
    end
})

-- AUTO HOP
local isAutoHopGlobalBoss  = Options.AutoHopGlobalBoss or false
local hopGlobalBossMinWait = tonumber(Options.HopGlobalBossMinWait) or 5
local visitedGlobalBossServers = {}

FarmTab:Slider({
    Title="Check boss respawn before hop server (minutes)", Icon="timer", Step=1,
    Value={ Min=1, Max=15, Default=hopGlobalBossMinWait },
    Callback = function(v) hopGlobalBossMinWait=tonumber(v) or 5 Options.HopGlobalBossMinWait=hopGlobalBossMinWait SaveConfig() end
})

FarmTab:Toggle({
    Title="Auto global boss (Hop Server)", Icon="refresh-cw", Desc="Hop server when no Global Boss is alive",
    Type="Checkbox", Value=Options.AutoHopGlobalBoss or false,
    Callback = function(v)
        isAutoHopGlobalBoss=v Options.AutoHopGlobalBoss=v SaveConfig()
        if isAutoHopGlobalBoss then
            task.spawn(function()
                while isAutoHopGlobalBoss do
                    if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard then task.wait(3) continue end
                    if not checkBossExists() then
                        if activeBossFight then task.wait(5) continue end
                        local countdown = 20
                        while countdown > 0 and isAutoHopGlobalBoss do
                            if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard then countdown=999 break end
                            WindUI:Notify({ Title="Auto Hop", Content="No Global Boss!\nHopping in "..countdown.."s...", Duration=1 })
                            task.wait(1) countdown -= 1
                        end
                        if isAutoHopGlobalBoss and countdown == 0 then
                            if checkBossExists() then
                                WindUI:Notify({ Title="Auto Hop", Content="Boss appeared! Cancelling hop.", Duration=3 })
                            else
                                local TeleportService = game:GetService("TeleportService")
                                local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
                                local ok, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
                                if ok and type(result) == "table" and result.data then
                                    local hopped = false
                                    for _, server in ipairs(result.data) do
                                        if server.playing < server.maxPlayers and server.id ~= game.JobId
                                        and not visitedGlobalBossServers[server.id] then
                                            visitedGlobalBossServers[server.id] = true
                                            WindUI:Notify({ Title="Hopping Server", Content="Teleporting...", Duration=3 })
                                            local okTp = pcall(function()
                                                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, game.Players.LocalPlayer)
                                            end)
                                            if okTp then hopped=true task.wait(8) break end
                                        end
                                    end
                                    if not hopped then
                                        visitedGlobalBossServers = {}
                                        WindUI:Notify({ Title="Auto Hop", Content="No available server, resetting list...", Duration=3 })
                                        task.wait(15)
                                    end
                                else task.wait(10) end
                            end
                        end
                    end
                    task.wait(5)
                end
            end)
        end
    end
})

-- ============================================================
--  TAB: GAMEMODE — TRIAL EASY
-- ============================================================
GamemodeTab:Section({ Title = "Trial Easy" })

GamemodeTab:Toggle({
    Title="Auto Trial", Icon="clock", Desc="Join Trial at :15 and :45 every hour",
    Type="Checkbox", Value=Options.AutoTrial or false,
    Callback = function(v)
        S.isAutoTrial=v Options.AutoTrial=v SaveConfig()
        if not S.isAutoTrial then S.isInsideTrial=false end
    end
})

task.spawn(function()
    local lastMin      = -1
    local noEnemyTimer = 0

    -- แก้ไข: Leave ใช้ format ใหม่ + ไม่ต้อง return world
    local function doLeaveAndReturn()
        leaveGamemode("Trial Easy")
        WindUI:Notify({ Title="Trial Ended", Content="Leaving Trial...", Duration=4 })
        task.wait(2)
        S.isInsideTrial     = false
        S.isInsideGamemode  = false
        S.isReturningFromMode = false
        noEnemyTimer = 0
    end

    local function getCurrentWave()
    local ok, wt = pcall(function()
        local waveValue = player.PlayerGui.UI.HUD.Gamemodes["Trial Easy"].Main.Wave.Title.Value
        return waveValue.ContentText ~= "" and waveValue.ContentText or waveValue.Text
    end)
    if not ok or type(wt) ~= "string" then return nil end
    return tonumber(string.match(wt, "^%s*(%d+)"))
end
    local function shouldLeaveNow()
        if not S.isAutoLeaveTrial then return false end
        local w = getCurrentWave()
        return w ~= nil and w >= trialTargetWave
    end
    local function getTrialTarget()
        local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            and player.Character.HumanoidRootPart.Position) or Vector3.zero
        local bestTarget, bestID, bestDist = nil, nil, math.huge
        local ce = workspace:FindFirstChild("Client") and workspace.Client:FindFirstChild("Enemies")
        if ce then
            for _, child in ipairs(ce:GetDescendants()) do
                local sID,dead,hp = child:GetAttribute("ID"),child:GetAttribute("Died"),child:GetAttribute("Health")
                if sID and not dead and (not hp or tonumber(hp) > 0) then
                    local pos = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                    if pos then local d=(pos-myPos).Magnitude if d<bestDist then bestDist=d bestTarget=child bestID=sID end end
                end
            end
        end
        if not bestTarget then
            local folder = workspace:FindFirstChild("Server") and workspace.Server:FindFirstChild("Enemies")
                and workspace.Server.Enemies:FindFirstChild("Gamemodes") and workspace.Server.Enemies.Gamemodes:FindFirstChild("Trial Easy")
            if folder then
                for _, child in pairs(folder:GetDescendants()) do
                    local sID,dead,hp = child:GetAttribute("ID"),child:GetAttribute("Died"),child:GetAttribute("Health")
                    if sID and not dead and (not hp or tonumber(hp) > 0) then
                        local pos = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                        if pos then local d=(pos-myPos).Magnitude if d<bestDist then bestDist=d bestTarget=child bestID=sID end end
                    end
                end
            end
        end
        return bestTarget, bestID
    end
    while true do
        task.wait(1)
        if not S.isAutoTrial then if S.isInsideTrial then S.isInsideTrial=false end lastMin=-1 continue end
        local t = os.date("*t")
        if not S.isInsideTrial then
            if t.min ~= 15 and t.min ~= 45 then lastMin=-1 end
            if (t.min==15 or t.min==45) and t.min ~= lastMin then
                lastMin=t.min
                S.isInsideTrial=true noEnemyTimer=0
                WindUI:Notify({ Title="⚔ Trial", Content="Joining Trial...", Duration=3 })
                task.wait(1.5)
                fireRemote({{{"General","Gamemodes","Join","Trial Easy",n=4},"\002"}})
                task.wait(3)
            end
        else
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(0.5) continue end
            if shouldLeaveNow() then WindUI:Notify({ Title="⚔ Trial", Content="Wave "..trialTargetWave.." reached! Leaving...", Duration=3 }) doLeaveAndReturn() continue end
            while S.isInsideTrial do
                if shouldLeaveNow() then WindUI:Notify({ Title="⚔ Trial", Content="Wave "..trialTargetWave.." reached! Leaving...", Duration=3 }) doLeaveAndReturn() break end
                local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not curHRP then task.wait(0.2) continue end
                local target, id = getTrialTarget()
                if not target then
                    noEnemyTimer += 0.1
                    if noEnemyTimer >= 5 then WindUI:Notify({ Title="⚔ Trial", Content="No enemies for 5s. Leaving...", Duration=3 }) doLeaveAndReturn() break end
                    task.wait(0.1)
                else
                    noEnemyTimer=0
                    local tCF = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                    if tCF and (curHRP.Position - tCF.Position).Magnitude > 8 then curHRP.CFrame = tCF * CFrame.new(0,3,0) end
                    while S.isInsideTrial do
                        if shouldLeaveNow() then break end
                        local hp,dead = target:GetAttribute("Health"),target:GetAttribute("Died")
                        if dead or (hp ~= nil and tonumber(hp) <= 0) or not target.Parent then break end
                        local freshHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if freshHRP then
                            local tCF2 = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                            if tCF2 and (freshHRP.Position - tCF2.Position).Magnitude > 8 then freshHRP.CFrame = tCF2 * CFrame.new(0,3,0) end
                        end
                        task.wait(0.1)
                    end
                    if shouldLeaveNow() then WindUI:Notify({ Title="⚔ Trial", Content="Wave "..trialTargetWave.." reached! Leaving...", Duration=3 }) doLeaveAndReturn() break end
                end
            end
        end
    end
end)

GamemodeTab:Toggle({
    Title="Auto Leave Trial", Icon="door-open", Desc="Leave when reaching target wave",
    Type="Checkbox", Value=Options.AutoLeaveTrial or false,
    Callback = function(v) S.isAutoLeaveTrial=v Options.AutoLeaveTrial=v SaveConfig() end
})

GamemodeTab:Slider({
    Title="Leave at Wave", Icon="skip-forward", Step=1,
    Value={ Min=1, Max=50, Default=Options.LeaveAtWave or 5 },
    Callback = function(v) trialTargetWave=v Options.LeaveAtWave=v SaveConfig() end
})

-- ============================================================
--  TAB: GAMEMODE — TRIAL MEDIUM
-- ============================================================
GamemodeTab:Divider()
GamemodeTab:Section({ Title = "Trial Medium" })

GamemodeTab:Toggle({
    Title="Auto Trial Medium", Icon="clock", Desc="Join Trial Medium at :00 and :30 every hour",
    Type="Checkbox", Value=Options.AutoTrialMedium or false,
    Callback = function(v)
        S.isAutoTrialMedium=v Options.AutoTrialMedium=v SaveConfig()
        if not S.isAutoTrialMedium then S.isInsideTrialMedium=false end
    end
})

task.spawn(function()
    local lastMinMed      = -1
    local noEnemyTimerMed = 0

    -- แก้ไข: Leave ใช้ format ใหม่ + ไม่ต้อง return world
    local function doLeaveAndReturnMed()
        leaveGamemode("Trial Medium")
        WindUI:Notify({ Title="Trial Medium Ended", Content="Leaving Trial Medium...", Duration=4 })
        task.wait(2)
        S.isInsideTrialMedium = false
        S.isInsideGamemode    = false
        S.isReturningFromMode = false
        noEnemyTimerMed = 0
    end

    local function getCurrentWaveMed()
        local ok, wt = pcall(function()
            local hud = player.PlayerGui.UI.HUD.Gamemodes["Trial Medium"]
            if not hud then return "" end
            local wave = hud:FindFirstChild("Main") and hud.Main:FindFirstChild("Wave")
            if not wave then return "" end
            if wave:IsA("TextLabel") or wave:IsA("TextBox") then return wave.ContentText ~= "" and wave.ContentText or wave.Text end
            for _, child in ipairs(wave:GetChildren()) do
                if child:IsA("TextLabel") or child:IsA("TextBox") then
                    local t = child.ContentText ~= "" and child.ContentText or child.Text
                    if t ~= "" then return t end
                end
            end
            return ""
        end)
        if not ok or type(wt) ~= "string" then return nil end
        return tonumber(string.match(wt, "(%d+)"))
    end
    local function shouldLeaveNowMed()
        if not S.isAutoLeaveTrialMed then return false end
        local w = getCurrentWaveMed()
        return w ~= nil and w >= trialMedTargetWave
    end
    local function getTrialMedTarget()
        local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            and player.Character.HumanoidRootPart.Position) or Vector3.zero
        local bestTarget, bestID, bestDist = nil, nil, math.huge
        local ce = workspace:FindFirstChild("Client") and workspace.Client:FindFirstChild("Enemies")
        if ce then
            for _, child in ipairs(ce:GetDescendants()) do
                local sID,dead,hp = child:GetAttribute("ID"),child:GetAttribute("Died"),child:GetAttribute("Health")
                if sID and not dead and (not hp or tonumber(hp) > 0) then
                    local pos = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                    if pos then local d=(pos-myPos).Magnitude if d<bestDist then bestDist=d bestTarget=child bestID=sID end end
                end
            end
        end
        if not bestTarget then
            local folder = workspace:FindFirstChild("Server") and workspace.Server:FindFirstChild("Enemies")
                and workspace.Server.Enemies:FindFirstChild("Gamemodes") and workspace.Server.Enemies.Gamemodes:FindFirstChild("Trial Medium")
            if folder then
                for _, child in pairs(folder:GetDescendants()) do
                    local sID,dead,hp = child:GetAttribute("ID"),child:GetAttribute("Died"),child:GetAttribute("Health")
                    if sID and not dead and (not hp or tonumber(hp) > 0) then
                        local pos = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                        if pos then local d=(pos-myPos).Magnitude if d<bestDist then bestDist=d bestTarget=child bestID=sID end end
                    end
                end
            end
        end
        return bestTarget, bestID
    end
    while true do
        task.wait(1)
        if not S.isAutoTrialMedium then if S.isInsideTrialMedium then S.isInsideTrialMedium=false end lastMinMed=-1 continue end
        local t = os.date("*t")
        if not S.isInsideTrialMedium then
            if t.min ~= 0 and t.min ~= 30 then lastMinMed=-1 end
            if (t.min==0 or t.min==30) and t.min ~= lastMinMed then
                lastMinMed=t.min
                leaveGamemode("Tempest Invasion")
                leaveGamemode("Dragon Defense")
                S.isInsideGamemode=false
                S.isInsideTrialMedium=true noEnemyTimerMed=0
                WindUI:Notify({ Title="⚔ Trial Medium", Content="High Priority: Joining Trial Medium...", Duration=3 })
                task.wait(1.5)
                fireRemote({{{"General","Gamemodes","Join","Trial Medium",n=4},"\002"}})
                task.wait(3)
            end
        else
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(0.5) continue end
            if shouldLeaveNowMed() then WindUI:Notify({ Title="⚔ Trial Medium", Content="Wave "..trialMedTargetWave.." reached! Leaving...", Duration=3 }) doLeaveAndReturnMed() continue end
            while S.isInsideTrialMedium do
                if shouldLeaveNowMed() then WindUI:Notify({ Title="⚔ Trial Medium", Content="Wave "..trialMedTargetWave.." reached! Leaving...", Duration=3 }) doLeaveAndReturnMed() break end
                local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not curHRP then task.wait(0.2) continue end
                local target, id = getTrialMedTarget()
                if not target then
                    noEnemyTimerMed += 0.1
                    if noEnemyTimerMed >= 5 then WindUI:Notify({ Title="⚔ Trial Medium", Content="No enemies for 5s. Leaving...", Duration=3 }) doLeaveAndReturnMed() break end
                    task.wait(0.1)
                else
                    noEnemyTimerMed=0
                    local tCF = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                    if tCF and (curHRP.Position - tCF.Position).Magnitude > 8 then curHRP.CFrame = tCF * CFrame.new(0,3,0) end
                    while S.isInsideTrialMedium do
                        if shouldLeaveNowMed() then break end
                        local hp,dead = target:GetAttribute("Health"),target:GetAttribute("Died")
                        if dead or (hp ~= nil and tonumber(hp) <= 0) or not target.Parent then break end
                        local freshHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if freshHRP then
                            local tCF2 = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                            if tCF2 and (freshHRP.Position - tCF2.Position).Magnitude > 8 then freshHRP.CFrame = tCF2 * CFrame.new(0,3,0) end
                        end
                        task.wait(0.1)
                    end
                    if shouldLeaveNowMed() then WindUI:Notify({ Title="⚔ Trial Medium", Content="Wave "..trialMedTargetWave.." reached! Leaving...", Duration=3 }) doLeaveAndReturnMed() break end
                end
            end
        end
    end
end)

GamemodeTab:Toggle({
    Title="Auto Leave Trial Medium", Icon="door-open", Desc="Leave when reaching target wave",
    Type="Checkbox", Value=Options.AutoLeaveTrialMed or false,
    Callback = function(v) S.isAutoLeaveTrialMed=v Options.AutoLeaveTrialMed=v SaveConfig() end
})

GamemodeTab:Slider({
    Title="Leave at Wave (Medium)", Icon="skip-forward", Step=1,
    Value={ Min=1, Max=50, Default=Options.LeaveAtWaveMed or 5 },
    Callback = function(v) trialMedTargetWave=v Options.LeaveAtWaveMed=v SaveConfig() end
})

-- ============================================================
--  TAB: GAMEMODE — TRIAL HARD
-- ============================================================
GamemodeTab:Divider()
GamemodeTab:Section({ Title = "Trial Hard" })

GamemodeTab:Toggle({
    Title="Auto Trial Hard", Icon="flame", Desc="Join Trial Hard at :10 and :40 every hour",
    Type="Checkbox", Value=Options.AutoTrialHard or false,
    Callback = function(v)
        S.isAutoTrialHard=v Options.AutoTrialHard=v SaveConfig()
        if not S.isAutoTrialHard then S.isInsideTrialHard=false end
    end
})

task.spawn(function()
    local lastMinHard      = -1
    local noEnemyTimerHard = 0

    -- แก้ไข: Leave ใช้ format ใหม่ + ไม่ต้อง return world
    local function doLeaveAndReturnHard()
        leaveGamemode("Trial Hard")
        WindUI:Notify({ Title="Trial Hard Ended", Content="Leaving Trial Hard...", Duration=4 })
        task.wait(2)
        S.isInsideTrialHard   = false
        S.isInsideGamemode    = false
        S.isReturningFromMode = false
        noEnemyTimerHard = 0
    end

    local function getCurrentWaveHard()
        local ok, wt = pcall(function()
            local hud = player.PlayerGui.UI.HUD.Gamemodes["Trial Hard"]
            if not hud then return "" end
            local wave = hud:FindFirstChild("Main") and hud.Main:FindFirstChild("Wave")
            if not wave then return "" end
            if wave:IsA("TextLabel") or wave:IsA("TextBox") then return wave.ContentText ~= "" and wave.ContentText or wave.Text end
            for _, child in ipairs(wave:GetChildren()) do
                if child:IsA("TextLabel") or child:IsA("TextBox") then
                    local t = child.ContentText ~= "" and child.ContentText or child.Text
                    if t ~= "" then return t end
                end
            end
            return ""
        end)
        if not ok or type(wt) ~= "string" then return nil end
        return tonumber(string.match(wt, "(%d+)"))
    end
    local function shouldLeaveNowHard()
        if not S.isAutoLeaveTrialHard then return false end
        local w = getCurrentWaveHard()
        return w ~= nil and w >= trialHardTargetWave
    end
    local function getTrialHardTarget()
        local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            and player.Character.HumanoidRootPart.Position) or Vector3.zero
        local bestTarget, bestID, bestDist = nil, nil, math.huge
        local ce = workspace:FindFirstChild("Client") and workspace.Client:FindFirstChild("Enemies")
        if ce then
            for _, child in ipairs(ce:GetDescendants()) do
                local sID,dead,hp = child:GetAttribute("ID"),child:GetAttribute("Died"),child:GetAttribute("Health")
                if sID and not dead and (not hp or tonumber(hp) > 0) then
                    local pos = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                    if pos then local d=(pos-myPos).Magnitude if d<bestDist then bestDist=d bestTarget=child bestID=sID end end
                end
            end
        end
        if not bestTarget then
            local folder = workspace:FindFirstChild("Server") and workspace.Server:FindFirstChild("Enemies")
                and workspace.Server.Enemies:FindFirstChild("Gamemodes") and workspace.Server.Enemies.Gamemodes:FindFirstChild("Trial Hard")
            if folder then
                for _, child in pairs(folder:GetDescendants()) do
                    local sID,dead,hp = child:GetAttribute("ID"),child:GetAttribute("Died"),child:GetAttribute("Health")
                    if sID and not dead and (not hp or tonumber(hp) > 0) then
                        local pos = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                        if pos then local d=(pos-myPos).Magnitude if d<bestDist then bestDist=d bestTarget=child bestID=sID end end
                    end
                end
            end
        end
        return bestTarget, bestID
    end
    while true do
        task.wait(1)
        if not S.isAutoTrialHard then if S.isInsideTrialHard then S.isInsideTrialHard=false end lastMinHard=-1 continue end
        if S.isInsideTrialMedium then
            if S.isInsideTrialHard then
                leaveGamemode("Trial Hard")
                S.isInsideTrialHard=false S.isInsideGamemode=false noEnemyTimerHard=0
            end
            continue
        end
        local t = os.date("*t")
        if not S.isInsideTrialHard then
            if t.min ~= 10 and t.min ~= 40 then lastMinHard=-1 end
            if (t.min==10 or t.min==40) and t.min ~= lastMinHard then
                if S.isInsideTrial then continue end
                lastMinHard=t.min
                leaveGamemode("Tempest Invasion")
                leaveGamemode("Dragon Defense")
                S.isInsideGamemode=false
                S.isInsideTrialHard=true noEnemyTimerHard=0
                WindUI:Notify({ Title="⚔ Trial Hard", Content="Joining Trial Hard...", Duration=3 })
                task.wait(1.5)
                fireRemote({{{"General","Gamemodes","Join","Trial Hard",n=4},"\002"}})
                task.wait(3)
            end
        else
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(0.5) continue end
            if S.isInsideTrialMedium then WindUI:Notify({ Title="⚔ Trial Hard", Content="Trial Medium started! Leaving Hard...", Duration=3 }) doLeaveAndReturnHard() continue end
            if shouldLeaveNowHard() then WindUI:Notify({ Title="⚔ Trial Hard", Content="Wave "..trialHardTargetWave.." reached! Leaving...", Duration=3 }) doLeaveAndReturnHard() continue end
            while S.isInsideTrialHard do
                if S.isInsideTrialMedium then WindUI:Notify({ Title="⚔ Trial Hard", Content="Trial Medium started! Leaving Hard...", Duration=3 }) doLeaveAndReturnHard() break end
                if shouldLeaveNowHard() then WindUI:Notify({ Title="⚔ Trial Hard", Content="Wave "..trialHardTargetWave.." reached! Leaving...", Duration=3 }) doLeaveAndReturnHard() break end
                local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not curHRP then task.wait(0.2) continue end
                local target, id = getTrialHardTarget()
                if not target then
                    noEnemyTimerHard += 0.1
                    if noEnemyTimerHard >= 5 then WindUI:Notify({ Title="⚔ Trial Hard", Content="No enemies for 5s. Leaving...", Duration=3 }) doLeaveAndReturnHard() break end
                    task.wait(0.1)
                else
                    noEnemyTimerHard=0
                    local tCF = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                    if tCF and (curHRP.Position - tCF.Position).Magnitude > 8 then curHRP.CFrame = tCF * CFrame.new(0,3,0) end
                    while S.isInsideTrialHard do
                        if S.isInsideTrialMedium or shouldLeaveNowHard() then break end
                        local hp,dead = target:GetAttribute("Health"),target:GetAttribute("Died")
                        if dead or (hp ~= nil and tonumber(hp) <= 0) or not target.Parent then break end
                        local freshHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if freshHRP then
                            local tCF2 = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                            if tCF2 and (freshHRP.Position - tCF2.Position).Magnitude > 8 then freshHRP.CFrame = tCF2 * CFrame.new(0,3,0) end
                        end
                        task.wait(0.1)
                    end
                    if S.isInsideTrialMedium then WindUI:Notify({ Title="⚔ Trial Hard", Content="Trial Medium started! Leaving Hard...", Duration=3 }) doLeaveAndReturnHard() break end
                    if shouldLeaveNowHard() then WindUI:Notify({ Title="⚔ Trial Hard", Content="Wave "..trialHardTargetWave.." reached! Leaving...", Duration=3 }) doLeaveAndReturnHard() break end
                end
            end
        end
    end
end)

GamemodeTab:Toggle({
    Title="Auto Leave Trial Hard", Icon="door-open", Desc="Leave when reaching target wave",
    Type="Checkbox", Value=Options.AutoLeaveTrialHard or false,
    Callback = function(v) S.isAutoLeaveTrialHard=v Options.AutoLeaveTrialHard=v SaveConfig() end
})

GamemodeTab:Slider({
    Title="Leave at Wave (Hard)", Icon="skip-forward", Step=1,
    Value={ Min=1, Max=50, Default=Options.LeaveAtWaveHard or 5 },
    Callback = function(v) trialHardTargetWave=v Options.LeaveAtWaveHard=v SaveConfig() end
})

-- ============================================================
--  DRAGON DEFENSE
-- ============================================================
GamemodeTab:Divider()
GamemodeTab:Section({ Title = "Dragon Defense" })

local isAutoLeaveDragon = Options.AutoLeaveDragon or false
local dragonTargetWave  = Options.LeaveDragonAtWave or 50

GamemodeTab:Toggle({
    Title="Auto Dragon Defense", Icon="shield", Desc="Checks Saiyan Key → farms if empty → enters Dungeon",
    Type="Checkbox", Value=Options.AutoDragonDefense or false,
    Callback = function(v)
        S.isAutoDragonDefense=v Options.AutoDragonDefense=v SaveConfig()
        if not S.isAutoDragonDefense then S.isInsideGamemode=false end
        if S.isAutoDragonDefense then
            task.spawn(function()
                while S.isAutoDragonDefense do
                    if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard or S.globalBossActive then
                        S.isInsideGamemode=false task.wait(1) continue
                    end
                    if getKeyCount("Saiyan Key") < 1 then
                        S.isInsideGamemode=false
                        WindUI:Notify({ Title="🔑 No Saiyan Key!", Content="Farming at Dragon Verse Zone 2...", Duration=4 })
                        farmUntilKey("Saiyan Key","Dragon Verse",2,function()
                            return S.isAutoDragonDefense and not S.isInsideTrial and not S.isInsideTrialHard and not S.globalBossActive
                        end, 10)
                        if not S.isAutoDragonDefense then break end
                        task.wait(1) continue
                    end
                    task.wait(0.5)
                    fireRemote({{{"General","Gamemodes","Join","Dragon Defense",n=4},"\002"}})
                    task.wait(2.5)
                    local okMap, defNode = pcall(function() return workspace.Client.Maps["Dragon Defense"].Map.Defense end)
                    if okMap and defNode then
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local ok2, cf = pcall(function()
                                return defNode:IsA("Model") and defNode:GetPivot() or (defNode:IsA("BasePart") and defNode.CFrame)
                            end)
                            if ok2 and cf then hrp.CFrame = cf * CFrame.new(0,5,0) end
                        end
                    else
                        WindUI:Notify({ Title="Dragon Defense", Content="Map not loaded yet, retrying...", Duration=2 })
                        task.wait(3) continue
                    end
                    task.wait(1)
                    S.isInsideGamemode=true
                    local function getDragonTarget()
                        local myPos = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            and player.Character.HumanoidRootPart.Position) or Vector3.zero
                        local bT,bID,bD = nil,nil,math.huge
                        local okC2, ce = pcall(function() return workspace.Client.Enemies end)
                        if okC2 and ce then
                            for _, child in ipairs(ce:GetDescendants()) do
                                local sID,isDead,hp = child:GetAttribute("ID"),child:GetAttribute("Died"),child:GetAttribute("Health")
                                if sID and not isDead and (not hp or tonumber(hp) > 0) then
                                    local tp = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                                    if tp then local d=(tp-myPos).Magnitude if d<bD then bD=d bT=child bID=sID end end
                                end
                            end
                        end
                        if not bT then
                            local okS, sdd = pcall(function() return workspace.Server.Enemies.Gamemodes["Dragon Defense"] end)
                            if okS and sdd then
                                for _, child in ipairs(sdd:GetDescendants()) do
                                    local sID,isDead,hp = child:GetAttribute("ID"),child:GetAttribute("Died"),child:GetAttribute("Health")
                                    if sID and not isDead and (not hp or tonumber(hp) > 0) then
                                        local tp = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                                        if tp then local d=(tp-myPos).Magnitude if d<bD then bD=d bT=child bID=sID end end
                                    end
                                end
                            end
                        end
                        return bT,bID
                    end
                    local farmStart = tick()
                    while S.isAutoDragonDefense do
                        if S.isInsideTrial or S.isInsideTrialHard or S.globalBossActive then break end
                        local myHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if not myHRP then task.wait(0.5) continue end
                        local shouldLeave = false
                        local okW, wt = pcall(function()
                            local w = player.PlayerGui.UI.HUD.Gamemodes["Dragon Defense"].Main.Wave.Value
                            if typeof(w) == "Instance" then
                                return (w:IsA("TextLabel") or w:IsA("TextBox")) and (w.ContentText ~= "" and w.ContentText or w.Text) or tostring(w.Value)
                            end
                            return tostring(w)
                        end)
                        if okW and type(wt) == "string" then
                            local cw = string.match(wt, "(%d+)/") or string.match(wt, "(%d+)")
                            if isAutoLeaveDragon and cw and tonumber(cw) >= dragonTargetWave then shouldLeave=true end
                        end
                        if shouldLeave then
                            leaveGamemode("Dragon Defense")
                            WindUI:Notify({ Title="Dragon Defense", Content="Target wave reached! Leaving...", Duration=4 })
                            S.isInsideGamemode=false
                            break
                        end
                        local bT, bID = getDragonTarget()
                        if bT and bID then
                            farmStart=tick()
                            task.wait(0.5)
                            local tCF = bT:IsA("Model") and bT:GetPivot() or (bT:IsA("BasePart") and bT.CFrame)
                            if tCF and (myHRP.Position - tCF.Position).Magnitude > 8 then myHRP.CFrame = tCF * CFrame.new(0,10,0) end
                            while S.isAutoDragonDefense do
                                if S.isInsideTrial or S.isInsideTrialHard then break end
                                if not bT or not bT.Parent then break end
                                local isDead,hp = bT:GetAttribute("Died"),bT:GetAttribute("Health")
                                if isDead or (hp and tonumber(hp) <= 0) then task.wait(0.2) break end
                                local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if curHRP then
                                    local tCF2 = bT:IsA("Model") and bT:GetPivot() or (bT:IsA("BasePart") and bT.CFrame)
                                    if tCF2 and (curHRP.Position - tCF2.Position).Magnitude > 8 then curHRP.CFrame = tCF2 * CFrame.new(0,10,0) end
                                end
                                if not S.isAttacking and bID then
                                    fireRemote({{{ "General","Attack","Click",{ [tostring(bID)]=true }, n=4 }, "\002" }})
                                end
                                task.wait(0.2)
                            end
                        else
                            if tick() - farmStart > 600 then
                                WindUI:Notify({ Title="Dragon Defense", Content="Round ended, rejoining...", Duration=3 })
                                S.isInsideGamemode=false break
                            end
                            task.wait(0.5)
                        end
                    end
                    S.isInsideGamemode=false
                    if S.isAutoDragonDefense and not S.isInsideTrial and not S.isInsideTrialHard then
                        if getKeyCount("Saiyan Key") < 1 then
                            WindUI:Notify({ Title="Dragon Defense", Content="Keys exhausted — farming 10 Saiyan Keys...", Duration=3 })
                            farmUntilKey("Saiyan Key","Dragon Verse",2,function()
                                return S.isAutoDragonDefense and not S.isInsideTrial and not S.isInsideTrialHard and not S.globalBossActive
                            end, 10)
                        else
                            S.isInsideGamemode=false
                            for i=10,1,-1 do
                                if not S.isAutoDragonDefense then break end
                                WindUI:Notify({ Title="Dragon Defense", Content="Saiyan Key x"..math.floor(getKeyCount("Saiyan Key")).." — Rejoining in "..i.."s...", Duration=1.2 })
                                task.wait(1)
                            end
                        end
                    end
                    task.wait(1)
                end
                S.isInsideGamemode=false
            end)
        end
    end
})

GamemodeTab:Toggle({
    Title="Auto Leave Dragon Defense", Icon="door-open", Type="Checkbox", Value=Options.AutoLeaveDragon or false,
    Callback = function(v) isAutoLeaveDragon=v Options.AutoLeaveDragon=v SaveConfig() end
})

GamemodeTab:Slider({
    Title="Leave at Wave (Dragon)", Icon="skip-forward", Step=1,
    Value={ Min=1, Max=100, Default=Options.LeaveDragonAtWave or 50 },
    Callback = function(v) dragonTargetWave=v Options.LeaveDragonAtWave=v SaveConfig() end
})

-- ============================================================
--  TEMPEST INVASION
-- ============================================================
GamemodeTab:Divider()
GamemodeTab:Section({ Title = "Tempest Invasion" })

local isAutoLeaveTempest  = Options.AutoLeaveTempest or false
local tempestTargetWave   = Options.LeaveTempestAtWave or 50
local isAutoTempestCenter = false

GamemodeTab:Toggle({
    Title="Auto Tempest Invasion", Icon="swords", Desc="Checks Slime Key → farms if empty → enters Dungeon",
    Type="Checkbox", Value=Options.AutoTempestInvasion or false,
    Callback = function(v)
        S.isAutoTempestInvasion=v Options.AutoTempestInvasion=v SaveConfig()
        if not S.isAutoTempestInvasion then S.isInsideGamemode=false end
        if S.isAutoTempestInvasion then
            task.spawn(function()
                while S.isAutoTempestInvasion do
                    if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard or S.globalBossActive then
                        S.isInsideGamemode=false task.wait(1) continue
                    end
                    local t = os.date("*t")
                    if S.isAutoTrialMedium and (t.min==59 or t.min==29) then task.wait(5) continue end
                    if S.isAutoTrial and (t.min==14 or t.min==44) then task.wait(5) continue end
                    if S.isAutoTrialHard and (t.min==9 or t.min==39) then task.wait(5) continue end

                    if getKeyCount("Slime Key") < 1 then
                        S.isInsideGamemode=false
                        local prevCenter = isAutoTempestCenter
                        isAutoTempestCenter = false
                        WindUI:Notify({ Title="🔑 No Slime Key!", Content="Farming at Slime Verse Zone 2...", Duration=4 })
                        farmUntilKey("Slime Key","Slime Verse",2,function()
                            return S.isAutoTempestInvasion and not S.isInsideTrial and not S.isInsideTrialMedium and not S.isInsideTrialHard and not S.globalBossActive
                        end, 10)
                        isAutoTempestCenter = prevCenter
                        if not S.isAutoTempestInvasion then break end
                        task.wait(1) continue
                    end

                    WindUI:Notify({ Title="Tempest Invasion", Content="Joining...", Duration=3 })
                    fireRemote({{{"General","Gamemodes","Join","Tempest Invasion",n=4},"\002"}})
                    task.wait(4)
                    S.isInsideGamemode=true
                    local inMatch = true
                    local tempestTimeout = tick()
                    while inMatch and S.isAutoTempestInvasion do
                        if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard or S.globalBossActive then
                            -- แก้ไข: ใช้ leaveGamemode format ใหม่
                            leaveGamemode("Tempest Invasion")
                            S.isInsideGamemode=false break
                        end
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if not hrp then task.wait(0.5) continue end
                        local shouldLeave = false
                        local okW, wt = pcall(function()
                            local w = player.PlayerGui.UI.HUD.Gamemodes["Tempest Invasion"].Main.Wave.Value
                            if typeof(w) == "Instance" then
                                return (w:IsA("TextLabel") or w:IsA("TextBox")) and (w.ContentText ~= "" and w.ContentText or w.Text) or tostring(w.Value)
                            end
                            return tostring(w)
                        end)
                        if okW and type(wt) == "string" then
                            local cw = string.match(wt, "(%d+)/") or string.match(wt, "(%d+)")
                            if isAutoLeaveTempest and cw and tonumber(cw) >= tempestTargetWave then shouldLeave=true end
                        end
                        if shouldLeave then
                            -- แก้ไข: ใช้ leaveGamemode format ใหม่ + ไม่ต้อง return world
                            leaveGamemode("Tempest Invasion")
                            WindUI:Notify({ Title="Tempest Invasion", Content="Target wave reached! Leaving...", Duration=4 })
                            S.isInsideGamemode=false
                            inMatch=false break
                        end
                        local target, targetID, shortestDist = nil, nil, math.huge
                        local ce = workspace:FindFirstChild("Client") and workspace.Client:FindFirstChild("Enemies")
                        if ce then
                            for _, child in ipairs(ce:GetDescendants()) do
                                local sID,isDead,hp = child:GetAttribute("ID"),child:GetAttribute("Died"),child:GetAttribute("Health")
                                if sID and not isDead and (not hp or tonumber(hp) > 0) then
                                    local tp = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                                    if tp then local d=(tp-hrp.Position).Magnitude if d<shortestDist then shortestDist=d target=child targetID=sID end end
                                end
                            end
                        end
                        if not target then
                            local okS, st = pcall(function() return workspace.Server.Enemies.Gamemodes["Tempest Invasion"] end)
                            if okS and st then
                                for _, child in ipairs(st:GetDescendants()) do
                                    local sID,isDead,hp = child:GetAttribute("ID"),child:GetAttribute("Died"),child:GetAttribute("Health")
                                    if sID and not isDead and (not hp or tonumber(hp) > 0) then
                                        local tp = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                                        if tp then local d=(tp-hrp.Position).Magnitude if d<shortestDist then shortestDist=d target=child targetID=sID end end
                                    end
                                end
                            end
                        end
                        if target and targetID then
                            tempestTimeout=tick()
                            task.wait(0.5)
                            if not isAutoTempestCenter then
                                local tCF = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                                if tCF and (hrp.Position - tCF.Position).Magnitude > 8 then
                                    hrp.CFrame = tCF * CFrame.new(0,4,0)
                                    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                                    if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
                                end
                            end
                            while S.isAutoTempestInvasion and target and target.Parent do
                                local isDead,hp = target:GetAttribute("Died"),target:GetAttribute("Health")
                                if isDead or (hp and tonumber(hp) <= 0) then break end
                                local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if curHRP then
                                    if not isAutoTempestCenter then
                                        local tCF2 = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                                        if tCF2 and (curHRP.Position - tCF2.Position).Magnitude > 8 then
                                            curHRP.CFrame = tCF2 * CFrame.new(0,4,0)
                                            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                                            if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
                                        end
                                    end
                                    if not S.isAttacking and targetID then
                                        fireRemote({{{ "General","Attack","Click",{ [tostring(targetID)]=true }, n=4 }, "\002" }})
                                    end
                                end
                                task.wait(0.15)
                            end
                        else
                            if tick() - tempestTimeout > 5 then
                                WindUI:Notify({ Title="Tempest Invasion", Content="Round ended. Rejoining...", Duration=3 })
                                S.isInsideGamemode=false inMatch=false break
                            end
                            task.wait(0.5)
                        end
                    end
                    S.isInsideGamemode=false
                    if S.isAutoTempestInvasion and not S.isInsideTrial and not S.isInsideTrialMedium and not S.isInsideTrialHard then
                        if getKeyCount("Slime Key") < 1 then
                            WindUI:Notify({ Title="Tempest Invasion", Content="Keys exhausted — farming 10 Slime Keys...", Duration=3 })
                            local prevCenter2 = isAutoTempestCenter
                            isAutoTempestCenter = false
                            farmUntilKey("Slime Key","Slime Verse",2,function()
                                return S.isAutoTempestInvasion and not S.isInsideTrial and not S.isInsideTrialMedium and not S.isInsideTrialHard and not S.globalBossActive
                            end, 10)
                            isAutoTempestCenter = prevCenter2
                        else
                            S.isInsideGamemode=false
                            for i=10,1,-1 do
                                if not S.isAutoTempestInvasion or S.isInsideTrialMedium or S.isInsideTrialHard then break end
                                WindUI:Notify({ Title="Tempest Invasion", Content="Slime Key x"..math.floor(getKeyCount("Slime Key")).." — Rejoining in "..i.."s...", Duration=1.2 })
                                task.wait(1)
                            end
                        end
                    end
                end
                S.isInsideGamemode=false
            end)
        end
    end
})

GamemodeTab:Toggle({
    Title="Auto Center (Tempest)", Desc="Continuously warps to center inside Tempest Invasion",
    Icon="crosshair", Type="Checkbox", Value=false,
    Callback = function(v)
        isAutoTempestCenter=v
        if isAutoTempestCenter then
            task.spawn(function()
                while isAutoTempestCenter do
                    if S.isInsideGamemode and S.isAutoTempestInvasion and not S.isReturning then
                        local char = player.Character
                        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                        local hum  = char and char:FindFirstChildOfClass("Humanoid")
                        if hrp then
                            hrp.CFrame = CFrame.new(-2850.46558, 206.60545, -1678.82849, -0.91468, 0.00000, -0.40417, 0.00000, 1.00000, -0.00000, 0.40417, -0.00000, -0.91468)
                            if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
})

GamemodeTab:Toggle({
    Title="Auto Leave Tempest Invasion", Icon="door-open", Type="Checkbox", Value=Options.AutoLeaveTempest or false,
    Callback = function(v) isAutoLeaveTempest=v Options.AutoLeaveTempest=v SaveConfig() end
})

GamemodeTab:Slider({
    Title="Leave at Wave (Tempest)", Icon="skip-forward", Step=1,
    Value={ Min=1, Max=100, Default=Options.LeaveTempestAtWave or 50 },
    Callback = function(v) tempestTargetWave=v Options.LeaveTempestAtWave=v SaveConfig() end
})

-- ============================================================
--  TOWER
-- ============================================================
GamemodeTab:Divider()
GamemodeTab:Section({ Title = "Tower" })

local isAutoLeaveTower  = Options.AutoLeaveTower or false
local towerTargetWave   = Options.LeaveTowerAtWave or 50

local isAutoTowerCenter = false

local towerCenterCFrame = CFrame.new(28125.1309, 838.309509, -15839.6621,
    0.0378362425, 5.26982475e-08, 0.999283969,
    2.53359045e-09, 1, -5.28319397e-08,
    -0.999283969, 4.53073845e-09, 0.0378362425)

GamemodeTab:Toggle({
    Title="Auto Tower", Icon="castle", Desc="Auto join and farm Tower gamemode",
    Type="Checkbox", Value=Options.AutoTower or false,
    Callback = function(v)
        Options.AutoTower=v SaveConfig()
        if not Options.AutoTower then
            S.isInsideGamemode=false
            isAutoTowerCenter=false
        end
        if Options.AutoTower then
            task.spawn(function()
                while Options.AutoTower do
                    if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard or S.globalBossActive then
                        S.isInsideGamemode=false task.wait(1) continue
                    end

                    if getKeyCount("Tower Key") < 1 then
                        S.isInsideGamemode=false
                        local savedCenter = isAutoTowerCenter
                        isAutoTowerCenter = false  
                        WindUI:Notify({ Title="🔑 No Tower Key!", Content="Farming at Leveling Verse Zone 2...", Duration=4 })
                        farmUntilKey("Tower Key","Leveling Verse",2,function()
                            return Options.AutoTower
                            and not S.isInsideTrial
                            and not S.isInsideTrialMedium
                            and not S.isInsideTrialHard
                            and not S.globalBossActive
                        end, 10)
                        isAutoTowerCenter = savedCenter  -- คืนค่า center หลัง farm เสร็จ
                        if not Options.AutoTower then break end
                        task.wait(1) continue
                    end

                    WindUI:Notify({ Title="Tower", Content="Joining Tower...", Duration=3 })
                    fireRemote({{{"General","Gamemodes","Join","Tower",n=4},"\002"}})
                    task.wait(4)
                    S.isInsideGamemode=true

                    local hrpInit = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrpInit and not isAutoTowerCenter then
                        hrpInit.CFrame = towerCenterCFrame * CFrame.new(0,3,0)
                    end

                    local inMatch      = true
                    local towerTimeout = tick()

                    while inMatch and Options.AutoTower do
                        if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard or S.globalBossActive then
                            leaveGamemode("Tower")
                            S.isInsideGamemode=false break
                        end

                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if not hrp then task.wait(0.5) continue end

                        local shouldLeave = false

                        pcall(function()
                            local waveStr = player.PlayerGui.UI.HUD.Gamemodes["Tower"].Main.Wave.Value.Text
                            local cw = string.match(waveStr, "(%d+)%s*/%s*%d+") or string.match(waveStr, "(%d+)")
                            if isAutoLeaveTower and cw and tonumber(cw) >= towerTargetWave then
                                shouldLeave = true
                            end
                        end)

                        if shouldLeave then
                            leaveGamemode("Tower")
                            WindUI:Notify({ Title="Tower", Content="Target wave reached! Leaving...", Duration=4 })
                            S.isInsideGamemode=false
                            inMatch=false break
                        end

                        local target, targetID = nil, nil
                        local shortestDist = math.huge
                        local myPos = hrp.Position

                        local ce = workspace:FindFirstChild("Client") and workspace.Client:FindFirstChild("Enemies")
                        if ce then
                            for _, child in ipairs(ce:GetDescendants()) do
                                local sID  = child:GetAttribute("ID")
                                local dead = child:GetAttribute("Died")
                                local hp   = child:GetAttribute("Health")
                                if sID and not dead and (not hp or tonumber(hp) > 0) then
                                    local pos = child:IsA("Model") and child:GetPivot().Position
                                             or (child:IsA("BasePart") and child.Position)
                                    if pos then
                                        local d = (pos - myPos).Magnitude
                                        if d < shortestDist then shortestDist=d target=child targetID=sID end
                                    end
                                end
                            end
                        end

                        if not target then
                            local okS, towerFolder = pcall(function()
                                return workspace.Server.Enemies.Gamemodes.Tower
                            end)
                            if okS and towerFolder then
                                for _, child in ipairs(towerFolder:GetDescendants()) do
                                    local sID  = child:GetAttribute("ID")
                                    local dead = child:GetAttribute("Died")
                                    local hp   = child:GetAttribute("Health")
                                    if sID and not dead and (not hp or tonumber(hp) > 0) then
                                        local pos = child:IsA("Model") and child:GetPivot().Position
                                                 or (child:IsA("BasePart") and child.Position)
                                        if pos then
                                            local d = (pos - myPos).Magnitude
                                            if d < shortestDist then shortestDist=d target=child targetID=sID end
                                        end
                                    end
                                end
                            end
                        end

                        if target and targetID then
                            towerTimeout = tick()
                            if not isAutoTowerCenter then
                                local tCF = target:IsA("Model") and target:GetPivot()
                                         or (target:IsA("BasePart") and target.CFrame)
                                if tCF and (hrp.Position - tCF.Position).Magnitude > 8 then
                                    hrp.CFrame = tCF * CFrame.new(0,4,0)
                                    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                                    if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
                                end
                            end
                            while Options.AutoTower and target and target.Parent do
                                if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard or S.globalBossActive then break end
                                local dead = target:GetAttribute("Died")
                                local hp   = target:GetAttribute("Health")
                                if dead or (hp and tonumber(hp) <= 0) then break end
                                local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if curHRP and not isAutoTowerCenter then
                                    local tCF2 = target:IsA("Model") and target:GetPivot()
                                             or (target:IsA("BasePart") and target.CFrame)
                                    if tCF2 and (curHRP.Position - tCF2.Position).Magnitude > 8 then
                                        curHRP.CFrame = tCF2 * CFrame.new(0,4,0)
                                        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                                        if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
                                    end
                                end
                                if not S.isAttacking and targetID then
                                    fireRemote({{{ "General","Attack","Click",{ [tostring(targetID)]=true }, n=4 }, "\002" }})
                                end
                                task.wait(0.15)
                            end
                        else
                            if tick() - towerTimeout > 30 then
                                local stillInTower = false
                                pcall(function()
                                    local towerHUD = player.PlayerGui.UI.HUD.Gamemodes["Tower"]
                                    if towerHUD and towerHUD.Visible then
                                        stillInTower = true
                                    end
                                end)
                                if stillInTower then
                                    towerTimeout = tick()
                                else
                                    WindUI:Notify({ Title="Tower", Content="Round ended. Rejoining...", Duration=3 })
                                    S.isInsideGamemode=false inMatch=false break
                                end
                            end
                            task.wait(0.5)
                        end
                    end

                    S.isInsideGamemode=false

                    if Options.AutoTower and not S.isInsideTrial and not S.isInsideTrialMedium and not S.isInsideTrialHard then
                        if getKeyCount("Tower Key") < 1 then
                            WindUI:Notify({ Title="Tower", Content="Keys exhausted — farming 10 Tower Keys...", Duration=3 })
                            local savedCenter2 = isAutoTowerCenter
                            isAutoTowerCenter = false  -- ปิด center ก่อน farm
                            farmUntilKey("Tower Key","Leveling Verse",2,function()
                                return Options.AutoTower
                                and not S.isInsideTrial
                                and not S.isInsideTrialMedium
                                and not S.isInsideTrialHard
                                and not S.globalBossActive
                            end, 10)
                            isAutoTowerCenter = savedCenter2  -- คืนค่า center
                        else
                            for i=30,1,-1 do
                                if not Options.AutoTower then break end
                                WindUI:Notify({ Title="Tower", Content="Tower Key x"..math.floor(getKeyCount("Tower Key")).." — Rejoining in "..i.."s...", Duration=1.2 })
                                task.wait(1)
                            end
                        end
                    end
                end
                S.isInsideGamemode=false
            end)
        end
    end
})

GamemodeTab:Toggle({
    Title="Auto Center (Tower)", Desc="Continuously warps to center inside Tower",
    Icon="crosshair", Type="Checkbox", Value=false,
    Callback = function(v)
        isAutoTowerCenter=v
        if isAutoTowerCenter then
            task.spawn(function()
                while isAutoTowerCenter do
                    if S.isInsideGamemode and Options.AutoTower and not S.isReturning then
                        local char = player.Character
                        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                        local hum  = char and char:FindFirstChildOfClass("Humanoid")
                        if hrp then
                            hrp.CFrame = towerCenterCFrame
                            if hum then hum:ChangeState(Enum.HumanoidStateType.Freefall) end
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
})

GamemodeTab:Toggle({
    Title="Auto Leave Tower", Icon="door-open", Type="Checkbox", Value=Options.AutoLeaveTower or false,
    Callback = function(v) isAutoLeaveTower=v Options.AutoLeaveTower=v SaveConfig() end
})

GamemodeTab:Slider({
    Title="Leave at Wave (Tower)", Icon="skip-forward", Step=1,
    Value={ Min=1, Max=100, Default=Options.LeaveTowerAtWave or 50 },
    Callback = function(v) towerTargetWave=v Options.LeaveTowerAtWave=v SaveConfig() end
})


-- ============================================================
--  HOLLOW DEFENSE
-- ============================================================
GamemodeTab:Divider()
GamemodeTab:Section({ Title = "Hollow Defense" })

local isAutoLeaveHollow = Options.AutoLeaveHollow or false
local hollowTargetWave  = Options.LeaveHollowAtWave or 50

GamemodeTab:Toggle({
    Title="Auto Hollow Defense", Icon="shield", Desc="Checks Hollow Key → farms if empty → enters Dungeon",
    Type="Checkbox", Value=Options.AutoHollowDefense or false,
    Callback = function(v)
        Options.AutoHollowDefense=v SaveConfig()
        if not Options.AutoHollowDefense then S.isInsideGamemode=false end
        if Options.AutoHollowDefense then
            task.spawn(function()
                while Options.AutoHollowDefense do
                    if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard or S.globalBossActive then
                        S.isInsideGamemode=false task.wait(1) continue
                    end

                    if getKeyCount("Hollow Key") < 1 then
                        S.isInsideGamemode=false
                        WindUI:Notify({ Title="🔑 No Hollow Key!", Content="Farming Hard+ at Hollow Verse Zone 1...", Duration=4 })
                        farmHollowKey(function()
                            return Options.AutoHollowDefense
                            and not S.isInsideTrial
                            and not S.isInsideTrialMedium
                            and not S.isInsideTrialHard
                            and not S.globalBossActive
                        end, 10)
                        if not Options.AutoHollowDefense then break end
                        task.wait(1) continue
                    end

                    -- *** set true ตอน join จริงๆ ***
                    WindUI:Notify({ Title="Hollow Defense", Content="Joining...", Duration=3 })
                    S.isInsideGamemode = true
                    fireRemote({{{"General","Gamemodes","Join","Hollow Defense",n=4},"\002"}})
                    task.wait(4)

                    local inMatch = true
                    local hollowTimeout = tick()

                    while inMatch and Options.AutoHollowDefense do
                        if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard or S.globalBossActive then
                            leaveGamemode("Hollow Defense")
                            S.isInsideGamemode=false break
                        end
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if not hrp then task.wait(0.5) continue end
                        local shouldLeave = false
                        pcall(function()
                            local waveObj = player.PlayerGui.UI.HUD.Gamemodes["Hollow Defense"].Main.Wave.Value
                            local wt = waveObj.ContentText ~= "" and waveObj.ContentText or waveObj.Text
                            local cw = tonumber(string.match(wt, "^%s*(%d+)"))
                            if isAutoLeaveHollow and cw and cw >= hollowTargetWave then
                                shouldLeave = true
                            end
                        end)
                        if shouldLeave then
                            leaveGamemode("Hollow Defense")
                            WindUI:Notify({ Title="Hollow Defense", Content="Target wave reached! Leaving...", Duration=4 })
                            S.isInsideGamemode=false inMatch=false break
                        end
                        local target, targetID = nil, nil
                        local shortestDist = math.huge
                        local myPos = hrp.Position
                        local ce = workspace:FindFirstChild("Client") and workspace.Client:FindFirstChild("Enemies")
                        if ce then
                            for _, child in ipairs(ce:GetDescendants()) do
                                local sID,dead,hp = child:GetAttribute("ID"),child:GetAttribute("Died"),child:GetAttribute("Health")
                                if sID and not dead and (not hp or tonumber(hp) > 0) then
                                    local pos = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                                    if pos then local d=(pos-myPos).Magnitude if d<shortestDist then shortestDist=d target=child targetID=sID end end
                                end
                            end
                        end
                        if not target then
                            local okS, hdf = pcall(function() return workspace.Server.Enemies.Gamemodes["Hollow Defense"] end)
                            if okS and hdf then
                                for _, child in ipairs(hdf:GetDescendants()) do
                                    local sID,dead,hp = child:GetAttribute("ID"),child:GetAttribute("Died"),child:GetAttribute("Health")
                                    if sID and not dead and (not hp or tonumber(hp) > 0) then
                                        local pos = child:IsA("Model") and child:GetPivot().Position or (child:IsA("BasePart") and child.Position)
                                        if pos then local d=(pos-myPos).Magnitude if d<shortestDist then shortestDist=d target=child targetID=sID end end
                                    end
                                end
                            end
                        end
                        if target and targetID then
                            hollowTimeout=tick()
                            local tCF = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                            if tCF and (hrp.Position-tCF.Position).Magnitude > 8 then hrp.CFrame = tCF*CFrame.new(0,10,0) end
                            while Options.AutoHollowDefense and target and target.Parent do
                                if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard or S.globalBossActive then break end
                                local dead,hp = target:GetAttribute("Died"),target:GetAttribute("Health")
                                if dead or (hp and tonumber(hp) <= 0) then break end
                                local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                if curHRP then
                                    local tCF2 = target:IsA("Model") and target:GetPivot() or (target:IsA("BasePart") and target.CFrame)
                                    if tCF2 and (curHRP.Position-tCF2.Position).Magnitude > 8 then curHRP.CFrame = tCF2*CFrame.new(0,10,0) end
                                end
                                if not S.isAttacking and targetID then
                                    fireRemote({{{ "General","Attack","Click",{ [tostring(targetID)]=true }, n=4 }, "\002" }})
                                end
                                task.wait(0.15)
                            end
                        else
                            if tick()-hollowTimeout > 300 then
                                WindUI:Notify({ Title="Hollow Defense", Content="Round ended. Rejoining...", Duration=3 })
                                S.isInsideGamemode=false inMatch=false break
                            end
                            task.wait(0.5)
                        end
                    end

                    S.isInsideGamemode=false

                    if Options.AutoHollowDefense and not S.isInsideTrial and not S.isInsideTrialMedium and not S.isInsideTrialHard then
                        if getKeyCount("Hollow Key") < 1 then
                            WindUI:Notify({ Title="Hollow Defense", Content="Keys exhausted — farming 10 Hollow Keys (Hard+)...", Duration=3 })
                            farmHollowKey(function()
                                return Options.AutoHollowDefense
                                and not S.isInsideTrial
                                and not S.isInsideTrialMedium
                                and not S.isInsideTrialHard
                                and not S.globalBossActive
                            end, 10)
                        else
                            for i=20,1,-1 do
                                if not Options.AutoHollowDefense then break end
                                WindUI:Notify({ Title="Hollow Defense", Content="Hollow Key x"..math.floor(getKeyCount("Hollow Key")).." — Rejoining in "..i.."s...", Duration=1.2 })
                                task.wait(1)
                            end
                        end
                    end
                end
                S.isInsideGamemode=false
            end)
        end
    end
})

GamemodeTab:Toggle({
    Title="Auto Leave Hollow Defense", Icon="door-open", Type="Checkbox", Value=Options.AutoLeaveHollow or false,
    Callback = function(v) isAutoLeaveHollow=v Options.AutoLeaveHollow=v SaveConfig() end
})

GamemodeTab:Slider({
    Title="Leave at Wave (Hollow)", Icon="skip-forward", Step=1,
    Value={ Min=1, Max=100, Default=Options.LeaveHollowAtWave or 50 },
    Callback = function(v) hollowTargetWave=v Options.LeaveHollowAtWave=v SaveConfig() end
})
-- ============================================================
--  TAB: QUEST
-- ============================================================
QuestTab:Section({ Title = "Quest Settings" })

local QuestDropdown = QuestTab:Dropdown({
    Title="Select Quest", Icon="list", Values={"Loading..."},
    Callback = function(v) selectedQuest=v Options.SelectedQuest=v SaveConfig() end
})

task.delay(4, function()
    local waited = 0
    while not questsReady and waited < 15 do task.wait(0.2) waited += 0.2 end
    if QuestDropdown and #questNames > 0 then QuestDropdown:Refresh(questNames) end
end)

QuestTab:Toggle({
    Title="Auto Quest", Icon="circle-check-big", Desc="Complete selected quest automatically",
    Type="Checkbox", Value=Options.AutoQuest or false,
    Callback = function(v)
        S.isAutoQuest=v Options.AutoQuest=v SaveConfig()
        if S.isAutoQuest then
            task.spawn(function()
                while S.isAutoQuest do
                    if S.isInsideTrial then task.wait(1) continue end
                    local questData = getQuestData(selectedQuest)
                    if questData and questData.Missions then
                        for missionIndex, mission in ipairs(questData.Missions) do
                            if not S.isAutoQuest then break end
                            local slot, cachedEnemy = tostring(missionIndex), nil
                            while S.isAutoQuest and not isSlotDone(slot) do
                                if not cachedEnemy then
                                    cachedEnemy = getTargetEnemyFromQuest(slot)
                                    if cachedEnemy then WindUI:Notify({ Title="Quest", Content="Targeting: "..cachedEnemy, Duration=3 }) end
                                end
                                if cachedEnemy then
                                    local target, enemyID, targetWorld, targetZone = getQuestTarget(cachedEnemy)
                                    if target and enemyID and targetWorld then
                                        local cw, cz = getCurrentWorldName()
                                        if (cw ~= "" and cw ~= targetWorld) or cz ~= targetZone then
                                            fireRemote({{{"Player","Teleport","Teleport",targetWorld,targetZone or 1,n=5},"\002"}})
                                            task.wait(2.5)
                                        end
                                        while S.isAutoQuest and not isSlotDone(slot) and target.Parent do
                                            local isDead,hp = target:GetAttribute("Died"),target:GetAttribute("Health")
                                            if isDead or (hp and tonumber(hp) <= 0) then break end
                                            local curHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                                            if curHRP then
                                                local tCF = target:IsA("Model") and target:GetPivot() or target.CFrame
                                                if tCF and (curHRP.Position - tCF.Position).Magnitude > 8 then curHRP.CFrame = tCF * CFrame.new(0,3,0) end
                                            end
                                            task.wait(0.1)
                                        end
                                    else task.wait(0.5) end
                                else task.wait(0.5) end
                            end
                            if S.isAutoQuest then
                                fireRemote({{{"General","Quests","Complete",selectedQuest,mission,n=5},"\002"}})
                                task.wait(0.3)
                            end
                        end
                        if S.isAutoQuest then
                            fireRemote({{{"General","Quests","Finish",selectedQuest,n=4},"\002"}})
                            task.wait(1)
                        end
                    else task.wait(1) end
                end
            end)
        end
    end
})

QuestTab:Divider()
QuestTab:Section({ Title = "Side Quests" })

local sideQuestMap = {
    ["Kibe"]        = "Kibe Quest",
    ["Jinbei"]      = "Ginbe Quest",
    ["Mr Satan"]    = "Mr Satan Quest",
    ["Rimuru"]      = "Rimuro Quest",
    ["Gojouw"]      = "Gojouw Quest",
    ["Jin Hu"]      = "Jin Hu Quest",
}
local selectedSideQuest = "Mr Satan"

QuestTab:Dropdown({
    Title="Select Side Quest", Desc="Choose a side quest to accept", Icon="scroll-text",
    Values={"Kibe","Jinbei","Mr Satan","Rimuru","Gojouw","Jin Hu"}, Value="Mr Satan",
    Callback = function(v) selectedSideQuest=v end
})

QuestTab:Button({
    Title="Accept Side Quest", Desc="Instantly accept the selected quest (no teleport needed)", Icon="check-circle",
    Callback = function()
        local questName = sideQuestMap[selectedSideQuest]
        if not questName then
            WindUI:Notify({ Title="Error", Content="Quest not found!", Duration=3 })
            return
        end
        fireRemote({{{"General","Quests","Accept",questName,n=4},"\002"}})
        WindUI:Notify({ Title="Quest Accepted", Content="Accepted: "..questName, Duration=3 })
    end
})

QuestTab:Button({
    Title="Accept All Side Quests", Desc="Accept every side quest at once", Icon="check-check",
    Callback = function()
        task.spawn(function()
            for npcName, questName in pairs(sideQuestMap) do
                fireRemote({{{"General","Quests","Accept",questName,n=4},"\002"}})
                task.wait(0.5)
            end
            WindUI:Notify({ Title="Done", Content="Accepted all side quests!", Duration=3 })
        end)
    end
})

-- ============================================================
--  TAB: SUMMON
-- ============================================================
SummonTab:Section({ Title = "Auto Equip" })

SummonTab:Toggle({
    Title="Auto Equip Best Unit", Icon="user-check", Type="Checkbox", Value=Options.AutoEquip or false,
    Callback = function(v)
        S.isAutoEquip=v Options.AutoEquip=v SaveConfig()
        if S.isAutoEquip then task.spawn(function() while S.isAutoEquip do fireRemote({{{"General","Units","EquipBest","Power",n=4},"\002"}}) task.wait(30) end end) end
    end
})

SummonTab:Toggle({
    Title="Auto Equip Best Accessory", Icon="gem", Type="Checkbox", Value=Options.AutoEquipAcc or false,
    Callback = function(v)
        Options.AutoEquipAcc=v SaveConfig()
        if v then task.spawn(function() while Options.AutoEquipAcc do fireRemote({{{"General","Accessories","EquipBest","Power",n=4},"\002"}}) task.wait(60) end end) end
    end
})

SummonTab:Toggle({
    Title="Auto Equip Best Sword", Icon="swords", Type="Checkbox", Value=Options.AutoEquipSword or false,
    Callback = function(v)
        Options.AutoEquipSword=v SaveConfig()
        if v then task.spawn(function() while Options.AutoEquipSword do fireRemote({{{"General","Swords","EquipBest","Power",n=4},"\002"}}) task.wait(60) end end) end
    end
})

SummonTab:Toggle({
    Title="Auto Awaken", Icon="zap", Type="Checkbox", Value=Options.AutoAwaken or false,
    Callback = function(v)
        S.isAutoAwaken=v Options.AutoAwaken=v SaveConfig()
        if S.isAutoAwaken then task.spawn(function() while S.isAutoAwaken do fireRemote({{{"General","Awakening","Awaken",n=3},"\002"}}) task.wait(1) end end) end
    end
})

SummonTab:Divider()
SummonTab:Section({ Title = "Star Summon" })

SummonTab:Dropdown({
    Title="Select Star World", Icon="map-pin",
    Values={"Dressrosa","Marine Fortress","Capsule Corp","Dragon Arena","Jura Forest","Tempest Federation","Sorcerers Academy","Cursed Bridge","Leveling City","Double Dungeon"},
    Value=Options.SelectedStar or "Dressrosa",
    Callback = function(v) selectedStar=v Options.SelectedStar=v SaveConfig() end
})

SummonTab:Toggle({
    Title="Auto Summon (No Gamepass)", Icon="star", Desc="Teleport to Star → Summon → Farm 5s → Repeat",
    Type="Checkbox", Value=Options.AutoSummonNoGP or false,
    Callback = function(v)
        S.isAutoSummon=v Options.AutoSummonNoGP=v SaveConfig()
        if S.isAutoSummon then
            task.spawn(function()
                while S.isAutoSummon do
                    if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard or S.isInsideGamemode or S.isReturning then
                        task.wait(1) continue
                    end
                    teleportToStar(selectedStar)
                    S.isAutoSummonActive=true
                    task.wait(0.5)
                    fireRemote({{{"General","Stars","Open",selectedStar,99,n=5},"\002"}})
                    S.isAutoSummonActive=false
                    local cooldownEnd = tick() + 5
                    while tick() < cooldownEnd do
                        if not S.isAutoSummon then break end
                        if S.isInsideTrial or S.isInsideTrialMedium or S.isInsideTrialHard or S.isInsideGamemode or S.isReturning then break end
                        task.wait(0.1)
                    end
                end
                S.isAutoSummonActive=false
            end)
        else
            S.isAutoSummonActive=false
        end
    end
})

SummonTab:Toggle({
    Title="Auto Summon (With Gamepass)", Icon="star", Type="Checkbox", Value=Options.AutoSummonGP or false,
    Callback = function(v)
        S.isAutoSummon=v Options.AutoSummonGP=v SaveConfig()
        if S.isAutoSummon then
            task.spawn(function()
                while S.isAutoSummon do fireRemote({{{"General","Stars","Open",selectedStar,99,n=5},"\002"}}) task.wait(1) end
            end)
        end
    end
})

-- ============================================================
--  TAB: UNITS
-- ============================================================
UnitTab:Section({ Title = "Auto Rename" })

local renameUnitUID  = ""
local targetPower    = nil
local targetDamage   = nil
local targetCrystals = nil
local isAutoRename   = false
local renameName1    = Options.RenameName1 or "GhostA"
local renameName2    = Options.RenameName2 or "GhostB"
local renameFlip     = false

local RenameUnitDropdown = UnitTab:Dropdown({
    Title="Select Unit to Rename", Icon="user", Values={"Press Refresh 1 time."},
    Callback = function(v)
        if v and unitUIDMap[v] then renameUnitUID=unitUIDMap[v] end
    end
})

UnitTab:Button({
    Title="Refresh Rename Unit List", Icon="refresh-cw",
    Callback = function()
        local list = getUnitList()
        RenameUnitDropdown:Refresh(list)
        WindUI:Notify({ Title="Refreshed", Content="Rename unit list updated!", Duration=2 })
    end
})

task.delay(3.5, function()
    local waited = 0
    while not omniReady and waited < 15 do task.wait(0.2) waited += 0.2 end
    local list = getUnitList()
    RenameUnitDropdown:Refresh(list)
    if #list > 0 and list[1] ~= "No Units Found" and list[1] ~= "Loading..." then
        renameUnitUID = unitUIDMap[list[1]] or ""
    end
end)

UnitTab:Input({ Title="Rename Name 1", Desc="First name to swap", PlaceholderText="GhostHubontop", ClearTextOnFocus=false,
    Callback = function(v) if v and v ~= "" then renameName1=v Options.RenameName1=v SaveConfig() end end })
UnitTab:Input({ Title="Rename Name 2", Desc="Second name to swap", PlaceholderText="GhostHubonfire", ClearTextOnFocus=false,
    Callback = function(v) if v and v ~= "" then renameName2=v Options.RenameName2=v SaveConfig() end end })
UnitTab:Input({ Title="Target Power (1.1 - 1.75)", Desc="Leave blank to ignore", PlaceholderText="e.g., 1.5", ClearTextOnFocus=false,
    Callback = function(v) targetPower=tonumber(v) end })
UnitTab:Input({ Title="Target Damage (0.1 - 0.75)", Desc="Leave blank to ignore", PlaceholderText="e.g., 0.5", ClearTextOnFocus=false,
    Callback = function(v) targetDamage=tonumber(v) end })
UnitTab:Input({ Title="Target Crystals (0.1 - 0.75)", Desc="Leave blank to ignore", PlaceholderText="e.g., 0.3", ClearTextOnFocus=false,
    Callback = function(v) targetCrystals=tonumber(v) end })

UnitTab:Toggle({
    Title="Auto Rename", Desc="Alternates between Name 1 & Name 2 until target stats are met",
    Icon="pencil", Type="Checkbox", Value=false,
    Callback = function(v)
        isAutoRename=v
        if isAutoRename then
            renameFlip=false
            task.spawn(function()
                while isAutoRename do
                    if renameUnitUID == "" or renameUnitUID == "0" then
                        WindUI:Notify({ Title="Auto Rename", Content="Please select a Unit to rename first!", Duration=3 })
                        task.wait(2) continue
                    end
                    local ok, unitData = pcall(function() return Omni.Data.Inventory.Units[renameUnitUID] end)
                    if not ok or not unitData then
                        isAutoRename=false
                        WindUI:Notify({ Title="Auto Rename", Content="Unit not found! Stopped.", Duration=3 })
                        break
                    end
                    local buffs = unitData.RenameBuffs or {}
                    local p = tonumber(buffs["Power"]) or 0
                    local d = tonumber(buffs["Damage"]) or 0
                    local c = tonumber(buffs["Crystals"]) or 0
                    if (not targetPower or p >= targetPower)
                    and (not targetDamage or d >= targetDamage)
                    and (not targetCrystals or c >= targetCrystals) then
                        isAutoRename=false
                        WindUI:Notify({ Title="Stat Sniper ✅", Content=string.format("Target stats reached! P:%.2f D:%.2f C:%.2f", p,d,c), Duration=6 })
                        break
                    end
                    local nameToUse = renameFlip and renameName2 or renameName1
                    renameFlip = not renameFlip
                    fireRemote({{{"General","Units","Rename",renameUnitUID,nameToUse,n=5},"\002"}})
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- ============================================================
--  AUTO ARISE
-- ============================================================
UnitTab:Divider()
UnitTab:Section({ Title = "Auto Arise" })

local ariseUnitUID     = ""
local ariseTargetRank  = ""
local isAutoArise      = false
local ariseRanksList   = {}
local ariseDataReady   = false
local ariseRankIndex   = {}

task.spawn(function()
    local waited = 0
    while not omniReady and waited < 15 do task.wait(0.2) waited += 0.2 end
    local ok, ariseModule = pcall(function()
        return require(RS:WaitForChild("Omni",15):WaitForChild("Shared",10):WaitForChild("Arise",10))
    end)
    if ok and type(ariseModule) == "table" then
        local ranks = ariseModule["Ranks"]
        if type(ranks) == "table" then
            for i, rankName in ipairs(ranks) do
                table.insert(ariseRanksList, rankName)
                ariseRankIndex[rankName] = i
            end
        end
    end
    if #ariseRanksList == 0 then
        ariseRanksList = {"E","D","C","B","A","S"}
        for i, r in ipairs(ariseRanksList) do ariseRankIndex[r] = i end
    end
    ariseDataReady = true
end)

local ariseTokenLabel = UnitTab:Section({ Title = "Arise Tokens: Loading..." })

local function getAriseTokenCount()
    if not Omni then return 0 end
    local ok, n = pcall(function() return Omni.Data.Inventory.Items["Arise Token"] or 0 end)
    return (ok and math.floor(tonumber(n) or 0)) or 0
end

task.spawn(function()
    while true do
        ariseTokenLabel:SetTitle("Arise Tokens: " .. getAriseTokenCount())
        task.wait(10)
    end
end)

local AriseUnitDropdown = UnitTab:Dropdown({
    Title="Select Unit to Arise", Icon="user", Values={"Press Refresh"},
    Callback = function(v)
        if v and unitUIDMap[v] then ariseUnitUID=unitUIDMap[v] end
    end
})

UnitTab:Button({
    Title="Refresh Unit List", Icon="refresh-cw",
    Callback = function()
        local list = getUnitListSimple()
        AriseUnitDropdown:Refresh(list)
        ariseTokenLabel:SetTitle("Arise Tokens: " .. getAriseTokenCount())
        WindUI:Notify({ Title="Refreshed", Content="Arise unit list updated!", Duration=2 })
    end
})

task.delay(4, function()
    local waited = 0
    while not omniReady and waited < 15 do task.wait(0.2) waited += 0.2 end
    local list = getUnitListSimple()
    AriseUnitDropdown:Refresh(list)
    if #list > 0 and list[1] ~= "No Units Found" and list[1] ~= "Loading..." then
        ariseUnitUID = unitUIDMap[list[1]] or ""
    end
end)

local AriseRankDropdown = UnitTab:Dropdown({
    Title="Target Rank", Icon="target", Values={"Loading..."},
    Callback = function(v) ariseTargetRank=v end
})

task.delay(4.5, function()
    local waited = 0
    while not ariseDataReady and waited < 15 do task.wait(0.2) waited += 0.2 end
    if #ariseRanksList > 0 then
        AriseRankDropdown:Refresh(ariseRanksList)
        ariseTargetRank = ariseRanksList[#ariseRanksList]
    end
end)

UnitTab:Toggle({
    Title="Auto Arise", Desc="Continuously Arises the selected unit until it reaches the target rank",
    Icon="arrow-up-circle", Type="Checkbox", Value=false,
    Callback = function(v)
        isAutoArise=v
        if isAutoArise then
            task.spawn(function()
                while isAutoArise do
                    if ariseUnitUID == "" then
                        WindUI:Notify({ Title="Auto Arise", Content="Please select a Unit first!", Duration=3 })
                        task.wait(2) continue
                    end
                    if ariseTargetRank == "" then
                        WindUI:Notify({ Title="Auto Arise", Content="Please select a Target Rank first!", Duration=3 })
                        task.wait(2) continue
                    end
                    local currentRank = ""
                    pcall(function()
                        local ud = Omni.Data.Inventory.Units[ariseUnitUID]
                        if ud then
                            currentRank = ud.AriseRank or ud.ArisedRank or ud.Arise or ud.Rise or ud.Rank or ud.rank or ""
                            if currentRank == "" and ud.SerialNumber then
                                local sn = tostring(ud.SerialNumber)
                                local ok1, statsData = pcall(function() return Omni.Data.Stats end)
                                if ok1 and type(statsData) == "table" then
                                    local info = statsData[ariseUnitUID] or statsData[sn]
                                    if type(info) == "table" then
                                        local rawRank = info.Rank or info.AriseRank or info.Rise or info.Arise
                                        if rawRank then
                                            local numToRank = {
                                                [1]="E", [2]="D", [3]="C", [4]="B", [5]="A", [6]="S",
                                                ["1"]="E", ["2"]="D", ["3"]="C", ["4"]="B", ["5"]="A", ["6"]="S",
                                            }
                                            currentRank = numToRank[rawRank] or tostring(rawRank)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    local currentIdx = ariseRankIndex[currentRank] or 0
                    local targetIdx  = ariseRankIndex[ariseTargetRank] or 999
                    WindUI:Notify({
                        Title="Auto Arise",
                        Content="Current: "..(currentRank~="" and currentRank or "None").." → Target: "..ariseTargetRank,
                        Duration=3
                    })
                    if currentIdx >= targetIdx then
                        isAutoArise=false
                        WindUI:Notify({ Title="Auto Arise ✅", Content="Reached! "..currentRank.." ≥ "..ariseTargetRank, Duration=5 })
                        break
                    end
                    local tokens = getAriseTokenCount()
                    ariseTokenLabel:SetTitle("Arise Tokens: "..tokens.." | Rank: "..(currentRank~="" and currentRank or "None").." → "..ariseTargetRank)
                    if tokens <= 0 then
                        WindUI:Notify({ Title="Auto Arise", Content="No Arise Tokens! Waiting...", Duration=3 })
                        task.wait(5) continue
                    end
                    fireRemote({{{"General","Units","Arise",ariseUnitUID,n=4},"\002"}})
                    task.wait(3.5)
                end
            end)
        end
    end
})

-- ============================================================
--  TAB: PASSIVE
-- ============================================================
UnitTab:Section({ Title = "Auto Passive Unit" })

local PassiveUnitDropdown = UnitTab:Dropdown({
    Title="Select Unit", Icon="user", Values={"Loading..."},
    Callback = function(v)
        if v and unitUIDMap[v] then selectedUnitUID=unitUIDMap[v] end
    end
})

task.delay(3, function()
    local waited = 0
    while not omniReady and waited < 15 do task.wait(0.2) waited += 0.2 end
    local list = getUnitListSimple()
    PassiveUnitDropdown:Refresh(list)
    if #list > 0 and list[1] ~= "No Units Found" and list[1] ~= "Loading..." then
        selectedUnitUID = unitUIDMap[list[1]] or ""
    end
end)

UnitTab:Button({ Title="Refresh Unit List", Icon="refresh-cw",
    Callback = function()
        local list = getUnitListSimple()
        PassiveUnitDropdown:Refresh(list)
        WindUI:Notify({ Title="Refreshed", Content="Unit list updated!", Duration=2 })
    end
})

UnitTab:Divider()
UnitTab:Section({ Title = "Passive Unit Recipe" })

local passiveCraftInfoLabel = UnitTab:Section({ Title = "Select a Passive to view its recipe." })

local PassiveDropdown = UnitTab:Dropdown({
    Title="Target Passive", Icon="target", Values={"Loading..."},
    Callback = function(v)
        selectedTargetPassive=v
        if passiveCraftInfoLabel then passiveCraftInfoLabel:SetTitle(getPassiveCraftText(v)) end
    end
})

task.delay(3, function()
    local waited = 0
    while not passiveDataReady and waited < 10 do task.wait(0.2) waited += 0.2 end
    buildPassiveOrderedList()
    if PassiveDropdown then PassiveDropdown:Refresh(passiveOrderedList) end
end)

UnitTab:Button({ Title="Refresh Passive List", Icon="list",
    Callback = function()
        if not passiveDataReady then WindUI:Notify({ Title="Please wait", Content="Loading...", Duration=2 }) return end
        buildPassiveOrderedList()
        if PassiveDropdown then PassiveDropdown:Refresh(passiveOrderedList) WindUI:Notify({ Title="Refreshed", Content="Passive list updated!", Duration=2 }) end
    end
})

UnitTab:Button({ Title="Refresh Materials (recheck inventory)", Icon="refresh-cw",
    Callback = function()
        if selectedTargetPassive ~= "" and passiveCraftInfoLabel then
            passiveCraftInfoLabel:SetTitle(getPassiveCraftText(selectedTargetPassive))
        end
    end
})

UnitTab:Button({ Title="Forge Selected Passive", Icon="hammer",
    Callback = function()
        if selectedUnitUID == "" or selectedUnitUID == "0" or selectedTargetPassive == "" then
            WindUI:Notify({ Title="Error", Content="Please select a Unit and Passive first!", Duration=3 }) return
        end
        local currentPassive = ""
        pcall(function()
            local d = Omni.Data.Inventory.Units[selectedUnitUID]
            if d then currentPassive = d.Passive or "" end
        end)
        if currentPassive == selectedTargetPassive then
            WindUI:Notify({ Title="Done!", Content="This unit already has "..selectedTargetPassive, Duration=4 }) return
        end
        local config = PassivePunksData[selectedTargetPassive]
        if config and config.Items then
            fireRemote({{{"General","PassivePunks","Forge",selectedUnitUID,config.Items,n=5},"\002"}})
            WindUI:Notify({ Title="Forge Sent", Content="Forging: "..selectedTargetPassive, Duration=2 })
        else
            WindUI:Notify({ Title="Error", Content="Invalid Passive Configuration", Duration=3 })
        end
    end
})

-- ============================================================
--  ENCHANT PUNKS
-- ============================================================
local swordUIDMap = {}
local cachedSwordList    = nil
local lastSwordListTime  = 0

local function getSwordList()
    if cachedSwordList and tick() - lastSwordListTime < 300 then
        return cachedSwordList
    end
    swordUIDMap = {}
    local swords   = {}
    local foundInv = nil
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Inventory") then
            local inv = rawget(v, "Inventory")
            if type(inv) == "table" and rawget(inv, "Swords") then
                local swordInv = rawget(inv, "Swords")
                local count = 0
                for _ in pairs(swordInv) do count += 1 end
                if count > 0 then foundInv = swordInv break end
            end
        end
    end
    if foundInv then
        local nameCount = {}
        for uid, data in pairs(foundInv) do
            if type(data) == "table" then
                local name = rawget(data, "Name") or "Unknown"
                nameCount[name] = (nameCount[name] or 0) + 1
                local displayName = name .. " #" .. nameCount[name]
                table.insert(swords, displayName)
                swordUIDMap[displayName] = uid
            end
        end
    end
    if #swords == 0 then table.insert(swords, "No Swords Found") end
    table.sort(swords)
    cachedSwordList   = swords
    lastSwordListTime = tick()
    return swords
end

SwordTab:Divider()
SwordTab:Section({ Title = "Enchant Sword" })

local EnchantSwordDropdown = SwordTab:Dropdown({
    Title="Select Sword", Icon="swords", Values={"Loading..."},
    Callback = function(v)
        if v and swordUIDMap[v] then selectedEnchantUnitUID=swordUIDMap[v] end
    end
})

task.delay(3.2, function()
    local waited = 0
    while not omniReady and waited < 15 do task.wait(0.2) waited += 0.2 end
    task.wait(1)
    local list = getSwordList()
    EnchantSwordDropdown:Refresh(list)
    if #list > 0 and list[1] ~= "No Swords Found" and list[1] ~= "Loading..." then
        selectedEnchantUnitUID = swordUIDMap[list[1]] or ""
    end
end)

SwordTab:Button({ Title="Refresh Sword List", Icon="refresh-cw",
    Callback = function()
        task.wait(0.2)
        local list = getSwordList()
        EnchantSwordDropdown:Refresh(list)
        WindUI:Notify({ Title="Refreshed", Content="Enchant sword list updated!", Duration=2 })
    end
})

SwordTab:Divider()
SwordTab:Section({ Title = "Enchant Sword Recipe" })

local enchantCraftInfoLabel = SwordTab:Section({ Title = "Select an Enchant to view its recipe." })

local EnchantDropdown = SwordTab:Dropdown({
    Title="Target Enchant", Icon="wand-2", Values={"Loading..."},
    Callback = function(v)
        selectedTargetEnchant=v
        if enchantCraftInfoLabel then enchantCraftInfoLabel:SetTitle(getEnchantCraftText(v)) end
    end
})

task.delay(3.5, function()
    local waited = 0
    while not enchantDataReady and waited < 10 do task.wait(0.2) waited += 0.2 end
    buildEnchantOrderedList()
    if EnchantDropdown then
        EnchantDropdown:Refresh(#enchantOrderedList > 0 and enchantOrderedList or {"No Enchants Found"})
    end
end)

SwordTab:Button({ Title="Refresh Enchant List", Icon="list",
    Callback = function()
        if not enchantDataReady then WindUI:Notify({ Title="Please wait", Content="Loading...", Duration=2 }) return end
        buildEnchantOrderedList()
        if EnchantDropdown then
            EnchantDropdown:Refresh(#enchantOrderedList > 0 and enchantOrderedList or {"No Enchants Found"})
            WindUI:Notify({ Title="Refreshed", Content="Enchant list updated!", Duration=2 })
        end
    end
})

SwordTab:Button({ Title="Refresh Materials (Enchant)", Icon="refresh-cw",
    Callback = function()
        if selectedTargetEnchant ~= "" and enchantCraftInfoLabel then
            enchantCraftInfoLabel:SetTitle(getEnchantCraftText(selectedTargetEnchant))
        end
    end
})

SwordTab:Button({ Title="Forge Selected Enchant", Icon="hammer",
    Callback = function()
        if selectedEnchantUnitUID == "" or selectedEnchantUnitUID == "0" or selectedTargetEnchant == "" then
            WindUI:Notify({ Title="Error", Content="Please select a Sword and Enchant first!", Duration=3 }) return
        end
        local currentEnchant = ""
        pcall(function()
            local d = Omni.Data.Inventory.Swords[selectedEnchantUnitUID]
            if d then currentEnchant = d.Enchant or "" end
        end)
        if currentEnchant == selectedTargetEnchant then
            WindUI:Notify({ Title="Done!", Content="This sword already has "..selectedTargetEnchant, Duration=4 }) return
        end
        local config = EnchantPunksData[selectedTargetEnchant]
        if config and config.Items then
            fireRemote({{{"General","EnchantPunks","Forge",selectedEnchantUnitUID,config.Items,n=5},"\002"}})
            WindUI:Notify({ Title="Forge Sent", Content="Enchanting sword: "..selectedTargetEnchant, Duration=2 })
        else
            WindUI:Notify({ Title="Error", Content="Invalid Enchant Configuration", Duration=3 })
        end
    end
})

-- ============================================================
--  SWORDS FORGE
-- ============================================================
SwordTab:Divider()
SwordTab:Section({ Title = "Swords Forge" })

local forgeData = {
    ["Sand Dagger"]     = { Requirements = { {Item="Blue Ore",Amount=125}, {Item="Yellow Ore",Amount=75}, {Item="Green Ore",Amount=100}, {Item="Architect Token",Amount=100} } },
    ["Fire Dagger"]     = { Requirements = { {Item="Red Ore",Amount=200}, {Item="Yellow Ore",Amount=125}, {Item="Orange Ore",Amount=100}, {Item="Architect Token",Amount=250} } },
    ["Commander Sword"] = { Requirements = { {Item="Red Ore",Amount=100}, {Item="Yellow Ore",Amount=200}, {Item="Orange Ore",Amount=250}, {Item="Architect Token",Amount=750} } },
    ["Shadow Sword"]    = { Requirements = { {Item="Red Ore",Amount=175}, {Item="Blue Ore",Amount=350}, {Item="Purple Ore",Amount=250}, {Item="Architect Token",Amount=2000} } },
}
local forgeItemNames = { "Sand Dagger", "Fire Dagger", "Commander Sword", "Shadow Sword" }
local selectedForgeItem = forgeItemNames[1]

local function getForgeCraftText(itemName)
    if itemName == "" then return "Select a Sword to view its recipe." end
    local data = forgeData[itemName]
    if not data then return "No data found for: " .. itemName end
    local lines = { "[ " .. itemName .. " ]", "" }
    for _, req in ipairs(data.Requirements) do
        local have = 0
        pcall(function() have = math.floor(tonumber(Omni.Data.Inventory.Items[req.Item]) or 0) end)
        local status = have >= req.Amount and "[OK]" or "[--]"
        table.insert(lines, string.format("%s  %s  x%d  (have: %d)", status, req.Item, req.Amount, have))
    end
    return table.concat(lines, "\n")
end

local forgeCraftInfoLabel = SwordTab:Section({ Title = "Select a Sword to view its recipe." })

SwordTab:Dropdown({
    Title="Select Sword to Forge", Icon="swords", Values=forgeItemNames, Value=forgeItemNames[1],
    Callback = function(v)
        selectedForgeItem = v
        if forgeCraftInfoLabel then forgeCraftInfoLabel:SetTitle(getForgeCraftText(v)) end
    end
})

SwordTab:Button({ Title="Refresh Materials (Forge)", Icon="refresh-cw",
    Callback = function()
        if forgeCraftInfoLabel then forgeCraftInfoLabel:SetTitle(getForgeCraftText(selectedForgeItem)) end
    end
})

SwordTab:Button({ Title="Forge Selected Sword", Icon="hammer",
    Callback = function()
        if selectedForgeItem == "" then
            WindUI:Notify({ Title="Error", Content="Please select a Sword to forge first!", Duration=3 }) return
        end
        local data = forgeData[selectedForgeItem]
        if not data then
            WindUI:Notify({ Title="Error", Content="Invalid sword data!", Duration=3 }) return
        end
        local canForge = true
        local missing = {}
        for _, req in ipairs(data.Requirements) do
            local have = 0
            pcall(function() have = math.floor(tonumber(Omni.Data.Inventory.Items[req.Item]) or 0) end)
            if have < req.Amount then
                canForge = false
                table.insert(missing, req.Item .. " (need " .. req.Amount .. ", have " .. have .. ")")
            end
        end
        if not canForge then
            WindUI:Notify({ Title="Not Enough Materials!", Content="Missing:\n" .. table.concat(missing, "\n"), Duration=5 })
            return
        end
        local reqTable = {}
        for _, req in ipairs(data.Requirements) do
            table.insert(reqTable, { Type="Item", Item=req.Item, Amount=req.Amount })
        end
        fireRemote({{{"General","Forge","Craft","Swords Forge",selectedForgeItem,reqTable,n=6},"\002"}})
        WindUI:Notify({ Title="Forge Sent", Content="Forging: " .. selectedForgeItem, Duration=3 })
        task.delay(1.5, function()
            if forgeCraftInfoLabel then forgeCraftInfoLabel:SetTitle(getForgeCraftText(selectedForgeItem)) end
        end)
    end
})

SwordTab:Toggle({
    Title="Auto Craft Swords Forge", Icon="repeat", Desc="Auto craft when materials are ready",
    Type="Checkbox", Value=Options.AutoCraftSwordsForge or false,
    Callback = function(v)
        Options.AutoCraftSwordsForge=v SaveConfig()
        if v then
            task.spawn(function()
                while Options.AutoCraftSwordsForge do
                    pcall(function()
                        if not Omni then return end
                        local data = forgeData[selectedForgeItem]
                        if not data then return end
                        local canCraft = true
                        for _, req in ipairs(data.Requirements) do
                            local have = math.floor(tonumber(Omni.Data.Inventory.Items[req.Item] or 0) or 0)
                            if have < req.Amount then canCraft = false break end
                        end
                        if canCraft then
                            local reqTable = {}
                            for _, req in ipairs(data.Requirements) do
                                table.insert(reqTable, { Type="Item", Item=req.Item, Amount=req.Amount })
                            end
                            fireRemote({{{"General","Forge","Craft","Swords Forge",selectedForgeItem,reqTable,n=6},"\002"}})
                            WindUI:Notify({ Title="Auto Craft ⚒", Content="Crafting: "..selectedForgeItem, Duration=2 })
                            task.wait(2)
                            if forgeCraftInfoLabel then
                                forgeCraftInfoLabel:SetTitle(getForgeCraftText(selectedForgeItem))
                            end
                        end
                    end)
                    task.wait(3)
                end
            end)
        end
    end
})
-- ============================================================
--  TAB: ACCESSORY
-- ============================================================
local AccessoryEvolveData = {}
local accessoryEvolveReady = false

task.spawn(function()
    local waited = 0
    while not omniReady and waited < 15 do task.wait(0.2) waited += 0.2 end
    local ok, data = pcall(function()
        return require(RS:WaitForChild("Omni",15):WaitForChild("Shared",10):WaitForChild("AccessoryEvolve",10))
    end)
    if ok and type(data) == "table" and data.List then
        AccessoryEvolveData = data.List
    end
    accessoryEvolveReady = true
end)

-- UID Map สำหรับ Accessory
local accessoryUIDMap = {}

local function getAccessoryList()
    accessoryUIDMap = {}
    local accs = {}
    if not Omni then return { "Loading..." } end
    pcall(function()
        local inv = Omni.Data.Inventory.Accessories
        if type(inv) == "table" then
            local nameCount = {}
            for uid, data in pairs(inv) do
                if type(data) == "table" then
                    local name = data.Name or "Unknown"
                    -- แก้ไข: ใช้ Evolve field ตรงๆ
                    local level = tonumber(data.Evolve) or 0
                    local equipTag = data.Equipped and "[✔] " or ""
                    local base = string.format("%s%s [Lv.%d]", equipTag, name, level)
                    nameCount[base] = (nameCount[base] or 0) + 1
                    local displayName = base .. " #" .. nameCount[base]
                    table.insert(accs, displayName)
                    accessoryUIDMap[displayName] = uid
                end
            end
        end
    end)
    if #accs == 0 then table.insert(accs, "No Accessories Found") end
    table.sort(accs)
    return accs
end

local function getAccessoryEvolveLevel(uid)
    local level = 0
    pcall(function()
        local data = Omni.Data.Inventory.Accessories[uid]
        if data then
            level = tonumber(data.Evolve) or 0
        end
    end)
    return level
end

-- ฟังก์ชันสร้าง text แสดง recipe ของแต่ละ level
local function getEvolveLevelText(levelIndex)
    local entry = AccessoryEvolveData[levelIndex]
    if not entry then return "No data for Level " .. levelIndex end

    local lines = {}
    table.insert(lines, string.format("[ Level %d → %d ] (Chance: %d%%)", levelIndex - 1, levelIndex, entry.Chance or 0))
    table.insert(lines, "")

    -- Perks ที่จะได้รับ
    if entry.Perks and next(entry.Perks) then
        table.insert(lines, "Perks:")
        for perkName, perkData in pairs(entry.Perks) do
            local pType   = perkData.Type or "?"
            local pAmount = perkData.Amount or 0
            if pType == "Multi" then
                table.insert(lines, string.format("  • %s ×%.2f", perkName, pAmount))
            else
                table.insert(lines, string.format("  • %s +%.2f", perkName, pAmount))
            end
        end
        table.insert(lines, "")
    end

    -- Requirements
    if entry.Requirements and #entry.Requirements > 0 then
        table.insert(lines, "Materials:")
        for _, req in ipairs(entry.Requirements) do
            local itemName = req.Item or "?"
            local required = tonumber(req.Amount) or 0
            local have = 0
            pcall(function()
                have = math.floor(tonumber(Omni.Data.Inventory.Items[itemName]) or 0)
            end)
            local status = have >= required and "[OK]" or "[--]"
            table.insert(lines, string.format("  %s  %s  x%d  (have: %d)", status, itemName, required, have))
        end
    end

    return table.concat(lines, "\n")
end

-- ============================================================
--  UI ของ Accessory Tab
-- ============================================================
AccessoryTab:Section({ Title = "Accessory Evolve" })

local selectedAccessoryUID   = ""
local selectedEvolveTarget   = 1
local isAutoEvolveAccessory  = false

-- Dropdown เลือก Accessory
local AccessoryDropdown = AccessoryTab:Dropdown({
    Title = "Select Accessory", Icon = "gem", Values = { "Press Refresh" },
    Callback = function(v)
        if v and accessoryUIDMap[v] then
            selectedAccessoryUID = accessoryUIDMap[v]
        end
    end
})

AccessoryTab:Button({
    Title = "Refresh Accessory List", Icon = "refresh-cw",
    Callback = function()
        local list = getAccessoryList()
        AccessoryDropdown:Refresh(list)
        WindUI:Notify({ Title = "Refreshed", Content = "Accessory list updated!", Duration = 2 })
    end
})

task.delay(3.5, function()
    local waited = 0
    while not omniReady and waited < 15 do task.wait(0.2) waited += 0.2 end
    local list = getAccessoryList()
    AccessoryDropdown:Refresh(list)
    if #list > 0 and list[1] ~= "No Accessories Found" and list[1] ~= "Loading..." then
        selectedAccessoryUID = accessoryUIDMap[list[1]] or ""
    end
end)

-- Dropdown เลือก Target Level
local evolveLevelValues = {}
task.delay(4, function()
    local waited = 0
    while not accessoryEvolveReady and waited < 15 do task.wait(0.2) waited += 0.2 end
    for i = 1, #AccessoryEvolveData do
        table.insert(evolveLevelValues, "Level " .. i)
    end
    if #evolveLevelValues == 0 then
        -- fallback ถ้าโหลดไม่ได้
        for i = 1, 5 do table.insert(evolveLevelValues, "Level " .. i) end
    end
    if EvolveLevelDropdown then EvolveLevelDropdown:Refresh(evolveLevelValues) end
end)

-- Label แสดง recipe
local evolveRecipeLabel = AccessoryTab:Section({ Title = "Select an Accessory & Level to view recipe." })

EvolveLevelDropdown = AccessoryTab:Dropdown({
    Title = "Target Level", Icon = "arrow-up-circle",
    Values = { "Loading..." },
    Callback = function(v)
        local n = tonumber(string.match(v or "", "(%d+)"))
        if n then
            selectedEvolveTarget = n
            evolveRecipeLabel:SetTitle(getEvolveLevelText(n))
        end
    end
})

-- Button refresh recipe (เช็ค inventory ใหม่)
AccessoryTab:Button({
    Title = "Refresh Materials", Icon = "refresh-cw",
    Callback = function()
        if selectedEvolveTarget >= 1 then
            evolveRecipeLabel:SetTitle(getEvolveLevelText(selectedEvolveTarget))
        end
    end
})

-- Button Evolve ครั้งเดียว
AccessoryTab:Button({
    Title = "Evolve Accessory (Once)", Icon = "zap",
    Callback = function()
        if selectedAccessoryUID == "" then
            WindUI:Notify({ Title = "Error", Content = "Please select an Accessory first!", Duration = 3 })
            return
        end
        local entry = AccessoryEvolveData[selectedEvolveTarget]
        if not entry then
            WindUI:Notify({ Title = "Error", Content = "Invalid evolve level!", Duration = 3 })
            return
        end
        -- เช็ค materials ก่อน
        local canEvolve = true
        local missing = {}
        for _, req in ipairs(entry.Requirements or {}) do
            local have = 0
            pcall(function() have = math.floor(tonumber(Omni.Data.Inventory.Items[req.Item]) or 0) end)
            if have < req.Amount then
                canEvolve = false
                table.insert(missing, req.Item .. " (need " .. req.Amount .. ", have " .. have .. ")")
            end
        end
        if not canEvolve then
            WindUI:Notify({ Title = "Not Enough Materials!", Content = table.concat(missing, "\n"), Duration = 5 })
            return
        end
        fireRemote({{{"General","Accessories","Evolve",selectedAccessoryUID,selectedEvolveTarget,n=5},"\002"}})
        WindUI:Notify({ Title = "Evolve Sent!", Content = "Evolving to Level " .. selectedEvolveTarget .. "...", Duration = 3 })
        task.delay(1.5, function()
            evolveRecipeLabel:SetTitle(getEvolveLevelText(selectedEvolveTarget))
            local list = getAccessoryList()
            AccessoryDropdown:Refresh(list)
        end)
    end
})

AccessoryTab:Divider()

-- ============================================================
--  AUTO EVOLVE
-- ============================================================
AccessoryTab:Section({ Title = "Auto Evolve" })

local autoEvolveStopLevel  = 5   
local autoEvolveMaxRetries = 50 

AccessoryTab:Slider({
    Title = "Stop at Level", Icon = "flag", Step = 1,
    Value = { Min = 1, Max = 5, Default = 5 },
    Callback = function(v) autoEvolveStopLevel = v end
})

AccessoryTab:Slider({
    Title = "Max Retries (per level)", Icon = "repeat", Step = 1,
    Value = { Min = 1, Max = 200, Default = 50 },
    Callback = function(v) autoEvolveMaxRetries = v end
})

AccessoryTab:Toggle({
    Title = "Auto Evolve Accessory", Icon = "zap", Type = "Checkbox", Value = false,
    Desc = "Auto evolve selected accessory until reaching Stop Level",
    Callback = function(v)
        isAutoEvolveAccessory = v
        if isAutoEvolveAccessory then
            task.spawn(function()
                while isAutoEvolveAccessory do
                    if selectedAccessoryUID == "" then
                        WindUI:Notify({ Title = "Auto Evolve", Content = "Please select an Accessory first!", Duration = 3 })
                        task.wait(2) continue
                    end

                    local currentLevel = getAccessoryEvolveLevel(selectedAccessoryUID)

                    -- ถึง stop level แล้ว หยุด
                    if currentLevel >= autoEvolveStopLevel then
                        isAutoEvolveAccessory = false
                        WindUI:Notify({
                            Title = "Auto Evolve ✅",
                            Content = "Reached Level " .. currentLevel .. "! Stopped.",
                            Duration = 5
                        })
                        break
                    end

                    local nextLevel = currentLevel + 1
                    local entry = AccessoryEvolveData[nextLevel]
                    if not entry then
                        WindUI:Notify({ Title = "Auto Evolve", Content = "No data for Level " .. nextLevel .. ". Stopped.", Duration = 4 })
                        isAutoEvolveAccessory = false
                        break
                    end

                    local canEvolve = true
                    local missing = {}
                    for _, req in ipairs(entry.Requirements or {}) do
                        local have = 0
                        pcall(function() have = math.floor(tonumber(Omni.Data.Inventory.Items[req.Item]) or 0) end)
                        if have < req.Amount then
                            canEvolve = false
                            table.insert(missing, req.Item .. " (need " .. req.Amount .. ", have " .. have .. ")")
                        end
                    end

                    if not canEvolve then
                        WindUI:Notify({
                            Title = "Auto Evolve — No Materials",
                            Content = "Missing for Lv." .. nextLevel .. ":\n" .. table.concat(missing, "\n"),
                            Duration = 5
                        })
                        isAutoEvolveAccessory = false
                        break
                    end

                    -- ส่ง Evolve
                    WindUI:Notify({
                        Title = "Auto Evolve",
                        Content = "Evolving Lv." .. currentLevel .. " → Lv." .. nextLevel .. " (Chance: " .. (entry.Chance or "?") .. "%)",
                        Duration = 3
                    })
                    fireRemote({{{"General","Accessories","Evolve",selectedAccessoryUID,nextLevel,n=5},"\002"}})
                    task.wait(2)

                    -- อัพเดต recipe label
                    evolveRecipeLabel:SetTitle(getEvolveLevelText(nextLevel))

                    -- รีเฟรช dropdown เพื่ออัพ level ที่แสดง
                    local list = getAccessoryList()
                    AccessoryDropdown:Refresh(list)

                    task.wait(0.5)
                end
            end)
        end
    end
})

-- ============================================================
--  TAB: GACHA
-- ============================================================
GachaTab:Section({ Title = "Auto Roll" })

GachaTab:Toggle({ Title="Auto Roll Haki", Icon="dices", Type="Checkbox", Value=Options.AutoHaki or false,
    Callback=function(v) S.isAutoGacha=v Options.AutoHaki=v SaveConfig()
        if S.isAutoGacha then task.spawn(function() while S.isAutoGacha do fireRemote({{{"General","Gacha","Roll","Haki",{},n=5},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Fruit", Icon="apple", Type="Checkbox", Value=Options.AutoFruit or false,
    Callback=function(v) S.isAutoFruit=v Options.AutoFruit=v SaveConfig()
        if S.isAutoFruit then task.spawn(function() while S.isAutoFruit do fireRemote({{{"General","Gacha","Roll","Fruit",{},n=5},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Sword", Icon="swords", Type="Checkbox", Value=Options.AutoSword or false,
    Callback=function(v) S.isAutoSword=v Options.AutoSword=v SaveConfig()
        if S.isAutoSword then task.spawn(function() while S.isAutoSword do fireRemote({{{"General","Banner","Roll","Swords Banner",n=4},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Race", Icon="dna", Type="Checkbox", Value=Options.AutoRace or false,
    Callback=function(v) S.isAutoRollRace=v Options.AutoRace=v SaveConfig()
        if S.isAutoRollRace then task.spawn(function() while S.isAutoRollRace do fireRemote({{{"General","Gacha","Roll","Race",{},n=5},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Spin Wheel", Icon="ferris-wheel", Type="Checkbox", Value=Options.AutoSpinWheel or false,
    Callback=function(v) S.isAutoRollFightStyle=v Options.AutoSpinWheel=v SaveConfig()
        if S.isAutoRollFightStyle then task.spawn(function() while S.isAutoRollFightStyle do fireRemote({{{"General","Roulette","Roll","Dragon Wish",{},n=4},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Dragon Power", Icon="activity", Type="Checkbox", Value=Options.AutoDragonPower or false,
    Callback=function(v) S.isAutoRollClass=v Options.AutoDragonPower=v SaveConfig()
        if S.isAutoRollClass then task.spawn(function() while S.isAutoRollClass do fireRemote({{{"General","Gacha","Roll","Dragon Power",{},n=5},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Slime Power", Icon="panda", Type="Checkbox", Value=Options.AutoSlimePower or false,
    Callback=function(v) S.isAutoRollSlimePower=v Options.AutoSlimePower=v SaveConfig()
        if S.isAutoRollSlimePower then task.spawn(function() while S.isAutoRollSlimePower do fireRemote({{{"General","Gacha","Roll","Slime Power",{},n=5},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Primordial Demon", Icon="flame", Type="Checkbox", Value=Options.AutoPrimordial or false,
    Callback=function(v) S.isAutoPrimordial=v Options.AutoPrimordial=v SaveConfig()
        if S.isAutoPrimordial then task.spawn(function() while S.isAutoPrimordial do fireRemote({{{"General","Gacha","Roll","Primordial Demon",{},n=5},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Fighters Banner", Icon="shield", Type="Checkbox", Value=Options.AutoFightersBanner or false,
    Callback=function(v) S.isAutoRollFighters=v Options.AutoFightersBanner=v SaveConfig()
        if S.isAutoRollFighters then task.spawn(function() while S.isAutoRollFighters do fireRemote({{{"General","Banner","Roll","Fighters Banner",n=4},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Cursed Technique", Icon="wand", Type="Checkbox", Value=Options.AutoCursedTech or false,
    Callback=function(v) S.isAutoRollCursed=v Options.AutoCursedTech=v SaveConfig()
        if S.isAutoRollCursed then task.spawn(function() while S.isAutoRollCursed do fireRemote({{{"General","Gacha","Roll","Cursed Technique",{},n=5},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Cursed Spirit", Icon="ghost", Type="Checkbox", Value=Options.AutoCursedSpirit or false,
    Callback=function(v) Options.AutoCursedSpirit=v SaveConfig()
        if v then task.spawn(function() while Options.AutoCursedSpirit do fireRemote({{{"General","Gacha","Roll","Cursed Spirit",{},n=5},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Hunter Rank", Icon="shield-check", Type="Checkbox", Value=Options.AutoHunterRank or false,
    Callback=function(v) Options.AutoHunterRank=v SaveConfig()
        if v then task.spawn(function() while Options.AutoHunterRank do fireRemote({{{"General","Gacha","Roll","Hunter Rank",{},n=5},"\002"}}) task.wait(0.5) end end) end end })

GachaTab:Toggle({ Title="Auto Roll Monarch Awakening", Icon="crown", Type="Checkbox", Value=Options.AutoMonarchAwakening or false,
    Callback=function(v) Options.AutoMonarchAwakening=v SaveConfig()
        if v then task.spawn(function() while Options.AutoMonarchAwakening do fireRemote({{{"General","Gacha","Roll","Monarch Awakening",{},n=5},"\002"}}) task.wait(0.5) end end) end end })
GachaTab:Toggle({ Title="Auto Roll Gotei Hierarchy", Icon="shield", Type="Checkbox", Value=Options.AutoGoteiHierarchy or false,
    Callback=function(v) Options.AutoGoteiHierarchy=v SaveConfig()
        if v then task.spawn(function() while Options.AutoGoteiHierarchy do fireRemote({{{"General","Gacha","Roll","Gotei Hierarchy",{},n=5},"\002"}}) task.wait(0.5) end end) end end })
-- ============================================================
--  TAB: UPGRADE
-- ============================================================
UpgradeTab:Section({ Title = "Auto Upgrade" })

UpgradeTab:Toggle({ Title="Auto Upgrade Fighting Style", Icon="dumbbell", Type="Checkbox", Value=Options.AutoFightStyle or false,
    Callback=function(v) S.isAutoFightStyle=v Options.AutoFightStyle=v SaveConfig()
        if S.isAutoFightStyle then task.spawn(function() while S.isAutoFightStyle do fireRemote({{{"General","Progression","Upgrade","Fighting Style",n=4},"\002"}}) task.wait(0.5) end end) end end })

UpgradeTab:Toggle({ Title="Auto Upgrade Ki Progression", Icon="flame", Type="Checkbox", Value=Options.AutoKiProgression or false,
    Callback=function(v) S.isAutoKiProgression=v Options.AutoKiProgression=v SaveConfig()
        if S.isAutoKiProgression then task.spawn(function() while S.isAutoKiProgression do fireRemote({{{"General","Progression","Upgrade","Ki Progression",n=4},"\002"}}) task.wait(0.5) end end) end end })

UpgradeTab:Toggle({ Title="Auto Upgrade Aura", Icon="lollipop", Type="Checkbox", Value=Options.AutoAura or false,
    Callback=function(v) S.isAutoAura=v Options.AutoAura=v SaveConfig()
        if S.isAutoAura then task.spawn(function() while S.isAutoAura do fireRemote({{{"General","Aura","Upgrade",n=3},"\002"}}) task.wait(0.5) end end) end end })

UpgradeTab:Toggle({ Title="Auto Upgrade Demon Lord", Icon="shrub", Type="Checkbox", Value=Options.AutoDemonLord or false,
    Callback=function(v) S.isAutoDemonlord=v Options.AutoDemonLord=v SaveConfig()
        if S.isAutoDemonlord then task.spawn(function() while S.isAutoDemonlord do fireRemote({{{"General","Progression","Upgrade","Demon Lord Progression",n=4},"\002"}}) task.wait(0.5) end end) end end })

UpgradeTab:Toggle({ Title="Auto Upgrade Domain Progression", Icon="layers", Type="Checkbox", Value=Options.AutoDomainProgression or false,
    Callback=function(v) S.isAutoUpgradeDomain=v Options.AutoDomainProgression=v SaveConfig()
        if S.isAutoUpgradeDomain then task.spawn(function() while S.isAutoUpgradeDomain do fireRemote({{{"General","Progression","Upgrade","Domain Progression",n=4},"\002"}}) task.wait(0.5) end end) end end })

UpgradeTab:Toggle({ Title="Auto Upgrade System Progression", Icon="cpu", Type="Checkbox", Value=Options.AutoSystemProgression or false,
    Callback=function(v) Options.AutoSystemProgression=v SaveConfig()
        if v then task.spawn(function() while Options.AutoSystemProgression do fireRemote({{{"General","Progression","Upgrade","System Progression",n=4},"\002"}}) task.wait(0.5) end end) end end })
UpgradeTab:Toggle({ Title="Auto Upgrade Hogyoku Progression", Icon="gem", Type="Checkbox", Value=Options.AutoHogyokuProgression or false,
    Callback=function(v) Options.AutoHogyokuProgression=v SaveConfig()
        if v then task.spawn(function() while Options.AutoHogyokuProgression do fireRemote({{{"General","Progression","Upgrade","Hogyoku Progression",n=4},"\002"}}) task.wait(0.5) end end) end end })
-- ============================================================
--  TAB: MISC
-- ============================================================
local redeemCodesList = {
    "RELEASE","SRRY4SHUTDOWN","SRRY4SHUTDOWN2","TIOGADIHIT!",
    "THX1KCCU","2KCCU!","THANKYOU3KCCU","4KONCHAMBER!",
    "ALREADY5K?","6KTHXSOMUCH","7KISALOT!","THANKS1KLIKES",
    "100KVISITSONCHAMBER!","SRRY4SHUTDOWN3","RELEASEPATCH",
    "TY2KLIKES!!","THXFOR200KVISITS!","300KVISITSTHANKYOU!",
    "400KVISITSINCREDIBLE","WOW500KVISITS!","1KFAVORITESTHX!",
    "RELEASEPT2","EVENT2.5K!","THXFOR3KFAVORITES!",
    "THX3KLIKES!","600KVISITSYAY!","700KVISITSINGAME","2KFAVORITESTHANKYOU!",
    "SPLENDID800KVISITS!","900KVISITSTHANKYOU!","ALREADY1MVISITS!?","THXFOR4KLIKES",
    "RELEASEQOL","COOL1.2MVISITS!","YAY5KLIKES!","8KCCUISAWESOME!",
    "UPDATE1","SRRY4DELAY","AWESOME11KCCU","9KPLAYERS",
    "WOW10KCCU","6KLIKESLOVU!","GOOD7KLIKES!","AWESOME1.4MVISITS!",
    "1.6MILLIONVISITS!","1.8MILLIONVISITSALREADY?!","2MILLIONSSSVISITS!","SRRY4UPDPROBLEMS",
    "LOVE8KLIKES!","THXSOMUCHFOR9KLIKES!",
    "2.2MVISITS!!","2.4MVISITSTYSM!!","2.6MILLIONVISITSTY!","2.8MILLIONVISITSTHX!","3MILLIONVISITSWOAH!",
    "OHYEAH3.5MILLIONVISITS!","4KFAVORITESYOUAREREAL!","LOVEUALL5KFAVORITES","6KFAVORITESWOAH!",
    "7KFAVORITESSS!","8KFAVORITESINWF!","YAY9KFAVORITES!","UPDATE1QOL","UPDATE2","SRRY4SHUTDOWN","CANTBELIEVE12KCCU!",
    "WOW10KLIKES!","11KLIKESLETSGO!","12KLIKESINSANE!","13KLIKESMILESTONE!","TYFOR14KLIKES!","ALREADY15KLIKESAWESOME?!",
    "OMG4MILLIONVISITS!","4.5MILLIONVISITSYOOO!","5MILLIONVISITSINSANE!","10KFAVORITESTYSM!","11KFAVORITESNOWAY!","12KFAVORITESBABY!",
    "15KFAVORITES!!!","20KFAVORITESYAY!!","DAMN25KFAVORITES!!","13KPLAYERSISALOT","UPDATE2PT2","SRRY4SHUTDOWN","17.5KLIKES?!","6MILLIONVISITSYO!!!",
    "7MILLIONVISITSYAY!?!","DAMN25KFAVORITES!!","YEAAA30KFAVORITES!!","SRRY4SHUTDOWN2","UPDATE3","!!8MILLIONVISITS!!","40KFAVORITES!TY!","20KLIKESYOUAREINSANE?!","SRRY4SHUTDOWN"
}
Options.RedeemedCodes = Options.RedeemedCodes or {}

MiscTab:Section({ Title = "Codes" })

MiscTab:Button({ Title="Redeem New Codes", Icon="ticket",
    Callback = function()
        task.spawn(function()
            local count = 0
            for _, code in ipairs(redeemCodesList) do
                if not Options.RedeemedCodes[code] then
                    fireRemote({{{"General","Codes","Redeem",code,n=4},"\002"}})
                    Options.RedeemedCodes[code]=true
                    count += 1
                    task.wait(3)
                end
            end
            SaveConfig()
            if count > 0 then
                WindUI:Notify({ Title="Codes Redeemed", Content="Redeemed "..count.." new code(s)!", Duration=3 })
            else
                WindUI:Notify({ Title="No New Codes", Content="All codes have been redeemed!", Duration=3 })
            end
        end)
    end
})

MiscTab:Button({ Title="Reset Redeemed History", Icon="rotate-ccw",
    Callback = function()
        Options.RedeemedCodes = {} SaveConfig()
        WindUI:Notify({ Title="Cleared", Content="Redeemed code history cleared!", Duration=3 })
    end
})

MiscTab:Divider()
MiscTab:Section({ Title = "Auto Rewards" })

local function claimAllChests()
    local chests = {"Daily Chest", "Group Chest", "VIP Chest"}
    for _, chestName in ipairs(chests) do
        fireRemote({{{"General","Chests","Claim",chestName,n=4},"\002"}})
        task.wait(0.5)
    end
    WindUI:Notify({ Title="Chests", Content="Claimed all available chests!", Duration=3 })
end

MiscTab:Toggle({
    Title="Auto Claim Chests", Icon="package", Type="Checkbox",
    Desc="Auto claim chests every 60 minutes",
    Value=Options.AutoClaimChests or false,
    Callback = function(v)
        Options.AutoClaimChests=v SaveConfig()
        if v then
            task.spawn(function()
                claimAllChests()
                while Options.AutoClaimChests do
                    task.wait(3600)
                    if Options.AutoClaimChests then claimAllChests() end
                end
            end)
        end
    end
})

MiscTab:Toggle({ Title="Auto Collect Time Reward", Icon="clock", Type="Checkbox", Value=Options.AutoTimeReward or false,
    Callback = function(v)
        S.isAutoReward=v Options.AutoTimeReward=v SaveConfig()
        if S.isAutoReward then
            task.spawn(function()
                while S.isAutoReward do
                    local okR, resetBtn = pcall(function() return player.PlayerGui.UI.Frames.TimeRewards.Background.Main.Reset end)
                    if okR and resetBtn and resetBtn.Visible then
                        fireRemote({{{ "General","TimeRewards","Reset",n=3 },"\002"}}) task.wait(0.5)
                    end
                    for i=1,7 do
                        if not S.isAutoReward then break end
                        local ok, tt = pcall(function()
                            local obj = player.PlayerGui.UI.Frames.TimeRewards.Background.Main.Rewards[tostring(i)].Main.Time
                            return (obj:IsA("TextLabel") or obj:IsA("TextBox")) and (obj.ContentText ~= "" and obj.ContentText or obj.Text) or tostring(obj.Text)
                        end)
                        if ok and type(tt) == "string" and string.lower(tt) == "ready" then
                            fireRemote({{{ "General","TimeRewards","Claim",i,n=4 },"\002"}}) task.wait(0.3)
                        end
                    end
                    task.wait(5)
                end
            end)
        end
    end
})

MiscTab:Toggle({ Title="Auto Claim Daily Reward", Icon="calendar", Type="Checkbox", Value=Options.AutoDailyReward or false,
    Callback = function(v)
        S.isAutoDailyReward=v Options.AutoDailyReward=v SaveConfig()
        if S.isAutoDailyReward then
            task.spawn(function()
                while S.isAutoDailyReward do
                    for i=1,7 do
                        if not S.isAutoDailyReward then break end
                        local ok, tt = pcall(function()
                            local obj = player.PlayerGui.UI.Frames.DailyRewards.Background.Main.Rewards[tostring(i)].Main.Time
                            return (obj:IsA("TextLabel") or obj:IsA("TextBox")) and (obj.ContentText ~= "" and obj.ContentText or obj.Text) or tostring(obj.Text)
                        end)
                        if ok and type(tt) == "string" and string.lower(tt) == "ready" then
                            fireRemote({{{"General","DailyRewards","Claim",i,n=4},"\002"}}) task.wait(0.3)
                        end
                    end
                    task.wait(60)
                end
            end)
        end
    end
})

MiscTab:Toggle({ Title="Auto Claim Achievement", Icon="award", Type="Checkbox", Value=Options.AutoAchieve or false,
    Callback = function(v)
        S.isAutoAchieve=v Options.AutoAchieve=v SaveConfig()
        for _, conn in ipairs(achieveConnections) do if conn.Connected then conn:Disconnect() end end
        achieveConnections = {}
        if S.isAutoAchieve then
            task.spawn(function()
                local ok, list = pcall(function() return player.PlayerGui.UI.Frames.Achievements.Background.Main.List end)
                if not (ok and list) then return end
                local function checkAndClaim(text)
                    if not S.isAutoAchieve then return end
                    local p = text:match("(%d+%.?%d*)")
                    if p and tonumber(p) and tonumber(p) >= 100 and not isClaimingAchieve then
                        isClaimingAchieve=true
                        fireRemote({{{ "General","Achievements","ClaimAll",n=3 },"\002" }})
                        task.wait(2) isClaimingAchieve=false
                    end
                end
                local function hookTitle(title)
                    checkAndClaim(title.ContentText ~= "" and title.ContentText or title.Text)
                    local c1 = title:GetPropertyChangedSignal("Text"):Connect(function()
                        if S.isAutoAchieve then checkAndClaim(title.Text) end
                    end)
                    local c2 = title:GetPropertyChangedSignal("ContentText"):Connect(function()
                        if S.isAutoAchieve then checkAndClaim(title.ContentText) end
                    end)
                    table.insert(achieveConnections, c1)
                    table.insert(achieveConnections, c2)
                end
                local function setupItem(item)
                    if item:IsA("GuiObject") then
                        local title = item:FindFirstChild("Background") and item.Background:FindFirstChild("Main")
                            and item.Background.Main:FindFirstChild("Progress") and item.Background.Main.Progress:FindFirstChild("Title")
                        if title then hookTitle(title)
                        else
                            local c3 = item.DescendantAdded:Connect(function(desc)
                                if desc.Name == "Title" and desc.Parent and desc.Parent.Name == "Progress" then hookTitle(desc) end
                            end)
                            table.insert(achieveConnections, c3)
                        end
                    end
                end
                for _, item in ipairs(list:GetChildren()) do setupItem(item) end
                local c4 = list.ChildAdded:Connect(function(child) task.wait(0.1) setupItem(child) end)
                table.insert(achieveConnections, c4)
            end)
        end
    end
})

-- ============================================================
--  AUTO BUY — DRAGON MERCHANT
-- ============================================================
MiscTab:Divider()
MiscTab:Section({ Title = "Dragon Merchant Shop" })

local function getDragonCoinCount()
    if Omni then
        local ok, n = pcall(function() return Omni.Data.Inventory.Items["Dragon Coin"] end)
        if ok and n then return math.floor(tonumber(n) or 0) end
    end
    return 0
end

local balanceLabel = MiscTab:Section({ Title = "Your Balance: "..getDragonCoinCount().." Dragon Coins" })
local statusLabel  = MiscTab:Section({ Title = "Status: Idle" })

task.spawn(function()
    while true do
        balanceLabel:SetTitle("Your Balance: "..getDragonCoinCount().." Dragon Coins")
        task.wait(60)
    end
end)

local dragonShopItems = {}
local dragonShopData  = {}

pcall(function()
    local shopModule = require(RS:WaitForChild("Omni"):WaitForChild("Shared"):WaitForChild("Merchant"):WaitForChild("Dragon Merchant"))
    if shopModule and shopModule.Products then
        for itemName, itemInfo in pairs(shopModule.Products) do
            table.insert(dragonShopItems, itemName)
            local price = 0
            if itemInfo.Price and itemInfo.Price.Amount then price=tonumber(itemInfo.Price.Amount) or 0 end
            dragonShopData[itemName] = { Price=price }
        end
        table.sort(dragonShopItems)
    end
end)

if #dragonShopItems == 0 then
    dragonShopItems = {"Oatmeel","Power Potion I","Damage Potion I","Luck Potion I","Crystals Potion I","Pirate Token","Dragon Balls Token"}
    dragonShopData = {
        ["Oatmeel"]={Price=250},["Power Potion I"]={Price=500},["Damage Potion I"]={Price=500},
        ["Luck Potion I"]={Price=500},["Crystals Potion I"]={Price=500},["Pirate Token"]={Price=5},["Dragon Balls Token"]={Price=1000}
    }
end

local selectedDragonItems = {}
local isAutoBuyDragonShop = false

MiscTab:Dropdown({ Title="Select Items", Desc="Select one or more items to buy", Icon="shopping-bag",
    Values=dragonShopItems, Multi=true,
    Callback = function(v) selectedDragonItems=v end
})

MiscTab:Toggle({ Title="Auto Buy Selected Items", Desc="Automatically buy with balance & stock checks",
    Icon="coins", Type="Checkbox", Value=false,
    Callback = function(v)
        isAutoBuyDragonShop=v
        if not isAutoBuyDragonShop then statusLabel:SetTitle("Status: Idle") end
        if isAutoBuyDragonShop then
            task.spawn(function()
                while isAutoBuyDragonShop do
                    local myCoins = getDragonCoinCount()
                    for _, itemName in ipairs(selectedDragonItems) do
                        if not isAutoBuyDragonShop then break end
                        local itemPrice = dragonShopData[itemName] and dragonShopData[itemName].Price or 0
                        if myCoins >= itemPrice then
                            local isOutOfStock = false
                            pcall(function()
                                local merchantData = Omni.Data.Merchants and Omni.Data.Merchants["Dragon Merchant"]
                                if merchantData and merchantData.Products then
                                    local productInfo = merchantData.Products[itemName]
                                    if productInfo and productInfo.Stock and tonumber(productInfo.Stock) <= 0 then isOutOfStock=true end
                                end
                            end)
                            if isOutOfStock then
                                statusLabel:SetTitle("Status: "..itemName.." Out of Stock!")
                            else
                                statusLabel:SetTitle("Status: Buying "..itemName.."...")
                                fireRemote({{{"General","Merchant","Buy","Dragon Merchant",itemName,1,n=6},"\002"}})
                                myCoins -= itemPrice
                            end
                        else
                            statusLabel:SetTitle("Status: Not enough coins for "..itemName)
                        end
                        task.wait(0.5)
                    end
                    task.wait(1.5)
                end
            end)
        end
    end
})
-- ============================================================
--  TAB: EXCHANGE
-- ============================================================
ExchangeTab:Section({ Title = "Potion Exchange (Potion I → Potion II)" })
local potionExchangeIDs = {
    ["Luck"]     = 1,
    ["Power"]    = 2,
    ["Crystals"] = 4,
    ["Damage"]   = 6,
}
local potionTypes = { "Power", "Damage", "Crystals", "Luck" }
local selectedPotionExchange = "Power"
local isAutoExchangePotion   = false

local function getPotionCount(potionName)
    if not Omni then return 0 end
    local ok, n = pcall(function()
        return Omni.Data.Inventory.Potions[potionName]
    end)
    if ok and tonumber(n) then return math.floor(tonumber(n)) end
    
    local ok2, n2 = pcall(function()
        return Omni.Data.Inventory.Items[potionName]
    end)
    return (ok2 and math.floor(tonumber(n2) or 0)) or 0
end

local potionStatusLabel = ExchangeTab:Section({ Title = "Select a Potion type to view counts." })

task.spawn(function()
    local waited = 0
    while not omniReady and waited < 15 do task.wait(0.2) waited += 0.2 end
    task.wait(1) -- รอ data sync
    updatePotionStatus(selectedPotionExchange)
end)
local function updatePotionStatus(potType)
    local p1Name = potType .. " Potion I"
    local p2Name = potType .. " Potion II"
    local have1  = getPotionCount(p1Name)
    local have2  = getPotionCount(p2Name)
    local canMake = math.floor(have1 / 5)
    potionStatusLabel:SetTitle(
        string.format("[ %s ]\nPotion I: %d  |  Potion II: %d\nCan craft: %d Potion II (need 5 Potion I each)",
            potType, have1, have2, canMake)
    )
end

ExchangeTab:Dropdown({
    Title = "Select Potion Type", Icon = "flask-conical",
    Values = potionTypes, Value = "Power",
    Callback = function(v)
        selectedPotionExchange = v
        updatePotionStatus(v)
    end
})

ExchangeTab:Button({
    Title = "Refresh Counts", Icon = "refresh-cw",
    Callback = function()
        updatePotionStatus(selectedPotionExchange)
    end
})

ExchangeTab:Button({
    Title = "Exchange Once (Potion I × 5 → Potion II × 1)", Icon = "arrow-left-right",
    Callback = function()
        local p1Name = selectedPotionExchange .. " Potion I"
        local have1  = getPotionCount(p1Name)
        if have1 < 5 then
            WindUI:Notify({ Title="Exchange", Content="Not enough "..p1Name.." (need 5, have "..have1..")", Duration=3 })
            return
        end
        local exchangeID = potionExchangeIDs[selectedPotionExchange]
        if not exchangeID then
            WindUI:Notify({ Title="Error", Content="Unknown potion type!", Duration=3 })
            return
        end
        fireRemote({{{"General","Forge","Craft","Exchange",exchangeID,1,n=6},"\002"}})
        WindUI:Notify({ Title="Exchange Sent", Content="Exchanging 5x "..p1Name.." → 1x "..selectedPotionExchange.." Potion II", Duration=3 })
        task.delay(1.5, function() updatePotionStatus(selectedPotionExchange) end)
    end
})

ExchangeTab:Button({
    Title = "Exchange ALL (Potion I → Potion II)", Icon = "layers",
    Callback = function()
        task.spawn(function()
            local p1Name = selectedPotionExchange .. " Potion I"
            local exchangeID = potionExchangeIDs[selectedPotionExchange]
            if not exchangeID then return end
            local count = 0
            while getPotionCount(p1Name) >= 5 do
                fireRemote({{{"General","Forge","Craft","Exchange",exchangeID,1,n=6},"\002"}})
                count += 1
                task.wait(1)
            end
            WindUI:Notify({ Title="Exchange Done ✅", Content="Crafted "..count.."x "..selectedPotionExchange.." Potion II", Duration=4 })
            updatePotionStatus(selectedPotionExchange)
        end)
    end
})

ExchangeTab:Divider()
ExchangeTab:Section({ Title = "Auto Exchange Potion" })

ExchangeTab:Toggle({
    Title = "Auto Exchange Potion I → II", Icon = "repeat", Type = "Checkbox", Value = false,
    Desc = "Auto exchange when Potion I reaches 5+",
    Callback = function(v)
        isAutoExchangePotion = v
        if isAutoExchangePotion then
            task.spawn(function()
                while isAutoExchangePotion do
                    pcall(function()
                        local p1Name = selectedPotionExchange .. " Potion I"
                        local exchangeID = potionExchangeIDs[selectedPotionExchange]
                        if exchangeID and getPotionCount(p1Name) >= 5 then
                            fireRemote({{{"General","Forge","Craft","Exchange",exchangeID,1,n=6},"\002"}})
                            WindUI:Notify({ Title="Auto Exchange ⚗", Content="5x "..p1Name.." → 1x "..selectedPotionExchange.." Potion II", Duration=2 })
                            task.wait(1.5)
                            updatePotionStatus(selectedPotionExchange)
                        end
                    end)
                    task.wait(5)
                end
            end)
        end
    end
})

ExchangeTab:Divider()
ExchangeTab:Section({ Title = "Token Exchange" })

local tokenExchangeItems = {
    "Haki Token","Fruit Token","Race Token","Dragon Power Token","Slime Power Token",
    "Demon Token","Cursed Token","Spirit Token","Hunter Token","Combat Token",
    "Ki Essence","Dragon Token","Domain Token","System Token","Pirate Token",
    "Monarch Token","Sword Fragment","Shikigami Token","Slime Shard","Arise Token"
}
local selectedTokenExchange = "Haki Token"
local isAutoExchangeToken   = false

local function getExchangeTokenCount()
    if not Omni then return 0 end
    local ok, n = pcall(function() return Omni.Data.Inventory.Items["Exchange Token"] end)
    return (ok and math.floor(tonumber(n) or 0)) or 0
end

local tokenStatusLabel = ExchangeTab:Section({ Title = "Exchange Token: Loading..." })

task.spawn(function()
    while true do
        tokenStatusLabel:SetTitle("Exchange Token: " .. getExchangeTokenCount())
        task.wait(15)
    end
end)

ExchangeTab:Dropdown({
    Title = "Select Token to Get", Icon = "coins",
    Values = tokenExchangeItems, Value = "Haki Token",
    Callback = function(v)
        selectedTokenExchange = v
        local have = getPotionCount(v)
        local et   = getExchangeTokenCount()
        tokenStatusLabel:SetTitle(string.format("Exchange Token: %d  |  %s: %d", et, v, have))
    end
})

ExchangeTab:Button({
    Title = "Exchange Token → Selected Token (×1)", Icon = "arrow-left-right",
    Desc = "Use 1 Exchange Token to get 1 of the selected token",
    Callback = function()
        local et = getExchangeTokenCount()
        if et < 1 then
            WindUI:Notify({ Title="Exchange", Content="No Exchange Token! (have "..et..")", Duration=3 })
            return
        end
        fireRemote({{{"General","Forge","Craft","Exchange",selectedTokenExchange,{
            { Type="Item", Item="Exchange Token", Amount=1 }
        },n=6},"\002"}})
        WindUI:Notify({ Title="Exchange Sent", Content="1x Exchange Token → 1x "..selectedTokenExchange, Duration=3 })
        task.delay(1.5, function()
            tokenStatusLabel:SetTitle("Exchange Token: "..getExchangeTokenCount().."  |  "..selectedTokenExchange..": "..getPotionCount(selectedTokenExchange))
        end)
    end
})

ExchangeTab:Button({
    Title = "Exchange ALL Exchange Tokens → Selected", Icon = "layers",
    Callback = function()
        task.spawn(function()
            local count = 0
            while getExchangeTokenCount() >= 1 do
                fireRemote({{{"General","Forge","Craft","Exchange",selectedTokenExchange,{
                    { Type="Item", Item="Exchange Token", Amount=1 }
                },n=6},"\002"}})
                count += 1
                task.wait(1)
            end
            WindUI:Notify({ Title="Exchange Done ✅", Content="Got "..count.."x "..selectedTokenExchange, Duration=4 })
            tokenStatusLabel:SetTitle("Exchange Token: "..getExchangeTokenCount())
        end)
    end
})

ExchangeTab:Button({
    Title = "Convert Token → Exchange Token (×10)", Icon = "repeat",
    Desc = "Trade 10 of selected token back for 1 Exchange Token",
    Callback = function()
        local have = getPotionCount(selectedTokenExchange)
        if have < 10 then
            WindUI:Notify({ Title="Exchange", Content="Need 10x "..selectedTokenExchange.." (have "..have..")", Duration=3 })
            return
        end
        fireRemote({{{"General","Forge","Craft","Exchange","Exchange Token",{
            { Type="Item", Item=selectedTokenExchange, Amount=10 }
        },n=6},"\002"}})
        WindUI:Notify({ Title="Exchange Sent", Content="10x "..selectedTokenExchange.." → 1x Exchange Token", Duration=3 })
        task.delay(1.5, function()
            tokenStatusLabel:SetTitle("Exchange Token: "..getExchangeTokenCount())
        end)
    end
})

-- ============================================================
--  TAB: SETTINGS
-- ============================================================
local notifConnection = nil

SettingTab:Section({ Title = "General" })

SettingTab:Keybind({
    Title="Toggle UI Key", Desc="Keybind to show/hide the window",
    Value=Options.ToggleUIKey or "RightControl",
    Callback = function(v)
        Options.ToggleUIKey=tostring(v) SaveConfig()
        local key = typeof(v)=="EnumItem" and v or Enum.KeyCode[v]
        Window:SetToggleKey(key)
    end
})

SettingTab:Toggle({ Title="Anti AFK", Icon="shield", Type="Checkbox", Value=Options.AntiAFK or false,
    Callback = function(v)
        Options.AntiAFK=v SaveConfig()
        if v then Omni.Signal:Fire("General","Settings","Set","Anti Afk",false) end
    end
})

SettingTab:Toggle({ Title="Hide Game Notifications", Icon="eye-off", Desc="Hide Notify messages", Type="Checkbox", Value=Options.HideNotif or false,
    Callback = function(v)
        Options.HideNotif=v SaveConfig()
        if v then
            task.spawn(function()
                local ok, list = pcall(function() return player.PlayerGui.Notifications.List end)
                if not (ok and list) then return end
                local function checkAndHide(child)
                    task.wait(0.05)
                    for _, desc in ipairs(child:GetDescendants()) do
                        if desc:IsA("TextLabel") or desc:IsA("TextBox") then
                            local text = desc.ContentText ~= "" and desc.ContentText or desc.Text
                            if text and string.find(text, "^You don't") then child.Visible=false break end
                        end
                    end
                end
                for _, child in ipairs(list:GetChildren()) do checkAndHide(child) end
                notifConnection = list.ChildAdded:Connect(checkAndHide)
            end)
        else
            if notifConnection then notifConnection:Disconnect() notifConnection=nil end
            local ok, list = pcall(function() return player.PlayerGui.Notifications.List end)
            if ok and list then for _, child in ipairs(list:GetChildren()) do if child:IsA("GuiObject") then child.Visible=true end end end
        end
    end
})

SettingTab:Slider({
    Title = "Walk Speed", Icon = "footprints", Step = 1,
    Value = { Min = 16, Max = 500, Default = Options.WalkSpeed or 16 },
    Callback = function(v)
        Options.WalkSpeed = v SaveConfig()
        local char = Players.LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
})

SettingTab:Divider()
SettingTab:Section({ Title = "Performance & Network" })

SettingTab:Toggle({ Title="Auto Rejoin", Icon="plug", Desc="Reconnect automatically on disconnect", Type="Checkbox", Value=Options.AutoRejoin or false,
    Callback = function(v)
        Options.AutoRejoin=v SaveConfig()
        if v then
            task.spawn(function()
                 CoreGui2        = game:GetService("CoreGui")
                 TeleportService = game:GetService("TeleportService")
                 promptOverlay   = CoreGui2:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")
                if not getgenv().RejoinConnection then
                    getgenv().RejoinConnection = promptOverlay.ChildAdded:Connect(function(child)
                        if Options.AutoRejoin and child.Name == "ErrorPrompt" then
                            task.wait(5)
                            TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
                        end
                    end)
                end
            end)
        end
    end
})

SettingTab:Toggle({ Title="Wipe VFX All (Anti-Lag)", Icon="eye-off", Desc="Disable particles, trails, beams, etc.", Type="Checkbox", Value=Options.WipeVFX or false,
    Callback = function(v)
        Options.WipeVFX=v SaveConfig()
        if v then
            task.spawn(function()
                while Options.WipeVFX do
                    pcall(function()
                        local count = 0
                        for _, obj in pairs(workspace:GetDescendants()) do
                            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
                            or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Smoke") then
                                obj.Enabled = false
                                count += 1
                                if count % 50 == 0 then task.wait() end
                            end
                        end
                        local cf = workspace:FindFirstChild("Client")
                        if cf and cf:FindFirstChild("VFX") then cf.VFX:ClearAllChildren() end
                        if workspace:FindFirstChild("VFX") then workspace.VFX:ClearAllChildren() end
                    end)
                    task.wait(120)
                end
            end)
        end
    end
})

SettingTab:Divider()
SettingTab:Section({ Title = "Screen Setting" })

 CoreGui       = game:GetService("CoreGui")
 screenTarget  = (gethui and gethui()) or CoreGui or player.PlayerGui

local function makeScreen(color, name)
    local g = Instance.new("ScreenGui")
    g.Name=name g.ResetOnSpawn=false g.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    local f = Instance.new("Frame")
    f.Size=UDim2.new(1,0,1,0) f.BackgroundColor3=color
    f.BorderSizePixel=0 f.ZIndex=999 f.Parent=g
    g.Parent=screenTarget
    return g
end

local function clearScreen(key)
    if S[key] then S[key]:Destroy() S[key]=nil end
end

SettingTab:Toggle({
    Title="Black Screen (Reduce GPU)", Icon="moon",
    Desc="Disable 3D Render + Black Screen",
    Type="Checkbox", Value=false,
    Callback = function(v)
        if v then
            clearScreen("whiteScreenGui")
            pcall(function() RunService:Set3dRenderingEnabled(false) end)
            S.blackScreenGui = makeScreen(Color3.new(0,0,0), "GH_BlackScreen")
        else
            clearScreen("blackScreenGui")
            pcall(function() RunService:Set3dRenderingEnabled(true) end)
        end
    end
})

SettingTab:Toggle({
    Title="White Screen", Icon="sun",
    Desc="Disable 3D Render + White Screen",
    Type="Checkbox", Value=false,
    Callback = function(v)
        if v then
            clearScreen("blackScreenGui")
            pcall(function() RunService:Set3dRenderingEnabled(false) end)
            S.whiteScreenGui = makeScreen(Color3.new(1,1,1), "GH_WhiteScreen")
        else
            clearScreen("whiteScreenGui")
            pcall(function() RunService:Set3dRenderingEnabled(true) end)
        end
    end
})

local function applyWalkSpeed()
     char = Players.LocalPlayer.Character
     hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
     ws = Options.WalkSpeed or 16
    if ws == 16 then return end
     mt = getrawmetatable(hum)
     oldNewIndex = mt.__newindex
    setreadonly(mt, false)
    mt.__newindex = function(self, key, value)
        if key == "WalkSpeed" and self == hum and Options.WalkSpeed ~= 16 then
            value = Options.WalkSpeed
        end
        return oldNewIndex(self, key, value)
    end
    setreadonly(mt, true)
    hum.WalkSpeed = ws
end

Players.LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    applyWalkSpeed()
end)

applyWalkSpeed()

-- ============================================================
--  ANTI AFK LOOP
-- ============================================================
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    local VIM         = game:GetService("VirtualInputManager")
    while true do
        task.wait(120)
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        pcall(function()
            VIM:SendKeyEvent(true,  Enum.KeyCode.Space, false, game)
            task.wait(0.1)
            VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
    end
end)

FarmTab:Select()

-- ============================================================
--  DRAGGABLE TOGGLE BUTTON
-- ============================================================
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name="WFSToggleGui" ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
local targetGui = (gethui and gethui()) or (pcall(function() return CoreGui.Name end) and CoreGui) or player.PlayerGui
ScreenGui.Parent = targetGui

local ToggleBtn = Instance.new("ImageButton")
ToggleBtn.Name="ToggleButton" ToggleBtn.Parent=ScreenGui
ToggleBtn.BackgroundTransparency=1
ToggleBtn.Position=UDim2.new(0.5,0,0,40)
ToggleBtn.Size=UDim2.new(0,50,0,50)
ToggleBtn.Image="rbxassetid://110552700896064"
ToggleBtn.AnchorPoint=Vector2.new(0.5,0.5)

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius=UDim.new(1,0) UICorner2.Parent=ToggleBtn

local UIStroke2 = Instance.new("UIStroke")
UIStroke2.Parent=ToggleBtn UIStroke2.Thickness=2
UIStroke2.Color=Color3.fromRGB(124,58,237) UIStroke2.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

local dragging, dragStart, startPos

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging=true dragStart=input.Position startPos=ToggleBtn.Position
        TweenService:Create(ToggleBtn, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Size=UDim2.new(0,42,0,42)}):Play()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            dragging=false
            TweenService:Create(ToggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size=UDim2.new(0,50,0,50)}):Play()
            if dragStart and (input.Position - dragStart).Magnitude < 10 then
                 vim = game:GetService("VirtualInputManager")
                 keyStr = Options.ToggleUIKey or "RightControl"
                 key = typeof(keyStr)=="EnumItem" and keyStr or Enum.KeyCode[keyStr]
                if not key then key=Enum.KeyCode.RightControl end
                vim:SendKeyEvent(true,key,false,game) task.wait(0.05)
                vim:SendKeyEvent(false,key,false,game)
            end
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) and dragging then
         delta = input.Position - dragStart
        ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
    end
end)

-- ============================================================
--  CUSTOM PLAYER HUD
-- ============================================================
local function customizePlayerHUD()
     lp        = Players.LocalPlayer
     character = lp.Character or lp.CharacterAdded:Wait()
     head      = character:WaitForChild("Head", 10)
    if not head then return end
     playerHUD = head:WaitForChild("PlayerHUD", 5)
     mainUI    = playerHUD and playerHUD:FindFirstChild("Main")
    if mainUI then
         titleUID2 = mainUI:FindFirstChild("Title")
        if titleUID2 then
            titleUID2.Text       = "discord.gg/ghosthubofficial"
            titleUID2.TextColor3 = Color3.fromRGB(255,0,0)
        end
         titleUID = mainUI:FindFirstChild("Title") and mainUI.Title:FindFirstChild("UID")
        if titleUID then titleUID.Visible=false end
         roleUID2 = mainUI:FindFirstChild("Role")
        if roleUID2 then
            roleUID2.Text       = "[ GHOST HUB ]"
            roleUID2.TextColor3 = Color3.fromRGB(76,0,153)
        end
         roleUID = mainUI:FindFirstChild("Role") and mainUI.Role:FindFirstChild("UID")
        if roleUID then roleUID.Visible=false end
         titleSystem = mainUI:FindFirstChild("TitleSystem")
        if titleSystem then titleSystem.Visible=false end
    end
end

task.spawn(customizePlayerHUD)
Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(3) customizePlayerHUD()
end)
task.spawn(function()
    while task.wait(6000) do customizePlayerHUD() end
end)
