function [data_nii,param] = read_from_nii(input,param)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Read with aedes
patate = aedes_read_nifti(input);
data_nii = patate.FTDATA;

param.nx = size(data_nii,1);
param.ny = size(data_nii,2);
param.nz = size(data_nii,3);
param.nt = size(data_nii,4);

end

