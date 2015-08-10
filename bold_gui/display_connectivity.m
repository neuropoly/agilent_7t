function handles = display_connectivity(handles)
current_seed = handles.AllData.current_seed;
current_fc_slice = handles.AllData.current_fc_slice;
% Display plots on SPM graphics window
h = spm_figure('GetWin', 'Graphics');
spm_figure('Clear', 'Graphics');
spm_figure('ColorMap','jet')
Hpos = 630;
Hoff = 70;
Nseeds = handles.AllData.Nseeds;
Ns = handles.AllData.Ns; 
%Slider for slices
fc_slider_slice_text = uicontrol(h,'Style','text','String','Slice: ','FontSize',14,'Position',[Hpos,1022,70,25]);
handles.fc_slider_slice_text = fc_slider_slice_text;
fc_slider_slice_value = uicontrol(h,'Style','text','String',int2str(current_fc_slice),'FontSize',14,'Position',[Hpos+Hoff,1022,35,25]);
handles.fc_slider_slice_value = fc_slider_slice_value;
fc_slider_slice = uicontrol(h,'Style','slider','String','Slice','SliderStep',[1/Ns 1/Ns],'Min',1/Ns,'Max',1,...
    'Position',[Hpos,1000,70,25],'Value',current_fc_slice/Ns,...
    'Callback',{@fc_slider_slice_Callback});
handles.fc_slider_slice = fc_slider_slice;
%Slider for seeds
fc_slider_seed_text = uicontrol(h,'Style','text','String','Seed: ','FontSize',14,'Position',[Hpos,927,70,25]);
handles.fc_slider_seed_text = fc_slider_seed_text;
fc_slider_seed_value = uicontrol(h,'Style','text','String',int2str(current_seed),'FontSize',14,'Position',[Hpos+Hoff,927,35,25]);
handles.fc_slider_seed_value = fc_slider_seed_value;
fc_slider_seed = uicontrol(h,'Style','slider','String','Seed','SliderStep',[1/Nseeds 1/Nseeds],'Min',1/Nseeds,'Max',1,...
    'Position',[Hpos,900,70,25],'Value',current_seed/Nseeds,...
    'Callback',{@fc_slider_seed_Callback});
handles.fc_slider_seed = fc_slider_seed;
%Slider for seeds (outer loop) and slices (inner loop)
fc_slider_seed_slice_text = uicontrol(h,'Style','text','String','Seed, slice','FontSize',14,'Position',[Hpos,822,140,25]);
handles.fc_slider_seed_slice_text = fc_slider_seed_slice_text;
fc_slider_seed_slice = uicontrol(h,'Style','slider','String','Seed, Slice','SliderStep',...
    [1/(Ns*Nseeds) 1/(Ns*Nseeds)],'Min',1/(Ns*Nseeds),'Max',1,...
    'Position',[Hpos,800,70,25],'Value',(current_fc_slice+(current_seed-1)*Ns)/(Ns*Nseeds),...
    'Callback',{@fc_slider_seed_slice_Callback});
handles.fc_slider_seed_slice = fc_slider_seed_slice;
%Slider for slices (outer loop) and seeds (inner loop)
fc_slider_slice_seed_text = uicontrol(h,'Style','text','String','Slice, seed','FontSize',14,'Position',[Hpos,722,140,25]);
handles.fc_slider_slice_seed_text = fc_slider_slice_seed_text;
fc_slider_slice_seed = uicontrol(h,'Style','slider','String','Slice, Seed','SliderStep',...
    [1/(Ns*Nseeds) 1/(Ns*Nseeds)],'Min',1/(Ns*Nseeds),'Max',1,...
    'Position',[Hpos,700,70,25],'Value',(current_seed+(current_fc_slice-1)*Nseeds)/(Ns*Nseeds),...
    'Callback',{@fc_slider_slice_seed_Callback});
handles.fc_slider_slice_seed = fc_slider_slice_seed;
set(h,'UserData',handles); %Pass handles onward through h
%Now the fast(?) display routine:
handles = update_connectivity(handles);

function fc_slider_slice_Callback(hObject,eventdata)
h = spm_figure('GetWin', 'Graphics');
handles = get(h,'UserData');
Nseeds = handles.AllData.Nseeds;
Ns = handles.AllData.Ns; 
current_fc_slice = round(get(hObject,'Value')*Ns);
current_seed = handles.AllData.current_seed;
set(handles.fc_slider_slice_value,'String',int2str(current_fc_slice));
set(handles.fc_slider_seed_slice,'Value',((current_seed-1)*Ns+current_fc_slice)/(Nseeds*Ns));
set(handles.fc_slider_slice_seed,'Value',((current_fc_slice-1)*Nseeds+current_seed)/(Nseeds*Ns));
handles.AllData.current_fc_slice = current_fc_slice;
handles = update_connectivity(handles);
set(h,'UserData',handles);
%guidata(hObject, handles);

function fc_slider_seed_Callback(hObject,eventdata)
h = spm_figure('GetWin', 'Graphics');
handles = get(h,'UserData');
Nseeds = handles.AllData.Nseeds;
Ns = handles.AllData.Ns; 
current_seed = round(get(hObject,'Value')*Nseeds);
set(handles.fc_slider_seed_value,'String',int2str(current_seed));
current_fc_slice = handles.AllData.current_fc_slice;
set(handles.fc_slider_seed_slice,'Value',((current_seed-1)*Ns+current_fc_slice)/(Nseeds*Ns));
set(handles.fc_slider_slice_seed,'Value',((current_fc_slice-1)*Nseeds+current_seed)/(Nseeds*Ns));
handles.AllData.current_seed = current_seed;
handles = update_connectivity(handles);
set(h,'UserData',handles);
%guidata(hObject, handles);

function fc_slider_seed_slice_Callback(hObject,eventdata)
h = spm_figure('GetWin', 'Graphics');
handles = get(h,'UserData');
Nseeds = handles.AllData.Nseeds;
Ns = handles.AllData.Ns; 
tmp_seed_slice = round(get(hObject,'Value')*Nseeds*Ns);
tmp_slice = mod(tmp_seed_slice,Ns);
if tmp_slice == 0 
    tmp_slice = Ns;
end
current_fc_slice = tmp_slice;
current_seed = ceil(tmp_seed_slice/Ns);
set(handles.fc_slider_seed_value,'String',int2str(current_seed));
set(handles.fc_slider_seed,'Value',current_seed/Nseeds);
handles.AllData.current_seed = current_seed;
set(handles.fc_slider_slice_value,'String',int2str(current_fc_slice));
set(handles.fc_slider_slice,'Value',current_fc_slice/Ns);
set(handles.fc_slider_slice_seed,'Value',((current_fc_slice-1)*Nseeds+current_seed)/(Nseeds*Ns));
handles.AllData.current_fc_slice = current_fc_slice;
handles = update_connectivity(handles);
set(h,'UserData',handles);
%guidata(hObject, handles);

function fc_slider_slice_seed_Callback(hObject,eventdata)
h = spm_figure('GetWin', 'Graphics');
handles = get(h,'UserData');
Nseeds = handles.AllData.Nseeds;
Ns = handles.AllData.Ns; 
tmp_slice_seed = round(get(hObject,'Value')*Nseeds*Ns);
tmp_seed = mod(tmp_slice_seed,Nseeds);
if tmp_seed == 0 
    tmp_seed = Nseeds;
end
current_seed = tmp_seed;
current_fc_slice = ceil(tmp_slice_seed/Nseeds);
set(handles.fc_slider_seed_value,'String',int2str(current_seed));
set(handles.fc_slider_seed,'Value',current_seed/Nseeds);
handles.AllData.current_seed = current_seed;
set(handles.fc_slider_slice_value,'String',int2str(current_fc_slice));
set(handles.fc_slider_seed_slice,'Value',((current_seed-1)*Ns+current_fc_slice)/(Nseeds*Ns));
set(handles.fc_slider_slice,'Value',current_fc_slice/Ns);
handles.AllData.current_fc_slice = current_fc_slice;
handles = update_connectivity(handles);
set(h,'UserData',handles);
%guidata(hObject, handles);