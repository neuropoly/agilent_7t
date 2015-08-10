function data = mri_fft_no_abs(data)
%from k space data to image space
data=fftshift(fftshift(fft(fft(data,[],1),[],2),1),2);
data = flipdim(flipdim(data,1),2);