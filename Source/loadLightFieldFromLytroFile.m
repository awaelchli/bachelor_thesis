function [lightFieldData, metadata] = loadLightFieldFromLytroFile( lytroFile, lytroCameraPath, varargin)
% lytroFile:                Path to the .lfr file
% lytroCameraPath:          Path to the installed camera, usually in C:/Users/username/AppData/Local/Lytro/cameras/.

file = fullfile(lytroFile);
whiteImageDatabasePath = fullfile(lytroCameraPath, 'WhiteImageDatabase.mat');

if(~exist(whiteImageDatabasePath, 'file'))
    errorStruct.message = sprintf('The file "%s" does not exist.', whiteImageDatabasePath);
    errorStruct.identifier = 'loadLightFieldFromLytroFile:DatabaseNotFound';
    error(errorStruct);
end

if(~exist(file, 'file'))
    errorStruct.message = sprintf('The file "%s" does not exist.', file);
    errorStruct.identifier = 'loadLightFieldFromLytroFile:FileNotFound';
    error(errorStruct);
end

FileOptions = LFDefaultField('FileOptions', 'SaveResult', true);
FileOptions = LFDefaultField('FileOptions', 'SaveFnamePattern', '%s_Decoded.mat');

DecodeOptions = LFDefaultField('DecodeOptions', 'WhiteImageDatabasePath', whiteImageDatabasePath);

if nargin == 3 && strcmpi(varargin{1}, 'ColourCorrect')
    DecodeOptions = LFDefaultField('DecodeOptions', 'OptionalTasks', {'ColourCorrect'});
end

LFUtilUnpackLytroArchive(lytroCameraPath);
LFUtilProcessWhiteImages(lytroCameraPath);
LFUtilDecodeLytroFolder(file, FileOptions, DecodeOptions, []);

[path, name, ~] = fileparts(file);
load([path filesep name '_Decoded.mat']);

lightFieldData = LF;

lightFieldData = lightFieldData(:, :, :, :, 1 : 3);
lightFieldData = im2single(lightFieldData);
metadata = LFMetadata;

end

