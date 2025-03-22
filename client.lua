---Return whether any draft horse is walking
---@param vehicle number
---@return boolean
function IsAnyDraftHorseWalking(vehicle)
    local harnessCount = GetNumDraftVehicleHarnessPed(GetEntityModel(vehicle))
    if (harnessCount > 0) then
        for i = 0, harnessCount - 1 do
            local horse = GetPedInDraftHarness(vehicle, i)
            if (not DoesEntityExist(horse)) then
                goto continue
            end

            local speed = select(3, GetPedCurrentMoveBlendRatio(horse))
            if (not IsMoveBlendRatioStill(speed)) then
                return true
            end

            ::continue::
        end
    end

    return false
end

---Return whether the draft vehicle is bugged
---@param vehicle number
---@return boolean
function IsDraftBugged(vehicle)
    return (IsVehicleStopped(vehicle) and IsAnyDraftHorseWalking(vehicle))
end

---Return whether the entity is controllable
---@param entity number
---@return boolean
function IsEntityControllable(entity)
    return (not NetworkGetEntityIsNetworked(entity) or NetworkHasControlOfEntity(entity))
end

---Delete a the ped in a vehicle seat
---@param vehicle number
---@param seat number
function DeletePedInVehicleSeat(vehicle, seat)
    local ped = GetPedInVehicleSeat(vehicle, seat)
    if (not DoesEntityExist(ped) or not IsEntityControllable(ped)) then return end
    SetEntityAsMissionEntity(ped, true, true)
    DeletePed(ped)
end

---Delete a vehicle and its passengers
---@param vehicle number
function DeleteVehicle_2(vehicle)
    -- Delete driver
    DeletePedInVehicleSeat(vehicle, -1)
                    
    local seatCount = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle))
    if (seatCount > 0) then
        -- Delete all passengers
        for i = 0, seatCount - 1 do
            DeletePedInVehicleSeat(vehicle, i)

            if (GetVehicleNumberOfPassengers(vehicle) == 0) then
                break
            end
        end
    end

    -- Delete vehicle
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(3000)
        
        local vehicles = GetGamePool("CVehicle")
        if (#vehicles == 0) then
            goto continue
        end

        for i = 1, #vehicles do
            local vehicle = vehicles[i]
            if (IsDraftVehicle(vehicle) and IsEntityControllable(vehicle) and IsDraftBugged(vehicle)) then
                DeleteVehicle_2(vehicle)
            end
        end

        ::continue::
    end
end)