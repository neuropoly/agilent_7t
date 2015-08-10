function [] = eliminate_dot_underscore(input_folder)
% Eliminates all the ._ files of a folder

%%
dot_underscore_list = dir([input_folder filesep '._*']);

for i=1:length(dot_underscore_list)
    cmd = ['rm ' dot_underscore_list(i).name];
    unix(cmd);
end
