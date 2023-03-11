/**
 * Copyright (c) 2021, John M. Daniel & John Storey
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
private class ApplicationSObjectSelectorTest
{
    @IsTest
    private static void getSObjectFieldListTest()
    {
        configureSelectors();

        TestAccountsSelector sel = (TestAccountsSelector) Application.Selector.newInstance(Account.SObjectType);
        List<SObjectField> fieldList = sel.getSObjectFieldList();

        System.Assert.isNotNull(fieldList);
        System.Assert.isFalse(fieldList.isEmpty());
    }

    @IsTest
    private static void selectionInjectionTest()
    {
        configureSelectors();

        TestSelectorMethodParameters queryParams = new TestSelectorMethodParameters();
        queryParams.accountNumberSet = new Set<String>{ '123456' };

        TestAccountsSelector sel = (TestAccountsSelector) Application.Selector.newInstance(Account.SObjectType);
        List<Account> accountList = sel.selectInjection(TestSelectorMethod.class, queryParams);

        System.Assert.isNotNull(accountList);
        System.Assert.isTrue(accountList.isEmpty());
    }

    private static void configureSelectors()
    {
        ApplicationFactory_SelectorBinding__mdt accountsSelectorBinding = new ApplicationFactory_SelectorBinding__mdt();
        accountsSelectorBinding.BindingSObjectAlternate__c = 'Account';
        accountsSelectorBinding.To__c = 'ApplicationSObjectSelectorTest.TestAccountsSelector';

        ApplicationFactory_SelectorBinding__mdt contactsSelectorBinding = new ApplicationFactory_SelectorBinding__mdt();
        contactsSelectorBinding.BindingSObjectAlternate__c = 'Contact';
        contactsSelectorBinding.To__c = 'ApplicationSObjectSelectorTest.TestContactsSelector';

        List<ApplicationFactory_SelectorBinding__mdt> bindingList = new List<ApplicationFactory_SelectorBinding__mdt>
        {
            accountsSelectorBinding,
            contactsSelectorBinding
        };

        ApplicationSObjectSelectorDIModule.bindingRecords.addAll(bindingList);

        // override the selector bindings just in case this method
        //  executes in an org that already has an AccountsSelector.
        Application.Selector.setMock(new TestAccountsSelector());
    }

    public class TestSelectorMethod
        extends AbstractSelectorMethodInjectable
        implements ISelectorMethodInjectable
    {
        public List<SObject> selectQuery()
        {
            TestSelectorMethodParameters params = (TestSelectorMethodParameters) getParams();

            Set<String> accountNumberSet = params.accountNumberSet;

            return Database.query( newQueryFactory().setCondition( Account.AccountNumber + ' in :accountNumberSet').toSOQL() );
        }
    }

    public class TestSelectorMethodParameters
        implements ISelectorMethodParameterable
    {
        public Set<String> accountNumberSet;
    }

    public interface ITestAccountsSelector
        extends IApplicationSObjectSelector
    {
        List<Account> selectById(Set<Id> idSet);
    }

    @TestVisible
    public class TestAccountsSelector 
        extends ApplicationSObjectSelector
        implements ITestAccountsSelector
    {
        public Schema.sObjectType getSObjectType()
        {
            return Account.SObjectType;
        }

        private List<Schema.SObjectField> getAdditionalSObjectFieldList()
        {
            return new List<Schema.SObjectField> { };
        }

        public List<Account> selectById(Set<Id> idSet)
        {
            return (List<Account>) selectSObjectsById( idSet == null ? new Set<Id>() : idSet );
        }
    }
}
