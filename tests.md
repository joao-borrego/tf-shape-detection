## Trials

We have used Single Shot Detector [SSD][ssd] using [MobileNet][mobilenet] as the feature extractor (which was trained using [ImageNet][imagenet]) and pre-trained on [COCO][coco] dataset as our baseline.

### Hardware Setup

```
    CPU: Intel(R) Core(TM) i7-7820X CPU @ 3.60GHz
    GPU0: Nvidia TITAN Xp
    GPU1: Nvidia TITAN Xp
    RAM: 64GB
    OS: Ubuntu 18.04 Bionic
```

The network is automatically split between the 2 GPUs.
Our setup allowed us to use a batch size of 8 in all training scenarios.

### Training Set Composition

The following table shows which dataset is used in each run, and its composition.

| Run                       | Training Set           | # sim images | # real images | SSD Checkpoint  | Epochs |
|---------------------------|------------------------|--------------|---------------|-----------------|--------|
| fine_tune/real            | real.record            | 0            | 175           | COCO            | 16k    |
| sim_no_camera             | sim_no_camera.record   | 30k          | 0             | -               | ~90    |
| sim_big_camera            | sim_big_camera.record  | 30k          | 0             | -               | ~90    |
| fine_tune/sim_no_camera   | real.record            | 0            | 175           | sim_no_camera   | ~2.2k  |
| fine_tune/sim_big_camera  | real.record            | 0            | 175           | sim_big_camera  | ~2.2k  |
| sim_no_camera_*           | sim_no_camera_*.record | 6k           | 0             | -               | ~130   |
| fine_tune/sim_no_camera_* | real.record            | 0            | 175           | sim_no_camera_* | ~1.1k  |

The baseline is `fine_tune/real` which corresponds to using SSD pre-trained on COCO and fine-tuning on real image dataset.
The asterisk (\*) in `sim_no_camera_*` represents each of the 5 subdatasets, namely `base`,`flat`,`chess`,`gradient`,`perlin`. 

### Training Parameters

We used exponentially decaying learning rate, α = α_0 * k ^ floor(- iteration / t), with k = 0.95.

| Run                       | Learning rate α_0 | Decay steps t | Iterations |
|---------------------------|-------------------|---------------|------------|
| fine_tune/real            | 0.004             | 100k          | 350k       |
| sim_no_camera             | 0.008             | 50k           | 350k       |
| sim_big_camera            | 0.004             | 50k           | 350k       |
| fine_tune/sim_no_camera   | 0.001             | -             | 50k        |
| fine_tune/sim_big_camera  | 0.001             | -             | 50k        |
| sim_no_camera_*           | 0.004             | 50k           | 100k       |
| fine_tune/sim_no_camera_* | 0.001             | -             | 25k        |

[coco]: http://cocodataset.org/#home
[imagenet]: https://arxiv.org/abs/1704.04861
[mobilenet]: https://papers.nips.cc/paper/4824-imagenet-classification-with-deep-convolutional-neural-networks.pdf
[ssd]: http://www.cs.unc.edu/%7Ewliu/papers/ssd.pdf
