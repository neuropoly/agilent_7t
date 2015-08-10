function mri_get_B1
try
    run_Label = 'B';
    cutoff = pi;
    path_spm = spm('dir');
    try
        addpath(fullfile(path_spm,'toolbox','mri12','aedes'));
    catch
        disp('Aedes toolbox not found');
    end
    [dir_list sts] = spm_select(1,'dir','Select .fid folder of cine scans for B1 mapping','',pwd,'.fid*');
    [procpar,msg]=aedes_readprocpar(fullfile(dir_list,'procpar'));
    FA0 = procpar.flip1;
    te = procpar.te;
    tr1 = procpar.tr;
    tr2 = 0.021-tr1; %hard-coded, cannot find procpar entry -- mintrseg???
    n = tr2/tr1;
    Nsl = procpar.acqcycles;
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
    nx = nx/2;
    cData = zeros(nx,ny,2,N);
    for n0=1:N
        for k0 = 1:2
            cData(:,:,k0,n0) = mri_fft_no_abs(squeeze(DATA.KSPACE((1:nx)+(k0-1)*nx,:,n0)));
        end
    end
    
    %Mask by anatomical scan
    y = spm_input('Mask by anatomical image?',1,'y/n');
    if strcmp(y,'y')
        [dir_list_anat sts_anat] = spm_select(1,'dir','Select .dcm folder of anatomical scan','',pwd,'.*\.dcm$');
        if sts
            [anat_scans,dummy] = spm_select('FPList',dir_list_anat,'.*\.dcm$');
            Y = dicomread(anat_scans);
            Y = squeeze(Y);
            [nxa nya Na] = size(Y);
            Y2= imresize(Y,[nx,ny]);
            Y3 = zeros(nx,ny,N);
            for i0=1:nx
                Y3(i0,:,:) = imresize(squeeze(Y2(i0,:,:)),[ny,N]);
            end
            A = permute(Y3(end:-1:1,end:-1:1,:),[2 1 3]);
            M = A>1e3;
            mask = 1;
        else
            mask = 0;
        end
    else
        mask = 0;
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
        %r = abs(squeeze(cData(:,:,2,i0))./squeeze(cData(:,:,1,i0)));
        r = abs(squeeze(cData(:,:,2,i0)))./abs(squeeze(cData(:,:,1,i0)));
        %r(r>2) = 2;
        %r(r<0.5) = 0.5;
        v = (r*n-1)./(n-r);
        v(v<-1) = -1;
        v(v>1) = 1;
        FA = acos(v); %Could multiply by 180/pi to show in degrees
        FA = (FA*180/(pi*FA0)-1)*100;
        if mask
            FA = FA .* M(:,:,i0);
        end
        Ftitle = [run_Label ' color flip angle (% change) map for slice ' int2str(i0)];
        h = figure; imagesc(FA); colorbar; title(Ftitle); %colormap(gray); 
%         mri_print_figure(h,Ftitle,OP); close(h);
    end
    a=1;
catch exception
    disp(exception.identifier);
    disp(exception.stack(1));
end