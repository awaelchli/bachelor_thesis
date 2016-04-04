classdef SensorPlane < PixelPlane
    
    % Properties from superclass
    properties (SetAccess = protected)
        planeResolution;
        planeSize;
    end
    
    properties (SetAccess = private)
        z;
    end
    
    methods
        
        function this = SensorPlane(sensorResolution, sensorSize, z)
            this.planeResolution = sensorResolution;
            this.planeSize = sensorSize;
            this.z = z;
        end
        
    end
    
end

