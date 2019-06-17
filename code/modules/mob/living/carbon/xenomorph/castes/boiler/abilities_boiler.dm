// ***************************************
// *********** Long range sight
// ***************************************

/datum/action/xeno_action/toggle_long_range
	name = "Toggle Long Range Sight"
	action_icon_state = "toggle_long_range"
	mechanics_text = "Activates your weapon sight in the direction you are facing. Must remain stationary to use."
	plasma_cost = 20
	keybind_signal = COMSIG_XENOABILITY_LONG_RANGE_SIGHT

/datum/action/xeno_action/toggle_long_range/action_activate()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	if(X.is_zoomed)
		X.zoom_out()
		X.visible_message("<span class='notice'>[X] stops looking off into the distance.</span>", \
		"<span class='notice'>You stop looking off into the distance.</span>", null, 5)
	else
		X.visible_message("<span class='notice'>[X] starts looking off into the distance.</span>", \
			"<span class='notice'>You start focusing your sight to look off into the distance.</span>", null, 5)
		if(!do_after(X, 20, FALSE, null, BUSY_ICON_GENERIC) || X.is_zoomed)
			return
		X.zoom_in()
		..()

// ***************************************
// *********** Gas type toggle
// ***************************************

/datum/action/xeno_action/toggle_bomb
	name = "Toggle Bombard Type"
	action_icon_state = "toggle_bomb0"
	mechanics_text = "Switches Boiler Bombard type between Corrosive Acid and Neurotoxin."
	use_state_flags = XACT_USE_BUSY
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_BOMB

/datum/action/xeno_action/toggle_bomb/action_activate()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	to_chat(X, "<span class='notice'>You will now fire [X.ammo.type == /datum/ammo/xeno/boiler_gas/corrosive ? "corrosive acid. This is lethal!" : "neurotoxic gas. This is nonlethal."]</span>")
	if(X.ammo.type == /datum/ammo/xeno/boiler_gas)
		X.ammo = GLOB.ammo_list[/datum/ammo/xeno/boiler_gas/corrosive]
	else
		X.ammo = GLOB.ammo_list[/datum/ammo/xeno/boiler_gas]
	update_button_icon()

/datum/action/xeno_action/toggle_bomb/update_button_icon()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	button.overlays.Cut()
	if(X.ammo?.type == /datum/ammo/xeno/boiler_gas/corrosive)
		button.overlays += image('icons/mob/actions.dmi', button, "toggle_bomb1")
	else
		button.overlays += image('icons/mob/actions.dmi', button, "toggle_bomb0")
	return ..()

// ***************************************
// *********** Gas cloud bombs
// ***************************************
/datum/action/xeno_action/activable/bombard
	name = "Bombard"
	action_icon_state = "bombard"
	mechanics_text = "Launch a glob of neurotoxin or acid. Must remain stationary for a few seconds to use."
	plasma_cost = 200
	ability_name = "bombard"
	keybind_signal = COMSIG_XENOABILITY_BOMBARD

/datum/action/xeno_action/activable/bombard/get_cooldown()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	return X.xeno_caste.bomb_delay

/datum/action/xeno_action/activable/bombard/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>You feel your toxin glands swell. You are able to bombard an area again.</span>")
	var/mob/living/carbon/xenomorph/boiler/X = owner
	if(X.selected_ability == src)
		X.set_bombard_pointer()
	return ..()

/datum/action/xeno_action/activable/bombard/on_activation()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	X.visible_message("<span class='notice'>\The [X] begins digging their claws into the ground.</span>", \
	"<span class='notice'>You begin digging yourself into place.</span>", null, 5)
	if(!do_after(X, 30, FALSE, null, BUSY_ICON_HOSTILE))
		on_deactivation()
		X.selected_ability = null
		X.update_action_button_icons()
		X.reset_bombard_pointer()
		return FALSE

	X.visible_message("<span class='notice'>\The [X] digs itself into the ground!</span>", \
		"<span class='notice'>You dig yourself into place! If you move, you must wait again to fire.</span>", null, 5)
	X.set_bombard_pointer()
	RegisterSignal(X, COMSIG_MOB_ATTACK_RANGED, /datum/action/xeno_action/activable/bombard/proc.on_ranged_attack)


/datum/action/xeno_action/activable/bombard/on_deactivation()
	var/mob/living/carbon/xenomorph/boiler/X = owner
	if(X.selected_ability == src)
		X.reset_bombard_pointer()
		to_chat(X, "<span class='notice'>You relax your stance.</span>")
	UnregisterSignal(X, COMSIG_MOB_ATTACK_RANGED)


/datum/action/xeno_action/activable/bombard/proc/on_ranged_attack(mob/living/carbon/xenomorph/X, atom/A, params)
    if(can_use_ability(A))
        use_ability(A)


/mob/living/carbon/xenomorph/boiler/Moved(atom/OldLoc,Dir)
	. = ..()
	if(selected_ability?.type == /datum/action/xeno_action/activable/bombard)
		var/datum/action/xeno_action/activable/bomb = actions_by_path[/datum/action/xeno_action/activable/bombard]
		bomb.on_deactivation()
		selected_ability.button.icon_state = "template"
		selected_ability = null
		update_action_button_icons()

/mob/living/carbon/xenomorph/boiler/proc/set_bombard_pointer()
	if(client)
		client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")

/mob/living/carbon/xenomorph/boiler/proc/reset_bombard_pointer()
	if(client)
		client.mouse_pointer_icon = initial(client.mouse_pointer_icon)

/datum/action/xeno_action/activable/bombard/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/turf/T = get_turf(A)
	var/turf/S = get_turf(owner)
	if(!isturf(T) || T.z != S.z)
		if(!silent)
			to_chat(owner, "<span class='warning'>This is not a valid target.</span>")
		return FALSE
	if(get_dist(T, S) <= 5) //Magic number
		if(!silent)
			to_chat(owner, "<span class='warning'>You are too close! You must be at least 7 meters from the target due to the trajectory arc.</span>")
		return FALSE

/datum/action/xeno_action/activable/bombard/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/boiler/X = owner
	var/turf/T = get_turf(A)
	var/offset_x = rand(-1, 1)
	var/offset_y = rand(-1, 1)

	if(prob(30))
		offset_x = 0
	if(prob(30))
		offset_y = 0

	var/turf/target = locate(T.x + offset_x, T.y + offset_y, T.z)

	if(!istype(target))
		return

	to_chat(X, "<span class='xenonotice'>You begin building up acid.</span>")

	succeed_activate()

	if(!do_after(X, 50, FALSE, target, BUSY_ICON_DANGER))
		to_chat(X, "<span class='warning'>You decide not to launch any acid.</span>")
		return fail_activate()

	if(!can_use_ability(target, FALSE, XACT_IGNORE_PLASMA))
		return fail_activate()

	X.visible_message("<span class='xenowarning'>\The [X] launches a huge glob of acid hurling into the distance!</span>", \
	"<span class='xenowarning'>You launch a huge glob of acid hurling into the distance!</span>", null, 5)

	var/obj/item/projectile/P = new /obj/item/projectile(X.loc)
	P.generate_bullet(X.ammo)
	P.fire_at(target, X, null, X.ammo.max_range, X.ammo.shell_speed)
	playsound(X, 'sound/effects/blobattack.ogg', 25, 1)
	if(X.ammo.type == /datum/ammo/xeno/boiler_gas/corrosive)
		round_statistics.boiler_acid_smokes++
	else
		round_statistics.boiler_neuro_smokes++

	add_cooldown()
	X.reset_bombard_pointer()

// ***************************************
// *********** Acid spray
// ***************************************
/datum/action/xeno_action/activable/spray_acid/line/boiler
	cooldown_timer = 9 SECONDS
