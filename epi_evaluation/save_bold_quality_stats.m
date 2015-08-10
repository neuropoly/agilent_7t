function [] = save_bold_quality_stats(stats,output,param,prefix)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%%
[~, name, ext] = fileparts(param.foldername);

h=display_function(stats.drift_voxel,'drift',stats.tsnr,'tsnr');
saveas(h,[output filesep prefix '_drift_tsnr'],'png');
saveas(h,[output filesep prefix '_drift_tsnr'],'fig');

h=figure('Name',[name ext '_temporal signal']);
plot(stats.temporal_signal);
if isfield(param,'TR'), xlabel(['scans (TR=)' num2str(param.TR)]);
else xlabel('scans'); end
ylabel('average');
title([name ext '_3D average'])
saveas(h,[output filesep prefix '_temp_signal'],'png');
saveas(h,[output filesep prefix '_temp_signal'],'fig');

h = figure('Name',[name ext '_tspr']);
for z=1:size(stats.tspr,2)
    subplot(1,size(stats.tspr,2),z)
    plot(squeeze(stats.tspr(1,z,:)),'b');
    title(['z=' num2str(z)])
end
saveas(h,[output filesep prefix '_tspr'],'png')
saveas(h,[output filesep prefix '_tspr'],'fig')

end

