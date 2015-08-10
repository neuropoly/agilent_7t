function handles = interpolate_BOLD(handles)
%interpolate
B0 = handles.AllData.B0;
Nt = handles.AllData.Nt;
NxA = handles.AllData.NxA;
NyA = handles.AllData.NyA;
Ns = handles.AllData.Ns;
B = zeros(NxA,NyA,Nt,Ns);
for s1=1:Ns
for p1=1:Nt
    B1 = squeeze(B0(:,:,p1,s1));
    B(:,:,p1,s1) = imresize(B1,[NxA NyA]);
end
end
handles.AllData.B = B; 
handles.AllData.Nx = NxA;
handles.AllData.Ny = NyA;