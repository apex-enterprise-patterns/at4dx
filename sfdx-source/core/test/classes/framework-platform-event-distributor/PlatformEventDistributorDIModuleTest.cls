@IsTest
private class PlatformEventDistributorDIModuleTest {
    @IsTest
    private static void registeredSubscirbersTest()
    {
        PlatformEvents_Subscription__mdt pes1 = new PlatformEvents_Subscription__mdt(
            DeveloperName = 'At4dxUnitTest1',
            Consumer__c = 'PlatformEventDistributorTest.TestPlatformEventsConsumer',
            IsActive__c = true,
            EventCategory__c = Account.getSObjectType().getDescribe().getName(),
            MatcherRule__c = 'MatchEventBusAndCategoryAndEventName',
            EventBus__c = AT4DXMessage__e.SobjectType.getDescribe().getName(),
            Event__c = 'TestOfPlatformEventDistributor',
            Execute_Synchronous__c = true

        );PlatformEvents_Subscription__mdt pes2 = new PlatformEvents_Subscription__mdt(
            DeveloperName = 'At4dxUnitTest2',
            Consumer__c = 'PlatformEventDistributorTest.TestPlatformEventsConsumer',
            IsActive__c = true,
            EventCategory__c = Account.getSObjectType().getDescribe().getName(),
            MatcherRule__c = 'MatchEventBusAndCategoryAndEventName',
            EventBus__c = AT4DXMessage__e.SobjectType.getDescribe().getName(),
            Event__c = 'TestOfPlatformEventDistributor',
            Execute_Synchronous__c = true
        );

        PlatformEventDistributorDIModule dimod = new PlatformEventDistributorDIModule();
        PlatformEventDistributorDIModule.registeredSubscribers = new List<PlatformEvents_Subscription__mdt> { pes1, pes2 };
        dimod.configure();

        System.assertEquals(
            new List<PlatformEvents_Subscription__mdt> { pes1, pes2 },
            PlatformEventDistributorDIModule.registeredSubscribers,
            'Registered Subscirbers Not Equal'
        );

        System.assertEquals(
            null,
            PlatformEventDistributorDIModule.configureWarningMessage,
            'Warning message Not Equal'
        );
    }

    @IsTest
    private static void noEventBusWarningMessageTest(){

        PlatformEvents_Subscription__mdt pes = new PlatformEvents_Subscription__mdt(
            DeveloperName = 'At4dxUnitTest',
            Consumer__c = 'PlatformEventDistributorTest.TestPlatformEventsConsumer',
            IsActive__c = true,
            EventCategory__c = Account.getSObjectType().getDescribe().getName(),
            MatcherRule__c = 'MatchEventBusAndCategoryAndEventName',
            Event__c = 'TestOfPlatformEventDistributor',
            Execute_Synchronous__c = true
        );

        PlatformEventDistributorDIModule dimod = new PlatformEventDistributorDIModule();
        PlatformEventDistributorDIModule.registeredSubscribers = new List<PlatformEvents_Subscription__mdt> { pes };
        dimod.configure();
        
        System.assertEquals(
            'Platform Events - Subscription record named, At4dxUnitTest, does not have required field, Event Bus',
            PlatformEventDistributorDIModule.configureWarningMessage,
            'Warning Message Is Not Equal'
        );
    }

    @IsTest
    private static void noConsumerWarningMessageTest(){

        PlatformEvents_Subscription__mdt pes = new PlatformEvents_Subscription__mdt(
            DeveloperName = 'At4dxUnitTest',
            IsActive__c = true,
            EventCategory__c = Account.getSObjectType().getDescribe().getName(),
            MatcherRule__c = 'MatchEventBusAndCategoryAndEventName',
            EventBus__c = AT4DXMessage__e.SobjectType.getDescribe().getName(),
            Event__c = 'TestOfPlatformEventDistributor',
            Execute_Synchronous__c = true
        );

        PlatformEventDistributorDIModule dimod = new PlatformEventDistributorDIModule();
        PlatformEventDistributorDIModule.registeredSubscribers = new List<PlatformEvents_Subscription__mdt> { pes };
        dimod.configure();
        
        System.assertEquals(
            'Platform Events - Subscription record named, At4dxUnitTest, does not have required field, Consumer',
            PlatformEventDistributorDIModule.configureWarningMessage,
            'Warning Message Is Not Equal'
        );
    }
}
