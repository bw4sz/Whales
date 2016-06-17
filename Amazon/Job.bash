#!/bin/bash 

#cd into whales
cd Whales

#git pull to make sure we are at HEAD
git pull

#make new branch
#name it the instance ID
iid=$(ec2metadata --instance-id)

git checkout -b $iid

#render script
Rscript -e "rmarkdown::render('SingleSpecies.Rmd')"

#push results
git add --all
git commit -m "ec2 run complete"
git push -u origin $iid

#kill instance
sudo halt
