
/particles/debris
	icon = 'icons/effects/particles/generic_particles.dmi'
	width = 500
	height = 500
	count = 10
	spawning = 10
	lifespan = 0.7 SECONDS
	fade = 0.4 SECONDS
	position = generator(GEN_CIRCLE, 3, 3)
	scale = 1
	velocity = list(50, 0)
	friction = generator(GEN_NUM, 0.3, 0.6)
	rotation = generator(GEN_NUM, -20, 20)
	spin = generator(GEN_NUM, -20, 20)
	drift = generator(GEN_CIRCLE, 0, 9, SQUARE_RAND)

/particles/impact_smoke
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke5"
	width = 500
	height = 500
	count = 5
	spawning = 15
	lifespan = 0.7 SECONDS
	fade = 3.3 SECONDS
	grow = 0.065
	drift = generator(GEN_CIRCLE, 8, 8)
	scale = 0.1
	spin = generator(GEN_NUM, -20, 20)
	velocity = list(50, 0)
	friction = generator(GEN_NUM, 0.3, 0.6)

/datum/element/debris
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	///Icon state of debris when impacted by a projectile
	var/debris = null
	///Velocity of debris particles
	var/debris_velocity = -40
	///Amount of debris particles
	var/debris_amount = 8
	///Scale of particle debris
	var/debris_scale = 1

/datum/element/debris/Attach(datum/target, _debris_icon_state, _debris_velocity = -40, _debris_amount = 8, _debris_scale = 1)
	. = ..()
	debris = _debris_icon_state
	debris_velocity = _debris_velocity
	debris_amount = _debris_amount
	debris_scale = _debris_scale
	RegisterSignal(target, COMSIG_ATOM_BULLET_ACT, PROC_REF(register_for_impact), TRUE) //override because the element gets overriden

/datum/element/debris/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_BULLET_ACT)

/datum/element/debris/proc/register_for_impact(datum/source, atom/movable/projectile/proj)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(on_impact), source, proj)

/datum/element/debris/proc/on_impact(datum/source, atom/movable/projectile/P)
	if(!P.ammo.ping)
		return
	var/angle = !isnull(P.dir_angle) ? P.dir_angle : round(Get_Angle(P.starting_turf, source), 1)
	var/x_component = sin(angle) * debris_velocity
	var/y_component = cos(angle) * debris_velocity
	var/x_component_smoke = sin(angle) * -37
	var/y_component_smoke = cos(angle) * -37
	var/obj/effect/abstract/particle_holder/debris_visuals
	var/obj/effect/abstract/particle_holder/smoke_visuals
	var/position_offset = rand(-6,6)
	smoke_visuals = new(source, /particles/impact_smoke)
	smoke_visuals.particles.position = list(position_offset, position_offset)
	smoke_visuals.particles.velocity = list(x_component_smoke, y_component_smoke)
	if(debris && !(P.ammo.ammo_behavior_flags & AMMO_ENERGY || P.ammo.ammo_behavior_flags & AMMO_XENO))
		debris_visuals = new(source, /particles/debris)
		debris_visuals.particles.position = generator(GEN_CIRCLE, position_offset, position_offset)
		debris_visuals.particles.velocity = list(x_component, y_component)
		debris_visuals.layer = ABOVE_OBJ_LAYER + 0.02
		debris_visuals.particles.icon_state = debris
		debris_visuals.particles.count = debris_amount
		debris_visuals.particles.spawning = debris_amount
		debris_visuals.particles.scale = debris_scale
	smoke_visuals.layer = ABOVE_OBJ_LAYER + 0.01
	if(P.ammo.sound_bounce && prob(50))
		var/pitch = 0
		if(P.ammo.ammo_behavior_flags & AMMO_SOUND_PITCH)
			pitch = 55000
		playsound(source, P.ammo.sound_bounce, 50, TRUE, 4, 5, pitch)
	addtimer(CALLBACK(src, PROC_REF(remove_ping), src, smoke_visuals, debris_visuals), 0.7 SECONDS)

/datum/element/debris/proc/remove_ping(hit, obj/effect/abstract/particle_holder/smoke_visuals, obj/effect/abstract/particle_holder/debris_visuals)
	QDEL_NULL(smoke_visuals)
	if(debris_visuals)
		QDEL_NULL(debris_visuals)
