function handles = select_bad_scans(handles)
axes(handles.TimeCourse1);
h = imline;
pos = getPosition(h);
%pos = api.getPosition()
if ~isfield(handles.AllData,'BadScans')
    handles.AllData.BadScans = [];
end
TR = handles.AllData.TR;
%Nt = handles.AllData.Nt;
x1 = pos(1,1);
x2 = pos(2,1);
%d = (x2-x1);
%xLimits = get(gca,'XLim');  
%yLimits = get(gca,'YLim'); 
%dLimits = xLimits(2)-xLimits(1);
%dt = dLimits/(Nt*TR);
dt = 1; %Assume the plot is displayed correctly in seconds
BS1tmp = ceil(dt*x1/TR);
BS2tmp = ceil(dt*x2/TR);
BS1 = min(BS1tmp,BS2tmp);
BS2 = max(BS1tmp,BS2tmp);
handles.AllData.BadScans = sort(unique([handles.AllData.BadScans BS1:BS2]));
