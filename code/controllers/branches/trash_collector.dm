//Defined in setup.dm. Referenced here.
/*
#define TA_TRASH_ME		1 //Trash it.
#define TA_REVIVE_ME	2 //Not killing this one, instead adding it to the recycler. Call this on bullets, for example.
#define TA_PURGE_ME		3 //Purge it, but later. Not different from adding it to queue regularly as the trash authority will incinerate it when possible.
#define TA_PURGE_ME_NOW	4 //Purge it immediately. Generally don't want to use this.
#define TA_IGNORE_ME	5 //Ignore this atom, don't do anything with it. In case the atom will die on its own or something.
					 	  //Shouldn't usually use this as garbage collection is far better, but you might want an immortal atom.
*/
	/*
	This is the main trash collector that should be collecting, sorting, and then deleting information.
	The majority of the deletion process will come from the BYOND built-in garbage collector, but for
	cases where the garbage collector is unable to scrub the atom/datum with soft deletion, this will
	hard delete it instead. The end goal is to eliminate the need for hard deletion completely, so
	that lag is minimal due to Del() being run constantly.

	The other part of this is the atom_recycler.dm which, instead of being deleted through this process
	goes back into a list for further use. This is preferable to constantly creating and deleting atoms
	since we can just take an existing, but unused atom, and use it instead.

	This system is inspired by, and in part taken from, Ter13's pooling libraries as well as the /vg/ / bay
	and /tg/ station systems that serve a similar function. Honestly, not too different from them because
	you can't do much to innovate here. Works exactly the same way as those systems, somewhere in between
	complexity of /vg/ and /tg/, but with different names. I prefer the naming structure of an actual
	garbage collection authority, and that is reflected here.

	If I ever do a master controller, it would be called the governing authority. ~N
	*/

#define DEBUG_TA_AUTHORITY 0

var/global/datum/authority/branch/trash/TrashAuthority = new() //This is the actual process called on.
/datum/var/ta_directive //This is used in reference to deletion later in the process to accurately sweep stuff away.

//This is the proc you should be called on to trash something, not calling on the other procs directly. This is a replacement for del().
//cdel stands for clean delete.
/proc/cdel(datum/garbage, override = null, countdown)
	if(countdown)
		set waitfor = 0
		sleep(countdown)//What if we don't want to delete it right away? This will allow other procs to run while this one sleeps.

	if(!garbage) return //Nothing? Huh. Could be deleted by now.

	if(!istype(garbage))
		del(garbage)
		return

	//get directive here from the atom.
	//If it's already set, that means that it's either going to be revived, or it's already in queue for soft/hard deletion.
	if(!garbage.ta_directive) // <---- This should always be 0 or null on anything not processed.
		var/directive = garbage.Dispose(override)
		if(!directive) directive = TA_TRASH_ME
		switch(directive)
			if(TA_IGNORE_ME)   //Nothing.
			if(TA_REVIVE_ME)
				RecycleAuthority.RecycleTrash(garbage)
				#if DEBUG_TA_AUTHORITY
				world << "<span class='debuginfo'>Sending [garbage.type] to the recycler.</span>"
				#endif
			if(TA_PURGE_ME_NOW) TrashAuthority.PurgeTrash(garbage)
			else 				TrashAuthority.DeliverTrash(garbage) //If it returned anything else.
	return

/datum/authority/branch/trash
	name = "Trash Authority"
	var/trashing[] = list() //The list for what to delete later. Your basic queue. Not named queue because I like to know specifically what the queue is.
	var/ready_trash[] = list() //Reference IDs stored to be trashed later.
	var/purge_trash[] = list() //Whatever we need to hard delete for any reason.
	var/cannot_trash[] = list() //Everything we weren't able to trash is referenced here as we hard delete it. We can later find and look at this list.
	var/purging = 0 //Toggle to hard delete everything with del(). This shouldn't be toggled on unless there is some crazy bottleneck.
	var/soft_del_count = 0 //How many soft deletions we did. This is the primary thing we're concerned with, and we don't list these items since they were successfully collected.
	var/hard_del_count = 0 //How many hard deletions we did. This gives us a baseline for what ISN'T being deleted properly, with cannot_trash as our specific reference list.

/datum/authority/branch/trash/proc/DeliverTrash(datum/garbage) //Preparing to add to queue.
	if(!istype(garbage)) //If it's not a datum.
		del(garbage)
		return

	if(purging)
		garbage.ta_directive = TA_PURGE_ME_NOW
		PurgeTrash(garbage)
		return

	var/refID = "\ref[garbage]"
	if(trashing[refID])
		trashing -= refID
	trashing[refID] = world.time

//Man, I might as well straight up copy stuff considering how few ways there are to handle this.
//Generic defines.
#define TA_WORK_TIMEOUT (30 SECONDS) //30 seconds is the standard. If we didn't delete it in 30 seconds, we kill it manually.
#define TA_EMPTY_PER_TICK 120 //120 soft deletion checks per tick. 150 is the standard elsewhere, lowering it for now.
#define TA_PURGE_PER_TICK 25 //25 hard deletions per tick. 30 is the standard elsewhere, lowering it.
//Remember, we only need to run this to check if the item has been collected by the trash compactor. If it hasn't,
//only THEN do we del() it. Otherwise we're good to go.
/datum/authority/branch/trash/proc/EmptyTrash() //Disposing of the trash proper.

	var/soft_del_remaining = TA_EMPTY_PER_TICK
	var/hard_del_remaining = TA_PURGE_PER_TICK
	var/work_timeframe = ( world.time - TA_WORK_TIMEOUT )

	while(trashing.len && --soft_del_remaining >= 0) //Still have stuff to trash and we're good for more soft deletion checks.
		if(hard_del_remaining <= 0) break //We're out of hard del times per tick, so let's take a break.
		var/refID = trashing[1]

		var/disposal_time = trashing[refID]

		if(disposal_time > work_timeframe) break //It's not old enough.

		var/datum/garbage = locate(refID) //Let's see if it still exists. locate() is wonderful.

		if( garbage && garbage.ta_directive == disposal_time ) //It still exists. Time to kill it.
			garbage.ta_directive = TA_PURGE_ME_NOW
			PurgeTrash(garbage)
			hard_del_remaining--

		else soft_del_count++ //Success. Let's move on.

		trashing.Cut(1, 2) //Cut the list down.
#undef TA_WORK_TIMEOUT
#undef TA_EMPTY_PER_TICK
#undef TA_PURGE_PER_TICK

/*
The incinerator. If the object is queued for deletion, or it is being deleted now, it will do so.
Otherwise it will add it to queue for later hard deletion.
*/
/datum/authority/branch/trash/proc/PurgeTrash(datum/garbage) //Preparing to incinerate.
	if(!garbage) return //How did this happen? Maybe it was already deleted.

	if(garbage.ta_directive == TA_PURGE_ME_NOW)
		garbage.Dispose() //We're going to give it one more chance to clean up any references.
		cannot_trash["\ref[garbage]"] = world.time
		del(garbage)
		hard_del_count++
	else
		purge_trash += garbage //Since we're getting rid of it, no reason to carry additional data.
/*
Individual atoms will need to modify this proc and call ..() after. Null all references to other atoms before getting rid of it.
This makes sure the BYOND garbage collector does its job properly. As mentioned in the atoms.dm, these procs should always
. = ..() so that the right directive is returned unless you manually override it with a different return. Even though the
default action is to add to queue, you may want to hard delete instead. Like the case with turfs. You don't need to call
cdel on anything in contents, like gun attachments. They are automtically cdel'd, so just null references instead and do
anything additional that may be required.
You will find the individual Dispose() calls in the various /atom  /atom/movable /obj /turf /mob files.

Override exists for any specific behavior you may want to happen. For example, you may want to force delete something instead
of adding it queue in some circumstances but not others.

TO DO: Implement more support for /mob.
*/
/datum/proc/Dispose(override = 0) //This is the proc parent of how atoms get rid of trash.
	tag = null //Can't have one of these and still be garbage collected. Same for key in mobs, which will be added to that subtype.
	disposed = TRUE
	return TA_TRASH_ME

//======================================================
//======================================================
//Debug verbs.

/datum/proc/ta_diagnose()
	set category = "Debug"
	set name = "Trash: TA Diagnose"
	set desc = "This will bring up diagnostic information about the Trash Authority and log the results in debug."

	usr << "Currently processed: <b>[TrashAuthority.soft_del_count]</b> soft deletions and <b>[TrashAuthority.hard_del_count]</b> hard deletions."
	usr << "Currently storing: <b>[TrashAuthority.trashing.len]</b> items in queue."
	usr << "Currently hard deleted: <b>[TrashAuthority.cannot_trash.len]</b> items:"
	if(TrashAuthority.cannot_trash.len)
		for(var/I in TrashAuthority.cannot_trash)
			var/deletion_time = TrashAuthority.cannot_trash[I]
			usr << "<b>[TrashAuthority.cannot_trash[I]]</b> deleted at:[TrashAuthority.cannot_trash[deletion_time]]."
	else usr << "\blue Empty!"
	log_debug("TA: Currently processed: <b>[TrashAuthority.soft_del_count]</b> soft deletions and <b>[TrashAuthority.hard_del_count]</b> hard deletions.")

/datum/proc/ta_purge()
	set category = "Debug"
	set name = "Trash: TA Purge Toggle"
	set desc = "This will toggle the Trash Authority's purge mode and log the results in debug. Do not use this without good reason."

	TrashAuthority.purging = !TrashAuthority.purging
	usr << "\red TA is [TrashAuthority.purging? "now purging." : "is no longer purging."]"
	log_debug("TA: <b>[usr.key]</b> used the purge toggle.")

#undef DEBUG_TA_AUTHORITY
