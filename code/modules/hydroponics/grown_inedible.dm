// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/grown // Grown things that are not edible
	name = "grown_weapon"
	icon = 'icons/obj/items/weapons.dmi'
	var/plantname
	var/potency = 1

/obj/item/grown/New()

	..()

	var/datum/reagents/R = new/datum/reagents(50)
	reagents = R
	R.my_atom = src

	//Handle some post-spawn var stuff.
	spawn(1)
		// Fill the object up with the appropriate reagents.
		if(!isnull(plantname))
			var/datum/seed/S = GLOB.seed_types[plantname]
			if(!S || !S.chems)
				return

			potency = S.potency

			for(var/rid in S.chems)
				var/list/reagent_data = S.chems[rid]
				var/rtotal = reagent_data[1]
				if(reagent_data.len > 1 && potency > 0)
					rtotal += round(potency/reagent_data[2])
				reagents.add_reagent(rid,max(1,rtotal))

/obj/item/grown/log
	name = "towercap"
	name = "tower-cap log"
	desc = "It's better than bad, it's good!"
	icon = 'icons/obj/items/harvest.dmi'
	icon_state = "logs"
	force = 5
	flags_atom = NOFLAGS
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3
	origin_tech = "materials=1"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")

	attackby(obj/item/W as obj, mob/user as mob)
		if(W.sharp == IS_SHARP_ITEM_BIG)
			user.show_message("<span class='notice'>You make planks out of \the [src]!</span>", 1)
			for(var/i=0,i<2,i++)
				var/obj/item/stack/sheet/wood/NG = new (user.loc)
				for (var/obj/item/stack/sheet/wood/G in user.loc)
					if(G==NG)
						continue
					if(G.amount>=G.max_amount)
						continue
					G.attackby(NG, user)
					to_chat(usr, "You add the newly-formed wood to the stack. It now contains [NG.amount] planks.")
			qdel(src)
			return

/obj/item/grown/sunflower // FLOWER POWER!
	plantname = "sunflowers"
	name = "sunflower"
	desc = "It's beautiful! A certain person might beat you to death if you trample these."
	icon = 'icons/obj/items/harvest.dmi'
	icon_state = "sunflower"
	damtype = "fire"
	force = 0
	flags_atom = NOFLAGS
	throwforce = 1
	w_class = 1.0
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
	damtype = "fire"
	force = 15
	flags_atom = NOFLAGS
	throwforce = 1
	w_class = 2.0
	throw_speed = 1
	throw_range = 3
	origin_tech = "combat=1"
	attack_verb = list("stung")
	hitsound = ""

	var/potency_divisior = 5

/obj/item/grown/nettle/New()
	..()
	spawn(5)
		force = round((5+potency/potency_divisior), 1)

/obj/item/grown/nettle/pickup(mob/living/carbon/human/user as mob)
	if(istype(user) && !user.gloves)
		to_chat(user, "<span class='warning'>The nettle burns your bare hand!</span>")
		if(ishuman(user))
			var/organ = ((user.hand ? "l_":"r_") + "arm")
			var/datum/limb/affecting = user.get_limb(organ)
			if(affecting.take_damage_limb(0, force))
				user.UpdateDamageIcon()
		else
			user.take_limb_damage(0,force)
		return 1
	return 0

/obj/item/grown/nettle/proc/lose_leaves(var/mob/user)
	if(force > 0)
		playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1)
		force -= rand(1,(force/3)+1) // When you whack someone with it, leaves fall off

	sleep(1)

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
	origin_tech = "combat=3"
	potency_divisior = 2.5

/obj/item/grown/nettle/death/pickup(mob/living/carbon/human/user as mob)

	if(..() && prob(50))
		user.KnockOut(5)
		to_chat(user, "<span class='warning'>You are stunned by the deathnettle when you try picking it up!</span>")

/obj/item/grown/nettle/attack(mob/living/carbon/M as mob, mob/user as mob)

	if(!..()) return

	lose_leaves(user)

/obj/item/grown/nettle/death/attack(mob/living/carbon/M as mob, mob/user as mob)

	if(!..()) return

	if(isliving(M))
		to_chat(M, "<span class='warning'>You are stunned by the powerful acid of the deathnettle!</span>")

		log_combat(user, M, "hit", src)
		msg_admin_attack("[ADMIN_TPMONTY(usr)] used the [src.name] on [ADMIN_TPMONTY(M)].")

		M.adjust_blurriness(force/7)
		if(prob(20))
			M.KnockOut(force/6)
			M.KnockDown(force/15)
		M.drop_held_item()

/obj/item/corncob
	name = "corn cob"
	desc = "A reminder of meals gone by."
	icon = 'icons/obj/items/harvest.dmi'
	icon_state = "corncob"
	item_state = "corncob"
	w_class = 2.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/corncob/attackby(obj/item/W as obj, mob/user as mob)
	if(W.sharp == IS_SHARP_ITEM_ACCURATE)
		to_chat(user, "<span class='notice'>You use [W] to fashion a pipe out of the corn cob!</span>")
		new /obj/item/clothing/mask/cigarette/pipe/cobpipe (user.loc)
		qdel(src)
	else
		return ..()
