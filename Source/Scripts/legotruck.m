actualLayerHeight = 90;
actualThickness = 15.2;


editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/legotruck/', 'png', [17, 17], 0.3);
editor.angularSliceY(17 : -3 : 1);
editor.angularSliceX(1 : 3 : 17);

actualLayerWidth = editor.spatialResolution(2) / editor.spatialResolution(1) * actualLayerHeight;
attenuatorSize = [actualLayerHeight, actualLayerWidth];

editor.distanceBetweenTwoCameras = [100, 100];
editor.cameraPlaneZ = 2000;
editor.sensorSize = attenuatorSize;
editor.sensorPlaneZ = -1;
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
rec2.bilinearLayerInterpolation();
rec.computeAttenuationLayers();
rec.evaluation.displayLayers(1 : attenuator.numberOfLayers);

% For the reconstruction, use a propagation matrix that projects from the sensor plane instead of the sampling plane
resamplingPlane2 = SensorPlane(1 * layerResolution, attenuatorSize, lightField.sensorPlane.z);
rec2 = FastReconstructionForResampledLF(lightField, attenuator, resamplingPlane2);
rec2.nearestLayerInterpolation();
rec2.constructPropagationMatrix();

rec.usePropagationMatrixForReconstruction(rec2.propagationMatrix);
rec.reconstructLightField();

evaluation = rec.evaluation;
evaluation.evaluateViews([3, 1; 3, 2; 3, 3; 3, 4; 3, 5; 3, 6; 3, 7; 3, 8; 3, 9]);
% rec.evaluation.evaluateViews([9, 1; 9, 2; 9, 3; 9, 4; 9, 5; 9, 6; 9, 7; 9, 8; 9, 9]);
evaluation.displayReconstructedViews();
% rec.evaluation.displayErrorImages();
evaluation.storeErrorImages();
evaluation.storeReconstructedViews();
evaluation.storeLayers(1 : numberOfLayers);
