--Ouwigahara
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
local playerValues = game:GetService("ReplicatedStorage").PlayerValues:WaitForChild(client.Name)
local distance = 15

-- DUMP
local places = require(game:GetService("ReplicatedStorage").Modules.Global.Map_Locaations)
local bosses = {}

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

local counter = 0
local time = tick()

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

function findMob(hrp)
    for i, v in pairs(workspace.Mobs:GetChildren()) do
        if v:IsA("Folder") and v:FindFirstChildWhichIsA("Model") then   
            local model = v:FindFirstChildWhichIsA("Model")
            if model:FindFirstChild("Humanoid") and model:FindFirstChild("Humanoid").Health > 0 then
                if hrp then
                    if model:FindFirstChild('HumanoidRootPart') then
                        return model
                    end
                else
                    return model
                end
            end
        end
    end
    return
end

local function noclip()
    for i, v in pairs(client.Character:GetChildren()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
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

Window.Root.Active = true

local Tabs = {
    ["Auto Farm"] = Window:AddTab({Title = "Auto Farm", Icon = "house"});
    ["Kill Auras"] = Window:AddTab({Title = "Kill Auras", Icon = ""});
    ["Misc"] = Window:AddTab({Title = "Misc", Icon = ""});
    ["Buffs"] = Window:AddTab({Title = "Buffs", Icon = ""});
    ["Webhook settings"] = Window:AddTab({Title = "Webhook settings", Icon = ""});
    ["Settings"] = Window:AddTab({Title = "UI Settings", Icon = "settings"});
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
    Title = "Select Macro",
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
	Title = "Auto Tp To Mobs",
    Description = "Very Important to enable even with arrow ka";
	Default = false,
	Callback = function(Value)
        local _conn
        if Value then
            task.spawn(function()
                _conn = RunService.Stepped:Connect(noclip)
                local antifall = Instance.new("BodyVelocity")
                antifall.Velocity = Vector3.new(0, 0, 0)
                antifall.Parent = client.Character.HumanoidRootPart
                while options.tAutoBoss.Value do
                    for i, v in workspace.Mobs:GetChildren() do
                        if not v:FindFirstChildWhichIsA("Model") then
                            pcall(function()
                                tweento(CFrame.new(v:WaitForChild("Npc_Configuration", 1):WaitForChild("spawnlocaitonasd123", 1).Value) * CFrame.new(0, if options["tAutoM1"].Value then 10 else 25, 0) * CFrame.Angles(math.rad(-90), 0, 0)).Completed:Wait()
                            end)
                        else
                            tweento(v:FindFirstChildWhichIsA("Model"):GetModelCFrame() * CFrame.new(0, if options["tAutoM1"].Value then 10 else 25, 0) * CFrame.Angles(math.rad(-90), 0, 0)).Completed:Wait()
                        end
                        local model = v:FindFirstChildWhichIsA("Model")
                        if options["tAutoM1"].Value then
                            while model and model:FindFirstChild("Humanoid") and model:FindFirstChild("Humanoid").Health > 0 and options.tAutoBoss.Value do
                                tpto(model.HumanoidRootPart.CFrame * CFrame.new(0, distance, 0) * CFrame.Angles(math.rad(-90), 0, 0))
                                task.wait()
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
                        game:GetService("ReplicatedStorage").Remotes.To_Server.Handle_Initiate_S:FireServer(weapons[options.dWeaponSelect.Value], client, client.Character, client.Character.HumanoidRootPart, client.Character.Humanoid, 919)
                        game:GetService("ReplicatedStorage").Remotes.To_Server.Handle_Initiate_S:FireServer(weapons[options.dWeaponSelect.Value], client, client.Character, client.Character.HumanoidRootPart, client.Character.Humanoid, math.huge)
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

-- KILL AURAS
Tabs["Kill Auras"]:AddToggle("tArrowKA", {
    Title = 'Arrow KA',
    Default = false,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while options.tArrowKA.Value do
                    local args = {
                        [1] = "skil_ting_asd",
                        [2] = client,
                        [3] = "arrow_knock_back",
                        [4] = 5
                    }

                    game:GetService("ReplicatedStorage").Remotes.To_Server.Handle_Initiate_S_:InvokeServer(unpack(args))
                    task.wait(6)
                end
            end)
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

                        game:GetService("ReplicatedStorage").Remotes.To_Server.Handle_Initiate_S:FireServer(unpack(args))
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
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
    Multi = false
})

Tabs["Buffs"]:AddToggle("tGodMode", {
    Title = "Toggle God Mode",
    Default = false,
    Callback = function(Value)
        if Value then
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
                    
                    game:GetService("ReplicatedStorage").Remotes.To_Server.Handle_Initiate_S:FireServer(unpack(args))  
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
    Title = "tInfBreath",
    Default = true,
    Callback = function(Value)
        if Value then
            playerValues.Breath.MinValue = 9999
        else
            playerValues.Breath.MinValue = 0
        end
    end
})

SaveManager:SetLibrary(Library)
SaveManager:SetFolder("CloudHub/babouche")
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