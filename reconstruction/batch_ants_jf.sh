#!/bin/sh

workingDir=/Volumes/folder_shared/test_registration_T2

FILE_DEST=$workingDir/j_template_RLPAIS_flipy
FILE_SRC=$workingDir/j_data_RLPAIS_crop
EXT=nii.gz
FILE_DEST_MARKER=$workingDir/j_mask_template
FILE_SRC_MARKER=$workingDir/j_mask_data
EXT_MARKER=nii.gz

DIM=3
resample=1
field_bias_correction=0
skull_stripping=0
landmark_based=1
mutual_information=0
affine=1
diffeomorphic=1
nbofiterN4=1
nbofiterreg=1

# resample to anat space
if [ "$resample" -eq 1 ]; then
echo ">> c3d ${FILE_DEST}.${EXT} ${FILE_SRC}.${EXT} -reslice-identity -o ${FILE_SRC}_resampled.${EXT}"
c3d ${FILE_DEST}.${EXT} ${FILE_SRC}.${EXT} -reslice-identity -o ${FILE_SRC}_resampled.${EXT}
FILE_SRC=${FILE_SRC}_resampled
fi

# Field Bias correction
if [ "$field_bias_correction" -eq 1 ]; then
counter=1
echo ">> N4BiasFieldCorrection -d $DIM -i ${FILE_SRC} -o ${FILE_SRC}_bcor $nbofiterN4 time(s)"
while [ $counter -le $nbofiterN4 ]; do
N4BiasFieldCorrection -d $DIM -i ${FILE_SRC}.${EXT} -o ${FILE_SRC}_bcor.${EXT}
FILE_SRC=${FILE_SRC}_bcor
#N4BiasFieldCorrection -d $DIM -i ${FILE_DEST}.${EXT} -o ${FILE_DEST}_bcor.${EXT}
#FILE_DEST=${FILE_DEST}_bcor
let "counter+=1"
done
fi

# Skull-stripping
if [ "$skull_stripping" -ge 1 ]; then
echo ">> bet ${FILE_SRC}.${EXT} ${FILE_SRC}_strp.${EXT} -f 0.7 "
bet ${FILE_SRC}.${EXT} ${FILE_SRC}_strp.${EXT} -f 0.7
FILE_SRC=${FILE_SRC}_strp
echo ">> bet ${FILE_DEST}.${EXT} ${FILE_DEST}_strp.${EXT} -f 0.7 "
bet ${FILE_DEST}.${EXT} ${FILE_DEST}_strp.${EXT} -f 0.7
FILE_DEST=${FILE_DEST}_strp
fi

counter=1
while [ $counter -le $nbofiterreg ]; do

# registration with Point set metric and mutual information
if [ "$landmark_based" -eq 1 ]; then
echo ">> ants $DIM -m PSE[${FILE_DEST}.${EXT},${FILE_SRC}.${EXT},${FILE_DEST_MARKER}.${EXT},${FILE_SRC_MARKER}.${EXT},0.8,100,1,0,1,100000] -o ${FILE_SRC} -i 0 --rigid-affine true --number-of-affine-iterations 1000x1000x1000 -m MI[${FILE_DEST}.${EXT},${FILE_SRC}.${EXT},0.2,4] --use-all-metrics-for-convergence 1"
ants $DIM -m PSE[${FILE_DEST}.${EXT},${FILE_SRC}.${EXT},${FILE_DEST_MARKER}.${EXT_MARKER},${FILE_SRC_MARKER}.${EXT_MARKER},0.8,100,1,0,1,100000] -o ${FILE_SRC} -i 0 --rigid-affine true --number-of-affine-iterations 1000x1000x1000 -m MI[${FILE_DEST}.${EXT},${FILE_SRC}.${EXT},0.2,4] --use-all-metrics-for-convergence 1
fi

# registration with mutual information and cross correlation
if [ "$mutual_information" -eq 1 ]; then
echo ">> ants $DIM -m MI[${FILE_DEST}.${EXT},${FILE_SRC}.${EXT}]  -t SyN -i 0 -r Gauss[6,1] -o reg_ --number-of-affine-iterations 10000x10000x10000 --do-rigid true --use-Histogram-Matching 1 --use-all-metrics-for-convergence 1"
ants $DIM -m MI[${FILE_DEST}.${EXT},${FILE_SRC}.${EXT},0.5,32] -m CC[${FILE_DEST}.${EXT},${FILE_SRC}.${EXT},0.5,4] -t SyN -i 50x50x50 -r Gauss[1,0] -o ${FILE_SRC} --number-of-affine-iterations 1000x1000x1000 --rigid-affine true --use-Histogram-Matching 1 --use-all-metrics-for-convergence 1
fi

# apply transformation(s)
if [ "$affine" -eq 1 ]; then
echo ">> WarpImageMultiTransform $DIM ${FILE_SRC}.${EXT} ${FILE_SRC}_reg_affine.${EXT} -R ${FILE_DEST}.${EXT} --use-BSpline ${FILE_SRC}Affine.txt"
WarpImageMultiTransform $DIM ${FILE_SRC}.${EXT} ${FILE_SRC}_reg_affine.${EXT} -R ${FILE_DEST}.${EXT} --use-BSpline ${FILE_SRC}Affine.txt
if [ "$landmark_based" -eq 1 ]; then
WarpImageMultiTransform $DIM ${FILE_SRC_MARKER}.${EXT} ${FILE_SRC_MARKER}_reg_affine.${EXT} -R ${FILE_DEST_MARKER}.${EXT} --use-BSpline ${FILE_SRC}Affine.txt
fi
fi

if [ "$diffeomorphic" -eq 1 ]; then
echo ">> WarpImageMultiTransform $DIM ${FILE_SRC}.${EXT} ${FILE_SRC}_reg_diffeo.${EXT} -R ${FILE_DEST}.${EXT} --use-BSpline ${FILE_SRC}Warp.nii.gz ${FILE_SRC}Affine.txt"
WarpImageMultiTransform $DIM ${FILE_SRC}.${EXT} ${FILE_SRC}_reg_diffeo.${EXT} -R ${FILE_DEST}.${EXT} --use-BSpline ${FILE_SRC}Warp.nii.gz ${FILE_SRC}Affine.txt
if [ "$landmark_based" -eq 1 ]; then
WarpImageMultiTransform $DIM ${FILE_SRC_MARKER}.${EXT} ${FILE_SRC_MARKER}_reg_diffeo.${EXT} -R ${FILE_DEST_MARKER}.${EXT} --use-BSpline ${FILE_SRC}Warp.nii.gz ${FILE_SRC}Affine.txt
fi
fi

FILE_SRC=${FILE_SRC}_reg_affine
FILE_SRC_MARKER=${FILE_SRC_MARKER}_reg_affine
let "counter+=1"
done
