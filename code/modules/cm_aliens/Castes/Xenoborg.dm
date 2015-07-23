
/mob/living/carbon/Xenomorph/Xenoborg
	caste = "Xenoborg"
	name = "Xenoborg"
	desc = "What.. what is this monstrosity? A cyborg in the shape of a xenomorph?! What hath our science wrought?"
	icon_state = "Xenoborg Walking"
	melee_damage_lower = 24
	melee_damage_upper = 28
	health = 200
	maxHealth = 200
	storedplasma = 1500
	plasma_gain = 0
	maxplasma = 1500
	jellyMax = 0
	caste_desc = "Oh dear god!"
	speed = -1.8
	evolves_to = list() //Cannot evolve.
	charge_type = 1 //Pounce
	is_intelligent = 1
	universal_speak = 1
	universal_understand = 1
	speak_emote = list("buzzes", "beeps")
	armor_deflection = 70
	fire_immune = 1
	is_robotic = 1

	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/regurgitate,
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		/mob/living/carbon/Xenomorph/proc/Pounce,
		/mob/living/carbon/Xenomorph/proc/tail_attack,
		/mob/living/carbon/Xenomorph/proc/corrosive_acid
		)

/mob/living/carbon/Xenomorph/Xenoborg/ClickOn(var/atom/A, params)

	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && middle_mouse_toggle)
		Pounce(A)
		return
	if(modifiers["shift"] && shift_mouse_toggle)
		Pounce(A)
		return
	..()


/mob/living/carbon/Xenomorph/Xenoborg/emp_act(severity)
	src.visible_message("[src] visibly shudders!","\red WARN__--d-sEIE)(*##&&$*@#*&#")
	adjustBruteLoss(20 * severity)
	adjustFireLoss(20 * severity)
	Weaken(12)
	updatehealth()

/mob/living/carbon/Xenomorph/Xenoborg/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(user && O && stat != DEAD)
		if(istype(O,/obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = O
			updatehealth()
			if(health < maxHealth)
				if(!WT.remove_fuel(10))
					user << "\red You need more welding fuel to repair this xenoborg."
					return
				adjustBruteLoss(-20)
				adjustFireLoss(-20)
				updatehealth()
				playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
				src.visible_message("\red [user] repairs some damage to the [src].")
				return
			else
				user << "The [src] is not damaged."
				return
		if(istype(O,/obj/item/weapon/cell))
			var/obj/item/weapon/cell/C = O
			if(storedplasma >= maxplasma)
				user << "[src] does not need a new cell right now."
				return
			src.visible_message("\red [user] carefully inserts [C] into the [src]'s power supply port.")
			storedplasma += C.charge
			if(storedplasma > maxplasma) storedplasma = maxplasma
			src << "\blue You feel your power recharging. Charge now at: [storedplasma]/[maxplasma]"
			del(O)
			user.update_inv_l_hand(0) //Update the user sprites after the del, just to be safe.
			user.update_inv_r_hand()
	return ..() //Just do normal stuff then.