//
//  ViewController.m
//  SoundRec
//
//  Created by Catalin Stoica on 05/08/16.
//  Copyright © 2016 Cata. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
@import AudioToolbox;



@interface ViewController () {
  AVAudioRecorder* _audioRecorder;
  AVAudioPlayer* _audioPlayer;
  AVAudioSession* _session;
  NSData* _audioData;
}

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation ViewController

- (void)viewDidLoad {
  NSError* error;
  [super viewDidLoad];
  
  // Set the audio file
  NSArray *pathComponents = [NSArray arrayWithObjects:
                             [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                             @"MyAudioMemo.m4a",
                             nil];
  NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
  
  // Setup audio session
  _session = [AVAudioSession sharedInstance];
  [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
  
  // Define the recorder setting
  NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
  [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
  [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
  [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
  
  // Initiate and prepare the recorder
  _audioRecorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
  _audioRecorder.delegate = self;
  _audioRecorder.meteringEnabled = YES;
  [_audioRecorder prepareToRecord];

}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)stopButtonTapped:(id)sender {
  
  [_audioRecorder stop];
  [_session setActive:NO error:nil];
  
}

- (IBAction)recordButtonTapped:(id)sender {

  if (_audioPlayer.playing) {
    [_audioPlayer stop];
  }
  
  if (!_audioRecorder.recording) {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    
    // Start recording
    [_audioRecorder record];
    [_recordButton setTitle:@"Pause" forState:UIControlStateNormal];
    
  } else {
    
    // Pause recording
    [_audioRecorder pause];
    [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
  }
  
  [_stopButton setEnabled:YES];
  
}
- (IBAction)playButtonTapped:(id)sender {
  NSError* error;
  
  [_session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
  [_session setActive:YES error:nil];
  if (!_audioRecorder.recording){
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_audioRecorder.url error:nil];
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfURL:_audioRecorder.url] error:nil];
    [_audioPlayer setDelegate:self];
    [_audioPlayer setVolume:1.0];
    NSLog(@"Audio Data: %@", _audioPlayer.data);
    if(_audioPlayer.playing){
      [_audioPlayer stop];
      [_playButton setTitle:@"Play" forState:UIControlStateNormal];
    }else {
      [_audioPlayer play];
      [_playButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
  }
  
  
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
  [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
  [_stopButton setEnabled:NO];
  [_playButton setEnabled:YES];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
  [_recordButton setTitle:@"Record" forState:UIControlStateNormal];
  [_stopButton setEnabled:NO];
  [_playButton setTitle:@"Play" forState:UIControlStateNormal];
}

@end
