///A component that lets you turn your character transparent in order to see and click through yourself.
/datum/component/seethrough_mob
	///The atom that enables our dark magic
	var/atom/movable/render_source_atom
	///The fake version of ourselves
	var/image/trickery_image
	///Which alpha do we animate towards?
	var/target_alpha
	///How long our faze in/out takes
	var/animation_time
	///Does this object let clicks from players its transparent to pass through it
	var/clickthrough
	///Is the seethrough effect currently active
	var/is_active
	///The mob's original render_target value
	var/initial_render_target_value
	///This component's personal uid
	var/personal_uid
	///The associated action
	var/datum/action/toggle_seethrough/action

/datum/component/seethrough_mob/Initialize(target_alpha = 170, animation_time = 0.5 SECONDS, clickthrough = TRUE)
	. = ..()

	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	src.target_alpha = target_alpha
	src.animation_time = animation_time
	src.clickthrough = clickthrough
	src.is_active = FALSE
	src.render_source_atom = new()

	var/static/uid = 0
	uid++
	src.personal_uid = uid

	render_source_atom.appearance_flags |= (KEEP_APART|RESET_ALPHA)

	render_source_atom.vis_flags |= (VIS_INHERIT_ID|VIS_INHERIT_PLANE|VIS_INHERIT_LAYER)

	render_source_atom.render_source = "*transparent_bigmob[personal_uid]"

	action = new(src)
	action.give_action(parent)

/datum/component/seethrough_mob/Destroy(force)
	QDEL_NULL(render_source_atom)
	QDEL_NULL(action)
	return ..()

///Set up everything we need to trick the client and keep it looking normal for everyone else
/datum/component/seethrough_mob/proc/trick_mob()
	SIGNAL_HANDLER

	var/mob/fool = parent
	var/datum/hud/our_hud = fool.hud_used
	for(var/atom/movable/screen/plane_master/seethrough as anything in our_hud.get_true_plane_masters(SEETHROUGH_PLANE))
		seethrough.unhide_plane(fool)

	render_source_atom.name = "seethrough" //So our name is not just "movable" when looking at VVs

	initial_render_target_value = fool.render_target
	fool.render_target = "*transparent_bigmob[personal_uid]"
	fool.vis_contents.Add(render_source_atom)

	trickery_image = new(render_source_atom)
	trickery_image.loc = render_source_atom
	trickery_image.override = TRUE

	trickery_image.pixel_x = 0
	trickery_image.pixel_y = 0

	if(clickthrough)
		//Special plane so we can click through the overlay
		SET_PLANE_EXPLICIT(trickery_image, SEETHROUGH_PLANE, fool)

	fool.client.images += trickery_image

	animate(trickery_image, alpha = target_alpha, time = animation_time)

	RegisterSignal(fool, COMSIG_MOB_LOGOUT, PROC_REF(on_client_disconnect))

///Remove the screen object and make us appear solid to ourselves again
/datum/component/seethrough_mob/proc/untrick_mob()
	var/mob/fool = parent
	animate(trickery_image, alpha = 255, time = animation_time)
	UnregisterSignal(fool, COMSIG_MOB_LOGOUT)

	//after playing the fade-in animation, remove the image and the trick atom
	addtimer(CALLBACK(src, PROC_REF(clear_image), trickery_image, fool.client), animation_time)

///Remove the image and the trick atom
/datum/component/seethrough_mob/proc/clear_image(image/removee, client/remove_from)
	var/atom/movable/atom_parent = parent
	atom_parent.vis_contents -= render_source_atom
	atom_parent.render_target = initial_render_target_value
	remove_from?.images -= removee
	remove_from?.mob.update_appearance(UPDATE_ICON)

///Effect is disabled when they log out because client gets deleted
/datum/component/seethrough_mob/proc/on_client_disconnect(datum/source)
	SIGNAL_HANDLER

	untrick_mob()
	action.set_toggle(FALSE)
	var/mob/fool = parent
	var/datum/hud/our_hud = fool.hud_used
	for(var/atom/movable/screen/plane_master/seethrough as anything in our_hud.get_true_plane_masters(SEETHROUGH_PLANE))
		seethrough.hide_plane(fool)
	is_active = FALSE

/datum/component/seethrough_mob/proc/toggle_active()
	is_active = !is_active
	if(is_active)
		trick_mob()
		action.set_toggle(TRUE)
	else
		untrick_mob()
		action.set_toggle(FALSE)

/datum/action/toggle_seethrough
	name = "Toggle Seethrough"
	desc = "Allows you to see behind your massive body and click through it."
	action_icon = 'icons/Xeno/actions/general.dmi'
	action_icon_state = "xenohide"
	action_type = ACTION_TOGGLE
	/// Spam prevention as mashing the ability breaks a lot of things
	COOLDOWN_DECLARE(toggle_cooldown)

/datum/action/toggle_seethrough/action_activate(atom/t)
	if(!COOLDOWN_FINISHED(src, toggle_cooldown))
		return
	. = ..()
	var/datum/component/seethrough_mob/transparency = target
	transparency.toggle_active()
	COOLDOWN_START(src, toggle_cooldown, 1 SECONDS)

/datum/action/toggle_seethrough/Destroy()
	var/datum/component/seethrough_mob/transparency = target
	if(transparency.is_active)
		transparency.untrick_mob()
	return ..()
