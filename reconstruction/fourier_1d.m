function ksP = fourier_1d(fftxksP)

for z=1:size(fftxksP,3)
    for t=1:size(fftxksP,4)
        for y=1:size(fftxksP,2)
            ksP(:,y,z,t) = (ifft(fftxksP(:,y,z,t)));
        end
    end
end

display_function(ksP,'corrected K-space')
end