//
//  OTRBuddyViewController.m
//  Off the Record
//
//  Created by David on 3/6/13.
//  Copyright (c) 2013 Chris Ballinger. All rights reserved.
//

#import "OTRBuddyViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "OTRSafariActionSheet.h"
#import "OTRInLineTextEditTableViewCell.h"
#import "Strings.h"

@interface OTRBuddyViewController ()

@end

@implementation OTRBuddyViewController

@synthesize buddy;


-(id)initWithBuddyID:(NSManagedObjectID *)buddyID
{
    if(self = [self init])
    {
        self.buddy = (OTRManagedBuddy *)[[NSManagedObjectContext MR_contextForCurrentThread] existingObjectWithID:buddyID error:nil];
        self.title = @"Buddy Info";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
    
    displayNameTextField = [[UITextField alloc]init];
    displayNameTextField.placeholder = OPTIONAL_STRING;
    displayNameTextField.font = [UIFont boldSystemFontOfSize:15];
    
    if ([buddy.displayName length] && ![buddy.displayName isEqualToString:buddy.accountName]) {
        displayNameTextField.text = buddy.displayName;
    }
    
    UIButton * removeBuddyButton = [[UIButton alloc] init];
    UIButton * blockBuddyButton = [[UIButton alloc] init];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1) {
        return 2;
    }
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 80.0f;
    }
    return 44.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"cell";
    static NSString * cellIdentifierText = @"cellText";
    static NSString * cellIdentifierLabel = @"cellLabel";
    static NSString * cellIdentifierGroups = @"cellgroups";
    static NSString * cellIdentifierButtons = @"cellgroups";
    UITableViewCell * cell = nil;
    
    
    if (indexPath.section == 0) {
        // Image and Status
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [self setupPhotoCell:cell];
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        //Account Name
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierLabel];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifierLabel];
            cell.textLabel.text = @"Email";
            cell.detailTextLabel.text = buddy.accountName;
        }
        
    }
    else if(indexPath.section == 1 && indexPath.row == 1){
        //Display Name
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierText];
        if (!cell) {
            cell =[[OTRInLineTextEditTableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifierText];
        }
        cell.textLabel.text = @"Name";
        [cell layoutIfNeeded];
        ((OTRInLineTextEditTableViewCell *)cell).textField = displayNameTextField;
    }
    else if(indexPath.section == 2 && indexPath.row == 0)
    {
        //Groups
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierGroups];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifierGroups];
        }
        if ([buddy.groups count] > 1) {
            cell.textLabel.text = @"Groups";
        }
        else
        {
            cell.textLabel.text = @"Group";
        }
        
        cell.detailTextLabel.text = [[buddy groupNames] componentsJoinedByString:@", "];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    else if(indexPath.section == 3 && indexPath.row == 0)
    {
        //remove and block
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifierButtons];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [self setupButtonsCell:cell];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)setupButtonsCell:(UITableViewCell *)cell
{
    
}

-(void)setupPhotoCell:(UITableViewCell *)cell
{
    //cell.backgroundView = cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    UIImageView * buddyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 70.0, 70.0)];
    buddyImageView.backgroundColor = [UIColor lightGrayColor];
    
    if (self.buddy.photo) {
        UIImage * image = self.buddy.photo;
        CGSize size = image.size;
        buddyImageView.image = buddy.photo;
    }
    else
    {
        buddyImageView.image = [UIImage imageNamed:@"person"];
    }
    [buddyImageView.layer setCornerRadius:10.0];
    buddyImageView.layer.masksToBounds = YES;
    
    [cell.contentView addSubview:buddyImageView];
    
    
    
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nameLabel.font = [UIFont boldSystemFontOfSize:18];
    nameLabel.numberOfLines = 0;
    //nameLabel.lineBreakMode = UILineBreakModeWordWrap;
    nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.shadowOffset = CGSizeMake(1, 1);
    nameLabel.textColor = [UIColor blackColor];
    [cell.contentView addSubview:nameLabel];
    if([buddy.displayName length])
    {
        nameLabel.text = buddy.displayName;
    }
    else{
        nameLabel.text = buddy.accountName;
    }
    
    [nameLabel sizeToFit];
    
    CGFloat xPos = buddyImageView.frame.size.width + buddyImageView.frame.origin.x + 10;
    
    CGRect tempFrame = nameLabel.frame;
    tempFrame.size.width = cell.contentView.frame.size.width -xPos;
    tempFrame.origin = CGPointMake(xPos, 5.0);
    nameLabel.frame = tempFrame;
    
    
    
    TTTAttributedLabel * statusMessageLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setObject:(id)[statusMessageLabel.textColor CGColor] forKey:(NSString*)kCTForegroundColorAttributeName];
    [mutableLinkAttributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    statusMessageLabel.linkAttributes = mutableLinkAttributes;
    statusMessageLabel.delegate = self;
    statusMessageLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    statusMessageLabel.numberOfLines = 0;
    statusMessageLabel.lineBreakMode = UILineBreakModeWordWrap;
    statusMessageLabel.backgroundColor = [UIColor clearColor];
    statusMessageLabel.shadowOffset = CGSizeMake(1, 1);
    statusMessageLabel.textColor = [UIColor blackColor];
    [cell.contentView addSubview:statusMessageLabel];
    statusMessageLabel.text = self.buddy.currentStatusMessage.message;
    
    [statusMessageLabel sizeToFit];
    
    
    
    tempFrame = statusMessageLabel.frame;
    tempFrame.size.width = cell.contentView.frame.size.width -xPos;
    tempFrame.origin = CGPointMake(xPos, nameLabel.frame.origin.y+nameLabel.frame.size.height+5.0);
    statusMessageLabel.frame = tempFrame;
}

-(void)doneButtonPressed:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    OTRSafariActionSheet * actionSheet = [[OTRSafariActionSheet alloc] initWithUrl:url];
    [actionSheet showInView:self.view];
}

@end