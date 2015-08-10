function Step21a_Correct_fid_of_WT03_baseline_GESFIDE_scan
fpath = '/home/liom/Documents/GESFIDE_common/s_20150330_GESFIDE_WT0301/gesfide_mouse_01.fid';
addpath('/home/liom/cvsmod/tfisp/matlab/fid');
[k, hdr, block_hdr, par] = readfid(fpath); %, par, dc_correct, tfisp, ext);
kspace = reshape(k,[128,55296/128,128]);
%figure; imagesc(squeeze(abs(kspace(:,3,:))));

%add filter for KSpace artefacts
do_kspace_filter = 1;
if do_kspace_filter
    sz = size(kspace);
    ln = length(sz);
    %kspace0 = kspace;
    kspace2 = kspace;
    f1 = max(round(sz(1)/sz(2)),1);
    f2 = max(round(sz(2)/sz(1)),1);
    ck1 = 2; %size of center
    ck2 = ck1;
    th = 4;
    if ln<4, sz(4) = 1; end
    if ln<3, sz(3) = 1; end
    wt1 = 4*f1; %6;
    wt2 = 4*f2; %6;
    k1_list = [1:wt1:sz(1)-wt1 sz(1)+1-wt1];
    k2_list = [1:wt2:sz(2)-wt2 sz(2)+1-wt2];
    for k3=1:sz(3)
        for k4=1:sz(4)
            %k3 = 9; k4 = 5;
            tmp = squeeze(kspace(:,:,k3,k4));
            for k1=k1_list
                for k2=k2_list
                    %Don't correct center of k space
                    if ~(k1>sz(1)/2-ck1*wt1 && k1<sz(1)/2+ck1*wt1 && ...
                         k2>sz(2)/2-ck2*wt2 && k2<sz(2)/2+ck2*wt2 )  
                     sqr = tmp(k1:k1+wt1-1,k2:k2+wt2-1);
                     ab = abs(sqr);
                     md = median(ab(:));
                     sqr(abs(sqr)>th*md) = md;
                     kspace2(k1:k1+wt1-1,k2:k2+wt2-1,k3,k4) = sqr;
                    end
                end
            end
        end
    end
    kspace = kspace2;
end
kout = reshape(kspace,[55296,128]);
cleanup = false;
bh = block_hdr;
writefid(fpath, kout, par, hdr, bh, cleanup);
