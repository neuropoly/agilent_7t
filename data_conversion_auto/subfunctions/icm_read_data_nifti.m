clear all
list=dir('*.nii');
list=list(cellfun(@(x) x~=0,{list(:).isdir}));
nb_folders=size(list,1);

for i_folder=1:nb_folders
    data(i_folder).name=list(i_folder).name;
    data(i_folder).data=read_avw([list(i_folder).name '/v4d/v4d.nii.gz']);
    if exist([list(i_folder).name '/v4d/' strrep(data(i_folder).name,'.nii','.scheme')])
        fid = fopen([list(i_folder).name '/v4d/' strrep(data(i_folder).name,'.nii','.scheme')],'r');
        fgetl(fid);fgetl(fid);fgetl(fid); % skip first 3 lines
        data(i_folder).scheme = fscanf(fid,'%f %f %f %f %f %f %f',[7,Inf]); data(i_folder).scheme = data(i_folder).scheme';
        data(i_folder).scheme = round(data(i_folder).scheme*10^6)/10^6; % floating-point problems
    end
    
    if exist([list(i_folder).name '/v4d/param.mat'])
        load([list(i_folder).name '/v4d/param.mat'])
        data(i_folder).param = param;
    end

end