/datum/xeno_caste/xenoborg
	caste_name = "Xenoborg"
	display_name = "Xenoborg"
	upgrade_name = ""
	caste_desc = "Oh dear god!"
	caste_type_path = /mob/living/carbon/Xenomorph/Xenoborg

	tier = 0
	upgrade = 0

	// *** Melee Attacks *** //
	melee_damage_lower = 24
	melee_damage_upper = 24

	// *** Tackle *** //
	tackle_damage = 50 //How much HALLOSS damage a xeno deals when tackling

	// *** Speed *** //
	speed = -2.1

	// *** Plasma *** //
	plasma_max = 1500
	plasma_gain = 0

	// *** Health *** //
	max_health = 300

	// *** Flags *** //
	caste_flags = CASTE_IS_INTELLIGENT|CASTE_IS_ROBOTIC|CASTE_FIRE_IMMUNE|CASTE_DECAY_PROOF

	// *** Defense *** //
	armor_deflection = 90 //Chance of deflecting projectiles.

	// *** Ranged Attack *** //
	charge_type = 1 //Pounce
	pounce_delay = 4 SECONDS

/mob/living/carbon/Xenomorph/Xenoborg
	caste_base_type = /mob/living/carbon/Xenomorph/Xenoborg
	name = "Xenoborg"
	desc = "What.. what is this monstrosity? A cyborg in the shape of a xenomorph?! What hath our science wrought?"
	icon_state = "Xenoborg Walking"
	health = 300
	maxHealth = 300
	plasma_stored = 1500
	speed = -2.1
	universal_speak = 1
	universal_understand = 1
	speak_emote = list("buzzes", "beeps")
	xeno_explosion_resistance = 3 //no stuns from explosions, ignore damages except devastation range.
	var/gun_on = 0
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid,
		/datum/action/xeno_action/activable/pounce,
//		/datum/action/xeno_action/activable/fire_cannon,
		/datum/action/xeno_action/activable/salvage_plasma/improved
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)

	New()
		..()
		add_language("English")
		add_language("Xenomorph") //xenocommon
		add_language("Hivemind") //hivemind


/mob/living/carbon/Xenomorph/Xenoborg/proc/fire_cannon(atom/T)
	if(!T)
		return

	if(!check_state())
		return

	if(!gun_on)
		to_chat(src, "<span class='warning'>Your autocannon is currently retracted.</span>")
		return

	if(usedPounce)
		return

	if(!check_plasma(5))
		return
	use_plasma(5)

	var/turf/M = get_turf(src)
	var/turf/U = get_turf(T)
	if (!istype(M) || !istype(U))
		return
	face_atom(T)

	visible_message("<span class='xenowarning'>\The [src] fires its autocannon!</span>", \
	"<span class='xenowarning'>You fire your autocannon!</span>" )
	playsound(src.loc,'sound/weapons/gun_smg.ogg', 75, 1)
	usedPounce = TRUE
	addtimer(CALLBACK(src, .proc/reset_pounce_delay), 1)

/mob/living/carbon/Xenomorph/Xenoborg/emp_act(severity)
	visible_message("<span class='danger'>\The [src] sparks and shudders!</span>", \
	"<span class='xenodanger'>WARN__--d-sEIE)(*##&&$*@#*&#</span>")
	adjustBruteLoss(50 * severity)
	adjustFireLoss(50 * severity)
	KnockDown(10)
	updatehealth()

/mob/living/carbon/Xenomorph/Xenoborg/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(user && O && stat != DEAD)
		if(iswelder(O))
			var/obj/item/tool/weldingtool/WT = O
			updatehealth()
			if(health < maxHealth)
				if(!WT.remove_fuel(10))
					to_chat(user, "<span class='warning'>You need more welding fuel to repair \the [src].</span>")
					return
				adjustBruteLoss(-20)
				adjustFireLoss(-20)
				updatehealth()
				playsound(src.loc, 'sound/items/Welder.ogg', 25, 1)
				visible_message("<span class='notice'>\The [user] repairs some of the damage to \the [src].</span>")
				return
			else
				to_chat(user, "<span class='warning'>\The [src] is not damaged.</span>")
				return
		if(istype(O, /obj/item/cell))
			var/obj/item/cell/C = O
			if(plasma_stored >= xeno_caste.plasma_max)
				to_chat(user, "<span class='warning'>\The [src] does not need a new cell right now.</span>")
				return
			src.visible_message("<span class='notice'>\The [user] carefully inserts \the [C] into \the [src]'s power supply port.")
			plasma_stored += C.charge
			if(plasma_stored > xeno_caste.plasma_max)
				plasma_stored = xeno_caste.plasma_max
			to_chat(src, "<span class='notice'>Your power supply suddenly updates. New charge: [plasma_stored]/[xeno_caste.plasma_max]")
			qdel(O)
			user.update_inv_l_hand(0) //Update the user sprites after the del, just to be safe.
			user.update_inv_r_hand()
	return ..() //Just do normal stuff then.

/mob/living/carbon/Xenomorph/Xenoborg/verb/toggle_gun()
	set name = "Toggle Autocannon"
	set desc = "Turns on or off click behavior for middle mouse, between pounce and gun."
	set category = "Alien"

	if(!gun_on)
		visible_message("<span class='xenowarning'>\The [src] extends and starts dry-spinning his arm-embedded autocannon.</span>", \
		"<span class='xenowarning'>You secure your stance as you extend and start dry-spinning your autocannon.</span>")
		gun_on = 1
	else
		visible_message("<span class='xenowarning'>\The [src] suddenly retracts his arm-embedded autocannon.</span>", \
		"<span class='xenowarning'>You retract your autocannon and switch back to your advanced mobility module.</span>")
		gun_on = 0
