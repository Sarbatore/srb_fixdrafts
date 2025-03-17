function IsAnyDraftHorseWalking(vehicle)
    local harnessCount = GetNumDraftVehicleHarnessPed(GetEntityModel(vehicle))
    if (harnessCount > 0) then
        for i = 0, harnessCount - 1 do
            local horse = GetPedInDraftHarness(vehicle, i)
            if (DoesEntityExist(horse)) and (IsPedWalking(horse)) then
                return true
            end
        end
    end

    return false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1500)
        
        local vehicles = GetGamePool("CVehicle")
        for _, vehicle in ipairs(vehicles) do
            if (
                IsDraftVehicle(vehicle) and
                IsVehicleStopped(vehicle) and
                (not NetworkGetEntityIsNetworked(vehicle) or NetworkHasControlOfEntity(vehicle))
                and IsAnyDraftHorseWalking(vehicle)
            ) then
                local seatCount = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle))
                if (seatCount > 0) then
                    for i = 0, seatCount - 1 do
                        local ped = GetPedInVehicleSeat(vehicle, i)
                        if (
                            DoesEntityExist(ped) and
                            (not NetworkGetEntityIsNetworked(vehicle) or NetworkHasControlOfEntity(vehicle))
                        ) then
                            SetEntityAsMissionEntity(ped, true, true)
                            DeletePed(ped)
                        end
                    end
                end

                SetEntityAsMissionEntity(vehicle, true, true)
                DeleteVehicle(vehicle)
            end
        end
    end
end)