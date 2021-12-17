//DEFINITIONS FOR ASSET DATUMS START HERE.


/datum/asset/simple/tgui
	keep_local_name = TRUE
	assets = list(
		"tgui.bundle.js" = file("tgui/public/tgui.bundle.js"),
		"tgui.bundle.css" = file("tgui/public/tgui.bundle.css"),
	)

/datum/asset/simple/tgui_panel
	keep_local_name = TRUE
	assets = list(
		"tgui-panel.bundle.js" = file("tgui/public/tgui-panel.bundle.js"),
		"tgui-panel.bundle.css" = file("tgui/public/tgui-panel.bundle.css"),
	)

/datum/asset/simple/inventory
	assets = list(
		"inventory-glasses.png" = 'icons/UI_Icons/inventory/glasses.png',
		"inventory-head.png" = 'icons/UI_Icons/inventory/head.png',
		"inventory-mask.png" = 'icons/UI_Icons/inventory/mask.png',
		"inventory-ears.png" = 'icons/UI_Icons/inventory/ears.png',
		"inventory-uniform.png" = 'icons/UI_Icons/inventory/uniform.png',
		"inventory-suit.png" = 'icons/UI_Icons/inventory/suit.png',
		"inventory-gloves.png" = 'icons/UI_Icons/inventory/gloves.png',
		"inventory-hand_l.png" = 'icons/UI_Icons/inventory/hand_l.png',
		"inventory-hand_r.png" = 'icons/UI_Icons/inventory/hand_r.png',
		"inventory-shoes.png" = 'icons/UI_Icons/inventory/shoes.png',
		"inventory-suit_storage.png" = 'icons/UI_Icons/inventory/suit_storage.png',
		"inventory-belt.png" = 'icons/UI_Icons/inventory/belt.png',
		"inventory-back.png" = 'icons/UI_Icons/inventory/back.png',
		"inventory-pocket.png" = 'icons/UI_Icons/inventory/pocket.png',
	)

/datum/asset/simple/minimap_blip
	assets = list(
		"alpha_engi" = 'icons/UI_Icons/minimap_blips/alpha_engi.png',
		"alpha_leader" = 'icons/UI_Icons/minimap_blips/alpha_leader.png',
		"alpha_medic" = 'icons/UI_Icons/minimap_blips/alpha_medic.png',
		"alpha_smargunner" = 'icons/UI_Icons/minimap_blips/alpha_smartgunner.png',
		"alpha_private" = 'icons/UI_Icons/minimap_blips/alpha_private.png',
		"bravo_engi" = 'icons/UI_Icons/minimap_blips/bravo_engi.png',
		"bravo_leader" = 'icons/UI_Icons/minimap_blips/bravo_leader.png',
		"bravo_medic" = 'icons/UI_Icons/minimap_blips/bravo_medic.png',
		"bravo_smargunner" = 'icons/UI_Icons/minimap_blips/bravo_smartgunner.png',
		"bravo_private" = 'icons/UI_Icons/minimap_blips/bravo_private.png',
		"charlie_engi" = 'icons/UI_Icons/minimap_blips/charlie_engi.png',
		"charlie_leader" = 'icons/UI_Icons/minimap_blips/charlie_leader.png',
		"charlie_medic" = 'icons/UI_Icons/minimap_blips/charlie_medic.png',
		"charlie_private" = 'icons/UI_Icons/minimap_blips/charlie_private.png',
		"charlie_smargunner" = 'icons/UI_Icons/minimap_blips/charlie_smartgunner.png',
		"delta_engi" = 'icons/UI_Icons/minimap_blips/delta_engi.png',
		"delta_leader" = 'icons/UI_Icons/minimap_blips/delta_leader.png',
		"delta_medic" = 'icons/UI_Icons/minimap_blips/delta_medic.png',
		"delta_private" = 'icons/UI_Icons/minimap_blips/delta_private.png',
		"delta_smargunner" = 'icons/UI_Icons/minimap_blips/delta_smartgunner.png',
		"blue_disk" = 'icons/UI_Icons/minimap_blips/blue_disk.png',
		"red_disk" = 'icons/UI_Icons/minimap_blips/red_disk.png',
		"green_disk" = 'icons/UI_Icons/minimap_blips/green_disk.png',
		"nuke" = 'icons/UI_Icons/minimap_blips/nuke.png',
		"miner_phoron_on" = 'icons/UI_Icons/minimap_blips/miner_phoron_on.png',
		"miner_phoron_off" = 'icons/UI_Icons/minimap_blips/miner_phoron_off.png',
		"miner_platinium_on" = 'icons/UI_Icons/minimap_blips/miner_platinium_on.png',
		"miner_platinium_off" = 'icons/UI_Icons/minimap_blips/miner_platinium_off.png',
		"defibbable" = 'icons/UI_Icons/minimap_blips/defibbable.png',
		"undefibbable" = 'icons/UI_Icons/minimap_blips/undefibbable.png',
		"requisition" = 'icons/UI_Icons/minimap_blips/requisition.png',
		"cse" = 'icons/UI_Icons/minimap_blips/cse.png',
		"generator" = 'icons/UI_Icons/minimap_blips/generator.png',
		"fieldcommander" = 'icons/UI_Icons/minimap_blips/fieldcommander.png',
		"staffofficer" = 'icons/UI_Icons/minimap_blips/staffofficer.png',
		"synth" = 'icons/UI_Icons/minimap_blips/synth.png',
		"private" = 'icons/UI_Icons/minimap_blips/private.png',
		"xeno" = 'icons/UI_Icons/minimap_blips/xeno.png',
		"xenoqueen" = 'icons/UI_Icons/minimap_blips/xenoqueen.png',
		"xenominion" = 'icons/UI_Icons/minimap_blips/xenominion.png',
		"xenoking" = 'icons/UI_Icons/minimap_blips/xenoking.png',
		"xenoshrike" = 'icons/UI_Icons/minimap_blips/xenoshrike.png',
		"xenoleader" = 'icons/UI_Icons/minimap_blips/xenoleader.png',
		"player" = 'icons/UI_Icons/minimap_blips/player.png',
	)

/datum/asset/simple/irv
	assets = list(
		"jquery-ui.custom-core-widgit-mouse-sortable-min.js" = 'html/IRV/jquery-ui.custom-core-widgit-mouse-sortable-min.js',
	)

/datum/asset/group/irv
	children = list(
		/datum/asset/simple/jquery,
		/datum/asset/simple/irv,
	)


/datum/asset/simple/jquery
	legacy = TRUE
	assets = list(
		"jquery.min.js" = 'html/jquery.min.js',
	)

/datum/asset/simple/namespaced/fontawesome
	legacy = TRUE //remove on tgui4
	assets = list(
		"fa-regular-400.eot"  = 'html/font-awesome/webfonts/fa-regular-400.eot',
		"fa-regular-400.woff" = 'html/font-awesome/webfonts/fa-regular-400.woff',
		"fa-solid-900.eot"    = 'html/font-awesome/webfonts/fa-solid-900.eot',
		"fa-solid-900.woff"   = 'html/font-awesome/webfonts/fa-solid-900.woff',
		"v4shim.css"          = 'html/font-awesome/css/v4-shims.min.css'
	)
	parents = list("font-awesome.css" = 'html/font-awesome/css/all.min.css')

/datum/asset/simple/namespaced/tgfont
	assets = list(
		"tgfont.eot" = file("tgui/packages/tgfont/dist/tgfont.eot"),
		"tgfont.woff2" = file("tgui/packages/tgfont/dist/tgfont.woff2"),
	)
	parents = list(
		"tgfont.css" = file("tgui/packages/tgfont/dist/tgfont.css")
	)

/datum/asset/spritesheet/chat
	name = "chat"

/datum/asset/spritesheet/chat/register()
	InsertAll("emoji", 'icons/misc/emoji.dmi')
	// pre-loading all lanugage icons also helps to avoid meta
	InsertAll("language", 'icons/misc/language.dmi')
	// catch languages which are pulling icons from another file
	for(var/path in typesof(/datum/language))
		var/datum/language/L = path
		var/icon = initial(L.icon)
		if (icon != 'icons/misc/language.dmi')
			var/icon_state = initial(L.icon_state)
			Insert("language-[icon_state]", icon, icon_state=icon_state)
	..()

/datum/asset/simple/minimap
	var/name = "minimap"

/datum/asset/simple/minimap/register()
	for(var/datum/game_map/GM as anything in SSminimap.minimaps)
		var/asset = GM.generated_map
		if (!asset)
			continue
		asset = fcopy_rsc(asset) //dedupe
		var/asset_name = SANITIZE_FILENAME("minimap.[GM.name].png")
		var/datum/asset_cache_item/ACI = SSassets.transport.register_asset(asset_name, asset)
		ACI.keep_local_name = TRUE
		assets[asset_name] = ACI

/datum/asset/simple/namespaced/common
	assets = list("padlock.png"	= 'html/images/padlock.png')
	parents = list("common.css" = 'html/browser/common.css')

/datum/asset/simple/permissions
	assets = list(
		"search.js" = 'html/browser/search.js',
		"panels.css" = 'html/browser/panels.css'
	)

/datum/asset/group/permissions
	children = list(
		/datum/asset/simple/permissions,
		/datum/asset/simple/namespaced/common,
	)

/datum/asset/simple/notes
	assets = list(
		"high_button.png" = 'html/images/high_button.png',
		"medium_button.png" = 'html/images/medium_button.png',
		"minor_button.png" = 'html/images/minor_button.png',
		"none_button.png" = 'html/images/none_button.png',
	)


//this exists purely to avoid meta by pre-loading all language icons.
/datum/asset/language/register()
	for(var/path in typesof(/datum/language))
		set waitfor = FALSE
		var/datum/language/L = new path ()
		L.get_icon()

/datum/asset/simple/orbit
	assets = list(
		"ghost.png" = 'html/images/ghost.png'
	)

/datum/asset/spritesheet/blessingmenu
	name = "blessingmenu"

/datum/asset/spritesheet/blessingmenu/register()
	InsertAll("", 'icons/UI_Icons/buyable_icons.dmi')
	..()
