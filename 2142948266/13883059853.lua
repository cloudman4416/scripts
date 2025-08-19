--MAP 2 PRIV
local options, linked, SaveManager = loadfile("CloudHub/PJS/base")()

-- SERVICES

-- VARS

linked.ordered = {
    "Muichiro Tokito";
    "Rengoku";
    "Nomay Bandit Boss";
    "Akeza";
    "Inosuke";
    "Enme";
    "Slasher";
    "Sound Trainee";
    "Tengen";
    "Snow Trainee";
    "Douma";
    "Renpeke";
    "Swampy";
}

linked.bosses = {}
for i, v in workspace.Mobs.Bosses:GetDescendants() do
    if v:IsA("Configuration") and v:FindFirstChild("Npc_Configuration") then
        local info = require(v.Npc_Configuration)
        linked.bosses[info["Name"]] = info["Npc_Spawning"]["Spawn_Locations"][1]
    end
end
local temp = {
    workspace.Mobs.Heikin["Reaper Boss"];
    workspace.Mobs.Village_1_quest_bandits.BanditBoss;
}
for i, v in temp do
    local info = require(v.Npc_Configuration)
    linked.bosses[info["Name"]] = info["Npc_Spawning"]["Spawn_Locations"][1]
end

temp = nil