@IsTest
public with sharing class ApplicationSObjectUnitOfWorkTest {
    @IsTest
    static void verifyRegisteredRecordListReturnsNewRecordsByType() {
        //Test register list of new records
        applicationSObjectUOW.register(acctList);

        //Test getting new records registered
        List<Account> returnedAccts = 
            applicationSObjectUOW.getNewRecordsByType(
                Account.SObjectType
            );

        System.assertEquals(
            acctList,
            returnedAccts,
            'Account Lists Not Equal'
        );
    }

    @IsTest
    static void verifyRegisterSingleRecordReturnsNewRecordsByType() {
        //Test register single new record
        applicationSObjectUOW.register(
            singleAccount
        );

        //Test getting new records registered
        List<Account> returnedAccts = 
            applicationSObjectUOW.getNewRecordsByType(
                Account.SObjectType
            );

        //Put Single account in list for assertion
        List<Account> expectedList = 
            new List<Account>{singleAccount};
          
        System.assertEquals(
            expectedList,
            returnedAccts,
            'Account Lists Not Equal'
        );
    }
   
    
    @IsTest
    static void verifyRegisteredRecordListReturnDirtyRecordsByType(){
		insert acctList;

        //Test register List of Dirty records
        applicationSObjectUOW.register(acctList);

        //Test Return Dirty Records By Type to Map
        Map<Id,SObject> returnedAcctsMap = 
        applicationSObjectUOW.getDirtyRecordsByType(
            acctList.getSObjectType()
        );

        //Put mapped values to list
        List<Account> returnedAcctsList =
            returnedAcctsMap.values(); 

        System.assertEquals(
            acctList,
            returnedAcctsList,
            'Lists Do Not Match'
        );
    }

  @IsTest
    static void verifyRegisterSingleRecordReturnDirtyRecordsByType(){
        insert singleAccount;
       
        //Test register single Dirty record
        applicationSObjectUOW.register(
            singleAccount
        );

        //Test Return Dirty Records By Type to Map
        Map<Id,SObject> returnedAcctsMap = 
        applicationSObjectUOW.getDirtyRecordsByType(
            singleAccount.getSObjectType()
        );

        //Put mapped values in list for assertion
        List<Account> returnedAcctsList =
            returnedAcctsMap.values();

        //Put Single account in list for assertion
        List<Account> expectedList = 
            new List<Account>{singleAccount};

        System.assertEquals(
            expectedList,
            returnedAcctsList,
            'Lists Do Not Match'
        );
    }

  @IsTest
    static void verifyApplicationSobjectUOWConstructorWithDML(){
        insert singleAccount;

       //Mock DML for testing constructor with Type and DML
        MockDML mockDML = new MockDML();
         
        List<Schema.SObjectType> sObjTypes = new List<Schema.SObjectType>();
        sObjTypes.add(Account.SOBjectType);

        ApplicationSObjectUnitOfWork applicationSObjectUOWDML= 
            new ApplicationSObjectUnitOfWork(sObjTypes,mockDML);

        //Test register single Dirty record
        applicationSObjectUOWDML.register(
            singleAccount
        );

        //Test Return Dirty Records By Type to Map
        Map<Id,SObject> returnedAcctsMap = 
        applicationSObjectUOWDML.getDirtyRecordsByType(
            singleAccount.getSObjectType()
        );

        //put mapped values in list for assertion
        List<Account> returnedAcctsList =
            returnedAcctsMap.values(); 

        //Put Single account in list for assertion
        List<Account> expectedList = 
            new List<Account>{singleAccount};

        System.assertEquals(
            expectedList,
            returnedAcctsList,
            'Lists Do Not Match'
        );
    }

    @IsTest
    static void verifyGetDeletedRecordsByType(){
        //Register List of records and commit them
        applicationSObjectUOW.register(acctList);
        applicationSObjectUOW.commitWork();

        //Delete registered records
        applicationSObjectUOW.registerDeleted(acctList);

        //Test Return deleted records by type to map
        Map<Id,SObject> returnedDeletedAcctsMap = 
        applicationSObjectUOW.getDeletedRecordsByType(
            acctList.getSObjectType()
        );

        //Group accounts for assertion
        List<Account> returnedDeletedAcctsList =
            returnedDeletedAcctsMap.values(); 

        System.assertEquals(
            acctList,
            returnedDeletedAcctsList,
            'Lists Do Not Match'
        );
    }

    @IsTest
    static void verifyRegisterNewWithParentRecord() {
        //Create account record to be parent
        Account parentAccount = new Account(name='parentAccount');
        insert parentAccount;

        Schema.SObjectField parentField = Account.ParentId; 

        //Test register single new record
        applicationSObjectUOW.register(
            singleAccount,
            parentField,
            parentAccount
        );
        applicationSObjectUOW.commitWork();

        //Test getting new records registered
        List<Account> returnedAccts = 
            applicationSObjectUOW.getNewRecordsByType(
                Account.SObjectType
            );

        Account returnedAcct = returnedAccts[0];
           
        System.assertEquals(
            parentAccount.Id,
            returnedAcct.ParentId,
            'Parent Id Not Equal'
        );
    }

    @IsTest
    static void verifyRegisterDirtyWithParentRecord(){
        //Create account record to be parent
        Account parentAccount = new Account(name='parentAccount');
        insert parentAccount;

        insert singleAccount;

       Schema.SObjectField parentField = Account.ParentId; 

        //Test register single Dirty record
        applicationSObjectUOW.register(
            singleAccount,
            parentField,
            parentAccount
        );
        applicationSObjectUOW.commitWork();

        //Test Return Dirty Records By Type to Map
        Map<Id,SObject> returnedAcctsMap = 
        applicationSObjectUOW.getDirtyRecordsByType(
            singleAccount.getSObjectType()
        );

        //Put mapped values in list for assertion
        List<Account> returnedAcctsList =
            returnedAcctsMap.values();

        Account returnedAcct = returnedAcctsList[0];

        System.assertEquals(
            parentAccount.Id,
            returnedAcct.ParentId,
            'Lists Do Not Match'
        );
    }

    @isTest
    private static void verifyRegisterEmails()
    {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new list<String>{ 'foobar@test.com' });
        email.setPlainTextBody('See Spot run.');

        List<Messaging.Email> emails = new List<Messaging.Email>();
        emails.add(email);

        applicationSObjectUOW.m_emailWork = new Mock_SendEmailWork();

        applicationSObjectUOW.register(singleAccount);

        applicationSObjectUOW.registerEmails(emails);

        applicationSObjectUOW.registerRelationship(email, singleAccount);
        
        applicationSObjectUOW.commitWork();

        List<Account> accts = 
            applicationSObjectUOW.getNewRecordsByType(
                singleAccount.getSObjectType()
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

    private class MockDML implements fflib_SObjectUnitOfWork.IDML
    {
        public List<SObject> recordsForInsert = new List<SObject>();
        public List<SObject> recordsForUpdate = new List<SObject>();
        public List<SObject> recordsForDelete = new List<SObject>();
        public List<SObject> recordsForRecycleBin = new List<SObject>();
        public List<SObject> recordsForEventPublish = new List<SObject>();

        public void dmlInsert(List<SObject> objList)
        {
            this.recordsForInsert.addAll(objList);
        }

        public void dmlUpdate(List<SObject> objList)
        {
            this.recordsForUpdate.addAll(objList);
        }

        public void dmlDelete(List<SObject> objList)
        {
            this.recordsForDelete.addAll(objList);
        }

        public void eventPublish(List<SObject> objList)
        {
            this.recordsForEventPublish.addAll(objList);
        }

        public void emptyRecycleBin(List<SObject> objList)
        {
            this.recordsForRecycleBin.addAll(objList);
        }
    }

    public static final ApplicationSObjectUnitOfWork applicationSObjectUOW= 
        new ApplicationSObjectUnitOfWork(
            new List<Schema.SObjectType>{
                Account.SObjectType
            }
        );

    public static final List<Account> acctList = new List<Account> {
    	new Account(Name='TestAccount1'),
		new Account(Name='TestAccount2') 
    };
        
    public static final Account singleAccount = 
        new Account(Name='NewTestAccount1');
}
