% Actual sizes in millimeters
actualLayerWidth = 90;
actualLayerHeight = 90;
actualThickness = 16;
attenuatorSize = [actualLayerHeight, actualLayerWidth];

editor = LightFieldEditor();
% editor.inputFromImageCollection('lightFields/tarot/small_angular_extent/rectified/', 'png', [17, 17], 0.5);
editor.inputFromImageCollection('lightFields/knights/rectified/', 'png', [17, 17], 0.5);
editor.angularSliceY(17 : -2 : 1);
editor.angularSliceX(17 : -2 : 1);

baseline = [190, 190];
% editor.distanceBetweenTwoCameras = baseline ./ (editor.angularResolution - 1);
editor.distanceBetweenTwoCameras = [30, 30] / 1.7;
% editor.cameraPlaneZ = 80 * 6;
editor.cameraPlaneZ = 200;
editor.sensorSize = attenuatorSize;
% editor.sensorPlaneZ = -1;
editor.sensorPlaneZ = 0;

lightField = editor.getPerspectiveLightField();


%% Run through a number of iterations

numberOfLayers = [2, 3, 4, 5, 10, 20];
mse = zeros(size(numberOfLayers));
psnr = zeros(size(numberOfLayers));
time = zeros(size(numberOfLayers));

for i = 1 : numel(numberOfLayers)
    
    close all;
    fprintf('Layers: %i\n', numberOfLayers(i));
    
    params.numberOfLayers = numberOfLayers(i);
    
    params.attenuatorSize = attenuatorSize;
    params.attenuatorThickness = actualThickness;
    params.layerResolution = round(1 * lightField.spatialResolution);
    params.tileResolution = 2 * [128, 128];
    params.tileOverlap = ceil(0.5 * params.tileResolution);
    params.tileResolutionMultiplier = 1;
    params.tileSizeMultiplier = 1; 
    params.verbose = 1;
    params.solver = @sart;
    params.iterations = 10;
    params.outputFolder = sprintf('results/numberOfLayers/knights/%i_layers/', params.numberOfLayers);
    
    mkdir(params.outputFolder);

    tic;
    [ attenuator ] = solveTiles(lightField, params);
    time(i) = toc;
    
    resamplingPlane2 = SensorPlane(ceil(1 * params.layerResolution), params.attenuatorSize, lightField.sensorPlane.z);
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
%     evaluation.storeReconstructedViews();
    evaluation.storeErrorImages();
    evaluation.storeLayers(1 : params.numberOfLayers);
    
    mse(i) = evaluation.mse;
    psnr(i) = evaluation.psnr;
    
%     evaluation.printLayers([1, 2; 3, 4], 18);
%     evaluation.printLayers(5, 18);

end


%% Plot RMSE and PSNR
close all;

figure(1);
plot(numberOfLayers, sqrt(mse));

figure(2);
plot(numberOfLayers, psnr);

figure(3);
plot(numberOfLayers, time);

save('results/numberOfLayers/knights/plots.mat', 'numberOfLayers', 'mse', 'psnr', 'time');