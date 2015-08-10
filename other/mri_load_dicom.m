function [A Av] = mri_load_dicom(files)
N = size(files,1);
for t0 = 1:N
    tmp = dicomread(files(t0,:));
    if t0 == 1
        Av = dicominfo(files(t0,:));
        [nx ny] = size(tmp);
        A = zeros(nx,ny,N);
    end
    A(:,:,t0) = tmp;
end