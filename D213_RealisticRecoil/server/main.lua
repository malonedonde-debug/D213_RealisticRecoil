local shootingSkills = {}

-- Initialize Database
MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS player_shooting_skill (
            identifier VARCHAR(60) NOT NULL PRIMARY KEY,
            skill FLOAT DEFAULT 0.0
        )
    ]])
end)

-- Fetch skill on player join
RegisterNetEvent("recoil:server:requestSkill", function()
    local src = source
    local identifier = GetPlayerIdentifier(src, 0) -- Simplified for Standalone/ESX
    
    local result = MySQL.single.await("SELECT skill FROM player_shooting_skill WHERE identifier = ?", {identifier})
    local skill = result and result.skill or 0.0
    
    shootingSkills[src] = skill
    TriggerClientEvent("recoil:client:updateSkill", src, skill)
end)

-- Update skill in DB
RegisterNetEvent("recoil:server:addSkill", function(amount)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    
    if not shootingSkills[src] then shootingSkills[src] = 0.0 end
    
    shootingSkills[src] = math.min(Config.MaxSkill, shootingSkills[src] + amount)
    
    MySQL.update.await("INSERT INTO player_shooting_skill (identifier, skill) VALUES (?, ?) ON DUPLICATE KEY UPDATE skill = ?", 
    {identifier, shootingSkills[src], shootingSkills[src]})
    
    TriggerClientEvent("recoil:client:updateSkill", src, shootingSkills[src])
end)

-- Command to check skill
RegisterCommand(Config.CommandName, function(source)
    local skill = shootingSkills[source] or 0.0
    local msg = string.format("Current Shooting Skill: %.2f%%", skill)
    TriggerClientEvent("recoil:client:notifySkill", source, msg)
end, false)