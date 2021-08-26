//
//  SummerToolViewModel.h
//  Summer
//
//  Created by JinglongBi on 2018/7/13.
//  Copyright © 2018年 jinglongbi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SummerToolViewModel : NSObject

@property (nonatomic, strong) NSMutableArray *stringPathArr;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *stringDictArr;

@property (nonatomic, strong) NSString *selectCSVFilePath;

- (void)csvFileToStringBtnClicked;
- (void)toCSVFileBtnClicked;

@end
