classdef ReconstructionForOrthographicLF < AbstractReconstruction
    
    methods
        
        function this = ReconstructionForOrthographicLF(lightField, attenuator)
            this = this@AbstractReconstruction(lightField, attenuator);
        end
        
        function constructPropagationMatrix(this)
            
            posY = this.lightField.sensorPlane.pixelPositionMatrixY;
            posX = this.lightField.sensorPlane.pixelPositionMatrixX;

            for imageX = 1 : this.lightField.angularResolution(2)
                for imageY = 1 : this.lightField.angularResolution(1)
                    for layer = 1 : this.attenuator.numberOfLayers

                        [posXCurrentLayer, ...
                         posYCurrentLayer] = this.projection([imageY, imageX], ...
                                                             this.attenuator.layerPositionZ(layer), ...
                                                             posX, ...
                                                             posY, ...
                                                             this.lightField.sensorPlane.z);
                        
                        [pixelsY, ...
                         pixelsX, ...
                         validIndices] = this.attenuator.positionToPixelCoordinates(posYCurrentLayer, ...
                                                                                    posXCurrentLayer);
                        
                        validX = sum(validIndices, 1) ~= 0;
                        validY = sum(validIndices, 2) ~= 0;
                        
                        indicesY = find(validY);
                        indicesX = find(validX);
                        
                        indicesX = repmat(indicesX, numel(indicesY), 1);
                        indicesY = repmat(indicesY, 1, size(indicesX, 2));
                        
                        pixelsY = pixelsY(validY, validX);
                        pixelsX = pixelsX(validY, validX);
                        
                        pixelsY = round(pixelsY);
                        pixelsX = round(pixelsX);
                        
                        this.propagationMatrix.submitEntries(imageY, imageX, ...
                                                             indicesY, indicesX, ...
                                                             layer, ...
                                                             pixelsY, pixelsX, ...
                                                             ones(size(pixelsY)));
                    end
                end
            end
        end
        
    end
    
    methods (Access = protected)
        
        function lightField = getLightFieldForOptimization(this)
            lightField = this.lightField;
        end
        
        function [X, Y] = projection(this, cameraIndex, targetPlaneZ, X, Y, Z)
            rayAngle = this.lightField.rayAngle(cameraIndex);
            Y = Y + tan(rayAngle(1)) * (targetPlaneZ - Z);
            X = X + tan(rayAngle(2)) * (targetPlaneZ - Z);
        end
        
        function weightMatrix = computeRayIntersectionWeights(~, pixelIndexMatrixY, ~)
            weightMatrix = ones(size(pixelIndexMatrixY));
        end
        
    end
    
end

