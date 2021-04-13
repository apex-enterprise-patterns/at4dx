@IsTest
private class PlatformEventDistributorDIModuleTest {
    @IsTest
    private static void platformEventDIModuleCoverage()
    {
        //leaving out consumer and eventbus values will trigger warning messages code
        PlatformEvents_Subscription__mdt pes = new PlatformEvents_Subscription__mdt(
            DeveloperName = 'At4dxUnitTest',
            IsActive__c = true,
            EventCategory__c = Account.getSObjectType().getDescribe().getName(),
            MatcherRule__c = 'MatchEventBusAndCategoryAndEventName',
            Event__c = 'TestOfPlatformEventDistributor',
            Execute_Synchronous__c = true
        );

        PlatformEvents_Subscription__mdt pes2 = new PlatformEvents_Subscription__mdt(
            DeveloperName = 'At4dxUnitTest',
            Consumer__c = 'PlatformEventDistributorTest.TestPlatformEventsConsumer',
            IsActive__c = true,
            EventCategory__c = Account.getSObjectType().getDescribe().getName(),
            MatcherRule__c = 'MatchEventBusAndCategoryAndEventName',
            EventBus__c = AT4DXMessage__e.SobjectType.getDescribe().getName(),
            Event__c = 'TestOfPlatformEventDistributor',
            Execute_Synchronous__c = true
        );

        PlatformEventDistributorDIModule dimod = new PlatformEventDistributorDIModule();
        PlatformEventDistributorDIModule.registeredSubscribers = new List<PlatformEvents_Subscription__mdt> { pes, pes2 };
        dimod.configure();

        System.assertEquals(
            new List<PlatformEvents_Subscription__mdt> { pes, pes2 },
            PlatformEventDistributorDIModule.registeredSubscribers,
            'Registered Subscirbers Not Equal'
        );
    }
}
