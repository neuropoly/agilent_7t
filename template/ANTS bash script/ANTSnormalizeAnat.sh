#!/bin/bash

#Define environment parameters
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#specify where ANTS is installed
export PATH=/usr/bin/:$PATH
export ANTSPATH=/usr/bin/


#Define experiment specific parameters
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#specify list of subjects
subjectList='HC19a'

#specify folder names
experimentDir=~/ants/data            #parent folder
inputDir=$experimentDir/old_rats_anat         #folder containing anatomical images
templateName=$experimentDir/template/old_rat_template12.nii    #path to and name of normtemplate
normAnatOutDir=$experimentDir/normAnat           #outputdir of the normalized T1 files

#specify parameters for antsIntroduction.sh
#compulsory arguments
ImageDimension=3
OutPrefix=''
ReferenceImage=$templateName

#optional arguments
IgnoreHDRWarning=1
MaxIteration=30x90x20
N3Correct=1
QualityCheck=0
MetricType='PR'
TransformationType='GR'

#Do you want to overwrite existing output files? (1 = yes, 0 = no)
overwrite=1


#Write the main script
#~~~~~~~~~~~~~~~~~~~~~

#If not created yet, let's create a new output folder
if [ ! -d $normAnatOutDir ]
then
mkdir -p $normAnatOutDir
fi

#go into the folder where the script should be run
cd $normAnatOutDir

#go through all subjects
for subj in $subjectList
do

#if anatomy of the subject wasn't normalized yet or if overwrite was set to 1=yes
# the antsIntroduction script gets executed
if [ ! -e $normAnatOutDir/$OutPrefix$subj"deformed.nii.gz" ] || [ $overwrite == 1 ]
then
#assemble the command for the script from the input parameters defined above
cmd="bash $ANTSPATH/antsIntroduction.sh -d $ImageDimension -r $ReferenceImage \
-i $inputDir/$subj.nii -o $normAnatOutDir/$OutPrefix$subj \
-f $IgnoreHDRWarning -m $MaxIteration -n $N3Correct -q $QualityCheck \
-s $MetricType -t $TransformationType"
echo $cmd #state the command
eval $cmd #execute the command
else
echo -e "NOTICE: ${OutPrefix}${subj}deformed.nii.gz does already exist! \
Skipping to next subject."
fi
done #subj done