%%
clear variables; close all;
fid_folder=
% fid_file{1} = '/Volumes/users_hd2-2/jfpp/data/s_20140228_MouseBold0701/epip_mouse_head_01.fid';
% fid_file{2} = '/Volumes/users_hd2-2/jfpp/data/s_20140228_MouseBold0701/epip_mouse_head_02.fid';
% fid_file{3} = '/Volumes/users_hd2-2/jfpp/data/s_20140228_MouseBold0701/epip_mouse_head_03.fid';
% fid_file{4} = '/Volumes/users_hd2-2/jfpp/data/s_20140228_MouseBold0701/epip_mouse_head_HC01.fid';
% fid_file{1} = '/Volumes/users_hd2-2/jfpp/data/s_20140911_PhantomJF03/epip_mouse_head_64x64_01.fid';
% fid_file{2} = '/Volumes/users_hd2-2/jfpp/data/s_20140911_PhantomJF03/epip_mouse_head_64x64_02.fid';
% fid_file{3} = '/Volumes/users_hd2-2/jfpp/data/s_20140911_PhantomJF03/epip_mouse_head_64x64_03.fid';
% fid_file{1} = '/Volumes/data_shared/montreal_icm/20131122_exvivo_spinalcord_01/epip07.fid';
% fid_file = '/Volumes/users_hd2-2/jfpp/data/s_20140926_JF_BOLD01/epip_mouse_head_jf_32_01.fid';
% fid_file{2} = '/Volumes/users_hd2-2/jfpp/data/s_20140926_JF_BOLD01/epip_mouse_head_jf_32_02.fid';
% fid_file{2} = '/Volumes/users_hd2-2/jfpp/data/s_20140926_JF_BOLD01/epip_mouse_head_jf_64_01.fid';

if iscell(fid_file)
    nb_files = length(fid_file);
else
    nb_files = 1;
end
for i=1:nb_files
    param{i}.data=1;
    param{i}.save_nii=1;
    param{i}.center_kspace=0;
    param{i}.nx=64;
    param{i}.ny=64;
    param{i}.display=0;
    param{i}.fdf_comp=0;
    param{i}.vol_pour=1;
    param{i}.median_smoothing=0;
    param{i}.navigator=0;
    param{i}.correction=0;
end
param{2}.median_smoothing=1;

%% Load fdf files
for i=1:nb_files
    if iscell(fid_file)
        [data_fdf{i},param{i}] = read_and_sort_kspace_from_fdf(fid_file{i},param{i});
    else
        [data_fdf,param{i}] = read_and_sort_kspace_from_fdf(fid_file,param{i});
    end
end
disp('Done reading fdf')

%% Load fid files
for i=1:nb_files
    if iscell(fid_file)
        [raw_data_fid{i},param{i}] = read_and_sort_kspace_from_fid(fid_file{i},param{i});
    else
        [raw_data_fid,param{i}] = read_and_sort_kspace_from_fid(fid_file,param{i});
    end
end
disp('Done reading fid')

%% xcorr
for param_corr=0
    for i=1:nb_files
        param{i}.correction=param_corr;
        if iscell(fid_file)
            [ksP_xcorr{i}.(genvarname(num2str(param{i}.correction))),ksN_xcorr{i}.(genvarname(num2str(param{i}.correction))) ...
                ,rsP_xcorr{i}.(genvarname(num2str(param{i}.correction))),rsN_xcorr{i}.(genvarname(num2str(param{i}.correction)))] = ...
                kspace_reading_xcorr(raw_data_fid{i},fid_file{i},param{i});
        else
            [ksP_xcorr.(genvarname(num2str(param{i}.correction))),ksN_xcorr.(genvarname(num2str(param{i}.correction))) ...
                ,rsP_xcorr.(genvarname(num2str(param{i}.correction))),rsN_xcorr.(genvarname(num2str(param{i}.correction)))] = ...
                kspace_reading_xcorr(raw_data_fid,fid_file,param{i});
        end
    end
end

%% pointwise
for i=1:nb_files
    if iscell(fid_file)
        [ksP_pointwise{i},rsP_pointwise{i}] = kspace_reading_pointwise(raw_data_fid{i},fid_file{i},param{i});
    else
        [ksP_pointwise,rsP_pointwise] = kspace_reading_pointwise(raw_data_fid,fid_file,param{i});
    end
end

%% tripleref
for i=1:nb_files
    if iscell(fid_file)
        [ksP_tripleref{i},rsP_tripleref{i}] = kspace_reading_tripleref(raw_data_fid{i},fid_file{i},param{i});
    else
        [ksP_tripleref,rsP_tripleref] = kspace_reading_tripleref(raw_data_fid,fid_file,param{i});
    end
end

%% Compare
close all
% for i=1:nb_files
%     if iscell(fid_file)
%         display_function(data_fdf{i},rsP_xcorr{i},rsP_pointwise{i},rsP_tripleref{i},'varian','xcorr','pointwise','tripleref');
%         [pathstr,name,~] = fileparts(fid_file{i});
%     else
%         display_function(data_fdf,rsP_xcorr.x0,rsP_xcorr.x1,rsP_tripleref,'varian','xcorr5','xcorr6','tripleref');
%         [pathstr,name,~] = fileparts(fid_file);
%     end
% end
% display_function(data_fdf{i},rsP_xcorr{i}.x0,rsP_xcorr{i}.x1,rsP_xcorr{i}.x2,rsP_xcorr{i}.x3,'fdf','xcorr0','xcorr1','xcorr2','xcorr3');
% display_function(data_fdf{i},rsP_xcorr{i}.x4,rsP_xcorr{i}.x5,rsP_xcorr{i}.x6,rsP_xcorr{i}.x7,'fdf','xcorr4','xcorr5','xcorr6','xcorr7');
% display_function(data_fdf{i},rsP_pointwise{i},rsP_tripleref{i},'fdf','pointwise','tripleref');

%% Save in .mat
for i=1:nb_files
    if iscell(fid_file)
        [pathstr,name,~] = fileparts(fid_file{i});
        output_dir=[pathstr filesep name '_recon.nii' filesep];
        output_file=[output_dir 'reconstruction_comparison.mat'];
        disp(['Writing ' output_file])
        save(output_file)
        disp('done')
    else
        [pathstr,name,~] = fileparts(fid_file);
        output_dir=[pathstr filesep name '_recon.nii' filesep];
        output_file=[output_dir 'reconstruction_comparison.mat'];
        disp(['Writing ' output_file])
        save(output_file)
        disp('done')
    end
end
