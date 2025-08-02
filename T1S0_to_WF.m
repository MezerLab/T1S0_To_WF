
% This script demonstrates the workflow for creating WF maps from T1 and M0 maps
% obtained using two acquisition methods: Variable Flip Angle (VFA) and MP2RAGE.
%
% Requirements:
% - All required maps and masks must be pre-aligned and in the same spatial space.
%
% Dependencies:
% The script uses functions and tools from the following repositories (linked in the README):
%   - mrQ
%   - MP2RAGE-related-scripts
%   - S0_to_PD
%
% Please ensure that these repositories are installed and added to your MATLAB path.


%% seg file should be ordered:

% WM = 1
% CSF = 2
% GM = 3
% CTX = 4

%% Estimating T1 and S0 from VFA acquistion:

% Using the mrQ package presented in: **  https://github.com/mezera/mrQ/tree/master  **
% Explanations about input and organization of the data are in the repository.

dataDir = 'path_to_nifti_input_dir';
outDir = 'path_to_output_dir';
inputData_spgr = 'structure_required_SPGR_parameters.mat';
inputdata_seir = 'structure_required_SEIR_parameters.mat';
B1file = 'path_to_SPGR_B1_map.nii.gz';

mrQ_run(dataDir, outDir, inputData_spgr, inputdata_seir, B1file)


%% Estimating T1 and S0 from MP2RAGE acquistion:

% Using the MP2RAGE package presented in: **  https://github.com/JosePMarques/MP2RAGE-related-scripts  **
% Explanations about input and organization of the data are in the repository.

% Updating MP2RAGE protocol info and loading the MP2RAGE dataset 
MP2RAGE.B0 = 3;           % in Tesla
MP2RAGE.TR = 5;           % MP2RAGE TR in seconds 
MP2RAGE.TRFLASH = 7.1e-3; % TR of the GRE readout
MP2RAGE.TIs = [0.7 2.5]; % Inversion times - time between middle of refocusing pulse and excitatoin of the k-space center encoding
MP2RAGE.NZslices = 176; % Slices Per Slab * [PartialFourierInSlice-0.5  0.5]
MP2RAGE.FlipDegrees = [4 5]; % Flip angle of the two readouts in degrees
MP2RAGE.filename = 'path_to_MP2RAGE_UNI.nii.gz'; % file
MP2RAGE.filenameINV1 = 'path_to_MP2RAGE_INV1.nii.gz';
MP2RAGE.filenameINV2 = 'path_to_MP2RAGE_INV2.nii.gz';
MP2RAGE.invEff = [];    

% Estimation of MP2RAGE T1 and S0 images with Fingerprinting method:
MP2RAGEimg = load_untouch_nii(MP2RAGE.filename);
INV1 = load_untouch_nii(MP2RAGE.filenameINV1);
INV2 = load_untouch_nii(MP2RAGE.filenameINV2);

% First we will correct theINV1 and INV2 maps, to be with negative and positive valuse.
[INV1final, INV2final] = Correct_INV1INV2_withMP2RAGEuni(INV1,INV2,MP2RAGEimg,[]);

INV1img = INV1final.img;
INV2img = INV2final.img;
B1 = load_untouch_nii('path_to_B1_map.nii.gz');

% Fingerprint method for T1 and S0 with B1 correction:
[T1, S0, R1] = MP2RAGE_dictionaryMatching(MP2RAGE,INV1img,INV2img,B1.img,[0.002, 0.005], 1, B1.img ~= 0);
dtiWriteNiftiWrapper(T1,tmp.qto_xyz,'path_to_T1_output.nii.gz');
dtiWriteNiftiWrapper(M0,tmp.qto_xyz,'path_to_S0_output.nii.gz');
dtiWriteNiftiWrapper(R1,tmp.qto_xyz,'path_to_R1_output.nii.gz');


%% Extracting PD map from T1 and M0
% From each pair of T1 and S0 we can now extract PD map.

T1map = 'path_to_T1_file.nii.gz';
S0map = 'path_to_S0_file.nii.gz'; 

PDmapDir = 'path_to_output_dir';

segFile = 'path_to_seg_file.nii.gz';
BMfile = 'path_to_BM_file.nii.gz';

factor = 1; 

M0_ToPD(PDmapDir, T1map, S0map, BMfile, segFile, factor);

%% Calibrating PD map to get WF map

PDmap = fullfile(PDmapDir,'PD.nii.gz'); % PD map extracted from M0_ToPD function

% We need a segmentation of the CSF only (as a logical matrix)
CSFmask = readFileNifti(segFile);
CSFmask = CSFmask.data;
CSFmask(CSFmask==1|CSFmask==3|CSFmask==4) = 0;
CSFmask = logical(CSFmask);

WFfilename = 'WF.nii.gz'; % Only the name for the WF map. The function will save it at the same directory of the PD map.

T1minmax = [4.2,4.7];

calibratePDmap(T1map, PDmap, CSFmask, T1minmax, WFfilename)

