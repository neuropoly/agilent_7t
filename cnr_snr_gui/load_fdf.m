function handles = load_fdf(handles)
try
    fimage = handles.AllData.fimage;
    DATA = aedes_readfdf(fimage);
    handles.AllData.Y = DATA.FTDATA;
    handles.AllData.V = DATA.HDR.FileHeader;    
catch exception
    disp(exception.identifier);
    disp(exception.stack(1));
end