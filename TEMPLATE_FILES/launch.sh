sed -e "s/\r//g" autochar.sh -i
sed -e "s/\r//g" pointchargesTEMPLATE.pc -i
sed -e "s/\r//g" *.inp -i

sh autochar.sh