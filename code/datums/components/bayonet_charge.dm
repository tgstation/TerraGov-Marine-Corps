
/datum/component/bayonetcharge
	//these variables modify the stats of a bayonet charge
	///the amount of tiles you need to walk to start charging
	var/min_charge_activation_dist = 5
	///speed increase per step once charging
	var/speed_addition_per_step = 0.2
	///MAXIMUMSPEED INCREASE
	var/max_speed = 2.4
	///the amount by which the stam loss is multiplied by per step taken when charging
	var/stam_loss_mult_per_step = 1
	///the multiplier for damage inflicted when you bayonet charge someone
	var/damage_multiplier = 1.5
	///the amount of time the stun lasts in 1/10ths of a second
	var/stun_length = 5
	///the amount of time cooldown lasts in deciseconds
	var/cooldown_duration = 150

	//Below are variables that are used internally. Do not externally change
	///represents the amount of steps the charger has taken since he has last stopped or activated the action
	var/steps_taken = 0

	///represents if the charger is charging
	var/is_player_charging = FALSE
	var/action_toggle_state = FALSE
	var/obj/item/weapon/gun/weaponinhand

	///represents the time (in world.time) when the steps_taken var resets
	var/next_move_restriction_timer
	///the guy that is charging
	var/mob/living/carbon/human/charger
	///the child action of this component
	var/datum/action/bayonetcharge/child

/datum/component/bayonetcharge/Initialize(...)
	var/mob/living/carbon/human/human_parent = parent
	human_parent.bayonet_charge_component = src
	return ..()

///this updates the critical vars of this component. Called on initalize and when the action is applied to a player
/datum/component/bayonetcharge/proc/updatevalues()
	charger = src.parent
	child = new
	child.give_action(src.charger)
	child.parent = src



/datum/action/bayonetcharge
	name = "Toggle Bayonet Charge"
	action_icon_state = "charge_human"

	var/datum/component/bayonetcharge/parent

/datum/action/bayonetcharge/remove_action(mob/M)


	parent.charge_off()
	. = ..()

/datum/action/bayonetcharge/action_activate()
	if(parent.is_player_charging)
		return
	if(parent.action_toggle_state == TRUE)
		parent.charge_off()
		return

	parent.charge_on()
///Called when the charge action is initiated. Adds the essencial Signals and does some misc work on the action frame and vars
/datum/component/bayonetcharge/proc/charge_on()
	if(TIMER_COOLDOWN_CHECK(charger, COOLDOWN_HUMAN_CHARGE))
		to_chat(charger, "<span class='warning'>Charge is still on cooldown!</span>")
		return
	action_toggle_state = TRUE
	child.add_selected_frame()
	 //just in case you didnt activate the action, charger would be null if you do.
	to_chat(charger, "<span class='warning'>You stand ready to charge</span>")
	RegisterSignal(charger, COMSIG_MOVABLE_MOVED, .proc/update_charging)
	RegisterSignal(charger, COMSIG_ATOM_DIR_CHANGE, .proc/on_dir_change)

///called when the charge action is deactivated.  Unregisters signals and manipulates the action frame. Also calls stop_charge
/datum/component/bayonetcharge/proc/charge_off()
	action_toggle_state = FALSE

	to_chat(charger, "<span class='warning'>You no longer stand ready to charge</span>")
	if(charger) //locks up if you dont check if charger is existant
		UnregisterSignal(charger, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(charger, COMSIG_ATOM_DIR_CHANGE)
		UnregisterSignal(charger, list(COMSIG_MOVABLE_PREBUMP_TURF, COMSIG_MOVABLE_PREBUMP_MOVABLE, COMSIG_MOVABLE_PREBUMP_EXIT_MOVABLE))
	child.remove_selected_frame()
	stop_charge()

///called the direction of the mob changes.
/datum/component/bayonetcharge/proc/on_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(old_dir == new_dir)
		return
	stop_charge()

//called when the marine moves
/datum/component/bayonetcharge/proc/update_charging(datum/source, atom/oldloc, direction, Forced)
	SIGNAL_HANDLER_DOES_SLEEP
	if(next_move_restriction_timer && world.time > next_move_restriction_timer) //if you have stopped moving, it resetss the steps taken counter
		if(is_player_charging)
			is_player_charging = FALSE
			TIMER_COOLDOWN_START(charger, COOLDOWN_HUMAN_CHARGE, cooldown_duration)
		stop_charge()
		next_move_restriction_timer = null
		return
	steps_taken++
	next_move_restriction_timer = world.time + 10

	handle_charge()

///this handles the charging checks and the charge itself. Checks for the needed states and if those states are satified, adds the movespeed mod and stam loss. Called on move.
/datum/component/bayonetcharge/proc/handle_charge()

	//actual charging is under here
	var/chargespeed = clamp(steps_taken * speed_addition_per_step, 0, max_speed)
	if(charger.incapacitated())
		return

	if(charger.pulling)
		return
	if(charger.getStaminaLoss() >= 0)
		charge_off()
		return
	if(steps_taken < min_charge_activation_dist)
		return

	//stuff in this if only happens once the charger starts charging, and not anytime else.
	if(!is_player_charging)
		charger.emote("warcry")
		RegisterSignal(charger, list(COMSIG_MOVABLE_PREBUMP_TURF, COMSIG_MOVABLE_PREBUMP_MOVABLE, COMSIG_MOVABLE_PREBUMP_EXIT_MOVABLE), .proc/on_contact_with_enemy, TRUE)
	is_player_charging = TRUE
	charger.add_movespeed_modifier(MOVESPEED_ID_MARINE_CHARGE, TRUE, 100, NONE, TRUE, -chargespeed)
	charger.toggle_move_intent(MOVE_INTENT_WALK) //if this aint here, the sprint compounds with the speed increase of the modifier, making you faster than a fucking charger
	charger.adjustStaminaLoss(stam_loss_mult_per_step * chargespeed)


///called when the code wants the player to stop charging. IE, when you hit a solid thing or run out of stamina
/datum/component/bayonetcharge/proc/stop_charge()
	is_player_charging = FALSE
	if(charger)
		charger.remove_movespeed_modifier(MOVESPEED_ID_MARINE_CHARGE)
	steps_taken = 0

///called when the player hits anything dense. Handles the damage application and always calls  charge_off
/datum/component/bayonetcharge/proc/on_contact_with_enemy(datum/source, atom/crushed)
	SIGNAL_HANDLER
	if(isliving(crushed) && is_player_charging == TRUE)
		var/mob/living/crushedliving = crushed
		if(istype(weaponinhand, /obj/item/weapon/gun))
			//handles the damage for guns'
			var/obj/item/weapon/gun/gun_weapon = weaponinhand
			var/originalbayodamage = weaponinhand.force * damage_multiplier
			var/preserved_name = crushed.name
			crushedliving.apply_damage(originalbayodamage, BRUTE, BODY_ZONE_CHEST, crushedliving.get_soft_armor("melee", BODY_ZONE_CHEST), updating_health = TRUE)

			crushedliving.do_item_attack_animation(crushedliving, used_item = gun_weapon )
			playsound(crushed.loc, 'sound/weapons/slice.ogg',35, 1)
			charger.visible_message("<span class='danger'>[charger] stabs [preserved_name]!</span>")
			crushedliving.Stun(stun_length)
			log_combat(charger, crushedliving, "human charged")

			charger.setStaminaLoss(-charger.max_stamina_buffer)

	TIMER_COOLDOWN_START(charger, COOLDOWN_HUMAN_CHARGE, cooldown_duration)
	charge_off()

