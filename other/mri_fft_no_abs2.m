function data = mri_fft_no_abs2(data)
%from k space data to image space
data=fft(fft(data,[],1),[],2);
data = flipdim(flipdim(data,1),2);