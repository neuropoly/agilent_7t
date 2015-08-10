function handles = update_position(pos,handles,whichPoint)
handles=guidata(handles.output);
pos = round(pos); %Gives position as (Horizontal,Vertical)
switch whichPoint
    case 1
        handles.AllData.DPmain = pos;
        set(handles.editMainH,'string',pos(1));
        set(handles.editMainV,'string',pos(2));
    case 2
        handles.AllData.DPnoise = pos;
        set(handles.editNoiseH,'string',pos(1));
        set(handles.editNoiseV,'string',pos(2));
    case 3
        handles.AllData.DPcontrast = pos;
        set(handles.editContrastH,'string',pos(1));
        set(handles.editContrastV,'string',pos(2));
    otherwise 
        disp('Problem with point identification')
end
handles = calculate_SNR_CNR(handles);

