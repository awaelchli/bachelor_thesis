classdef AbstractPropagationMatrix < handle
    
    properties (SetAccess = private)
        lightFieldSubscriptRange;
        attenuatorSubscriptRange;
    end
    
    properties (Dependent, SetAccess = private)
        size;
    end
    
    methods (Abstract)
        
        P = formSparseMatrix(this)
        
        P = formSparseSubMatrix(this, angularIndexY, angularIndexX)
        
        submitEntries(this, cameraIndexY, cameraIndexX, ...
                            pixelIndexOnSensorY, pixelIndexOnSensorX, ...
                            layerIndex, ...
                            pixelIndexOnLayerY, pixelIndexOnLayerX, ...
                            weightMatrix)
        
        clear(this)
    
    end
    
    methods
        
        function this = AbstractPropagationMatrix(lightField, attenuator)
            this.lightFieldSubscriptRange = lightField.resolution;
            this.attenuatorSubscriptRange = [attenuator.planeResolution, attenuator.numberOfLayers];
        end
        
        function size = get.size(this)
            size = [prod(this.lightFieldSubscriptRange), prod(this.attenuatorSubscriptRange)];
        end
        
    end
    
    methods (Access = protected)
        
        function rows = computeRowIndices(this, camIndexY, ...
                                                camIndexX, ...
                                                cameraPixelIndicesY, ...
                                                cameraPixelIndicesX)
            
            imageIndicesY = camIndexY + zeros(size(cameraPixelIndicesY));
            imageIndicesX = camIndexX + zeros(size(cameraPixelIndicesX));

            rows = sub2ind(this.lightFieldSubscriptRange, imageIndicesY(:), ...
                                                          imageIndicesX(:), ...
                                                          cameraPixelIndicesY(:), ...
                                                          cameraPixelIndicesX(:));
        end
        
        function columns = computeColumnIndices(this, layerPixelIndicesY, ...
                                                      layerPixelIndicesX, ...
                                                      layer)
            
            layerIndices = layer + zeros(size(layerPixelIndicesY));

            columns = sub2ind(this.attenuatorSubscriptRange, layerPixelIndicesY(:), ...
                                                             layerPixelIndicesX(:), ...
                                                             layerIndices(:));
        end
        
        function M = maskForSparseSubMatrix(this, angularIndexY, angularIndexX)
            
            numberOfAngularSubscripts = numel(angularIndexY);
            maskSize = [prod([numberOfAngularSubscripts, this.lightFieldSubscriptRange(LightField.spatialDimensions)]), this.size(1)];
            
            [ pixelIndicesY, pixelIndicesX ] = ndgrid(1 : this.lightFieldSubscriptRange(LightField.spatialDimensions(1)), ...
                                                      1 : this.lightFieldSubscriptRange(LightField.spatialDimensions(2)));
            
            pixelIndicesY = repmat(pixelIndicesY, 1, numberOfAngularSubscripts);
            pixelIndicesX = repmat(pixelIndicesX, 1, numberOfAngularSubscripts);
            angularIndicesY = repmat(angularIndexY(:)', prod(this.lightFieldSubscriptRange(LightField.spatialDimensions)), 1);
            angularIndicesX = repmat(angularIndexX(:)', prod(this.lightFieldSubscriptRange(LightField.spatialDimensions)), 1);
            
            I = 1 : maskSize(1);
            J = sub2ind(this.lightFieldSubscriptRange, angularIndicesY(:), angularIndicesX(:), pixelIndicesY(:), pixelIndicesX(:));
            S = ones(size(I));
            M = logical(sparse(I, J, S, maskSize(1), maskSize(2)));
        end
        
    end
    
end

