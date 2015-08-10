function [ksP,rsP] = kspace_reading_tripleref(raw_data_fid,fid_file,param)
%% kspace_reading_xcorr2
% This function reads the kspace of an EPIP experiment from a .fid varian
% file. It then performs the correction of the kspace with a cross
% correlation algorithm to correct the odd and even echoes mismatch.
% Finally, it performs a fourier transform to obtain the real space image.
% It can then compare those images to the .fid generated by varian and/or
% save the images in a .nii file.

% param fields (default value):
% param.data (1): specifies if the data used should be the raw Eplus and Eminus
% images or the intertwined images IprimeP and IprimeN

% param.save_nii (1): specifies if the data should be saved in a .nii files

% param.correction (1): specifies the type of correction
% 0: don't correction with the 2 reference scans
% 1: Correction with R+ and R-

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
field_names={'data','save_nii','correction','center_kspace','nx','ny','display','fdf_comp' 'vol_pour'};
default_values=[1 1 1 2 64 64 1 1 1];
field_verif = isfield(param,field_names);
if ~isempty(find(field_verif,1));
    default_fields = find(field_verif==0);
    for i=default_fields
        param.(field_names{i})=default_values(i);
        % param = setfield(param,field_names{i},default_values(i));
    end
end

%% Crop
% Rplus = Rplus(round(param.knx/4):round(3*param.knx/4-1),:,:);
% Rminus = Rminus(round(param.knx/4):round(3*param.knx/4-1),:,:);
% Eplus = Eplus(round(param.knx/4):round(3*param.knx/4-1),:,:,:);
% Eminus = Eminus(round(param.knx/4):round(3*param.knx/4-1),:,:,:);
% param.knx=param.knx/2;

%% 1. Reverse the even echoes in the R+ dataset
disp('1. Reverse the even echoes in the R+ dataset')
Rplus = raw_data_fid.Rplus;
Rplus(1:param.knx,2:2:end,:) = Rplus(param.knx:-1:1,2:2:end,:);

% 2. FT along the read dimension
disp('2. FT along the read dimension')
for z=1:param.knz
    for y=1:param.ny
        fftRplus(:,y,z) = fftshift(ifft(Rplus(:,y,z)));
    end
end
if param.display
    z=round(param.knz/2);
    figure('Name','Rplus')
    subplot(1,2,1); imagesc(abs(fftRplus(:,:,z))); title('abs fftRplus')
    subplot(1,2,2); imagesc(angle(fftRplus(:,:,z))); title('angle fftRplus')
end
% 3. Generate the nonlinear phase map, P+
disp('3. Generate the nonlinear phase map, P+')
Pplus = angle(fftRplus);

% 4. Reverse the odd echoes in the R- dataset
disp('4. Reverse the odd echoes in the R- dataset')
Rminus = raw_data_fid.Rminus;
Rminus(1:param.knx,2:2:end,:,:) = Rminus(:,2:2:end,:);


% 5. FT along the read dimension
disp('5. FT along the read dimension')
for z=1:param.knz
    for y=1:param.ny
        fftRminus(:,y,z) = fftshift(ifft(Rminus(:,y,z)));
    end
end
if param.display
    z=4;
    figure('Name','Rminus')
    subplot(1,2,1); imagesc(abs(fftRminus(:,:,z))); title('abs fftRminus')
    subplot(1,2,2); imagesc(angle(fftRminus(:,:,z))); title('abs fftRminus')
end

% 6. Generate the nonlinear phase map, P-
disp('6. Generate the nonlinear phase map, P-')
Pminus = angle(fftRminus);

% 7. Phase correct the phase-encoded reference data, E-, using P- to give E*-
disp('7. Phase correct the phase-encoded reference data, E-, using P- to give E*-')
Eminus = raw_data_fid.Eminus;
Eminus(1:param.knx,1:2:end-1,:,:) = raw_data_fid.Eminus(param.knx:-1:1,1:2:end-1,:,:);
for t=1:param.nt
    for z=1:param.knz
        for y=1:param.ny
            fftEminus(:,y,z,t) = fftshift(ifft(Eminus(:,y,z,t)));
        end
    end
end
if param.correction == 1
    Estarminusangle = angle(fftEminus) - repmat(Pminus,[1 1 1 size(fftEminus,4)]);
    a = real(abs(fftEminus).*cos(Estarminusangle));
    b = real(abs(fftEminus).*sin(Estarminusangle));
    Estarminus = complex(a,b);
else
    Estarminus = fftEminus;
end
if param.display
    figure('Name','Estarminus')
    imagesc(abs(Estarminus(:,:,4)));
end

% 8. Reverse the even echoes in the EPI dataset, E+
disp('8. Reverse the even echoes in the EPI dataset, E+')
Eplus = raw_data_fid.Eplus;
Eplus(1:param.knx,2:2:end,:,:) = raw_data_fid.Eplus(param.knx:-1:1,2:2:end,:,:);

% 9. FT along the read dimension
disp('9. FT along the read dimension')
for t=1:param.nt
    for z=1:param.knz
        for y=1:param.ny
            fftEplus(:,y,z,t) = fftshift(ifft(Eplus(:,y,z,t)));
        end
    end
end
if param.display
    t=param.nt; z=4;
    figure('Name','Eplus')
    subplot(1,2,1); imagesc(abs(Eplus(:,:,z,t))); title('Eplus')
    subplot(1,2,2); imagesc(abs(fftEplus(:,:,z,t))); title('fftEplus')
end
% 10. Phase correct the EPI data using P+, to give E*+
disp('10. Phase correct the EPI data using P+, to give E*+')
if param.correction == 1
    Estarplusphase = angle(fftEplus) - repmat(Pplus,[1 1 1 size(fftEplus,4)]);
    a = real(abs(fftEplus).*cos(Estarplusphase));
    b = real(abs(fftEplus).*sin(Estarplusphase));
    Estarplus = complex(a,b);
else
    Estarplus = fftEplus;
end

% 11. Apply the odd/even echo correction by complex addition of E*- and E*+
disp('11. Apply the odd/even echo correction by complex addition of E*- and E*+')
ksP = Estarminus + Estarplus;
Estardiff = Estarminus-Estarplus;
Ediff = sum(sum(Estardiff,3),4);
if param.display
    z=3; t=4;
    figure('Name','correction')
    subplot(1,3,1); imagesc(angle(Estarminus(:,:,z,t))); title('Estarminus')
    subplot(1,3,2); imagesc(angle(Estarplus(:,:,z,t))); title('Estarplus')
    subplot(1,3,3); imagesc(angle(ksP(:,:,z,t))); title(['E z=' num2str(z) ' t=' num2str(t)])
end

% 12. Apply the FT along the phase encode direction
disp('12. Apply the FT along the phase encode direction')
for t=1:param.nt
    for z=1:param.knz
        for x=1:param.knx
            rsP_full(x,:,z,t) = (fftshift(ifft(ksP(x,:,z,t))));
        end
    end
end

% Eliminating the double sampling in the frequency direction
if param.double_freq_sampling
    rsP=rsP_full(param.knx/4+1:3*param.knx/4,:,:,:);
else
    rsP=rsP_full;
end

% Centering rspace
if param.center_rspace == 1
    disp('Centering rspace')
    [ksP,rsP] = rspace_centering (ksP,rsP_full,rsP_full,param);
end

%% 13. Display the magnitude image
if param.display
    disp('13. Display the magnitude image')
    z=round(param.knz/2); t=param.nt;
    figure('Name','E')
    subplot(1,5,1); imagesc(angle(Estarminus(:,:,z,t))); title('Estarminus')
    subplot(1,5,2); imagesc(angle(Estarplus(:,:,z,t))); title('Estarplus')
    subplot(1,5,3); imagesc(angle(Estardiff(:,:,z,t))); title('Estardiff')
%     subplot(1,5,3); imagesc(abs(E(:,:,z,t))); title(['abs kspace z=' num2str(z) ' t=' num2str(t)])
    subplot(1,5,4); imagesc(angle(ksP(:,:,z,t))); title(['angle kspace z=' num2str(z) ' t=' num2str(t)])
    subplot(1,5,5); imagesc(abs(rsP(:,:,z,t))); title(['rspace z=' num2str(z) ' t=' num2str(t)])
    colormap gray
end

%% Display data_fdf and data_fid
if param.fdf_comp && param.display
    disp('Display data_fdf and data_fid')
    display_function(data_fdf,rsP,'Varian','tripleref');
end

%% Save in .nii
if param.save_nii
    [pathstr, name, ext] = fileparts(fid_file);
    output_dir=[pathstr filesep name '_recon.nii' filesep];
    if ~exist(output_dir,'dir')
        mkdir(output_dir);
    end
    output_file=[output_dir 'tripleref.nii'];
    output_file_rs_phase=[output_dir 'pointwise_phase.nii'];
    try
        disp(['Writing ' output_file])
        aedes_write_nifti(abs(rsP),output_file);
        if param.outputphase
            disp(['Writing ' output_file_rs_phase])
            aedes_write_nifti(angle(rsP),output_file_rs_phase);
        end
    catch exception
        errordlg(['unable to write ' output_file])
    end
end
disp('done')

