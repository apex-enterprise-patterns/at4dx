/** //working draft
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
public class DomainProcessInjectionTest
{
    public static AccountsTestDomain lastConstructed;
    public static List<Account> processedRecords = new List<Account>();
    
    @isTest
    private static void accountInsertTwoCriteria() 
    { 
        List<DomainProcessBinding__mdt> config = new List<DomainProcessBinding__mdt> {
            new DomainProcessBinding__mdt(
                Label = 'DallasAccountCriteria',
                ClassToInject__c = 'DomainProcessInjectionTest.AccountIsDallasCriteriaTest',
                IsActive__c = true,
                OrderOfExecution__c = 100853107.10,
                ProcessContext__c = 'TriggerExecution',
                RelatedDomainBindingSObject__c = 'Account',
                TriggerOperation__c = 'Before_Insert',
                Type__c = 'Criteria'
            ),
            new DomainProcessBinding__mdt(
                Label = 'RichmondAccountCriteria',
                ClassToInject__c = 'DomainProcessInjectionTest.AccountIsRichmondCriteriaTest',
                IsActive__c = true,
                OrderOfExecution__c = 110943007.10,
                ProcessContext__c = 'TriggerExecution',
                RelatedDomainBindingSObject__c = 'Account',
                TriggerOperation__c = 'Before_Insert',
                Type__c = 'Criteria'
            ),
            new DomainProcessBinding__mdt(
                Label = 'DallasAccountAction',
                ClassToInject__c = 'DomainProcessInjectionTest.DallasAccountActionTest',
                IsActive__c = true,
                OrderOfExecution__c = 100853107.10,
                ProcessContext__c = 'TriggerExecution',
                RelatedDomainBindingSObject__c = 'Account',
                TriggerOperation__c = 'Before_Insert',
                Type__c = 'Action'
            ),
            new DomainProcessBinding__mdt(
                Label = 'RichmondAccountAction',
                ClassToInject__c = 'DomainProcessInjectionTest.RichmondAccountActionTest',
                IsActive__c = true,
                OrderOfExecution__c = 110943007.10,
                ProcessContext__c = 'TriggerExecution',
                RelatedDomainBindingSObject__c = 'Account',
                TriggerOperation__c = 'Before_Insert',
                Type__c = 'Action'
            )
        };

        DomainProcessCoordinator.setMockDomainProcessBindings(config);

        List<Account> accList = new List<Account> {
            new Account(Name='Test1', BillingCity='Dallas' ),
            new Account(Name='Test2', BillingCity='Dallas' ),
            new Account(Name='Test3', BillingCity='Richmond'),
            new Account(Name='Test4', BillingCity='Richmond')
        };

        fflib_SObjectDomain.Test.Database.onInsert(accList);
        fflib_SObjectDomain.triggerHandler(DomainProcessInjectionTest.AccountsTestDomainConstructor.class);

        List<SObject> result = DomainProcessInjectionTest.lastConstructed.getRecords();

		Assert.areEqual(4, result.size(), '4 records should have been changed');
        
        for (SObject obj : result) {
            Account acc = (Account) obj;
            if (acc.BillingCity == 'Dallas' ) {
                Assert.areEqual(acc.BillingState, 'Texas', 'Account with city Dallas does not have state correctly set to Texas');
            }
            else if (acc.BillingCity == 'Richmond' && acc.BillingState == 'Virginia') {
                Assert.isTrue(true, 'Account with city Richmond does not have state correctly set to Virginia');
            }
            else {
                Assert.isTrue(false, 'Account not matching any criteria');
            }
        }
    }
 
    @isTest
    private static void accountUpdateTwoCriteria() {
        List<DomainProcessBinding__mdt> config = new List<DomainProcessBinding__mdt> {
            new DomainProcessBinding__mdt(
                Label = 'DallasAccountCriteria',
                ClassToInject__c = 'DomainProcessInjectionTest.AccountIsDallasCriteriaTest',
                IsActive__c = true,
                OrderOfExecution__c = 100853107.10,
                ProcessContext__c = 'TriggerExecution',
                RelatedDomainBindingSObject__c = 'Account',
                TriggerOperation__c = 'Before_Update',
                Type__c = 'Criteria'
            ),
            new DomainProcessBinding__mdt(
                Label = 'RichmondAccountCriteria',
                ClassToInject__c = 'DomainProcessInjectionTest.AccountIsRichmondCriteriaTest',
                IsActive__c = true,
                OrderOfExecution__c = 110943007.10,
                ProcessContext__c = 'TriggerExecution',
                RelatedDomainBindingSObject__c = 'Account',
                TriggerOperation__c = 'Before_Update',
                Type__c = 'Criteria'
            ),
            new DomainProcessBinding__mdt(
                Label = 'DallasAccountAction',
                ClassToInject__c = 'DomainProcessInjectionTest.DallasAccountActionTest',
                IsActive__c = true,
                OrderOfExecution__c = 100853107.10,
                ProcessContext__c = 'TriggerExecution',
                RelatedDomainBindingSObject__c = 'Account',
                TriggerOperation__c = 'Before_Update',
                Type__c = 'Action'
            ),
            new DomainProcessBinding__mdt(
                Label = 'RichmondAccountAction',
                ClassToInject__c = 'DomainProcessInjectionTest.RichmondAccountActionTest',
                IsActive__c = true,
                OrderOfExecution__c = 110943007.10,
                ProcessContext__c = 'TriggerExecution',
                RelatedDomainBindingSObject__c = 'Account',
                TriggerOperation__c = 'Before_Update',
                Type__c = 'Action'
            )
        };

        DomainProcessCoordinator.setMockDomainProcessBindings(config);

        List<Account> accList = new List<Account> {
            new Account(Name='Test1', BillingCity='Dallas', Id = fflib_idgenerator.generate(Account.SObjectType) ),
            new Account(Name='Test2', BillingCity='Dallas', Id = fflib_idgenerator.generate(Account.SObjectType) ),
            new Account(Name='Test3', BillingCity='Richmond', Id = fflib_idgenerator.generate(Account.SObjectType)),
            new Account(Name='Test4', BillingCity='Richmond', Id = fflib_idgenerator.generate(Account.SObjectType))
        };

        fflib_SObjectDomain.Test.Database.onUpdate(accList, new Map<Id, SObject>(accList));
        fflib_SObjectDomain.triggerHandler(DomainProcessInjectionTest.AccountsTestDomainConstructor.class);

        List<SObject> result = DomainProcessInjectionTest.lastConstructed.getRecords();
		Assert.areEqual(4, result.size(), '4 records should have been changed');
        for (SObject obj : result) {
            Account acc = (Account) obj;
            if (acc.BillingCity == 'Dallas' && acc.BillingState == 'Texas') {
                Assert.isTrue(true, 'Account with city Dallas does not have state correctly set to Texas');
            }
            else if (acc.BillingCity == 'Richmond' && acc.BillingState == 'Virginia') {
                Assert.isTrue(true, 'Account with city Richmond does not have state correctly set to Virginia');
            }
            else {
                Assert.isTrue(false, 'Account not matching any criteria');
            }
        }
    }

    @isTest
    private static void accountUpdateTwoCriteriaAsync() {
        List<DomainProcessBinding__mdt> config = new List<DomainProcessBinding__mdt> {
            new DomainProcessBinding__mdt(
                Label = 'DallasAccountCriteria',
                ClassToInject__c = 'DomainProcessInjectionTest.AccountIsDallasCriteriaTest',
                IsActive__c = true,
                OrderOfExecution__c = 100853107.10,
                ProcessContext__c = 'TriggerExecution',
                RelatedDomainBindingSObject__c = 'Account',
                TriggerOperation__c = 'Before_Update',
                ExecuteAsynchronous__c = true,
                Type__c = 'Criteria'
            ),
            new DomainProcessBinding__mdt(
                Label = 'RichmondAccountCriteria',
                ClassToInject__c = 'DomainProcessInjectionTest.AccountIsRichmondCriteriaTest',
                IsActive__c = true,
                OrderOfExecution__c = 110943007.10,
                ProcessContext__c = 'TriggerExecution',
                RelatedDomainBindingSObject__c = 'Account',
                TriggerOperation__c = 'Before_Update',
                ExecuteAsynchronous__c = true,
                Type__c = 'Criteria'
            ),
            new DomainProcessBinding__mdt(
                Label = 'DallasAccountAction',
                ClassToInject__c = 'DomainProcessInjectionTest.DallasAccountActionTest',
                IsActive__c = true,
                OrderOfExecution__c = 100853107.10,
                ProcessContext__c = 'TriggerExecution',
                RelatedDomainBindingSObject__c = 'Account',
                TriggerOperation__c = 'Before_Update',
                ExecuteAsynchronous__c = true,
                Type__c = 'Action'
            ),
            new DomainProcessBinding__mdt(
                Label = 'RichmondAccountAction',
                ClassToInject__c = 'DomainProcessInjectionTest.RichmondAccountActionTest',
                IsActive__c = true,
                OrderOfExecution__c = 110943007.10,
                ProcessContext__c = 'TriggerExecution',
                RelatedDomainBindingSObject__c = 'Account',
                TriggerOperation__c = 'Before_Update',
                ExecuteAsynchronous__c = true,
                Type__c = 'Action'
            )
        };

        DomainProcessCoordinator.setMockDomainProcessBindings(config);

        Test.startTest();

        List<Account> accList = new List<Account> {
            new Account(Name='Test1', BillingCity='Dallas', Id = fflib_idgenerator.generate(Account.SObjectType) ),
            new Account(Name='Test2', BillingCity='Dallas', Id = fflib_idgenerator.generate(Account.SObjectType) ),
            new Account(Name='Test3', BillingCity='Richmond', Id = fflib_idgenerator.generate(Account.SObjectType)),
            new Account(Name='Test4', BillingCity='Richmond', Id = fflib_idgenerator.generate(Account.SObjectType))
        };

        fflib_SObjectDomain.Test.Database.onUpdate(accList, new Map<Id, SObject>(accList));
        fflib_SObjectDomain.triggerHandler(DomainProcessInjectionTest.AccountsTestDomainConstructor.class);
        Test.stopTest();

        List<SObject> result = DomainProcessInjectionTest.processedRecords;
		Assert.areEqual(4, result.size(), '4 records should have been changed');
        for (SObject obj : result) {
            Account acc = (Account) obj;
            if (acc.BillingCity == 'Dallas' && acc.BillingState == 'Texas') {
                Assert.isTrue(true, 'Account with city Dallas has state correctly set to Texas');
            }
            else if (acc.BillingCity == 'Richmond' && acc.BillingState == 'Virginia') {
                Assert.isTrue(true, 'Account with city Richmond has state correctly set to Virginia');
            }
            else {
                Assert.isTrue(false, 'Account not matching any criteria');
            }
        }
    }
    
    @isTest
    private static void DomainProcessInjectionMethodTest() 
    { 
        List<DomainProcessBinding__mdt> config = new List<DomainProcessBinding__mdt> {
            new DomainProcessBinding__mdt(
                Label = 'DallasAccountCriteria',
                ClassToInject__c = 'DomainProcessInjectionTest.AccountIsDallasCriteriaTest',
                IsActive__c = true,
                OrderOfExecution__c = 100853107.10,
                ProcessContext__c = 'DomainMethodExecution',
                RelatedDomainBindingSObject__c = 'Account',
                DomainMethodToken__c = 'DallasProcess',
                Type__c = 'Criteria'
            ),
            new DomainProcessBinding__mdt(
                Label = 'RichmondAccountCriteria',
                ClassToInject__c = 'DomainProcessInjectionTest.AccountIsRichmondCriteriaTest',
                IsActive__c = true,
                OrderOfExecution__c = 110943007.10,
                ProcessContext__c = 'DomainMethodExecution',
                RelatedDomainBindingSObject__c = 'Account',
                DomainMethodToken__c = 'RichmondProcess',
                Type__c = 'Criteria'
            ),
            new DomainProcessBinding__mdt(
                Label = 'DallasAccountAction',
                ClassToInject__c = 'DomainProcessInjectionTest.DallasAccountActionTest',
                IsActive__c = true,
                OrderOfExecution__c = 100853107.10,
                ProcessContext__c = 'DomainMethodExecution',
                RelatedDomainBindingSObject__c = 'Account',
                DomainMethodToken__c = 'DallasProcess',
                Type__c = 'Action'
            ),
            new DomainProcessBinding__mdt(
                Label = 'RichmondAccountAction',
                ClassToInject__c = 'DomainProcessInjectionTest.RichmondAccountActionTest',
                IsActive__c = true,
                OrderOfExecution__c = 110943007.10,
                ProcessContext__c = 'DomainMethodExecution',
                RelatedDomainBindingSObject__c = 'Account',
                DomainMethodToken__c = 'RichmondProcess',
                Type__c = 'Action'
            )
        };

        DomainProcessCoordinator.setMockDomainProcessBindings(config);

        List<Account> accList = new List<Account> {
            new Account(Name='Test1', BillingCity='Dallas' ),
            new Account(Name='Test2', BillingCity='Dallas' ),
            new Account(Name='Test3', BillingCity='Richmond'),
            new Account(Name='Test4', BillingCity='Richmond')
        };

        applicationSObjectUOW.register(accList);
        AccountsTestDomain domain = (AccountsTestDomain)new AccountsTestDomainConstructor().Construct(accList);
        DomainProcessCoordinator coord = new DomainProcessCoordinator(domain);
        coord.processDomainLogicInjections('DallasProcess', applicationSObjectUOW);
        //fflib_SObjectDomain.Test.Database.onInsert(accList);
        //fflib_SObjectDomain.triggerHandler(DomainProcessInjectionTest.AccountsTestDomainConstructor.class);

        List<SObject> result = DomainProcessInjectionTest.lastConstructed.getRecords();

		Assert.areEqual(4, result.size(), '4 records should have been changed');
        
        for (SObject obj : result) {
            Account acc = (Account) obj;
            if (acc.BillingCity == 'Dallas' ) {
                Assert.areEqual(acc.BillingState, 'Texas', 'Account with city Dallas does not have state correctly set to Texas');
            }
            else if (acc.BillingCity == 'Richmond') {
                Assert.isNull(acc.BillingState, 'Account with city Richmond does not have null value for State set correctly');
            }
            else {
                Assert.isTrue(false, 'Account not matching any criteria');
            }
        }
    }

    public with sharing class AccountsTestDomain 
    extends ApplicationSObjectDomain
    {
        public AccountsTestDomain(List<Account> records)
        {
            super(records);

            // don't enforce CRUD security for Account records
            this.Configuration.disableTriggerCRUDSecurity();
        }
    }

    public class AccountsTestDomainConstructor
            implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain Construct(List<SObject> sObjectList)
        {
            DomainProcessInjectionTest.lastConstructed = new AccountsTestDomain(sObjectList);
            return DomainProcessInjectionTest.lastConstructed;
        }
    }

    public class AccountIsDallasCriteriaTest implements IDomainProcessCriteria
    {   
        private list<Account> records = new list<Account>();

        public IDomainProcessCriteria setRecordsToEvaluate(List<SObject> records)
        {
            this.records.clear();
            this.records.addAll( (list<Account>)records );

            return this;
        }

        public List<SObject> run()
        {
            list<Account> qualifiedRecords = new list<Account>();

            // Loop through the Account records.
            for ( Account record : this.records )
            {
                if ( record.BillingCity.equals('Dallas') )
                {
                    qualifiedRecords.add( record );
                }
            }

            return qualifiedRecords;
        }
    }

    public class AccountIsRichmondCriteriaTest implements IDomainProcessCriteria
    {
        private list<Account> records = new list<Account>();

        public IDomainProcessCriteria setRecordsToEvaluate(List<SObject> records)
        {
            this.records.clear();
            this.records.addAll( (list<Account>)records );

            return this;
        }

        public List<SObject> run()
        {
            list<Account> qualifiedRecords = new list<Account>();

            // Loop through the Account records.
            for ( Account record : this.records )
            {
                if ( record.BillingCity.equals('Richmond') )
                {
                    qualifiedRecords.add( record );
                }
            }

            return qualifiedRecords;
        }
    }

    public class DallasAccountActionTest extends DomainProcessAbstractAction
    {
        public override void runInProcess()
        {
            Account accountRecord = null;

            for ( SObject record : this.records )
            {
                accountRecord = (Account)record;
                accountRecord.BillingState = 'Texas';
                DomainProcessInjectionTest.processedRecords.add(accountRecord);
            }
        }
    }
    
    public class RichmondAccountActionTest extends DomainProcessAbstractAction
    {
        public override void runInProcess()
        {
            Account accountRecord = null;

            for ( SObject record : this.records )
            {
                accountRecord = (Account)record;
                accountRecord.BillingState = 'Virginia';
                DomainProcessInjectionTest.processedRecords.add(accountRecord);
            }
        }
    }

    public static final ApplicationSObjectUnitOfWork applicationSObjectUOW= 
        new ApplicationSObjectUnitOfWork(
            new List<Schema.SObjectType>{
                Account.SObjectType
            }
    );

    @IsTest
    static void verifyDomainProcessCoordinatorConstructorException(){
        try{
            DomainProcessCoordinator domainProcessCoordinator = new DomainProcessCoordinator(null);
        }catch(DomainProcessCoordinator.ProcessInjectionException ex){
            Assert.areEqual(
                ex.getMessage(),
                'The DomainProcessCoordinator must be used in conjunction with a IApplicationSObjectDomain as a constructor parameter.',
                'Message Does Not Match'
            );
        }
    }

    @IsTest
    static void verifyNewInstanceExceptionWithNullParams(){
        DomainProcessCoordinator domainProcessCoordinator = new DomainProcessCoordinator();
        try{
            domainProcessCoordinator.newInstance(null);
        }catch(di_Binding.BindingException ex){
            Assert.areEqual(
                ex.getMessage(),
                'No params object supplied',
                'Message Does Not Match'
            );
        }
    }   

    @IsTest
    static void verifyNewInstanceExceptionWithBadParams(){
        DomainProcessCoordinator domainProcessCoordinator = new DomainProcessCoordinator();
        try{
            domainProcessCoordinator.newInstance('Test Bad Params');
        }catch(di_Binding.BindingException ex){
            Assert.areEqual(
                ex.getMessage(),
                'The params object must implement IApplicationSObjectDomain',
                'Message Does Not Match'
            );
        }
    }
    
}