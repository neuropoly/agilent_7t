function handles = BOLD_load_fdf(handles)
try
    dirBOLDfdf = handles.AllData.dirBOLDfdf;
    %get list of images
    [fdflist dummy] = spm_select('FPList',dirBOLDfdf,'.fdf*');
    cmd=['rm ' dirBOLDfdf '._*']; unix(cmd);
    %load procpar
    [procpar,msg] = aedes_readprocpar(dirBOLDfdf);
    if isempty(msg)
        handles.AllData.procpar = procpar;
    end
    N = size(fdflist,1);
    Ns = procpar.ns;
    for i = 1:N
        fname = fdflist(i,:);
        DATA = aedes_readfdf(fname);
        tmp = DATA.FTDATA;
        if i== 1
            [Nx Ny] = size(tmp);
            B = zeros(Nx,Ny,N);
        end
        B(:,:,i) = tmp;
    end
    Nt = N/Ns;
    if strcmp(handles.AllData.procpar.epiref_type,'fulltriple')
        fac = 2;
    else
        fac = 1;
    end
    handles.AllData.TR = fac*handles.AllData.procpar.tr;
    
    B = reshape(B,[Nx Ny Nt Ns]);
    handles.AllData.BadScans = [];
    handles.AllData.Nx0 = Nx; %Number of voxels
    handles.AllData.Ny0 = Ny; %Number of voxels
    handles.AllData.Ns = Ns; %Number of slices
    handles.AllData.Nt = Nt; %Number of time points
    handles.AllData.N = N; %Total number of EPI slices
    handles.AllData.B0 = B; %all the data as 4-D volume: [Nx Ny Nt Ns]
catch exception
    disp(exception.identifier);
    disp(exception.stack(1));
end