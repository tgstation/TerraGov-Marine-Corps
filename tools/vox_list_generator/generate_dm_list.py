import os

directory = 'sound/vox'

folders = next(os.walk(directory))[1]

for i in folders:
    string = "list(\n"
    for voxFile in next(os.walk(f"{directory}/{i}"))[2]:
        string += f"\t\"{os.path.splitext(voxFile)[0]}\" = '{directory}/{i}/{voxFile}',\n"
    string += ")"
    with open(f"tools/vox_list_generator/{i}.dm", "w") as f:
        f.write(string)
        print(f"Generated {directory}/{i}.dm")

input("Press enter to close.")
