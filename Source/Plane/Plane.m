classdef Plane < handle
    
    %%%%%%%%%%%%%%%%%%%%
    %%% EXPERIMENTAL %%%
    %%%%%%%%%%%%%%%%%%%%
    
    properties (Constant, Hidden)
        defaultPosition = [0, 0, 0];
        defaultSize = [1, 1];
        dimension = 2;
    end
    
    properties
        position = Plane.defaultPosition;
        size = Plane.defaultSize;
    end
    
    properties (Dependent, SetAccess = private)
        height;
        width;
        aspectRatio;
    end
    
    methods
        
        function this = Plane(position, size)
            switch(nargin)
                case 0
                    % Use default position and size
                case 2
                    this.position = position;
                    this.size = size;
                otherwise
                    error('Wrong number of input arguments');
            end
        end
        
        function set.position(this, position)
            assert(numel(this.position) == numel(position), ...
                   'set.position:InvalidSizeOfPositionVector', ...
                   'The position vector must have the size 1x3.');
            this.position(:) = position(:);
        end
        
        function set.size(this, size)
            assert(numel(this.size) == Plane.dimension, ...
                   'set.position:InvalidSizeOfSize', ...
                   'The size must have two elements, the height and width.');
            this.size(:) = size(:);
        end
        
        function translate(this, translation)
            assert(numel(this.position) == numel(translation), ...
                   'translate:InvalidSizeOfTranslationVector', ...
                   'The translation vector must have the size 3x1.');
            this.position(:) = this.position(:) + translation(:);
        end
    end
    
end

