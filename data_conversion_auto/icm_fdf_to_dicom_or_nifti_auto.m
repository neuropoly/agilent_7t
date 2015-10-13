function icm_fdf_to_dicom_or_nifti_auto(folders)
% icm_fdf_to_dicom_or_nifti_auto('.../data/*_fsems*')
% Convert .img folders to nifti folders

% This script converts one or many .FDF MRI data to a DICOM and/or Nifti format
%% Initialization
dbstop if error
output_format = 'nifti';    % Desired output format ('dicom' or 'nifti' or 'both')
% protocol_path=[cd '/'];  % Path to the protocol folder, with all .fid and .img folders
% list=dir('*.img');
%list=list(cellfun(@(x) x~=0,{list(:).isdir}));
current_dir=cd;

[list, protocol_path]=sct_tools_ls([folders '.img'],0);

%==========================================================================
%==========================================================================
%==========================================================================
%[input path]= uigetfile('*.fdf','MultiSelect','on');  %Selects the file to be converted

nb_folders=length(list);

for i_folder=1:nb_folders
    fdf_files=dir([protocol_path list{i_folder} '/s*.fdf']);
    input={fdf_files(:).name};
    path = [protocol_path list{i_folder} '/'];
    
    if iscell(input)
        nb_files = size(input,2);
    else
        nb_files = 1;
    end
    
    
    %% Reads and writes the files in the desired format(s)
    for k = 1:nb_files
        % Reads the file(s)
        if nb_files == 1
            input_file = fullfile(path,input{1});
        else
            input_file = fullfile(path,input{k});
        end
        disp(['reading ' input_file])
        try
            DATA = aedes_readfdf(input_file);
        catch exception
            errordlg(['unable to open ' input_file])
        end
        data = DATA.FTDATA';
        xres = DATA.HDR.FileHeader.roi(1)/DATA.HDR.FileHeader.matrix(1);
        yres = DATA.HDR.FileHeader.roi(2)/DATA.HDR.FileHeader.matrix(2);
        zres = DATA.HDR.FileHeader.roi(3);
        res = [xres yres zres];
        [pathstr, name, ext] = fileparts(input_file);
        
        % Writes file(s) in the desired format
        switch output_format
            case 'dicom'
                output_file{k} = fullfile(pathstr,[name '.dcm']);
                disp(['writing ' output_file{k}])
                try
                    dicomwrite(data,output_file{k},'Modality','MR','ImagesInAcquisition',nb_files);
                catch exception
                    errordlg(['unable to write ' output_file{k}])
                end
                
            case 'nifti'
                output_file{k} = fullfile(pathstr,[name '.nii']);
                files2merge{k}= [name '.nii'];
                disp(['writing ' output_file{k}])
                try
                    save_avw(data,output_file{k},'f',res);
                catch exception
                    errordlg(['unable to write ' output_file{k}])
                end
                
            case 'both'
                output_file{k} = fullfile(pathstr,[name '.dcm']);
                disp(['writing ' output_file{k}])
                try
                    dicomwrite(data,output_file{k});
                catch exception
                    errordlg(['unable to write ' output_file{k}])
                end
                output_file{k} = fullfile(pathstr,[name '.nii']);
                disp(['writing ' output_file{k}])
                try
                    save_avw(data,output_file{k},'f',res);
                catch exception
                    errordlg(['unable to write ' output_file{k}])
                end
                
            otherwise
                errordlg('wrong output_format')
        end
        clear data input_file
    end
    
    %% Move files to another folder
    [pathname,~,ext] = fileparts (output_file{1});
    [pathname,filename,~] = fileparts (pathname);
    switch output_format
        case 'dicom'
            output_dir = fullfile(pathname,[filename '.dcm']);
        case 'nifti'
            output_dir = fullfile(pathname,[filename '.nii']);
    end
    if ~exist(output_dir,'dir')
        mkdir(output_dir)
    end
    disp(['Moving files to: ' output_dir]);
    for k = 1:nb_files
        movefile([output_file{k} '*'],output_dir);
    end
    
    %%
    if strcmp('nifti',output_format)
        pathfiles = output_dir;
        %% merge images to form 3D nifti files
        for k=1:length(files2merge)
            slice(k) = str2num(files2merge{k}(regexp(files2merge{k},'slice')+5:regexp(files2merge{k},'slice')+7));
            image(k) = str2num(files2merge{k}(regexp(files2merge{k},'image')+5:regexp(files2merge{k},'image')+7));
            echo(k) = str2num(files2merge{k}(regexp(files2merge{k},'echo')+4:regexp(files2merge{k},'echo')+6));
            organized_files{slice(k),max(image(k),echo(k))} = fullfile(pathfiles, files2merge{k});
        end
        nbslice=max(slice);
        nbimage=max(image);
        if nbimage==1
            nbimage=max(echo);
        end
        nbecho=max(echo);
        
        for j=1:nbimage
            merged_files_3d{j}=fullfile(pathfiles,['volume' num2str(j)]);
            %     merged_files_3d{j}=organized_files{1,j}([1:regexp(organized_files{1,j},'slice')-1 regexp(organized_files{1,j},'image'):end]);
            cmd_files=organized_files{1,j};
            for i=2:nbslice
                cmd_files = [cmd_files ' ' organized_files{i,j}];
            end
            cmd = ['fslmerge -z ',merged_files_3d{j},' ', cmd_files];
            disp(['write ' merged_files_3d{j} '.nii.gz'])
            [status result] = unix(cmd); if status, error(result); end

            
            for i=1:nbslice
                unix(['rm ' organized_files{i,j} '*']);
            end            
            
        end
        
        %% Merge volumes to form 4D nifti file
        mkdir(pathfiles,'v4d')
        merged_files_4d=fullfile(pathfiles,['v4d/' strrep(list{i_folder},'.img','.nii')]);
        cmd_files=merged_files_3d{1};
        for i=2:nbimage
            cmd_files = [cmd_files ' ' merged_files_3d{i}];
        end
        cmd = ['fslmerge -t ',merged_files_4d,' ', cmd_files];
        disp(['write ' merged_files_4d])
        [status result] = unix(cmd); if status, error(result); end
        
        if nbecho>1
            unix(['rm ' pathfiles '/*.nii*']);
        end
        
    end
    clear files2merge organized_files slice image echo cmd_files output_file
end

cd(current_dir);
