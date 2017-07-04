
/datum/light_source
	var/atom/owner
	var/atom/top_atom
	var/changed = 1
	var/list/effects
	var/__x = 0		//x coordinate at last update
	var/__y = 0		//y coordinate at last update

	var/_l_color //do not use directly, only used as reference for updating
	var/col_r
	var/col_g
	var/col_b


/datum/light_source/New(atom/A, atom/top)
	if(!istype(A))
		CRASH("The first argument to the light object's constructor must be the atom that is the light source. Expected atom, received '[A]' instead.")
	..()
	owner = A
	if(!owner.light_sources) owner.light_sources = list()
	owner.light_sources += src // Add ourselves to the light sources of the owner.

	if(top) top_atom = top
	else top_atom = owner
	if(top_atom != owner)
		if(!top_atom.light_sources) top_atom.light_sources = list()
		top_atom.light_sources += src // Add ourselves to the light sources of our new top atom.

	readrgb(owner.l_color)
	__x = top_atom.x
	__y = top_atom.y
	changed = 1
	// the lighting object maintains a list of all light sources
	lighting_controller.changed_lights.Add(src)


/datum/light_source/Dispose()
	if (top_atom)
		if(top_atom.light_sources)
			top_atom.light_sources -= src
			if(!top_atom.light_sources.len) top_atom.light_sources = null
		top_atom = null
	if(owner)
		if(owner.light_sources)
			owner.light_sources -= src
			if(!owner.light_sources.len) owner.light_sources = null
		if(owner.light == src)
			remove_effect()
			owner.light = null
			owner = null
	if(changed)
		lighting_controller.changed_lights.Remove(src)
	return ..()

//Check a light to see if its effect needs reprocessing. If it does, remove any old effect and create a new one
/datum/light_source/proc/check()
	if(!owner)
		remove_effect()
		return 0

	if (owner.l_color != _l_color)
		readrgb(owner.l_color)
		changed = 1

	if(changed)
		changed = 0
		remove_effect()
		return add_effect()
	return 0

/datum/light_source/proc/changed(atom/new_top_atom)

	// This top atom is different.
	if (new_top_atom && new_top_atom != top_atom)
		if(top_atom != owner && top_atom.light_sources) // Remove ourselves from the light sources of that top atom.
			if(top_atom.light_sources)
				top_atom.light_sources -= src
				if(!top_atom.light_sources.len)
					top_atom.light_sources = null

		top_atom = new_top_atom

		if(top_atom != owner)
			if(!top_atom.light_sources) top_atom.light_sources = list()
			top_atom.light_sources += src // Add ourselves to the light sources of our new top atom.

	__x = top_atom.x
	__y = top_atom.y

	if(!changed)
		changed = 1
		lighting_controller.changed_lights.Add(src)




/datum/light_source/proc/remove_effect()
	// before we apply the effect we remove the light's current effect.
	for(var/X in effects)	// negate the effect of this light source
		var/turf/T = X
		if(T.affecting_lights && T.affecting_lights.len)
			T.affecting_lights -= src
		T.update_lumcount(-effects[T], col_r, col_g, col_b, 1)

	effects = null

/datum/light_source/proc/add_effect()
	// only do this if the light is turned on and is on the map
	if(owner && owner.loc && owner.luminosity > 0)
		readrgb(owner.l_color)
		effects = list()
		var/turf/To = get_turf(owner)
		var/range = owner.get_light_range()
		for(var/turf/T in view(range,To))
			var/delta_lumen = get_lum(T)
			if(delta_lumen > 0)
				effects[T] = delta_lumen
				if(!T.affecting_lights)
					T.affecting_lights = list()
				T.affecting_lights |= src
				T.update_lumcount(delta_lumen, col_r, col_g, col_b, 0)
		return 0
	else
		owner.light = null
		return 1	//cause the light to be removed from the lights list and garbage collected once it's no
					//longer referenced by the queue

/datum/light_source/proc/get_lum(turf/A)
	if (!owner.luminosity)
		return 0
	var/dist
	if(!A)
		dist = 0
	else
#ifdef LIGHTING_CIRCULAR
		dist = cheap_hypotenuse(A.x, A.y, __x, __y)
#else
		dist = max(abs(A.x - __x), abs(A.y - __y))
#endif
	return LIGHTING_CAP * (owner.luminosity - dist) / owner.luminosity

/datum/light_source/proc/readrgb(col)
	_l_color = col
	if(col)
		col_r = GetRedPart(col)
		col_g = GetGreenPart(col)
		col_b = GetBluePart(col)
	else
		col_r = 0
		col_g = 0
		col_b = 0