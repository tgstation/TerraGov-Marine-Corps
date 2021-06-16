//DEFINITIONS FOR ASSET DATUMS START HERE.

/datum/asset/simple/tgui_common
	keep_local_name = TRUE
	assets = list(
		"tgui-common.bundle.js" = 'tgui/public/tgui-common.bundle.js',
	)

/datum/asset/simple/tgui
	keep_local_name = TRUE
	assets = list(
		"tgui.bundle.js" = 'tgui/public/tgui.bundle.js',
		"tgui.bundle.css" = 'tgui/public/tgui.bundle.css',
	)

/datum/asset/simple/tgui_panel
	keep_local_name = TRUE
	assets = list(
		"tgui-panel.bundle.js" = 'tgui/public/tgui-panel.bundle.js',
		"tgui-panel.bundle.css" = 'tgui/public/tgui-panel.bundle.css',
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
		"tgfont.eot" = 'tgui/packages/tgfont/dist/tgfont.eot',
		"tgfont.woff2" = 'tgui/packages/tgfont/dist/tgfont.woff2',
	)
	parents = list("tgfont.css" = 'tgui/packages/tgfont/dist/tgfont.css')

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
