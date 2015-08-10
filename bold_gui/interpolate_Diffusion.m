function handles = interpolate_Diffusion(handles)
%interpolate
D0 = handles.AllData.D0;
Nd = handles.AllData.Nd;
NxA = handles.AllData.NxA;
NyA = handles.AllData.NyA;
Ns = handles.AllData.Ns;
D = zeros(NxA,NyA,Nd,Ns);
for s1=1:Ns
for p1=1:Nd
    D1 = squeeze(D0(:,:,p1,s1));
    D(:,:,p1,s1) = imresize(D1,[NxA NyA]);
end
end
handles.AllData.D = D; 
handles.AllData.Nx = NxA;
handles.AllData.Ny = NyA;