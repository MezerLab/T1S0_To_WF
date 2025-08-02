function calibratePDmap(T1file,PDfile,CSFmask,T1minmax,WFfilename)

% This function calibrates a PD map to obtain a water fraction (WF) map.
% 
% The calibration is based on voxels within the CSF mask whose T1 values fall within a
% specified range (default: 4.2 to 4.7 seconds). Voxels outside this T1 range or with 
% outlier PD values are excluded from the calculation of calibration value.
%
%
% -- Inputs:
% T1file        : String. Path to the T1 map file (in NIfTI format).
% PDfile        : String. Path to the PD map file (in NIfTI format).
% CSFmask       : Logical 3D matrix. Binary mask indicating CSF voxels (same dimensions as T1 and PD maps).
% T1minmax      : 1x2 vector [T1_min T1_max]. Range of T1 values to consider within the CSF mask.
%                 - Default: [4.2 4.7]
%                 - If set to [0 0], the function will automatically use the min and max T1 values 
%                   found within the CSF mask.
% WFfilename    : String. Desired name for the output WF map file.
%                 The map will be saved in the same directory as the input PD map.
%
% --- Output:
% - A WF map saved with the specified WFfilename.
% - A "trusted CSF mask" used for calibration will also be saved, with '_CSFmask' appended to the name.
%
% Example:
% calibratePDmap('T1_map.nii.gz', 'PD_map.nii.gz', csf_mask, [4.2 4.7], 'WF_map.nii.gz');
%
% Note:
% The function assumes that T1 and PD maps are already aligned and in the same space.


T1 = readFileNifti(T1file);
T1_xform = T1.qto_xyz;
T1map = T1.data;

PD = readFileNifti(PDfile);
PDmap = PD.data;


if notDefined('T1minmax')
   T1min = 4.2;
   T1max = 4.7;
   T1minmax = [4.2 4.7];
elseif T1minmax == [0 0]
    T1min = min(T1map(CSFmask));
    T1max = max(T1map(CSFmask));
    T1minmax = [T1min T1max];
else
    T1min = T1minmax(1);
    T1max = T1minmax(2);
end


%% Check that the T1 values inside the mask are within [T1min,T1max]:

outliervoxels=find(T1map(CSFmask)<=T1min | T1map(CSFmask)>=T1max);

if length(outliervoxels)/length(find(CSFmask))>0.05
   warning('More than 5% of the voxels in the CSF mask: have T1 values outside [T1min,T1max]. Check if you trust this mask.')
end

%% Exclude all voxels that are out of T1 range & outliers values in the PD:

WFmask=CSFmask & PDmap<prctile(PDmap(CSFmask),99) & PDmap>prctile(PDmap(CSFmask),1) & T1map>=T1min & T1map<=T1max;

VoxNum = length(find(WFmask));
if VoxNum <= 200 
    warning('We could find only %d CSF voxels.  This makes the CSF WF estimation very noisy. You might want to consider changing the CSF mask',VoxNum)
end

%% Save the new CSFmask for WF calibration

x = fileparts(PDfile);
WFmask_path = fullfile(x,['CSFmask_',WFfilename]);
dtiWriteNiftiWrapper(single(WFmask), T1_xform, WFmask_path);

%% Calculate the calibration valuse as the median of the voxels in the WFmask

CalibrationVal = median(PDmap(WFmask));

%% Apply calibration to PD images to get WFfile and save

WF=PDmap./CalibrationVal;
WFfile = fullfile(x,WFfilename);

dtiWriteNiftiWrapper(WF,T1_xform,WFfile);

end