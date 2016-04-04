% Actual sizes in millimeters
actualLayerWidth = 90;
actualLayerHeight = 90;
actualThickness = 16;
attenuatorSize = [actualLayerHeight, actualLayerWidth];

editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/tarot/small_angular_extent/rectified/', 'png', [17, 17], 0.5);
editor.angularSliceY(17 : -2 : 1);
editor.angularSliceX(17 : -2 : 1);

baseline = [190, 190];
editor.distanceBetweenTwoCameras = baseline ./ (editor.angularResolution - 1);
editor.cameraPlaneZ = 80 * 6;
editor.sensorSize = attenuatorSize;
editor.sensorPlaneZ = -1;

lightField = editor.getPerspectiveLightField();


%% Run through a number of iterations

iterations = [2, 3, 4, 5, 10, 20];
mse = zeros(size(iterations));
psnr = zeros(size(iterations));
time = zeros(size(iterations));

for i = 1 : numel(iterations)
    
    close all;
    fprintf('Iterations: %i\n', iterations(i));
    
    params.iterations = iterations(i);
    
    params.attenuatorSize = attenuatorSize;
    params.attenuatorThickness = actualThickness;
    params.numberOfLayers = 5;
    params.layerResolution = round(1 * lightField.spatialResolution);
    params.tileResolution = 2 * [128, 128];
    params.tileOverlap = ceil(0.5 * params.tileResolution);
    params.tileResolutionMultiplier = 1;
    params.tileSizeMultiplier = 1; 
    params.verbose = 1;
    params.solver = @sart;
    params.outputFolder = sprintf('results/sart/%i_iterations/', params.iterations);
    
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
plot(iterations, sqrt(mse));

figure(2);
plot(iterations, psnr);

figure(3);
plot(iterations, time);

save('results/sart/plots.mat', 'iterations', 'mse', 'psnr', 'time');