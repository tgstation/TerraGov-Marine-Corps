/atom/movable/screen/text/lobby/clickable/MouseEntered(location, control, params)
	. = ..()
	color = COLOR_RUTGMC_RED

/atom/movable/screen/text/lobby/clickable/setup_character
	maptext = "<span class='maptext' style=font-size:6px>ПЕРСОНАЖ: ...</span>"

/atom/movable/screen/text/lobby/clickable/setup_character/set_text()
	maptext = "<span class='maptext' style=font-size:6px>ПЕРСОНАЖ: [hud?.mymob.client ? hud.mymob.client.prefs.real_name : "Unknown User"]</span>"

/atom/movable/screen/text/lobby/clickable/join_game
	maptext = "<span class='maptext' style=font-size:8px>ПРИСОЕДИНИТЬСЯ</span>"

/atom/movable/screen/text/lobby/clickable/observe
	maptext = "<span class='maptext' style=font-size:8px>НАБЛЮДАТЬ</span>"

/atom/movable/screen/text/lobby/clickable/ready
	maptext = "<span class='maptext' style=font-size:8px>ВЫ: НЕ ГОТОВЫ</span>"

/atom/movable/screen/text/lobby/clickable/ready/set_text()
	var/mob/new_player/player = hud.mymob
	maptext = "<span class='maptext' style=font-size:8px>ВЫ: [player.ready ? "" : "НЕ "]ГОТОВЫ</span>"

/atom/movable/screen/text/lobby/clickable/manifest
	maptext = "<span class='maptext' style=font-size:8px>СПИСОК ИГРОКОВ</span>"

/atom/movable/screen/text/lobby/clickable/background
	maptext = "<span class='maptext' style=font-size:8px>ПРЕДЫСТОРИЯ</span>"

/atom/movable/screen/text/lobby/clickable/changelog
	maptext = "<span class='maptext' style=font-size:8px>ЛОГ ИЗМЕНЕНИЙ</span>"

/atom/movable/screen/text/lobby/clickable/polls/fetch_polls()
	var/mob/new_player/player = hud.mymob
	var/hasnewpolls = player.check_playerpolls()
	if(isnull(hasnewpolls))
		maptext = "<span class='maptext' style=font-size:8px>НЕТ БАЗЫ ДАННЫХ!</span>"
		return
	maptext = "<span class='maptext' style=font-size:8px>ПОКАЗАТЬ ОПРОСЫ[hasnewpolls ? " (NEW!)" : ""]</span>"
