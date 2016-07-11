//
//  ToastView.m
//  AirMap
//
//  Created by Mijeong Jeon on 7/6/16.
//  Copyright © 2016 FCSProjectAirMap. All rights reserved.
//

#import "ToastView.h"

@interface ToastView ()

@property (weak, nonatomic) UILabel *toastTextLabel;

@end

@implementation ToastView

const CGFloat margin = 5.0;
const CGFloat duration = 4.0;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

// 텍스트 라벨 설정
- (UILabel *)textLabel {
    
        if (!self.toastTextLabel) {
            UILabel *toastTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin, self.frame.size.width-2*margin, self.frame.size.height - 2 * margin)];
            toastTextLabel.alpha = 1.0f;
            toastTextLabel.backgroundColor = [UIColor clearColor];
            toastTextLabel.textColor = [UIColor whiteColor];
            toastTextLabel.textAlignment = NSTextAlignmentCenter;
            toastTextLabel.numberOfLines = 0;
            toastTextLabel.font = [UIFont boldSystemFontOfSize:14.0];
            toastTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
            toastTextLabel.userInteractionEnabled = false;
            self.toastTextLabel = toastTextLabel;
            [self addSubview:toastTextLabel];
            
        }

    return self.toastTextLabel;

}

// 화면에 토스트 메세지 띄우기
+ (void)showToastInView:(UIView *)view withMessege:(NSString *)messege {
    
    CGRect parentFrame = view.bounds;
    CGRect toastFrame = CGRectMake(margin, parentFrame.size.height - 25 * margin, parentFrame.size.width - 2 * margin, 50);
    
    ToastView *toast = [[ToastView alloc] initWithFrame:toastFrame];
    
    toast.backgroundColor = [UIColor blackColor];
    toast.alpha = 0.0f;
    toast.layer.cornerRadius = 20.0;
    toast.textLabel.text = messege;
    
    [view addSubview:toast];
    
    // 나타나는 애니메이션 설정
    [UIView animateWithDuration:0.5
                     animations:^{
                         toast.alpha = 0.8f;
                         toast.textLabel.alpha = 0.8f;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                         }
                     }];
    
    [toast performSelector:@selector(hideToastView) withObject:nil afterDelay:duration];
    
    // 터치시 셋팅으로 이동
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:toast action:@selector(moveToSetting:)];
    [toast addGestureRecognizer:tap];
}

// 사라지는 애니메이션
- (void)hideToastView {
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 0.0f;
                         self.textLabel.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

// 토스트 뷰 터치시 설정 화면으로 이동
- (void)moveToSetting:(id)sender {
    
    [[UIApplication sharedApplication]
     openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    
}

@end