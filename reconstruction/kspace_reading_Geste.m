function [ksP,ksN,rsP,rsN] = kspace_reading_Geste(fid_file,param)
%% kspace_reading_Geste
% This function reads the kspace of an EPIP experiment from a .fid varian 
% file. It then performs the correction of the kspace with the Geste method
% as described in the "a subspace identification extension to the phase
% correlation method" by William Scott Hoge

% param fields (default value):
% param.data (1): specifies if the data used should be the raw Eplus and Eminus
% images or the intertwined images IprimeP and IprimeN

% param.save_nii (1): specifies if the data should be saved in a .nii files

% param.xcorr_type (1): specifies the type of correlation to be used.
% 1: Correct odd and even echoes mismatch with the central columns of each scan
% 2: Correct odd and even echoes mismatch with the 2 most correlated odd/even columns of each scan
% 3: Correct odd and even echoes mismatch individually for each column

% param.center_kspace (2): specifies the type of kspace centering to be
% applied before the cross correlation
% 0: no centering
% 1: 1D centering (only in the frequency direction)
% 2: 2D centering

% param.nx (64): Must specify the number of lines in the frequency direction

% param.ny (64): Must specify the number of lines in the phase direction

% param.display (1): Specifies if the data should be displayed or not

% param.fdf_comp (1): Specifies if the fdf data should be readed and
% compared

% param.vol_pour (1): specifies the pourcentage of volumes to be
% kept and analysed. 1=all the volumes. 0=only the first volume

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
acq_order = struct_fid.PROCPAR.image;

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
nx=param.nx; knx=nx*2; % Double sampling in the frequency direction
ny=param.ny; kny=ny+2; % 2 additionnal column in the phase direction. For reconstruction purpose?
knz=size(data_fid,3); nz=knz;
knt=size(data_fid,2); nt=(knt-2)/2;
% nz=16; knz=nz; % Same
% nt=20; knt=nt*2+2; % 2 reference scans at the begin + 1 navigation scan in between each scan
ksraw=reshape(data_fid,knx,kny,knt,knz);
ksraw=permute(ksraw,[1 2 4 3]); % Replace matrix in x,y,z,t order
if param.fdf_comp
    data_fdf=reshape(data_fdf,nx,ny,nt,nz);
    data_fdf=permute(data_fdf,[1 2 4 3]);
    data_fdf=data_fdf(:,ny:-1:1,:,:);
end
clear data_fid

%% Definition of the data sets
% R1 = ksraw(:,3:end,:,acq_order==0);         % Non-phase encoded reference scan (0)
% R2 = ksraw(:,3:end,:,acq_order==-2);        % Non-phase encoded reference scan with the read gradient polarity reversed (-2)
Eplus = ksraw(:,3:end,:,acq_order==1);      % Epi data (1)
Eminus = ksraw(:,3:end,:,acq_order==-1);    % Phase-encoded reference scan with the read gradient polarity reversed (-1)
if param.vol_pour~=1
    nt=round(param.vol_pour*nt);
    if nt==0, nt=1; end
    disp(['keeping only the first ' num2str(nt) ' scans (' num2str(param.vol_pour*100) '% of the total scan'])
    Eplus=Eplus(:,:,:,1:nt);
    Eminus=Eminus(:,:,:,1:nt);
end
clear ksraw

%% Computing IprimeP and IprimeN
IprimeP = zeros(knx,ny,knz,nt);
IprimeP(:,1:2:ny-1,:,:) = Eplus(:,1:2:ny-1,:,:);
IprimeP(:,2:2:ny,:,:) = Eminus(:,2:2:ny,:,:);
IprimeN = zeros(knx,ny,knz,nt);
IprimeN(:,2:2:ny,:,:) = Eplus(:,2:2:ny,:,:);
IprimeN(:,1:2:ny-1,:,:) = Eminus(:,1:2:ny-1,:,:);
for z=1:knz
    for t=1:nt
        fftIprimeP(:,:,z,t) = fftshift(fft2(IprimeP(:,:,z,t)));
        fftIprimeN(:,:,z,t) = fftshift(fft2(IprimeN(:,:,z,t)));
    end
end
if param.display
    t=4; z=4;
    figure
    subplot(2,4,1); imagesc(log(abs(Eplus(:,:,z,t)))); title('abs Eplus')
    subplot(2,4,2); imagesc(log(abs(IprimeP(:,:,z,t)))); title('abs IprimeP')
    subplot(2,4,3); imagesc(angle(IprimeP(:,:,z,t))); title('angle IprimeP')
    subplot(2,4,4); imagesc(abs(fftIprimeP(:,:,z,t))); title('fftIprimeP')
    subplot(2,4,5); imagesc(log(abs(Eminus(:,:,z,t)))); title('abs Eminus')
    subplot(2,4,6); imagesc(log(abs(IprimeN(:,:,z,t)))); title('abs IprimeN')
    subplot(2,4,7); imagesc(angle(IprimeN(:,:,z,t))); title('angle IprimeN')
    subplot(2,4,8); imagesc(abs(fftIprimeN(:,:,z,t))); title('fftIprimeN')
    colormap gray
end

%% Computing phi'
Q = (conj(IprimeN).*IprimeP)./abs(IprimeN.*conj(IprimeN));
Q(isnan(Q)) = 0;    %eliminate the NaN
for z=1:knz
    for t=1:nt
        [U(:,:,z,t),S(:,:,z,t),V(:,:,z,t)] = svd(Q(:,:,z,t));
    end
end
if param.display
    figure
    imagesc(log(abs(Q(:,:,z,t))));
end
