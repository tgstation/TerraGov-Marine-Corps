/datum/hud/robot/New(mob/living/silicon/robot/owner)
	..()
	var/obj/screen/using

//Radio
	using = new /obj/screen()
	using.name = "radio"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "radio"
	using.screen_loc = ui_movi
	using.layer = ABOVE_HUD_LAYER
	static_inventory += using

//Module select

	using = new /obj/screen()
	using.name = "module1"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv1"
	using.screen_loc = ui_inv1
	using.layer = ABOVE_HUD_LAYER
	owner.inv1 = using
	static_inventory += using

	using = new /obj/screen()
	using.name = "module2"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv2"
	using.screen_loc = ui_inv2
	using.layer = ABOVE_HUD_LAYER
	owner.inv2 = using
	static_inventory += using

	using = new /obj/screen()
	using.name = "module3"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv3"
	using.screen_loc = ui_inv3
	using.layer = ABOVE_HUD_LAYER
	owner.inv3 = using
	static_inventory += using

//End of module select

//Intent
	using = new /obj/screen/act_intent()
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "intent_"+owner.a_intent
	static_inventory += using
	action_intent = using

//Cell
	owner.cells = new /obj/screen()
	owner.cells.icon = 'icons/mob/screen1_robot.dmi'
	owner.cells.icon_state = "charge-empty"
	owner.cells.name = "cell"
	owner.cells.screen_loc = ui_toxin
	infodisplay += owner.cells

//Health
	healths = new /obj/screen/healths/robot()
	infodisplay += healths

//Installed Module
	owner.hands = new /obj/screen()
	owner.hands.icon = 'icons/mob/screen1_robot.dmi'
	owner.hands.icon_state = "nomod"
	owner.hands.name = "module"
	owner.hands.screen_loc = ui_borg_module
	static_inventory += owner.hands

//Module Panel
	using = new /obj/screen()
	using.name = "panel"
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "panel"
	using.screen_loc = ui_borg_panel
	using.layer = HUD_LAYER
	static_inventory += using

//Store
	module_store_icon = new /obj/screen()
	module_store_icon.icon = 'icons/mob/screen1_robot.dmi'
	module_store_icon.icon_state = "store"
	module_store_icon.name = "store"
	module_store_icon.screen_loc = ui_borg_store
	static_inventory += module_store_icon

//Temp
	bodytemp_icon = new /obj/screen/bodytemp()
	bodytemp_icon.screen_loc = ui_borg_temp
	infodisplay += bodytemp_icon

	oxygen_icon = new /obj/screen/oxygen()
	oxygen_icon.icon = 'icons/mob/screen1_robot.dmi'
	infodisplay += oxygen_icon

	fire_icon = new /obj/screen/fire()
	fire_icon.icon = 'icons/mob/screen1_robot.dmi'
	infodisplay += fire_icon

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = 'icons/mob/screen1_robot.dmi'
	pull_icon.screen_loc = ui_borg_pull
	static_inventory += pull_icon

	zone_sel = new /obj/screen/zone_sel/robot()
	zone_sel.update_icon(owner)
	static_inventory += zone_sel

	//Handle the gun settings buttons
	gun_setting_icon = new /obj/screen/gun/mode()
	gun_setting_icon.update_icon(owner)
	static_inventory += gun_setting_icon

	gun_item_use_icon = new /obj/screen/gun/item()
	gun_item_use_icon.update_icon(owner)
	static_inventory += gun_item_use_icon

	gun_move_icon = new /obj/screen/gun/move()
	gun_move_icon.update_icon(owner)
	static_inventory +=	gun_move_icon

	gun_run_icon = new /obj/screen/gun/run()
	gun_run_icon.update_icon(owner)
	static_inventory +=	gun_run_icon



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

