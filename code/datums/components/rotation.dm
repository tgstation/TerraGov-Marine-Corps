#define ROTATION_ALTCLICK (1<<0)
#define ROTATION_WRENCH (1<<1)
#define ROTATION_VERBS (1<<2)
#define ROTATION_COUNTERCLOCKWISE (1<<3)
#define ROTATION_CLOCKWISE (1<<4)
#define ROTATION_FLIP (1<<5)

/datum/component/simple_rotation
	var/datum/callback/can_user_rotate //Checks if user can rotate
	var/datum/callback/can_be_rotated  //Check if object can be rotated at all
	var/datum/callback/after_rotation     //Additional stuff to do after rotation

	var/rotation_flags = NONE
	var/default_rotation_direction = ROTATION_CLOCKWISE


/datum/component/simple_rotation/Initialize(rotation_flags = NONE, can_user_rotate, can_be_rotated, after_rotation)
	if(!ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE

	//throw if no rotation direction is specificed ?

	src.rotation_flags = rotation_flags

	if(can_user_rotate)
		src.can_user_rotate = can_user_rotate
	else
		src.can_user_rotate = CALLBACK(src,PROC_REF(default_can_user_rotate))

	if(can_be_rotated)
		src.can_be_rotated = can_be_rotated
	else
		src.can_be_rotated = CALLBACK(src,PROC_REF(default_can_be_rotated))

	if(after_rotation)
		src.after_rotation = after_rotation
	else
		src.after_rotation = CALLBACK(src,PROC_REF(default_after_rotation))

	//Try Clockwise,counter,flip in order
	if(src.rotation_flags & ROTATION_FLIP)
		default_rotation_direction = ROTATION_FLIP
	if(src.rotation_flags & ROTATION_COUNTERCLOCKWISE)
		default_rotation_direction = ROTATION_COUNTERCLOCKWISE
	if(src.rotation_flags & ROTATION_CLOCKWISE)
		default_rotation_direction = ROTATION_CLOCKWISE


/datum/component/simple_rotation/proc/add_signals()
	if(rotation_flags & ROTATION_ALTCLICK)
		RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(HandRot))
		RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(ExamineMessage))
	if(rotation_flags & ROTATION_WRENCH)
		RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(WrenchRot))


/datum/component/simple_rotation/proc/add_verbs()
	if(rotation_flags & ROTATION_VERBS)
		var/atom/movable/AM = parent
		if(rotation_flags & ROTATION_FLIP)
			AM.verbs += /atom/movable/proc/simple_rotate_flip
		if(src.rotation_flags & ROTATION_CLOCKWISE)
			AM.verbs += /atom/movable/proc/simple_rotate_clockwise
		if(src.rotation_flags & ROTATION_COUNTERCLOCKWISE)
			AM.verbs += /atom/movable/proc/simple_rotate_counterclockwise


/datum/component/simple_rotation/proc/remove_verbs()
	if(parent)
		var/atom/movable/AM = parent
		AM.verbs -= /atom/movable/proc/simple_rotate_flip
		AM.verbs -= /atom/movable/proc/simple_rotate_clockwise
		AM.verbs -= /atom/movable/proc/simple_rotate_counterclockwise


/datum/component/simple_rotation/proc/remove_signals()
	UnregisterSignal(parent, list(COMSIG_CLICK_ALT, COMSIG_ATOM_EXAMINE, COMSIG_ATOM_ATTACKBY))


/datum/component/simple_rotation/RegisterWithParent()
	add_verbs()
	add_signals()
	return ..()

/datum/component/simple_rotation/PostTransfer()
	//Because of the callbacks which we don't track cleanly we can't transfer this
	//item cleanly, better to let the new of the new item create a new rotation datum
	//instead (there's no real state worth transferring)
	return COMPONENT_NOTRANSFER


/datum/component/simple_rotation/UnregisterFromParent()
	remove_verbs()
	remove_signals()
	return ..()

/datum/component/simple_rotation/Destroy()
	can_user_rotate = null
	can_be_rotated = null
	after_rotation = null
	return ..()


/datum/component/simple_rotation/RemoveComponent()
	remove_verbs()
	return ..()


/datum/component/simple_rotation/proc/ExamineMessage(datum/source, mob/user)
	SIGNAL_HANDLER
	if(rotation_flags & ROTATION_ALTCLICK)
		. += span_notice("Alt-click to rotate it clockwise.")


/datum/component/simple_rotation/proc/HandRot(datum/source, mob/user, rotation = default_rotation_direction)
	SIGNAL_HANDLER
	if(!can_be_rotated.Invoke(user, rotation) || !can_user_rotate.Invoke(user, rotation))
		return
	BaseRot(user, rotation)


/datum/component/simple_rotation/proc/WrenchRot(datum/source, obj/item/I, mob/living/user)
	SIGNAL_HANDLER
	if(!can_be_rotated.Invoke(user,default_rotation_direction) || !can_user_rotate.Invoke(user,default_rotation_direction))
		return
	if(I.tool_behaviour == TOOL_WRENCH)
		BaseRot(user,default_rotation_direction)
		return COMPONENT_NO_AFTERATTACK


/datum/component/simple_rotation/proc/BaseRot(mob/user,rotation_type)
	var/atom/movable/AM = parent
	var/rot_degree
	switch(rotation_type)
		if(ROTATION_CLOCKWISE)
			rot_degree = -90
		if(ROTATION_COUNTERCLOCKWISE)
			rot_degree = 90
		if(ROTATION_FLIP)
			rot_degree = 180
	AM.setDir(turn(AM.dir,rot_degree))
	after_rotation.Invoke(user,rotation_type)


/datum/component/simple_rotation/proc/default_can_user_rotate(mob/living/user, rotation_type)
	if(!istype(user) || !parent.can_interact(user))
		return FALSE
	return TRUE


/datum/component/simple_rotation/proc/default_can_be_rotated(mob/user, rotation_type)
	var/atom/movable/AM = parent
	return !AM.anchored


/datum/component/simple_rotation/proc/default_after_rotation(mob/user, rotation_type)
	user.balloon_alert(user, "[rotation_type == ROTATION_FLIP ? "flipped" : "rotated"] [parent].")


/atom/movable/proc/simple_rotate_clockwise()
	set name = "Rotate Clockwise"
	set category = "Object"
	set src in oview(1)
	var/datum/component/simple_rotation/rotcomp = GetComponent(/datum/component/simple_rotation)
	if(rotcomp)
		rotcomp.HandRot(null, usr, ROTATION_CLOCKWISE)


/atom/movable/proc/simple_rotate_counterclockwise()
	set name = "Rotate Counter-Clockwise"
	set category = "Object"
	set src in oview(1)
	var/datum/component/simple_rotation/rotcomp = GetComponent(/datum/component/simple_rotation)
	if(rotcomp)
		rotcomp.HandRot(null, usr, ROTATION_COUNTERCLOCKWISE)


/atom/movable/proc/simple_rotate_flip()
	set name = "Flip"
	set category = "Object"
	set src in oview(1)
	var/datum/component/simple_rotation/rotcomp = GetComponent(/datum/component/simple_rotation)
	if(rotcomp)
		rotcomp.HandRot(null, usr, ROTATION_FLIP)
