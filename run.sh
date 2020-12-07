#!/bin/bash


#############################################################
##################### PROCESSING STEPS #####################
#############################################################

####### fMRIPrep outputs that pass QA #######
# QA: Prior manual + Euler-based inspection for unchecked images
# Assume csv of form: bblid,seslabel,t1RawDataExclude,cnr_graycsflh,cnr_graycsfrh,
# cnr_graywhitelh,cnr_graywhiterh,euler_lh,euler_rh
# To be run on the subject level

######## Find relevant files/paths ########
InDir=/data/input

#sessions=`ls -d ${InDir}/ses* | sed 's#.*/##'`
sessions="$@" #Make sure command line passes without "ses-" part
ases=`echo ${sessions} | cut -d ' ' -f 1`
subj=`find ${InDir}/${ases}/ -name "*${ases}.html" | cut -d '/' -f 5 | cut -d '_' -f 1`

t1wimages=""
for ses in $sessions; do
  t1wimage=`find ${InDir}/${ses}/anat -name "${subj}_${ses}_desc-preproc_T1w.nii.gz"`;
  t1wimages="${t1wimages} ${t1wimage}";
done

######## Make output directory ########

OutDir=/data/output
for ses in ${sessions}; do
  mkdir ${OutDir}/${ses};
done

######## Run Template Construction ########
# On bias-field corrected, but not skull-stripped, image

for image in ${t1wimages}; do echo "${image}" >> ${OutDir}/tmp_subjlist.csv ; done

antsMultivariateTemplateConstruction.sh -d 3 -o "${OutDir}/" -n 0 -i 8 -y 0 -c 2 -j 2 ${OutDir}/tmp_subjlist.csv

######## Rename files as appropriate ########

for ses in ${sessions} ; do
  mv ${OutDir}/*_${ses}_* ${OutDir}/${ses};
done

#mkdir ${OutDir}/${subj}/scripts
#mv ${OutDir}/${subj}/*.sh ${OutDir}/${subj}/scripts
mv ${OutDir}/template0.nii.gz ${OutDir}/${subj}_template0.nii.gz
mv ${OutDir}/templatewarplog.txt ${OutDir}/${subj}_templatewarplog.txt
mv ${OutDir}/template0Affine.txt ${OutDir}/${subj}_template0Affine.txt
mv ${OutDir}/template0warp.nii.gz ${OutDir}/${subj}_template0warp.nii.gz


######## Remove unnecessary files ########

rm ${OutDir}/tmp_subjlist.csv



#############################################################
#############################################################
#############################################################