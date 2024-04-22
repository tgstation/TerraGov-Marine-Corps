/datum/voicepack/male/get_sound(soundin, modifiers)
	var/used
	switch(modifiers)
		if("old")
			used = getmold(soundin)
		if("young")
			used = getmyoung(soundin)
		if("silenced")
			used = getmsilenced(soundin)
	if(!used)
		switch(soundin)
			if("deathgurgle")
				used = pick('sound/vo/male/gen/deathgurgle (1).ogg','sound/vo/male/gen/deathgurgle (2).ogg','sound/vo/male/gen/deathgurgle (3).ogg')
			if("agony")
				used = list('sound/vo/male/gen/agony (1).ogg','sound/vo/male/gen/agony (2).ogg','sound/vo/male/gen/agony (4).ogg','sound/vo/male/gen/agony (5).ogg','sound/vo/male/gen/agony (6).ogg','sound/vo/male/gen/agony (7).ogg','sound/vo/male/gen/agony (8).ogg','sound/vo/male/gen/agony (9).ogg','sound/vo/male/gen/agony (10).ogg','sound/vo/male/gen/agony (3).ogg','sound/vo/male/gen/agony (11).ogg','sound/vo/male/gen/agony (12).ogg','sound/vo/male/gen/agony (13).ogg')
			if("breathgasp")
				used = list('sound/vo/male/gen/breathgasp (1).ogg','sound/vo/male/gen/breathgasp (2).ogg','sound/vo/male/gen/breathgasp (3).ogg')
			if("burp")
				used = 'sound/vo/male/gen/burp.ogg'
			if("choke")
				used = 'sound/vo/male/gen/choke.ogg'
			if("chuckle")
				used = 'sound/vo/male/gen/chuckle.ogg'
			if("clearthroat")
				used = list('sound/vo/male/gen/clearthroat (1).ogg','sound/vo/male/gen/clearthroat (2).ogg','sound/vo/male/gen/clearthroat (3).ogg')
			if("cough")
				used = list('sound/vo/male/gen/cough (1).ogg','sound/vo/male/gen/cough (2).ogg')
			if("cry")
				used = list('sound/vo/male/gen/cry (1).ogg','sound/vo/male/gen/cry (2).ogg','sound/vo/male/gen/cry (3).ogg','sound/vo/male/gen/cry (4).ogg')
			if("drown")
				used = list('sound/vo/male/gen/drown (1).ogg','sound/vo/male/gen/drown (2).ogg','sound/vo/male/gen/drown (3).ogg')
			if("embed")
				used = list('sound/vo/male/gen/embed (1).ogg','sound/vo/male/gen/embed (2).ogg','sound/vo/male/gen/embed (3).ogg')
			if("fatigue")
				used = 'sound/vo/male/gen/fatigue.ogg'
			if("firescream")
				if(prob(5))
					used = 'sound/vo/male/gen/firescream (4).ogg' //it burns!
				else
					used = list('sound/vo/male/gen/firescream (1).ogg','sound/vo/male/gen/firescream (2).ogg','sound/vo/male/gen/firescream (3).ogg')
			if("gag")
				used = list('sound/vo/male/gen/gag (1).ogg','sound/vo/male/gen/gag (2).ogg','sound/vo/male/gen/gag (3).ogg')
			if("gasp")
				used = 'sound/vo/male/gen/gasp.ogg'
			if("groin")
				used = list('sound/vo/male/gen/groin (1).ogg','sound/vo/male/gen/groin (2).ogg')
			if("groan")
				used = list('sound/vo/male/gen/groan (1).ogg','sound/vo/male/gen/groan (2).ogg','sound/vo/male/gen/groan (3).ogg','sound/vo/male/gen/groan (4).ogg','sound/vo/male/gen/groan (5).ogg','sound/vo/male/gen/groan (6).ogg')
			if("grumble")
				used = 'sound/vo/male/gen/grumble.ogg'
			if("haltyell")
				used = list('sound/vo/male/gen/haltyell (1).ogg','sound/vo/male/gen/haltyell (2).ogg')
				if(prob(3))
					used = 'sound/vo/male/gen/HEY.ogg'
			if("hmm")
				used = 'sound/vo/male/gen/hmm.ogg'
			if("huh")
				used = list('sound/vo/male/gen/huh (1).ogg','sound/vo/male/gen/huh (2).ogg','sound/vo/male/gen/huh (3).ogg')
			if("hum")
				used = list('sound/vo/male/gen/hum (1).ogg','sound/vo/male/gen/hum (2).ogg','sound/vo/male/gen/hum (3).ogg')
			if("jump")
				used = 'sound/vo/male/gen/jump.ogg'
			if("laugh")
				used = list('sound/vo/male/gen/laugh (2).ogg','sound/vo/male/gen/laugh (3).ogg','sound/vo/male/gen/laugh (4).ogg','sound/vo/male/gen/laugh (5).ogg','sound/vo/male/gen/laugh (6).ogg')
			if("leap")
				used = 'sound/vo/male/gen/leap.ogg'
			if("pain")
				used = list('sound/vo/male/gen/pain (1).ogg','sound/vo/male/gen/pain (2).ogg','sound/vo/male/gen/pain (3).ogg')
			if("paincrit")
				used = list('sound/vo/male/gen/paincrit (1).ogg','sound/vo/male/gen/paincrit (2).ogg')
			if("painmoan")
				used = list('sound/vo/male/gen/painmoan (1).ogg','sound/vo/male/gen/painmoan (2).ogg','sound/vo/male/gen/painmoan (3).ogg','sound/vo/male/gen/painmoan (4).ogg','sound/vo/male/gen/painmoan (5).ogg')
			if("painscream")
				used = list('sound/vo/male/gen/painscream (1).ogg','sound/vo/male/gen/painscream (2).ogg','sound/vo/male/gen/painscream (3).ogg')
			if("rage")
				used = list('sound/vo/male/gen/rage (1).ogg','sound/vo/male/gen/rage (2).ogg')
			if("scream")
				used = list('sound/vo/male/gen/scream (1).ogg','sound/vo/male/gen/scream (2).ogg')
				if(prob(1))
					used = 'sound/vo/male/wilhelm_scream.ogg'
			if("shh")
				used = 'sound/vo/male/gen/shh.ogg'
			if("sigh")
				used = 'sound/vo/male/gen/sigh.ogg'
			if("snore")
				used = list('sound/vo/male/gen/snore (1).ogg','sound/vo/male/gen/snore (2).ogg','sound/vo/male/gen/snore (3).ogg','sound/vo/male/gen/snore (4).ogg')
			if("whimper")
				used = list('sound/vo/male/gen/whimper (1).ogg','sound/vo/male/gen/whimper (2).ogg','sound/vo/male/gen/whimper (3).ogg')
			if("whistle")
				used = list('sound/vo/male/gen/whistle (1).ogg','sound/vo/male/gen/whistle (2).ogg','sound/vo/male/gen/whistle (3).ogg')
			if("yawn")
				used = list('sound/vo/male/gen/yawn (1).ogg','sound/vo/male/gen/yawn (2).ogg')
			if("attnwhistle")
				used = 'sound/vo/attn.ogg'
			if("psst")
				used = 'sound/vo/psst.ogg'

	return used