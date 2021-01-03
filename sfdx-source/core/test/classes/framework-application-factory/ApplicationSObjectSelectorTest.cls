@IsTest
private class ApplicationSObjectSelectorTest
{
    @IsTest
    private static void getSObjectFieldListTest()
    {
        configureSelectors();

        TestOnlyClasses.TestAccountsSelector sel = (TestOnlyClasses.TestAccountsSelector) Application.Selector.newInstance(Account.SObjectType);
        List<SObjectField> fieldList = sel.getSObjectFieldList();

        System.assert(fieldList != null);
        System.assertEquals(false, fieldList.isEmpty());
    }

    @IsTest
    private static void selectionInjectionTest()
    {
        configureSelectors();

        TestSelectorMethod.Parameters queryParams = new TestSelectorMethod.Parameters();
        queryParams.accountNumberSet = new Set<String>{ '123456' };

        TestOnlyClasses.TestAccountsSelector sel = (TestOnlyClasses.TestAccountsSelector) Application.Selector.newInstance(Account.SObjectType);
        List<Account> accountList = sel.selectInjection(TestSelectorMethod.class, queryParams);

        System.assert(accountList != null);
        System.assert(accountList.isEmpty());
    }

    private static void configureSelectors()
    {
        ApplicationFactory_SelectorBinding__mdt accountsSelectorBinding = new ApplicationFactory_SelectorBinding__mdt();
        accountsSelectorBinding.BindingSObjectAlternate__c = 'Account';
        accountsSelectorBinding.To__c = 'TestOnlyClasses.TestAccountsSelector';

        ApplicationFactory_SelectorBinding__mdt contactsSelectorBinding = new ApplicationFactory_SelectorBinding__mdt();
        contactsSelectorBinding.BindingSObjectAlternate__c = 'Contact';
        contactsSelectorBinding.To__c = 'TestOnlyClasses.TestContactsSelector';

        List<ApplicationFactory_SelectorBinding__mdt> bindingList = new List<ApplicationFactory_SelectorBinding__mdt>
        {
            accountsSelectorBinding,
            contactsSelectorBinding
        };

        ApplicationSObjectSelectorDIModule.setMock(bindingList);
    }
}
