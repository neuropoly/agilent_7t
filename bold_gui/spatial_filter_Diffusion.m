function handles = spatial_filter_Diffusion(handles)
%Filter D
if isfield(handles.AllData,'F')
    F = handles.AllData.F;
    Nd = handles.AllData.Nd;
    Ns = handles.AllData.Ns;
    %Reinitialize D
    handles = interpolate_Diffusion(handles);
    D = handles.AllData.D;
    for j0=1:Ns
    for i0=1:Nd
        D1 = D(:,:,i0,j0);
        D1 = imfilter(D1,F);
        D(:,:,i0,j0) = D1;
    end
    end
    handles.AllData.D = D;
end