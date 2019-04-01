by Kheire007 



ESX = nil

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)




local nbCours = 0
--CONFIGURATION--

local coursier = { x = -927.6099, y = -2936.8957, z = 12.96} --Configuration marker prise de service
local coursierfin = { x = -963.9396, y = -3006.5700, z = 12.96} --Configuration marker fin de service
local spawnfaggio = { x = -979.4713, y = -2996.9001, z = 12.96} --Configuration du point de spawn du faggio

local livpt = { --Configuration des points de livraisons (repris ceux de Maykellll1 / NetOut)
[1] = {name = "Sandy Airport",x = 1610.0618, y = 3224.3693 , z = 40.41},
[2] = {name ="Grape Seed Airport" ,x= 2066.7512, y=4775.6176,z = 41.08},
[3] = {name = "Airport International LS",x = -1318.3190, y = -2734.2819 , z = 14.05}
}

local blips = {
  {title="ColisPostal", colour=4, id=90, x = -927.6099, y = -2936.8957, z = 12.96}, --Configuration du point sur la carte
}

local coefflouze = 0.1 --Coeficient multiplicateur qui en fonction de la distance definit la paie

--INIT--

local isInJobCours = false
local livr = 0
local plateab = "POPJOBS"
local isToHouse = false
local isToCoursier = false
local paie = 0

local pourboire = 0
local posibilidad = 0
local px = 0
local py = 0
local pz = 0

--THREADS--

Citizen.CreateThread(function() --Thread d'ajout du point de la pizzeria sur la carte

  for _, info in pairs(blips) do

    info.blip = AddBlipForCoord(info.x, info.y, info.z)
    SetBlipSprite(info.blip, info.id)
    SetBlipDisplay(info.blip, 4)
    SetBlipScale(info.blip, 0.9)
    SetBlipColour(info.blip, info.colour)
    SetBlipAsShortRange(info.blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(info.title)
    EndTextCommandSetBlipName(info.blip)
  end

end)

Citizen.CreateThread(function() --Thread lancement + livraison depuis le marker vert
  while true do

    Citizen.Wait(0)

    if isInJobCours == false then

      DrawMarker(1,coursier.x,coursier.y,coursier.z, 0, 0, 0, 0, 0, 0, 1.5001, 1.5001, 0.6001,0,255,0, 200, 0, 0, 0, 0)

      if GetDistanceBetweenCoords(coursier.x, coursier.y, coursier.z, GetEntityCoords(GetPlayerPed(-1),true)) < 1.5 then
        HelpText("Appuyez sur ~INPUT_CONTEXT~ pour lancer la livraison de ~r~colis",0,1,0.5,0.8,0.6,255,255,255,255)

        if IsControlJustPressed(1,38) then
            notif = true
            isInJobCours = true
            isToHouse = true
            livr = math.random(1, 3)

            px = livpt[livr].x
            py = livpt[livr].y
            pz = livpt[livr].z
            distance = round(GetDistanceBetweenCoords(coursier.x, coursier.y, coursier.z, px,py,pz))
            paie = distance * coefflouze

            spawn_faggio()
            goliv(livpt,livr)
            nbCours = math.random(1, 3)

            TriggerServerEvent("coursier:itemadd", nbCours)
        end
      end
    end

    if isToHouse == true then

      destinol = livpt[livr].name

      while notif == true do

        TriggerEvent("pNotify:SendNotification", {
          text = "Direction : " ..destinol.. " pour livrer le colis",
          type = "info",
          queue = "global",
          timeout = 4000,
          layout = "bottomRight"
        })

        notif = false

        i = 1
      end

      DrawMarker(1,livpt[livr].x,livpt[livr].y,livpt[livr].z, 0, 0, 0, 0, 0, 0, 1.5001, 1.5001, 0.6001,0,255,0, 200, 0, 0, 0, 0)

      if GetDistanceBetweenCoords(px,py,pz, GetEntityCoords(GetPlayerPed(-1),true)) < 3 then
        HelpText("Appuyez sur ~INPUT_CONTEXT~ pour livrer le colis",0,1,0.5,0.8,0.6,255,255,255,255)

        if IsControlJustPressed(1,38) then

          notif2 = true
          posibilidad = math.random(1, 100)
          afaitunecoursmin = true

          TriggerServerEvent("coursier:itemrm")
          nbCours = nbCours - 1

          if (posibilidad > 70) and (posibilidad < 90) then

            pourboire = math.random(100, 200)

            TriggerEvent("pNotify:SendNotification", {
              text = "Un petit pourboire : " .. pourboire .. "$",
              type = "success",
              queue = "global",
              timeout = 4000,
              layout = "bottomRight"
            })

            TriggerServerEvent("coursier:pourboire", pourboire)

          end

          RemoveBlip(liv)
          Wait(250)
          if nbCours == 0 then
            isToHouse = false
            isToCoursier = true
          else
            isToHouse = true
            isToCoursier = false
            livr = math.random(1, 3)

            px = livpt[livr].x
            py = livpt[livr].y
            pz = livpt[livr].z

            distance = round(GetDistanceBetweenCoords(coursier.x, coursier.y, coursier.z, px,py,pz))
            paie = distance * coefflouze

            goliv(livpt,livr)
          end


        end
      end
    end

    if isToCoursier == true then

      while notif2 == true do
        SetNewWaypoint(coursier.x,coursier.y)

        TriggerEvent("pNotify:SendNotification", {
          text = "Direction dépot!",
          type = "info",
          queue = "global",
          timeout = 4000,
          layout = "bottomRight"
        })

        notif2 = false

      end
      DrawMarker(1,coursier.x,coursier.y,coursier.z, 0, 0, 0, 0, 0, 0, 1.5001, 1.5001, 0.6001,0,255,0, 200, 0, 0, 0, 0)

      if GetDistanceBetweenCoords(coursier.x,coursier.y,coursier.z, GetEntityCoords(GetPlayerPed(-1),true)) < 3 and afaitunecoursmin == true then
        HelpText("Appuyez sur ~INPUT_CONTEXT~ pour recuperer les colis",0,1,0.5,0.8,0.6,255,255,255,255)

        if IsVehicleModel(GetVehiclePedIsIn(GetPlayerPed(-1), true), GetHashKey("shamal"))  then

          if IsControlJustPressed(1,38) then

            if IsInVehicle() then

              afaitunecoursmin = false

              TriggerEvent("pNotify:SendNotification", {
                text = "Nous vous remercions de votre travail, voici votre paie : " .. paie .. "$",
                type = "success",
                queue = "global",
                timeout = 4000,
                layout = "bottomRight"
              })

              TriggerServerEvent("coursier:pourboire", paie)

              isInJobCours = true
              isToHouse = true
              livr = math.random(1, 3)

              px = livpt[livr].x
              py = livpt[livr].y
              pz = livpt[livr].z

              distance = round(GetDistanceBetweenCoords(coursier.x, coursier.y, coursier.z, px,py,pz))
              paie = distance * coefflouze

              goliv(livpt,livr)
              nbPizza = math.random(1, 6)

              TriggerServerEvent("coursier:itemadd", nbPizza)

            else

              notifmoto1 = true

              while notifmoto1 == true do

                TriggerEvent("pNotify:SendNotification", {
                  text = "Et le camion tu l'as oublié ?",
                  type = "error",
                  queue = "global",
                  timeout = 4000,
                  layout = "bottomRight"
                })

                notifmoto1 = false

              end
            end
          end
        else

          notifmoto2 = true

          while notifmoto2 == true do

            TriggerEvent("pNotify:SendNotification", {
              text = "Et le camion tu l'as oublié ?",
              type = "error",
              queue = "global",
              timeout = 4000,
              layout = "bottomRight"
            })

            notifmoto2 = false

          end
        end
      end
    end
    if IsEntityDead(GetPlayerPed(-1)) then

      isInJobCours = false
      livr = 0
      isToHouse = false
      isToCoursier = false

      paie = 0
      px = 0
      py = 0
      pz = 0
      RemoveBlip(liv)

    end
  end
end)



Citizen.CreateThread(function() -- Thread de "fin de service" depuis le point rouge
  while true do

    Citizen.Wait(0)

    if isInJobCours == true then

      DrawMarker(1,coursierfin.x,coursierfin.y,coursierfin.z, 0, 0, 0, 0, 0, 0, 1.5001, 1.5001, 0.6001,255,0,0, 200, 0, 0, 0, 0)

      if GetDistanceBetweenCoords(coursierfin.x, coursierfin.y, coursierfin.z, GetEntityCoords(GetPlayerPed(-1),true)) < 1.5 then
        HelpText("Appuyez sur ~INPUT_CONTEXT~ pour arreter la livraison de ~r~colis",0,1,0.5,0.8,0.6,255,255,255,255)

        if IsControlJustPressed(1,38) then
          TriggerServerEvent('coursier:deleteAllCours')
          isInJobCours = false
          livr = 0
          isToHouse = false
          isToCoursier = false

          paie = 0
          px = 0
          py = 0
          pz = 0

          if afaitunecoursmin == true then

            local vehicleu = GetVehiclePedIsIn(GetPlayerPed(-1), false)

            SetEntityAsMissionEntity( vehicleu, true, true )
            deleteCar( vehicleu )

            TriggerEvent("pNotify:SendNotification", {
              text = "Merci d'avoir travaillé, bonne journée",
              type = "success",
              queue = "global",
              timeout = 4000,
              layout = "bottomRight"
            })

            TriggerServerEvent("coursier:paiefinale")

            SetWaypointOff()

            afaitunecoursmin = false

          else

            local vehicleu = GetVehiclePedIsIn(GetPlayerPed(-1), false)

            SetEntityAsMissionEntity( vehicleu, true, true )
            deleteCar( vehicleu )

            TriggerEvent("pNotify:SendNotification", {
              text = "Merci quand même (pour rien), bonne journée",
              type = "error",
              queue = "global",
              timeout = 4000,
              layout = "bottomRight"
            })
          end
        end
      end
    end
  end
end)

--FONCTIONS--

function goliv(livpt,livr) -- Fonction d'ajout du point en fonction de la destination de livraison chosie
  liv = AddBlipForCoord(livpt[livr].x,livpt[livr].y, livpt[livr].z)
  SetBlipSprite(liv, 1)
  SetNewWaypoint(livpt[livr].x,livpt[livr].y)
end

function spawn_faggio() -- Thread spawn faggio

  Citizen.Wait(0)

  local myPed = GetPlayerPed(-1)
  local player = PlayerId()
  local vehicle = GetHashKey('shamal')

  RequestModel(vehicle)

  while not HasModelLoaded(vehicle) do
    Wait(1)
  end

  local plateJob = math.random(1000, 9999)
  local spawned_car = CreateVehicle(vehicle, spawnfaggio.x,spawnfaggio.y,spawnfaggio.z, -979.4713, -2996.9001, 12.96, true, false)

  local plate = "COURSIER"..plateJob

  SetVehicleNumberPlateText(spawned_car, plate)
  SetVehicleOnGroundProperly(spawned_car)
  SetVehicleLivery(spawned_car, 2)
  SetPedIntoVehicle(myPed, spawned_car, - 1)
  SetModelAsNoLongerNeeded(vehicle)

  Citizen.InvokeNative(0xB736A491E64A32CF, Citizen.PointerValueIntInitialized(spawned_car))
end

function round(num, numDecimalPlaces)
  local mult = 5^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function deleteCar( entity )
  Citizen.InvokeNative( 0xEA386986E786A54F, Citizen.PointerValueIntInitialized( entity ) ) --Native qui del le vehicule
end

function IsInVehicle() --Fonction de verification de la presence ou non en vehicule du joueur
  local ply = GetPlayerPed(-1)
  if IsPedSittingInAnyVehicle(ply) then
    return true
  else
    return false
  end
end

function HelpText(text, state) --Fonction qui permet de creer les "Help Text" (Type "Appuyez sur ...")
  SetTextComponentFormat("STRING")
  AddTextComponentString(text)
  DisplayHelpTextFromStringLabel(0, state, 0, -1)
end
