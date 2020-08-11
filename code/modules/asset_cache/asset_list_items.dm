//DEFINITIONS FOR ASSET DATUMS START HERE.

/datum/asset/simple/tgui
	assets = list(
		"tgui.bundle.js" = 'tgui/packages/tgui/public/tgui.bundle.js',
		"tgui.bundle.css" = 'tgui/packages/tgui/public/tgui.bundle.css',
	)

/datum/asset/simple/irv
	assets = list(
		"jquery-ui.custom-core-widgit-mouse-sortable-min.js" = 'html/IRV/jquery-ui.custom-core-widgit-mouse-sortable-min.js',
	)

/datum/asset/group/irv
	children = list(
		/datum/asset/simple/jquery,
		/datum/asset/simple/irv
	)

/datum/asset/simple/changelog
	assets = list(
		"88x31.png" = 'html/images/88x31.png',
		"bug-minus.png" = 'html/images/bug-minus.png',
		"cross-circle.png" = 'html/images/cross-circle.png',
		"hard-hat-exclamation.png" = 'html/images/hard-hat-exclamation.png',
		"image-minus.png" = 'html/images/image-minus.png',
		"image-plus.png" = 'html/images/image-plus.png',
		"music-minus.png" = 'html/images/music-minus.png',
		"music-plus.png" = 'html/images/music-plus.png',
		"tick-circle.png" = 'html/images/tick-circle.png',
		"wrench-screwdriver.png" = 'html/images/wrench-screwdriver.png',
		"spell-check.png" = 'html/images/spell-check.png',
		"burn-exclamation.png" = 'html/images/burn-exclamation.png',
		"chevron.png" = 'html/images/chevron.png',
		"chevron-expand.png" = 'html/images/chevron-expand.png',
		"scales.png" = 'html/images/scales.png',
		"coding.png" = 'html/images/coding.png',
		"ban.png" = 'html/images/ban.png',
		"chrome-wrench.png" = 'html/images/chrome-wrench.png',
		"changelog.css" = 'html/browser/changelog.css'
	)

/datum/asset/group/goonchat
	children = list(
		/datum/asset/simple/jquery,
		/datum/asset/simple/goonchat,
		/datum/asset/spritesheet/goonchat,
		/datum/asset/simple/fontawesome
	)

/datum/asset/simple/jquery
	assets = list(
		"jquery.min.js"            = 'code/modules/goonchat/browserassets/js/jquery.min.js',
	)

/datum/asset/simple/goonchat
	assets = list(
		"json2.min.js"             = 'code/modules/goonchat/browserassets/js/json2.min.js',
		"browserOutput.js"         = 'code/modules/goonchat/browserassets/js/browserOutput.js',
		"browserOutput.css"	       = 'code/modules/goonchat/browserassets/css/browserOutput.css',
		"browserOutput_white.css"  = 'code/modules/goonchat/browserassets/css/browserOutput_white.css',
	)

/datum/asset/simple/fontawesome
	assets = list(
		"fa-regular-400.eot"  = 'html/font-awesome/webfonts/fa-regular-400.eot',
		"fa-regular-400.woff" = 'html/font-awesome/webfonts/fa-regular-400.woff',
		"fa-solid-900.eot"    = 'html/font-awesome/webfonts/fa-solid-900.eot',
		"fa-solid-900.woff"   = 'html/font-awesome/webfonts/fa-solid-900.woff',
		"font-awesome.css"    = 'html/font-awesome/css/all.min.css',
		"v4shim.css"          = 'html/font-awesome/css/v4-shims.min.css'
	)

/datum/asset/spritesheet/goonchat
	name = "chat"

/datum/asset/spritesheet/goonchat/register()
	InsertAll("emoji", 'icons/UI_Icons/emoji.dmi')

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

/datum/asset/simple/permissions
	assets = list(
		"padlock.png"	= 'html/images/padlock.png'
	)

/datum/asset/simple/notes
	assets = list(
		"high_button.png" = 'html/images/high_button.png',
		"medium_button.png" = 'html/images/medium_button.png',
		"minor_button.png" = 'html/images/minor_button.png',
		"none_button.png" = 'html/images/none_button.png',
	)

/datum/asset/spritesheet/simple/pills
	name ="pills"
	assets = list(
		"pill1" = 'icons/UI_Icons/Pills/pill1.png',
		"pill2" = 'icons/UI_Icons/Pills/pill2.png',
		"pill3" = 'icons/UI_Icons/Pills/pill3.png',
		"pill4" = 'icons/UI_Icons/Pills/pill4.png',
		"pill5" = 'icons/UI_Icons/Pills/pill5.png',
		"pill6" = 'icons/UI_Icons/Pills/pill6.png',
		"pill7" = 'icons/UI_Icons/Pills/pill7.png',
		"pill8" = 'icons/UI_Icons/Pills/pill8.png',
		"pill9" = 'icons/UI_Icons/Pills/pill9.png',
		"pill10" = 'icons/UI_Icons/Pills/pill10.png',
		"pill11" = 'icons/UI_Icons/Pills/pill11.png',
		"pill12" = 'icons/UI_Icons/Pills/pill12.png',
		"pill13" = 'icons/UI_Icons/Pills/pill13.png',
		"pill14" = 'icons/UI_Icons/Pills/pill14.png',
		"pill15" = 'icons/UI_Icons/Pills/pill15.png',
		"pill16" = 'icons/UI_Icons/Pills/pill16.png',
		"pill17" = 'icons/UI_Icons/Pills/pill17.png',
		"pill18" = 'icons/UI_Icons/Pills/pill18.png',
		"pill19" = 'icons/UI_Icons/Pills/pill19.png',
		"pill20" = 'icons/UI_Icons/Pills/pill20.png',
		"pill21" = 'icons/UI_Icons/Pills/pill21.png',
		"pill22" = 'icons/UI_Icons/Pills/pill22.png',
	)

//this exists purely to avoid meta by pre-loading all language icons.
/datum/asset/language/register()
	for(var/path in typesof(/datum/language))
		set waitfor = FALSE
		var/datum/language/L = new path ()
		L.get_icon()

/datum/asset/spritesheet/pipes
	name = "pipes"

/datum/asset/spritesheet/pipes/register()
	for (var/each in list(
			'icons/obj/atmospherics/pipes/pipe_item.dmi',
			'icons/obj/pipes/disposal.dmi',
			// 'icons/obj/pipes/transit_tube.dmi',
			// 'icons/obj/plumbing/fluid_ducts.dmi',
		))
		InsertAll("", each, GLOB.alldirs)
	..()

/datum/asset/spritesheet/vending
	name = "vending"

/datum/asset/spritesheet/vending/register()
	for (var/k in GLOB.vending_products)
		var/atom/item = k
		if (!ispath(item, /atom))
			continue

		var/icon_file = initial(item.icon)
		var/icon_state = initial(item.icon_state)
		var/icon/I

		var/icon_states_list = icon_states(icon_file)
		if(icon_state in icon_states_list)
			I = icon(icon_file, icon_state, SOUTH)
			var/c = initial(item.color)
			if (!isnull(c) && c != "#FFFFFF")
				I.Blend(c, ICON_MULTIPLY)
		else
			var/icon_states_string
			for (var/an_icon_state in icon_states_list)
				if (!icon_states_string)
					icon_states_string = "[json_encode(an_icon_state)](\ref[an_icon_state])"
				else
					icon_states_string += ", [json_encode(an_icon_state)](\ref[an_icon_state])"
			stack_trace("[item] does not have a valid icon state, icon=[icon_file], icon_state=[json_encode(icon_state)](\ref[icon_state]), icon_states=[icon_states_string]")
			I = icon('icons/turf/floors.dmi', "", SOUTH)

		var/imgid = replacetext(replacetext("[item]", "/obj/item/", ""), "/", "-")

		Insert(imgid, I)
	return ..()

/datum/asset/simple/orbit
	assets = list(
		"ghost.png"	= 'html/images/ghost.png'
	)

/datum/asset/simple/vv
	assets = list(
		"view_variables.css" = 'html/admin/view_variables.css'
	)

/datum/asset/spritesheet/sheetmaterials
	name = "sheetmaterials"

/datum/asset/spritesheet/sheetmaterials/register()
	InsertAll("", 'icons/obj/stack_objects.dmi')

	..()
