//
//  DTTableViewSectionModel.m
//  DTTableViewManager
//
//  Created by Denys Telezhkin on 23.11.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "DTTableViewSectionModel.h"

@implementation DTTableViewSectionModel

-(NSMutableArray *)objects
{
    if (!_objects)
    {
        _objects = [NSMutableArray array];
    }
    return _objects;
}

-(NSUInteger)numberOfObjects
{
    return [self.objects count];
}

@end
