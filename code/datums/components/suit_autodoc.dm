/datum/component/suit_autodoc
	var/obj/item/healthanalyzer/integrated/analyzer
	var/burn_nextuse
	var/oxy_nextuse
	var/brute_nextuse
	var/tox_nextuse
	var/pain_nextuse

	var/enabled

	var/damage_threshold = 50
	var/pain_threshold = 70

/datum/component/suit_autodoc/proc/examine(datum/source)
