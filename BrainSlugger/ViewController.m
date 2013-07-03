#import "ViewController.h"
#import "DetectFace.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController () <DetectFaceDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) DetectFace *detectFaceController;

@property (nonatomic, strong) UIImageView *slugImgView;
@property (nonatomic, strong) UIImageView *droolImgView; //TODO

@property (nonatomic, strong) UIButton *saveButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.detectFaceController = [[DetectFace alloc] init];
    self.detectFaceController.delegate = self;
    self.detectFaceController.previewView = self.previewView;
    [self.detectFaceController startDetection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillUnload
{
    [self.detectFaceController stopDetection];
    [super viewWillUnload];
}

- (void)viewDidUnload {
    [self setPreviewView:nil];
    [super viewDidUnload];
}

- (void)detectedFaceController:(DetectFace *)controller features:(NSArray *)featuresArray forVideoBox:(CGRect)clap withPreviewBox:(CGRect)previewBox
{
    
    if (!self.slugImgView) {
        self.slugImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"brainslug-transparent"]];
        self.slugImgView.contentMode = UIViewContentModeScaleToFill;
        [self.previewView addSubview:self.slugImgView];
    }
    
    for (CIFaceFeature *ff in featuresArray) {
        // find the correct position for the square layer within the previewLayer
        // the feature box originates in the bottom left of the video frame.
        // (Bottom right if mirroring is turned on)
        CGRect faceRect = [ff bounds];
        
        //isMirrored because we are using front camera
        faceRect = [DetectFace convertFrame:faceRect previewBox:previewBox forVideoBox:clap isMirrored:YES];
        
        float hat_width = 128.0;
        float hat_height = 128.0;
        float head_start_y = 120.0;
        float head_start_x = 30.0;
        
        //float width = faceRect.size.width * (hat_width / (hat_width - head_start_x));
        //float height = width * hat_height/hat_width;
        float width = faceRect.size.width * 0.5;
        float height = width;
        float y = faceRect.origin.y - (height * head_start_y) / hat_height;
        float x = faceRect.origin.x - (head_start_x * width/hat_width);
        [self.slugImgView setFrame:CGRectMake(x, y, width, height)];

        
        //TODO: include an "add drool" button
        
        //TODO: removing for now, not doing the right thing
        /* 
        if (!self.saveButton) {
            self.saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            self.saveButton.frame = CGRectMake(((self.view.frame.size.width / 2.0) + 50), (self.view.frame.size.height - 100), 100, 30); //x, y, width, height
            [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
            //[self.saveButton setReversesTitleShadowWhenHighlighted:YES];
            [self.saveButton setShowsTouchWhenHighlighted:YES];
            [self.saveButton addTarget:self action:@selector(savePressed) forControlEvents:UIControlEventTouchUpInside];
            [self.previewView addSubview:self.saveButton];
        }
         */
       
    }
}


-(UIImage*) makeImage {
    UIGraphicsBeginImageContextWithOptions(self.previewView.bounds.size, YES, 0.0);
    [self.previewView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
}


-(void)savePressed {
    //TODO: write a success of failure message: http://stackoverflow.com/questions/7628048/ios-uiimagewritetosavedphotosalbum
    UIImageWriteToSavedPhotosAlbum([self makeImage], nil, nil, nil);
}



@end
