-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------

local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------

cRP = {}
Tunnel.bindInterface("al_wanted",cRP)
vCLIENT = Tunnel.getInterface("al_wanted")

-----------------------------------------------------------------------------------------------------------------------------------------
-- PREPARES 
-----------------------------------------------------------------------------------------------------------------------------------------

-- PREPARE PARA PEGAR TODAS AS INFOS NA DB.
vRP.prepare("al_wanted:getwanted", "SELECT * FROM al_wanted")

-- PREPARE PARA SETAR O ID DO PLAYER PROCURADO.
vRP.prepare("al_wanted:setwantedID", "UPDATE al_wanted SET id_wanted = @id_wanted")

-- PREPARE PARA SETAR O COOLDOWN.
vRP.prepare("al_wanted:setwantedCD", "UPDATE al_wanted SET cooldown = @cooldown")

-- PREPARE PARA SETAR O VALOR DA RECOMPENSA.
vRP.prepare("al_wanted:setwantedPRICE", "UPDATE al_wanted SET price = @price")

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------

function cRP.getWantedID() -- FUNÇÃO PARA PEGAR O ID DO PLAYER PROCURADO
	local rows = vRP.query("al_wanted:getwanted")
	if rows[1] then
		return rows[1].id_wanted
	end
end
function cRP.getWantedCD() -- FUNÇÃO PARA PEGAR O COOLDOWN
	local rows = vRP.query("al_wanted:getwanted")
	if rows[1] then
		return rows[1].cooldown
	end
end
function cRP.getWantedPRICE() -- FUNÇÃO PARA PEGAR O VALOR FA RECOMPENSA
	local rows = vRP.query("al_wanted:getwanted")
	if rows[1] then
		return rows[1].price
	end
end
function cRP.setWantedID(id_wanted) -- FUNÇÃO PARA SETAR O ID DO PLAYER PROCURADO
	vRP.execute("al_wanted:setwantedID", {
		id_wanted = id_wanted
	})
end
function cRP.setWantedCD(cooldown) -- FUNÇÃO PARA SETAR O ID DO PLAYER PROCURADO
	vRP.execute("al_wanted:setwantedCD", {
		cooldown = cooldown
	})
end
function cRP.setWantedCD(price) -- FUNÇÃO PARA SETAR O ID DO PLAYER PROCURADO
	vRP.execute("al_wanted:setwantedPRICE", {
		price = price
	})
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADS
-----------------------------------------------------------------------------------------------------------------------------------------


Citizen.CreateThread(function() -- THREAD DE COOLDOWN
    while true do
        local idwanted = cRP.getWantedID()
        local cdwanted = cRP.getWantedCD()
        if idwanted ~= 0 then
	        if cdwanted == 0 then
                cRP.setWantedID(0)
	        else
                local newcdwanted = cdwanted - 1
                cRP.setWantedCD(newcdwanted)
	        end
        end
	    Citizen.Wait(60000)
    end
end)


RegisterNetEvent("al_wanted:setwanted")
AddEventHandler("al_wanted:setwanted",function()
    local idwanted = cRP.getWantedID()
    local cdwanted = cRP.getWantedCD()
    local pricewanted = cRP.getWantedPRICE()

    if idwanted == 0 then



        local newwantedid = vRP.prompt(source,"ID do Jogador:","")
	    if newwantedid == "" then
	    	return
        elseif newwantedid < 20 then
            print("notify: você não pode colocar recompensa em um membro da staff.")

        end

        local newwantedprice = vRP.prompt(source,"Valor da recompensa (MIN 250K, MAX 2KK)","")
        if newwantedid == "" then
            return
        elseif newwantedprice < 250000 then
            print("notify: valor minimo é 250k.")    
        elseif newwantedprice > 2000000 then
            print("notify: valor maximo é 2kk.")    
        end

        if vRP.getUserIdentity(newwantedid) = nil then
            print("notify: jogador nao encontrado.") 
        else
            if newwantedprice < 2000000 then
                local requestwanted = vRP.request(source," Você quer por uma recomensa de "..newwantedprice.." na cabeça do jogador "..vRP.getUserIdentity(newwantedid).."?",30)		
                if requestwanted then
                    cRP.setwantedPRICE(newwantedprice)
                    cRP.setWantedCD(15)
                    cRP.setWantedID(newwantedid)
                    
                end
                
            else
                print("notify: valor de recompensa invalido.") 
                
            end
        end
    else 
        print("notify: já existe uma recomepnsa ativa")
    end


end)