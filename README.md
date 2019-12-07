## Domain Randomization vs Domain Adaptation: A Case Study on Object Category Detection

This repository holds the code used for our recent work on domain randomization.
We try to study how we can use this technique in the creation of large domain-specific synthetic datasets.
We conclude that this approach can be preferable to fine-tuning *state-of-the-art* object detection CNNs on small real image datasets, after being pre-trained on huge and available datasets such as [COCO][coco].

### Walkthrough

We provide a [Jupyter notebook][notebook] with a step-by-step walkthrough which includes:

- How to preprocess image dataset and create binary `TF records`;
- How to train network with several configurations (e.g. starting checkpoint, training set, learning rate);
- How to get **mAP** (Mean Average Precision) curves on validation set over time;
- How to export inference graphs and infer detections;
- How to obtain **AP** metrics and precision-recall curves on test set. 

The tests we performed are summarized in [tests.md][tests].

### Reference

We have uploaded a *preprint* version of our work to [arXiv.org][arxiv] which can be cited as follows:
```
@article{borregoatabak2018,
  title={The impact of domain randomization on object detection: a case study on parametric shapes and synthetic textures},
  author={Dehban, Atabak and Borrego, Jo{\~a}o and Figueiredo, Rui and Moreno, Plinio and Bernardino, Alexandre and Santos-Victor, Jos{\'e}},
  booktitle="IEEE/RSJ International Conference on Intelligent Robots and Systems (IROS)",
  year={2018}
}
```
### Dataset

We provided the used real image dataset in our laboratory's [webpage][dataset].
The used synthetic datasets were generated using an open-source Domain Randomization [plugin][gap] for [Gazebo][gazebo] simulator.
A detailed walkthrough on how to generate such datasets is provided [here][scene_generation].

### Acknowledgements

Our pipeline is based on [Justin Francis][wagonhelm]' [TensorFlow Object Detection API repository][tf_od_api].

### Dependencies

Our pipeline requires the following software.

- [TensorFlow v1.8](http://www.tensorflow.org/)
- [protobuf](https://github.com/google/protobuf)
- [NumPy](http://www.numpy.org/)
- [Scipy](https://www.scipy.org/)
- [Matplotlib](http://matplotlib.org/)
- [Scikit-Image](http://scikit-image.org/)
- [lxml](http://lxml.de/)
- [Pandas](http://pandas.pydata.org/)
- [Jupyter](http://jupyter.org/)

[arxiv]: https://arxiv.org/abs/1807.09834
[coco]: http://cocodataset.org/#home
[dataset]: http://soma.isr.ist.utl.pt/vislab_data/shapes2018/shapes2018.tar.gz
[gap]: https://github.com/jsbruglie/gap
[gazebo]: http://gazebosim.org/
[notebook]: ShapeDetection.ipynb
[scene_generation]: https://github.com/jsbruglie/gap/tree/dev/examples/scene_example
[wagonhelm]: https://github.com/wagonhelm
[tests]: tests.md
[tf_od_api]: https://github.com/wagonhelm/TF_ObjectDetection_API
