classdef FastReconstructionForResampledLF < ReconstructionForResampledLF
    
    methods
        
        function this = FastReconstructionForResampledLF(lightField, attenuator, samplingPlane)
            this = this@ReconstructionForResampledLF(lightField, attenuator, samplingPlane);
            this.propagationMatrix = PropagationMatrixM(this.resampledLightField, attenuator, 1);
        end
        
        function constructPropagationMatrix(this)
            
            this.propagationMatrix = PropagationMatrixM(this.resampledLightField, this.attenuator, this.precomputeNumberOfNonZeroEntries());
            this.constructPropagationMatrix@ReconstructionForResampledLF();
            
        end
        
    end
    
    methods (Access = protected)
        
        function numberOfNonZeros = precomputeNumberOfNonZeroEntries(this)
            
            numberOfNonZeros = 0;
            
            pixelPositionsOnSamplingPlaneMatrixY = this.samplingPlane.pixelPositionMatrixY;
            pixelPositionsOnSamplingPlaneMatrixX = this.samplingPlane.pixelPositionMatrixX;
            samplingPlaneZ = this.samplingPlane.z;

            for camIndexY = 1 : this.lightField.angularResolution(1)
                for camIndexX = 1 : this.lightField.angularResolution(2)
                    
                    [ positionsOnSensorPlaneMatrixY, ...
                      positionsOnSensorPlaneMatrixX ] = this.projection([camIndexY, camIndexX], ...
                                                                        this.lightField.sensorPlane.z, ...
                                                                        pixelPositionsOnSamplingPlaneMatrixY, ...
                                                                        pixelPositionsOnSamplingPlaneMatrixX, ...
                                                                        samplingPlaneZ);
                    
                    [ ~, ~, validSensorIntersections ] = this.lightField.sensorPlane.positionToPixelCoordinates(positionsOnSensorPlaneMatrixY, positionsOnSensorPlaneMatrixX);
                    
                    for layer = 1 : this.attenuator.numberOfLayers
                        
                        currentLayerZ = this.attenuator.layerPositionZ(layer);
                        
                        [ positionsOnLayerMatrixY, ...
                          positionsOnLayerMatrixX ] = this.projection([camIndexY, camIndexX], ...
                                                                      currentLayerZ, ...
                                                                      pixelPositionsOnSamplingPlaneMatrixY, ...
                                                                      pixelPositionsOnSamplingPlaneMatrixX, ...
                                                                      samplingPlaneZ);
                        
                        [ ~, ~, validLayerIntersections ] = this.attenuator.positionToPixelCoordinates(positionsOnLayerMatrixY, positionsOnLayerMatrixX);
                               
                        validRayIndices = validSensorIntersections & validLayerIntersections;
                        numberOfNonZeros = numberOfNonZeros + nnz(validRayIndices);
                    end
                end
            end
            
            if strcmp(this.layerInterpolation, ReconstructionForResampledLF.bilinearInterpolation) % Bilinear interpolation
                numberOfNonZeros = 4 * numberOfNonZeros;
            end
            
        end
        
    end


end

