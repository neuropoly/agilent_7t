function selection = select_files_rec(folder,pref,mid,suf,ext,type,fpath,levels)
% 
% SELECTION = SELECT_FILES_REC(FOLDER,PREF,MID,SUF,EXT,TYPE,FPATH,LEVELS)
% 
% Select files/folders recursively.
% 
% 
%INPUT
%-----
% - FOLDER: parent directory to look the files/folders in
% - PREF  : files/folders prefix
% - MID   : middle part of the files/folders
% - SUF   : files/folders suffix
% - EXT   : files extension
% - TYPE  : 'files' or 'folders'
% - FPATH : 'path' (SELECTION will have the full path) or 'nopath' (only
%   files/folders names)
% - LEVELS: number of levels to go in recursively (0 [files/folders only
%   from FOLDER], 1, 2, ..., Inf)
% 
%TIPS
%----
% - PREF, MID, SUF and EXT can be empty strings
% - EXT is ignored if TYPE = 'folders'
% - SELECT_FILES_REC is case-insensitive
% - You cannot use ';' in the files/folders names
% - Use LEVELS = Inf to get all subfolders
% 
% 
%OUTPUT
%------
% - SELECTION: cell array containing the file/folder names
% 
% 
%EXAMPLE
%-------
% selection = select_files_rec('C:\MyDocs','','program','_new','m',...
%     'files','path',2);
% 
% 
% See also SELECT_FILES

% Guilherme Coco Beltramini (guicoco@gmail.com)
% 2012-Sep-10, 12:11 pm

curr_dir = pwd; % current directory

if folder(end)==filesep % there is a file separator in the end
    folder(end) = [];
end
orig_sep   = length(strfind(folder,filesep));
folders    = genpath(folder); % get all subfolders
folder_sep = strfind(folders,pathsep);


% Loop for all subfolders
%------------------------
selection = select_files(folder,pref,mid,suf,ext,type,fpath);
for ff=2:length(folder_sep)
    tmp_folder = folders( (folder_sep(ff-1)+1) : (folder_sep(ff)-1) );
    if length(strfind(tmp_folder,filesep))-orig_sep>levels
        continue
    end
    selection = [selection ; select_files(tmp_folder,pref,mid,suf,ext,type,fpath)];
end


% Remove empty cells
%-------------------
selection(cellfun(@isempty,selection)) = [];


% Go back to the current directory
%---------------------------------
cd(curr_dir)