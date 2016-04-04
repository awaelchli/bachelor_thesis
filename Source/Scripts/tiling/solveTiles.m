function [ attenuator ] = solveTiles( lightField, params )
%SOLVETILES Solves for a tiled attenuator
%
%   lightField                                  The lightfield (of class LightField)
%
%   params.numberOfLayers                       The number of layers that should be solved for
%   params.layerResolution                      Resolution of a attenuation layer
%   params.attenuatorSize                       Size of the attenuator (Y, X)
%   params.attenuatorThickness                  Thickness of the attenuator (from first to last layer, in Z-direction)
%   params.tileResolution                       The resolution of a single tile
%   params.tileOverlap                          Overlap of the tiles (0 to 1)
%   params.tileResolutionMultiplier             Multiplies the tile resolution by this factor for oversampling
%   params.tileSizeMultiplier                   Multiplies the size of each tile by this factor
%   params.verbose                              Verbose mode, true or false
%   params.solver                               Function handle to the solver that should be used
%   params.iterations                           The number of iterations the solver should perform
%   params.outputFolder                         Output folder for the results

    
    attenuator = Attenuator(params.numberOfLayers, params.layerResolution, params.attenuatorSize, params.attenuatorThickness, lightField.channels);

    %% Compute tile positions

    tiledPlane = TiledPixelPlane(attenuator.planeResolution, attenuator.planeSize);
    tiledPlane.regularTiling(params.tileResolution, params.tileOverlap);

    %% Solve for each tile

    tileSumMatrix = zeros(size(attenuator.attenuationValues));
    weightSumMatrix = zeros(size(attenuator.attenuationValues));

    tileIndexY = repmat(1 : tiledPlane.tilingResolution(1), [tiledPlane.tilingResolution(2), 1]);
    tileIndexX = repmat(1 : tiledPlane.tilingResolution(2), [1, tiledPlane.tilingResolution(1)]);
    tileIndices = [tileIndexY(:), tileIndexX(:)];

    tileBlendingMask = ones(params.tileResolution);
    tileBlendingMask = min(cumsum(tileBlendingMask, 1), cumsum(tileBlendingMask, 2));
    tileBlendingMask = min(tileBlendingMask, tileBlendingMask(end : -1 : 1, end : -1 : 1));
    tileBlendingMask = tileBlendingMask.^2;

    for index = 1 : size(tileIndices, 1)
            tic
            tileY = tileIndices(index, 1);
            tileX = tileIndices(index, 2);

            fprintf('\nWorking on tile %i/%i...\n', index, size(tileIndices, 1));

            tile = tiledPlane.tiles{tileY, tileX};
            attenuatorTile = Attenuator(params.numberOfLayers, tile.planeResolution, tile.planeSize, params.attenuatorThickness, lightField.channels);
            attenuatorTile.translate(tile.planeCenter);

            tileSamplingPlane = SensorPlane(ceil(params.tileResolutionMultiplier * tile.planeResolution), params.tileSizeMultiplier * tile.planeSize, attenuatorTile.layerPositionZ(1));
            tileSamplingPlane.translate(tile.planeCenter);
            rec = FastReconstructionForResampledLF(lightField, attenuatorTile, tileSamplingPlane);

            rec.verbose = params.verbose;
            rec.solver = params.solver;
            rec.iterations = params.iterations;
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
            out = sprintf('%stile_%i_%i/', params.outputFolder, tileY, tileX);
            mkdir(out);
            eval = rec.evaluation();
            eval.outputFolder = out;
            eval.storeLayers(1 : attenuator.numberOfLayers);
            toc
    end

    attenuationValues = tileSumMatrix ./ weightSumMatrix;
    attenuator.attenuationValues = attenuationValues;

    %% Show information about the tile coverage and blending weight distribution

%     figure('Name', 'Distribution of the blending weights'); imshow(squeeze(weightSumMatrix(1, :, :, 1)), []);
%     figure('Name', 'Coverage matrix'); imshow(tiledPlane.coverageMatrix, []);

    W = (weightSumMatrix - min(weightSumMatrix(:))) / (max(weightSumMatrix(:)) - min(weightSumMatrix(:)));
    imwrite(squeeze(W(1, :, :, :)), [params.outputFolder, 'blendingMaskSum.png']);
end

