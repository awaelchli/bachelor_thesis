% Actual sizes in millimeters
actualLayerWidth = 90;
actualLayerHeight = 90;
actualThickness = 16;
attenuatorSize = [actualLayerHeight, actualLayerWidth];

editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/knights/rectified/', 'png', [17, 17], 0.5);
editor.angularSliceY(17 : -2 : 1);
editor.angularSliceX(17 : -2 : 1);

baseline = [140, 140];
editor.distanceBetweenTwoCameras = baseline ./ (editor.angularResolution - 1);
editor.cameraPlaneZ = 200;
editor.sensorSize = attenuatorSize;
editor.sensorPlaneZ = 0;

lightField = editor.getPerspectiveLightField();


%% Solve

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
params.iterations = 50;
params.outputFolder = 'output/knights/';

start = tic;
[ attenuator ] = solveTiles(lightField, params);
fprintf('Total time for optimization is %.3f minutes', toc(start) / 60);

%% Show the layers
% close all;
for n = 1 : params.numberOfLayers
    figure; 
    imshow(squeeze(attenuator.attenuationValues(n, :, :, :)));
end

%% Reconstruct light field from layers
% close all;
% For the reconstruction, use a propagation matrix that projects from the sensor plane instead of the sampling plane
resamplingPlane2 = SensorPlane(ceil(1 * params.layerResolution), params.attenuatorSize, lightField.sensorPlane.z);
rec = FastReconstructionForResampledLF(lightField, attenuator, resamplingPlane2);
rec.constructPropagationMatrix();
rec.usePropagationMatrixForReconstruction(rec.propagationMatrix);

evaluation = rec.evaluation();
evaluation.outputFolder = params.outputFolder;
% evaluation.evaluateViews([3, 1; 3, 2; 3, 3; 3, 4; 3, 5; 3, 6]);
% evaluation.displayReconstructedViews();
% evaluation.displayErrorImages();

%% Store evaluation data to output folder

indY = 1 : lightField.angularResolution(1);
indX = 1 : lightField.angularResolution(2);

indY = repmat(indY, numel(indX), 1);
indX = repmat(indX, 1, size(indY, 2));

indices = [indY(:), indX(:)];
evaluation.evaluateViews(indices);
evaluation.storeReconstructedViews();
evaluation.storeErrorImages();
evaluation.storeLayers(1 : params.numberOfLayers);

save([evaluation.outputFolder 'evaluation.mat'], 'evaluation', '-v7.3');

%% Print

evaluation.printLayers([1, 2; 3, 4], 18);
evaluation.printLayers(5, 18);
