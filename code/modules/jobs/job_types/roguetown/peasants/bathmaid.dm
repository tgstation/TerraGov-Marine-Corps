/datum/job/roguetown/nightmaiden
	title = "Bath Wench"
	flag = JESTER
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 2
	spawn_positions = 3

	allowed_sexes = list("female")
	allowed_races = list("Humen",
	"Humen",
	"Elf",
	"Dark Elf",
	"Half-Elf",
	"Tiefling",
	"Aasimar"
	)

	tutorial = "Nobody would envy your lot in life, for the role of the bathwench is not something so idly taken. It comes from a place of desperation, least usually: for any with true compassion or skill would seek position with a nunnery or the medical trade. Launder clothes and soothe wounds, that is your loathsome creed."

	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED)
	outfit = /datum/outfit/job/roguetown/nightmaiden
	display_order = JDO_NIGHTMAIDEN
	give_bank_account = TRUE
	can_random = FALSE

/datum/outfit/job/roguetown/nightmaiden/pre_equip(mob/living/carbon/human/H)
	..()
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	armor = /obj/item/clothing/suit/roguetown/shirt/dress/gen/sexy
	neck = /obj/item/storage/belt/rogue/pouch
	backpack_contents = list(/obj/item/roguekey/nightmaiden = 1)
	ADD_TRAIT(H, RTRAIT_GOODLOVER, TRAIT_GENERIC)

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/stealing, pick(2,3,4), TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/music, pick(1,2), TRUE)

// Washing Implements

/obj/item/bath/soap
	name = "herbal soap"
	desc = "a soap made from various herbs"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "soap"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	throwforce = 0
	throw_speed = 1
	throw_range = 7
	var/cleanspeed = 35 //slower than mop
	var/uses = 10

/obj/item/bath/soap/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 80)

/obj/item/bath/soap/examine(mob/user)
	. = ..()
	var/max_uses = initial(uses)
	var/msg = "It looks like it was freshly made."
	if(uses != max_uses)
		var/percentage_left = uses / max_uses
		switch(percentage_left)
			if(0 to 0.2)
				msg = "There's just a tiny bit left of what it used to be, you're not sure it'll last much longer."
			if(0.21 to 0.4)
				msg = "It's dissolved quite a bit, but there's still some life to it."
			if(0.41 to 0.6)
				msg = "It's past its prime, but it's definitely still good."
			if(0.61 to 0.85)
				msg = "It's started to get a little smaller than it used to be, but it'll definitely still last for a while."
			else
				msg = "It's seen some light use, but it's still pretty fresh."
	. += "<span class='notice'>[msg]</span>"

/obj/item/bath/soap/attack(mob/target, mob/user)
	var/turf/bathspot = get_turf(target)
	if(!istype(bathspot, /turf/open/water/bath))
		to_chat(user, "<span class='warning'>They must be in the bath water!</span>")
		return
	if(istype(target, /mob/living/carbon/human))
		visible_message("<span class='info'>[user] begins scrubbing [target] with the [src].</span>")
		if(do_after(user, 50))
			if(user.job == "Bath Wench")
				visible_message("<span class='info'>[user] expertly scrubs and soothes [target] with the [src].</span>")
				to_chat(target, "<span class='love'>I feel so relaxed and clean!</span>")
				SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "bathcleaned", /datum/mood_event/bathcleaned)
			else
				visible_message("<span class='info'>[user] tries their best to scrub [target] with the [src].</span>")
				to_chat(target, "<span class='warning'>Ouch! That hurts!</span>")
			uses -= 1
			if(uses == 0)
				qdel(src)
