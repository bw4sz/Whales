#!/bin/bash 

#cd into whales
cd Whales

#git pull to make sure we are at HEAD
git pull

#render script
Rscript -e "rmarkdown::render('MutliSpeciesHMM.Rmd')"

#push results
git add --all
git commit -m "ec2 run complete"
git push


