#!/usr/bin/env python3

import subprocess
import os
import sys
import argparse

HEADER = '\033[1;37m'
BLUE = '\033[94m'
GREEN = '\033[92m'
YELLOW = '\033[93m'
FAIL = '\033[91m'
NORMAL = '\033[0m'
BOLD = '\033[1m'
UNDERLINE = '\033[4m'

def setTitle(title, size):
    title = " "[:]*5 + title + " "[:]*5
    print (HEADER + title.center(size+20, "#"))

def graph(size, title, values):

    setTitle(title, size)
    for row in values:
        value = round(float(row[0][:-1]))*size/100
        for i in range(size):
            if i < value:
                print (YELLOW + "#", end="")
            else:
                print (YELLOW + "=", end="")

        print (NORMAL + " " + row[0].rjust(6) + " - " + row[1])

def deviceUsage(resource, device=None):
    if resource == "CPU":
        cmd = "cat /proc/stat | awk '/cpu[0-9]/ {value=($2+$4)*100/($2+$4+$5); printf (\" %2.2f%% %s\\n\",value, $1) }'"
    elif resource == "storage":
        cmd = "df -h | awk '/"+device+"/ {printf (\"%5s %6s\\n\", $5, $6)}'"
    elif resource == "memory":
        cmd = "free | awk  '/^[Mem|Swap]/ {value=$3*100/$2; printf (\"%2.2f%% %s \\n\", value, substr($1, 1, length($1) -1))}'"

    p = subprocess.Popen(cmd,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines = True)

    process = []
    for line in p.stdout.readlines():
        detail = line.strip()
        process.append(detail.split())
    retval = p.wait()

    return process


def lastLogins(size, title, n = 3):

    setTitle(title, size)
    cmd = "last | head -n"+str(n)+" | awk '{name=substr($0,0,7); data=substr($0,40,16);status=substr($0,59,5); printf (\"%s|%s|%s\\n\", name, data, status )}' "
    p = subprocess.Popen(cmd,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            universal_newlines = True)

    for line in p.stdout.readlines():
        detail = line.strip()
        detail = detail.split("|")
        formatedDetail = UNDERLINE+detail[0] + "\t\t" + NORMAL+detail[1] + "\t" + BOLD+detail[2]
        print (formatedDetail)
    retval = p.wait()


def distroDetail(size, title):

    setTitle(title, size)
    getDistro = "uname -a | awk '{ printf (\"%s|%s|%s\", $6, $7, $9)}'"
    getUptime = "uptime -p | awk '{data=substr($0,4,40);printf (\"%s\", data)}'"
    getLogged = "w | awk 'FNR > 2 {print $0}' | wc -l"
    cmds = [getDistro, getUptime, getLogged]

    result = []
    for i in cmds:
        p = subprocess.Popen(i,
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                universal_newlines = True)

        resultRaw = p.stdout.readlines();
        resultRaw= ' '.join(resultRaw).rstrip().split("|")
        result += resultRaw

    labels = [BOLD + "Distro: ",
              BOLD + "\t\tKernel: ",
              BOLD + "\t\tARCH: ",
              BOLD + "\nUptime: ",
              BOLD + "\tLogged Users: "]

    formatedDetail = ''
    for i in range(len(labels)):
        formatedDetail +=  labels[i] + BLUE + result[i] + NORMAL

    print (formatedDetail)

def main(argv):
    size = 40

    if len(argv) == 1:
        cpu = deviceUsage("CPU")
        graph(size, "CPU", cpu)
        print()
        memory=deviceUsage("memory")
        graph(size, "Memory", memory)
        print()
        lastLogins(size, "Last Logins", 3)
        print()
        distroDetail(size, "Distro Details")
        print()

    for arg in argv:
        if arg == "--clear":
            os.system("clear")
        if "--size" in arg:
            size = arg.split("=")
            size=int(size[1])
        if arg == "--cpu":
            cpu = deviceUsage("CPU")
            graph(size, "CPU", cpu)
            print()
        elif arg == "--memory":
            memory=deviceUsage("memory")
            graph(size, "Memory", memory)
            print()
        elif "--storage" in arg:
            device = arg.split("=")
            storage=deviceUsage("storage", device[1])
            graph(size, "Storage", storage)
            print()
        elif arg == "--lastlogins":
            lastLogins(size, "Last Logins", 3)
            print()
        elif arg == "--distroDetail":
            distroDetail(size, "Distro Details")
            print()

if __name__ == "__main__":
    main(sys.argv)

