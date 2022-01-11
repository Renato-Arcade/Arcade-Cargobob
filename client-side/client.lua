local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vSERVER = Tunnel.getInterface("arcade-cargobob")

-------------------------------------------------------------------------------------------
-- [ VARIAVEIS ] --------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

Working = false
forklift = nil
cargobob3 = nil
props_renato = {}
prop1 = nil
prop2 = nil
prop3 = nil
prop4 = nil
blips = nil
carregado = false
DoorsOpen = false
chegarlocal = false
abrindoPorts = false
carregndoCaixas = false
fecharPortas = false
descrregando = false
prop1status = false
prop2status = false
prop3status = false
prop4status = false
retornando = false
idle = 1000
cooldown = 0
recebeu = ""

-------------------------------------------------------------------------------------------
-- [ FUNÇÃO DRAW MARKER] ------------------------------------------------------------------
-------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    while true do
        local ped = PlayerPedId()
        idle = 1000
        if Working == false then
            local cdsPed = GetEntityCoords(ped)
            for k,v in pairs(renato_drawMarker) do
                if Vdist(cdsPed,vector3(v.x,v.y,v.z)) <= 5.0 then
                    idle = 5
                    DrawText3D(v.x,v.y,v.z,v.text)
                    if Vdist(cdsPed,vector3(v.x,v.y,v.z)) <= 1.0 then
                        if IsControlJustPressed(0,38) and cooldown <= 0 and vSERVER.checkPermission() then
                            Working = true
                            TriggerEvent('stopWorking',v.sync)
                            TriggerEvent(v.sync)
                        elseif IsControlJustPressed(0,38) and cooldown > 0 and vSERVER.checkPermission() then
                            TriggerEvent('Notify','negado','Aguarde '..cooldown..' segundos.')
                        end
                    end
                end
            end
        end
        Citizen.Wait(idle)
    end
end)

-------------------------------------------------------------------------------------------
-- [ EVENTO SAIR DE SERVIÇO] --------------------------------------------------------------
-------------------------------------------------------------------------------------------

RegisterNetEvent('stopWorking')
AddEventHandler('stopWorking',function(sync)
    while Working do
        idle = 5
        drawTxt('PRESSIONE ~g~F7 ~w~PARA SAIR DE TRABALHO',2,0.23,0.93,0.40,255,255,255,180)
        if IsControlJustPressed(0,168) then
            Working = false
            RemoveBlip(blip)
            cooldown = cooldown_f7
            TriggerEvent('Notify','importante','Você saiu de serviço!')
            if sync == 'arcade-cargobob' then
                Fade(1000)
                if DoesEntityExist(forklift) then
                    TriggerServerEvent("trydeleteveh",VehToNet(forklift))
                end
                if DoesEntityExist(cargobob3) then
                    TriggerServerEvent("trydeleteveh",VehToNet(cargobob3))
                end
                for k,v in pairs(props_renato) do    
                    if DoesEntityExist(v) then
                        DetachEntity(v,false,false)
                        TriggerServerEvent("trydeleteobj",ObjToNet(v))
                    end               
                end
                if DoesEntityExist(prop1) then
                    TriggerServerEvent("trydeleteobj",ObjToNet(prop1))
                end
                if DoesEntityExist(prop2) then
                    TriggerServerEvent("trydeleteobj",ObjToNet(prop2))
                end
                if DoesEntityExist(prop3) then
                    TriggerServerEvent("trydeleteobj",ObjToNet(prop3))
                end
                abrindoPorts = false
                fecharPortas = false
                inRota = false
                forklift = nil
                cargobob3 = nil
                prop1 = nil
                prop2 = nil
                prop3 = nil
                prop4 = nil
                blips = nil
                Working = false
                fecharPortas = false
                descrregando = false
                prop1status = false
                prop2status = false
                prop3status = false
                prop4status = false
                renato_driver = false
                carregndoCaixas = false
                quantidade = 1
                closeRenato = false 
                DoorsOpen = false
                retornando = false
                chegarlocal = false
                return
            end
        end
        Citizen.Wait(idle)
    end
end)

-------------------------------------------------------------------------------------------
-- [ INICIAR SERVIÇO ] --------------------------------------------------------------------
-------------------------------------------------------------------------------------------

RegisterNetEvent('arcade-cargobob')
AddEventHandler('arcade-cargobob',function()
    local ped = PlayerPedId()
    RequestModel(GetHashKey('prop_boxpile_06a'))
    while not HasModelLoaded(GetHashKey('prop_boxpile_06a')) do
        Citizen.Wait(10)
    end
    Fade(1000)
    local id = FindID()
    if id == false then
        Working = false
        RemoveBlip(blips)
        DoScreenFadeOut(1000)
        renato_driver = false
        abrindoPorts = false
        carregndoCaixas = false
        fecharPortas = false
        inRota = false
        retornando = false
        chegarlocal = false
        Fade(1000)
        if DoesEntityExist(forklift) then
            TriggerServerEvent("trydeleteveh",VehToNet(forklift))
        end
        if DoesEntityExist(forklift2) then
            TriggerServerEvent("trydeleteveh",VehToNet(forklift2))
        end
        if DoesEntityExist(cargobob3) then
            TriggerServerEvent("trydeleteveh",VehToNet(cargobob3))
        end
        for k,v in pairs(props_renato) do    
            if DoesEntityExist(v) then
                DetachEntity(v,false,false)
                TriggerServerEvent("trydeleteobj",ObjToNet(v))
            end               
        end
        if DoesEntityExist(prop1) then
            TriggerServerEvent("trydeleteobj",ObjToNet(prop1))
        end
        if DoesEntityExist(prop2) then
            TriggerServerEvent("trydeleteobj",ObjToNet(prop2))
        end
        if DoesEntityExist(prop3) then
            TriggerServerEvent("trydeleteobj",ObjToNet(prop3))
        end
        DoScreenFadeIn(1000)
        TriggerEvent('Notify','negado','Estamos sem cargas disponiveis no momento.')
        return
    else
        TriggerEvent('Notify','importante','Você entrou em serviço!')
    end

-------------------------------------------------------------------------------------------
-- [ SYNC DO SERVIÇO     ] ----------------------------------------------------------------
-------------------------------------------------------------------------------------------

TriggerServerEvent('arcade-cargobob:syncStatusServer',id,true)

-------------------------------------------------------------------------------------------
-- [ SPAWN E FREEZE INICIAL ] -------------------------------------------------------------
-------------------------------------------------------------------------------------------

CriandoBlip2(config_props_renato[id].cds.coords.x,config_props_renato[id].cds.coords.y,config_props_renato[id].cds.coords.z)

-------------------------------------------------------------------------------------------
-- [ IR ATÉ O LOCAL ] ---------------------------------------------------------------------
-------------------------------------------------------------------------------------------

    chegarlocal = true
    while chegarlocal do
        local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
        local px,py,pz = config_props_renato[id].cds.coords.x,config_props_renato[id].cds.coords.y,config_props_renato[id].cds.coords.z
        if Vdist(x,y,z,px,py,pz) > 30.0 then
            drawTxt('Vá até a localização',4,0.5,0.93,0.50,255,255,255,180)
        end
        if Vdist(x,y,z,px,py,pz) <= 30.0 then
            Fade(1400)
            forklift = spawnVehicle('forklift',config_props_renato[id].cds.coords2.x,config_props_renato[id].cds.coords2.y,config_props_renato[id].cds.coords2.z,config_props_renato[id].cds.h2)
            cargobob3 = spawnVehicle('cargobob3',config_props_renato[id].cds.coords.x,config_props_renato[id].cds.coords.y,config_props_renato[id].cds.coords.z,config_props_renato[id].cds.h)
            FreezeEntityPosition(forklift,true)
            TriggerEvent("vrp_sound:source",'lock',0.5)
            for i=1,#config_props_renato[id].props do    
                table.insert(props_renato,CreateObject(GetHashKey('prop_boxpile_06a'), config_props_renato[id].props[i].x,config_props_renato[id].props[i].y,config_props_renato[id].props[i].z-0.965, true, true, true))
            end
            RemoveBlip(blips)
            abrindoPorts = true
            chegarlocal = false
        end
        Citizen.Wait(5)
    end

-------------------------------------------------------------------------------------------
-- [ ABRIR AS PORTAS ] --------------------------------------------------------------------
-------------------------------------------------------------------------------------------

    while abrindoPorts do
        local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
        local px,py,pz = table.unpack(GetOffsetFromEntityInWorldCoords(cargobob3, 0.0,-6.0,0.0))
        if not IsPedInAnyVehicle(ped) then
            idle = 5
            if Vdist(x,y,z,px,py,pz) > 3.0 then
                drawTxt('Abra as portas do ~g~helicoptero',4,0.5,0.93,0.50,255,255,255,180)
            end
            if Vdist(x,y,z,px,py,pz) <= 3.0 then
                DrawText3D(px,py,pz,'Pressione ~g~[E] ~w~para abrir as portas do helicoptero.')
                if IsControlJustPressed(0,38) and not IsPedInAnyVehicle(ped) then
                    DoorsOpen = true
                    SetVehicleDoorOpen(cargobob3, 3, false, false)
                    SetVehicleDoorOpen(cargobob3, 2, false, false)
                    abrindoPorts = false
                    carregndoCaixas = true
                end
            end
        else
            drawTxt('Saia do veículo',4,0.5,0.93,0.50,255,255,255,180)
        end
        Citizen.Wait(idle)
    end
    FreezeEntityPosition(forklift,false)

-------------------------------------------------------------------------------------------
-- [ COLOCAR AS CAIXAR NO HELICOPTERO ] ---------------------------------------------------
-------------------------------------------------------------------------------------------

    local quantidade = 1
    while carregndoCaixas do
        local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
        local px,py,pz = table.unpack(GetOffsetFromEntityInWorldCoords(cargobob3, 0.0,-8.0,0.0))
        for k,v in pairs(props_renato) do
            local ox,oy,oz = table.unpack(GetEntityCoords(v))
            local closeRenato = false
            if DoorsOpen then
                idle = 5
                if GetVehiclePedIsIn(ped,false) == forklift then
                    drawTxt('Carregue as ~g~caixas ~w~até o helicoptero',4,0.5,0.93,0.50,255,255,255,180)
                else
                    drawTxt('Entre na ~g~empilhadeira',4,0.5,0.93,0.50,255,255,255,180)
                end 
                if Vdist(ox,oy,oz,x,y,z) <= 25.0 and not closeRenato then
                    DrawMarker(21,ox,oy,oz+1.5,0,0,0,0.0,0,0,1.0,1.0,0.75,255,0,0,50,1,0,0,1)
                end
                if Vdist(ox,oy,oz,px,py,pz) <= 3.0 and Vdist(x,y,z,px,py,pz) <= 3.0 then
                    closeRenato = true
                    DrawText3D(ox,oy,oz+0.5,'Pressione ~g~[E] ~w~para colocar a caixa no helicoptero.')
                    if IsControlJustPressed(0,38) and GetVehiclePedIsIn(ped,false) == forklift then
                        if quantidade == 1 then
                            TriggerServerEvent("trydeleteobj",ObjToNet(v))
                            prop1 = CreateObject(GetHashKey('prop_boxpile_06a'),config_props_renato[id].cds.coords.x,config_props_renato[id].cds.coords.y,config_props_renato[id].cds.coords.z-30.00, true, true, true)
                            -- CreateObject(GetHashKey('prop_boxpile_06a'),x,y,z-0.965, true, true, true))
                            --AttachEntityToEntity(prop1,cargobob3,0.0,0.0,1.0,-0.80,0.0,0.0,0.0,false,false,true,false,2,true)
                            FreezeEntityPosition(prop1,true)
                            quantidade = quantidade +1
                            carregado = true
                        elseif quantidade == 2 then
                            TriggerServerEvent("trydeleteobj",ObjToNet(v))
                            prop2 = CreateObject(GetHashKey('prop_boxpile_06a'),config_props_renato[id].cds.coords.x,config_props_renato[id].cds.coords.y,config_props_renato[id].cds.coords.z-30.00, true, true, true)
                            --AttachEntityToEntity(prop2,cargobob3,0.0,0.0,-1.0,-0.80,0.0,0.0,0.0,false,false,true,false,2,true)
                            FreezeEntityPosition(prop2,true)
                            quantidade = quantidade +1
                        elseif quantidade == 3 then
                            TriggerServerEvent("trydeleteobj",ObjToNet(v))
                            prop3 = CreateObject(GetHashKey('prop_boxpile_06a'),config_props_renato[id].cds.coords.x,config_props_renato[id].cds.coords.y,config_props_renato[id].cds.coords.z-30.00, true, true, true)
                            --AttachEntityToEntity(prop3,cargobob3,0.0,0.0,-3.0,-0.80,0.0,0.0,0.0,false,false,true,false,2,true)
                            FreezeEntityPosition(prop3,true)
                            carregndoCaixas = false
                            fecharPortas = true
                        end
                    end
                end
            end
        end
        Citizen.Wait(idle)
    end
-------------------------------------------------------------------------------------------
-- [ FECHAR AS PORTAS ] -------------------------------------------------------------------
-------------------------------------------------------------------------------------------

    while fecharPortas do
        local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
        local px,py,pz = table.unpack(GetOffsetFromEntityInWorldCoords(cargobob3, 0.0,-6.0,0.0))
        if Vdist(x,y,z,px,py,pz) > 2.5 then
            drawTxt('Feche as portas do ~g~helicoptero',4,0.5,0.93,0.50,255,255,255,180)
        end
        if Vdist(x,y,z,px,py,pz) <= 2.5 then
            DrawText3D(px,py,pz,'Pressione ~g~[E] ~w~para fechar as portas do helicoptero.')
            if IsControlJustPressed(0,38) and not IsPedInAnyVehicle(ped) then
                DoorsOpen = false
                SetVehicleDoorShut(cargobob3, 3, false)
                SetVehicleDoorShut(cargobob3, 2, false)
                fecharPortas = false
                inRota = true
                --mathvalue = math.random(1,#config_rotas_cargobob)
                CriandoBlip(config_rotas_cargobob[id].cds.x,config_rotas_cargobob[id].cds.y,config_rotas_cargobob[id].cds.z)
                TriggerEvent('Notify','importante','Vá até <b>'..config_rotas_cargobob[id].nome,8000)
            end
        end
        Citizen.Wait(5)
    end

-------------------------------------------------------------------------------------------
-- [ SYNC DO EMPREGO ] --------------------------------------------------------------------
-------------------------------------------------------------------------------------------

    TriggerServerEvent('arcade-cargobob:syncStatusServer',id,false)
    TaskLeaveVehicle(ped,forklift,0)
    Citizen.Wait(500)
    if DoesEntityExist(forklift) then
        TriggerServerEvent("trydeleteveh",VehToNet(forklift))
    end

-------------------------------------------------------------------------------------------
-- [ INDO ATÉ O DESTINO ] -----------------------------------------------------------------
-------------------------------------------------------------------------------------------

    while inRota do
        if GetVehiclePedIsIn(ped,false) == cargobob3 then
            drawTxt('Vá até o ~g~destino',4,0.5,0.93,0.50,255,255,255,180)
            if Vdist(GetEntityCoords(PlayerPedId()),config_rotas_cargobob[id].cds) <= 10.0 then
                DrawText3D(config_rotas_cargobob[id].cds.x,config_rotas_cargobob[id].cds.y,config_rotas_cargobob[id].cds.z+0.8,'Pressione ~g~[E] ~w~para começar a entrega.')
                if Vdist(GetEntityCoords(PlayerPedId()),config_rotas_cargobob[id].cds) <= 10.0 then
                    if IsControlJustPressed(0,38) then
                        Fade(1000)
                        inRota = false
                        forklift2 = spawnVehicle('forklift',config_rotas_cargobob[id].forkLift.cds.x,config_rotas_cargobob[id].forkLift.cds.y,config_rotas_cargobob[id].forkLift.cds.z,config_rotas_cargobob[id].forkLift.h)
                        abrindoPorts = true
                    end
                end
            end
        else
            drawTxt('Entre no helicoptero',4,0.5,0.93,0.50,255,255,255,180)
        end 
        Citizen.Wait(5)
    end

-------------------------------------------------------------------------------------------
-- [ ABRIR AS PORTAS ] --------------------------------------------------------------------
-------------------------------------------------------------------------------------------

    while abrindoPorts do
        local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
        local px,py,pz = table.unpack(GetOffsetFromEntityInWorldCoords(cargobob3, 0.0,-6.0,0.0))
        if not IsPedInAnyVehicle(ped) then
            idle = 5
            if Vdist(x,y,z,px,py,pz) > 3.0 then
                drawTxt('Abra as portas do ~g~helicoptero',4,0.5,0.93,0.50,255,255,255,180)
            end
            if Vdist(x,y,z,px,py,pz) <= 3.0 then
                DrawText3D(px,py,pz,'Pressione ~g~[E] ~w~para abrir as portas do helicoptero.')
                if IsControlJustPressed(0,38) and not IsPedInAnyVehicle(ped) then
                    DoorsOpen = true
                    SetVehicleDoorOpen(cargobob3, 3, false, false)
                    SetVehicleDoorOpen(cargobob3, 2, false, false)
                    abrindoPorts = false
                    descrregando = true
                    caixaN = 3
                end
            end
        end
        Citizen.Wait(idle)
    end

-------------------------------------------------------------------------------------------
-- [ DESCARREGAR HELICOPTERO ] ------------------------------------------------------------
-------------------------------------------------------------------------------------------

    while descrregando do
        drawTxt('Entregue as caixas',4,0.5,0.93,0.50,255,255,255,180)
        local cdsP = GetOffsetFromEntityInWorldCoords(cargobob3,0,-8.5,0.0)
        local px,py,pz = table.unpack(GetOffsetFromEntityInWorldCoords(cargobob3, 0.0,-6.0,0.0))
        if Vdist(GetEntityCoords(PlayerPedId()),cdsP.x,cdsP.y,cdsP.z) <= 2.0 then
            idle = 5
            DrawText3D(px,py,pz,'Pressione ~g~[E] ~w~para descarregar a caixa.')
            if IsControlJustPressed(0,38) and not IsPedInAnyVehicle(ped) then
                if quantidade == 3 then
                    quantidade = quantidade-1
                    --DetachEntity(prop3,false,false)
                    SetEntityCoords(prop3,cdsP.x,cdsP.y,cdsP.z-1.3)
                    FreezeEntityPosition(prop3,false)
                elseif quantidade == 2 and caixaN == 2 then
                    quantidade = quantidade-1
                    --DetachEntity(prop2,false,false)
                    SetEntityCoords(prop2,cdsP.x,cdsP.y,cdsP.z-1.3)
                    FreezeEntityPosition(prop2,false)
                elseif quantidade == 1 and caixaN == 1 then
                    --DetachEntity(prop1,false,false)
                    SetEntityCoords(prop1,cdsP.x,cdsP.y,cdsP.z-1.3)
                    FreezeEntityPosition(prop1,false)
                    carregado = false
                end
            end
        end
        for i=1,#config_rotas_cargobob[id].props do
            idle = 5
            if Vdist(config_rotas_cargobob[id].props[i][1],GetEntityCoords(ped)) <= 20.0 then
                if config_rotas_cargobob[id].props[i].status == false then
                    DrawMarker(21,config_rotas_cargobob[id].props[i][1].x,config_rotas_cargobob[id].props[i][1].y,config_rotas_cargobob[id].props[i][1].z,0,0,0,0.0,0,0,1.0,1.0,0.75,255,0,0,50,1,0,0,1)
                end
            end
            if Vdist(config_rotas_cargobob[id].props[i][1],GetEntityCoords(prop3)) <= 2.0 or Vdist(config_rotas_cargobob[id].props[i][1],GetEntityCoords(prop2)) <= 1.0 or Vdist(config_rotas_cargobob[id].props[i][1],GetEntityCoords(prop1)) <= 1.0 then
                if IsControlJustPressed(0,38) then
                    if caixaN == 3 then
                        caixaN = caixaN - 1
                        TriggerServerEvent("trydeleteobj",ObjToNet(prop3))
                    elseif caixaN == 2 then
                        caixaN = caixaN - 1
                        TriggerServerEvent("trydeleteobj",ObjToNet(prop2))
                    elseif caixaN == 1 then
                        caixaN = caixaN - 1
                        TriggerServerEvent("trydeleteobj",ObjToNet(prop1))
                        config_rotas_cargobob[id].props[i].status = true
                        fecharPortas = true
                    end
                end
            end
        end
        if config_rotas_cargobob[id].props[1].status == true then
            descrregando = false
        end
        Citizen.Wait(idle)
    end
    RemoveBlip(blips)

-------------------------------------------------------------------------------------------
-- [ FECHAR AS PORTAS ] -------------------------------------------------------------------
-------------------------------------------------------------------------------------------

    while fecharPortas do
        local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
        local px,py,pz = table.unpack( GetOffsetFromEntityInWorldCoords(cargobob3, 0.0, -6.0, 0.0))
        if Vdist(x,y,z,px,py,pz) > 2.5 then
            drawTxt('Feche as portas do ~g~helicoptero',4,0.5,0.93,0.50,255,255,255,180)
        end
        if Vdist(x,y,z,px,py,pz) <= 2.5 then
            DrawText3D(px,py,pz,'Pressione ~g~[E] ~w~para fechar as portas do helicoptero.')
            if IsControlJustPressed(0,38) and not IsPedInAnyVehicle(ped) then
                DoorsOpen = false
                SetVehicleDoorShut(cargobob3, 3, false)
                SetVehicleDoorShut(cargobob3, 2, false)
                fecharPortas = false
                retornando = true
                CriandoBlip2(config_props_renato[id].cds.coords.x,config_props_renato[id].cds.coords.y,config_props_renato[id].cds.coords.z)
            end
        end
        Citizen.Wait(5)
    end
    TaskLeaveVehicle(ped,forklift2,0)
    Citizen.Wait(1000)
    if DoesEntityExist(forklift2) then
        TriggerServerEvent("trydeleteveh",VehToNet(forklift2))
    end
    if DoesEntityExist(prop1) then
        TriggerServerEvent("trydeleteobj",ObjToNet(prop1))
    end
    if DoesEntityExist(prop2) then
        TriggerServerEvent("trydeleteobj",ObjToNet(prop2))
    end
    if DoesEntityExist(prop3) then
        TriggerServerEvent("trydeleteobj",ObjToNet(prop3))
    end

-------------------------------------------------------------------------------------------
-- [ RETORNANDO / PAGAMENTO ] -------------------------------------------------------------
-------------------------------------------------------------------------------------------

    while retornando do
        if GetVehiclePedIsIn(ped,false) == cargobob3 then
            drawTxt('Leve o helicoptero até a localização',4,0.5,0.93,0.50,255,255,255,180)
        else
            drawTxt('Entre no helicoptero',4,0.5,0.93,0.50,255,255,255,180)
        end
        if Vdist(GetEntityCoords(ped),config_props_renato[id].cds.coords.x,config_props_renato[id].cds.coords.y,config_props_renato[id].cds.coords.z) <= 50.0 then
            DrawMarker(27,config_props_renato[id].cds.coords.x,config_props_renato[id].cds.coords.y,config_props_renato[id].cds.coords.z-0.9,0,0,0,0.0,0,0,10.0,10.0,0.3,255,0,0,50,0,0,0,1)
            if Vdist(GetEntityCoords(ped),config_props_renato[id].cds.coords.x,config_props_renato[id].cds.coords.y,config_props_renato[id].cds.coords.z) <= 2.5 then
                DrawText3D(config_props_renato[id].cds.coords.x,config_props_renato[id].cds.coords.y,config_props_renato[id].cds.coords.z+0.9,'Pressione ~r~[E] ~w~para finalizar o serviço.')
                if IsControlJustPressed(0,38) then
                    Working = false
                    RemoveBlip(blips)
                    DoScreenFadeOut(1000)
                    cooldown = cooldown_final
                    renato_driver = false
                    abrindoPorts = false
                    carregndoCaixas = false
                    fecharPortas = false
                    inRota = false
                    retornando = false
                    chegarlocal = false
                    Fade(1000)
                    if DoesEntityExist(forklift) then
                        TriggerServerEvent("trydeleteveh",VehToNet(forklift))
                    end
                    if DoesEntityExist(forklift2) then
                        TriggerServerEvent("trydeleteveh",VehToNet(forklift2))
                    end
                    if DoesEntityExist(cargobob3) then
                        TriggerServerEvent("trydeleteveh",VehToNet(cargobob3))
                    end
                    for k,v in pairs(props_renato) do    
                        if DoesEntityExist(v) then
                            DetachEntity(v,false,false)
                            TriggerServerEvent("trydeleteobj",ObjToNet(v))
                        end               
                    end
                    if DoesEntityExist(prop1) then
                        TriggerServerEvent("trydeleteobj",ObjToNet(prop1))
                    end
                    if DoesEntityExist(prop2) then
                        TriggerServerEvent("trydeleteobj",ObjToNet(prop2))
                    end
                    if DoesEntityExist(prop3) then
                        TriggerServerEvent("trydeleteobj",ObjToNet(prop3))
                    end
                    if DoesEntityExist(prop4) then
                        TriggerServerEvent("trydeleteobj",ObjToNet(prop4))
                    end
                    DoScreenFadeIn(1000)
                    TriggerEvent('Notify','importante','Você finalizou o serviço!')
                    vSERVER.checkPayment()
                    for r,n in pairs(config_pagamento) do
                        recebeu = recebeu ..  "<br><b>Item: </b>" .. n.item .. "<b> Quantidade: </b>" .. n.quantidade
                    end
                    recebeu = "<b>Recebeu:</b><br>"..recebeu
                    TriggerEvent('Notify','sucesso',recebeu,8000)
                end
            end
        end
        Citizen.Wait(5)
    end
end)

-------------------------------------------------------------------------------------------
-- [ SISTEMA DE COOLDOWN ] ----------------------------------------------------------------
-------------------------------------------------------------------------------------------

CreateThread( function()
	while true do
		if cooldown > 0 then
			cooldown = cooldown - 1
		end
		Wait(1000)
	end
end)


-------------------------------------------------------------------------------------------
-- [ FUNÇÕES GERAIS ] ---------------------------------------------------------------------
-------------------------------------------------------------------------------------------

function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

function createBlip(x,y,z,sprite,color,scale,text)
	blip = AddBlipForCoord(x,y,z)
	SetBlipSprite(blip,sprite)
	SetBlipColour(blip,color)
	SetBlipScale(blip,scale)
	SetBlipAsShortRange(blip,false)
	SetBlipRoute(blip,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blip)
end

function setBlipCoords(x,y,z)
    SetBlipCoords(blip,x,y,z)
	SetBlipRoute(blip,false)
	SetBlipRoute(blip,true)
end

function setBlipText(text)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blip)
end

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.3, 0.3)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.005+ factor, 0.03, 0, 0, 0,100)
end


function spawnVehicle(mhash,x,y,z,h)
    RequestModel(mhash)
    while not HasModelLoaded(mhash) do
        Citizen.Wait(10)
    end
    local ped = PlayerPedId()
    local nveh = CreateVehicle(mhash,x,y,z,h,true,false)
    SetVehicleIsStolen(nveh,false)
    SetVehicleOnGroundProperly(nveh)
    SetEntityInvincible(nveh,false)
    SetVehicleNumberPlateText(nveh,vRP.getRegistrationNumber())
    Citizen.InvokeNative(0xAD738C3085FE7E11,nveh,true,true)
    SetVehicleHasBeenOwnedByPlayer(nveh,true)
    SetVehicleDirtLevel(nveh,0.0)
    SetVehRadioStation(nveh,"OFF")
    SetModelAsNoLongerNeeded(mhash)
    SetVehicleDoorsLocked(nveh,false)
    if mhash == "cargobob3" and blipHelicoptero == true then
        targetBlip = AddBlipForEntity(nveh)
		SetBlipSprite(targetBlip,422)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("helicoptero")
		EndTextCommandSetBlipName(targetBlip)
    end

    if mhash == "forklift" and blipEmpilhadeira == true then
        targetBlip = AddBlipForEntity(nveh)
		SetBlipSprite(targetBlip,477)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("empilhadeira")
		EndTextCommandSetBlipName(targetBlip)
    end
    return nveh
end

function Fade(time)
    --FreezeEntityPosition(PlayerPedId(),true)
	DoScreenFadeOut(800)
	Wait(time)
	DoScreenFadeIn(800)
    --FreezeEntityPosition(PlayerPedId(),false)
end

function CriandoBlip(x,y,z)
	blips = AddBlipForCoord(x,y,z)
	SetBlipSprite(blips,12)
	SetBlipColour(blips,5)
	SetBlipScale(blips,0.9)
	SetBlipAsShortRange(blips,config_blip_rota1)
    SetBlipRoute(blips,false)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Destino")
	EndTextCommandSetBlipName(blips)
end

function CriandoBlip2(x,y,z)
	blips = AddBlipForCoord(x,y,z)
	SetBlipSprite(blips,12)
	SetBlipColour(blips,3)
	SetBlipScale(blips,0.9)
	SetBlipAsShortRange(blips,false)
    SetBlipRoute(blips,config_blip_rota2)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Destino")
	EndTextCommandSetBlipName(blips)
end

RegisterNetEvent('arcade-cargobob:syncStatusClient')
AddEventHandler('arcade-cargobob:syncStatusClient',function(id,status)
    config_props_renato[id].status = status
end)

function FindID()
    for i=1,#config_props_renato do
        if config_props_renato[i].status == false then
            return i
        end
    end
    return false
end