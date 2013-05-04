thresh = 0.15;
vidDevice = imaq.VideoDevice('winvideo', 1, 'MJPG_320x240');
vidInfo = imaqhwinfo(vidDevice);  % Acquire video information
% Make system object for blob analysis
hblob = vision.BlobAnalysis('AreaOutputPort', false,'CentroidOutputPort', true,'BoundingBoxOutputPort', true', 'MaximumBlobArea', 7500,'MaximumCount', 1);
% Make system object for Translucent Filled Box
hshapeinsRedBox = vision.ShapeInserter('BorderColor', 'Custom','CustomBorderColor', [0 0 0],'Fill', true,'FillColor', 'Custom','CustomFillColor', [0 0 0],'Opacity', 0.4);  
% Make system object for output video stream
hVideoIn = vision.VideoPlayer();  
nFrame = 300;  % Initialize number of frame counter
centX = 1; centY = 1;  % Feature Centroid initialization
MN= [30 30];
se = strel('rectangle',MN);
MN2= [30 30];
se2 = strel('rectangle',MN2);


while nFrame>0
    rgbFrame = step(vidDevice);
    binFrame = (im2bw(rgbFrame,0.97));  % Extract Single Frame

    
    binFrame = flipdim(binFrame,2);
    rgbFrame = flipdim(rgbFrame,2);
    %diffFrame = imsubtract(rgbFrame(:,:,1), rgb2gray(rgbFrame));  % Extract Red component
    %imshow(diffFrame);
    %diffFrame = medfilt2(diffFrame, [3 3]);  % Applying Medial Filter for denoising

    %binFrame = im2bw(diffFrame, thresh);  % Convert to binary image using red threshold
    
    % Discard large and small areas
    %imshow(imsubtract(bwareaopen(binFrame,30), bwareaopen(binFrame,400)));
    %imshow(binFrame);
    
    binFrame= (imdilate(imerode(bwareaopen(binFrame,300),se),se2));
    
    imshow(binFrame);
    [centroid, bbox] = step(hblob, binFrame);  % Get the reqired statistics of remaining blobs
    if ~isempty(bbox)  %  Get the centroid of remaining blobs
        centX = centroid(1); centY = centroid(2);
    end
    
    vidIn = step(hshapeinsRedBox, rgbFrame, bbox);  % Put a Red bounding box in input video stream
    step(hVideoIn, vidIn);  % Show the output video stream 

  nFrame = nFrame -1;
end
release(vidDevice);
clear vidDevice;