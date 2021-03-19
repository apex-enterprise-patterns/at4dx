@IsTest
public with sharing class ApplicationSObjectUnitOfWorkTest {
    @IsTest
    static void verifyReturnNewRecordsByType() {
        List<Account> newAcctList = new List<Account>{
            new Account(Name='NewTestAccount1'),
            new Account(Name='NewTestAccount2')
        };
        Account singleAccount = new Account(Name='NewTestAccount3');

        List<Schema.SObjectType> sObjTypes = new List<Schema.SObjectType>();
        sObjTypes.add(Account.SOBjectType);

        //Test Constructor with Only SObjectType
        ApplicationSObjectUnitOfWork applicationSObjectUOW= 
            new ApplicationSObjectUnitOfWork(sObjTypes);

        //Test register single new record
        applicationSObjectUOW.register(
            singleAccount
        );

        //Test register list of new records
        applicationSObjectUOW.register(newAcctList);

        //Test getting new records registered
        List<Account> returnedAccts = 
            applicationSObjectUOW.getNewRecordsByType(
                Account.SObjectType
            );

        //Group accounts for assertion
        newAcctList.add(singleAccount);
        
        //sort lists for assertion
        newAcctList.sort();
        returnedAccts.sort();

        System.assertEquals(
            newAcctList,
            returnedAccts,
            'Account Lists Not Equal'
        );
    }
    
    @IsTest
    static void verifyReturnDirtyRecordsByType(){
        List<Account> dirtyAcctList = new List<Account> {
			new Account(Name='DirtyTestAccount1'),
			new Account(Name='DirtyTestAccount2') 
        };		
		insert dirtyAcctList;

        Account singleAccount = 
            new Account(Name='NewTestAccount3');
        insert singleAccount;

        List<Schema.SObjectType> sObjTypes = new List<Schema.SObjectType>();
        sObjTypes.add(Account.SOBjectType);

        ApplicationSObjectUnitOfWork applicationSObjectUOW= 
            new ApplicationSObjectUnitOfWork(sObjTypes);
        
        //Test register single Dirty record
        applicationSObjectUOW.register(
            singleAccount
        );

        //Test register List of Dirty records
        applicationSObjectUOW.register(dirtyAcctList);

        //Test Retrun Dirty Records By Type to Map
        Map<Id,SObject> returnedAcctsMap = 
        applicationSObjectUOW.getDirtyRecordsByType(
            dirtyAcctList.getSObjectType()
        );

        //Group accounts for assertion
        dirtyAcctList.add(singleAccount);
        List<Account> returnedAcctsList =
            returnedAcctsMap.values(); 

        //Sort lists for assertion
        dirtyAcctList.sort();
        returnedAcctsList.sort();

        System.assertEquals(
            dirtyAcctList,
            returnedAcctsList,
            'Lists Do Not Match'
        );
    }

    @isTest
    private static void testRegisterEmails()
    {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new list<String>{ 'foobar@test.com' });
        email.setPlainTextBody('See Spot run.');

        List<Messaging.Email> emails = new List<Messaging.Email>();
        emails.add(email);

        List<Schema.SObjectType> sObjTypes = new List<Schema.SObjectType>();
        sObjTypes.add(Account.SOBjectType);

        ApplicationSObjectUnitOfWork applicationSObjectUOW= 
            new ApplicationSObjectUnitOfWork(sObjTypes);

        applicationSObjectUOW.m_emailWork = new Mock_SendEmailWork();

        Account acct = new Account(
            Name='TestAccount1'
        );
        applicationSObjectUOW.register(acct);

        applicationSObjectUOW.registerEmails(emails);

        applicationSObjectUOW.registerRelationship(email, acct);
        
        applicationSObjectUOW.commitWork();

        List<Account> accts = 
            applicationSObjectUOW.getNewRecordsByType(
                acct.getSObjectType()
            ); 

        // assert that mock email functionality was called
        system.assert(((Mock_SendEmailWork) applicationSObjectUOW.m_emailWork).doWorkWasCalled,
            'Email Not Registered'
        );

        System.assertEquals(
            1, 
            accts.size(),
            'Account Not Registered'
        );
    }

    /**
     * Mock implementation of fflib_SObjectUnitOfWork.SendEmailWork
     **/
    private class Mock_SendEmailWork implements fflib_SObjectUnitOfWork.IEmailWork
    {
        public Mock_SendEmailWork()
        {
        }

        public void registerEmail(Messaging.Email email)
        {
        }

        public void doWork()
        {
            doWorkWasCalled = true;
            // The code in the fflib_SObjectUnitOfWork class
            // causes unit test failures in Orgs that do not
            // have email enabled.
        }

        private boolean doWorkWasCalled = false;
    }
}
