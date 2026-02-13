local currentSkill = 0.0
local isAiming = false
local currentShakeIndex = 1
local shotCounter = 0
local isShootingShakeActive = false

-- Initialization
CreateThread(function()
    Wait(1000)
    TriggerServerEvent("recoil:server:requestSkill")
end)

RegisterNetEvent("recoil:client:updateSkill", function(skill)
    currentSkill = skill
end)

RegisterNetEvent("recoil:client:notifySkill", function(msg)
    SendNotification(msg, "info")
end)

-- Main Loop
CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()
        
        if IsPedArmed(ped, 4) then
            sleep = 0
            local aiming = IsControlPressed(0, 25) -- Right Click
            
            -- Handle Aiming Shake Toggle/Cycle
            if aiming and not isAiming then
                isAiming = true
                if Config.EnableAimShake then
                    -- Calculate reduction based on skill (0% skill = 1.0 intensity, 100% skill = 0.1 intensity)
                    local intensity = math.max(0.1, 1.0 - (currentSkill / 100))
                    
                    local shakeName = Config.AimShakes[currentShakeIndex]
                    ShakeGameplayCam(shakeName, intensity)
                    
                    -- Cycle index for next aim
                    currentShakeIndex = currentShakeIndex + 1
                    if currentShakeIndex > #Config.AimShakes then currentShakeIndex = 1 end
                end
            elseif not aiming and isAiming then
                isAiming = false
                StopGameplayCamShaking(true)
            end

            -- Handle Shooting Recoil
            if IsPedShooting(ped) then
                -- Only start the shake if it's not already active to prevent "restarting" the animation
                if not IsGameplayCamShaking() then
                    local intensity = math.max(0.1, Config.ShootingShakeAmplitude - (currentSkill / 200))
                    ShakeGameplayCam(Config.ShootingShake, intensity)
                    isShootingShakeActive = true
                end
                
                shotCounter = shotCounter + 1
                if shotCounter >= Config.ShotsToLevel then
                    shotCounter = 0
                    TriggerServerEvent("recoil:server:addSkill", Config.SkillGainPerLevel)
                    
                    -- 20% chance to show notification on level up to avoid spam
                    if math.random(1, 100) <= 20 then
                         SendNotification("Your aim feels steadier...", "success")
                    end
                end
            end

            -- If the player was shooting but stopped, and we aren't aiming, stop the shake
            if isShootingShakeActive and not IsPedShooting(ped) and not aiming then
                -- Small delay to let the last shake finish naturally
                SetTimeout(500, function()
                    if not IsPedShooting(ped) and not IsControlPressed(0, 25) then
                        StopGameplayCamShaking(true)
                        isShootingShakeActive = false
                    end
                end)
            end
        end
        
        Wait(sleep)
    end
end)