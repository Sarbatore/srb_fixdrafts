---Return whether any draft horse is walking
---@param vehicle number
---@return boolean
function IsAnyDraftHorseWalking(vehicle)
    local harnessCount = GetNumDraftVehicleHarnessPed(GetEntityModel(vehicle))
    if (harnessCount > 0) then
        for i = 0, harnessCount - 1 do
            local horse = GetPedInDraftHarness(vehicle, i)
            if (DoesEntityExist(horse)) then
                local speed = Absf(select(3, GetPedCurrentMoveBlendRatio(horse)))
                if (speed > 0.9) then
                    return true
                end
            end
        end
    end

    return false
end

function IsDraftVehicle(vehicle)
    return Citizen.InvokeNative(0xEA44E97849E9F3DD, vehicle)
end

---Return whether the draft vehicle is bugged
---@param vehicle number
---@return boolean
function IsDraftVehicleBugged(vehicle)
    return (IsVehicleStopped(vehicle) and IsAnyDraftHorseWalking(vehicle))
end

---Delete a the ped in a vehicle seat
---@param vehicle number
---@param seat number
function DeletePedInVehicleSeat(vehicle, seat)
    local ped = GetPedInVehicleSeat(vehicle, seat)
    if (DoesEntityExist(ped)) then
        NetworkRequestControlOfEntity(ped)
        SetEntityAsMissionEntity(ped, true, true)
        DeletePed(ped)
    end
end

---Delete a vehicle and its passengers
---@param vehicle number
function DeleteVehicle_2(vehicle)
    local seatCount = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle))
    if (seatCount > 0) then
        for i = 0, seatCount - 1 do
            DeletePedInVehicleSeat(vehicle, i)

            if (GetVehicleNumberOfPassengers(vehicle) == 0) then
                break
            end
        end
    end

    NetworkRequestControlOfEntity(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

CreateThread(function()
    while true do
        local itemSet = CreateItemset(true)
        local numVehicles = GetEntitiesNearPoint(GetEntityCoords(PlayerPedId()), 50.0, itemSet, 2, Citizen.ResultAsInteger())

        if (numVehicles > 0) then
            for i = 0, numVehicles - 1 do
                local itemsetItem = GetIndexedItemInItemset(i, itemSet)
                local vehicle = GetEntityFromItem(itemsetItem)

                if (DoesEntityExist(vehicle) and IsDraftVehicle(vehicle) and IsDraftVehicleBugged(vehicle)) then
                    DeleteVehicle_2(vehicle)
                end
            end
        end

        if (IsItemsetValid(itemSet)) then
            DestroyItemset(itemSet)
        end

        Wait(5000)
    end
end)