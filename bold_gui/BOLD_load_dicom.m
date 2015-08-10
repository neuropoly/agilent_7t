function handles = BOLD_load_dicom(handles)
try
    dirBOLDdicom = handles.AllData.dirBOLDdicom; 
    [dicomlist dummy] = spm_select('FPList',dirBOLDdicom,'.dcm*');
    N = size(dicomlist,1);
    for i = 1:N
        fname = dicomlist(i,:);
        tmp = dicomread(fname);
        if i== 1
            V = dicominfo(fname);
            Ns = V.ImagesInAcquisition; %number of slices
            [Nx Ny] = size(tmp);
            B = zeros(Nx,Ny,N);
        end
        B(:,:,i) = tmp;
    end
    Nt = N/Ns;
    yn = spm_input('Full Triple reference?',0,'y/n');
    if yn == 'y'
        fac = 2;
    else
        fac = 1;
    end
    handles.AllData.TR = fac*V.RepetitionTime/1000;
    B = reshape(B,[Nx Ny Nt Ns]);
    handles.AllData.BadScans = [];
    handles.AllData.Nx0 = Nx; %Number of voxels
    handles.AllData.Ny0 = Ny; %Number of voxels
    handles.AllData.Ns = Ns; %Number of slices
    handles.AllData.Nt = Nt; %Number of time points
    handles.AllData.N = N; %Total number of EPI slices
    handles.AllData.B0 = B; %all the data as 4-D volume: [Nx Ny Nt Ns]
    handles.AllData.V = V; %dicominfo of first volume
catch exception
    disp(exception.identifier);
    disp(exception.stack(1));
end