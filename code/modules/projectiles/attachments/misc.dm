
/obj/item/attachable/buildasentry
	name = "\improper Build-A-Sentry Attachment System"
	icon = 'icons/Marine/sentry.dmi'
	icon_state = "build_a_sentry_attachment"
	desc = "The Build-A-Sentry is the latest design in cheap, automated, defense. Simple attach it the rail of a gun and deploy. Its that easy!"
	slot = ATTACHMENT_SLOT_RAIL
	pixel_shift_x = 10
	pixel_shift_y = 18
	///Battery of the deployed sentry. This is stored here only when the this is not attached to a gun.
	var/obj/item/cell/lasgun/lasrifle/marine/battery
	///Deploy time for the build-a-sentry
	var/deploy_time = 2 SECONDS
	///Undeploy tim for the build-a-sentry
	var/undeploy_time = 2 SECONDS

/obj/item/attachable/buildasentry/Initialize()
	. = ..()
	battery = new(src)

/obj/item/attachable/buildasentry/update_icon_state()
	. = ..()
	var/has_battery
	if(master_gun)
		has_battery = master_gun.sentry_battery
	else
		has_battery = battery
	icon_state = has_battery ? "build_a_sentry_attachment" : "build_a_sentry_attachment_e"

/obj/item/attachable/buildasentry/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!istype(I, /obj/item/cell/lasgun/lasrifle/marine))
		return
	if(battery)
		to_chat(user, span_warning("[src] already has a [battery] installed!"))
		return
	to_chat(user, span_notice("You install [I] into [src]."))
	battery = I
	battery.forceMove(src)
	user.temporarilyRemoveItemFromInventory(I)
	playsound(src, 'sound/weapons/guns/interact/standard_laser_rifle_reload.ogg', 20)
	update_icon()

/obj/item/attachable/buildasentry/attack_hand(mob/living/user)
	if(user.get_inactive_held_item() != src)
		return ..()
	if(!battery)
		to_chat(user, span_warning("There is no battery to remove from [src]."))
		return
	user.put_in_hands(battery)
	battery = null
	playsound(src, 'sound/weapons/guns/interact/standard_laser_rifle_reload.ogg', 20)
	update_icon()

/obj/item/attachable/buildasentry/can_attach(obj/item/attaching_to, mob/attacher)
	if(!isgun(attaching_to))
		return FALSE
	var/obj/item/weapon/gun/attaching_gun = attaching_to
	if(CHECK_BITFIELD(attaching_gun.flags_gun_features, GUN_IS_SENTRY))
		to_chat(attacher, span_warning("[attaching_gun] is already a sentry!"))
		return FALSE
	return ..()

/obj/item/attachable/buildasentry/on_attach(attaching_item, mob/user)
	. = ..()
	ENABLE_BITFIELD(master_gun.flags_gun_features, GUN_IS_SENTRY)
	ENABLE_BITFIELD(master_gun.flags_item, IS_DEPLOYABLE)
	master_gun.sentry_battery_type = /obj/item/cell/lasgun/lasrifle/marine
	master_gun.sentry_battery = battery
	battery?.forceMove(master_gun)
	master_gun.ignored_terrains = list(
		/obj/machinery/deployable/mounted,
		/obj/machinery/miner,
	)
	if(master_gun.ammo_datum_type && CHECK_BITFIELD(initial(master_gun.ammo_datum_type.flags_ammo_behavior), AMMO_ENERGY) || istype(master_gun, /obj/item/weapon/gun/energy)) //If the guns ammo is energy, the sentry will shoot at things past windows.
		master_gun.ignored_terrains += list(
			/obj/structure/window,
			/obj/structure/window/reinforced,
			/obj/machinery/door/window,
			/obj/structure/window/framed,
			/obj/structure/window/framed/colony,
			/obj/structure/window/framed/mainship,
			/obj/structure/window/framed/prison,
		)
	master_gun.turret_flags |= TURRET_HAS_CAMERA|TURRET_SAFETY|TURRET_ALERTS
	master_gun.AddElement(/datum/element/deployable_item, /obj/machinery/deployable/mounted/sentry/buildasentry, deploy_time, undeploy_time)
	update_icon()

/obj/item/attachable/buildasentry/on_detach(detaching_item, mob/user)
	. = ..()
	var/obj/item/weapon/gun/detaching_gun = detaching_item
	DISABLE_BITFIELD(detaching_gun.flags_gun_features, GUN_IS_SENTRY)
	DISABLE_BITFIELD(detaching_gun.flags_item, IS_DEPLOYABLE)
	detaching_gun.ignored_terrains = null
	detaching_gun.turret_flags &= ~(TURRET_HAS_CAMERA|TURRET_SAFETY|TURRET_ALERTS)
	battery = detaching_gun.sentry_battery
	battery?.forceMove(src)
	detaching_gun.sentry_battery = null
	detaching_gun.RemoveElement(/datum/element/deployable_item, /obj/machinery/deployable/mounted/sentry/buildasentry, deploy_time, undeploy_time)


/obj/item/attachable/shoulder_mount
	name = "experimental shoulder attachment point"
	desc = "A brand new advance in combat technology. This device, once attached to a firearm, will allow the firearm to be mounted onto any piece of modular armor. Once attached to the armor and activated, the gun will fire when the user chooses.\nOnce attached to the armor, <b>right clicking</b> the armor with an empty hand will select what click will fire the armor (middle, right, left). <b>Right clicking</b> with ammunition will reload the gun. Using the <b>Unique Action</b> keybind will perform the weapon's unique action only when the gun is active."
	icon = 'icons/mob/modular/shoulder_gun.dmi'
	icon_state = "shoulder_gun"
	slot = ATTACHMENT_SLOT_RAIL
	pixel_shift_x = 13
	///What click the gun will fire on.
	var/fire_mode = "right"
	///Blacklist of item types not allowed to be in the users hand to fire the gun.
	var/list/in_hand_items_blacklist = list(
		/obj/item/weapon/gun,
		/obj/item/weapon/shield,
	)

/obj/item/attachable/shoulder_mount/on_attach(attaching_item, mob/user)
	. = ..()
	var/obj/item/weapon/gun/attaching_gun = attaching_item
	ENABLE_BITFIELD(flags_attach_features, ATTACH_BYPASS_ALLOWED_LIST|ATTACH_APPLY_ON_MOB)
	attaching_gun.AddElement(/datum/element/attachment, ATTACHMENT_SLOT_MODULE, icon, null, null, null, null, 0, 0, flags_attach_features, attach_delay, detach_delay, attach_skill, attach_skill_upper_threshold, attach_sound, attachment_layer = COLLAR_LAYER)
	RegisterSignal(attaching_gun, COMSIG_ATTACHMENT_ATTACHED, .proc/handle_armor_attach)
	RegisterSignal(attaching_gun, COMSIG_ATTACHMENT_DETACHED, .proc/handle_armor_detach)

/obj/item/attachable/shoulder_mount/on_detach(detaching_item, mob/user)
	var/obj/item/weapon/gun/detaching_gun = detaching_item
	detaching_gun.RemoveElement(/datum/element/attachment, ATTACHMENT_SLOT_MODULE, icon, null, null, null, null, 0, 0, flags_attach_features, attach_delay, detach_delay, attach_skill, attach_skill_upper_threshold, attach_sound, attachment_layer = COLLAR_LAYER)
	DISABLE_BITFIELD(flags_attach_features, ATTACH_BYPASS_ALLOWED_LIST|ATTACH_APPLY_ON_MOB)
	UnregisterSignal(detaching_gun, list(COMSIG_ATTACHMENT_ATTACHED, COMSIG_ATTACHMENT_DETACHED))
	return ..()

/obj/item/attachable/shoulder_mount/ui_action_click(mob/living/user, datum/action/item_action/action, obj/item/weapon/gun/G)
	if(!istype(master_gun.loc, /obj/item/clothing/suit/modular) || master_gun.loc.loc != user)
		return
	activate(user)

/obj/item/attachable/shoulder_mount/activate(mob/user)
	. = ..()
	if(CHECK_BITFIELD(master_gun.flags_item, IS_DEPLOYED))
		DISABLE_BITFIELD(master_gun.flags_item, IS_DEPLOYED)
		overlays -= image('icons/Marine/marine-weapons.dmi', src, "active")
		UnregisterSignal(user, COMSIG_MOB_MOUSEDOWN)
		master_gun.set_gun_user(null)
	else
		ENABLE_BITFIELD(master_gun.flags_item, IS_DEPLOYED)
		overlays += image('icons/Marine/marine-weapons.dmi', src, "active")
		update_icon()
		master_gun.set_gun_user(user)
		RegisterSignal(user, COMSIG_MOB_MOUSEDOWN, .proc/handle_firing)
		master_gun.RegisterSignal(user, COMSIG_MOB_MOUSEDRAG, /obj/item/weapon/gun.proc/change_target)
	for(var/datum/action/action_to_update AS in actions)
		action_to_update.update_button_icon()

///Handles the gun attaching to the armor.
/obj/item/attachable/shoulder_mount/proc/handle_armor_attach(datum/source, attaching_item, mob/user)
	SIGNAL_HANDLER
	if(!istype(attaching_item, /obj/item/clothing/suit/modular))
		return
	master_gun.set_gun_user(null)
	RegisterSignal(attaching_item, COMSIG_ITEM_EQUIPPED, .proc/handle_activations)
	RegisterSignal(attaching_item, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, .proc/switch_mode)
	RegisterSignal(attaching_item, COMSIG_PARENT_ATTACKBY_ALTERNATE, .proc/reload_gun)
	RegisterSignal(master_gun, COMSIG_MOB_GUN_FIRED, .proc/after_fire)
	master_gun.base_gun_icon = master_gun.placed_overlay_iconstate
	master_gun.update_icon()

///Handles the gun detaching from the armor.
/obj/item/attachable/shoulder_mount/proc/handle_armor_detach(datum/source, detaching_item, mob/user)
	SIGNAL_HANDLER
	if(!istype(detaching_item, /obj/item/clothing/suit/modular))
		return
	for(var/datum/action/action_to_delete AS in actions)
		if(action_to_delete.target != src)
			continue
		QDEL_NULL(action_to_delete)
		break
	overlays -= image('icons/Marine/marine-weapons.dmi', src, "active")
	update_icon(user)
	master_gun.base_gun_icon = initial(master_gun.icon_state)
	master_gun.update_icon()
	UnregisterSignal(detaching_item, list(COMSIG_ITEM_EQUIPPED, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, COMSIG_PARENT_ATTACKBY_ALTERNATE))
	UnregisterSignal(master_gun, COMSIG_MOB_GUN_FIRED)
	UnregisterSignal(user, COMSIG_MOB_MOUSEDOWN)

///Sets up the action.
/obj/item/attachable/shoulder_mount/proc/handle_activations(datum/source, mob/equipper, slot)
	if(!isliving(equipper))
		return
	if(slot != SLOT_WEAR_SUIT)
		LAZYREMOVE(actions_types, /datum/action/item_action/toggle)
		var/datum/action/item_action/toggle/old_action = locate(/datum/action/item_action/toggle) in actions
		if(!old_action)
			return
		old_action.remove_action(equipper)
		actions = null
	else
		LAZYADD(actions_types, /datum/action/item_action/toggle)
		var/datum/action/item_action/toggle/new_action = new(src)
		new_action.give_action(equipper)

///Performs the firing.
/obj/item/attachable/shoulder_mount/proc/handle_firing(datum/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(params)
	if(!modifiers[fire_mode])
		return
	if(!istype(master_gun.loc, /obj/item/clothing/suit/modular) || master_gun.loc.loc != source)
		return
	if(source.Adjacent(object))
		return
	var/mob/living/user = master_gun.gun_user
	var/active_hand = user.get_active_held_item()
	var/inactive_hand = user.get_inactive_held_item()
	if(user.stat != CONSCIOUS || user.lying_angle || LAZYACCESS(user.do_actions, src) || !user.dextrous || (!CHECK_BITFIELD(master_gun.flags_gun_features, GUN_ALLOW_SYNTHETIC) && !CONFIG_GET(flag/allow_synthetic_gun_use) && issynth(user)))
		return
	for(var/item_blacklisted in in_hand_items_blacklist)
		if(!istype(active_hand, item_blacklisted) && !istype(inactive_hand, item_blacklisted))
			continue
		to_chat(user, span_warning("[src] beeps. Guns or shields in your hands are interfering with its targetting. Aborting."))
		return
	master_gun.start_fire(source, object, location, control, null, TRUE)

///Switches click fire modes.
/obj/item/attachable/shoulder_mount/proc/switch_mode(datum/source, mob/living/user)
	SIGNAL_HANDLER
	switch(fire_mode)
		if("right")
			fire_mode = "middle"
			to_chat(user, span_notice("[master_gun] will now fire on a 'middle click'."))
		if("middle")
			fire_mode = "left"
			to_chat(user, span_notice("[master_gun] will now fire on a 'left click'."))
		if("left")
			fire_mode = "right"
			to_chat(user, span_notice("[master_gun] will now fire on a 'right click'."))

///Reloads the gun
/obj/item/attachable/shoulder_mount/proc/reload_gun(datum/source, obj/item/attacking_item, mob/living/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(master_gun, /obj/item/weapon/gun.proc/reload, attacking_item, user)

///Performs the unique action after firing and checks to see if the user is still able to fire.
/obj/item/attachable/shoulder_mount/proc/after_fire(datum/source, atom/target, obj/item/weapon/gun/fired_gun)
	SIGNAL_HANDLER
	if(CHECK_BITFIELD(master_gun.flags_gun_features, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION))
		INVOKE_ASYNC(master_gun, /obj/item/weapon/gun.proc/unique_action, master_gun.gun_user)
	var/mob/living/user = master_gun.gun_user
	if(user.stat == CONSCIOUS && !user.lying_angle && !LAZYACCESS(user.do_actions, src) && user.dextrous && (CHECK_BITFIELD(master_gun.flags_gun_features, GUN_ALLOW_SYNTHETIC) || CONFIG_GET(flag/allow_synthetic_gun_use) || !issynth(user)))
		return
	master_gun.stop_fire()

/obj/item/attachable/flamer_nozzle
	name = "standard flamer nozzle"
	desc = "The standard flamer nozzle. This one fires a stream of fire for direct and accurate flames. Though not as area filling as its counterpart, this one excels at directed frontline combat."
	icon_state = "flame_directional"
	slot = ATTACHMENT_SLOT_FLAMER_NOZZLE
	attach_delay = 2 SECONDS
	detach_delay = 2 SECONDS

	///This is pulled when the parent flamer fires, it determins how the parent flamers fire stream acts.
	var/stream_type = FLAMER_STREAM_STRAIGHT

	///Modifier for burn level of attached flamer. Percentage based.
	var/burn_level_mod = 1
	///Modifier for burn time of attached flamer. Percentage based.
	var/burn_time_mod = 1
	///Range modifier of attached flamer. Numerically based.
	var/range_modifier = 0
	///Damage multiplier for mobs caught in the initial stream of fire of the attached flamer.
	var/mob_flame_damage_mod = 1

/obj/item/attachable/flamer_nozzle/on_attach(attaching_item, mob/user)
	. = ..()
	if(!istype(attaching_item, /obj/item/weapon/gun/flamer))
		return
	var/obj/item/weapon/gun/flamer/flamer = attaching_item
	flamer.burn_level_mod *= burn_level_mod
	flamer.burn_time_mod *= burn_time_mod
	flamer.flame_max_range += range_modifier
	flamer.mob_flame_damage_mod *= mob_flame_damage_mod

/obj/item/attachable/flamer_nozzle/on_detach(attaching_item, mob/user)
	. = ..()
	if(!istype(attaching_item, /obj/item/weapon/gun/flamer))
		return
	var/obj/item/weapon/gun/flamer/flamer = attaching_item
	flamer.burn_level_mod /= burn_level_mod
	flamer.burn_time_mod /= burn_time_mod
	flamer.flame_max_range -= range_modifier
	flamer.mob_flame_damage_mod /= mob_flame_damage_mod

/obj/item/attachable/flamer_nozzle/unremovable
	flags_attach_features = NONE

/obj/item/attachable/flamer_nozzle/unremovable/invisible
	icon_state = null

/obj/item/attachable/flamer_nozzle/wide
	name = "spray flamer nozzle"
	desc = "This specialized nozzle sprays the flames of an attached flamer in a much more broad way than the standard nozzle. It serves for wide area denial as opposed to offensive directional flaming."
	icon_state = "flame_wide"
	range_modifier = -3
	pixel_shift_y = 17
	stream_type = FLAMER_STREAM_CONE

///Funny red wide nozzle that can fill entire screens with flames. Admeme only.
/obj/item/attachable/flamer_nozzle/wide/red
	name = "red spray flamer nozzle"
	desc = "It is red, therefore its obviously more effective."
	icon_state = "flame_wide_red"
	range_modifier = 0
