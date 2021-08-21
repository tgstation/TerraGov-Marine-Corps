/datum/pipeline
	var/list/obj/machinery/atmospherics/pipe/members
	var/list/obj/machinery/atmospherics/components/other_atmosmch

	var/update = TRUE

/datum/pipeline/New()
	members = list()
	other_atmosmch = list()
	SSair.networks += src

/datum/pipeline/Destroy()
	SSair.networks -= src
	for(var/obj/machinery/atmospherics/pipe/P in members)
		P.parent = null
	for(var/obj/machinery/atmospherics/components/C in other_atmosmch)
		C.nullifyPipenet(src)
	return ..()

/datum/pipeline/proc/build_pipeline(obj/machinery/atmospherics/base)
	if(istype(base, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/E = base
		members += E
	else
		addMachineryMember(base)
	var/list/possible_expansions = list(base)
	while(possible_expansions.len)
		for(var/obj/machinery/atmospherics/borderline in possible_expansions)
			var/list/result = borderline.pipeline_expansion(src)
			if(result && result.len)
				for(var/obj/machinery/atmospherics/P in result)
					if(istype(P, /obj/machinery/atmospherics/pipe))
						var/obj/machinery/atmospherics/pipe/item = P
						if(!members.Find(item))

							if(item.parent)
								var/static/pipenetwarnings = 10
								if(pipenetwarnings > 0)
									warning("build_pipeline(): [item.type] added to a pipenet while still having one. (pipes leading to the same spot stacking in one turf) around [AREACOORD(item)]")
									pipenetwarnings--
									if(pipenetwarnings == 0)
										warning("build_pipeline(): further messages about pipenets will be suppressed")
							members += item
							possible_expansions += item

							item.parent = src

					else
						P.setPipenet(src, borderline)
						addMachineryMember(P)

			possible_expansions -= borderline

/datum/pipeline/proc/addMachineryMember(obj/machinery/atmospherics/components/C)
	other_atmosmch |= C

/datum/pipeline/proc/addMember(obj/machinery/atmospherics/A, obj/machinery/atmospherics/N)
	if(istype(A, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = A
		if(P.parent)
			merge(P.parent)
		P.parent = src
		var/list/adjacent = P.pipeline_expansion()
		for(var/obj/machinery/atmospherics/pipe/I in adjacent)
			if(I.parent == src)
				continue
			var/datum/pipeline/E = I.parent
			merge(E)
		if(!members.Find(P))
			members += P
	else
		A.setPipenet(src, N)
		addMachineryMember(A)

/datum/pipeline/proc/merge(datum/pipeline/E)
	if(E == src)
		return
	members.Add(E.members)
	for(var/obj/machinery/atmospherics/pipe/S in E.members)
		S.parent = src
	for(var/obj/machinery/atmospherics/components/C in E.other_atmosmch)
		C.replacePipenet(E, src)
	other_atmosmch.Add(E.other_atmosmch)
	E.members.Cut()
	E.other_atmosmch.Cut()
	update = TRUE
	qdel(E)

/obj/machinery/atmospherics/proc/addMember(obj/machinery/atmospherics/A)
	return

/obj/machinery/atmospherics/pipe/addMember(obj/machinery/atmospherics/A)
	parent.addMember(A, src)

/obj/machinery/atmospherics/components/addMember(obj/machinery/atmospherics/A)
	var/datum/pipeline/P = returnPipenet(A)
	if(!P)
		CRASH("null.addMember() called by [type] on [COORD(src)]")
	P.addMember(A, src)
