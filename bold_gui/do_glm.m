function handles = do_glm(handles)
%Construction of protocol
spm_jobman('initcfg');
S.Nstim = str2double(get(handles.NumberOfStims,'String')); %Any large enough number -- the extra stims will not matter
S.Delay = str2double(get(handles.Delay,'String'));
S.DurationFirstStim = str2double(get(handles.DurationFirstStim,'String'));
S.DurationOtherStims = str2double(get(handles.DurationOtherStims,'String'));
S.StartFirstStim = str2double(get(handles.StartFirstStim,'String'));
S.RestBetweenStims = str2double(get(handles.RestBetweenStims,'String'));

S.BlockDuration = S.RestBetweenStims + S.DurationOtherStims;
S.DelayFirstStim = S.Delay+S.StartFirstStim;
handles.AllData.ons = [S.DelayFirstStim S.DelayFirstStim+S.DurationFirstStim+S.RestBetweenStims+...
    (0:S.BlockDuration:S.Nstim*S.BlockDuration)]; %onset times
handles.AllData.dur_eff = [S.DurationFirstStim repmat(S.DurationOtherStims,[1 length(handles.AllData.ons)-1])];
handles.AllData.S = S;
%Get path
if isfield(handles.AllData,'dirBOLDnii')
    [dirTmp dummy] = fileparts(handles.AllData.dirBOLDnii);
else
    if isfield(handles.AllData,'dirBOLDfdf')
        [dirTmp dummy] = fileparts(handles.AllData.dirBOLDfdf);
    end
end
dirBOLDnii = [dirTmp(1:end-4) '.nii'];
handles.AllData.dirBOLDnii = dirBOLDnii;
%Write nifti
B0 = handles.AllData.B0;
write_nifti(B0,dirBOLDnii);
%Realign and smooth
realign_smooth(dirBOLDnii,handles);
%Do GLM
handles.AllData.pathStat = [dirTmp(1:end-4) '.stat'];
if exist(handles.AllData.pathStat,'dir') %avoid overwriting results
    strnow = datestr(now);
    strnow = strrep(strnow, ':', '_');     
    handles.AllData.GLM_time = strnow;
    handles.AllData.pathStatRoot = dirTmp(1:end-4);
    handles.AllData.pathStat = [dirTmp(1:end-4) strnow '.stat'];    
end
glm_estimate(dirBOLDnii,handles)
%Display results
glm_display(handles);