function IsAnyDraftHorseWalking(vehicle)
    local harnessCount = GetNumDraftVehicleHarnessPed(GetEntityModel(vehicle))
    for i = 0, harnessCount - 1 do
        local horse = GetPedInDraftHarness(vehicle, i)
        if (DoesEntityExist(horse)) and (IsPedWalking(horse)) then
            return true
        end
    end

    return false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        
        local vehicles = GetGamePool("CVehicle")
        for _, vehicle in ipairs(vehicles) do
            if (
                IsDraftVehicle(vehicle)) and
                (IsVehicleStopped(vehicle)) and
                (not NetworkGetEntityIsNetworked(vehicle) or NetworkHasControlOfEntity(vehicle))
                and (IsAnyDraftHorseWalking(vehicle)
            ) then
                SetEntityAsMissionEntity(vehicle, true, true)
                DeleteVehicle(vehicle)
            end
        end
    end
end)