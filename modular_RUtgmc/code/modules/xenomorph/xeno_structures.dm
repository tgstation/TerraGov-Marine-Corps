/obj/structure/xeno/silo
	icon = 'modular_RUtgmc/icons/Xeno/resin_silo.dmi'

/obj/structure/xeno/acidwell
	icon = 'modular_RUtgmc/icons/Xeno/acid_pool.dmi'

/obj/structure/xeno/pherotower
	icon = 'modular_RUtgmc/icons/Xeno/1x1building.dmi'

/obj/structure/xeno/plant
	icon = 'modular_RUtgmc/icons/Xeno/plants.dmi'

//Sentient facehugger can get in the trap
/obj/structure/xeno/trap/attack_facehugger(mob/living/carbon/xenomorph/facehugger/F, isrightclick = FALSE)
	. = ..()
	if(tgui_alert(F, "Do you want to get into the trap?", "Get inside the trap", list("Yes", "No")) != "Yes")
		return

	if(trap_type)
		F.balloon_alert(F, "The trap is occupied")
		return

	var/obj/item/clothing/mask/facehugger/FH = new(src)
	FH.go_idle(TRUE)
	hugger = FH
	set_trap_type(TRAP_HUGGER)

	F.visible_message(span_xenowarning("[F] slides back into [src]."),span_xenonotice("You slides back into [src]."))
	F.ghostize()
	F.death(deathmessage = "get inside the trap", silent = TRUE)
	qdel(F)

/obj/structure/xeno/tunnel/attack_facehugger(mob/living/carbon/xenomorph/facehugger/F, isrightclick = FALSE)
	attack_alien(F)
