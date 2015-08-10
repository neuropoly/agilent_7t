function handles = display_dicom(handles)
axes(handles.MainImage);
Y = handles.AllData.Y;
a = imagesc(Y); colormap(gray);
axis image
handles = addPoints(handles);
%Calculate SNR, CNR
handles = calculate_SNR_CNR(handles);
