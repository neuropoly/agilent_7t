function handles = BOLD_load_fid(handles)
try
    dirBOLDfid = handles.AllData.dirBOLDfid;
    filename = fullfile(dirBOLDfid,'fid');
    tic
    [DATA,msg_out] = aedes_readfid(filename);
    toc
    a=1;
catch exception
    disp(exception.identifier);
    disp(exception.stack(1));
end