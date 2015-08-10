function handles = display_Diffusion_quick(handles)
axes(handles.FigBOLD);
sB = handles.AllData.sA; %handles.AllData.sB;
D = handles.AllData.D;
TP = handles.AllData.TP; %Time point
D1 = squeeze(D(:,:,TP,sB));
imagesc(D1);
axis off
axis image