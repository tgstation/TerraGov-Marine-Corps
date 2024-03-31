/datum/voicepack/proc/get_sound(soundin, modifiers)
	return

/datum/voicepack/proc/getfold(soundin)
	var/used
	if(istext(soundin))
		switch(soundin)
			if("asdf")
				used = 'sound/blank.ogg'
		return used

/datum/voicepack/proc/getfyoung(soundin)
	var/used
	if(istext(soundin))
		switch(soundin)
			if("asdf")
				used = 'sound/blank.ogg'
		return used

/datum/voicepack/proc/getmold(soundin)
	var/used
	if(istext(soundin))
		switch(soundin)
			if("laugh")
				testing("setlaughh")
				used = pick('sound/vo/male/old/laugh (1).ogg', 'sound/vo/male/old/laugh (2).ogg', 'sound/vo/male/old/laugh (3).ogg')
			if("scream")
				used = 'sound/vo/male/old/scream.ogg'
			if("pain")
				used = pick('sound/vo/male/old/pain (1).ogg','sound/vo/male/old/pain (2).ogg','sound/vo/male/old/pain (3).ogg')
			if("painscream")
				used = pick('sound/vo/male/old/pain (1).ogg','sound/vo/male/old/pain (2).ogg','sound/vo/male/old/pain (3).ogg')
		return used

/datum/voicepack/proc/getmyoung(soundin)
	var/used
	if(istext(soundin))
		switch(soundin)
			if("chuckle")
				used = pick('sound/vo/male/young/chuckle (1).ogg','sound/vo/male/young/chuckle (2).ogg')
			if("embed")
				used = pick('sound/vo/male/young/embed (1).ogg','sound/vo/male/young/embed (2).ogg')
			if("fatigue")
				used = 'sound/vo/male/young/embed (1).ogg'
			if("firescream")
				used = pick('sound/vo/male/young/firescream (1).ogg','sound/vo/male/young/firescream (2).ogg','sound/vo/male/young/firescream (3).ogg')
			if("laugh")
				used = pick('sound/vo/male/young/laugh (1).ogg','sound/vo/male/young/laugh (2).ogg','sound/vo/male/young/laugh (3).ogg','sound/vo/male/young/laugh (4).ogg','sound/vo/male/young/laugh (5).ogg','sound/vo/male/young/laugh (6).ogg','sound/vo/male/young/laugh (7).ogg')
			if("pain")
				used = pick('sound/vo/male/young/pain (1).ogg','sound/vo/male/young/pain (2).ogg','sound/vo/male/young/pain (3).ogg','sound/vo/male/young/pain (4).ogg')
			if("paincrit")
				used = pick('sound/vo/male/young/paincrit (1).ogg','sound/vo/male/young/paincrit (2).ogg','sound/vo/male/young/paincrit (3).ogg')
			if("painscream")
				used = pick('sound/vo/male/young/painscream (1).ogg','sound/vo/male/young/painscream (2).ogg','sound/vo/male/young/painscream (3).ogg')
			if("rage")
				used = 'sound/vo/male/young/rage.ogg'
		return used

/datum/voicepack/proc/getmsilenced(soundin)
	var/used
	if(istext(soundin))
		switch(soundin)
			if("asdf")
				used = pick('sound/vo/male/young/laugh (1).ogg','sound/vo/male/young/laugh (2).ogg')
		if(!used) //always silent
			used = 'sound/blank.ogg'
		return used

/datum/voicepack/proc/getfsilenced(soundin)
	var/used
	if(istext(soundin))
		switch(soundin)
			if("asdf")
				used = pick('sound/vo/male/young/laugh (1).ogg','sound/vo/male/young/laugh (2).ogg')
		if(!used) //always silent
			used = 'sound/blank.ogg'
		return used
