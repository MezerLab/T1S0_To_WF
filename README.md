# T1S0_To_WF

This repository contains the analysis pipeline and relevant scripts used in the study: "Mapping a Reproducible Water Fraction and T1 using MP2RAGE and Variable Flip Angle Quantitative MRI Protocols*".
The pipeline estimates the water fraction (WF) maps from quantitative MRI (qMRI) data, using two acquisition protocols estimating T1 - VFA and MP2RAGE.

The repository includes:
- Scripts for T1 and S0 map estimation
- PD estimation
- WF calculation


% Requirements:
All required maps and masks must be pre-aligned and in the same spatial space.

% Dependencies:
The script uses functions and tools from the following repositories (linked in the README):
 - mrQ
 - MP2RAGE-related-scripts
 - S0_to_PD
   
% Please ensure that these repositories are installed and added to your MATLAB path.


(*Add citation once the paper will be published)
