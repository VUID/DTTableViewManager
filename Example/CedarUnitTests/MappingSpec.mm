#import "DTTableViewController.h"
#import "DTTableViewController+UnitTests.h"
#import <Foundation/Foundation.h>
#import "CellWithNib.h"
#import "CellWithoutNib.h"
#import "MockTableHeaderView.h"
#import "NiblessTableHeaderView.h"
#import "MockTableHeaderFooterView.h"
#import "NiblessTableHeaderFooterView.h"
#import "DTTableViewMemoryStorage.h"
#import "DTAbstractCellModel.h"
#import "CustomCell.h"
#import "DTDefaultCellModel.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(MappingSpecs)

describe(@"mapping tests", ^{
    
    __block DTTableViewController *model;
    __block DTTableViewMemoryStorage * storage;
    __block Example * testModel;
    __block Example * acc1;
    
    describe(@"cell mapping from code", ^{
        
        beforeEach(^{
            
            [UIView setAnimationsEnabled:NO];
            
            model = [DTTableViewController new];
            storage = [DTTableViewMemoryStorage storage];
            storage.loggingEnabled = NO;
            model.dataStorage = storage;
            model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
            model.tableView.dataSource = model;
            model.tableView.delegate = model;
            testModel = [Example new];
            acc1 = [Example new];
            [model.tableView reloadData];
            
            [model registerCellClass:[CellWithoutNib class]
                       forModelClass:[Example class]];
            
        });
        
        afterEach(^{
            [model release];
            [testModel release];
            
            [UIView setAnimationsEnabled:YES];
        });
        
        it(@"should create cell from code", ^{
            
            [storage addItem:acc1];
            
            [model verifyTableItem:acc1 atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            CellWithoutNib * cell = (CellWithoutNib *)[model.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            cell.awakedFromNib should_not be_truthy;
            cell.inittedWithStyle should be_truthy;
        });
        
        
    });
    
    describe(@"cell mapping from nib", ^{
        
        beforeEach(^{
            
            [UIView setAnimationsEnabled:NO];
            
            model = [DTTableViewController new];
            storage = [DTTableViewMemoryStorage storage];
            model.dataStorage = storage;
            model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
            model.tableView.delegate = model;
            model.tableView.dataSource = model;
            testModel = [Example new];
            acc1 = [Example new];
            
            [model.tableView reloadData];
            
            [model registerCellClass:[CellWithNib class]
                       forModelClass:[Example class]];
        });
        
        afterEach(^{
            [model release];
            [testModel release];
            
            [UIView setAnimationsEnabled:YES];
        });

        it(@"should create cell from nib", ^{
            
            [storage addItem:acc1];
            
            [model verifyTableItem:acc1 atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            CellWithNib * cell = (CellWithNib *)[model.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            cell.awakedFromNib should be_truthy;
            cell.inittedWithStyle should_not be_truthy;
        });
        
        
    });
    
    describe(@"cell mapping should throw an exception, if no nib found", ^{
        
        beforeEach(^{
            
            [UIView setAnimationsEnabled:NO];
            
            model = [DTTableViewController new];
            storage = [DTTableViewMemoryStorage storage];
            model.dataStorage = storage;
            model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
            model.tableView.delegate = model;
            model.tableView.dataSource = model;
            testModel = [Example new];
            
            [model.tableView reloadData];
        });
        
        afterEach(^{
            [model release];
            [testModel release];
            
            [UIView setAnimationsEnabled:YES];
        });
        
        it(@"should create cell from nib", ^{
            ^{
                [model registerNibNamed:@"NO-SUCH-NIB"
                           forCellClass:[ExampleCell class]
                             modelClass:[Example class]];
            } should raise_exception;
        });
    });
    
    describe(@"header/footer mapping", ^{
        
        beforeEach(^{
            
            [UIView setAnimationsEnabled:NO];
            
            model = [DTTableViewController new];
            model.sectionHeaderStyle = DTTableViewSectionStyleView;
            model.sectionFooterStyle = DTTableViewSectionStyleView;
            storage = [DTTableViewMemoryStorage storage];
            model.dataStorage = storage;
            model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
            model.tableView.delegate = model;
            model.tableView.dataSource = model;
            testModel = [Example new];
            
            [model.tableView reloadData];
        });
        
        afterEach(^{
            [model release];
            [testModel release];
            
            [UIView setAnimationsEnabled:YES];
        });
        
        it(@"should create header view from UIView", ^{
            [model registerHeaderClass:[MockTableHeaderView class]
                         forModelClass:[Example class]];
            
            [storage setSectionHeaderModels:@[[[Example new] autorelease]]];
            
            UIView * headerView = [model tableView:model.tableView viewForHeaderInSection:0];
            
            [headerView isKindOfClass:[MockTableHeaderView class]] should BeTruthy();
        });
        
        it(@"should create footer view from UIView", ^{
           [model registerFooterClass:[MockTableHeaderView class]
                        forModelClass:[Example class]];
            
           [storage setSectionFooterModels:@[[[Example new] autorelease]]];
            
            UIView * footerView = [model tableView:model.tableView viewForFooterInSection:0];
            
            [footerView isKindOfClass:[MockTableHeaderView class]] should BeTruthy();
        });
        
        it(@"should create header view from UITableViewHeaderFooterView", ^{
            if ([UITableViewHeaderFooterView class])
            {
                [model registerHeaderClass:[MockTableHeaderFooterView class]
                             forModelClass:[Example class]];
                
                [storage setSectionHeaderModels:@[[[Example new] autorelease]]];
                
                UIView * headerView = [model tableView:model.tableView viewForHeaderInSection:0];
                
                [headerView isKindOfClass:[MockTableHeaderFooterView class]] should BeTruthy();
            }
        });
        
        it(@"should create footer view from UITableViewHeaderFooterView", ^{
            
            if ([UITableViewHeaderFooterView class])
            {
                [model registerFooterClass:[MockTableHeaderFooterView class]
                             forModelClass:[Example class]];
                
                [storage setSectionFooterModels:@[[[Example new] autorelease]]];
                
                UIView * footerView = [model tableView:model.tableView viewForFooterInSection:0];
                
                [footerView isKindOfClass:[MockTableHeaderFooterView class]] should BeTruthy();
            }
        });
        
        it(@"should raise an exception when registering nibless header", ^{
           
            ^{
                [model registerHeaderClass:[NiblessTableHeaderView class]
                             forModelClass:[Example class]];
            } should raise_exception;
            
        });
        
        it(@"should raise an exception when registering nibless footer", ^{
            
            ^{
                [model registerFooterClass:[NiblessTableHeaderView class]
                             forModelClass:[Example class]];
            } should raise_exception;
            
        });
        
        it(@"should raise an exception when registering wrong nib for header", ^{
           
            ^{
                [model registerNibNamed:@"NO-SUCH-NIB"
                         forHeaderClass:[MockTableHeaderView class]
                             modelClass:[Example class]];
            } should raise_exception;
            
        });
        
        it(@"should raise an exception when registering wrong nib for footer", ^{
            ^{
                [model registerNibNamed:@"NO-SUCH-NIB"
                         forFooterClass:[MockTableHeaderView class]
                             modelClass:[Example class]];
            } should raise_exception;
        });
    });
    
});

describe(@"Foundation class clusters", ^{
    
    __block DTTableViewController *model;
    __block DTTableViewMemoryStorage * storage;
    
    beforeEach(^{
        
        [UIView setAnimationsEnabled:NO];
        
        model = [DTTableViewController new];
        model.sectionHeaderStyle = DTTableViewSectionStyleView;
        storage = [DTTableViewMemoryStorage storage];
        model.dataStorage = storage;
        model.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStylePlain];
        model.tableView.dataSource = model;
        model.tableView.delegate = model;
        [model.tableView reloadData];
    });
    
    afterEach(^{
        [model release];
        [UIView setAnimationsEnabled:YES];
    });
    
    describe(@"NSString", ^{
       
        beforeEach(^{
            [model registerCellClass:[CellWithNib class]
                       forModelClass:[NSString class]];
            [model registerHeaderClass:[MockTableHeaderView class]
                         forModelClass:[NSString class]];
            [model registerFooterClass:[MockTableHeaderView class]
                         forModelClass:[NSString class]];
        });
        
        it(@"should accept constant strings", ^{
            ^{
                [storage addItem:@""];
            } should_not raise_exception;
        });
        
        it(@"should accept non-empty strings", ^{
            ^{
                [storage addItem:@"not empty"];
            } should_not raise_exception;
        });
        
        it(@"should accept mutable string", ^{
            ^{
                NSMutableString * string = [[NSMutableString alloc] initWithString:@"first"];
                [string appendString:@",second"];
                [storage addItem:string];
            } should_not raise_exception;
        });
        
        it(@"should accept NSString header", ^{
            ^{
                [storage setSectionHeaderModels:@[@"foo"]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSString footer ", ^{
            ^{
                [storage setSectionFooterModels:@[@"bar"]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
    });
    
    describe(@"NSMutableString", ^{
        
        beforeEach(^{
            [model registerCellClass:[CellWithNib class] forModelClass:[NSMutableString class]];
            [model registerHeaderClass:[MockTableHeaderView class] forModelClass:[NSMutableString class]];
            [model registerFooterClass:[MockTableHeaderView class] forModelClass:[NSMutableString class]];
        });
        
        it(@"should accept constant strings", ^{
            ^{
                [storage addItem:@""];
            } should_not raise_exception;
        });
        
        it(@"should accept non-empty strings", ^{
            ^{
                [storage addItem:@"not empty"];
            } should_not raise_exception;
        });
        
        it(@"should accept mutable string", ^{
            ^{
                NSMutableString * string = [[NSMutableString alloc] initWithString:@"first"];
                [string appendString:@",second"];
                [storage addItem:string];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableString header", ^{
            ^{
                [storage setSectionHeaderModels:@[@"foo"]];
                [model tableView:model.tableView viewForHeaderInSection:0];

            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableString footer ", ^{
            ^{
                [storage setSectionFooterModels:@[@"bar"]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
    });
    
    describe(@"NSNumber", ^{
       
        beforeEach(^{
            [model registerCellClass:[CellWithNib class] forModelClass:[NSNumber class]];
            [model registerHeaderClass:[MockTableHeaderView class] forModelClass:[NSNumber class]];
            [model registerFooterClass:[MockTableHeaderView class] forModelClass:[NSNumber class]];
            model.sectionFooterStyle = DTTableViewSectionStyleView;
        });
        
        it(@"should accept nsnumber for cells", ^{
            ^{
                [storage addItem:@5];
            } should_not raise_exception;
        });
        
        it(@"should accept bool number for cells", ^{
            ^{
                [storage addItem:@YES];
            } should_not raise_exception;
        });
        
        it(@"should accept number for header", ^{
            ^{
                [storage setSectionHeaderModels:@[@5]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept number for footer", ^{
            ^{
                [storage setSectionFooterModels:@[@5]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept BOOL for header", ^{
            ^{
                [storage setSectionHeaderModels:@[@YES]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept bool for footer", ^{
            ^{
                [storage setSectionFooterModels:@[@YES]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
    });
    
    describe(@"NSDictionary", ^{
        
        beforeEach(^{
            [model registerCellClass:[CellWithNib class] forModelClass:[NSDictionary class]];
            [model registerHeaderClass:[MockTableHeaderView class] forModelClass:[NSDictionary class]];
            [model registerFooterClass:[MockTableHeaderView class] forModelClass:[NSDictionary class]];
            model.sectionFooterStyle = DTTableViewSectionStyleView;
        });
        
        it(@"should accept NSDictionary for cells", ^{
            ^{
                [storage addItem:@{@1:@2}];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableDictionary for cells", ^{
            ^{
                [storage addItem:[[@{@1:@2} mutableCopy] autorelease]];
            } should_not raise_exception;
        });
        
        it(@"should accept NSDictionary for header", ^{
            ^{
                [storage setSectionHeaderModels:@[@{}]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSDictionary for footer", ^{
            ^{
                [storage setSectionFooterModels:@[@{}]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableDictionary for header", ^{
            ^{
                [storage setSectionHeaderModels:@[[[@{} mutableCopy] autorelease]]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableDictionary for footer", ^{
            ^{
                [storage setSectionFooterModels:@[[[@{} mutableCopy] autorelease]]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
    });
    
    describe(@"NSMutableDictionary", ^{
        
        beforeEach(^{
            [model registerCellClass:[CellWithNib class] forModelClass:[NSMutableDictionary class]];
            [model registerHeaderClass:[MockTableHeaderView class] forModelClass:[NSMutableDictionary class]];
            [model registerFooterClass:[MockTableHeaderView class] forModelClass:[NSMutableDictionary class]];
            model.sectionFooterStyle = DTTableViewSectionStyleView;
        });
        
        it(@"should accept NSDictionary for cells", ^{
            ^{
                [storage addItem:@{@1:@2}];
            } should_not raise_exception;
        });
        
        it(@"should accept NSDictionary for cells", ^{
            ^{
                [storage addItem:[[@{@1:@2} mutableCopy] autorelease]];
            } should_not raise_exception;
        });
        
        it(@"should accept NSDictionary for header", ^{
            ^{
                [storage setSectionHeaderModels:@[@{}]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSDictionary for footer", ^{
            ^{
                [storage setSectionFooterModels:@[@{}]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableDictionary for header", ^{
            ^{
                [storage setSectionHeaderModels:@[[[@{} mutableCopy] autorelease]]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableDictionary for footer", ^{
            ^{
                [storage setSectionFooterModels:@[[[@{} mutableCopy] autorelease]]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
    });
    
    describe(@"NSArray", ^{
        
        beforeEach(^{
            [model registerCellClass:[CellWithNib class] forModelClass:[NSArray class]];
            [model registerHeaderClass:[MockTableHeaderView class] forModelClass:[NSArray class]];
            [model registerFooterClass:[MockTableHeaderView class] forModelClass:[NSArray class]];
            model.sectionFooterStyle = DTTableViewSectionStyleView;
        });
        
        it(@"should accept NSArray for cells", ^{
            ^{
                [storage addItem:@[]];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableArray for cells", ^{
            ^{
                [storage addItem:[[@[] mutableCopy] autorelease]];
            } should_not raise_exception;
        });
        
        it(@"should accept NSArray for header", ^{
            ^{
                [storage setSectionHeaderModels:@[@[]]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableArray for header", ^{
            ^{
                [storage setSectionHeaderModels:@[[[@[] mutableCopy] autorelease]]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSArray for footer", ^{
            ^{
                [storage setSectionFooterModels:@[@[]]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableArray for footer", ^{
            ^{
                [storage setSectionFooterModels:@[[[@[] mutableCopy] autorelease]]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
        
    });
    
    describe(@"NSMutableArray", ^{
        
        beforeEach(^{
            [model registerCellClass:[CellWithNib class] forModelClass:[NSMutableArray class]];
            [model registerHeaderClass:[MockTableHeaderView class] forModelClass:[NSMutableArray class]];
            [model registerFooterClass:[MockTableHeaderView class] forModelClass:[NSMutableArray class]];
            model.sectionFooterStyle = DTTableViewSectionStyleView;
        });
        
        it(@"should accept NSArray for cells", ^{
            ^{
                [storage addItem:@[]];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableArray for cells", ^{
            ^{
                [storage addItem:[[@[] mutableCopy] autorelease]];
            } should_not raise_exception;
        });
        
        it(@"should accept NSArray for header", ^{
            ^{
                [storage setSectionHeaderModels:@[@[]]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableArray for header", ^{
            ^{
                [storage setSectionHeaderModels:@[[[@[] mutableCopy] autorelease]]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSArray for footer", ^{
            ^{
                [storage setSectionFooterModels:@[@[]]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSMutableArray for footer", ^{
            ^{
                [storage setSectionFooterModels:@[[[@[] mutableCopy] autorelease]]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
        
    });
    
    describe(@"NSDate", ^{
        
        beforeEach(^{
            [model registerCellClass:[CellWithNib class] forModelClass:[NSDate class]];
            [model registerHeaderClass:[MockTableHeaderView class] forModelClass:[NSDate class]];
            [model registerFooterClass:[MockTableHeaderView class] forModelClass:[NSDate class]];
            model.sectionFooterStyle = DTTableViewSectionStyleView;
        });
        
        it(@"should accept NSDate for cells", ^{
            ^{
                [storage addItem:[NSDate date]];
            } should_not raise_exception;
        });

        it(@"should accept NSDate for header", ^{
            ^{
                [storage setSectionHeaderModels:@[[NSDate date]]];
                [model tableView:model.tableView viewForHeaderInSection:0];
            } should_not raise_exception;
        });
        
        it(@"should accept NSDate for footer", ^{
            ^{
                [storage setSectionFooterModels:@[[NSDate date]]];
                [model tableView:model.tableView viewForFooterInSection:0];
            } should_not raise_exception;
        });
       
    });
    
    describe(@"DTAbstractCellModel tests", ^{
        
        it(@"should accept DTAbstractCellModel with correct cellClass", ^{
            DTAbstractCellModel * abstractCellModel = [DTAbstractCellModel modelWithCellClass:[ExampleCell class]
                                                                              reuseIdentifier:nil
                                                                           configurationBlock:nil];
            [storage addItem:abstractCellModel];
             
            UITableViewCell * cell = [model tableView:model.tableView
                                cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                         inSection:0]];
            
            [cell class] should equal([ExampleCell class]);
        });
        
        it(@"should raise if cell class is not derived from UITableViewCell", ^{
            ^{
                [DTAbstractCellModel modelWithCellClass:[NSString class] reuseIdentifier:nil configurationBlock:nil];
            } should raise_exception();
        });
        
        it(@"should invoke configuration block", ^{
            DTAbstractCellModel * cellModel = [DTAbstractCellModel modelWithCellClass:[CustomCell class]
                                                                      reuseIdentifier:nil
                                                                   configurationBlock:^(UITableViewCell *cell) {
                                                   CustomCell * customCell = (CustomCell *)cell;
                                                   customCell.label1 = [[UILabel alloc] init];
                                                   customCell.label1.text = @"foo";
                                               }];
            
            [storage addItem:cellModel];
            
            UITableViewCell * cell = [model tableView:model.tableView
                                cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                         inSection:0]];
            
            [cell class] should equal([CustomCell class]);
            
            [(CustomCell *)cell label1].text should equal(@"foo");
        });
        
    });
    
    describe(@"DTDefaultCellModel tests", ^{
       
        it(@"should accept DTDefaultCellModel with correct parameters", ^{
           DTDefaultCellModel * cellModel = [DTDefaultCellModel modelWithCellStyle:UITableViewCellStyleSubtitle
                                                                   reuseIdentifier:nil
                                                                configurationBlock:nil];
            [storage addItem:cellModel];
            
            UITableViewCell * cell = [model tableView:model.tableView
                                cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                         inSection:0]];
            
            [cell class] should equal([UITableViewCell class]);
        });
        
        it(@"should invoke configuration block", ^{
            DTDefaultCellModel * cellModel = [DTDefaultCellModel modelWithCellStyle:UITableViewCellStyleSubtitle
                                                                    reuseIdentifier:nil
                                                                 configurationBlock:^(UITableViewCell *cell) {
                                                                     cell.textLabel.text = @"foo";
                                                                     cell.detailTextLabel.text = @"bar";
                                                                 }];
            [storage addItem:cellModel];
            
            UITableViewCell * cell = [model tableView:model.tableView
                                cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                         inSection:0]];
            
            [cell class] should equal([UITableViewCell class]);
            
            cell.textLabel.text should equal(@"foo");
            cell.detailTextLabel.text should equal(@"bar");
        });
    });
});



SPEC_END
