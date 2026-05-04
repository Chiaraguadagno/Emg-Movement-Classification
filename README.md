# EMG Movement Classification

## Overview
Implementation of a MATLAB pipeline for classification of wrist and finger movements using multichannel surface EMG signals and a k-Nearest Neighbors (kNN) classifier.

The project focuses on feature extraction from EMG envelopes and evaluation of classifier robustness under electrode shift conditions (simulating prosthetic socket misalignment).

---

## Data

Input data consist of multichannel EMG signals acquired using a high-density electrode grid and stored in MATLAB (.mat) format.

Each dataset includes:
- Raw EMG signals  
- EMG envelopes  
- Kinematic reference signals (joint angles)  
- Movement labels and metadata  

---

## Scripts

Main MATLAB scripts:

- `main_analysis.m`        # Visual inspection and channel selection  
- `main_training.m`        # Feature extraction and kNN training  
- `main_classify.m`        # Classification and testing  
- `main_general.m`         # Pipeline launcher  

Supporting functions:

- `calc_features.m`        # Feature extraction  
- `get_movement_label.m`   # Label extraction from metadata  
- `select_cycles.m`        # Cycle selection  
- `plot_envelopes.m`       # Signal visualization  

---

## Method

- EMG signal loading and preprocessing  
- Visual inspection and channel selection (4 channels)  
- Feature extraction from EMG envelopes:
  - Mean value  
  - Maximum value  
  - Standard deviation  
  - Dynamic slope  

- Dataset construction (feature matrix + labels)  
- Min-max normalization  
- Train/validation split (70/30)  
- kNN classifier training:
  - Distance: cityblock (Manhattan)  
  - Distance weighting: inverse  

- Cross-validation for model selection  
- Testing on standard and electrode-shifted data  

---

## Key Features

- Multichannel EMG processing  
- Feature-based movement classification  
- kNN model with cross-validation  
- Simulation of electrode shift (prosthetic socket misalignment)  
- Robustness analysis  

---

## Results

- Successful classification of wrist and finger movements  
- Performance dependent on channel selection and feature quality  
- Sensitivity to electrode displacement highlighted  
- Framework suitable for prosthetic control applications  

---

## Notes

Project focused on myoelectric control systems and robustness of EMG-based classifiers in realistic conditions.

The use of a reduced number of channels simulates practical constraints of commercial prosthetic systems.
