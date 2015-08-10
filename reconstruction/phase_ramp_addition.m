function [data_mod] = phase_ramp_addition(data,x_shift,y_shift)
% fourier_shift 
% Adds a linear phase ramp in the x and/or y direction to a fourier
% transform. This means the result of the ifft will be shifted by x_shift 
% and y_shift.

x=(1:size(data,1))/size(data,1);
y=(1:size(data,2))/size(data,2);
phase_ramp_x = repmat(2*pi*x_shift*x',[1 size(data,2),size(data,3)]);
phase_ramp_y = repmat(2*pi*y_shift*y,[size(data,1),1,size(data,3)]);

kspace_abs = abs(data);
kspace_angle = angle(data)+phase_ramp_x+phase_ramp_y;
kspace_a = kspace_abs.*cos(kspace_angle);
kspace_b = kspace_abs.*sin(kspace_angle);
data_mod=complex(kspace_a,kspace_b);

end

