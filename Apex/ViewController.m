//
//  ViewController.m
//  Apex
//
//  Created by Mustafa on 4/21/16.
//  Copyright © 2016 Mustafa. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *InFromUser;

- (IBAction)OnceDone:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *response;
@property (weak, nonatomic) IBOutlet UITableView *List;


@end

@implementation ViewController{
 NSMutableArray *ListOfNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
 ListOfNames=[NSMutableArray new];
    
[[AFNetworkReachabilityManager sharedManager] startMonitoring];
 
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [ListOfNames count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [ListOfNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"List";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];

    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }
    /////////////////////////////////////////////ADDING RESULT TO TABLE
    cell.textLabel.text =[[ListOfNames objectAtIndex:indexPath.row] objectForKey:@"lf"];
    return cell;
}
-(void) RefershTable
{
    [self.List reloadData];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//On CLick from user
- (IBAction)OnceDone:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self GetEvent:_InFromUser.text];
    _response.text=[NSString stringWithFormat:@"Result For %@ ",_InFromUser.text];
    
    
}


-(void)GetEvent: (NSString *) Abervation{
    
    //Check Conenction
    if([AFNetworkReachabilityManager sharedManager].reachable){
        
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"http://www.nactem.ac.uk/software/acromine/dictionary.py"
     
      parameters:@{ @"sf": Abervation}
         success:^(AFHTTPRequestOperation *operation, id responseObject) {

             NSArray *jsonDataArray = [[NSArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil]];
             
             [self ResponseHandler:jsonDataArray];
            
             
             [self closeMbProgress];
             
         }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            

             NSLog(@"Error: %@", error);
               [self closeMbProgress];
         }

     ];
    }else{
     _response.text=@"No Internet connection";
        [self closeMbProgress];
    }
    
}

//handle the responsefrom server
-(void)ResponseHandler:(NSArray *)Response{
NSDictionary *dictObject = [Response objectAtIndex:0];
NSMutableArray *NoOFLongform=dictObject[@"lfs"];
    ListOfNames=NoOFLongform;
    [self RefershTable];


}
//closing the progress bar

-(void)closeMbProgress{
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}
@end
