function handles = Diffusion_initialize(handles)
%Initialization: Diffusion Slice to display -- a mid brain slice
handles.AllData.sB = handles.AllData.sA; %Make sure it's the same slice for Diffusion and for anatomical %round(handles.AllData.Ns/2);
handles = interpolate_Diffusion(handles);
%Initialization: central point in image
Nx = handles.AllData.Nx;
Ny = handles.AllData.Ny;
DP = [round(Nx/2) round(Ny/2) handles.AllData.sB];
handles.AllData.DP = DP;
handles = display_Diffusion(handles);
