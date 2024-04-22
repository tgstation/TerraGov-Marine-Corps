#define FABRIC_PER_SHEET 4


///This is a loom. It's usually made out of wood and used to weave fabric like durathread or cotton into their respective cloth types.
/obj/structure/loom
	name = "loom"
	desc = ""
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "loom"
	density = TRUE
	anchored = TRUE

/obj/structure/loom/attackby(obj/item/I, mob/user)
	if(weave(I, user))
		return
	return ..()

/obj/structure/loom/wrench_act(mob/living/user, obj/item/I)
	..()
	default_unfasten_wrench(user, I, 5)
	return TRUE

///Handles the weaving.
/obj/structure/loom/proc/weave(obj/item/stack/sheet/cotton/W, mob/user)
	if(!istype(W))
		return FALSE
	if(!anchored)
		user.show_message("<span class='notice'>The loom needs to be wrenched down.</span>", MSG_VISUAL)
		return FALSE
	if(W.amount < FABRIC_PER_SHEET)
		user.show_message("<span class='notice'>I need at least [FABRIC_PER_SHEET] units of fabric before using this.</span>", MSG_VISUAL)
		return FALSE
	user.show_message("<span class='notice'>I start weaving \the [W.name] through the loom..</span>", MSG_VISUAL)
	if(W.use_tool(src, user, W.pull_effort))
		if(W.amount >= FABRIC_PER_SHEET)
			new W.loom_result(drop_location())
			W.use(FABRIC_PER_SHEET)
			user.show_message("<span class='notice'>I weave \the [W.name] into a workable fabric.</span>", MSG_VISUAL)
	return TRUE

#undef FABRIC_PER_SHEET
