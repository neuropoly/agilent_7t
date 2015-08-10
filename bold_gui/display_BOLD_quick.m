function handles = display_BOLD_quick(handles)
axes(handles.FigBOLD);
sB = handles.AllData.sA; %handles.AllData.sB;
B = handles.AllData.B;
TP = handles.AllData.TP; %Time point
B1 = squeeze(B(:,:,TP,sB));
imagesc(B1);
axis off
axis image