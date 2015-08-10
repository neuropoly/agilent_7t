%superpose DICOM images
Ns = 22;
Nt = 10;

path0 = '/Users/liom/Documents/IRM_scans/';
fn0 = 'sems02.dcm';
fn1 = 'slice';
fn2 = 'image';
fn3 = 'echo001.dcm';

X{Ns,Nt} = [];
Z{Ns} = [];
M{Ns} = [];
S{Ns} = [];
for s0=1:Ns   
    for t0=1:Nt
        fname = fullfile(path0,fn0,[fn1 gen_num_str(s0,3) fn2 gen_num_str(t0,3) fn3]);
        X{s0,t0} = dicomread(fname);
        if t0 == 1            
            %Y{Ns} = [];
            Y{s0} = zeros(size(X{1,1}));
            Z{s0} = zeros([Nt size(X{1,1})]);
        end
        
        Y{s0} = Y{s0} + double(X{s0,t0});
        Z{s0}(t0,:,:) = double(X{s0,t0});
    end
    M{s0} = squeeze(median(Z{s0},1));
    S{s0} = squeeze(std(Z{s0},0,1));
    
end
        
figure; imagesc(M{22},[0 2000]); colormap(gray); 

figure; subplot(2,5,10); s0 = 20;
for t0=1:5
    for t1 = 1:2
        c0 = 2*(t0-1)+t1;
        subplot(2,5,c0);
        imagesc(X{s0,t0})
    end
end

figure;
s0 = 20;
%x=256; y = 512;
x= 370; y = 800;
v = zeros(Nt,1);
w = zeros(Nt,1);
for t0=1:Nt
    v(t0) = double(X{s0,t0}(y,x));
    w(t0) = X{s0,t0}(y,x);
end
plot(v);