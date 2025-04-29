--Arise Crossover Main
repeat task.wait() until game:IsLoaded()
local Library = loadstring(game:HttpGetAsync("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local options = Library.Options

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
local xtrafuncs = require(game:GetService("ReplicatedStorage").SharedModules.ExtraFunctions)
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
		--print(`\t{a} : {b:sub(1, -2) .. "" .. b:sub(-1)}`)
	end
end

local worlds = {}

for i, v in require(game:GetService("ReplicatedStorage").Indexer.MapInfo) do
    worlds[v.Order] = i
end

client.Character.CharacterScripts.FlyingFixer.Enabled = false

local function noclip()
    for i, v in pairs(client.Character:GetChildren()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end

local function tweento(coords:CFrame)
    local Distance = (coords.Position - client.Character.HumanoidRootPart.Position).Magnitude
    local Speed = Distance/1000

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

Window.Root.Active = true

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
                for i, v in workspace.__Extra.__Interactions:GetChildren() do
                    for a, b in v:GetChildren() do
                        if b:FindFirstChild("Model") then
                            for c, d in b.Model:GetChildren() do
                                if d:GetAttribute("Type") == "ActionZone" then
                                    d.Enabled = false
                                end
                            end
                        end
                    end
                end
                while options["tAutoMobs"].Value do
                    for i, v in serverMobs:GetDescendants() do
                        if v:GetAttribute("Dead") or not v:GetAttribute("Id") or not options["tAutoMobs"].Value then
                            continue
                        end
                        if mobinfo[v:GetAttribute("Model")].Name == options["dMobSelect"].Value and (options["tFarmBrute"].Value or not mobinfo[v:GetAttribute("Id")].TypeG) then
                            tpto(v.CFrame * CFrame.new(8, 0, 0) * CFrame.Angles(0, math.rad(90), 0))
                            task.wait(0.3)
                            local target = clientMobs:WaitForChild(v.Name)
                            if not target then continue end
                            task.spawn(function()
                                while not v:GetAttribute("Dead") and options["tAutoMobs"].Value do
                                    while not truc:GetChildren()[1]:GetAttribute("Target") and options["tAutoMobs"].Value do
                                        dataRemoteEvent:FireServer({
                                            [1] = {
                                                ["PetPos"] = {},
                                                ["AttackType"] = "All",
                                                ["Event"] = "Attack",
                                                ["Enemy"] = target.Name
                                            },
                                            [2] = "\8"
                                        })
                                        task.wait(0.3)
                                    end
                                    task.wait()
                                end
                            end)
                            for a, b in truc:GetChildren() do
                                b:WaitForChild(b.Name):WaitForChild("HumanoidRootPart").CFrame = target.HumanoidRootPart.CFrame
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
                            client.PlayerGui:WaitForChild("ProximityPrompts", 1)
                            if client.PlayerGui:FindFirstChild("ProximityPrompts") then
                                client.PlayerGui.ProximityPrompts:WaitForChild("Arise", 1)
                                while client.PlayerGui.ProximityPrompts:FindFirstChild("Arise") and options["tAutoMobs"].Value do
                                    dataRemoteEvent:FireServer({
                                        [1] = {
                                            ["Event"] = `Enemy{options["dMobAction"].Value}`;
                                            ["Enemy"] = target.Name;
                                        };
                                        [2] = "\4"
                                    })
                                    task.wait(0.2)
                                end
                            end
                        end
                    end
                    task.wait()
                end
                _conn:Disconnect()
                antifall:Destroy()
                for i, v in workspace.__Extra.__Interactions:GetChildren() do
                    for a, b in v:GetChildren() do
                        if b:FindFirstChild("Model") then
                            for c, d in b.Model:GetChildren() do
                                if d:GetAttribute("Type") == "ActionZone" then
                                    d.Enabled = true
                                end
                            end
                        end
                    end
                end
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
})
serverMobs.DescendantAdded:Connect(function(Desc)
    pcall(function()
        if zone == tonumber(Desc.Parent.Name) then
            return
        end
        if Desc.Parent == serverMobs then
            zone = 250
            options["dMobSelect"]:SetValues(getKeys(bla[zone] or {}))
            return
        end
        zone = tonumber(Desc.Parent.Name)
        options["dMobSelect"]:SetValues(getKeys(bla[zone] or {}))
    end)
end)


Tabs["Auto Farm"]:AddDropdown("dMobAction", {
    Title = "Action When Mob Is Killed";
    Values = {"Capture", "Destroy"};
    Default = "Capture";
    Multi = false
})


Tabs["Auto Farm"]:AddToggle("tFarmBrute", {
    Title = "Include Brutes";
    Description = "Will Also Farm Brutes (Big Ennemies)";
    Default = false;
})

--DUNGEON TAB
local p = Tabs["Dungeon"]:AddParagraph({
    Title = "Dungeon Status";
    Content = `Map : {workspace.__Main.__Dungeon:FindFirstChild("Dungeon") and workspace.__Main.__Dungeon.Dungeon:GetAttribute("MapName") or "Not Spawned Yet"}\nDifficulty : {xtrafuncs.GetRankInfo(workspace.__Main.__Dungeon:FindFirstChild("Dungeon") and workspace.__Main.__Dungeon.Dungeon:GetAttribute("DungeonRank") or 1)}`
})

workspace.__Main.__Dungeon.ChildAdded:Connect(function(child)
    if child.Name == "Dungeon" then
        p:SetDesc(`Map : {child:GetAttribute("MapName")}\nDifficulty : {xtrafuncs.GetRankInfo(child:GetAttribute("DungeonRank"))}`)
    end
end)

Tabs["Dungeon"]:AddToggle("tJoinDungeon", {
    Title = "Auto Join Dungeons";
    Default = false;
    Callback = function(Value)
        if Value then
            task.wait(1)
            task.spawn(function()
                while options["tJoinDungeon"].Value do
                    local dungeon = workspace.__Main.__Dungeon:WaitForChild("Dungeon")
                    if options["tJoinDungeon"].Value and dungeon then
                        if options[`dDungeon{dungeon:GetAttribute("MapName")}`].Value[xtrafuncs.GetRankInfo(dungeon:GetAttribute("DungeonRank"))] then
                            print("joining current dungeon caus")
                            if options["tBuyDungTicket"].Value then
                                dataRemoteEvent:FireServer({
                                    [1] = {
                                        ["Type"] = "Gems",
                                        ["Event"] = "DungeonAction",
                                        ["Action"] = "BuyTicket"
                                    },
                                    [2] = "\n"
                                })                                
                            end
                            task.wait(1)
                            dataRemoteEvent:FireServer({
                                [1] = {
                                    ["Event"] = "DungeonAction";
                                    ["Action"] = "Create";
                                };
                                [2] = "\n";
                            })
                            repeat task.wait() until client:GetAttribute("InDungeon")
                            dataRemoteEvent:FireServer({
                                [1] = {
                                    ["Dungeon"] = client.UserId;
                                    ["Event"] = "DungeonAction";
                                    ["Action"] = "Start"
                                };
                                [2] = "\n";
                            })
                            task.wait(10)
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

Tabs["Dungeon"]:AddToggle("tBuyDungTicket", {
    Title = "Auto Buy Dungeon Ticket";
    Default = false;
})

for i, v in worlds do
    Tabs["Dungeon"]:AddDropdown(`dDungeon{v}`, {
        Title = `{v} Configuration`;
        Values = {"E", "D", "C", "B", "A", "S", "SS"};
        Default = {};
        Multi = true;
    })
end



--TELEPORT TAB
local ranks = {}

Tabs["Teleport"]:AddDropdown("dWorldSelect", {
    Title = "Select World";
    Values = worlds;
    Default = 1;
    Multi = false;
})


Tabs["Teleport"]:AddButton({
    Title = "Teleport";
    Callback = function()
        Library:Notify({
            Title = "Loading",
            Content = "Preloading Map",
            Duration = 2
        })
        client:RequestStreamAroundAsync(workspace.__Extra.__Spawns[options["dWorldSelect"].Value].Position)
        tpto(CFrame.new(workspace.__Extra.__Spawns[options["dWorldSelect"].Value].Position) * CFrame.new(0, 5, 0))
    end
})

Tabs["Teleport"]:AddButton({
    Title = "Teleport To Dedu Island";
    Description = "Will Only Tp If Map Is Loaded";
    Callback = function()
        Library:Notify({
            Title = "Loading",
            Content = "Preloading Map",
            Duration = 2
        })
        client:RequestStreamAroundAsync(Vector3.new(3928, 59, 3179))
        tpto(CFrame.new(3928, 59, 3179) * CFrame.new(0, 5, 0))
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

for i, v in options do
    v:OnChanged(function()
        SaveManager:Save(options.SaveManager_ConfigList.Value)
    end)
end