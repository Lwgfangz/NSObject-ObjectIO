//  Copyright (c) 2012 The Board of Trustees of The University of Alabama
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. Neither the name of the University nor the names of the contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
//  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
//  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
//  OF THE POSSIBILITY OF SUCH DAMAGE.

#import "ViewController.h"
#import "NSObject+ObjectIO.h"
#import "SpaceObjects.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Create a test object structure (Something to save!)
    //Defaults to 8 planets, ~8 moons, and one hundred thousand asteroids
    SolarSystem *testSolarSystem = [SolarSystem ourSolarSystem];
    
    //Test save and load with encryption and reduced file size
    //Saves to your documents folder
    [self saveAndLoadEncryptedSolarSystem:testSolarSystem];
}

-(void)saveAndLoadEncryptedSolarSystem:(SolarSystem *)exampleSolarSystem{
    //Generate Salt
    //You will want to save this somewhere as it is necessary for decrypting the file
    NSString *salt = [NSMutableData generateSalt];
    
    NSString *fileName = @"ObjectIOTestReducedEncrypted.txt";
    
    //Save document
    [StatusLabel setText:@"Saving..."];
    [exampleSolarSystem saveToDocumentsDirectoryWithName:fileName reducedFileSize:YES password:@"Password1" salt:salt completion:^(NSError *error) {
        
        //Create a new solar system
        __block SolarSystem *encryptedSSReduced = [[SolarSystem alloc] init];
        
        //Load back the Solar System
        [StatusLabel setText:@"Loading..."];
        [encryptedSSReduced loadFromDocumentsDirectoryWithName:fileName password:@"Password1" salt:salt completion:^(id object, NSError *error) {
            
            //Assign object
            encryptedSSReduced = (SolarSystem *)object;
            
            //Get documents folder path
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            
            NSString *completionString = [NSString stringWithFormat:@"Complete - %@", [self fileSizeForPath:[NSString stringWithFormat:@"%@/%@", paths[0], fileName]]];
            
            //Give feedback
            NSLog(@"Encrypted and Reduced Save/Load Complete");
            [StatusLabel setText:completionString];
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)fileSizeForPath:(NSString *)path{
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
    
    if (fileSize < 1000) {
        return [NSString stringWithFormat:@"%lld bytes", fileSize];
    }
    else if (fileSize >= 1000 && fileSize < 1000000) {
        return [NSString stringWithFormat:@"%.2f kB", (float)fileSize/1000000];
    }
    else if (fileSize > 1000000) {
        return [NSString stringWithFormat:@"%.2f MB", (float)fileSize/1000000];
    }
    
    return @"";
}

@end
