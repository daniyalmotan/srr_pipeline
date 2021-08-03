# srr_pipeline
Scripts to automate the SRR Process for Fetal Brains

*Intended for use with NiftyMIC running as a docker*

https://github.com/gift-surg/NiftyMIC

steps:
1 – from the command line start docker using:
>docker run -it --rm --mount type=bind,source=C:\srrdata,target=/app/data renbem/niftymic /bin/bash

the command line should now show

>root@94c6dc7c063c:/app#

2 – go into the data folder that has been mounted using:
>root@94c6dc7c063c:/app# cd data

3 – run the following command where 20002 is the name of the folder with the nii.gz files for the particular subject
>root@94c6dc7c063c:/app/data# bash srr_process_full.sh 20002

full folder path may also be entered, both ways work

>root@94c6dc7c063c:/app/data# bash srr_process_full.sh /app/data/20002

All the intermediate files and the final output will be inside the 20002 folder once the whole process has been run
