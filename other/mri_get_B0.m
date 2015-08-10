function mri_get_B0
% try
    run_Label = 'A';
    cutoff = pi;
    path_spm = spm('dir');
    try
        addpath(fullfile(path_spm,'toolbox','mri12','aedes'));
    catch
        disp('Aedes toolbox not found');
    end
    [dir_list sts] = spm_select(1,'dir','Select .fid folder of mgems scans for B0 mapping','',pwd,'.fid*');
    [procpar,msg]=aedes_readprocpar(fullfile(dir_list,'procpar'));
    te = procpar.te;
    Nsl = procpar.ns;
    Ne = procpar.ne;
    te_list = linspace(te,Ne*te,Ne);
    OP.save_figures_png = 1;
    OP.save_figures_fig = 1;
    OP.pathn = dir_list;
    DATA=aedes_readfid(fullfile(dir_list,'fid'),...
        'procpar',procpar,...
        'wbar','on',...
        'Return',3,...
        'DCcorrection','off',...
        'Zeropadding','auto',...
        'sorting','on',...
        'FastRead','on',...
        'Precision','single',...
        'OrientImages','on',...
        'RemoveEPIphaseIm','off');
    %     ksp = squeeze(DATA.KSPACE(:,:,1));
    %     rdt = squeeze(DATA.FTDATA(:,:,1));
    
    %calculate the phase in image space rather than k-space
    [nx ny N] = size(DATA.KSPACE);
    cData = zeros(size(DATA.KSPACE));
    for n0=1:N
        cData(:,:,n0) = mri_fft_no_abs(squeeze(DATA.KSPACE(:,:,n0)));
    end
    
    %N = size(t_list,1);
    %TE = [];
    %     %load data
    %     for i0=1:N
    %         fname = t_list(i0,:);
    %         V = dicominfo(fname);
    %         [dir1 fil1] = fileparts(fname);
    %         j0 = str2double(fil1(6:8));
    %         k0 = str2double(fil1(21:23));
    %         Y{j0,k0} = dicomread(fname);
    %         %TE = [TE V.EchoTime];
    %     end
    %     Nsl = j0;
    %     Ne = k0;
    %TE = unique(TE);
    for i0 = 1:Nsl
        ph2 = zeros(nx,ny);
        cr2 = zeros(nx,ny);
        for x0=1:nx
            for y0=1:ny
                Bs = double(angle(squeeze(cData(x0,y0,Ne*(i0-1)+(1:Ne)))));
                su = mri_unwrap_phase(Bs,cutoff);
                [p S] = polyfit(te_list,su,1);   % p returns 2 coefficients fitting r = p_1 * x + p_2
                cor = corr(te_list',su');
                %r = p(1) .* te + p(2); % compute a n
                ph2(x0,y0) = p(1); %frequency -- slope
                cr2(x0,y0) = cor;
            end
        end
        Ftitle = [run_Label ' phase map for sl ' int2str(i0)];
        h = figure; imagesc(ph2); colorbar; colormap(gray); title(Ftitle);
%         mri_print_figure(h,Ftitle,OP); close(h);
        Ftitle = [run_Label ' abs correlation map for sl ' int2str(i0)];
        h = figure; imagesc(abs(cr2)); colorbar; colormap(gray); title(Ftitle);
%         mri_print_figure(h,Ftitle,OP); close(h);
    end
% catch exception
%     disp(exception.identifier);
%     disp(exception.stack(1));
% end