function data = mri_fft(data)
%from k space data to image space
data=fftshift(fftshift(abs(fft(fft(data,[],1),[],2)),1),2);
data = flipdim(flipdim(data,1),2);