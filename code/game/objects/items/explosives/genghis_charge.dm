/obj/item/explosive/plastique/genghis_charge
	name = "EX-62 Genghis incendiary charge"
	desc = "A specialized device for incineration of bulk organic matter, patented Thermal Memory ensuring that all ignition proceeds safely away from the user. Will not attach to plants due to environmental concerns."
	icon_state = "genghis-charge"

/obj/item/explosive/plastique/genghis_charge/afterattack(atom/target, mob/user, flag)
	if(target.allow_pass_flags & PASS_FIRE)
		return ..()
	if(istype(target, /obj/structure/mineral_door/resin))
		return ..()
	balloon_alert(user, "Insufficient organic matter!")

/obj/item/explosive/plastique/genghis_charge/detonate()
	var/turf/flame_target = get_turf(plant_target)
	if(QDELETED(plant_target))
		playsound(plant_target, 'sound/weapons/ring.ogg', 100, FALSE, 25)
		flame_target.ignite(10, 5)
		qdel(src)
		return
	new /obj/fire/flamer/autospread(flame_target, 9, 62)
	playsound(plant_target, SFX_EXPLOSION_SMALL, 100, FALSE, 25)
	qdel(src)

/obj/fire/flamer/autospread
	///Which directions this patch is capable of spreading to, as bitflags
	var/possible_directions = NONE

/obj/fire/flamer/autospread/Initialize(mapload, fire_lvl, burn_lvl, f_color, fire_stacks = 0, fire_damage = 0, inherited_directions = NONE)
	. = ..()

	for(var/direction in GLOB.cardinals)
		if(inherited_directions && !(inherited_directions & direction))
			continue
		var/turf/turf_to_check = get_step(src, direction)
		if(turf_contains_valid_burnable(turf_to_check))
			possible_directions |= direction
			addtimer(CALLBACK(src, PROC_REF(spread_flames), direction, turf_to_check), rand(2, 7))

///Returns TRUE if the supplied turf has something we can ignite on, either a resin wall or door
/obj/fire/flamer/autospread/proc/turf_contains_valid_burnable(turf/turf_to_check)
	if(turf_to_check.allow_pass_flags & PASS_FIRE)
		return TRUE
	if(locate(/obj/structure/mineral_door/resin) in turf_to_check)
		return TRUE
	return FALSE

///Ignites an adjacent turf or adds our possible directions to an existing flame
/obj/fire/flamer/autospread/proc/spread_flames(direction, turf/turf_to_burn)
	var/spread_directions = possible_directions & ~REVERSE_DIR(direction) //Make sure we can't go backwards
	var/old_flame = locate(/obj/fire/flamer) in turf_to_burn
	if(istype(old_flame, /obj/fire/flamer/autospread))
		var/obj/fire/flamer/autospread/old_spreader = old_flame
		spread_directions |= old_spreader.possible_directions
	if(old_flame)
		qdel(old_flame)
	new /obj/fire/flamer/autospread(turf_to_burn, 9, 62, flame_color, 0, 0, spread_directions)
