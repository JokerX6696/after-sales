#!/bin/bash
set -e
# DZQD2023040883
HTH=$1

paste -d "\t" \
<(cat <(/data/software/install/miniconda3/envs/python.3.7.0/bin/python /data/scripts/PBT/bin/view.py|grep "#合同号") \
<(/data/software/install/miniconda3/envs/python.3.7.0/bin/python /data/scripts/PBT/bin/view.py|grep "$HTH")) \
<(cat <(echo "结题报告名") <(/data/software/install/miniconda3/envs/python.3.7.0/bin/python /data/scripts/PBT/bin/view.py|grep "$HTH"|awk -F"\t" '{print$23}'|while read pat
do
    find ${pat}/Backup/ -name "*.zip"|while read A
    do
        new=$(echo $A|awk -F"/" '{print $NF}')
        printf ${new}";"
    done
    echo ""
done))|
awk -F'\t' '{OFS="\t";print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$26,$24,$25}'|\
less -SN