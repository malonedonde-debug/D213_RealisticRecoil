
Config = {}

-- General Settings
Config.CommandName = "shootingskill"
Config.SkillNotifyFrequency = 5 -- Notify player every X shots about progress

-- Aiming Shake Settings
Config.EnableAimShake = true -- Can be toggled in-game via script logic
Config.AimShakes = {
    "DRUNK_SHAKE",
    "WATER_BOB_SHAKE",
    "CINEMATIC_SHOOTING_RUN_SHAKE",
    "HAND_SHAKE"
}

-- Shooting Shake Settings
Config.ShootingShake = "CINEMATIC_SHOOTING_RUN_SHAKE"
Config.ShootingShakeAmplitude = 0.5 -- Base intensity
Config.ShootingShakeSpeed = 1.0     -- Base speed

-- Skill System Settings
Config.MaxSkill = 100.0             -- Maximum skill percentage
Config.ShotsToLevel = 10            -- How many shots to gain [SkillGainPerLevel] percentage
Config.SkillGainPerLevel = 0.2      -- Percent gained every [ShotsToLevel] shots

-- Notification System
-- Options: "esx", "mythic", "vms", "ox"
Config.NotifySystem = "ox"

function SendNotification(msg, type)
    if Config.NotifySystem == "ox" then
        exports.ox_lib:notify({ title = "Shooting System", description = msg, type = type })
    elseif Config.NotifySystem == "esx" then
        ESX.ShowNotification(msg)
    elseif Config.NotifySystem == "mythic" then
        exports["mythic_notify"]:DoCustomHudText(type, msg)
    elseif Config.NotifySystem == "vms" then
        exports["vms_notify"]:Notification("SHOOTING", msg, 5000, "#ffcc00", "fa-gun")
    end
end