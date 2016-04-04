% Actual sizes in millimeters
actualLayerWidth = 90;
actualLayerHeight = 90;
actualThickness = 16;

attenuatorSize = [actualLayerHeight, actualLayerWidth];
samplingPlaneSize = attenuatorSize;

editor = LightFieldEditor();
editor.inputFromImageCollection('lightFields/tarot/small_angular_extent/rectified/', 'png', [17, 17], 0.5);
editor.angularSliceY(17 : -1 : 1);
editor.angularSliceX(17 : -1 : 1);

baseline = [190, 190];
% baseline = [300, 300];
% editor.distanceBetweenTwoCameras = [5.76, 5.76] * 6;
editor.distanceBetweenTwoCameras = baseline ./ (editor.angularResolution - 1);
% editor.distanceBetweenTwoCameras = [1.8, 1.8] * 6;
editor.cameraPlaneZ = 80 * 6;
editor.sensorSize = attenuatorSize;
editor.sensorPlaneZ = -1;

lightField = editor.getPerspectiveLightField();

numberOfLayers = 5;
attenuatorThickness = actualThickness;
layerResolution = round( 1 * lightField.spatialResolution );

attenuator = Attenuator(numberOfLayers, layerResolution, attenuatorSize, attenuatorThickness, lightField.channels);

%% Compute tile positions

tileResolution = 2 * [128, 128];
tileOverlap = ceil(0.5 * tileResolution);
tiledPlane = TiledPixelPlane(attenuator.planeResolution, attenuator.planeSize);
tiledPlane.regularTiling(tileResolution, tileOverlap);

%% Solve for each tile

tileSumMatrix = zeros(size(attenuator.attenuationValues));
weightSumMatrix = zeros(size(attenuator.attenuationValues));

tileIndexY = repmat(1 : tiledPlane.tilingResolution(1), [tiledPlane.tilingResolution(2), 1]);
tileIndexX = repmat(1 : tiledPlane.tilingResolution(2), [1, tiledPlane.tilingResolution(1)]);
tileIndices = [tileIndexY(:), tileIndexX(:)];

tileBlendingMask = ones(tileResolution);
tileBlendingMask = min(cumsum(tileBlendingMask, 1), cumsum(tileBlendingMask, 2));
tileBlendingMask = min(tileBlendingMask, tileBlendingMask(end : -1 : 1, end : -1 : 1));
tileBlendingMask = tileBlendingMask.^2;

for index = 1 : size(tileIndices, 1)
        tic
        tileY = tileIndices(index, 1);
        tileX = tileIndices(index, 2);
        
        fprintf('\nWorking on tile %i/%i...\n', index, size(tileIndices, 1));
        
        tile = tiledPlane.tiles{tileY, tileX};
        attenuatorTile = Attenuator(numberOfLayers, tile.planeResolution, tile.planeSize, attenuatorThickness, lightField.channels);
        attenuatorTile.translate(tile.planeCenter);
        
        tileSamplingPlane = SensorPlane(ceil(1 * tile.planeResolution), 1 * tile.planeSize, attenuatorTile.layerPositionZ(1));
        tileSamplingPlane.translate(tile.planeCenter);
        rec = FastReconstructionForResampledLF(lightField, attenuatorTile, tileSamplingPlane);
        
        rec.verbose = 1;
        rec.iterations = 6;
        rec.computeAttenuationLayers();
        
        tileValues = attenuatorTile.attenuationValues;
        indicesY = tile.pixelIndexInParentY(:, 1);
        indicesX = tile.pixelIndexInParentX(1, :);
        
        validY = indicesY ~= 0;
        validX = indicesX ~= 0;
        
        indicesY = indicesY(validY);
        indicesX = indicesX(validX);
        
        F = tileBlendingMask(validY, validX);
        F = permute(repmat(F, [1, 1, attenuatorTile.channels, attenuatorTile.numberOfLayers]), [4, 1, 2, 3]);
        
        tileValues = F .* tileValues(:, validY, validX, :);
        tileSumMatrix(:, indicesY, indicesX, :) = tileSumMatrix(:, indicesY, indicesX, :) + tileValues;
        weightSumMatrix(:, indicesY, indicesX, :) = weightSumMatrix(:, indicesY, indicesX, :) + F;
        
        % Store the current attenuator tile
        out = sprintf('output/tile_%i_%i/', tileY, tileX);
        mkdir(out);
        eval = rec.evaluation();
        eval.outputFolder = out;
        eval.storeLayers(1 : attenuator.numberOfLayers);
        toc
end

attenuationValues = tileSumMatrix ./ weightSumMatrix;
attenuator.attenuationValues = attenuationValues;

%% Show information about the tile coverage and blending weight distribution

figure('Name', 'Distribution of the blending weights'); imshow(squeeze(weightSumMatrix(1, :, :, 1)), []);
figure('Name', 'Coverage matrix'); imshow(tiledPlane.coverageMatrix, []);

%% Show the layers
% close all;
for n = 1 : numberOfLayers
    figure; 
    imshow(squeeze(attenuator.attenuationValues(n, :, :, :)));
end

%% Reconstruct light field from layers
% close all;
% For the reconstruction, use a propagation matrix that projects from the sensor plane instead of the sampling plane
resamplingPlane2 = SensorPlane(ceil(1 * layerResolution), samplingPlaneSize, lightField.sensorPlane.z);
rec = FastReconstructionForResampledLF(lightField, attenuator, resamplingPlane2);
rec.constructPropagationMatrix();
rec.usePropagationMatrixForReconstruction(rec.propagationMatrix);

evaluation = rec.evaluation();
evaluation.outputFolder = 'results/baseline_adjustment/baseline_scaled_shifted/';
% evaluation.evaluateViews([3, 1; 3, 2; 3, 3; 3, 4; 3, 5; 3, 6]);
% evaluation.displayReconstructedViews();
% evaluation.displayErrorImages();

%% Store evaluation data to output folder

W = (weightSumMatrix - min(weightSumMatrix(:))) / (max(weightSumMatrix(:)) - min(weightSumMatrix(:)));
imwrite(squeeze(W(1, :, :, :)), [evaluation.outputFolder, 'blendingMaskSum.png']);

indY = 1 : lightField.angularResolution(1);
indX = 1 : lightField.angularResolution(2);

indY = repmat(indY, numel(indX), 1);
indX = repmat(indX, 1, size(indY, 2));

indices = [indY(:), indX(:)];
evaluation.evaluateViews(indices);
evaluation.storeReconstructedViews();
evaluation.storeErrorImages();
evaluation.storeLayers(1 : numberOfLayers);

%% Print

evaluation.printLayers([1, 2; 3, 4], 18);
evaluation.printLayers(5, 18);
