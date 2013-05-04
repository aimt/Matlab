vid = videoinput('winvideo', 1,'MJPG_160x120');
set(vid,'TriggerRepeat',Inf);
vid.FrameGrabInterval = 2;
vid_src = getselectedsource(vid);
ScreenSize=get(0,'ScreenSize');
start(vid);
while(vid.FramesAcquired<=300)
    img = getsnapshot(vid);
    imSize = size(img);
    img3 =getsnapshot(vid);
    img4 = zeros(imSize(1),imSize(2));
    
%     for x = 1:imSize(1)
%        for y= 1: imSize(2)
%            if(img(x,y,1)> 80 && img(x,y,1)< 190 && img(x,y,2)> 60 && img(x,y,2)<140 && img(x,y,3)> 50 && img(x,y,3)<100)
%             img4(x,imSize(2)-y+1) = bitxor(img(x,imSize(2)-y+1,1),img3(x,imSize(2)-y+1,1));
%             %img4(x,imSize(2)-y+1)=img(x,imSize(2)-y+1,1);
%            end
%        end
%     end
%     
%     
        
    for x = 1:imSize(1)
       for y= 1: imSize(2)
           if(img(x,y,1)> 20 && img(x,y,1)< 190 && img(x,y,2)> 20 && img(x,y,2)<140 && img(x,y,3)> 20 && img(x,y,3)<100)
            img4(x,imSize(2)-y+1) = bitxor(img(x,imSize(2)-y+1,1),img3(x,imSize(2)-y+1,1));
%            img4(x,imSize(2)-y+1)=img(x,imSize(2)-y+1,1);
           end
       end
    end
    
    
    
     img4=bwareaopen(img4,500);

    imgZoomed = zeros(imSize(1)*2+2,imSize(2)*2+2);
 for x = 1:imSize(1)
          for y= 1: imSize(2)
                imgZoomed(2*x-1,2*y-1) = img4(x,y);
                imgZoomed(2*x,2*y) = img4(x,y);
                imgZoomed(2*x-1,2*y) = img4(x,y);
                imgZoomed(2*x,2*y-1) = img4(x,y);

          end
 end   
imgZoomed = imfill(imgZoomed,'holes');
imgZoomed= imfill(imgZoomed);

  s  = regionprops(imgZoomed, 'centroid');
   centroids = cat(1, s.Centroid);


imshow(imgZoomed);
     hold on;
     szCen = size(centroids);
     if(szCen(1) ==1)
         plot(centroids(:,1), centroids(:,2), 'r*');
          
           
          set(0,'PointerLocation',[centroids(1)*ScreenSize(3)/320,ScreenSize(4)-centroids(2)*ScreenSize(4)/240]);

     end
   hold off;
 
    img = zeros(imSize(1),imSize(2));
    
   % img2 = zeros(imSize(1),imSize(2));
    img3 = zeros(imSize(1),imSize(2));
    img4 = zeros(imSize(1),imSize(2));
end;
stop(vid);
delete(vid)
clear vid
clear all