function handles = Anat_load_fdf(handles)
try
    switch handles.AllData.Amode
        case 1
            %For BOLD mode
            dirAnatfdf = handles.AllData.dirAnatfdf;
            cmd=['rm ' dirAnatfdf '._*']; unix(cmd);
            [fdflist dummy] = spm_select('FPList',dirAnatfdf,'.img*');
            fprocpar = fullfile(dirAnatfdf,'procpar');
            procpar = aedes_readprocpar(fprocpar);
            N = size(fdflist,1);
            for i = 1:N
                fname = fdflist(i,:);
                tmp = aedes_readfdf(fname);
                tmp = double(tmp.FTDATA);
                if i== 1
                    %VA = dicominfo(fname);
                    NsA = procpar.ns; %VA.ImagesInAcquisition; %number of slices
                    [NxA NyA] = size(tmp);
                    A = zeros(NxA,NyA,N);
                end
                A(:,:,i) = tmp;
            end
        case 2
            %For diffusion mode
            %Take first image of each slice
            fileAnatfdf = handles.AllData.fileAnatfdf;
            N = size(fileAnatfdf,1);
            fdflist = {};
            ct = 0;
            Atmp = [];            
            for i = 1:N
                fname = fileAnatfdf(i,:);
                if i == 1
                    [dir0 dummy] = fileparts(fname);
                    fprocpar = fullfile(dir0,'procpar');
                    procpar = aedes_readprocpar(fprocpar);
                end
                im0 = strfind(fname,'image');
                imN = str2double(fname(im0+5:im0+7));
                if imN == 1
                    ct = ct + 1;
                    fdflist = [fdflist; fname];
                    tmp = aedes_readfdf(fname);
                    tmp = double(tmp.FTDATA);
                    if ct == 1
                        %VA = dicominfo(fname);
                        [NxA NyA] = size(tmp);
                    end
                    Atmp = [Atmp tmp];
                end
            end
            NsA = ct;
            A = reshape(Atmp,[NxA,NyA,NsA]);
    end
    handles.AllData.NxA = NxA; %Number of voxels
    handles.AllData.NyA = NyA; %Number of voxels
    handles.AllData.NsA = NsA; %Number of slices
    handles.AllData.A = A; %all the data as 3-D volume: [NxA NyA NsA]
    %handles.AllData.VA = VA; %dicominfo of first iamge
    handles.AllData.Aprocpar = procpar; %Anatomical procpar
    %Maximal intensity
    maxA = max(A(:));
    handles.AllData.ContrastMax = maxA;
    handles.AllData.ContrastMax0 = maxA;
    set(handles.SliderContrastMax,'Value',maxA);
    set(handles.SliderContrastMax,'Max',maxA);
    %set(handles.SliderContrastMax,'SliderStep',[0.01*maxA 0.1*maxA]);
catch exception
    disp(exception.identifier);
    disp(exception.stack(1));
end