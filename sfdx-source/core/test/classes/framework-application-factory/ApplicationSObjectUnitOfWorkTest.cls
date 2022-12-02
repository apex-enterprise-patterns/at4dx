/** working draft
 * Copyright (c) 2020, John M. Daniel & John Storey
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the John M. Daniel, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

@IsTest
public with sharing class ApplicationSObjectUnitOfWorkTest {
    @IsTest
    static void verifyRegisteredRecordListReturnsNewRecordsByType() {
        List<Account> acctList = getAcctList(2);

        //Test register list of new records
        applicationSObjectUOW.register(acctList);

        //Test getting new records registered
        List<Account> returnedAccts = 
            applicationSObjectUOW.getNewRecordsByType(Account.SObjectType);

        System.Assert.areEqual(
            acctList,
            returnedAccts,
            'Account Lists Not Equal'
        );
    }

    @IsTest
    static void verifyRegisterSingleRecordReturnsNewRecordsByType() {
        Account singleAccount = getAcctList(1)[0];

        //Test register single new record
        applicationSObjectUOW.register(singleAccount);

        //Test getting new records registered
        List<Account> returnedAccts = 
            applicationSObjectUOW.getNewRecordsByType(Account.SObjectType);

        //Put Single account in list for assertion
        List<Account> expectedList = new List<Account>{singleAccount};
          
        System.Assert.areEqual(
            expectedList,
            returnedAccts,
            'Account Lists Not Equal'
        );
    }
   
    
    @IsTest
    static void verifyRegisteredRecordListReturnDirtyRecordsByType(){
        List<Account> acctList = getAcctList(2);
		insert acctList;

        //Test register List of Dirty records
        applicationSObjectUOW.register(acctList);

        //Test Return Dirty Records By Type to Map
        Map<Id,SObject> returnedAcctsMap = 
            applicationSObjectUOW.getDirtyRecordsByType(acctList.getSObjectType());

        //Put mapped values to list
        List<Account> returnedAcctsList = returnedAcctsMap.values(); 

        System.Assert.areEqual(
            acctList,
            returnedAcctsList,
            'Lists Do Not Match'
        );
    }

  @IsTest
    static void verifyRegisterSingleRecordReturnDirtyRecordsByType(){
        Account singleAccount = getAcctList(1)[0];
        insert singleAccount;
       
        //Test register single Dirty record
        applicationSObjectUOW.register(singleAccount);

        //Test Return Dirty Records By Type to Map
        Map<Id,SObject> returnedAcctsMap = 
            applicationSObjectUOW.getDirtyRecordsByType(singleAccount.getSObjectType());

        //Put mapped values in list for assertion
        List<Account> returnedAcctsList = returnedAcctsMap.values();

        //Put Single account in list for assertion
        List<Account> expectedList = new List<Account>{singleAccount};

        System.Assert.areEqual(
            expectedList,
            returnedAcctsList,
            'Lists Do Not Match'
        );
    }

  @IsTest
    static void verifyApplicationSobjectUOWConstructorWithDML(){
        Account singleAccount = getAcctList(1)[0];
        insert singleAccount;

       //Mock DML for testing constructor with Type and DML
        MockDML mockDML = new MockDML();
         
        List<Schema.SObjectType> sObjTypes = new List<Schema.SObjectType>();
        sObjTypes.add(Account.SOBjectType);

        ApplicationSObjectUnitOfWork applicationSObjectUOWDML= 
            new ApplicationSObjectUnitOfWork(sObjTypes,mockDML);

        //Test register single Dirty record
        applicationSObjectUOWDML.register(singleAccount);

        //Test Return Dirty Records By Type to Map
        Map<Id,SObject> returnedAcctsMap = 
            applicationSObjectUOWDML.getDirtyRecordsByType(singleAccount.getSObjectType());

        //put mapped values in list for assertion
        List<Account> returnedAcctsList = returnedAcctsMap.values(); 

        //Put Single account in list for assertion
        List<Account> expectedList = new List<Account>{singleAccount};

        System.Assert.areEqual(
            expectedList,
            returnedAcctsList,
            'Lists Do Not Match'
        );
    }

    @IsTest
    static void verifyGetDeletedRecordsByType(){
        List<Account> acctList = getAcctList(2);

        //Register List of records and commit them
        applicationSObjectUOW.register(acctList);
        applicationSObjectUOW.commitWork();

        //Delete registered records
        applicationSObjectUOW.registerDeleted(acctList);

        //Test Return deleted records by type to map
        Map<Id,SObject> returnedDeletedAcctsMap = 
            applicationSObjectUOW.getDeletedRecordsByType(acctList.getSObjectType());

        //Group accounts for assertion
        List<Account> returnedDeletedAcctsList = returnedDeletedAcctsMap.values(); 

        System.Assert.areEqual(
            acctList,
            returnedDeletedAcctsList,
            'Lists Do Not Match'
        );
    }

    @IsTest
    static void verifyRegisterNewWithParentRecord() {

        Contact childContact = new Contact();
        childContact.FirstName = 'sdfeoriwemnnwj';
        childContact.LastName = 'kljasdlkjflajskdf';

        //Create account record to be parent
        Account parentAccount = new Account(name='parentAccount');
        insert parentAccount;

        Schema.SObjectField parentField = Contact.AccountId; 

        //Test register single new record
        applicationSObjectUOW.register(
            childContact,
            parentField,
            parentAccount
        );
        applicationSObjectUOW.commitWork();

        //Test getting new records registered
        List<Contact> returnedContacts = applicationSObjectUOW.getNewRecordsByType(Contact.SObjectType);

        Contact returnedContact = returnedContacts[0];
           
        System.Assert.areEqual(
            parentAccount.Id,
            returnedContact.AccountId,
            'Parent Id Not Equal'
        );
    }

    @IsTest
    static void verifyRegisterDirtyWithParentRecord(){
        //Create account record to be parent
        Account parentAccount = new Account(name='parentAccount');
        insert parentAccount;

        Contact childContact = new Contact();
        childContact.FirstName = 'sdfeoriwemnnwj';
        childContact.LastName = 'kljasdlkjflajskdf';
        insert childContact;

       Schema.SObjectField parentField = Contact.AccountId;

        //Test register single Dirty record
        applicationSObjectUOW.register(
            childContact,
            parentField,
            parentAccount
        );
        applicationSObjectUOW.commitWork();

        //Test Return Dirty Records By Type to Map
        Map<Id,SObject> returnedAcctsMap = applicationSObjectUOW.getDirtyRecordsByType(Contact.SObjectType);

        //Put mapped values in list for assertion
        List<Contact> returnedContactsList = returnedAcctsMap.values();

        Contact returnedContact = returnedContactsList[0];

        System.Assert.areEqual(
            parentAccount.Id,
            returnedContact.AccountId,
            'Lists Do Not Match'
        );
    }

    @IsTest
    private static void verifyRegisterEmails()
    {
        Account singleAccount = getAcctList(1)[0];

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
            applicationSObjectUOW.getNewRecordsByType(singleAccount.getSObjectType()); 

        // assert that mock email functionality was called
        System.Assert.isTrue(((Mock_SendEmailWork) applicationSObjectUOW.m_emailWork).doWorkWasCalled,
            'Email Not Registered'
        );

        System.Assert.areEqual(
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
                Account.SObjectType, 
                Contact.SObjectType
            }
    );

    public static List<Account> getAcctList(Integer numAccts){
        List<Account> acctList = new List<Account>(); 
        for(Integer i=0; i<numAccts; i++){
    	    acctList.add(new Account(Name='TestAccount'+i));
        }
        return acctList;
    }
}