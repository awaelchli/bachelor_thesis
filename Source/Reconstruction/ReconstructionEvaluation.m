classdef ReconstructionEvaluation < handle
    
    properties (Constant)
        defaultOutputFolder = 'output/';
        imageOutputType = 'png';
    end
    
    properties (Constant, Hidden)
        filenameReconstructionOfView = 'Reconstruction_of_view_(%i,%i)';
        filenameErrorForView = 'MSE_for_view_(%i,%i)';
        filenameRMSEFile = 'RMSE.txt';
        filenamePSNRFile = 'PSNR.txt';
    end
    
    properties (SetAccess = protected)
        lightField;
        reconstruction;
    end
    
    properties (SetAccess = private)
        reconstructionIndices;
        replicationSizes = [1, 1, 1, 1, 1];
        mse = inf;
        psnr = -inf;
    end
    
    properties (Dependent, SetAccess = private)
        attenuator;
        numberOfReconstructions;
    end
    
    properties 
        outputFolder = ReconstructionEvaluation.defaultOutputFolder;
    end
    
    methods
        
        function this = ReconstructionEvaluation(reconstruction, lightField)
            switch(nargin)
                case 1
                    this.lightField = reconstruction.lightField;
                case 2
                    this.lightField = lightField;
                otherwise
                    error('Wrong number of input arguments');
            end
            this.reconstruction = reconstruction;
        end
        
        function evaluateViews(this, angularIndices)
            assert(numel(size(angularIndices)) == 2 & size(angularIndices, 2) == 2, ...
                   'evaluateViews:wrongInputDimensions', ...
                   'The input must be a N x 2 matrix containing N angular indices.');
            
            validIndices = arrayfun(@(i) this.lightField.isValidAngularIndex(angularIndices(i, :)), 1 : size(angularIndices, 1));
            this.reconstructionIndices = angularIndices(validIndices, :);
            
            if(any(~validIndices))
                ReconstructionEvaluation.warningForInvalidCameraIndices(angularIndices(~validIndices, :));
            end
        end
        
        function replicateAngularDimensionY(this, replication)
            this.replicationSizes(LightField.angularDimensions(1)) = replication;
        end
        
        function replicateAngularDimensionX(this, replication)
            this.replicationSizes(LightField.angularDimensions(2)) = replication;
        end
        
        function replicateSpatialDimensionY(this, replication)
            this.replicationSizes(LightField.spatialDimensions(1)) = replication;
        end
        
        function replicateSpatialDimensionX(this, replication)
            this.replicationSizes(LightField.spatialDimensions(2)) = replication;
        end
        
        function attenuator = get.attenuator(this)
            attenuator = this.reconstruction.attenuator;
        end
        
        function numberOfReconstructions = get.numberOfReconstructions(this)
            numberOfReconstructions = size(this.reconstructionIndices, 1);
        end
        
        function set.outputFolder(this, outputFolder)
            assert(ReconstructionEvaluation.folderExists(outputFolder), ...
                   'outputFolder:folderDoesNotExist', ...
                   'Invalid path: The folder "%s" does not exist.', outputFolder);
            this.outputFolder = outputFolder;
        end
        
        function clearOutputFolder(this)
        	delete([this.outputFolder '/*']);
        end
        
        function displayReconstructedViews(this)
            for i = 1 : this.numberOfReconstructions
                this.displaySingleReconstructedView(this.reconstructionIndices(i, :));
            end
        end
        
        function displaySingleReconstructedView(this, cameraIndex, varargin)
            reconstructedView = getReplicatedReconstructedView(this, cameraIndex);
            
            if nargin == 3
                axes(varargin{1});
                imshow(reconstructedView);
            else
                displayTitle = sprintf('Reconstruction of view (%i, %i)', cameraIndex);
                figure('Name', 'Light field reconstruction from attenuation layers');
                imshow(reconstructedView);
                title(displayTitle);
            end
        end
        
        function storeReconstructedViews(this)
            this.createOutputFolderIfNotExists();
            
            for i = 1 : this.numberOfReconstructions
                this.storeSingleReconstructedView(this.reconstructionIndices(i, :));
            end
        end
        
        function displayErrorImages(this)
            RMSEoutput = '';
            PSNRoutput = '';
            for i = 1 : this.numberOfReconstructions
                currentCameraIndex = this.reconstructionIndices(i, :);
                [~, rmse, psnr] = this.displaySingleErrorImage(currentCameraIndex);
                RMSEoutput = this.appendRMSEOutput(RMSEoutput, currentCameraIndex, rmse);
                PSNRoutput = this.appendPSNROutput(PSNRoutput, currentCameraIndex, psnr);
            end
            % Print RMSE and PSNR to console
            fprintf(RMSEoutput);
            fprintf(PSNRoutput);
        end
        
        function [errorImage, rmse, psnr] = displaySingleErrorImage(this, cameraIndex, varargin)
            [errorImage, rmse, psnr] = this.getErrorForView(cameraIndex);
            
            if nargin == 3
                axes(varargin{1})
                imshow(errorImage, []);
            else
                displayTitle = sprintf('MSE for view (%i, %i)', cameraIndex);
                figure('Name', 'Mean-Square-Error for reconstructed view');
                imshow(errorImage, []);
                title(displayTitle);
            end
        end
        
        function storeErrorImages(this)
            this.createOutputFolderIfNotExists();
            
            errorImages = cell(1, this.numberOfReconstructions);
            
            rmses = zeros(this.numberOfReconstructions, 1);
            psnrs = zeros(this.numberOfReconstructions, 1);
            
            RMSEoutput = '';
            PSNRoutput = '';
            for i = 1 : this.numberOfReconstructions
                currentCameraIndex = this.reconstructionIndices(i, :);
                [errorImage, rmse, psnr] = this.getErrorForView(currentCameraIndex);
                errorImages{i} = errorImage;
                RMSEoutput = this.appendRMSEOutput(RMSEoutput, currentCameraIndex, rmse);
                PSNRoutput = this.appendPSNROutput(PSNRoutput, currentCameraIndex, psnr);
                
                rmses(i) = rmse;
                psnrs(i) = psnr;
            end
            
            this.mse = mean(rmses .^ 2, 1);
            rmse = sqrt(this.mse);
            this.psnr = 10 * log10((255^2) / this.mse);
            
            RMSEoutput = ReconstructionEvaluation.appendAverageRMSE(RMSEoutput, rmse);
            PSNRoutput = ReconstructionEvaluation.appendAveragePSNR(PSNRoutput, this.psnr);
            
            ReconstructionEvaluation.writeRMSEToTextFile(RMSEoutput, this.outputFolder);
            ReconstructionEvaluation.writePSNRToTextFile(PSNRoutput, this.outputFolder);
            
            minErrors = cellfun(@(im) min(im(:)), errorImages);
            maxErrors = cellfun(@(im) max(im(:)), errorImages);
            minError = min(minErrors);
            maxError = max(maxErrors);
            
            for i = 1 : this.numberOfReconstructions
                currentCameraIndex = this.reconstructionIndices(i, :);
                errorImage = (errorImages{i} - minError) / (maxError - minError);
                errorImage = ind2rgb(gray2ind(errorImage, 255^2), jet(255^2));
                filename = sprintf(ReconstructionEvaluation.filenameErrorForView, currentCameraIndex);
                imwrite(errorImage, [this.outputFolder '/' filename '.' ReconstructionEvaluation.imageOutputType]);
            end
        end
        
        function reconstructedView = getReplicatedReconstructedView(this, cameraIndex)
            reconstructedView = this.reconstruction.reconstructLightFieldSlice(cameraIndex(1), cameraIndex(2));
            reconstructedView = reshape(reconstructedView, [1, size(reconstructedView)]);
            reconstructedView = repmat(reconstructedView, this.replicationSizes);
            reconstructedView = squeeze(reconstructedView);
        end
        
        function displayLayers(this, layerNumbers)
            layers = this.getReplicatedAttenuationLayers(layerNumbers);
            for i = 1 : numel(layerNumbers)
                figure('Name', sprintf('Layer %i', layerNumbers(i)));
                imshow(squeeze(layers(i, :, :, :)));
            end
        end
        
        function storeLayers(this, layerNumbers)
            this.createOutputFolderIfNotExists();
            layers = this.getReplicatedAttenuationLayers(layerNumbers);
            for number = 1 : numel(layerNumbers)
                imwrite(squeeze(layers(number, :, :, :)), sprintf('%s/%i.%s', this.outputFolder, number, ReconstructionEvaluation.imageOutputType));
            end
        end
        
        function printLayers(this, arrangementMatrix, markerSize, varargin)
            this.createOutputFolderIfNotExists();
            
            layerNumbers = unique(arrangementMatrix(arrangementMatrix ~= 0));
            layers = this.getReplicatedAttenuationLayers(1 : this.attenuator.numberOfLayers);
            layersWithMarkers = addMarkersToLayers(layers, markerSize);
            
            for i = 1 : numel(layerNumbers)
                imwrite(squeeze(layersWithMarkers(layerNumbers(i), :, :, :)), sprintf('%s/print_%i.%s', this.outputFolder, layerNumbers(i), ReconstructionEvaluation.imageOutputType));
            end
            
            filename = ['Print_Layers' sprintf('-%i', reshape(layerNumbers, 1, []))];
            printSizeScale = 1;
            
            if nargin == 5
                filename = varargin{1};
                printSizeScale = varargin{2}; % Scaling for the size depending on the metric unit
            end
            if nargin == 4
                filename = varargin{1};
            end
            
            % Account for added marker padding before printing to pdf
            padding = max(0, 2 * markerSize - 1);
            paddedSize = this.attenuator.pixelSize .* 2 .* [0, padding];
            printSize = this.attenuator.planeSize + paddedSize;
            
            % Scale if unit is not millimeter
            printSize = printSize * printSizeScale;
            
            printImagesToPDF(this.outputFolder, filename, layersWithMarkers, printSize, arrangementMatrix);
        end
        
    end
    
    methods (Access = private)
        
        function storeSingleReconstructedView(this, cameraIndex)
            filename = sprintf(ReconstructionEvaluation.filenameReconstructionOfView, cameraIndex);
            reconstructedView = getReplicatedReconstructedView(this, cameraIndex);
            imwrite(reconstructedView, [this.outputFolder '/' filename '.' ReconstructionEvaluation.imageOutputType]);
        end
        
        function viewFromOriginal = getReplicatedOriginalView(this, cameraIndex)
            viewFromOriginal = this.lightField.lightFieldData(cameraIndex(1), cameraIndex(2), :, :, :);
            viewFromOriginal = repmat(viewFromOriginal, this.replicationSizes);
            viewFromOriginal = squeeze(viewFromOriginal);
        end
        
        function [errorImage, rmse, psnr] = getErrorForView(this, cameraIndex)
            viewFromOriginal = this.getReplicatedOriginalView(cameraIndex);
            viewFromReconstruction = this.getReplicatedReconstructedView(cameraIndex);
            [errorImage, rmse, psnr] = meanSquaredErrorImage(viewFromReconstruction, viewFromOriginal);
        end
        
        function layers = getReplicatedAttenuationLayers(this, layerNumbers)
            layers = this.attenuator.getAttenuationLayers(layerNumbers);
            layers = repmat(layers, [1, this.replicationSizes([LightField.spatialDimensions, LightField.channelDimension])]);
        end
        
        function valid = outputFolderExists(this)
            valid = ReconstructionEvaluation.folderExists(this.outputFolder);
        end
        
        function createOutputFolderIfNotExists(this)
            if(~this.outputFolderExists())
                mkdir(this.outputFolder);
            end
        end
        
    end
    
    methods (Static, Access = private)
        
        function warningForInvalidCameraIndices(angularIndices)
            for i = 1 : size(angularIndices, 1)
                ReconstructionEvaluation.warningForInvalidCameraIndex(angularIndices(i, :));
            end
        end
        
        function warningForInvalidCameraIndex(cameraIndex)
            warning('Skipping invalid camera index: (%i, %i)\n', cameraIndex);
        end
        
        function writeRMSEToTextFile(text, outputFolder)
            rmseFileID = fopen([outputFolder '/' ReconstructionEvaluation.filenameRMSEFile], 'wt');
            fprintf(rmseFileID, text);
            fclose(rmseFileID);
        end
        
        function writePSNRToTextFile(text, outputFolder)
            psnrFileID = fopen([outputFolder '/' ReconstructionEvaluation.filenamePSNRFile], 'wt');
            fprintf(psnrFileID, text);
            fclose(psnrFileID);
        end
        
        function RMSEoutput = appendRMSEOutput(RMSEoutput, cameraIndex, rmse)
            RMSEoutput = sprintf('%sRMSE for view (%i, %i): %f \n', RMSEoutput, cameraIndex(1), cameraIndex(2), rmse);
        end
        
        function PSNRoutput = appendPSNROutput(PSNRoutput, cameraIndex, psnr)
            PSNRoutput = sprintf('%sPSNR for view (%i, %i): %f \n', PSNRoutput, cameraIndex(1), cameraIndex(2), psnr);
        end
        
        function RMSEoutput = appendAverageRMSE(RMSEoutput, avgrmse)
            RMSEoutput = sprintf('%sTotal RMSE: %f \n', RMSEoutput, avgrmse);
        end
        
        function PSNRoutput = appendAveragePSNR(PSNRoutput, avgpsnr)
            PSNRoutput = sprintf('%sTotal PSNR: %f \n', PSNRoutput, avgpsnr);
        end
        
        function valid = folderExists(folder)
            valid = exist(folder, 'dir') == 7;
        end
        
    end
    
end

