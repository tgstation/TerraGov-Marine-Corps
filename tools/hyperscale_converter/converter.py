from operator import setitem
import PIL as pillow
from PIL import Image
from PIL import PngImagePlugin
from pathlib import Path
import os

parentPath = os.path.dirname(os.path.dirname(os.path.dirname(__file__))) #gets the TGMC directory
path = input("File path of .dmi (Relative to the repository directory): ")
full_path = os.path.join(parentPath, path).replace('\\', '/')
try :
	image = PngImagePlugin.PngImageFile
	image = PngImagePlugin.PngImageFile(full_path)

	metadata = image.info["Description"]
	image = image.convert("L")
except FileNotFoundError :
	print("File not found.")
	exit

layers = dict()
for x in range(image.size[0]):
	for y in range(image.size[1]):
		pixel = image.getpixel((x,y))
		if pixel == 192 or pixel == 0 : continue
		newset = list()
		newset.append((x,y))
		if pixel in layers.keys() :
			layer = list
			layer = layers.get(pixel)
			layer += newset
			continue
		setitem(layers, pixel, list(newset))
		continue

for key in layers.keys() :
	newImage = Image.new(mode="L", size=image.size, color=0)
	pixelList = list
	pixelList = layers.get(key)
	pixelmap = newImage.load()
	for i in range(len(pixelList)) :
		pixel = pixelList[i]
		pixelmap[pixel[0], pixel[1]] = 255
	newpath = (os.path.dirname(__file__) + "\\output\\" + str(key) + ".png").replace('\\', '/')
	newImage.info.update({"Description":metadata})
	info = PngImagePlugin.PngInfo()
	info.add_text("Description", metadata, True)
	PngImagePlugin.PngImageFile.save(newImage, newpath, save_all=True, pnginfo=info)
	p = Path(newpath)
	p.rename(p.with_suffix('.dmi'))
print("Successfully split file into " + str(len(layers.keys())) + " sprites.")
