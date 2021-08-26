//
//  ViewController.m
//  Summer
//
//  Created by JinglongBi on 2018/7/12.
//  Copyright © 2018年 jinglongbi. All rights reserved.
//

#import "ViewController.h"
#import "SummerToolViewModel.h"

static NSString *const kStringFileName = @"Localizable.strings";

@interface ViewController ()<NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSButtonCell *selectCSVFileBtn;
@property (weak) IBOutlet NSButtonCell *csvFileToStringBtn;
@property (weak) IBOutlet NSButtonCell *selectAssertDirBtn;
@property (weak) IBOutlet NSButtonCell *toCSVFileBtn;
@property (weak) IBOutlet NSTableView *tableView;

@property (strong) SummerToolViewModel *viewModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [SummerToolViewModel new];
    // Do any additional setup after loading the view.
    [self.selectCSVFileBtn setAction:@selector(selectCSVFileBtnClicked:)];
    [self.csvFileToStringBtn setAction:@selector(csvFileToStringBtnClicked:)];
    [self.selectAssertDirBtn setAction:@selector(selectAssertDirBtnClicked:)];
    [self.toCSVFileBtn setAction:@selector(toCSVFileBtnClicked:)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - Btn Actions

- (void)selectCSVFileBtnClicked:(NSButtonCell *)btn {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.allowsMultipleSelection = NO;
    openPanel.allowedFileTypes = [NSArray arrayWithObjects: @"csv", nil];
    openPanel.directoryURL = nil;
    
    [openPanel beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            NSArray* urls = [openPanel URLs];
            [self.viewModel.stringPathArr removeAllObjects];
            
            for (NSURL *url in urls) {
                [self.viewModel.stringPathArr addObject:url.absoluteString];
            }
            // reload the tabelView
            [self.tableView reloadData];
        }
    }];
}

- (void)csvFileToStringBtnClicked:(NSButtonCell *)btn {
    [self.viewModel csvFileToStringBtnClicked];
}

- (void)selectAssertDirBtnClicked:(NSButtonCell *)btn {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = YES;
    openPanel.allowsMultipleSelection = YES;
    openPanel.allowedFileTypes = [NSArray arrayWithObjects: @"lproj", nil];
    
    [openPanel beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:^(NSModalResponse returnCode){
        if (returnCode == NSModalResponseOK) {
            NSArray* urls = [openPanel URLs];
            [self.viewModel.stringPathArr removeAllObjects];
            
            for (NSURL *url in urls) {
                NSString *stringFilePath = [url.absoluteString stringByAppendingString:kStringFileName];
                [self.viewModel.stringPathArr addObject:stringFilePath];
            }
            // reload the tabelView
            [self.tableView reloadData];
        }
    }];
}

- (void)toCSVFileBtnClicked:(NSButtonCell *)btn {
    [self.viewModel toCSVFileBtnClicked];
}

#pragma mark - NSTableViewDelegate & NSTableViewDataSource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.viewModel.stringPathArr.count;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    NSView *cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if (tableColumn == tableView.tableColumns[0]) {
        ((NSTableCellView *) cell).textField.stringValue = [NSString stringWithFormat:@"%ld", (long)(row + 1)];
    } else if (row < self.viewModel.stringPathArr.count) {
        ((NSTableCellView *) cell).textField.stringValue = self.viewModel.stringPathArr[row];
    }
    
    return cell;
}

@end
