% Actual sizes in millimeters
actualLayerWidth = 90;
actualLayerHeight = 90;
actualThickness = 16;

attenuatorSize = [actualLayerHeight, actualLayerWidth];
samplingPlaneSize = attenuatorSize;

editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/tarot/small_angular_extent/rectified/', 'png', [17, 17], 0.4);
editor.angularSliceY(17 : -1 : 1);
editor.angularSliceX(17 : -1 : 1);

baseline = [190, 190];
% editor.distanceBetweenTwoCameras = [5.76, 5.76] * 6;
editor.distanceBetweenTwoCameras = baseline ./ (editor.angularResolution - 1);
editor.cameraPlaneZ = 80 * 6;
editor.sensorSize = attenuatorSize;
editor.sensorPlaneZ = -1;

lightField = editor.getPerspectiveLightField();

numberOfLayers = 5;
attenuatorThickness = actualThickness;
layerResolution = round(1 * lightField.spatialResolution );
attenuator = Attenuator(numberOfLayers, layerResolution, attenuatorSize, attenuatorThickness, lightField.channels);

resamplingPlane = SensorPlane(round(1 * 1 * layerResolution), 1 * samplingPlaneSize, attenuator.layerPositionZ(1));
rec = FastReconstructionForResampledLF(lightField, attenuator, resamplingPlane);
evaluation = rec.evaluation();

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

clear b;


%% Compute the layers

rec.computeAttenuationLayers();
evaluation.displayLayers(1 : attenuator.numberOfLayers);
evaluation.storeLayers(1 : attenuator.numberOfLayers);

evaluation.printLayers([1, 2], 15);
evaluation.printLayers([3, 4], 15);
evaluation.printLayers(5, 15);

%% Reconstruct light field from layers

% For the reconstruction, use a propagation matrix that projects from the sensor plane instead of the sampling plane
resamplingPlane2 = SensorPlane(round(2 * 0.95 * layerResolution), 0.95 * samplingPlaneSize, lightField.sensorPlane.z);
rec2 = FastReconstructionForResampledLF(lightField, attenuator, resamplingPlane2);
rec2.constructPropagationMatrix();

rec.usePropagationMatrixForReconstruction(rec2.propagationMatrix);

% evaluation.evaluateViews([3, 1; 3, 2; 3, 3; 3, 4; 3, 5; 3, 6]);
% rec.evaluation.evaluateViews([1, 3; 2, 3; 3, 3; 4, 3; 5, 3; 6, 3]);
% evaluation.displayReconstructedViews();
% rec.evaluation.displayErrorImages();
% evaluation.storeReconstructedViews();


%% Store all reconstructed views

indY = 1 : lightField.angularResolution(1);
indX = 1 : lightField.angularResolution(2);

indY = repmat(indY, numel(indX), 1);
indX = repmat(indX, 1, size(indY, 2));

indices = [indY(:), indX(:)];
evaluation.evaluateViews(indices);
evaluation.storeReconstructedViews();
evaluation.storeErrorImages();
