classdef AbstractReconstruction < handle
    
    properties (SetAccess = protected)
        lightField;
        attenuator;
        % The propagation matrix used to solve for the attenuation values
        propagationMatrix;
        % A different propagation matrix that can be used for reconstructing views from attenuation layers
        propagationMatrixForReconstruction;
    end
    
    properties
        iterations = 20;
        weightFunctionHandle;
        verbose = 1;
        solver = @sart;
    end
    
    methods (Abstract)
        
        constructPropagationMatrix(this)
        
    end
    
    methods (Abstract, Access = protected)
        
        lightField = getLightFieldForOptimization(this);
        
        [X, Y] = projection(this, cameraIndex, targetPlaneZ, X, Y, Z)
        
        weightMatrix = computeRayIntersectionWeights(this, pixelIndexMatrixY, pixelIndexMatrixX, intersectionMatrixY, intersectionMatrixX)
        
    end
    
    methods
        
        function this = AbstractReconstruction(lightField, attenuator)
            this.lightField = lightField;
            this.attenuator = attenuator;
            this.propagationMatrix = PropagationMatrix(lightField, attenuator);
            this.propagationMatrixForReconstruction = this.propagationMatrix;
            this.weightFunctionHandle = @(data) ones(size(data, 1), 1);
        end
        
        function computeAttenuationLayers(this)
            
            tic;
            if(this.verbose)
                fprintf('\nComputing propagation matrix P ...\n');
            end
            
            this.constructPropagationMatrix();
            this.propagationMatrixForReconstruction = this.propagationMatrix;
            
            if(this.verbose)
                fprintf('Done calculating P. Calculation took %i seconds.\n', floor(toc));
            end
           
            tic;
            if(this.verbose)
                fprintf('Running optimization ...\n');
            end
            
            this.runOptimization();
            
            if(this.verbose)
                fprintf('Optimization took %i seconds.\n', floor(toc));
            end
            
        end
        
        function [ reconstructedLF, varargout ] = reconstructLightField(this)
            
            nargoutchk(1, 2);
            
            attenuationValues = this.attenuator.vectorizeData();
            reconstructionVector = this.propagationMatrixForReconstruction.formSparseMatrix() * log(attenuationValues);

            % convert the light field vector to the 4D light field
            reconstructionData = reshape(reconstructionVector, [this.propagationMatrixForReconstruction.lightFieldSubscriptRange, this.lightField.channels]);
            reconstructionData = exp(reconstructionData);
            reconstructedLF = LightField(reconstructionData);
            
            if nargout == 2
                % compute MSE
                diff = reshape(reconstructedLF.lightFieldData - this.getLightFieldForOptimization().lightFieldData, [], 1);
                varargout{1} = sum((diff * 255) .^2) / (prod(reconstructedLF.resolution) * reconstructedLF.channels);
            end
            
        end
        
        function reconstructionData = reconstructLightFieldSlice(this, angularIndexY, angularIndexX)
            
            attenuationValues = this.attenuator.vectorizeData();
            reconstructionVector = this.propagationMatrixForReconstruction.formSparseSubMatrix(angularIndexY, angularIndexX) * log(attenuationValues);

            reconstructionData = reshape(reconstructionVector, [this.propagationMatrixForReconstruction.lightFieldSubscriptRange(LightField.spatialDimensions), ...
                                                                numel(angularIndexY), ...
                                                                this.lightField.channels]);
            
            reconstructionData = permute(reconstructionData, [3, 1, 2, 4]);
            reconstructionData = exp(reconstructionData);
        end
        
        function evaluation = evaluation(this)
            evaluation = ReconstructionEvaluation(this);
        end
        
        function usePropagationMatrixForReconstruction(this, P)
            assert(P.size(2) == this.propagationMatrix.size(2), ...
                   'set.P:newPmatrixHasWrongDimensions', ...
                   'The second dimension of the matrix does not match the resolution of the attenuator.');
            this.propagationMatrixForReconstruction = P;
        end
        
        function backProjection = backprojectLightField(this)
            P = this.propagationMatrix.formSparseMatrix();
            l = this.getLightFieldForOptimization().vectorizeData();
            
            backProjection = P' * double(l);
            
            backProjection = backProjection ./ repmat(sum(P, 1)', [1, this.lightField.channels]);
            backProjection = permute(backProjection, [2, 1]);
            backProjection = reshape(backProjection, [this.attenuator.channels, this.attenuator.planeResolution, this.attenuator.numberOfLayers]);
            backProjection = permute(backProjection, [4, 2, 3, 1]);
        end
        
    end
    
    methods (Access = protected)
        
        function runOptimization(this)
            
            P = this.propagationMatrix.formSparseMatrix();
            lightFieldVector = this.getLightFieldForOptimization().vectorizeData();
            
            % Convert to log light field
            lightFieldVector(lightFieldVector < Attenuator.minimumTransmission) = Attenuator.minimumTransmission;
            lightFieldVectorLogDomain = log(lightFieldVector);

            % Optimization constraints
            ub = zeros(this.propagationMatrix.size(2), this.getLightFieldForOptimization().channels); 
            lb = zeros(size(ub)) + log(Attenuator.minimumTransmission);
%             x0 = zeros(size(ub));
            x0 = log(this.attenuator.vectorizeData());
            
            % Solve the optimization problem using the provided solver
            attenuationValuesLogDomain = this.solver(P, double(lightFieldVectorLogDomain), x0, lb, ub, this.iterations);
            
            attenuationValues = exp(attenuationValuesLogDomain);
            
            attenuationValues = permute(attenuationValues, [2, 1]);
            attenuationValues = reshape(attenuationValues, [this.attenuator.channels, this.attenuator.planeResolution, this.attenuator.numberOfLayers]);
            attenuationValues = permute(attenuationValues, [4, 2, 3, 1]);

            this.attenuator.attenuationValues = attenuationValues;
        end
        
        function progressUpdateForMatrixConstruction(this, angularIndexY, angularIndexX)
            if(~this.verbose)
                return;
            end
            fprintf('(%i, %i) ', angularIndexY, angularIndexX);
            if(angularIndexX == this.lightField.angularResolution(2))
                fprintf('\n');
            end
        end
        
    end
    
end

