/obj/item/clothing/under/misc
	icon = 'icons/obj/clothing/under/misc.dmi'
	mob_overlay_icon = 'icons/mob/clothing/under/misc.dmi'

/obj/item/clothing/under/misc/pj
	name = "\improper PJs"
	desc = ""
	can_adjust = FALSE
	item_state = "w_suit"

/obj/item/clothing/under/misc/pj/red
	icon_state = "red_pyjamas"

/obj/item/clothing/under/misc/pj/blue
	icon_state = "blue_pyjamas"

/obj/item/clothing/under/misc/patriotsuit
	name = "Patriotic Suit"
	desc = ""
	icon_state = "ek"
	item_state = "ek"
	can_adjust = FALSE

/obj/item/clothing/under/misc/mailman
	name = "mailman's jumpsuit"
	desc = ""
	icon_state = "mailman"
	item_state = "b_suit"

/obj/item/clothing/under/misc/psyche
	name = "psychedelic jumpsuit"
	desc = ""
	icon_state = "psyche"
	item_state = "p_suit"

/obj/item/clothing/under/misc/vice_officer
	name = "vice officer's jumpsuit"
	desc = ""
	icon_state = "vice"
	item_state = "gy_suit"
	can_adjust = FALSE

/obj/item/clothing/under/misc/adminsuit
	name = "administrative cybernetic jumpsuit"
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	icon_state = "syndicate"
	item_state = "bl_suit"
	mob_overlay_icon = 'icons/mob/clothing/under/syndicate.dmi'
	desc = ""
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100,"energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	can_adjust = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/under/misc/burial
	name = "burial garments"
	desc = ""
	icon_state = "burial"
	item_state = "burial"
	can_adjust = FALSE
	has_sensor = NO_SENSORS

/obj/item/clothing/under/misc/overalls
	name = "laborer's overalls"
	desc = ""
	icon_state = "overalls"
	item_state = "lb_suit"
	can_adjust = FALSE
	custom_price = 20

/obj/item/clothing/under/misc/assistantformal
	name = "assistant's formal uniform"
	desc = ""
	icon_state = "assistant_formal"
	item_state = "gy_suit"
	can_adjust = FALSE

/obj/item/clothing/under/plasmaman
	name = "plasma envirosuit"
	desc = ""
	icon_state = "plasmaman"
	item_state = "plasmaman"
	icon = 'icons/obj/clothing/under/plasmaman.dmi'
	mob_overlay_icon = 'icons/mob/clothing/under/plasmaman.dmi'
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 95, "acid" = 95)
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	can_adjust = FALSE
	strip_delay = 80
	var/next_extinguish = 0
	var/extinguish_cooldown = 100
	var/extinguishes_left = 5


/obj/item/clothing/under/plasmaman/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There are [extinguishes_left] extinguisher charges left in this suit.</span>"

/obj/item/clothing/under/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.on_fire)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message("<span class='warning'>[H]'s suit automatically extinguishes [H.p_them()]!</span>","<span class='warning'>My suit automatically extinguishes you.</span>")
			H.ExtinguishMob()
			new /obj/effect/particle_effect/water(get_turf(H))
	return 0

/obj/item/clothing/under/plasmaman/attackby(obj/item/E, mob/user, params)
	..()
	if (istype(E, /obj/item/extinguisher_refill))
		if (extinguishes_left == 5)
			to_chat(user, "<span class='notice'>The inbuilt extinguisher is full.</span>")
			return
		else
			extinguishes_left = 5
			to_chat(user, "<span class='notice'>I refill the suit's built-in extinguisher, using up the cartridge.</span>")
			qdel(E)
			return
		return
	return

/obj/item/extinguisher_refill
	name = "envirosuit extinguisher cartridge"
	desc = ""
	icon_state = "plasmarefill"
	icon = 'icons/obj/device.dmi'

/obj/item/clothing/under/misc/durathread
	name = "durathread jumpsuit"
	desc = ""
	icon_state = "durathread"
	item_state = "durathread"
	can_adjust = FALSE
	armor = list("melee" = 10, "laser" = 10, "fire" = 40, "acid" = 10, "bomb" = 5)
