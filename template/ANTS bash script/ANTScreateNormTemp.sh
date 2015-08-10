# specify where ANTS is installed
export PATH=/usr/bin/:$PATH
export ANTSPATH=/usr/bin/

# specify list of subjects
subjectList='HC05 HC06 HC07 HC08 HC09 HC10 HC11 HC12 HC13 HC14 HC15 HC16 HC17 HC18 HC19'
#subjectList='HC20 HC21 HC22 HC23 HC24 HC25'

# specify folder names
experimentDir=/Volumes/hd2_local/users_local/jfpp/data/Hypercapnia              #parent folder
inputDir=$experimentDir       #folder containing anatomical images
workingDir=$experimentDir/template_creation       #working directory

# specify parameters for buildtemplateparallel.sh
#compulsory arguments
ImageDimension=3
OutPrefix='NORM'
#optional arguments
ParallelMode=2
GradientStep='0.25'
IterationLimit=4    #number of iteration. Number of registration to do = $iteration limit * number of subjects
Cores=4     #numbers of cores used during the template creation
N3Correct=0     #preferable to do the field bias correction in the pre-processing
MaxIteration=30x90x20   #number of iteration for each registration
Rigid=1     #do a rigid registration to begin with
MetricType='MI'     #metric used for the registration. MI=mutual information. CC=cross-correlation. PR= probability mapping (default). MSQ= mean square difference. SSD= Ssum of squared differences
TransformationType='GR'     #transformation type used for the registration. RI=purely rigid. RA=affine rigid. EL=elastic transformation model. SY= SyN with time (default). GR= greedty SyN. EX= exponential. DD= diffeomorphic demons style exponential mapping
template='/Network/Servers/django.neuro.polymtl.ca/Volumes/hd2/users_hd2/jfpp/ants/data/template/030913.nii'    #initial template.

# pre-processing options
N4Correct=1
Skull_stripping=1
PreRegistration=0

#If not created yet, let's create a new output folder
mkdir -p $workingDir

#go into the folder where the script should be run
cd $workingDir

#Let's get the input, the subject specific anatomical images. You might
# have to alter this part a bit to satisfy the structure of your system
#Assuming that the name of your subject specific anatomical image is
# 'subjectname.nii' the loop to grab the files would look something like this

#for subj in $subjectList
#do
#Ext="_antsT1.nii"
#cp $inputDir/$subj.nii $workingDir/$subj$Ext
#done #subj done

for subj in $subjectList
do
Ext="_antsT1.nii"
cd $inputDir/$subj*
cp T1.nii $workingDir/$subj$Ext
echo $cmd
eval $cmd
done #subj done
cd $workingDir

# Pre-processing loop
for subj in $subjectList
do
#Field correction
if [ "$N4Correct" -eq 1 ]; then
nb=1
while [ "$nb" -le 2 ]; do
cmd="${ANTSPATH}N4BiasFieldCorrection -d $ImageDimension -i $subj$Ext -o $subj$Ext"
echo $cmd #state the command
eval $cmd #execute the command
let "nb+=1"
done
fi

#Cropping the images to keep only the brain
if [ "$Skull_stripping" -eq 1 ]; then
cmd="bet ${subj}${Ext} ${subj}_strp${Ext} -R -f 0.8"
echo $cmd
eval $cmd
fi

#Pre-registration of the images on the previous template
if [ "$PreRegistration" -eq 1 ]; then
#if [ -s ${subj}Affine.txt ]; then
cmd="ants 3 -m MI[${subj}${Ext},${template}] -t SyN[0.5] -i 0 -r Gauss[3,0.5] -o ${subj} --number-of-affine-iterations 10000x10000x10000 --rigid-affine true --use-Histogram-Matching 1 --R 55x150x105x130x0x11"
echo $cmd
eval $cmd
cmd="WarpImageMultiTransform 3 ${subj}${Ext} ${subj}reg${Ext} -R ${template} --use-BSpline ${subj}Affine.txt"
echo $cmd
eval $cmd
#fi
fi
done #subj done

if [ "$Skull_stripping" -eq 1 ]; then
Ext="_strp_antsT1.nii.gz"
fi

#assemble the command for the script from the input parameters defined above
cmd="buildtemplateparallel.sh -d $ImageDimension -c $ParallelMode \
-g $GradientStep -i $IterationLimit -j $Cores -m $MaxIteration -n $N3Correct  \
-r $Rigid -s $MetricType -t $TransformationType -o $OutPrefix *${Ext}"
#-z  $template

echo $cmd #state the command
eval $cmd #execute the command
