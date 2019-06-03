/datum/component/forensics
	dupe_mode = COMPONENT_DUPE_UNIQUE
	can_transfer = TRUE
	var/list/fingerprints		//assoc ckey = realname/time/action/ckey


/datum/component/forensics/InheritComponent(datum/component/forensics/F, original)		//Use of | and |= being different here is INTENTIONAL.
	fingerprints = fingerprints | F.fingerprints
	return ..()


/datum/component/forensics/Initialize(new_fingerprints)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	fingerprints = new_fingerprints


/datum/component/forensics/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/f_attack_self)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/f_attackby)
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, .proc/f_attack_hand)
	RegisterSignal(parent, COMSIG_TOPIC, .proc/f_topic)
	RegisterSignal(parent, COMSIG_PARENT_PREQDELETED, .proc/transfer)


/datum/component/forensics/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)
	UnregisterSignal(parent, COMSIG_PARENT_ATTACKBY)
	UnregisterSignal(parent, COMSIG_ATOM_ATTACK_HAND)
	UnregisterSignal(parent, COMSIG_TOPIC)
	UnregisterSignal(parent, COMSIG_PARENT_PREQDELETED)


/datum/component/forensics/PostTransfer()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE


/datum/component/forensics/proc/f_attack_self(atom/A, mob/M)
	add_fingerprint(M, "attack_self")


/datum/component/forensics/proc/f_attackby(atom/A, obj/item/I, mob/M, params)
	add_fingerprint(M, "attackby", I)


/datum/component/forensics/proc/f_attack_hand(atom/A, mob/M)
	add_fingerprint(M, "attack_hand")


/datum/component/forensics/proc/f_topic(atom/A, mob/M, href_list)
	add_fingerprint(M, "topic")


/datum/component/forensics/proc/transfer(force)
	var/atom/A = parent
	if(!isturf(A.loc))
		return

	TransferComponents(A.loc)



/datum/component/forensics/proc/add_fingerprint(mob/M, type, special)
	if(!type)
		CRASH("Attempted to add fingerprint of invalid action type.")

	if(!istype(M))
		CRASH("Invalid mob type [M] when attempting to add fingerprint of type [type].")

	if(!M.key)
		return

	var/current_time = stationTimestamp()

	if(!LAZYACCESS(fingerprints, M.key))
		LAZYSET(fingerprints, M.key, "First: [M.real_name] | [current_time] | [type] |[special ? " [special] |" : ""]")
	else
		var/laststamppos = findtext(LAZYACCESS(fingerprints, M.key), " Last: ")
		if(laststamppos)
			LAZYSET(fingerprints, M.key, copytext(fingerprints[M.key], 1, laststamppos))
		fingerprints[M.key] += " Last: [M.real_name] | [current_time] | [type] |[special ? " [special] |" : ""]"
	
	return TRUE