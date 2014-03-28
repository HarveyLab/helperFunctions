function varargout = tiffRead(fPath, castType)
% img = tiffLoad(fPath, [castType]); [img, scanimage] = tiffLoad(fPath);

if ~exist('castType', 'var')
    castType = 'double';
end

% Gracefully handle missing extension:
if exist(fPath, 'file') ~= 2
    if exist([fPath, '.tif'], 'file')
        fPath = [fPath, '.tif'];
    elseif exist([fPath, '.tiff'], 'file')
        fPath = [fPath, '.tiff'];
    else
        error(['Could not find ' fPath '.'])
    end
end

% Create Tiff object:
t = Tiff(fPath);

% Get number of directories (= frames):
t.setDirectory(1);
while ~t.lastDirectory
    t.nextDirectory;
end
nDirectories = t.currentDirectory;

% Load all directories (= frames):
img = zeros(t.getTag('ImageLength'), ...
    t.getTag('ImageWidth'), ...
    nDirectories, ...
    castType);

for i = 1:nDirectories
    t.setDirectory(i);
    img(:,:,i) = t.read;  
    if ~mod(i, 200)
        fprintf('%1.0f frames loaded.\n', i);
    end
end

varargout{1} = img;

% Scanimage metadata: Tiffs saved by Scanimage contain useful metadata in
% form of a struct. This data can be requested as a second output argument.
if nargout > 1
    imgDesc = t.getTag('ImageDescription');
    imgDescC = regexp(imgDesc, 'scanimage\..+? = .+?(?=\n)', 'match');
    imgDescC = strrep(imgDescC, '<nonscalar struct/object>', 'NaN');
    for e = imgDescC;
    	eval([e{:} ';']);
    end
    varargout{2} = scanimage;
end

% Close:
t.close();
    
