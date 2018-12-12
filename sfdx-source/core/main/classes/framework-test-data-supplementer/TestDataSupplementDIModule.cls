public class TestDataSupplementDIModule
    extends di_Module
{
    public override void configure()
    {
        Schema.DescribeSobjectResult[] results = null;

        String bindingSObjectAPIName = null;

        for (TestDataSupplementer__mdt bindingConfig : [select DeveloperName, QualifiedAPIName, BindingSObject__c
                                                             , BindingSObject__r.QualifiedApiName, BindingSObjectAlternate__c
                                                             , SupplementingClass__c 
                                                          from TestDataSupplementer__mdt 
                                                         order by Sequence__c])
        {
            apex();

            bindingSObjectAPIName = String.isNotBlank(bindingConfig.BindingSObject__c) ? bindingConfig.BindingSObject__r.QualifiedApiName : bindingConfig.BindingSObjectAlternate__c; 

            if (String.isNotBlank( bindingSObjectAPIName )) 
            {
                results = Schema.describeSObjects(new String[] { bindingSObjectAPIName.toLowerCase().trim() });
                if(results.size() != 1) 
                {
                    throw new di_Injector.InjectorException(
                        'Failed to find SObject ' + bindingSObjectAPIName + 
                        ' referened by binding ' + bindingConfig.DeveloperName + 
                        ' for TestDataSupplementDIModule di_Injection module.');
                }
                bind(results[0].getSObjectType());
                bind(ITestDataSupplement.class);
            }
            data(bindingConfig);
            to(bindingConfig.SupplementingClass__c);
        }
    }
}
