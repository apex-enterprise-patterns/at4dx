@IsTest
public class TestDataSupplementDIModule
    extends di_Module
{
    public override void configure()
    {
        Schema.DescribeSobjectResult[] results = null;

        for (TestDataSupplementer__mdt bindingConfig : [select DeveloperName, QualifiedAPIName, BindingSObjectType__c
                                                             , BindingSObjectType__r.QualifiedApiName, SupplementingClass__c 
                                                          from TestDataSupplementer__mdt 
                                                         order by Sequence__c])
        {
            apex();
            if (String.isNotBlank(bindingConfig.BindingSObjectType__c)) 
            {
                results = Schema.describeSObjects(new String[] { bindingConfig.BindingSObjectType__r.QualifiedApiName.toLowerCase().trim() });
                if(results.size() != 1) 
                {
                    throw new di_Injector.InjectorException(
                        'Failed to find SObject ' + bindingConfig.BindingSObjectType__r.QualifiedApiName + 
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
