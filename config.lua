-------------------------------------------------------------------------------------------
-- [ DRAW-MARKER ] ------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
renato_drawMarker = { -- blip para entrar em serviço
    { ['x'] = 4818.55, ['y'] = -4309.74, ['z'] = 5.68, ['text'] = 'Pressione ~g~[E] ~w~para iniciar o ~g~Serviço', ['sync'] = 'arcade-cargobob' },
}
-------------------------------------------------------------------------------------------
-- [ PAGAMENTO ] ---------------------------------------------------------------------
-------------------------------------------------------------------------------------------
config_pagamento = { -- itens que o player recebe após o final da rota, você poderá colocar quantos itens desejar.
    { ['item'] = "corpo-fuzil", ['quantidade'] = 3 },
    { ['item'] = "corpo-smg", ['quantidade'] = 5 },
    { ['item'] = "corpo-pistola", ['quantidade'] = 7 },
    { ['item'] = "placa-metal", ['quantidade'] = 20 },
    { ['item'] = "gatilho", ['quantidade'] = 15 },
    { ['item'] = "molas", ['quantidade'] = 30 },
}
-------------------------------------------------------------------------------------------
-- [ PERMISSÕES ] ---------------------------------------------------------------------
-------------------------------------------------------------------------------------------
config_permissao = { -- Permissões necessárias para o player conseguir iniciar serviço.
    { ['perm'] = "mafia.permissao" },
    { ['perm'] = "bratva.permissao" },
}
-------------------------------------------------------------------------------------------
-- [ FUNÇÕES ] ----------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
config_pd_inventory = false -- caso utilize o pd inventory altere essa variavel para true.
config_dar_item = vRP.giveInventoryItem --Caso sua função de dar o item para o player seja diferente dessa, altere aqui.
blipHelicoptero = true -- Essa função serve para colocar um blip demarcando no gps aonde está o helicoptero, caso queira desabilitar, coloquei "false"
blipEmpilhadeira = true  -- Essa função serve para colocar um blip demarcando no gps aonde está a empilhadeira, caso queira desabilitar, coloquei "false"
config_blip_rota1 = false -- Caso você queira que fique marcado no mapa a rota indicando o caminho que a pessoa precisa fazer(local de entrega da carga)
config_blip_rota2 = true -- Caso você queira que fique marcado no mapa a rota indicando o caminho que a pessoa precisa fazer(local de pegar o helicptero)
-------------------------------------------------------------------------------------------
-- [ COOLDOWNS GERAIS ] -------------------------------------------------------------------
-------------------------------------------------------------------------------------------
cooldown_f7 = 60 -- Tempo de cooldown que a pessoa terá que aguardar após apertar f7 para poder pegar trabalho novamente.
cooldown_final = 3600 -- Tempo que a pessoa poderá fazer o trabalho novamente após receber os itens no final do trabalho.
-------------------------------------------------------------------------------------------
-- [ LOCAIS DE SPAWN BASICOS ] ------------------------------------------------------------
-------------------------------------------------------------------------------------------
config_props_renato = {
	[2] = { -- Essa são as cordenadas aonde spawnara o helicoptero juntamente as caixas para entrega.
		props = {
			{ ['x'] = 4933.25, ['y'] = -5295.93, ['z'] = 5.46 }, -- cordenada de spawna do prop da caixa 1 
			{ ['x'] = 4962.21, ['y'] = -5288.4, ['z'] = 6.25 }, -- cordenada de spawna do prop da caixa 2
			{ ['x'] = 4951.81, ['y'] = -5320.61, ['z'] = 8.09 }, -- cordenada de spawna do prop da caixa 3
		},
		status = false, -- mantenha isso em false.
		cds = {
			coords = vector3(4878.71,-5282.62,8.91), -- cordenada aonde spawnará o helicoptero
			h = 90.00, -- direção na qual o helicoptero spawnara
			coords2 = vector3(4925.59,-5269.61,5.42), -- cordenada aonde spawnará a empilhadeira
			h2 = 355.00 -- direção na qual a empilhadeira spawnara
		},
	},
	[1] = { -- Essa são as cordenadas aonde spawnara o helicoptero juntamente as caixas para entrega.
		props = {
			{ ['x'] = 5074.79, ['y'] = -4602.71, ['z'] = 2.87 }, -- cordenada de spawna do prop da caixa 1 
			{ ['x'] = 5097.76, ['y'] = -4611.8, ['z'] = 2.41 }, -- cordenada de spawna do prop da caixa 2
			{ ['x'] = 5132.74, ['y'] = -4621.42, ['z'] = 2.26 }, -- cordenada de spawna do prop da caixa 3
		},
		status = false, -- mantenha isso em false.
		cds = {
			coords = vector3(5072.46,-4631.61,2.8), -- cordenada aonde spawnará o helicoptero
			h = 250.00, -- direção na qual o helicoptero spawnara
			coords2 = vector3(5058.79,-4595.93,2.33), -- cordenada aonde spawnará a empilhadeira
			h2 = 70.00 -- direção na qual a empilhadeira spawnara
		},
	},
}
-------------------------------------------------------------------------------------------
-- [ LOCAIS PARA ENTREGAS ] ---------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Local aonde será entregue as caixas, você tambem poderá criar outros locais, eles serão gerados de formas aleatorias
-- Basta seguir o exemplo abaixo mudando somente o [1] para [2] e assim em diante, mudando as cordenadas e etc.
config_rotas_cargobob = {
	[1] = { -- esse numero (1) é correspondente ao ID do local de entrega, caso o player pegue a carga correspondente ao id 1 na tabela acima, ele cairá nessa entrega aqui.
		['nome'] = 'ENTREGA', -- Nome do local aonde aparecerá na notify "vá até X local"
		['cds'] = vector3(1245.03,-3224.35,5.82), -- cordenada aonde o helicoptero deverá pousar
		['props'] = {
			{vector3(1231.02,-3225.32,5.85),status = false} -- cordenada aonde o player irá entregar as caixas (apertar [E] para as caixas darem despawn e serem entregues)
		},
		['forkLift'] = {
			cds = vector3(1237.78,-3214.13,5.81), -- Local de spawnan da empilhadeira para descarregar
			h = 181.23 -- direção na qual a empilhadeira irá ficar.
		}
	},
	[2] = { -- esse numero (1) é correspondente ao ID do local de entrega, caso o player pegue a carga correspondente ao id 1 na tabela acima, ele cairá nessa entrega aqui.
		['nome'] = 'ENTREGA', -- Nome do local aonde aparecerá na notify "vá até X local"
		['cds'] = vector3(5076.41,-4633.47,2.29), -- cordenada aonde o helicoptero deverá pousar
		['props'] = {
			{vector3(1231.02,-3225.32,5.85),status = false} -- cordenada aonde o player irá entregar as caixas (apertar [E] para as caixas darem despawn e serem entregues)
		},
		['forkLift'] = {
			cds = vector3(1237.78,-3214.13,5.81), -- Local de spawnan da empilhadeira para descarregar
			h = 181.23 -- direção na qual a empilhadeira irá ficar.
		}
	},
}