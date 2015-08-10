function [param] = icm_spm_mouse(pathNii,param)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% parameter verification
Default = spm_get_defaults;
spm_jobman('initcfg')
field_names={'Nstim','Delay','DurationFirstStim','DurationOtherStims','StartFirstStim','RestBetweenStims','TR'};
default_values=[20 0 180 180 60 180 2];
field_verif = isfield(param,field_names);
if sum(field_verif)<length(default_values)
    default_fields = find(field_verif==0);
    for j=default_fields
        param.(field_names{j})=default_values(j);
    end
end

%% Construction of protocol
param.BlockDuration = param.RestBetweenStims + param.DurationOtherStims;
param.DelayFirstStim = param.Delay+param.StartFirstStim;
param.ons = [param.DelayFirstStim param.DelayFirstStim+param.DurationFirstStim+param.RestBetweenStims+...
    (0:param.BlockDuration:param.Nstim*param.BlockDuration)]; %onset times
param.dur_eff = [param.DurationFirstStim repmat(param.DurationOtherStims,[1 length(param.ons)-1])];

%%
param.pathStat = [pathNii filesep 'stats'];
if ~exist(param.pathStat,'dir'), mkdir(param.pathStat); end
ons = param.ons;
dur_eff = param.dur_eff;
TR = param.TR;
HPF =120;
MVT = 1; 
scaling_GLM = 1;
scans = {};
if scaling_GLM 
    scaling = 'Scaling';
else
    scaling = 'None';
end

for i0=1:param.nt
    scans = [scans; fullfile(pathNii,['srvolume' gen_num_str(i0,3) '.nii,1'])];
end
mvt_params = fullfile(pathNii,['rp_volume001.txt']);
%%
matlabbatch{1}.spm.stats.fmri_spec.dir = {param.pathStat};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
%
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = scans;
%
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.name = 'HC';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.onset = ons';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.duration = dur_eff;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond.pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
if MVT
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {mvt_params};
else
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {''};
end
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = HPF;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = scaling; %'None';
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tname = 'Select SPM.mat';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1).sname = 'fMRI model specification: SPM.mat File';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_output = substruct('.','spmmat');
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep;
matlabbatch{3}.spm.stats.con.spmmat(1).tname = 'Select SPM.mat';
matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(1).value = 'mat';
matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(2).value = 'e';
matlabbatch{3}.spm.stats.con.spmmat(1).sname = 'Model estimation: SPM.mat File';
matlabbatch{3}.spm.stats.con.spmmat(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{3}.spm.stats.con.spmmat(1).src_output = substruct('.','spmmat');
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'HC';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'NegHC';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = -1;
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
% warning('off')
spm_jobman('run',matlabbatch);
% warning('on')

end

