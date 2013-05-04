thresh = 0.15;
vidDevice = imaq.VideoDevice('winvideo', 1, 'MJPG_320x240');
vidInfo = imaqhwinfo(vidDevice);  % Acquire video information
% Make system object for blob analysis
hblob = vision.BlobAnalysis('AreaOutputPort', false,'CentroidOutputPort', true,'BoundingBoxOutputPort', true', 'MaximumBlobArea', 600,'MaximumCount', 1);
% Make system object for Translucent Filled Box
hshapeinsRedBox = vision.ShapeInserter('BorderColor', 'Custom','CustomBorderColor', [0 0 0],'Fill', true,'FillColor', 'Custom','CustomFillColor', [0 0 0],'Opacity', 0.4);  
% Make system object for output video stream
hVideoIn = vision.VideoPlayer();  
nFrame = 300;  % Initialize number of frame counter
centX = 1; centY = 1;  % Feature Centroid initialization
minSize=10;
maxSize=10;
se = strel('disk',10,0);
while nFrame>0
    rgbFrame = step(vidDevice);  % Extract Single Frame
    rgbFrame = flipdim(rgbFrame,2);
    binFrame = (im2bw(rgbFrame,0.95));
    bitFrame= imsubtract(bwareaopen(binFrame,30), bwareaopen(binFrame,200));
    
    rgbFrame1 = step(vidDevice);  % Extract Single Frame
    rgbFrame1 = flipdim(rgbFrame1,2);
    binFrame1 = (im2bw(rgbFrame1,0.95));
    bitFrame1= imsubtract(bwareaopen(binFrame1,30), bwareaopen(binFrame1,200));
    
    
    imshow(bwareaopen(imsubtract(binFrame1,binFrame),200));
    
    
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