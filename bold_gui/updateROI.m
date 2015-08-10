function handles = updateROI(handles)
ROI = handles.AllData.ROI;
%B = handles.AllData.B;
%NxA = handles.AllData.NxA;
%NyA = handles.AllData.NyA;
handles.AllData.DP(1) = round(mean(ROI.position(:,1)));
handles.AllData.DP(2) = round(mean(ROI.position(:,2)));
handles = show_BOLD_time_course(handles);

