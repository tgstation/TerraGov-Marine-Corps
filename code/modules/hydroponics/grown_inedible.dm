// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/grown // Grown things that are not edible
	name = "grown_weapon"
	icon = 'icons/obj/items/weapons.dmi'
	var/plantname
	var/potency = 1

/obj/item/grown/Initialize(mapload)
	. = ..()

	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = WEAKREF(src)

/obj/item/grown/LateInitialize()
	. = ..()
	// Fill the object up with the appropriate reagents.
	if(isnull(plantname))
		return
	var/datum/seed/S = GLOB.seed_types[plantname]
	if(!S || !S.chems)
		return

	potency = S.potency

	for(var/rid in S.chems)
		var/list/reagent_data = S.chems[rid]
		var/rtotal = reagent_data[1]
		if(length(reagent_data) > 1 && potency > 0)
			rtotal += round(potency/reagent_data[2])
		reagents.add_reagent(rid,max(1,rtotal))

/obj/item/grown/log
	name = "towercap"
	name = "tower-cap log"
	desc = "It's better than bad, it's good!"
	icon = 'icons/obj/items/harvest.dmi'
	icon_state = "logs"
	force = 5
	flags_atom = NONE
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 3
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")


/obj/item/grown/log/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(I.sharp != IS_SHARP_ITEM_BIG)
		return

	user.show_message(span_notice("You make planks out of \the [src]!"), 1)
	var/obj/item/stack/sheet/wood/NG = new(user.loc, 2)
	NG.add_to_stacks(user)
	qdel(src)


/obj/item/grown/sunflower // FLOWER POWER!
	plantname = "sunflowers"
	name = "sunflower"
	desc = "It's beautiful! A certain person might beat you to death if you trample these."
	icon = 'icons/obj/items/harvest.dmi'
	icon_state = "sunflower"
	damtype = BURN
	force = 0
	flags_atom = NONE
	throwforce = 1
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3

/obj/item/grown/sunflower/attack(mob/M as mob, mob/user as mob)
	to_chat(M, "<font color='green'><b> [user] smacks you with a sunflower!</font><font color='yellow'><b>FLOWER POWER<b></font>")
	to_chat(user, "<font color='green'> Your sunflower's </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'> strikes [M]</font>")

/obj/item/grown/nettle // -- Skie
	plantname = "nettle"
	desc = "It's probably <B>not</B> wise to touch it with bare hands..."
	icon = 'icons/obj/items/weapons.dmi'
	name = "nettle"
	icon_state = "nettle"
	damtype = BURN
	force = 15
	flags_atom = NONE
	throwforce = 1
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 1
	throw_range = 3
	attack_verb = list("stung")
	hitsound = ""

	var/potency_divisior = 5

/obj/item/grown/nettle/Initialize(mapload)
	. = ..()
	force = round(5 + potency / potency_divisior)

/obj/item/grown/nettle/pickup(mob/living/carbon/human/user as mob)
	if(istype(user) && !user.gloves)
		to_chat(user, span_warning("The nettle burns your bare hand!"))
		if(ishuman(user))
			var/organ = ((user.hand ? "l_":"r_") + "arm")
			var/datum/limb/affecting = user.get_limb(organ)
			if(affecting.take_damage_limb(0, force))
				user.UpdateDamageIcon()
		else
			user.take_limb_damage(0, force)
			UPDATEHEALTH(user)
		return 1
	return 0

/obj/item/grown/nettle/proc/lose_leaves(mob/user)
	if(force > 0)
		playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off

	sleep(0.1 SECONDS)

	if(force <= 0)
		if(user)
			to_chat(user, "All the leaves have fallen off \the [src] from violent whacking.")
			user.temporarilyRemoveItemFromInventory(src)
		qdel(src)

/obj/item/grown/nettle/death // -- Skie
	plantname = "deathnettle"
	desc = "The <span class='warning'> glowing \black nettle incites <span class='warning'><B>rage</B>\black in you just from looking at it!</span>"
	name = "deathnettle"
	icon_state = "deathnettle"
	potency_divisior = 2.5

/obj/item/grown/nettle/death/pickup(mob/living/carbon/human/user as mob)

	if(..() && prob(50))
		user.Unconscious(10 SECONDS)
		to_chat(user, span_warning("You are stunned by the deathnettle when you try picking it up!"))

/obj/item/grown/nettle/attack(mob/living/carbon/M as mob, mob/user as mob)

	if(!..()) return

	lose_leaves(user)

/obj/item/grown/nettle/death/attack(mob/living/carbon/M as mob, mob/user as mob)

	if(!..()) return

	if(isliving(M))
		to_chat(M, span_warning("You are stunned by the powerful acid of the deathnettle!"))

		log_combat(user, M, "hit", src)

		M.adjust_blurriness(force/7)
		if(prob(20))
			M.Unconscious(force/3 SECONDS)
			M.Paralyze(force/7.5 SECONDS)
		M.drop_held_item()

/obj/item/corncob
	name = "corn cob"
	desc = "A reminder of meals gone by."
	icon = 'icons/obj/items/harvest.dmi'
	icon_state = "corncob"
	item_state = "corncob"
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 4
	throw_range = 20

/obj/item/corncob/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(I.sharp == IS_SHARP_ITEM_ACCURATE)
		to_chat(user, span_notice("You use [I] to fashion a pipe out of the corn cob!"))
		new /obj/item/clothing/mask/cigarette/pipe/cobpipe(user.loc)
		qdel(src)
