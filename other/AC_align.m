function [M,R] = AC_align(Template,Image,flip,Others,Nits)

% Usages:
% AC_align(Template,Image)
% AC_align(Template,Image,flip)
% AC_align(Template,Image,flip,Others)
% AC_align(Template,Image,flip,Others,Nits)
% 
% Template : template NIFTI (mandatory)
% Image: image to be reoriented (mandatory)
% flip: flips the image if the position is not supine but prono (optional, default 0)
% Others: other images to be reoriented (optional, default '')
% Nits: number of times the rotation matrix is estimated (optional, default 2)

if nargin == 2
    flip = 0;
    Others = '';
    Nits = 2;
end
if nargin == 3
    Others = '';
    Nits = 2;
end
if nargin == 4
    Nits = 2;
end
%--- flip images
files = strvcat(Image,Others); %#ok<VCAT>
if flip
    M = diag([-1 1 1 1]);
else
    M = eye(4);
end
for i = 1:size(files)
    rescale_nii(deblank(files(i,:)));
    spm_get_space(deblank(files(i,:)),M*spm_get_space(deblank(files(i,:))));
end
%--- estimate affine transformation
sep = 8./[1 2 4*ones(1,Nits)];
flags = struct('WG'      ,[]    ,...
               'WF'      ,[]    ,...
               'sep'     ,8     ,...
               'regtype' ,'mni' ,...
               'globnorm',0); 
V = spm_smoothto8bit(spm_vol(Image),8);
VTmp = spm_smoothto8bit(spm_vol(Template),0);
V.pinfo(1:2,:) = V.pinfo(1:2,:)/spm_global(V);
VTmp.pinfo(1:2,:) = VTmp.pinfo(1:2,:)/spm_global(VTmp);
[M,scal] = spm_affreg(VTmp,V,flags,eye(4));
for i = 2:Nits,
    flags.sep = sep(i);
    [M,scal] = spm_affreg(VTmp,V,flags,M,scal); %VTmp.mat\M*VRef.mat
end
%--- calculate rigis transformation via the polar decomposition
[A,B,C] = svd(M(1:3,1:3)); R = A*C';
R(:,4) = R*(M(1:3,1:3)\M(1:3,4)); R(4,4) = 1;
%--- reorient images
for i = 1:size(files,1),
    spm_get_space(deblank(files(i,:)),R*spm_get_space(deblank(files(i,:))));
end