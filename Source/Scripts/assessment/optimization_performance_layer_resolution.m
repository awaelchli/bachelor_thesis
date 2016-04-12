% Actual sizes in millimeters
actualLayerWidth = 90;
actualLayerHeight = 90;
actualThickness = 16;
attenuatorSize = [actualLayerHeight, actualLayerWidth];

editor = LightFieldEditor();
editor.inputFromImageCollection('../Data/lightFields/tarot/small_angular_extent/rectified/', 'png', [17, 17], 0.1);
% editor.inputFromImageCollection('../Data/lightFields/knights/rectified/', 'png', [17, 17], 0.1);
editor.angularSliceY(17 : -2 : 1);
editor.angularSliceX(17 : -2 : 1);

baseline = [190, 190];
editor.distanceBetweenTwoCameras = baseline ./ (editor.angularResolution - 1);
editor.cameraPlaneZ = 200;
% editor.cameraPlaneZ = 80 * 6;
editor.sensorPlaneZ = -1;
% editor.sensorPlaneZ = 0;

editor.sensorSize = [85, 85];
lightField = editor.getPerspectiveLightField();


%% Run through a number of iterations

layerResolutionFactor = [1, 1.25, 1.5, 1.75, 2, 2.25, 2.5];
mse = zeros(size(layerResolutionFactor));
psnr = zeros(size(layerResolutionFactor));
time = zeros(size(layerResolutionFactor));

for i = 1 : numel(layerResolutionFactor)
    
    close all;
    fprintf('Resolution Factor: %i\n', layerResolutionFactor(i));
    
    params.numberOfLayers = 5;
    params.attenuatorSize = attenuatorSize;
    params.attenuatorThickness = actualThickness;
    params.layerResolution = round(layerResolutionFactor(i) * lightField.spatialResolution);
    params.tileResolution = layerResolutionFactor(i) * [100, 100];
    params.tileOverlap = ceil(0.5 * params.tileResolution);
    params.tileResolutionMultiplier = 1;
    params.tileSizeMultiplier = 1; 
    params.verbose = 1;
    params.solver = @sart;
    params.iterations = 10;
    params.outputFolder = sprintf('../results/layerResolution/tarots/%i_x/', layerResolutionFactor(i));
    
    mkdir(params.outputFolder);

    tic;
    [ attenuator ] = solveTiles(lightField, params);
    time(i) = toc;
    
    resamplingPlane2 = lightField.sensorPlane;
    rec = FastReconstructionForResampledLF(lightField, attenuator, resamplingPlane2);
    rec.constructPropagationMatrix();
    rec.usePropagationMatrixForReconstruction(rec.propagationMatrix);

    evaluation = rec.evaluation();
    evaluation.outputFolder = params.outputFolder;
    
    indY = 1 : lightField.angularResolution(1);
    indX = 1 : lightField.angularResolution(2);

    indY = repmat(indY, numel(indX), 1);
    indX = repmat(indX, 1, size(indY, 2));

    indices = [indY(:), indX(:)];
    evaluation.evaluateViews(indices);
    evaluation.storeReconstructedViews();
    evaluation.storeErrorImages();
    evaluation.storeLayers(1 : params.numberOfLayers);
    
    mse(i) = evaluation.mse;
    psnr(i) = evaluation.psnr;
    
    save([params.outputFolder 'evaluation.mat'], 'evaluation', '-v7.3');
    
%     evaluation.printLayers([1, 2; 3, 4], 18);
%     evaluation.printLayers(5, 18);

end


%% Plot RMSE and PSNR
close all;

figure(1);
plot(layerResolutionFactor, sqrt(mse));

figure(2);
plot(layerResolutionFactor, psnr);

figure(3);
plot(layerResolutionFactor, time);

save('../results/layerResolution/tarots/plots.mat', 'layerResolutionFactor', 'mse', 'psnr', 'time');