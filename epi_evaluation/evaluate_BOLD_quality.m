function [stats] = evaluate_BOLD_quality(input,output,param)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

stats = mri_stability_stats(input);
stats.tspr = evaluate_phantom(input,output);
stats.tsnr = evaluate_tsnr(input);

end

