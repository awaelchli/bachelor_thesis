classdef LightFieldO < LightField
    % LIGHTFIELDO models a light field caputured from orthographic projections over a range of angles
    %
    %   The orthographic light field defines each light ray by the intersection with the sensor plane and the angle
    %   between the ray and the normal on the sensor plane.
    
    properties (Constant)
        verticalFOVIndex = 1;
        horizontalFOVIndex = 2;
    end
    
    properties (SetAccess = private)
        sensorPlane;
        % Vertical and horizontal field of view of the light field in radians
        fov;
    end
    
    properties (Dependent, SetAccess = private)
        % Vertical field of view in radians
        fovY;
        % Horizontal field of view in radians
        fovX;
    end
    
    methods
        
        function this = LightFieldO(lightFieldData, sensorPlane, fieldOfView)
            this = this@LightField(lightFieldData);
            this.sensorPlane = sensorPlane;
            this.fov = deg2rad(fieldOfView);
            this.assertInvariant();
        end
        
        function rayAngle = rayAngle(this, angularIndex)
            halfFOV = this.fov / 2;
            angularStep = this.fov ./ (this.angularResolution - 1);
            rayAngle(1) = halfFOV(1) - (angularIndex(1) - 1) .* angularStep(1);
            rayAngle(2) = -halfFOV(2) + (angularIndex(2) - 1) .* angularStep(2);
            this.assertInvariant();
        end
        
        function fovY = get.fovY(this)
            fovY = this.fov(LightFieldO.verticalFOVIndex);
        end
        
        function fovX = get.fovX(this)
            fovX = this.fov(LightFieldO.horizontalFOVIndex);
        end
        
    end
    
    methods (Access = protected)
        
        function assertInvariant(this)
            this.assertInvariant@LightField();
            assert(all(this.sensorPlane.planeResolution == this.spatialResolution), ...
                   'assertInvariant:wrongSpatialResolution', ...
                   'The resolution of the sensor plane must match the dimensions of the data.');
            assert(numel(this.fov) == 2, ...
                   'assertInvariant:wrongFOVSize', ...
                   'The FOV must be a tupel of vertical and horizontal field of view.');
        end
        
    end
    
end

