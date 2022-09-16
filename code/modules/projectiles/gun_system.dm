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

/*
 *  Muzzle Vars
*/
	///Effect for the muzzle flash of the gun.
	var/atom/movable/vis_obj/effect/muzzle_flash/muzzle_flash
	///Icon state of the muzzle flash effect.
	var/muzzleflash_iconstate
	///Brightness of the muzzle flash effect.
	var/muzzle_flash_lum = 3
	///Color of the muzzle flash effect.
	var/muzzle_flash_color = COLOR_VERY_SOFT_YELLOW

/*
 *  Firing Vars
*/

	///State for a fire animation if the gun has any
	var/fire_animation = null
	///Animation for opening the chamber of a gun.
	var/shell_eject_animation = null

	///Sound of firing the gun.
	var/fire_sound = 'sound/weapons/guns/fire/gunshot.ogg'
	///Does our gun have a unique sound when running out of ammo? If so, use this instead of pitch shifting.
	var/fire_rattle = null
	///World.time of last gun firing.
	var/last_fired = 0


/*
 *  Cocking Vars
*/
	///Message given to user on cocking.
	var/cocked_message
	///Message for a pump lock.
	var/cock_locked_message
	///Message for when the chamber is opened.
	var/chamber_opened_message
	///Message for when the chamber is closed.
	var/chamber_closed_message

	///Animation of the gun Cocking.
	var/cock_animation

	///World.time of the last cocked_message.
	var/last_cock_message
	///Delay between given cocked_message.
	var/cock_message_delay = 1 SECONDS

	///Sound of cocking the gun.
	var/cocked_sound = null
	///Sounds of opening the guns reciever. (DBs, Martinis opening.)
	var/opened_sound = null

	///World.time of the last cock.
	var/last_cocked
	///Delay between cocking the gun.
	var/cock_delay = 3 SECONDS

/*
 *  RELOADING_VARS
 *
*/
	///Sound for the gun firing when empty.
	var/dry_fire_sound = 'sound/weapons/guns/fire/empty.ogg'
	///Sound of unloading the gun.
	var/unload_sound = 'sound/weapons/flipblade.ogg'
	///Sound played when the gun auto ejects its magazine.
	var/empty_sound = 'sound/weapons/guns/misc/empty_alarm.ogg'
	///Sound played for reloading.
	var/reload_sound = null
	///Sound for reloading by handfuls
	var/hand_reload_sound

	///Stored sum of magazine rounds / chamber contents. This is used for anything needing ammo. It is updated on reload/unload/fire
	var/rounds
	///If the gun uses magazines, it is the max rounds of the magazine(s). If it has an internal chamber, it is max_chamber_items.
	var/max_rounds

	///Current object slated for firing. Magazines/Handfuls will make this a projectile. Internal magazines that aren't handfuls will have this be the object in the gun.
	var/obj/in_chamber
	///List of stored ammunition items.
	var/list/obj/chamber_items = list()
	///Maximum allowed chamber items. If the gun has AMMO_RECIEVER_TOGGLES_OPEN then the total amount in the gun will be the one here. If not, the gun will be able to contain this number + the chamber. If this is zero and doesnt use magazines, reloading will go directly into the chamber.
	var/max_chamber_items = 1

	///Current selected position of chamber_items, this will determin the next item to be inserted into the chamber. If the gun uses magazines it will be the position of the magazine to be used. If the gun cycles (revolvers), this number will increase by one everytime it cycles until it reaches max_chamber_items, then it will revert back to one.
	var/current_chamber_position = 1

	///Flags to determin guns ammo/operation.
	var/reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_AUTO_EJECT

	///Types of casing it ejects.
	var/type_of_casings = null
	///Amount of casings to eject for guns that toggle like revolvers and dbs.
	var/casings_to_eject

	///If the gun uses a magazine, the gun will subtract this from the magazine every fire.
	var/rounds_per_shot = 1

	///Stored ammo datum. I changed the var name because it was really annoying to find specific cases of 'ammo' in a file full of guns and ammunition.
	var/datum/ammo/ammo_datum_type = /datum/ammo/bullet
	///Default magazine to spawn with.
	var/default_ammo_type = null
	///List of allowed specific types. If trying to reload with something in this list it will succeed. This is mainly for use in internal magazine weapons or scenarios where you do not want to inclue a whole subtype.
	var/list/allowed_ammo_types = list(
		/obj/item/ammo_magazine,
	)

/*
 * Operation Vars
*/

	///Innate carateristics of that gun
	var/flags_gun_features = GUN_CAN_POINTBLANK
	///Current selected firemode of the gun.
	var/gun_firemode = GUN_FIREMODE_SEMIAUTO
	///List of allowed firemodes.
	var/list/gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)

	///Skill used to operate this gun.
	var/gun_skill_category = GUN_SKILL_RIFLES

	///the default gun icon_state. change to reskin the gun
	var/base_gun_icon

	///Key for the codex
	var/general_codex_key = "guns"

	///The mob holding the gun
	var/mob/living/gun_user
	///The atom targeted by the user
	var/atom/target
	///How many bullets the gun fired while bursting/auto firing
	var/shots_fired = 0
	///If this gun is in inactive hands and shooting in akimbo
	var/dual_wield = FALSE
	///determines upper accuracy modifier in akimbo
	var/upper_akimbo_accuracy = 2
	///determines lower accuracy modifier in akimbo
	var/lower_akimbo_accuracy = 1
	///If fire delay is 1 second, and akimbo_additional_delay is 0.5, then you'll have to wait 1 second * 0.5 to fire the second gun
	var/akimbo_additional_delay = 0.5
	///Delay for the gun winding up before firing.
	var/windup_delay = 0
	///Sound played during windup.
	var/windup_sound
	///Used if a weapon need windup before firing
	var/windup_checked = WEAPON_WINDUP_NOT_CHECKED

/*
 *  STAT VARS
*/

	///Multiplier. Increased and decreased through attachments. Multiplies the projectile's accuracy by this number.
	var/accuracy_mult = 1
	///Same as above, for damage.
	var/damage_mult = 1
	///Same as above, for damage bleed (falloff)
	var/damage_falloff_mult = 1
	///Screen shake when the weapon is fired while wielded.
	var/recoil = 0
	///Screen shake when the weapon is fired while unwielded.
	var/recoil_unwielded = 0
	///a multiplier of the duration the recoil takes to go back to normal view, this is (recoil*recoil_backtime_multiplier)+1
	var/recoil_backtime_multiplier = 2
	///this is how much deviation the gun recoil can have, recoil pushes the screen towards the reverse angle you shot + some deviation which this is the max.
	var/recoil_deviation = 22.5
	///How much the bullet scatters when fired while wielded.
	var/scatter	= 4
	///How much the bullet scatters when fired while unwielded.
	var/scatter_unwielded = 12
	///Multiplier. Increases or decreases how much bonus scatter is added when burst firing (wielded only).
	var/burst_scatter_mult = 1
	///Multiplier. Defaults to 1 (no penalty). Multiplies accuracy modifier by this amount while burst firing; usually a fraction (penalty) when set.
	var/burst_accuracy_mult	= 1
	///same vars as above but for unwielded firing.
	var/accuracy_mult_unwielded = 1
	///Multiplier. Increased and decreased through attachments. Multiplies the accuracy/scatter penalty of the projectile when firing onehanded while moving.
	var/movement_acc_penalty_mult = 5
	///For regular shots, how long to wait before firing again.
	var/fire_delay = 6
	///Modifies the speed of projectiles fired.
	var/shell_speed_mod	= 0
	///Modifies projectile damage by a % when a marine gets passed, but not hit
	var/iff_marine_damage_falloff = 0
	///Determines how fire delay is changed when aim mode is active
	var/aim_fire_delay = 0
	///Holds the values modifying aim_fire_delay
	var/list/aim_fire_delay_mods = list()
	///Determines character slowdown from aim mode. Default is 66%
	var/aim_speed_modifier = 6
	/// Time to enter aim mode, generally one second.
	var/aim_time = 1 SECONDS

	///How many shots can the weapon shoot in burst? Anything less than 2 and you cannot toggle burst.
	var/burst_amount = 1
	///The delay in between shots. Lower = less delay = faster.
	var/burst_delay = 0.1 SECONDS
	///When burst-firing, this number is extra time before the weapon can fire again. Depends on number of rounds fired.
	var/extra_delay	= 0
	///when autobursting, this is the amount of extra (extra) time before the weapon fires again. If no amount is specified, defaults to x2 fire_delay
	var/autoburst_delay = 0

	///Slowdown for wielding
	var/aim_slowdown = 0
	///How long between wielding and firing in tenths of seconds
	var/wield_delay	= 0.4 SECONDS
	///Extra wield delay for untrained operators
	var/wield_penalty = 0.2 SECONDS
	///Storing value for above
	var/wield_time = 0


	///how much energy is consumed per shot.
	var/charge_cost	= 0
	///How much ammo consumed per shot; normally 1.
	var/ammo_per_shot = 1
	///In overcharge mode?
	var/overcharge = 0
	///what ammo to use for overcharge
	var/ammo_diff = null

/*
 *  extra icon and item states or overlays
*/

	///Whether the gun has ammo level overlays for its icon, mainly for eguns
	var/ammo_level_icon
	///Whether the icon_state overlay is offset in the x axis
	var/icon_overlay_x_offset = 0
	///Whether the icon_state overlay is offset in the Y axis
	var/icon_overlay_y_offset = 0

/*
 *
 *   ATTACHMENT VARS
 *
*/


	///List of offsets to make attachment overlays not look wonky.
	var/list/attachable_offset = null
	///List of allowed attachments, IT MUST INCLUDE THE STARTING ATTACHMENT TYPES OR THEY WILL NOT ATTACH.
	var/list/attachable_allowed = null
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
	///the current gun attachment, used for attachment aim mode
	var/obj/item/weapon/gun/gunattachment = null
/*
 * Gun as Attachment Vars
*/

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
	///How long ADS takes (time before firing)
	var/wield_delay_mod	= 0


/*
 * Deployed and Sentry Vars
*/
	///If the gun has a deployed item..
	var/deployable_item = null

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
	///IFF signal for sentries. If it is set here it will be this signal forever. If null the IFF signal will be dependant on the deployer.
	var/sentry_iff_signal = NONE

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
	AddComponent(/datum/component/automatedfire/autofire, fire_delay, autoburst_delay, burst_delay, burst_amount, gun_firemode, CALLBACK(src, .proc/set_bursting), CALLBACK(src, .proc/reset_fire), CALLBACK(src, .proc/Fire)) //This should go after handle_starting_attachment() and setup_firemodes() to get the proper values set.
	AddComponent(/datum/component/attachment_handler, attachments_by_slot, attachable_allowed, attachable_offset, starting_attachment_types, null, CALLBACK(src, .proc/on_attachment_attach), CALLBACK(src, .proc/on_attachment_detach), attachment_overlays)
	if(CHECK_BITFIELD(flags_gun_features, GUN_IS_ATTACHMENT))
		AddElement(/datum/element/attachment, slot, icon, .proc/on_attach, .proc/on_detach, .proc/activate, .proc/can_attach, pixel_shift_x, pixel_shift_y, flags_attach_features, attach_delay, detach_delay, "firearms", SKILL_FIREARMS_DEFAULT, 'sound/machines/click.ogg')

	muzzle_flash = new(src, muzzleflash_iconstate)

	if(deployable_item)
		AddElement(/datum/element/deployable_item, deployable_item, type, deploy_time, undeploy_time)

	GLOB.nightfall_toggleable_lights += src

	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_ROTATES_CHAMBER))
		for(var/i in 0 to max_chamber_items)
			chamber_items.Add(null)
	if(spawn_empty)
		update_icon()
		return
	INVOKE_ASYNC(src, .proc/fill_gun)

/obj/item/weapon/gun/Destroy()
	active_attachable = null
	QDEL_NULL(muzzle_flash)
	QDEL_NULL(chamber_items)
	QDEL_NULL(in_chamber)
	GLOB.nightfall_toggleable_lights -= src
	set_gun_user(null)
	return ..()

/obj/item/weapon/gun/turn_light(mob/user, toggle_on, cooldown, sparks, forced, light_again)
	. = ..()
	if(. != CHECKS_PASSED)
		return
	var/obj/item/attachable = attachments_by_slot[ATTACHMENT_SLOT_RAIL]
	if(!attachable || !istype(attachable, /obj/item/attachable))
		return
	var/obj/item/attachable/attachable_attachment = attachable
	attachable_attachment.turn_light(user, toggle_on, cooldown, sparks, forced, light_again)

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
	. = ..()
	set_gun_user(null)
	active_attachable?.removed_from_inventory(user)
	if(!length(chamber_items) || !chamber_items[current_chamber_position] || chamber_items[current_chamber_position].loc == src)
		return
	drop_connected_mag(chamber_items[current_chamber_position], user)

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
	if(master_gun?.master_gun) //Prevent gunception
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
	. = ..()

	for(var/datum/action/action AS in actions)
		action.update_button_icon()

	if(master_gun)
		for(var/datum/action/action AS in master_gun.actions)
			action.update_button_icon()

	update_item_state()

/obj/item/weapon/gun/update_icon_state()
	. = ..()
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_TOGGLES_OPEN) && !CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_CLOSED))
		icon_state = base_gun_icon + "_o"
	else if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION) && !in_chamber && length(chamber_items))
		icon_state = base_gun_icon + "_u"
	else if((!length(chamber_items) && max_chamber_items) || !rounds)
		icon_state = base_gun_icon + "_e"
	else if(current_chamber_position <= length(chamber_items) && chamber_items[current_chamber_position] && chamber_items[current_chamber_position].loc != src)
		icon_state = base_gun_icon + "_l"
	else
		icon_state = base_gun_icon

//manages the overlays for the gun - separate from attachment overlays
/obj/item/weapon/gun/update_overlays()
	. = ..()
	//ammo level overlays
	if(ammo_level_icon && length(chamber_items) && rounds > 0 && chamber_items[current_chamber_position].loc == src)
		var/remaining = CEILING((rounds /(max_rounds)) * 100, 25)
		var/image/ammo_overlay = image(icon, icon_state = "[ammo_level_icon]_[remaining]", pixel_x = icon_overlay_x_offset, pixel_y = icon_overlay_y_offset)
		. += ammo_overlay

	//magazines overlays
	var/image/overlay = attachment_overlays[ATTACHMENT_SLOT_MAGAZINE]
	if(!CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES) || !length(chamber_items))
		attachment_overlays[ATTACHMENT_SLOT_MAGAZINE] = null
		return
	if(!get_magazine_overlay(chamber_items[current_chamber_position]))
		return
	var/obj/item/current_mag = chamber_items[current_chamber_position]
	overlay = get_magazine_overlay(current_mag)
	attachment_overlays[ATTACHMENT_SLOT_MAGAZINE] = overlay
	. += overlay

/obj/item/weapon/gun/update_item_state()
	if(!CHECK_BITFIELD(flags_gun_features, GUN_SHOWS_AMMO_REMAINING))
		item_state = "[base_gun_icon][flags_item & WIELDED ? "_w" : ""]"
		return

	//If the gun has item states that show how much ammo is remaining
	var/current_state = item_state
	var/cell_charge = (!length(chamber_items) || rounds <= 0) ? 0 : CEILING((rounds / max((length(chamber_items) ? max_rounds : max_shells), 1)) * 100, 25)
	item_state = "[initial(icon_state)]_[cell_charge][flags_item & WIELDED ? "_w" : ""]"
	if(current_state != item_state && ishuman(gun_user))
		var/mob/living/carbon/human/human_user = gun_user
		if(src == human_user.l_hand)
			human_user.update_inv_l_hand()
		else if (src == human_user.r_hand)
			human_user.update_inv_r_hand()


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
		dat += gun_attachable.rounds ? "([gun_attachable.rounds]/[gun_attachable.max_rounds])" : "(Unloaded)"

	if(dat)
		. += "[dat.Join(" ")]"

	examine_ammo_count(user)
	if(!CHECK_BITFIELD(flags_item, IS_DEPLOYED))
		if(CHECK_BITFIELD(flags_item, IS_DEPLOYABLE))
			. += span_notice("Use Ctrl-Click on a tile to deploy.")
		return
	if(!CHECK_BITFIELD(flags_item, DEPLOYED_NO_ROTATE))
		. += span_notice("Right Click on a nearby tile to aim rotate towards it.")
		return
	. += span_notice("Click-Drag to yourself to undeploy.")
	. += span_notice("Alt-Click to unload.")
	. += span_notice("Right-Click to perform the guns unique action.")

///Gives the user a description of the ammunition remaining, as well as other information pertaining to reloading/ammo.
/obj/item/weapon/gun/proc/examine_ammo_count(mob/user)
	if(CHECK_BITFIELD(flags_gun_features, GUN_UNUSUAL_DESIGN) && CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES)) //Internal mags and unusual guns have their own stuff set.
		return
	var/list/dat = list()
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_TOGGLES_OPEN))
		dat += "[CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_CLOSED) ? "It is closed. \n" : "It is open. \n"]"
	if(rounds > 0)
		if(flags_gun_features & GUN_AMMO_COUNTER)
			if(max_rounds && CHECK_BITFIELD(flags_gun_features, GUN_AMMO_COUNT_BY_PERCENTAGE))
				dat += "Ammo counter shows [round((rounds / max_rounds) * 100)] percent remaining.<br>"
			else if(max_rounds && CHECK_BITFIELD(flags_gun_features, GUN_AMMO_COUNT_BY_SHOTS_REMAINING))
				dat += "Ammo counter shows [round(max_rounds / rounds_per_shot)] shots remaining."
			else
				dat += "Ammo counter shows [rounds] round\s remaining.<br>"
		else
			dat += "It's loaded[in_chamber?" and has a round chambered":""].<br>"
	else
		dat += "It's unloaded[in_chamber?" but has a round chambered":""].<br>"
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES) && max_chamber_items > 1)
		dat += "It has [length(chamber_items)] of [max_chamber_items] magazines loaded.\n"
	if(!dat)
		return
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
			modify_fire_delay(fire_delay * akimbo_additional_delay) // Adds the additional delay to auto_fire
			if(gun_user.get_inactive_held_item() == src && (gun_firemode == GUN_FIREMODE_SEMIAUTO || gun_firemode == GUN_FIREMODE_BURSTFIRE))
				return
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
	if(dual_wield)
		modify_fire_delay(-fire_delay + fire_delay/(1 + akimbo_additional_delay)) // Removes the additional delay from auto_fire
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
	if(!target || !(gun_user || istype(loc, /obj/machinery/deployable/mounted/sentry)) || !(CHECK_BITFIELD(flags_item, IS_DEPLOYED) || able_to_fire(gun_user)) || windup_checked == WEAPON_WINDUP_CHECKING)
		return
	if(windup_delay && windup_checked == WEAPON_WINDUP_NOT_CHECKED)
		windup_checked = WEAPON_WINDUP_CHECKING
		playsound(loc, windup_sound, 30, TRUE)
		if(!gun_user)
			addtimer(CALLBACK(src, .proc/fire_after_autonomous_windup), windup_delay)
			return
		if(!do_after(gun_user, windup_delay, TRUE, src, BUSY_ICON_DANGER, BUSY_ICON_DANGER, ignore_turf_checks = TRUE))
			windup_checked = WEAPON_WINDUP_NOT_CHECKED
			return
		windup_checked = WEAPON_WINDUP_CHECKED
	if(!target)
		windup_checked = WEAPON_WINDUP_NOT_CHECKED
		return
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE))
		cycle(gun_user, FALSE)
	//The gun should return the bullet that it already loaded from the end cycle of the last Fire().
	var/obj/projectile/projectile_to_fire = in_chamber //Load a bullet in or check for existing one.
	if(!projectile_to_fire) //If there is nothing to fire, click.
		playsound(src, dry_fire_sound, 25, 1, 5)
		if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_ROTATES_CHAMBER) && !CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION) && !CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE))
			cycle(gun_user, FALSE)
		windup_checked = WEAPON_WINDUP_NOT_CHECKED
		return

	if(!do_fire(projectile_to_fire))
		windup_checked = WEAPON_WINDUP_NOT_CHECKED
		return

	last_fired = world.time
	SEND_SIGNAL(src, COMSIG_MOB_GUN_FIRED, target, src)

	if(!max_chamber_items)
		in_chamber = null
	else
		if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_TOGGLES_OPEN) || CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION))
			casings_to_eject++
		if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_HANDFULS))
			QDEL_NULL(in_chamber)
		else
			in_chamber = null
		if(!(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION) || CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE)))
			cycle(null)
		if(length(chamber_items) && CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_AUTO_EJECT) && CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES) && get_current_rounds(chamber_items[current_chamber_position]) < (!CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION) ? rounds_per_shot : 0))
			playsound(src, empty_sound, 25, 1)
			unload(after_fire = TRUE)
	update_ammo_count()
	gun_user?.hud_used.update_ammo_hud(gun_user, src)
	update_icon()
	if(dual_wield && (gun_firemode == GUN_FIREMODE_SEMIAUTO || gun_firemode == GUN_FIREMODE_BURSTFIRE))
		var/obj/item/weapon/gun/inactive_gun = gun_user.get_inactive_held_item()
		if(inactive_gun.rounds && !(inactive_gun.flags_gun_features & GUN_WIELDED_FIRING_ONLY))
			inactive_gun.last_fired = max(world.time - fire_delay * (1 - akimbo_additional_delay), inactive_gun.last_fired)
			gun_user.swap_hand()
	return TRUE

///Actually fires the gun, sets up the projectile and fires it.
/obj/item/weapon/gun/proc/do_fire(obj/object_to_fire)
	var/firer = (istype(loc, /obj/machinery/deployable/mounted/sentry) && !gun_user) ? loc : gun_user
	var/obj/projectile/projectile_to_fire = object_to_fire
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_HANDFULS))
		projectile_to_fire = get_ammo_object()
	apply_gun_modifiers(projectile_to_fire, target, firer)
	setup_bullet_accuracy(projectile_to_fire, gun_user, shots_fired) //User can be passed as null.

	var/firing_angle = get_angle_with_scatter((gun_user || get_turf(src)), target, get_scatter(projectile_to_fire.scatter, gun_user), projectile_to_fire.p_x, projectile_to_fire.p_y)

	//Finally, make with the pew pew!
	if(!isobj(projectile_to_fire))
		stack_trace("projectile malfunctioned while firing. User: [gun_user]")
		return
	play_fire_sound(loc)

	if(muzzle_flash && !muzzle_flash.applied)
		var/atom/movable/flash_loc = (master_gun || !istype(loc, /obj/machinery/deployable/mounted)) ? gun_user : loc
		var/prev_light = light_range
		if(!light_on && (light_range <= muzzle_flash_lum))
			set_light_range(muzzle_flash_lum)
			set_light_color(muzzle_flash_color)
			set_light_on(TRUE)
			addtimer(CALLBACK(src, .proc/reset_light_range, prev_light), 1 SECONDS)
		//Offset the pixels.
		switch(firing_angle)
			if(0, 360)
				muzzle_flash.pixel_x = 0
				muzzle_flash.pixel_y = 4
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(1 to 44)
				muzzle_flash.pixel_x = round(4 * ((firing_angle) / 45))
				muzzle_flash.pixel_y = 4
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(45)
				muzzle_flash.pixel_x = 4
				muzzle_flash.pixel_y = 4
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(46 to 89)
				muzzle_flash.pixel_x = 4
				muzzle_flash.pixel_y = round(4 * ((90 - firing_angle) / 45))
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(90)
				muzzle_flash.pixel_x = 4
				muzzle_flash.pixel_y = 0
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(91 to 134)
				muzzle_flash.pixel_x = 4
				muzzle_flash.pixel_y = round(-3 * ((firing_angle - 90) / 45))
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(135)
				muzzle_flash.pixel_x = 4
				muzzle_flash.pixel_y = -3
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(136 to 179)
				muzzle_flash.pixel_x = round(4 * ((180 - firing_angle) / 45))
				muzzle_flash.pixel_y = -3
				muzzle_flash.layer = ABOVE_MOB_LAYER
			if(180)
				muzzle_flash.pixel_x = 0
				muzzle_flash.pixel_y = -3
				muzzle_flash.layer = ABOVE_MOB_LAYER
			if(181 to 224)
				muzzle_flash.pixel_x = round(-3 * ((firing_angle - 180) / 45))
				muzzle_flash.pixel_y = -3
				muzzle_flash.layer = ABOVE_MOB_LAYER
			if(225)
				muzzle_flash.pixel_x = -3
				muzzle_flash.pixel_y = -3
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(226 to 269)
				muzzle_flash.pixel_x = -3
				muzzle_flash.pixel_y = round(-3 * ((270 - firing_angle) / 45))
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(270)
				muzzle_flash.pixel_x = -3
				muzzle_flash.pixel_y = 0
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(271 to 314)
				muzzle_flash.pixel_x = -3
				muzzle_flash.pixel_y = round(4 * ((firing_angle - 270) / 45))
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(315)
				muzzle_flash.pixel_x = -3
				muzzle_flash.pixel_y = 4
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(316 to 359)
				muzzle_flash.pixel_x = round(-3 * ((360 - firing_angle) / 45))
				muzzle_flash.pixel_y = 4
				muzzle_flash.layer = initial(muzzle_flash.layer)

		muzzle_flash.transform = null
		muzzle_flash.transform = turn(muzzle_flash.transform, firing_angle)
		flash_loc.vis_contents += muzzle_flash
		muzzle_flash.applied = TRUE

		addtimer(CALLBACK(src, .proc/remove_muzzle_flash, flash_loc, muzzle_flash), 0.2 SECONDS)

	simulate_recoil(dual_wield, firing_angle)

	projectile_to_fire.fire_at(target, master_gun ? gun_user : loc, src, projectile_to_fire.ammo.max_range, projectile_to_fire.projectile_speed, firing_angle, suppress_light = HAS_TRAIT(src, TRAIT_GUN_SILENCED))

	shots_fired++

	if(fire_animation) //Fires gun firing animation if it has any. ex: rotating barrel
		flick("[fire_animation]", src)

	return TRUE

/// Fire after a fake windup
/obj/item/weapon/gun/proc/fire_after_autonomous_windup()
	windup_checked = WEAPON_WINDUP_CHECKED
	Fire()

/obj/item/weapon/gun/attack(mob/living/M, mob/living/user, def_zone)
	if(!CHECK_BITFIELD(flags_gun_features, GUN_CAN_POINTBLANK) || !able_to_fire(user) || gun_on_cooldown(user) || CHECK_BITFIELD(M.status_flags, INCORPOREAL)) // If it can't point blank, you can't suicide and such.
		if(master_gun)
			return
		return ..()

	if(M != user && (M.faction != user.faction || user.a_intent == INTENT_HARM))
		. = ..()
		if(!.)
			return
		set_target(M)
		if(gun_firemode == GUN_FIREMODE_BURSTFIRE && burst_amount > 1)
			SEND_SIGNAL(src, COMSIG_GUN_FIRE)
			return TRUE
		Fire()
		return TRUE

	if(master_gun)
		return

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
		playsound(src, dry_fire_sound, 25, 1, 5)
		ENABLE_BITFIELD(flags_gun_features, GUN_CAN_POINTBLANK)
		return

	projectile_to_fire = get_ammo_object()

	user.visible_message("<span class = 'warning'>[user] pulls the trigger!</span>")
	var/actual_sound = (active_attachable?.fire_sound) ? active_attachable.fire_sound : fire_sound
	var/sound_volume = (HAS_TRAIT(src, TRAIT_GUN_SILENCED) && !active_attachable) ? 25 : 60
	playsound(user, actual_sound, sound_volume, 1)
	simulate_recoil(2, Get_Angle(user, M))
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

	QDEL_NULL(projectile_to_fire)

	ENABLE_BITFIELD(flags_gun_features, GUN_CAN_POINTBLANK)

/obj/item/weapon/gun/attack_alternate(mob/living/M, mob/living/user)
	if(active_attachable)
		active_attachable.attack(M, user)
		return
	return ..()

//----------------------------------------------------------
				//							\\
				//         RELOADING        \\
				//							\\
				//						   	\\
//----------------------------------------------------------


/**
 *  Performs the unique action. Can be overwritten.
 *  This does a few things, depending on the flags of the gun.
 *  If the gun doesn't Toggle it will perform a cycle, if it requires operation the gun will check the cycle against the cock delays.
 *  If the gun does toggle, Unique action will open the chamber. (Open the barrel on a DB, or the cylinder on a revolver.)
 */
/obj/item/weapon/gun/unique_action(mob/user, special_treatment = FALSE)
	if(HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING))
		return
	if(!length(chamber_items) && in_chamber && !CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_TOGGLES_OPEN) && !CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION))
		unload(user)
		return
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION) && !special_treatment)
		if(last_cocked + cock_delay > world.time)
			return
		if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_UNIQUE_ACTION_LOCKS) && in_chamber)
			if(last_cock_message + cock_message_delay > world.time)
				return
			if(cock_locked_message)
				to_chat(user, span_warning(cock_locked_message))
			playsound(user, 'sound/weapons/throwtap.ogg', 25, 1)
			last_cock_message = world.time
			return
		cycle(user, FALSE)
		playsound(src, cocked_sound, 25, 1)
		if(!CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_TOGGLES_OPEN) && casings_to_eject)
			make_casing()
			casings_to_eject = 0
		if(cocked_message)
			to_chat(user, span_notice(cocked_message))
		if(cock_animation)
			flick("[cock_animation]", src)
		last_cocked = world.time
		return
	if(!CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_TOGGLES_OPEN))
		cycle(user, FALSE)
		playsound(src, cocked_sound, 25, 1)
		return
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_CLOSED)) //We want to open it.
		DISABLE_BITFIELD(reciever_flags, AMMO_RECIEVER_CLOSED)
		playsound(src, opened_sound, 25, 1)
		if(shell_eject_animation)
			flick("[shell_eject_animation]", src)
		if(chamber_opened_message)
			to_chat(user, span_notice(chamber_opened_message))
		if(in_chamber)
			if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES))
				adjust_current_rounds(chamber_items[current_chamber_position], rounds_per_shot)  //If the gun uses mags, it will refund the current mag.
				QDEL_NULL(in_chamber)
			else
				chamber_items.Insert(current_chamber_position, in_chamber) //Otherwise we insert in_chamber back into the chamber_items. We dont want in_chamber to be full when the gun is open.
				in_chamber = null
		if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_TOGGLES_OPEN_EJECTS))
			if(length(chamber_items))
				if(!CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_HANDFULS))
					for(var/obj/object_to_eject in chamber_items) //If the gun ejects on toggle, we wanna yeet the loaded items out.
						if(user)
							user.put_in_hands(object_to_eject)
						else
							object_to_eject.forceMove(get_turf(src))
				else
					var/obj/item/ammo_magazine/handful_to_fill = chamber_items[1]
					var/list/obj/item/objects_to_eject = list(handful_to_fill)
					for(var/obj/item/ammo_magazine/handful_to_eject in chamber_items)
						if(handful_to_eject == handful_to_fill || !handful_to_eject)
							continue
						if(!handful_to_fill || handful_to_eject.default_ammo != handful_to_fill.default_ammo)
							handful_to_fill = handful_to_eject
							objects_to_eject += handful_to_fill
							continue
						handful_to_fill.transfer_ammo(handful_to_eject, user, handful_to_eject.current_rounds)
						if(handful_to_fill.current_rounds < handful_to_fill.max_rounds)
							continue
						handful_to_fill = handful_to_eject
						objects_to_eject += handful_to_fill
					for(var/obj/object_to_eject in objects_to_eject)
						if(user)
							user.put_in_hands(object_to_eject)
						else
							object_to_eject.forceMove(get_turf(src))
				chamber_items = list()
				if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_ROTATES_CHAMBER)) //If the reciever cycles (like revolvers) we want to populate the chamber with null objects.
					for(var/i = 0, i < max_chamber_items, i++)
						chamber_items.Add(null)
			for(var/i = 0, i < casings_to_eject, i++) //Eject casings equal to the rounds fired between the last opening.
				make_casing(null, FALSE)
			casings_to_eject = 0
	else
		ENABLE_BITFIELD(reciever_flags, AMMO_RECIEVER_CLOSED)
		playsound(src, cocked_sound, 25, 1)
		if(chamber_closed_message)
			to_chat(user, span_notice(chamber_opened_message))
		cycle(user, FALSE)
	update_ammo_count()
	update_icon()


/**
 *  Handles reloading. Called on attack_by
 *  Reload works in one of three ways, depending on the guns flags.
 *  First, if the gun is set to magazines, it will do checks based on the magazines vars and if it succeeds it will load the magazine.
 *  If the gun uses handfuls, the gun will create or take a handful with one round and insert those.
 *  If the gun does not use handfuls, or magazines. It will merely fill the gun with whatever item is inserted.
 */
/obj/item/weapon/gun/proc/reload(obj/item/new_mag, mob/living/user, force = FALSE)
	if(HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING) || user?.do_actions)
		return
	if(!(new_mag.type in allowed_ammo_types))
		if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_HANDFULS))
			var/obj/item/ammo_magazine/mag = new_mag
			if(!CHECK_BITFIELD(mag.flags_magazine, MAGAZINE_HANDFUL)) //If the gun uses handfuls, it accepts all handfuls since it uses caliber to check if its allowed.
				to_chat(user, span_warning("[new_mag] cannot fit into [src]!"))
				return FALSE
			if(mag.caliber != caliber)
				to_chat(user, span_warning("Those handfuls cannot fit into [src]!"))
				return FALSE
		else
			to_chat(user, span_warning("[new_mag] cannot fit into [src]!"))
			return FALSE

	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_CLOSED) && !force)
		if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_TOGGLES_OPEN)) //AMMO_RECIEVER_CLOSED without AMMO_RECIEVER_TOGGLES_OPEN means the gun is not allowed to reload. Period.
			to_chat(user, span_warning("[src] is closed!"))
		else
			to_chat(user, span_warning("You cannot reload [src]!"))
		return FALSE

	if((length(chamber_items) >= max_chamber_items) && max_chamber_items)
		if(!CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_ROTATES_CHAMBER))
			to_chat(user, span_warning("There is no room for [new_mag]!"))
			return FALSE
		if(rounds >= max_chamber_items)
			to_chat(user, span_warning("There is no room for [new_mag]!"))
			return FALSE

	if(!max_chamber_items && in_chamber)
		to_chat(user, span_warning("[src]'s chamber is closed"))
		return FALSE

	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES))
		if(!get_current_rounds(new_mag) && !force)
			to_chat(user, span_notice("[new_mag] is empty!"))
			return FALSE
		var/flags_magazine_features = get_flags_magazine_features(new_mag)
		if(flags_magazine_features && CHECK_BITFIELD(flags_magazine_features, MAGAZINE_WORN) && user && user.get_active_held_item() == new_mag)
			return FALSE
		if(get_magazine_reload_delay(new_mag) > 0 && user && !force)
			to_chat(user, span_notice("You begin reloading [src] with [new_mag]."))
			if(!do_after(user, get_magazine_reload_delay(new_mag), TRUE, user))
				to_chat(user, span_warning("Your reload was interupted!"))
				return FALSE
		if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_ROTATES_CHAMBER))
			for(var/i = 1, i <= length(chamber_items), i++)
				if(chamber_items[i])
					continue
				chamber_items[i] = new_mag
				break
		else
			chamber_items += new_mag
		get_ammo()
		if(user)
			playsound(src, reload_sound, 25, 1)
		if(!flags_magazine_features || (flags_magazine_features && !CHECK_BITFIELD(flags_magazine_features, MAGAZINE_WORN)))
			new_mag.forceMove(src)
			user?.temporarilyRemoveItemFromInventory(new_mag)
		if(istype(new_mag, /obj/item/ammo_magazine))
			var/obj/item/ammo_magazine/magazine = new_mag
			magazine.on_inserted(src)
		if(!in_chamber && !CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION) && !CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE))
			cycle(user, FALSE)
		update_ammo_count()
		update_icon()
		to_chat(user, span_notice("You reload [src] with [new_mag]."))
		RegisterSignal(new_mag, COMSIG_ITEM_REMOVED_INVENTORY, /obj/item/weapon/gun.proc/drop_connected_mag)
		return TRUE


	var/list/obj/items_to_insert = list()
	if(max_chamber_items)
		if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_HANDFULS))
			var/obj/item/ammo_magazine/mag = new_mag
			if(CHECK_BITFIELD(mag.flags_magazine, MAGAZINE_HANDFUL))
				if(mag.current_rounds > 1)
					items_to_insert += mag.create_handful(null, 1)
				else
					items_to_insert += mag
				playsound(src, hand_reload_sound, 25, 1)
			else
				if((length(chamber_items) && !CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_ROTATES_CHAMBER)) || (CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_ROTATES_CHAMBER) && rounds))
					to_chat(user, span_warning("[src] must be completely empty to use the [mag]!"))
					return FALSE
				var/rounds_to_fill = mag.current_rounds < max_chamber_items ? mag.current_rounds : max_chamber_items
				for(var/i = 0, i < rounds_to_fill, i++)
					items_to_insert += mag.create_handful(null, 1)
				playsound(src, reload_sound, 25, 1)
		else
			items_to_insert += new_mag

		if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_ROTATES_CHAMBER))
			for(var/obj/object_to_insert in items_to_insert)
				for(var/i = 1, i <= length(chamber_items), i++)
					if(chamber_items[i])
						continue
					chamber_items[i] = object_to_insert
					break
		else
			chamber_items += items_to_insert
	else
		items_to_insert += new_mag
		in_chamber = new_mag
	for(var/obj/obj_to_insert in items_to_insert)
		obj_to_insert.forceMove(src)
		user?.temporarilyRemoveItemFromInventory(obj_to_insert)
	if(!CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_HANDFULS))
		playsound(src, reload_sound, 25, 1)
	if(!CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION) && !CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_TOGGLES_OPEN) && !in_chamber && max_chamber_items && !CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE))
		cycle(user, FALSE)
	get_ammo()
	update_ammo_count()
	update_icon()
	return TRUE

///Fills the gun with ammunition. This is not inlined with Initialize because it could be used outside and needs to sleep.
/obj/item/weapon/gun/proc/fill_gun()
	if(!default_ammo_type)
		return
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_HANDFULS) || CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES))
		var/obj/item/ammo_magazine/ammo_type = default_ammo_type
		if((!ispath(ammo_type, /datum/ammo) && CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_HANDFULS)) || CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES))
			var/thing_to_reload = new default_ammo_type(src)
			if(!reload(thing_to_reload, null, TRUE))
				qdel(thing_to_reload) //If the item doesnt suceed in reloading, we dont want to keep it around.
			if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_TOGGLES_OPEN))
				ENABLE_BITFIELD(reciever_flags, AMMO_RECIEVER_CLOSED)
				cycle()
			update_icon()
			return
	for(var/i in 0 to max_chamber_items)
		var/obj/object_to_insert
		if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_HANDFULS) && ispath(default_ammo_type, /datum/ammo))
			var/datum/ammo/ammo_type = default_ammo_type
			var/obj/item/ammo_magazine/handful/handful = new /obj/item/ammo_magazine/handful()
			handful.generate_handful(ammo_type, caliber, 1, initial(ammo_type.handful_amount))
			object_to_insert = handful
		else
			object_to_insert = new default_ammo_type(src)
		if(!reload(object_to_insert, null, TRUE))
			qdel(object_to_insert)
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_TOGGLES_OPEN))
		ENABLE_BITFIELD(reciever_flags, AMMO_RECIEVER_CLOSED)
		cycle()
	update_icon()

///Handles unloading. Called on attackhand. Draws the chamber_items out first, then in_chamber
/obj/item/weapon/gun/proc/unload(mob/living/user, drop = TRUE, after_fire = FALSE)
	if(HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING) && !after_fire)
		return FALSE
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_CLOSED))
		if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_TOGGLES_OPEN))
			to_chat(user, span_warning("You have to open [src] first!"))
		else
			to_chat(user, span_warning("You cannot unload [src]!"))
		return
	if(!length(chamber_items))
		if(!in_chamber)
			return FALSE
		var/obj/obj_in_chamber
		if(istype(in_chamber, /obj/projectile))
			if(!CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS))
				var/obj/projectile/projectile_in_chamber = in_chamber
				var/obj/item/ammo_magazine/handful/new_handful = new /obj/item/ammo_magazine/handful()
				new_handful.generate_handful(projectile_in_chamber.ammo.type, caliber, 1, projectile_in_chamber.ammo.handful_amount)
				obj_in_chamber = new_handful
			QDEL_NULL(in_chamber)
		else
			obj_in_chamber = in_chamber
		if(obj_in_chamber)
			if(user)
				user.put_in_hands(obj_in_chamber)
			else
				obj_in_chamber.forceMove(get_turf(src))
		in_chamber = null
		obj_in_chamber.update_icon()
		get_ammo()
		update_ammo_count()
		update_icon()
		return TRUE

	var/obj/item/mag = chamber_items[current_chamber_position]
	if(!mag)
		return
	playsound(src, unload_sound, 25, 1, 5)
	user?.visible_message(span_notice("[user] unloads [mag] from [src]."),
	span_notice("You unload [mag] from [src]."), null, 4)
	if(drop && !(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES) && CHECK_BITFIELD(get_flags_magazine_features(mag), MAGAZINE_WORN)))
		if(user)
			user.put_in_hands(mag)
		else
			mag.forceMove(get_turf(src))
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_ROTATES_CHAMBER))
		chamber_items[chamber_items.Find(mag)] = null
	else
		chamber_items -= mag
	if(istype(mag, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/magazine = mag
		magazine.on_removed(src)
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES) && CHECK_BITFIELD(get_flags_magazine_features(mag), MAGAZINE_REFUND_IN_CHAMBER) && !after_fire && !CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE))
		QDEL_NULL(in_chamber)
		adjust_current_rounds(mag, rounds_per_shot)
	UnregisterSignal(mag, COMSIG_ITEM_REMOVED_INVENTORY)
	mag.update_icon()
	get_ammo()
	update_ammo_count()
	update_icon()
	return TRUE

///Cycles the gun, handles ammunition draw
/obj/item/weapon/gun/proc/cycle(mob/living/user, after_fire = TRUE)
	if(!length(chamber_items) || (CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES) && !get_current_rounds(chamber_items[current_chamber_position])))
		update_ammo_count()
		return
	if((CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_ROTATES_CHAMBER) && !CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES)) || (CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_ROTATES_CHAMBER) && CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES) && get_current_rounds(chamber_items[current_chamber_position]) <= 0))
		var/next_chamber_position = current_chamber_position + 1
		if(next_chamber_position > max_chamber_items)
			next_chamber_position = 1
		current_chamber_position = next_chamber_position
	if((!user && CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION)) || (!rounds && after_fire))
		return
	var/new_in_chamber
	if(current_chamber_position > length(chamber_items))
		new_in_chamber = null
	else if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES))
		if(!after_fire && in_chamber && !CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS))
			playsound(src, cocked_sound, 25, 1)
			if(cocked_message)
				to_chat(user, span_notice(cocked_message))
			var/obj/projectile/projectile_in_chamber = in_chamber
			var/obj/item/ammo_magazine/handful/new_handful = new /obj/item/ammo_magazine/handful()
			new_handful.generate_handful(projectile_in_chamber.ammo.type, caliber, 1, projectile_in_chamber.ammo.handful_amount)
			user.put_in_any_hand_if_possible(new_handful)
			QDEL_NULL(in_chamber)
		if(!CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_DO_NOT_EMPTY_ROUNDS_AFTER_FIRE))
			adjust_current_rounds(chamber_items[current_chamber_position], -rounds_per_shot)
		new_in_chamber = get_ammo_object()
	else
		var/object_to_chamber = chamber_items[current_chamber_position]
		if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_ROTATES_CHAMBER))
			chamber_items[current_chamber_position] = null
		else
			chamber_items -= object_to_chamber
		new_in_chamber = object_to_chamber
		if(in_chamber && !after_fire && user)
			user.put_in_hands(in_chamber)
	in_chamber = new_in_chamber
	update_ammo_count()
	update_icon()
	if(!after_fire || CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_TOGGLES_OPEN))
		return
	make_casing()

///Generates a casing.
/obj/item/weapon/gun/proc/make_casing(obj/item/magazine, after_fire = TRUE)
	if(!type_of_casings || (current_chamber_position > length(chamber_items) && after_fire) || (!CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES) && !CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_HANDFULS)))
		return
	var/num_of_casings
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES) && istype(chamber_items[current_chamber_position], /obj/item/ammo_magazine))
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


///Gets a projectile to fire from the magazines ammo type.
/obj/item/weapon/gun/proc/get_ammo_object()
	var/datum/ammo/new_ammo = get_ammo()
	if(!new_ammo)
		return
	var/projectile_type = CHECK_BITFIELD(initial(new_ammo.flags_ammo_behavior), AMMO_HITSCAN) ? /obj/projectile/hitscan : /obj/projectile
	var/obj/projectile/projectile = new projectile_type(null, initial(new_ammo.hitscan_effect_icon))
	projectile.generate_bullet(new_ammo)
	return projectile

///Sets and returns the guns ammo type from the current magazine.
/obj/item/weapon/gun/proc/get_ammo()
	var/ammo_type
	if(in_chamber)
		if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_HANDFULS))
			ammo_type = get_magazine_default_ammo(in_chamber)
		else if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES))
			var/obj/projectile/projectile_in_chamber = in_chamber
			ammo_type = projectile_in_chamber.ammo.type
		else
			ammo_type = initial(ammo_datum_type)
		ammo_datum_type = ammo_type
		return ammo_datum_type
	if(!length(chamber_items) || !chamber_items[current_chamber_position] || current_chamber_position > length(chamber_items))
		return ammo_datum_type
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_HANDFULS) || CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES) && get_magazine_default_ammo(chamber_items[current_chamber_position]))
		ammo_type = get_magazine_default_ammo(chamber_items[current_chamber_position])
	else if(!get_magazine_default_ammo(chamber_items[current_chamber_position]))
		return ammo_datum_type
	else
		ammo_type = initial(ammo_datum_type)
	ammo_datum_type = ammo_type
	return ammo_datum_type

/obj/item/weapon/gun/proc/get_ammo_list()
	if(!ammo_datum_type)
		return list("unknown", "unknown")
	return list(initial(ammo_datum_type.hud_state), initial(ammo_datum_type.hud_state_empty))

///Updates the guns rounds and max_rounds vars based on the contents of chamber_items
/obj/item/weapon/gun/proc/update_ammo_count()
	if(!CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES))
		var/new_rounds = length(chamber_items) + (in_chamber ? rounds_per_shot : 0)
		if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_ROTATES_CHAMBER))
			new_rounds = 0
			for(var/obj/chamber_item in chamber_items)
				if(!chamber_item)
					continue
				new_rounds++
			if(in_chamber)
				new_rounds++
		rounds = new_rounds
		max_rounds = max_chamber_items + 1
		gun_user?.hud_used.update_ammo_hud(gun_user, src)
		return
	var/total_rounds
	var/total_max_rounds
	for(var/obj/chamber_item in chamber_items)
		total_rounds += get_current_rounds(chamber_item)
		total_max_rounds += get_max_rounds(chamber_item)
	total_max_rounds += rounds_per_shot
	rounds = total_rounds + (in_chamber ? rounds_per_shot : 0)
	max_rounds = total_max_rounds
	update_icon()
	gun_user?.hud_used.update_ammo_hud(gun_user, src)

///Disconnects from a worn magazine.
/obj/item/weapon/gun/proc/drop_connected_mag(datum/source, mob/user)
	SIGNAL_HANDLER
	unload(user, FALSE)

///Getter to draw current rounds. Overwrite if the magazine is not a /ammo_magazine
/obj/item/weapon/gun/proc/get_current_rounds(obj/item/mag)
	var/obj/item/ammo_magazine/magazine = mag
	return magazine?.current_rounds

///Adds or subtracts rounds from the magazine.
/obj/item/weapon/gun/proc/adjust_current_rounds(obj/item/mag, new_rounds)
	var/obj/item/ammo_magazine/magazine = mag
	magazine?.current_rounds += new_rounds

///Getter to draw max rounds.
/obj/item/weapon/gun/proc/get_max_rounds(obj/item/mag)
	var/obj/item/ammo_magazine/magazine = mag
	return magazine?.max_rounds

///Getter to draw flags_magazine features. If the mag has none, overwrite and return null.
/obj/item/weapon/gun/proc/get_flags_magazine_features(obj/item/mag)
	var/obj/item/ammo_magazine/magazine = mag
	return magazine ? magazine.flags_magazine : NONE

///Getter to draw default ammo type. If the mag has none, overwrite and return null.
/obj/item/weapon/gun/proc/get_magazine_default_ammo(obj/item/mag)
	var/obj/item/ammo_magazine/magazine = mag
	return magazine?.default_ammo

///Getter to draw reload delay. If the mag has none, overwrite and return null.
/obj/item/weapon/gun/proc/get_magazine_reload_delay(obj/item/mag)
	var/obj/item/ammo_magazine/magazine = mag
	return magazine?.reload_delay

///Getter to draw the magazine overlay on the gun. If the mag has none, overwrite and return null.
/obj/item/weapon/gun/proc/get_magazine_overlay(obj/item/mag)
	var/obj/item/ammo_magazine/magazine = mag
	return magazine?.bonus_overlay

//----------------------------------------------------------
				//							\\
				// FIRE CYCLE RELATED PROCS \\
				//							\\
				//						   	\\
//----------------------------------------------------------

/obj/item/weapon/gun/proc/able_to_fire(mob/user)
	if(!user || user.stat != CONSCIOUS || user.lying_angle || !isturf(user.loc))
		return
	if(rounds - rounds_per_shot < 0 && rounds)
		to_chat(user, span_warning("Theres not enough rounds left to fire."))
		return FALSE
	if(!CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_CLOSED) && CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_TOGGLES_OPEN))
		to_chat(user, span_warning("The chamber is open! Close it first."))
		return FALSE
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

/obj/item/weapon/gun/proc/play_fire_sound(mob/user)
	//Guns with low ammo have their firing sound
	var/firing_sndfreq = CHECK_BITFIELD(flags_gun_features, GUN_NO_PITCH_SHIFT_NEAR_EMPTY) ? FALSE : ((rounds / (max_rounds ? max_rounds : max_shells)) > 0.25) ? FALSE : 55000
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
	projectile_to_fire.projectile_speed = projectile_to_fire.ammo.shell_speed
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
	//no point blank bonus when akimbo
	if(dual_wield)
		projectile_to_fire.point_blank_range = 0


/obj/item/weapon/gun/proc/setup_bullet_accuracy(obj/projectile/projectile_to_fire, mob/user, bullets_fired = 1)
	var/gun_accuracy_mult = accuracy_mult_unwielded
	var/gun_accuracy_mod = 0
	var/gun_scatter = scatter_unwielded
	var/wielded_fire

	if(((flags_item & WIELDED) && wielded_stable()) || CHECK_BITFIELD(flags_item, IS_DEPLOYED) || (master_gun && CHECK_BITFIELD(master_gun.flags_item, WIELDED) && master_gun.wielded_stable()))
		gun_accuracy_mult = accuracy_mult
		gun_scatter = scatter
		wielded_fire = TRUE

	if(user && world.time - user.last_move_time < 5) //if you moved during the last half second, you have some penalties to accuracy and scatter
		if(wielded_fire)
			//if you're wielding your weapon, the penalty is lower
			gun_accuracy_mult = max(0.1, gun_accuracy_mult - max(0,movement_acc_penalty_mult * 0.03))
			gun_scatter += max(0, movement_acc_penalty_mult * 0.5)
		else
			//if you're not wielding your weapon, the penalty is higher
			gun_accuracy_mult = max(0.1, gun_accuracy_mult - max(0,movement_acc_penalty_mult * 0.06))
			gun_scatter += max(0, movement_acc_penalty_mult)

	if(gun_firemode == GUN_FIREMODE_BURSTFIRE || gun_firemode == GUN_FIREMODE_AUTOBURST && burst_amount > 1)
		gun_accuracy_mult = max(0.1, gun_accuracy_mult * burst_accuracy_mult)

	if(dual_wield) //akimbo firing gives terrible scatter
		gun_scatter += 2 * rand(upper_akimbo_accuracy, lower_akimbo_accuracy)

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
					gun_scatter += 5

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

		if(ishuman(user))
			var/mob/living/carbon/human/shooter_human = user
			gun_accuracy_mod -= round(min(20, (shooter_human.shock_stage * 0.2))) //Accuracy declines with pain, being reduced by 0.2% per point of pain.
			if(shooter_human.marksman_aura)
				gun_accuracy_mod += 10 + max(5, shooter_human.marksman_aura * 5) //Accuracy bonus from active focus order

	projectile_to_fire.accuracy = round((projectile_to_fire.accuracy * gun_accuracy_mult) + gun_accuracy_mod) // Apply gun accuracy multiplier to projectile accuracy
	projectile_to_fire.scatter += gun_scatter					//Add gun scatter value to projectile's scatter value

/obj/item/weapon/gun/proc/get_scatter(starting_scatter, mob/user)
	. = starting_scatter //projectile_to_fire.scatter

	if(gun_firemode ==  GUN_FIREMODE_BURSTFIRE || gun_firemode == GUN_FIREMODE_AUTOBURST) //Much higher chance on a burst or similar.
		if(flags_item & WIELDED && wielded_stable() || CHECK_BITFIELD(flags_item, IS_DEPLOYED)) //if deployed, its pretty stable.
			. += burst_amount * burst_scatter_mult
		else
			. += burst_amount * burst_scatter_mult * 2

	if(CHECK_BITFIELD(flags_item, IS_DEPLOYED)) //if our gun is deployed, change the scatter by this number, usually a negative
		. += deployed_scatter_change

	if(!user?.skills.getRating("firearms")) //no training in any firearms
		. += 10
	else
		var/scatter_tweak = user.skills.getRating(gun_skill_category)
		if(scatter_tweak > 1)
			. -= scatter_tweak * 2

	if(. <= 0)
		return 0


/obj/item/weapon/gun/proc/simulate_recoil(recoil_bonus = 0, firing_angle)
	if(CHECK_BITFIELD(flags_item, IS_DEPLOYED) || !gun_user)
		return TRUE
	var/total_recoil = recoil_bonus
	if(flags_item & WIELDED && wielded_stable() || master_gun)
		total_recoil += recoil
	else
		total_recoil += recoil_unwielded
		if(HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING))
			total_recoil += 1
	if(!gun_user.skills.getRating("firearms")) //no training in any firearms
		total_recoil += 2
	else
		var/recoil_tweak = gun_user.skills.getRating(gun_skill_category)
		if(recoil_tweak)
			total_recoil -= recoil_tweak * 2


	var/actual_angle = firing_angle + rand(-recoil_deviation, recoil_deviation) + 180
	if(actual_angle > 360)
		actual_angle -= 360
	if(total_recoil > 0)
		recoil_camera(gun_user, total_recoil + 1, (total_recoil * recoil_backtime_multiplier)+1, total_recoil, actual_angle)
		return TRUE

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
