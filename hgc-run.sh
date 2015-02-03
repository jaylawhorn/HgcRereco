#!/bin/bash

#for testing
#IN_DIR=root://eoscms.cern.ch//store/relval/CMSSW_6_2_0_SLHC23
#IN_DATA_SET=RelValQCDForPF_14TeV/GEN-SIM-DIGI-RAW/PH2_1K_FB_V6_UPGHGCalV5-v1
#IN_BOOK=00000
#IN_FILE=10978F91-149C-E411-9841-0025905A610A.root
#NEVT=10
#OUT_DIR=/store/user/jlawhorn/HGC_ReReco

IN_DIR=$1 
IN_DATA_SET=$2 
IN_BOOK=$3 
IN_FILE=$4 
NEVT=$5
OUT_DIR=$6

h=`basename $0`
echo "Script:    $h"
echo "Arguments: $*"

# some basic printing                                                                                                                                                      
echo " "; echo "${h}: Show who and where we are";
echo " "
echo " user executing: "`id`;
echo " running on    : "`hostname`;
echo " executing in  : "`pwd`;
echo " submitted from: $HOSTNAME";
echo " ";

#initialize the CMSSW environment
echo " "; echo "${h}: Initialize CMSSW (in $CMSSW_BASE)"; echo " "
WORK_DIR=`pwd`
cd $CMSSW_BASE
eval `scram runtime -sh`
cd -
echo " "
echo "Running Re-reco with parameters: "
echo "First" $NEVT "events"
echo "from relval sample " ${IN_DIR}/${IN_DATA_SET}/${IN_BOOK}/${IN_FILE}
echo "with CMSSW version located at" $CMSSW_BASE

/afs/cern.ch/project/eos/installation/0.3.4/bin/eos.select mkdir -p ${OUT_DIR}/${IN_DATA_SET}/${IN_BOOK}/

addRecHits="s/Content.outputCommands/Content.outputCommands+cms.untracked.vstring\('keep *_*RecHit*_*_*'\)/"

cmsDriver.py step3 --conditions auto:upgradePLS3 -n $NEVT --eventcontent FEVTDEBUGHLT -s RAW2DIGI,L1Reco,RECO --datatier GEN-SIM-RECO --customise SLHCUpgradeSimulations/Configuration/combinedCustoms.cust_2023HGCalMuon --geometry Extended2023HGCalMuon,Extended2023HGCalMuonReco --magField 38T_PostLS1 --filein file:${IN_DIR}/${IN_DATA_SET}/${IN_BOOK}/${IN_FILE} --fileout ${IN_FILE} --no_exec

sed -i "${addRecHits}" step3_RAW2DIGI_L1Reco_RECO.py

cmsRun step3_RAW2DIGI_L1Reco_RECO.py

cmsStage ${IN_FILE} ${OUT_DIR}/${IN_DATA_SET}/${IN_BOOK}/