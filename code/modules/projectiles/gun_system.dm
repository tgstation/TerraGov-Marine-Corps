/obj/item/weapon/gun
	name = "Guns"
	desc = "Its a gun. It's pretty terrible, though."
	icon = 'icons/obj/items/gun.dmi'
	icon_state = ""
	item_state = "gun"
	item_state_worn = TRUE
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
		)
	max_integrity = 250
	materials = list(/datum/material/metal = 100)
	w_class 	= 3
	throwforce 	= 5
	throw_speed = 4
	throw_range = 5
	force 		= 5
	flags_atom = CONDUCT
	flags_item = TWOHANDED
	light_system = MOVABLE_LIGHT
	light_range = 0
	light_color = COLOR_WHITE

	var/atom/movable/vis_obj/effect/muzzle_flash/muzzle_flash
	var/muzzleflash_iconstate
	var/muzzle_flash_lum = 3 //muzzle flash brightness
	var/muzzle_flash_color = COLOR_VERY_SOFT_YELLOW

	///State for a fire animation if the gun has any
	var/fire_animation = null
	var/shell_eject_animation = null
	var/fire_sound 		= 'sound/weapons/guns/fire/gunshot.ogg'
	///Does our gun have a unique sound when running out of ammo? If so, use this instead of pitch shifting.
	var/fire_rattle		= null
	var/dry_fire_sound	= 'sound/weapons/guns/fire/empty.ogg'
	var/unload_sound 	= 'sound/weapons/flipblade.ogg'
	var/empty_sound 	= 'sound/weapons/guns/misc/empty_alarm.ogg'
	var/reload_sound 	= null					//We don't want these for guns that don't have them.

	var/last_fired = 0

	var/cock_notice
	var/cock_locked_message

	var/cock_animation

	var/last_cock_message
	var/cock_message_delay = 1 SECONDS

	var/cocked_sound 	= null
	var/opened_sound

	var/last_cocked
	var/cock_delay = 3 SECONDS

/*
 *  RELOADING_VARS
 *
*/

	var/rounds
	var/max_rounds

	var/obj/in_chamber
	var/list/obj/chamber_items = list()
	var/max_chamber_items = 1

	var/current_chamber_position = 1

	var/reciever_flags = RECIEVER_MAGAZINES

	var/type_of_casings = null

	var/rounds_to_draw = 1

	var/datum/ammo/ammo = /datum/ammo/bullet
	var/obj/item/ammo_magazine/default_magazine_type = /obj/item/ammo_magazine
	var/obj/item/allowed_mag_type = /obj/item/ammo_magazine
	var/list/allowed_ammo_types = list(
		/obj/item/ammo_magazine,
	)

	var/current_rounds_var = "current_rounds"
	var/max_rounds_var = "max_rounds"
	var/magazine_flags_var = "flags_magazine"
	var/ammo_type_var = "default_ammo"


/*
 *
 *  STAT VARS
 *
*/

	//Basic stats.
	var/accuracy_mult 			= 1				//Multiplier. Increased and decreased through attachments. Multiplies the projectile's accuracy by this number.
	var/damage_mult 			= 1				//Same as above, for damage.
	var/damage_falloff_mult 	= 1				//Same as above, for damage bleed (falloff)
	var/recoil 					= 0				//Screen shake when the weapon is fired.
	var/recoil_unwielded 		= 0
	var/scatter					= 20				//How much the bullet scatters when fired.
	var/scatter_unwielded 		= 20
	var/burst_scatter_mult		= 3				//Multiplier. Increases or decreases how much bonus scatter is added when burst firing (wielded only).
	var/burst_accuracy_mult		= 1				//Multiplier. Defaults to 1 (no penalty). Multiplies accuracy modifier by this amount while burst firing; usually a fraction (penalty) when set.
	var/accuracy_mod			= 0.05				//accuracy modifier, used by most attachments.
	var/accuracy_mult_unwielded = 1		//same vars as above but for unwielded firing.
	var/movement_acc_penalty_mult = 5				//Multiplier. Increased and decreased through attachments. Multiplies the accuracy/scatter penalty of the projectile when firing onehanded while moving.
	var/fire_delay = 6							//For regular shots, how long to wait before firing again.
	var/shell_speed_mod	= 0						//Modifies the speed of projectiles fired.
	///Modifies projectile damage by a % when a marine gets passed, but not hit
	var/iff_marine_damage_falloff = 0
	///Determines how fire delay is changed when aim mode is active
	var/aim_fire_delay = 0
	///Determines character slowdown from aim mode. Default is 66%
	var/aim_speed_modifier = 6

	//Burst fire.
	var/burst_amount 	= 1						//How many shots can the weapon shoot in burst? Anything less than 2 and you cannot toggle burst.
	var/burst_delay 	= 0.1 SECONDS			//The delay in between shots. Lower = less delay = faster.
	var/extra_delay		= 0						//When burst-firing, this number is extra time before the weapon can fire again. Depends on number of rounds fired.


	//Slowdowns
	var/aim_slowdown	= 0						//Self explanatory. How much does aiming (wielding the gun) slow you
	var/wield_delay		= 0.4 SECONDS		//How long between wielding and firing in tenths of seconds
	var/wield_penalty	= 0.2 SECONDS	//Extra wield delay for untrained operators
	var/wield_time		= 0						//Storing value for above


	//Energy Weapons
	var/charge_cost		= 0						//how much energy is consumed per shot.
	var/ammo_per_shot	= 1						//How much ammo consumed per shot; normally 1.
	var/overcharge		= 0						//In overcharge mode?
	var/ammo_diff		= null					//what ammo to use for overcharge

/*
 *
 *   ATTACHMENT VARS
 *
*/


	///List of offsets to make attachment overlays not look wonky.
	var/list/attachable_offset 		= null		//Is a list, see examples of from the other files. Initiated on New() because lists don't initial() properly.
	///List of allowed attachments, does not have to include the starting attachment types.
	var/list/attachable_allowed		= null		//Must be the exact path to the attachment present in the list. Empty list for a default.

	///This is only not null when a weapon attachment is activated. All procs of firing get passed to this when it is not null.
	var/obj/item/weapon/gun/active_attachable = null
	///The attachments this gun starts with on Init
	var/list/starting_attachment_types = null
	///Image list of attachments overlays.
	var/list/image/attachment_overlays = list()
	///List of slots a gun can have.
	var/list/attachments_by_slot = list(
		ATTACHMENT_SLOT_MUZZLE,
		ATTACHMENT_SLOT_RAIL,
		ATTACHMENT_SLOT_STOCK,
		ATTACHMENT_SLOT_UNDER,
		ATTACHMENT_SLOT_MAGAZINE,
	)
	///Innate carateristics of that gun
	var/flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK

	var/gun_firemode = GUN_FIREMODE_SEMIAUTO
	var/list/gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)

	var/gun_skill_category = GUN_SKILL_RIFLES //Using rifles because they are the most common, and need a skill that at default the value is 0

	var/base_gun_icon //the default gun icon_state. change to reskin the gun

	var/general_codex_key = "guns"

	///The mob holding the gun
	var/mob/gun_user
	///The atom targeted by the user
	var/atom/target
	///How many bullets the gun fired while bursting/auto firing
	var/shots_fired = 0
	///If this gun is in inactive hands and shooting in akimbo
	var/dual_wield = FALSE
	///Used if a weapon need windup before firing
	var/windup_checked = WEAPON_WINDUP_NOT_CHECKED

	///determines upper accuracy modifier in akimbo
	var/upper_akimbo_accuracy = 2
	///determines lower accuracy modifier in akimbo
	var/lower_akimbo_accuracy = 1

	///If the gun is deployable, the time it takes for the weapon to deploy.
	var/deploy_time = 0
	///If the gun is deployable, the time it takes for the weapon to undeploy.
	var/undeploy_time = 0
	///If the gun is deployed, change the scatter amount by this number. Negative reduces scatter, positive adds.
	var/deployed_scatter_change = 0
	///List of turf/objects/structures that will be ignored in the sentries targeting.
	var/list/ignored_terrains
	///Flags that the deployed sentry uses upon deployment.
	var/turret_flags = NONE
	///Damage threshold for whether a turret will be knocked down.
	var/knockdown_threshold = 100
	///Range of deployed turret
	var/turret_range = 7
	///Battery used for radial mode on deployed turrets.
	var/obj/item/cell/sentry_battery
	///Battery type for sentries
	var/sentry_battery_type = /obj/item/cell
	///Battery drain per shot for radial sentry mode
	var/sentry_battery_drain = 20
	///IFF signal for sentries. If it is set here it will be this signal forever. If null the IFF signal will be dependant on the deployer.
	var/sentry_iff_signal = NONE

	///Gun reference if src is an attachment and is attached to a gun. This will be the gun that src is attached to.
	var/obj/item/weapon/gun/master_gun
	///Slot the gun fits into.
	var/slot
	///Pixel shift on the X Axis for the attached overlay.
	var/pixel_shift_x = 16
	///Pixel shift on the Y Axis for the attached overlay.
	var/pixel_shift_y = 16
	///Flags for attachment functions.
	var/flags_attach_features = ATTACH_REMOVABLE
	///Time it takes to attach src to a master gun.
	var/attach_delay = 0 SECONDS
	///Time it takes to detach src to a master gun.
	var/detach_delay = 0 SECONDS
	///Icon state used for an added overlay for a sentry. Currently only used in Build-A-Sentry.
	var/placed_overlay_iconstate = "rifle"

//----------------------------------------------------------
				//				    \\
				// NECESSARY PROCS  \\
				//					\\
				//					\\
//----------------------------------------------------------

/obj/item/weapon/gun/Initialize(mapload, spawn_empty) //You can pass on spawn_empty to make the sure the gun has no bullets or mag or anything when created.
	. = ..()					//This only affects guns you can get from vendors for now. Special guns spawn with their own things regardless.
	base_gun_icon = icon_state

	update_force_list() //This gives the gun some unique verbs for attacking.

	setup_firemodes()
	AddComponent(/datum/component/automatedfire/autofire, fire_delay, burst_delay, burst_amount, gun_firemode, CALLBACK(src, .proc/set_bursting), CALLBACK(src, .proc/reset_fire), CALLBACK(src, .proc/Fire)) //This should go after handle_starting_attachment() and setup_firemodes() to get the proper values set.
	AddComponent(/datum/component/attachment_handler, attachments_by_slot, attachable_allowed, attachable_offset, starting_attachment_types, null, CALLBACK(src, .proc/on_attachment_attach), CALLBACK(src, .proc/on_attachment_detach), attachment_overlays)
	if(CHECK_BITFIELD(flags_gun_features, GUN_IS_ATTACHMENT))
		AddElement(/datum/element/attachment, slot, icon, .proc/on_attach, .proc/on_detach, .proc/activate, .proc/can_attach, pixel_shift_x, pixel_shift_y, flags_attach_features, attach_delay, detach_delay, "firearms", SKILL_FIREARMS_DEFAULT, 'sound/machines/click.ogg')

	muzzle_flash = new(src, muzzleflash_iconstate)

	if(flags_item & IS_DEPLOYABLE)
		if(flags_gun_features & GUN_IS_SENTRY)
			AddElement(/datum/element/deployable_item, /obj/machinery/deployable/mounted/sentry, deploy_time, undeploy_time)
			sentry_battery = new sentry_battery_type(src)
			return
		AddElement(/datum/element/deployable_item, /obj/machinery/deployable/mounted, deploy_time, undeploy_time)

	GLOB.nightfall_toggleable_lights += src

	ammo = new ammo()

/obj/item/weapon/gun/Destroy()
	active_attachable = null
	if(muzzle_flash)
		QDEL_NULL(muzzle_flash)
	QDEL_NULL(sentry_battery)
	GLOB.nightfall_toggleable_lights -= src
	set_gun_user(null)
	return ..()

/obj/item/weapon/gun/turn_light(mob/user, toggle_on, cooldown, sparks, forced)
	. = ..()
	if(. != CHECKS_PASSED)
		return
	var/obj/item/attachable = attachments_by_slot[ATTACHMENT_SLOT_RAIL]
	if(!attachable || !istype(attachable, /obj/item/attachable))
		return
	var/obj/item/attachable/attachable_attachment = attachable
	attachable_attachment.turn_light(user, toggle_on, cooldown, sparks, forced)

/obj/item/weapon/gun/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/weapon/gun/equipped(mob/user, slot)
	unwield(user)
	if(ishandslot(slot))
		set_gun_user(user)
		return ..()
	set_gun_user(null)
	return ..()

/obj/item/weapon/gun/removed_from_inventory(mob/user)
	set_gun_user(null)
	active_attachable?.removed_from_inventory(user)

///Set the user in argument as gun_user
/obj/item/weapon/gun/proc/set_gun_user(mob/user)
	active_attachable?.set_gun_user(user)
	if(user == gun_user)
		return
	if(gun_user)
		UnregisterSignal(gun_user, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP, COMSIG_ITEM_ZOOM, COMSIG_ITEM_UNZOOM, COMSIG_MOB_MOUSEDRAG, COMSIG_KB_RAILATTACHMENT, COMSIG_KB_UNDERRAILATTACHMENT, COMSIG_KB_UNLOADGUN, COMSIG_KB_FIREMODE, COMSIG_KB_GUN_SAFETY, COMSIG_KB_UNIQUEACTION, COMSIG_PARENT_QDELETING))
		gun_user.client?.mouse_pointer_icon = initial(gun_user.client.mouse_pointer_icon)
		SEND_SIGNAL(gun_user, COMSIG_GUN_USER_UNSET)
		gun_user.hud_used.remove_ammo_hud(gun_user, src)
		gun_user = null
	if(!user)
		return
	gun_user = user
	SEND_SIGNAL(gun_user, COMSIG_GUN_USER_SET, src)
	gun_user.hud_used.add_ammo_hud(gun_user, src)
	if(master_gun)
		return
	if(!CHECK_BITFIELD(flags_item, IS_DEPLOYED))
		RegisterSignal(gun_user, COMSIG_MOB_MOUSEDOWN, .proc/start_fire)
		RegisterSignal(gun_user, COMSIG_MOB_MOUSEDRAG, .proc/change_target)
	else
		RegisterSignal(gun_user, COMSIG_KB_UNIQUEACTION, .proc/unique_action)
	RegisterSignal(gun_user, COMSIG_PARENT_QDELETING, .proc/clean_gun_user)
	RegisterSignal(gun_user, list(COMSIG_MOB_MOUSEUP, COMSIG_ITEM_ZOOM, COMSIG_ITEM_UNZOOM), .proc/stop_fire)
	RegisterSignal(gun_user, COMSIG_KB_RAILATTACHMENT, .proc/activate_rail_attachment)
	RegisterSignal(gun_user, COMSIG_KB_UNDERRAILATTACHMENT, .proc/activate_underrail_attachment)
	RegisterSignal(gun_user, COMSIG_KB_UNLOADGUN, .proc/unload_gun)
	RegisterSignal(gun_user, COMSIG_KB_FIREMODE, .proc/do_toggle_firemode)
	RegisterSignal(gun_user, COMSIG_KB_GUN_SAFETY, .proc/toggle_gun_safety_keybind)


///Null out gun user to prevent hard del
/obj/item/weapon/gun/proc/clean_gun_user()
	SIGNAL_HANDLER
	set_gun_user(null)

/obj/item/weapon/gun/update_icon(mob/user)
	if(!length(chamber_items))
		icon_state = base_gun_icon + "_e"
	else if(chamber_items[current_chamber_position].loc != src)
		icon_state = base_gun_icon + "_l"
	else if(CHECK_BITFIELD(reciever_flags, RECIEVER_TOGGLES) && CHECK_BITFIELD(reciever_flags, RECIEVER_CLOSED))
		icon_state = base_gun_icon + "_o"
	else
		icon_state = base_gun_icon

	. = ..()

	for(var/action_to_update in actions)
		var/datum/action/action = action_to_update
		action.update_button_icon()

	if(master_gun)
		for(var/action_to_update in master_gun.actions)
			var/datum/action/action = action_to_update
			action.update_button_icon()

	update_item_state(user)



/obj/item/weapon/gun/update_item_state(mob/user)
	item_state = "[base_gun_icon][flags_item & WIELDED ? "_w" : ""]"


/obj/item/weapon/gun/examine(mob/user)
	. = ..()
	var/list/dat = list()
	if(HAS_TRAIT(src, TRAIT_GUN_SAFETY))
		dat += "The safety's on!<br>"
	else
		dat += "The safety's off!<br>"

	for(var/key in attachments_by_slot)
		var/obj/item/attachable = attachments_by_slot[key]
		if(!attachable)
			continue
		dat += "It has [icon2html(attachable, user)] [attachable.name]"
		if(!istype(attachable, /obj/item/weapon/gun))
			continue
		var/obj/item/weapon/gun/gun_attachable = attachable
		if(istype(attachable, /obj/item/weapon/gun/grenade_launcher))
			continue
		var/chamber = in_chamber ? 1 : 0
		dat += gun_attachable.rounds ? "([gun_attachable.rounds + chamber]/[gun_attachable.max_rounds])" : "(Unloaded)"

	if(dat)
		to_chat(user, "[dat.Join(" ")]")

	examine_ammo_count(user)
	if(!CHECK_BITFIELD(flags_item, IS_DEPLOYED))
		if(CHECK_BITFIELD(flags_item, IS_DEPLOYABLE))
			to_chat(user, span_notice("Use Ctrl-Click to deploy."))
		if(CHECK_BITFIELD(flags_gun_features, GUN_IS_SENTRY))
			to_chat(user, span_notice("Use Alt-Right-Click to remove the sentries battery."))
		return
	to_chat(user, span_notice("Click-Drag to yourself to undeploy."))
	to_chat(user, span_notice("Alt-Click to unload."))
	to_chat(user, span_notice("Right-Click to perform the guns unique action."))
	if(CHECK_BITFIELD(flags_gun_features, GUN_IS_SENTRY))
		to_chat(user, span_notice("Ctrl-Click to remove the sentries battery."))

/obj/item/weapon/gun/proc/examine_ammo_count(mob/user)
	var/list/dat = list()
	if(!(flags_gun_features & (GUN_INTERNAL_MAG|GUN_UNUSUAL_DESIGN))) //Internal mags and unusual guns have their own stuff set.
		if(CHECK_BITFIELD(reciever_flags, RECIEVER_TOGGLES))
			dat += "[CHECK_BITFIELD(reciever_flags, RECIEVER_CLOSED) ? "It is open. \n" : "It is closed. \n"]"
		if(rounds > 0)
			if(flags_gun_features & GUN_AMMO_COUNTER)
				dat += "Ammo counter shows [rounds] round\s remaining.<br>"
			else
				dat += "It's loaded[in_chamber?" and has a round chambered":""].<br>"
		else
			dat += "It's unloaded[in_chamber?" but has a round chambered":""].<br>"
		if(CHECK_BITFIELD(reciever_flags, RECIEVER_MAGAZINES) && max_chamber_items > 1)
			dat += "It has [length(chamber_items)] of [max_chamber_items] magazines loaded.\n"
	if(dat)
		to_chat(user, "[dat.Join(" ")]")

/obj/item/weapon/gun/wield(mob/user)
	if(CHECK_BITFIELD(flags_gun_features, GUN_DEPLOYED_FIRE_ONLY))
		to_chat(user, span_notice("[src] cannot be fired by hand and must be deployed."))
		return

	. = ..()

	if(!.)
		return

	user.add_movespeed_modifier(MOVESPEED_ID_AIM_SLOWDOWN, TRUE, 0, NONE, TRUE, aim_slowdown)

	var/wdelay = wield_delay
	//slower or faster wield delay depending on skill.
	if(!user.skills.getRating("firearms"))
		wdelay += 0.3 SECONDS //no training in any firearms
	else
		var/skill_value = user.skills.getRating(gun_skill_category)
		if(skill_value > 0)
			wdelay -= skill_value * 2
		else
			wdelay += wield_penalty
	wield_time = world.time + wdelay
	do_wield(user, wdelay)
	if(HAS_TRAIT(src, TRAIT_GUN_AUTO_AIM_MODE))
		toggle_aim_mode(user)


/obj/item/weapon/gun/unwield(mob/user)
	. = ..()
	if(!.)
		return FALSE

	user.remove_movespeed_modifier(MOVESPEED_ID_AIM_SLOWDOWN)

	if(HAS_TRAIT(src, TRAIT_GUN_IS_AIMING))
		toggle_aim_mode(user)

	return TRUE


//----------------------------------------------------------
			//							    \\
			// AFTER ATTACK AND CHAMBERING  \\
			//							    \\
			//						   	    \\
//----------------------------------------------------------
///Check if the gun can fire and add it to bucket auto_fire system if needed, or just fire the gun if not
/obj/item/weapon/gun/proc/start_fire(datum/source, atom/object, turf/location, control, params, bypass_checks = FALSE)
	SIGNAL_HANDLER

	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		return
	if(modifiers["ctrl"] && !modifiers["right"] && gun_user.get_active_held_item() == src && isturf(object) && get_turf(gun_user) != object && gun_user.Adjacent(object)) //This is so we can simulate it like we are deploying to a tile.
		gun_user.setDir(get_cardinal_dir(gun_user, object))
		CtrlClick(gun_user)
		return

	if(modifiers["right"] || modifiers["middle"])
		modifiers -= "right"
		modifiers -= "middle"
		params = list2params(modifiers)
		active_attachable?.start_fire(source, object, location, control, params, bypass_checks)
		return
	if(gun_on_cooldown(gun_user))
		return
	if(!bypass_checks)
		if(master_gun && gun_user.get_active_held_item() != master_gun)
			return
		if(gun_user.hand && !isgun(gun_user.l_hand) || !gun_user.hand && !isgun(gun_user.r_hand)) // If the object in our active hand is not a gun, abort
			return
		if(gun_user.hand && isgun(gun_user.r_hand) || !gun_user.hand && isgun(gun_user.l_hand)) // If we have a gun in our inactive hand too, both guns get innacuracy maluses
			dual_wield = TRUE
		if(gun_user.in_throw_mode)
			return
		if(gun_user.Adjacent(object)) //Dealt with by attack code
			return
	if(QDELETED(object))
		return
	set_target(get_turf_on_clickcatcher(object, gun_user, params))
	if(gun_firemode == GUN_FIREMODE_SEMIAUTO)
		if(!INVOKE_ASYNC(src, .proc/Fire) || windup_checked == WEAPON_WINDUP_CHECKING)
			return
		reset_fire()
		return
	SEND_SIGNAL(src, COMSIG_GUN_FIRE)
	if(master_gun)
		SEND_SIGNAL(gun_user, COMSIG_MOB_ATTACHMENT_FIRED, target, src, master_gun)
	gun_user?.client?.mouse_pointer_icon = 'icons/effects/supplypod_target.dmi'

///Set the target and take care of hard delete
/obj/item/weapon/gun/proc/set_target(atom/object)
	active_attachable?.set_target(object)
	if(object == target || object == gun_user)
		return
	if(target)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	target = object
	if(target)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/clean_target)

///Set the target to it's turf, so we keep shooting even when it was qdeled
/obj/item/weapon/gun/proc/clean_target()
	SIGNAL_HANDLER
	active_attachable?.clean_target()
	target = get_turf(target)

///Reset variables used in firing and remove the gun from the autofire system
/obj/item/weapon/gun/proc/stop_fire()
	SIGNAL_HANDLER
	active_attachable?.stop_fire()
	gun_user?.client?.mouse_pointer_icon = initial(gun_user.client.mouse_pointer_icon)
	if(!HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING))
		reset_fire()
	SEND_SIGNAL(src, COMSIG_GUN_STOP_FIRE)

///Clean all references
/obj/item/weapon/gun/proc/reset_fire()
	shots_fired = 0//Let's clean everything
	set_target(null)
	windup_checked = WEAPON_WINDUP_NOT_CHECKED
	dual_wield = FALSE
	gun_user?.client?.mouse_pointer_icon = initial(gun_user.client.mouse_pointer_icon)

///Inform the gun if he is currently bursting, to prevent reloading
/obj/item/weapon/gun/proc/set_bursting(bursting)
	if(bursting)
		ADD_TRAIT(src, TRAIT_GUN_BURST_FIRING, GUN_TRAIT)
		return
	REMOVE_TRAIT(src, TRAIT_GUN_BURST_FIRING, GUN_TRAIT)

///Update the target if you draged your mouse
/obj/item/weapon/gun/proc/change_target(datum/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	set_target(get_turf_on_clickcatcher(over_object, gun_user, params))
	gun_user?.face_atom(target)






//----------------------------------------------------------
		//									   \\
		// FIRE BULLET AND POINT BLANK/SUICIDE \\
		//									   \\
		//						   			   \\
//----------------------------------------------------------

///Wrapper proc to complete the whole firing process.
/obj/item/weapon/gun/proc/Fire()
	if(!target || (!gun_user && !istype(loc, /obj/machinery/deployable/mounted/sentry)) || (!CHECK_BITFIELD(flags_item, IS_DEPLOYED) && !able_to_fire(gun_user)))
		return

	//The gun should return the bullet that it already loaded from the end cycle of the last Fire().
	var/obj/projectile/projectile_to_fire = in_chamber //Load a bullet in or check for existing one.
	if(!projectile_to_fire) //If there is nothing to fire, click.
		click_empty(gun_user)
		return

	if(!do_fire(projectile_to_fire))
		return
	finish_fire()
	return TRUE

///Actually fires the gun, sets up the projectile and fires it.
/obj/item/weapon/gun/proc/do_fire(obj/projectile/projectile_to_fire)
	var/firer
	if(istype(loc, /obj/machinery/deployable/mounted/sentry) && !gun_user)
		firer = loc
	else
		firer = gun_user
	if(CHECK_BITFIELD(reciever_flags, RECIEVER_HANDFULS))
		projectile_to_fire = get_ammo_object(projectile_to_fire)
	apply_gun_modifiers(projectile_to_fire, target, firer)
	setup_bullet_accuracy(projectile_to_fire, gun_user, shots_fired, dual_wield) //User can be passed as null.

	var/firing_angle = get_angle_with_scatter((gun_user || get_turf(src)), target, get_scatter(projectile_to_fire.scatter, gun_user), projectile_to_fire.p_x, projectile_to_fire.p_y)

	//Finally, make with the pew pew!
	if(!isobj(projectile_to_fire))
		stack_trace("projectile malfunctioned while firing. User: [gun_user]")
		return


	play_fire_sound(loc)
	muzzle_flash(firing_angle, master_gun ? gun_user : loc)
	simulate_recoil(dual_wield, gun_user)

	//This is where the projectile leaves the barrel and deals with projectile code only.
	//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
	projectile_to_fire.fire_at(target, master_gun ? gun_user : loc, src, projectile_to_fire.ammo.max_range, projectile_to_fire.ammo.shell_speed, firing_angle, suppress_light = HAS_TRAIT(src, TRAIT_GUN_SILENCED))
	//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

	shots_fired++

	if(fire_animation) //Fires gun firing animation if it has any. ex: rotating barrel
		flick("[fire_animation]", src)

	return TRUE

///Performs the after firing functions.
/obj/item/weapon/gun/proc/finish_fire()
	last_fired = world.time

	SEND_SIGNAL(src, COMSIG_MOB_GUN_FIRED, target, src)
	post_fire()
	gun_user?.hud_used.update_ammo_hud(gun_user, src)
	if(!CHECK_BITFIELD(flags_gun_features, GUN_IS_SENTRY) || !CHECK_BITFIELD(flags_item, IS_DEPLOYED) || !CHECK_BITFIELD(turret_flags, TURRET_RADIAL) || gun_user)
		return
	sentry_battery.charge -= sentry_battery_drain
	if(sentry_battery.charge >= 0)
		return
	DISABLE_BITFIELD(turret_flags, TURRET_RADIAL)
	sentry_battery.forceMove(get_turf(src))
	sentry_battery.charge = 0
	sentry_battery = null

/obj/item/weapon/gun/attack(mob/living/M, mob/living/user, def_zone)
	if(!CHECK_BITFIELD(flags_gun_features, GUN_CAN_POINTBLANK)) // If it can't point blank, you can't suicide and such.
		return ..()

	if(!able_to_fire(user))
		return ..()

	if(gun_on_cooldown(user))
		return ..()

	if(M.status_flags & INCORPOREAL) //Can't attack the incorporeal
		return ..()

	if(M != user && (M.faction != user.faction || user.a_intent == INTENT_HARM))
		. = ..()
		if(!.)
			return

		if(gun_firemode == GUN_FIREMODE_BURSTFIRE && burst_amount > 1)
			set_target(M)
			SEND_SIGNAL(src, COMSIG_GUN_FIRE)
			return TRUE

		//Point blanking simulates firing the bullet proper but without actually firing it.
		var/obj/projectile/projectile_to_fire = in_chamber
		if(!projectile_to_fire) //We actually have a projectile, let's move on. We're going to simulate the fire cycle.
			return // no ..(), already invoked above

		user.visible_message(span_danger("[user] fires [src] point blank at [M]!"))
		apply_gun_modifiers(projectile_to_fire, M, user)
		setup_bullet_accuracy(projectile_to_fire, user) //We add any damage effects that we need.
		projectile_to_fire.setDir(get_dir(user, M))
		projectile_to_fire.distance_travelled = get_dist(user, M)
		simulate_recoil(1, user) // 1 is a scalar value not boolean
		play_fire_sound(user)

		if(projectile_to_fire.ammo.bonus_projectiles_amount)
			var/obj/projectile/BP
			for(var/i = 1 to projectile_to_fire.ammo.bonus_projectiles_amount)
				BP = new /obj/projectile(M.loc)
				BP.generate_bullet(GLOB.ammo_list[projectile_to_fire.ammo.bonus_projectiles_type])
				BP.damage *= damage_mult
				BP.setDir(get_dir(user, M))
				BP.distance_travelled = get_dist(user, M)
				BP.ammo.on_hit_mob(M, BP)
				M.bullet_act(BP)
				qdel(BP)

		projectile_to_fire.ammo.on_hit_mob(M, projectile_to_fire)
		M.bullet_act(projectile_to_fire)
		last_fired = world.time

		if(!delete_bullet(projectile_to_fire))
			QDEL_NULL(projectile_to_fire)

		user?.hud_used.update_ammo_hud(user, src)
		return TRUE

	if(M != user || user.zone_selected != "mouth")
		return ..()

	DISABLE_BITFIELD(flags_gun_features, GUN_CAN_POINTBLANK) //If they try to click again, they're going to hit themselves.

	user.visible_message(span_warning("[user] sticks their gun in their mouth, ready to pull the trigger."))
	log_combat(user, null, "is trying to commit suicide")

	if(!do_after(user, 40, TRUE, src, BUSY_ICON_DANGER))
		M.visible_message(span_notice("[user] decided life was worth living."))
		ENABLE_BITFIELD(flags_gun_features, GUN_CAN_POINTBLANK)
		return

	var/obj/projectile/projectile_to_fire = in_chamber

	if(!projectile_to_fire) //We actually have a projectile, let's move on.
		click_empty(user)//If there's no projectile, we can't do much.
		ENABLE_BITFIELD(flags_gun_features, GUN_CAN_POINTBLANK)
		return

	user.visible_message("<span class = 'warning'>[user] pulls the trigger!</span>")
	var/actual_sound = (active_attachable?.fire_sound) ? active_attachable.fire_sound : fire_sound
	var/sound_volume = (HAS_TRAIT(src, TRAIT_GUN_SILENCED) && !active_attachable) ? 25 : 60
	playsound(user, actual_sound, sound_volume, 1)
	simulate_recoil(2, user)
	var/obj/item/weapon/gun/revolver/current_revolver = src
	log_combat(user, null, "committed suicide with [src].")
	message_admins("[ADMIN_TPMONTY(user)] committed suicide with [src].")
	if(istype(current_revolver) && current_revolver.russian_roulette) //If it's a revolver set to Russian Roulette.
		user.apply_damage(projectile_to_fire.damage * 3, projectile_to_fire.ammo.damage_type, "head", 0, TRUE)
		user.apply_damage(200, OXY) //In case someone tried to defib them. Won't work.
		user.death()
		to_chat(user, span_highdanger("Your life flashes before you as your spirit is torn from your body!"))
		user.ghostize(0) //No return.
		ENABLE_BITFIELD(flags_gun_features, GUN_CAN_POINTBLANK)
		return

	switch(projectile_to_fire.ammo.damage_type)
		if(STAMINA)
			to_chat(user, "<span class = 'notice'>Ow...</span>")
			user.apply_damage(200, STAMINA)
		else
			user.apply_damage(projectile_to_fire.damage * 2.5, projectile_to_fire.ammo.damage_type, "head", 0, TRUE)
			user.apply_damage(200, OXY)
			if(ishuman(user) && user == M)
				var/mob/living/carbon/human/HM = user
				HM.set_undefibbable() //can't be defibbed back from self inflicted gunshot to head
			user.death()

	user.log_message("commited suicide with [src]", LOG_ATTACK, "red") //Apply the attack log.
	last_fired = world.time

	projectile_to_fire.play_damage_effect(user)

	if(!delete_bullet(projectile_to_fire)) //If this proc DIDN'T delete the bullet, we're going to do so here.
		QDEL_NULL(projectile_to_fire)

	ENABLE_BITFIELD(flags_gun_features, GUN_CAN_POINTBLANK)

/obj/item/weapon/gun/attack_alternate(mob/living/M, mob/living/user)
	. = ..()
	if(!active_attachable)
		return
	active_attachable.attack(M, user)

/obj/item/weapon/gun/proc/delete_bullet(obj/projectile/projectile_to_fire, refund = FALSE)
	return FALSE


//----------------------------------------------------------
				//							\\
				//         RELOADING        \\
				//							\\
				//						   	\\
//----------------------------------------------------------



/obj/item/weapon/gun/proc/post_fire()
	in_chamber = null
	if(CHECK_BITFIELD(reciever_flags, RECIEVER_REQUIRES_OPERATION))
		return
	cycle(null)
	if(rounds <= 0 && CHECK_BITFIELD(reciever_flags, RECIEVER_AUTO_EJECT) && CHECK_BITFIELD(reciever_flags, RECIEVER_MAGAZINES))
		unload()
		return


/obj/item/weapon/gun/proc/do_unique_action(mob/user)
	if(CHECK_BITFIELD(reciever_flags, RECIEVER_REQUIRES_OPERATION))
		if(last_cocked + cock_delay > world.time)
			return
		if(CHECK_BITFIELD(reciever_flags, RECIEVER_LOCKS) && in_chamber)
			if(last_cock_message + cock_message_delay > world.time)
				return
			to_chat(user, span_warning(cock_locked_message))
			playsound(user, 'sound/weapons/throwtap.ogg', 25, 1)
			last_cock_message = world.time
			return
		cycle(user)
		to_chat(user, span_notice(cock_notice))
		if(cock_animation)
			flick("[cock_animation]", src)
		cock_delay = world.time
		return
	if(CHECK_BITFIELD(reciever_flags, RECIEVER_TOGGLES_EJECTS) && CHECK_BITFIELD(reciever_flags, RECIEVER_CLOSED))
		for(var/obj/object_to_eject in chamber_items)
			if(user)
				user.put_in_hands(object_to_eject)
			else
				object_to_eject.forceMove(get_turf(src))
	if(CHECK_BITFIELD(reciever_flags, RECIEVER_CLOSED))
		DISABLE_BITFIELD(reciever_flags, RECIEVER_CLOSED)
		return
	ENABLE_BITFIELD(reciever_flags, RECIEVER_CLOSED)



/obj/item/weapon/gun/proc/reload(obj/item/new_mag, mob/living/user)
	if((!(new_mag.type in allowed_ammo_types) && !istype(new_mag, allowed_mag_type)))
		to_chat(user, span_warning("[new_mag] cannot fit into [src]!"))
		return

	if(CHECK_BITFIELD(reciever_flags, RECIEVER_CLOSED))
		to_chat(user, span_warning("[src] is closed!"))
		return

	if((length(chamber_items) == max_chamber_items))
		to_chat(user, span_warning("There is no room for [new_mag]!"))
		return

	if(CHECK_BITFIELD(reciever_flags, RECIEVER_MAGAZINES))
		rounds += new_mag.vars[current_rounds_var]
		max_rounds += new_mag.vars[max_rounds_var]
		chamber_items += new_mag
		get_ammo()
		new_mag.forceMove(src)
		playsound(src, reload_sound, 25, 1)
		user?.temporarilyRemoveItemFromInventory(new_mag)
		if(!in_chamber)
			cycle(user)
		update_icon()
		return

	if(!CHECK_BITFIELD(reciever_flags, RECIEVER_INTERNAL))
		return

	var/obj/item_to_insert = new_mag
	if(CHECK_BITFIELD(reciever_flags, RECIEVER_HANDFULS))
		var/obj/item/ammo_magazine/mag = new_mag
		if(!CHECK_BITFIELD(mag.flags_magazine, MAGAZINE_HANDFUL))
			return
		if(mag.current_rounds > 1)
			item_to_insert = mag.create_handful(null, 1)

	rounds = length(chamber_items) + in_chamber ? 1 : 0
	chamber_items += item_to_insert
	get_ammo()
	item_to_insert.forceMove(src)
	playsound(src, reload_sound, 25, 1)
	user?.temporarilyRemoveItemFromInventory(item_to_insert)
	if(in_chamber)
		return
	if(CHECK_BITFIELD(reciever_flags, RECIEVER_MAGAZINES))
		cycle(user)
	update_icon()
	user?.hud_used.update_ammo_hud(user, src)

/obj/item/weapon/gun/proc/unload(mob/living/user)
	if(HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING))
		return
	if(!length(chamber_items))
		if(in_chamber)
			if(user)
				user.put_in_hands(in_chamber)
			else
				in_chamber.forceMove(get_turf(src))
			in_chamber = null
			return
		return cycle(user)

	var/obj/item/mag = chamber_items[current_chamber_position]
	playsound(src, unload_sound, 25, 1, 5)
	user?.visible_message(span_notice("[user] unloads [mag] from [src]."),
	span_notice("You unload [mag] from [src]."), null, 4)
	rounds -= mag.vars[current_rounds_var]
	max_rounds -= mag.vars[max_rounds_var]
	if(user)
		user.put_in_hands(chamber_items[current_chamber_position])
	else
		chamber_items[current_chamber_position].forceMove(get_turf(src))
	chamber_items -= mag
	mag.update_icon()
	update_icon()
	user?.hud_used.update_ammo_hud(user, src)

	playsound(src, empty_sound, 25, 1)


/obj/item/weapon/gun/proc/return_obj_to_fire()
	if(CHECK_BITFIELD(reciever_flags, RECIEVER_MAGAZINES))
		return get_ammo_object(chamber_items[current_chamber_position])
	return chamber_items[current_chamber_position]

/obj/item/weapon/gun/proc/cycle(mob/living/user)
	if(!CHECK_BITFIELD(reciever_flags, RECIEVER_MAGAZINES))
		var/thing_to_delete = chamber_items[current_chamber_position]
		chamber_items -= thing_to_delete
		qdel(thing_to_delete)
	if((CHECK_BITFIELD(reciever_flags, RECIEVER_CYCLES) && !CHECK_BITFIELD(reciever_flags, RECIEVER_MAGAZINES)) || (CHECK_BITFIELD(reciever_flags, RECIEVER_CYCLES) && CHECK_BITFIELD(reciever_flags, RECIEVER_MAGAZINES) && chamber_items[current_chamber_position].vars[current_rounds_var] <= 0))
		var/next_chamber_position = current_chamber_position + 1
		if(next_chamber_position > max_chamber_items)
			next_chamber_position = 1
		current_chamber_position = next_chamber_position
	if(user)
		playsound(src, cocked_sound, 25, 1)
	if(!user && CHECK_BITFIELD(reciever_flags, RECIEVER_REQUIRES_OPERATION))
		return

	if(!rounds)
		return

	if(CHECK_BITFIELD(reciever_flags, RECIEVER_MAGAZINES))
		var/obj/mag = chamber_items[current_chamber_position]
		mag.vars[current_rounds_var] -= rounds_to_draw
		rounds -= rounds_to_draw
	else
		rounds = length(chamber_items) + in_chamber ? 1 : 0
	make_casing()

	in_chamber = return_obj_to_fire()


/obj/item/weapon/gun/proc/make_casing(obj/item/magazine)
	if(!type_of_casings)
		return
	var/num_of_casings
	if(istype(chamber_items[current_chamber_position], /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/mag = magazine
		num_of_casings = (mag && mag.used_casings) ? mag.used_casings : 1
	else
		num_of_casings = 1
	var/sound_to_play = type_of_casings == "shell" ? 'sound/bullets/bulletcasing_shotgun_fall1.ogg' : pick('sound/bullets/bulletcasing_fall2.ogg','sound/bullets/bulletcasing_fall1.ogg')
	var/turf/current_turf = get_turf(src)
	var/new_casing = text2path("/obj/item/ammo_casing/[type_of_casings]")
	var/obj/item/ammo_casing/casing = locate(new_casing) in current_turf
	if(!casing)
		casing = new new_casing(current_turf)
		num_of_casings--
	if(num_of_casings)
		casing.current_casings += num_of_casings
		casing.update_icon()
	playsound(current_turf, sound_to_play, 25, 1, 5)



/obj/item/weapon/gun/proc/get_ammo_object(obj/item/magazine)
	var/obj/item/mag = magazine
	var/datum/ammo/new_ammo
	if(ammo_type_var)
		new_ammo = mag.vars[ammo_type_var]
		new_ammo = new new_ammo()
	else
		new_ammo = ammo

	var/projectile_type = CHECK_BITFIELD(new_ammo.flags_ammo_behavior, AMMO_HITSCAN) ? /obj/projectile/hitscan : /obj/projectile
	var/obj/projectile/projectile = new projectile_type(null, new_ammo.hitscan_effect_icon)
	projectile.generate_bullet(new_ammo)
	return projectile


/obj/item/weapon/gun/proc/get_ammo()
	if(!CHECK_BITFIELD(reciever_flags, RECIEVER_HANDFULS) && !CHECK_BITFIELD(reciever_flags, RECIEVER_MAGAZINES) || !length(chamber_items))
		return
	var/ammo_type = chamber_items[current_chamber_position].vars[ammo_type_var]
	ammo = new ammo_type()
	return ammo


/obj/item/weapon/gun/proc/drop_connected_mag(mob/user)




//----------------------------------------------------------
				//							\\
				// FIRE CYCLE RELATED PROCS \\
				//							\\
				//						   	\\
//----------------------------------------------------------

/obj/item/weapon/gun/proc/able_to_fire(mob/user)
	if(!user || user.stat != CONSCIOUS || user.lying_angle)
		return

	if(!user.dextrous)
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return FALSE
	if(!(flags_gun_features & GUN_ALLOW_SYNTHETIC) && !CONFIG_GET(flag/allow_synthetic_gun_use) && issynth(user))
		to_chat(user, span_warning("Your program does not allow you to use this firearm."))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_GUN_SAFETY))
		to_chat(user, span_warning("The safety is on!"))
		return FALSE
	if(CHECK_BITFIELD(flags_gun_features, GUN_WIELDED_FIRING_ONLY)) //If we're not holding the weapon with both hands when we should.
		if(!master_gun && !CHECK_BITFIELD(flags_item, WIELDED))
			to_chat(user, "<span class='warning'>You need a more secure grip to fire this weapon!")
			return FALSE
		if(master_gun && !CHECK_BITFIELD(master_gun.flags_item, WIELDED))
			to_chat(user, span_warning("You need a more secure grip to fire [src]!"))
			return FALSE
	if(LAZYACCESS(user.do_actions, src))
		to_chat(user, "<span class='warning'>You are doing something else currently.")
		return FALSE
	if(CHECK_BITFIELD(flags_gun_features, GUN_WIELDED_STABLE_FIRING_ONLY))//If we must wait to finish wielding before shooting.
		if(!master_gun && !wielded_stable())
			to_chat(user, "<span class='warning'>You need a more secure grip to fire this weapon!")
			return FALSE
		if(master_gun && !master_gun.wielded_stable())
			to_chat(user, "<span class='warning'>You need a more secure grip to fire [src]!")
			return FALSE
	if(CHECK_BITFIELD(flags_gun_features, GUN_DEPLOYED_FIRE_ONLY) && !CHECK_BITFIELD(flags_item, IS_DEPLOYED))
		to_chat(user, span_notice("You cannot fire [src] while it is not deployed."))
		return FALSE
	if(CHECK_BITFIELD(flags_gun_features, GUN_IS_ATTACHMENT) && !master_gun && CHECK_BITFIELD(flags_gun_features, GUN_ATTACHMENT_FIRE_ONLY))
		to_chat(user, span_notice("You cannot fire [src] without it attached to a gun!"))
		return FALSE
	return TRUE

/obj/item/weapon/gun/proc/gun_on_cooldown(mob/user)
	var/added_delay = fire_delay
	if(user)
		if(!user.skills.getRating("firearms")) //no training in any firearms
			added_delay += 3 //untrained humans fire more slowly.
		else
			switch(gun_skill_category)
				if(GUN_SKILL_HEAVY_WEAPONS)
					if(fire_delay > 1 SECONDS) //long delay to fire
						added_delay = max(fire_delay - 3 * user.skills.getRating(gun_skill_category), 6)
				if(GUN_SKILL_SMARTGUN)
					if(user.skills.getRating(gun_skill_category) < 0)
						added_delay -= 2 * user.skills.getRating(gun_skill_category)
	var/delay = last_fired + added_delay
	if(gun_firemode == GUN_FIREMODE_BURSTFIRE)
		delay += extra_delay

	if(world.time >= delay)
		return FALSE

	if(world.time % 3 && !user?.client?.prefs.mute_self_combat_messages)
		to_chat(user, span_warning("[src] is not ready to fire again!"))
	return TRUE


/obj/item/weapon/gun/proc/click_empty(mob/user)
	if(user)
		user.hud_used.update_ammo_hud(user, src)
		to_chat(user, span_warning("<b>*click*</b>"))
	playsound(src, dry_fire_sound, 25, 1, 5)

/obj/item/weapon/gun/proc/play_fire_sound(mob/user)
	//Guns with low ammo have their firing sound
	var/firing_sndfreq = ((rounds / max_rounds) > 0.25) ? FALSE : 55000
	if(HAS_TRAIT(src, TRAIT_GUN_SILENCED))
		playsound(user, fire_sound, 25, firing_sndfreq ? TRUE : FALSE, frequency = firing_sndfreq)
		return
	if(firing_sndfreq && fire_rattle)
		playsound(user, fire_rattle, 60, FALSE)
		return
	playsound(user, fire_sound, 60, firing_sndfreq ? TRUE : FALSE, frequency = firing_sndfreq)


/obj/item/weapon/gun/proc/apply_gun_modifiers(obj/projectile/projectile_to_fire, atom/target, firer)
	projectile_to_fire.shot_from = src
	projectile_to_fire.damage *= damage_mult
	projectile_to_fire.damage_falloff *= damage_falloff_mult
	projectile_to_fire.projectile_speed += shell_speed_mod
	if(flags_gun_features & GUN_IFF || HAS_TRAIT(src, TRAIT_GUN_IS_AIMING) || projectile_to_fire.ammo.flags_ammo_behavior & AMMO_IFF)
		var/iff_signal
		if(ishuman(firer))
			var/mob/living/carbon/human/_firer = firer
			var/obj/item/card/id/id = _firer.get_idcard()
			iff_signal = id?.iff_signal
		else if(istype(firer, /obj/machinery/deployable/mounted/sentry))
			var/obj/machinery/deployable/mounted/sentry/sentry = firer
			iff_signal = sentry.iff_signal
		projectile_to_fire.iff_signal = iff_signal
	projectile_to_fire.damage_marine_falloff = iff_marine_damage_falloff


/obj/item/weapon/gun/proc/setup_bullet_accuracy(obj/projectile/projectile_to_fire, mob/user, bullets_fired = 1, dual_wield = FALSE)
	var/gun_accuracy_mult = accuracy_mult_unwielded
	var/gun_accuracy_mod = 0
	var/gun_scatter = scatter_unwielded

	if(flags_item & WIELDED && wielded_stable() || CHECK_BITFIELD(flags_item, IS_DEPLOYED))
		gun_accuracy_mult = accuracy_mult
		gun_scatter = scatter

	else if(user && world.time - user.last_move_time < 5) //moved during the last half second
		//accuracy and scatter penalty if the user fires unwielded right after moving
		gun_accuracy_mult = max(0.1, gun_accuracy_mult - max(0,movement_acc_penalty_mult * 0.15))
		gun_scatter += max(0, movement_acc_penalty_mult * 5)

	if(gun_firemode == GUN_FIREMODE_BURSTFIRE || gun_firemode == GUN_FIREMODE_AUTOBURST && burst_amount > 1)
		gun_accuracy_mult = max(0.1, gun_accuracy_mult * burst_accuracy_mult)

	if(dual_wield) //akimbo firing gives terrible accuracy
		gun_scatter += 10*rand(upper_akimbo_accuracy, lower_akimbo_accuracy)

	if(user)
		// Apply any skill-based bonuses to accuracy
		var/skill_accuracy = 0
		if(!user.skills.getRating("firearms")) //no training in any firearms
			skill_accuracy = -1
		else
			skill_accuracy = user.skills.getRating(gun_skill_category)
		if(skill_accuracy)
			gun_accuracy_mult += skill_accuracy * 0.15 // Accuracy mult increase/decrease per level is equal to attaching/removing a red dot sight

		projectile_to_fire.firer = user
		if(isliving(user))
			var/mob/living/living_user = user
			gun_accuracy_mod += living_user.ranged_accuracy_mod
			if(iscarbon(user))
				var/mob/living/carbon/carbon_user = user
				projectile_to_fire.def_zone = user.zone_selected
				if(carbon_user.stagger)
					gun_scatter += 30

			// Status effect changes
			if(living_user.has_status_effect(STATUS_EFFECT_GUN_SKILL_ACCURACY_BUFF))
				var/datum/status_effect/stacking/gun_skill/buff = living_user.has_status_effect(STATUS_EFFECT_GUN_SKILL_ACCURACY_BUFF)
				gun_accuracy_mod += buff.stacks
			if(living_user.has_status_effect(STATUS_EFFECT_GUN_SKILL_ACCURACY_DEBUFF))
				var/datum/status_effect/stacking/gun_skill/debuff = living_user.has_status_effect(STATUS_EFFECT_GUN_SKILL_ACCURACY_DEBUFF)
				gun_accuracy_mod -= debuff.stacks
			if(living_user.has_status_effect(STATUS_EFFECT_GUN_SKILL_SCATTER_BUFF))
				var/datum/status_effect/stacking/gun_skill/buff = living_user.has_status_effect(STATUS_EFFECT_GUN_SKILL_SCATTER_BUFF)
				gun_scatter -= buff.stacks
			if(living_user.has_status_effect(STATUS_EFFECT_GUN_SKILL_SCATTER_DEBUFF))
				var/datum/status_effect/stacking/gun_skill/debuff = living_user.has_status_effect(STATUS_EFFECT_GUN_SKILL_SCATTER_DEBUFF)
				gun_scatter += debuff.stacks

	projectile_to_fire.accuracy = round((projectile_to_fire.accuracy * gun_accuracy_mult) + gun_accuracy_mod) // Apply gun accuracy multiplier to projectile accuracy
	projectile_to_fire.scatter += gun_scatter					//Add gun scatter value to projectile's scatter value





/obj/item/weapon/gun/proc/get_scatter(starting_scatter, mob/user)
	. = starting_scatter //projectile_to_fire.scatter

	if(. <= 0) //Not if the gun doesn't scatter at all, or negative scatter.
		return 0

	switch(gun_firemode)
		if(GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST, GUN_FIREMODE_AUTOMATIC) //Much higher chance on a burst or similar.
			if(flags_item & WIELDED && wielded_stable() || CHECK_BITFIELD(flags_item, IS_DEPLOYED)) //if deployed, its pretty stable.
				. += burst_amount * burst_scatter_mult
			if(CHECK_BITFIELD(flags_item, IS_DEPLOYED)) //if our gun is deployed, change the scatter by this number, usually a negative
				. += deployed_scatter_change
			else
				. += burst_amount * burst_scatter_mult * 5

	if(!user?.skills.getRating("firearms")) //no training in any firearms
		. += 15
	else
		var/scatter_tweak = user.skills.getRating(gun_skill_category)
		if(scatter_tweak)
			. -= scatter_tweak * 15

	if(!prob(.)) //RNG at work.
		return 0


/obj/item/weapon/gun/proc/simulate_recoil(recoil_bonus = 0, mob/user)
	if(CHECK_BITFIELD(flags_item, IS_DEPLOYED) || !user)
		return TRUE
	var/total_recoil = recoil_bonus
	if(flags_item & WIELDED && wielded_stable() || master_gun)
		total_recoil += recoil
	else
		total_recoil += recoil_unwielded
		if(HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING))
			total_recoil += 1
	if(!user.skills.getRating("firearms")) //no training in any firearms
		total_recoil += 2
	else
		var/recoil_tweak = user.skills.getRating(gun_skill_category)
		if(recoil_tweak)
			total_recoil -= recoil_tweak * 2
	if(total_recoil > 0 && ishuman(user))
		shake_camera(user, total_recoil + 1, total_recoil)
		return TRUE


/obj/item/weapon/gun/proc/muzzle_flash(angle, atom/movable/flash_loc)
	if(!muzzle_flash || muzzle_flash.applied)
		return
	var/prev_light = light_range
	if(!light_on && (light_range <= muzzle_flash_lum))
		set_light_range(muzzle_flash_lum)
		set_light_color(muzzle_flash_color)
		set_light_on(TRUE)
		addtimer(CALLBACK(src, .proc/reset_light_range, prev_light), 1 SECONDS)

	//Offset the pixels.
	switch(angle)
		if(0, 360)
			muzzle_flash.pixel_x = 0
			muzzle_flash.pixel_y = 4
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(1 to 44)
			muzzle_flash.pixel_x = round(4 * ((angle) / 45))
			muzzle_flash.pixel_y = 4
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(45)
			muzzle_flash.pixel_x = 4
			muzzle_flash.pixel_y = 4
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(46 to 89)
			muzzle_flash.pixel_x = 4
			muzzle_flash.pixel_y = round(4 * ((90 - angle) / 45))
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(90)
			muzzle_flash.pixel_x = 4
			muzzle_flash.pixel_y = 0
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(91 to 134)
			muzzle_flash.pixel_x = 4
			muzzle_flash.pixel_y = round(-3 * ((angle - 90) / 45))
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(135)
			muzzle_flash.pixel_x = 4
			muzzle_flash.pixel_y = -3
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(136 to 179)
			muzzle_flash.pixel_x = round(4 * ((180 - angle) / 45))
			muzzle_flash.pixel_y = -3
			muzzle_flash.layer = ABOVE_MOB_LAYER
		if(180)
			muzzle_flash.pixel_x = 0
			muzzle_flash.pixel_y = -3
			muzzle_flash.layer = ABOVE_MOB_LAYER
		if(181 to 224)
			muzzle_flash.pixel_x = round(-3 * ((angle - 180) / 45))
			muzzle_flash.pixel_y = -3
			muzzle_flash.layer = ABOVE_MOB_LAYER
		if(225)
			muzzle_flash.pixel_x = -3
			muzzle_flash.pixel_y = -3
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(226 to 269)
			muzzle_flash.pixel_x = -3
			muzzle_flash.pixel_y = round(-3 * ((270 - angle) / 45))
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(270)
			muzzle_flash.pixel_x = -3
			muzzle_flash.pixel_y = 0
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(271 to 314)
			muzzle_flash.pixel_x = -3
			muzzle_flash.pixel_y = round(4 * ((angle - 270) / 45))
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(315)
			muzzle_flash.pixel_x = -3
			muzzle_flash.pixel_y = 4
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(316 to 359)
			muzzle_flash.pixel_x = round(-3 * ((360 - angle) / 45))
			muzzle_flash.pixel_y = 4
			muzzle_flash.layer = initial(muzzle_flash.layer)

	muzzle_flash.transform = null
	muzzle_flash.transform = turn(muzzle_flash.transform, angle)
	flash_loc.vis_contents += muzzle_flash
	muzzle_flash.applied = TRUE

	addtimer(CALLBACK(src, .proc/remove_muzzle_flash, flash_loc, muzzle_flash), 0.2 SECONDS)

/obj/item/weapon/gun/proc/reset_light_range(lightrange)
	set_light_range(lightrange)
	set_light_color(initial(light_color))
	if(lightrange <= 0)
		set_light_on(FALSE)

/obj/item/weapon/gun/proc/remove_muzzle_flash(atom/movable/flash_loc, atom/movable/vis_obj/effect/muzzle_flash/muzzle_flash)
	if(!QDELETED(flash_loc))
		flash_loc.vis_contents -= muzzle_flash
	muzzle_flash.applied = FALSE

/obj/item/weapon/gun/on_enter_storage(obj/item/I)
	if(istype(I,/obj/item/storage/belt/gun))
		var/obj/item/storage/belt/gun/GB = I
		if(!GB.current_gun)
			GB.current_gun = src //If there's no active gun, we want to make this our icon.
			GB.update_gun_icon()

/obj/item/weapon/gun/on_exit_storage(obj/item/I)
	if(istype(I,/obj/item/storage/belt/gun))
		var/obj/item/storage/belt/gun/GB = I
		if(GB.current_gun == src)
			GB.current_gun = null
			GB.update_gun_icon()

//For letting xenos turn off the flashlights on any guns left lying around.
/obj/item/weapon/gun/attack_alien(mob/living/carbon/xenomorph/X, isrightclick = FALSE)
	if(!HAS_TRAIT(src, TRAIT_GUN_FLASHLIGHT_ON))
		return
	var/obj/item/attachment = attachments_by_slot[ATTACHMENT_SLOT_RAIL]
	if(!istype(attachment, /obj/item/attachable))
		return
	var/obj/item/attachable/attachable = attachment
	attachable.turn_light(null, FALSE)
	playsound(loc, "alien_claw_metal", 25, 1)
	X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	to_chat(X, span_warning("We disable the metal thing's lights.") )
