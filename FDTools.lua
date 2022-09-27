--[[
    [используемые стили]:

    [используемые библиотке]:
        imgui:
        samp events:
        inicfg:
        fAwesome5:
        vkeys\rkeys:

]]

script_name('FDTools')
script_author('Mico')
script_description('Удобный помощник для FullDostup-a')
script_version('3.6.1')

require('moonloader')
require('sampfuncs')
local encoding          = require "encoding"
encoding.default        = "CP1251"
u8                      = encoding.UTF8 
local imgui             = require 'imgui'
local inicfg            = require 'inicfg'
local vkeys             = require 'vkeys'
local rkeys             = require 'rkeys'
local fa                = require 'fAwesome5'
local memory            = require 'memory'
local hook = require("lib.samp.events")
local bNotf, notf       = pcall(import, "imgui_notf.lua")
local fa_glyph_ranges   = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local sw, sh            = getScreenResolution()
local main_window       = imgui.ImBool(false)
local main_give           = imgui.ImBool(false)
local updates           = imgui.ImBool(false)
local prefix_id         = imgui.ImBuffer(256)
local cmdid         = imgui.ImBuffer(256)
local prefix_name         = imgui.ImBuffer(256)
local prefix         = imgui.ImBuffer(256)
local promo_name        = imgui.ImBuffer(256)
local id_give_stat        = imgui.ImBuffer(256)
local statscol        = imgui.ImBuffer(256)
local combo_prefix_mafia      = imgui.ImInt(0)
local combo_prefix_ghetto      = imgui.ImInt(0)
local combo_prefix_goss      = imgui.ImInt(0)
local combo_prefix_ved      = imgui.ImInt(0)
local combo_prefix_ruk      = imgui.ImInt(0)
local rub                   = imgui.ImInt(1)
local use                   = imgui.ImInt(1)
local combo_permission      = imgui.ImInt(0)
local time                  = imgui.ImInt(1)
local nick_cmd              = imgui.ImBuffer(256)
local id_cmd              = imgui.ImBuffer(256)
local combo_cmd             = imgui.ImInt(0)
local id_stats              = imgui.ImBuffer(256)
local number_s              = imgui.ImBuffer(256)
local combo_stats      = imgui.ImInt(1)
local main_color = 0x1E90FF
local tag = "{1E90FF}>> [FDHelper] "

local ini = inicfg.load({
    config = {
        theme = 1,
        position = 0,
        hotkey = 'F4'
    }
}, 'fdtools.ini')
inicfg.save(ini, 'fdtools.ini')

local perm = {
    u8'Игроки',
    u8'Администраторы'
}
local commands = {
    u8'makeadmin',
    u8'makeleader',
    u8'makehelper',
    u8'offleader',
    u8'offhelper',
    u8'gzcolor',
    u8'ghetto',
    u8'banip',
    u8'avig',
    u8'aunvig'
}

local stats_item = {
    u8'Отсутствует',
    u8'Уровень',
    u8'Законка',
    u8'Материаллы',
    u8'Скин',
    u8'Убийства',
    u8'Номер телефона',
    u8'Опыт',
    u8'Ключ от дома',
    u8'Бизнес',
    u8'Уровень VIP',
    u8'Работа игрока',
    u8'Аптечки',
    u8'Деньги в банке',
    u8'Мобильный',
    u8'Деньги',
    u8'Варны',
    u8'Аптечки',
    u8'Организация',
    u8'Скилл Бокса',
    u8'Время бокса',
    u8'Бокс',
    u8'Конг-Фу',
    u8'Кикбокс',
    u8'Уважение',
    u8'Бег',
    u8'1 слот',
    u8'2 слот',
    u8'3 слот',
    u8'4 слот',
    u8'5 слот',
    u8'Наркозависимость (опыт)',
    u8'Фракционный скин',
    u8'Муж или Жена',
    u8'Процы',
    u8'Время банка',
    u8'Доступ к /ban',
    u8'Доступ к /warn'
}

local gossprefix = {
    u8'Goss | Главный следящий',
    u8'Goss | Заместитель ГС',
    u8'Goss | Помощник ГС'
}

local ghettoprefix = {
    u8'Ghetto | Главный следящий',
    u8'Ghetto | Заместитель ГС',
    u8'Ghetto | Помощник ГС'
}

local mafiaprefix = {
    u8'Mafia | Главный следящий',
    u8'Mafia | Заместитель ГС',
    u8'Mafia | Помощник ГС'
}

local vedprefix = {
    u8'Заместитель ГА',
    u8'Главный Администратор',
    u8'Заместитель Руководителя',
    u8'Руководитель Сервера',
    u8'Заместитель Куратора',
    u8'Куратор Сервера',
    u8'Технический Администратор'
}

local rukprefix = {
    u8'Помощник Основателя',
    u8'Заместитель Основателя',
    u8'И.О. Основателя',
    u8'Основатель Сервера',
    u8'Владелец Сервера'
}
local tHotKeyData = {
	edit 							= nil,
	save 							= {},
	lasted 							= os.clock(),
}

function main()
    if not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end
    autoupdate("https://raw.githubusercontent.com/MicoExp/fdtools/main/tools.json", '['..string.upper(thisScript().name)..']: ', "")

    sampRegisterChatCommand('givecmd', fullcmd)
    style()
    sampRegisterChatCommand('fdtools', cmdfd)
    sampAddChatMessage(tag..'{FFFFFF}Активация помощника: {1E90FF}/fdtools', main_color)
    sampRegisterChatCommand('fdgive', givefd)

    while true do
        imgui.ShowCursor = main_window.v or main_give.v or updates.v
        imgui.Process = main_window.v or main_give.v or updates.v
        wait(0)
        _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
		nick = sampGetPlayerNickname(id)

        if main_window.v == false then
            imgui.Process = false
            imgui.ShowCursor = false
        end
        if main_give.v == false then
            imgui.Process = false
            imgui.ShowCursor = false
        end

        if updates.v == false then
            imgui.Process = false
            imgui.ShowCursor = false
        end

        if isKeysDown(ini.config.hotkey) and (os.clock() - tHotKeyData.lasted > 0.1) and not sampIsChatInputActive() then
			cmdfd()
		end
    end
end
function isKeysDown(keylist, pressed)
	if keylist == nil then return end
	keylist = (string.find(keylist, '.+ %p .+') and {keylist:match('(.+) %p .+'), keylist:match('.+ %p (.+)')} or {keylist})
	local tKeys = keylist
	if pressed == nil then
		pressed = false
	end
	if tKeys[1] == nil then
		return false
	end
	local bool = false
	local key = #tKeys < 2 and tKeys[1] or tKeys[2]
	local modified = tKeys[1]
	if #tKeys < 2 then
		if wasKeyPressed(vkeys.name_to_id(key, true)) and not pressed then
			bool = true
		elseif isKeyDown(vkeys.name_to_id(key, true)) and pressed then
			bool = true
		end
	else
		if isKeyDown(vkeys.name_to_id(modified,true)) and not wasKeyReleased(vkeys.name_to_id(modified, true)) then
			if wasKeyPressed(vkeys.name_to_id(key, true)) and not pressed then
				bool = true
			elseif isKeyDown(vkeys.name_to_id(key, true)) and pressed then
				bool = true
			end
		end
	end
	if nextLockKey == keylist then
		if pressed and not wasKeyReleased(vkeys.name_to_id(key, true)) then
			bool = false
		else
			bool = false
			nextLockKey = ''
		end
	end
	return bool
end
function hook.onShowDialog(dialogId, style, title, button1, button2, text)
	if parsim and dialogId == 228 and title:find("Статистика администратора") then -- как и говорил, хер знает почему, но половина диалогов на РРП с идом 228, по-этому делаем дополнительную через тайтл
		for line in text:gmatch("[^\r\n]+") do -- парсим каждую строку
			if line:find("%{FFFFFF%}Административный уровень:%s+%{dfb519%}%d+") then -- проверяем строку на нужный нам текст
				adm_level = line:match("%{FFFFFF%}Административный уровень:%s+%{dfb519%}(%d+)") -- всю эту бадулу выводим в переменную, чтобы потом использовать можно было её
			end
		end
		for line in text:gmatch("[^\r\n]+") do -- парсим каждую строку
			if line:find("%{FFFFFF%}Выговоров:%s+%{dfb519%}%d+ из 3") then -- проверяем строку на нужный нам текст
				adm_vig = line:match("%{FFFFFF%}Выговоров:%s+%{dfb519%}(%d+) из 3") -- всю эту бадулу выводим в переменную, чтобы потом использовать можно было её
			end
		end
		for line in text:gmatch("[^\r\n]+") do -- парсим каждую строку
			if line:find("%{FFFFFF%}В сети за сегодня:%s+%{dfb519%}%d+ час. %d+ мин") then -- проверяем строку на нужный нам текст
				adm_onl_seg1, adm_onl_seg2 = line:match("%{FFFFFF%}В сети за сегодня:%s+%{dfb519%}(%d+) час. (%d+) мин") -- всю эту бадулу выводим в переменную, чтобы потом использовать можно было её
			end
		end
		for line in text:gmatch("[^\r\n]+") do -- парсим каждую строку
			if line:find("%{FFFFFF%}В сети за вчера:%s+%{dfb519%}%d+ час. %d+ мин") then -- проверяем строку на нужный нам текст
				adm_onl_v1, adm_onl_v2 = line:match("%{FFFFFF%}В сети за вчера:%s+%{dfb519%}(%d+) час. (%d+) мин") -- всю эту бадулу выводим в переменную, чтобы потом использовать можно было её
			end
		end
		for line in text:gmatch("[^\r\n]+") do -- парсим каждую строку
			if line:find("%{FFFFFF%}Ответов на репорт:%s+%{dfb519%}%d+") then -- проверяем строку на нужный нам текст
				adm_rep = line:match("%{FFFFFF%}Ответов на репорт:%s+%{dfb519%}(%d+)") -- всю эту бадулу выводим в переменную, чтобы потом использовать можно было её
			end
		end
		for line in text:gmatch("[^\r\n]+") do -- парсим каждую строку
			if line:find("%{FFFFFF%}Кикнуто:%s+%{dfb519%}%d+") then -- проверяем строку на нужный нам текст
				adm_kick = line:match("%{FFFFFF%}Кикнуто:%s+%{dfb519%}(%d+)") -- всю эту бадулу выводим в переменную, чтобы потом использовать можно было её
			end
		end
		for line in text:gmatch("[^\r\n]+") do -- парсим каждую строку
			if line:find("%{FFFFFF%}Заварнено:%s+%{dfb519%}%d+") then -- проверяем строку на нужный нам текст
				adm_warn = line:match("%{FFFFFF%}Заварнено:%s+%{dfb519%}(%d+)") -- всю эту бадулу выводим в переменную, чтобы потом использовать можно было её
			end
		end
		for line in text:gmatch("[^\r\n]+") do -- парсим каждую строку
			if line:find("%{FFFFFF%}Забанено:%s+%{dfb519%}%d+") then -- проверяем строку на нужный нам текст
				adm_ban = line:match("%{FFFFFF%}Забанено:%s+%{dfb519%}(%d+)") -- всю эту бадулу выводим в переменную, чтобы потом использовать можно было её
			end
		end
		for line in text:gmatch("[^\r\n]+") do -- парсим каждую строку
			if line:find("%{FFFFFF%}Выдача мута:%s+%{dfb519%}%d+") then -- проверяем строку на нужный нам текст
				adm_mute = line:match("%{FFFFFF%}Выдача мута:%s+%{dfb519%}(%d+)") -- всю эту бадулу выводим в переменную, чтобы потом использовать можно было её
			end
		end
		for line in text:gmatch("[^\r\n]+") do -- парсим каждую строку
			if line:find("%{FFFFFF%}Посажено в тюрьму:%s+%{dfb519%}%d+") then -- проверяем строку на нужный нам текст
				adm_jail = line:match("%{FFFFFF%}Посажено в тюрьму:%s+%{dfb519%}(%d+)") -- всю эту бадулу выводим в переменную, чтобы потом использовать можно было её
			end
		end
		parsim = false
		return false -- не показываем этот самый диалог пользователю, ибо нахер он ему нужен
	end
end

function fullcmd()
    lua_thread.create(function()
        sampSendChat("/setcmd "..nick.." /makeadmin 1")
        wait(1000)
        sampSendChat("/setcmd "..nick.." /makeleader 1")
        wait(1000)
        sampSendChat("/setcmd "..nick.." /offleader 1")
        wait(1000)
        sampSendChat("/setcmd "..nick.." /makehelper 1")
        wait(1000)
        sampSendChat("/setcmd "..nick.." /offhelper 1")
        wait(1000)
        sampSendChat("/setcmd "..nick.." /ghetto 1")
        wait(1000)
        sampSendChat("/setcmd "..nick.." /gzcolor 1")
        wait(1000)
        sampSendChat("/setcmd "..nick.." /avig 1")
        wait(1000)
        sampSendChat("/setcmd "..nick.." /aunvig 1")
        wait(1000)
        sampSendChat("/setcmd "..nick.." /banip 1")
        wait(1000)
        sampSendChat("/setstat "..id.." 36 1")
        wait(1000)
        sampSendChat("/setstat "..id.." 37 1")
        wait(1000)
        sampAddChatMessage(tag.."{FFFFFF}вам были выданы все команды!", main_color)
    end)
end
function string.split(inputstr, sep)
	if sep == nil then
		sep = '%s'
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, '([^'..sep..']+)') do
		t[i] = str
		i = i + 1
	end
	return t
end
function getDownKeys()
	local curkeys = ''
	local bool = false
	for k, v in pairs(vkeys) do
		if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT) then
			if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then
				curkeys = v
			end
		end
	end
	for k, v in pairs(vkeys) do
		if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT) then
			if string.len(tostring(curkeys)) == 0 then
				curkeys = v
				return curkeys,true
			else
				curkeys = curkeys .. ' ' .. v
				return curkeys,true
			end
			bool = false
		end
	end
	return curkeys, bool
end

function imgui.GetKeysName(keys)
	if type(keys) ~= 'table' then
	   	return false
	else
	  	local tKeysName = {}
	  	for k = 1, #keys do
			tKeysName[k] = vkeys.id_to_name(tonumber(keys[k]))
	  	end
	  	return tKeysName
	end
end
function imgui.HotKey(name, path, pointer, defaultKey, width)
	local width = width or 90
	local cancel = isKeyDown(0x08)
	local tKeys, saveKeys = string.split(getDownKeys(), ' '),select(2,getDownKeys())
	local name = tostring(name)
	local keys, bool = path[pointer] or defaultKey, false

	local sKeys = keys
	for i=0,2 do
		if imgui.IsMouseClicked(i) then
			tKeys = {i==2 and 4 or i+1}
			saveKeys = true
		end
	end

	if tHotKeyData.edit ~= nil and tostring(tHotKeyData.edit) == name then
		if not cancel then
			if not saveKeys then
				if #tKeys == 0 then
					sKeys = (math.ceil(imgui.GetTime()) % 2 == 0) and '______' or ' '
				else
					sKeys = table.concat(imgui.GetKeysName(tKeys), ' + ')
				end
			else
				path[pointer] = table.concat(imgui.GetKeysName(tKeys), ' + ')
				tHotKeyData.edit = nil
				tHotKeyData.lasted = os.clock()
				inicfg.save(ini, 'fdtools')
			end
		else
			path[pointer] = defaultKey
			tHotKeyData.edit = nil
			tHotKeyData.lasted = os.clock()
			inicfg.save(ini, 'fdtools')
		end
	end

	imgui.PushStyleColor(imgui.Col.Button, imgui.GetStyle().Colors[imgui.Col.FrameBg])
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.GetStyle().Colors[imgui.Col.FrameBgHovered])
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.GetStyle().Colors[imgui.Col.FrameBgActive])
	if imgui.Button((sKeys ~= '' and sKeys or u8'Свободно') .. '## '..name, imgui.ImVec2(width, 0)) then
		tHotKeyData.edit = name
	end
	imgui.PopStyleColor(3)
	return bool
end
function cmdfd(args)
    lua_thread.create(function()
        sampSendChat("/astats") -- отправляем серверу /astats
        parsim = true
        wait(1)
        main_window.v = true
    end)
end

function givefd(args)
    playerId = args
    main_give.v = true
    playerId = playerId
    nickname = sampGetPlayerNickname(playerId)
end

function save()
    inicfg.save(ini, "fdtools.ini")
end

function imgui.GrayText(text)
	imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.767, 0.782, 0.774, 0.780))
		local text = imgui.Text(text)
	imgui.PopStyleColor(1)
	return text
end

function imgui.BlackGrayText(text)
	imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.49, 0.55, 0.66, 0.780))
		local text = imgui.Text(text)
	imgui.PopStyleColor(1)
	return text
end

local fontsize35 = nil
local fontsize15 = nil
local font_8 = nil
local fa_font23 = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })

function imgui.BeforeDrawFrame()
    local font_config = imgui.ImFontConfig()
    font_config.MergeMode = true

    if fa_font23 == nil then
        fa_font23 = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 40, font_config, fa_glyph_ranges)
        fa_font23 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 15, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
    end
    if fa_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true
        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 15.0, font_config, fa_glyph_ranges)
        fa_font2 = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 12.0, font_config2, fa_glyph_ranges)
        fa_font3 = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 16.0, font_config3, fa_glyph_ranges)
    end
    if fontsize35 == nil then
        fontsize35 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14).. '\\trebucbd.ttf', 25.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
    if font_8 == nil then
        font_8 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14).. '\\trebucbd.ttf', 8.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
    if font_16 == nil then
        font_16 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14).. '\\trebucbd.ttf', 18.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
    if font_14 == nil then
        font_14 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14).. '\\trebucbd.ttf', 16.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
    if font_12 == nil then
        font_12 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14).. '\\trebucbd.ttf', 14.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
    if font_24 == nil then
        font_24 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14).. '\\trebucbd.ttf', 28.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
    if fontsize15 == nil then
        fontsize15 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14).. '\\trebucbd.ttf', 25.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- вместо 30 любой нужный размер
    end
end

function imgui.OnDrawFrame( ... )
    if main_window.v then
	    imgui.SetNextWindowSize(imgui.ImVec2(570,305), imgui.Cond.FirstUseEver)
	    imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8'fdtools', main_window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.ShowBorders + imgui.WindowFlags.AlwaysUseWindowPadding)
        imgui.PushFont(fontsize35)
        imgui.TextColoredRGB(u8'{D6D6D6}FD Helper')
        imgui.PopFont()
        imgui.SameLine()
        imgui.SetCursorPosY(25)
        imgui.Hint(u8'{313742}v3.6', u8'Обновление (364), от 27.09')
        imgui.SameLine()
        imgui.SetCursorPosY(10)
        imgui.SetCursorPosX(485)
        imgui.PushFont(fa_font2)
        if imgui.CloseButton(fa.ICON_FA_QUESTION_CIRCLE, imgui.ImVec2(30,30)) then
            imgui.OpenPopup(u8'info')
        end
        imgui.SameLine()
        if imgui.CloseButton(fa.ICON_FA_TIMES, imgui.ImVec2(30,30)) then
            main_window.v = false
        end
        if imgui.BeginPopupModal(u8('info'), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.ShowBorders) then
            imgui.PushFont(font_16)
            imgui.CenterText(u8'Доступные команды и информация')
            imgui.PopFont()
            imgui.PushFont(font_12)
            imgui.Text(u8'Команды скрипта:\n')
            imgui.Text(u8'/fdtools - Главное меню скрипта\n/fdgive [ID] - Меню быстрой выдачи\n/givecmd - Выдать все команды себе\n\n')
            imgui.Text(u8'Горячие клавиши:')
            imgui.Text(ini.config.hotkey.. u8' - Главное меню')
            if imgui.ClosePopupButton(u8'Закрыть', imgui.ImVec2(450,30)) then
                imgui.CloseCurrentPopup()
            end
            imgui.PopFont()
            imgui.EndPopup()
        end		
        imgui.PopFont()
        if menu == 0 or menu == nil then
            imgui.SetCursorPosY(100)
            imgui.SetCursorPosX(114)
            imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 3)
            if imgui.AnimatedButton('\n\n   '..fa.ICON_FA_USER_CIRCLE..u8'\n\n Профиль', imgui.ImVec2(110, 120), 0.5, true) then
                lua_thread.create(function()
                    menu = 1
                end)
            end
            imgui.PopStyleVar()
            imgui.SameLine()
            imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 3)
            if imgui.AnimatedButton('\n\n     '..fa.ICON_FA_LIST_ALT..u8'\n\nФункционал', imgui.ImVec2(110, 120), 0.5, true) then
                lua_thread.create(function()
                    menu = 2
                end)
            end
            imgui.PopStyleVar()
            imgui.SameLine()
            imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 3)
            if imgui.AnimatedButton('\n\n '..fa.ICON_FA_COGS..u8'\n\nНастройки', imgui.ImVec2(110, 120), 0.5, true) then
                lua_thread.create(function()
                    menu = 3
                end)
            end
            imgui.PopStyleVar()
            imgui.Text('')
            imgui.CenterText(u8'')
        end
        if menu == 1 then
            imgui.SetCursorPosY(54)
            imgui.PushFont(fa_font23)
            if imgui.CloseButton(fa.ICON_FA_ANGLE_LEFT..u8'', imgui.ImVec2(15,20)) then
                menu = 0
            end
            imgui.PopFont()
            imgui.SameLine()
            imgui.PushFont(font_24)
            imgui.SetCursorPosY(45)
            imgui.Text(u8'Профиль')
            imgui.PopFont()
            imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
            imgui.PushFont(fa_font23)
            imgui.SetCursorPosY(105)
            if imgui.MenuButton(fa.ICON_FA_USER_CIRCLE..u8' Профиль', imgui.ImVec2(150,30)) then
                user = 1
            end
            if imgui.MenuButton(fa.ICON_FA_INFO_CIRCLE..u8' Информация', imgui.ImVec2(150,30)) then
                user = 3
            end
            if imgui.MenuNoAButton(fa.ICON_FA_LEVEL_UP_ALT..u8' Уровень доступа', imgui.ImVec2(150,30)) then
            --    user = 2
            end
            
            if imgui.MenuNoAButton(fa.ICON_FA_LOCK..u8' Скоро', imgui.ImVec2(150,30)) then
            end
            imgui.PopFont()
            imgui.PopStyleVar()
            imgui.SetCursorPosY(54)
            imgui.SetCursorPosX(180)
            imgui.BeginChild(u8'##menu-profile', imgui.ImVec2(373, 235), imgui.WindowFlags.NoBorders)
                if user == 1 or user == nil then
                    imgui.SetCursorPosY(11)
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Профиль')
                    imgui.PopFont()
                    imgui.SetCursorPosX(11)
                    imgui.Text(u8'Ваше имя: ')
                    imgui.SameLine()
                    imgui.BlackGrayText(u8''..nick..' ['..id..']')
                    imgui.SetCursorPosX(11)
                    imgui.Text(u8'Уровень администратора: ')
                    imgui.SameLine()
                    imgui.BlackGrayText(adm_level)
                    imgui.SetCursorPosX(11)
                    imgui.Text(u8'Должность: ')
                    imgui.SameLine()
                    imgui.BlackGrayText(u8'Руководящий')
                    imgui.SetCursorPosX(11)
                    imgui.Text(u8'Онлайн: ')
                    imgui.SameLine()
                    imgui.BlackGrayText(adm_onl_seg1..u8' часов, '..adm_onl_seg2..u8' минут')
                    imgui.Text('')
                    imgui.SetCursorPosX(11)
                    imgui.Text(u8'Ответы на репорты: ')
                    imgui.SameLine()
                    imgui.BlackGrayText(adm_rep)
                    imgui.SameLine(200)
                    imgui.Text(u8'Кикнуто: ')
                    imgui.SameLine()
                    imgui.BlackGrayText(adm_kick..u8' человек')
                    imgui.SetCursorPosX(11)
                    imgui.Text(u8'Заварнено: ')
                    imgui.SameLine()
                    imgui.BlackGrayText(adm_warn..u8' человек')
                    imgui.SameLine(200)
                    imgui.Text(u8'Забанено: ')
                    imgui.SameLine()
                    imgui.BlackGrayText(adm_ban..u8' человек')
                    imgui.SetCursorPosX(11)
                    imgui.Text(u8'Посажено: ')
                    imgui.SameLine()
                    imgui.BlackGrayText(adm_jail..u8' человек')
                    imgui.SameLine(200)
                    imgui.Text(u8'Замучено: ')
                    imgui.SameLine()
                    imgui.BlackGrayText(adm_mute..u8' человек')
                end
                if user == 2 then
                    imgui.SetCursorPosY(11)
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Уровень доступа')
                    imgui.PopFont()
                end
                if user == 3 then
                --[[    imgui.SetCursorPosY(11)
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Информация')
                    imgui.PopFont()
                    imgui.PushFont(font_14)
                    imgui.SetCursorPosX(11)
                    imgui.Text(u8'Помощник Основателя')
                    imgui.PopFont()
                    imgui.SetCursorPosX(11)
                    imgui.GrayText(u8'/astats [nick], /setstat [id], /setcmd [nick]') --]]
                end
            imgui.EndChild()
        end
        if menu == 2 then
            imgui.SetCursorPosY(54)
            imgui.PushFont(fa_font23)
            if imgui.CloseButton(fa.ICON_FA_ANGLE_LEFT..u8'', imgui.ImVec2(15,20)) then
                menu = 0
            end
            imgui.PopFont()
            imgui.SameLine()
            imgui.PushFont(font_24)
            imgui.SetCursorPosY(45)
            imgui.Text(u8'Функции')
            imgui.PopFont()
            imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
            imgui.PushFont(fa_font23)
            imgui.SetCursorPosY(105)
            if imgui.MenuButton(fa.ICON_FA_SIGNATURE..u8' Префиксы', imgui.ImVec2(150,30)) then
                func = 1
            end
            if imgui.MenuButton(fa.ICON_FA_TERMINAL..u8' Команды', imgui.ImVec2(150,30)) then
                func = 2
            end
            if imgui.MenuButton(fa.ICON_FA_ADDRESS_CARD..u8' Статистика', imgui.ImVec2(150,30)) then
                func = 3
            end
            if imgui.MenuButton(fa.ICON_FA_COINS..u8' Промокоды', imgui.ImVec2(150,30)) then
                func = 4
            end
            imgui.PopFont()
            imgui.PopStyleVar()
            imgui.SetCursorPosY(54)
            imgui.SetCursorPosX(180)
            imgui.BeginChild(u8'##menu-func', imgui.ImVec2(373, 235), imgui.WindowFlags.NoBorders)
                if func == 1 or func == nil then
                    imgui.SetCursorPosY(11)
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Префиксы')
                    imgui.PopFont()
                    imgui.SetCursorPosX(11)
                    imgui.NewInputText(u8'##idprefix', prefix_id, 140, u8'Введите ID игрока', 2)
                    imgui.SameLine()
                    imgui.SetCursorPosX(158)
                    imgui.NewInputText(u8'##prefix', prefix, 190, u8'Введите префкис', 2)
                    imgui.SetCursorPosX(11)
                    if imgui.GreenButton(u8'Выдать префикс', imgui.ImVec2(164, 25)) then
                        sampSendChat('/prefix '..prefix_id.v..' '..u8:decode(prefix.v))
                    end
                    imgui.SetCursorPosX(11)
                    imgui.PushFont(font_14)
                    imgui.Text(u8'Следящие: Государственные структуры')
                    imgui.PopFont()
                    imgui.SetCursorPosX(11)
                    imgui.PushItemWidth(164) 
                    imgui.Combo(u8"##goss", combo_prefix_goss, gossprefix)
                    imgui.SameLine()
                    if imgui.GreenButton(u8'Выдать префикс##gos', imgui.ImVec2(164, 25)) then
                        sampSendChat('/prefix '..prefix_id.v..' '..u8:decode(gossprefix[combo_prefix_goss.v + 1]))
                    end
                    imgui.SetCursorPosX(11)
                    imgui.PushFont(font_14)
                    imgui.Text(u8'Следящие: Мафиозные структуры')
                    imgui.PopFont()
                    imgui.SetCursorPosX(11)
                    imgui.Combo(u8"##mafia", combo_prefix_mafia, mafiaprefix)
                    imgui.SameLine()
                    if imgui.GreenButton(u8'Выдать префикс##maf', imgui.ImVec2(164, 25)) then
                        sampSendChat('/prefix '..prefix_id.v..' '..u8:decode(mafiaprefix[combo_prefix_mafia.v + 1]))
                    end
                    imgui.SetCursorPosX(11)
                    imgui.PushFont(font_14)
                    imgui.Text(u8'Следящие: Нелегальные структуры')
                    imgui.PopFont()
                    imgui.SetCursorPosX(11)
                    imgui.Combo(u8"##ghetoo", combo_prefix_ghetto, ghettoprefix)
                    imgui.SameLine()
                    if imgui.GreenButton(u8'Выдать префикс##ghe', imgui.ImVec2(164, 25)) then
                        sampSendChat('/prefix '..prefix_id.v..' '..u8:decode(ghettoprefix[combo_prefix_ghetto.v + 1]))
                    end
                    imgui.SetCursorPosX(11)
                    imgui.PushFont(font_14)
                    imgui.Text(u8'Ведущие и Красные')
                    imgui.PopFont()
                    imgui.SetCursorPosX(11)
                    imgui.Combo(u8"##ved", combo_prefix_ved, vedprefix)
                    imgui.SameLine()
                    if imgui.GreenButton(u8'Выдать префикс##ved', imgui.ImVec2(164, 25)) then
                        sampSendChat('/prefix '..prefix_id.v..' '..u8:decode(vedprefix[combo_prefix_ved.v + 1]))
                    end
                    imgui.SetCursorPosX(11)
                    imgui.PushFont(font_14)
                    imgui.Text(u8'Руководящие')
                    imgui.PopFont()
                    imgui.SetCursorPosX(11)
                    imgui.Combo(u8"##ruk", combo_prefix_ruk, rukprefix)
                    imgui.SameLine()
                    if imgui.GreenButton(u8'Выдать префикс##ruk', imgui.ImVec2(164, 25)) then
                        sampSendChat('/prefix '..prefix_id.v..' '..u8:decode(rukprefix[combo_prefix_ruk.v + 1]))
                    end
                    imgui.PopItemWidth()
                end
                if func == 2 then
                    imgui.SetCursorPosY(11)
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Команды')
                    imgui.PopFont()
                   -- setcmd nick cmd 1\0
                    imgui.SetCursorPosX(11)
                    imgui.NewInputText(u8'##idcmd', cmdid, 140, u8'Введите ID игрока', 2)
                    imgui.SameLine(161)
                    imgui.NewInputText(u8'##nickcmd', nick_cmd, 201, u8'Введите ник игрока', 2)
                    imgui.SetCursorPosX(11)
                    imgui.PushItemWidth(164) 
                    imgui.Combo(u8"##cmd", combo_cmd, commands)
                    imgui.SetCursorPosX(11)
                    imgui.PushFont(font_14)
                    imgui.Text(u8'Выдать онлайн')
                    imgui.PopFont()
                    nick_id = sampGetPlayerNickname(cmdid.v)
                    imgui.SetCursorPosX(11)
                    if imgui.GreenButton(u8'Выдать команду', imgui.ImVec2(172, 30)) then
                        sampSendChat('/setcmd '..nick_id..' /'..u8:decode(commands[combo_cmd.v + 1])..' 1')
                    end
                    imgui.SameLine()
                    if imgui.RedButton(u8'Забрать команду', imgui.ImVec2(172, 30)) then
                        sampSendChat('/setcmd '..nick_id..' /'..u8:decode(commands[combo_cmd.v + 1])..' 0')
                    end
                    imgui.SetCursorPosX(11)
                    imgui.PushFont(font_14)
                    imgui.Text(u8'Выдать оффлайн')
                    imgui.PopFont()
                    imgui.SetCursorPosX(11)
                    if imgui.GreenButton(u8'Выдать команду##s', imgui.ImVec2(172, 30)) then
                        sampSendChat('/setcmd '..nick_cmd.v..' /'..u8:decode(commands[combo_cmd.v + 1])..' 1')
                    end
                    imgui.SameLine()
                    if imgui.RedButton(u8'Забрать команду##ss', imgui.ImVec2(172, 30)) then
                        sampSendChat('/setcmd '..nick_cmd.v..' /'..u8:decode(commands[combo_cmd.v + 1])..' 0')
                    end
                    imgui.PopItemWidth()
                end
                if func == 3 then
                    imgui.SetCursorPosY(11)
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Статистика')
                    imgui.PopFont()
                    imgui.SetCursorPosX(11)
                    imgui.NewInputText(u8'##idstat', id_give_stat, 140, u8'Введите ID игрока', 2)
                    imgui.SetCursorPosX(11)
                    imgui.PushItemWidth(164) 
                    imgui.Combo(u8"##statsss", combo_stats, stats_item)
                    imgui.PopItemWidth()
                    imgui.SetCursorPosX(11)
                    imgui.NewInputText(u8'##colvo', statscol, 140, u8'Введите количество', 2)
                    imgui.SetCursorPosX(11)
                    if imgui.GreenButton(u8'Изменить статистику##s', imgui.ImVec2(172, 30)) then
                        sampSendChat('/setstat '..id_give_stat.v..' '..combo_stats.v..' '..statscol.v)
                    end
                    imgui.SameLine()
                    if imgui.RedButton(u8'Забрать статистику##ss', imgui.ImVec2(172, 30)) then
                        sampSendChat('/setstat '..id_give_stat.v..' '..combo_stats.v..' 0')
                    end
                end
                if func == 4 then
                    imgui.SetCursorPosY(11)
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Промокоды')
                    imgui.PopFont()
                    imgui.SetCursorPosX(11)
                    imgui.NewInputText(u8'##namepromo', promo_name, 180, u8'Введите название без #', 2)
                    imgui.SameLine()
                    imgui.SetCursorPosX(201)
                    imgui.GrayText(u8'Название промокода')
                    imgui.PushItemWidth(180) 
                    imgui.SetCursorPosX(11)
                    imgui.SliderInt(u8"##количество", rub, 1, 200, "%.0f")
                    imgui.SameLine()
                    imgui.SetCursorPosX(201)
                    imgui.GrayText(u8'Количество рублей')
                    imgui.SetCursorPosX(11)
                    imgui.SliderInt(u8"##количествоisp", use, 1, 300, "%.0f")
                    imgui.SameLine()
                    imgui.SetCursorPosX(201)
                    imgui.GrayText(u8'Количество использований')
                    imgui.SetCursorPosX(11)
                    imgui.Combo(u8'##perm', combo_permission, perm)
                    imgui.SameLine()
                    imgui.SetCursorPosX(201)
                    imgui.GrayText(u8'Разрещение')
                    imgui.SetCursorPosX(11)
                    imgui.SliderInt(u8"##time", time, 1, 100, "%.0f")
                    imgui.SameLine()
                    imgui.SetCursorPosX(201)
                    imgui.GrayText(u8'Количество отыгровки')
                    imgui.PopItemWidth()
                    imgui.SetCursorPosX(11)
                    if imgui.GreenButton(u8'Создать промокод', imgui.ImVec2(180, 30)) then
                        sampSendChat('/newpromo #'..promo_name.v..' '..rub.v..' '..use.v..' '..combo_permission.v..' '..time.v)
                    end
                end
            imgui.EndChild()
            
        end
        if menu == 3 then
            imgui.SetCursorPosY(54)
            imgui.PushFont(fa_font23)
            if imgui.CloseButton(fa.ICON_FA_ANGLE_LEFT..u8'', imgui.ImVec2(15,20)) then
                menu = 0
            end
            imgui.PopFont()
            imgui.SameLine()
            imgui.PushFont(font_24)
            imgui.SetCursorPosY(45)
            imgui.Text(u8'Настройки')
            imgui.PopFont()
            imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
            imgui.PushFont(fa_font23)
            imgui.SetCursorPosY(105)
            if imgui.MenuButton(fa.ICON_FA_PALETTE..u8' Вид скрипта', imgui.ImVec2(150,30)) then
                set = 1
            end
            if imgui.MenuButton(fa.ICON_FA_USER_CIRCLE..u8' Дополнительно', imgui.ImVec2(150,30)) then
                set = 3
            end
            if imgui.MenuNoAButton(fa.ICON_FA_USER_CIRCLE..u8' Профиль', imgui.ImVec2(150,30)) then
           --     set = 2
            end
            if imgui.MenuNoAButton(fa.ICON_FA_LOCK..u8' Скоро', imgui.ImVec2(150,30)) then
            end
            imgui.PopFont()
            imgui.PopStyleVar()
            imgui.SetCursorPosY(54)
            imgui.SetCursorPosX(180)
            imgui.BeginChild(u8'##menu-set', imgui.ImVec2(373, 235), imgui.WindowFlags.NoBorders)
                if set == 1 or set == nil then
                    imgui.SetCursorPosY(11)
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Вид скрипта')
                    imgui.PopFont()
                    imgui.SetCursorPosX(11)
                    imgui.PushFont(font_14)
                    imgui.Text(u8'Выбор стиля')
                    imgui.PopFont()
                    imgui.SetCursorPosX(19)
                    if imgui.CircleButton('##orange', ini.config.theme == 1,  imgui.ImVec4(1.00, 0.42, 0.00, 1.00)) then
                        ini.config.theme = 1
                        inicfg.save(ini, 'fdtools.ini')
                        style()
                    end
                    imgui.SameLine()
                    if imgui.CircleButton('##blue', ini.config.theme == 2, imgui.ImVec4(0.28, 0.56, 1.00, 1.00)) then
                        ini.config.theme = 2
                        inicfg.save(ini, 'fdtools.ini')
                        style()
                    end
                    imgui.SameLine()
                    if imgui.CircleButton('##green', ini.config.theme == 3, imgui.ImVec4(0.00, 0.80, 0.38, 1.00)) then
                        ini.config.theme = 3
                        inicfg.save(ini, 'fdtools.ini')
                        style()
                    end
                    imgui.SameLine()
                    if imgui.CircleButton('##pink', ini.config.theme == 4, imgui.ImVec4(0.41, 0.19, 0.63, 1.00)) then
                        ini.config.theme = 4
                        inicfg.save(ini, 'fdtools.ini')
                        style()
                    end
                    imgui.SetCursorPosX(11)
                    imgui.PushFont(font_14)
                    imgui.Text(u8'Дополнительно')
                    imgui.PopFont()
                    imgui.SetCursorPosX(19)

                end
                if set == 2 then
                    imgui.SetCursorPosY(11)
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Настройки профиля')
                    imgui.PopFont()
                end
                if set == 3 then
                    imgui.SetCursorPosY(11)
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Дополнительные настройки')
                    imgui.PopFont()
                    imgui.SetCursorPosX(11)
                    imgui.HotKey('##hot', ini.config, 'hotkey', 'F4', string.find(ini.config.hotkey, '+') and 150 or 75)
                    imgui.SameLine()
                    imgui.Text(u8'Активация')
                end
            imgui.EndChild()
            
        end
        imgui.End()
    end
    if main_give.v then
	    imgui.SetNextWindowSize(imgui.ImVec2(625,355), imgui.Cond.FirstUseEver)
	    imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8'##gives', main_give, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.ShowBorders + imgui.WindowFlags.AlwaysUseWindowPadding)
        imgui.PushFont(fontsize35)
        imgui.TextColoredRGB(u8'{D6D6D6}FD Helper')
        imgui.PopFont()
        imgui.SameLine()
        imgui.SetCursorPosY(25)
        imgui.Hint(u8'{313742}v3.5', u8'Обновление (351), от 25.09')
        imgui.SameLine()
        imgui.SetCursorPosY(10)
        imgui.SetCursorPosX(545)
        imgui.PushFont(fa_font2)
        if imgui.CloseButton(fa.ICON_FA_QUESTION_CIRCLE, imgui.ImVec2(30,30)) then
            imgui.OpenPopup(u8'info')
        end
        imgui.SameLine()
        if imgui.CloseButton(fa.ICON_FA_TIMES, imgui.ImVec2(30,30)) then
            main_give.v = false
        end
        imgui.PopFont()
        imgui.Text('')
        imgui.Text('')
        if imgui.ClosePopupButton(u8'Goss', imgui.ImVec2(90,30)) then
            menu_give = 1
        end
        imgui.SameLine()
        if imgui.ClosePopupButton(u8'Ghetto', imgui.ImVec2(90,30)) then
            menu_give = 2
        end
        if imgui.ClosePopupButton(u8'Mafia', imgui.ImVec2(72,30)) then
            menu_give = 3
        end
        imgui.SameLine()
        if imgui.ClosePopupButton(u8'Ведущие', imgui.ImVec2(108,30)) then
            menu_give = 4
        end
        if imgui.ClosePopupButton(u8'Руководящая администрация', imgui.ImVec2(188,30)) then
            menu_give = 5
        end
        if imgui.ClosePopupButton(u8'Без должности', imgui.ImVec2(188,30)) then
            menu_give = 6
        end
        if imgui.ClosePopupButton(u8'Очистка должности', imgui.ImVec2(188,30)) then
            sampAddChatMessage(tag..'{FFFFFF}недоступно!', main_color)
        end
            if menu_give == 1 or menu_give == nil then
                imgui.SetCursorPosY(45)
                imgui.Text(u8'\n>> Государственные структуры\n')
                imgui.SetCursorPosX(220)
                imgui.SetCursorPosY(65)
                imgui.BeginChild(u8'##goss', imgui.ImVec2(385,264), true)
                imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.0, 0.0, 0.0, 0.0))
                imgui.PushFont(font_16)
                imgui.CenterText(u8'Помощник Главного следящего')
                imgui.PopFont()
                if imgui.ClosePopupButton(u8'Выдать префикс##sssss', imgui.ImVec2(140,30)) then
                    sampSendChatMessage('/prefix '..playerId..' Goss | Помощник ГС')
                end
                imgui.SameLine()
                imgui.GrayText(u8'<< можно выдать только префикс')
                imgui.PushFont(font_16)
                imgui.CenterText(u8'\nЗаместитель Главного следящего')
                imgui.PopFont()
                if imgui.ClosePopupButton(u8'Префикс##Sdsfds', imgui.ImVec2(74,30)) then
                    sampSendChatMessage('/prefix '..playerId..' Goss | Заместитель ГС')
                end
                imgui.SameLine()
                if imgui.ClosePopupButton(u8'Команды##lpdkf', imgui.ImVec2(74,30)) then
                    lua_thread.create(function()
                        sampSendChatMessage('/setstat '..playerId..' 36 1')
                        wait(1000)
                        sampSendChatMessage('/setstat '..playerId..' 37 1')
                        wait(1000)
                        sampSendChatMessage('/setcmd '..nickname..' /makeleader 1')
                    end)
                end
                imgui.SameLine()
                if imgui.ClosePopupButton(u8'Выдать всё##lasklkp', imgui.ImVec2(191,30)) then
                    lua_thread.create(function()
                        sampSendChatMessage('/prefix '..playerId..' Goss | Заместитель ГС')
                        wait(1000)
                        sampSendChatMessage('/setstat '..playerId..' 36 1')
                        wait(1000)
                        sampSendChatMessage('/setstat '..playerId..' 37 1')
                        wait(1000)
                        sampSendChatMessage('/setcmd '..nickname..' /makeleader 1')
                    end)
                end
                imgui.PushFont(font_16)
                imgui.CenterText(u8'\nГлавный следящий')
                imgui.PopFont()
                if imgui.ClosePopupButton(u8'Префикс##kalksjdhbhbsd', imgui.ImVec2(74,30)) then
                    sampSendChatMessage('/prefix '..playerId..' Goss | Главный Следящий')
                end
                imgui.SameLine()
                if imgui.ClosePopupButton(u8'Команды##jakskabsubias', imgui.ImVec2(74,30)) then
                    lua_thread.create(function()
                        sampSendChatMessage('/setstat '..playerId..' 36 1')
                        wait(1000)
                        sampSendChatMessage('/setstat '..playerId..' 37 1')
                        wait(1000)
                        sampSendChatMessage('/setcmd '..nickname..' /makeleader 1')
                        wait(1000)
                        sampSendChatMessage('/setcmd '..nickname..' /offleader 1')
                    end)
                end
                imgui.SameLine()
                if imgui.ClosePopupButton(u8'/offleader##sjjid', imgui.ImVec2(74,30)) then
                    sampSendChatMessage('/setcmd '..nickname..' /offleader 1')
                end
                imgui.SameLine()
                if imgui.ClosePopupButton(u8'Выдать всё##sdjisi', imgui.ImVec2(108,30)) then
                    lua_thread.create(function()
                        sampSendChatMessage('/prefix '..playerId..' Goss | Главный Следящий')
                        wait(1000)
                        sampSendChatMessage('/setstat '..playerId..' 36 1')
                        wait(1000)
                        sampSendChatMessage('/setstat '..playerId..' 37 1')
                        wait(1000)
                        sampSendChatMessage('/setcmd '..nickname..' /makeleader 1')
                        wait(1000)
                        sampSendChatMessage('/setcmd '..nickname..' /offleader 1')
                    end)
                end
                imgui.PopStyleColor(1)
                imgui.EndChild()
            end
                if menu_give == 2 then
                    imgui.SetCursorPosY(45)
                    imgui.Text(u8'\n>> Ghetto группировки\n')
                    imgui.SetCursorPosX(220)
                    imgui.SetCursorPosY(65)
                    imgui.BeginChild(u8'##ghetto', imgui.ImVec2(385,264), true)
                    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.0, 0.0, 0.0, 0.0))
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Помощник Главного следящего')
                    imgui.PopFont()
                    if imgui.ClosePopupButton(u8'Выдать префикс##ojodijosijd', imgui.ImVec2(140,30)) then
                        sampSendChatMessage('/prefix '..playerId..' Ghetto | Помощник ГС')
                    end
                    imgui.SameLine()
                    imgui.GrayText(u8'<< можно выдать только префикс')
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'\nЗаместитель Главного следящего')
                    imgui.PopFont()
                    if imgui.ClosePopupButton(u8'Префикс##kojsdiijisjd', imgui.ImVec2(74,30)) then
                        sampSendChatMessage('/prefix '..playerId..' Ghetto | Заместитель ГС')
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Команды##isdihishdihi', imgui.ImVec2(74,30)) then
                        lua_thread.create(function()
                            sampSendChatMessage('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChatMessage('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChatMessage('/setcmd '..nickname..' /makeleader 1')
                            wait(1000)
                            sampSendChatMessage('/setcmd '..nickname..' /ghetto 1')
                            wait(1000)
                            sampSendChatMessage('/setcmd '..nickname..' /gzcolor 1')
                        end)
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Выдать всё##[pkopsjdojd', imgui.ImVec2(191,30)) then
                        lua_thread.create(function()
                            sampSendChatMessage('/prefix '..playerId..' Ghetto | Заместитель ГС')
                            wait(1000)
                            sampSendChatMessage('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChatMessage('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChatMessage('/setcmd '..nickname..' /makeleader 1')
                            wait(1000)
                            sampSendChatMessage('/setcmd '..nickname..' /ghetto 1')
                            wait(1000)
                            sampSendChatMessage('/setcmd '..nickname..' /gzcolor 1')
                        end)
                    end
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'\nГлавный следящий')
                    imgui.PopFont()
                    if imgui.ClosePopupButton(u8'Префикс##sdwoksoo', imgui.ImVec2(74,30)) then
                        sampSendChatMessage('/prefix '..playerId..' Ghetto | Главный Следящий')
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Команды##lpojsdjoijd', imgui.ImVec2(74,30)) then
                        lua_thread.create(function()
                            sampSendChatMessage('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /ghetto 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /gzcolor 1')
                        end)
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'/offleader##lsjiadsjd', imgui.ImVec2(74,30)) then
                        sampSendChat('/setcmd '..nickname..' /offleader 1')
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Выдать всё##ojaisniajd', imgui.ImVec2(108,30)) then
                        lua_thread.create(function()
                            sampSendChat('/prefix '..playerId..' Ghetto | Главный Следящий')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /ghetto 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /gzcolor 1')
                        end)
                    end
                    imgui.PopStyleColor(1)
                    imgui.EndChild()
                end
                if menu_give == 3 then
                    imgui.SetCursorPosY(45)
                    imgui.Text(u8'\n>> Mafia и безнес-организации\n')
                    imgui.SetCursorPosX(220)
                    imgui.SetCursorPosY(65)
                    imgui.BeginChild(u8'##mafia', imgui.ImVec2(385,264), true)
                    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.0, 0.0, 0.0, 0.0))
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Помощник Главного следящего')
                    imgui.PopFont()
                    if imgui.ClosePopupButton(u8'Выдать префикс##kwosidhahdihiajdi', imgui.ImVec2(140,30)) then
                        sampSendChat('/prefix '..playerId..' Mafia | Помощник ГС')
                    end
                    imgui.SameLine()
                    imgui.GrayText(u8'<< можно выдать только префикс')
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'\nЗаместитель Главного следящего')
                    imgui.PopFont()
                    if imgui.ClosePopupButton(u8'Префикс##sojdioahidhiohf', imgui.ImVec2(74,30)) then
                        sampSendChat('/prefix '..playerId..' Mafia | Заместитель ГС')
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Команды##aofjoijiodjfio', imgui.ImVec2(74,30)) then
                        lua_thread.create(function()
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeleader 1')
                        end)
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Выдать всё##eidnafjiejd', imgui.ImVec2(191,30)) then
                        lua_thread.create(function()
                            sampSendChat('/prefix '..playerId..' Mafia | Заместитель ГС')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeleader 1')
                        end)
                    end
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'\nГлавный следящий')
                    imgui.PopFont()
                    if imgui.ClosePopupButton(u8'Префикс##oaodijiaf', imgui.ImVec2(74,30)) then
                        sampSendChat('/prefix '..playerId..' Mafia | Главный Следящий')
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Команды##opajdjojdf', imgui.ImVec2(74,30)) then
                        lua_thread.create(function()
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offleader 1')
                        end)
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'/offleader##mdkfnkajifj', imgui.ImVec2(74,30)) then
                        sampSendChat('/setcmd '..nickname..' /offleader 1')
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Выдать всё##iahfihidahf', imgui.ImVec2(108,30)) then
                        lua_thread.create(function()
                            sampSendChat('/prefix '..playerId..' Mafia | Главный Следящий')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offleader 1')
                        end)
                    end
                    imgui.PopStyleColor()
                    imgui.EndChild()
                end
                if menu_give == 4 then
                    imgui.SetCursorPosY(45)
                    imgui.Text(u8'\n>> Ведущая Администрация\n')
                    imgui.SetCursorPosX(220)
                    imgui.SetCursorPosY(65)
                    imgui.BeginChild(u8'##ved', imgui.ImVec2(385,264), true)
                    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.0, 0.0, 0.0, 0.0))
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Заместитель Главного Администратора')
                    imgui.PopFont()
                    if imgui.ClosePopupButton(u8'Префикс##pakodkosd', imgui.ImVec2(74,30)) then
                        sampSendChat('/prefix '..playerId..' Заместитель ГА')
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Команды##akodkokoakd', imgui.ImVec2(74,30)) then
                        lua_thread.create(function()
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /avig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /auvig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /banip 1')
                        end)
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Выдать всё##apkdojokod', imgui.ImVec2(191,30)) then
                        lua_thread.create(function()
                            sampSendChat('/prefix '..playerId..' Заместитель ГА')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /avig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /auvig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /banip 1')
                        end)
                    end
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Главный Администратор')
                    imgui.PopFont()
                    if imgui.ClosePopupButton(u8'Префикс##kapksdpokpd', imgui.ImVec2(74,30)) then
                        sampSendChat('/prefix '..playerId..' Главный Администратор')
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Команды##lpkoad', imgui.ImVec2(74,30)) then
                        lua_thread.create(function()
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /avig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /auvig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /banip 1')
                        end)
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Выдать всё##akoodjoajodjad', imgui.ImVec2(191,30)) then
                        lua_thread.create(function()
                            sampSendChat('/prefix '..playerId..' Главный Администратор')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /avig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /auvig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /banip 1')
                        end)
                    end
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Руководитель Сервера')
                    imgui.PopFont()
                    if imgui.ClosePopupButton(u8'Префикс##ao[dkdpkad', imgui.ImVec2(74,30)) then
                        sampSendChat('/prefix '..playerId..' Руководитель Сервера')
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Команды##ajodiiad', imgui.ImVec2(74,30)) then
                        lua_thread.create(function()
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /avig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /auvig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /banip 1')
                        end)
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Выдать всё##a[lpkpkpfkdf', imgui.ImVec2(191,30)) then
                        lua_thread.create(function()
                            sampSendChat('/prefix '..playerId..' Руководитель Сервера')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /avig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /auvig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /banip 1')
                        end)
                    end
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Куратор Сервера')
                    imgui.PopFont()
                    if imgui.ClosePopupButton(u8'Префикс##pakpkdkpodk', imgui.ImVec2(74,30)) then
                        sampSendChat('/prefix '..playerId..' Куратор Сервера')
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Команды##aojdjodfjo', imgui.ImVec2(74,30)) then
                        lua_thread.create(function()
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /avig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /auvig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /gzcolor 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /ghetto 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /banip 1')
                        end)
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Выдать всё', imgui.ImVec2(191,30)) then
                        lua_thread.create(function()
                            sampSendChat('/prefix '..playerId..' Куратор Сервера')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /avig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /auvig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /gzcolor 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /ghetto 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /banip 1')
                        end)
                    end
                    imgui.PopStyleColor(1)
                    imgui.EndChild()
                end
                if menu_give == 5 then
                    imgui.SetCursorPosY(45)
                    imgui.Text(u8'\n>> Руководящая Администрация\n')
                    imgui.SetCursorPosX(220)
                    imgui.SetCursorPosY(65)
                    imgui.BeginChild(u8'##ruk', imgui.ImVec2(385,264), true)
                    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.0, 0.0, 0.0, 0.0))
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Помощник Основателя')
                    imgui.PopFont()
                    if imgui.ClosePopupButton(u8'Префикс', imgui.ImVec2(74,30)) then
                        sampSendChat('/prefix '..playerId..' Помощник Основателя')
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Команды', imgui.ImVec2(74,30)) then
                        lua_thread.create(function()
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /avig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /auvig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /banip 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeadmin 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makehelper 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offhelper 1')
                        end)
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Выдать всё', imgui.ImVec2(191,30)) then
                        lua_thread.create(function()
                            sampSendChat('/prefix '..playerId..' Помощник Основателя')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /avig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /auvig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /banip 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeadmin 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makehelper 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offhelper 1')
                        end)
                    end
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Заместитель Основателя')
                    imgui.PopFont()
                    if imgui.ClosePopupButton(u8'Префикс##s', imgui.ImVec2(74,30)) then
                        sampSendChat('/prefix '..playerId..' Заместитель Основателя')
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Команды##s', imgui.ImVec2(74,30)) then
                        lua_thread.create(function()
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /avig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /auvig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /banip 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeadmin 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makehelper 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offhelper 1')
                        end)
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Выдать всё##s', imgui.ImVec2(191,30)) then
                        lua_thread.create(function()
                            sampSendChat('/prefix '..playerId..' Заместитель Основателя')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /avig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /auvig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /banip 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeadmin 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makehelper 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offhelper 1')
                        end)
                    end
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Исполняющий Обязанности Основателя')
                    imgui.PopFont()
                    if imgui.ClosePopupButton(u8'Префикс##ss', imgui.ImVec2(74,30)) then
                        sampSendChat('/prefix '..playerId..' И.О. Основателя')
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Команды##ss', imgui.ImVec2(74,30)) then
                        lua_thread.create(function()
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /avig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /auvig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /banip 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeadmin 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makehelper 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offhelper 1')
                        end)
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Выдать всё##qa', imgui.ImVec2(191,30)) then
                        lua_thread.create(function()
                            sampSendChat('/prefix '..playerId..' И.О. Основателя')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /avig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /auvig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /banip 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeadmin 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makehelper 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offhelper 1')
                        end)
                    end
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Основатель Сервера')
                    imgui.PopFont()
                    if imgui.ClosePopupButton(u8'Префикс##spkp', imgui.ImVec2(74,30)) then
                        sampSendChat('/prefix '..playerId..' Основатель Сервера')
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Команды##spkp', imgui.ImVec2(74,30)) then
                        lua_thread.create(function()
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /avig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /auvig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /banip 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeadmin 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makehelper 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offhelper 1')
                        end)
                    end
                    imgui.SameLine()
                    if imgui.ClosePopupButton(u8'Выдать всё##spkp', imgui.ImVec2(191,30)) then
                        lua_thread.create(function()
                            sampSendChat('/prefix '..playerId..' Основатель Сервера')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 36 1')
                            wait(1000)
                            sampSendChat('/setstat '..playerId..' 37 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /avig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /auvig 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /banip 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makeadmin 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /makehelper 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offleader 1')
                            wait(1000)
                            sampSendChat('/setcmd '..nickname..' /offhelper 1')
                        end)
                    end
                    imgui.PopStyleColor(1)
                    imgui.EndChild()
                end
                if menu_give == 6 then
                    imgui.SetCursorPosY(45)
                    imgui.Text(u8'\n>> Без должности\n')
                    imgui.SetCursorPosX(220)
                    imgui.SetCursorPosY(65)
                    imgui.BeginChild(u8'##bez', imgui.ImVec2(385,264), true)
                    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.0, 0.0, 0.0, 0.0))
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Выдать команду')
                    imgui.PopFont()
                    imgui.PushItemWidth(150) 
                    imgui.Combo(u8"##cmd", combo_cmd, commands)
                    imgui.PopItemWidth()
                    if imgui.GreenButton(u8'Выдать команду##nodzh', imgui.ImVec2(172, 30)) then
                        sampSendChat('/setcmd '..nickname..' /'..u8:decode(commands[combo_cmd.v + 1])..' 1')
                    end
                    imgui.SameLine()
                    if imgui.RedButton(u8'Забрать команду##nodzh', imgui.ImVec2(172, 30)) then
                        sampSendChat('/setcmd '..nickname..' /'..u8:decode(commands[combo_cmd.v + 1])..' 0')
                    end
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Изменить статистику')
                    imgui.PopFont()
                    imgui.PushItemWidth(150)
                    imgui.Combo(u8'##item', combo_stats, stats_item)
                    imgui.PopItemWidth()
                    imgui.SameLine()
                    imgui.NewInputText(u8'##num', number_s, 192, u8'Количество', 2)
                    if imgui.GreenButton(u8'Изменить статистику##nodzh', imgui.ImVec2(172, 30)) then
                        sampSendChat('/setstat '..playerId..' '..combo_stats.v..' '..number_s.v)
                    end
                    imgui.SameLine()
                    if imgui.RedButton(u8'Отобрать статистику##nodzh', imgui.ImVec2(172, 30)) then
                        sampSendChat('/setstat '..playerId..' '..combo_stats.v..' 0')
                    end
                    imgui.PushFont(font_16)
                    imgui.CenterText(u8'Выдать префикс')
                    imgui.PopFont()
                    imgui.NewInputText(u8'##pref', prefix_name, 150, u8'Введите префикс', 2)
                    imgui.SameLine(175)
                    if imgui.GreenButton(u8'Выдать префикс', imgui.ImVec2(196, 25)) then
                        sampSendChat('/prefix '..playerId..' '..prefix_name.v)
                    end
                    imgui.PopStyleColor(1)
                    imgui.EndChild()
                end
        imgui.End()
    end
    if updates.v then
	    imgui.SetNextWindowSize(imgui.ImVec2(0,0), imgui.Cond.FirstUseEver)
	    imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8'udatess', updates, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.ShowBorders + imgui.WindowFlags.AlwaysUseWindowPadding)
        imgui.PushFont(fontsize35)
        imgui.TextColoredRGB(u8'{D6D6D6}Версия: '..thisScript().version)
        imgui.PopFont()
        imgui.Text('')
        imgui.Text(u8'Исправление ошибок и добавлены новые')
        imgui.Text(u8'Добавлено автообновление')
        imgui.Text(u8'Добавлена команда /givecmd - выдать себе все команды')
        if imgui.ClosePopupButton(u8'Закрыть', imgui.ImVec2(450,30)) then
            updates.v = false
        end
        imgui.End()
    end
end


function imgui.ClosePopupButton(text, size)
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.156, 0.156, 0.156, 0.650))
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.303, 0.303, 0.303, 0.650))
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.200, 0.200, 0.200, 0.500))
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.06, 0.05, 0.07, 0.00))
		local button = imgui.Button(text, size)
	imgui.PopStyleColor(4)
	return button
end

function imgui.ButtonTwo(text, size)
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.06, 0.05, 0.07, 0.00))
		local button = imgui.Button(text, size)
	imgui.PopStyleColor(1)
	return button
end

function imgui.GreenButton(text, size)
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.06, 0.45, 0.15, 0.65))
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.15, 0.75, 0.21, 0.65))
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.12, 0.35, 0.03, 0.50))
--    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.06, 0.05, 0.07, 0.00))
		local button = imgui.Button(text, size)
	imgui.PopStyleColor(3)
	return button
end

function imgui.RedButton(text, size)
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.45, 0.06, 0.06, 0.65))
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.75, 0.15, 0.15, 0.65))
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.35, 0.03, 0.03, 0.50))
--    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.06, 0.05, 0.07, 0.00))
		local button = imgui.Button(text, size)
	imgui.PopStyleColor(3)
	return button
end
function imgui.CloseButton(text, size)
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.45, 0.06, 0.06, 0.00))
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.75, 0.15, 0.15, 0.00))
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.35, 0.03, 0.03, 0.00))
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.06, 0.05, 0.07, 0.00))
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 0.50))
		local button = imgui.Button(text, size)
	imgui.PopStyleColor(5)
	return button
end
function imgui.MenuButton(text, size)
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.142, 0.142, 0.142, 0.654))
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.142, 0.142, 0.142, 0.654))
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.142, 0.142, 0.142, 0.654))
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.06, 0.05, 0.07, 0.00))
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 0.90))
		local button = imgui.Button(text, size)
	imgui.PopStyleColor(5)
	return button
end
function imgui.MenuNoAButton(text, size)
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.142, 0.142, 0.142, 0.254))
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.142, 0.142, 0.142, 0.254))
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.142, 0.142, 0.142, 0.254))
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.06, 0.05, 0.07, 0.00))
    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 0.20))
		local button = imgui.Button(text, size)
	imgui.PopStyleColor(5)
	return button
end

function imgui.TransparentText(text)
	imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 1.0, 0.2))
		local text = imgui.Text(text)
	imgui.PopStyleColor(1)
	return text
end

function save()
    inicfg.save(ini, 'fdtools.ini')
end
function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end

    render_text(text)
end

function imgui.AnimatedButton(label, size, speed, rounded)
    local size = size or imgui.ImVec2(0, 0)
    local bool = false
    local text = label:gsub('##.+$', '')
    local ts = imgui.CalcTextSize(text)
    speed = speed and speed or 0.4
    if not AnimatedButtons then AnimatedButtons = {} end
    if not AnimatedButtons[label] then
        local color = imgui.GetStyle().Colors[imgui.Col.ButtonHovered]
        AnimatedButtons[label] = {circles = {}, hovered = false, state = false, time = os.clock(), color = imgui.ImVec4(color.x, color.y, color.z, 0.2)}
    end
    local button = AnimatedButtons[label]
    local dl = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()
    local c = imgui.GetCursorPos()
    local CalcItemSize = function(size, width, height)
        local region = imgui.GetContentRegionMax()
        if (size.x == 0) then
            size.x = width
        elseif (size.x < 0) then
            size.x = math.max(4.0, region.x - c.x + size.x);
        end
        if (size.y == 0) then
            size.y = height;
        elseif (size.y < 0) then
            size.y = math.max(4.0, region.y - c.y + size.y);
        end
        return size
    end
    size = CalcItemSize(size, ts.x+imgui.GetStyle().FramePadding.x*2, ts.y+imgui.GetStyle().FramePadding.y*2)
    local ImSaturate = function(f) return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f) end
    if #button.circles > 0 then
        local PathInvertedRect = function(a, b, col)
            local rounding = rounded and imgui.GetStyle().FrameRounding or 0
            if rounding <= 0 or not rounded then return end
            local dl = imgui.GetWindowDrawList()
            dl:PathLineTo(a)
            dl:PathArcTo(imgui.ImVec2(a.x + rounding, a.y + rounding), rounding, -3.0, -1.5)
            dl:PathFillConvex(col)

            dl:PathLineTo(imgui.ImVec2(b.x, a.y))
            dl:PathArcTo(imgui.ImVec2(b.x - rounding, a.y + rounding), rounding, -1.5, -0.205)
            dl:PathFillConvex(col)

            dl:PathLineTo(imgui.ImVec2(b.x, b.y))
            dl:PathArcTo(imgui.ImVec2(b.x - rounding, b.y - rounding), rounding, 1.5, 0.205)
            dl:PathFillConvex(col)

            dl:PathLineTo(imgui.ImVec2(a.x, b.y))
            dl:PathArcTo(imgui.ImVec2(a.x + rounding, b.y - rounding), rounding, 3.0, 1.5)
            dl:PathFillConvex(col)
        end
        for i, circle in ipairs(button.circles) do
            local time = os.clock() - circle.time
            local t = ImSaturate(time / speed)
            local color = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
            local color = imgui.GetColorU32(imgui.ImVec4(color.x, color.y, color.z, (circle.reverse and (255-255*t) or (255*t))/255))
            local radius = math.max(size.x, size.y) * (circle.reverse and 1.5 or t)
            imgui.PushClipRect(p, imgui.ImVec2(p.x+size.x, p.y+size.y), true)
            dl:AddCircleFilled(circle.clickpos, radius, color, radius/2)
            PathInvertedRect(p, imgui.ImVec2(p.x+size.x, p.y+size.y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.WindowBg]))
            imgui.PopClipRect()
            if t == 1 then
                if not circle.reverse then
                    circle.reverse = true
                    circle.time = os.clock()
                else
                    table.remove(button.circles, i)
                end
            end
        end
    end
    local t = ImSaturate((os.clock()-button.time) / speed)
    button.color.w = button.color.w + (button.hovered and 0.8 or -0.8)*t
    button.color.w = button.color.w < 0.2 and 0.2 or (button.color.w > 1 and 1 or button.color.w)
    color = imgui.GetStyle().Colors[imgui.Col.Button]
    color = imgui.GetColorU32(imgui.ImVec4(color.x, color.y, color.z, 0.2))
    dl:AddRectFilled(p, imgui.ImVec2(p.x+size.x, p.y+size.y), color, rounded and imgui.GetStyle().FrameRounding or 0)
    dl:AddRect(p, imgui.ImVec2(p.x+size.x, p.y+size.y), imgui.GetColorU32(button.color), rounded and imgui.GetStyle().FrameRounding or 0)
    local align = imgui.GetStyle().ButtonTextAlign
    imgui.SetCursorPos(imgui.ImVec2(c.x+(size.x-ts.x)*align.x, c.y+(size.y-ts.y)*align.y))
    imgui.Text(text)
    imgui.SetCursorPos(c)
    if imgui.InvisibleButton(label, size) then
        bool = true
        table.insert(button.circles, {animate = true, reverse = false, time = os.clock(), clickpos = imgui.ImVec2(getCursorPos())})
    end
    button.hovered = imgui.IsItemHovered()
    if button.hovered ~= button.state then
        button.state = button.hovered
        button.time = os.clock()
    end
    return bool
end

function imgui.Link(label, description)

    local size = imgui.CalcTextSize(label)
    local p = imgui.GetCursorScreenPos()
    local p2 = imgui.GetCursorPos()
    local result = imgui.InvisibleButton(label, size)

    imgui.SetCursorPos(p2)

    if imgui.IsItemHovered() then
        if description then
            imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
            imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
            imgui.EndTooltip()

        end

        imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.CheckMark], label)
        imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + size.y), imgui.ImVec2(p.x + size.x, p.y + size.y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.CheckMark]))

    else
        imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.CheckMark], label)
    end

    return result
end

function imgui.CircleButton(str_id, bool, color4, radius, isimage)
	local rBool = false

	local p = imgui.GetCursorScreenPos()
	local isimage = isimage or false
	local radius = radius or 10
	local draw_list = imgui.GetWindowDrawList()
	if imgui.InvisibleButton(str_id, imgui.ImVec2(23, 23)) then
		rBool = true
	end

	draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius, p.y + radius), radius-3, imgui.ColorConvertFloat4ToU32(isimage and imgui.ImVec4(0,0,0,0) or color4))

	if bool then
		draw_list:AddCircle(imgui.ImVec2(p.x + radius, p.y + radius), radius, imgui.ColorConvertFloat4ToU32(color4),_,1.5)
	end

	imgui.SetCursorPosY(imgui.GetCursorPosY()+radius)
	return rBool
end

function imgui.ToggleButton(str_id, bool)
	local rBool = false

	local p = imgui.GetCursorScreenPos()
	local draw_list = imgui.GetWindowDrawList()
	local height = 20
	local width = height * 1.55
	local radius = height * 0.50

	if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
		bool[0] = not bool[0]
		rBool = true
		LastActiveTime[tostring(str_id)] = imgui.GetTime()
		LastActive[tostring(str_id)] = true
	end

	imgui.SameLine()
	imgui.SetCursorPosY(imgui.GetCursorPosY()+3)
	imgui.Text(str_id)

	local t = bool[0] and 1.0 or 0.0

	if LastActive[tostring(str_id)] then
		local time = imgui.GetTime() - LastActiveTime[tostring(str_id)]
		if time <= 0.13 then
			local t_anim = ImSaturate(time / 0.13)
			t = bool[0] and t_anim or 1.0 - t_anim
		else
			LastActive[tostring(str_id)] = false
		end
	end

	local col_bg = imgui.ColorConvertFloat4ToU32(bool[0] and imgui.GetStyle().Colors[imgui.Col.CheckMark] or imgui.ImVec4(100 / 255, 100 / 255, 100 / 255, 180 / 255))

	draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + (height / 6)), imgui.ImVec2(p.x + width - 1.0, p.y + (height - (height / 6))), col_bg, 10.0)
	draw_list:AddCircleFilled(imgui.ImVec2(p.x + (bool[0] and radius + 1.5 or radius - 3) + t * (width - radius * 2.0), p.y + radius), radius - 6, imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Text]))

	return rBool
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
	local height = imgui.GetWindowHeight()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function imgui.CenterTT(text)
    local width = imgui.GetWindowWidth()
	local height = imgui.GetWindowHeight()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.TransparentText(text)
end

function imgui.CenterLink(label, description)
    local width = imgui.GetWindowWidth()
	local height = imgui.GetWindowHeight()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Link(label, description)
end
function imgui.NewInputText(lable, val, width, hint, hintpos)
    local hint = hint and hint or ''
    local hintpos = tonumber(hintpos) and tonumber(hintpos) or 1
    local cPos = imgui.GetCursorPos()
    imgui.PushItemWidth(width)
    local result = imgui.InputText(lable, val)
    if #val.v == 0 then
        local hintSize = imgui.CalcTextSize(hint)
        if hintpos == 2 then imgui.SameLine(cPos.x + (width - hintSize.x) / 2)
        elseif hintpos == 3 then imgui.SameLine(cPos.x + (width - hintSize.x - 5))
        else imgui.SameLine(cPos.x + 5) end
        imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 0.40), tostring(hint))
    end
    imgui.PopItemWidth()
    return result
end
function imgui.CustomSlider(str_id, min, max, width, int) -- by aurora
    local p = imgui.GetCursorScreenPos()
    local draw_list = imgui.GetWindowDrawList()
    local pos = imgui.GetWindowPos()
    local posx,posy = getCursorPos()
    local n = max - min
    if int.v == 0 then
        int.v = min
    end
    local col_bg_active = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.ButtonActive])
    local col_bg_notactive = imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.ModalWindowDarkening])
    draw_list:AddRectFilled(imgui.ImVec2(p.x + 7, p.y + 12), imgui.ImVec2(p.x + (width/n)*(int.v-min), p.y + 12), col_bg_active, 5.0)
    draw_list:AddRectFilled(imgui.ImVec2(p.x + (width/n)*(int.v-min), p.y + 12), imgui.ImVec2(p.x + width, p.y + 12), col_bg_notactive, 5.0)
    for i = 0, n do
        if posx > (p.x + i*width/(max+1) ) and posx < (p.x + (i+1)*width/(max+1)) and posy > p.y + 2 and posy < p.y + 22 and imgui.IsMouseDown(0) then
            int.v = i + min
            draw_list:AddCircleFilled(imgui.ImVec2(p.x + (width/n)*(int.v-min) + 4,  p.y + 7*2 - 2), 7+2, col_bg_active)
        end
    end
    imgui.SetCursorPos(imgui.ImVec2(p.x + width + 6 - pos.x, p.y - 8 - pos.y))
    imgui.Text(tostring(int.v))
    draw_list:AddCircleFilled(imgui.ImVec2(p.x + (width/n)*(int.v-min) + 4,  p.y + 7*2 - 2), 7, col_bg_active)
    imgui.NewLine()
    return int
end

function imgui.Hint(label, description)
    imgui.TextColoredRGB(label)

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function style()
    imgui.SwitchContext()
        local style = imgui.GetStyle()
        local style = imgui.GetStyle()
        local colors = style.Colors
        local clr = imgui.Col
        local ImVec4 = imgui.ImVec4
        local ImVec2 = imgui.ImVec2

        style.WindowPadding       = ImVec2(16, 16)
        style.WindowRounding      = 6
        style.ChildWindowRounding = 6
        style.FramePadding        = ImVec2(5, 5)
        style.FrameRounding       = 5
        style.ItemSpacing         = ImVec2(8, 6)
        style.TouchExtraPadding   = ImVec2(0, 0)
        style.IndentSpacing       = 25
        style.ScrollbarSize       = 15
        style.ScrollbarRounding   = 6
        style.GrabMinSize         = 5
        style.GrabRounding        = 3
        style.WindowTitleAlign    = ImVec2(0.5, 0.5)
        style.ButtonTextAlign     = ImVec2(0.5, 0.5)

    if ini.config.theme == 1 or ini.config.theme == nil then
        colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled] = ImVec4(1.815, 1.388, 1.051, 0.000)
        colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 0.93)
        colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
        colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.38)
        colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
        colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
        colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
        colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
        colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
        colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
        colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
        colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
        colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
        colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
        colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
        colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
        colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
        colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
        colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
        colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
        colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
        colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
        colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
    elseif ini.config.theme == 2 then
        colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled] = ImVec4(0.28, 0.56, 1.00, 1.00)
        colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 0.93)
        colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 0.00)
        colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
        colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
        colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
        colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
        colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
        colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
        colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
        colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
        colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
        colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
        colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
        colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
        colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
        colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
        colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
        colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
        colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
        colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
        colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
        colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
        colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
        colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
        colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
        colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
        colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
        colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
        colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
        colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
        colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
        colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
        colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
        colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
        colors[clr.TextSelectedBg]          = ImVec4(0.25, 1.00, 0.00, 0.43)
        colors[clr.ModalWindowDarkening]   = ImVec4(1.00, 0.98, 0.95, 0.73)
    elseif ini.config.theme == 3 then
        colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.00, 0.80, 0.38, 1.00)
        colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 0.93)
        colors[clr.ChildWindowBg]          = ImVec4(0.10, 0.10, 0.10, 0.00)
        colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 1.00)
        colors[clr.Border]                 = ImVec4(0.70, 0.70, 0.70, 0.40)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
        colors[clr.FrameBgHovered]         = ImVec4(0.19, 0.19, 0.19, 0.71)
        colors[clr.FrameBgActive]          = ImVec4(0.34, 0.34, 0.34, 0.79)
        colors[clr.TitleBg]                = ImVec4(0.00, 0.69, 0.33, 0.80)
        colors[clr.TitleBgActive]          = ImVec4(0.00, 0.74, 0.36, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.69, 0.33, 0.50)
        colors[clr.MenuBarBg]              = ImVec4(0.00, 0.80, 0.38, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.16, 0.16, 0.16, 1.00)
        colors[clr.ScrollbarGrab]          = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.00, 1.00, 0.48, 1.00)
        colors[clr.ComboBg]                = ImVec4(0.20, 0.20, 0.20, 0.99)
        colors[clr.CheckMark]              = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.SliderGrab]             = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.SliderGrabActive]       = ImVec4(0.00, 0.77, 0.37, 1.00)
        colors[clr.Button]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.ButtonHovered]          = ImVec4(0.00, 0.82, 0.39, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.00, 0.87, 0.42, 1.00)
        colors[clr.Header]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.HeaderHovered]          = ImVec4(0.00, 0.76, 0.37, 0.57)
        colors[clr.HeaderActive]           = ImVec4(0.00, 0.88, 0.42, 0.89)
        colors[clr.Separator]              = ImVec4(1.00, 1.00, 1.00, 0.40)
        colors[clr.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.60)
        colors[clr.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 0.80)
        colors[clr.ResizeGrip]             = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.ResizeGripHovered]      = ImVec4(0.00, 0.76, 0.37, 1.00)
        colors[clr.ResizeGripActive]       = ImVec4(0.00, 0.86, 0.41, 1.00)
        colors[clr.CloseButton]            = ImVec4(0.00, 0.82, 0.39, 1.00)
        colors[clr.CloseButtonHovered]     = ImVec4(0.00, 0.88, 0.42, 1.00)
        colors[clr.CloseButtonActive]      = ImVec4(0.00, 1.00, 0.48, 1.00)
        colors[clr.PlotLines]              = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(0.00, 0.74, 0.36, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.00, 0.69, 0.33, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(0.00, 0.80, 0.38, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(0.00, 0.69, 0.33, 0.72)
        colors[clr.ModalWindowDarkening]   = ImVec4(0.17, 0.17, 0.17, 0.48)
    elseif ini.config.theme == 4 then
        colors[clr.Text]					= ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]            = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.WindowBg]				= ImVec4(0.14, 0.12, 0.16, 0.93)
		colors[clr.ChildWindowBg]		 	= ImVec4(0.30, 0.20, 0.39, 0.00)
		colors[clr.PopupBg]					= ImVec4(0.05, 0.05, 0.10, 0.90)
		colors[clr.Border]					= ImVec4(0.89, 0.85, 0.92, 0.30)
		colors[clr.BorderShadow]			= ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]					= ImVec4(0.30, 0.20, 0.39, 1.00)
		colors[clr.FrameBgHovered]			= ImVec4(0.41, 0.19, 0.63, 0.68)
		colors[clr.FrameBgActive]		 	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.TitleBg]			   		= ImVec4(0.41, 0.19, 0.63, 0.45)
		colors[clr.TitleBgCollapsed]	  	= ImVec4(0.41, 0.19, 0.63, 0.35)
		colors[clr.TitleBgActive]		 	= ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.MenuBarBg]			 	= ImVec4(0.30, 0.20, 0.39, 0.57)
		colors[clr.ScrollbarBg]		   		= ImVec4(0.30, 0.20, 0.39, 1.00)
		colors[clr.ScrollbarGrab]		 	= ImVec4(0.41, 0.19, 0.63, 0.31)
		colors[clr.ScrollbarGrabHovered]  	= ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.ScrollbarGrabActive]   	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.CheckMark]			 	= ImVec4(0.56, 0.61, 1.00, 1.00)
		colors[clr.SliderGrab]				= ImVec4(0.41, 0.19, 0.63, 0.24)
		colors[clr.SliderGrabActive]	  	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.Button]					= ImVec4(0.41, 0.19, 0.63, 0.44)
		colors[clr.ButtonHovered]		 	= ImVec4(0.41, 0.19, 0.63, 0.86)
		colors[clr.ButtonActive]		  	= ImVec4(0.64, 0.33, 0.94, 1.00)
		colors[clr.Header]					= ImVec4(0.41, 0.19, 0.63, 0.76)
		colors[clr.HeaderHovered]		 	= ImVec4(0.41, 0.19, 0.63, 0.86)
		colors[clr.HeaderActive]		  	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.ResizeGrip]				= ImVec4(0.41, 0.19, 0.63, 0.20)
		colors[clr.ResizeGripHovered]	 	= ImVec4(0.41, 0.19, 0.63, 0.78)
		colors[clr.ResizeGripActive]	  	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.PlotLines]			 	= ImVec4(0.89, 0.85, 0.92, 0.63)
		colors[clr.PlotLinesHovered]	  	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.PlotHistogram]		 	= ImVec4(0.89, 0.85, 0.92, 0.63)
		colors[clr.PlotHistogramHovered]  	= ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.TextSelectedBg]			= ImVec4(0.41, 0.19, 0.63, 0.43)
		colors[clr.ModalWindowDarkening]  		= ImVec4(0.20, 0.20, 0.20, 0.35)
    elseif ini.config.theme == 5 then
        colors[clr.Text]					= ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.TextDisabled]   			= ImVec4(0.00, 0.35, 1.00, 0.78)
		colors[clr.WindowBg]				= ImVec4(1.00, 1.00, 1.00, 0.93)
		colors[clr.ChildWindowBg]					= ImVec4(0.96, 0.96, 0.96, 1.00)
		colors[clr.PopupBg]			  		= ImVec4(0.92, 0.92, 0.92, 1.00)
		colors[clr.Border]			   		= ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.BorderShadow]		 	= ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]			  		= ImVec4(0.68, 0.68, 0.68, 0.50)
		colors[clr.FrameBgHovered]	   		= ImVec4(0.82, 0.82, 0.82, 1.00)
		colors[clr.FrameBgActive]			= ImVec4(0.76, 0.76, 0.76, 1.00)
		colors[clr.TitleBg]			  		= ImVec4(0.00, 0.45, 1.00, 0.82)
		colors[clr.TitleBgCollapsed]	 	= ImVec4(0.00, 0.45, 1.00, 0.82)
		colors[clr.TitleBgActive]			= ImVec4(0.00, 0.45, 1.00, 0.82)
		colors[clr.MenuBarBg]				= ImVec4(0.00, 0.37, 0.78, 1.00)
		colors[clr.ScrollbarBg]		  		= ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.ScrollbarGrab]			= ImVec4(0.00, 0.35, 1.00, 0.78)
		colors[clr.ScrollbarGrabHovered] 	= ImVec4(0.00, 0.33, 1.00, 0.84)
		colors[clr.ScrollbarGrabActive]  	= ImVec4(0.00, 0.31, 1.00, 0.88)
		colors[clr.CheckMark]				= ImVec4(0.00, 0.49, 1.00, 0.59)
		colors[clr.SliderGrab]		   		= ImVec4(0.00, 0.49, 1.00, 0.59)
		colors[clr.SliderGrabActive]	 	= ImVec4(0.00, 0.39, 1.00, 0.71)
		colors[clr.Button]			   		= ImVec4(0.00, 0.49, 1.00, 0.59)
		colors[clr.ButtonHovered]			= ImVec4(0.00, 0.49, 1.00, 0.71)
		colors[clr.ButtonActive]		 	= ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.Header]			   		= ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.HeaderHovered]			= ImVec4(0.00, 0.49, 1.00, 0.71)
		colors[clr.HeaderActive]		 	= ImVec4(0.00, 0.49, 1.00, 0.78)
		colors[clr.Separator]			  	= ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.SeparatorHovered]	   	= ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.SeparatorActive]			= ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.ResizeGrip]		   		= ImVec4(0.00, 0.39, 1.00, 0.59)
		colors[clr.ResizeGripHovered]		= ImVec4(0.00, 0.27, 1.00, 0.59)
		colors[clr.ResizeGripActive]	 	= ImVec4(0.00, 0.25, 1.00, 0.63)
		colors[clr.PlotLines]				= ImVec4(0.00, 0.39, 1.00, 0.75)
		colors[clr.PlotLinesHovered]	 	= ImVec4(0.00, 0.39, 1.00, 0.75)
		colors[clr.PlotHistogram]			= ImVec4(0.00, 0.39, 1.00, 0.75)
		colors[clr.PlotHistogramHovered]	= ImVec4(0.00, 0.35, 0.92, 0.78)
		colors[clr.TextSelectedBg]			= ImVec4(0.00, 0.47, 1.00, 0.59)
		colors[clr.ModalWindowDarkening] 		= ImVec4(0.88, 0.88, 0.88, 0.35)

    else 
        ini.config.theme = 1
        style()
    end
end


function autoupdate(json_url, prefix, url)
    local dlstatus = require('moonloader').download_status
    local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
    if doesFileExist(json) then os.remove(json) end
    downloadUrlToFile(json_url, json,
      function(id, status, p1, p2)
        if status == dlstatus.STATUSEX_ENDDOWNLOAD then
          if doesFileExist(json) then
            local f = io.open(json, 'r')
            if f then
              local info = decodeJson(f:read('*a'))
              updatelink = info.updateurl
              updateversion = info.latest
              f:close()
              os.remove(json)
              if updateversion ~= thisScript().version then
                lua_thread.create(function(prefix)
                  local dlstatus = require('moonloader').download_status
                  local color = -1
                  sampAddChatMessage((prefix..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion), color)
                  wait(250)
                  downloadUrlToFile(updatelink, thisScript().path,
                    function(id3, status1, p13, p23)
                      if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                        print(string.format('Загружено %d из %d.', p13, p23))
                      elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                        print('Загрузка обновления завершена.')
                        sampAddChatMessage((prefix..'Обновление завершено!'), color)
                        updates.v = true
                        goupdatestatus = true
                        lua_thread.create(function() wait(500) thisScript():reload() end)
                      end
                      if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                        if goupdatestatus == nil then
                          sampAddChatMessage((prefix..'Обновление прошло неудачно. Запускаю устаревшую версию..'), color)
                          update = false
                        end
                      end
                    end
                  )
                  end, prefix
                )
              else
                update = false
                print('v'..thisScript().version..': Обновление не требуется.')
              end
            end
          else
            print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..url)
            update = false
          end
        end
      end
    )
    while update ~= false do wait(100) end
  end