function handles = call_select_seed(handles)
%To select a seed, first choose the desired slice in FigAnat, then click on
%the select seed button
axes(handles.FigAnat);
h = impoint;
pos = getPosition(h);
name = spm_input('Seed name',0,'s');
if ~isfield(handles.AllData,'seeds')
    s1 = 1;
else
    s1 = length(handles.AllData.seeds)+1;
end
handles.AllData.seeds{s1}.pos = pos;
handles.AllData.seeds{s1}.slice = handles.AllData.sA;
handles.AllData.seeds{s1}.name = name;
figure(handles.figure_BOLD_GUI);
