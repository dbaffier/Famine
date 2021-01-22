import os
import subprocess
import glob


class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


os.system("rm -rf /tmp/test/ /tmp/test2/")
print("Creating /tmp/test/ /tmp/test/2 ...")
os.system("mkdir /tmp/test/ /tmp/test2/")

print("cp /bin/* => /tmp/test/ of type [EXECUTABLE]")
target1 = glob.glob("/bin/*")
for p in target1:
    res = subprocess.run(['file', p], stdout=subprocess.PIPE)
    if b"LSB executable" in res.stdout:
        cmd = "cp " + p + " /tmp/test"
        os.system(cmd)
# target2 = glob.glob("/usr/bin/*")
# len2 = len(target2)
# print("cp /bin/* => /tmp/test/2 of type [EXECUTABLE]")
# for p in target2:
#     res = subprocess.run(['file', p], stdout=subprocess.PIPE)
    # if b"shared" not in res.stdout:
        # cmd = "cp " + p + " /tmp/test2"
        # os.system(cmd)
print("Compilling Famine ...")
os.system("make fclean && make all")

pg = subprocess.run(('pgrep', 'test'), stdout=subprocess.PIPE)
if pg.stdout:
    print(bcolors.HEADER + " test program is running" + bcolors.ENDC)
print("Launching ./Famine")
os.system('mv ./Famine /')  # only for my vm
os.system("cd / && ./Famine")  # only for my vm
print("analyze ...")
target1 = glob.glob("/tmp/test/*")
i = 0
len1 = len(target1)
print('{:<30} {:<10} {:<10}'.format('target', 'infected', 'signature'))
for p in target1:
    u = subprocess.run(('grep', 'dbaffier', p), stdout=subprocess.PIPE)
    if u.stdout:
        i += 1
        print('{:<30} {:<10} {:<10}'.format(
            p, bcolors.OKGREEN + "YES", bcolors.OKGREEN + "YES"))
    else:
        print('{:<30} {:<10} {:<10}'.format(
            p, bcolors.WARNING + "NO", bcolors.WARNING + "NO"))
    print(bcolors.ENDC, end='')
print("Total infected : ", i, " / ", len1)
