function handles = addPoints(handles)
Y = handles.AllData.Y;
%Main Point
pos = round(size(Y)/2);
set(handles.editMainH,'string',pos(1));
set(handles.editMainV,'string',pos(2));
%Point for background noise
pos = round(size(Y)/16);
set(handles.editNoiseH,'string',pos(1));
set(handles.editNoiseV,'string',pos(2));
%Point for contrast
pos = round(size(Y)/4);
set(handles.editContrastH,'string',pos(1));
set(handles.editContrastV,'string',pos(2));

handles.AllData.CurrentPointColor = 'r';
handles.AllData.CurrentPointType = 'Main';
handles = add_drag_point(handles,1); %Specify which point

handles.AllData.CurrentPointColor = 'g';
handles.AllData.CurrentPointType = 'Noise';
handles = add_drag_point(handles,2);

handles.AllData.CurrentPointColor = 'b';
handles.AllData.CurrentPointType = 'Contrast';
handles = add_drag_point(handles,3);