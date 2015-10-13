%% 
clear all; close all; clc

%% Lecture fichier avec fscanf
text_file = '/Users/Tanguy/Dropbox/Taf/mri_icm/sequence/samples.txt';
txt_ID = fopen(text_file);
formatSpec = '%f';
A = txt2mat(text_file);

%% OR
A=zeros(1,4);
%% Organizsation
dro = [0 0 A(:,2)'];
dpe = [0 0 A(:,3)'];
dsl = [0 0 A(:,4)'];

%% add diagonale
%XY
dro=[dro linspace(-1,1,100)];
dpe=[dpe linspace(-1,1,100)];
dsl=[dsl zeros(1,100)];

%-XY
dro=[dro -linspace(-1,1,100)];
dpe=[dpe linspace(-1,1,100)];
dsl=[dsl zeros(1,100)];

% Z
% dro=[dro zeros(1,100)];
% dpe=[dpe zeros(1,100)];
% dsl=[dsl linspace(-1,1,100)];

nbval = 5;
nbzero = 3;
nbdirs = length(dro);


%% Display
gradientsDisplay([dro' dpe' dsl'],0)

%% add virgule
fid = fopen('NODDI.txt','w+');
fprintf(fid, '%s\n\n%s\n%s\n\n%s\n\n',...
    'zero_gf',...
    '// Use temporary variables $dro, $dpe, $dsl to avoid',...
    '// errors about unequal array sizes for dro, dpe, dsl',...
    '// Start with a b=0');

dir_str={'dro','dpe','dsl'};
dir = [dro;dpe;dsl];
for i_dir=1:length(dir_str)
    dro_string = ['$' dir_str{i_dir} ' = $' dir_str{i_dir} ', ' num2str(dir(i_dir,1))];
    fprintf(fid, '\n%s\n',['$' dir_str{i_dir} ' = ' num2str(dir(i_dir,1))]);
    for i=2:length(dro)
        if mod(i-1,6)==0
            fprintf(fid, '%s\n',dro_string);
            dro_string = ['$' dir_str{i_dir} ' = $' dir_str{i_dir} ', ' num2str(dir(i_dir,i))];
        else
            dro_string = [dro_string ', ' num2str(dir(i_dir,i))];
        end
    end
end
fprintf(fid, '\n%s\n%s\n%s\n\n%s\n\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n',... 
    'dro = $dro',...
    'dpe = $dpe',...
    'dsl = $dsl',...
    'set_gf_array',...
    'create(''nbval'',''real'',''current'',0)',...
    'create(''nbzero'',''real'',''current'',0)',...
    'create(''nbdirs'',''real'',''current'',0)',...
    'create(''dstart'',''real'',''current'',0)',...
    ['nbval=' num2str(nbval)],...
    ['nbzero=' num2str(nbzero)],...
    ['nbdirs='  num2str(nbdirs)]);

fclose(fid);

