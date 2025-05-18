--Arise Crossover Dungeon
repeat task.wait() until game:IsLoaded()
local Library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/cloudman4416/CloudLib/refs/heads/main/main.lua"))() --https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
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
local dataRemoteEvent = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")
local truc = workspace.__Main.__Pets:FindFirstChild(client.UserId, true)
local clientMobs = workspace.__Main.__Enemies.Client
local serverMobs = workspace.__Main.__Enemies.Server
local xtrafuncs = require(ReplicatedStorage.SharedModules.ExtraFunctions)
-- VERY IMPORTANT BRIDGE THING
local bridgenet = require(ReplicatedStorage.BridgeNet2)
local pet_bridge = bridgenet.ReferenceBridge("PET_EVENT")
local enemy_bridge = bridgenet.ReferenceBridge("ENEMY_EVENT")
local general_bridge = bridgenet.ReferenceBridge("GENERAL_EVENT")

local signals = {
	EnemyDeath = Instance.new("BindableEvent");
    EnemyArise = Instance.new("BindableEvent");
    EnemyDestroy = Instance.new("BindableEvent");
    Arise = Instance.new("BindableEvent");
}

enemy_bridge:Connect(function(data)
	local s = signals[data.Event]
	if s then
		s:Fire(data)
	end
end)

local function await(event, options, timeout)
	local s = signals[event]
	if not s then
		warn(`{event} Is Not A Valid Event`)
	end
	local be = Instance.new("BindableEvent")
	tmp = s.Event:Connect(function(data)
		for i, v in (options or {}) do
			if data[i] ~= v then
				return
			end
		end
		be:Fire(data)
		tmp:Disconnect()
	end)
    if timeout then
        task.delay(timeout, function()
            tmp:Disconnect()
            be:Fire({})
        end)
    end
	return be.Event:Wait()
end


--[[
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
]]

client.Character.CharacterScripts.FlyingFixer.Enabled = false

local function noclip()
    for i, v in pairs(client.Character:GetChildren()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end

local tweento = function(coords:CFrame)
    local Distance = (coords.Position - client.Character.HumanoidRootPart.Position).Magnitude
    local Speed = Distance/300

    local tween = TweenService:Create(client.Character.HumanoidRootPart,
        TweenInfo.new(Speed, Enum.EasingStyle.Linear),
        { CFrame = coords}
    )

    tween:Play()
    return tween
end

local function tpto(p1)
    pcall(function()
        client.Character.HumanoidRootPart.CFrame = p1
    end)
end

local function getKeys(tbl)
	local keys = {}
	for k in pairs(tbl) do
		table.insert(keys, k)
	end
	return keys
end

local function WaitForChildWichIsA(parent, class)
    while not parent:FindFirstChildWhichIsA(class) do
        task.wait()
    end
    return parent:FindFirstChildWhichIsA(class)
end

--GUI ANNOYING PART

local Window;
if UserInputService.TouchEnabled then
    Window = Library:CreateWindow{
        Title = `Cloudhub | Arise Crossover`,
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

    local conn = Frame.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)

    task.spawn(function()
        repeat task.wait()
        until Library.Unloaded

        Frame:Destroy()
        conn:Disconnect()
    end)
else
    Window = Library:CreateWindow{
        Title = `Cloudhub | Arise Crossover`,
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
    ["Auto Farm"] = Window:AddTab({Title = "Auto Farm", Icon = ""});
    ["Webhook Settings"] = Window:AddTab({Title = "Webhook settings", Icon = ""});
    ["Settings"] = Window:AddTab({Title = "Settings", Icon = "settings"});
}

-- AUTOFARM
Tabs["Auto Farm"]:AddToggle("tAutoMobs", {
    Title = "Auto Clear Dungeon";
    Default = false;
    Callback = function(Value)
        if Value then
            task.spawn(function()
                local _conn = RunService.Stepped:Connect(noclip)
                local antifall = Instance.new("BodyVelocity")
                antifall.Velocity = Vector3.new(0, 0, 0)
                antifall.Parent = client.Character.HumanoidRootPart
                local cr = coroutine.create(function()
                    while options["tAutoMobs"].Value do
                        for i, v in serverMobs:GetDescendants() do
                            if v:GetAttribute("Dead") or not v:GetAttribute("Id") or not options["tAutoMobs"].Value then
                                continue
                            end
                            tweento(v.CFrame * CFrame.new(8, 0, 0) * CFrame.Angles(0, math.rad(90), 0)).Completed:Wait()
                            task.wait(0.3)
                            local target = clientMobs:WaitForChild(v.Name)
                            if not target then continue end
                            for a, b in truc:GetChildren() do
                                b:WaitForChild(b.Name):WaitForChild("HumanoidRootPart").CFrame = target.HumanoidRootPart.CFrame
                            end
                            task.spawn(function()
                                while not v:GetAttribute("Dead") and options["tAutoMobs"].Value do
                                    while not (truc:GetChildren()[1] or Instance.new("Folder")):GetAttribute("Target") and options["tAutoMobs"].Value do
                                        pet_bridge:Fire({
                                            ["PetPos"] = {},
                                            ["AttackType"] = "All",
                                            ["Event"] = "Attack",
                                            ["Enemy"] = target.Name
                                        })
                                        task.wait(0.3)
                                    end
                                    task.wait()
                                end
                            end)

                            while not v:GetAttribute("Dead") and options["tAutoMobs"].Value do
                                enemy_bridge:Fire({
                                    ["Event"] = "PunchAttack",
                                    ["Enemy"] = target.Name
                                })
                                task.wait()
                            end
                            if await("EnemyArise", {Enemy = v.Name}, 1)["CanArise"] and options["tAutoMobs"].Value then
                                client.PlayerGui:WaitForChild("ProximityPrompts", 1)
                                client.PlayerGui.ProximityPrompts:WaitForChild("Arise", 1)
                                while client.PlayerGui.ProximityPrompts:FindFirstChild("Arise") and options["tAutoMobs"].Value do
                                    enemy_bridge:Fire({
                                            ["Event"] = `Enemy{options["tCollectBoss"].Value and v:GetAttribute("IsBoss") and "Capture" or options["dMobAction"].Value}`;
                                            ["Enemy"] = target.Name;
                                        })
                                    task.wait(0.3)
                                end
                            end
                        end
                        task.wait()
                    end
                end)
                coroutine.resume(cr)
                while options["tAutoMobs"].Value do
                    task.wait()
                end
                coroutine.close(cr)
                _conn:Disconnect()
                antifall:Destroy()
            end)
        end
    end
})


Tabs["Auto Farm"]:AddDropdown("dMobAction", {
    Title = "Action When Mob Is Killed";
    Values = {"Capture", "Destroy"};
    Default = "Capture";
    Multi = false
})

Tabs["Auto Farm"]:AddToggle("tCollectBoss", {
    Title = "Capture Boss";
    Description = "Will Capture The Boss Whatever You Chose Above";
    Default = false;
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

for i, v in options do
    v:OnChanged(function()
        SaveManager:Save(options.SaveManager_ConfigList.Value)
    end)
end