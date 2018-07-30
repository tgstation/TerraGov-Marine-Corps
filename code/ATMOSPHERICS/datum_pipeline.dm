
/datum/pipeline

	var/list/obj/machinery/atmospherics/pipe/members
	var/list/obj/machinery/atmospherics/pipe/edges //Used for building networks

	var/datum/pipe_network/network

	var/alert_pressure = 0

/datum/pipeline/Dispose()
	if(network)
		cdel(network)

	..()

/datum/pipeline/proc/process()//This use to be called called from the pipe networks

	//Allow for reactions
	//air.react() //Should be handled by pipe_network now

/datum/pipeline/proc/temporarily_store_air()


/datum/pipeline/proc/build_pipeline(obj/machinery/atmospherics/pipe/base)

	var/list/possible_expansions = list(base)
	members = list(base)
	edges = list()

	var/volume = base.volume
	base.parent = src
	alert_pressure = base.alert_pressure

	while(possible_expansions.len>0)
		for(var/obj/machinery/atmospherics/pipe/borderline in possible_expansions)

			var/list/result = borderline.pipeline_expansion()
			var/edge_check = result.len

			if(result.len>0)
				for(var/obj/machinery/atmospherics/pipe/item in result)
					if(!members.Find(item))
						members += item
						possible_expansions += item

						volume += item.volume
						item.parent = src

						alert_pressure = min(alert_pressure, item.alert_pressure)

					edge_check--

			if(edge_check>0)
				edges += borderline

			possible_expansions -= borderline


/datum/pipeline/proc/network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)

	if(new_network.line_members.Find(src))
		return 0

	new_network.line_members += src

	network = new_network

	for(var/obj/machinery/atmospherics/pipe/edge in edges)
		for(var/obj/machinery/atmospherics/result in edge.pipeline_expansion())
			if(!istype(result,/obj/machinery/atmospherics/pipe) && (result!=reference))
				result.network_expand(new_network, edge)

	return 1

/datum/pipeline/proc/return_network(obj/machinery/atmospherics/reference)
	if(!network)
		network = new /datum/pipe_network()
		network.build_network(src, null)
			//technically passing these parameters should not be allowed
			//however pipe_network.build_network(..) and pipeline.network_extend(...)
			//		were setup to properly handle this case

	return network

/datum/pipeline/proc/mingle_with_turf(turf/target, mingle_volume)

/datum/pipeline/proc/temperature_interact(turf/target, share_volume)

//surface must be the surface area in m^2
/datum/pipeline/proc/radiate_heat_to_space(surface)
