 #!/bin/bash

 #This script automates the Super Resolution Reconstruction (SRR) Process for Fetal Brains. It is intended to be used with the renbem/niftymic docker <<https://hub.docker.com/r/renbem/niftymic>>
 #Instructions for use available at <<https://github.com/daniyalmotan/srr_pipeline>>
 #Script developed by: Daniyal Motan, UCLH, 2021.  Adapted from initial script by Magdalena Sokolska, UCLH

 #Version = 0.1

 #function clalled to display how to use script incase no argument supplied
 usage(){
	echo "Usage: $0 'enter path to folder with unprocessed nifty files'"
	exit 1
}

# if argument not supplied, display usage 
	if [  $# -eq 0 ] 
	then 
		usage
		exit 1
	fi 

#[potentially add a check for a lockfile - to see if a folder has already been processed previously]

#Identifies the Current Folder and Directory and stores as variables
NAME=`basename "$1"`
echo $NAME

DIR=$(dirname "$1")
echo $DIR

#create a masks folder
mkdir $DIR/$NAME/masks
echo  $DIR/$NAME/masks created

#list all the nifti images in the specified folder (i.e. files with the .nii.gz extension)
ls $DIR/$NAME/*nii.gz > $DIR/$NAME/image_list.txt

#read image names from image_list.txt and populate segment_brains_command in the required format (to later run as a command within the docker)
n=0 ;  
while read line; 
	do n=$(($n+1)); 
		if (( $n == 1))
		then
		echo -n 'niftymic_segment_fetal_brains  --filenames  ' 
		fi;
    file=` basename "$line"`;
	echo -n "./$NAME/$file " ;
	done < $DIR/$NAME/image_list.txt  >  $DIR/$NAME/segment_brains_command.txt

#populate segment_brains_command with masks list in the required format (to later run as a command within the docker) 
n=0 ;  
while read line; 
	do n=$(($n+1)); 
		if (( $n == 1))
		then
		echo -n '  --filenames-masks  ' 
		fi;
    file=` basename "$line"`;
	echo -n  "./$NAME/masks/$file " ;
	done < $DIR/$NAME/image_list.txt  >>  $DIR/$NAME/segment_brains_command.txt

#read image names from image_list.txt and populate reconstruction_pipeline_command.txt in the required format (to later run as a command within the docker)
n=0 ;  
while read line; 
	do n=$(($n+1)); 
		if (( $n == 1))
		then
		echo -n 'niftymic_run_reconstruction_pipeline  --filenames  ' 
		fi;
    file=` basename "$line"`;
	echo -n "./$NAME/$file " ;
	done < $DIR/$NAME/image_list.txt  >  $DIR/$NAME/reconstruction_pipeline_command.txt
  
#populate reconstruction_pipeline_command.txt with masks list in the required format (to later run as a command within the docker) 
n=0 ;  
while read line; 
	do n=$(($n+1)); 
		if (( $n == 1))
		then
		echo -n '  --filenames-masks  ' 
		fi;
    file=` basename "$line"`;
	echo -n  "./$NAME/masks/$file " ;
	done < $DIR/$NAME/image_list.txt  >>  $DIR/$NAME/reconstruction_pipeline_command.txt

#add the output directory to reconstruction_pipeline_command.txt
echo '  --dir-output '$DIR/$NAME/'srroutput  ' >> $DIR/$NAME/reconstruction_pipeline_command.txt

#runs segment_brains_command.txt created previously as a bash command
#bash $DIR/$NAME/segment_brains_command.txt

#[potentially add a break / exit in case of an error]

#runs reconstruction_pipeline_command.txt created previously as a bash command
#bash $DIR/$NAME/reconstruction_pipeline_command.txt