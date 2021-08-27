 #!/bin/bash

 #This script automates the Super Resolution Reconstruction (SRR) Process for Fetal Brains. It is intended to be used with the renbem/niftymic docker <<https://hub.docker.com/r/renbem/niftymic>>
 #Instructions for use available at <<https://github.com/daniyalmotan/srr_pipeline>>
 #Script developed by: Daniyal Motan, UCLH, 2021.  Adapted from initial script by Magdalena Sokolska, UCLH

 #Version = 0.4

 #function clalled to display how to use script incase no argument supplied
 usage(){
	echo "Usage: bash $0 'enter full path to folder with unprocessed nifty files (including docker mount path)'"
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
echo "The folder you have chosen to process is:" $NAME

DIR=$(dirname "$1")
echo "The directory this folder is in is:" $DIR

#creates a masks folder, checks if the folder already exists
#also checks if the input folder specified is valid, inacse invalid - process exits gracefully
if mkdir $DIR/$NAME/masks ; then
	echo  $DIR/$NAME/masks created
else
	if [ -d "$DIR/$NAME/masks" ] ; then
		echo could not create a masks folder as $DIR/$NAME/masks already exists
		echo proceeding to next steps...
	else
		echo folder you have specified is invalid, exiting...
		echo 'make sure you enter the full path to folder with unprocessed nifty files (including docker mount path)'
		exit 1
	fi
fi

# Check for nifti files (i.e. files with the .nii.gz extension), if no nifti files found, exit gracefully
# if nifti files exist, list all the nifti images in the specified file
ls $DIR/$NAME/*.nii.gz  >/dev/null || { echo "no NIFTI (*.nii.gz) files found, exiting..." ; exit 1 ; }
	ls $DIR/$NAME/*.nii.gz > $DIR/$NAME/image_list.txt

#read image names from image_list.txt and populate segment_brains_command in the required format (to later run as a command within the docker)
n=0 ;  
while read line; 
	do n=$(($n+1)); 
		if (( $n == 1))
		then
		echo -n 'niftymic_segment_fetal_brains  --filenames  ' 
		fi;
    file=` basename "$line"`;
	echo -n "$DIR/$NAME/$file " ;
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
	echo -n  "$DIR/$NAME/masks/$file " ;
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
	echo -n "$DIR/$NAME/$file " ;
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
	echo -n  "$DIR/$NAME/masks/$file " ;
	done < $DIR/$NAME/image_list.txt  >>  $DIR/$NAME/reconstruction_pipeline_command.txt

#add the output directory to reconstruction_pipeline_command.txt
echo '  --dir-output '$DIR/$NAME/'srroutput  ' >> $DIR/$NAME/reconstruction_pipeline_command.txt

#runs segment_brains_command.txt created previously as a bash command
echo initiating brain segmentation...
bash $DIR/$NAME/segment_brains_command.txt

#[potentially add a break / exit in case of an error]

#runs reconstruction_pipeline_command.txt created previously as a bash command
echo initiating reconstrction process...
bash $DIR/$NAME/reconstruction_pipeline_command.txt

#simply checks for existence of the final reconstructed output 
#i.e. the srr_template.nii.gz file to say if the reconstruction process was successful or not
if [ -f "$DIR/$NAME/srroutput/recon_template_space/srr_template.nii.gz" ] ; then
		echo the reconstruction process was successful
	else
		echo the reconstruction may not have been successful, please check the $DIR/$NAME/srroutput folder
	fi