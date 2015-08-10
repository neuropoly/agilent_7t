function handles = display_Anat(handles)
axes(handles.FigAnat); %tag: FigAnat
sA = handles.AllData.sA;
A = handles.AllData.A;
A1 = squeeze(A(:,:,sA));
NxA = handles.AllData.NxA;
NyA = handles.AllData.NyA;
if isfield(handles.AllData,'DP')
    Nx = handles.AllData.Nx;
    Ny = handles.AllData.Ny;
    %add point to anatomical image
    DP = handles.AllData.DP;
    ar1 = DP(1)*NxA/Nx;
    ar2 = DP(2)*NyA/Ny;
    switch handles.AllData.Amode
        case 1
            np = 4;
        case 2
            np = 1;
    end
    np1a = np;
    np2a = np;
    np1b = np;
    np2b = np;
    if np1a>=ar1, np1a = ar1-1; end
    if np2a>=ar2, np2a = ar2-1; end
    if np1b>=NxA-ar1, np1b = NxA-ar1-1; end
    if np2b>=NyA-ar2, np2b = NyA-ar2-1; end
    A1(ar1-np1a:ar1+np1b,ar2-np2a:ar2+np2b) = handles.AllData.ContrastMax;
end
clims = [0 handles.AllData.ContrastMax];
a = imagesc(A1,clims); colormap(gray);
set(a,'ButtonDownFcn', @FigAnat_ButtonDownFcn);
%set(a,'HitTest','off'); %To make ButtonDownFcn work
axis off
axis image
%Show all images
NsA = handles.AllData.NsA;


A1 = [];
axes(handles.FigAllAnat); %tag: FigAllAnat
combine_images = 1;
if combine_images
    s0 = 0;
    c1 = floor((NsA*3/2)^(0.5));
    r1 = floor((NsA*2/3)^(0.5));
    if r1*c1 < NsA
        if (r1+1)*c1 < NsA
            if r1*(c1+1) < NsA
                r1 = r1+1; c1 = c1+1;
            else
                c1 = c1+1;
            end
        else
            r1 = r1+1;
        end
    end
    for r0 = 1:r1
        Av = [];
        for c0 = 1:c1
            s0 = s0+1;
            if s0 > NsA
                Av = [Av zeros(NxA,NyA)];
            else
                Av = [Av double(squeeze(A(:,:,s0)))];
            end
        end
        A1 = [A1; Av];
    end
else
    for i=1:NsA
        %subplot(2,3,i) %to generalize
        A1 = [A1 squeeze(A(:,:,i))];
    end
end
imagesc(A1,clims); colormap(gray);
%set(ca,'HitTest','Off');
axis off
axis image