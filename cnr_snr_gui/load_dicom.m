function handles = load_dicom(handles)
try
    fimage = handles.AllData.fimage;
    Y = dicomread(fimage);
    V = dicominfo(fimage);
    handles.AllData.Y = Y;
    handles.AllData.V = V;    
catch exception
    disp(exception.identifier);
    disp(exception.stack(1));
end