clear variables;
close all;
param_fields = {'DurationFirstStim','DurationOtherStims','StartFirstStim','RestBetweenStims'};
param{1}.smoothing=1;
param{1}.realign=1;

%% s_20140117_MouseBold01
xp_folder = '/Users/jepelh/data/s_20140117_MouseBold01';
input = [xp_folder filesep 'epip_01.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 20;
param{1}.(param_fields{2}) = 20;
param{1}.(param_fields{3}) = 20;
param{1}.(param_fields{4}) = 40;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_02.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 20;
param{1}.(param_fields{2}) = 20;
param{1}.(param_fields{3}) = 15;
param{1}.(param_fields{4}) = 40;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_0.5iso01.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 20;
param{1}.(param_fields{2}) = 20;
param{1}.(param_fields{3}) = 55;
param{1}.(param_fields{4}) = 40;
icm_mouse_pipeline(input,output,param);

%% s_20140207_MouseBold02
xp_folder = '/Users/jepelh/data/s_20140207_MouseBold02';
input = [xp_folder filesep 'epip_mouse_head_0_5iso01.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 11.5;
param{1}.(param_fields{2}) = 20;
param{1}.(param_fields{3}) = 15;
param{1}.(param_fields{4}) = 40;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_0_5iso02.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 20;
param{1}.(param_fields{2}) = 20;
param{1}.(param_fields{3}) = 25;
param{1}.(param_fields{4}) = 40;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_0_75iso01.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 20;
param{1}.(param_fields{2}) = 20;
param{1}.(param_fields{3}) = 46.5;
param{1}.(param_fields{4}) = 40;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_1_0iso01.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 20;
param{1}.(param_fields{2}) = 20;
param{1}.(param_fields{3}) = 18;
param{1}.(param_fields{4}) = 40;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_1_5iso01.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 17.5;
param{1}.(param_fields{2}) = 20;
param{1}.(param_fields{3}) = 15;
param{1}.(param_fields{4}) = 40;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_0_5isoHC37o201.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 30;
param{1}.(param_fields{2}) = 30;
param{1}.(param_fields{3}) = 30;
param{1}.(param_fields{4}) = 90;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_0_5isoHC100o201.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 30;
param{1}.(param_fields{2}) = 30;
param{1}.(param_fields{3}) = 30;
param{1}.(param_fields{4}) = 90;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_2isoHC100o201.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 30;
param{1}.(param_fields{2}) = 30;
param{1}.(param_fields{3}) = 30;
param{1}.(param_fields{4}) = 90;
icm_mouse_pipeline(input,output,param);

%% s_20140228_MouseBold03
xp_folder = '/Users/jepelh/data/s_20140228_MouseBold03';
input = [xp_folder filesep 'epip_mouse_head_01.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 30;
param{1}.(param_fields{2}) = 30;
param{1}.(param_fields{3}) = 39.5;
param{1}.(param_fields{4}) = 30;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_02.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 22;
param{1}.(param_fields{2}) = 30;
param{1}.(param_fields{3}) = 18.5;
param{1}.(param_fields{4}) = 30;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_03.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 22;
param{1}.(param_fields{2}) = 30;
param{1}.(param_fields{3}) = 20;
param{1}.(param_fields{4}) = 30;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_HC01.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 30;
param{1}.(param_fields{2}) = 30;
param{1}.(param_fields{3}) = 30;
param{1}.(param_fields{4}) = 90;
icm_mouse_pipeline(input,output,param);

%% s_20140926_MouseBold04
xp_folder = '/Users/jepelh/data/s_20140926_MouseBold04';
input = [xp_folder filesep 'epip_mouse_head_jf_32_01.fid'];
param{1}.(param_fields{1}) = 30;
param{1}.(param_fields{2}) = 30;
param{1}.(param_fields{3}) = 30;
param{1}.(param_fields{4}) = 90;
output = [input date '_analysis'];
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_jf_32_02.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 30;
param{1}.(param_fields{2}) = 30;
param{1}.(param_fields{3}) = 30;
param{1}.(param_fields{4}) = 90;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_jf_64_01.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 30;
param{1}.(param_fields{2}) = 30;
param{1}.(param_fields{3}) = 30;
param{1}.(param_fields{4}) = 90;
icm_mouse_pipeline(input,output,param);

%% s_20150423_MouseBold05
xp_folder = '/Users/jepelh/data/s_20150423_MouseBold05';
input = [xp_folder filesep 'epip_mouse_head_01.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 180;
param{1}.(param_fields{2}) = 180;
param{1}.(param_fields{3}) = 60;
param{1}.(param_fields{4}) = 180;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_02.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 180;
param{1}.(param_fields{2}) = 180;
param{1}.(param_fields{3}) = 60;
param{1}.(param_fields{4}) = 180;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_repos01.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 180;
param{1}.(param_fields{2}) = 180;
param{1}.(param_fields{3}) = 60;
param{1}.(param_fields{4}) = 180;
icm_mouse_pipeline(input,output,param);

%% s_20150423_MouseBold06
xp_folder = '/Users/jepelh/data/s_20150423_MouseBold06';
input = [xp_folder filesep 'epip_mouse_head_01.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 180;
param{1}.(param_fields{2}) = 180;
param{1}.(param_fields{3}) = 60;
param{1}.(param_fields{4}) = 180;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_02.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 180;
param{1}.(param_fields{2}) = 180;
param{1}.(param_fields{3}) = 60;
param{1}.(param_fields{4}) = 180;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_03.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 180;
param{1}.(param_fields{2}) = 180;
param{1}.(param_fields{3}) = 60;
param{1}.(param_fields{4}) = 180;
icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'epip_mouse_head_repos01.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 180;
param{1}.(param_fields{2}) = 180;
param{1}.(param_fields{3}) = 60;
param{1}.(param_fields{4}) = 180;
icm_mouse_pipeline(input,output,param);

%% s_20150716_MouseBold07
xp_folder = '/Volumes/Usagers/Etudiants/jepelh/data_server/s_20150716_VarianMouse_JF_102';
input = [xp_folder filesep 'fsems_JF_01.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 180;
param{1}.(param_fields{2}) = 180;
param{1}.(param_fields{3}) = 60;
param{1}.(param_fields{4}) = 180;
param{1}.TR=30;
[rspace_sr,tmap,raw_quality_stats,pp_quality_stats,param,output] = icm_mouse_pipeline(input,output,param);

input = [xp_folder filesep 'fsems_JF_02.fid'];
output = [input date '_analysis'];
param{1}.(param_fields{1}) = 180;
param{1}.(param_fields{2}) = 180;
param{1}.(param_fields{3}) = 60;
param{1}.(param_fields{4}) = 180;
param{1}.TR=30;
[rspace_sr,tmap,raw_quality_stats,pp_quality_stats,param,output] = icm_mouse_pipeline(input,output,param);

