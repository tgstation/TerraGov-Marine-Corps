//DEFINITIONS FOR ASSET DATUMS START HERE.

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
	assets = list(
		"fa-regular-400.ttf" = 'html/font-awesome/webfonts/fa-regular-400.ttf',
		"fa-solid-900.ttf" = 'html/font-awesome/webfonts/fa-solid-900.ttf',
		"fa-v4compatibility.ttf" = 'html/font-awesome/webfonts/fa-v4compatibility.ttf',
		"v4shim.css" = 'html/font-awesome/css/v4-shims.min.css',
	)
	parents = list("font-awesome.css" = 'html/font-awesome/css/all.min.css')

/datum/asset/simple/namespaced/tgfont
	assets = list(
		"tgfont.eot" = file("tgui/packages/tgfont/static/tgfont.eot"),
		"tgfont.woff2" = file("tgui/packages/tgfont/static/tgfont.woff2"),
	)
	parents = list(
		"tgfont.css" = file("tgui/packages/tgfont/static/tgfont.css")
	)

/datum/asset/spritesheet/chat
	name = "chat"

/datum/asset/spritesheet/chat/create_spritesheets()
	InsertAll("emoji", EMOJI_SET)
	// pre-loading all lanugage icons also helps to avoid meta
	InsertAll("language", 'icons/misc/language.dmi')
	// catch languages which are pulling icons from another file
	for(var/path in typesof(/datum/language))
		var/datum/language/L = path
		var/icon = initial(L.icon)
		if (icon != 'icons/misc/language.dmi')
			var/icon_state = initial(L.icon_state)
			Insert("language-[icon_state]", icon, icon_state=icon_state)

/datum/asset/simple/namespaced/common
	assets = list("padlock.png" = 'html/images/padlock.png')
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
/datum/asset/spritesheet/blessingmenu
	name = "blessingmenu"

/datum/asset/spritesheet/blessingmenu/create_spritesheets()
	InsertAll("", 'icons/UI_Icons/buyable_icons.dmi')

/datum/asset/spritesheet/mechaarmor
	name = "mechaarmor"

/datum/asset/spritesheet/mechaarmor/create_spritesheets()
	InsertAll("", 'icons/UI_Icons/mecha/armor.dmi')

/datum/asset/spritesheet/mech_builder
	name = "mech_builder"

/datum/asset/spritesheet/mech_builder/create_spritesheets()
	InsertAll("", 'icons/mecha/mecha_equipment_64x32.dmi')

/datum/asset/spritesheet/mech_ammo
	name = "mech_ammo"

/datum/asset/spritesheet/mech_ammo/create_spritesheets()
	InsertAll("", 'icons/mecha/mecha_ammo.dmi')

/datum/asset/spritesheet/hivestatus
	name = "hivestatus"

/datum/asset/spritesheet/hivestatus/create_spritesheets()
	InsertAll("", 'icons/UI_Icons/hive_status_icons.dmi')

/datum/asset/spritesheet/campaign
	name = "campaign_base"
	///The dmi file used for this spritesheet
	var/icon_sheet
	///The list of icon names to use for this sprite sheet
	var/list/icon_names

/datum/asset/spritesheet/campaign/create_spritesheets()
	for(var/icon_name in icon_names)
		var/icon/iconNormal = icon(icon_sheet, icon_name, SOUTH)
		Insert(icon_name, iconNormal)

		var/icon/iconBig = icon(icon_sheet, icon_name, SOUTH)
		iconBig.Scale(iconBig.Width()*2, iconBig.Height()*2)
		Insert("[icon_name]_big", iconBig)

/datum/asset/spritesheet/campaign/missions
	name = "campaign_missions"
	icon_sheet = 'icons/UI_Icons/campaign/mission_icons.dmi'

/datum/asset/spritesheet/campaign/missions/New()
	icon_names = GLOB.campaign_mission_icons
	return ..()
/datum/asset/spritesheet/campaign/assets
	name = "campaign_assets"
	icon_sheet = 'icons/UI_Icons/campaign/asset_icons.dmi'

/datum/asset/spritesheet/campaign/assets/New()
	icon_names = GLOB.campaign_asset_icons
	return ..()

/datum/asset/spritesheet/campaign/perks
	name = "campaign_perks"
	icon_sheet = 'icons/UI_Icons/campaign/perk_icons.dmi'

/datum/asset/spritesheet/campaign/perks/New()
	icon_names = GLOB.campaign_perk_icons
	return ..()

/datum/asset/spritesheet/campaign/loadout_items
	name = "campaign_loadout_items"
	icon_sheet = 'icons/UI_Icons/campaign/loadout_item_icons.dmi'

/datum/asset/spritesheet/campaign/loadout_items/New()
	icon_names = GLOB.campaign_loadout_item_icons
	return ..()

/datum/asset/simple/particle_editor
	assets = list(
		"motion" = 'icons/ui_icons/particle_editor/motion.png',

		"uniform" = 'icons/ui_icons/particle_editor/uniform_rand.png',
		"normal" ='icons/ui_icons/particle_editor/normal_rand.png',
		"linear" = 'icons/ui_icons/particle_editor/linear_rand.png',
		"square_rand" = 'icons/ui_icons/particle_editor/square_rand.png',

		"num" = 'icons/ui_icons/particle_editor/num_gen.png',
		"vector" = 'icons/ui_icons/particle_editor/vector_gen.png',
		"box" = 'icons/ui_icons/particle_editor/box_gen.png',
		"circle" = 'icons/ui_icons/particle_editor/circle_gen.png',
		"sphere" = 'icons/ui_icons/particle_editor/sphere_gen.png',
		"square" = 'icons/ui_icons/particle_editor/square_gen.png',
		"cube" = 'icons/ui_icons/particle_editor/cube_gen.png',
	)

/datum/asset/simple/paper
	assets = list(
		"ntlogo.png" = 'html/images/ntlogo.png',
		"tgmclogo.png" = 'html/images/tgmclogo.png',
	)
