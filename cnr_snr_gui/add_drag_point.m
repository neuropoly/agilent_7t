function handles = add_drag_point(handles,whichPoint)
switch whichPoint
    case 1
        pos(1) = str2double(get(handles.editMainV,'String'));
        pos(2) = str2double(get(handles.editMainH,'String'));
    case 2       
        pos(1) = str2double(get(handles.editNoiseV,'String'));
        pos(2) = str2double(get(handles.editNoiseH,'String'));
    case 3
        pos(1) = str2double(get(handles.editContrastV,'String'));
        pos(2) = str2double(get(handles.editContrastH,'String'));
end
h = impoint(handles.MainImage,pos(1),pos(2));
PointColor = handles.AllData.CurrentPointColor;
PointType = handles.AllData.CurrentPointType;
% Construct boundary constraint function
XLim = get(handles.MainImage,'XLim');
YLim = get(handles.MainImage,'YLim');
XLim(2) = XLim(2)-1;
YLim(2) = YLim(2)-1;
setColor(h,PointColor);
setString(h,PointType);
fcn = makeConstrainToRectFcn('impoint',XLim,YLim);
% Enforce boundary constraint function using setPositionConstraintFcn
setPositionConstraintFcn(h,fcn);
addNewPositionCallback(h,@(h) update_position(h,handles,whichPoint)); %h will become pos
