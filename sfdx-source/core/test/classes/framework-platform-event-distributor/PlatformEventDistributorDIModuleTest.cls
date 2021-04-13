@IsTest
public with sharing class PlatformEventDistributorDIModuleTest {
    @IsTest
    private static void platformEventDIModuleCoverage()
    {
        String eventName = 'TestOfPlatformEventDistributor';

        //leaving out consumer and eventbus values will trigger warning messages code
        PlatformEvents_Subscription__mdt pes = new PlatformEvents_Subscription__mdt();
        pes.DeveloperName = 'At4dxUnitTest';
        //pes.Consumer__c = 'PlatformEventDistributorTest.TestPlatformEventsConsumer';
        pes.IsActive__c = true;
        pes.EventCategory__c = Account.getSObjectType().getDescribe().getName();
        pes.MatcherRule__c = 'MatchEventBusAndCategoryAndEventName';
        //pes.EventBus__c = AT4DXMessage__e.SobjectType.getDescribe().getName();
        pes.Event__c = eventName;
        pes.Execute_Synchronous__c = true;

        PlatformEvents_Subscription__mdt pes2 = new PlatformEvents_Subscription__mdt();
        pes2.DeveloperName = 'At4dxUnitTest';
        pes2.Consumer__c = 'PlatformEventDistributorTest.TestPlatformEventsConsumer';
        pes2.IsActive__c = true;
        pes2.EventCategory__c = Account.getSObjectType().getDescribe().getName();
        pes2.MatcherRule__c = 'MatchEventBusAndCategoryAndEventName';
        pes2.EventBus__c = AT4DXMessage__e.SobjectType.getDescribe().getName();
        pes2.Event__c = eventName;
        pes2.Execute_Synchronous__c = true;

        PlatformEventDistributorDIModule dimod = new PlatformEventDistributorDIModule();
        PlatformEventDistributorDIModule.registeredSubscribers = new List<PlatformEvents_Subscription__mdt> { pes, pes2 };
        dimod.configure();

        System.assertEquals(
        new List<PlatformEvents_Subscription__mdt> { pes, pes2 },
        dimod.getRegisteredSubscribers(),
        'Registered Subscirbers Not Equal'
        );
    }
}
