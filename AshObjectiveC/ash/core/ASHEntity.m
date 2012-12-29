
#import "ASHEntity.h"
#import <objc/runtime.h>

@implementation ASHEntity

@synthesize name;
@synthesize componentAdded;
@synthesize componentRemoved;

@synthesize previous;
@synthesize next;
@synthesize components;

- (id)init
{
    self = [super init];
    
    if(self != nil)
    {
        componentAdded = [[ASHSignal2 alloc] init] ;
        componentRemoved = [[ASHSignal2 alloc] init];
        components = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (ASHEntity *)addComponent:(id)component
          componentClass:(Class)componentClass
{
    if(componentClass == nil)
    {
        componentClass = [component class];
    }
    
    NSString * componentClassKey = NSStringFromClass(componentClass);
    
    if(components[componentClassKey] != nil)
    {
        [self removeComponent:componentClass];
    }
    
    components[componentClassKey] = component;
    
    [componentAdded dispatchWithObject:self
                            withObject:componentClass];
    return self;
}

- (ASHEntity *)addComponent:(id)component
{
    Class componentClass = [component class];
    NSString * componentClassKey = NSStringFromClass(componentClass);
    
    if(components[componentClassKey] != nil)
    {
        [self removeComponent:componentClass];
    }
    
    components[componentClassKey] = component;
    
    [componentAdded dispatchWithObject:self
                            withObject:componentClass];
    return self;
}

- (id)removeComponent:(Class)componentClass
{
    id component = components[NSStringFromClass(componentClass)];
   
    if(component != nil)
    {
        [components removeObjectForKey:NSStringFromClass(componentClass)];
        [componentRemoved dispatchWithObject:self 
                                  withObject:componentClass];
        return component;
    }
    
    return nil;
}

- (id)getComponent:(Class)componentClass
{
    return components[NSStringFromClass(componentClass)];
}

- (NSArray *)allComponents
{
    return components.allValues;
}

- (BOOL)hasComponent:(Class)componentClass
{    
    return components[NSStringFromClass(componentClass)] != nil;
}

- (ASHEntity *)clone
{
    ASHEntity * clone = [[ASHEntity alloc] init];
    
    for (NSString * componentClassKey in components)
    {
        id originalComponent = components[componentClassKey];
        Class componentClass = NSClassFromString(componentClassKey);
        id componentCopy = [[componentClass alloc] init];
        [clone addComponent:componentCopy];
        
        u_int count;
        objc_property_t * properties = class_copyPropertyList(componentClass, &count);
        
        for (NSUInteger i = 0; i < count; i++)
        {
            NSString * propertyName = [NSString stringWithCString:property_getName(properties[i])
                                                         encoding:NSUTF8StringEncoding];            
            [componentCopy setValue:[originalComponent valueForKey:propertyName]
                             forKey:propertyName];
             
        }
        
        free(properties);
    }
    
    return clone;
}

@end