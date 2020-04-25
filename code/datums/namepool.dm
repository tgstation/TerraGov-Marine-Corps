GLOBAL_LIST_EMPTY_TYPED(namepool, /datum/namepool)

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

/datum/namepool/sectoid/get_random_name()
	return "Sectoid [rand(1,9)]X[ascii2text(rand(65, 87))]" //65 to 87 is (uppercase) A to W
