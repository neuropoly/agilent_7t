function handles = spatial_filter_BOLD(handles)
%Filter B
if isfield(handles.AllData,'F')
    F = handles.AllData.F;
    Nt = handles.AllData.Nt;
    Ns = handles.AllData.Ns;
    %Reinitialize B
    handles = interpolate_BOLD(handles);
    B = handles.AllData.B;
    for j0=1:Ns
    for i0=1:Nt
        B1 = B(:,:,i0,j0);
        B1 = imfilter(B1,F);
        B(:,:,i0,j0) = B1;
    end
    end
    handles.AllData.B = B;
end