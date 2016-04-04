classdef ReconstructionForResampledLF < AbstractReconstruction
    
    properties (Constant)
        interpolationMethod = 'linear';
        bilinearInterpolation = 'bi-linear';
        nearestInterpolation = 'nearest';
    end
    
    properties (SetAccess = private)
        resampledLightField;
        samplingPlane;
        layerInterpolation = ReconstructionForResampledLF.nearestInterpolation;
    end
    
    methods
        
        function this = ReconstructionForResampledLF(lightField, attenuator, samplingPlane)
            this = this@AbstractReconstruction(lightField, attenuator);
            
            resampledLFResolution = [lightField.angularResolution, samplingPlane.planeResolution];
            resampledLFData = zeros([resampledLFResolution, lightField.channels]);
            newSensorPlane = SensorPlane(samplingPlane.planeResolution, lightField.sensorPlane.planeSize, lightField.sensorPlane.z);
            this.samplingPlane = samplingPlane;
            
            % Initialize empty resampled light field
            this.resampledLightField = LightFieldP(resampledLFData, lightField.cameraPlane, newSensorPlane);
            this.propagationMatrix = PropagationMatrix(this.resampledLightField, attenuator);
        end
        
        function constructPropagationMatrix(this)
            
            pixelPositionsOnSamplingPlaneMatrixY = this.samplingPlane.pixelPositionMatrixY;
            pixelPositionsOnSamplingPlaneMatrixX = this.samplingPlane.pixelPositionMatrixX;
            samplingPlaneZ = this.samplingPlane.z;

            [ pixelIndexOnSamplingPlaneMatrixY, pixelIndexOnSamplingPlaneMatrixX ] = ndgrid(1 : this.samplingPlane.planeResolution(1), 1 : this.samplingPlane.planeResolution(2));

            for camIndexY = 1 : this.lightField.angularResolution(1)
                for camIndexX = 1 : this.lightField.angularResolution(2)
                    
                    [ positionsOnSensorPlaneMatrixY, ...
                      positionsOnSensorPlaneMatrixX ] = this.projection([camIndexY, camIndexX], ...
                                                                        this.lightField.sensorPlane.z, ...
                                                                        pixelPositionsOnSamplingPlaneMatrixY, ...
                                                                        pixelPositionsOnSamplingPlaneMatrixX, ...
                                                                        samplingPlaneZ);
                    
                    [ sensorIntersectionMatrixY, ...
                      sensorIntersectionMatrixX, ...
                      validIntersections ] = this.lightField.sensorPlane.positionToPixelCoordinates(positionsOnSensorPlaneMatrixY, positionsOnSensorPlaneMatrixX);
                    
                    invalidRayIndicesForSensorY = ~sum(validIntersections, 2);
                    invalidRayIndicesForSensorX = ~sum(validIntersections, 1);
                  
                    this.resampleView(camIndexY, camIndexX, sensorIntersectionMatrixY, sensorIntersectionMatrixX);
                    
                    pixelIndexOnSensorMatrixY = pixelIndexOnSamplingPlaneMatrixY; % contains also the invalid indices
                    pixelIndexOnSensorMatrixX = pixelIndexOnSamplingPlaneMatrixX; % contains also the invalid indices

                    for layer = 1 : this.attenuator.numberOfLayers

                        % Adjust distance for current layer; the coordinate origin is
                        % at the center of the layer stack
                        currentLayerZ = this.attenuator.layerPositionZ(layer);
                        
                        [ positionsOnLayerMatrixY, ...
                          positionsOnLayerMatrixX ] = this.projection([camIndexY, camIndexX], ...
                                                                      currentLayerZ, ...
                                                                      pixelPositionsOnSamplingPlaneMatrixY, ...
                                                                      pixelPositionsOnSamplingPlaneMatrixX, ...
                                                                      samplingPlaneZ);
                        
                        [ layerIntersectionMatrixY, ...
                          layerIntersectionMatrixX, ...
                          validIntersections ] = this.attenuator.positionToPixelCoordinates(positionsOnLayerMatrixY, positionsOnLayerMatrixX);
                        
                        invalidRayIndicesForLayerY = ~sum(validIntersections, 2);
                        invalidRayIndicesForLayerX = ~sum(validIntersections, 1);
                        
                        validRayIndicesY = ~(invalidRayIndicesForSensorY | invalidRayIndicesForLayerY);
                        validRayIndicesX = ~(invalidRayIndicesForSensorX | invalidRayIndicesForLayerX);
                        
                        pixelIndicesOnSensorY = pixelIndexOnSensorMatrixY(validRayIndicesY, validRayIndicesX); % column vector
                        pixelIndicesOnSensorX = pixelIndexOnSensorMatrixX(validRayIndicesY, validRayIndicesX); % row vector
                        
                        if strcmp(this.layerInterpolation, ReconstructionForResampledLF.nearestInterpolation) % Nearest neighbor
                            
                            pixelIndexOnLayerMatrixY = round(layerIntersectionMatrixY);
                            pixelIndexOnLayerMatrixX = round(layerIntersectionMatrixX);

                            weightsForLayerMatrix = this.computeRayIntersectionWeights(pixelIndexOnLayerMatrixY, ...
                                                                                       pixelIndexOnLayerMatrixX, ...
                                                                                       layerIntersectionMatrixY, ...
                                                                                       layerIntersectionMatrixX);

                            layerPixelIndicesY = pixelIndexOnLayerMatrixY(validRayIndicesY, validRayIndicesX); % column vector
                            layerPixelIndicesX = pixelIndexOnLayerMatrixX(validRayIndicesY, validRayIndicesX); % row vector

                            weightsForLayerMatrix = weightsForLayerMatrix(validRayIndicesY, validRayIndicesX);

                            this.propagationMatrix.submitEntries(camIndexY, camIndexX, ...
                                                                 pixelIndicesOnSensorY, pixelIndicesOnSensorX, ...
                                                                 layer, ...
                                                                 layerPixelIndicesY, layerPixelIndicesX, ...
                                                                 weightsForLayerMatrix);
                        
                        elseif strcmp(this.layerInterpolation, ReconstructionForResampledLF.bilinearInterpolation) % Bilinear interpolation
                            
                            x1 = floor(layerIntersectionMatrixX);
                            x2 = ceil(layerIntersectionMatrixX);
                            y1 = floor(layerIntersectionMatrixY);
                            y2 = ceil(layerIntersectionMatrixY);
                            
                            % Bilinear interpolation weights (grid size is 1)
                            w11 = (x2 - layerIntersectionMatrixX) .* (y2 - layerIntersectionMatrixY);
                            w21 = (layerIntersectionMatrixX - x1) .* (y2 - layerIntersectionMatrixY);
                            w12 = (x2 - layerIntersectionMatrixX) .* (layerIntersectionMatrixY - y1);
                            w22 = (layerIntersectionMatrixX - x1) .* (layerIntersectionMatrixY - y1);
                            
                            x1 = x1(validRayIndicesY, validRayIndicesX);
                            x2 = x2(validRayIndicesY, validRayIndicesX);
                            y1 = y1(validRayIndicesY, validRayIndicesX);
                            y2 = y2(validRayIndicesY, validRayIndicesX);
                            
                            w11 = w11(validRayIndicesY, validRayIndicesX);
                            w21 = w21(validRayIndicesY, validRayIndicesX);
                            w12 = w12(validRayIndicesY, validRayIndicesX);
                            w22 = w22(validRayIndicesY, validRayIndicesX);
                            
                            
                            this.propagationMatrix.submitEntries(camIndexY, camIndexX, ...
                                                                 pixelIndicesOnSensorY, pixelIndicesOnSensorX, ...
                                                                 layer, y1, x1, w11);
                            
                            this.propagationMatrix.submitEntries(camIndexY, camIndexX, ...
                                                                 pixelIndicesOnSensorY, pixelIndicesOnSensorX, ...
                                                                 layer, y1, x2, w21);
                                                          
                            this.propagationMatrix.submitEntries(camIndexY, camIndexX, ...
                                                                 pixelIndicesOnSensorY, pixelIndicesOnSensorX, ...
                                                                 layer, y2, x1, w12);
                                                            
                            this.propagationMatrix.submitEntries(camIndexY, camIndexX, ...
                                                                 pixelIndicesOnSensorY, pixelIndicesOnSensorX, ...
                                                                 layer, y2, x2, w22);
                            
                        end
                    end
                    
                    this.progressUpdateForMatrixConstruction(camIndexY, camIndexX);
                end
            end
        end
        
        function evaluation = evaluation(this)
            evaluation = ReconstructionEvaluation(this, this.resampledLightField);
        end
        
        function bilinearLayerInterpolation(this)
            this.layerInterpolation = ReconstructionForResampledLF.bilinearInterpolation;
        end
        
        function nearestLayerInterpolation(this)
            this.layerInterpolation = ReconstructionForResampledLF.nearestInterpolation;
        end
        
    end
    
    methods (Access = protected)
        
        function lightField = getLightFieldForOptimization(this)
            % Use the resampled light field for optimization instead of the input light field
            lightField = this.resampledLightField;
        end
        
        function [X, Y] = projection(this, cameraIndex, targetPlaneZ, X, Y, Z)
            
            % Get the position of the current camera on the camera plane
            centerOfProjection = [this.lightField.cameraPlane.cameraPositionMatrixY(cameraIndex(1), cameraIndex(2)), ...
                                  this.lightField.cameraPlane.cameraPositionMatrixX(cameraIndex(1), cameraIndex(2)), ...
                                  this.lightField.cameraPlane.z];
            
            distanceBetweenCameraPlaneAndFirstPlane = centerOfProjection(3) - Z;
            distanceBetweenCameraPlaneAndTargetPlane = centerOfProjection(3) - targetPlaneZ;
       
            % Shift positions to camera coordinate system
            X = X - centerOfProjection(1);
            Y = Y - centerOfProjection(2);

            % Project positions from first plane to the target plane
            X = X .* distanceBetweenCameraPlaneAndTargetPlane ./ distanceBetweenCameraPlaneAndFirstPlane;
            Y = Y .* distanceBetweenCameraPlaneAndTargetPlane ./ distanceBetweenCameraPlaneAndFirstPlane;

            % Shift positions back to world coordinate system
            X = X + centerOfProjection(1);
            Y = Y + centerOfProjection(2);
            
        end
        
        function weightMatrix = computeRayIntersectionWeights(this, ...
                                                              pixelIndexMatrixY, ...
                                                              pixelIndexMatrixX, ...
                                                              intersectionMatrixY, ...
                                                              intersectionMatrixX)

            % Weights are computed based on the deviation from the exact pixel location
            deviationY = intersectionMatrixY - pixelIndexMatrixY;
            deviationX = intersectionMatrixX - pixelIndexMatrixX;

            queryData = cat(3, deviationY, deviationX);
            queryData = reshape(queryData, [], 2);

            weightVector = this.weightFunctionHandle(queryData);
            weightMatrix = reshape(weightVector, size(pixelIndexMatrixY));

        end
        
        function resampleView(this, camIndexY, camIndexX, sensorIntersectionMatrixY, sensorIntersectionMatrixX)
            % Interpolating the current view of the light field
            % Interpolation in invalid query points will set the corresponding values in the light field to zero
            view = squeeze(this.lightField.lightFieldData(camIndexY, camIndexX, :, :, :));
            gridVectors = {sensorIntersectionMatrixY(:, 1), sensorIntersectionMatrixX(1, :), 1 : this.lightField.channels};
            
            % Remove arrays of singleton dimensions (2D light fields or single channel)
            indicesOfScalars = cellfun(@isscalar, gridVectors);
            grid = cell(1, nnz(~indicesOfScalars));
            [ grid{:} ] = ndgrid(gridVectors{~indicesOfScalars});
            
            this.resampledLightField.replaceView(camIndexY, camIndexX, interpn(view, grid{:}, ReconstructionForResampledLF.interpolationMethod, 0));
        end
        
    end


end

