/*
	Modified DynamicAreaLighting for TGstation - Coded by Carnwennan

	This is TG's 'new' lighting system. It's basically a heavily modified combination of Forum_Account's and
	ShadowDarke's respective lighting libraries. Credits, where due, to them.

	Like sd_DAL (what we used to use), it changes the shading overlays of areas by splitting each type of area into sub-areas
	by using the var/tag variable and moving turfs into the contents list of the correct sub-area. This method is
	much less costly than using overlays or objects.

	Unlike sd_DAL however it uses a queueing system. Everytime we call a change to opacity or luminosity
	(through SetOpacity() or SetLuminosity()) we are  simply updating variables and scheduling certain lights/turfs for an
	update. Actual updates are handled periodically by the lighting_controller. This carries additional overheads, however it
	means that each thing is changed only once per lighting_controller.processing_interval ticks. Allowing for greater control
	over how much priority we'd like lighting updates to have. It also makes it possible for us to simply delay updates by
	setting lighting_controller.processing = 0 at say, the start of a large explosion, waiting for it to finish, and then
	turning it back on with lighting_controller.processing = 1.

	Unlike our old system there are hardcoded maximum luminositys (different for certain atoms).
	This is to cap the cost of creating lighting effects.
	(without this, an atom with luminosity of 20 would have to update 41^2 turfs!) :s

	Also, in order for the queueing system to work, each light remembers the effect it casts on each turf. This is going to
	have larger memory requirements than our previous system but it's easily worth the hassle for the greater control we
	gain. It also reduces cost of removing lighting effects by a lot!

	Known Issues/TODO:
		Shuttles still do not have support for dynamic lighting (I hope to fix this at some point)
		No directional lighting support. (prototype looked ugly)
*/



/atom
	var/datum/light_source/light //the light source associated with this atom.
	var/list/light_sources // Any light sources that are "inside" of us, for example, if src here was a mob that's carrying a flashlight, that flashlight's light source would be part of this list.
	var/l_color //the color of the light this atom emits.


// Updates the light.
// Creates or destroys it if needed, makes it update values.
/atom/proc/update_light()
	if(ta_directive) //cdeleted
		return

	if (!luminosity) // We won't emit light anyways, destroy the light source.
		if(light)
			cdel(light)
			light = null
	else
		if(ismob(loc)) // We choose what atom should be the top atom of the light here.
			. = loc
		else
			. = src

		if (light) // Update the light or create it if it does not exist.
			light.changed(.)
		else
			light = new/datum/light_source(src, .)



//Movable atoms with opacity when they are constructed will trigger nearby lights to update
//Movable atoms with luminosity when they are constructed will create a light_source automatically
/atom/movable/New()
	..()
	if(opacity)
		UpdateAffectingLights()
	if(luminosity)
		update_light()

//Objects with opacity will trigger nearby lights to update at next lighting process.
/atom/movable/Dispose()
	if(light)
		cdel(light)
		light = null
	if(opacity)
		UpdateAffectingLights()
	. = ..()



//Sets our luminosity and update the light
/atom/proc/SetLuminosity(new_luminosity)
	if(new_luminosity < 0)
		new_luminosity = 0
	if(luminosity == new_luminosity) return
	luminosity = new_luminosity
	update_light()




//change our opacity (defaults to toggle), and then update all lights that affect us.
/atom/proc/SetOpacity(new_opacity)
	if(new_opacity == null)
		new_opacity = !opacity			//default = toggle opacity
	else if(opacity == new_opacity)
		return 0						//opacity hasn't changed! don't bother doing anything
	opacity = new_opacity				//update opacity, the below procs now call light updates.
	UpdateAffectingLights()
	return 1




#define LIGHTING_MAX_LUMINOSITY_STATIC	8	//Maximum luminosity to reduce lag.
#define LIGHTING_MAX_LUMINOSITY_MOBILE	5	//Moving objects have a lower max luminosity since these update more often. (lag reduction)
#define LIGHTING_MAX_LUMINOSITY_TURF	1	//turfs have a severely shortened range to protect from inevitable floor-lighttile spam.

//set the changed status of all lights which could have possibly lit this atom.
//We don't need to worry about lights which lit us but moved away, since they will have change status set already
//This proc can cause lots of lights to be updated. :(
/atom/proc/UpdateAffectingLights()

/atom/movable/UpdateAffectingLights()
	if(isturf(loc))
		loc.UpdateAffectingLights()

turf/UpdateAffectingLights()
	if(affecting_lights)
		for(var/X in affecting_lights)
			var/datum/light_source/LS = X
			LS.changed()			//force it to update at next process()


//caps luminosity effects max-range based on what type the light's owner is.
/atom/proc/get_light_range()
	return min(luminosity, LIGHTING_MAX_LUMINOSITY_STATIC)

/atom/movable/get_light_range()
	return min(luminosity, LIGHTING_MAX_LUMINOSITY_MOBILE)

obj/machinery/light/get_light_range()
	return min(luminosity, LIGHTING_MAX_LUMINOSITY_STATIC)

turf/get_light_range()
	return min(luminosity, LIGHTING_MAX_LUMINOSITY_TURF)

#undef LIGHTING_MAX_LUMINOSITY_STATIC
#undef LIGHTING_MAX_LUMINOSITY_MOBILE
#undef LIGHTING_MAX_LUMINOSITY_TURF

