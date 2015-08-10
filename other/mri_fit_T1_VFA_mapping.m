function mri_fit_T1_VFA_mapping
try
    hF = fspecial('gaussian', [5 5], 1); 
    nFA = spm_input('Number of flip angles?','0');
    for cF = 1:nFA
        FA(cF) = spm_input('Flip angle for this next series of images');
        [t_list{cF} sts] = spm_select(Inf,'any','Select DICOM files for this FA','',pwd);
        t = t_list{cF};
        if sts
            N = size(t,1);
            first_pass = 1;
            keep_going = 1;
            for i = 1:N
                fname = t(i,:);
                V = dicominfo(fname);
                tmp = dicomread(fname);
                tmp = imfilter(tmp,hF);
                %tmp = imresize(tmp,2*size(tmp),'bicubic');
                [dir0 fil0] = fileparts(fname);
                cS = str2double(fil0(6:8));
                if i==1 && cF == 1
                    TR = V.RepetitionTime/1000; %Repetition time in s
                    %Choose ROI
                    h = figure; imagesc(tmp); colormap(gray);
                    H = imrect;
                    BW = createMask(H); %roipoly;
                    %pos = getPosition(H);
                    close(h);
                    for j0=1:size(BW,1);
                        t1 = find(BW(j0,:));
                        if ~isempty(t1)
                            v1 = length(t1); %t1(end)-t1(1);
                            break
                        end
                    end
                    BW1 = find(BW);
                    v2 = length(BW1);
                    tmp0 = reshape(tmp(BW),[],v1);
                    [nx ny] = size(tmp0);
                end
                tmp = reshape(tmp(BW),[],v1);
                X{cF,cS} = tmp;
            end
        end
    end
    save('X.mat','X','FA');
    %load('X.mat');
    %superpose DICOM images
    Ns = size(X,2); %number of slices
    Nf = size(X,1); %number of flip angles
    for f0=1:Nf
        divsin(f0) = 1/sin(FA(f0)*pi/180);
        divtan(f0) = 1/tan(FA(f0)*pi/180);
    end
    [path0 dummy] = fileparts(t_list{1}(1,:));
    [path0 dummy] = fileparts(path0);
    fn1 = 'slice';
    fn2 = 'image001';
    fn3 = 'echo';
    
    robust = 0;
    if robust
        statset('nlinfit');
        options = statset('robust','on','display','iter','TolX',1e-10);
    else
        statset('nlinfit');
        options = statset('robust','off','display','off');
    end
    %
    %tmpY = zeros(1,Nf);
    %tmpX = zeros(1,Nf);
    tmp1 = zeros(1,Nf);
    warning('off')
    for s0 = 1:Ns
        tic
        s0
        T1{s0} = zeros(nx,ny);
        T1mod{s0} = zeros(nx,ny);
        Xd{s0} = zeros(nx,ny);
        Yd{s0} = zeros(nx,ny);
        P2{s0} = zeros(nx,ny);
        %Q{s0} = zeros(nx,ny);
        P1{s0} = zeros(nx,ny);
        for z1 = 1:nx %(nx/2-10):(nx/2+10) %1:nx
            for z2 = 1:ny
                for f0=1:Nf
                    tmp1(f0) = X{f0,s0}(z1,z2);
                end
                tmpX = double(tmp1(1:Nf)).*divtan(1:Nf);
                tmpY = double(tmp1(1:Nf)).*divsin(1:Nf);
                [p S mu] = polyfit(tmpX,tmpY,1);
                p(1) = p(1)/mu(2);
                if p(1) < 0, p(1) = 1e-6; end
                T1{s0}(z1,z2) = -TR/log(p(1));
                P2{s0}(z1,z2) = p(2);
                P1{s0}(z1,z2) = p(1);
                Xd{s0}(z1,z2) = tmpX(1)-tmpX(2);
                Yd{s0}(z1,z2) = tmpY(1)-tmpY(2);
                %TMSE{s0}(z1,z2) = mu(1);
            end
        end
        T = T1{s0};
        T(T>10) = 0;
        T(T<0) = -0.1;
        T1mod{s0} = T;
        toc
        figure; imagesc(T1mod{s0}); colorbar; title(['T1 map for sl ' int2str(s0)]);
        %maps of other objects
        other_images = 0;
        if other_images
            figure; imagesc(P2{s0}); colorbar; title(['P2 map for sl ' int2str(s0)]);
            figure; imagesc(P1{s0}); colorbar; title(['P1 map for sl ' int2str(s0)]);
            figure; imagesc(Xd{s0}); colorbar; title(['Xd map for sl ' int2str(s0)]);
            figure; imagesc(Yd{s0}); colorbar; title(['Yd map for sl ' int2str(s0)]);
            %figure; imagesc(TMSE{s0}); colorbar; title(['MSE map for sl ' int2str(s0)]);            
        end
        a = 1;
    end
    %figure; x=0:0.01:(pi/2-0.2); plot(x,sin(x)); hold on; plot(x,tan(x),'r');
    %figure; x=0:(0.01/(pi/180)):((pi/2-0.2)/(pi/180)); plot(x,sin(x*(pi/180))); hold on; plot(x,tan(x*(pi/180)),'r');
    %figure; x=(0.1/(pi/180)):(0.01/(pi/180)):((pi/2-0.2)/(pi/180)); plot(x,1./sin(x*(pi/180))); hold on; plot(x,1./tan(x*(pi/180)),'r');
    
    warning('on')
    save('T1map.mat','T1','B1','B2');
    if ~exist(path1,'dir'), mkdir(path1); end
    for s0=1:Ns
        fname = fullfile(path1,['T2_' fn1 gen_num_str(s0,3) fn2 fn3 gen_num_str(1,3) '.dcm']);
        fname2 = fullfile(path1,['T2_' fn1 gen_num_str(s0,3) fn2 fn3 gen_num_str(1,3) '.fig']);
        fname3 = fullfile(path1,['T2_' fn1 gen_num_str(s0,3) fn2 fn3 gen_num_str(1,3) '.png']);
        %X{s0,e0} = dicomread(fname);
        %V{s0,e0} = dicominfo(fname);
        W{s0} = V{s0,1};
        W{s0}.ImagesInAcquisition = 35;
        Tmp = T2{s0};
        m1 = min(Tmp(:));
        M1 = max(Tmp(:));
        Tmp = round(2^15*((Tmp-m1)/(M1-m1)));
        dicomwrite(Tmp,fname,W{s0});
        h = figure; imagesc(T2{s0}); colorbar; axis off;
        saveas(h,fname2);
        print(h,'-dtiffn',fname3);
        close(h);
    end
catch exception
    disp(exception.identifier);
    disp(exception.stack(1));
end
%
% for s0 = 26
%     T2{s0} = zeros(nx,ny);
%     for z1 = 1:nx
%         for z2 = 1:ny
%             tmpY = Z{s0}(:,z1,z2);
%             if tmpY(1) > tmpY(end)
%                 try
%                     [beta,r0,J,COVB,tmse] = nlinfit(x1',tmpY,@fitT2,[1e3 60],options);
%                     T2{s0}(nx,ny) = beta(2);
%                 end
%             end
%         end
%         z1
%     end
% end

