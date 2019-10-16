/*
IconProcs README

A BYOND library for manipulating icons and colors

by Lummox JR

version 1.0

The IconProcs library was made to make a lot of common icon operations much easier. BYOND's icon manipulation
routines are very capable but some of the advanced capabilities like using alpha transparency can be unintuitive to beginners.

CHANGING ICONS

Several new procs have been added to the /icon datum to simplify working with icons. To use them,
remember you first need to setup an /icon var like so:

GLOBAL_DATUM_INIT(my_icon, /icon, new('iconfile.dmi'))

icon/ChangeOpacity(amount = 1)
	A very common operation in DM is to try to make an icon more or less transparent. Making an icon more
	transparent is usually much easier than making it less so, however. This proc basically is a frontend
	for MapColors() which can change opacity any way you like, in much the same way that SetIntensity()
	can make an icon lighter or darker. If amount is 0.5, the opacity of the icon will be cut in half.
	If amount is 2, opacity is doubled and anything more than half-opaque will become fully opaque.
icon/GrayScale()
	Converts the icon to grayscale instead of a fully colored icon. Alpha values are left intact.
icon/ColorTone(tone)
	Similar to GrayScale(), this proc converts the icon to a range of black -> tone -> white, where tone is an
	RGB color (its alpha is ignored). This can be used to create a sepia tone or similar effect.
	See also the global ColorTone() proc.
icon/MinColors(icon)
	The icon is blended with a second icon where the minimum of each RGB pixel is the result.
	Transparency may increase, as if the icons were blended with ICON_ADD. You may supply a color in place of an icon.
icon/MaxColors(icon)
	The icon is blended with a second icon where the maximum of each RGB pixel is the result.
	Opacity may increase, as if the icons were blended with ICON_OR. You may supply a color in place of an icon.
icon/Opaque(background = "#000000")
	All alpha values are set to 255 throughout the icon. Transparent pixels become black, or whatever background color you specify.
icon/BecomeAlphaMask()
	You can convert a simple grayscale icon into an alpha mask to use with other icons very easily with this proc.
	The black parts become transparent, the white parts stay white, and anything in between becomes a translucent shade of white.
icon/AddAlphaMask(mask)
	The alpha values of the mask icon will be blended with the current icon. Anywhere the mask is opaque,
	the current icon is untouched. Anywhere the mask is transparent, the current icon becomes transparent.
	Where the mask is translucent, the current icon becomes more transparent.
icon/UseAlphaMask(mask, mode)
	Sometimes you may want to take the alpha values from one icon and use them on a different icon.
	This proc will do that. Just supply the icon whose alpha mask you want to use, and src will change
	so it has the same colors as before but uses the mask for opacity.

COLOR MANAGEMENT AND HSV

RGB isn't the only way to represent color. Sometimes it's more useful to work with a model called HSV, which stands for hue, saturation, and value.

	* The hue of a color describes where it is along the color wheel. It goes from red to yellow to green to
	cyan to blue to magenta and back to red.
	* The saturation of a color is how much color is in it. A color with low saturation will be more gray,
	and with no saturation at all it is a shade of gray.
	* The value of a color determines how bright it is. A high-value color is vivid, moderate value is dark,
	and no value at all is black.

Just as BYOND uses "#rrggbb" to represent RGB values, a similar format is used for HSV: "#hhhssvv". The hue is three
hex digits because it ranges from 0 to 0x5FF.

	* 0 to 0xFF - red to yellow
	* 0x100 to 0x1FF - yellow to green
	* 0x200 to 0x2FF - green to cyan
	* 0x300 to 0x3FF - cyan to blue
	* 0x400 to 0x4FF - blue to magenta
	* 0x500 to 0x5FF - magenta to red

Knowing this, you can figure out that red is "#000ffff" in HSV format, which is hue 0 (red), saturation 255 (as colorful as possible),
value 255 (as bright as possible). Green is "#200ffff" and blue is "#400ffff".

More than one HSV color can match the same RGB color.

Here are some procs you can use for color management:

ReadRGB(rgb)
	Takes an RGB string like "#ffaa55" and converts it to a list such as list(255,170,85). If an RGBA format is used
	that includes alpha, the list will have a fourth item for the alpha value.
hsv(hue, sat, val, apha)
	Counterpart to rgb(), this takes the values you input and converts them to a string in "#hhhssvv" or "#hhhssvvaa"
	format. Alpha is not included in the result if null.
ReadHSV(rgb)
	Takes an HSV string like "#100FF80" and converts it to a list such as list(256,255,128). If an HSVA format is used that
	includes alpha, the list will have a fourth item for the alpha value.
RGBtoHSV(rgb)
	Takes an RGB or RGBA string like "#ffaa55" and converts it into an HSV or HSVA color such as "#080aaff".
HSVtoRGB(hsv)
	Takes an HSV or HSVA string like "#080aaff" and converts it into an RGB or RGBA color such as "#ff55aa".
BlendRGB(rgb1, rgb2, amount)
	Blends between two RGB or RGBA colors using regular RGB blending. If amount is 0, the first color is the result;
	if 1, the second color is the result. 0.5 produces an average of the two. Values outside the 0 to 1 range are allowed as well.
	The returned value is an RGB or RGBA color.
BlendHSV(hsv1, hsv2, amount)
	Blends between two HSV or HSVA colors using HSV blending, which tends to produce nicer results than regular RGB
	blending because the brightness of the color is left intact. If amount is 0, the first color is the result; if 1,
	the second color is the result. 0.5 produces an average of the two. Values outside the 0 to 1 range are allowed as well.
	The returned value is an HSV or HSVA color.
BlendRGBasHSV(rgb1, rgb2, amount)
	Like BlendHSV(), but the colors used and the return value are RGB or RGBA colors. The blending is done in HSV form.
HueToAngle(hue)
	Converts a hue to an angle range of 0 to 360. Angle 0 is red, 120 is green, and 240 is blue.
AngleToHue(hue)
	Converts an angle to a hue in the valid range.
RotateHue(hsv, angle)
	Takes an HSV or HSVA value and rotates the hue forward through red, green, and blue by an angle from 0 to 360.
	(Rotating red by 60° produces yellow.) The result is another HSV or HSVA color with the same saturation and value
	as the original, but a different hue.
GrayScale(rgb)
	Takes an RGB or RGBA color and converts it to grayscale. Returns an RGB or RGBA string.
ColorTone(rgb, tone)
	Similar to GrayScale(), this proc converts an RGB or RGBA color to a range of black -> tone -> white instead of
	using strict shades of gray. The tone value is an RGB color; any alpha value is ignored.
*/


#define TO_HEX_DIGIT(n) ascii2text((n&15) + ((n&15)<10 ? 48 : 87))


/icon/proc/BecomeLying()
	Turn(90)
	Shift(SOUTH,6)
	Shift(EAST,1)


// Multiply all alpha values by this float
/icon/proc/ChangeOpacity(opacity = 1)
	MapColors(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,opacity, 0,0,0,0)


// Convert to grayscale
/icon/proc/GrayScale()
	MapColors(0.3,0.3,0.3, 0.59,0.59,0.59, 0.11,0.11,0.11, 0,0,0)


/icon/proc/ColorTone(tone)
	GrayScale()

	var/list/TONE = ReadRGB(tone)
	var/gray = round(TONE[1]*0.3 + TONE[2]*0.59 + TONE[3]*0.11, 1)

	var/icon/upper = (255-gray) ? new(src) : null

	if(gray)
		MapColors(255/gray,0,0, 0,255/gray,0, 0,0,255/gray, 0,0,0)
		Blend(tone, ICON_MULTIPLY)
	else 
		SetIntensity(0)
	if(255-gray)
		upper.Blend(rgb(gray,gray,gray), ICON_SUBTRACT)
		upper.MapColors((255-TONE[1])/(255-gray),0,0,0, 0,(255-TONE[2])/(255-gray),0,0, 0,0,(255-TONE[3])/(255-gray),0, 0,0,0,0, 0,0,0,1)
		Blend(upper, ICON_ADD)


// Take the minimum color of two icons; combine transparency as if blending with ICON_ADD
/icon/proc/MinColors(icon)
	var/icon/I = new(src)
	I.Opaque()
	I.Blend(icon, ICON_SUBTRACT)
	Blend(I, ICON_SUBTRACT)


// Take the maximum color of two icons; combine opacity as if blending with ICON_OR
/icon/proc/MaxColors(icon)
	var/icon/I
	if(isicon(icon))
		I = new(icon)
	else
		// solid color
		I = new(src)
		I.Blend("#000000", ICON_OVERLAY)
		I.SwapColor("#000000", null)
		I.Blend(icon, ICON_OVERLAY)
	var/icon/J = new(src)
	J.Opaque()
	I.Blend(J, ICON_SUBTRACT)
	Blend(I, ICON_OR)


// make this icon fully opaque--transparent pixels become black
/icon/proc/Opaque(background = "#000000")
	SwapColor(null, background)
	MapColors(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,0, 0,0,0,1)


// Change a grayscale icon into a white icon where the original color becomes the alpha
// I.e., black -> transparent, gray -> translucent white, white -> solid white
/icon/proc/BecomeAlphaMask()
	SwapColor(null, "#000000ff")	// don't let transparent become gray
	MapColors(0,0,0,0.3, 0,0,0,0.59, 0,0,0,0.11, 0,0,0,0, 1,1,1,0)


/icon/proc/UseAlphaMask(mask)
	Opaque()
	AddAlphaMask(mask)


/icon/proc/AddAlphaMask(mask)
	var/icon/M = new(mask)
	M.Blend("#ffffff", ICON_SUBTRACT)
	// apply mask
	Blend(M, ICON_ADD)


/*
	HSV format is represented as "#hhhssvv" or "#hhhssvvaa"

	Hue ranges from 0 to 0x5ff (1535)

		0x000 = red
		0x100 = yellow
		0x200 = green
		0x300 = cyan
		0x400 = blue
		0x500 = magenta

	Saturation is from 0 to 0xff (255)

		More saturation = more color
		Less saturation = more gray

	Value ranges from 0 to 0xff (255)

		Higher value means brighter color
*/


/proc/ReadRGB(rgb)
	if(!rgb)
		return

	// interpret the HSV or HSVA value
	var/start = 1
	if(text2ascii(rgb) == 35)
		start++ // skip opening #
	var/ch
	var/digits = 0
	for(var/i = start to length(rgb))
		ch = text2ascii(rgb, i)
		switch(ch)
			if(-INFINITY to 47, 58 to 64, 71 to 96, 103 to INFINITY)
				break
		if(++digits == 8)
			break

	var/usealpha = FALSE
	var/single = digits < 6
	switch(digits)
		if(4, 8)
			usealpha = TRUE
		if(3, 6) //proceed as normal
		else
			return

	var/which = 0
	var/alpha = 0
	var/r = 0
	var/g = 0
	var/b = 0
	while(digits)
		ch = text2ascii(rgb, start++)
		switch(ch)
			if(48 to 57)
				ch -= 48
			if(65 to 70)
				ch -= 55
			if(97 to 102)
				ch -= 87
			else
				break
		digits--
		switch(which)
			if(0)
				r = (r << 4) | ch
				if(single)
					r |= r << 4
					which++
				else if(!(digits & 1))
					which++
			if(1)
				g = (g << 4) | ch
				if(single)
					g |= g << 4
					which++
				else if(!(digits & 1))
					which++
			if(2)
				b = (b << 4) | ch
				if(single)
					b |= b << 4
					which++
				else if(!(digits & 1))
					which++
			if(3)
				alpha = (alpha << 4) | ch
				if(single)
					alpha |= alpha << 4

	. = list(r, g, b)
	if(usealpha)
		. += alpha


/proc/ReadHSV(hsv)
	if(!hsv)
		return

	// interpret the HSV or HSVA value
	var/start = 1
	if(text2ascii(hsv) == 35)
		start++ // skip opening #
	var/ch
	var/digits = 0
	for(var/i = start to length(hsv))
		ch = text2ascii(hsv, i)
		switch(ch)
			if(-INFINITY to 47, 58 to 64, 71 to 96, 103 to INFINITY)
				break
		if(++digits == 9)
			break

	var/usealpha = FALSE
	var/which = 0
	if(digits >= 8)
		usealpha = TRUE
	else
		if(digits <= 4)
			which++
		if(digits <= 2)
			which++
	
	var/hue = 0
	var/sat = 0
	var/val = 0
	var/alpha = 0
	while(digits)
		ch = text2ascii(hsv, start++)
		switch(ch)
			if(48 to 57)
				ch -= 48
			if(65 to 70)
				ch -= 55
			if(97 to 102)
				ch -= 87
			else
				break
		digits--
		switch(which)
			if(0)
				hue = (hue << 4) | ch
				if(digits == (usealpha ? 6 : 4))
					++which
			if(1)
				sat = (sat << 4) | ch
				if(digits == (usealpha ? 4 : 2))
					++which
			if(2)
				val = (val << 4) | ch
				if(digits == (usealpha ? 2 : 0))
					++which
			if(3)
				alpha = (alpha << 4) | ch

	. = list(hue, sat, val)
	if(usealpha)
		. += alpha


/proc/HSVtoRGB(hsv)
	if(!hsv)
		return "#000000"
	var/list/HSV = ReadHSV(hsv)
	if(!HSV)
		return "#000000"

	var/hue = HSV[1]
	var/sat = HSV[2]
	var/val = HSV[3]

	// Compress hue into easier-to-manage range
	hue -= hue >> 8
	if(hue >= 0x5fa)
		hue -= 0x5fa

	var/hi
	var/mid
	var/lo
	var/r
	var/g
	var/b
	hi = val
	lo = round((255 - sat) * val / 255)
	mid = lo + round(abs(round(hue, 510) - hue) * (hi - lo) / 255)
	switch(hue)
		if(1275 to INFINITY)
			r = hi
			g = lo
			b = mid
		if(1020 to 1274)
			r = mid
			g = lo
			b = hi
		if(765 to 1019)
			r = lo
			g = mid
			b = hi
		if(510 to 764)
			r = lo
			g = hi
			b = mid
		if(255 to 509)
			r = mid
			g = hi
			b = lo
		else
			r = hi
			g = mid
			b = lo

	return (HSV.len > 3) ? rgb(r,g,b,HSV[4]) : rgb(r,g,b)


/proc/RGBtoHSV(rgb)
	if(!rgb)
		return "#0000000"
	var/list/RGB = ReadRGB(rgb)
	if(!RGB)
		return "#0000000"

	var/r = RGB[1]
	var/g = RGB[2]
	var/b = RGB[3]
	var/hi = max(r,g,b)
	var/lo = min(r,g,b)

	var/val = hi
	var/sat = hi ? round((hi-lo) * 255 / hi) : 0
	var/hue = 0

	if(sat)
		var/dir
		var/mid
		if(hi == r)
			if(lo == b)
				hue = 0
				dir = 1
				mid = g
			else
				hue = 1535
				dir =- 1
				mid = b
		else if(hi == g)
			if(lo == r)
				hue = 512
				dir = 1
				mid = b
			else
				hue = 511
				dir =- 1
				mid = r
		else
			if(lo == g)
				hue = 1024
				dir = 1
				mid = r
			else
				hue = 1023
				dir = -1
				mid = g
		hue += dir * round((mid-lo) * 255 / (hi-lo))

	return hsv(hue, sat, val, (length(RGB) > 3 ? RGB[4] : null))


/proc/hsv(hue, sat, val, alpha)
	if(hue < 0 || hue >= 1536)
		hue %= 1536
	if(hue < 0)
		hue += 1536
	if((hue & 0xFF) == 0xFF)
		hue++
		if(hue >= 1536)
			hue = 0
	sat = CLAMP(sat, 0, 255)
	val = CLAMP(val, 0, 255)
	. = "#"
	. += TO_HEX_DIGIT(hue >> 8)
	. += TO_HEX_DIGIT(hue >> 4)
	. += TO_HEX_DIGIT(hue)
	. += TO_HEX_DIGIT(sat >> 4)
	. += TO_HEX_DIGIT(sat)
	. += TO_HEX_DIGIT(val >> 4)
	. += TO_HEX_DIGIT(val)
	if(!isnull(alpha))
		alpha = CLAMP(alpha, 0, 255)
		. += TO_HEX_DIGIT(alpha >> 4)
		. += TO_HEX_DIGIT(alpha)


/*
	Smooth blend between HSV colors

	amount=0 is the first color
	amount=1 is the second color
	amount=0.5 is directly between the two colors

	amount<0 or amount>1 are allowed
*/


/proc/BlendHSV(hsv1, hsv2, amount)
	var/list/HSV1 = ReadHSV(hsv1)
	var/list/HSV2 = ReadHSV(hsv2)

	// add missing alpha if needed
	if(length(HSV1) < length(HSV2))
		HSV1 += 255
	else if(length(HSV2) < length(HSV1))
		HSV2 += 255
	var/usealpha = length(HSV1) > 3

	// normalize hsv values in case anything is screwy
	if(!HSV1[3])
		HSV1[1] = 0
		HSV1[2] = 0
	else
		if(HSV1[1] > 1536)
			HSV1[1] %= 1536
		if(HSV1[1] < 0)
			HSV1[1] += 1536
	if(!HSV2[3])
		HSV2[1] = 0
		HSV2[2] = 0
	else
		if(HSV2[1] > 1536)
			HSV2[1] %= 1536
		if(HSV2[1] < 0)
			HSV2[1] += 1536

	// no value for one color means don't change saturation
	if(!HSV1[3])
		HSV1[2] = HSV2[2]
	if(!HSV2[3])
		HSV2[2] = HSV1[2]
	// no saturation for one color means don't change hues
	if(!HSV1[2])
		HSV1[1] = HSV2[1]
	if(!HSV2[2])
		HSV2[1] = HSV1[1]

	// Compress hues into easier-to-manage range
	HSV1[1] -= HSV1[1] >> 8
	HSV2[1] -= HSV2[1] >> 8

	var/hue_diff = HSV2[1] - HSV1[1]
	if(hue_diff > 765)
		hue_diff -= 1530
	else if(hue_diff <= -765)
		hue_diff += 1530

	var/hue = round(HSV1[1] + hue_diff * amount)
	var/sat = round(HSV1[2] + (HSV2[2] - HSV1[2]) * amount)
	var/val = round(HSV1[3] + (HSV2[3] - HSV1[3]) * amount)
	var/alpha = usealpha ? round(HSV1[4] + (HSV2[4] - HSV1[4]) * amount) : null

	// normalize hue
	if(hue < 0 || hue >= 1530)
		hue %= 1530
	if(hue < 0)
		hue += 1530
	// decompress hue
	hue += round(hue / 255)

	return hsv(hue, sat, val, alpha)


/*
	Smooth blend between RGB colors

	amount=0 is the first color
	amount=1 is the second color
	amount=0.5 is directly between the two colors

	amount<0 or amount>1 are allowed
*/


/proc/BlendRGB(rgb1, rgb2, amount)
	var/list/RGB1 = ReadRGB(rgb1)
	var/list/RGB2 = ReadRGB(rgb2)

	// add missing alpha if needed
	if(length(RGB1) < length(RGB2))
		RGB1 += 255
	else if(length(RGB2) < length(RGB1))
		RGB2 += 255
	var/usealpha = length(RGB1) > 3

	var/r = round(RGB1[1] + (RGB2[1] - RGB1[1]) * amount, 1)
	var/g = round(RGB1[2] + (RGB2[2] - RGB1[2]) * amount, 1)
	var/b = round(RGB1[3] + (RGB2[3] - RGB1[3]) * amount, 1)
	var/alpha = usealpha ? round(RGB1[4] + (RGB2[4] - RGB1[4]) * amount, 1) : null

	return isnull(alpha) ? rgb(r, g, b) : rgb(r, g, b, alpha)


/proc/BlendRGBasHSV(rgb1, rgb2, amount)
	return HSVtoRGB(RGBtoHSV(rgb1), RGBtoHSV(rgb2), amount)


/proc/HueToAngle(hue)
	// normalize hsv in case anything is screwy
	if(hue < 0 || hue >= 1536)
		hue %= 1536
	if(hue < 0)
		hue += 1536
	// Compress hue into easier-to-manage range
	hue -= hue >> 8
	return hue / (1530/360)


/proc/AngleToHue(angle)
	// normalize hsv in case anything is screwy
	if(angle < 0 || angle >= 360)
		angle -= 360 * round(angle / 360)
	var/hue = angle * (1530/360)
	// Decompress hue
	hue += round(hue / 255)
	return hue



// positive angle rotates forward through red->green->blue
/proc/RotateHue(hsv, angle)
	var/list/HSV = ReadHSV(hsv)

	// normalize hsv in case anything is screwy
	if(HSV[1] >= 1536)
		HSV[1] %= 1536
	if(HSV[1] < 0)
		HSV[1] += 1536

	// Compress hue into easier-to-manage range
	HSV[1] -= HSV[1] >> 8

	if(angle < 0 || angle >= 360)
		angle -= 360 * round(angle / 360)
	HSV[1] = round(HSV[1] + angle * (1530/360), 1)

	// normalize hue
	if(HSV[1] < 0 || HSV[1] >= 1530)
		HSV[1] %= 1530
	if(HSV[1] < 0)
		HSV[1] += 1530
	// decompress hue
	HSV[1] += round(HSV[1] / 255)

	return hsv(HSV[1], HSV[2], HSV[3], (length(HSV) > 3 ? HSV[4] : null))


// Convert an rgb color to grayscale
/proc/GrayScale(rgb)
	var/list/RGB = ReadRGB(rgb)
	var/gray = RGB[1] * 0.3 + RGB[2] * 0.59 + RGB[3] * 0.11
	return (length(RGB) > 3) ? rgb(gray, gray, gray, RGB[4]) : rgb(gray, gray, gray)


// Change grayscale color to black->tone->white range
/proc/ColorTone(rgb, tone)
	var/list/RGB = ReadRGB(rgb)
	var/list/TONE = ReadRGB(tone)

	var/gray = RGB[1] * 0.3 + RGB[2] * 0.59 + RGB[3] * 0.11
	var/tone_gray = TONE[1]*0.3 + TONE[2]*0.59 + TONE[3]*0.11

	if(gray <= tone_gray)
		return BlendRGB("#000000", tone, gray / (tone_gray || 1))
	else
		return BlendRGB(tone, "#ffffff", (gray - tone_gray) / ((255 - tone_gray) || 1))


// Creates a single icon from a given /atom or /image.  Only the first argument is required.
/proc/getFlatIcon(image/A, defdir, deficon, defstate, defblend, start = TRUE, no_anim = FALSE)
	//Define... defines.
	var/static/icon/flat_template = icon('icons/effects/effects.dmi', "nothing")

	#define BLANK icon(flat_template)
	#define SET_SELF(SETVAR) do { \
		var/icon/SELF_ICON = icon(icon(curicon, curstate, base_icon_dir), "", SOUTH, no_anim ? 1 : null); \
		if(A.alpha < 255) { \
			SELF_ICON.Blend(rgb(255, 255, 255, A.alpha), ICON_MULTIPLY);\
		} \
		if(A.color) { \
			if(islist(A.color)){ \
				SELF_ICON.MapColors(arglist(A.color))} \
			else{ \
				SELF_ICON.Blend(A.color, ICON_MULTIPLY)} \
		} \
		##SETVAR=SELF_ICON;\
		} while (0)
	#define INDEX_X_LOW 1
	#define INDEX_X_HIGH 2
	#define INDEX_Y_LOW 3
	#define INDEX_Y_HIGH 4

	#define flatX1 flat_size[INDEX_X_LOW]
	#define flatX2 flat_size[INDEX_X_HIGH]
	#define flatY1 flat_size[INDEX_Y_LOW]
	#define flatY2 flat_size[INDEX_Y_HIGH]
	#define addX1 add_size[INDEX_X_LOW]
	#define addX2 add_size[INDEX_X_HIGH]
	#define addY1 add_size[INDEX_Y_LOW]
	#define addY2 add_size[INDEX_Y_HIGH]

	if(!A || A.alpha <= 0)
		return BLANK

	var/noIcon = FALSE
	if(start)
		if(!defdir)
			defdir = A.dir
		if(!deficon)
			deficon = A.icon
		if(!defstate)
			defstate = A.icon_state
		if(!defblend)
			defblend = A.blend_mode

	var/curicon = A.icon || deficon
	var/curstate = A.icon_state || defstate

	if(!((noIcon = (!curicon))))
		var/curstates = icon_states(curicon)
		if(!(curstate in curstates))
			if("" in curstates)
				curstate = ""
			else
				noIcon = TRUE // Do not render this object.

	var/curdir
	var/base_icon_dir	//We'll use this to get the icon state to display if not null BUT NOT pass it to overlays as the dir we have

	//These should use the parent's direction (most likely)
	if(!A.dir || A.dir == SOUTH)
		curdir = defdir
	else
		curdir = A.dir

	//Try to remove/optimize this section ASAP, CPU hog.
	//Determines if there's directionals.
	if(!noIcon && curdir != SOUTH)
		var/exist = FALSE
		var/static/list/checkdirs = list(NORTH, EAST, WEST)
		for(var/i in checkdirs)		//Not using GLOB for a reason.
			if(length(icon_states(icon(curicon, curstate, i))))
				exist = TRUE
				break
		if(!exist)
			base_icon_dir = SOUTH
	//

	if(!base_icon_dir)
		base_icon_dir = curdir

	ASSERT(!BLEND_DEFAULT)		//I might just be stupid but lets make sure this define is 0.

	var/curblend = A.blend_mode || defblend

	if(length(A.overlays) || length(A.underlays))
		var/icon/flat = BLANK
		// Layers will be a sorted list of icons/overlays, based on the order in which they are displayed
		var/list/layers = list()
		var/image/copy
		// Add the atom's icon itself, without pixel_x/y offsets.
		if(!noIcon)
			copy = image(icon = curicon, icon_state = curstate, layer = A.layer, dir = base_icon_dir)
			copy.color = A.color
			copy.alpha = A.alpha
			copy.blend_mode = curblend
			layers[copy] = A.layer

		// Loop through the underlays, then overlays, sorting them into the layers list
		for(var/process_set in 0 to 1)
			var/list/process = process_set ? A.overlays : A.underlays
			for(var/i in 1 to length(process))
				var/image/current = process[i]
				if(!current)
					continue
				if(current.plane != FLOAT_PLANE && current.plane != A.plane)
					continue
				var/current_layer = current.layer
				if(current_layer < 0)
					if(current_layer <= -1000)
						return flat
					current_layer = process_set + A.layer + current_layer / 1000

				for(var/p in 1 to layers.len)
					var/image/cmp = layers[p]
					if(current_layer < layers[cmp])
						layers.Insert(p, current)
						break
				layers[current] = current_layer

		//sortTim(layers, /proc/cmp_image_layer_asc)

		var/icon/add // Icon of overlay being added

		// Current dimensions of flattened icon
		var/list/flat_size = list(1, flat.Width(), 1, flat.Height())
		// Dimensions of overlay being added
		var/list/add_size[4]

		for(var/V in layers)
			var/image/I = V
			if(I.alpha == 0)
				continue

			if(I == copy) // 'I' is an /image based on the object being flattened.
				curblend = BLEND_OVERLAY
				add = icon(I.icon, I.icon_state, base_icon_dir)
			else // 'I' is an appearance object.
				add = getFlatIcon(image(I), curdir, curicon, curstate, curblend, FALSE, no_anim)
			if(!add)
				continue
			// Find the new dimensions of the flat icon to fit the added overlay
			add_size = list(
				min(flatX1, I.pixel_x+1),
				max(flatX2, I.pixel_x+add.Width()),
				min(flatY1, I.pixel_y+1),
				max(flatY2, I.pixel_y+add.Height())
			)

			if(flat_size ~! add_size)
				// Resize the flattened icon so the new icon fits
				flat.Crop(
				addX1 - flatX1 + 1,
				addY1 - flatY1 + 1,
				addX2 - flatX1 + 1,
				addY2 - flatY1 + 1
				)
				flat_size = add_size.Copy()

			// Blend the overlay into the flattened icon
			flat.Blend(add, blendMode2iconMode(curblend), I.pixel_x + 2 - flatX1, I.pixel_y + 2 - flatY1)

		if(A.color)
			if(islist(A.color))
				flat.MapColors(arglist(A.color))
			else
				flat.Blend(A.color, ICON_MULTIPLY)

		if(A.alpha < 255)
			flat.Blend(rgb(255, 255, 255, A.alpha), ICON_MULTIPLY)

		if(no_anim)
			//Clean up repeated frames
			var/icon/cleaned = new /icon()
			cleaned.Insert(flat, "", SOUTH, 1, 0)
			. = cleaned
		else
			. = icon(flat, "", SOUTH)
	else	//There's no overlays.
		if(!noIcon)
			SET_SELF(.)

	//Clear defines
	#undef flatX1
	#undef flatX2
	#undef flatY1
	#undef flatY2
	#undef addX1
	#undef addX2
	#undef addY1
	#undef addY2

	#undef INDEX_X_LOW
	#undef INDEX_X_HIGH
	#undef INDEX_Y_LOW
	#undef INDEX_Y_HIGH

	#undef BLANK
	#undef SET_SELF


/proc/getHologramIcon(icon/A, safety = TRUE)//If safety is on, a new icon is not created.
	var/icon/flat_icon = safety ? A : new(A)//Has to be a new icon to not constantly change the same icon.
	flat_icon.ColorTone(rgb(125,180,225))//Let's make it bluish.
	flat_icon.ChangeOpacity(0.5)//Make it half transparent.
	var/icon/alpha_mask = new('icons/effects/effects.dmi', "scanline")//Scanline effect.
	flat_icon.AddAlphaMask(alpha_mask)//Finally, let's mix in a distortion effect.
	return flat_icon


/proc/adjust_brightness(color, value)
	if(!color)
		return "#FFFFFF"

	if(!value)
		return color

	var/list/RGB = ReadRGB(color)
	RGB[1] = CLAMP(RGB[1] + value, 0, 255)
	RGB[2] = CLAMP(RGB[2] + value, 0, 255)
	RGB[3] = CLAMP(RGB[3] + value, 0, 255)
	return rgb(RGB[1], RGB[2], RGB[3])


/proc/sort_atoms_by_layer(list/L)
	// Comb sort icons based on levels
	var/list/result = L.Copy()
	var/gap = length(L)
	var/swapped = TRUE
	while(gap > 1 || swapped)
		swapped = FALSE
		if(gap > 1)
			gap = round(gap / 1.3) // 1.3 is the emperic comb sort coefficient
		if(gap < 1)
			gap = 1
		for(var/i = 1; gap + i <= length(result); i++)
			var/atom/l = result[i]		//Fucking hate
			var/atom/r = result[gap+i]	//how lists work here
			if(l.layer > r.layer)		//no "result[i].layer" for me
				result.Swap(i, gap + i)
				swapped = TRUE
	return result


//Hook, override to run code on- wait this is images
//Images have dir without being an atom, so they get their own definition.
//Lame.
/image/proc/setDir(newdir)
	dir = newdir



//Converts an icon to base64. Operates by putting the icon in the iconCache savefile,
// exporting it as text, and then parsing the base64 from that.
// (This relies on byond automatically storing icons in savefiles as base64)
/proc/icon2base64(icon/icon, iconKey = "misc")
	if(!isicon(icon))
		return FALSE
	WRITE_FILE(GLOB.iconCache[iconKey], icon)
	var/iconData = GLOB.iconCache.ExportText(iconKey)
	var/list/partial = splittext(iconData, "{")
	return replacetext(copytext(partial[2], 3, -5), "\n", "")


/proc/icon2html(thing, target, icon_state, dir, frame = 1, moving = FALSE)
	if(!thing)
		return

	var/key
	var/icon/I = thing
	if(!target)
		return
	if(target == world)
		target = GLOB.clients

	var/list/targets
	if(!islist(target))
		targets = list(target)
	else
		targets = target
		if(!length(targets))
			return
	if(!isicon(I))
		if(isfile(thing)) //special snowflake
			var/name = sanitize_filename("[generate_asset_name(thing)].png")
			register_asset(name, thing)
			for(var/thing2 in targets)
				send_asset(thing2, key, FALSE)
			return "<img class='icon icon-misc' src=\"[url_encode(name)]\">"
		var/atom/A = thing
		if(isnull(dir))
			dir = A.dir
		if(isnull(icon_state))
			icon_state = A.icon_state
		I = A.icon
		if(ishuman(thing)) // Shitty workaround for a BYOND issue.
			var/icon/temp = I
			I = icon()
			I.Insert(temp, dir = SOUTH)
			dir = SOUTH
	else
		if(isnull(dir))
			dir = SOUTH
		if(isnull(icon_state))
			icon_state = ""

	I = icon(I, icon_state, dir, frame, moving)

	key = "[generate_asset_name(I)].png"
	register_asset(key, I)
	for(var/thing2 in targets)
		send_asset(thing2, key, FALSE)

	return "<img class='icon icon-[icon_state]' src=\"[url_encode(key)]\">"


/proc/icon2base64html(thing)
	if(!thing)
		return
	var/static/list/bicon_cache = list()
	if(isicon(thing))
		var/icon/I = thing
		var/icon_base64 = icon2base64(I)

		if(I.Height() > world.icon_size || I.Width() > world.icon_size)
			var/icon_md5 = md5(icon_base64)
			icon_base64 = bicon_cache[icon_md5]
			if(!icon_base64) // Doesn't exist yet, make it.
				bicon_cache[icon_md5] = icon_base64 = icon2base64(I)


		return "<img class='icon icon-misc' src='data:image/png;base64,[icon_base64]'>"

	// Either an atom or somebody fucked up and is gonna get a runtime, which I'm fine with.
	var/atom/A = thing
	var/key = "[istype(A.icon, /icon) ? "[REF(A.icon)]" : A.icon]:[A.icon_state]"


	if(!bicon_cache[key]) // Doesn't exist, make it.
		var/icon/I = icon(A.icon, A.icon_state, SOUTH, 1)
		if(ishuman(thing)) // Shitty workaround for a BYOND issue.
			var/icon/temp = I
			I = icon()
			I.Insert(temp, dir = SOUTH)

		bicon_cache[key] = icon2base64(I, key)

	return "<img class='icon icon-[A.icon_state]' src='data:image/png;base64,[bicon_cache[key]]'>"


//Costlier version of icon2html() that uses getFlatIcon() to account for overlays, underlays, etc. Use with extreme moderation, ESPECIALLY on mobs.
/proc/costly_icon2html(thing, target)
	if(!thing)
		return

	if(isicon(thing))
		return icon2html(thing, target)

	var/icon/I = getFlatIcon(thing)
	return icon2html(I, target)


//For creating consistent icons for human looking simple animals
/proc/get_flat_human_icon(icon_id, datum/job/J, datum/preferences/prefs, dummy_key, showDirs = GLOB.cardinals, outfit_override)
	var/static/list/humanoid_icon_cache = list()
	if(!icon_id || !humanoid_icon_cache[icon_id])
		var/mob/living/carbon/human/dummy/body = generate_or_wait_for_human_dummy(dummy_key)

		prefs?.copy_to(body,TRUE,FALSE)

		J?.equip(body, TRUE, FALSE, outfit_override = outfit_override)

		if(outfit_override)
			body.equipOutfit(outfit_override,visualsOnly = TRUE)


		var/icon/out_icon = icon('icons/effects/effects.dmi', "nothing")
		for(var/D in showDirs)
			body.setDir(D)
			COMPILE_OVERLAYS(body)
			var/icon/partial = getFlatIcon(body)
			out_icon.Insert(partial, dir = D)

		humanoid_icon_cache[icon_id] = out_icon
		dummy_key ? unset_busy_human_dummy(dummy_key) : qdel(body)
		return out_icon
	else
		return humanoid_icon_cache[icon_id]
