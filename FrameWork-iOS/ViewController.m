//
//  ViewController.m
//  FrameWork-iOS
//
//  Created by Mao on 11/5/14.
//  Copyright (c) 2014 Mao. All rights reserved.
//

#import "ViewController.h"
#import <YFAudio/YFAudioPlayer.h>
#import <YFAudio/YFAudioRecorder.h>

@interface ViewController ()<YFAudioRecorderDelegate, YFAudioPlayerDelegate>
@property(nonatomic, strong)NSString* voiceFileName;
@end

@implementation ViewController

- (void)viewDidLoad {
	self.title = @"FrameWork Maker";
	self.view.backgroundColor = [UIColor whiteColor];
	[super viewDidLoad];
	
	
#pragma mark Test YFAudio FrameWork Works
	UIButton* startRecordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	startRecordButton.frame = CGRectMake(100, 100, 100, 50);
	[startRecordButton setTitle:@"StartRecord" forState:UIControlStateNormal];
	[startRecordButton addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:startRecordButton];
	
	UIButton* stopRecordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	stopRecordButton.frame = CGRectMake(100, 200, 100, 50);
	[stopRecordButton setTitle:@"StopRecord" forState:UIControlStateNormal];
	[stopRecordButton addTarget:self action:@selector(stopRecord) forControlEvents:
	 UIControlEventTouchUpInside];
	[self.view addSubview:stopRecordButton];
	

	UIButton* playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	playButton.frame = CGRectMake(100, 300, 100, 50);
	[playButton setTitle:@"Play" forState:UIControlStateNormal];
	[playButton addTarget:self action:@selector(doPlay) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:playButton];
	
	[YFAudioRecorder setMaxVoiceLength:60];
	[YFAudioRecorder setMinVoiceLength:1];
#pragma mark ========================================
}


#pragma mark Test YFAudio FrameWork Works

- (void)stopRecord
{
	YFAudioRecorder* recorder = [YFAudioRecorder shareRecorder];
	[recorder stopRecord];
}


- (void)startRecord
{
	YFAudioRecorder* recorder = [YFAudioRecorder shareRecorder];
	recorder.delegate = self;
	[recorder checkRecordAvailableBlock:^(BOOL available) {
		if (available)
		{
			[YFAudioRecorder shareRecorder].isSpeakerMode = YES;
			[[YFAudioRecorder shareRecorder] startRecord];
			NSLog(@"%s", __func__);
		}
		else
		{
			NSString* appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
			NSString* message = [NSString stringWithFormat:@"请在“设置-隐私-麦克风”选项中允许%@访问你的麦克风", appName];
			[[[UIAlertView alloc] initWithTitle:@"无法录音" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
		}
	}];
}


- (void)doPlay
{
	NSString* filePath = [self cachePathForMedia:self.voiceFileName];
//	BOOL isSpeakerMode = [MISSetting sharedSetting].isSpeakerMode;
	
	[[YFAudioPlayer sharePlayer] startPlayAudioWithPath:filePath delegate:self isSpeakerMode:YES];
}


#pragma mark ====YFAudioRecorderDelegate=====

- (void)didStartRecord
{
	NSLog(@"%s", __func__);
}
- (void)didRecordFailedWithError:(RecorderError )error
{
	NSLog(@"%s, %@", __func__, @(error));
}

- (void)didRecordFinishedWithFilePath:(NSString *)filePath length:(NSInteger)length
{
//	int maxLength = [YFAudioRecorder maxVoiceLength];
	self.voiceFileName = [self fileNameByPath:filePath];
	NSLog(@"%s, %@", __func__, @(length));
}
- (void)didCancelRecord
{
	NSLog(@"%s", __func__);
}

- (void)didRecordingWithMeters:(float)meters
{
	NSLog(@"%s, %@", __func__, @(meters));
}

- (void)didRecordingWithLength:(NSInteger)length
{
	NSLog(@"%s, %@", __func__, @(length));
}


- (NSString *)fileNameByPath:(NSString *)path
{
	NSString* result = path;
	
	//找不到"/"
	NSRange range = [path rangeOfString:@"/"];
	if (range.length == 0)
	{
		return result;
	}
	
	do {
		result = [result substringFromIndex:range.location + 1];
		range = [result rangeOfString:@"/"];
		
	} while (range.length > 0);
	
	return result;
}


- (NSString *)documentfilePath:(NSString *) fileName{
	if(fileName == nil)
		return nil;
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentsDirectory = [paths objectAtIndex: 0];
	NSString* documentsPath = [documentsDirectory stringByAppendingPathComponent: fileName];
	
	return documentsPath;
}

- (NSString *)cachePathForMedia:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Cache"];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath])
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
								  withIntermediateDirectories:YES
												   attributes:nil
														error:NULL];
	}
	
	//only filename filter path or url
	NSString *filename_ = fileName;
	NSRange range = [filename_ rangeOfString:@"/"];
	
	while (range.length > 0)
	{
		filename_ = [filename_ substringFromIndex:range.location + 1];
		range = [filename_ rangeOfString:@"/"];
	}
	
	return [diskCachePath stringByAppendingPathComponent:filename_];
}

#pragma mark Test YFAudio FrameWork Works end================


@end
