
/obj/structure/xeno/acid_pool
	name = "acid pool"
	desc = "A pool of weak viscous acid that solidifies quickly when removed from the pool. Swimming is not recommended due to the lack of a lifeguard."
	icon = 'icons/Xeno/3x3building.dmi'
	icon_state = "pool"
	bound_width = 96
	bound_height = 64
	max_integrity = 400

/obj/structure/xeno/acid_pool/Initialize(mapload, _hivenumber)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	update_icon()

/obj/structure/xeno/acid_pool/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "pool_emissive")

/obj/structure/xeno/acid_pool/process()
	for(var/atom/location AS in locs)
		for(var/mob/living/carbon/xenomorph/xeno in location)
			if(xeno.stat == DEAD)
				continue
			if(!xeno.lying_angle)
				continue
			if(GLOB.hive_datums[hivenumber] != xeno.hive)
				continue
			xeno.adjust_sunder(-1)
