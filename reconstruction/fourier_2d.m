function rspace = fourier_2d(kspace)

for t=1:size(kspace,4)
    for z=1:size(kspace,3)
        rspace(:,:,z,t) = fftshift(ifft2(kspace(:,:,z,t)));
    end
end

display_function(abs(rspace),'raw R-space')

end