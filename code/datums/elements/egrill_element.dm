/datum/element/egrill
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/egrill/Attach(datum/target)
	if(!isobj(target))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	RegisterSignal(target, COMSIG_ATOM_BUMPED, PROC_REF(bumped))
	RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND, PROC_REF(attack_hand))
	RegisterSignal(target, COMSIG_ATOM_ATTACKBY, PROC_REF(attackby))
	RegisterSignal(target, COMSIG_OBJ_ATTACK_ALIEN, PROC_REF(attack_alien))
	START_PROCESSING(SSegrill, target)

/datum/element/egrill/Detach(datum/source, force)
	UnregisterSignal(source, list(
		COMSIG_ATOM_BUMPED,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACKBY,
		COMSIG_OBJ_ATTACK_ALIEN,
	))
	STOP_PROCESSING(SSegrill, source)
	return ..()

/datum/element/egrill/proc/bumped(obj/source, atom/movable/bumped_by)
	SIGNAL_HANDLER
	if(!ismob(bumped_by))
		return
	shock(source, bumped_by)

/datum/element/egrill/proc/attack_hand(obj/source, mob/living/touched_by)
	SIGNAL_HANDLER
	shock(source, touched_by)

/datum/element/egrill/proc/attackby(obj/source, obj/item/attacked_by, mob/attacker, params)
	SIGNAL_HANDLER
	if(!iswirecutter(attacked_by) && !isscrewdriver(attacked_by) && !(attacked_by.atom_flags & CONDUCT))
		return
	if(shock(source, attacker))
		return COMPONENT_NO_AFTERATTACK

/datum/element/egrill/proc/attack_alien(obj/source, mob/living/carbon/xenomorph/attacker, damage_amount)
	SIGNAL_HANDLER
	if(attacker.status_flags & INCORPOREAL)
		return FALSE
	shock(source, attacker)

/datum/element/egrill/proc/shock(obj/source, mob/living/user)
	if(!source.anchored || source.obj_integrity <= source.integrity_failure)		// anchored/destroyed grilles are never connected
		return FALSE
	if(!in_range(source, user))//To prevent TK and mech users from getting shocked
		return FALSE
	var/turf/T = get_turf(source)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		var/datum/powernet/PN = C.powernet
		if(PN.delayedload >= PN.newavail)
			return FALSE // no power left
		if(electrocute_mob(user, C, source))
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(3, 1, source)
			s.start()
			return TRUE
		else
			return FALSE
	return FALSE
