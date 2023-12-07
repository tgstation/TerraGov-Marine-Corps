#define BLINK_DRIVE_RANGE 7
#define BLINK_DRIVE_MAX_CHARGES 3
#define BLINK_DRIVE_CHARGE_TIME 2 SECONDS

/obj/item/blink_drive
	name = "blink drive"
	desc = "A portable Bluespace Displacement Drive, otherwise known as a blink drive. Can teleport the user across short distances with a degree of unreliability, with potentially fatal results. Teleporting past 5 tiles, to tiles out of sight or rapid use of the drive add variance to the teleportation destination. <b>Alt right click or middleclick to teleport to a destination when the blink drive is equipped.</b>"
	icon = 'icons/obj/items/jetpack.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/backpacks_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/backpacks_right.dmi',
	)
	icon_state = "bluespace_pack"
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK
	obj_flags = CAN_BE_HIT
	light_range = 0.1
	light_power = 0.1
	light_color = LIGHT_COLOR_BLUE
	///Number of teleport charges you currently have
	var/charges = 3
	///True if you can use shift click/middle click to use it
	var/selected = FALSE
	///The timer for recharging the drive
	var/charge_timer
	///The mob wearing the blink drive. Needed for item updates.
	var/mob/equipped_user
	COOLDOWN_DECLARE(blink_stability_cooldown)

/obj/item/blink_drive/update_icon()
	. = ..()
	equipped_user?.update_inv_back()
	if(charges)
		turn_light(equipped_user, TRUE)
	else
		turn_light(equipped_user, FALSE)

/obj/item/blink_drive/update_icon_state()
	. = ..()
	if(charges)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_e"

/obj/item/blink_drive/turn_light(mob/user, toggle_on)
	. = ..()
	if(. != CHECKS_PASSED)
		return
	set_light_on(toggle_on)

/obj/item/blink_drive/equipped(mob/user, slot)
	. = ..()
	equipped_user = user
	if(slot == SLOT_BACK)
		RegisterSignal(user, COMSIG_MOB_CLICK_ALT_RIGHT, PROC_REF(can_use))
		var/datum/action/item_action/toggle/action = new(src)
		action.give_action(user)

/obj/item/blink_drive/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, list(COMSIG_MOB_CLICK_ALT_RIGHT, COMSIG_MOB_MIDDLE_CLICK))
	UnregisterSignal(user, COMSIG_ITEM_EXCLUSIVE_TOGGLE)
	selected = FALSE
	equipped_user = null
	LAZYCLEARLIST(actions)

/obj/item/blink_drive/ui_action_click(mob/user, datum/action/item_action/action)
	if(selected)
		UnregisterSignal(user, COMSIG_MOB_MIDDLE_CLICK)
		action.set_toggle(FALSE)
		UnregisterSignal(user, COMSIG_ITEM_EXCLUSIVE_TOGGLE)
	else
		RegisterSignal(user, COMSIG_MOB_MIDDLE_CLICK, PROC_REF(can_use))
		action.set_toggle(TRUE)
		SEND_SIGNAL(user, COMSIG_ITEM_EXCLUSIVE_TOGGLE, user)
		RegisterSignal(user, COMSIG_ITEM_EXCLUSIVE_TOGGLE, PROC_REF(unselect))
	selected = !selected

/obj/item/blink_drive/apply_custom(mutable_appearance/standing, inhands, icon_used, state_used)
	. = ..()
	var/mutable_appearance/emissive_overlay = emissive_appearance(icon_used, "[state_used]_emissive")
	standing.overlays.Add(emissive_overlay)

///Signal handler for making it impossible to use middleclick to use the blink drive
/obj/item/blink_drive/proc/unselect(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!selected)
		return
	selected = FALSE
	UnregisterSignal(user, COMSIG_MOB_MIDDLE_CLICK)
	UnregisterSignal(user, COMSIG_ITEM_EXCLUSIVE_TOGGLE)

	for(var/action in user.actions)
		if(!istype(action, /datum/action/item_action))
			continue
		var/datum/action/item_action/iaction = action
		if(iaction?.holder_item == src)
			iaction.set_toggle(FALSE)

///Check if we can use the blink drive and give feedback to the user
/obj/item/blink_drive/proc/can_use(datum/source, atom/A)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/human_user = usr
	if(human_user.incapacitated() || human_user.lying_angle)
		return
	if(is_mainship_level(human_user.z))
		human_user.balloon_alert(human_user, "can't use here")
		return
	if(charges <= 0)
		human_user.balloon_alert(human_user, "no charge")
		playsound(src, 'sound/items/blink_empty.ogg', 25, 1)
		return
	INVOKE_ASYNC(src, PROC_REF(teleport), A, human_user)

///Handles the actual teleportation
/obj/item/blink_drive/proc/teleport(atom/A, mob/user)
	var/turf/target_turf = get_turf(A)

	if(target_turf == user.loc)
		return

	var/target_distance = get_dist(user, target_turf)

	if(target_distance > BLINK_DRIVE_RANGE)
		user.balloon_alert(user, "too far")
		return

	user.face_atom(target_turf)

	var/instability = 0 //certain factors can make the teleport unreliable
	if(target_distance > BLINK_DRIVE_RANGE - 2)
		instability ++
	if(!COOLDOWN_CHECK(src, blink_stability_cooldown))
		instability ++
	if(!line_of_sight(user, target_turf, 9))
		instability ++

	target_turf = pick(RANGE_TURFS(instability, target_turf))

	var/atom/movable/pulled_target = user.pulling
	if(pulled_target)
		if(!do_after(user, 0.5 SECONDS, IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE, user, BUSY_ICON_HOSTILE))
			return
		if(pulled_target != user.pulling)
			return
		user.balloon_alert(user, "pulled someone through")

	teleport_debuff_aoe(user)
	user.forceMove(target_turf)
	if(pulled_target)
		pulled_target.forceMove(target_turf)
	teleport_debuff_aoe(user)

	if(!target_turf.can_teleport_here())
		user.emote("gored")
		user.gib() //telegibbed
		if(pulled_target && ismob(pulled_target))
			var/mob/mob_target = pulled_target
			mob_target.emote("gored")
			mob_target.gib()
		return

	COOLDOWN_START(src, blink_stability_cooldown, 1 SECONDS)
	charges --
	deltimer(charge_timer)
	charge_timer = addtimer(CALLBACK(src, PROC_REF(recharge)), BLINK_DRIVE_CHARGE_TIME * 2, TIMER_STOPPABLE)
	update_icon()

///Recharges the drive, and sets another timer if not maxed out
/obj/item/blink_drive/proc/recharge()
	charges ++
	playsound(src, 'sound/items/blink_recharge.ogg', 25, 1)
	if(charges < BLINK_DRIVE_MAX_CHARGES)
		charge_timer = addtimer(CALLBACK(src, PROC_REF(recharge)), BLINK_DRIVE_CHARGE_TIME, TIMER_STOPPABLE)
	else
		charge_timer = null
	update_icon()

///The effects applied on teleporting from or to a location
/obj/item/blink_drive/proc/teleport_debuff_aoe(atom/movable/teleporter)
	playsound(teleporter, 'sound/effects/EMPulse.ogg', 25, 1)

	new /obj/effect/temp_visual/blink_drive(get_turf(teleporter))

	for(var/mob/living/living_target in range(1, teleporter))
		living_target.adjust_stagger(1 SECONDS)
		living_target.add_slowdown(1)
		to_chat(living_target, span_warning("You feel nauseous as reality warps around you!"))

//codex stuff
/obj/item/blink_drive/get_mechanics_info()
	. = ..()
	var/list/traits = list()

	traits += "The 'blink drive', properly known as a Bluespace Displacement Drive, is a cutting edge SOM device designed for use by their elite infantry.<br>\
		It allows the user to travel very short distances through bluespace, which had previously been considering impossible to do without near certain risk of death \
		due to the inherent instability associated with such bluespace drives of this size. <br> <br>\
		While the blink drive appears to be the most accurate bluespace drive of this size yet seen, there are still dramatic risks associated with its use. <br> \
		Multiple reported instances of user displacing themselves into solid walls or other obstacles resulting in their instant death testifies to the enduring risks of such technology.<br>\
		The SOM however, appear to have no shortage of volunteers ready to accept such risks in the name of their cause. <br>"

	traits += "<U>Range:</U><br>The blink drive can teleport the user up to [BLINK_DRIVE_RANGE] tiles away, by middle clicking with the drive active. Line of Sight is not required to teleport.<br>"

	traits += "<U>Instability:</U><br>The blink drive is inherently unstable, and pushing it to its limits results in instability.<br> \
	Instability results in the user potentially teleporting to a tile near, but not exactly where they intended. <br>\
	There are three causes of instability, each level of instability means you can end up one tile away from where you click, up to a maximum of 3 tiles away.<br> \
	1. Distance: Teleporting more than [BLINK_DRIVE_RANGE - 2] tiles away <br> \
	2. Visibility: Teleporting to a tile you cannot directly see <br> \
	3. Rapid use: Using the drive less than one second after its last use <br>"

	traits += "<U>Risks:</U><br>Teleporting into a solid turf such as a wall will <U>instantly gib the user</U>.<br>\
	Great caution is advised when using the drive near solid turfs, especially when factoring in instability.<br>"

	traits += "<U>Charging:</U><br>The blink drive can store up to three charges, and recharges one every [BLINK_DRIVE_CHARGE_TIME * 0.1] seconds. It cannot recharge while in use.<br>"

	traits += "<U>AOE effect:</U><br>When the drive is used, any mob (including the user) in a small area of effect suffers from a very brief period of stagger and slowdown.<br>\
	This applies both to the users initial location as well as their exit location.<br>"

	traits += "<U>Shared use:</U><br>If the user has grabbed another mob when activating the drive, the grabbed mob will be teleported with them.<br>"

	. += jointext(traits, "<br>")
