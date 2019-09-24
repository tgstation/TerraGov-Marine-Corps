/mob/living/carbon/monkey
	name = "monkey"
	speak_emote = list("chimpers")
	icon_state = "monkey1"
	icon = 'icons/mob/monkey.dmi'
	gender = NEUTER
	flags_pass = PASSTABLE
	hud_type = /datum/hud/monkey
	hud_possible = list(XENO_EMBRYO_HUD)

	var/obj/item/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/greaterform_type = /datum/species/human
	icon_state = "monkey1"
	//var/uni_append = "12C4E2"                // Small appearance modifier for different species.
	var/list/uni_append = list(0x12C,0x4E2)    // Same as above for DNA2.
	var/update_muts = 1                        // Monkey gene must be set at start.

	//temperature limits, will default to the greater form's if not set.
	var/cold_level_1
	var/cold_level_2
	var/cold_level_3

	var/heat_level_1
	var/heat_level_2
	var/heat_level_3


/mob/living/carbon/monkey/prepare_huds()
	..()
	med_hud_set_status()
	add_to_all_mob_huds()


/mob/living/carbon/monkey/tajara
	name = "farwa"
	speak_emote = list("mews")
	icon_state = "tajkey1"
	greaterform_type = /datum/species/tajaran
	uni_append = list(0x0A0,0xE00) // 0A0E00

/mob/living/carbon/monkey/skrell
	name = "neaera"
	speak_emote = list("squicks")
	icon_state = "skrellkey1"
	greaterform_type = /datum/species/skrell
	uni_append = list(0x01C,0xC92) // 01CC92

/mob/living/carbon/monkey/unathi
	name = "stok"
	speak_emote = list("hisses")
	icon_state = "stokkey1"
	greaterform_type = /datum/species/unathi
	uni_append = list(0x044,0xC5D) // 044C5D


//-----Monkey Yeti Thing
/mob/living/carbon/monkey/yiren
	name = "yiren"
	speak_emote = list("grumbles")
	icon_state = "yirenkey1"
	cold_level_1 = ICE_COLONY_TEMPERATURE - 20
	cold_level_2 = ICE_COLONY_TEMPERATURE - 40
	cold_level_3 = ICE_COLONY_TEMPERATURE - 80


/mob/living/carbon/monkey/Initialize()
	verbs += /mob/living/proc/lay_down
	create_reagents(1000)

	if(greaterform_type)
		species = new greaterform_type()

		cold_level_1 = null ? species.cold_level_1 : cold_level_1
		cold_level_2 = null ? species.cold_level_2 : cold_level_2
		cold_level_3 = null ? species.cold_level_3 : cold_level_3

		heat_level_1 = null ? species.heat_level_1 : heat_level_1
		heat_level_2 = null ? species.heat_level_2 : heat_level_2
		heat_level_3 = null ? species.heat_level_3 : heat_level_3


	if(name == initial(name)) //To stop Pun-Pun becoming generic.
		name = "[name] ([rand(1, 1000)])"
		real_name = name

	if(gender == NEUTER)
		gender = pick(MALE, FEMALE)

	return ..()

/mob/living/carbon/monkey/movement_delay()
	. = ..()

	if(reagents)
		if(reagents.has_reagent(/datum/reagent/medicine/hyperzine)) . -= 1

	var/health_deficiency = (100 - health)
	if(health_deficiency >= 45) . += (health_deficiency / 25)

	if(bodytemperature < 283.222)
		. += (283.222 - bodytemperature) / 10 * 1.75

	. += CONFIG_GET(number/outdated_movedelay/monkey_delay)

/mob/living/carbon/monkey/get_permeability_protection()
	var/protection = 0
	//if(head)
	//	protection = 1 - head.permeability_coefficient ((no head slot in inventory for time being))
	if(wear_mask)
		protection = max(1 - wear_mask.permeability_coefficient, protection)
	protection = protection/7 //the rest of the body isn't covered.
	return protection

/mob/living/carbon/monkey/reagent_check(datum/reagent/R) //can metabolize all reagents
	return FALSE

/mob/living/carbon/monkey/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["item"])
		if(!usr.incapacitated() && in_range(src, usr))
			if(!usr.action_busy)
				var/slot = text2num(href_list["item"])
				var/obj/item/what = get_item_by_slot(slot)
				if(what)
					usr.stripPanelUnequip(what,src,slot)
				else
					what = usr.get_active_held_item()
					usr.stripPanelEquip(what,src,slot)

	if(href_list["internal"])

		if(!usr.action_busy)
			log_combat(usr, src, "toggled internals (attempted)")
			if(internal)
				usr.visible_message("<span class='danger'>[usr] is trying to disable [src]'s internals</span>", null, 4)
			else
				usr.visible_message("<span class='danger'>[usr] is trying to enable [src]'s internals.</span>", null, 4)

			if(do_mob(usr, src, 30, BUSY_ICON_GENERIC))
				if (internal)
					internal = null
					if (hud_used && hud_used.internals)
						hud_used.internals.icon_state = "internal0"
				else
					if(istype(wear_mask, /obj/item/clothing/mask))
						if (istype(back, /obj/item/tank))
							internal = back
							visible_message("[src] is now running on internals.", null, 3)
							if (hud_used && hud_used.internals)
								hud_used.internals.icon_state = "internal1"



/mob/living/carbon/monkey/attack_paw(mob/living/carbon/monkey/user)
	. = ..()

	if (user.a_intent == INTENT_HARM)
		help_shake_act(user)
	else
		if ((user.a_intent == INTENT_HARM && !( istype(wear_mask, /obj/item/clothing/mask/muzzle) )))
			if ((prob(75) && health > 0))
				playsound(loc, 'sound/weapons/bite.ogg', 25, 1)
				visible_message("<span class='danger'>[user] has bit [src]!</span>")
				var/damage = rand(1, 5)
				adjustBruteLoss(damage)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
			else
				visible_message("<span class='danger'>[user] has attempted to bite [src]!</span>")


/mob/living/carbon/monkey/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	if(H.gloves)
		var/obj/item/clothing/gloves/G = H.gloves
		if(G.cell)
			if(H.a_intent == INTENT_HARM)//Stungloves. Any contact will stun the alien.
				if(G.cell.charge >= 2500)
					G.cell.use(2500)
					knock_down(5)
					if (stuttering < 5)
						stuttering = 5
					stun(5)

					visible_message("<span class='danger'>[src] has been touched with the stun gloves by [H]!</span>", "<span class='warning'> You hear someone fall</span>")
					return
				else
					to_chat(H, "<span class='warning'>Not enough charge! </span>")
					return

	if (H.a_intent == INTENT_HELP)
		help_shake_act(H)
	else
		if (H.a_intent == INTENT_HARM)
			var/datum/unarmed_attack/attack = H.species.unarmed
			if ((prob(75) && health > 0))
				visible_message("<span class='danger'>[H] [pick(attack.attack_verb)]ed [src]!</span>")

				playsound(loc, "punch", 25, 1)
				var/damage = rand(5, 10)
				if (prob(40))
					damage = rand(10, 15)
					if (knocked_out < 5)
						knock_out(rand(10, 15))
						visible_message("<span class='danger'>[H] has knocked out [src]!</span>")

				adjustBruteLoss(damage)

				log_combat(H, src, "[pick(attack.attack_verb)]ed")
				msg_admin_attack("[key_name(H)] [pick(attack.attack_verb)]ed [key_name(src)]")

				updatehealth()
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1)
				visible_message("<span class='danger'>[H] tried to [pick(attack.attack_verb)] [src]!</span>")
		else
			if (H.a_intent == INTENT_GRAB)
				if(H == src || anchored)
					return 0

				H.start_pulling(src)
				return 1
			else
				if (!( knocked_out ))
					if (prob(25))
						knock_out(2)
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1)
						visible_message("<span class='danger'>[H] has pushed down [src]!</span>")
					else
						drop_held_item()
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1)
						visible_message("<span class='danger'>[H] has pushed down [src]!</span>")


/mob/living/carbon/monkey/attack_animal(mob/living/M as mob)
	if (!..())
		return 0

	if(M.melee_damage == 0)
		M.emote("[M.friendly] [src]")
	else
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 25, 1)
		visible_message("<span class='danger'>[M] [M.attacktext] [src]!</span>", 1)
		log_combat(M, src, "attacked")
		var/damage = M.melee_damage
		adjustBruteLoss(damage)
		updatehealth()

	return 1


/mob/living/carbon/monkey/Stat()
	. = ..()

	if(statpanel("Stats"))
		stat(null, text("Intent: []", a_intent))
		stat(null, text("Move Mode: []", m_intent))

/mob/living/carbon/monkey/verb/removeinternal()
	set name = "Remove Internals"
	set category = "IC"
	internal = null
	return


/mob/living/carbon/monkey/emp_act(severity)
	if(wear_id) wear_id.emp_act(severity)
	..()

/mob/living/carbon/monkey/has_smoke_protection()
	if(istype(wear_mask) && wear_mask.flags_inventory & BLOCKGASEFFECT)
		return TRUE
	return ..()

/mob/living/carbon/monkey/ex_act(severity)
	flash_eyes()

	switch(severity)
		if(1.0)
			if (stat != DEAD)
				adjustBruteLoss(200)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
		if(2.0)
			if (stat != DEAD)
				adjustBruteLoss(60)
				adjustFireLoss(60)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
		if(3.0)
			if (stat != DEAD)
				adjustBruteLoss(30)
				health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()
			if (prob(50))
				knock_out(10)
		else
	return


/mob/living/carbon/monkey/get_idcard(hand_first)
	var/obj/item/card/id/id_card
	id_card = get_active_held_item()

	if(!id_card) //If there is no id, check the other hand
		id_card = get_inactive_held_item()

	if(istype(id_card, /obj/item/storage/wallet))
		var/obj/item/storage/wallet/W = id_card
		id_card = W.front_id
	
	return istype(id_card) ? id_card : null


/mob/living/carbon/monkey/get_reagent_tags()
	. = ..()
	return .|IS_MONKEY
