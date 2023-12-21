#define TARGETTING_DUMMY_USE_DELAY 20
#define TARGETTING_DUMMY_WELD_DELAY 10

// Targets, the things that actually get shot!
/obj/item/target
	name = "shooting target"
	desc = "A shooting target."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_h"
	density = FALSE
	resistance_flags = INDESTRUCTIBLE

/obj/item/target/default
	desc = "A shooting target with a distinctly human outline."

/obj/item/target/syndicate
	icon_state = "target_s"
	desc = "A shooting target that looks like a hostile agent."

/obj/item/target/alien
	icon_state = "target_q"
	desc = "A shooting target with a threatening silhouette."

///Basically these are for the firing range
/obj/structure/target_stake
	name = "target stake"
	desc = "A thin platform with negatively-magnetized wheels."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_stake"
	density = TRUE
	flags_atom = CONDUCT
	max_integrity = 15000 //important that what the marines are shooting at doesn't break, we don't make it invulnerable because we still need to plasma cutter it sometimes
	soft_armor = list(MELEE = 80, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 120, BIO = 100, FIRE = 100, ACID = 0)
	///ungas need to actually hit this
	coverage = 90

/obj/structure/target_stake/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!istype(I, /obj/item/target))
		return
	var/obj/item/target/targetcushion = I
	to_chat(user, "You start fitting the target onto the stake.")
	if(!do_after(user, TARGETTING_DUMMY_USE_DELAY, NONE, src, BUSY_ICON_FRIENDLY))
		return
	if(istype(targetcushion, /obj/item/target/default))
		new /obj/structure/target_stake/occupied(loc)
	else if(istype(targetcushion, /obj/item/target/alien))
		new /obj/structure/target_stake/occupied/alien(loc)
	else if(istype(targetcushion, /obj/item/target/syndicate))
		new /obj/structure/target_stake/occupied/syndicate(loc)
	else //default to a regular human target
		new /obj/structure/target_stake/occupied(loc)
	to_chat(user, "You slide the target into the stake.")
	qdel(src) //delete original target_stake
	qdel(I) //delete targetting dummy in users hand

///These are occupied variations for targetting stakes
/obj/structure/target_stake/occupied
	desc = "A thin platform with negatively-magnetized wheels, this one appears to have a target dummy mounted on it."
	icon_state = "target_stake_target_h"
	///what kind of target to drop when a player removes a dummy from the targetting stake
	var/cushion_type = "default"

/obj/structure/target_stake/occupied/welder_act(mob/living/user, obj/item/I)
	. = ..()
	var/obj/item/tool/weldingtool/usedwelder = I
	if(!do_after(user, TARGETTING_DUMMY_WELD_DELAY, NONE, src, BUSY_ICON_FRIENDLY))
		return
	if(usedwelder.remove_fuel(2, user))
		overlays.Cut()
		obj_integrity = max_integrity
		to_chat(usr, "You slice off [src]'s uneven chunks of aluminum and patch the bullet holes, it looks practically new.")
		return

/obj/structure/target_stake/occupied/alien
	icon_state = "target_stake_target_q"
	cushion_type = "alien"

/obj/structure/target_stake/occupied/syndicate
	icon_state = "target_stake_target_s"
	cushion_type = "syndicate"

/obj/structure/target_stake/occupied/attack_hand(mob/living/user)
	to_chat(user, "You start removing the target from the stake.")
	if(!do_after(user, TARGETTING_DUMMY_USE_DELAY, NONE, src, BUSY_ICON_FRIENDLY))
		return
	///create new target stake to create the illusion of a new one
	new /obj/structure/target_stake(loc)
	if(obj_integrity < 2000) //if critically damaged we don't give the user a new target dummy after removal
		to_chat(user, "As remove the last shreds of the target from the stake, you conclude there's nothing worth salvaging from the mess.")
		qdel(src)
		return
	///dump new target at the foot of the user
	switch(cushion_type)
		if("default")
			new /obj/item/target/default(get_turf(user))
		if("alien")
			new /obj/item/target/alien(get_turf(user))
		if("syndicate")
			new /obj/item/target/syndicate(get_turf(user))
	to_chat(user, "You take the target out of the stake.")
	qdel(src)

/obj/structure/target_stake/occupied/examine(mob/user)
	. = ..()
	switch(obj_integrity)
		if(10000 to INFINITY)
			. += span_info("It appears to be in good shape.")
		if(5000 to 10000)
			. += span_warning("It's been damaged some, but it's still in good shape for target practice.")
		if(2000 to 5000)
			. += span_warning("It's quite riddled with bullet holes and sagging slightly..")
		if(-INFINITY to 2000)
			. += span_warning("There's almost nothing left of it, it's been shredded away.")

#undef TARGETTING_DUMMY_USE_DELAY
#undef TARGETTING_DUMMY_WELD_DELAY
