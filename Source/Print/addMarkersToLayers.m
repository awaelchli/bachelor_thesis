function layersWithMarkers = addMarkersToLayers(layers, markerSize)

    padding = max(0, 2 * markerSize - 1);
    layersWithMarkers = zeros(size(layers) + [0, 0, 2 * padding, 0]);
    
    for i = 1 : size(layers, 1)
        layersWithMarkers(i, :, :, :) = padarray(layers(i, :, :, :), [0, 0, padding], 1);
    end
    
    resolution = [size(layersWithMarkers, 2), size(layersWithMarkers, 3)];

    markerPositions = [markerSize, markerSize;
                       resolution(1) - markerSize + 1, markerSize;
                       markerSize, resolution(2) - markerSize + 1;
                       resolution - markerSize + 1];
    
    for i = 1 : size(markerPositions, 1)
        
        center = markerPositions(i, :);
        
        verticalY = center(1) - markerSize + 1 : 1 : center(1) + markerSize - 1;
        verticalX = repmat(center(2), size(verticalY));
        horizontalX = center(2) - markerSize + 1 : 1 : center(2) + markerSize - 1;
        horizontalY = repmat(center(1), size(horizontalX));
        
        % white box for marker
        boxY = repmat(verticalY', 1, numel(horizontalX));
        boxX = repmat(horizontalX, numel(verticalY), 1);
        layersWithMarkers(:, boxY(:), boxX(:), :) = 1;
        
        % black cross marker
        layersWithMarkers(:, verticalY, verticalX, :) = 0;
        layersWithMarkers(:, horizontalY, horizontalX, :) = 0;
    end
    
end