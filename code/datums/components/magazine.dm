#define MAGAZINE_BULLET 1 // ammo datum
#define MAGAZINE_CHARGE 2 // cell-type charge
#define MAGAZINE_AM 3 // atom/movable
#define MAGAZINE_REAGENT 4 // pull from parent's reagent datum

/datum/component/magazine
	var/type_of_object = MAGAZINE_BULLET
	var/datum/ammo_typepath // ammo datum typepath, null, atom/movable typepath, datum/reagent id
	var/current_count // how many things we have
	var/max_count // the max things we can contain

/datum/component/magazine/Initialize(type_of_object, datum/ammo_typepath, current_count, max_count)
	src.type_of_object = type_of_object
	src.ammo_typepath = ammo_typepath
	src.current_count = current_count
	src.max_count = max_count

	RegisterSignal(parent, COMSIG_MAGAZINE_RECEIVER_HIT, .proc/attempt_to_load)

/datum/component/magazine/proc/attempt_to_load(datum/source, mob/user, atom/movable/AM)
	
