thresh = 0.15;
vidDevice = imaq.VideoDevice('winvideo', 1, 'MJPG_320x240');
vidInfo = imaqhwinfo(vidDevice);  % Acquire video information
% Make system object for blob analysis
hblob = vision.BlobAnalysis('AreaOutputPort', false,'CentroidOutputPort', true,'BoundingBoxOutputPort', true', 'MaximumBlobArea', 5000,'MaximumCount', 1);
% Make system object for Translucent Filled Box
hshapeinsRedBox = vision.ShapeInserter('BorderColor', 'Custom','CustomBorderColor', [0 0 0],'Fill', true,'FillColor', 'Custom','CustomFillColor', [0 0 0],'Opacity', 0.4);  
% Make system .......object for output video stream
hVideoIn = vision.VideoPlayer();  
nFrame = 300;  % Initialize number of frame counter
centX = 1; centY = 1;  % Feature Centroid initialization
minSize=10;
maxSize=10;
se = strel('disk',10,0);

predict = zeros(2,30);
i= 1;

robot = java.awt.Robot();
while nFrame>0
    
    rgbFrame = step(vidDevice);  % Extract Single Frame
    rgbFrame = flipdim(rgbFrame,2);
    binFrame = (im2bw(rgbFrame,0.95));
    bitFrame= imsubtract(bwareaopen(binFrame,30), bwareaopen(binFrame,150));
    
    rgbFrame1 = step(vidDevice);  % Extract Single Frame
    rgbFrame1 = flipdim(rgbFrame1,2);
    binFrame1 = (im2bw(rgbFrame1,0.95));
    bitFrame1= imsubtract(bwareaopen(binFrame1,30), bwareaopen(binFrame1,200));
    
    
    
    binFrame =(bwareaopen(imsubtract(binFrame1,binFrame),200));
    MN= [10 10];
    se = strel('rectangle',MN);
    
    binFrame = imdilate(imfill(binFrame,'holes'),se);
    imshow(binFrame);
    
    movL = 0;movU = 0;
    movL1 = 0;movU1 = 0;
    movL2 = 0;movU2 = 0;
    movL3 = 0;movU3 = 0;
    movL4 = 0;movU4 = 0;

    [centroid, bbox] = step(hblob, binFrame);  % Get the reqired statistics of remaining blobs
    if ~isempty(bbox)  %  Get the centroid of remaining blobs
        centX = centroid(1); centY = centroid(2);
        %x 15 300
        %y 50 150
        i= mod(i+1,30)+1;
        predict(1,i)=uint16(centX);
        predict(2,i)=uint16(centY);
            
    end
         movL =  predict(1,mod(i+1,30)+1);
         movU =  predict(2,mod(i+1,30)+1);

          movL1 =  predict(1,mod(i+7,30)+1);
         movU1 =  predict(2,mod(i+7,30)+1);

          movL2 =  predict(1,mod(i+13,30)+1);
         movU2 =  predict(2,mod(i+13,30)+1);

          movL3 =  predict(1,mod(i+19,30)+1);
         movU3 =  predict(2,mod(i+19,30)+1);

          movL4 =  predict(1,mod(i+25,30)+1);
         movU4 =  predict(2,mod(i+25,30)+1);

         
    vidIn = step(hshapeinsRedBox, rgbFrame, bbox);  % Put a Red bounding box in input video stream
    step(hVideoIn, vidIn);  % Show the output video stream 

  nFrame = nFrame -1;

         
        
         if (movL==0 || movL1==0 || movL2==0 || movL3==0 || movL4==0  )
             
         elseif ( movL < movL1 &&  movL1 < movL2 &&  movL2 < movL3 &&  movL3 < movL4 )
           if (predict(1,i)-movL2 > 70)
                 disp('Right');

                 robot.keyPress(java.awt.event.KeyEvent.VK_N);
                  robot.keyRelease(java.awt.event.KeyEvent.VK_N);
                 predict = zeros(2,30);
                 continue;
           end
         elseif ( movL > movL1 &&  movL1 > movL2 &&  movL2 > movL3 &&  movL3 > movL4)
           if (movL2 - predict(1,i) > 70)
                disp('Left');
                robot.keyPress(java.awt.event.KeyEvent.VK_P);
                robot.keyRelease(java.awt.event.KeyEvent.VK_P);
                predict = zeros(2,30);
                continue;
           end
         end
         
         if (movU==0 || movU1==0 || movU2==0 || movU3==0 || movU4==0  )  
         elseif ( movU < movU1 &&  movU1 < movU2 &&  movU2 < movU3 &&  movU3 < movU4 )
           if (predict(2,i)-movU2 > 70)
                 disp('Down');
                 robot.keyPress(java.awt.event.KeyEvent.VK_SPACE);
                  robot.keyRelease(java.awt.event.KeyEvent.VK_SPACE);
                 predict = zeros(2,30);
           continue;
           end
         end
         
         
    
    
    
end
release(vidDevice);
clear vidDevice;