function handles = BOLD_load_nii(handles)
% try
    BOLDnii = handles.AllData.BOLDnii;
    handles.AllData.dirBOLDnii = fileparts(handles.AllData.BOLDnii);
    if strcmp(BOLDnii(end-1:end),',1')
        BOLDnii = BOLDnii(1:end-2);
    end
    DATA = aedes_read_nifti(BOLDnii);
    tmp = DATA.FTDATA;
    [Nx Ny Ns Nt] = size(tmp);
    N = Ns*Nt;
    handles.AllData.TR = 2;
    
    B = permute(tmp,[1 2 4 3]);
    B = B(:,end:-1:1,:,:);
    handles.AllData.BadScans = [];
    handles.AllData.Nx0 = Nx; %Number of voxels
    handles.AllData.Ny0 = Ny; %Number of voxels
    handles.AllData.Ns = Ns; %Number of slices
    handles.AllData.Nt = Nt; %Number of time points
    handles.AllData.N = N; %Total number of EPI slices
    handles.AllData.B0 = B; %all the data as 4-D volume: [Nx Ny Nt Ns]
% catch exception
%     disp(exception.identifier);
%     disp(exception.stack(1));
% end