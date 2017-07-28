//
//  UIView+UIAppearance.m
//  test
//
//  Created by Jave on 2017/7/20.
//  Copyright © 2017年 Marike Jave. All rights reserved.
//
#import <objc/runtime.h>
#import <JRSwizzle/JRSwizzle.h>
#import "UIView+UIAppearance.h"

@interface UIAppearanceHooker : NSObject

@property (nonatomic, strong) id appearance;

@property (nonatomic, strong) Class appearanceViewClass;

@property (nonatomic, copy) NSMutableArray *appearanceInvocations;
@property (nonatomic, copy) NSHashTable *mutableInstances;

@end

@implementation UIAppearanceHooker

+ (NSMutableDictionary<NSString *, UIAppearanceHooker *> *)shareHookers{
    static NSMutableDictionary *hookers = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hookers = [NSMutableDictionary new];
    });
    return hookers;
}

+ (id)hookerWithViewClass:(Class)viewClass{
    return [self shareHookers][NSStringFromClass(viewClass)];
}

+ (id)createHookerWithAppearance:(id)appearance viewClass:(Class)viewClass;{
    UIAppearanceHooker *hooker = [self new];
    hooker.appearance = appearance;
    hooker.appearanceViewClass = viewClass;
    
    self.shareHookers[NSStringFromClass(viewClass)] = hooker;
    
    return hooker;
}

+ (id)hookerWithAppearance:(id)appearance viewClass:(Class)viewClass;{
    UIAppearanceHooker *hooker = [self hookerWithViewClass:viewClass];
    if (!hooker) {
        hooker = [self createHookerWithAppearance:appearance viewClass:viewClass];
    }
    return hooker;
}

- (IMP)methodForSelector:(SEL)aSelector;{
    return [[self appearance] methodForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    BOOL contained = NO;
    for (NSInvocation *invocation in [[self appearanceInvocations] copy]) {
        if ([invocation selector] == [anInvocation selector]) {
            contained = YES;
            break;
        }
    }
    
    if (!contained && [[self appearanceViewClass] instancesRespondToSelector:[anInvocation selector]]) {
        [[self appearanceInvocations] addObject:anInvocation];
    }
    
    for (id target in [[self mutableInstances] copy]) {
        if ([target respondsToSelector:[anInvocation selector]]) {
            [anInvocation invokeWithTarget:target];
        }
    }
    
    return [[self appearance] forwardInvocation:anInvocation];
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    if ([[self appearance] respondsToSelector:aSelector]) {
        return [self appearance];
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    return [[self appearance] methodSignatureForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector{
    return [[self appearance] respondsToSelector:aSelector];
}

#pragma mark - accessor

- (NSMutableArray *)appearanceInvocations{
    if (!_appearanceInvocations) {
        _appearanceInvocations = [NSMutableArray new];
    }
    return _appearanceInvocations;
}

- (NSHashTable *)mutableInstances{
    if (!_mutableInstances) {
        _mutableInstances = [NSHashTable weakObjectsHashTable];
    }
    return _mutableInstances;
}

- (void)registerAppreanceInstance:(UIView *)instance;{
    NSParameterAssert(instance);
    NSParameterAssert([[instance class] conformsToProtocol:@protocol(UIAppearance)]);
    
    if ([instance allowSynchronizeAppreance]) {
        [[self mutableInstances] addObject:instance];
    }
}

@end

@implementation UIView (UIAppearance)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self jr_swizzleClassMethod:@selector(allocWithZone:) withClassMethod:@selector(swizzle_allocWithZone:) error:nil];
        [self jr_swizzleClassMethod:@selector(appearance) withClassMethod:@selector(swizzle_appearance) error:nil];
    });
}

+ (instancetype)swizzle_appearance{
    id appearance = [self swizzle_appearance];
    
    return [UIAppearanceHooker hookerWithAppearance:appearance viewClass:[self class]];
}

+ (instancetype)swizzle_allocWithZone:(struct _NSZone *)zone{
    id object = [self swizzle_allocWithZone:zone];
    if ([object allowSynchronizeAppreance]) {
        UIAppearanceHooker *appreance = [self appearance];
        [appreance registerAppreanceInstance:object];
    }
    return object;
}

- (BOOL)allowSynchronizeAppreance{
    return NO;
}

@end
