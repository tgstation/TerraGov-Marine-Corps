/* Gas mines - Release smoke clouds on detonation, war crime certified */
/obj/item/mine/tanglefoot
	name = "tanglefoot mine"
	desc = "Releases plasma-draining smoke."
	icon_state = "gas"
	detonation_message = "beeps and hisses, releasing purple vapors."
	range = 2
	duration = 10 SECONDS	//Stays around for a bit venting gas
	detonation_delay = 1.5 SECONDS
	disarm_delay = 5 SECONDS
	undeploy_delay = 3 SECONDS
	deploy_delay = 3 SECONDS
	gas_type = /datum/effect_system/smoke_spread/plasmaloss
	gas_range = 3
	gas_duration = 15
	mine_features = MINE_DISCERN_LIVING|MINE_ELECTRONIC|MINE_ILLEGAL|MINE_VOLATILE_DAMAGE|MINE_VOLATILE_FIRE|MINE_VOLATILE_EXPLOSION
