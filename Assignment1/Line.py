# Class to help with adding lines to the video frame

import cv2

class Line:
    
    def __init__(self,  x1, y1, x2, y2):
        
        #require two points (in this case 2 pixel locations to create the line
        
        self.x1 = x1
        self.x2 = x2
        self.y1 = y1
        self.y2 = y2
        
        self.slope = self.compute_slope()
        
    def compute_slope(self):
        
        return (self.y2 - self.y1)/(self.x2 - self.x1)
    
    def set_pts(self, x1, y1, x2, y2 ):
        
        self.x1 = x1
        self.x2 = x2
        self.y1 = y1
        self.y2 = y2
        
    def lane_directionality(self):
        
        # Slope of the left lane ('1') line will be positive, whereas the right 
        # lane ('0') will be negative 

        if self.slope > 0:
            return 1
        else:
            return 0
        
    def draw_line(self, img):
        
        thickness = 15
        color = [0, 0, 255] # blue line
        cv2.line(img, (self.x1, self.y1), (self.x2, self.y2), color, thickness)