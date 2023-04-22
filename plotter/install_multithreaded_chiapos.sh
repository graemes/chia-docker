#!/bin/bash

# Note: 
#       I have not actually tested this installing into the 
#       chia-blockchain `install.sh` venv as I did not use it
#	      when I installed chia. I have only tested it in a
#       test venv. YMMV!

if [ $# -eq 0 ]
  then
    echo "Usage: ./install_multithreaded_chiapos.sh /full/path/to/current/chia-blockchain"
    exit 1
fi

WORK_DIR=/tmp/build-chia-stuff

# Clean up temporary files from previous attempts if they exist
rm -rf $WORK_DIR

cd $1
# activate the venv
# shellcheck disable=SC1091
if [ ! -f "activate" ]; then
  echo "Error: Cannot find venv to activate"
  exit 1
fi
. ./activate

# Create and move to temporary working directory
mkdir $WORK_DIR
cd $WORK_DIR

# Clone multithreaded library repo
git clone https://github.com/SippieCup/chiapos.git
cd chiapos

# We checkout a specific combined branch commit that I reviewed for security issues
# This ensures that any future potentially malicious commits, or modified history
# with malicious intent will not be included

# IF THIS COMMIT DOES NOT EXIST - DO NOT USE THE REPO 
# UNTIL SOMEONE YOU TRUST HAS VALIDATED ITS SAFETY
git checkout 24288eb9eb4c75593cd51bd6bccb8fe036fc6244

# Build chiapos library
python setup.py clean --all
python setup.py install

# Return to working directory and clone the official chia-blockchain repo
cd $1
#cd $WORK_DIR
#git clone https://github.com/Chia-Network/chia-blockchain.git
#cd chia-blockchain

# Update setup.py to accept the modified version of chiapos
sed -i.bak 's/chiapos==1.0.2/chiapos/g' setup.py 

# Build and install chia-blockchain binaries into the venv
python setup.py clean --all
python setup.py install

# Clean up temporary files after build
rm -rf $WORK_DIR

