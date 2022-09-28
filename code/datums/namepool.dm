GLOBAL_LIST_EMPTY_TYPED(namepool, /datum/namepool)
GLOBAL_LIST_EMPTY_TYPED(operation_namepool, /datum/operation_namepool)

/datum/namepool
	var/firstname_male_pool = "names/first_male"
	var/firstname_female_pool = "names/first_female"
	var/lastname_pool = "names/last_name"

/datum/namepool/proc/random_name(mob/living/carbon/human/H)
	return get_random_name(H.gender)

/datum/namepool/proc/get_random_name(gender = MALE)
	if(gender == MALE)
		. = pick(SSstrings.get_list_from_file(firstname_male_pool))
	else
		. = pick(SSstrings.get_list_from_file(firstname_female_pool))
	if(!lastname_pool)
		return

	. += " " + pick(SSstrings.get_list_from_file(lastname_pool))

/datum/namepool/clf
	firstname_male_pool = "names/first_male_clf"
	firstname_female_pool = "names/first_female_clf"
	lastname_pool = "names/last_name_clf"

/datum/namepool/pmc
	firstname_male_pool = "names/first_male_pmc"
	firstname_female_pool = "names/first_female_pmc"
	lastname_pool = "names/last_name_pmc"

/datum/namepool/russian
	firstname_male_pool = "names/first_male_russian"
	firstname_female_pool = "names/first_female_russian"
	lastname_pool = "names/last_name_russian"

/datum/namepool/moth
	firstname_male_pool = "names/moth_first"
	firstname_female_pool = "names/moth_first"
	lastname_pool = "names/moth_last"

/datum/namepool/synth
	firstname_male_pool = "names/male_synth"
	firstname_female_pool = "names/female_synth"
	lastname_pool = ""

/datum/namepool/sectoid/get_random_name()
	return "Sectoid [rand(1,9)]X[ascii2text(rand(65, 87))]" //65 to 87 is (uppercase) A to W

/datum/namepool/vatborn/
	firstname_male_pool = "names/first_male"
	firstname_female_pool = "names/first_female"

/datum/namepool/vatborn/get_random_name(gender = MALE)
	if(gender == MALE)
		. = pick(SSstrings.get_list_from_file(firstname_male_pool))
	else
		. = pick(SSstrings.get_list_from_file(firstname_female_pool))
	if(prob(25))
		. = "[ascii2text(rand(65, 90))]" //65 to 87 is (uppercase) A to Z

	. += "-[rand(1,999)]"

/datum/namepool/skeleton
	firstname_male_pool = "names/skeleton"
	firstname_female_pool = "names/skeleton"
	lastname_pool = "names/skeleton"

/datum/namepool/robotic
	firstname_female_pool = "names/robotic"

/datum/namepool/robotic/get_random_name(gender = MALE)
	. = pick(SSstrings.get_list_from_file(firstname_female_pool))
	. += "-[rand(1,999)]" //pathfinder-738 or such

/datum/operation_namepool
	var/list/operation_titles = "names/operation_title"
	var/list/operation_prefixes = "names/operation_prefix"
	var/list/operation_postfixes = "names/operation_postfix"
	var/operation_name

/datum/operation_namepool/proc/get_random_name()
	operation_name = pick(SSstrings.get_list_from_file(operation_titles))
	operation_name += " [pick(SSstrings.get_list_from_file(operation_prefixes))]"
	operation_name += "-[pick(SSstrings.get_list_from_file(operation_postfixes))]"
	return uppertext(operation_name)
