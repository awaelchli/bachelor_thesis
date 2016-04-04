inputFolder = 'lightFields/dice/perspective/1x500x1000x1000/';
fileType = 'png';
angularResolution = [1 500];
epiOutput = 'output/epi_1x500x1000x1000/';

% Prepare to write results in output folder
if ~exist(epiOutput, 'dir')
    mkdir(epiOutput);
end

% Load middle image
editor = LightFieldEditor();
editor.inputFromImageCollection(inputFolder, fileType, angularResolution, 1);
editor.angularSliceX([1, angularResolution(2)]);

LF = editor.getPerspectiveLightField();
left = squeeze(LF.lightFieldData(1, 1, :, :, :));
right = squeeze(LF.lightFieldData(1, 2, :, :, :));
spatialResolution = size(left);

overview = (left + 0.1 * right);
overview = (overview - min(overview(:))) / (max(overview(:)) - min(overview(:))); 

figure(1);
subplot(1, 2, 1);
imagesc(overview);
title('Left- and Rightmost Views');
axis equal tight;



while true
    
    [~, y, key] = ginput(1);
    
    if key == 27
        break;
    end
    
    y = max(floor(y), 1);
    
    % Draw line in overview image
    overview(y, :, :) = 0;
    
    % Load slice of selected scanline
    editor.inputFromImageCollection(inputFolder, fileType, angularResolution, 1);
    editor.spatialSliceY(y);
    LF = editor.getPerspectiveLightField();
    epi = squeeze(LF.lightFieldData);
    
    % Write epipolar image to file
    imwrite(epi, sprintf([epiOutput 'scanY=%i.%s'], y, fileType));
    
    figure(1);
    subplot(1, 2, 1);
    imagesc(overview);
    title('Left- and Rightmost Views');
    axis equal tight;
    
    subplot(1, 2, 2);
    imagesc(epi);
    title('Epipolar Image');
    axis equal tight;
end

imwrite(overview, [epiOutput 'overview.' fileType]);