


inputarray=$1
linum=$LSB_JOBINDEX

echo "inputarray  "$inputarray
echo "LSB_JOBINDEX  "$LSB_JOBINDEX

#file open
stringline=$(awk 'NR == v1' v1="${linum}" $inputarray)

echo "stringline; "$stringline

#line by line, split to array
IFS=' ' read -r -a array <<< $stringline

fullpath=${array[0]}
savedir=${array[1]}
VxWidth=${array[2]}
VxDepth=${array[3]}

FIJI="/groups/scicompsoft/home/otsunah/Desktop/Fiji.app/ImageJ-linux64"
SEGMACRO1="/nrs/scicompsoft/otsuna/Macros/Skeleton_Generator_cluster_CPUpart.ijm"
SEGMACRO2="/nrs/scicompsoft/otsuna/Macros/Skeleton_Generator_cluster_GPUpart.ijm"
JFRCMaskDir="/nrs/scicompsoft/otsuna/template/Template_MIP/"

echo "fullpath; "${fullpath}
echo "savedir; "${savedir}
echo "JFRCMaskDir; "${JFRCMaskDir}
echo "VxWidth; "${VxWidth}
echo "VxDepth; "${VxDepth}

if [[ ! -d $savedir ]]; then
    mkdir $savedir
fi



cd ${savedir}
#num=0
#while [ -e ${fullpath} ]
#do
$FIJI -macro ${SEGMACRO1} "${fullpath},${savedir},${JFRCMaskDir},${VxWidth},${VxDepth}" 
#num=$((num+1))

#if [[ $num == 10 ]]; then
#  break
#fi
#done


a=$fullpath

b=${a%.*}
c=${b#*/}
d=${c#*/}
e=${d#*/}
f=${e#*/}
g=${f#*/}
h=${g#*/}
i=${h#*/}
foldername=${i#*/}

echo "foldername; "$foldername

fullpath2=${savedir}${foldername}/${foldername}.nrrd

Textpath=${savedir}${foldername}/${foldername}.txt

if [ -e ${fullpath2} ]; then
  bsub -n 3 -W 55 -gpu "num=1" -q gpu_rtx -o /dev/null -P imagingsupport sh /nrs/scicompsoft/otsuna/Macros/ThreeD_seg_GPUpart.sh $fullpath2 $savedir $Textpath;
fi
#/nrs/scicompsoft/emlm/VNC/$foldername.log
rm ${savedir}${foldername}.h5j.txt

exit 0




