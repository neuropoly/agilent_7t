%% Read
clear all; close all;
fid_file= '/Volumes/jfpp/data_server/s_20140926_JF_BOLD01/fsems_mouse_head_01.fid';
data_fid = aedes_readfid(fid_file,'Return',3);
[pathstr, name, ext] = fileparts(fid_file);
fdf_folder= [pathstr filesep name '.img'];
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
    struct_fdf = aedes_readfdf(input_file);
    data_fdf(:,:,k) = struct_fdf.FTDATA';
end
data_fdf=data_fdf(end:-1:1,:,:);

% Playing with kspace
kspace_raw=data_fid.KSPACE(:,:,3);
nb_files=1;
display.abskspaceraw = log(abs(kspace_raw));
display.anglekspaceraw = angle(kspace_raw);

%% Normalization (affects only intensity)
kspace_mod=kspace_raw/max(max(max(kspace_raw)));

%% Circshift (no effect)
kspace_mod=circshift(kspace_raw,[20 20 0]);

%% Circshift complex only
kspace_abs = abs(kspace_raw);
kspace_angle = angle(kspace_raw);
kspace_a = kspace_abs.*cos(kspace_angle);
kspace_b = kspace_abs.*sin(kspace_angle);
kspace_mod=complex(kspace_a,circshift(kspace_b,[0 5 0]));

%% Circshift phase only
kspace_abs = abs(kspace_raw);
kspace_angle = circshift(angle(kspace_raw),[5 0 0]);
kspace_a = kspace_abs.*cos(kspace_angle);
kspace_b = kspace_abs.*sin(kspace_angle);
kspace_mod=complex(kspace_a,kspace_b);

%% Circshift des evens
kspace_mod = kspace_raw;
kspace_mod(:,2:2:end,:) = circshift(kspace_raw(:,2:2:end,:),[5 0 0]);

%% Inverse evens
kspace_mod = kspace_raw;
kspace_mod(:,2:2:end,:) = kspace_raw(end:-1:1,2:2:end,:); 

%% Inverse readout
kspace_mod = kspace_raw(end:-1:1,:,:);

%% Inverse phase encode
kspace_mod = kspace_raw(:,end:-1:1,:);

%% Addition of phase
kspace_abs = abs(kspace_raw);
kspace_angle = angle(kspace_raw)+pi/2;
kspace_a = kspace_abs.*cos(kspace_angle);
kspace_b = kspace_abs.*sin(kspace_angle);
kspace_mod=complex(kspace_a,kspace_b);

%% Addition of complex
kspace_abs = abs(kspace_raw);
kspace_angle = angle(kspace_raw);
kspace_a = kspace_abs.*cos(kspace_angle);
kspace_b = kspace_abs.*sin(kspace_angle)+2*pi;
kspace_mod=complex(kspace_a,kspace_b);

%% Phase ramp addition
x_shift=10;
y_shift=10;
x=(1:size(kspace_raw,1))/size(kspace_raw,1);
y=(1:size(kspace_raw,2))/size(kspace_raw,2);
phase_ramp_x = repmat(2*pi*x_shift*x',[1 size(kspace_raw,2),size(kspace_raw,3)]);
phase_ramp_y = repmat(2*pi*y_shift*y,[size(kspace_raw,1),1,size(kspace_raw,3)]);

kspace_abs = abs(kspace_raw);
kspace_angle = angle(kspace_raw)+phase_ramp_x+phase_ramp_y;
kspace_a = kspace_abs.*cos(kspace_angle);
kspace_b = kspace_abs.*sin(kspace_angle);
kspace_mod=complex(kspace_a,kspace_b);

%% Normalize the phase between -pi and pi
kspace_abs = abs(kspace_raw);
kspace_angle = angle(kspace_raw)./max(max(max(angle(kspace_raw)))).*pi;
kspace_a = kspace_abs.*cos(kspace_angle);
kspace_b = kspace_abs.*sin(kspace_angle);
kspace_mod=complex(kspace_a,kspace_b);

%% Unwrap the phase (does nothing because the phase is already included between -pi and pi)
kspace_abs = abs(kspace_raw);
kspace_angle = angle(kspace_raw);
kspace_angle = mod(kspace_angle,pi);
kspace_a = kspace_abs.*cos(kspace_angle);
kspace_b = kspace_abs.*sin(kspace_angle);
kspace_mod=complex(kspace_a,kspace_b);

%% Display
display.abskspacemod = log(abs(kspace_mod));
display.anglekspacemod = angle(kspace_mod);
for z=1:nb_files
    display.rspaceraw(:,:,z) = fftshift(ifft2(kspace_raw(:,:,z)'));
    display.rspacemod(:,:,z) = fftshift(ifft2(kspace_mod(:,:,z)'));    
end
close all
display_function(display);

%% Save in .nii
xres = struct_fdf.HDR.FileHeader.roi(1)/struct_fdf.HDR.FileHeader.matrix(1);
yres = struct_fdf.HDR.FileHeader.roi(2)/struct_fdf.HDR.FileHeader.matrix(2);
zres = struct_fdf.HDR.FileHeader.roi(3);
res = [xres yres zres];
[pathstr, name, ext] = fileparts(fid_file);
output_dir=[pathstr filesep name '.nii' filesep];
if ~exist(output_dir,'dir')
    mkdir(output_dir);
end
output_file=[output_dir 'fsems.nii'];
try
    disp(['Writing ' output_file])
    aedes_write_nifti(data_fdf,output_file,'VoxelSize',res);
catch exception
    errordlg(['unable to write ' output_file])
end
