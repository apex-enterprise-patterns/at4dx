/**
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
    @isTest
    private static void accountInsertTwoCriteria() 
    {
        List<DomainProcessBinding__mdt> config = new List<DomainProcessBinding__mdt> {
            new DomainProcessBinding__mdt(
                Label = 'DallasAccountCriteria',
                ClassToInject__c = 'DomainProcessInjectionTest.AccountIsDallasCriteriaTest',
                IsActive__c = true,
                OrderOfExecution__c = 10.10,
                ProcessContext__c = 'Trigger Execution',
                RelatedDomainBindingSObject__c = 'Account',
                TriggerOperation__c = 'Before Insert',
                Type__c = 'Criteria'
            ),
            new DomainProcessBinding__mdt(
                Label = 'RichmondAccountCriteria',
                ClassToInject__c = 'DomainProcessInjectionTest.AccountIsRichmondCriteriaTest',
                IsActive__c = true,
                OrderOfExecution__c = 11.10,
                ProcessContext__c = 'Trigger Execution',
                RelatedDomainBindingSObject__c = 'Account',
                TriggerOperation__c = 'Before Insert',
                Type__c = 'Criteria'
            ),
            new DomainProcessBinding__mdt(
                Label = 'DallasAccountAction',
                ClassToInject__c = 'DomainProcessInjectionTest.DallasAccountActionTest',
                IsActive__c = true,
                OrderOfExecution__c = 10.10,
                ProcessContext__c = 'Trigger Execution',
                RelatedDomainBindingSObject__c = 'Account',
                TriggerOperation__c = 'Before Insert',
                Type__c = 'Action'
            ),
            new DomainProcessBinding__mdt(
                Label = 'RichmondAccountAction',
                ClassToInject__c = 'DomainProcessInjectionTest.RichmondAccountActionTest',
                IsActive__c = true,
                OrderOfExecution__c = 11.10,
                ProcessContext__c = 'Trigger Execution',
                RelatedDomainBindingSObject__c = 'Account',
                TriggerOperation__c = 'Before Insert',
                Type__c = 'Action'
            )
        };

        DomainProcessCoordinator.domainProcesses.addAll(config);

        List<Account> accList = new List<Account> {
            new Account(Name='Test1', BillingCity='Dallas' ),
            new Account(Name='Test2', BillingCity='Dallas' ),
            new Account(Name='Test3', BillingCity='Richmond'),
            new Account(Name='Test4', BillingCity='Richmond')
        };

        fflib_SObjectDomain.Test.Database.onInsert(accList);
        fflib_SObjectDomain.triggerHandler(DomainProcessInjectionTest.AccountsTestDomainConstructor.class);

        /*List<SObject> result = accounts.getChangedRecords(
				new Set<String>
				{
						'Name',
						'BillingCity',
						'BillingState'
				}
		);*/

        /*List<Account> dallasAcccounts = [select Id, Name, BillingCity, BillingState
                                        from Account
                                        where BillingCity = 'Dallas'
                                        and BillingState = 'Texas'];
        List<Account> richmondAccounts = [select Id, Name, BillingCity, BillingState
                                            from Account
                                            where BillingCity = 'Richmond'
                                            and BillingState = 'Virginia'];*/

        /*for (SObject obj : result) {
            Account acc = (Account) obj;
            if (acc.BillingCity == 'Dallas' && acc.BillingState == 'Texas') {
                System.assert(true, 'Account with city Dallas has state correctly set to Texas');
            }
            else if (acc.BillingCity == 'Richmond' && acc.BillingState == 'Virginia') {
                System.assert(true, 'Account with city Richmond has state correctly set to Virginia');
            }
            else {
                System.assert(false, 'Account not matching any criteria');
            }
        }*/
    }

    private with sharing class AccountsTestDomain 
    extends ApplicationSObjectDomain
    {
        public AccountsTestDomain(List<Account> records)
        {
            super(records);

            // don't enforce CRUD security for Account records
            this.Configuration.disableTriggerCRUDSecurity();
        }
    }

    private class AccountsTestDomainConstructor
            implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain Construct(List<SObject> sObjectList)
        {
            return new AccountsTestDomain(sObjectList);
        }
    }

    private class AccountIsDallasCriteriaTest implements IDomainProcessCriteria
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

    private class AccountIsRichmondCriteriaTest implements IDomainProcessCriteria
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

    private class DallasAccountActionTest extends DomainProcessAbstractAction
    {
        public override void runInProcess()
        {
            Account accountRecord = null;

            for ( SObject record : this.records )
            {
                accountRecord = (Account)record;
                accountRecord.BillingState = 'Texas';
            }
        }
    }

    
    private class RichmondAccountActionTest extends DomainProcessAbstractAction
    {
        public override void runInProcess()
        {
            Account accountRecord = null;

            for ( SObject record : this.records )
            {
                accountRecord = (Account)record;
                accountRecord.BillingState = 'Virginia';
            }
        }
    }

}
