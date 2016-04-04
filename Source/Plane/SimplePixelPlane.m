classdef SimplePixelPlane < PixelPlane
    
    % Properties from superclass
    properties (SetAccess = protected)
        planeResolution;
        planeSize;
    end
    
    methods
        
        function this = SimplePixelPlane(planeResolution, planeSize)
            this.planeResolution = planeResolution;
            this.planeSize = planeSize;
        end
        
    end
    
end