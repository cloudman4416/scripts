--MAP 1 PRIV
local options, linked, SaveManager = loadfile("CloudHub/PJS/base")()

-- SERVICES

-- VARS

linked.ordered = {
    "Susamaru";
    "Yahaba";
    "Sanemi";
    "Bandit Kaden";
    "Zanegutsu Kuuchie";
    "Bandit Zoku";
    "Sabito";
    "Giyu";
    "Shiron";
    "Nezuko";
    "Slasher";
}

linked.bosses = {}
for i, v in workspace.Mobs.Bosses:GetDescendants() do
    if v:IsA("Configuration") and v:FindFirstChild("Npc_Configuration") then
        local info = require(v.Npc_Configuration)
        linked.bosses[info["Name"]] = info["Npc_Spawning"]["Spawn_Locations"][1]
    end
end
local temp = {
    workspace.Mobs.Bandits.Zone1.Boss;
    workspace.Mobs.Bandits.Zone2.Kaden;
}
for i, v in temp do
    local info = require(v.Npc_Configuration)
    linked.bosses[info["Name"]] = info["Npc_Spawning"]["Spawn_Locations"][1]
end

temp = nil