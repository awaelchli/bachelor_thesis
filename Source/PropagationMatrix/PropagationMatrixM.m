classdef PropagationMatrixM < AbstractPropagationMatrix
    
    properties (Access = private)
        I;
        J;
        S;
        currentIndex = 1;
        indexStart;
        indexEnd;
    end
    
    methods
        
        function this = PropagationMatrixM(lightField, attenuator, numberOfNonZeros)
            this = this@AbstractPropagationMatrix(lightField, attenuator);
            % Pre-allocate memory
            this.I = zeros(1, numberOfNonZeros);
            this.J = zeros(1, numberOfNonZeros);
            this.S = zeros(1, numberOfNonZeros);
            
            this.indexStart = zeros([lightField.angularResolution, attenuator.numberOfLayers]);
            this.indexEnd = zeros(size(this.indexStart));
        end
        
        function P = formSparseMatrix(this)
            P = sparse(this.I, this.J, this.S, this.size(1), this.size(2));
        end
        
        function P = formSparseSubMatrix(this, angularIndexY, angularIndexX)
            M = this.maskForSparseSubMatrix(angularIndexY, angularIndexX);
            
            layerIndex = repmat(1 : this.attenuatorSubscriptRange(3), numel(angularIndexY), 1);
            angularIndexY = repmat(angularIndexY(:), size(layerIndex, 2), 1);
            angularIndexX = repmat(angularIndexX(:), size(layerIndex, 2), 1);
            slices = sub2ind(size(this.indexStart), angularIndexY(:), angularIndexX(:), layerIndex(:));
            
            idxStart = this.indexStart(slices);
            idxEnd = this.indexEnd(slices);
            indices = arrayfun(@colon, idxStart, idxEnd, 'UniformOutput', false);
            indices = [indices{:}];
            
            P = M * sparse(this.I(indices), this.J(indices), this.S(indices), this.size(1), this.size(2));
        end
        
        function submitEntries(this, cameraIndexY, cameraIndexX, ...
                                     pixelIndexOnSensorY, pixelIndexOnSensorX, ...
                                     layerIndex, ...
                                     pixelIndexOnLayerY, pixelIndexOnLayerX, ...
                                     weightMatrix)
            
            this.indexStart(cameraIndexY, cameraIndexX, layerIndex) = this.currentIndex;
                                 
            rows = this.computeRowIndices(cameraIndexY, cameraIndexX, ...
                                          pixelIndexOnSensorY, pixelIndexOnSensorX);
            columns = this.computeColumnIndices(pixelIndexOnLayerY, pixelIndexOnLayerX, ...
                                                layerIndex);
            
            numberOfInsertions = numel(rows);
            this.I(this.currentIndex : this.currentIndex + numberOfInsertions - 1) = rows';
            this.J(this.currentIndex : this.currentIndex + numberOfInsertions - 1) = columns';
            this.S(this.currentIndex : this.currentIndex + numberOfInsertions - 1) = permute(weightMatrix(:), [2, 1]);
            this.currentIndex = this.currentIndex + numberOfInsertions;
            
            this.indexEnd(cameraIndexY, cameraIndexX, layerIndex) = this.currentIndex - 1;
        end
        
        function clear(this)
            this.I = [];
            this.J = [];
            this.S = [];
            this.currentIndex = 1;
        end
        
    end
    
end

