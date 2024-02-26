function flickerRect = flickerRectLoc(window,rect,RelativePos)
% function provides location of box on screen used to activate photosensor
% on monitor. rect is a 1x4 vector providing coordinates of the top left
% and bottom right corners of the rectangle where the rectangle is
% positioned in the top left corner of the screen. Thus, rect=[0 0 x y]
% where x and y represent the width and height of the rectangle in number
% of pixels. RelativePos is a string telling desired location of the
% flicker rectangle. Options are
% 'TopLeft','TopRight','BottomLeft','BottomRight'.
rectWidth=rect(3)-rect(1);
rectHeight=rect(4)-rect(2);
[screenXpixels,screenYpixels]=Screen('WindowSize',window);
switch RelativePos
    case 'TopLeft'
        flickerRect = rect;
    case 'TopRight'
        flickerRect = [screenXpixels-rectWidth 0 screenXpixels rect(4)];
    case 'BottomLeft'
        flickerRect = [0 screenYpixels-rectHeight rect(3) screenYpixels];
    case 'BottomRight'
        flickerRect = [screenXpixels-rectWidth screenYpixels-rectHeight screenXpixels screenYpixels];
    case 'Centered'
        xRectCent=round((rect(3)-rect(1))/2);
        yRectCent=round((rect(4)-rect(2))/2);
        xPixCent=round(screenXpixels/2);
        yPixCent=round(screenYpixels/2);
        flickerRect = [xPixCent-xRectCent yPixCent-yRectCent xPixCent+xRectCent yPixCent+yRectCent];
end
end