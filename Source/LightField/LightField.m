classdef LightField < handle
    % LIGHTFIELD is a general model class for the light field
    %   
    %   The class models a 4D light field. The data is stored in a 5D-matrix where the 5th dimension is used for the color
    %   space.
    
    properties (Constant)
        lightFieldDimension = 4;
        angularDimensions = [1, 2];
        spatialDimensions = [3, 4];
        channelDimension = 5;
    end
    
    properties (SetAccess = protected)
        lightFieldData;
    end
    
    properties (Dependent, SetAccess = private)
        resolution;
        angularResolution;
        spatialResolution;
        channels;
    end
    
    methods
        
        function this = LightField(lightFieldData)
            % LightField - Creates a light field from existing data
            this.lightFieldData = lightFieldData;
            this.assertLightFieldDataSize();
        end
        
        function resolution = get.resolution(this)
            resolution = size(this.lightFieldData);
            resolution = resolution([LightField.angularDimensions, LightField.spatialDimensions]);
        end
        
        function angularResolution = get.angularResolution(this)
            angularResolution = this.resolution(LightField.angularDimensions);
        end
        
        function spatialResolution = get.spatialResolution(this)
            spatialResolution = this.resolution(LightField.spatialDimensions);
        end
        
        function channels = get.channels(this)
            channels = size(this.lightFieldData, LightField.channelDimension);
        end
        
        function replaceView(this, angularIndexY, angularIndexX, image)
            assert(this.isValidAngularIndex([angularIndexY, angularIndexX]), ...
                   'replaceView:InvalidAngularIndex', ...
                   sprintf('(%i, %i) is not a valid angular index.', angularIndexY, angularIndexX));
            
            assert(all([size(image, 1), size(image, 2)] == [this.spatialResolution]), ...
                   'replaceView:InvalidSpatialResolutionOfViewReplacement', ...
                   'The size of the image does not correspond to spatial resolution.');
            
          	assert(size(image, 3) == this.channels, ...
                   'replaceView:InvalidNumberOfChannelsInViewReplacement', ...
                   'The number of channels in the image does not correspond to the number of channels in the light field.');
            
            this.lightFieldData(angularIndexY, angularIndexX, : , : , :) = image;
            this.assertInvariant();
        end
        
        function valid = isValidAngularIndex(this, index)
            valid = PixelPlane.isValidIndex(index, this.angularResolution);
        end
        
        function valid = isValidSpatialIndex(this, index)
            valid = PixelPlane.isValidIndex(index, this.spatialResolution);
        end
        
        function lightFieldVector = vectorizeData(this)
            lightFieldVector = reshape(this.lightFieldData, [], this.channels);
        end
        
    end
    
    methods (Access = protected)
        
        function assertInvariant(this)
            this.assertLightFieldDataSize();
        end
        
    end
    
    methods (Access = private)
        
        function assertLightFieldDataSize(this)
            assert(numel(size(this.lightFieldData)) >= LightField.lightFieldDimension, ...
                   'assertLightFieldDataSize:dataHasWrongNumberOfDimensions', ...
                   'The light field data must be a 4D or 5D array.');
        end
        
    end
    
end

