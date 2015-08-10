function handles = calculate_SNR_CNR(handles)
pMain(1) = str2double(get(handles.editMainV,'String')); 
pMain(2) = str2double(get(handles.editMainH,'String')); 
pNoise(1) = str2double(get(handles.editNoiseV,'String'));
pNoise(2) = str2double(get(handles.editNoiseH,'String'));
pContrast(1) = str2double(get(handles.editContrastV,'String'));
pContrast(2) = str2double(get(handles.editContrastH,'String'));

Y = handles.AllData.Y;
%Construct ROIs
ROInx = floor(str2double(get(handles.VertSize,'String'))/2);
ROIny = floor(str2double(get(handles.HorzSize,'String'))/2);
BROInx = floor(str2double(get(handles.BVertSize,'String'))/2);
BROIny = floor(str2double(get(handles.BHorzSize,'String'))/2);

Ymain = get_list_in_ROI(Y,pMain,ROInx,ROIny);
Ynoise = get_list_in_ROI(Y,pNoise,BROInx,BROIny);
Ycontrast = get_list_in_ROI(Y,pContrast,ROInx,ROIny);
stdNoise = std(double(Ynoise));
meanNoise = mean(double(Ynoise));
meanMain = mean(double(Ymain));
meanContrast = mean(double(Ycontrast));
SNR = round((meanMain-meanNoise)/stdNoise);
CNR = round(abs(meanContrast-meanMain)/stdNoise);
CNRpct = round(abs(meanContrast/meanMain-1)*100);
set(handles.SNRvalue,'string',int2str(SNR));
set(handles.CNRvalue,'string',int2str(CNR));
set(handles.CNRpercent,'string',int2str(CNRpct));