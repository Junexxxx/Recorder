//
//  AudioTool.m
//  recorder
//
//  Created by Zhang on 2021/1/29.
//

#import "AudioTool.h"
#import <AVFoundation/AVFoundation.h>
#import "RecorderModel.h"

@interface AudioTool ()

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation AudioTool

+ (instancetype)tool {
    static AudioTool *tool;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        tool = [[self.class alloc] init];
    });
    return tool;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [AVAudioSession.sharedInstance setActive:YES error:nil];
    }
    return self;
}

- (void)authorization {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                                     completionHandler:^(BOOL granted) {}];
    }
}

- (void)startRecorderWithModel:(RecorderModel *)model {
    [self stopRecorder];
    if (!model) return;
    //
    NSURL *url = [NSURL URLWithString:model.recorderPath];
    NSDictionary *settings = @{AVEncoderAudioQualityKey : [NSNumber numberWithInteger:AVAudioQualityLow],
                               AVEncoderBitRateKey : [NSNumber numberWithInteger:16],
                               AVSampleRateKey : [NSNumber numberWithFloat:8000],
                               AVNumberOfChannelsKey : [NSNumber numberWithInteger:2]};
    NSError *error;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if (!error) {
        _audioRecorder.meteringEnabled = YES;
        if ([_audioRecorder prepareToRecord]) {
            [_audioRecorder record];
        }
    }
}

- (void)stopRecorder {
    if (_audioRecorder) {
        [_audioRecorder stop];
        _audioRecorder = nil;
    }
}

- (void)startPlayWithModel:(RecorderModel *)model {
    [self stopPlay];
    if (!model) return;
    //
    NSURL *url = [NSURL URLWithString:model.recorderPath];
    NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    _audioPlayer.numberOfLoops = 0;
    _audioPlayer.volume = 1.0;
    if (!error) {
        if ([_audioPlayer prepareToPlay]) {
            [_audioPlayer play];
        }
    }
}

- (void)stopPlay {
    if (_audioPlayer) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
}

@end
