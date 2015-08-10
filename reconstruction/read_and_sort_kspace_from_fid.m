function [raw_data_fid,param] = read_and_sort_kspace_from_fid(fid_file,param)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Read with aedes
disp(['Reading ' fid_file ' with aedes'])
struct_fid=aedes_readfid(fid_file,'Return',2);
data_fid=(struct_fid.KSPACE);
param.t_order = struct_fid.PROCPAR.image;
z_order = struct_fid.PROCPAR.pss;
z_spacing=(max(z_order)-min(z_order))/(length(z_order)-1);
z_order = z_order/z_spacing;
param.z_order = round(z_order-min(z_order)+1);

%% Reshape
param.double_freq_sampling = 1;
param.knx=param.nx*2; % Double sampling in the frequency direction
param.kny=param.ny+2; % 2 additionnal columns in the phase direction (navigator echoes)
param.knz=length(param.z_order);
param.knt=length(param.t_order);
try
    ksraw=reshape(data_fid,param.knx,param.kny,param.knt,param.knz);
catch exception
    disp(exception.identifier);
    disp(['trying param.knx=' num2str(param.knx/2) ' instead'])
    param.double_freq_sampling = 0;
    param.knx=param.knx/2;
    ksraw=reshape(data_fid,param.knx,param.kny,param.knt,param.knz);
end
ksraw=permute(ksraw,[1 2 4 3]); % Replace matrix in x,y,z,t order
% ksraw=ksraw(:,:,param.z_order,:); % Replace the slices in the correct order
ksraw(:,:,param.z_order,:) = ksraw;

%% Definition of the data sets
raw_data_fid.Rplus = ksraw(:,3:end,:,param.t_order==0);           % Non-phase encoded reference scan (0)
raw_data_fid.navi.Rplus = ksraw(:,1:2,:,param.t_order==0);
raw_data_fid.Rminus = ksraw(:,3:end,:,param.t_order==-2);         % Non-phase encoded reference scan with the read gradient polarity reversed (-2)
raw_data_fid.navi.Rminus = ksraw(:,1:2,:,param.t_order==-2);
raw_data_fid.Eplus = ksraw(:,3:end,:,param.t_order==1);           % Epi data (1)
raw_data_fid.navi.Eplus = ksraw(:,1:2,:,param.t_order==1);
raw_data_fid.Eminus = ksraw(:,3:end,:,param.t_order==-1);         % Phase-encoded reference scan with the read gradient polarity reversed (-1)
raw_data_fid.navi.Eminus = ksraw(:,1:2,:,param.t_order==-1);

if isfield(param,'vol_pour')  && param.vol_pour~=1
    param.nt=round(param.vol_pour*param.nt);
    if param.nt==0, param.nt=1; end
    disp(['keeping only the first ' num2str(param.nt) ' scans (' num2str(param.vol_pour*100) '% of the total number of scans)'])
    raw_data_fid.Eplus=raw_data_fid.Eplus(:,:,:,1:param.nt);
    raw_data_fid.Eminus=raw_data_fid.Eminus(:,:,:,1:param.nt);
end

end

