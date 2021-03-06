
#import <GHUnitIOS/GHUnit.h>
#import "ASHComponentPool.h"
#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import "MockHelpers.h"


@interface ComponentPoolTest : GHTestCase

@end


@implementation ComponentPoolTest

- (void)setUp
{
    [self createPool];
}

- (void)tearDown
{
    [self destroyPool];
}

- (void)createPool
{
    
}

- (void)destroyPool
{
    [[ASHComponentPool sharedInstance] empty];
}

- (void)testGetRetrievesObjectOfAppropriateClass
{
    assertThat([[ASHComponentPool sharedInstance] getComponent:[MockComponent class]], instanceOf([MockComponent class]));
}

- (void)testDisposedComponentsAreRetrievedByGet
{
    MockComponent * mockComponent = [[MockComponent alloc] init];
    [[ASHComponentPool sharedInstance] disposeComponent:mockComponent];
    MockComponent * retrievedComponent = [[ASHComponentPool sharedInstance] getComponent:[MockComponent class]];
    assertThat(retrievedComponent, sameInstance(mockComponent));
}

- (void)testEmptyPreventsRetrievalOfPreviouslyDisposedComponents
{
    MockComponent * mockComponent = [[MockComponent alloc] init];
    [[ASHComponentPool sharedInstance] disposeComponent:mockComponent];
    [[ASHComponentPool sharedInstance] empty];
    MockComponent * retrievedComponent = [[ASHComponentPool sharedInstance] getComponent:[MockComponent class]];
    assertThat(retrievedComponent, isNot(sameInstance(mockComponent)));
}

@end
