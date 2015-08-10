mainPath = fullfile(filesep,'Volumes','hd2_local','users_local','jfpp','data','hypercapnia');
asl = 0;
runEPI = 1;
[rat_MRI_order rat_name path_rat path_epip path_fsems ...
    Nepip ons dur dur_eff ons_delay] = load_hypercapnia_rat_dat(runEPI,mainPath);
subj = 15 ; %19:24; % [9 11:20]; %4:19; %[14:19]; %[7:12]; %
pathA = fullfile(mainPath,'Analysis');
force_Timage = 0;
force_preprocess = 0;
force_stats = 1;
remove_first_scan = 1;
if remove_first_scan
    first_scan = 2;
else
    first_scan = 1;
end
use_physiology = 0;
HPF = 240; %in seconds; default: 240 s = 4 minutes
interp_option = 'nearest';
scaling_GLM = 1; %'Scaling'; %None
MVT = 0; %boolean, whether to include movement parameters or not in GLM
fnameTemplate = fullfile(mainPath,'template','head_rat.nii');
spm_jobman('initcfg');
%fsems_to_epi_ratio = 4;

Vtemplate = spm_vol(fnameTemplate);
Ttemplate = spm_read_vols(Vtemplate);
Vtemplate.fname = fnameTemplate;

for su = subj
    cr = rat_MRI_order(su); %current rat
    path0 = path_rat{cr};
    scan = path_epip{cr};
    fsems_scan = path_fsems{cr};
    pathNii = fullfile(path0,[scan '.nii']);
    %TR0 = TR{cr};
    N = Nepip{cr};
    ons_delay0 = ons_delay{cr};
    ons0 = ons{cr}+ons_delay0;
    dur0 = dur{cr};
    dur_eff0 = dur_eff{cr};
    Stat0 = ['StatD' int2str(dur_eff0(1)) '_d' int2str(ons_delay0) '_m' int2str(MVT) '_S' int2str(scaling_GLM) '_R' int2str(runEPI)];
    StaTimage = [Stat0 '_' interp_option];
    nameID = [gen_num_str(cr,2) '_' gen_num_str(rat_name{cr},2)];
    pathStat = fullfile(pathA,[Stat0 '_' nameID]);
    if ~exist(pathStat,'dir'), mkdir(pathStat); end
    %Get basic info from the EPIP files
    if asl == 1
        fname0 = fullfile(path0,[scan '.dcm'],'slice001image0001echo001.dcm');
    else
        fname0 = fullfile(path0,[scan '.dcm'],'slice001image001echo001.dcm');
    end
    Y0 = dicomread(fname0);
    V0 = dicominfo(fname0);
    [nx ny] = size(Y0);
    Nslice = V0.ImagesInAcquisition;
    if use_physiology
        reg = mri_load_rat_physiology_respirationOnly(fullfile(mainPath,'Respiration'),['HC' nameID]);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Step 1: Convert Timage image (anatomical scan) to .nii, read and change
    %to convinient location
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear matlabbatch
    fnameTimage = fullfile(path0, 'Timage.nii');
    % If the anatomical scan isn't converted to .nii yet, convert it
    if ~exist(fnameTimage,'file') || force_Timage
        pathTimage = fullfile(path0,'tempTimage.nii');
        if ~exist(pathTimage,'dir'), mkdir(pathTimage); end
        matlabbatch = mri_set_matlabbatch_old_rats_dicom_to_nifti(path0,pathTimage,fsems_scan,1,Nslice);
        spm_jobman('run',matlabbatch);
        [files,dirs] = spm_select('FPList',pathTimage,'.*');
        [dir0 fil0 ext0] = fileparts(files(1,:));
        movefile(files(1,:),fnameTimage);
    end
    % Read the info of the anatomical scan
%     fnameAnat = fullfile(path0,[fsems_scan '.nii'],'volume0001.nii');
    fnameAnat = fullfile(path0,'Timage.nii');
    Vimage = spm_vol(fnameAnat);
    Timage = spm_read_vols(Vimage);
    VTimage = Vimage;
    fnameTimage = fullfile(path0,'Timage.nii');
    VTimage.fname = fnameTimage;
    % Flip from S-I to I-S
    Timage(:,:,:)=Timage(:,:,Vimage.dim(3):-1:1);
    
    % Copy to convinient location
    if ~exist(VTimage.fname,'file') || force_Timage
        spm_write_vol(VTimage,Timage);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Step 2: Coregister and realign the anatomical scan according to the rat template
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    clear matlabbatch
    matlabbatch = mri_set_matlabbatch_coregister_and_realign(fnameTemplate,fnameAnat);
    spm_jobman('run',matlabbatch);
    
%     [M R] = AC_align(template,fnameTimage,1,'',10);
   

end


%%
center = (size(Timage) + 1) / 2;
T = makehgtform('translate',center,...
    'yrotate',pi,...
    'translate',-center);
T = T';
tT = maketform('affine',T);
tR = makeresampler('linear', 'fill');
TDIMS_A = [1 2 3];
TDIMS_B = [1 2 3];
TSIZE_B = size(Timage);
B = tformarray(Timage, tT, tR, TDIMS_A, TDIMS_B, TSIZE_B,[],[]);
figure
subplot(1,2,1);
p = patch(isosurface(Timage,0.5));
set(p, 'FaceColor', 'red', 'EdgeColor', 'none');
daspect([1 1 1]);
view(3)
camlight
lighting gouraud
subplot(1,2,2);
p = patch(isosurface(B,0.5));
set(p, 'FaceColor', 'red', 'EdgeColor', 'none');
daspect([1 1 1]);
view(3)
camlight
lighting gouraud
