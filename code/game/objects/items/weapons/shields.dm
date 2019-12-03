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
	flags_equip_slot = ITEM_SLOT_BACK
	force = 5.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	materials = list(/datum/material/metal = 1000)
	attack_verb = list("shoved", "bashed")
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 0, "acid" = 0)
	hit_sound = 'sound/effects/grillehit.ogg'
	destroy_sound = 'sound/effects/glassbr3.ogg'
	var/cooldown = 0 //shield bash cooldown. based on world.time

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

/obj/item/weapon/shield/energy/test
	name = "test shield"
	armor = list("melee" = 80, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 80, "bio" = 30, "rad" = 0, "fire" = 80, "acid" = 80)

/obj/item/weapon/shield/energy/test/set_shield()
	AddComponent(/datum/component/shield/overhealth)
