//
//  SummerToolViewModel.m
//  Summer
//
//  Created by JinglongBi on 2018/7/13.
//  Copyright © 2018年 jinglongbi. All rights reserved.
//

#import "SummerToolViewModel.h"
#import <Appkit/AppKit.h>
#import "CHCSVParser.h"

#define kDefaultLanguageCapacity             10
#define kDefaultTranslationStrCapacity      300

@interface SummerToolViewModel () <CHCSVParserDelegate>

@property (nonatomic, strong) CHCSVParser *csvParser;
@property (nonatomic, strong) CHCSVWriter *csvWriter;
@property (nonatomic, strong) NSString *currentLineFirstValue;

@end

@implementation SummerToolViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.stringPathArr = [[NSMutableArray alloc] initWithCapacity:kDefaultLanguageCapacity];
        self.stringDictArr = [[NSMutableArray alloc] initWithCapacity:kDefaultLanguageCapacity];
        self.currentLineFirstValue = @"";
    }
    return self;
}

#pragma mark - Btn Actions

- (NSString *)selectCSVFilePath {
    NSString *tempFilePath = @"";
    if (self.stringPathArr.count > 0) {
        NSString *selectFilePath = self.stringPathArr.firstObject;
        NSRange range = [selectFilePath rangeOfString:@".csv"];
        if (range.location + range.length == selectFilePath.length) {
            tempFilePath = selectFilePath;
        }
    }
    return tempFilePath;
}

- (void)toCSVFileBtnClicked {
    // read StringFiles To DictArr
    if (self.stringPathArr.count == 0) {
        return;
    }
    [self.stringDictArr removeAllObjects];
    for (NSString *currentPath in self.stringPathArr) {
        NSMutableDictionary *tempMapDict = [NSMutableDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:currentPath]];
        [self.stringDictArr addObject:tempMapDict];
    }
    // Write data to the output CSV file
    NSString *csvFileName = [NSString stringWithFormat:@"%@_%@.csv", @"Translation", [self currentTimeStr]];
    NSString *csvSavePath = [[self destinationDirPath] stringByAppendingPathComponent:csvFileName];
    [self checkExistAndCreateDestinationDir];
    
    self.csvWriter = [[CHCSVWriter alloc] initForWritingToCSVFile:csvSavePath];
    for (NSString *currentKey in self.stringDictArr.firstObject.allKeys) {
        NSMutableArray *stringsInLine = [[NSMutableArray alloc] initWithCapacity:10];
        [stringsInLine addObject:currentKey];
        for (NSDictionary *currentDict in self.stringDictArr) {
            if ([currentDict.allKeys containsObject:currentKey]) {
                [stringsInLine addObject:currentDict[currentKey]];
            }
        }
        [self.csvWriter writeLineOfFields:stringsInLine];
        [stringsInLine removeAllObjects];
    }
    // Open destination dir
    [self openDestinationDir];
}

- (void)csvFileToStringBtnClicked {
    if (self.selectCSVFilePath.length == 0) {
        return;
    }
    
    NSURL *fileUrl = [NSURL URLWithString:self.selectCSVFilePath];
    self.csvParser = [[CHCSVParser alloc] initWithContentsOfCSVURL:fileUrl];
    self.csvParser.delegate = self;
    [self.stringDictArr removeAllObjects];
    [self.csvParser parse];
}

#pragma mark - CHCSVParserDelegate

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    if (fieldIndex > self.stringDictArr.count) {
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithCapacity:kDefaultTranslationStrCapacity];
        [self.stringDictArr addObject:tempDict];
    }
    // Store the first value in each line of the csv file.This value is the key.
    if (0 == fieldIndex) {
        self.currentLineFirstValue = field;
    } else if (fieldIndex - 1 >= 0 && self.stringDictArr.count > fieldIndex - 1) {
        NSMutableDictionary *currentDict = self.stringDictArr[fieldIndex - 1];
        [currentDict setValue:field forKey:self.currentLineFirstValue];
    }
}

- (void)parserDidEndDocument:(CHCSVParser *)parser {
    // CSV文件解析完毕后 依次创建各个语言的翻译文件
    [self checkExistAndCreateDestinationDir];
    NSUInteger currentFileIndex = 0;
    for (NSMutableDictionary *currentDict in self.stringDictArr) {
        NSString *strFileName = [NSString stringWithFormat:@"Localizable_%@_%@.strings", [self currentTimeStr], @(currentFileIndex)];
        NSString *strFilePath = [[self destinationDirPath] stringByAppendingPathComponent:strFileName];
        CHCSVWriter *fileWriter = [[CHCSVWriter alloc] initForWritingToCSVFile:strFilePath];
        for (NSString *currentKey in currentDict.allKeys) {
            NSString *tempStr = [NSString stringWithFormat:@"%@ = %@;", [self formatStrWithDoubleQuotes:currentKey], [self formatStrWithDoubleQuotes:currentDict[currentKey]]];
            [fileWriter _writeString:tempStr];
            [fileWriter finishLine];
        }
        currentFileIndex++;
    }
    
    [self openDestinationDir];
}

#pragma mark - Helper

- (NSString *)formatStrWithDoubleQuotes:(NSString *)sourceStr {
    if (([sourceStr hasPrefix:@"\""] && [sourceStr hasSuffix:@"\""])) {
        return sourceStr;
    } else {
        return [NSString stringWithFormat:@"\"%@\"", sourceStr];
    }
}

- (void)openDestinationDir {
    NSURL *folderURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", [self destinationDirPath]]];
    [[NSWorkspace sharedWorkspace] openURL:folderURL];
}

- (NSString *)destinationDirPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Summer_Output"];
}

- (void)checkExistAndCreateDestinationDir {
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self destinationDirPath]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[self destinationDirPath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSString *)currentTimeStr {
    // 获取系统当前时间
    NSDate *date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate *currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
    
    //设置时间输出格式：
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd_HHmmss"];
    NSString *tempStr = [dateFormatter stringFromDate:currentDate];
    return tempStr;
}

@end
