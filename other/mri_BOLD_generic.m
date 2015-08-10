function mri_BOLD_generic
try
    [MRI_order subj_name path_subj path_epip path_fsems ...
        Nepip ons0 dur0 dur_eff0 ons_delay0 HPF0 scans_to_remove0] = load_BOLD_generic;
    subj = [ 2]; %
    pathA = 'D:\Users\Philippe Pouliot\IRM_scans\BOLD_analysis';
    force_T1 = 0;
    force_preprocess = 0;
    force_stats = 0;    
    use_physiology = 0;
    do_GLM = 0;
    interp_option = 'nearest';
    scaling_GLM = 1; %'Scaling'; %None
    plot_BOLD = 1;
    MVT = 0; %boolean, whether to include movement parameters or not in GLM
    %fsems_to_epi_ratio = 4;
    for su = subj
        cr = MRI_order(su); %current rat
        path0 = path_subj{cr};
        scan = path_epip{cr};
        fsems_scan = path_fsems{cr};
        scans_to_remove = scans_to_remove0{cr};
        HPF = HPF0{cr};
        pathNii = fullfile(path0,[scan '.nii']);
        %TR0 = TR{cr};
        N = Nepip{cr};
        ons_delay = ons_delay0{cr};
        ons = ons0{cr}+ons_delay;
        dur = dur0{cr};
        dur_eff = dur_eff0{cr};
        Stat0 = ['StatD' int2str(dur_eff(1)) '_d' int2str(ons_delay) '_m' int2str(MVT) '_S' int2str(scaling_GLM)];
        Stat1 = [Stat0 '_' interp_option];
        nameID = [gen_num_str(cr,2) '_' gen_num_str(subj_name{cr},2)];
        pathStat = fullfile(pathA,[Stat0 '_' nameID]);
        if ~exist(pathStat,'dir'), mkdir(pathStat); end
        %Get basic info from the EPIP files
        fname0 = fullfile(path0,[scan '.dcm'],'slice001image001echo001.dcm');
        Y0 = dicomread(fname0);
        V0 = dicominfo(fname0);
        [nx ny] = size(Y0);
        Nslice = V0.ImagesInAcquisition;
        %         if use_physiology
        %             reg = mri_load_rat_physiology(path0,['HC' nameID]);
        %         end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Step 1: Copy T1 image to convenient location and change name --
        %need to start from DICOM, since the NII produced by Varian has
        %incorrect information on pixel size and positions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        clear matlabbatch
        fnameT1 = fullfile(path0, 'T1.nii');
        if ~exist(fnameT1,'file') || force_T1
            pathT1 = fullfile(path0,'tempT1.nii');
            if ~exist(pathT1,'dir'), mkdir(pathT1); end
            matlabbatch = mri_matlabbatch_dicom_to_nifti(path0,pathT1,fsems_scan,1,Nslice);
            spm_jobman('run',matlabbatch);
            [files,dirs] = spm_select('FPList',pathT1,'.*');
            [dir0 fil0 ext0] = fileparts(files(1,:));
            movefile(files(1,:),fnameT1);
        end
        switch V0.SequenceName
            case 'epip'
                TR = 2*V0.RepetitionTime/1000;
            case 'epi'
                TR = V0.RepetitionTime/1000;
        end
        V0.ImagePositionPatient;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Step 2: convert the DICOM data to NIFTI, to use in SPM8
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~exist(pathNii,'dir')
            %Only convert DICOM if pathNii does not exist. Otherwise, do
            %not run it -- delete the folder if you need to rerun
            mkdir(pathNii);
            clear matlabbatch
            matlabbatch = mri_matlabbatch_dicom_to_nifti(path0,pathNii,scan,N,Nslice);
            spm_jobman('run',matlabbatch);
            [files,dirs] = spm_select('FPList',pathNii,'.*');
            for t0 = 1:size(files,1)
                [dir0 fil0 ext0] = fileparts(files(t0,:));
                movefile(files(t0,:),fullfile(dir0,['volume' gen_num_str(t0,3) '.nii']));
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Step 6: Use SPM8 to estimate the GLM -- see batch in the scripts folder
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fname = fullfile(pathNii,['srvolume' gen_num_str(scans_to_remove+1,3) '.nii']);
        if ~exist(fname,'file') || force_preprocess
            clear matlabbatch
            matlabbatch = mri_matlabbatch_realign_smooth(pathNii,N,scans_to_remove);
            spm_jobman('run',matlabbatch);
        end
        if plot_BOLD
            %Code to load epip data
            for i0 = (scans_to_remove+1):N
                fname = fullfile(path0,[scan '.nii'],['srvolume' gen_num_str(i0,3) '.nii']);
                tV = spm_vol(fname);
                tY = spm_read_vols(tV);
                Z(:,:,:,i0) = tY;
            end
            T = N*TR;
            lp = linspace(T/N+(scans_to_remove)*TR,T,N-scans_to_remove);
            Z = Z(:,:,:,(scans_to_remove+1):end);
            rdus = 2;
            rdusz = 1;
            ROI{1} = [30 48 6]; %max intensity
            ROI{2} = [42 44 6]; %second max
            ROI{3} = [34 38 6]; %weak, deep into brain
            ROI{4} = [33 57 6]; %definitely outside the brain
            lsc{1} = 'k'; lsc{2} = 'b'; lsc{3} = 'g'; lsc{4} = 'r';
            Nf = size(Z,4);
            figure; hold on
            for j0=1:length(ROI)
                [x0 y0 z0] = ndgrid(ROI{j0}(1)-rdus:ROI{j0}(1)+rdus,...
                    ROI{j0}(2)-rdus:ROI{j0}(2)+rdus,ROI{j0}(3)-rdusz:ROI{j0}(3)+rdusz);
                tz = zeros(Nf,1);
                B = [x0(:) y0(:) z0(:)];
                for k0=1:Nf
                    for r0=1:size(B,1)
                        tz(k0) = tz(k0) + Z(B(r0,1),B(r0,2),B(r0,3),k0);
                    end
                    
                end
            
                plot(tz,lsc{j0});
            end
        end
        
        if do_GLM
            if ~exist(fullfile(pathStat,'SPM.mat'),'file') || force_stats
                clear matlabbatch
                matlabbatch = mri_matlabbatch_glm_estimate(pathNii,N,...
                    pathStat,ons,dur_eff,TR,HPF,scans_to_remove,MVT,scaling_GLM);
                spm_jobman('run',matlabbatch);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %Step 7: Superpose t-stat on anatomical and zoom a bit to remove the ear!
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %T1
            V_T1 = spm_vol(fnameT1);
            T1 = spm_read_vols(V_T1);
            %Tstat BOLD
            Vb = spm_vol(fullfile(pathStat,'spmT_0001.img'));
            Yb = spm_read_vols(Vb);
            Yr = zeros(size(T1));
            %Load SPM.mat, for threshold
            [nxT1 nyT1 nzT1] = size(T1);
            fsems_to_epi_ratio = nxT1/nx;
            
            %resize:
            for i0=1:Nslice
                %Yr(:,:,Nslice+1-i0) = imresize(squeeze(Yb(end:-1:1,end:-1:1,i0)),fsems_to_epi_ratio);
                Yr(:,:,i0) = imresize(squeeze(Yb(:,:,i0)),fsems_to_epi_ratio,interp_option);
            end
            %Select a subregion
            ax = 1:256; %10:180; %vertical
            ay = 1:256; %30:230; %horizontal
            %ax = 1:256; ay = 1:256;
            T1s = T1(ax,ay,:);
            %T1s = T1s(end:-1:1,end:-1:1,:);
            Y2 = Yr(ax,ay,:);
            %Y2 = Yb;
            th = 4.5; %1.95;
            %Ov = 0.99*th*(T1s/max(T1s(:))-0.5);
            mn = min(T1s(:));
            mx = max(T1s(:));
            Ov = 0.9*th*((T1s-mn)/mx-0.5)*2;
            thf = 1.2*th;
            Ov(Y2<-thf) = Y2(Y2<-thf);
            Ov(Y2>thf) = Y2(Y2>thf);
            
            djet = jet(2*64);
            cool = djet(1:64,:);
            cmap = [cool; gray(64); hot(64)];
            h = figure;
            %clims = [-max(Y2(:)) max(Y2(:))];
            clims = [min(Y2(:)) -min(Y2(:))];
            for i=1:Nslice
                subplot(3,4,i);
                %imagesc(squeeze(Yr(:,:,i)));
                imagesc(squeeze(Ov(:,:,i))',clims);
                axis off; axis xy;
                if i==Nslice
                    colorbar
                end
            end;
            colormap(cmap);
            pathF = fullfile(pathA,Stat1);
            if ~exist(pathF,'dir'),mkdir(pathF); end
            fname = fullfile(pathF,nameID);
            print(h, '-dpng', [fname '.png'], '-r300');
            close(h)
            
            look_at_time_courses = 0;
            if look_at_time_courses
                %Code to load epip data
                for i0 = first_scan:N
                    fname = fullfile(path0,[scan '.nii'],['srvolume' gen_num_str(i0,3) '.nii']);
                    tV = spm_vol(fname);
                    tY = spm_read_vols(tV);
                    Z(:,:,:,i0) = tY;
                end
                T = N*TR;
                lp = linspace(T/N+(first_scan-1)*TR,T,N-first_scan+1);
                Z = Z(:,:,:,first_scan:end);
                figure; plot(lp,squeeze(Z(35,48,10,:)));
                figure; plot(lp,squeeze(mean(mean(Z(35-1:35+1,48-1:48+1,10,:),1),2)));
                figure; plot(lp,squeeze(mean(mean(Z(35-2:35+2,48-2:48+2,10,:),1),2)));
                figure; plot(lp,squeeze(mean(mean(Z(35-3:35+3,48-3:48+3,10,:),1),2)));
            end
        end
    end
catch exception
    disp(exception.identifier)
    disp(exception.stack(1))
    try
        disp(exception.stack(2))
        disp(exception.stack(3))
    end
end