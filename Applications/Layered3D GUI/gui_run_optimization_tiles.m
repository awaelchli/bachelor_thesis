function [ attenuator ] = gui_run_optimization_tiles( handles )


attenuator = [];

tileResolution = [str2double(get(handles.editTileResY, 'String')), str2double(get(handles.editTileResX, 'String'))];
overlap = get(handles.sliderOverlap, 'Value');
iterations = str2double(get(handles.editIterations, 'String'));

if any(isnan(tileResolution)) || any(tileResolution <= 0) || any(rem(tileResolution, 1) ~= 0)
    gui_warning(handles.textOptimizationInfo, 'Tile resolution must be a positive integer');
    return;
end
if isnan(iterations) || iterations <= 0 || rem(iterations, 1) ~= 0
    gui_warning(handles.textOptimizationInfo, 'Iterations must be a positive integer');
    return;
end

solver = @gui_sart;
switch get(handles.popupAlgorithm, 'Value')
    case 1
        solver = @gui_sart;
    case 2
        solver = @gui_lsqlin;
end

tileOverlap = ceil(overlap * tileResolution);
tiledPlane = TiledPixelPlane(handles.data.attenuator.planeResolution, handles.data.attenuator.planeSize);
tiledPlane.regularTiling(tileResolution, tileOverlap);

numberOfLayers = handles.data.attenuator.numberOfLayers;
attenuatorThickness = handles.data.attenuator.thickness;

tileSumMatrix = zeros(size(handles.data.attenuator.attenuationValues));
weightSumMatrix = zeros(size(handles.data.attenuator.attenuationValues));

tileIndexY = repmat(1 : tiledPlane.tilingResolution(1), [tiledPlane.tilingResolution(2), 1]);
tileIndexX = repmat(1 : tiledPlane.tilingResolution(2), [1, tiledPlane.tilingResolution(1)]);
tileIndices = [tileIndexY(:), tileIndexX(:)];

tileBlendingMask = ones(tileResolution);
tileBlendingMask = min(cumsum(tileBlendingMask, 1), cumsum(tileBlendingMask, 2));
tileBlendingMask = min(tileBlendingMask, tileBlendingMask(end : -1 : 1, end : -1 : 1));
tileBlendingMask = tileBlendingMask .^ 2;
% tileBlendingMask = (tileBlendingMask - min(tileBlendingMask(:))) / (max(tileBlendingMask(:)) - min(tileBlendingMask(:)));

ticStart = tic;
for index = 1 : size(tileIndices, 1)
        
        tileY = tileIndices(index, 1);
        tileX = tileIndices(index, 2);
        
        set(handles.textOptimizationInfo, 'String', sprintf('Working on tile %i/%i ...', index, size(tileIndices, 1)));
        drawnow;
        
        tile = tiledPlane.tiles{tileY, tileX};
        attenuatorTile = Attenuator(numberOfLayers, tile.planeResolution, tile.planeSize, attenuatorThickness, handles.data.attenuator.channels);
        attenuatorTile.translate(tile.planeCenter);
        
        % HARD-CODED sampling density
        tileSamplingPlane = SensorPlane(ceil(1 * tile.planeResolution), 1 * tile.planeSize, attenuatorTile.layerPositionZ(1));
        tileSamplingPlane.translate(tile.planeCenter);
        rec = FastReconstructionForResampledLF(handles.data.lightfield, attenuatorTile, tileSamplingPlane);
        
        rec.verbose = 1;
        rec.solver = solver;
        rec.iterations = iterations;
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
%         out = sprintf('output/tile_%i_%i/', tileY, tileX);
%         mkdir(out);
%         eval = rec.evaluation();
%         eval.outputFolder = out;
%         eval.storeLayers(1 : attenuator.numberOfLayers);
end
elapsed = toc(ticStart);
set(handles.textOptimizationInfo, 'String', sprintf('Done. Elapsed time is %.0f seconds.', elapsed));

attenuationValues = tileSumMatrix ./ weightSumMatrix;
handles.data.attenuator.attenuationValues = attenuationValues;
attenuator = handles.data.attenuator;

end

