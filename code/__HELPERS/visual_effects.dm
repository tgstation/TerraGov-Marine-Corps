/// Makes this atom look like a "hologram"
/// So transparent, blue, with a scanline and an emissive glow
/// This is acomplished using a combination of filters and render steps/overlays
/// The degree of the opacity is optional, based off the opacity arg (0 -> 1)
/atom/proc/makeHologram(opacity = 0.5, modify_color_transparency = TRUE)
	// First, we'll make things blue (roughly) and sorta transparent
	if(modify_color_transparency)
		add_filter("HOLO: Color and Transparent", 1, color_matrix_filter(rgb(125,180,225, opacity * 255)))
	// Now we're gonna do a scanline effect
	// Gonna take this atom and give it a render target, then use it as a source for a filter
	// (We use an atom because it seems as if setting render_target on an MA is just invalid. I hate this engine)
	var/atom/movable/scanline = new(null)
	scanline.icon = 'icons/effects/effects.dmi'
	scanline.icon_state = "scanline"
	scanline.appearance_flags |= RESET_TRANSFORM
	// * so it doesn't render
	var/static/uid_scan = 0
	scanline.render_target = "*HoloScanline [uid_scan]"
	uid_scan++
	// Now we add it as a filter, and overlay the appearance so the render source is always around
	add_filter("HOLO: Scanline", 2, alpha_mask_filter(render_source = scanline.render_target))
	add_overlay(scanline)
	qdel(scanline)
	// Annd let's make the sucker emissive, so it glows in the dark
	if(!render_target)
		var/static/uid = 0
		render_target = "HOLOGRAM [uid]"
		uid++
	// I'm using static here to reduce the overhead, it does mean we need to do plane stuff manually tho
	var/static/atom/movable/render_step/emissive/glow
	if(!glow)
		glow = new(null)
	glow.render_source = render_target
	SET_PLANE_EXPLICIT(glow, initial(glow.plane), src)
	// We're creating a render step that copies ourselves, and draws it to the emissive plane
	// Then we overlay it, and release "ownership" back to this proc, since we get to keep the appearance it generates
	// We can't just use an MA from the start cause render_source setting starts going fuckey REALLY quick
	var/mutable_appearance/glow_appearance = new(glow)
	add_overlay(glow_appearance)
	LAZYADD(update_overlays_on_z, glow_appearance)
