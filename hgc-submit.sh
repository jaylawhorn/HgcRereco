#!/bin/bash

#RELVAL_LIST=(`/afs/cern.ch/project/eos/installation/0.3.4/bin/eos.select ls /store/relval/CMSSW_6_2_0_SLHC23/`)
RELVAL_SOURCE=/store/relval/CMSSW_6_2_0_SLHC23
RELVAL_LIST=(RelValQCDForPF_14TeV)
GEO_PU=PH2_1K_FB_V6_UPGHGCalV5-v1
NEVT=50

OUTPUT_EOS=/store/user/jlawhorn/HGC_ReReco
LOG_DIR=/afs/cern.ch/work/j/jlawhorn/public/HGC_RERECO_STATUS/SLHC23_patch1

echo "Submitting jobs for HGC re-reco with parameters: "
echo "Relval samples " ${RELVAL_SOURCE}
echo "Rereco'd with  " ${CMSSW_BASE}
echo "Physics process" ${RELVAL_LIST[@]}
echo "Geometry/PU    " ${GEO_PU}
echo "# of evts/file " ${NEVT}
echo "Output location" ${OUTPUT_EOS}
echo "Enter y/n?"
read answer

if [[ $answer != "y" ]]
then
    exit -1
fi

for dataset in "${RELVAL_LIST[@]}"
do
    echo $dataset
    BOOK_LIST=(`/afs/cern.ch/project/eos/installation/0.3.4/bin/eos.select ls ${RELVAL_SOURCE}/${dataset}/GEN-SIM-DIGI-RAW/${GEO_PU}/`)
    for book in "${BOOK_LIST[@]}"
    do
	echo " " $book
	mkdir -p ${LOG_DIR}/${dataset}/${GEO_PU}/${book}
	FILE_LIST=(`/afs/cern.ch/project/eos/installation/0.3.4/bin/eos.select ls ${RELVAL_SOURCE}/${dataset}/GEN-SIM-DIGI-RAW/${GEO_PU}/${book}/`)
	for file in "${FILE_LIST[@]}"
	do 
	    echo "  " ${file}
	    if [[ `/afs/cern.ch/project/eos/installation/0.3.4/bin/eos.select ls ${OUTPUT_EOS}/${dataset}/GEN-SIM-DIGI-RAW/${GEO_PU}/${book}/${file} 2> /dev/null` ]]
		then
		echo "This file already exists! If you really want to do this, delete the extant file and resubmit."
	    elif [[ `bjobs -w 2> /dev/null | grep ${file}` ]]
		then
		echo "Job already running. Not submitting."
	    else
		echo "Submitting job: hgc-run.sh root://eoscms.cern.ch/"${RELVAL_SOURCE} ${dataset}/GEN-SIM-DIGI-RAW/${GEO_PU} $book $file $NEVT ${OUTPUT_EOS}
		bsub -o ${LOG_DIR}/${dataset}/${GEO_PU}/${book}/${file%.*}.out -e ${LOG_DIR}/${dataset}/${GEO_PU}/${book}/${file%.*}.err -q 2nd hgc-run.sh root://eoscms.cern.ch/${RELVAL_SOURCE} ${dataset}/GEN-SIM-DIGI-RAW/${GEO_PU} $book $file $NEVT ${OUTPUT_EOS}
	    fi
	done
    done
done