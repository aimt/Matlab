vid = videoinput('winvideo', 1,'MJPG_320x240');
set(vid,'TriggerRepeat',Inf);
vid.FrameGrabInterval = 5;
vid_src = getselectedsource(vid);
start(vid);
while(vid.FramesAcquired<=100)
    img = getsnapshot(vid);
    imSize = size(img);
    k=1;
    k= mod(k+5,25)+1;
    img2 = zeros(imSize(1),imSize(2),3,'uint8');
    for x = 1:imSize(1)
       for y= 1: imSize(2)
     %      if(img(x,y,1)> 80 && img(x,y,1)< 190 && img(x,y,2)> 60 && img(x,y,2)<140 && img(x,y,3)> 50 && img(x,y,3)<100)
                img2(x,imSize(2)-y+1,1)=img(x,int32(y/k)+1,1);
                img2(x,imSize(2)-y+1,2)=img(x,int32(y/k)+1,2);
                img2(x,imSize(2)-y+1,3)=img(x,int32(y/k)+1,3);
     %      end
       end
    end
    
    imshow(img2);
end;

stop(vid);
delete(vid)
clear vid
clear all