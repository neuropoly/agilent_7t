function icm_move_v4d(in,output,recon,subfile)
% icm_move_v4d('../data/fsems*','./test/')
[list, path]=sct_tools_ls([in '.nii'],0);

if nargin<3, recon=[]; end
if nargin<4, subfile='v4d/v4d.nii.gz'; end
[~,~,ext]=sct_tool_remove_extension(subfile,0);
if isempty(fileparts(output)), output=[pwd filesep output]; end
if ~exist(output,'dir'), mkdir(output);end
nb_folders=length(list);

for i_folder=1:nb_folders
    % Go to folder and read sequence name
    disp(['cp ' path list{i_folder} '/v4d/' strrep(list{i_folder},'.nii','') '* ' output])
    unix(['cp ' path list{i_folder} filesep subfile ' ' output filesep strrep(list{i_folder},'.nii','') ext]);
    unix(['cp ' path list{i_folder} '/v4d/' strrep(list{i_folder},'.nii','') '* ' output]);
    for i=recon
        unix(['cp ' path strrep(list{i_folder},'.nii','_recon.nii') '/rs_xcorr_type' num2str(i) '.nii ' output '/' list{i_folder} '.gz']);
    end
end


