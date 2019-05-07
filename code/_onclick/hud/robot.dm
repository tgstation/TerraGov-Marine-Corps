/obj/screen/robot
	icon = 'icons/mob/screen/cyborg.dmi'

/obj/screen/robot/Click()
	if(!iscyborg(usr))
		return TRUE

/obj/screen/robot/module
	name = "cyborg module"
	icon_state = "no_mod"
	layer = ABOVE_HUD_LAYER

/obj/screen/robot/cyborg_module/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/R = usr
	if(R.module)
		return TRUE
	R.pick_module()

/obj/screen/robot/module
	name = "module1"
	icon_state = "inv1"
	var/toggle_num = 1

/obj/screen/robot/module/Initialize()
	. = ..()
	name = "module[toggle_num]"
	icon_state = "inv[toggle_num]"

/obj/screen/robot/module/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/R = usr
	R.toggle_module(toggle_num)

/obj/screen/robot/module/two
	toggle_num = 2

/obj/screen/robot/module/three
	toggle_num = 3

/obj/screen/robot/radio
	name = "radio"
	icon_state = "radio"
	layer = ABOVE_HUD_LAYER

/obj/screen/robot/radio/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/R = usr
	R.radio_menu()

/obj/screen/robot/store
	name = "store"
	icon_state = "store"

/obj/screen/robot/store/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/R = usr
	R.uneq_active()

/obj/screen/robot/panel
	name = "panel"
	icon_state = "panel"

/obj/screen/robot/panel/Click()
	. = ..()
	if(.)
		return
	var/mob/living/silicon/robot/R = usr
	R.installed_modules()

/datum/hud/robot/New(mob/living/silicon/robot/owner)
	..()
	var/obj/screen/using

//Radio
	using = new /obj/screen/robot/radio()
	using.screen_loc = ui_movi
	static_inventory += using

//Module select

	using = new /obj/screen/robot/module()
	using.screen_loc = ui_inv1
	owner.inv1 = using
	static_inventory += using

	using = new /obj/screen/robot/module/two()
	using.screen_loc = ui_inv2
	owner.inv2 = using
	static_inventory += using

	using = new /obj/screen/robot/module/three()
	using.screen_loc = ui_inv3
	owner.inv3 = using
	static_inventory += using

//End of module select

//Intent
	using = new /obj/screen/act_intent()
	using.icon = 'icons/mob/screen/cyborg.dmi'
	using.icon_state = owner.a_intent
	static_inventory += using
	action_intent = using

//Cell
	owner.cells = new /obj/screen()
	owner.cells.icon = 'icons/mob/screen/cyborg.dmi'
	owner.cells.icon_state = "charge-empty"
	owner.cells.name = "cell"
	owner.cells.screen_loc = ui_toxin
	infodisplay += owner.cells

//Health
	healths = new /obj/screen/healths/robot()
	infodisplay += healths

//Installed Module
	owner.hands = new /obj/screen/robot/cyborg_module()
	owner.hands.screen_loc = ui_borg_module
	static_inventory += owner.hands

//Module Panel
	using = new /obj/screen/robot/panel()
	using.screen_loc = ui_borg_panel
	static_inventory += using

//Store
	module_store_icon = new /obj/screen/robot/store()
	module_store_icon.screen_loc = ui_borg_store
	static_inventory += module_store_icon

//Temp
	bodytemp_icon = new /obj/screen/bodytemp()
	bodytemp_icon.icon = 'icons/mob/screen/cyborg.dmi'
	bodytemp_icon.screen_loc = ui_borg_temp
	infodisplay += bodytemp_icon

	oxygen_icon = new /obj/screen/oxygen()
	oxygen_icon.icon = 'icons/mob/screen/cyborg.dmi'
	infodisplay += oxygen_icon

	fire_icon = new /obj/screen/fire()
	fire_icon.icon = 'icons/mob/screen/cyborg.dmi'
	infodisplay += fire_icon

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = 'icons/mob/screen/cyborg.dmi'
	pull_icon.screen_loc = ui_borg_pull
	static_inventory += pull_icon

	zone_sel = new /obj/screen/zone_sel/robot()
	zone_sel.update_icon(owner)
	static_inventory += zone_sel


/mob/living/silicon/robot/create_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/robot(src)



/datum/hud/robot/persistant_inventory_update()
	if(!mymob)
		return
	var/mob/living/silicon/robot/R = mymob
	if(hud_shown)
		if(R.module_state_1)
			R.module_state_1.screen_loc = ui_inv1
			R.client.screen += R.module_state_1
		if(R.module_state_2)
			R.module_state_2.screen_loc = ui_inv2
			R.client.screen += R.module_state_2
		if(R.module_state_3)
			R.module_state_3.screen_loc = ui_inv3
			R.client.screen += R.module_state_3
	else
		if(R.module_state_1)
			R.module_state_1.screen_loc = null
		if(R.module_state_2)
			R.module_state_2.screen_loc = null
		if(R.module_state_3)
			R.module_state_3.screen_loc = null

