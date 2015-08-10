%superpose DICOM images
Ns = 35; %number of slices
Ne = 16; %number of echoes
run = 2;

switch run
    case 1
        
        %path0 = '/Users/liom/Documents/IRM_scans/CoeurNano1/mems02.dcm/';
        path0 = 'D:\Users\Philippe Pouliot\IRM_scans\mems02.dcm';
        path1 = 'D:\Users\Philippe Pouliot\IRM_scans\QuantT2';
        TE = 14.21;
    case 2
        %LyCoeur1
        path0 = 'D:\Users\Philippe Pouliot\IRM_scans\LyCoeur1_mems01.dcm';
        path1 = 'D:\Users\Philippe Pouliot\IRM_scans\LyCoeur1_QuantT2';
        TE = 13.5;
end
fn1 = 'slice';
fn2 = 'image001';
fn3 = 'echo';

X{Ns,Ne} = [];
V{Ns,Ne} = [];

for s0=1:Ns
    for e0=1:Ne
        fname = fullfile(path0,[fn1 gen_num_str(s0,3) fn2 fn3 gen_num_str(e0,3) '.dcm']);
        X{s0,e0} = dicomread(fname);
        V{s0,e0} = dicominfo(fname);
        if e0 == 1
            [nx ny] = size(X{1,1});
            Z{s0} = zeros([Ne nx ny]);
        end
        Z{s0}(e0,:,:) = double(X{s0,e0});
    end
end

%
robust = 0;

x1 = TE:TE:TE*Ne;

if robust
    statset('nlinfit');
    options = statset('robust','on');
else
    statset('nlinfit');
    options = statset('robust','off');
end
%
warning('off')
for s0 = 1:Ns
    tic
    s0
    T2{s0} = zeros(nx,ny);
    B2{s0} = zeros(nx,ny);
    B1{s0} = zeros(nx,ny);
    B3{s0} = zeros(nx,ny);
    for z1 = 1:nx %(nx/2-10):(nx/2+10) %1:nx
        for z2 = 1:ny
            tmpY = Z{s0}(:,z1,z2);
            if median(tmpY(1:2)) > median(tmpY(end-3:end))
                try
                    [beta,r0,J,COVB,tmse] = nlinfit(x1',tmpY,@fitT2mod,[1e4 50 1e4],options);
                    T2{s0}(z1,z2) = beta(2);
                    B1{s0}(z1,z2) = beta(1);
                    B2{s0}(z1,z2) = beta(2);
                    B3{s0}(z1,z2) = beta(3);
                end
            end
        end
        z1
    end
    T = T2{s0};
    T(T>2e2) = 0;
    T(T<0) = 0;
    T2{s0} = T;
    toc
end
figure; imagesc(T2{s0});
warning('on')
save('CoeurNanoQuant','T2','B1','B2','B3');
if ~exist(path1,'dir'), mkdir(path1); end
for s0=1:Ns
    fname = fullfile(path1,['T2_' fn1 gen_num_str(s0,3) fn2 fn3 gen_num_str(1,3) '.dcm']);
    fname2 = fullfile(path1,['T2_' fn1 gen_num_str(s0,3) fn2 fn3 gen_num_str(1,3) '.fig']);
    fname3 = fullfile(path1,['T2_' fn1 gen_num_str(s0,3) fn2 fn3 gen_num_str(1,3) '.tif']);
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

