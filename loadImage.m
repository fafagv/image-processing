function image = loadImage(filename)
% LOADIMAGE Load an image from disc and return it as type double.
%
%   image = loadImage(filename) reads the image file specified by the
%   string filename and returns it as an MxNx3 double array with values
%   scaled to the range [0,1]. Using double throughout the rest of the
%   pipeline avoids the integer rounding/overflow problems that come
%   with uint8 arithmetic (e.g. when averaging pixel colours).

    raw = imread(filename);

    % im2double scales uint8/uint16 images into the [0,1] range and
    % leaves already-double images unchanged.
    image = im2double(raw);

    % Some of the sample images may be indexed/paletted or contain an
    % alpha channel. Make sure we always return a 3-channel RGB image.
    if size(image,3) == 1
        image = repmat(image,[1 1 3]);
    elseif size(image,3) == 4
        image = image(:,:,1:3);
    end
end
