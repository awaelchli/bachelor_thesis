classdef TiledPixelPlane < SimplePixelPlane
    
    properties (Constant)
        initialTilingResolution = [1, 1];
    end
    
    properties (SetAccess = private)
        tiles;
    end
    
    properties (Dependent, SetAccess = private)
        tilingResolution;
        coverageMatrix;
    end
    
    methods
        
        function this = TiledPixelPlane(planeResolution, planeSize)
            this = this@SimplePixelPlane(planeResolution, planeSize);
            this.tiles = cell(TiledPixelPlane.initialTilingResolution);
            this.tiles{1, 1} = Tile(this, [1, 1], planeResolution);
        end
        
        function tilingResolution = get.tilingResolution(this)
            tilingResolution = size(this.tiles);
        end
        
        function coverageMatrix = get.coverageMatrix(this)
            coverageMatrix = zeros(this.planeResolution);
            for tileY = 1 : this.tilingResolution(1)
                for tileX = 1 : this.tilingResolution(2)
                    tile = this.tiles{tileY, tileX};
                    coverageMatrix(tile.validPixelIndexInParentY(:, 1), tile.validPixelIndexInParentX(1, :)) = ...
                        coverageMatrix(tile.validPixelIndexInParentY(:, 1), tile.validPixelIndexInParentX(1, :)) + 1;
                end
            end
        end
        
        function setTile(this, tileIndex, locationPixelIndex, tileResolution)
            assert(PixelPlane.isValidIndex(tileIndex, size(this.tiles)), ...
                   'setTile:InvalidTileIndex', ...
                   'Invalid tile index. The tiling resolution is %ix%i.', ...
                   this.tilingResolution(1), this.tilingResolution(2));
            this.tiles{tileIndex(1), tileIndex(2)} = Tile(this, locationPixelIndex, tileResolution);
        end
        
        % Override 
        function translate(this, translationYX)
            this.translate@SimplePixelPlane(translationYX);
            % Translate every tile
            cellfun(@(tile) tile.translate(translationYX), this.tiles);
        end
        
        function regularTiling(this, tileResolution, tileOverlap)
            assert(all(tileResolution > tileOverlap), ...
                   'regularTiling:InvalidTileOverlap', ...
                   'The overlap must be smaller than a tile.');
            
            anchorPixelsY = 1 : tileResolution(1) - tileOverlap(1) : this.planeResolution(1) - tileOverlap(1);
            anchorPixelsX = 1 : tileResolution(2) - tileOverlap(2) : this.planeResolution(2) - tileOverlap(2);
            this.tiles = cell([numel(anchorPixelsY), numel(anchorPixelsX)]);
            
            % Create the tiles
            for tileY = 1 : this.tilingResolution(1)
                for tileX = 1 : this.tilingResolution(2)
                    this.tiles{tileY, tileX} = Tile(this, [anchorPixelsY(tileY), anchorPixelsX(tileX)], tileResolution);
                end
            end
        end
        
    end
    
end