function handles = BOLD_add_drag_point(handles)
DP = handles.AllData.DP;
h = impoint(handles.FigBOLD,DP(1),DP(2));
% Construct boundary constraint function
XLim = get(handles.FigBOLD,'XLim');
YLim = get(handles.FigBOLD,'YLim');
XLim(2) = XLim(2)-1;
YLim(2) = YLim(2)-1;
handles.AllData.FigBOLD_XLim = XLim;
handles.AllData.FigBOLD_YLim = YLim;
addNewPositionCallback(h,@(h) update_BOLD_position(h,handles)); %h will become pos, related to DP
fcn = makeConstrainToRectFcn('impoint',XLim,YLim);
% Enforce boundary constraint function using setPositionConstraintFcn
setPositionConstraintFcn(h,fcn);
setColor(h,'r');

% figure(handles.figure_BOLD_GUI);
% set(handles.figure_BOLD_GUI,'WindowButtonMotionFcn', @hoverCallback);
% axes(handles.FigAnat); %Put to the front so as to allow right-clicking on it
