function handles = Diffusion_load_dicom(handles)
try
    fileDiffusiondicom = handles.AllData.fileDiffusiondicom;
    SkipFirst = get(handles.SkipFirst,'Value'); %Used to remove water reference scan 
    %Use last file to compute number of slices and of directions (including b0 directions)
    fnameL = fileDiffusiondicom(end,:);
    im0 = strfind(fnameL,'image');
    Nd = str2double(fnameL(im0+5:im0+7))-SkipFirst; %number of directions
    im1 = strfind(fnameL,'slice0');
    Ns = str2double(fnameL(im1+5:im1+7)); %Number of slices   
    N = size(fileDiffusiondicom,1);
    dicomlist = {};
    ct = 0;
    for i = 1:N
        fname = fileDiffusiondicom(i,:);
        im0 = strfind(fname,'image');
        d1 = str2double(fname(im0+5:im0+7));
        if d1 >= 1+SkipFirst
            ct = ct + 1;
            im1 = strfind(fname,'slice0');
            s1 = str2double(fname(im1+5:im1+7));
            dicomlist = [dicomlist; fname];
            tmp = dicomread(fname);
            if ct == 1
                V = dicominfo(fname);
                [Nx Ny] = size(tmp);
                D = zeros(Nx,Ny,Nd,Ns);
            end
            D(:,:,d1-SkipFirst,s1) = tmp;
        end
    end
    handles.AllData.Nx0 = Nx; %Number of voxels
    handles.AllData.Ny0 = Ny; %Number of voxels
    handles.AllData.Ns = Ns; %Number of slices
    handles.AllData.Nd = Nd; %Number of directions
    handles.AllData.N = N; %Total number of EPI slices
    handles.AllData.D0 = D; %all the data as 4-D volume: [Nx Ny Nd Ns]
    handles.AllData.V = V; %dicominfo of first volume
    handles.AllData.dicomlist = dicomlist;
catch exception
    disp(exception.identifier);
    disp(exception.stack(1));
end