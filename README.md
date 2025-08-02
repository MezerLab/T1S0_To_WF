# T1S0_To_WF

This repository contains the analysis pipeline and relevant scripts used in the study: "Mapping a Reproducible Water Fraction and T1 using MP2RAGE and Variable Flip Angle Quantitative MRI Protocols*".


## Overview:
The pipeline estimates Water Fraction (WF) maps from quantitative MRI (qMRI) data, using two acquisition protocols for T1 mapping - Variable Flip Angle (VFA) and MP2RAGE.

The repository includes:
- T1S0_to_WF.m - an exmaple script demonstrating the full pipeline
- Reporisoties of T1 and S0 estimation for both VFA and MP2RAGE
- PD estimation functions
- calibratePDmap.m - WF calculation function 


## Dependencies:
The script uses functions and tools from the following repositories (linked in the README):
 - mrQ - https://github.com/mezera/mrQ/tree/master
 - MP2RAGE-related-scripts - https://github.com/JosePMarques/MP2RAGE-related-scripts/tree/master
 - Vistasoft - https://github.com/vistalab/vistasoft
 - SPM8 - https://github.com/spm/spm8

Please ensure that these repositories are installed and added to your MATLAB path.


(*Add citation once the paper will be published)
