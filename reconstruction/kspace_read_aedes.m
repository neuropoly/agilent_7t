function [ksraw, data_fdf, param] = kspace_read_aedes(fid_file, param)
%% Parameter verification
if ~exist(fid_file,'file')
    errordlg('Cannot find the fid_file')
end
field_names={'data','save_nii','xcorr_type','center_kspace','nx','ny','display','fdf_comp' 'vol_pour'};
default_values=[1 1 1 2 64 64 1 1 1];
field_verif = isfield(param,field_names);
if ~isempty(find(field_verif,1));
    default_fields = find(field_verif==0);
    for i=default_fields
        param.(field_names{i})=default_values(i);
        % param = setfield(param,field_names{i},default_values(i));
    end
end

%% Read with aedes
disp('Reading with aedes')
[pathstr, name, ext] = fileparts(fid_file);
fdf_folder= [pathstr filesep name '.img'];

struct_fid=aedes_readfid(fid_file,'Return',2);
data_fid=(struct_fid.KSPACE);
param.acq_order = struct_fid.PROCPAR.image;

if param.fdf_comp
    fdf_files=dir([fdf_folder '/s*.fdf']);
    input={fdf_files(:).name};
    if iscell(input)
        nb_files = size(input,2);
    else
        nb_files = 1;
    end
    
    for k = 1:nb_files
        if nb_files == 1
            input_file = fullfile(fdf_folder,input{1});
        else
            input_file = fullfile(fdf_folder,input{k});
        end
        patate = aedes_readfdf(input_file);
        data_fdf(:,:,k) = patate.FTDATA;
    end
end

%% Reshape
nx=param.nx; param.knx=nx*2; % Double sampling in the frequency direction
ny=param.ny; param.kny=ny+2; % 2 additionnal column in the phase direction. For reconstruction purpose?
param.knz=size(data_fid,3); param.nz=param.knz;
param.knt=size(data_fid,2); param.nt=(param.knt-2)/2;
% nz=16; param.knz=nz; % Same
% param.nt=20; kparam.nt=param.nt*2+2; % 2 reference scans at the begin + 1 navigation scan in between each scan
ksraw=reshape(data_fid,param.knx,param.kny,param.knt,param.knz);
ksraw=permute(ksraw,[1 2 4 3]); % Replace matrix in x,y,z,t order
if param.fdf_comp
    data_fdf=reshape(data_fdf,nx,ny,param.nt,param.nz);
    data_fdf=permute(data_fdf,[1 2 4 3]);
    data_fdf=data_fdf(:,ny:-1:1,:,:);
end

if param.vol_pour~=1
    param.knt=floor((round(param.vol_pour*param.knt)-2)/2)*2+2; param.nt=(param.knt-2)/2;
    if param.nt==0, param.nt=1; end
    disp(['keeping only the first ' num2str(param.knt) ' scans (' num2str(param.vol_pour*100) '% of the total scan'])
    ksraw=ksraw(:,:,:,1:param.knt);
    data_fdf=data_fdf(:,:,:,1:param.knt);
    param.acq_order=param.acq_order(1:param.knt);
end