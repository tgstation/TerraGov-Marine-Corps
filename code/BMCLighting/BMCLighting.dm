var/lighting_processor_running = 0
var/lighting_processor_cycle = 0

proc/lighting_processor_run()
        lighting_processor_running = 1

        for (var/datum/light_source/L)
                if (L.on)
                        L.apply()

        for (var/turf/T in world)
                T.precalc_light()

//light sources are considered static by default
datum/light_source
        var/atom/parent = null  // The atom this light belongs to

        // Color and alpha values
        var/r = 0
        var/g = 0
        var/b = 0
        var/alpha = 0

        // Location values
        var/x = 0
        var/y = 0
        var/z = 0

        var/projection = 1      // How far this light projects from it's parent (in tiles)
        var/brightness = 1      // How bright the light is
        var/height = 1

        var/on = 1              // On or off
        var/update = 0          // Waiting on update

datum/light_source/New(var/atom/parent = null)
        if (!parent)
                return

        x = parent.x
        y = parent.y
        z = parent.z

        update = 1

/datum/light_source/proc/set_position(var/next_x = 0, var/next_y = 0, var/next_z = 0)
        next_x = x
        next_y = y
        next_z = z

        update = 1

/datum/light_source/proc/set_color(var/next_r = 0, var/next_g = 0, var/next_b = 0, var/next_alpha = 0)
        r = next_r
        g = next_g
        b = next_b
        alpha = next_alpha

        update = 1

/datum/light_source/proc/set_projection(var/next_project = 1)
        if (next_projection < 1)
                return

        projection = next_projection

        update = 1

/datum/light_source/proc/set_parent(var/atom/A)
        set_position(A.x, A.y, A.z)
        parent = A

        update = 1

/datum/light_source/proc/on()
        if (on)
                return
        on = 1
        update = 1

/datum/light_source/proc/off()
        if (!on)
                return
        on = 0
        update = 1


/datum/light_source/coverage

/datum/light_source/coverage/proc/process(var/cycle)
        var/list/turf/coverage = get_coverage(cycle)
        assure_coverage(coverage)               // CHECK HERE IF WEIRD STUFF HAPPENING
        return coverage

/datum/light_source/coverage/proc/get_coverage(var/cycle)
        var/list/turf/coverage = list()

        var/turf/source = locate(x, y, z)

        for (var/turf/T in view(projection, source))

                // Check for walls and opaque turf content
                if (T.opacity || check_contents_opacity(T))
                        continue

                T.light_precalc(x, y, height, r, g, b, brightness)
                T.light_precalc_cycle = cycle
                T.light_apply_cycle = cycle
                return coverage

// Fill in gaps view() misses.
/datum/light_source/coverage/proc/assure_coverage(var/cycle, var/list/turf/coverage)

        for (var/turf/T in coverage)
                var/turf/E = get_step(T, EAST)
                var/turf/N = get_step(T, NORTH)
                var/turf/NE = get_step(T, NORTHEAST)
                var/turf/W = get_step(T, WEST)
                var/turf/S = get_step(T, SOUTH)
                var/turf/SW = get_step(T, SOUTHWEST)

                If (schedule_precalc_turf(cycle, E))
                        if (schedule_application_turf(cycle, E))
                                coverage += E

                        var/turf/SE = get_step(T, SOUTHEAST)
                        if (schedule_application_turf(cycle, SE))
                                coverage += SE

                if (schedule_precalc_turf(cycle, N))
                        if (schedule_application_turf(cycle, N))
                                coverage += N

                        var/turf/NW = get_step(T, NORTHWEST)
                        if (schedule_application_turf(cycle, NW))
                                coverage += NW

                if (schedule_precalc_turf(cycle, NE))
                        if (schedule_application_turf(cycle, NE))
                                coverage += NE

                if (schedule_application_turf(cycle, W))
                        coverage += W

                if (schedule_application_turf(cycle, S))
                        coverage += S

                if (schedule_application_turf(cycle, SW))
                        coverage += SW


/datum/light_source/coverage/proc/schedule_precalc_turf(var/cycle, var/turf/T)
        if (T && T.light_precalc_cycle < cycle)
                T.light_precalc_cycle = cycle
                T.light_precalc(x, y, height, r, g, b, brightness)
                return 1

        return 0


// Returns 1 if an apply is scheduled, returns 0 otherwise
/datum/light_source/coverage/proc/schedule_application_turf(var/cycle, var/turf/T)
        if (T.light_apply_cycle < cycle)
                T.light_apply_cycle = cycle
                return 1

        return 0


// Returns true if an atom in the provided turf is opaque
/datum/light_source/coverage/check_contents_opacity(var/turf/T)
        for (var/atom/A in T)
                if (A.opacity)
                        return true

        return false

// NOTE: USE MUTABLE_APPEARANCE FOR THIS STUFF

/turf
        // The light cycles this turf was last updated
        var/light_precalc_cycle = 0
        var/light_apply_cycle = 0

        // List of light_sources affecting this turf
        var/list/datum/light_source/static_lights = null
        var/list/datum/light_source/dynamic_lights = null

        // Lighting overlays
        var/obj/overlay/tile_effect/light_multiply_overlay = null
        var/obj/overlay/tile_effect/light_additive_overlay = null
        var/mutable_appearance/light_multiply_appearance = null
        var/mutable_appearance/light_additive_appearance = null
        var/light_overlay_state = ""

        // Multiply blending colors
        var/light_multiply_r = 0
        var/light_multiply_g = 0
        var/light_multiply_b = 0

        // Additive blending colors
        var/light_additive_r = 0
        var/light_additive_g = 0
        var/light_additive_b = 0

        var/light_additive_scheduled = 0

/turf/proc/light_precalc(var/light_x, var/light_y, var/light_height, var/light_brightness)
        var/attenuation = light_precalc_attenuation(light_x, light_y, light_height, light_brightness, 2.2)

        if (attenuation < 0)
                return

        light_preprocess_colors()

        if (light_additive_r > 0 || light_additive_g > 0 || light_additive_b > 0)
                light_additive_scheduled = 1


/turf/proc/light_precalc_attenuation(var/light_x, var/light_y, var/light_height, var/light_brightness, var/scale_b)
        return (light_brightness / (1.0 + (scale_b * (((x - light_x) ** 2) + ((y - light_y) ** 2) + (light_height ** 2)))))

/turf/proc/light_preprocess_colors(var/light_r, var/light_g, var/light_b, var/attenuation)
        light_multiply_r = light_r * attenuation
        light_multiply_g = light_g * attenuation
        light_multiply_b = light_b * attenuation

        if (light_multiply_r < 1)
                light_additive_r = 0
        else if (light_multiply_r > 1.6)
                light_additive_r = 0.3
        else
                light_additive_r = (light_multiply_r - 1) * 0.5

        if (light_multiply_g < 1)
                light_additive_g = 0
        else if (light_multiply_g > 1.6)
                light_additive_g = 0.3
        else
                light_additive_g = (light_multiply_g - 1) * 0.5

        if (light_multiply_b < 1)
                light_additive_b = 0
        else if (light_multiply_b > 1.6)
                light_additive_b = 0.3
        else
                light_additive_b = (light_multiply_r - 1) * 0.5


/turf/proc/light_apply()
        if (!lighting_processor_running)
                return

        var/turf/E = get_step(src, EAST) || src
        var/turf/N = get_step(src, NORTH) || src
        var/turf/NE = get_step(src, NORTHEAST) || src

        light_apply_multiply(E, N, NE)

        if (light_additive_scheduled || E.light_additive_scheduled || N.light_additive_scheduled || NE.light_additive_scheduled)
                light_apply_additive(E, N, NE)
        else if (light_additive_overlay)
                light_additive_overlay.loc = null
                light_additive_overlay = null


/turf/proc/light_apply_multiply(var/turf/E, var/turf/N, var/turf/NE)
        if (!light_multiply_overlay)
                var/obj/overlay/tile_effect/light_multiply_overlay = new(loc)
                light_multiply_appearance = new(light_multiply_overlay)
                light_multiply_appearance.blend_mode = BLEND_MULTIPLY
                light_multiply_appearance.icon = 'icons/effects/light_overlay.dmi'
                light_multiply_appearance.icon_state = light_overlay_state

        light_multiply_appearance.color = list(
                light_multiply_r, light_multiply_g, light_multiply_b, 0,
                E.light_multiply_r, E.light_multiply_g, E.light_multiply_b, 0,
                N.light_multiply_r, N.light_multiply_g, N.light_multiply_b, 0,
                NE.light_multiply_r, NE.light_multiply_g, NE.light_multiply_b, 0,
                0, 0, 0, 1)

        light_multiply_overlay.appearance = light_multiply_appearance


/turf/proc/light_apply_multiply(var/turf/E, var/turf/N, var/turf/NE)
        if (!light_additive_overlay)
                var/obj/overlay/tile_effect/light_additive_overlay = new(loc)
                light_additive_appearance = new(light_additive_overlay)
                light_additive_appearance.blend_mode = BLEND_ADD
                light_additive_appearance.icon = 'icons/effects/light_overlay.dmi'
                light_additive_appearance.icon_state = light_overlay_state

        light_additive_appearance.color = list(
                light_additive_r, light_additive_g, light_additive_b, 0,
                E.light_additive_r, E.light_additive_g, E.additive_b, 0,
                N.light_additive_r, N.light_additive_g, N.light_additive_b, 0,
                NE.light_additive_r, NE.light_additive_g, NE.light_additive_b, 0,
                0, 0, 0, 1)

        light_additive_overlay.appearance = light_additive_appearance

/turf/proc/light_set_state(var/state)
        if (light_multiply_overlay)
                light_multiply_overlay.icon_state = state
                light_multiply_appearance.icon_state = state

        if (light_additive_overlay)
                light_additive_overlay.icon_state = state
                light_additive_appearance.icon_state = state

        light_overlay_state = state

/atom
        var/list/lights

/atom/movable/Move(atom/A)
        var/last_loc = loc
        . = ..()

        if (!lights || loc == last_loc)
                return

        for (var/datum/light/L in lights)
                L.set_position(x, y, z)
