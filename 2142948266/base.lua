repeat task.wait() until game:IsLoaded()
local Library = loadstring(game:HttpGetAsync("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local options = Library.Options
warn("---------------------------------")
-- SERVICES
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- VARS
local client = Players.LocalPlayer
repeat task.wait() until ReplicatedStorage.Player_Data:FindFirstChild(client.Name)
local playerValues = ReplicatedStorage.PlayerValues:WaitForChild(client.Name, 1)
local playerData = ReplicatedStorage.Player_Data:WaitForChild(client.Name, 1)
local Handle_Initiate_S = ReplicatedStorage.Remotes.To_Server:WaitForChild("Handle_Initiate_S")
local Handle_Initiate_S_ = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("To_Server"):WaitForChild("Handle_Initiate_S_")
options.distance = 15
local gameId = game.PlaceId

-- DUMP

-- FUNCTIONS
local tweento = function(coords:CFrame)
    local Distance = (coords.Position - client.Character.HumanoidRootPart.Position).Magnitude
    local Speed = Distance/options["sTweenSpeed"].Value

    local tween = TweenService:Create(client.Character.HumanoidRootPart,
        TweenInfo.new(Speed, Enum.EasingStyle.Linear),
        { CFrame = coords}
    )

    tween:Play()
    return tween
end

function tpto(p1)
    pcall(function()
        client.Character.HumanoidRootPart.CFrame = p1
    end)
end

local function smartTp(dest:CFrame)
    dest = dest.Position
    local closest = nil
    local shortest = (client.Character.HumanoidRootPart.Position - dest).Magnitude
    for loc, coord in places do
        if playerData.MapUi.UnlockedLocations:FindFirstChild(loc) and game:GetService("Players").LocalPlayer.PlayerGui.Map_Ui.Holder.Locations:FindFirstChild(loc) then
            local dist = (coord-dest).Magnitude
            if dist < shortest then
                closest = loc
                shortest = dist
            end
        end
    end
    if closest then
        local args = {
            [1] = `Players.{client.Name}.PlayerGui.Npc_Dialogue.Guis.ScreenGui.LocalScript`,
            [2] = os.clock(),
            [3] = closest
        }
        game:GetService("ReplicatedStorage"):WaitForChild("teleport_player_to_location_for_map_tang"):InvokeServer(unpack(args))
    end
    tweento(CFrame.new(dest)).Completed:Wait()
end

local function findBoss(name, hrp)
    for i, v in pairs(workspace.Mobs:GetDescendants()) do
        if v:IsA("Model") and v.Name == name and v:FindFirstChild("Humanoid") then
            if hrp then
                if v:FindFirstChild('HumanoidRootPart') then
                    return v
                end
            else
                return v
            end
        end
    end
end

local function findMob(hrp)
    for i, v in pairs(workspace.Mobs:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            if hrp then
                if v:FindFirstChild('HumanoidRootPart') then
                    return v
                end
            else
                return v
            end
        end
    end
    return nil
end

local function noclip()
    for i, v in pairs(client.Character:GetChildren()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end

local function webhook(item)
    local img_link = string.match(item.Image.Image, "id=(%d+)")
    local ret; 
	repeat
		ret = request({
			Url = `https://thumbnails.roblox.com/v1/assets?assetIds={img_link}&size=250x250&format=Png&cacheBust={tostring(tick())}`,
			Method = "GET",
			Headers = {
				["Content-Type"] = "text/json",
			}
		})
		task.wait(0.3)
	until HttpService:JSONDecode(ret.Body)["data"][1]["state"] == "Completed"
    local msg = {
        ["embeds"] = {
            {
                ["title"] = "Got An Item !!!",
                ["color"] = 16711680,
                ["fields"] = {},
                ["thumbnail"] = {
                    ["url"] = HttpService:JSONDecode(ret.Body)["data"][1]["imageUrl"];
                },
                ["description"] = `||{client.Name}|| collected a \n{item.Name}`,
                ["timestamp"] = DateTime.now():ToIsoDate(),
            },
        },
        ["username"] = "Step Mom",
        ["avatar_url"] = "https://cdn.discordapp.com/avatars/1300809146903429120/152ae0be266098e7a09ce8548796fc63.png",
    }
    request({
        Url = options["iWebhook"].Value,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
        },
        Body = HttpService:JSONEncode(msg),
    })
end

-- GUI PART
--local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/dawid-scripts/Fluent-Renewed/master/Addons/SaveManager.luau"))()
--local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/dawid-scripts/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local Window;
if UserInputService.TouchEnabled then
    Window = Library:CreateWindow{
        Title = `Cloudhub | Project Slayer`,
        TabWidth = 150,
        Size = UDim2.fromOffset(600, 300);
        Resize = true, -- Resize this ^ Size according to a 1920x1080 screen, good for mobile users but may look weird on some devices
        MinSize = Vector2.new(235, 190),
        Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightShift -- Used when theres no MinimizeKeybind
    }
    local ScreenGui = Instance.new("ScreenGui", gethui())
    local Frame = Instance.new("ImageButton", ScreenGui)
    Frame.Size = UDim2.fromOffset(60, 60)
    Frame.Position = UDim2.fromOffset(30, 30)
    Window.Root.Active = true
    Frame.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)
else
    Window = Library:CreateWindow{
        Title = `Cloudhub | Project Slayer`,
        TabWidth = 150,
        Size = UDim2.fromOffset(747, 472),
        Resize = false, -- Resize this ^ Size according to a 1920x1080 screen, good for mobile users but may look weird on some devices
        MinSize = Vector2.new(470, 380),
        Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightShift -- Used when theres no MinimizeKeybind
    }
end

local Tabs = {
    ["Lobby"] = Window:AddTab({Title = "Lobby", Icon = ""});
    ["Auto Farm"] = Window:AddTab({Title = "Auto Farm", Icon = ""});
    ["Kill Auras"] = Window:AddTab({Title = "Kill Auras", Icon = ""});
    ["Misc"] = Window:AddTab({Title = "Misc", Icon = ""});
    ["Quests"] = Window:AddTab({Title = "Quests", Icon = ""});
    ["Buffs"] = Window:AddTab({Title = "Buffs", Icon = ""});
    ["Webhook Settings"] = Window:AddTab({Title = "Webhook settings", Icon = ""});
    ["Settings"] = Window:AddTab({Title = "Settings", Icon = "settings"});
}

local maps = {
    ["Map 1"] = "17387475546";
    ["Map 2"] = "17387482786"
}

-- LOBBY
Tabs["Lobby"]:AddButton({
    Title = "Daily Spin";
    Callback = function()
        if gameId == 5956785391 then
            ReplicatedStorage:WaitForChild("spins_thing_remote", math.huge):InvokeServer()
        end
    end
})

Tabs["Lobby"]:AddButton({
    Title = "Race Spin";
    Callback = function()
        if gameId == 5956785391 then
            Handle_Initiate_S_:InvokeServer("check_can_spin")
        end
    end
})

Tabs["Lobby"]:AddSlider("sSlot", {
    Title = "Slot Chooser",
    Description = "Default is one",
    Default = 1,
    Min = 1,
    Max = 3,
    Rounding = 0,
})

Tabs["Lobby"]:AddInput("iCode", {
    Title = "PSCode",
    Default = nil,
    Placeholder = "Enter private server code",
    Numeric = false, -- Only allows numbers
    Finished = true -- Only calls callback when you press enter
})

Tabs["Lobby"]:AddDropdown("dMapSelect", {
    Title = "Select Map",
    Values = {"Map 1", "Map 2", "Hub"};
    Default = "Map 2",
    Multi = false,
})

Tabs["Auto Join"]:AddToggle("tAutoJoin", {
    Title = "Auto Join Server";
    Default = false;
    Callback = function(Value)
        task.spawn(function()
            if Value then
                repeat task.wait() until game:IsLoaded()
                workspace.Is_Customization_place:WaitForChild("Slot3")
                print("loaded") 
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Apply_Slot"):InvokeServer(options["sSlot"].Value)
                while task.wait(1) do
                    if not options["tAntiJoin"].Value and options["tAutoJoin"].Value then
                        game:GetService("ReplicatedStorage"):WaitForChild("handle_privateserver"):InvokeServer("join", options["iCode"].Value, tonumber(maps[options["dMapSelect"].Value]))
                    end
                end
            end
        end)
    end
})

-- AUTO FARM

local weapons = {
    ["Combat"] = "fist_combat";
    ["Scythe"] = "Scythe_Combat_Slash";
    ["Sword"] = "Sword_Combat_Slash";
    ["Fans"] = "fans_combat_slash";
    ["Claws"] = "claw_Combat_Slash";
}

Tabs["Auto Farm"]:AddDropdown("dWeaponSelect", {
    Title = "Select Weapon";
    Values = {"Combat", "Scythe", "Sword", "Fans", "Claws"};
    Default = "Combat";
    Multi = false;
})

Tabs["Auto Farm"]:AddSlider("sTweenSpeed", {
    Title = "TweenSpeed";
    Description = "This is a slider";
    Default = 400;
    Min = 100;
    Max = 500;
    Rounding = 0;
})
Tabs["Auto Farm"]:AddToggle("tAutoBoss", {
	Title = "Auto Boss";
	Default = false;
})

Tabs["Auto Farm"]:AddToggle("tAutoM1", {
	Title = "Weapon KillAura";
	Default = false;
    Callback = function(Value)
        task.spawn(function()
            if Value then
                while options.tAutoM1.Value do
                    if not options["tGodMode"].Value then options.distance = 7 end
                    task.wait(0.1)
                    for i = 1, 8 do
                        Handle_Initiate_S:FireServer(weapons[options.dWeaponSelect.Value], client, client.Character, client.Character.HumanoidRootPart, client.Character.Humanoid, 919)
                        Handle_Initiate_S:FireServer(weapons[options.dWeaponSelect.Value], client, client.Character, client.Character.HumanoidRootPart, client.Character.Humanoid, math.huge)
                    end
                    task.wait(client:GetNetworkPing() * 2)
                    if not options["tGodMode"].Value then options.distance = 15 end
                    task.wait(1)
                    repeat task.wait() until client.combotangasd123.Value == 0 and not playerValues:FindFirstChild("Stun")
                end
            end
        end)
    end
})

Tabs["Auto Farm"]:AddToggle("tAutoBlock", {
    Title = "Auto Block";
    Default = false;
    Callback = function(Value)
        if Value then
            while options["tAutoBlock"].Value do
                local args = {
                    [1] = "add_blocking",
                    [2] = `Players.{client.Name}.PlayerScripts.Skills_Modules.Combat.Combat//Block`,
                    [3] =  os.clock(),
                    [4] = playerValues,
                    [5] = 99999
                }
                Handle_Initiate_S:FireServer(unpack(args))
                task.wait(0.5)
            end
        else
            Handle_Initiate_S_:InvokeServer("remove_blocking", playerValues)
        end
    end
})


local rarities = {
    "Mythic",
    "Supreme",
    "Polar",
    "Devourer",
    "Limited";
}

Tabs["Auto Farm"]:AddToggle("tAutoChest", {
	Title = "Auto Collect Chests";
	Default = false;
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while options.tAutoChest.Value do
                    for a, b in pairs(game.Workspace.Debree:GetChildren()) do
                        if b.Name == "Loot_Chest" then
                            for c, d in pairs(b.Drops:GetChildren()) do
                                b.Add_To_Inventory:InvokeServer(d.Name)
                            end
                            b:Destroy()
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})


Tabs["Auto Farm"]:AddToggle("tAutoFlower", {
    Title = "Auto Collect Flower";
    Description = "Disable Auto Boss";
    Default = false;
})

-- KILL AURAS
Tabs["Kill Auras"]:AddToggle("tArrowKA", {
    Title = 'Arrow KA';
    Default = false;
    Callback = function(Value)
        if Value then
            if options.tBringMob.Value then
                Library:Notify({
                    Title = "Attention",
                    Content = "You'r succeptible to get kicked if you use two different KA",
                    Duration = 5
                })
            end
            task.spawn(function()
                while options.tArrowKA.Value do 
                    local target = findMob(true)
                    if target then
                        local args = {
                            [1] = "arrow_knock_back_damage",
                            [2] = client.Character,
                            [3] = target:GetModelCFrame(),
                            [4] = target,
                            [5] = math.huge,
                            [6] = math.huge
                        }

                        Handle_Initiate_S:FireServer(unpack(args))
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
})

Tabs["Kill Auras"]:AddToggle("tBringMob", {
    Title = 'Arrow Bring Mob';
    Default = false;
    Callback = function(Value)
        if Value then
            if options.tArrowKA.Value then
                Library:Notify({
                    Title = "Attention",
                    Content = "You'r succeptible to get kicked if you use two different KA",
                    Duration = 5
                })
            end
            task.spawn(function()
                while options.tBringMob.Value do 
                    local target = findMob(true)
                    if target then
                        local args = {
                            [1] = "piercing_arrow_damage",
                            [2] = client,
                            [3] = target:GetModelCFrame()
                        }
                        Handle_Initiate_S:FireServer(unpack(args))
                        task.wait(0.2)
                    else
                        task.wait()
                    end
                end
            end)
        end
    end
})

task.spawn(function()
    while true do
        if options.tBringMob.Value or options.tArrowKA.Value then
            local args = {
                [1] = "skil_ting_asd",
                [2] = client,
                [3] = "arrow_knock_back",
                [4] = 5
            }
            Handle_Initiate_S_:InvokeServer(unpack(args))
            task.wait(6)
        end
        task.wait()
    end
end)



if getrenv and gameId ~= 5956785391 then
    local tang = playerData.Keys
    local skill = getrenv()._G.skills_modules_thing
    local skells = client.PlayerGui.Power_Adder
    for i = 1, 6 do
        Tabs["Misc"]:AddToggle(`tMove{i}`, {
            Title = `Auto Skill {tang["Move"..i]["2"].Value}`;
            Default = false;
            Callback = function(Value)
                if Value then
                    task.spawn(function()
                        local art = (playerData.Race.Value == 3 and playerData.Demon_Art.Value) or ((playerData.Race.Value == 1) or (playerData.Race.Value == 2) and playerData.Power.Value)
                        while options[`tMove{i}`].Value do
                            local skill_config = skells[art]["Skills"]:GetChildren()[i]
                            Handle_Initiate_S:FireServer("skil_ting_asd", client, skill_config["Actual_Skill_Name"].Value, 5)                        
                            skill[skill_config["Actual_Skill_Name"].Value]["Down"](skill_config)
                            task.wait(0.1)
                            skill[skill_config["Actual_Skill_Name"].Value]["Up"](skill_config)
                            task.wait(skill_config["CoolDown"].Value + 1)
                        end
                    end)
                end
            end
        })
    end
end

Tabs["Misc"]:AddToggle("tAutoSoul", {
    Title = "Auto Eat Soul";
    Default = false;
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while options["tAutoSoul"].Value do
                    for i, v in workspace.Debree:GetChildren() do
                        if v.Name == "Soul" then
                            v:WaitForChild("Handle"):WaitForChild("Eatthedamnsoul"):FireServer()
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

Tabs["Misc"]:AddButton({
    Title = "Teleport To Muzan";
    Description = "Teleport To Muzan If He Is Spawned";
})

Tabs["Misc"]:AddButton({
    Title = "Finish Dr.Higoshima Quest";
})

Tabs["Misc"]:AddButton({
    Title = "Teleport To Dr.Higoshima";
})

Tabs["Misc"]:AddButton({
    Title = "View Progress";
    Description = "View Demon And Slayer Progress For Free";
    Callback = function()
        local unlock = Instance.new("Part")
        unlock.Name = "18589360"
        unlock.Parent = client.gamepasses
    end
})

Tabs["Misc"]:AddButton({
    Title = "Unlock Fast Spins";
    Description = "For Clans And Bda Only";
    Callback = function()
        local unlock = Instance.new("Part")
        unlock.Name = "46503236"
        unlock.Parent = client.gamepasses
    end
})

Tabs["Misc"]:AddButton({
    Title = "Gourd Progress Viewer";
    Description = "See Your Gourd Progress For Free";
    Callback = function()
        local unlock = Instance.new("Part")
        unlock.Name = "19241624"
        unlock.Parent = client.gamepasses
    end
})

-- QUESTS

Tabs["Quests"]:AddSection("All These Functions Will Use A Smart Tp That Use Your Unlocked Map Location")

Tabs["Quests"]:AddToggle("tAutoRice", {
    Title = "Auto Rice";
    Default = false;
})

Tabs["Quests"]:AddToggle("tAutoWagon", {
    Title = "Auto Transport Wagon";
    Default = false;
})

Tabs["Quests"]:AddButton({
    Title = "Train Target";
})

Tabs["Quests"]:AddButton({
    Title = "Train Meditation";
})

Tabs["Quests"]:AddButton({
    Title = "Train Pushups";
})

Tabs["Quests"]:AddButton({
    Title = "Train Lighting Dodge";
})

-- BUFFS

local skillMod = require(game:GetService("ReplicatedStorage").Modules.Server.Skills_Modules_Handler).Skills
local gmSkills = {
    "scythe_asteroid_reap";
    "Water_Surface_Slash";
    "insect_breathing_dance_of_the_centipede";
    "blood_burst_explosive_choke_slam";
    "Wind_breathing_black_wind_mountain_mist";
    "snow_breatihng_layers_frost";
    "flame_breathing_flaming_eruption";
    "Beast_breathing_devouring_slash";
    "akaza_flashing_williow_skillasd";
    "dream_bda_flesh_monster";
    "swamp_bda_swamp_domain";
    "sound_breathing_smoke_screen";
    "ice_demon_art_bodhisatva";
}
local newtbl = {}
if gameId ~= 5956785391 then
    for i, v in gmSkills do
        for a, b in game:GetService("Players").LocalPlayer.PlayerGui.Power_Adder:GetChildren() do
            if b:IsA("Configuration") and b.Mastery_Equiped.Value == skillMod[v]["Mastery"] then
                for c, d in b["Skills"]:GetChildren() do
                    if d.Actual_Skill_Name.Value == v then
                        table.insert(newtbl, `{skillMod[v]["Mastery"]} -- {if d:FindFirstChild("Locked_Txt") then "Ult Unlocked" else `Mas {skillMod[v]["MasteryNeed"]}`}`)
                    end
                end
            end
        end
    end
end

Tabs["Buffs"]:AddDropdown("dGodMode", {
    Title = "Select Method";
    Values = newtbl;
    Default = nil;
    Multi = false;
})

Tabs["Buffs"]:AddToggle("tGodMode", {
    Title = "Toggle God Mode";
    Default = false;
    Callback = function(Value)
        if Value then
            if options["tArrowKA"].Value or options["tBringMob"].Value then
                Library:Notify({
                    Title = "Attention",
                    Content = "Can't toggle godmode and arrow ka at the same time",
                    Duration = 2
                })
                options["tGodMode"]:SetValue(false)
                return
            end
            task.spawn(function()
                options.distance = 6
                while options["tGodMode"].Value do
                    local skillName = gmSkills[table.find(newtbl, options["dGodMode"].Value)]
                    local args = {
                        [1] = "skil_ting_asd",
                        [2] = client,
                        [3] = skillName,
                        [4] = 1
                    }
                    
                    Handle_Initiate_S:FireServer(unpack(args))  
                    task.wait(skillMod[skillName]["addiframefor"])
                end
                options.distance = 7
            end)
        end
    end
})

Tabs["Buffs"]:AddToggle("tWarDrum", {
    Title = "War Drum Buff",
    Default = false,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while options["tWarDrum"].Value do
                    ReplicatedStorage.Remotes:WaitForChild("war_Drums_remote", math.huge):FireServer(true)
                    task.wait(20)
                end
            end)
        end
    end
})
options["tWarDrum"]:SetValue(true)

Tabs["Buffs"]:AddToggle("tSunImm", {
    Title = "Sun Immunity",
    Default = true,
    Callback = function(Value)
        client.PlayerScripts.Small_Scripts.Gameplay.Sun_Damage.Disabled = Value
    end
})

Tabs["Buffs"]:AddToggle("tInfStam", {
    Title = "Infinite Stamina";
    Default = true;
    Callback = function(Value)
        if Value then
            playerValues.Stamina.MinValue = 9999
        else
            playerValues.Stamina.MinValue = 0
        end
    end
})

Tabs["Buffs"]:AddToggle("tInfBreath", {
    Title = "Infinite Breathing";
    Default = true;
    Callback = function(Value)
        if Value then
            playerValues.Breath.MinValue = 9999
        else
            playerValues.Breath.MinValue = 0
        end
    end
})

Tabs["Webhook Settings"]:AddInput("iWebhook", {
    Title = "Webhook",
    Default = nil,
    Placeholder = "Enter your webhook link",
    Numeric = false, -- Only allows numbers
    Finished = true -- Only calls callback when you press enter
})

local wb_conn;
Tabs["Webhook Settings"]:AddToggle("tWebHook", {
    Title = "Webhook";
    Default = false;
    Callback = function(Value)
        if Value then
            wb_conn = ReplicatedStorage.Remotes.To_Client.New_Item.OnClientEvent:Connect(function(item)
                webhook(item)
            end)
        else
            if wb_conn then
                wb_conn:Disconnect()
            end
        end
    end
})

SaveManager:SetLibrary(Library)
makefolder(`CloudHub/PJS`)
makefolder(`CloudHub/PJS/{client.UserId}`)
SaveManager:SetFolder(`CloudHub/PJS/{client.UserId}`)
SaveManager:BuildConfigSection(Tabs["Settings"])
Tabs["Settings"]:AddToggle("tAutoExec", {
    Title = "Auto Execute Script On Rejoin";
    Default = true;
    Callback = function(Value)
        getgenv().AutoExecCloudy = Value
    end
})
SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)

return options