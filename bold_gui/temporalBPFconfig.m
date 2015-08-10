function [z, p, k] = temporalBPFconfig(type, fs, cutoff, FilterOrder, varargin)
% Butterworth type Band-pass filter (1-D)
% SYNTAX
% [z, p, k] = temporalBPFconfig(type, fs, cutoff, FilterOrder, [Rp Rs])
% INPUTS
% type          String specifying the type of filter to use:
%               'butter'
%               'cheby1'
%               'cheby2'
%               'ellip'
% fs            Sampling frequency(in seconds)
% cutoff        A two-element vector fn (in Hz) that must be 0.0 < fn < fs/2
% FilterOrder   An integer (usually N=4)
% [Rp Rs]       OPTIONAL: 2-element vector with Rp dB of ripple in the passband,
%               and a stopband Rs dB down from the peak value in the passband.
% OUTPUTS
% z             zeros
% p             poles
% k             gain
%_______________________________________________________________________________
% Copyright (C) 2012 LIOM Laboratoire d'Imagerie Optique et Moléculaire
%                    École Polytechnique de Montréal
%_______________________________________________________________________________
try
    % only want 1 optional input at most
    numVarArgs = length(varargin);
    if numVarArgs > 1
        error('temporalBPFconfig:TooManyInputs', ...
            'requires at most 1 optional input: [Rp Rs]');
    end
    
    % set defaults for optional inputs ()
    optArgs = {[.5 80]};
    
    % now put these defaults into the optArgs cell array,
    % and overwrite the ones specified in varargin.
    optArgs(1:numVarArgs) = varargin;
    % or ...
    % [optargs{1:numvarargs}] = varargin{:};
    
    % Place optional args in memorable variable names
    [Rp_Rs] = optArgs{:};
    Rp = Rp_Rs(1); Rs = Rp_Rs(2); 

    Wn = cutoff*2 / fs;                 % Normalised cut-off frequency
    
    switch type
        case 'butter'                   % Butterworth filter
            [z, p, k] = butter(FilterOrder, Wn, 'bandpass');
        case 'cheby1'                   % Chebyshev I filter
            % RP dB of peak-to-peak ripple in the passband
            [z, p, k] = cheby1(FilterOrder, Rp, Wn, 'bandpass');
        case 'cheby2'                   % Chebyshev II filter
            % stopband ripple RS dB down from the peak passband value
            [z, p, k] = cheby2(FilterOrder, Rs, Wn, 'bandpass');
        case 'ellip'                    % Elliptic filter
            % Rp dB of ripple in the passband, and a stopband Rs dB down from
            % the peak value in the passband

            % Due to edge artifacts, one should use the [z,p,k] syntax to design
            % IIR filters.
            [z, p, k] = ellip(FilterOrder, Rp, Rs, Wn, 'bandpass');
        otherwise
            fprintf('Filter %s not available \n',type);
            return
    end
catch exception
    z = []; p = []; k = [];
    disp(exception.identifier)
    disp(exception.stack(1))
end

% EOF
