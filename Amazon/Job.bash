#!/bin/bash 

#clone
git clone git@github.com:bw4sz/Whales.git --depth 1

cd Whales||sudo halt

#unzip data file if needed
#cd OutData
#unzip pars.zip
#cd ..

#make new branch
#name it the instance ID
iid=$(ec2metadata --instance-id)

git checkout -b $iid

#render script
Rscript -e "rmarkdown::render('SingleSpecies.Rmd')" &> run.txt

#push results
git add --all
git commit -m "ec2 run complete"
git push -u origin $iid

#kill instance
sudo halt
