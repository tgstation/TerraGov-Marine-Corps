/obj/structure/displaycase
	name = "display case"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox1"
	desc = "A display case for prized possessions. It taunts you to kick it."
	density = TRUE
	anchored = TRUE
	resistance_flags = UNACIDABLE
	max_integrity = 30
	var/occupied = 1
	var/destroyed = 0

/obj/structure/displaycase/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			deconstruct(FALSE)
		if(EXPLODE_HEAVY)
			take_damage(15)
		if(EXPLODE_LIGHT)
			take_damage(5)


/obj/structure/displaycase/update_icon()
	if(destroyed)
		icon_state = "glassboxb[occupied]"
	else
		icon_state = "glassbox[occupied]"


/obj/structure/displaycase/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(destroyed && occupied)
		to_chat(user, span_notice("You deactivate the hover field built into the case."))
		occupied = FALSE
		update_icon()
		return

	visible_message(span_warning("[user] kicks the display case."), span_notice("You kick the display case."))
	take_damage(2)

//Quick destroyed case.
/obj/structure/displaycase/destroyed
	icon_state = "glassboxb0"
	max_integrity = 0
	occupied = FALSE
	destroyed = TRUE
	coverage = 0
