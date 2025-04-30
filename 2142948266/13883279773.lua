--Map 1 Priv
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

-- VARS
local client = Players.LocalPlayer
repeat task.wait() until game:GetService("ReplicatedStorage").Player_Data:FindFirstChild(client.Name)
local playerValues = game:GetService("ReplicatedStorage").PlayerValues:WaitForChild(client.Name)
local playerData = game:GetService("ReplicatedStorage").Player_Data:WaitForChild(client.Name)
local Handle_Initiate_S = game:GetService("ReplicatedStorage").Remotes.To_Server:WaitForChild("Handle_Initiate_S")
local Handle_Initiate_S_ = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("To_Server"):WaitForChild("Handle_Initiate_S_")
local distance = 15

-- DUMP
local places = require(game:GetService("ReplicatedStorage").Modules.Global.Map_Locaations)
local bosses = {}
for i, v in workspace.Mobs.Bosses:GetDescendants() do
    if v:IsA("Configuration") and v:FindFirstChild("Npc_Configuration") then
        local info = require(v.Npc_Configuration)
        bosses[info["Name"]] = info["Npc_Spawning"]["Spawn_Locations"][1]
    end
end
local temp = {
    workspace.Mobs.Bandits.Zone1.Boss;
    workspace.Mobs.Bandits.Zone2.Kaden;
}
for i, v in temp do
    local info = require(v.Npc_Configuration)
    bosses[info["Name"]] = info["Npc_Spawning"]["Spawn_Locations"][1]
end

temp = nil

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
        TabWidth = 160,
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
        TabWidth = 160,
        Size = UDim2.fromOffset(830, 525),
        Resize = true, -- Resize this ^ Size according to a 1920x1080 screen, good for mobile users but may look weird on some devices
        MinSize = Vector2.new(470, 380),
        Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightShift -- Used when theres no MinimizeKeybind
    }
end

local Tabs = {
    ["Auto Farm"] = Window:AddTab({Title = "Auto Farm", Icon = ""});
    ["Kill Auras"] = Window:AddTab({Title = "Kill Auras", Icon = ""});
    ["Misc"] = Window:AddTab({Title = "Misc", Icon = ""});
    ["Quests"] = Window:AddTab({Title = "Quests", Icon = ""});
    ["Buffs"] = Window:AddTab({Title = "Buffs", Icon = ""});
    ["Webhook Settings"] = Window:AddTab({Title = "Webhook settings", Icon = ""});
    ["Settings"] = Window:AddTab({Title = "Settings", Icon = "settings"});
}

-- AUTO FARM

local weapons = {
    ["Combat"] = "fist_combat";
    ["Scythe"] = "Scythe_Combat_Slash";
    ["Sword"] = "Sword_Combat_Slash";
    ["Fans"] = "fans_combat_slash";
    ["Claws"] = "claw_Combat_Slash";
}

Tabs["Auto Farm"]:AddDropdown("dWeaponSelect", {
    Title = "Select Weapon",
    Values = {"Combat", "Scythe", "Sword", "Fans", "Claws"};
    Default = "Combat",
    Multi = false,
    Callback = function(Options) 
        
    end,
})

Tabs["Auto Farm"]:AddSlider("sTweenSpeed", {
    Title = "TweenSpeed",
    Description = "This is a slider",
    Default = 400,
    Min = 100,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
    end
})
Tabs["Auto Farm"]:AddToggle("tAutoBoss", {
	Title = "Auto Boss",
	Default = false,
	Callback = function(Value)
        if Value then
            options["tAutoFlower"]:SetValue(false)
            task.spawn(function()
                local _conn = RunService.Stepped:Connect(noclip)
                local antifall = Instance.new("BodyVelocity")
                antifall.Velocity = Vector3.new(0, 0, 0)
                antifall.Parent = client.Character.HumanoidRootPart
                while options.tAutoBoss.Value do
                    for boss, coord in bosses do
                        if options.tAutoBoss.Value then
                            --smartTp(coord + Vector3.new(0, 3, 0))
                            tweento(CFrame.new(coord) * CFrame.new(0, 3, 0)).Completed:Wait()
                            local boboss = findBoss(boss, true)
                            if boboss ~= nil and options.tAutoBoss.Value then
                                while boboss:FindFirstChild("Humanoid").Health > 0 and options.tAutoBoss.Value do
                                    tpto(boboss.HumanoidRootPart.CFrame * CFrame.new(0, distance, 0) * CFrame.Angles(math.rad(-90), 0, 0))
                                    task.wait()
                                end
                            end
                        end
                    end
                    task.wait()
                end
                _conn:Disconnect()
                antifall:Destroy()
            end)
        end
	end    
})

Tabs["Auto Farm"]:AddToggle("tAutoM1", {
	Title = "Weapon KillAura",
	Default = false,
    Callback = function(Value)
        task.spawn(function()
            if Value then
                while options.tAutoM1.Value do
                    if not options["tGodMode"].Value then distance = 7 end
                    task.wait(0.1)
                    for i = 1, 8 do
                        Handle_Initiate_S:FireServer(weapons[options.dWeaponSelect.Value], client, client.Character, client.Character.HumanoidRootPart, client.Character.Humanoid, 919)
                        Handle_Initiate_S:FireServer(weapons[options.dWeaponSelect.Value], client, client.Character, client.Character.HumanoidRootPart, client.Character.Humanoid, math.huge)
                    end
                    task.wait(0.1)
                    if not options["tGodMode"].Value then distance = 15 end
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
	Title = "Auto Collect Chests",
	Default = false,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while options.tAutoChest.Value do
                    for a, b in pairs(game.Workspace.Debree:GetChildren()) do
                        if b.Name == "Loot_Chest" then
                            for c, d in pairs(b.Drops:GetChildren()) do
                                b.Add_To_Inventory:InvokeServer(d.Name)
                                if options["tWebHook"].Value then
                                    task.spawn(function()
                                        if table.find(rarities, d.Value) then
                                            webhook(client.PlayerGui.MainGuis.Info2.Holder.Items_Holder[d.Name])
                                        end
                                    end)
                                end
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
    Callback = function(Value)
        if Value then
            options["tAutoBoss"]:SetValue(false)
            local _conn = RunService.Stepped:Connect(noclip)
            local antifall = Instance.new("BodyVelocity")
            antifall.Velocity = Vector3.new(0, 0, 0)
            antifall.Parent = client.Character.HumanoidRootPart
            while options["tAutoFlower"].Value do
                for i, v in workspace.Demon_Flowers_Spawn:GetChildren() do
                    if v:IsA("Model") and options["tAutoFlower"].Value then
                        pcall(function()
                            tweento(v:GetModelCFrame()).Completed:Wait()
                            v["Cube.002"].CFrame = v["Cube.002"].CFrame * CFrame.new(0, 5, 0)
                            task.wait(0.5)
                            fireproximityprompt(v["Cube.002"].Pick_Demon_Flower_Thing)
                            task.wait(0.5)
                        end)
                    end
                end
            end
            _conn:Disconnect()
            antifall:Destroy()
        end
    end
})

-- KILL AURAS
Tabs["Kill Auras"]:AddToggle("tArrowKA", {
    Title = 'Arrow KA',
    Default = false,
    Callback = function(Value)
        if Value then
            if options["tBringMob"].Value then
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
    Title = 'Arrow Bring Mob',
    Default = false,
    Callback = function(Value)
        if Value then
            if options["tArrowKA"].Value then
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

--[[

local args = {
    [1] = "Quest_add",
    [2] = "Players.niatok1.PlayerGui.ExcessGuis.chairui.Holder.LocalScript",
    [3] = 860.1893076999986,
    [4] = {},
    [5] = game:GetService("Players").LocalPlayer,
    [6] = "donetargettraining"
}

Handle_Initiate_S_:InvokeServer(unpack(args))


local args = {
    [1] = "Quest_add",
    [2] = "Players.niatok1.PlayerGui.ExcessGuis.Meditate_gui.Holder.LocalScript",
    [3] = 606.4314756999956,
    [4] = {},
    [5] = game:GetService("Players").LocalPlayer,
    [6] = "donedoingmeditation"
}

Handle_Initiate_S_:InvokeServer(unpack(args))

local args = {
    [1] = "Quest_add",
    [2] = "Players.niatok1.PlayerGui.ExcessGuis.Push_Up_Gui.Holder.push_up_mat_local_script",
    [3] = 784.9211604000011,
    [4] = {},
    [5] = game:GetService("Players").LocalPlayer,
    [6] = "donepushuptraining"
}

Handle_Initiate_S_:InvokeServer(unpack(args))

local args = {
    [1] = "Quest_add",
    [2] = "Players.niatok1.PlayerGui.ExcessGuis.thnder_gui.Holder.LocalScript",
    [3] = 1003.2731308999937,
    [4] = {},
    [5] = game:GetService("Players").LocalPlayer,
    [6] = "donelightningdodge"
}

Handle_Initiate_S_:InvokeServer(unpack(args))


]]

if getrenv then
    local tang = game:GetService("Players").LocalPlayer.PlayerGui.MainGuis.Settings.Scroll.KeybindsHolder
    local skill = getrenv()._G.skills_modules_thing
    local skells = client.PlayerGui.Power_Adder
    for i = 1, 6 do
        Tabs["Misc"]:AddToggle(`tMove{i}`, {
            Title = `Auto Skill {tang:WaitForChild("Move"..i).Buttons.txt.txt.Text}`;
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
    Callback = function()
        local _conn = RunService.Stepped:Connect(noclip)
        local antifall = Instance.new("BodyVelocity")
        antifall.Velocity = Vector3.new(0, 0, 0)
        antifall.Parent = client.Character.HumanoidRootPart
        if workspace:FindFirstChild("Muzan") then
            tweento(CFrame.new(workspace.Muzan.SpawnPos.Value))
        else
            Library:Notify({
                Title = "Muzan",
                Content = "Muzan Is Not Spawned Wait For The Night",
                Duration = 2
            })
        end
        antifall:Destroy()
        _conn:Disconnect()
    end
})

Tabs["Misc"]:AddButton({
    Title = "Finish Dr.Higoshima Quest";
    Callback = function()
        local args = {
            [1] = "Quest_add",
            [2] = `Players.{client.Name}.PlayerGui.Npc_Dialogue.LocalScript.Functions`,
            [3] = os.clock(),
            [4] = {},
            [5] = client,
            [6] = "doctorhigoshimabringbacktomuzan"
        }
        Handle_Initiate_S:FireServer(unpack(args))
    end
})

Tabs["Misc"]:AddButton({
    Title = "Teleport To Dr.Higoshima";
    Callback = function()
        local _conn = RunService.Stepped:Connect(noclip)
        local antifall = Instance.new("BodyVelocity")
        antifall.Velocity = Vector3.new(0, 0, 0)
        antifall.Parent = client.Character.HumanoidRootPart
        tweento(workspace["Doctor Higoshima"]:GetModelCFrame())
        antifall:Destroy()
        _conn:Disconnect()
    end
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
    Callback = function(Value)
        task.spawn(function()
            if Value then
                local _conn = RunService.Stepped:Connect(noclip)
                local antifall = Instance.new("BodyVelocity")
                antifall.Velocity = Vector3.new(0, 0, 0)
                antifall.Parent = client.Character.HumanoidRootPart
                while options["tAutoRice"].Value do
                    smartTp(workspace.Sarah:GetModelCFrame())
                    task.wait(0.2)
                    local args = {
                        [1] = "AddQuest",
                        [2] = `Players.{client.Name}.PlayerGui.Npc_Dialogue.LocalScript.Functions`,
                        [3] = os.clock(),
                        [4] = playerData:WaitForChild("Quest"),
                        [5] = {
                            ["Current"] = "Help Sarah pick rice"
                        }
                    }
                    Handle_Initiate_S:FireServer(unpack(args))
                    task.wait(0.2)

                    while playerData.Quest.Current.Value == "Help Sarah pick rice" and options["tAutoRice"].Value do
                        local rice = workspace.StarterVillage_RiceStrings:FindFirstChild("RiceString")
                        if rice then
                            tweento(rice.CFrame).Completed:Wait()
                            task.wait(0.2)
                            local args = {
                                [1] = "givericequestthing",
                                [2] = `Players.{client.Name}.PlayerGui.localscript_cache.Prompts_Handler`,
                                [3] = client,
                                [4] = rice,
                                [5] = os.clock()
                            }
                            
                            Handle_Initiate_S:FireServer(unpack(args))
                        end
                        task.wait(0.2)
                    end
                end
                _conn:Disconnect()
                antifall:Destroy()
            end
        end)
    end
})

Tabs["Quests"]:AddToggle("tAutoWagon", {
    Title = "Auto Transport Wagon";
    Default = false;
    Callback = function(Value)
        if Value then
            task.spawn(function()
                local _conn = RunService.Stepped:Connect(noclip)
                local antifall = Instance.new("BodyVelocity")
                antifall.Velocity = Vector3.new(0, 0, 0)
                antifall.Parent = client.Character.HumanoidRootPart
                while options["tAutoWagon"].Value do
                    smartTp(workspace["Grandpa Wagwon"]:GetModelCFrame())
                    task.wait(0.2)
                    local args = {
                        [1] = "AddQuest",
                        [2] = `Players.{client.Name}.PlayerGui.Npc_Dialogue.LocalScript.Functions`,
                        [3] = os.clock(),
                        [4] = playerData:WaitForChild("Quest"),
                        [5] = {
                            ["Current"] = "Deliver grandpa Wagwon's wagon",
                        }
                    }
                    Handle_Initiate_S:FireServer(unpack(args))
                    task.wait(0.2)
                    while playerData.Quest.Current.Value == "Deliver grandpa Wagwon's wagon" and workspace.Debree:FindFirstChild("wagonasd") do
                        smartTp(CFrame.new(454.2309875488281, 275.26300048828125, -2670.489013671875))
                    end
                end
                _conn:Disconnect()
                antifall:Destroy()
            end)
        end
    end
})

Tabs["Quests"]:AddButton({
    Title = "Train Target";
    Callback = function()
        client:RequestStreamAroundAsync(Vector3.new(2857, 315, -4064))
        workspace.Target_Training.Chair:WaitForChild("Detect_Part").Initiated:FireServer()
        task.wait(1)
        local args = {
            [1] = "Quest_add",
            [2] = `Players.{client.Name}.PlayerGui.ExcessGuis.chairui.Holder.LocalScript`,
            [3] = os.clock(),
            [4] = {},
            [5] = client,
            [6] = "donetargettraining"
        }
        
        Handle_Initiate_S_:InvokeServer(unpack(args))
        Handle_Initiate_S:FireServer("remove_item", client.PlayerGui.ExcessGuis:WaitForChild("chairui", 1))
    end;
})

Tabs["Quests"]:AddButton({
    Title = "Train Meditation";
    Callback = function()
        client:RequestStreamAroundAsync(Vector3.new(2786, 314, -3856))
        workspace.Map.Chunk23:WaitForChild("Meditate_Mat").Initiated:FireServer()
        task.wait(1)
        local args = {
            [1] = "Quest_add",
            [2] = `Players.{client.Name}.PlayerGui.ExcessGuis.Meditate_gui.Holder.LocalScript`,
            [3] = os.clock(),
            [4] = {},
            [5] = client,
            [6] = "donedoingmeditation"
        }
        
        Handle_Initiate_S_:InvokeServer(unpack(args))
        Handle_Initiate_S:FireServer("remove_item", client.PlayerGui.ExcessGuis:WaitForChild("Meditate_gui", 1))
    end;
})

Tabs["Quests"]:AddButton({
    Title = "Train Pushups";
    Callback = function()
        client:RequestStreamAroundAsync(Vector3.new(2786, 314, -3856))
        workspace.Map.Chunk23:WaitForChild("Push_Ups_Mat").Initiated:FireServer()
        task.wait(1)
        local args = {
            [1] = "Quest_add",
            [2] = `Players.{client.Name}.PlayerGui.ExcessGuis.Push_Up_Gui.Holder.push_up_mat_local_script`,
            [3] = os.clock(),
            [4] = {},
            [5] = client,
            [6] = "donepushuptraining"
        }
        
        Handle_Initiate_S_:InvokeServer(unpack(args))
        Handle_Initiate_S:FireServer("remove_item", client.PlayerGui.ExcessGuis:WaitForChild("Push_Up_Gui", 1))
    end;
})

Tabs["Quests"]:AddButton({
    Title = "Train Lighting Dodge";
    Callback = function()
        local _conn = RunService.Stepped:Connect(noclip)
        local antifall = Instance.new("BodyVelocity")
        antifall.Velocity = Vector3.new(0, 0, 0)
        antifall.Parent = client.Character.HumanoidRootPart
        tweento(CFrame.new(-992, 469, -2309)).Completed:Wait()
        client.PlayerGui.ExcessGuis:WaitForChild("thnder_gui")
        task.wait(1)
        local args = {
            [1] = "Quest_add",
            [2] = `Players.{client.Name}.PlayerGui.ExcessGuis.thnder_gui.Holder.LocalScript`,
            [3] = os.clock(),
            [4] = {},
            [5] = client,
            [6] = "donelightningdodge"
        }
        
        Handle_Initiate_S_:InvokeServer(unpack(args))
        Handle_Initiate_S:FireServer("remove_item", client.PlayerGui.ExcessGuis:WaitForChild("thnder_gui", 1))
        _conn:Disconnect()
        antifall:Destroy()
    end;
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

Tabs["Buffs"]:AddDropdown("dGodMode", {
    Title = "Select Method",
    Values = newtbl;
    Default = nil,
    Multi = false,
    Callback = function(Options) 
        print(Options)
    end,
})

Tabs["Buffs"]:AddToggle("tGodMode", {
    Title = "Toggle God Mode",
    Default = false,
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
                distance = 6
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
                distance = 7
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
                    game:GetService("ReplicatedStorage").Remotes.war_Drums_remote:FireServer(true)
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
    Title = "Infinite Stamina",
    Default = true,
    Callback = function(Value)
        if Value then
            playerValues.Stamina.MinValue = 9999
        else
            playerValues.Stamina.MinValue = 0
        end
    end
})

Tabs["Buffs"]:AddToggle("tInfBreath", {
    Title = "Infinite Breathing",
    Default = true,
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

Tabs["Webhook Settings"]:AddToggle("tWebHook", {
    Title = "Webhook";
    Default = false;
    Callback = function(Value)
        
    end
})

SaveManager:SetLibrary(Library)
makefolder(`CloudHub/{game.PlaceId}`)
makefolder(`CloudHub/{game.PlaceId}/{client.UserId}`)
SaveManager:SetFolder(`CloudHub/{game.PlaceId}/{client.UserId}`)
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
