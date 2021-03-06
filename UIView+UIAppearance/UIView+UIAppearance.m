// Copyright (c) 2017 Modool. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <objc/runtime.h>
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

static void UIView_UIAppearanceMethodSwizzle(Class class, SEL origSel, SEL altSel){
    Method origMethod = class_getInstanceMethod(class, origSel);
    Method altMethod = class_getInstanceMethod(class, altSel);
    
    class_addMethod(class, origSel, class_getMethodImplementation(class, origSel), method_getTypeEncoding(origMethod));
    class_addMethod(class, altSel, class_getMethodImplementation(class, altSel), method_getTypeEncoding(altMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(class, origSel), class_getInstanceMethod(class, altSel));
}

@implementation UIView (UIAppearance)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIView_UIAppearanceMethodSwizzle(object_getClass((id)self), @selector(allocWithZone:), @selector(swizzle_allocWithZone:));
        UIView_UIAppearanceMethodSwizzle(object_getClass((id)self), @selector(appearance), @selector(swizzle_appearance));
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
