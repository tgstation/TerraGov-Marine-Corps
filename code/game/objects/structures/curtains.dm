#define XENO_CURTAIN_PULL_DELAY 5 SECONDS

/obj/structure/curtain
	icon = 'icons/obj/structures/curtain.dmi'
	name = "curtain"
	icon_state = "medicalcurtain"
	///used to reset curtain back to default state when closing
	var/initial_icon_state = "medicalcurtain"
	layer = ABOVE_MOB_LAYER
	opacity = TRUE
	density = FALSE

/obj/structure/curtain/open
	icon_state = "medicalcurtain_open"
	layer = OBJ_LAYER
	opacity = FALSE


/obj/structure/curtain/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	playsound(get_turf(loc), "rustle", 15, 1, 6)
	toggle()

/obj/structure/curtain/attack_alien(mob/living/carbon/xenomorph/attackingxeno, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(!do_after(attackingxeno, XENO_CURTAIN_PULL_DELAY, NONE, src, BUSY_ICON_FRIENDLY))
		return
	attackingxeno.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	attackingxeno.visible_message(span_danger("\The [attackingxeno] pulls [src] down and slices it apart!"), \
	span_danger("You pull the [src] down and rip it to shreds!"), null, 5)
	qdel(src)

/obj/structure/curtain/proc/toggle()
	opacity = !opacity
	if(opacity)
		icon_state = initial_icon_state
		layer = ABOVE_MOB_LAYER
	else
		icon_state += "_open"
		layer = OBJ_LAYER

/obj/structure/curtain/shower
	name = "shower curtain"
	color = "#ACD1E9"
	alpha = 200

/obj/structure/curtain/black
	name = "black curtain"
	color = "#222222"

/obj/structure/curtain/medical
	name = "plastic curtain"
	color = "#B8F5E3"
	alpha = 200

/obj/structure/curtain/temple
	name = "fabric curtain"
	color = "#690000"
	icon_state = "fabric_curtain"
	initial_icon_state = "fabric_curtain"
	alpha = 230

/obj/structure/curtain/open/shower
	name = "shower curtain"
	color = "#ACD1E9"
	alpha = 200

/obj/structure/curtain/open/black
	name = "black curtain"
	color = "#222222"

/obj/structure/curtain/open/temple
	name = "black curtain"
	color = "#690000"
	icon_state = "fabric_curtain_open"
	alpha = 230

/obj/structure/curtain/open/medical
	name = "plastic curtain"
	color = "#B8F5E3"
	alpha = 200

#undef XENO_CURTAIN_PULL_DELAY
