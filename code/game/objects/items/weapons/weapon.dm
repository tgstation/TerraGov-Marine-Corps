//items designed as weapon
/obj/item/weapon
	name = "weapon"
	icon = 'icons/obj/items/weapons.dmi'
	hitsound = "swing_hit"
	var/caliber = "missing from codex" //codex
	var/load_method = null //codex, defines are below.
	var/max_shells = 0 //codex, bullets, shotgun shells
	var/max_shots = 0 //codex, energy weapons
	var/scope_zoom = FALSE//codex
	var/self_recharge = FALSE //codex

	///Bayonet Charge base obj
	var/datum/action/bayonet_charge/charge
//its here because if I dont place it in the same script as the base weapon define, it breaks.
/datum/action/bayonet_charge
	name = "Toggle Bayonet Charge"
	action_icon_state = "charge_human"

	//these variables modify the stats of a bayonet charge
	///the amount of tiles you need to walk to start charging
	var/minactivationrundist = 5
	///thhe amount of tiles you need to walk to charge fully
	var/fullspeedrundist = 9
	///speed increase per step once charging
	var/speedperstep = 0.2
	///MAXIMUMSPEED INCREASE
	var/maxspeed = 2.4
	///the amount by which the stam loss is multiplied by per step taken when charging
	var/stamlossmult = 1
	///the multiplier for damage inflicted when you bayonet charge someone
	var/damagemult = 1.5
	///This is a speed mult for when you finish charging
	var/postspeedmult = 1.5
	///the amount of time the post charge speed boost lasts (in deciseconds)
	var/postspeedtime = 50
	///the amount of time the stun lasts in 1/10ths of a second
	var/slownesstime = 5
	///the amount of time cooldown lasts in deciseconds
	var/cooldowntime = 150

	//Below are static variables that should not be changed, ever.
	var/stepstaken = 0
	var/chargedir = null

	var/amcharging = FALSE
	var/chargewhenmove = FALSE
	var/incooldown = FALSE
	var/obj/item/weapon/weaponinhand

	///represents the time when the stepstaken var resets
	var/movementcontinuationlimit
	///the guy that is charging
	var/mob/living/carbon/human/charger

	///The list of melee/not gun weapons available to be charged with
	var/list/enabled_melee_weapons = list(
		/obj/item/weapon/powerfist,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/claymore/mercsword/officersword,
		/obj/item/weapon/twohanded/spear/tactical,
	)

/obj/item/weapon/Initialize()
	. = ..()
	charge = new

/obj/item/weapon/dropped(mob/user)
	. = ..()
	charge.remove_action(user)

datum/action/bayonet_charge/give_action(mob/M, obj/item/weapon/W)
	. = ..()
	weaponinhand = W
	charger = owner

datum/action/bayonet_charge/remove_action(mob/M)

	charger = owner
	charge_off()
	. = ..()

datum/action/bayonet_charge/action_activate()
	if(amcharging)
		return
	if(chargewhenmove == TRUE)
		charge_off()
		return
	charger = owner
	charge_on()
datum/action/bayonet_charge/proc/charge_on()
	if(incooldown)
		to_chat(charger, "<span class='warning'>Charge is still on cooldown!</span>")
		return
	chargewhenmove = TRUE
	src.add_selected_frame()
	charger = owner //just in case you didnt activate the action, charger would be null if you do.
	to_chat(charger, "<span class='warning'>You stand ready to charge</span>")
	RegisterSignal(charger, COMSIG_MOVABLE_MOVED, .proc/update_charging)
	RegisterSignal(charger, COMSIG_ATOM_DIR_CHANGE, .proc/on_dir_change)

datum/action/bayonet_charge/proc/charge_off()
	chargewhenmove = FALSE
	charger = owner
	to_chat(charger, "<span class='warning'>You no longer stand ready to charge</span>")
	if(charger) //locks up if you dont check if charger is existant
		UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(owner, COMSIG_ATOM_DIR_CHANGE)
		UnregisterSignal(owner, list(COMSIG_MOVABLE_PREBUMP_TURF, COMSIG_MOVABLE_PREBUMP_MOVABLE, COMSIG_MOVABLE_PREBUMP_EXIT_MOVABLE))
	src.remove_selected_frame()
	stop_charge()


datum/action/bayonet_charge/proc/on_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(old_dir == new_dir)
		return
	stop_charge()
//called when the marine moves
datum/action/bayonet_charge/proc/update_charging(datum/source, atom/oldloc, direction, Forced)
	SIGNAL_HANDLER_DOES_SLEEP
	if(movementcontinuationlimit && world.time > movementcontinuationlimit) //if you have stopped moving, it resetss the steps taken coutner
		stop_charge()
		movementcontinuationlimit = null
		return
	stepstaken++
	movementcontinuationlimit = world.time + 10

	handle_charge()

datum/action/bayonet_charge/proc/handle_charge()

	//actual charging is under here
	var/chargespeed = clamp(stepstaken * speedperstep, 0, maxspeed)
	if(charger.incapacitated())
		return

	if(charger.pulling)
		return
	if(charger.getStaminaLoss() >= 0)
		charge_off()
		return
	if(stepstaken < minactivationrundist)
		return

	//stuff in this if only happens once the charger starts charging, and not anytime else.
	if(!amcharging)
		charger.emote("warcry")
		RegisterSignal(charger, list(COMSIG_MOVABLE_PREBUMP_TURF, COMSIG_MOVABLE_PREBUMP_MOVABLE, COMSIG_MOVABLE_PREBUMP_EXIT_MOVABLE), .proc/on_contact_with_enemy, TRUE)
	amcharging = TRUE
	charger.add_movespeed_modifier(MOVESPEED_ID_MARINE_CHARGE, TRUE, 100, NONE, TRUE, -chargespeed)
	charger.toggle_move_intent(MOVE_INTENT_WALK) //if this aint here, the sprint compounds with the speed increase of the modifier, making you faster than a fucking charger
	charger.adjustStaminaLoss(stamlossmult * chargespeed)



datum/action/bayonet_charge/proc/stop_charge()
	amcharging = FALSE
	if(charger)
		charger.remove_movespeed_modifier(MOVESPEED_ID_MARINE_CHARGE)
	stepstaken = 0

datum/action/bayonet_charge/proc/on_contact_with_enemy(datum/source, atom/crushed)
	if(istype(crushed, /mob/living) && amcharging == TRUE)
		if(isliving(crushed))
			var/mob/living/crushedliving = crushed
			if(istype(weaponinhand, /obj/item/weapon/gun))
				//handles the damage for guns'
				var/obj/item/weapon/gun/gun_weapon = weaponinhand
				var/originalbayodamage = weaponinhand.force * damagemult
				var/preserved_name = crushed.name
				crushedliving.apply_damage(originalbayodamage, BRUTE, BODY_ZONE_CHEST, crushedliving.get_soft_armor("melee", BODY_ZONE_CHEST), updating_health = TRUE)

				crushedliving.do_item_attack_animation(crushedliving, used_item = gun_weapon )
				playsound(crushed.loc, 'sound/weapons/slice.ogg',35, 1)
				charger.visible_message("<span class='danger'>[charger] stabs [preserved_name]!</span>")
				crushedliving.Stun(slownesstime)
				log_combat(charger, crushedliving, "human charged")
				charger.setStaminaLoss(-charger.max_stamina_buffer)

	incooldown = TRUE
	addtimer(CALLBACK(src, .proc/cooldownend), cooldowntime)
	charge_off()

datum/action/bayonet_charge/proc/cooldownend()
	incooldown = FALSE
