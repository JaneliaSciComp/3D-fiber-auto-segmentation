

FIJI="/groups/scicompsoft/home/otsunah/Desktop/Fiji.app/ImageJ-linux64"
SEGMACRO1="/nrs/scicompsoft/otsuna/Macros/Skeleton_Generator_cluster_CPUpart.ijm"
SEGMACRO2="/nrs/scicompsoft/otsuna/Macros/Skeleton_Generator_cluster_GPUpart.ijm"

fullpath=$1
savedir=$2
JFRCMaskDir="/nrs/scicompsoft/otsuna/template/Template_MIP/"
Textpath=$3


echo "fullpath; "${fullpath}
echo "savedir; "${savedir}
echo "JFRCMaskDir; "${JFRCMaskDir}
echo "Textpath; "$Textpath

if [[ ! -d $savedir ]]; then
    mkdir $savedir
fi


foldername=${fullpath%/*}/
echo "foldername; "$foldername


cd ${savedir}
num=0
while [ -e ${fullpath} ]
do
$FIJI -macro ${SEGMACRO2} "${fullpath},${savedir},${JFRCMaskDir},${Textpath}" 
num=$((num+1))

if [[ $num == 10 ]]; then
  break
fi
done


rm -rf $foldername

exit 0




