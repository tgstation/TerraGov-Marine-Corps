GLOBAL_LIST_EMPTY(cached_images)

/datum/element/rendercache
	id_arg_index = 2
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	var/image/cached_image

//Every unique appearance has the same ref
/datum/element/rendercache/Attach(atom/target, _appearance)
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	. = ..()

	if(!cached_image)
		cached_image = image(target, SSrender.render_target, layer = AREA_LAYER)
		cached_image.render_target = "[REF(src)]"
		cached_image.plane = RENDER_CACHE_PLANE
		GLOB.cached_images[cached_image] = list()
		if(SSrender.initialized)
			for(var/user in GLOB.clients)
				user << cached_image
	GLOB.cached_images[cached_image] += target
	RegisterSignal(target, list(COMSIG_ATOM_LATEUPDATE_ICON, COMSIG_ATOM_DIR_CHANGE), .proc/on_icon_change)
	RegisterSignal(target, COMSIG_ATOM_RENDER_CACHE_EMPTIED, .proc/Detach)
	target.render_source = "[REF(src)]"

/datum/element/rendercache/Detach(atom/source, force)
	. = ..()
	source.render_target = null
	GLOB.cached_images[cached_image] -= source
	UnregisterSignal(source, list(COMSIG_ATOM_LATEUPDATE_ICON, COMSIG_ATOM_DIR_CHANGE, COMSIG_ATOM_RENDER_CACHE_EMPTIED))
	if(!length(GLOB.cached_images[cached_image]))
		cached_image = null //let it gc

/datum/element/rendercache/proc/on_icon_change(atom/target)
	SIGNAL_HANDLER
	Detach(target)
	target.AddElement(/datum/element/rendercache, target.appearance)
