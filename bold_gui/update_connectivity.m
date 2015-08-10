function handles = update_connectivity(handles)
current_seed = handles.AllData.current_seed;
current_fc_slice = handles.AllData.current_fc_slice;
pValue = handles.AllData.fc_pValue;
h = spm_figure('GetWin', 'Graphics');
seeds = handles.AllData.seeds;
roi_radius = handles.AllData.roi_radius;
roi = handles.AllData.roi;
corrMap = roi{current_seed}.corrMap;
pValueMap = roi{current_seed}.pValueMap;
% Seed annotation dimensions the lower left corner of
% the bounding rectangle at the point seedX, seedY
seedX = round(seeds{current_seed}.pos(1)) - roi_radius;
seedY = round(seeds{current_seed}.pos(2)) - roi_radius;
% Seed width
seedW = 2*roi_radius;
% Seed height
seedH = 2*roi_radius;
seedPos = [seedX seedY seedW seedH];
%To display:
corrMap_same_slice = squeeze(corrMap(:,:,current_fc_slice));
pValueMap_same_slice = squeeze(pValueMap(:,:,current_fc_slice));

% Correlation map
subplot(211)
imagesc(corrMap_same_slice,[-1 1]); colorbar; axis image;
if current_fc_slice == seeds{current_seed}.slice
    % Display ROI
    rectangle('Position',seedPos,'Curvature',[1,1],'LineWidth',2,'LineStyle','-');
    set(gca,'Xtick',[]); set(gca,'Ytick',[]);
    xlabel('Left', 'FontSize', 14); ylabel('Rostral', 'FontSize', 14);
end
title(sprintf('fc map, seed %d, slice %d',current_seed, current_fc_slice), 'FontSize', 14)

% Show only significant pixels
subplot(212)
imagesc(corrMap_same_slice .* (pValueMap_same_slice <= pValue), [-1 1]); colorbar; axis image;
% Display ROI
if current_fc_slice == seeds{current_seed}.slice
    rectangle('Position',seedPos,'Curvature',[1,1],'LineWidth',2,'LineStyle','-');
    set(gca,'Xtick',[]); set(gca,'Ytick',[]);
    xlabel('Left', 'FontSize', 14); ylabel('Rostral', 'FontSize', 14);
end
title(sprintf('significant voxels (p<%.2f), seed %d,  slice %d\n',pValue,current_seed,current_fc_slice),'interpreter', 'none', 'FontSize', 14)