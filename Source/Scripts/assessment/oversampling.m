% Actual sizes in millimeters
actualLayerWidth = 90;
actualLayerHeight = 90;
actualThickness = 16;
attenuatorSize = [actualLayerHeight, actualLayerWidth];

editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/dice/perspective/baseline_1.0/10x10x1000x1000_lambertian/rectified/', 'png', [10, 10], 0.5);
editor.angularSliceY(1 : 10);
editor.angularSliceX(1 : 10);

baseline = [1, 1] * 90;
editor.distanceBetweenTwoCameras = baseline ./ (editor.angularResolution - 1);
editor.cameraPlaneZ = 150;
editor.sensorSize = [80, 80];
editor.sensorPlaneZ = 0;
lightField = editor.getPerspectiveLightField();


%% Run through different sampling densities

samplingDensity = [1.5, 2];
mse = zeros(size(samplingDensity));
psnr = zeros(size(samplingDensity));
time = zeros(size(samplingDensity));

for i = 1 : numel(samplingDensity)
    
    close all;
    fprintf('Sampling Density: %i\n', samplingDensity(i));
    
    params.iterations = 10;
    params.attenuatorSize = attenuatorSize;
    params.attenuatorThickness = actualThickness;
    params.numberOfLayers = 5;
    params.layerResolution = round(1 * lightField.spatialResolution);
    params.tileResolution = 1 * [250, 250];
    params.tileOverlap = ceil(0.5 * params.tileResolution);
    params.tileResolutionMultiplier = samplingDensity(i);
    params.tileSizeMultiplier = 1; 
    params.verbose = 1;
    params.solver = @sart;
    params.outputFolder = sprintf('results/oversampling/density_%i/', samplingDensity(i));
    
    mkdir(params.outputFolder);

    tic;
    [ attenuator ] = solveTiles(lightField, params);
    time(i) = toc;
    
    resamplingPlane2 = SensorPlane(lightField.spatialResolution, lightField.sensorPlane.planeSize, lightField.sensorPlane.z);
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
    save([params.outputFolder 'evaluation.mat'], 'evaluation', '-v7.3');
%     evaluation.printLayers([1, 2; 3, 4], 18);
%     evaluation.printLayers(5, 18);

end


%% Plot RMSE and PSNR
close all;

figure(1);
plot(samplingDensity, sqrt(mse));

figure(2);
plot(samplingDensity, psnr);

figure(3);
plot(samplingDensity, time);

save('results/oversampling/plots.mat', 'samplingDensity', 'mse', 'psnr', 'time');