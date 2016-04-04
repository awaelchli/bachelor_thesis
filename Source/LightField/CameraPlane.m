classdef CameraPlane < handle
    
    properties (SetAccess = private)
        cameraPositionMatrixY;
        cameraPositionMatrixX;
        z;
    end
    
    properties (Dependent, SetAccess = private)
        size;
        resolution;
        distanceBetweenTwoCameras;
    end
    
    methods
        
        function this = CameraPlane(gridResolution, distanceBetweenTwoCameras, z)
            this.z = z;
            [ this.cameraPositionMatrixY, ...
              this.cameraPositionMatrixX ] = computeCenteredGridPositions(gridResolution, distanceBetweenTwoCameras);
        end
        
        function size = get.size(this)
            resolution = this.resolution;
            height = 2 * this.cameraPositionMatrixY(1, 1);
            width = 2 * this.cameraPositionMatrixX(1, resolution(2));
            size = [height, width];
        end
        
        function resolution = get.resolution(this)
            resolution = size(this.cameraPositionMatrixY);
        end
        
        function distance = get.distanceBetweenTwoCameras(this)
            distance = [0, 0];
            
            if(this.resolution(1) > 1)
                distance(1) = this.cameraPositionMatrixY(1, 1) - ...
                              this.cameraPositionMatrixY(2, 1);
            end
            if(this.resolution(2) > 1)
                distance(2) = this.cameraPositionMatrixX(1, 2) - ...
                              this.cameraPositionMatrixX(1, 1);
            end
        end
        
    end
    
end

