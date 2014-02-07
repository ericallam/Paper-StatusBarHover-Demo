//
//  ForegroundViewController.m
//  PaperOverStatusBar
//
//  Created by Eric Allam on 07/02/2014.
//
//

#import "ForegroundViewController.h"

@interface ForegroundViewController ()
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIAttachmentBehavior *panAttachment;
@end

@implementation ForegroundViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    CALayer *layer = self.view.layer;
    layer.cornerRadius = 5.0f;
    
    // Pan for a dismissal using UIKit Dynamics
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self.view addGestureRecognizer:panGesture];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view.superview];
}

- (void)didPan:(UIPanGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.view.superview];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            
            // Cleanup existing behaviors like the "snap" behavior when, after a pan starts, this view
            // gets snapped back into place
            [self.animator removeAllBehaviors];
            
            // Give the view some rotation
            UIDynamicItemBehavior *rotationBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.view]];
            rotationBehavior.allowsRotation = YES;
            rotationBehavior.angularResistance = 10.0f;
            
            [self.animator addBehavior:rotationBehavior];
            
            // Calculate the offset from the center of the view to use in the attachment behavior
            CGPoint viewCenter = self.view.center;
            UIOffset centerOffset = UIOffsetMake(location.x - viewCenter.x, location.y - viewCenter.y);
            
            // Attach to the location of the pan in the container view.
            self.panAttachment = [[UIAttachmentBehavior alloc] initWithItem:self.view
                                                           offsetFromCenter:centerOffset
                                                           attachedToAnchor:location];
            self.panAttachment.damping = 0.7f;
            self.panAttachment.length = 0;
            [self.animator addBehavior:self.panAttachment];
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            // Now when the finger moves around we just update the anchor point,
            // which will move the view around
            self.panAttachment.anchorPoint = location;
            
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            // Not enough velocity to exit the modal, so snap it back into the center of the screen
            [self.animator removeAllBehaviors];
            
            UISnapBehavior *snapIt = [[UISnapBehavior alloc] initWithItem:self.view snapToPoint:CGPointMake(160, 284)];
            snapIt.damping = 0.7;
            
            [self.animator addBehavior:snapIt];
            
            
            break;
        }
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
