/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/structures/crates.dmi'
	icon_state = "closed_basic"
	icon_opened = "open_basic"
	icon_closed = "closed_basic"
	anchored = FALSE
	mob_storage_capacity = 0
	storage_capacity = 100
	closet_flags = CLOSET_ALLOW_OBJS|CLOSET_ALLOW_DENSE_OBJ
	allow_pass_flags = PASS_LOW_STRUCTURE|PASSABLE|PASS_WALKOVER
	open_sound = 'sound/machines/click.ogg'
	close_sound = 'sound/machines/click.ogg'

/obj/structure/closet/crate/Initialize(mapload, ...)
	. = ..()
	var/static/list/connections = list(
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/closet/crate/can_close()
	. = ..()
	if(!.)
		return
	for(var/mob/living/L in get_turf(src)) //Can't close if someone is standing inside it. This is to prevent "crate traps" (let someone step in, close, open for 30 damage)
		return FALSE
	return TRUE

/obj/structure/closet/crate/open(mob/living/user)
	. = ..()
	if(!.)
		return

	if(climbable)
		INVOKE_ASYNC(src, PROC_REF(structure_shaken))
		climbable = FALSE //Open crate is not a surface that works when climbing around

/obj/structure/closet/crate/close()
	. = ..()
	if(!.)
		return
	climbable = TRUE

/obj/structure/closet/crate/alpha
	name = "alpha squad crate"
	desc = "A crate with alpha squad's symbol on it. "
	icon_state = "closed_alpha"
	icon_opened = "open_alpha"
	icon_closed = "closed_alpha"

/obj/structure/closet/crate/ammo
	name = "ammunitions crate"
	desc = "A ammunitions crate"
	icon_state = "closed_ammo"
	icon_opened = "open_ammo"
	icon_closed = "closed_ammo"

/obj/structure/closet/crate/bravo
	name = "bravo squad crate"
	desc = "A crate with bravo squad's symbol on it. "
	icon_state = "closed_bravo"
	icon_opened = "open_bravo"
	icon_closed = "closed_bravo"

/obj/structure/closet/crate/charlie
	name = "charlie squad crate"
	desc = "A crate with charlie squad's symbol on it. "
	icon_state = "closed_charlie"
	icon_opened = "open_charlie"
	icon_closed = "closed_charlie"

/obj/structure/closet/crate/construction
	name = "construction crate"
	desc = "A construction crate"
	icon_state = "closed_construction"
	icon_opened = "open_construction"
	icon_closed = "closed_construction"

/obj/structure/closet/crate/delta
	name = "delta squad crate"
	desc = "A crate with delta squad's symbol on it. "
	icon_state = "closed_delta"
	icon_opened = "open_delta"
	icon_closed = "closed_delta"

/obj/structure/closet/crate/explosives
	name = "explosives crate"
	desc = "A explosives crate"
	icon_state = "closed_explosives"
	icon_opened = "open_explosives"
	icon_closed = "closed_explosives"

/obj/structure/closet/crate/explosives/whiskeyoutpost/Initialize(mapload)
	. = ..()
	new /obj/item/explosive/grenade/stick(src)
	new /obj/item/explosive/grenade/stick(src)
	new /obj/item/explosive/grenade/stick(src)
	new /obj/item/explosive/grenade/stick(src)
	new /obj/item/explosive/grenade/stick(src)
	new /obj/item/explosive/grenade/stick(src)
	new /obj/item/explosive/grenade/stick(src)
	new /obj/item/explosive/grenade/stick(src)
	new /obj/item/explosive/grenade/stick(src)
	new /obj/item/explosive/grenade/stick(src)
	new /obj/item/explosive/grenade/upp(src)
	new /obj/item/explosive/grenade/upp(src)
	new /obj/item/explosive/grenade/upp(src)
	new /obj/item/explosive/grenade/phosphorus/upp(src)
	new /obj/item/explosive/grenade/phosphorus/upp(src)
	new /obj/item/explosive/grenade/phosphorus/upp(src)
	new /obj/item/explosive/grenade/phosphorus/upp(src)

/obj/structure/closet/crate/explosives/whiskeyoutposttwo/Initialize(mapload)
	. = ..()
	new /obj/structure/closet/crate/explosives(src)
	new /obj/item/storage/box/visual/grenade/razorburn(src)
	new /obj/item/storage/box/visual/grenade/razorburn(src)
	new /obj/item/storage/box/visual/grenade/M15(src)
	new /obj/item/storage/box/visual/grenade/phosphorus(src)
	new /obj/item/explosive/grenade/incendiary/molotov(src)
	new /obj/item/explosive/grenade/incendiary/molotov(src)

/obj/structure/closet/crate/freezer
	name = "freezer crate"
	desc = "A freezer crate."
	icon_state = "closed_freezer"
	icon_opened = "open_freezer"
	icon_closed = "closed_freezer"
	var/target_temp = T0C - 40
	var/cooling_power = 40


/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "closed_hydro"
	icon_opened = "open_hydro"
	icon_closed = "closed_hydro"

/obj/structure/closet/crate/hydroponics/prespawned/Initialize(mapload)
	. = ..()
	new /obj/item/reagent_containers/spray/plantbgone(src)
	new /obj/item/reagent_containers/spray/plantbgone(src)
	new /obj/item/tool/minihoe(src)

/obj/structure/closet/crate/internals
	name = "internals crate"
	desc = "A internals crate."
	icon_state = "closed_oxygen"
	icon_opened = "open_oxygen"
	icon_closed = "closed_oxygen"

/obj/structure/closet/crate/medical
	name = "medical crate"
	desc = "A medical crate."
	icon_state = "closed_medical"
	icon_opened = "open_medical"
	icon_closed = "closed_medical"

/obj/structure/closet/crate/plastic
	name = "plastic crate"
	desc = "A rectangular plastic crate."
	icon_state = "closed_plastic"
	icon_opened = "open_plastic"
	icon_closed = "closed_plastic"


/obj/structure/closet/crate/rcd
	name = "RCD crate"
	desc = "A crate for the storage of the RCD."

/obj/structure/closet/crate/rcd/Initialize(mapload)
	. = ..()
	new /obj/item/ammo_rcd(src)
	new /obj/item/ammo_rcd(src)
	new /obj/item/ammo_rcd(src)
	new /obj/item/tool/rcd(src)

/obj/structure/closet/crate/solar
	name = "Solar Pack crate"


/obj/structure/closet/crate/freezer/rations //Fpr use in the escape shuttle
	desc = "A crate of emergency rations."
	name = "Emergency Rations"

/obj/structure/closet/crate/freezer/rations/Initialize(mapload)
	. = ..()
	new /obj/item/storage/box/donkpockets(src)
	new /obj/item/storage/box/donkpockets(src)

/obj/structure/closet/crate/radiation
	name = "radioactive gear crate"
	desc = "A crate with a radiation sign on it."
	icon_state = "closed_radioactive"
	icon_opened = "open_radioactive"
	icon_closed = "closed_radioactive"

/obj/structure/closet/crate/radiation/Initialize(mapload)
	. = ..()
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)

/obj/structure/closet/crate/science
	name = "science crate"
	desc = "A science crate."
	icon_state = "closed_science"
	icon_opened = "open_science"
	icon_closed = "closed_science"

/obj/structure/closet/crate/supply
	name = "supply crate"
	desc = "A supply crate."
	icon_state = "closed_supply"
	icon_opened = "open_supply"
	icon_closed = "closed_supply"

/obj/structure/closet/crate/trashcart
	name = "Trash Cart"
	desc = "A heavy, metal trashcart with wheels."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "closed_trashcart"
	icon_opened = "open_trashcart"
	icon_closed = "closed_trashcart"

/obj/structure/closet/crate/wayland
	name = "Wayland crate"
	desc = "A crate with a Wayland insignia on it."
	icon_state = "closed_wayland"
	icon_opened = "open_wayland"
	icon_closed = "closed_wayland"

/obj/structure/closet/crate/weapon
	name = "weapons crate"
	desc = "A weapons crate."
	icon_state = "closed_weapons"
	icon_opened = "open_weapons"
	icon_closed = "closed_weapons"



/obj/structure/closet/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "Mining car (not for rails)"
	icon_state = "closed_mcart"
	density = TRUE
	icon_opened = "open_mcart"
	icon_closed = "closed_mcart"

/obj/structure/closet/crate/miningcar/stripe
	icon_state = "closed_mcart_y"
	icon_opened = "open_mcart_y"
	icon_closed = "closed_mcart_y"

/obj/structure/closet/crate/mass_produced_crate
	name = "Mass Produced Crate"
	desc = "A rectangular steel crate. Cannot be welded for metal."
	icon = 'icons/obj/structures/crates.dmi'
	icon_state = "closed_basic"
	icon_opened = "open_basic"
	icon_closed = "closed_basic"
	max_integrity = 5 //hopefully makes it so req crate spam can easily be destroyed
	drop_material = null


/obj/structure/closet/crate/mass_produced_crate/alpha
	name = "Mass Produced Alpha Squad Crate"
	desc = "A crate with alpha squad's symbol on it. Cannot be welded for metal. "
	icon_state = "closed_alpha"
	icon_opened = "open_alpha"
	icon_closed = "closed_alpha"

/obj/structure/closet/crate/mass_produced_crate/ammo
	name = "Mass Produced Ammunitions Crate"
	desc = "A ammunitions crate. Cannot be welded for metal."
	icon_state = "closed_ammo"
	icon_opened = "open_ammo"
	icon_closed = "closed_ammo"

/obj/structure/closet/crate/mass_produced_crate/bravo
	name = "Mass Produced Bravo Squad Crate"
	desc = "A crate with bravo squad's symbol on it. Cannot be welded for metal."
	icon_state = "closed_bravo"
	icon_opened = "open_bravo"
	icon_closed = "closed_bravo"

/obj/structure/closet/crate/mass_produced_crate/charlie
	name = "Mass Produced Charlie Squad Crate"
	desc = "A crate with charlie squad's symbol on it. Cannot be welded for metal."
	icon_state = "closed_charlie"
	icon_opened = "open_charlie"
	icon_closed = "closed_charlie"

/obj/structure/closet/crate/mass_produced_crate/construction
	name = "Mass Produced Construction Crate"
	desc = "A construction crate. Cannot be welded for metal."
	icon_state = "closed_construction"
	icon_opened = "open_construction"
	icon_closed = "closed_construction"

/obj/structure/closet/crate/mass_produced_crate/delta
	name = "Mass Produced Delta Squad Crate"
	desc = "A crate with delta squad's symbol on it. Cannot be welded for metal. "
	icon_state = "closed_delta"
	icon_opened = "open_delta"
	icon_closed = "closed_delta"

/obj/structure/closet/crate/mass_produced_crate/explosives
	name = "Mass Produced Explosives Crate"
	desc = "A explosives crate. Cannot be welded for metal."
	icon_state = "closed_explosives"
	icon_opened = "open_explosives"
	icon_closed = "closed_explosives"

/obj/structure/closet/crate/mass_produced_crate/medical
	name = "Mass Produced Medical Crate"
	desc = "A medical crate. Cannot be welded for metal."
	icon_state = "closed_medical"
	icon_opened = "open_medical"
	icon_closed = "closed_medical"

/obj/structure/closet/crate/mass_produced_crate/supply
	name = "Mass Produced Supply Crate"
	desc = "A supply crate. Cannot be welded for metal."
	icon_state = "closed_supply"
	icon_opened = "open_supply"
	icon_closed = "closed_supply"

/obj/structure/closet/crate/mass_produced_crate/weapon
	name = "Mass Produced Weapons Crate"
	desc = "A weapons crate. Cannot be welded for metal."
	icon_state = "closed_weapons"
	icon_opened = "open_weapons"
	icon_closed = "closed_weapons"
