/obj/item/fulton
	name = "fulton"
	var/mob/living/attached

/obj/item/fulton/attack(mob/living/L, mob/user)
	if(!istype(L))
		return ..()
	if (!ishuman(user))
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return