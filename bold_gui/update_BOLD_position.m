function handles = update_BOLD_position(pos,handles)
XLim = handles.AllData.FigBOLD_XLim;
YLim = handles.AllData.FigBOLD_YLim;
DP(1) = round(YLim(1)+pos(2));
DP(2) = round(XLim(1)+pos(1));
set(handles.VertPos,'string',int2str(DP(1)));
set(handles.HorzPos,'string',int2str(DP(2)));
handles.AllData.DP = [DP handles.AllData.DP(3)];
handles = show_BOLD_time_course(handles);
handles = display_Anat(handles);
%guidata(hObject, handles);