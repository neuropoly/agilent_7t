function mri_average_scans_DTI
%Average scans
[pdir dummy] = fileparts(which('BOLD_GUI'));
addpath(fullfile(pdir,'aedes'));
addpath(fullfile(pdir,'spm'));
%W:\BruceAllen\AllenP2901\cine_higher_res_FA40_5avg05.dcm
[dir_list sts] = spm_select(Inf,'dir','Select folders of scans to average','',pwd,'.dcm*');
Nt  = size(dir_list,1);
write_png = spm_input('Write .png files?','-1','y/n');
inv_scans = spm_input('Inv scans?','-1','y/n');
if inv_scans == 'y'
    inv_str = '_inv';
else
    inv_str = '';
end
if sts
    for n1 = 1:Nt
        cdir = dir_list(n1,:);
        [files dummy] = spm_select('FPList',cdir,'.*');
        N = size(files,1);
        for i1 = 1:N
            fname = files(i1,:);
            tmp = dicomread(fname);
            if n1==1 && i1==1
                if length(size(tmp)) == 4
                    [nx ny nt nz] = size(tmp);
                    D3 = 1;
                else
                    [nx ny] = size(tmp);
                    D3 = 0;
                    nt = 1;
                    nz = 1;
                end
            end
            if i1==1
                V2{n1} = dicominfo(fname);
            end
            if n1==1
                V{i1} = dicominfo(fname);
                [dir0 fil0] = fileparts(V{i1}.Filename);
                if i1==1
                    [path0 file0] = fileparts(dir0);
                    path0 = fullfile(path0,['Average' inv_str]);
                    if ~exist(path0,'dir'), mkdir(path0); end
                end
                V{i1}.Filename = fullfile(path0,[fil0 '.dcm']);
                FilenameNii{i1} = fullfile(path0,[fil0 '.nii']);
                if D3
                    X{i1} = zeros(nx,ny,nt,nz);
                else
                    X{i1} = zeros(nx,ny);
                end
            end
            %tmp = imfilter(tmp,hF);
            %tmp = imresize(tmp,2*size(tmp),'bicubic');
            average_on = 1;
            if average_on
                %Y{i1,n1} = double(tmp);
                X{i1} = X{i1}+double(tmp);
                if n1 == Nt
                    %Return to int16
                    Z{i1} = int16(round(X{i1}/Nt));
                    dicomwrite(Z{i1},V{i1}.Filename,V{i1}, 'CreateMode', 'copy');
                    %write nifti
                    Y = squeeze(Z{i1});
                    V0.fname = FilenameNii{i1};
                    V0.dim = [size(Y) 1];
                    V0.mat = eye(4);
                    V0.dt = [4 1];
                    spm_write_vol(V0,Y);
                end
            end
        end
    end
    save(fullfile(path0,'A3D.mat'),'Y');
    if write_png
        color = 0;
        OP.save_figures_fig = 0;
        OP.save_figures_png = 1;
        OP.pathn = path0;
        %find common min and max
        minI = 0;
        maxI = 0;
        for i0=1:length(Z)
            minI = min(minI,min(Z{i0}(:)));
            maxI = max(maxI,max(Z{i0}(:)));
        end
        %increase dynamic range for display of low intensities
        maxI = maxI/2;
        for i0=1:length(Z)
            for j0=1:nz
                if color
                    fname = ['Image' gen_num_str(i0,3) 'x' gen_num_str(j0,3) 'color2'];
                else
                    fname = ['Image' gen_num_str(i0,3) 'x' gen_num_str(j0,3)];
                end
                if D3
                    W = squeeze(Z{i0}(:,:,1,j0));
                else
                    W = Z{i0};
                end
                %Smooth
                W1 = imresize(W,2);
                h = figure; imagesc(W1,[minI,maxI]); title(fname); %colormap(gray)
                axis off; axis image
                if ~color
                    colormap(gray);
                end
                
                mri_print_figure(h,fname,OP);
                close(h);
            end
        end
    end
end