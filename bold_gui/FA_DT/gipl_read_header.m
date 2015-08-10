function [info] =gipl_read_header(fname)
% function for reading header of  Guys Image Processing Lab (Gipl) volume file
%
% header = gipl_read_header(filename);
%
% examples:
% 1,  info=gipl_read_header()
% 2,  info=gipl_read_header('volume.gipl');
dis=false;

if(exist('fname','var')==0)
    [filename, pathname] = uigetfile('*.gipl', 'Read gipl-file');
    fname = [pathname filename];
end

f=fopen(fname,'rb','ieee-be');
if(f<0)
    fprintf('could not open file %s\n',fname);
    return
end

trans_type{1}='binary'; trans_type{7}='char'; trans_type{8}='uchar'; 
trans_type{15}='short'; trans_type{16}='ushort'; trans_type{31}='uint'; 
trans_type{32}='int';  trans_type{64}='float';trans_type{65}='double'; 
trans_type{144}='C_short';trans_type{160}='C_int';  trans_type{192}='C_float'; 
trans_type{193}='C_double'; trans_type{200}='surface'; trans_type{201}='polygon';

trans_orien{0+1}='UNDEFINED'; trans_orien{1+1}='UNDEFINED_PROJECTION'; 
trans_orien{2+1}='AP_PROJECTION';  trans_orien{3+1}='LATERAL_PROJECTION'; 
trans_orien{4+1}='OBLIQUE_PROJECTION'; trans_orien{8+1}='UNDEFINED_TOMO'; 
trans_orien{9+1}='AXIAL'; trans_orien{10+1}='CORONAL'; 
trans_orien{11+1}='SAGITTAL'; trans_orien{12+1}='OBLIQUE_TOMO';

offset=256; % header size

%get the file size
fseek(f,0,'eof');
fsize = ftell(f); 
fseek(f,0,'bof');

sizes=fread(f,4,'ushort')';
if(sizes(4)==1), maxdim=3; else maxdim=4; end
sizes=sizes(1:maxdim);
image_type=fread(f,1,'ushort');
scales=fread(f,4,'float')';
scales=scales(1:maxdim);
patient=fread(f,80, 'uint8=>char')';
matrix=fread(f,20,'float')';
orientation=fread(f,1, 'uint8')';
par2=fread(f,1, 'uint8')';
voxmin=fread(f,1,'double');
voxmax=fread(f,1,'double');
origin=fread(f,4,'double')';
origin=origin(1:maxdim);
pixval_offset=fread(f,1,'float');
pixval_cal=fread(f,1,'float');
interslicegap=fread(f,1,'float');
user_def2=fread(f,1,'float');
magic_number= fread(f,1,'uint');
if (magic_number~=4026526128), error('file corrupt - or not big endian'); end
fclose('all');

if(dis)
    disp(['filename : ' num2str(fname)]);   
    disp(['filesize : ' num2str(fsize)]);
    disp(['sizes : ' num2str(sizes)]);
    disp(['scales : ' num2str(scales)]);
    disp(['image_type : ' num2str(image_type) ' - ' trans_type{image_type}]);
    disp(['patient : ' patient]);
    disp(['matrix : ' num2str(matrix)]);
    disp(['orientation : ' num2str(orientation) ' - ' trans_orien{orientation+1}]);
    disp(['voxel min : ' num2str(voxmin)]);
    disp(['voxel max : ' num2str(voxmax)]);
    disp(['origing : ' num2str(origin)]);
    disp(['pixval_offset : ' num2str(pixval_offset)]);
    disp(['pixval_cal : ' num2str(pixval_cal)]);
    disp(['interslicegap : ' num2str(interslicegap)]);
    disp(['user_def2 : ' num2str(user_def2)]);
    disp(['par2 : ' num2str(par2)]);
    disp(['offset : ' num2str(offset)]);
    fprintf('\n');
end

info=struct('filename',fname,'filesize',fsize,'sizes',sizes,'scales',scales,'image_type',image_type,'patient',patient,'matrix',matrix,'orientation',orientation,'voxel_min',voxmin,'voxel_max',voxmax,'origing',origin,'pixval_offset',pixval_offset,'pixval_cal',pixval_cal,'interslicegap',interslicegap,'user_def2',user_def2,'par2',par2,'offset',offset);
end

