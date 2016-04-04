actualLayerHeight = 90;
actualThickness = 16;


editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/dice/perspective/baseline_1.0/10x10x1000x1000_lambertian/rectified/', 'png', [10, 10], 0.25);
editor.angularSliceY(1 : 10);
editor.angularSliceX(1 : 10);

actualLayerWidth = editor.spatialResolution(2) / editor.spatialResolution(1) * actualLayerHeight;
attenuatorSize = [actualLayerHeight, actualLayerWidth];

baseline = [1, 1] * 90;
editor.distanceBetweenTwoCameras = baseline ./ (editor.angularResolution - 1);
editor.cameraPlaneZ = 150;
editor.sensorSize = [80, 80];
editor.sensorPlaneZ = 0;
lightField = editor.getPerspectiveLightField();

numberOfLayers = 5;
attenuatorThickness = actualThickness;
layerResolution = round( 1 * lightField.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, attenuatorSize, attenuatorThickness, lightField.channels);

resamplingPlane = SensorPlane(round(1 * layerResolution), attenuatorSize, attenuator.layerPositionZ(1));
rec = FastReconstructionForResampledLF(lightField, attenuator, resamplingPlane);


%% Back projection P^T * LF

close all;
% rec.evaluation.clearOutputFolder();
rec.constructPropagationMatrix();

b = rec.backprojectLightField();

for i = 1 : attenuator.numberOfLayers
    figure('Name', sprintf('Layer %i', i));
    imshow(squeeze(b(i, :, :, :)), []);
    imwrite(squeeze(b(i, :, :, :)), sprintf('output/Back_Projection_Layer_%i.png', i));
end


%% Compute the layers
rec.nearestLayerInterpolation();
rec.computeAttenuationLayers();
rec.evaluation.displayLayers(1 : attenuator.numberOfLayers);

% For the reconstruction, use a propagation matrix that projects from the sensor plane instead of the sampling plane
resamplingPlane2 = SensorPlane(lightField.sensorPlane.planeResolution, lightField.sensorPlane.planeSize, lightField.sensorPlane.z);
rec2 = FastReconstructionForResampledLF(lightField, attenuator, resamplingPlane2);
rec2.nearestInterpolation();
rec2.constructPropagationMatrix();

rec.usePropagationMatrixForReconstruction(rec2.propagationMatrix);
[R, mse] = rec.reconstructLightField();
mse

evaluation = rec.evaluation;

%% Output
evaluation.outputFolder = 'output/interp_near/';

indY = 1 : lightField.angularResolution(1);
indX = 1 : lightField.angularResolution(2);

indY = repmat(indY, numel(indX), 1);
indX = repmat(indX, 1, size(indY, 2));

indices = [indY(:), indX(:)];
evaluation.evaluateViews(indices);

save([evaluation.outputFolder 'evaluation.mat'], 'evaluation','-v7.3');

evaluation.storeReconstructedViews();
% evaluation.storeErrorImages();
evaluation.storeLayers(1 : numberOfLayers);


