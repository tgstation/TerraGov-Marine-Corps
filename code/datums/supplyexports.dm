// Sell costs are just ballpark numbers right now, can be changed later.

/datum/supply_export
	var/cost = null
	var/export_obj = null

/datum/supply_export/xemomorph
	cost = 0
	export_obj = /mob/living/carbon/xenomorph


/datum/supply_export/xemomorph/larva
	cost = 0
	export_obj = /mob/living/carbon/xenomorph/larva


/datum/supply_export/xemomorph/drone
	cost = 10
	export_obj = /mob/living/carbon/xenomorph/drone

/datum/supply_export/xemomorph/runner
	cost = 5
	export_obj = /mob/living/carbon/xenomorph/runner

/datum/supply_export/xemomorph/defender
	cost = 10
	export_obj = /mob/living/carbon/xenomorph/defender

/datum/supply_export/xemomorph/sentinel
	cost = 10
	export_obj = /mob/living/carbon/xenomorph/sentinel


/datum/supply_export/xemomorph/carrier
	cost = 20
	export_obj = /mob/living/carbon/xenomorph/carrier

/datum/supply_export/xemomorph/hivelord
	cost = 20
	export_obj = /mob/living/carbon/xenomorph/hivelord

/datum/supply_export/xemomorph/hunter
	cost = 15
	export_obj = /mob/living/carbon/xenomorph/hunter

/datum/supply_export/xemomorph/warrior
	cost = 15
	export_obj = /mob/living/carbon/xenomorph/warrior

/datum/supply_export/xemomorph/spitter
	cost = 15
	export_obj = /mob/living/carbon/xenomorph/spitter


/datum/supply_export/xemomorph/praetorian
	cost = 30
	export_obj = /mob/living/carbon/xenomorph/praetorian

/datum/supply_export/xemomorph/crusher
	cost = 30
	export_obj = /mob/living/carbon/xenomorph/crusher

/datum/supply_export/xemomorph/ravager
	cost = 30
	export_obj = /mob/living/carbon/xenomorph/ravager

/datum/supply_export/xemomorph/boiler
	cost = 30
	export_obj = /mob/living/carbon/xenomorph/boiler


/datum/supply_export/xemomorph/queen
	cost = 60
	export_obj = /mob/living/carbon/xenomorph/queen