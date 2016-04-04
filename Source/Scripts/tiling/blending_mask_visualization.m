%% Tile blending mask

unit = [25, 25];

planeSize = [10, 10];
planeResolution = 15 * unit;
tileResolution = 7 * unit;
tileOverlap = 2 * unit;

%% Create matrix with sum of tiles
tiledPlane = TiledPixelPlane(planeResolution, planeSize);
tiledPlane.regularTiling(tileResolution, tileOverlap);

weightSumMatrix = zeros(planeResolution);

tileIndexY = repmat(1 : tiledPlane.tilingResolution(1), [tiledPlane.tilingResolution(2), 1]);
tileIndexX = repmat(1 : tiledPlane.tilingResolution(2), [1, tiledPlane.tilingResolution(1)]);
tileIndices = [tileIndexY(:), tileIndexX(:)];

tileBlendingMask = ones(tileResolution);
tileBlendingMask = min(cumsum(tileBlendingMask, 1), cumsum(tileBlendingMask, 2));
tileBlendingMask = min(tileBlendingMask, tileBlendingMask(end : -1 : 1, end : -1 : 1));
tileBlendingMask = tileBlendingMask.^2;

for index = 1 : size(tileIndices, 1)
        tileY = tileIndices(index, 1);
        tileX = tileIndices(index, 2);
        
        tile = tiledPlane.tiles{tileY, tileX};
        
        indicesY = tile.pixelIndexInParentY(:, 1);
        indicesX = tile.pixelIndexInParentX(1, :);
        
        validY = indicesY ~= 0;
        validX = indicesX ~= 0;
        
        indicesY = indicesY(validY);
        indicesX = indicesX(validX);
        
        F = tileBlendingMask(validY, validX);
% %         F = permute(repmat(F, [1, 1, attenuatorTile.channels, attenuatorTile.numberOfLayers]), [4, 1, 2, 3]);
%         
         weightSumMatrix(indicesY, indicesX) = weightSumMatrix(indicesY, indicesX) + F;
end

figure; imagesc(weightSumMatrix); axis equal image; colormap jet;

%% Store
W = (weightSumMatrix - min(weightSumMatrix(:))) / (max(weightSumMatrix(:)) - min(weightSumMatrix(:)));
imwrite(W, ['../../bachelor_thesis/Document/Figures/tiling/', 'blending_masks_sum_3x3.png']);