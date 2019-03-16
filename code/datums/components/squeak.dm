/datum/component/squeak
	var/squeak_sound
	var/squeak_chance = 100
	var/volume = 30

	// This is so shoes don't squeak every step
	var/steps = 0
	var/step_delay = 1

	// This is to stop squeak spam from inhand usage
	var/last_use = 0
	var/use_delay = 20


/datum/component/squeak/Initialize(squeak_sound, volume_override, chance_override, step_delay_override, use_delay_override)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, list(COMSIG_ATOM_ENTERED, COMSIG_PARENT_ATTACKBY), .proc/play_squeak)
	if(ismovableatom(parent))
		RegisterSignal(parent, list(COMSIG_MOVABLE_BUMP, COMSIG_MOVABLE_IMPACT), .proc/play_squeak)
		RegisterSignal(parent, COMSIG_MOVABLE_CROSSED, .proc/play_squeak_crossed)
		if(isitem(parent))
			RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/play_squeak)
			RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/use_squeak)
			RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
			RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)
			if(istype(parent, /obj/item/clothing/shoes))
				RegisterSignal(parent, COMSIG_SHOES_STEP_ACTION, .proc/step_squeak)

	if(islist(squeak_sound))
		squeak_sound = pick(squeak_sound)
	if(chance_override)
		squeak_chance = chance_override
	if(volume_override)
		volume = volume_override
	if(isnum(step_delay_override))
		step_delay = step_delay_override
	if(isnum(use_delay_override))
		use_delay = use_delay_override


/datum/component/squeak/proc/play_squeak()
	if(prob(squeak_chance))
		if(!squeak_sound)
			CRASH("Squeak component attempted to play invalid sound.")
		else
			playsound(parent, squeak_sound, volume, 1, -1)


/datum/component/squeak/proc/step_squeak()
	if(steps > step_delay)
		play_squeak()
		steps = 0
	else
		steps++


/datum/component/squeak/proc/play_squeak_crossed(atom/movable/AM)
	if(isitem(AM))
		var/obj/item/I = AM
		if(I.flags_item & ITEM_ABSTRACT)
			return
		else if(istype(AM, /obj/item/projectile))
			var/obj/item/projectile/P = AM
			if(P.original != parent)
				return

	var/atom/current_parent = parent
	if(isturf(current_parent.loc))
		play_squeak()


/datum/component/squeak/proc/use_squeak()
	if(last_use + use_delay < world.time)
		last_use = world.time
		play_squeak()


/datum/component/squeak/proc/on_equip(datum/source, mob/equipper, slot)
	return


/datum/component/squeak/proc/on_drop(datum/source, mob/user)
	return


/datum/component/squeak/proc/holder_dir_change(datum/source, old_dir, new_dir)
	//If the dir changes it means we're going through a bend in the pipes, let's pretend we bumped the wall
	if(old_dir != new_dir)
		play_squeak()