/obj/item/crowbar
	name = "pocket crowbar"
	desc = ""
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	usesound = 'sound/blank.ogg'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron=50)
	drop_sound = 'sound/blank.ogg'
	pickup_sound =  'sound/blank.ogg'

	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	var/force_opens = FALSE

/obj/item/crowbar/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is beating [user.p_them()]self to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/blank.ogg', 50, TRUE, -1)
	return (BRUTELOSS)

/obj/item/crowbar/red
	icon_state = "crowbar_red"
	force = 8

/obj/item/crowbar/abductor
	name = "alien crowbar"
	desc = ""
	icon = 'icons/obj/abductor.dmi'
	usesound = 'sound/blank.ogg'
	icon_state = "crowbar"
	toolspeed = 0.1


/obj/item/crowbar/large
	name = "crowbar"
	desc = ""
	force = 12
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 3
	throw_range = 3
	custom_materials = list(/datum/material/iron=70)
	icon_state = "crowbar_large"
	item_state = "crowbar"
	toolspeed = 0.7

/obj/item/crowbar/power
	name = "jaws of life"
	desc = ""
	icon_state = "jaws_pry"
	item_state = "jawsoflife"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_materials = list(/datum/material/iron=150,/datum/material/silver=50,/datum/material/titanium=25)
	usesound = 'sound/blank.ogg'
	force = 15
	toolspeed = 0.7
	force_opens = TRUE

/obj/item/crowbar/power/examine()
	. = ..()
	. += " It's fitted with a [tool_behaviour == TOOL_CROWBAR ? "prying" : "cutting"] head."

/obj/item/crowbar/power/suicide_act(mob/user)
	if(tool_behaviour == TOOL_CROWBAR)
		user.visible_message("<span class='suicide'>[user] is putting [user.p_their()] head in [src], it looks like [user.p_theyre()] trying to commit suicide!</span>")
		playsound(loc, 'sound/blank.ogg', 50, TRUE, -1)
	else
		user.visible_message("<span class='suicide'>[user] is wrapping \the [src] around [user.p_their()] neck. It looks like [user.p_theyre()] trying to rip [user.p_their()] head off!</span>")
		playsound(loc, 'sound/blank.ogg', 50, TRUE, -1)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			var/obj/item/bodypart/BP = C.get_bodypart(BODY_ZONE_HEAD)
			if(BP)
				BP.drop_limb()
				playsound(loc, "desceration", 50, TRUE, -1)
	return (BRUTELOSS)

/obj/item/crowbar/power/attack_self(mob/user)
	playsound(get_turf(user), 'sound/blank.ogg', 50, TRUE)
	if(tool_behaviour == TOOL_CROWBAR)
		tool_behaviour = TOOL_WIRECUTTER
		to_chat(user, "<span class='notice'>I attach the cutting jaws to [src].</span>")
		usesound = 'sound/blank.ogg'
		icon_state = "jaws_cutter"
	else
		tool_behaviour = TOOL_CROWBAR
		to_chat(user, "<span class='notice'>I attach the prying jaws to [src].</span>")
		usesound = 'sound/blank.ogg'
		icon_state = "jaws_pry"

/obj/item/crowbar/power/attack(mob/living/carbon/C, mob/user)
	if(istype(C) && C.handcuffed && tool_behaviour == TOOL_WIRECUTTER)
		user.visible_message("<span class='notice'>[user] cuts [C]'s restraints with [src]!</span>")
		qdel(C.handcuffed)
		return
	else
		..()

/obj/item/crowbar/cyborg
	name = "hydraulic crowbar"
	desc = ""
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "crowbar_cyborg"
	usesound = 'sound/blank.ogg'
	force = 10
	toolspeed = 0.5
