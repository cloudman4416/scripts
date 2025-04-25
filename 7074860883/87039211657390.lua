--Arise Crossover
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
local dataRemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")
local truc = workspace.__Main.__Pets:FindFirstChild(client.UserId, true)
local clientMobs = workspace.__Main.__Enemies.Client
local serverMobs = workspace.__Main.__Enemies.Server
local mobinfo = require(game:GetService("ReplicatedStorage").Indexer.EnemyInfo)
local bla = {}

for i, v in workspace.__Main.__Enemies.Server:GetChildren() do
	bla[tonumber(v.Name)] = {}
end

for i, v in mobinfo do
	if v.TypeC == "Boss" or v.TypeG then continue end
	bla[v.World or 250][v.Name] = i
end
for i, v in bla do
	--print(i)
	for a, b in v do
		--print(`\t{a} : {b:sub(1, -2) .. "B" .. b:sub(-1)}`)
	end
end

local worlds = {}

for i, v in require(game:GetService("ReplicatedStorage").Indexer.MapInfo) do
    worlds[v.Order] = workspace.__Extra.__Spawns[i].CFrame
end


local function noclip()
    for i, v in pairs(client.Character:GetChildren()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end

local tweento = function(coords:CFrame)
    local Distance = (coords.Position - client.Character.HumanoidRootPart.Position).Magnitude
    local Speed = Distance/1000

    local tween = TweenService:Create(client.Character.HumanoidRootPart,
        TweenInfo.new(Speed, Enum.EasingStyle.Linear),
        { CFrame = coords}
    )

    tween:Play()
    return tween
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

    Frame.MouseButton1Click:Connect(function()
        Window:Minimize()
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

local Tabs = {
    ["Auto Farm"] = Window:AddTab({Title = "Auto Farm", Icon = ""});
    ["Dungeon"] = Window:AddTab({Title = "Dungeon", Icon = ""});
    ["Teleport"] = Window:AddTab({Title = "Teleport", Icon = ""});
    ["Webhook Settings"] = Window:AddTab({Title = "Webhook settings", Icon = ""});
    ["Settings"] = Window:AddTab({Title = "Settings", Icon = "settings"});
}

-- AUTOFARM
Tabs["Auto Farm"]:AddToggle("tAutoMobs", {
    Title = "Auto Farm Mobs";
    Default = false;
    Callback = function(Value)
        if Value then
            task.spawn(function()
                local _conn = RunService.Stepped:Connect(noclip)
                local antifall = Instance.new("BodyVelocity")
                antifall.Velocity = Vector3.new(0, 0, 0)
                antifall.Parent = client.Character.HumanoidRootPart
                while options["tAutoMobs"].Value do
                    for i, v in serverMobs:GetDescendants() do
                        if v:GetAttribute("Dead") or not v:GetAttribute("Id") or not options["tAutoMobs"].Value then
                            continue
                        end
                        if mobinfo[v:GetAttribute("Id")].Name == options["dMobSelect"].Value and not mobinfo[v:GetAttribute("Id")].TypeG then
                            tweento(v.CFrame * CFrame.new(8, 0, 0) * CFrame.Angles(0, math.rad(90), 0)).Completed:Wait()
                            task.wait(0.5)
                            local target = clientMobs:WaitForChild(v.Name)
                            if not target then continue end
                            local args = {
                                [1] = {
                                    [1] = {
                                        ["PetPos"] = {},
                                        ["AttackType"] = "All",
                                        ["Event"] = "Attack",
                                        ["Enemy"] = target.Name
                                    },
                                    [2] = "\5"
                                }
                            }
                            dataRemoteEvent:FireServer(unpack(args))
                            for a, b in truc:GetChildren() do
                                WaitForChildWichIsA(b, "Model"):WaitForChild("HumanoidRootPart").CFrame = target.HumanoidRootPart.CFrame
                                print("tp mob ")
                            end
                            while not v:GetAttribute("Dead") and options["tAutoMobs"].Value do
                                local args = {
                                    [1] = {
                                        [1] = {
                                            ["Event"] = "PunchAttack",
                                            ["Enemy"] = target.Name
                                        },
                                        [2] = "\4"
                                    }
                                }
                                dataRemoteEvent:FireServer(unpack(args))
                                task.wait()
                            end
                            task.wait(0.2)
                            local args = {
                                [1] = {
                                    [1] = {
                                        ["Event"] = "EnemyDestroy",
                                        ["Enemy"] = target.Name
                                    },
                                    [2] = "\4"
                                }
                            }
                            while client.PlayerGui.ProximityPrompts:FindFirstChild("Arise") and options["tAutoMobs"].Value do
                                dataRemoteEvent:FireServer(unpack(args))
                                task.wait(0.2)
                            end
                            task.wait(0.1)
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

local ting = serverMobs:FindFirstChildWhichIsA("BasePart", true)
local zone;
if ting then 
    zone = tonumber(ting.Parent.Name)
end
Tabs["Auto Farm"]:AddDropdown("dMobSelect", {
    Title = "Select Mob To Farm",
    Values = getKeys(bla[zone] or {});
    Default = nil,
    Multi = false,
    Callback = function(Options) 
        
    end,
})

serverMobs.DescendantAdded:Connect(function(Desc)
    pcall(function()
        if zone == tonumber(Desc.Parent.Name) then
            return
        end
        zone = tonumber(Desc.Parent.Name)
        options["dMobSelect"]:SetValues(getKeys(bla[zone] or {}))
    end)
end)

Tabs["Teleport"]:AddDropdown("dWorldSelect", {
    Title = "Select World";
    Values = getKeys(worlds);
    Default = 1;
    Multi = false;
})

Tabs["Teleport"]:AddButton({
    Title = "Teleport";
    Callback = function()
        local _conn = RunService.Stepped:Connect(noclip)
        local antifall = Instance.new("BodyVelocity")
        antifall.Velocity = Vector3.new(0, 0, 0)
        antifall.Parent = client.Character.HumanoidRootPart
        tweento(CFrame.new(worlds[options["dWorldSelect"].Value].Position) * CFrame.new(0, 5, 0)).Completed:Wait()
        _conn:Disconnect()
        antifall:Destroy()
    end
})

SaveManager:SetLibrary(Library)
makefolder(`CloudHub/{game.PlaceId}`)
makefolder(`CloudHub/{game.PlaceId}/{client.UserId}`)
SaveManager:SetFolder(`CloudHub/{game.PlaceId}/{client.UserId}`)
SaveManager:BuildConfigSection(Tabs["Settings"])
SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)

if queue_on_teleport and not getgenv().CloudHub then
    getgenv().CloudHub = true
    client.OnTeleport:Once(function(State)
        queue_on_teleport(`loadstring(game:HttpGet("https://raw.githubusercontent.com/cloudman4416/scripts/main/Loader.lua"))()`)
    end)
end

--[[
local args = {
    [1] = {
        [1] = {
            ["Dungeon"] = 4493042898,
            ["Event"] = "DungeonAction",
            ["Action"] = "Create"
        },
        [2] = "\n"
    }
}

game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))

local args = {
    [1] = {
        [1] = {
            ["Dungeon"] = 4493042898,
            ["Event"] = "DungeonAction",
            ["Action"] = "Start"
        },
        [2] = "\n"
    }
}

game:GetService("ReplicatedStorage"):WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent"):FireServer(unpack(args))

]]