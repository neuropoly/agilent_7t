function handles = display_Diffusion(handles)
axes(handles.FigBOLD);
sB = handles.AllData.sA;
D = handles.AllData.D;
TP = handles.AllData.TP; %Direction
D1 = squeeze(D(:,:,TP,sB));
imagesc(D1);
axis off
axis image

%Show all images
D1 = [];
Nd = handles.AllData.Nd;
Nx = handles.AllData.Nx;
Ny = handles.AllData.Ny;
axes(handles.FigBOLDAll); %tag: FigAllAnat
combine_images = 1;
if combine_images
    s0 = 1; %skip the first image (b0) as it is brighter than the others
    c1 = floor((Nd*3/2)^(0.5));
    r1 = floor((Nd*2/3)^(0.5));
    if r1*c1 < Nd
        if (r1+1)*c1 < Nd
            if r1*(c1+1) < Nd
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
            if s0 > Nd
                Av = [Av zeros(Nx,Ny)];
            else
                Av = [Av double(squeeze(D(:,:,s0,sB)))];
            end
        end
        D1 = [D1; Av];
    end
else    
    for i=1:Ns
        %subplot(2,3,i) %to generalize
        D1 = [D1 squeeze(D(:,:,TP,i))];
    end
end
imagesc(D1);
axis off
axis image
handles = Diffusion_add_drag_point(handles);