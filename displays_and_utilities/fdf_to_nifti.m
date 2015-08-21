function [data,names] = fdf_to_nifti(input_folder)

% This script converts all the .fdf images contained in the .img subfolders
% of the input_folder

%% Initialization
output_format = 'nifti';    % Desired output format ('dicom' or 'nifti' or 'both')
erase_2d = 0;       % If set to 1, this will erase the 2d volumes to only keep the 3d and 4d files

cd(input_folder)
list=dir('*.img');
list=list(cellfun(@(x) x~=0,{list(:).isdir}));
nb_folders=size(list,1);

for i_folder=1:nb_folders
    cd([input_folder filesep list(i_folder).name])
    fdf_files=dir('*.fdf');
    input={fdf_files(:).name};
    names{i_folder} = list(i_folder).name(1:end-4);
    path = [input_folder filesep list(i_folder).name '/'];
    
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
        if nb_files < 10
            disp(['reading ' input_file])
        end
        try
            DATA = aedes_readfdf(input_file);
        catch exception
            errordlg(['unable to open ' input_file])
        end
        if length(size(DATA.FTDATA))==2
            data{i_folder}(:,:,k) = DATA.FTDATA';
        elseif length(size(DATA.FTDATA))==3
            data{i_folder} = DATA.FTDATA;
        end
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
                    dicomwrite(data{i_folder},output_file{k},'Modality','MR','ImagesInAcquisition',nb_files);
                catch exception
                    errordlg(['unable to write ' output_file{k}])
                end
                
            case 'nifti'
                output_file{k} = fullfile(pathstr,[name '.nii']);
                files2merge{k}= [name '.nii'];
                disp(['writing ' output_file{k}])
                try
%                     save_avw(data,output_file{k},'f',res);
                    aedes_write_nifti(data{i_folder},output_file{k},'VoxelSize',res);
                catch exception
                    errordlg(['unable to write ' output_file{k}])
                end
                
            case 'both'
                output_file{k} = fullfile(pathstr,[name '.dcm']);
                disp(['writing ' output_file{k}])
                try
                    dicomwrite(data{i_folder},output_file{k});
                catch exception
                    errordlg(['unable to write ' output_file{k}])
                end
                output_file{k} = fullfile(pathstr,[name '.nii']);
                disp(['writing ' output_file{k}])
                try
%                     save_avw(data,output_file{k},'f',res);
                    aedes_write_nifti(data{i_folder},output_file{k},'VoxelSize',res);
                catch exception
                    errordlg(['unable to write ' output_file{k}])
                end
                
            otherwise
                errordlg('wrong output_format')
        end
        clear input_file
    end
    
    %% Move files to another folder
    try
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
        disp(['moving files to: ' output_dir]);
        for k = 1:nb_files
            movefile([output_file{k}],output_dir);
        end
    catch
        disp('unable to move files')
    end
    
    if strcmp('nifti',output_format) && strcmp(name(1),'s')
        pathfiles = output_dir;
        cd(pathfiles)
        %% merge images to form 3D nifti files
        for k=1:length(files2merge)
            slice(k) = str2num(files2merge{k}(regexp(files2merge{k},'slice')+5:regexp(files2merge{k},'slice')+7));
            image(k) = str2num(files2merge{k}(regexp(files2merge{k},'image')+5:regexp(files2merge{k},'image')+7));
            echo(k) = str2num(files2merge{k}(regexp(files2merge{k},'echo')+4:regexp(files2merge{k},'echo')+6));
            organized_files{slice(k),max(image(k),echo(k))} = files2merge{k};
        end
        nbslice=max(slice);
        nbimage=max(image);
        if nbimage==1
            nbimage=max(echo);
        end
        nbecho=max(echo);
        
        if nbslice>1
            for j=1:nbimage
                merged_files_3d{j}=fullfile(pathfiles,['volume' num2str(j)]);
                %     merged_files_3d{j}=organized_files{1,j}([1:regexp(organized_files{1,j},'slice')-1 regexp(organized_files{1,j},'image'):end]);
                cmd_files=fullfile(pathfiles,organized_files{1,j});
                for i=2:nbslice
                    cmd_files = [cmd_files ' ' organized_files{i,j}];
                end
                cmd = ['fslmerge -z ',merged_files_3d{j},' ', cmd_files];
                disp(['write ' merged_files_3d{j} '.nii.gz'])
                try
                    [status result] = unix(cmd); if status, error(result); end
                catch
                    disp('unable to merge')
                end
            end
        end
        %% Merge volumes to form 4D nifti file
        if nbimage>1
%             mkdir(pathfiles,'v4d')
            merged_files_4d=fullfile(pathfiles,'v4d');
            cmd_files=merged_files_3d{1};
            for i=2:nbimage
                cmd_files = [cmd_files ' ' merged_files_3d{i}];
            end
            cmd = ['fslmerge -t ',merged_files_4d,' ', cmd_files];
            disp(['write ' merged_files_4d])
            try
                [status result] = unix(cmd); if status, error(result); end
            catch
                disp('unable to merge')
            end
            if nbecho>1
                unix(['rm ' pathfiles '/*.nii*']);
            end
            
            if erase_2d
                cmd = 'rm slice*';
                disp('erasing all 2d files');
                [status result] = unix(cmd); if status, error(result); end
            end
                
            cd('../')
        end
    end
    clear files2merge organized_files slice image echo cmd_files output_file
end


end

