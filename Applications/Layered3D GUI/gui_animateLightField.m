function gui_animateLightField( lightfield, handles, varargin )
%ANIMATELIGHTFIELD Takes light field data and cycles through the views
%   Input:      lightfield:     5D light field data, last dimension is the color channel
%               mode:           cycle direction, possible values: 'vertical', 'horizontal'

resolution = size(lightfield);
angularResolution = resolution([1 2]);
spatialResolution = resolution([3 4]);
if(numel(resolution) == 5)
    channels = resolution(5);
else 
    channels = 1;
end

if(nargin == 2)
    % Assume mode = 'horizontal'
    lightfield = permute(lightfield, [2 1 3 4 5]);
elseif(nargin == 4)
    if(strcmpi(varargin{1}, 'mode') && strcmpi(varargin{2}, 'horizontal'))
        lightfield = permute(lightfield, [2 1 3 4 5]);
    elseif(strcmpi(varargin{1}, 'mode') && strcmpi(varargin{2}, 'vertical'))
        % No change
    else
        error('Wrong input parameter for mode.');
    end
else
    error('Wrong number of inputs.');
end

lightfield = reshape(lightfield, [], spatialResolution(1), spatialResolution(2), channels);

axes(handles.axesLFPreview);
% while(handles.data.animationState)

    for i = 1 : prod(angularResolution)
        
%         if(~handles.data.animationState)
%             break;
%         end
        
        imshow(squeeze(lightfield(i, :, :, :)));
        axis equal image;
        pause(0.05);
    end
% end


end

