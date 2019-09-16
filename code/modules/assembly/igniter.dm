/obj/item/assembly/igniter
	name = "igniter"
	desc = "A small electronic device able to ignite combustible substances."
	icon_state = "igniter"
	materials = list(/datum/material/metal = 500, /datum/material/glass = 50)
	var/datum/effect_system/spark_spread/sparks
	heat = 1000


/obj/item/assembly/igniter/Initialize()
	. = ..()
	sparks = new
	sparks.set_up(2, 0, src)
	sparks.attach(src)


/obj/item/assembly/igniter/Destroy()
	QDEL_NULL(sparks)
	return ..()


/obj/item/assembly/igniter/activate()
	. = ..()
	if(!.)
		return FALSE //Cooldown check
	sparks.start()
	return TRUE


/obj/item/assembly/igniter/attack_self(mob/user)
	activate()
