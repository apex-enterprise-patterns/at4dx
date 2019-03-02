/**
 *
 * di_Module based class used to manage the Application Factory mappings of for the SOBject
 */
public class ApplicationSObjectDomainDIModule 
    extends di_Module
{
    public override void configure() 
    {
        Schema.DescribeSobjectResult[] results = null;

        String bindingSObjectAPIName = null;

        list<ApplicationFactory_DomainBinding__mdt> bindingRecords = [select DeveloperName, QualifiedAPIName, To__c
                                                                           , BindingSObject__c, BindingSObject__r.QualifiedApiName, BindingSObjectAlternate__c
                                                                        from ApplicationFactory_DomainBinding__mdt];

        for ( ApplicationFactory_DomainBinding__mdt bindingConfig : bindingRecords)
        {
            bindingSObjectAPIName = String.isNotBlank(bindingConfig.BindingSObject__c) ? bindingConfig.BindingSObject__r.QualifiedApiName : bindingConfig.BindingSObjectAlternate__c;

            apex();
            if (String.isNotBlank(bindingSObjectAPIName)) 
            {
                results = Schema.describeSObjects(new String[] { bindingSObjectAPIName.toLowerCase().trim() });
                if(results.size() != 1) 
                {
                    throw new di_Injector.InjectorException('Failed to find SObject ' + bindingSObjectAPIName 
                                                                 + ' referened by binding ' + bindingConfig.DeveloperName 
                                                                 + ' for ApplicationSObjectDomainDIModule di_Injectory module.');
                }
                bind(results[0].getSObjectType());
                bind(IApplicationSObjectDomain.class);
            }
            data(bindingConfig);
            to(bindingConfig.To__c);
        }
    }
}
