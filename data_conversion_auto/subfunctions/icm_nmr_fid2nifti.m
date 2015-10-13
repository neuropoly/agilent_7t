diff_fid_folders=dir('*nmr_14*fid');
output='/home/django/tanguy/data/Montreal/Animal7T/20140716_fibers_mouse_nogse/nifti/fromfid/';
diff_fid_folders=diff_fid_folders(cellfun(@(x) x~=0,{diff_fid_folders(:).isdir}));
fid_folders={diff_fid_folders.name};


nb_folders=size(diff_fid_folders,1);

for i_folder=1:nb_folders
cd(fid_folders{i_folder})
data=aedes_readfid('fid','Return',2);
ks=abs(data.KSPACE);
ks4d(:,:,1,:)=ks;
save_avw_v2(mean(ks4d(:,16,1,:),1),[output strrep(fid_folders{i_folder},'.fid','')],'f',[1 1 1 3])
cd ..
clear ks4d
end
