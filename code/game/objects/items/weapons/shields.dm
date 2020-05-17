/obj/item/weapon/shield
	name = "shield"

/obj/item/weapon/shield/Initialize()
	. = ..()
	set_shield()

/obj/item/weapon/shield/proc/set_shield()
	AddComponent(/datum/component/shield, SHIELD_PARENT_INTEGRITY)

/obj/item/weapon/shield/riot
	name = "riot shield"
	desc = "A shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "riot"
	max_integrity = 200
	flags_equip_slot = ITEM_SLOT_BACK
	force = 5
	throwforce = 5
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	materials = list(/datum/material/metal = 1000)
	attack_verb = list("shoved", "bashed")
	soft_armor = list("melee" = 40, "bullet" = 20, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 0, "acid" = 0)
	hard_armor = list("melee" = 5, "bullet" = 5, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	hit_sound = 'sound/effects/grillehit.ogg'
	destroy_sound = 'sound/effects/glassbr3.ogg'
	var/cooldown = 0 //shield bash cooldown. based on world.time


/obj/item/weapon/shield/riot/examine(mob/user, distance, infix, suffix)
	. = ..()
	var/health_status = (obj_integrity * 100) / max_integrity
	switch(health_status)
		if(0 to 20)
			to_chat(user, "<span class='notice'>It's falling appart, will not be able to withstand much further damage.</span>")
		if(20 to 40)
			to_chat(user, "<span class='notice'>It has cracked edges and dents.</span>")
		if(40 to 60)
			to_chat(user, "<span class='notice'>It appears damaged, but still sturdy.</span>")
		if(60 to 80)
			to_chat(user, "<span class='notice'>It appears in decent condition, with some damage marks.</span>")
		if(80 to 100)
			to_chat(user, "<span class='notice'>It appears in perfect condition.</span>")
	

/obj/item/weapon/shield/riot/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/baton) && world.time >= cooldown)
		user.visible_message("<span class='warning'>[user] bashes [src] with [I]!</span>")
		playsound(user.loc, 'sound/effects/shieldbash.ogg', 25, 1)
		cooldown = world.time + 2.5 SECONDS
		return TRUE
	return ..()


/obj/item/weapon/shield/energy
	name = "energy combat shield"
	desc = "A shield capable of stopping most projectile and melee attacks. It can be retracted, expanded, and stored anywhere."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "eshield0" // eshield1 for expanded
	flags_atom = CONDUCT|NOBLOODY
	force = 3
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("shoved", "bashed")
	var/on_force = 10

/obj/item/weapon/shield/energy/set_shield()
	AddComponent(/datum/component/shield, SHIELD_TOGGLE|SHIELD_PURE_BLOCKING)

/obj/item/weapon/shield/energy/attack_self(mob/living/user)
	toggle_active()
	icon_state = "eshield[active]"
	if(active)
		force = on_force
		w_class = WEIGHT_CLASS_BULKY
		playsound(user, 'sound/weapons/saberon.ogg', 25, TRUE)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = initial(force)
		w_class = WEIGHT_CLASS_TINY
		playsound(user, 'sound/weapons/saberoff.ogg', 25, TRUE)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	add_fingerprint(user, "turned [active ? "on" : "off"]")
