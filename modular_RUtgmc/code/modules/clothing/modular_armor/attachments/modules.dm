/obj/item/armor_module/module/style/light_armor
	soft_armor = list(MELEE = 40, BULLET = 60, LASER = 60, ENERGY = 50, BOMB = 45, BIO = 45, FIRE = 45, ACID = 50)

/obj/item/armor_module/module/style/heavy_armor
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 50, ACID = 60)

/obj/item/armor_module/module/motion_detector
	name = "Tactical sensor helmet module"
	desc = "Help you to detect the xeno in the darkness."
	icon = 'modular_RUtgmc/icons/mob/modular/modular_armor_modules.dmi'
	icon_state = "mod_head_scanner"
	item_state = "mod_head_scanner_a"
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_APPLY_ON_MOB
	slot = ATTACHMENT_SLOT_HEAD_MODULE
	prefered_slot = SLOT_HEAD

	/// Who's using this item
	var/mob/living/carbon/human/operator
	///The range of this motion detector
	var/range = 16
	//таймер для работы модуля
	var/motion_timer = null
	//время через которое будет срабатывать модуль
	var/scan_time = 2 SECONDS
	///The time needed after the last move to not be detected by this motion detector
	var/move_sensitivity = 1 SECONDS
	///The list of all the blips
	var/list/obj/effect/blip/blips_list = list()

/obj/item/armor_module/module/motion_detector/Destroy()
	stop_and_clean()
	return ..()

/obj/item/armor_module/module/motion_detector/on_attach(obj/item/attaching_to, mob/user)
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_UNEQUIPPED, PROC_REF(stop_and_clean))

/obj/item/armor_module/module/motion_detector/on_detach(obj/item/detaching_from, mob/user)
	UnregisterSignal(parent, COMSIG_ITEM_UNEQUIPPED, PROC_REF(stop_and_clean))
	stop_and_clean()
	return ..()

//убираем графическую хуйню и останавливает сканирование.
/obj/item/armor_module/module/motion_detector/proc/stop_and_clean()
	SIGNAL_HANDLER

	active = FALSE
	clean_blips()
	operator = null
	if(motion_timer)
		deltimer(motion_timer)
		motion_timer = null


//вкл-выкл модуль
/obj/item/armor_module/module/motion_detector/activate(mob/living/user)
	active = !active
	to_chat(user, span_notice("You toggle \the [src]. [active ? "enabling" : "disabling"] it."))
	if(active)
		operator = user
		if(!motion_timer)
			motion_timer = addtimer(CALLBACK(src, PROC_REF(do_scan)), scan_time, TIMER_LOOP|TIMER_STOPPABLE)
	else
		stop_and_clean()


/obj/item/armor_module/module/motion_detector/proc/do_scan()
	if(!operator?.client || operator?.stat != CONSCIOUS)
		stop_and_clean()
		return
	var/hostile_detected = FALSE
	for (var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(operator, range))
		if(nearby_human == operator)
			continue
		if(nearby_human.last_move_time + move_sensitivity < world.time)
			continue
		if(!hostile_detected && (!operator.wear_id || !nearby_human.wear_id || nearby_human.wear_id.iff_signal != operator.wear_id.iff_signal))
			hostile_detected = TRUE
		prepare_blip(nearby_human, nearby_human.wear_id?.iff_signal & operator.wear_id?.iff_signal ? MOTION_DETECTOR_FRIENDLY : MOTION_DETECTOR_HOSTILE)
	for (var/mob/living/carbon/xenomorph/nearby_xeno AS in cheap_get_xenos_near(operator, range))
		if(!hostile_detected)
			hostile_detected = TRUE
		if(nearby_xeno.last_move_time + move_sensitivity < world.time )
			continue
		prepare_blip(nearby_xeno, MOTION_DETECTOR_HOSTILE)
	if(hostile_detected)
		playsound(loc, 'sound/items/tick.ogg', 100, 0, 1)
	addtimer(CALLBACK(src, PROC_REF(clean_blips)), scan_time / 2)


///Clean all blips from operator screen
/obj/item/armor_module/module/motion_detector/proc/clean_blips()
	if(!operator)//We already cleaned
		return
	for(var/obj/effect/blip/blip AS in blips_list)
		blip.remove_blip(operator)
	blips_list.Cut()

///Prepare the blip to be print on the operator screen
/obj/item/armor_module/module/motion_detector/proc/prepare_blip(mob/target, status)
	if(!operator.client)
		return

	var/list/actualview = getviewsize(operator.client.view)
	var/viewX = actualview[1]
	var/viewY = actualview[2]
	var/turf/center_view = get_view_center(operator)
	var/screen_pos_y = target.y - center_view.y + round(viewY * 0.5) + 1
	var/dir
	if(screen_pos_y < 1)
		dir = SOUTH
		screen_pos_y = 1
	else if (screen_pos_y > viewY)
		dir = NORTH
		screen_pos_y = viewY
	var/screen_pos_x = target.x - center_view.x + round(viewX * 0.5) + 1
	if(screen_pos_x < 1)
		dir = (dir ? dir == SOUTH ? SOUTHWEST : NORTHWEST : WEST)
		screen_pos_x = 1
	else if (screen_pos_x > viewX)
		dir = (dir ? dir == SOUTH ? SOUTHEAST : NORTHEAST : EAST)
		screen_pos_x = viewX
	if(dir)
		blips_list += new /obj/effect/blip/edge_blip(null, status, operator, screen_pos_x, screen_pos_y, dir)
		return
	blips_list += new /obj/effect/blip/close_blip(get_turf(target), status, operator)

/obj/item/armor_module/module/fire_proof/som
	icon = 'modular_RUtgmc/icons/mob/modular/modular_armor_modules.dmi'

/obj/item/armor_module/module/tyr_extra_armor/som
	icon = 'modular_RUtgmc/icons/mob/modular/modular_armor_modules.dmi'

/obj/item/armor_module/module/mimir_environment_protection/som
	icon = 'modular_RUtgmc/icons/mob/modular/modular_armor_modules.dmi'

/obj/item/armor_module/module/valkyrie_autodoc/som
	icon = 'modular_RUtgmc/icons/mob/modular/modular_armor_modules.dmi'

/obj/item/armor_module/module/welding/som
	icon = 'modular_RUtgmc/icons/mob/modular/modular_armor_modules.dmi'

/obj/item/armor_module/storage/engineering/som
	icon = 'modular_RUtgmc/icons/mob/modular/modular_armor_modules.dmi'

/obj/item/armor_module/storage/general/som
	icon = 'modular_RUtgmc/icons/mob/modular/modular_armor_modules.dmi'

/obj/item/armor_module/storage/medical/som
	icon = 'modular_RUtgmc/icons/mob/modular/modular_armor_modules.dmi'

/obj/item/armor_module/module/valkyrie_autodoc
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_autodoc_xn", /obj/item/clothing/suit/modular = "mod_autodoc_jg")

/obj/item/armor_module/module/fire_proof
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_fire_xn", /obj/item/clothing/suit/modular = "mod_fire_jg")

/obj/item/armor_module/module/tyr_extra_armor
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_armor_xn", /obj/item/clothing/suit/modular = "mod_armor_jg")

/obj/item/armor_module/module/mimir_environment_protection
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_biohazard_xn", /obj/item/clothing/suit/modular = "mod_biohazard_jg")

/obj/item/armor_module/module/hlin_explosive_armor
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_bombimmune_xn", /obj/item/clothing/suit/modular = "mod_bombimmune_jg")

/obj/item/armor_module/module/ballistic_armor
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_ff_xn", /obj/item/clothing/suit/modular = "mod_ff_jg")

/obj/item/armor_module/module/eshield
	variants_by_parent_type = list(/obj/item/clothing/suit/modular/xenonauten = "mod_eshield_xn", /obj/item/clothing/suit/modular = "mod_eshield_jg")
