function handles = display_BOLD(handles)
axes(handles.FigBOLD);
sB = handles.AllData.sA; %handles.AllData.sB;
B = handles.AllData.B;
TP = handles.AllData.TP; %Time point
B1 = squeeze(B(:,:,TP,sB));
imagesc(B1);
axis off
axis image
%Show all images
Ns = handles.AllData.Ns;
axes(handles.FigBOLDAll); %tag: FigAllAnat
B1 = [];
for i=1:Ns
    %subplot(2,3,i) %to generalize
    B1 = [B1 squeeze(B(:,:,TP,i))];
end
imagesc(B1);
axis off
axis image
handles = BOLD_add_drag_point(handles);