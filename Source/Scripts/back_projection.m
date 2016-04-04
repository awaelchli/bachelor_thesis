editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/tarot/small_angular_extent/', 'png', [17, 17], 0.2);
editor.angularSliceY(1 : 3 : 17);
editor.angularSliceX(1 : 3 : 17);
editor.distanceBetweenTwoCameras = [0.03, 0.03];
editor.cameraPlaneZ = 10;
editor.sensorSize = [1, 1];
editor.sensorPlaneZ = 0;

lightField = editor.getPerspectiveLightField();

numberOfLayers = 5;
attenuatorThickness = 4;
layerResolution = round( 1 * lightField.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, [1, 1], attenuatorThickness, lightField.channels);

% Compute the attenuation layers by sampling the rays at the first layer (bottom) 
resamplingPlane = SensorPlane(1 * layerResolution, [1, 1], - attenuatorThickness / 2);
rec = ReconstructionForResampledLF(lightField, attenuator, resamplingPlane);
rec.computeAttenuationLayers();

% Compute the propagation matrix for reconstruction: Here, the resampling plane is at the center of the attenuator
resamplingPlane2 = SensorPlane(1 * layerResolution, [1, 1], 0);
rec2 = ReconstructionForResampledLF(lightField, attenuator, resamplingPlane2);
rec2.constructPropagationMatrix();

% Reconstruct the light field from the layers with the new propagation matrix
rec.usePropagationMatrixForReconstruction(rec2.propagationMatrix);
rec.reconstructLightField();

close all;
rec.evaluation.clearOutputFolder();
rec.evaluation.displayLayers(1 : numberOfLayers);
rec.evaluation.storeLayers(1 : numberOfLayers);
reconstructionIndices = [1, 1; 2, 2; 3, 3; 4, 4; 5, 5; 6, 6];
rec.evaluation.evaluateViews(reconstructionIndices);
% rec.evaluation.displayReconstructedViews();
rec.evaluation.storeReconstructedViews();
% rec.evaluation.displayErrorImages();
% rec.evaluation.storeErrorImages();


%% Back projection P^T * LF

b = rec.backprojectLightField();

for i = 1 : attenuator.numberOfLayers
    figure('Name', sprintf('Layer %i', i)); imshow(squeeze(b(i, :, :, :)));
    imwrite(squeeze(b(i, :, :, :)), sprintf('output/Back_Projection_Layer_%i.png', i));
end