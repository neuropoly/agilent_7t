function icm_procpar2bvec_file(folders)
% icm_procpar2bvec_file('mems*')
% read procpar in .fid folders and put it in .nii folder
currentdir = pwd;

diff_fid_folders=dir([folders '.fid']);
diff_fid_folders=diff_fid_folders(cellfun(@(x) x~=0,{diff_fid_folders(:).isdir}));

cd(fileparts(folders))


nb_folders=size(diff_fid_folders,1);

for i_folder=1:nb_folders
    % Go to folder and read sequence name
    cd(diff_fid_folders(i_folder).name)
    proc_file='procpar';
    [~,acq_basename,~]=fileparts(cd);
    
    % read procpar
    proc=aedes_readprocpar(proc_file);
    
    % test data type
    % diffusion
    if isfield(proc,'dro') && length(proc.dro)>1 && (2*(proc.volumes +1)==length(proc.dro(:)) || proc.volumes==length(proc.dro(:)))
        bvec=[proc.dro(:) proc.dpe(:) proc.dsl(:)];
        
        nb_dwi=size(bvec,1);
        if nb_dwi==2*(proc.volumes +1)
            bvec(1,:)=[];
            bvec(1:2:length(bvec),:)=[];  % YOU MAY HAVE TO PUT IT ON!!
            nb_dwi=size(bvec,1);
        end
        
        bvec_file=[acq_basename '.bvec'];
        fid_bvec   = fopen(bvec_file,'w');
        for i_dwi=1:nb_dwi
            fprintf(fid_bvec, '%f %f %f\n',bvec(i_dwi,:));
        end
        scd_schemefile_create({bvec_file}, 0, proc.tDELTA, proc.tdelta, proc.gdiff*1e-2, proc.te, acq_basename);
        if ~exist(strrep(diff_fid_folders(i_folder).name,'.fid','.nii')), mkdir(strrep(diff_fid_folders(i_folder).name,'.fid','.nii')); end
        if ~exist([strrep(diff_fid_folders(i_folder).name,'.fid','.nii') '/v4d']), mkdir([strrep(diff_fid_folders(i_folder).name,'.fid','.nii') '/v4d']); end
        unix(['mv *_bvecs.txt ../' strrep(diff_fid_folders(i_folder).name,'.fid','.nii') '/v4d/']);
        unix(['mv *_bvals.txt ../' strrep(diff_fid_folders(i_folder).name,'.fid','.nii') '/v4d/']);
        unix(['mv *.scheme ../' strrep(diff_fid_folders(i_folder).name,'.fid','.nii') '/v4d/']);
    % Inversion Recovery
    elseif isfield(proc,'ti') && length(proc.ti)==proc.volumes
        param.ti=proc.ti;
        param.te=proc.te;
        param.tr=proc.tr;
        save('param','param')
        clear param
        unix(['mv param.mat ../' strrep(diff_fid_folders(i_folder).name,'.fid','.nii') '/v4d/' strrep(diff_fid_folders(i_folder).name,'.fid','_param.mat')]);

        
    elseif isfield(proc,'te2')
        param.te2=proc.te+proc.te2;
        param.te1=proc.te;
        param.tr=proc.tr;
        save('param','param')
        clear param
        unix(['mv param.mat ../' strrep(diff_fid_folders(i_folder).name,'.fid','.nii') '/v4d/' strrep(diff_fid_folders(i_folder).name,'.fid','_param.mat')]);
    else
        param.te=proc.te;
        param.tr=proc.tr;
        save('param','param')
        clear param
        unix(['mv param.mat ../' strrep(diff_fid_folders(i_folder).name,'.fid','.nii') '/v4d/' strrep(diff_fid_folders(i_folder).name,'.fid','_param.mat')]);
    end
    
    cd ../
end

cd(currentdir)











% % Diffusion Info
% proc=aedes_readprocpar('procpar');
%
% %select double fields
% names=fieldnames(proc);
% db=structfun(@(x) strcmp(class(x),'double'),proc);
% names=names(~db);
% proc=rmfield(proc,names);
%
% %select vector (remove single values)
% names=fieldnames(proc);
% vect=structfun(@(x) size(x,2)>2,proc);
% names=names(~vect);
% proc=rmfield(proc,names);

