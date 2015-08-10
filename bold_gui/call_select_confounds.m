function handles = call_select_confounds(handles)
%To select a confound, first choose the desired slice in FigAnat, then click on
%the select confound button -- select white matter, CSF, etc.
axes(handles.FigAnat);
h = impoint;
setColor(h,'r');
pos = getPosition(h);
name = spm_input('Confound name',0,'s');
if ~isfield(handles.AllData,'confounds')
    s1 = 1;
else
    s1 = length(handles.AllData.confounds)+1;
end
handles.AllData.confounds{s1}.pos = pos;
handles.AllData.confounds{s1}.slice = handles.AllData.sA;
handles.AllData.confounds{s1}.name = name;
figure(handles.figure_BOLD_GUI);
