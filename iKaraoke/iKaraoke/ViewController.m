//
//  ViewController.m
//  iKaraoke
//
//  Created by Rajesh on 9/16/16.
//  Copyright © 2016 org. All rights reserved.
//

#import "ViewController.h"
#import "YTPlayerView.h"
#import <AVFoundation/AVFoundation.h>

typedef enum {
    kVidPlay,
    kVidPause,
    kVidStop,
    kRecord,
    kRecordPause,
    kRecordStop,
}ButtonType;

@interface ViewController () <AVAudioRecorderDelegate>//,YTPlayerViewDelegate, AVAudioPlayerDelegate

@property(nonatomic, strong) IBOutlet YTPlayerView *playerView;
@property(nonatomic, strong) AVAudioRecorder *recorder;
@property(nonatomic, strong) AVAudioPlayer *player;
@property(nonatomic, strong) UIDocumentInteractionController * documentInteractionController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //https://www.youtube.com/watch?v=QRoS2QlxXog
    NSString *videoId = @"QRoS2QlxXog";
    NSDictionary *playerVars = @{
                                 @"controls" : @1,
                                 @"playsinline" : @1,
                                 @"autohide" : @1,
                                 @"showinfo" : @0,
                                 @"modestbranding" : @1,
                                 @"quality" : @"small"
                                 };
//    self.playerView.delegate = self;
    [_playerView loadWithVideoId:videoId playerVars:playerVars];

    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    [session requestRecordPermission:^(BOOL granted) {
        
    }];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    _recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)buttonAction:(UIButton *)sender {
    switch (sender.tag) {
        case kVidPlay :
            [_playerView playVideo];
            break;
        case kVidPause :
            [_playerView pauseVideo];
            break;
        case kVidStop :
            [_playerView stopVideo];
            break;
        case kRecord :
            [_recorder record];
            break;
        case kRecordPause :
            [_playerView pauseVideo];
            [_recorder pause];
            break;
        case kRecordStop :
            [_playerView stopVideo];
            [_recorder stop];
            break;
        default:
            break;
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (!recorder.recording){
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
//        [_player setDelegate:self];
        [_player play];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             _documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:recorder.url];
            [_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        });
    }
}

@end
