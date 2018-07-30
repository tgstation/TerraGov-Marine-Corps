	/*
	Made this into a datum, unlike some of the other implementations.
	Honestly no reason it shouldn't be a controller on its own
	considering I specifically made it to perform joint functions
	with the TA.
	~N
	*/

/*
This is what you call on instead of new() for certain things. rnew stands for Re-New and will do a few things
for you. First, it will attempt to find the fetch_type from a list of pooled items (the recycling list).
The directive is an argument list you pass on to the datum in order to actually get an item exactly to your
specifications. If it's not a list, it should be the location where the item will spawn. If it's not a location,
the list must have the location as the first argument. The list is really only useful for things like images
that have several arguments in terms of creating their stuff.

If it can't find whatever it is you are trying to get, it'll just new() it with the list of arguments. Since we
don't specifically know what to return, we'll be using . = whatever a lot.

Calling on new() is faster, obviously, if the item doesn't exist in the recycle list since there is no overhead.
But as things are stored and called on this becomes more and more useful.

Do NOT call this through RecycleTrash(). The idea is to use cdel() instead, and the atom/whatever should return
a TA_REVIVE_ME through Dispose(), telling the Trash Authority to send the object to the recycler instead of
adding it to the trash queue. This gives the object time to null any references and such, and its location will
be nulled so it doesn't appear anywhere. Once it's added to the recycle list, it won't be deleted because the
list will reference it. Even if it's somehow deleted in the interim, it doesn't honestly matter too much.
*/

#define DEBUG_RA_AUTHORITY 0

/proc/rnew(fetch_type, directive)
	if(!fetch_type || !ispath(fetch_type)) return
	return RecycleAuthority.FetchProduct(fetch_type, directive)

#define RA_PRODUCT_SPACE 40 //I might expand this per individual types based on need.
							 //Right now it applies to every category.

var/global/datum/authority/branch/recycle/RecycleAuthority = new()
/datum/authority/branch/recycle
	name = "Recycle Authority"
	var/recycling[] = list() //This is where we pull objects from. The opposite of trashing[].
	var/gathered_variables[] = list() //This is a list of variables we can later compare to type; once we have this, we don't need to repeat the create variable process.
	var/excluded_variables[] = list("animate_movement", "client", "contents", "gender", "group", "key", "loc", "locs", "mob", "parent_type", "screen_loc", "ta_directive", "type", "vars", "verbs", "x", "y", "z") //These variables we don't need to include.
	var/shelf_space = RA_PRODUCT_SPACE //We cannot go over this number per individual product.
	var/purging = 0 //Toggle like with the Trash Authority. Will throw it back to the TA for queue unless the TA is also purging.
	var/recycle_count = 0

#undef RA_PRODUCT_SPACE

/datum/authority/branch/recycle/proc/FetchProduct(fetch_type, directive)
	if( recycling[fetch_type] && length(recycling[fetch_type]) )
		var/datum/fetched = popleft(recycling[fetch_type]) //Get us the oldest element to reuse.
		if(fetched) //This shouldn't happen, but the system is not optimized enough to eliminate the outlier cases...
			fetched.ta_directive = null //Reset this, in case we need to dispose of it later, though it should still be recycled in most cases.

			if(islist(directive)) 	fetched.New(arglist(directive))
			else 					fetched.New(directive)
			recycle_count++
			#if DEBUG_RA_AUTHORITY
			world << "<span class='debuginfo'>Was able to pull product from shelf.</span>"
			#endif
			return fetched

		else log_debug("RA: FetchFromShelf returned a null item: [fetch_type] and it was somehow deleted in the interim. Pulling from new instead.")

	if(islist(directive)) 	. = new fetch_type(arglist(directive)) //Give us a an argument list.
	else 					. = new fetch_type(directive) //Give us a loc.
	#if DEBUG_RA_AUTHORITY
	world << "<span class='debuginfo'>Had to create a new atom. Could not get from shelf.</span>"
	#endif

/*
loc is reset through cdel, which is how things get into the recycler in the first place (how they should anyway),
so there's honestly not too much to do here.
*/
/datum/authority/branch/recycle/proc/RecycleTrash(datum/product)
	if(!istype(product)) return

	//This shouldn't happen, unless you call through RecycleProduct instead of cdel.
	if(product in recycling[product.type]) return //If the item is already on the shelf. Somehow.
	if( isnull(recycling[product.type]) ) recycling[product.type] = list() //Slap on a new list to reference the whatever.
	if(purging || length(recycling[product.type]) >= shelf_space)
		TrashAuthority.DeliverTrash(product) //We're just gonna get rid of it.
		log_debug("RA: trashed the product instead of recycling. Current shelf length is: <b>[length(recycling[product.type])]</b>")
		if(length(recycling[product.type]) > shelf_space)
			shelf_space += 10
			log_debug("Increasing RA shelf space. Current maximum space: <b>[shelf_space]</b>")

	var/i
	if(!gathered_variables[product.type]) //If we don't have a variable reference, we're going to make one.
		var/blacklist[] = excluded_variables + product.Recycle() //Let's combine these so we know what to exclude in the following step.
		blacklist &= product.vars //We need to get the items they have in common only, as this is what we need to remove.
		gathered_variables[product.type] = product.vars ^ blacklist //Then we remove the incommon items. Easy.
		#if DEBUG_RA_AUTHORITY
		world << "<span class='debuginfo'>Successfully notated [product.type].</span>"
		#endif

		for(i in gathered_variables[product.type])
			if(islist(product.vars[i])) gathered_variables[product.type][i] = list() //We reset it to empty if it's a list.
			else gathered_variables[product.type][i] = initial(product.vars[i]) //Reset.
		#if DEBUG_RA_AUTHORITY
		world << "<span class='debuginfo'>Successfully reset [product.type].</span>"
		#endif

	//Time to reset its variables.
	for(i in gathered_variables[product.type]) //We still need to empty lists here. Sigh. Better to just empty them on Dispose().
		product.vars[i] = islist(product.vars[i]) ? list() : gathered_variables[product.type][i]

	recycling[product.type] += product //Adds it to the list.
	product.ta_directive = TA_REVIVE_ME //It won't be collected and disposed of later.

/*
This is the opposite of Dispose. You can override this proc for certain things if you want to preserve
specific variables about it. For example, if you have a variable that should not be initial()'ed, you
can return it with Recycle(). You can make it a list of vars too, such as list("var1","var2",...) etc.
You can also just return a single variable, it won't make a difference. If the variable is a list, you don't
need to return the whole list, just the variable name. Lists are reset to = list().

Unless you know what you are doing, you can probably leave this as it is and not bother. However, if you do
reset a bunch of referencing with Dispose(), you can pass those through so they aren't checked along with
the other vars that are read only or somesuch.
You can also return the entire list of variables if you reset them manually. Not sure why you'd want to do that though.
*/
/datum/proc/Recycle() return

#if DEBUG_RA_AUTHORITY
/image/debug_image
	New(icon,loc,icon_state,layer = FLOAT_LAYER,dir)

/mob/verb/debug_reusable_image()
	set name = "Test Image Variables"
	set category = "Debug"
	set desc = "Test out image creation on New() and the variables as they are set."

	var/directives[] = list('icons/testing/Zone.dmi',src,"assigned",10,10)
	var/image/debug_image/I = new(arglist(directives))
	src << "<span class='debuginfo'><b>Initial Spawn</b></span>"
	src << "<span class='debuginfo'>Icon is [I.icon].</span>"
	src << "<span class='debuginfo'>Location is [I.loc].</span>"
	src << "<span class='debuginfo'>Icon state is [I.icon_state].</span>"
	src << "<span class='debuginfo'>Layer is [I.layer].</span>"
	src << "<span class='debuginfo'>Direction is [I.dir].</span>"

	I.New(arglist(list('icons/testing/Zone.dmi',src,"assigned2",4,6)))
	src << "<span class='debuginfo'><b>New() Spawn</b></span>"
	src << "<span class='debuginfo'>Icon is [I.icon].</span>"
	src << "<span class='debuginfo'>Location is [I.loc].</span>"
	src << "<span class='debuginfo'>Icon state is [I.icon_state].</span>"
	src << "<span class='debuginfo'>Layer is [I.layer].</span>"
	src << "<span class='debuginfo'>Direction is [I.dir].</span>"
#endif

/*Generic image parent for any reusable image that works with the recycler.
Set up on new() as an overlay. layer and dir can be overriden, the other
stuff is required for it to show up in the first place. Anything generated
with image() sets the arguments without needing to actually set them through
New(), just like loc works for regular atoms (always set as first argument).

This means that by having overrides in New(), the proc will write everything
twice on image(). This same behavior also applies to new. When the image is
recycled, it will NOT autoset the arguments, so you have to set them through
New() instead. I thought about having a unique proc insted of using New(), to
cut down on overhead, but I think having uniform behavior is best here as the
overhead only applies when the image is first created.*/
/image/reusable
	New(IC,LC,IS,L = FLOAT_LAYER,D)
		icon = IC
		loc = LC
		icon_state = IS
		layer = L
		dir = D

	Dispose()
		..()
		loc = null
		return TA_REVIVE_ME

	Recycle()
		. = ..() + list("icon","icon_state","loc","layer","dir")

//Quickly shows the image to everyone, then removes it some time later.
//We don't want apperance flags by default for everything, but we want them here to ignore color, transparency, and transform.
/image/reusable/proc/flick_overlay(atom/A, time = 1, flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM|TILE_BOUND)
	set waitfor = 0
	appearance_flags = flags
	A.overlays += src
	sleep(time)
	if(A && A.loc) A.overlays -= src
	cdel(src)

//======================================================
//======================================================
//Debug verbs.

/datum/proc/ra_diagnose()
	set category = "Debug"
	set name = "Trash: RA Diagnose"
	set desc = "This will bring up diagnostic information about the Trash Authority and log the results in debug."

	usr << "Currently processed: <b>[RecycleAuthority.recycle_count]</b> products."
	usr << "Currently storing: <b>[RecycleAuthority.recycling.len]</b> item categories."
	log_debug("RA: Currently processed: <b>[RecycleAuthority.recycle_count]</b> products. Currently storing: <b>[RecycleAuthority.recycling.len]</b> item categories.")

/datum/proc/ra_purge()
	set category = "Debug"
	set name = "Trash: RA Purge Toggle"
	set desc = "This will toggle the Recycle Authority's purge mode and log the results in debug. Do not use this without good reason."

	RecycleAuthority.purging = !RecycleAuthority.purging
	usr << "\red RA is [RecycleAuthority.purging? "now purging." : "is no longer purging."]"
	log_debug("RA: <b>[usr.key]</b> used the purge toggle.")

#undef DEBUG_RA_AUTHORITY
