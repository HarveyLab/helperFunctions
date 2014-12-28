function varargout = tiffRead(fPath, castType, isSilent)
% img = tiffLoad(fPath, [castType]); [img, scanimage] = tiffLoad(fPath);

if ~exist('castType', 'var') || isempty(castType)
    castType = 'double';
end

if ~exist('isSilent', 'var') || isempty(isSilent)
    isSilent = false;
end

% Accessing network drives sometimes causes intermittent errors, so we wrap
% the main code in this error-handling block that retries the disk access
% once if it fails:
try
    varargout = tiffReadMainCode(fPath, castType, nargout, isSilent);
catch err
    fprintf('%s got the following error:\n%s', mfilename, getReport(err));
    fprintf('%s will now wait for some time and try again once.\n', mfilename);
    
    pause(60);
    
    try
        varargout = tiffReadMainCode(fPath, castType, nargout, isSilent);
    catch err
        fprintf('Retry failed. Re-throwing error:\n');
        rethrow(err);
    end
end

function outArgs = tiffReadMainCode(fPath, castType, nargout, isSilent)

%turn off warning thrown by reading in scanImage3 files
warning('off','MATLAB:imagesci:tiffmexutils:libtiffWarning'),

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
    if ~isSilent && ~mod(i, 200)
        fprintf('%1.0f frames of %d loaded.\n', i, nDirectories);
    end
end

outArgs{1} = img;

%turn back on warning to avoid conflicts later
warning('on','MATLAB:imagesci:tiffmexutils:libtiffWarning'),

% Scanimage metadata: Tiffs saved by Scanimage contain useful metadata in
% form of a struct. This data can be requested as a second output argument.
if nargout > 1
    imgDesc = t.getTag('ImageDescription');
    imgDescC = regexp(imgDesc, 'scanimage\..+? = .+?(?=\n)', 'match');
    imgDescC = strrep(imgDescC, '<nonscalar struct/object>', 'NaN');
    if ~isempty(imgDescC) %If it's a scanImage4 file
        for e = imgDescC;
            eval([e{:} ';']);
        end
        outArgs{2} = scanimage;
    else %If it's a scanImage3 file
        lineDesc = regexp(imgDesc,'state.','start');
        lineDesc(end+1) = length(imgDesc)+1;
        for e = 1:length(lineDesc)-1
            eval([imgDesc(lineDesc(e):lineDesc(e+1)-2) ';']);
        end
        outArgs{2} = state;
    end
end

% Close:
t.close();

