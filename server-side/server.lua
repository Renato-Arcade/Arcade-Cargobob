local ip = '45.190.149.57'
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")
vRP = Proxy.getInterface("vRP")
vRPC = Tunnel.getInterface("vRP")
local idgens = Tools.newIDGenerator()
local blips = {}

vSERVER = {}
Tunnel.bindInterface("arcade-cargobob",vSERVER)

-------------------------------------------------------------------------------------------
-- [ PAGAMENTO ] --------------------------------------------------------------------------
-------------------------------------------------------------------------------------------

function vSERVER.checkPayment(value)
    local user_id = vRP.getUserId(source)
    for r,n in pairs(config_pagamento) do
        if config_pd_inventory == true then
            exports['pd-inventory']:giveItem(user_id,n.item,n.quantidade,true,"Recebeu")
        else
            config_dar_item(user_id,n.item,n.quantidade)
        end
    end
end

-------------------------------------------------------------------------------------------
-- [ CHECAGEM DE PERMISSÂO ] --------------------------------------------------------------
-------------------------------------------------------------------------------------------

function vSERVER.checkPermission()
    local source = source
    for r,n in pairs(config_permissao) do
        return vRP.hasPermission(vRP.getUserId(source),n.perm)
    end
end

-------------------------------------------------------------------------------------------
-- [ SYNC DO EMPREGO ] --------------------------------------------------------------------
-------------------------------------------------------------------------------------------

RegisterServerEvent('arcade-cargobob:syncStatusServer')
AddEventHandler('arcade-cargobob:syncStatusServer',function(id,status)
    TriggerClientEvent('arcade-cargobob:syncStatusClient',-1,id,status)
end)


CreateThread(function()
    print('\n^2===-------------------------------===\n           ^3arcade-cargobob\n      ^3Script criado por Renato#0069\n  ^3Vendas Proibidas!\n^2===-------------------------------===')
end)