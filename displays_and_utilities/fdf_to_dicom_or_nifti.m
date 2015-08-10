% This script converts one or many .FDF MRI data to a DICOM and/or Nifti format

%% Initialization
clear all; close all; clc;
[input path]= uigetfile('*.fdf','MultiSelect','on');  %Selects the file to be converted
if iscell(input)
    nb_files = size(input,2);
else
    nb_files = 1;
end
output_format = 'nifti';    % Desired output format ('dicom' or 'nifti' or 'both')

%% Reads and writes the files in the desired format(s)
for k = 1:nb_files
    % Reads the file(s)
    if nb_files == 1
        input_file = fullfile(path,input);
    else
        input_file = fullfile(path,input{k});
    end
    disp(['reading ' input_file])
    try
        DATA = aedes_readfdf(input_file);
    catch exception
        errordlg(['unable to open ' input_file])
    end
    data = uint16(DATA.FTDATA);
    xres = DATA.HDR.FileHeader.roi(1)/DATA.HDR.FileHeader.matrix(1);
    yres = DATA.HDR.FileHeader.roi(2)/DATA.HDR.FileHeader.matrix(2);
    zres = DATA.HDR.FileHeader.roi(3);
    res = [xres yres zres];
    [pathstr, name, ext] = fileparts(input_file);
    [pathstr, folder, ~] = fileparts(pathstr);
    % Writes file(s) in the desired format
    switch output_format
        case 'dicom'
            if k==1
                mkdir([pathstr filesep folder '.dcm'])
            end
            output_file{k} = fullfile([pathstr filesep folder '.dcm'],[name '.dcm']);
            disp(['writing ' output_file{k}])
            try
                dicomwrite(data,output_file{k},'Modality','MR','ImagesInAcquisition',nb_files);
            catch exception
                errordlg(['unable to write ' output_file{k}])
            end
            
        case 'nifti'
            if k==1
                mkdir([pathstr filesep folder '.nii'])
            end
            output_file{k} = fullfile([pathstr filesep folder '.nii'],[name '.nii']);
            disp(['writing ' output_file{k}])
            try
                save_avw(data,output_file{k},'s',res);
            catch exception
                errordlg(['unable to write ' output_file{k}])
            end
            
        case 'both'
            if k==1
                mkdir([pathstr filesep folder '.dcm'])
                mkdir([pathstr filesep folder '.nii'])
            end
            output_file{k} = fullfile([pathstr filesep folder '.nii'],[name '.dcm']);
            disp(['writing ' output_file{k}])
            try
                dicomwrite(data,output_file{k});
            catch exception
                errordlg(['unable to write ' output_file{k}])
            end
            output_file{k} = fullfile([pathstr filesep folder '.dcm'],[name '.nii']);
            disp(['writing ' output_file{k}])
            try
                save_avw(data,output_file{k},'s',res);
            catch exception
                errordlg(['unable to write ' output_file{k}])
            end
            
        otherwise
            errordlg('wrong output_format')
    end
    clear data input_file
end

%% Move files to another folder
% [pathname,~,ext] = fileparts (output_file{1});
% [pathname,filename,~] = fileparts (pathname);
% output_dir = fullfile(pathname,[filename '.nii']);
% if ~exist(output_dir,'dir')
%     mkdir(output_dir)
% end
% for k = 1:nb_files
%     movefile([output_file{k} '*'],output_dir);
% end

%% 
% [files2merge pathfiles] = uigetfile('*.nii.gz','MultiSelect','on');
files2merge = output_file;
[pathfiles,~,~] = fileparts(files2merge{1});
% cd(pathfiles)
%% merge images to form 3D nifti files
for k=1:length(files2merge)
    slice(k) = str2num(files2merge{k}(regexp(files2merge{k},'slice')+5:regexp(files2merge{k},'slice')+7));
    image(k) = str2num(files2merge{k}(regexp(files2merge{k},'image')+5:regexp(files2merge{k},'image')+7));
    echo(k) = str2num(files2merge{k}(regexp(files2merge{k},'echo')+4:regexp(files2merge{k},'echo')+6));
    organized_files{slice(k),image(k)} = files2merge{k};
end
nbslice=max(slice);
nbimage=max(image);

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
end

%% Merge volumes to form 4D nifti file
merged_files_4d=fullfile(pathfiles,'v4d');
cmd_files=merged_files_3d{1};
for i=2:nbimage
    cmd_files = [cmd_files ' ' merged_files_3d{i}];
end
cmd = ['fslmerge -t ',merged_files_4d,' ', cmd_files];
disp(['write ' merged_files_4d])
[status result] = unix(cmd); if status, error(result); end


