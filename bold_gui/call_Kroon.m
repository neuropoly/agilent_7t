function handles = call_Kroon(handles)
%Addpath
[pdir dummy] = fileparts(which('BOLD_GUI'));
addpath(fullfile(pdir,'FA_DT'));
handles = call_DTI(handles);
handles = call_FT(handles);
