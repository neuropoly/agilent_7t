function mri_fit_T1_mapping
try
    [t sts] = spm_select(Inf,'any','Select DICOM files of the T1 mapping','',pwd);
    if sts
        N = size(t,1);
        first_pass = 1;
        keep_going = 1;
        for i = 1:N
            fname = t(i,:);
            V = dicominfo(fname);
            tmp = dicomread(fname);
            cF = V.EchoNumber;
            [dir0 fil0] = fileparts(fname);
            cS = str2double(fil0(6:8));            
            if i==1
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
    
    
    %superpose DICOM images
    Ns = size(X,2); %number of slices
    Ne = size(X,1); %number of echoes -- inversion times
    Np = 3; %number of phases, hard coded
    Nt = Ne/Np; %number of time points on the inversion recovery curve
    DeltaT = 0.033; %Time between phases, 1/Np time RR interval, as input in the T1mapping sequence, approximately
    x1 = linspace(DeltaT, DeltaT*Ne, Nt)+0.3;
    [path0 dummy] = fileparts(t(1,:));
    Z = X(:);
    
    figure;
    for i0=0:(Nt-1)
        subplot(3,4,i0+1);
        imagesc(Z{i0*Ns*Np+1}); colormap(gray)
    end
    W = reshape(Z,[Ns Np Nt]);
    figure;
    for i0=0:(Nt-1)
        subplot(3,4,i0+1);
        imagesc(W{Ns-3,1,i0+1}); colormap(gray)
    end
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
    warning('off')
    for s0 = 1:Ns
        for p0=1:Np
            tic
            s0
            T1{s0,p0} = zeros(nx,ny);
            A{s0,p0} = zeros(nx,ny);
            Q{s0,p0} = zeros(nx,ny);
            TMSE{s0,p0} = zeros(nx,ny);
            x1t = x1+(p0-1)*DeltaT;
            for z1 = 1:nx %(nx/2-10):(nx/2+10) %1:nx
                for z2 = 1:ny
                    for t0=1:Nt
                        tmpY(t0) = W{s0,p0,t0}(z1,z2);
                    end
                    
%                     for t0=1:Nt
%                         C1=1;
%                         tmpY(t0) = mean(mean(W{s0,p0,t0}(z1-C1:z1+C1,z2-C1:z2+C1)));
%                     end
                    tmpY= double(tmpY);
                    %if median(tmpY(1:2)) > median(tmpY(end-3:end))
                        try
                            n0 = 1;
                            while n0 < 3 %length(tmpY)-2
                                if tmpY(n0) > tmpY(n0+1) %&& tmpY(n0) > tmpY(n0+2)
                                    tmpY(n0) = -tmpY(n0);
                                end
                                n0 = n0+1;
                            end
                            %[beta,r0,J,COVB,tmse] = nlinfit(x1t',tmpY',@expAbsT1,[0.9 tmpY(end) tmpY(1)],options);
                            [beta,r0,J,COVB,tmse] = nlinfit(x1t',tmpY',@expqT1,[0.2 abs(tmpY(1)) 1],options);
                            T1{s0,p0}(z1,z2) = beta(1);
                            A{s0,p0}(z1,z2) = beta(2);
                            Q{s0,p0}(z1,z2) = beta(3);
                            TMSE{s0,p0}(z1,z2) = tmse;
                        end
                    %end
                end
            end
            T = T1{s0,p0};
            T(T>1.2) = 0;
            T(T<0) = 0;
            T1{s0,p0} = T;
            toc
            figure; imagesc(T1{s0,p0}); colorbar; title(['T1 map for sl ' int2str(s0) ' and phase ' int2str(p0)]);
            %maps of other objects
            other_images = 1;
            if other_images
                figure; imagesc(A{s0,p0}); colorbar; title(['A map for sl ' int2str(s0) ' and phase ' int2str(p0)]);
                figure; imagesc(Q{s0,p0}); colorbar; title(['Q map for sl ' int2str(s0) ' and phase ' int2str(p0)]);
                figure; imagesc(TMSE{s0,p0}); colorbar; title(['MSE map for sl ' int2str(s0) ' and phase ' int2str(p0)]);
      
            end
            a = 1;
        end
    end
    
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

