/datum/outfit/job
	var/jobtype

/datum/outfit/job/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return

/datum/outfit/job/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return

/datum/outfit/job/proc/handle_id(mob/living/carbon/human/H)
	var/datum/job/job = H.job ? H.job : SSjob.GetJobType(jobtype)
	var/obj/item/card/id/id = H.wear_id
	if(!istype(id))
		return
	id.access = job.get_access()
	id.iff_signal = GLOB.faction_to_iff[job.faction]
	shuffle_inplace(id.access) // Shuffle access list to make NTNet passkeys less predictable
	id.registered_name = H.real_name
	id.assignment = job.title
	id.rank = job.title
	id.paygrade = job.paygrade
	id.update_label()
	if(H.mind?.initial_account) // In most cases they won't have a mind at this point.
		id.associated_account_number = H.mind.initial_account.account_number
