### Pad image, construct template, and organize outputs
###
### Ellyn Butler
### April 16, 2020 - April 17, 2020

######## Interactive ANTs shell with bids directory ########
# docker run -it -v /Users/butellyn/Documents/antssstbids/bids_directory/:/data antsx/ants
# CREATE INPUT AND OUTPUT DIRECTORIES TO MOUNT BIDS DATA TO IN DOCKERFILE


######## Parse arguments ########
bidsInDir=#argument to container... "~/Documents/antssstbids/bids_directory"
subj=#argument to container... sub-100088
t1wimages=`find ${bidsInDir}/${subj}/ses*/anat -name "*T1w.nii*"`
sessions=`ls -d ${bidsInDir}/${subj}/ses* | sed 's#.*/##'`
#sessions=`find ${bidsInDir}/${subj} -maxdepth 1 -type d -name "ses-*" `

######## Make output directory ########

currentDir=`dirname ${bidsInDir}`
bidsOutDir=${currentDir}/bids_out_directory/
mkdir ${bidsOutDir}
mkdir ${bidsOutDir}/${subj}
for ses in ${sessions}; do
  mkdir -p ${bidsOutDir}/${subj}/${ses}/anat;
done

######## N4 Bias Field Correction ########

######## Run Template Construction ########

for image in ${t1wimages}; do echo "${image}" >> ${bidsOutDir}/tmp_subjlist.csv ; done

antsMultivariateTemplateConstruction.sh \
    -d 3 -o "${bidsOutDir}/${subj}/" \
    -c 2 -j 2 ${bidsOutDir}/tmp_subjlist.csv

#antsMultivariateTemplateConstruction.sh \
#    -d 3 -o "${bidsOutDir}/${subj}/${subj}_SST" \
#    -c 2 -j 2 ${bidsOutDir}/tmp_subjlist.csv


######## Rename files as appropriate ########

for ses in ${sessions} ; do
  mv ${bidsOutDir}/${subj}/*_${ses}_* ${bidsOutDir}/${subj}/${ses}/anat;
done

mkdir ${bidsOutDir}/${subj}/scripts
mv ${bidsOutDir}/${subj}/*.sh ${bidsOutDir}/${subj}/scripts
mv ${bidsOutDir}/${subj}/template0.nii.gz ${bidsOutDir}/${subj}/${subj}_template0.nii.gz
mv ${bidsOutDir}/${subj}/templatewarplog.txt ${bidsOutDir}/${subj}/${subj}_templatewarplog.txt
mv ${bidsOutDir}/${subj}/template0Affine.txt ${bidsOutDir}/${subj}/${subj}_template0Affine.txt
mv ${bidsOutDir}/${subj}/template0warp.nii.gz ${bidsOutDir}/${subj}/${subj}_template0warp.nii.gz


######## Remove unnecessary files ########

rm ${bidsOutDir}/tmp_subjlist.csv
