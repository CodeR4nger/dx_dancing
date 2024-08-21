local isDancing = false
local selectedDict = 1
local danceIntensity = 0
local isDisplayingText = true
local soloDanceDictionaries = {
    {dict = "ANIM@AMB@NIGHTCLUB@MINI@DANCE@DANCE_SOLO@FEMALE@VAR_A@"},
    {dict = "ANIM@AMB@NIGHTCLUB@MINI@DANCE@DANCE_SOLO@FEMALE@VAR_B@"},
    {dict = "ANIM@AMB@NIGHTCLUB@MINI@DANCE@DANCE_SOLO@MALE@VAR_B@"},
    {dict = "ANIM@AMB@NIGHTCLUB@MINI@DANCE@DANCE_SOLO@MALE@VAR_A@"},
    {dict = "ANIM@AMB@NIGHTCLUB@MINI@DANCE@DANCE_SOLO@JUMPER@"},
    {dict = "ANIM@AMB@NIGHTCLUB@MINI@DANCE@DANCE_SOLO@TECHNO_MONKEY@"},
    {dict = "ANIM@AMB@NIGHTCLUB@MINI@DANCE@DANCE_SOLO@SHUFFLE@"},
    {dict = "ANIM@AMB@NIGHTCLUB@MINI@DANCE@DANCE_SOLO@TECHNO_KARATE@"},
    {dict = "ANIM@AMB@NIGHTCLUB@MINI@DANCE@DANCE_SOLO@BEACH_BOXING@"},
    {dict = "ANIM@AMB@NIGHTCLUB@MINI@DANCE@DANCE_SOLO@SAND_TRIP@"},
    {dict = "anim@amb@casino@mini@dance@dance_solo@female@var_a@"},
    {dict = "anim@amb@casino@mini@dance@dance_solo@female@var_b@"},
}

local relaxAreas = {
    {
        points = {
            vector3(141.69,-643.65,27.75),
            vector3(136.56,-657.67,27.75),
            vector3(136.56,-657.67,27.75),
            vector3(130.53,-657.02,27.75),
            vector3(130.46,-657.00,27.75),
            vector3(125.47,-653.21,27.91),
            vector3(125.85,-645.74,27.75),
            vector3(130.16,-640.00,27.97),
            vector3(137.77,-640.54,27.75),
        },
        thickness = 4,
    },
}



local function dancingLoop()
    local selectedAnim = ''
    local lastAnim
    local lastDict = selectedDict
    local currentIntensity = 'low'
    local onBeatReward = 0
    local lastStyleSwitch = 0
    local animSwitch = 0
    local lastFacialAnim = ''
    lib.requestAnimDict(soloDanceDictionaries[selectedDict].dict,500)
    CreateThread(function() 
        local allLoaded = false
        local loaded = {}
        while not allLoaded do
            for k,v in pairs(soloDanceDictionaries) do
                if HasAnimDictLoaded(v.dict) then
                    loaded[k] = true
                else
                    RequestAnimDict(v.dict)
                end
            end
            allLoaded = true
            for i = 1,#loaded do
                if not loaded[i] then allLoaded = false end
            end
            Wait(0)
        end
    end)

    local currentBeatValue = 0
    local lastBeat = 0
    local lastClick = 0
    local lastMeter = 0.0
    local lastReduction = GetGameTimer()
    local intensities = {
        [0] = 'low',
        [1] = 'med',
        [2] = 'high'
    }
    local lastBuffCheck = GetGameTimer()
    local scaleform = RequestScaleformMovie('DANCER')
    while not HasScaleformMovieLoaded(scaleform) do 
        scaleform = RequestScaleformMovie('DANCER')
        Wait(0)
    end
    BeginScaleformMovieMethod(scaleform, "SET_IS_MOUSE_CONTROL")
    ScaleformMovieMethodAddParamBool(true)
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(scaleform, "SET_METER")
    ScaleformMovieMethodAddParamFloat(0.0)
    EndScaleformMovieMethod()
    BeginScaleformMovieMethod(scaleform, "SET_LEVEL")
    ScaleformMovieMethodAddParamInt(0)
    EndScaleformMovieMethod()
    CreateThread(function() 
        local meter = 0.0
        local meterLocal = 0.0
        while isDancing do
            if (lastMeter == 0.0 and meter >= 0.99) or (lastMeter >= 0.75 and meter <= 0.01) then
                if lastMeter == 0.0 then 
                    meter = 0.0
                else
                    meter = 1.0
                end
                meterLocal = lastMeter
            elseif lastMeter == 1.0 and meter <= 0.5 then
                meterLocal = 0.0
            elseif lastMeter == 0.0 and meter >= 0.5 then
                meterLocal = 1.0
            else 
                meterLocal = lastMeter
            end
            if math.abs(meterLocal - meter) > 0.01 then
                local mult = (meterLocal - meter) / math.abs(meterLocal - meter)
                meter = meter + (0.01 * mult)
                BeginScaleformMovieMethod(scaleform, "SET_METER")
                ScaleformMovieMethodAddParamFloat(meter)
                EndScaleformMovieMethod()
                if meter < 0.25 then
                    BeginScaleformMovieMethod(scaleform, "SET_METER_IS_RED")
                    ScaleformMovieMethodAddParamBool(true)
                    EndScaleformMovieMethod()
                else
                    BeginScaleformMovieMethod(scaleform, "SET_METER_IS_RED")
                    ScaleformMovieMethodAddParamBool(false)
                    EndScaleformMovieMethod()
                end
                Wait(10)
            end
            Wait(0)
        end
    end)
    CreateThread(function() 
        local menuText =  "[W/S/A/D] - Pasos de baile  \n [←/→] - Cambiar estilo de baile  \n [Click izquierdo] - Presiona al ritmo para   \nincrementar la intensidad  \n [Espacio] - Potenciar intensidad  \n [F] - Bajar intensidad  \n [Q/E] - Girar  \n [TAB] - Esconder controles  \n [Backspace] - Salir"
        while isDancing do
            if isDisplayingText and not lib.isTextUIOpen() then
                lib.showTextUI(menuText, {
                    position = 'right-center'
                })
            elseif not isDisplayingText and lib.isTextUIOpen() then
                lib.hideTextUI()
            end
            Wait(100)
        end
        lib.hideTextUI()
    end)
    while isDancing do
        DrawScaleformMovieFullscreen(scaleform,255,255,255,255,0)
        if (GetGameTimer() - lastBeat) > 500 then 
            CallScaleformMovieMethod(scaleform, "MUSIC_BEAT")
            lastBeat = GetGameTimer()
        end
        if IsControlJustPressed(0,24) or IsDisabledControlJustPressed(0,24) then
            CallScaleformMovieMethod(scaleform, "PULSE_ICON")
            BeginScaleformMovieMethod(scaleform, "FLASH_ICON")
            EndScaleformMovieMethod()
            if (GetGameTimer() - lastClick) > 300 and (GetGameTimer() - lastBeat) < 500 then
                BeginScaleformMovieMethod(scaleform, "PLAYER_BEAT")
                ScaleformMovieMethodAddParamBool(true)
                EndScaleformMovieMethod()
                onBeatReward += 1
                currentBeatValue = currentBeatValue + 1 
                if currentBeatValue >= 24 then currentBeatValue = 24 end
            else
                currentBeatValue = currentBeatValue - 1 
                if currentBeatValue <= 0 then currentBeatValue = 0 end
                BeginScaleformMovieMethod(scaleform, "PLAYER_BEAT")
                ScaleformMovieMethodAddParamBool(false)
                EndScaleformMovieMethod()
            end
            lastClick = GetGameTimer()
        end
        lastDict = selectedDict
        lastAnim = selectedAnim
        if (GetGameTimer() - lastReduction) > 1000 and (GetGameTimer() - lastClick) > 1000 then
            lastReduction = GetGameTimer()
            currentBeatValue = currentBeatValue - 1 
            if currentBeatValue <= 0 then currentBeatValue = 0 end
            BeginScaleformMovieMethod(scaleform, "PLAYER_BEAT")
            ScaleformMovieMethodAddParamBool(false)
            EndScaleformMovieMethod()
        end
        local intensityLevel = math.floor(currentBeatValue/8)
        if intensityLevel >= 0 and IsControlJustPressed(0,22) then
            lastClick = GetGameTimer()
            intensityLevel += 1
            currentBeatValue = 8 * (intensityLevel+1) - 1
            if currentBeatValue >= 24 then currentBeatValue = 24 end
        elseif intensityLevel >= 0 and IsControlJustPressed(0,23) then
            lastClick = GetGameTimer()
            intensityLevel -= 1
            if intensityLevel < 0 then intensityLevel = 0 end
            if intensityLevel == 0 then 
                currentBeatValue = 0 
            else
                currentBeatValue = 8 * (intensityLevel+1) - 1
            end
            if intensityLevel <= 0 then currentBeatValue = 0 end
        end 
        if intensityLevel > 2 then intensityLevel = 2 end
        currentIntensity = intensities[intensityLevel]
        if currentBeatValue > 0 then intensityLevel += 1 end
        local displayLevel = intensityLevel
        local meter
        if currentBeatValue >= 24 then
            meter = 1.0
        elseif currentBeatValue > 0 then
            meter = (currentBeatValue%8) / 8   
        else
            meter = 0.0
        end
        if meter > 1.0 then meter = 1.0 end
        lastMeter = meter
        BeginScaleformMovieMethod(scaleform, "SET_LEVEL")
        ScaleformMovieMethodAddParamInt(displayLevel)
        EndScaleformMovieMethod()
        selectedAnim = currentIntensity
        facialAnim = 'mood_dancing_'..(currentIntensity == 'med' and 'medium' or currentIntensity)
        if IsControlJustPressed(0,174) and (GetGameTimer() - lastStyleSwitch) > 500 then
            lastStyleSwitch = GetGameTimer()
            selectedDict = selectedDict - 1
            if selectedDict <= 0 then
                selectedDict = #soloDanceDictionaries
            end
        elseif IsControlJustPressed(0,175) and (GetGameTimer() - lastStyleSwitch) > 500 then
            lastStyleSwitch = GetGameTimer()
            selectedDict = selectedDict + 1
            if selectedDict > #soloDanceDictionaries then
                selectedDict = 1
            end
        end
        if IsControlPressed(0,38) then
            local pHeading = GetEntityHeading(cache.ped)
            SetEntityHeading(cache.ped,pHeading - 0.2)
        elseif IsControlPressed(0,44) then
            local pHeading = GetEntityHeading(cache.ped)
            SetEntityHeading(cache.ped,pHeading + 0.2)
        end
        if IsControlPressed(0,34) then
            selectedAnim = selectedAnim..'_left'
        elseif IsControlPressed(0,35) then
            selectedAnim = selectedAnim..'_right'
        else
            selectedAnim = selectedAnim..'_center'
        end
        if IsControlPressed(0,32) then
            selectedAnim = selectedAnim..'_up'
        elseif IsControlPressed(0,33) then
            selectedAnim = selectedAnim..'_down'
        end
        if IsControlPressed(0,177) then
            isDancing = false
        end
        if IsControlJustPressed(0,37) or IsDisabledControlJustPressed(0,37) then
            isDisplayingText = not isDisplayingText
        end
        if not IsEntityPlayingAnim(cache.ped,soloDanceDictionaries[selectedDict].dict,selectedAnim,3) then 
            if (GetGameTimer() - animSwitch) > 500 then
                animSwitch = GetGameTimer()
                TaskPlayAnim(cache.ped,soloDanceDictionaries[selectedDict].dict,selectedAnim,2.0,2.0,-1,1)
            end
        end
        if (GetGameTimer() - lastBuffCheck) > 30*1000 then
            lastBuffCheck = GetGameTimer()
            if onBeatReward >= 30 then
                local pCoords = GetEntityCoords(cache.ped)
                for i = 1,#relaxAreas do
                    if relaxAreas[i].zone:contains(pCoords) then
                        lib.notify({
                            description = 'Te sientes relajado al bailar al ritmo de la música',
                            type = 'inform'
                        })
                        TriggerServerEvent('hud:server:RelieveStress', math.random(7,11))
                        break
                    end
                end
            end
            onBeatReward = 0
        end
        if lastFacialAnim ~= facialAnim then
            lastFacialAnim = facialAnim
            local maxValue = currentIntensity == 'high' and 2 or 3
            local playFaceAnim = facialAnim..'_'..tostring(math.random(1,maxValue))
            SetFacialIdleAnimOverride(cache.ped,playFaceAnim)
        end
        Wait(0)
    end
    ClearFacialIdleAnimOverride(cache.ped)
    ClearPedTasks(cache.ped)
    for k,v in pairs(soloDanceDictionaries) do
        RemoveAnimDict(v.dict)
    end
end



local function dance()
    if not isDancing then 
        isDancing = true
        dancingLoop()
    else
        isDancing = false
    end
end

local function createDanceAreas()
    for k,v in pairs(relaxAreas) do
        local zoneData = relaxAreas[k]
        relaxAreas[k].zone = lib.zones.poly({
            points = zoneData.points,
            thickness = zoneData.thickness,
            debug = false,
            onEnter = function()
                lib.showTextUI('[Mantener E] - Bailar')
                CreateThread(function() 
                    Wait(3000)
                    lib.hideTextUI()
                end)
            end,
            inside = function()
                if IsControlPressed(0,38) then
                    Wait(1000)
                    if IsControlPressed(0,38) then
                        lib.hideTextUI()
                        dance()
                    end
                end
            end,
            onExit = function()
                lib.hideTextUI()
            end,
        })
    end

end
CreateThread(createDanceAreas)


RegisterCommand('dance',dance)