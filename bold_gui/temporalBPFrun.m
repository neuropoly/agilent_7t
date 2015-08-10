function Yfilt = temporalBPFrun(Y, z, p, k)
% Zero-phase forward and reverse digital IIR filtering.
% Uses digital filter object to keep maximum numerical accuracy.
% SYNTAX
% Yfilt = temporalBPFrun(Y, z, p, k)
% INPUTS
% Y             The 1-D signal to be filtered
% z             zeros
% p             poles
% k             gain
% OUTPUTS
% Yfilt         The filtered 1-D signal
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________
try
    % Convert zero-pole-gain filter parameters to second-order sections form
    [sos, g] = zp2sos(z,p,k);
    % Zero-phase forward and reverse digital IIR filtering using digital filter
    % object to keep maximum numerical accuracy. //EGC
    Yfilt = mri_filtfilt(sos, g, Y);
catch exception
    Yfilt = Y;
    disp(exception.identifier)
    disp(exception.stack(1))
end

% EOF
