@IsTest
public class PlatformEventDistributorTest
{
    @IsTest(seeAllData = true)
    static void test()
    {
        Event__e platformEventbus = new Event__e();

        platformEventbus.EventName__c = 'Account_Slogan_Has_Changed';
        platformEventbus.Payload__c = json.serialize(new Set<Id>{ fflib_IDGenerator.generate(Account.SObjectType)});
        // platformEventbus.Category__c = Account.getSObjectType().getDescribe().getName();

        new PlatformEventDistributor().triggerHandler(new List<Event__e> {platformEventbus});
    }

    // @isTest
    private static void basicTestToActivateCodeCoverage() 
    {
        Event__e platformEventbus = new Event__e();

        platformEventbus.EventName__c = 'bluefish';
        platformEventbus.Payload__c = json.serialize( new Set<Id>{ fflib_IDGenerator.generate(Account.SObjectType ) } );
        platformEventbus.Category__c = Account.getSObjectType().getDescribe().getName();

        Test.startTest();
        Database.SaveResult sr = EventBus.publish(platformEventbus);
        Test.stopTest();

        System.assertEquals(true, sr.isSuccess());
    }
}
