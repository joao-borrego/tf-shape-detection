#!/usr/bin/bash

# Setup environment variables
#wd=`pwd`"/models/research"
#export PYTHONPATH=$PYTHONPATH:${wd}:${wd}/slim
#protoc ${wd}/object_detection/protos/*.proto --python_out=${wd}

# Workspace dir
ws=$1

# Trials
declare -a trials=(
   "sim_no_camera"
   "sim_big_camera"
   "sim_no_camera_base"
   "sim_no_camera_chess"
   "sim_no_camera_flat"
   "sim_no_camera_gradient"
   "sim_no_camera_perlin")

# Trials
declare -a fine_tune_trials=(
   "real"
   "sim_no_camera"
   "sim_big_camera"
   "sim_no_camera_base"
   "sim_no_camera_chess"
   "sim_no_camera_flat"
   "sim_no_camera_gradient"
   "sim_no_camera_perlin")

# Run metrics
for trial in "${trials[@]}"
do
    mkdir -p ${ws}/inference_results/${trial}

    python -m object_detection/metrics/offline_eval_map_corloc \
        --eval_dir=${ws}/inference_results/${trial}/ \
        --eval_config_path=test_eval_config.pbtxt \
        --input_config_path=${ws}/test_input_config/${trial}.pbtxt 
done

for trial in "${fine_tune_trials[@]}"
do
    mkdir -p ${ws}/inference_results/fine_tune/${trial}

    python -m object_detection/metrics/offline_eval_map_corloc \
        --eval_dir=${ws}/inference_results/fine_tune/${trial}/ \
        --eval_config_path=test_eval_config.pbtxt \
        --input_config_path=${ws}/test_input_config/fine_tune_${trial}.pbtxt 

done
