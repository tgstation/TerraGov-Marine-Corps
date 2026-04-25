///All in one function to begin interactions
/mob/proc/interaction_emote(mob/target)
	if(!target || target == src)
		return

	var/list/interactions_list = list("Headbutt" = /atom/movable/screen/interaction/headbutt)	//Universal interactions
	if(isxeno(src))	//Benos don't high five each other, they slap tails! A beno cannot initiate a high five, but can recieve one if prompted by a human
		interactions_list["Tail Slap"] = /atom/movable/screen/interaction/fist_bump
	else
		interactions_list["High Five"] = /atom/movable/screen/interaction
		interactions_list["Fist Bump"] = /atom/movable/screen/interaction/fist_bump

	//Change src to target if you are using the interaction testing tool
	var/atom/movable/screen/interaction/interaction = interactions_list[tgui_input_list(src, "Select an interaction type", "Interactive Emotes", interactions_list)]

	if(!interaction)
		return

	if(LAZYLEN(target.queued_interactions))
		for(var/atom/movable/screen/interaction/element AS in target.queued_interactions)
			if(element.initiator == src)
				balloon_alert(src, "slow your roll!")
				return

	interaction = new interaction()
	interaction.owner = target
	interaction.initiator = src
	interaction.register_movement_signals()
	LAZYADD(target.queued_interactions, interaction)

	if(target.client && target.hud_used)
		target.hud_used.update_interactive_emotes()

	interaction.transform = matrix(32, 6, MATRIX_TRANSLATE)
	animate(interaction, transform = matrix(), time = 2.5, easing = CUBIC_EASING)

	interaction.timer_id = addtimer(CALLBACK(interaction, TYPE_PROC_REF(/atom/movable/screen/interaction, end_interaction), FALSE), interaction.timeout, TIMER_STOPPABLE|TIMER_UNIQUE)

//Mob interactions
/atom/movable/screen/interaction
	name = "high five"
	desc = "You gonna leave them hanging?"
	icon = 'icons/mob/screen_alert.dmi'
	icon_state = "drunk2"	//It looks jolly
	///Sound filed played when interaction is successful
	var/interaction_sound = 'sound/effects/snap.ogg'
	///Who this offer for interaction is being made to
	var/mob/owner
	///The mob that initiated the interaction
	var/mob/initiator
	///Clear itself after a certain amount of time
	var/timeout = 10 SECONDS
	///The reference to the existing timer
	var/timer_id

/atom/movable/screen/interaction/Initialize(mapload)
	. = ..()
	desc += "\nLeft-click to accept interaction. Right-click or SHIFT + left-click to decline."

///Separate proc to register signals; not on Initialize because owner and initiator are not set yet
/atom/movable/screen/interaction/proc/register_movement_signals()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(interactees_moved))
	RegisterSignal(initiator, COMSIG_MOVABLE_MOVED, PROC_REF(interactees_moved))

///What to do when either the owner or the initiating mob moves
/atom/movable/screen/interaction/proc/interactees_moved()
	SIGNAL_HANDLER
	if(!owner.Adjacent(initiator))
		end_interaction(FALSE)

///Functions to end the interaction
/atom/movable/screen/interaction/proc/end_interaction(success = TRUE)
	if(!success)
		owner.visible_message(failure_message())
	qdel(src)

//Delete itself from the owner's hud and list of queued interactions
/atom/movable/screen/interaction/Destroy()
	deltimer(timer_id)
	LAZYREMOVE(owner.queued_interactions, src)
	if(owner.client && owner.hud_used)
		owner.client.screen -= src
		owner.hud_used.update_interactive_emotes()

	return ..()

/atom/movable/screen/interaction/RightClick(mob/user)
	. = ..()
	end_interaction(FALSE)

/atom/movable/screen/interaction/ShiftClick(mob/user)
	. = ..()
	end_interaction(FALSE)

/atom/movable/screen/interaction/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(modifiers[SHIFT_CLICK] || modifiers[RIGHT_CLICK])	//These modifiers will deny the interaction
		return ..()

	if(usr != owner || !owner.can_interact(initiator))
		end_interaction(FALSE)
		return FALSE

	//Begin interaction functions
	interaction_animation()

	owner.visible_message(success_message())
	playsound(owner, interaction_sound, 50, TRUE)
	end_interaction()

///Seperate proc meant to be overriden for unique animations
/atom/movable/screen/interaction/proc/interaction_animation()
	owner.face_atom(initiator)
	initiator.face_atom(owner)

	//Calculate the distances between the two mobs
	var/x_distance = owner.x - initiator.x
	var/y_distance = owner.y - initiator.y

	animate(owner, pixel_x = owner.pixel_x - x_distance * 8, pixel_y = owner.pixel_y - y_distance * 8, time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_x = initial(owner.pixel_x), pixel_y = initial(owner.pixel_y), time = 0.1 SECONDS)
	animate(initiator, pixel_x = initiator.pixel_x + x_distance * 8, pixel_y = initiator.pixel_y + y_distance * 8, time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_x = initial(initiator.pixel_x), pixel_y = initial(initiator.pixel_y), time = 0.1 SECONDS)

///Returns a string for successful interactions
/atom/movable/screen/interaction/proc/success_message()
	return "[owner] high fives [initiator]!"

///Returns a string for unsuccessful interactions
/atom/movable/screen/interaction/proc/failure_message()
	return "[owner] left [initiator] hanging in the air..."

//Following 2 procs are for tooltip functionality; taken from action buttons
/atom/movable/screen/interaction/MouseEntered(location, control, params)
	if(!usr.client?.prefs?.tooltips)
		return
	openToolTip(usr, src, params, title = name, content = desc)

/atom/movable/screen/interaction/MouseExited()
	if(!usr.client?.prefs?.tooltips)
		return
	closeToolTip(usr)

/atom/movable/screen/interaction/fist_bump
	name = "fist bump"
	desc = "Bro."
	interaction_sound = 'sound/weapons/throwtap.ogg'

//Benos turn around and slap with their tail instead of a fist bump
/atom/movable/screen/interaction/fist_bump/interaction_animation()
	owner.face_atom(initiator)
	initiator.face_atom(owner)

	var/x_distance = owner.x - initiator.x
	var/y_distance = owner.y - initiator.y

	if(isxeno(owner))
		animate(owner, pixel_x = owner.pixel_x - x_distance * 8, pixel_y = owner.pixel_y - y_distance * 8, dir = initiator.dir,
				time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
		owner.face_atom(initiator)
	else
		animate(owner, pixel_x = owner.pixel_x - x_distance * 8, pixel_y = owner.pixel_y - y_distance * 8,
				time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_x = initial(owner.pixel_x), pixel_y = initial(owner.pixel_y), time = 0.1 SECONDS)

	if(isxeno(initiator))
		animate(initiator, pixel_x = initiator.pixel_x + x_distance * 8, pixel_y = initiator.pixel_y + y_distance * 8, dir = owner.dir,
				time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
		initiator.face_atom(owner)
	else
		animate(initiator, pixel_x = initiator.pixel_x + x_distance * 8, pixel_y = initiator.pixel_y + y_distance * 8,
				time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_x = initial(initiator.pixel_x), pixel_y = initial(initiator.pixel_y), time = 0.1 SECONDS)

//We support interspecies bumping of fists and tails!
/atom/movable/screen/interaction/fist_bump/success_message()
	var/owner_xeno = isxeno(owner)
	var/initiator_xeno = isxeno(initiator)
	if(owner_xeno && initiator_xeno)
		return "[owner] and [initiator] slap tails together!"
	if(owner_xeno)
		return "[owner] slaps [initiator]'s fist!"
	if(initiator_xeno)
		return "[owner] fist bumps [initiator]'s tail!"
	return "[owner] fist bumps [initiator]!"

/atom/movable/screen/interaction/fist_bump/failure_message()
	return "[owner] left [initiator] hanging. Not cool!"

/atom/movable/screen/interaction/headbutt
	name = "head bump"
	desc = "Touch skulls."
	interaction_sound = 'sound/weapons/throwtap.ogg'

/atom/movable/screen/interaction/headbutt/interaction_animation()
	owner.face_atom(initiator)
	initiator.face_atom(owner)

	var/x_distance = owner.x - initiator.x
	var/y_distance = owner.y - initiator.y

	var/matrix/owner_matrix = owner.transform
	var/matrix/initiator_matrix = initiator.transform
	var/rotation_angle
	//This was so much pain, maintainers forgive me
	if(owner.dir & (EAST | WEST))
		if(isxenorunner(owner))	//Rounies get special upwards headbutts
			rotation_angle = owner.dir & EAST ? -15 : 15
		else
			rotation_angle = owner.dir & EAST ? 15 : -15

		//The animation if the mobs face east/west is to rotate their heads together
		animate(owner, pixel_x = owner.pixel_x - x_distance * 8, pixel_y = owner.pixel_y - y_distance * 8,
				transform = owner_matrix.Turn(rotation_angle), time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
		animate(pixel_x = initial(owner.pixel_x), pixel_y = initial(owner.pixel_y),
				transform = owner_matrix.Turn(-rotation_angle), time = 0.1 SECONDS)
	else
		//If facing north or south, basically the same animation as the high five but move even closer
		animate(owner, pixel_x = owner.pixel_x - x_distance * 8, pixel_y = owner.pixel_y - y_distance * 16,
				time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
		animate(pixel_x = initial(owner.pixel_x), pixel_y = initial(owner.pixel_y), time = 0.1 SECONDS)

	if(initiator.dir & (EAST | WEST))
		if(isxenorunner(initiator))
			rotation_angle = initiator.dir & EAST ? -15 : 15
		else
			rotation_angle = initiator.dir & EAST ? 15 : -15

		animate(initiator, pixel_x = initiator.pixel_x + x_distance * 8, pixel_y = initiator.pixel_y + y_distance * 8,
				transform = initiator_matrix.Turn(rotation_angle), time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
		animate(pixel_x = initial(initiator.pixel_x), pixel_y = initial(initiator.pixel_y),
				transform = initiator_matrix.Turn(-rotation_angle), time = 0.1 SECONDS)
	else
		animate(initiator, pixel_x = initiator.pixel_x + x_distance * 8, pixel_y = initiator.pixel_y + y_distance * 16,
				time = 0.5 SECONDS, easing = BACK_EASING, flags = ANIMATION_PARALLEL)
		animate(pixel_x = initial(initiator.pixel_x), pixel_y = initial(initiator.pixel_y), time = 0.1 SECONDS)

/atom/movable/screen/interaction/headbutt/success_message()
	return "[owner] and [initiator] bonk heads together!!"

/atom/movable/screen/interaction/headbutt/failure_message()
	return "[owner] did not headbutt [initiator]..."

/* HUD code */
///Update the hud; taken from how alerts do it, but slimmed down
/datum/hud/proc/update_interactive_emotes()
	var/mob/viewer = mymob
	if(!viewer.client)
		return

	var/list/queued_interactions = LAZYLISTDUPLICATE(mymob.queued_interactions)
	if(!LAZYLEN(queued_interactions))	//No interactions to show
		return FALSE

	if(!hud_shown)	//Clear the hud of interaction button(s)
		for(var/atom/movable/screen/interaction/interaction AS in queued_interactions)
			viewer.client.screen -= interaction
		return TRUE

	//I don't want to mess with screen real estate so it will only show the first interaction in the list until it's dismissed/expired
	var/atom/movable/screen/interaction/interaction = LAZYACCESS(queued_interactions, 1)
	interaction.screen_loc = "EAST-1:28,TOP-1:28"
	viewer.client.screen |= interaction
	return TRUE

//If anyone wants to add more interactions, here is an easy test item to use, just be sure to edit tgui_input_list() at the top
/obj/item/interaction_tester
	name = "interaction tester"
	icon_state = "coin"

/obj/item/interaction_tester/attack_self(mob/user)
	var/mob/target = tgui_input_list(user, "Select a target", "Select a target", GLOB.alive_living_list)
	if(!target)
		return
	target.interaction_emote(user)
