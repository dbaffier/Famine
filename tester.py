import os
from subprocess import PIPE, Popen

TARGET = "War"


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


def cmdline(command):
    process = Popen(
        args=command,
        stdout=PIPE,
        shell=True
    )
    return process.communicate()[0]


os.system("make re")
os.system("rm -rf /tmp/test/ /tmp/test2/")
print("Creating /tmp/test/ /tmp/test/2 directories")
os.system("mkdir /tmp/test/ /tmp/test2/")

while True:
    print(bcolors.BOLD + "******** WAR TESTER ********" + bcolors.ENDC)
    print("1 : basic test (ls, bash..)")
    print("4 : quit")
    inp = input()
    if inp == "4":
        break
    if inp == "1":
        target1 = ['/bin/echo', '/bin/ps',
                   '/bin/pwd', '/bin/ls', '/bin/bash', './bin/Hello']
        for p in target1:
            cmd = "cp " + p + " /tmp/test/"
            print(cmd)
            os.system(cmd)
        os.system('mv War /')  # only for my vm
        os.system("cd / && ./War")  # only for my vm
        print("Launching WAR", end="\n")
        print()
        target1 = ['/tmp/test/ps', '/tmp/test/pwd',
                   '/tmp/test/ls', '/tmp/test/bash', '/tmp/test/Hello']
        for p in target1:
            print('{:<20}'.format(p))
            print(bcolors.WARNING, end='')
            print(cmdline('strings ' + p + ' | grep \"dbaffier\"'))
            print(bcolors.ENDC, end='')
        print()
    if inp == "3":
        target1 = ['./bin/Hello', '/bin/ls']
        for p in target1:
            cmd = "cp " + p + " /tmp/test/"
            print(cmd)
            os.system(cmd)
        target1 = ['/tmp/test/Hello', '/tmp/test/ls']
        print("Dupplicating binary ...")
        for p in target1:
            cmd = "cp " + p + " " + p + "_2"
            os.system(cmd)
        os.system('mv War /')  # only for my vm
        os.system("cd / && ./War")  # only for my vm
        # for p in target1:
        #     res = subprocess.run(['file', p], stdout=subprocess.PIPE)
        #     cmd = "cp " + p + " /tmp/test"
        #     os.system(cmd)

        # print("Compilling " + TARGET + " ...")
        # os.system("make fclean && make all")

        # pg = subprocess.run(('pgrep', 'test'), stdout=subprocess.PIPE)
        # if pg.stdout:
        #     print(bcolors.HEADER + " test program is running" + bcolors.ENDC)
        # print("Launching ./Famine")
        # os.system('mv ./Famine /')  # only for my vm
        # os.system("cd / && ./Famine")  # only for my vm
        # print("analyze ...")
        # target1 = glob.glob("/tmp/test/*")
        # i = 0
        # len1 = len(target1)
        # print('{:<30} {:<10} {:<10}'.format('target', 'infected', 'signature'))
        # for p in target1:
        #     u = subprocess.run(('grep', 'dbaffier', p), stdout=subprocess.PIPE)
        #     if u.stdout:
        #         i += 1
        #         print('{:<30} {:<10} {:<10}'.format(
        #             p, bcolors.OKGREEN + "YES", bcolors.OKGREEN + "YES"))
        #     else:
        #         print('{:<30} {:<10} {:<10}'.format(
        #             p, bcolors.WARNING + "NO", bcolors.WARNING + "NO"))
        #     print(bcolors.ENDC, end='')
        # print("Total infected : ", i, " / ", len1)
