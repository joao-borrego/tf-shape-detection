## Trials

### Hardware Setup

```
    CPU: Intel(R) Core(TM) i7-7820X CPU @ 3.60GHz
    GPU0: Nvidia TITAN Xp
    GPU1: Nvidia TITAN Xp
    RAM: 64GB
```

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

We used exponentially decaying learning rate, α = α_0 * k ^ (- iteration * t), with k = 0.95.

| Run                       | Learning rate α_0 | Decay steps t | Iterations |
|---------------------------|-------------------|---------------|------------|
| fine_tune/real            | 0.004             | 100k          | 350k       |
| sim_no_camera             | 0.008             | 50k           | 350k       |
| sim_big_camera            | 0.004             | 50k           | 350k       |
| fine_tune/sim_no_camera   | 0.001             | -             | 50k        |
| fine_tune/sim_big_camera  | 0.001             | -             | 50k        |
| sim_no_camera_*           | 0.004             | 50k           | 100k       |
| fine_tune/sim_no_camera_* | 0.001             | -             | 25k        |
