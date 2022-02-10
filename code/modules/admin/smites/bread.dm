#define BREADIFY_TIME (5 SECONDS)
#define BREAD_PARALYZE_TIME (5 MINUTES)

/// Turns the target into bread
/datum/smite/bread
	name = "Bread"

/datum/smite/bread/effect(client/user, mob/living/target)
	. = ..()
	if(tgui_alert(usr, "Irreversibly transform [target] into a delectable loaf of bread?", "Continue?", list("Yes", "No")) != "Yes")
		return
	var/mutable_appearance/bread_appearance = mutable_appearance('icons/obj/items/food.dmi', "breadtg")
	var/mutable_appearance/transform_scanline = mutable_appearance('icons/effects/effects.dmi', "transform_effect")
	target.transformation_animation(bread_appearance,time = BREADIFY_TIME, transform_overlay=transform_scanline, reset_after=TRUE)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/breadify, target), BREADIFY_TIME)
	addtimer(CALLBACK(target, /mob/living.proc/Paralyze, BREAD_PARALYZE_TIME), BREADIFY_TIME) //necessary to keep the trapped mob from doing actions while inside the bread

/proc/breadify(atom/movable/target)
	var/obj/item/reagent_containers/food/snacks/marinebread/bread = new(get_turf(target))
	target.forceMove(bread)

#undef BREADIFY_TIME
#undef BREAD_PARALYZE_TIME
