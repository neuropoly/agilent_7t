function Amode_update_GUI(handles)
Amode = handles.AllData.Amode;
switch Amode
    case 1
        set(handles.TimeText,'String','Time')
    case 2
        %hide various items
        set(handles.TimeText,'String','Direction')
end