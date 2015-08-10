function glm_display(handles)
try
    pathStat = handles.AllData.pathStat;
    %Tstat BOLD
    A = handles.AllData.A;
    Ns = handles.AllData.Ns;
    Vb = spm_vol(fullfile(pathStat,'spmT_0001.img'));
    Yb = spm_read_vols(Vb);
    Yr = zeros(size(A));
    %Load SPM.mat, for threshold
    [nxT1 nyT1 nzT1] = size(A);
    nx = Vb.dim(1); ny = Vb.dim(2);
    fsems_to_epi_ratio = nxT1/nx;
    
    %resize:
    for i0=1:Ns
        %Yr(:,:,Nslice+1-i0) = imresize(squeeze(Yb(end:-1:1,end:-1:1,i0)),fsems_to_epi_ratio);
        Yr(:,:,i0) = imresize(squeeze(Yb(:,:,i0)),fsems_to_epi_ratio,'nearest');
    end
    %Select a subregion
    ax = 1:handles.AllData.NxA; %10:180; %vertical
    ay = 1:handles.AllData.NyA; %30:230; %horizontal
    %ax = 1:256; ay = 1:256;
    T1s = A(ax,ay,:);
    %T1s = T1s(end:-1:1,end:-1:1,:);
    Y2 = Yr(ax,ay,:);
    %Y2 = Yb;
    th = str2double(get(handles.Threshold,'String')); %2.1; % 2.3; %1.95; %1.95;
    %Ov = 0.99*th*(T1s/max(T1s(:))-0.5);
    mn = min(T1s(:));
    mx = max(T1s(:));
    Ov = 0.9*th*((T1s-mn)/mx-0.5)*2;
    thf = 1.2*th;
    Ov(Y2<-thf) = Y2(Y2<-thf);
    Ov(Y2>thf) = Y2(Y2>thf);
    
    djet = jet(2*64);
    cool = djet(1:64,:);
    cmap = [cool; gray(64); hot(64)];
    clims = [min(Y2(:)) -min(Y2(:))];
    %Map in gray on main figure, since colormap applies to whole figure
    axes(handles.GLMresults);
    A1 = [];
    for i=1:Ns
        A1 = [A1 squeeze(Ov(:,:,i))];
    end
    imagesc(A1,clims); colormap(gray);
    axis off
    axis image
       
    h = figure;
    clims = [min(Y2(:)) -min(Y2(:))];
    for i=1:Ns
        switch Ns
            case 1
            case 2
                subplot(1,2,i);
            case 3
                subplot(1,3,i);
            case 4
                subplot(2,2,i);
            case {5,6}
                subplot(2,3,i);
            case {7,8,9}
                subplot(3,3,i);
            case {10,11,12}
                subplot(3,4,i);
            case {13,14,15}
                subplot(3,5,i);
            case 16
                subplot(4,4,i);
        end
        imagesc(squeeze(Ov(:,:,i)),clims);
        axis off; axis image;
        if i==1
            colorbar
        end
    end;
    colormap(cmap);
    
    fname = fullfile(pathStat,'GLM');
    print(h, '-dpng', [fname '.png'], '-r300');
%     close(h)
    
    output_each_slice_separately = 0;
    if output_each_slice_separately
        for i=1:Ns
            h = figure;
            imagesc(squeeze(Ov(:,:,i)),clims);
            axis off; axis image;
            colormap(cmap);
            hc1 = colorbar('EastOutside');
            hc2 = colorbar('WestOutside');
            sbar = linspace(clims(1), clims(2), 192);
%             hc2 = nirs_set_colorbar(hc2,sbar(1),sbar(64),5,12);
%             hc1 = nirs_set_colorbar(hc1,sbar(129),sbar(192),5,12);
            print(h, '-dpng', [fname 'Slice' gen_num_str(i,2) '.png'], '-r300');
            close(h)
        end
    end
catch exception
    disp(exception.identifier);
    disp(exception.stack(1));
end