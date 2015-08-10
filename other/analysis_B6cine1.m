%B6cine analysis
%tagcine 1 to 3: various, done before starting the physio waveform recording
%Started physio waveform recording sat 11:30 AM
%tagcine4: 192 x 192, TR = 100, SNR = 4
%Started at 11:40:
%tagcine5: 192 x 192, TR = 113
%6: Started at 11:48
%7: Started at 11:58
%8: Started at 12:05
%9: Started at 12:14
%10:Started at 12:21 -- nominal duration of each scan pair was 4 min 10 s
%tagcine 6,7,8,9,10: pairs of 128 x 128 cine scans with TE = 2.25 ms, 
%SNR of each scan around 8, 60 kHz bandwidth; TR = 122 ms
%8 slices iwth 8 frames, with a 20 degree angle in the axial - coronal
%plane starting from an axial view, to get a short axis view

%load the 128 x 128 scans
path0 = 'D:\Users\Philippe Pouliot\IRM_scans\B6cine104';
scans = 6:10;
nS = 8; %number of slices
nF = 8; %number of frames
nscan = 2; %number of scans per folder
nx = 128;
ny = 128;
A = zeros(nscan*length(scans),nS,nF,nx,ny);
ct = 0;
X{nscan*length(scans),nS,nF} = [];
V{nscan*length(scans),nS,nF} = [];
for s0=scans
    path1 = fullfile(path0,['tagcine' gen_num_str(s0,2) '.dcm']);
    for Inscan = 1:nscan
        ct = ct+1;
        for InS=1:nS
            for InF=1:nF
                 fname = ['slice' gen_num_str(InS,3) 'image' gen_num_str(Inscan,3) 'echo' gen_num_str(InF,3) '.dcm'];
                 Fname = fullfile(path1,fname);
                 X{ct,InS,InF} = dicomread(Fname);
                 V{ct,InS,InF} = dicominfo(Fname);
                 A(ct,InS,InF,:,:) = X{ct,InS,InF};
            end
        end
    end
end
%first show average of scans
M0 = mean(single(A),1);
figure; imagesc(squeeze(M0(1,6,1,:,:))); colormap(gray); axis off
%save it with a set of headers
path2 = fullfile(path0,['tagcineMean.dcm']);
if ~exist(path2,'dir'), mkdir(path2); end
for InS=1:nS
    for InF=1:nF
        fname = ['slice' gen_num_str(InS,3) 'image001echo' gen_num_str(InF,3) '.dcm'];
        Fname = fullfile(path2,fname);        
        dicomwrite(int16(floor(squeeze(M0(1,InS,InF,:,:)))),Fname,V{1,InS,InF});        
    end
end
%look for motion between 1st and last scan or mean scan
figure; imagesc(squeeze(M0(1,6,1,:,:)-A(1,6,1,:,:))); colormap(gray); axis off
figure; imagesc(squeeze(A(10,6,1,:,:)-A(1,6,1,:,:))); colormap(gray); axis off
%Look at physiology
P = load(fullfile(path0,'MouseCine1','B6heart1a.txt'),'-ascii');
K = load(fullfile(path0,'MouseCine1','B6heart1b.txt'),'-ascii');
figure; n = size(K,1); lp = linspace(1,n/900,n); plot(lp,...
K(:,2),'k'); hold on; stem(lp, 800*(K(:,1)),'r')
figure; n = size(P,1); lp = linspace(1,4*n/900,n); plot(lp,...
P(:,2),'k'); hold on; stem(lp, 800*(1-P(:,1)),'r')

%reduced figures:
figure; ns = 1e6; n = 10000; lp = linspace(1,n/900,n); plot(lp,K((ns+1):(ns+n),2),'k'); % hold on; stem(lp, 500*(1-K((ns+1):(ns+n),1)),'r')
figure; ns = 1e5; n = 10000; lp = linspace(1,4*n/900,n); plot(lp,P((ns+1):(ns+n),2),'k'); hold on; stem(lp, 800*(1-P((ns+1):(ns+n),1)),'r')
a=1;