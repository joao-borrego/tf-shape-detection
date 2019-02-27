#!/usr/bin/bash

# Workspace dir
ws=$1

#
# Trials
#

# Fine-tune for 350k iterations
baseline="real"
# Train for 350k iterations
declare -a long_trials=(
    "sim_big_camera"
    "sim_no_camera")
# Train for 100k iterations
declare -a trials=(
    "sim_no_camera_base"
    "sim_no_camera_chess"
    "sim_no_camera_flat"
    "sim_no_camera_gradient"
    "sim_no_camera_perlin")
# Fine-tune for 25k iterations
declare -a fine_tune_trials=(
    "sim_big_camera"
    "sim_no_camera"
    "sim_no_camera_base"
    "sim_no_camera_chess"
    "sim_no_camera_flat"
    "sim_no_camera_gradient"
    "sim_no_camera_perlin")

#
# Metrics
#

declare -a eval_trials=(
    "sim_big_camera"
    "sim_no_camera"
    "sim_no_camera_base"
    "sim_no_camera_chess"
    "sim_no_camera_flat"
    "sim_no_camera_gradient"
    "sim_no_camera_perlin"
)

declare -a eval_fine_tune_trials=(
    "real"
    "sim_big_camera"
    "sim_no_camera"
    "sim_no_camera_base"
    "sim_no_camera_chess"
    "sim_no_camera_flat"
    "sim_no_camera_gradient"
    "sim_no_camera_perlin"
)

#
# Baseline
#

# Launch eval (on CPU) first and send to background
(export CUDA_VISIBLE_DEVICES=3; \
python models/research/object_detection/eval.py \
    --logtostderr \
    --eval_dir=${ws}/eval/fine_tune/${baseline}/ \
    --pipeline_config_path=${ws}/config/fine_tune_${baseline}.config \
    --checkpoint_dir=${ws}/train/fine_tune/${baseline}/ &)

# Launch train and wait for conclusion
python models/research/object_detection/train.py \
    --logtostderr \
    --train_dir=${ws}/train/fine_tune/${baseline}/ \
    --pipeline_config_path=${ws}/config/fine_tune_${baseline}.config \
    --num_clones=2 \
    --ps_tasks=1

# Kill eval process
sleep 5m
pkill -f eval.py

# Export inference graph
python models/research/object_detection/export_inference_graph.py \
    --input_type image_tensor \
    --pipeline_config_path ${ws}/config/fine_tune_${baseline}.config \
    --trained_checkpoint_prefix ${ws}/train/fine_tune/${baseline}/model.ckpt-350000 \
    --output_directory ${ws}/inference_graph/fine_tune/${baseline}

#
# Train for 350k iterations
#

# Train from ImageNet runs
for trial in "${long_trials[@]}"
do
    (export CUDA_VISIBLE_DEVICES=3; \
    python models/research/object_detection/eval.py \
        --logtostderr \
        --eval_dir=${ws}/eval/${trial}/ \
        --pipeline_config_path=${ws}/config/${trial}.config \
        --checkpoint_dir=${ws}/train/${trial}/ &)

    python models/research/object_detection/train.py \
        --logtostderr \
        --train_dir=${ws}/train/${trial}/ \
        --pipeline_config_path=${ws}/config/${trial}.config \
        --num_clones=2 \
        --ps_tasks=1
    sleep 5m
    pkill -f eval.py

    python models/research/object_detection/export_inference_graph.py \
        --input_type image_tensor \
        --pipeline_config_path ${ws}/config/${trial}.config \
        --trained_checkpoint_prefix ${ws}/train/${trial}/model.ckpt-350000 \
        --output_directory ${ws}/inference_graph/${trial}
done

#
# Train for 100k iterations
#

for trial in "${trials[@]}"
do
    (export CUDA_VISIBLE_DEVICES=3; \
    python models/research/object_detection/eval.py \
        --logtostderr \
        --eval_dir=${ws}/eval/${trial}/ \
        --pipeline_config_path=${ws}/config/${trial}.config \
        --checkpoint_dir=${ws}/train/${trial}/ &)

    python models/research/object_detection/train.py \
        --logtostderr \
        --train_dir=${ws}/train/${trial}/ \
        --pipeline_config_path=${ws}/config/${trial}.config \
        --num_clones=2 \
        --ps_tasks=1
    sleep 5m
    pkill -f eval.py

    python models/research/object_detection/export_inference_graph.py \
        --input_type image_tensor \
        --pipeline_config_path ${ws}/config/${trial}.config \
        --trained_checkpoint_prefix ${ws}/train/${trial}/model.ckpt-100000 \
        --output_directory ${ws}/inference_graph/${trial}
done

#
# Fine-tune for 25k iterations
#

for trial in "${fine_tune_trials[@]}"
do
    (export CUDA_VISIBLE_DEVICES=3; \
    python models/research/object_detection/eval.py \
        --logtostderr \
        --eval_dir=${ws}/eval/${trial}/ \
        --pipeline_config_path=${ws}/config/fine_tune_${trial}.config \
        --checkpoint_dir=${ws}/train/fine_tune/${trial}/ &)

    python models/research/object_detection/train.py \
        --logtostderr \
        --train_dir=${ws}/train/fine_tune/${trial}/ \
        --pipeline_config_path=${ws}/config/fine_tune_${trial}.config \
        --num_clones=2 \
        --ps_tasks=1
    sleep 5m
    pkill -f eval.py

    python models/research/object_detection/export_inference_graph.py \
        --input_type image_tensor \
        --pipeline_config_path ${ws}/config/fine_tune_${trial}.config \
        --trained_checkpoint_prefix ${ws}/train/fine_tune/${trial}/model.ckpt-25000 \
        --output_directory ${ws}/inference_graph/fine_tune/${trial}
done

#
# Compute metrics
#
for trial in "${eval_trials[@]}"
do
    mkdir -p ${ws}/inference_results/${trial}

    python -m object_detection/inference/infer_detections \
        --input_tfrecord_paths=${ws}/data/test.record \
        --output_tfrecord_path=${ws}/inference_results/${trial}/detections.tfrecord \
        --inference_graph=${ws}/inference_graph/${trial}/frozen_inference_graph.pb \
        --discard_image_pixels

    python -m object_detection/metrics/offline_eval_map_corloc \
        --eval_dir=${ws}/inference_results/${trial}/ \
        --eval_config_path=${ws}/config/test_eval_config.pbtxt \
        --input_config_path=${ws}/test_input_config/${trial}.pbtxt 
done

for trial in "${eval_fine_tune_trials[@]}"
do
    mkdir -p ${ws}/inference_results/fine_tune/${trial}

    python -m object_detection/inference/infer_detections \
        --input_tfrecord_paths=${ws}/data/test.record \
        --output_tfrecord_path=${ws}/inference_results/fine_tune/${trial}/detections.tfrecord \
        --inference_graph=${ws}/inference_graph/fine_tune/${trial}/frozen_inference_graph.pb \
        --discard_image_pixels

    python -m object_detection/metrics/offline_eval_map_corloc \
        --eval_dir=${ws}/inference_results/fine_tune/${trial}/ \
        --eval_config_path=${ws}/config/test_eval_config.pbtxt \
        --input_config_path=${ws}/test_input_config/fine_tune_${trial}.pbtxt 

done
