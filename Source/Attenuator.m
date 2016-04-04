classdef Attenuator < PixelPlane
    
    properties (Constant)
        layerDimension = 1;
        spatialDimensions = [2, 3];
        channelDimension = 4;
        minimumNumberOfLayers = 2;
        minimumTransmission = 0.001;
    end
    
    properties
        attenuationValues;
    end
    
    properties (Dependent, SetAccess = protected)
        planeResolution;
    end
    
    properties (SetAccess = protected)
        planeSize;
    end
    
    properties (SetAccess = private)
        layerPositionZ;
    end
    
    properties (Dependent, SetAccess = private)
        numberOfLayers;
        channels;
        thickness;
    end
    
    
    methods
        
        function this = Attenuator(numberOfLayers, layerResolution, layerSize, thickness, channels)
            if(numberOfLayers < Attenuator.minimumNumberOfLayers)
                error('Attenuator must have a minimum of %i layers.', Attenuator.minimumNumberOfLayers);
            end
            this.planeSize = layerSize;
            this.attenuationValues = ones([numberOfLayers, layerResolution, channels]);
            this.initLayerPositions(thickness, numberOfLayers);
            this.assertInvariant();
        end
        
        function numberOfLayers = get.numberOfLayers(this)
            numberOfLayers = numel(this.layerPositionZ);
        end
        
        function channels = get.channels(this)
            channels = size(this.attenuationValues, Attenuator.channelDimension);
        end
        
        function planeResolution = get.planeResolution(this)
            planeResolution = size(this.attenuationValues);
            planeResolution = planeResolution(Attenuator.spatialDimensions);
        end
        
        function planeSize = get.planeSize(this)
            planeSize = this.planeSize;
        end
        
        function thickness = get.thickness(this)
            thickness = abs(max(this.layerPositionZ) - min(this.layerPositionZ));
        end
        
        function placeLayer(this, layerNumber, z)
            arrayfun(@(n) this.errorIfInvalidLayerNumber(n), layerNumber);
            this.layerPositionZ(layerNumber) = z;
            this.assertInvariant();
        end
        
        function translateLayers(this, translationZ)
            this.layerPositionZ = this.layerPositionZ + translationZ;
        end

        function layers = getAttenuationLayers(this, layerNumbers)
            arrayfun(@(n) this.errorIfInvalidLayerNumber(n), layerNumbers); 
            layers = this.attenuationValues(layerNumbers, :, :, :);
        end
        
        function vector = vectorizeData(this)
            vector = reshape(permute(this.attenuationValues, [2, 3, 1, 4]), ...
                             prod([this.planeResolution, this.numberOfLayers]), []);
        end
        
        function valid = isValidLayerNumber(this, layerNumber)
            valid = isscalar(layerNumber) & ...
                    1 <= layerNumber & ...
                    this.numberOfLayers >= layerNumber & ...
                    mod(layerNumber, 1) == 0;
        end
        
    end
    
    methods (Access = private)
        
        function errorIfInvalidLayerNumber(this, layerNumber)
            if(~this.isValidLayerNumber(layerNumber))
                errorStruct.message = sprintf('Invalid layer number: %i', layerNumber);
                errorStruct.identifier = 'errorIfInvalidLayerNumber:invalidLayerNumber';
                error(errorStruct);
            end
        end
        
        function initLayerPositions(this, thickness, numberOfLayers)
            % Equidistant spaced layers
            distanceBetweenLayers = thickness / (numberOfLayers - 1);
            this.layerPositionZ = -thickness / 2 : distanceBetweenLayers : thickness / 2;
            this.assertInvariant();
        end
        
        function assertInvariant(this)
            assert(size(this.attenuationValues, Attenuator.layerDimension) == this.numberOfLayers, ...
                   'assertInvariant:WrongNumberOfLayers', ...
                   'The number of layers does not correspond to the size of the attenuation data.');
        end
        
    end
    
end

