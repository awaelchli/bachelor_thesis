classdef PixelPlane < handle
    
    properties (SetAccess = private)
        planeCenter = [0, 0];
    end
    
    properties (Abstract, SetAccess = protected)
        planeResolution;
        planeSize;
    end
    
    properties (Dependent, SetAccess = private)
        pixelSize;
        pixelPositionMatrixY;
        pixelPositionMatrixX;
        height;
        width;
        aspectRatio;
    end
    
    methods
        
        function pixelSize = get.pixelSize(this)
            pixelSize = this.planeSize ./ this.planeResolution;
        end
        
        function [ positionsY, positionsX ] = pixelPositionMatrices(this)
            [ positionsY, positionsX ] = computeCenteredGridPositions(this.planeResolution, this.pixelSize);
            positionsY = positionsY + this.planeCenter(1);
            positionsX = positionsX + this.planeCenter(2);
        end
        
        function positionsY = get.pixelPositionMatrixY(this)
            [ positionsY, ~ ] = pixelPositionMatrices(this);
        end
        
        function positionsX = get.pixelPositionMatrixX(this)
            [ ~, positionsX ] = pixelPositionMatrices(this);
        end
        
        function translate(this, translationYX)
            this.planeCenter = this.planeCenter + translationYX;
        end
        
        function translateY(this, translationY)
            this.translate([translationY, 0]);
        end
        
        function translateX(this, translationX)
            this.translate([0, translationX]);
        end
        
        function height = get.height(this)
            height = this.planeSize(1);
        end
        
        function width = get.width(this)
            width = this.planeSize(2);
        end
        
        function aspect = get.aspectRatio(this)
            aspect = this.width / this.height;
        end
        
        function [Y, X, validIndices] = positionToPixelCoordinates(this, Y, X)
            
            Y = Y - this.planeCenter(1);
            X = X - this.planeCenter(2);
            
            maxPositionY = this.height / 2;
            maxPositionX = this.width / 2;
            scalePositionToIndex = (this.planeResolution - 1) ./ this.planeSize;
            
            % Convert to 'screen' coordinate system
            Y = maxPositionY - Y;
            X = X + maxPositionX;
            
            validIndices = Y >= 0 & X >= 0 & Y <= this.planeSize(1) & X <= this.planeSize(2);
            
            % Scale positions to the range [0, resolution - 1]
            Y = scalePositionToIndex(1) .* Y;
            X = scalePositionToIndex(2) .* X;
            
            % Add one to the coordinates so that they are in range of [1, resolution]
            Y = Y + 1;
            X = X + 1;
            
            % In case the plane is 1D, correct the indices and positions
            if(this.planeResolution(1) == 1)
                Y = ones(size(Y));
            end
            
            if(this.planeResolution(2) == 1)
                X = ones(size(X));
            end
        end
        
    end
    
    methods (Static)
        
        function valid = isValidIndex(index, resolution)
            valid = numel(index) == 2 && ...
                    all(index <= resolution) && ...
                    all(index >= [1, 1]) && ...
                    all(~mod(index, 1));
        end

    end
    
end