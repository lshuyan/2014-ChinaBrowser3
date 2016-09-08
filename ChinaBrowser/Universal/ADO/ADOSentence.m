//
//  ADOSentence.m
//  ChinaBrowser
//
//  Created by David on 14-9-6.
//  Copyright (c) 2014年 KOTO Inc. All rights reserved.
//

#import "ADOSentence.h"

@implementation ADOSentence

static int QueryCallback (void *result, int colCount, char **data, char **colName)
{
    NSMutableArray *arrResult = (__bridge NSMutableArray *)result;
    ModelSentence *model = [ModelSentence model];
    model.iid = atoi(data[0]);
    model.cid = atoi(data[1]);
    model.no = atoi(data[2]);
    char *
    value = data[3];
    if (value) model.sentence = [NSString stringWithCString:value encoding:NSUTF8StringEncoding];
    value = data[4];
    if (value) model.lan = [NSString stringWithCString:value encoding:NSUTF8StringEncoding];
    [arrResult addObject:model];
    return 0;
}

+ (BOOL)isExistWithSentence:(NSString *)sentence cid:(NSInteger)cid lan:(NSString *)lan
{
    const char *filename = [TRANS_DBPATH UTF8String];
    sqlite3 *db = nil ;
    const char *sql = [lan?[NSString stringWithFormat:@"select * from tab_sentence where sentence=\"%@\" and cid=%ld and lan = \"%@\"", sentence, (long)cid, lan]:[NSString stringWithFormat:@"select * from tab_sentence where sentence=\"%@\" and cid=%ld", sentence?:@"", (long)cid] UTF8String];
    sqlite3_callback callback = QueryCallback;
    NSMutableArray *arrResult = [NSMutableArray array];
    char *msg = nil;
    do {
        if (SQLITE_OK!=sqlite3_open(filename, &db))
            break;
        if (SQLITE_OK!=sqlite3_exec(db, sql, callback, (__bridge void*)arrResult, &msg))
            break;
    } while (NO);
    
    if (msg) sqlite3_free(msg);
    if (db) sqlite3_close(db);
    
    return arrResult.count>0;
}

+ (NSInteger)addModel:(ModelSentence *)model
{
    if ([ADOSentence isExistWithSentence:model.sentence cid:model.cid lan:model.lan]) {
        return 0;
    }
    NSInteger lastInsertId = 0;
    const char *filename = [TRANS_DBPATH UTF8String];
    sqlite3 *db;
    const char *sql = [[NSString stringWithFormat:@"insert into tab_sentence (cid, no, sentence, lan) values (%ld, %ld, \"%@\", \"%@\")", (long)model.cid, (long)model.no, model.sentence?:@"", model.lan?:@""] UTF8String];
    char *msg=nil;
    do {
        if (SQLITE_OK!=sqlite3_open(filename, &db))
            break;
        if (SQLITE_OK!=sqlite3_exec(db, sql, nil, nil, &msg)) {
            break;
        }
    } while (NO);
    
    lastInsertId = (NSInteger)sqlite3_last_insert_rowid(db);
    
    if (msg) {
        NSLog(@"----------error:%@=%s", model.sentence, msg);
    }
    
    if (msg) sqlite3_free(msg);
    if (db) sqlite3_close(db);
    
    return lastInsertId;
}

+ (ModelSentence *)queryWithId:(NSInteger)iid
{
    const char *filename = [TRANS_DBPATH UTF8String];
    sqlite3 *db = nil ;
    const char *sql = [[NSString stringWithFormat:@"select * from tab_sentence where iid = %ld", (long)iid] UTF8String];
    sqlite3_callback callback = QueryCallback;
    NSMutableArray *arrResult = [NSMutableArray array];
    char *msg = nil;
    do {
        if (SQLITE_OK!=sqlite3_open(filename, &db))
            break;
        if (SQLITE_OK!=sqlite3_exec(db, sql, callback, (__bridge void*)arrResult, &msg))
            break;
    } while (NO);
    
    if (msg) sqlite3_free(msg);
    if (db) sqlite3_close(db);
    
    return arrResult.count>0?arrResult[0]:nil;
}

+ (NSArray *)queryWithCid:(NSInteger)cid lan:(NSString *)lan
{
    const char *filename = [TRANS_DBPATH UTF8String];
    sqlite3 *db = nil ;
    const char *sql = [lan?[NSString stringWithFormat:@"select * from tab_sentence where cid = %ld and lan = \"%@\" order by no", (long)cid, lan?:@""]:[NSString stringWithFormat:@"select * from tab_sentence where cid = %ld order by no", (long)cid] UTF8String];
    sqlite3_callback callback = QueryCallback;
    NSMutableArray *arrResult = [NSMutableArray array];
    char *msg = nil;
    do {
        if (SQLITE_OK!=sqlite3_open(filename, &db))
            break;
        if (SQLITE_OK!=sqlite3_exec(db, sql, callback, (__bridge void*)arrResult, &msg))
            break;
    } while (NO);
    
    if (msg) sqlite3_free(msg);
    if (db) sqlite3_close(db);
    
    return arrResult;
}

@end
