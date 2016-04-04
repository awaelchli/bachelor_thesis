classdef Tile < PixelPlane

    % Properties from superclass
    properties (Dependent, SetAccess = protected)
        planeResolution;
        planeSize;
    end
    
    properties (Dependent, SetAccess = private)
        validPixelIndexInParentY;
        validPixelIndexInParentX;
    end
    
    properties (SetAccess = private)
        parentPlane;
        pixelIndexInParentY;
        pixelIndexInParentX;
    end
    
    methods
        
        function this = Tile(parentPlane, location, tileResolution)
            % location: The pixel index in the parent plane of the top left corner pixel of this tile
            assert(PixelPlane.isValidIndex(location, parentPlane.planeResolution), ...
                   'Tile:InvalidTileLocation', ...
                   'The tile must be placed at a pixel lying within the parent plane.');
            this.parentPlane = parentPlane;
            this.initPixelIndexMatrices(location, tileResolution)
            this.initTileCenter(location);
        end
        
        function resolution = get.planeResolution(this)
            resolution = size(this.pixelIndexInParentY);
        end
        
        function planeSize = get.planeSize(this)
            planeSize = this.parentPlane.pixelSize .* this.planeResolution;
        end
        
        function valid = get.validPixelIndexInParentY(this)
            validY = sum(this.pixelIndexInParentY, 2) ~= 0; 
            validX = sum(this.pixelIndexInParentY, 1) ~= 0; 
            valid = this.pixelIndexInParentY(validY, validX);
        end
        
        function valid = get.validPixelIndexInParentX(this)
            validY = sum(this.pixelIndexInParentX, 2) ~= 0; 
            validX = sum(this.pixelIndexInParentX, 1) ~= 0; 
            valid = this.pixelIndexInParentX(validY, validX);
        end
        
    end
    
    methods (Access = private)
        
        function initPixelIndexMatrices(this, location, planeResolution)
            indicesY = location(1) : location(1) + planeResolution(1) - 1;
            indicesX = location(2) : location(2) + planeResolution(2) - 1;
            
            indicesY(indicesY <= 0) = 0;
            indicesY(indicesY > this.parentPlane.planeResolution(1)) = 0;
            indicesX(indicesX <= 0) = 0;
            indicesX(indicesX > this.parentPlane.planeResolution(2)) = 0;
            
            this.pixelIndexInParentY = repmat(indicesY', 1, numel(indicesX));
            this.pixelIndexInParentX = repmat(indicesX, numel(indicesY), 1);
        end
        
        function initTileCenter(this, location)
            [ positionsY, positionsX ] = this.parentPlane.pixelPositionMatrices();
            firstPixelPosition = [positionsY(location(1), location(2)), positionsX(location(1), location(2))];
            topLeftCornerPosition = firstPixelPosition + [this.pixelSize(1) / 2, -this.pixelSize(2) / 2];
            tileSize = this.parentPlane.pixelSize .* this.planeResolution;
            tileCenter = [topLeftCornerPosition(1) - tileSize(1) / 2, topLeftCornerPosition(2) + tileSize(2) / 2];
            this.translate(tileCenter);
        end
        
    end
    
end