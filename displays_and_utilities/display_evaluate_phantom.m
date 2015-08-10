function display_evaluate_phantom(tspr,signal,phantom,input,output)

if isstruct(input)
    recon_name = fieldnames(input);
else
    recon_name{1} = 'tspr';
end
for i=1:length(recon_name)
    h = figure('Name',recon_name{i});
    for z=1:size(tspr,2)
        subplot(1,size(tspr,2),z)
        plot(squeeze(signal(i,z,:)),'g'); hold on;
%         plot(squeeze(tspr(i,z,:)),'b');
        plot(squeeze(phantom(i,z,:)),'r'); hold off;
    end
    % legend('tspr','signal','phantom')
    legend('signal','phantom')
    saveas(h,[output filesep 'tspr'],'png')
end

end