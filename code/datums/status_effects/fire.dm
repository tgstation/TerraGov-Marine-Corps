#define FIRE_STACK_DECAY 1
#define DAMPNESS_STACK_DECAY -1

/datum/status_effect/stacking/fire
	id = "fire"
	tick_interval = 2 SECONDS
	stack_decay = DAMPNESS_STACK_DECAY
	consumed_on_threshold = FALSE
	consumed_on_fadeout = FALSE //TODO: change this to only fade out on exactly 0
	/// Owner of the debuff is limited to carbons.
	var/mob/living/carbon/debuff_owner
	/// Used for the fire effect.
	//var/obj/vis_melt_fire/visual_fire //need to sort this out to work with xenos etc
	///Are they actually burning
	var/is_ignited = FALSE
/*
/obj/vis_melt_fire
	name = "ouch ouch ouch"
	icon = 'icons/mob/OnFire.dmi'
	layer = ABOVE_MOB_LAYER
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_ID | VIS_INHERIT_PLANE
*/

/datum/status_effect/stacking/fire/on_creation(mob/living/new_owner, stacks_to_apply, ignite_on_start = TRUE)
	if(stacks_to_apply > 0 && (!new_owner.can_ignite()))
		qdel(src)
		return
	. = ..()
	//visual_fire = new
	//visual_fire.icon_state = "melting_low_stacks"
	debuff_owner = new_owner
	if(ignite_on_start)
		do_ignite()

/datum/status_effect/stacking/fire/can_have_status()
	return TRUE

/datum/status_effect/stacking/fire/can_gain_stacks()
	return TRUE

/// on remove has owner set to null
/datum/status_effect/stacking/fire/on_remove()
	//owner.vis_contents -= visual_fire
	//QDEL_NULL(visual_fire)
	. = ..()
	debuff_owner.update_fire()
	debuff_owner = null

/datum/status_effect/stacking/fire/stack_decay_effect()
	//if(is_ignited && debuff_owner)
	//	debuff_owner.update_fire() //todo: make update_fire() only actually change shit if required

/datum/status_effect/stacking/fire/add_stacks(stacks_added)
	. = ..()
	if(stacks == 0)
		qdel(src)
		return

	if(stacks > 0)
		stack_decay = FIRE_STACK_DECAY
	else
		douse_fire()

	if(is_ignited && debuff_owner)
		debuff_owner.update_fire()

/datum/status_effect/stacking/fire/fadeout_effect()
	debuff_owner.adjust_bodytemperature(-80, 300)

///Actually sets them on fire
/datum/status_effect/stacking/fire/proc/do_ignite()
	if(is_ignited)
		return
	if(stacks <= 0)
		return //wet
	if(!debuff_owner.can_ignite())
		return
	is_ignited = TRUE
	stack_decay = FIRE_STACK_DECAY
	SEND_SIGNAL(debuff_owner, COMSIG_LIVING_IGNITED, stacks)
	RegisterSignal(debuff_owner, COMSIG_LIVING_DO_RESIST, PROC_REF(call_resist_debuff))

	//debuff_owner.vis_contents += visual_fire
	//debuff_owner.balloon_alert(debuff_owner, "melting fire!")
	//stack_decay_effect()
	debuff_owner.update_fire()

	debuff_owner.throw_alert(id, /atom/movable/screen/alert/fire)

	to_chat(debuff_owner, span_danger("You are on fire! Use Resist to put yourself out!"))
	debuff_owner.visible_message(span_danger("[debuff_owner] bursts into flames!"), isxeno(debuff_owner) ? span_xenodanger("You burst into flames!") : span_userdanger("You burst into flames!"))

///If stacks go into negatives, we turn off the burning
/datum/status_effect/stacking/fire/proc/douse_fire()
	is_ignited = FALSE
	stack_decay = DAMPNESS_STACK_DECAY
	UnregisterSignal(debuff_owner, COMSIG_LIVING_DO_RESIST)
	debuff_owner.update_fire()
	debuff_owner.clear_alert(id)

/// Called when the debuff's owner uses the Resist action for this debuff
/datum/status_effect/stacking/fire/proc/call_resist_debuff()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(resist_debuff)) // grilled cheese sandwich

///Try and remove fire from ourselves
/datum/status_effect/stacking/fire/proc/resist_debuff()
	if(!debuff_owner)
		qdel(src)
		return
	//if(length(debuff_owner.do_actions))
	//	return
	if(ishuman(debuff_owner))
		debuff_owner.spin(30, 1.5)
	debuff_owner.Paralyze(3 SECONDS) //check if you can spam this

	var/turf/T = get_turf(src)
	if(istype(T, /turf/open/floor/plating/ground/snow))
		debuff_owner.visible_message(span_danger("[src] rolls in the snow, putting themselves out!"), \
		span_notice("You extinguish yourself in the snow!"), null, 5)
		debuff_owner.ExtinguishMob()
		return

	var/remove_amount = min(rand(3, 6), stacks)
	debuff_owner.visible_message(span_danger("[src] rolls on the floor, trying to put themselves out!"), \
	span_notice("You stop, drop, and roll!"), null, 5)

	if((stacks - remove_amount) <= 0)
		debuff_owner.visible_message(span_danger("[src] has successfully extinguished themselves!"), \
		span_notice("You extinguish yourself."), null, 5)

	add_stacks(- remove_amount)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Mobs on Fire

/mob/living/proc/IgniteMob()
	if(!can_ignite())
		return FALSE
	var/datum/status_effect/stacking/fire/current_burning = has_burning()
	if(current_burning.is_ignited)
		return FALSE
	if(current_burning.stacks <= 0)
		return FALSE
	current_burning.do_ignite()
	return TRUE

///Checks if the mob can be set on fire
/mob/living/proc/can_ignite()
	if(status_flags & GODMODE)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_NON_FLAMMABLE))
		return FALSE
	if(soft_armor?.getRating(FIRE) >= 100)
		return FALSE
	if(!CHECK_BITFIELD(datum_flags, DF_ISPROCESSING))
		return FALSE
	return TRUE

///Effects when set on fire
/mob/living/proc/on_ignite()
	return


///Puts out any fire on the mob
/mob/living/proc/ExtinguishMob()
	remove_status_effect(STATUS_EFFECT_MELTING_FIRE)
	if(!has_status_effect(STATUS_EFFECT_BURNING))
		return
	remove_status_effect(STATUS_EFFECT_BURNING)

///Updates fire visuals
/mob/living/proc/update_fire()
	return

///effects of being on fire
/mob/living/proc/handle_fire(stacks)
	SEND_SIGNAL(src, COMSIG_LIVING_HANDLE_FIRE) //this is only used by a rav mutation

//////////////normal status setter procs

///Adjusting the amount of fire_stacks we have - does not automatically ignite
/mob/living/proc/adjust_fire_stacks(new_stacks)
	if(QDELETED(src))
		return

	if(new_stacks > 0)	//Fire stack increases are affected by armor, end result rounded up.
		if(!can_ignite())
			return
		new_stacks = CEILING(modify_by_armor(new_stacks, FIRE), 1)

	var/datum/status_effect/stacking/fire/current_burning = has_burning()
	if(!current_burning)
		apply_status_effect(STATUS_EFFECT_BURNING, new_stacks, FALSE) //add the effect but don't ignite
		return

	current_burning.add_stacks(new_stacks)


//status procs for firedown

///Returns true if actually on fire
/mob/living/proc/is_on_fire()
	if(has_status_effect(STATUS_EFFECT_MELTING_FIRE))
		return TRUE
	var/datum/status_effect/stacking/fire/current_burning = has_status_effect(STATUS_EFFECT_BURNING)
	if(!current_burning)
		return FALSE
	if(current_burning.is_ignited && current_burning.stacks > 0)
		return TRUE

///Returns if we have the burning status effect - including negative stacks
/mob/living/proc/has_burning()
	return has_status_effect(STATUS_EFFECT_BURNING)

///Returns remaining fire stacks
/mob/living/proc/amount_burning()
	var/datum/status_effect/stacking/fire/current_burning = has_burning()
	return current_burning ? current_burning.stacks : 0

///Applies fire unless existing stacks is higher
/mob/living/proc/ignite(amount)
	if(amount <= 0)
		return //wrong proc
	if(!can_ignite())
		return

	amount = CEILING(modify_by_armor(amount, FIRE), 1)

	var/datum/status_effect/stacking/fire/current_burning = has_burning()
	if(!current_burning)
		return apply_status_effect(STATUS_EFFECT_BURNING, amount)

	if(current_burning.stacks >= amount)
		return current_burning

	current_burning.add_stacks(amount - current_burning.stacks)
	return current_burning

///Used to set fire to a set amount, commonly to remove it
/mob/living/proc/set_burning(amount)
	var/datum/status_effect/stacking/fire/current_burning = has_burning()
	if(amount == 0)
		if(current_burning)
			qdel(current_burning)
		return

	if(amount < 0)
		amount = CEILING(modify_by_armor(amount, FIRE), 1)
		if(current_burning)
			if(current_burning.stacks < 0)
				current_burning.add_stacks(amount - current_burning.stacks)
				return
			qdel(current_burning)
		apply_status_effect(STATUS_EFFECT_BURNING, amount, FALSE)
		return

	if(!can_ignite())
		return current_burning

	if(!current_burning)
		return apply_status_effect(STATUS_EFFECT_BURNING, amount)

	current_burning.add_stacks(amount - current_burning.stacks)
	return current_burning

///Applies fire or adds to existing duration
/mob/living/proc/adjust_burning(amount)
	if(amount > 0)
		if(!can_ignite())
			return
		amount = CEILING(modify_by_armor(amount, FIRE), 1)

	var/datum/status_effect/stacking/fire/current_burning = has_burning()
	//logic here to ensure stacks don't go into the negatives
	if(current_burning)
		current_burning.add_stacks(amount)
		current_burning.do_ignite()
	else
		current_burning = apply_status_effect(STATUS_EFFECT_BURNING, amount, amount > 0)

	return current_burning
