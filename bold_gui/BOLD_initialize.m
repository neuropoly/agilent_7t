function handles = BOLD_initialize(handles)
%Initialization: BOLD Slice to display -- a mid brain slice
handles.AllData.sB = handles.AllData.sA; %Make sure it's the same slice for BOLD and for anatomical %round(handles.AllData.Ns/2);
handles = interpolate_BOLD(handles);
%Initialization: central point in image
Nx = handles.AllData.Nx;
Ny = handles.AllData.Ny;
DP = [round(Nx/2) round(Ny/2) handles.AllData.sB];
handles.AllData.DP = DP;
handles = display_BOLD(handles);
