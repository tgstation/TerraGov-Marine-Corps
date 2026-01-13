/obj/item/weapon/twohanded/fireaxe/som
	name = "boarding axe"
	desc = "A SOM boarding axe, effective at breaching doors as well as skulls. When wielded it can be used to block as well as attack."
	icon = 'icons/obj/items/weapons/64x64.dmi'
	icon_state = "som_axe"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/weapon64_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/weapon64_right.dmi',
	)
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	worn_icon_state = "som_axe"
	force = 40
	force_activated = 80
	penetration = 35
	equip_slot_flags = ITEM_SLOT_BACK
	attack_speed = 15
	///Special attack action granted to users with the right trait
	var/datum/action/ability/activable/weapon_skill/axe_sweep/special_attack

/obj/item/weapon/twohanded/fireaxe/som/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shield, SHIELD_TOGGLE|SHIELD_PURE_BLOCKING, list(MELEE = 45, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0))
	AddComponent(/datum/component/stun_mitigation, SHIELD_TOGGLE, shield_cover = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 60, BIO = 60, FIRE = 60, ACID = 60))
	AddElement(/datum/element/strappable)
	special_attack = new(src, force_activated, penetration)

/obj/item/weapon/twohanded/fireaxe/som/Destroy()
	QDEL_NULL(special_attack)
	return ..()

/obj/item/weapon/twohanded/fireaxe/som/wield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_item_bump_attack(user, TRUE)
	if(HAS_TRAIT(user, TRAIT_AXE_EXPERT))
		special_attack.give_action(user)

/obj/item/weapon/twohanded/fireaxe/som/unwield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_item_bump_attack(user, FALSE)
	special_attack?.remove_action(user)

//Special attack
/datum/action/ability/activable/weapon_skill/axe_sweep
	name = "Sweeping blow"
	action_icon_state = "axe_sweep"
	desc = "A powerful sweeping blow that hits foes in the direction you are facing. Cannot stun."
	ability_cost = 10
	cooldown_duration = 6 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_WEAPONABILITY_AXESWEEP,
	)
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/action/ability/activable/weapon_skill/axe_sweep/ai_should_use(atom/target)
	if(get_dist(owner, target) > 2)
		return FALSE
	return ..()

/datum/action/ability/activable/weapon_skill/axe_sweep/use_ability(atom/A)
	succeed_activate()
	add_cooldown()
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.Move(get_step(carbon_owner, angle_to_dir(Get_Angle(carbon_owner, A))), get_dir(carbon_owner, A))
	carbon_owner.face_atom(A)
	activate_particles(owner.dir)
	playsound(owner, 'sound/effects/alien/tail_swipe3.ogg', 50, 0, 5)
	owner.visible_message(span_danger("[owner] Swing their weapon in a deadly arc!"))

	var/list/atom/movable/atoms_to_ravage = get_step(owner, owner.dir).contents.Copy()
	atoms_to_ravage += get_step(owner, turn(owner.dir, -45)).contents
	atoms_to_ravage += get_step(owner, turn(owner.dir, 45)).contents
	for(var/atom/movable/victim AS in atoms_to_ravage)
		if((victim.resistance_flags & INDESTRUCTIBLE))
			continue
		if(!ishuman(victim))
			var/obj/obj_victim = victim
			obj_victim.take_damage(damage, BRUTE, MELEE, TRUE, TRUE, get_dir(obj_victim, carbon_owner), penetration, carbon_owner)
			obj_victim.knockback(owner, 1, 2, knockback_force = MOVE_FORCE_VERY_STRONG)
			continue
		var/mob/living/carbon/human/human_victim = victim
		if(human_victim.lying_angle)
			continue
		human_victim.apply_damage(damage, BRUTE, BODY_ZONE_CHEST, MELEE, TRUE, TRUE, TRUE, penetration, attacker = owner)
		human_victim.knockback(owner, 1, 2, knockback_force = MOVE_FORCE_VERY_STRONG)
		human_victim.adjust_stagger(1 SECONDS)
		playsound(human_victim, "sound/weapons/wristblades_hit.ogg", 25, 0, 5)
		shake_camera(human_victim, 2, 1)

/// Handles the activation and deactivation of particles, as well as their appearance.
/datum/action/ability/activable/weapon_skill/axe_sweep/proc/activate_particles(direction)
	particle_holder = new(get_turf(owner), /particles/ravager_slash)
	QDEL_NULL_IN(src, particle_holder, 5)
	particle_holder.particles.rotation += dir2angle(direction)
	switch(direction) // There's no shared logic here because sprites are magical.
		if(NORTH) // Gotta define stuff for each angle so it looks good.
			particle_holder.particles.position = list(8, 4)
			particle_holder.particles.velocity = list(0, 20)
		if(EAST)
			particle_holder.particles.position = list(3, -8)
			particle_holder.particles.velocity = list(20, 0)
		if(SOUTH)
			particle_holder.particles.position = list(-9, -3)
			particle_holder.particles.velocity = list(0, -20)
		if(WEST)
			particle_holder.particles.position = list(-4, 9)
			particle_holder.particles.velocity = list(-20, 0)
