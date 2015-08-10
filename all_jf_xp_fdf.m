clear variables;
close all;
param_fields = {'DurationFirstStim','DurationOtherStims','StartFirstStim','RestBetweenStims'};
param.smoothing=1;
param.realign=1;

% %% s_20140117_MouseBold01
% xp_folder = '/Users/jepelh/data/s_20140117_MouseBold01';
% input = [xp_folder filesep 'epip_01.img'];
% output = [input date '_analysis'];
% param.(param_fields{1}) = 20;
% param.(param_fields{2}) = 20;
% param.(param_fields{3}) = 20;
% param.(param_fields{4}) = 40;
% icm_mouse_pipeline(input,output,param);
% 
% input = [xp_folder filesep 'epip_02.img'];
% output = [input date '_analysis'];
% param.(param_fields{1}) = 20;
% param.(param_fields{2}) = 20;
% param.(param_fields{3}) = 15;
% param.(param_fields{4}) = 40;
% icm_mouse_pipeline(input,output,param);
% 
% input = [xp_folder filesep 'epip_0.5iso01.img'];
% output = [input date '_analysis'];
% param.(param_fields{1}) = 20;
% param.(param_fields{2}) = 20;
% param.(param_fields{3}) = 55;
% param.(param_fields{4}) = 40;
% icm_mouse_pipeline(input,output,param);
% 
% %% s_20140207_MouseBold02
% xp_folder = '/Users/jepelh/data/s_20140207_MouseBold02';
% input = [xp_folder filesep 'epip_mouse_head_0_5iso01.img'];
% output = [input date '_analysis'];
% param.(param_fields{1}) = 11.5;
% param.(param_fields{2}) = 20;
% param.(param_fields{3}) = 15;
% param.(param_fields{4}) = 40;
% icm_mouse_pipeline(input,output,param);
% 
% input = [xp_folder filesep 'epip_mouse_head_0_5iso02.img'];
% output = [input date '_analysis'];
% param.(param_fields{1}) = 20;
% param.(param_fields{2}) = 20;
% param.(param_fields{3}) = 25;
% param.(param_fields{4}) = 40;
% icm_mouse_pipeline(input,output,param);
% 
% input = [xp_folder filesep 'epip_mouse_head_0_75iso01.img'];
% output = [input date '_analysis'];
% param.(param_fields{1}) = 20;
% param.(param_fields{2}) = 20;
% param.(param_fields{3}) = 46.5;
% param.(param_fields{4}) = 40;
% icm_mouse_pipeline(input,output,param);
% 
% input = [xp_folder filesep 'epip_mouse_head_1_0iso01.img'];
% output = [input date '_analysis'];
% param.(param_fields{1}) = 20;
% param.(param_fields{2}) = 20;
% param.(param_fields{3}) = 18;
% param.(param_fields{4}) = 40;
% icm_mouse_pipeline(input,output,param);
% 
% input = [xp_folder filesep 'epip_mouse_head_1_5iso01.img'];
% output = [input date '_analysis'];
% param.(param_fields{1}) = 17.5;
% param.(param_fields{2}) = 20;
% param.(param_fields{3}) = 15;
% param.(param_fields{4}) = 40;
% icm_mouse_pipeline(input,output,param);
% 
% input = [xp_folder filesep 'epip_mouse_head_0_5isoHC37o201.img'];
% output = [input date '_analysis'];
% param.(param_fields{1}) = 30;
% param.(param_fields{2}) = 30;
% param.(param_fields{3}) = 30;
% param.(param_fields{4}) = 90;
% icm_mouse_pipeline(input,output,param);
% 
% input = [xp_folder filesep 'epip_mouse_head_0_5isoHC100o201.img'];
% output = [input date '_analysis'];
% param.(param_fields{1}) = 30;
% param.(param_fields{2}) = 30;
% param.(param_fields{3}) = 30;
% param.(param_fields{4}) = 90;
% icm_mouse_pipeline(input,output,param);
% 
% input = [xp_folder filesep 'epip_mouse_head_2isoHC100o201.img'];
% output = [input date '_analysis'];
% param.(param_fields{1}) = 30;
% param.(param_fields{2}) = 30;
% param.(param_fields{3}) = 30;
% param.(param_fields{4}) = 90;
% icm_mouse_pipeline(input,output,param);
% 
% %% s_20140228_MouseBold03
% xp_folder = '/Users/jepelh/data/s_20140228_MouseBold03';
% input = [xp_folder filesep 'epip_mouse_head_01.img'];
% output = [input date '_analysis'];
% param.(param_fields{1}) = 30;
% param.(param_fields{2}) = 30;
% param.(param_fields{3}) = 39.5;
% param.(param_fields{4}) = 30;
% icm_mouse_pipeline(input,output,param);
% 
% input = [xp_folder filesep 'epip_mouse_head_02.img'];
% output = [input date '_analysis'];
% param.(param_fields{1}) = 22;
% param.(param_fields{2}) = 30;
% param.(param_fields{3}) = 18.5;
% param.(param_fields{4}) = 30;
% icm_mouse_pipeline(input,output,param);
% 
% input = [xp_folder filesep 'epip_mouse_head_03.img'];
% output = [input date '_analysis'];
% param.(param_fields{1}) = 22;
% param.(param_fields{2}) = 30;
% param.(param_fields{3}) = 20;
% param.(param_fields{4}) = 30;
% icm_mouse_pipeline(input,output,param);
% 
% input = [xp_folder filesep 'epip_mouse_head_HC01.img'];
% output = [input date '_analysis'];
% param.(param_fields{1}) = 30;
% param.(param_fields{2}) = 30;
% param.(param_fields{3}) = 30;
% param.(param_fields{4}) = 90;
% icm_mouse_pipeline(input,output,param);

%% s_20140926_MouseBold04
xp_folder = '/Volumes/jepelh/data_server/s_20140926_JF_BOLD01';
input = [xp_folder filesep 'epip_mouse_head_jf_32_01.img'];
param.(param_fields{1}) = 30;
param.(param_fields{2}) = 30;
param.(param_fields{3}) = 30;
param.(param_fields{4}) = 90;
output = [input date '_analysis'];
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_jf_32_02.img'];
output = [input date '_analysis'];
param.(param_fields{1}) = 30;
param.(param_fields{2}) = 30;
param.(param_fields{3}) = 30;
param.(param_fields{4}) = 90;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_jf_64_01.img'];
output = [input date '_analysis'];
param.(param_fields{1}) = 30;
param.(param_fields{2}) = 30;
param.(param_fields{3}) = 30;
param.(param_fields{4}) = 90;
icm_mouse_pipeline(input,output,param);

%% s_20150423_MouseBold05
xp_folder = '/Volumes/jepelh/data_server/s_20150423_Mouse_BOLD_HC0201';
input = [xp_folder filesep 'epip_mouse_head_01.img'];
output = [input date '_analysis'];
param.(param_fields{1}) = 180;
param.(param_fields{2}) = 180;
param.(param_fields{3}) = 60;
param.(param_fields{4}) = 180;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_02.img'];
output = [input date '_analysis'];
param.(param_fields{1}) = 180;
param.(param_fields{2}) = 180;
param.(param_fields{3}) = 60;
param.(param_fields{4}) = 180;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_repos01.img'];
output = [input date '_analysis'];
param.(param_fields{1}) = 180;
param.(param_fields{2}) = 180;
param.(param_fields{3}) = 60;
param.(param_fields{4}) = 180;
icm_mouse_pipeline(input,output,param);

%% s_20150423_MouseBold06
xp_folder = '/Volumes/jepelh/data_server/s_20150423_Mouse_BOLD_HC0301';
input = [xp_folder filesep 'epip_mouse_head_01.img'];
output = [input date '_analysis'];
param.(param_fields{1}) = 180;
param.(param_fields{2}) = 180;
param.(param_fields{3}) = 60;
param.(param_fields{4}) = 180;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_02.img'];
output = [input date '_analysis'];
param.(param_fields{1}) = 180;
param.(param_fields{2}) = 180;
param.(param_fields{3}) = 60;
param.(param_fields{4}) = 180;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_03.img'];
output = [input date '_analysis'];
param.(param_fields{1}) = 180;
param.(param_fields{2}) = 180;
param.(param_fields{3}) = 60;
param.(param_fields{4}) = 180;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_repos01.img'];
output = [input date '_analysis'];
param.(param_fields{1}) = 180;
param.(param_fields{2}) = 180;
param.(param_fields{3}) = 60;
param.(param_fields{4}) = 180;
icm_mouse_pipeline(input,output,param);

%% s_20150716_MouseBold07
xp_folder = '/Volumes/Usagers/Etudiants/jepelh/data_server/s_20150716_VarianMouse_JF_102';
input = [xp_folder filesep 'fsems_JF_01.img'];
output = [input date '_analysis'];
param.(param_fields{1}) = 180;
param.(param_fields{2}) = 180;
param.(param_fields{3}) = 60;
param.(param_fields{4}) = 180;
param.TR=30;
[rspace_sr,tmap,raw_quality_stats,pp_quality_stats,param,output] = icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'fsems_JF_02.img'];
output = [input date '_analysis'];
param.(param_fields{1}) = 180;
param.(param_fields{2}) = 180;
param.(param_fields{3}) = 60;
param.(param_fields{4}) = 180;
param.TR=30;
[rspace_sr,tmap,raw_quality_stats,pp_quality_stats,param,output] = icm_mouse_pipeline(input,output,param);

