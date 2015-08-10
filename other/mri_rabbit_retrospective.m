function mri_rabbit_retrospective
path0 = 'D:\Users\Philippe Pouliot\IRM_scans\LapinFR13a01';
nameID = 'FR13';
suffixID = '';
mri_load_rabbit_physiology(path0,nameID,suffixID);
path_fsems = fullfile(path0,'fsems_RabbitClinical08.dcm');
% for i0=1:15
%     for j0=1:4
%         fname = fullfile(path_fsems,['slice' gen_num_str(i0,3) 'image' gen_num_str(j0,3) 'echo001.dcm']);
%         Y{i0,j0} = dicomread(fname);
%         if j0 == 1
%              Z{i0} = zeros(size(Y{1,1}));
%         end
%         Z{i0} = Z{i0} + double(Y{i0,j0});
%     end
%     %if i0>4 && i0<12
%     figure; imagesc(Z{i0}); colormap(gray)
% end

