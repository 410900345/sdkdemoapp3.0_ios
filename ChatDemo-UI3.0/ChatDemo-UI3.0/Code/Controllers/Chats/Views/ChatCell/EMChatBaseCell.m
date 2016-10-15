//
//  EMChatBaseCell.m
//  ChatDemo-UI3.0
//
//  Created by EaseMob on 16/9/27.
//  Copyright © 2016年 easemob. All rights reserved.
//

#import "EMChatBaseCell.h"

#import "EMChatBaseBubbleView.h"
#import "EMChatTextBubbleView.h"
#import "EMChatImageBubbleView.h"
#import "EMChatAudioBubbleView.h"
#import "EMChatVideoBubbleView.h"
#import "EMChatLocationBubbleView.h"

#define HEAD_PADDING 15.f
#define TIME_PADDING 45.f
#define BOTTOM_PADDING 16.f

#define kColorOrangeRed RGBACOLOR(255, 59, 58, 1)
#define kColorKermitGreenTwo RGBACOLOR(72, 184, 0, 1)

@interface EMChatBaseCell () <EMChatBaseBubbleViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *readLabel;
@property (weak, nonatomic) IBOutlet UILabel *notDeliveredLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkView;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (strong, nonatomic) EMChatBaseBubbleView *bubbleView;

@property (strong, nonatomic) EMMessage *message;

- (IBAction)didResendButtonPressed:(id)sender;

@end

@implementation EMChatBaseCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithMessage:(EMMessage*)message
{
    self = (EMChatBaseCell*)[[[NSBundle mainBundle]loadNibNamed:@"EMChatBaseCell" owner:nil options:nil] firstObject];
    if (self) {
        [self _setupBubbleView:message];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didHeadImageSelected:)];
        self.headImageView.userInteractionEnabled = YES;
        [self.headImageView addGestureRecognizer:tap];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _headImageView.left = _message.direction == EMMessageDirectionSend ? (self.width - _headImageView.width - HEAD_PADDING) : HEAD_PADDING;
    
    _timeLabel.left = _message.direction == EMMessageDirectionSend ? (self.width - _timeLabel.width - TIME_PADDING) : TIME_PADDING;
    _timeLabel.top = self.height - BOTTOM_PADDING;
    _timeLabel.textAlignment = _message.direction == EMMessageDirectionSend ? NSTextAlignmentRight : NSTextAlignmentLeft;
    
    _bubbleView.left = _message.direction == EMMessageDirectionSend ? (self.width - _bubbleView.width - TIME_PADDING) : TIME_PADDING;
    _bubbleView.top = 5;
    
    _readLabel.top = self.height - BOTTOM_PADDING;
    _checkView.top = self.height - BOTTOM_PADDING;
    _resendButton.top = _bubbleView.top + (_bubbleView.height - _resendButton.height)/2;
    _resendButton.left = _bubbleView.left - 25.f;
    _activityView.top = _bubbleView.top + (_bubbleView.height - _resendButton.height)/2;
    _activityView.left = _bubbleView.left - 25.f;
    _notDeliveredLabel.top = self.height - BOTTOM_PADDING;
    _notDeliveredLabel.left = self.width - _notDeliveredLabel.width - 15.f;
    
    [self _setViewsDisplay];
}

#pragma mark - EMChatBaseBubbleViewDelegate

- (void)didBubbleViewPressed:(EMMessage *)message
{
    if (self.delegate) {
        switch (message.body.type) {
            case EMMessageBodyTypeText:
                if ([self.delegate respondsToSelector:@selector(didTextCellPressed:)]) {
                    [self.delegate didTextCellPressed:message];
                }
                break;
            case EMMessageBodyTypeImage:
                if ([self.delegate respondsToSelector:@selector(didImageCellPressed:)]) {
                    [self.delegate didImageCellPressed:message];
                }
                break;
            case EMMessageBodyTypeVoice:
                if ([self.delegate respondsToSelector:@selector(didAudioCellPressed:)]) {
                    [self.delegate didAudioCellPressed:message];
                }
                break;
            case EMMessageBodyTypeVideo:
                if ([self.delegate respondsToSelector:@selector(didVideoCellPressed:)]) {
                    [self.delegate didVideoCellPressed:message];
                }
                break;
            case EMMessageBodyTypeLocation:
                if ([self.delegate respondsToSelector:@selector(didLocationCellPressed:)]) {
                    [self.delegate didLocationCellPressed:message];
                }
                break;
            default:
                break;
        }
    }
}

- (void)didBubbleViewLongPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCellLongPressed:)]) {
        [self.delegate didCellLongPressed:self];
    }
}

#pragma mark - action

- (void)didHeadImageSelected:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didHeadImagePressed:)]) {
        [self.delegate didHeadImagePressed:self.message];
    }
}

- (IBAction)didResendButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didResendButtonPressed:)]) {
        [self.delegate didResendButtonPressed:self.message];
    }
}

#pragma mark - private

- (void)_setupBubbleView:(EMMessage*)message
{
    _message = message;
    switch (message.body.type) {
        case EMMessageBodyTypeText:
            _bubbleView = [[EMChatTextBubbleView alloc] init];
            break;
        case EMMessageBodyTypeImage:
            _bubbleView = [[EMChatImageBubbleView alloc] init];
            break;
        case EMMessageBodyTypeVoice:
            _bubbleView = [[EMChatAudioBubbleView alloc] init];
            break;
        case EMMessageBodyTypeVideo:
            _bubbleView = [[EMChatVideoBubbleView alloc] init];
            break;
        case EMMessageBodyTypeLocation:
            _bubbleView = [[EMChatLocationBubbleView alloc] init];
            break;
        default:
            _bubbleView = [[EMChatTextBubbleView alloc] init];
            break;
    }
    _bubbleView.delegate = self;
    [self.contentView addSubview:_bubbleView];
}

- (NSString *)_getMessageTime:(EMMessage*)message
{
    NSString *messageTime = @"";
    if (message) {
        double timeInterval = message.timestamp ;
        if(timeInterval > 140000000000) {
            timeInterval = timeInterval / 1000;
        }
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"aa HH:mm"];
        messageTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    }
    return messageTime;
}

- (void)_setViewsDisplay
{
    _timeLabel.hidden = NO;
    if (_message.direction == EMMessageDirectionSend) {
        if (_message.status == EMMessageStatusFailed || _message.status == EMMessageStatusPending) {
            _notDeliveredLabel.text = NSLocalizedString(@"chat.not.delivered", @"Not Delivered");
            _checkView.hidden = YES;
            _readLabel.hidden = YES;
            _timeLabel.hidden = YES;
            _activityView.hidden = YES;
            _resendButton.hidden = NO;
            _notDeliveredLabel.hidden = NO;
            
        } else if (_message.status == EMMessageStatusSuccessed) {
            if (_message.isReadAcked) {
                _readLabel.text = NSLocalizedString(@"chat.read", @"Read");
                _checkView.hidden = NO;
            } else {
                _readLabel.text = NSLocalizedString(@"chat.sent", @"Sent");
                _checkView.hidden = YES;
            }
            _resendButton.hidden = YES;
            _notDeliveredLabel.hidden = YES;
            _activityView.hidden = YES;
            _readLabel.hidden = NO;
        } else if (_message.status == EMMessageStatusDelivering) {
            _activityView.hidden = YES;
            _readLabel.hidden = YES;
            _checkView.hidden = YES;
            _resendButton.hidden = YES;
            _notDeliveredLabel.hidden = YES;
            _activityView.hidden = NO;
            [_activityView startAnimating];
        }
    } else {
        _activityView.hidden = YES;
        _readLabel.hidden = YES;
        _checkView.hidden = YES;
        _resendButton.hidden = YES;
        _notDeliveredLabel.hidden = YES;
    }
}

#pragma mark - public

- (void)setMessage:(EMMessage*)message
{
    _message = message;
    
    [_bubbleView setMessage:message];
    [_bubbleView sizeToFit];
    
    _headImageView.image = [UIImage imageNamed:@"Button_Join"];
    _timeLabel.text = [self _getMessageTime:message];
}

+ (CGFloat)heightForMessage:(EMMessage*)message
{
    CGFloat height = 100.f;
    switch (message.body.type) {
        case EMMessageBodyTypeText:
            height = [EMChatTextBubbleView heightForBubbleWithMessage:message] + 26.f;
            break;
        case EMMessageBodyTypeImage:
            height = [EMChatImageBubbleView heightForBubbleWithMessage:message] + 26.f;
            break;
        case EMMessageBodyTypeLocation:
            height = [EMChatLocationBubbleView heightForBubbleWithMessage:message] + 26.f;
            break;
        case EMMessageBodyTypeVoice:
            height = [EMChatAudioBubbleView heightForBubbleWithMessage:message] + 26.f;
            break;
        case EMMessageBodyTypeVideo:
            height = [EMChatVideoBubbleView heightForBubbleWithMessage:message] + 26.f;
            break;
        default:
            break;
    }
    return height;
}

+ (NSString *)cellIdentifierForMessage:(EMMessage *)message
{
    NSString *identifier = @"MessageCell";
    if (message.direction == EMMessageDirectionSend) {
        identifier = [identifier stringByAppendingString:@"Sender"];
    }
    else{
        identifier = [identifier stringByAppendingString:@"Receiver"];
    }
    
    switch (message.body.type) {
        case EMMessageBodyTypeText:
            identifier = [identifier stringByAppendingString:@"Text"];
            break;
        case EMMessageBodyTypeImage:
            identifier = [identifier stringByAppendingString:@"Image"];
            break;
        case EMMessageBodyTypeVoice:
            identifier = [identifier stringByAppendingString:@"Audio"];
            break;
        case EMMessageBodyTypeLocation:
            identifier = [identifier stringByAppendingString:@"Location"];
            break;
        case EMMessageBodyTypeVideo:
            identifier = [identifier stringByAppendingString:@"Video"];
            break;
        default:
            break;
    }
    
    return identifier;
}

@end
