function glm_estimate(pathNii,handles)
N = handles.AllData.Nt;
pathStat = handles.AllData.pathStat;
ons = handles.AllData.ons;
dur_eff = handles.AllData.dur_eff;
TR = handles.AllData.TR;
HPF =120;
MVT = 1; 
scaling_GLM = 1;
scans = {};
if scaling_GLM 
    scaling  = 'Scaling';
else
    scaling = 'None';
end   
%N= 212;
for i0=1:N
    scans = [scans; fullfile(pathNii,['srvolume' gen_num_str(i0,3) '.nii,1'])];
end
mvt_params = fullfile(pathNii,['rp_volume001.txt']);
%Regressors for bad scans
removeBadScans = get(handles.removeBadScans,'Value');
if removeBadScans
    rp = load(mvt_params);
    BadScans = handles.AllData.BadScans;
    Nt = handles.AllData.Nt;
    %TR = handles.AllData.TR;
    for j0=1:length(BadScans)
        if BadScans(j0) > 0 && BadScans(j0) <= Nt
            tmp = [zeros(BadScans(j0)-1,1); 1; zeros(Nt-BadScans(j0),1)];
            rp = [rp tmp];
        end
    end
    badScans_params_file = [handles.AllData.pathStatRoot '_' handles.AllData.GLM_time '.txt'];
    handles.AllData.badScans_params_file = badScans_params_file;
    save(badScans_params_file,'rp','-ascii');
end
if ~exist(pathStat,'dir'), mkdir(pathStat); end
matlabbatch{1}.spm.stats.fmri_spec.dir = {pathStat};
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
    if removeBadScans
        matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {badScans_params_file};
    else
        matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {mvt_params};
    end
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
warning('off')
spm_jobman('run',matlabbatch);
warning('on')