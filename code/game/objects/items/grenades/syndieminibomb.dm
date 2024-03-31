/obj/item/grenade/syndieminibomb
	desc = ""
	name = "syndicate minibomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "syndicate"
	item_state = "flashbang"


/obj/item/grenade/syndieminibomb/prime()
	update_mob()
	explosion(src.loc,1,2,4,flame_range = 2)
	qdel(src)

/obj/item/grenade/syndieminibomb/concussion
	name = "HE Grenade"
	desc = ""
	icon_state = "concussion"

/obj/item/grenade/syndieminibomb/concussion/prime()
	update_mob()
	explosion(src.loc,0,2,3,flame_range = 3)
	qdel(src)

/obj/item/grenade/syndieminibomb/concussion/frag
	name = "frag grenade"
	desc = ""
	icon_state = "frag"

/obj/item/grenade/gluon
	desc = ""
	name = "gluon frag grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "bluefrag"
	item_state = "flashbang"
	var/freeze_range = 4
	var/rad_damage = 350
	var/stamina_damage = 30

/obj/item/grenade/gluon/prime()
	update_mob()
	playsound(loc, 'sound/blank.ogg', 50, TRUE)
	radiation_pulse(src, rad_damage)
	for(var/turf/T in view(freeze_range,loc))
		if(isfloorturf(T))
			var/turf/open/floor/F = T
			F.MakeSlippery(TURF_WET_PERMAFROST, 6 MINUTES)
			for(var/mob/living/carbon/L in T)
				L.adjustStaminaLoss(stamina_damage)
				L.adjust_bodytemperature(-230)
	qdel(src)
